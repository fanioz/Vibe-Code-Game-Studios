# .opencode — OpenCode Configuration

OpenCode (opencode.ai, v1.18+) loads this folder natively. Verified against the
official docs (agents / skills / commands / plugins / permissions / config) and
tested with the installed binary (`opencode debug skill|agent|config|startup`).

## What maps where

| Claude Code (`.claude/`) | OpenCode (`.opencode/`) | Notes |
|---|---|---|
| `agents/*.md` (49) | `agents/*.md` | Frontmatter converted from the Claude Code source: `description`, `mode: subagent`, `permission:` block. No `model:` — subagents inherit the invoking primary agent's model (CC's `model: opus/sonnet` has no OpenCode equivalent). CC `maxTurns` / `memory:` / `skills:` keys dropped (no OpenCode equivalent; frontmatter schema: `name, model, variant, description, mode, hidden, color, steps, options, permission, disable, temperature, top_p`). Invoke with `@agent-name` or let the primary delegate. |
| `skills/*/SKILL.md` (73) | *read in place from `.claude/skills/`* | OpenCode natively scans project `.claude/skills/` (Claude-compatible path) — verified at runtime: a real session lists all 73 skills with zero duplicates. Skills keep a single source of truth; no copy here. Loaded via the native `skill` tool; frontmatter extras (`allowed-tools`, `model`, `user-invocable`, `argument-hint`) are ignored. |
| `hooks/*.sh` (12) | `hooks/*.sh` | Live scripts; executed by the plugin. |
| — | `plugins/hooks.ts` | TypeScript plugin (auto-loaded from `.opencode/plugins/`) bridging Claude Code hook semantics to OpenCode's plugin API. Deps: `@opencode-ai/plugin` (type-only import — works without install). |
| `settings.json` permissions | `opencode.json` | `permission.bash` glob rules port the deny list (rm -rf, force push, reset --hard, clean -f, sudo, chmod 777, .env writes/reads) and the read-only git allow list; `permission.read` blocks `.env*` reads. Last matching rule wins. |
| `docs/`, `rules/`, `agent-memory/` | *read in place from `.claude/`* | Agents and hook scripts reference `.claude/…` directly — single source, no mirrors. |
| `CLAUDE.md` (repo root) | `../AGENTS.md` | OpenCode reads `AGENTS.md` (root, walking up from cwd). It also reads `CLAUDE.md` as a fallback only when no `AGENTS.md` exists. |

## Hook mapping (plugins/hooks.ts)

| Claude Code event | OpenCode mechanism |
|---|---|
| SessionStart (`session-start.sh`, `detect-gaps.sh`) | `event` → `session.created` (side effects run; stdout is *not* injected into context — see note) |
| PreToolUse Bash (`validate-commit.sh`, `validate-push.sh`) | `tool.execute.before`, exit 2 → throw (blocks the tool call, message surfaces to the model) |
| PostToolUse Write\|Edit (`validate-assets.sh`, `validate-skill-change.sh`) | `tool.execute.after` |
| Stop (`session-stop.sh`) | `event` → `session.idle` |
| PreCompact (`pre-compact.sh`) | `experimental.session.compacting` (stdout injected as context) |
| PostCompact (`post-compact.sh`) | `event` → `session.compacted` |
| Notification (`notify.sh`) | `event` → `permission.asked` / `tui.toast.show` |
| SubagentStart/Stop (`log-agent*.sh`) | proxied on `tool.execute.*` (no native subagent events) |

**Note:** Claude Code injects SessionStart hook stdout into the model context;
OpenCode has no direct equivalent for session start. The essential recovery
state is covered declaratively: the session-start script archives
`production/session-state/active.md`, and `AGENTS.md` points agents at it.
Everything else the script printed (branch, sprint, bug count) is information
the agent can query itself.

## Notes

- **Skill discovery note**: `opencode debug skill` (v1.18.20) prints a
  truncated, random subset — do not use it to judge what a session sees.
  Verified via a real `opencode run` session: all 73 studio skills + global
  skills load with no duplicates. The oh-my-openagent setup also injects a
  local `skills.urls` server; if that daemon is down, restart the OpenCode
  TUI so it re-resolves.
- **No commands needed**: OpenCode has no user-invocable skill slash commands;
  the `skill` tool discovers and loads skills on demand from descriptions.
- **Config**: `.opencode/opencode.json` is a valid project-config location
  (merged with `opencode.json` at root if present). Restart OpenCode after
  editing config/agents/skills — nothing hot-reloads.
- `package.json` is gitignored by `.opencode/.gitignore`; the plugin's
  `@opencode-ai/plugin` import is type-only, so it transpiles fine without
  `bun install`.
