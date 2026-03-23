#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${WEIXIN_AGENT_REPO_DIR:-$HOME/workspace/weixin-agent-sdk}"

if [[ ! -d "$REPO_DIR" ]]; then
  echo "未找到仓库目录: $REPO_DIR" >&2
  exit 1
fi

cd "$REPO_DIR"
if [[ $# -eq 0 ]]; then
  exec pnpm exec codex login --device-auth
fi

exec pnpm exec codex login "$@"
