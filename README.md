# weixin-agent-sdk

> This repository is not an official WeChat project. It is adapted from [@tencent-weixin/openclaw-weixin](https://npmx.dev/package/@tencent-weixin/openclaw-weixin) for learning, experimentation, and self-hosted integrations.

Bridge WeChat to AI agents through a small SDK, an ACP adapter, and ready-to-run headless scripts for macOS.

> Highlight: this fork supports **Codex account sign-in on a headless machine** through the OpenAI device-auth flow. In practice, you run `./codex-account-login.sh`, open the device-auth URL in a browser, and complete the authorization without managing API keys.

## What this fork adds

- Headless `Codex + WeChat` flow for macOS via device-code / browser authorization
- `OpenAI + WeChat` wrapper scripts and env-file based startup
- `launchd` templates for long-running background services
- One-command `launchd` installer for Codex autostart
- Documentation for state paths, auth flows, and operational setup

## Repository layout

```text
packages/
  sdk/                  Core WeChat bridge SDK
  agent-acp/            ACP adapter published as weixin-acp
  example-openai/       OpenAI example agent

launchd/
  ai.weixin-agent-codex.plist.example
  ai.weixin-agent-openai.plist.example

codex-account-login.sh  Codex account login (device auth)
codex-acp-run.sh        Local ACP wrapper for Codex
install-launchd-codex.sh Install and enable macOS autostart for Codex flow
weixin-codex-login.sh   WeChat QR login for ACP flow
weixin-codex-start.sh   Start weixin-acp with codex-acp
weixin-openai-login.sh  WeChat QR login for OpenAI example
weixin-openai-start.sh  Start the OpenAI example with env file
weixin-agent-openai.env.example
```

## Requirements

- macOS or Linux
- Node.js `>= 22`
- `pnpm` via Corepack or global install

Recommended:

```bash
corepack enable
corepack prepare pnpm@latest --activate
pnpm install
```

If you want to run `packages/example-openai`, build the SDK once after install:

```bash
pnpm --dir packages/sdk run build
```

## Quickstart

### Option A: Codex account auth + WeChat QR login

This is the recommended path for a headless Mac that should run on a ChatGPT plan instead of API keys.
It is the most important flow in this fork.

Install dependencies:

```bash
pnpm install
```

Log Codex in with device auth:

```bash
./codex-account-login.sh
```

This prints a device-auth URL and one-time code. Open the URL in a browser, sign in to ChatGPT, and finish the authorization flow.
This is effectively the "Codex scan / authorize login" flow for remote and headless machines.

Check current status:

```bash
./codex-account-login.sh status
```

Connect WeChat by QR code:

```bash
./weixin-codex-login.sh
```

Start the bot:

```bash
./weixin-codex-start.sh
```

What this does:

- `weixin-codex-login.sh` runs `weixin-acp login`
- `weixin-codex-start.sh` runs `weixin-acp start -- ./codex-acp-run.sh`
- `codex-acp-run.sh` runs `codex-acp`, which wraps the local `codex` CLI over ACP
- `install-launchd-codex.sh` installs and enables macOS autostart for this flow

### Option B: OpenAI API key + WeChat QR login

Copy and edit the env template:

```bash
cp weixin-agent-openai.env.example ~/.config/weixin-agent-openai.env
chmod 600 ~/.config/weixin-agent-openai.env
```

Set at least:

```bash
OPENAI_API_KEY=...
OPENAI_MODEL=gpt-5.4
```

Connect WeChat by QR code:

```bash
./weixin-openai-login.sh
```

Start the example:

```bash
./weixin-openai-start.sh
```

### Option C: Claude via ACP

The ACP adapter for Claude does not provide account-based auth in its published README. Use it only if you are willing to supply `ANTHROPIC_API_KEY`.

Typical flow:

```bash
pnpm add -w @zed-industries/claude-agent-acp
pnpm exec weixin-acp login
pnpm exec weixin-acp start -- pnpm exec claude-agent-acp
```

## Root helper scripts

These wrappers exist to keep remote/headless setup simple:

- `./codex-account-login.sh`
- `./weixin-codex-login.sh`
- `./weixin-codex-start.sh`
- `./weixin-openai-login.sh`
- `./weixin-openai-start.sh`

Equivalent root package scripts are also provided:

```bash
pnpm run codex:login
pnpm run launchd:install:codex
pnpm run weixin:login:codex
pnpm run weixin:start:codex
pnpm run weixin:login:openai
pnpm run weixin:start:openai
```

## launchd setup

Example templates live in:

- `launchd/ai.weixin-agent-codex.plist.example`
- `launchd/ai.weixin-agent-openai.plist.example`

Copy the template you want to `~/Library/LaunchAgents/`, replace `YOUR_USER`, then load it:

```bash
cp launchd/ai.weixin-agent-codex.plist.example ~/Library/LaunchAgents/ai.weixin-agent-codex.plist
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/ai.weixin-agent-codex.plist
launchctl kickstart -k "gui/$(id -u)/ai.weixin-agent-codex"
```

To inspect logs:

```bash
tail -f ~/Library/Logs/weixin-agent-codex.log
tail -f ~/Library/Logs/weixin-agent-codex.err.log
```

If you want the repository to install Codex autostart for you, use:

```bash
./install-launchd-codex.sh
```

or:

```bash
pnpm run launchd:install:codex
```

## Development

Useful commands:

```bash
pnpm run build:sdk
pnpm run build:agent-acp
pnpm run typecheck
pnpm run typecheck:example-openai
pnpm run typecheck:agent-acp
```

Notes:

- `packages/example-openai` imports the local workspace SDK package, so `packages/sdk` must be built first.
- `weixin-acp` is the published package name for `packages/agent-acp`.
- The root shell wrappers are intentionally thin and safe to use over SSH.

## WeChat state and credentials

WeChat-related state is typically stored under:

```text
~/.openclaw/openclaw-weixin/
```

Important data includes:

- account tokens
- account index
- sync buffers for long polling

Codex auth state is typically stored under:

```text
~/.codex/
```

OpenAI example env file is expected at:

```text
~/.config/weixin-agent-openai.env
```

## Security

Do not commit any of the following:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- generated account tokens under `~/.openclaw/`
- Codex login state under `~/.codex/`
- machine-specific `~/Library/LaunchAgents/*.plist`

Commit only:

- scripts
- templates
- docs
- source changes

## Supported message types

Inbound:

- text
- image
- audio
- video
- file
- quoted messages

Outbound:

- text
- image
- video
- file
- text + media

## Slash commands

Built-in WeChat slash commands include:

- `/echo <message>`
- `/toggle-debug`

## References

- [ACP overview](https://agentclientprotocol.com/)
- [weixin-acp on npm](https://www.npmjs.com/package/weixin-acp)
- [codex-acp on npm](https://www.npmjs.com/package/@zed-industries/codex-acp)
- [claude-agent-acp on npm](https://www.npmjs.com/package/@zed-industries/claude-agent-acp)
- [OpenAI Codex CLI](https://www.npmjs.com/package/@openai/codex)
