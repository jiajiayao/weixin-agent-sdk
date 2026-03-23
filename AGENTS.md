# AGENTS.md

This repository contains a WeChat-to-agent bridge plus local operational wrappers for headless macOS deployments.

## Scope

- `packages/sdk`: core WeChat bridge SDK
- `packages/agent-acp`: ACP adapter published as `weixin-acp`
- `packages/example-openai`: OpenAI example agent
- repo root scripts: operational wrappers for Codex/OpenAI auth and startup
- `install-launchd-codex.sh`: install and enable the checked-in Codex launchd template
- `launchd/`: checked-in example service templates

## Runtime assumptions

- Node.js `>= 22`
- `pnpm` via Corepack
- headless or remote machines should prefer device auth for Codex
- WeChat login is QR-based

## Important workflows

### Install

```bash
corepack enable
corepack prepare pnpm@latest --activate
pnpm install
```

### Build

`packages/example-openai` depends on the local SDK package export, so build `packages/sdk` before running or typechecking that package:

```bash
pnpm --dir packages/sdk run build
```

### Typecheck

```bash
pnpm run typecheck
pnpm run typecheck:example-openai
pnpm run typecheck:agent-acp
```

### Codex account-auth flow

```bash
./codex-account-login.sh
./weixin-codex-login.sh
./weixin-codex-start.sh
./install-launchd-codex.sh
```

### OpenAI API-key flow

```bash
./weixin-openai-login.sh
./weixin-openai-start.sh
```

## State and secrets

Do not commit secrets or machine state.

Relevant paths:

- `~/.openclaw/openclaw-weixin/`
- `~/.codex/`
- `~/.config/weixin-agent-openai.env`
- `~/Library/LaunchAgents/`
- `~/Library/Logs/`

Never commit:

- API keys
- logged-in account state
- generated launchd files with real usernames
- machine-local logs

Commit only templates and examples.

## Editing guidance

- Keep root scripts thin; business logic belongs in packages unless the change is purely operational.
- Prefer documenting operational behavior in `README.md` whenever adding new wrapper scripts.
- If you change auth or startup behavior, update both `README.md` and `launchd/` examples.
- If you change launchd behavior, update `install-launchd-codex.sh` too.
- If you change `packages/example-openai`, verify `packages/sdk` is built and the example still typechecks.

## Validation checklist

Before shipping changes, run:

```bash
pnpm --dir packages/sdk run build
pnpm --dir packages/example-openai run typecheck
pnpm --dir packages/agent-acp run typecheck
```

For operational changes, also verify:

- `./codex-account-login.sh status`
- `./weixin-codex-start.sh` fails only on expected auth preconditions when not configured
- launchd plist examples still pass `plutil -lint`
