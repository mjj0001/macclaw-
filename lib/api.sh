#!/usr/bin/env bash

provider_health_check(){ step "检查 provider 连通性"; local name="$1"; python3 - "$OPENCLAW_CONFIG_FILE" "$name" <<'PY'
import json,sys,urllib.request
path,name=sys.argv[1:3]
d=json.load(open(path,'r',encoding='utf-8'))
pr=((d.get('models') or {}).get('providers') or {}).get(name)
if not isinstance(pr,dict): print('❌ provider 不存在'); raise SystemExit(2)
base=pr.get('baseUrl'); key=pr.get('apiKey')
if not base or not key: print('❌ provider 缺少 baseUrl/apiKey'); raise SystemExit(3)
req=urllib.request.Request(base.rstrip('/')+'/models',headers={'Authorization':f'Bearer {key}','User-Agent':'Mozilla/5.0'})
with urllib.request.urlopen(req,timeout=8) as resp: resp.read(1024)
print('✅ /models 可访问')
PY
}
provider_add_interactive(){ step "添加 provider"; local provider_name base_url api_key models_json available_models default_model input_model confirm; read -r -p "请输入 Provider 名称: " provider_name; [[ -n "$provider_name" ]] || { warn "Provider 名称不能为空"; return 1; }; read -r -p "请输入 Base URL (如 https://api.xxx.com/v1): " base_url; [[ -n "$base_url" ]] || { warn "Base URL 不能为空"; return 1; }; base_url="${base_url%/}"; read -r -s -p "请输入 API Key: " api_key; echo; [[ -n "$api_key" ]] || { warn "API Key 不能为空"; return 1; }; cecho "🔍 正在获取可用模型列表..."; models_json=$(curl -s -m 10 -H "Authorization: Bearer $api_key" "${base_url}/models" || true); available_models=$(python3 -c 'import sys,json; raw=sys.stdin.read().strip();
try:
 d=json.loads(raw); arr=d.get("data",[]) if isinstance(d,dict) else []; print("\n".join(sorted(str(x.get("id")) for x in arr if isinstance(x,dict) and x.get("id"))))
except Exception:
 pass' <<< "$models_json"); [[ -z "$available_models" ]] && warn "未拉到模型列表，后续只能手动写默认模型"; [[ -n "$available_models" ]] && { cecho "✅ 发现模型："; nl -w2 -s'. ' <<< "$available_models"; }; read -r -p "请输入默认 Model ID 或序号（留空默认第一个）: " input_model; if [[ -z "$input_model" && -n "$available_models" ]]; then default_model=$(printf '%s\n' "$available_models" | head -n1); elif [[ "$input_model" =~ ^[0-9]+$ ]]; then default_model=$(printf '%s\n' "$available_models" | sed -n "${input_model}p"); else default_model="$input_model"; fi; [[ -n "$default_model" ]] || { warn "默认模型不能为空"; return 1; }; read -r -p "是否写入全部可用模型？(y/N): " confirm; python3 - "$OPENCLAW_CONFIG_FILE" "$provider_name" "$base_url" "$api_key" "$default_model" "$available_models" "$confirm" <<'PY'
import json,sys
path,name,url,key,default_model,available,confirm=sys.argv[1:8]
try:d=json.load(open(path,'r',encoding='utf-8'))
except Exception:d={}
providers=d.setdefault('models',{}).setdefault('providers',{})
models=[]
ids=[x for x in available.splitlines() if x.strip()]
if confirm.lower().startswith('y') and ids:
    for mid in ids:
        models.append({'id':mid,'name':f'{name} / {mid}','input':['text','image'],'contextWindow':1048576,'maxTokens':128000,'cost':{'input':0.15,'output':0.60,'cacheRead':0,'cacheWrite':0}})
else:
    models=[{'id':default_model,'name':f'{name} / {default_model}','input':['text','image'],'contextWindow':1048576,'maxTokens':128000,'cost':{'input':0.15,'output':0.60,'cacheRead':0,'cacheWrite':0}}]
providers[name]={'baseUrl':url,'apiKey':key,'api':'openai-completions','models':models}
defs=d.setdefault('agents',{}).setdefault('defaults',{})
defs_models=defs.get('models') if isinstance(defs.get('models'),dict) else {}
defs['models']=defs_models
for m in models: defs_models.setdefault(f"{name}/{m['id']}",{})
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2); open(path,'a',encoding='utf-8').write('\n')
PY
openclaw models set "$provider_name/$default_model" || warn "默认模型设置失败，请稍后手动设置"; restart_gateway || true; cecho "✅ API 已添加"; }
provider_list(){ step "列出 provider"; python3 - "$OPENCLAW_CONFIG_FILE" <<'PY'
import json,sys
p=sys.argv[1]
try:d=json.load(open(p,'r',encoding='utf-8'))
except Exception as e: print(f'❌ 读取配置失败: {e}'); raise SystemExit(0)
providers=((d.get('models') or {}).get('providers') or {})
if not providers: print('ℹ️ 当前未配置任何 API provider。'); raise SystemExit(0)
print('--- 已配置 API 列表 ---')
for i,name in enumerate(sorted(providers),1):
 pr=providers.get(name) or {}
 base=pr.get('baseUrl') or '-'
 api=pr.get('api') or '-'
 models=pr.get('models') if isinstance(pr.get('models'),list) else []
 mc=sum(1 for m in models if isinstance(m,dict) and m.get('id'))
 print(f'[{i}] {name} | API: {base} | 协议: {api} | 模型数量: {mc}')
PY
}
provider_sync(){ step "同步 provider 模型"; read -r -p "请输入要同步的 provider 名称: " name; [[ -n "$name" ]] || { warn "provider 名称不能为空"; return 1; }; provider_health_check "$name"; python3 - "$OPENCLAW_CONFIG_FILE" "$name" <<'PY'
import json,sys,urllib.request
path,name=sys.argv[1],sys.argv[2]
d=json.load(open(path,'r',encoding='utf-8'))
providers=((d.get('models') or {}).get('providers') or {})
pr=providers.get(name)
if not isinstance(pr,dict): print('❌ provider 不存在'); raise SystemExit(2)
base=pr.get('baseUrl'); key=pr.get('apiKey')
if not base or not key: print('❌ provider 缺少 baseUrl/apiKey'); raise SystemExit(3)
req=urllib.request.Request(base.rstrip('/')+'/models',headers={'Authorization':f'Bearer {key}','User-Agent':'Mozilla/5.0'})
with urllib.request.urlopen(req,timeout=12) as resp: raw=resp.read().decode('utf-8','ignore')
obj=json.loads(raw)
ids=[str(x.get('id')) for x in obj.get('data',[]) if isinstance(x,dict) and x.get('id')]
if not ids: print('❌ 上游模型为空'); raise SystemExit(4)
tpl={'input':['text','image'],'contextWindow':1048576,'maxTokens':128000,'cost':{'input':0.15,'output':0.60,'cacheRead':0,'cacheWrite':0}}
pr['models']=[dict(tpl, id=mid, name=f'{name} / {mid}') for mid in ids]
defs=d.setdefault('agents',{}).setdefault('defaults',{})
defs_models=defs.get('models') if isinstance(defs.get('models'),dict) else {}
defs['models']=defs_models
for k in list(defs_models.keys()):
 if isinstance(k,str) and k.startswith(name+'/') and k not in {f'{name}/{x}' for x in ids}: defs_models.pop(k,None)
for mid in ids: defs_models.setdefault(f'{name}/{mid}',{})
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2); open(path,'a',encoding='utf-8').write('\n')
print(f'✅ {name}: 当前 {len(ids)} 个模型')
PY
restart_gateway || true; }
provider_switch_protocol(){ step "切换 provider 协议"; read -r -p "请输入 provider 名称: " name; [[ -n "$name" ]] || return 1; cecho "1. openai-completions"; cecho "2. openai-responses"; read -r -p "请选择：" c; local api=""; [[ "$c" == "1" ]] && api="openai-completions"; [[ "$c" == "2" ]] && api="openai-responses"; [[ -n "$api" ]] || { warn "无效选择"; return 1; }; python3 - "$OPENCLAW_CONFIG_FILE" "$name" "$api" <<'PY'
import json,sys
path,name,api=sys.argv[1:4]
d=json.load(open(path,'r',encoding='utf-8'))
pr=((d.get('models') or {}).get('providers') or {}).get(name)
if not isinstance(pr,dict): print('❌ provider 不存在'); raise SystemExit(2)
pr['api']=api
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2); open(path,'a',encoding='utf-8').write('\n')
print(f'✅ 已更新 {name} 协议为 {api}')
PY
restart_gateway || true; }
provider_delete(){ step "删除 provider"; read -r -p "请输入要删除的 provider 名称: " name; [[ -n "$name" ]] || return 1; read -r -p "输入 DELETE 确认删除：" y; [[ "$y" == "DELETE" ]] || { warn "已取消"; return 0; }; python3 - "$OPENCLAW_CONFIG_FILE" "$name" <<'PY'
import json,sys
path,name=sys.argv[1:3]
d=json.load(open(path,'r',encoding='utf-8'))
providers=((d.get('models') or {}).get('providers') or {})
if name not in providers: print('❌ provider 不存在'); raise SystemExit(2)
providers.pop(name,None)
defs=d.setdefault('agents',{}).setdefault('defaults',{})
defs_models=defs.get('models') if isinstance(defs.get('models'),dict) else {}
defs['models']=defs_models
for k in list(defs_models.keys()):
 if isinstance(k,str) and k.startswith(name+'/'): defs_models.pop(k,None)
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2); open(path,'a',encoding='utf-8').write('\n')
print(f'✅ 已删除 provider: {name}')
PY
restart_gateway || true; }
provider_showcase(){ cat <<'EOF'
🌟 API 厂商推荐
- DeepSeek: https://api-docs.deepseek.com/
- OpenRouter: https://openrouter.ai/
- Kimi: https://platform.moonshot.cn/docs/guide/start-using-kimi-api
- 硅基流动: https://cloud.siliconflow.cn/
- 智谱 GLM: https://www.bigmodel.cn/
- MiniMax: https://www.minimaxi.com/
- NVIDIA: https://build.nvidia.com/settings/api-keys
- Ollama: https://ollama.com/
EOF
}
api_manage_menu(){ while true; do clear; cecho "OpenClaw API 管理"; provider_list; echo; cecho "1. 添加API"; cecho "2. 同步API供应商模型列表"; cecho "3. 切换 API 类型"; cecho "4. 删除API"; cecho "5. 检查 API 连通性"; cecho "6. API 厂商推荐"; cecho "0. 返回"; read -r -p "请选择：" c; case "$c" in 1) provider_add_interactive; press_enter;; 2) provider_sync; press_enter;; 3) provider_switch_protocol; press_enter;; 4) provider_delete; press_enter;; 5) read -r -p "输入 provider 名称：" name; [[ -n "$name" ]] && provider_health_check "$name"; press_enter;; 6) provider_showcase; press_enter;; 0) return 0;; *) warn "无效选项"; sleep 1;; esac; done; }
