#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="OpenClaw"
SCRIPT_VERSION="v0.3.1-modular"
OPENCLAW_NPM_PACKAGE="openclaw@latest"
OPENCLAW_HOME="${HOME}/.openclaw"
OPENCLAW_CONFIG_FILE="${OPENCLAW_HOME}/openclaw.json"
WORKSPACE_DIR="${OPENCLAW_HOME}/workspace"
BACKUP_DIR="${OPENCLAW_HOME}/backups"
LAUNCH_AGENT_PLIST="${HOME}/Library/LaunchAgents/ai.openclaw.gateway.plist"
LAST_ERROR_STEP="初始化"
TEST_MODE="${OPENCLAW_TEST_MODE:-0}"

cecho(){ printf '%s\n' "$*"; }
warn(){ printf '⚠️ %s\n' "$*"; }
die(){ printf '❌ %s\n' "$*" >&2; exit 1; }
press_enter(){ read -r -p "按回车继续..." _; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || die "缺少命令: $1"; }
step(){ LAST_ERROR_STEP="$1"; }
trap 'rc=$?; if [ $rc -ne 0 ]; then printf "\n❌ 失败步骤：%s\n" "$LAST_ERROR_STEP" >&2; printf "💡 建议先看上方报错，再决定重试哪一步。\n" >&2; fi' ERR

ensure_macos(){ step "检查系统"; if [[ "$TEST_MODE" == "1" ]]; then return 0; fi; [[ "$(uname -s)" == "Darwin" ]] || die "这个脚本只支持 macOS。"; }
load_brew_env(){ [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || true; [[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)" || true; }
ensure_xcode_clt(){ step "检查 Xcode CLT"; xcode-select -p >/dev/null 2>&1 || { xcode-select --install || true; die "请先安装 Xcode Command Line Tools。"; }; }
ensure_homebrew(){ step "检查 Homebrew"; command -v brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; load_brew_env; need_cmd brew; }
install_dependencies(){ step "安装依赖"; brew update; brew install git jq node python tmux coreutils gnu-tar sqlite || true; }
configure_npm_registry_if_needed(){ step "配置 npm 镜像"; local c=""; c=$(curl -fsSL --max-time 3 ipinfo.io/country 2>/dev/null || true); [[ "$c" == "CN" || "$c" == "HK" ]] && npm config set registry https://registry.npmmirror.com || true; }
ensure_openclaw_dirs(){ step "创建目录"; mkdir -p "$OPENCLAW_HOME" "$WORKSPACE_DIR" "$BACKUP_DIR" "$OPENCLAW_HOME/logs" "$(dirname "$LAUNCH_AGENT_PLIST")"; }
ensure_openclaw_config(){ step "准备配置文件"; ensure_openclaw_dirs; [[ -f "$OPENCLAW_CONFIG_FILE" ]] || printf '{}\n' > "$OPENCLAW_CONFIG_FILE"; }

self_check(){
  step "环境自检"
  clear
  cecho "======================================="
  cecho "🔍 环境自检"
  cecho "======================================="
  cecho "脚本版本: $SCRIPT_VERSION"
  cecho "测试模式: $TEST_MODE"
  cecho "系统: $(sw_vers -productName 2>/dev/null || uname -s) $(sw_vers -productVersion 2>/dev/null || true)"
  cecho "架构: $(uname -m)"
  echo
  for cmd in bash curl python3 git; do
    if command -v "$cmd" >/dev/null 2>&1; then echo "✅ $cmd: $(command -v "$cmd")"; else echo "❌ $cmd: 未安装"; fi
  done
  if xcode-select -p >/dev/null 2>&1; then echo "✅ Xcode CLT: 已安装"; else echo "❌ Xcode CLT: 未安装"; fi
  load_brew_env
  if command -v brew >/dev/null 2>&1; then echo "✅ brew: $(command -v brew)"; else echo "❌ brew: 未安装"; fi
  if command -v node >/dev/null 2>&1; then echo "✅ node: $(node -v 2>/dev/null)"; else echo "❌ node: 未安装"; fi
  if command -v npm >/dev/null 2>&1; then echo "✅ npm: $(npm -v 2>/dev/null)"; else echo "❌ npm: 未安装"; fi
  if command -v openclaw >/dev/null 2>&1; then echo "✅ openclaw: $(command -v openclaw)"; else echo "⚠️ openclaw: 未安装"; fi
  echo
  press_enter
}

json_update_base(){
step "写基础配置"
python3 - "$OPENCLAW_CONFIG_FILE" <<'PY'
import json,sys
p=sys.argv[1]
try:d=json.load(open(p,'r',encoding='utf-8'))
except Exception:d={}
d.setdefault('tools',{})
d['tools'].setdefault('profile','full')
d['tools'].setdefault('elevated',{})
d['tools']['elevated'].setdefault('enabled',True)
d.setdefault('session',{})
d['session']['dmScope']=d['session'].get('dmScope','per-channel-peer')
d['session']['resetTriggers']=['/new','/reset']
d['session']['reset']={'mode':'idle','idleMinutes':10080}
d['session']['resetByType']={'direct':{'mode':'idle','idleMinutes':10080},'thread':{'mode':'idle','idleMinutes':1440},'group':{'mode':'idle','idleMinutes':120}}
d.setdefault('gateway',{})
d['gateway'].setdefault('controlUi',{})
d['gateway']['controlUi'].setdefault('allowedOrigins',['http://127.0.0.1'])
json.dump(d,open(p,'w',encoding='utf-8'),ensure_ascii=False,indent=2); open(p,'a',encoding='utf-8').write('\n')
PY
}
