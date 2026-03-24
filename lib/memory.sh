#!/usr/bin/env bash

memory_status(){ step "查看 Memory 状态"; openclaw memory status 2>/dev/null || echo "未安装/未初始化"; }
memory_backend(){ python3 - "$OPENCLAW_CONFIG_FILE" <<'PY'
import json,sys
try:d=json.load(open(sys.argv[1],'r',encoding='utf-8'))
except Exception: print('未配置'); raise SystemExit(0)
backend=((d.get('memory') or {}).get('backend')) or '未配置'
print('Local' if backend in ('local','builtin') else backend)
PY
}
memory_scheme_apply(){ step "切换 Memory 方案"; local s="$1"; if [[ "$s" == "qmd" ]]; then openclaw config set memory.backend qmd || true; openclaw config set memory.qmd.command qmd || true; else openclaw config set memory.backend builtin || true; openclaw config set agents.defaults.memorySearch.provider local || true; fi; }
memory_setup_local(){ step "准备本地 embedding 模型"; mkdir -p "$OPENCLAW_HOME/models/embedding"; local model="$OPENCLAW_HOME/models/embedding/embeddinggemma-300M-Q8_0.gguf"; if [[ ! -f "$model" ]]; then curl -L --fail --retry 2 -o "$model" "https://huggingface.co/ggml-org/embeddinggemma-300M-GGUF/resolve/main/embeddinggemma-300M-Q8_0.gguf" || warn "模型下载失败，你之后可手动补"; fi; openclaw config set agents.defaults.memorySearch.local.modelPath "$model" || true; }
memory_auto_setup(){ step "自动推荐 Memory 方案"; cecho "自动推荐逻辑：网络受限优先 QMD，否则优先 Local"; local scheme="local"; curl -I -m 2 -s https://huggingface.co >/dev/null 2>&1 || scheme="qmd"; cecho "推荐方案：$scheme"; read -r -p "输入 yes 确认部署：" y; [[ "$y" == "yes" ]] || return 0; if [[ "$scheme" == "qmd" ]]; then npm install -g @tobilu/qmd || true; memory_scheme_apply qmd; else memory_scheme_apply local; memory_setup_local; fi; openclaw memory index --force || true; restart_gateway || true; }
memory_fix_index(){ step "修复 Memory 索引"; cecho "1. 修复当前默认索引"; cecho "2. 全量重建索引"; read -r -p "请选择：" c; case "$c" in 1) openclaw memory index || true;; 2) openclaw memory index --force || true;; *) warn "无效选择"; return 1;; esac; restart_gateway || true; }
memory_view_files(){ step "查看 Memory 文件"; mkdir -p "$WORKSPACE_DIR/memory"; find "$WORKSPACE_DIR" -maxdepth 2 \( -name 'MEMORY.md' -o -path '*/memory/*.md' \) -print | sort || true; }
memory_scheme_menu(){ step "Memory 方案菜单"; while true; do clear; cecho "OpenClaw 记忆方案"; cecho "当前方案: $(memory_backend)"; cecho "1. 切换 QMD"; cecho "2. 切换 Local"; cecho "3. Auto（自动推荐并部署）"; cecho "0. 返回"; read -r -p "请选择：" c; case "$c" in 1) npm install -g @tobilu/qmd || true; memory_scheme_apply qmd; restart_gateway || true; press_enter;; 2) memory_scheme_apply local; memory_setup_local; restart_gateway || true; press_enter;; 3) memory_auto_setup; press_enter;; 0) return 0;; *) warn "无效选项"; sleep 1;; esac; done; }
memory_menu(){ step "Memory 管理"; while true; do clear; cecho "OpenClaw 记忆管理"; memory_status; echo; cecho "1. 更新记忆索引"; cecho "2. 查看记忆文件"; cecho "3. 索引修复"; cecho "4. 记忆方案（QMD/Local/Auto）"; cecho "0. 返回"; read -r -p "请选择：" c; case "$c" in 1) openclaw memory index || true; press_enter;; 2) memory_view_files; press_enter;; 3) memory_fix_index; press_enter;; 4) memory_scheme_menu;; 0) return 0;; *) warn "无效选项"; sleep 1;; esac; done; }
