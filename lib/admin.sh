#!/usr/bin/env bash

permission_backup_file(){ echo "$BACKUP_DIR/openclaw-permission-last.json"; }
permission_backup_current(){ step "备份权限配置"; cp -f "$OPENCLAW_CONFIG_FILE" "$(permission_backup_file)" 2>/dev/null || true; }
permission_restore_backup(){ step "恢复权限配置"; [[ -f "$(permission_backup_file)" ]] && cp -f "$(permission_backup_file)" "$OPENCLAW_CONFIG_FILE" && restart_gateway; }
permission_render_status(){ step "查看权限状态"; python3 - "$OPENCLAW_CONFIG_FILE" <<'PY'
import json,sys
try:d=json.load(open(sys.argv[1],'r',encoding='utf-8'))
except Exception as e: print(f'❌ 配置解析失败: {e}'); raise SystemExit(0)
def g(path):
 cur=d
 for p in path.split('.'):
  if isinstance(cur,dict) and p in cur: cur=cur[p]
  else: return '(unset)'
 return cur
for k in ['tools.profile','tools.exec.security','tools.exec.ask','tools.elevated.enabled','commands.bash','tools.exec.applyPatch.enabled','tools.exec.applyPatch.workspaceOnly']:
 print(f'{k}: {g(k)}')
PY
}
permission_apply(){ step "应用权限模式"; local mode="$1"; permission_backup_current; case "$mode" in standard) openclaw config set tools.profile coding; openclaw config set tools.exec.security allowlist; openclaw config set tools.exec.ask on-miss; openclaw config set tools.elevated.enabled false; openclaw config set commands.bash false; openclaw config set tools.exec.applyPatch.enabled false; openclaw config set tools.exec.applyPatch.workspaceOnly true;; developer) openclaw config set tools.profile coding; openclaw config set tools.exec.security allowlist; openclaw config set tools.exec.ask on-miss; openclaw config set tools.elevated.enabled true; openclaw config set commands.bash true; openclaw config set tools.exec.applyPatch.enabled true; openclaw config set tools.exec.applyPatch.workspaceOnly true;; full) openclaw config set tools.profile full; openclaw config set tools.exec.security full; openclaw config set tools.exec.ask off; openclaw config set tools.elevated.enabled true; openclaw config set commands.bash true; openclaw config set tools.exec.applyPatch.enabled true; openclaw config set tools.exec.applyPatch.workspaceOnly true;; defaults) openclaw config unset tools.profile >/dev/null 2>&1 || true; openclaw config unset tools.exec.security >/dev/null 2>&1 || true; openclaw config unset tools.exec.ask >/dev/null 2>&1 || true; openclaw config unset tools.elevated.enabled >/dev/null 2>&1 || true; openclaw config unset commands.bash >/dev/null 2>&1 || true; openclaw config unset tools.exec.applyPatch.enabled >/dev/null 2>&1 || true; openclaw config unset tools.exec.applyPatch.workspaceOnly >/dev/null 2>&1 || true;; esac; restart_gateway || true; }
permission_menu(){ step "权限管理"; while true; do clear; cecho "权限管理"; permission_render_status; echo; cecho "1. 标准安全模式"; cecho "2. 开发增强模式"; cecho "3. 完全开放模式"; cecho "4. 恢复官方默认"; cecho "5. 运行安全审计"; cecho "6. 恢复上次权限备份"; cecho "0. 返回"; read -r -p "请选择：" c; case "$c" in 1) read -r -p "输入 yes 确认：" y; [[ "$y" == "yes" ]] && permission_apply standard; press_enter;; 2) read -r -p "输入 yes 确认：" y; [[ "$y" == "yes" ]] && permission_apply developer; press_enter;; 3) read -r -p "输入 FULL 确认：" y; [[ "$y" == "FULL" ]] && permission_apply full; press_enter;; 4) read -r -p "输入 yes 确认：" y; [[ "$y" == "yes" ]] && permission_apply defaults; press_enter;; 5) openclaw security audit || true; press_enter;; 6) permission_restore_backup; press_enter;; 0) return 0;; *) warn "无效选项"; sleep 1;; esac; done; }

multiagent_json(){ step "获取多智能体列表"; openclaw agents list --json 2>/dev/null || echo '[]'; }
multiagent_render_status(){ python3 - <<'PY' "$(multiagent_json)"
import json,sys
try:a=json.loads(sys.argv[1])
except: a=[]
print(f'已配置智能体数: {len(a)}')
for x in a[:8]: print(f"- {x.get('id','?')} | {x.get('workspace','-')}")
PY
}
multiagent_menu(){ step "多智能体管理"; while true; do clear; cecho "多智能体管理"; multiagent_render_status; echo; cecho "1. 列出智能体"; cecho "2. 新增智能体"; cecho "3. 删除智能体"; cecho "4. 新增路由绑定"; cecho "5. 移除路由绑定"; cecho "6. 查看会话概况"; cecho "7. 健康检查"; cecho "0. 返回"; read -r -p "请选择：" c; case "$c" in 1) openclaw agents list || true; press_enter;; 2) read -r -p "输入 Agent ID：" aid; read -r -p "输入 workspace（默认 ~/.openclaw/workspace-$aid）：" ws; [[ -n "$aid" ]] && openclaw agents add "$aid" --workspace "${ws:-~/.openclaw/workspace-$aid}"; press_enter;; 3) read -r -p "输入 Agent ID：" aid; read -r -p "输入 DELETE 确认：" y; [[ "$y" == "DELETE" && -n "$aid" ]] && openclaw agents delete "$aid"; press_enter;; 4) read -r -p "输入 Agent ID：" aid; read -r -p "输入 bind 值：" bind; [[ -n "$aid" && -n "$bind" ]] && openclaw agents bind --agent "$aid" --bind "$bind"; press_enter;; 5) read -r -p "输入 Agent ID：" aid; read -r -p "输入 bind 值：" bind; [[ -n "$aid" && -n "$bind" ]] && openclaw agents unbind --agent "$aid" --bind "$bind"; press_enter;; 6) find "$OPENCLAW_HOME/agents" -name 'sessions.json' -maxdepth 3 2>/dev/null | sed 's#^#- #'; press_enter;; 7) openclaw config validate || true; find "$OPENCLAW_HOME/agents" -maxdepth 2 -type d 2>/dev/null | sed 's#^#- #'; press_enter;; 0) return 0;; *) warn "无效选项"; sleep 1;; esac; done; }
