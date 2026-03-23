#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${WEIXIN_AGENT_REPO_DIR:-$HOME/workspace/weixin-agent-sdk}"
ENV_FILE="${WEIXIN_AGENT_ENV_FILE:-$HOME/.config/weixin-agent-openai.env}"

if [[ ! -d "$REPO_DIR" ]]; then
  echo "未找到仓库目录: $REPO_DIR" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "未找到环境变量文件: $ENV_FILE" >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

: "${OPENAI_API_KEY:?请在环境变量文件中设置 OPENAI_API_KEY}"

cd "$REPO_DIR"
exec pnpm --dir packages/example-openai run start
