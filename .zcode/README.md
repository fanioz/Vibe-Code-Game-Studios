# .zcode — ZCode Configuration (mirror of .claude)

ZCode (Z.ai, harness for GLM-5.3) reads this folder the way Claude Code reads
`.claude/`. Verified against the official docs at <https://zcode.z.ai/en/docs>
(pages: `skill`, `commands`, `subagents`, `hooks`, `plugin`, `qa`, `agents`).

## What maps 1:1

| Claude Code (`.claude/`) | ZCode (`.zcode/`) | Notes |
|---|---|---|
| `skills/<name>/SKILL.md` (70) | `skills/<name>/SKILL.md` | Workspace-level skills, path `<workspace>/.zcode/skills/<name>/SKILL.md`. Invoke with `$skill-name` (also listed in the `/` panel Skills group). Frontmatter extras (`allowed-tools`, `model`, `argument-hint`, `user-invocable`) are silently ignored by ZCode — harmless. |
| `agents/*.md` (49) | `agents/*.md` | Workspace subagents at `<workspace>/.zcode/agents/`. Frontmatter normalized: `model: opus/sonnet/haiku` → `model: inherit` (follows the primary model; CC model names don't exist in ZCode), `tools:` comma-string → YAML list (CC-only `Task` tool dropped — ZCode subagents cannot spawn subagents), CC-only `memory:` key removed. `maxTurns`, `skills`, `disallowedTools` kept. |
| `docs/`, `rules/`, `agent-memory/` | same | Reference material read on demand by agents/skills via the Read tool. All internal references were rewritten `.claude/` → `.zcode/`, so this tree is self-contained. |
| `hooks/*.sh` (12) | `hooks/*.sh` | Scripts kept as the live, editable copies. They only *run* through the plugin below. |

Not copied (no ZCode equivalent):

- `settings.json` — ZCode has no project-level settings.json. Permissions →
  handled by execution modes (Shift+Tab) + "Always Allow/Reject" learning +
  the deny-guard hook in the plugin. Hooks → the plugin below.
- `statusline.sh` — ZCode (desktop ADE) has no `statusLine` setting; its status
  UI is built in.

## Hooks: the `vcgs-studio-hooks` plugin (required)

ZCode **ignores project-level hook configs** (`<workspace>/.zcode/config.json`,
`zcode.json`) for security — hooks only run from user config or a plugin. The
plugin in this repo makes the studio hooks executable:

```
.zcode/marketplace.json                 ← local marketplace manifest
.zcode/zcode-plugin/
├── .zcode-plugin/plugin.json           ← plugin manifest (.zcode-plugin form)
└── hooks/
    ├── hooks.json                      ← event wiring (ZCode format)
    ├── session-context.sh              ← SessionStart: wraps plain-text output
    │                                     into additionalContext JSON
    ├── run-workspace-hook.sh           ← generic bridge: cds to the workspace
    │                                     (from stdin cwd) and execs the live
    │                                     script in .zcode/hooks/
    ├── deny-guard.sh                   ← ports permissions.deny from
    │                                     .claude/settings.json
    └── validate-skill-change.sh        ← watches .zcode/skills/ + .claude/skills/
```

### Install (one-time, per machine)

1. ZCode → Settings → Plugins → **Create → Add marketplace**
2. Choose **local directory** and pick this repo's `.zcode` folder
3. Install **vcgs-studio-hooks** (auto-enabled after install)
4. Start a new session — the SessionStart context banner should appear in the
   first model turn

Because `run-workspace-hook.sh` executes the scripts in `.zcode/hooks/` live,
future edits to those scripts take effect without reinstalling the plugin
(new session required — hook config is snapshotted at session start).

### Event mapping (Claude Code → ZCode)

| CC event | ZCode event | Status |
|---|---|---|
| SessionStart (`session-start.sh`, `detect-gaps.sh`) | `SessionStart` | ✅ via `session-context.sh` (ZCode ignores non-JSON stdout; output is wrapped in `additionalContext`) |
| PreToolUse Bash (`validate-commit.sh`, `validate-push.sh`) | `PreToolUse` matcher `Bash` | ✅ same stdin JSON contract, same exit-code semantics (2 = block) |
| PostToolUse Write\|Edit (`validate-assets.sh`, `validate-skill-change.sh`) | `PostToolUse` matcher `Write\|Edit` | ✅ |
| Stop (`session-stop.sh`) | `Stop` | ✅ |
| Notification (`notify.sh`) | — | ❌ no ZCode event; the desktop app notifies natively |
| PreCompact / PostCompact (`pre-compact.sh`, `post-compact.sh`) | — | ❌ no ZCode events (compaction is automatic; `/compact` exists as a command) |
| SubagentStart / SubagentStop (`log-agent*.sh`) | — | ❌ no ZCode events in the current version |

ZCode hook events: `SessionStart, UserPromptSubmit, PreToolUse,
PermissionRequest, PostToolUse, PostToolUseFailure, Stop`.

### Permissions (from `.claude/settings.json`)

- **deny** rules are enforced by the `deny-guard.sh` PreToolUse hook (exit 2 +
  stderr reason): `rm -rf`, `git push --force`, `git push -f`, `git reset
  --hard`, `git clean -f`, `sudo`, `chmod 777`, writes into `.env`, shell reads
  of `.env`, and Read of `.env*` files.
- **allow** rules (read-only git commands etc.) have no project-level
  equivalent; in ZCode use "Always Allow" / "Full access" per your trust level.

## Skills & commands

The studio's "commands" (`/start`, `/sprint-plan`, …) are implemented as
`user-invocable` **skills** in this repo. ZCode surfaces skills in the `/`
panel's Skills group and via `$skill-name` — so command parity is covered
without a separate `.zcode/commands/` folder (the repo has no
`.claude/commands/` to port).

## Subagent fallback

Workspace-level subagents load from `.zcode/agents/`. If a ZCode update
changes discovery (Settings → Subagents should list them as workspace
agents), copy or symlink them to the user level:

```bash
mkdir -p ~/.zcode/agents && cp .zcode/agents/*.md ~/.zcode/agents/
```

## Root file ZCode requires

ZCode reads **`AGENTS.md`** at the workspace root (not `CLAUDE.md`, and it does
not expand `@import`s). The repo-root `AGENTS.md` carries the studio rules and
points the agent at the reference docs. Claude Code ignores it harmlessly.
