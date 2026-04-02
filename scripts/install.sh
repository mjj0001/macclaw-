#!/usr/bin/env bash
set -euo pipefail
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
BASE_URL="https://raw.githubusercontent.com/mjj0001/macosscript/main"
mkdir -p "$TMP_DIR/lib" "$TMP_DIR/scripts" "$TMP_DIR/docs"

echo "📦 下载主脚本..."
curl -fsSL "$BASE_URL/openclaw-macos-kejilion-rebuild.sh" -o "$TMP_DIR/openclaw-macos-kejilion-rebuild.sh"

echo "📦 下载 lib 模块..."
for f in common.sh core.sh api.sh memory.sh admin.sh backup.sh bot.sh plugin.sh skill.sh; do
  echo "  - $f"
  curl -fsSL "$BASE_URL/lib/$f" -o "$TMP_DIR/lib/$f"
done

chmod +x "$TMP_DIR/openclaw-macos-kejilion-rebuild.sh"
echo "✅ 下载完成，启动..."
exec "$TMP_DIR/openclaw-macos-kejilion-rebuild.sh"
