#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="$REPO_DIR/launchd/ai.weixin-agent-codex.plist.example"
TARGET_PATH="$HOME/Library/LaunchAgents/ai.weixin-agent-codex.plist"
LOG_DIR="$HOME/Library/Logs"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
UID_VALUE="$(id -u)"
LABEL="ai.weixin-agent-codex"

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "未找到 launchd 模板: $TEMPLATE_PATH" >&2
  exit 1
fi

mkdir -p "$LAUNCH_AGENTS_DIR" "$LOG_DIR"

sed "s|YOUR_USER|$USER|g" "$TEMPLATE_PATH" > "$TARGET_PATH"
chmod 644 "$TARGET_PATH"
plutil -lint "$TARGET_PATH" >/dev/null

launchctl bootout "gui/$UID_VALUE" "$TARGET_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$UID_VALUE" "$TARGET_PATH"
launchctl kickstart -k "gui/$UID_VALUE/$LABEL"

echo "已安装并启用 $LABEL"
echo "plist: $TARGET_PATH"
echo "stdout: $LOG_DIR/weixin-agent-codex.log"
echo "stderr: $LOG_DIR/weixin-agent-codex.err.log"
