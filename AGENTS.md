# Vibe Code Game Studios — Agent Instructions (AGENTS.md)

Indie game development managed through 49 coordinated studio subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

> This file is the agent entry point for tools that read `AGENTS.md`
> (**ZCode**, **OpenCode**). It contains no `@import` directives — tools that
> don't expand imports still work. Claude Code users: see `CLAUDE.md`.
> All files describe the same studio system.

## Technology Stack

- **Engine**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5]
- **Language**: [CHOOSE: GDScript / C# / C++ / Blueprint]
- **Version Control**: Git with trunk-based development
- **Build System**: [SPECIFY after choosing engine]
- **Asset Pipeline**: [SPECIFY after choosing engine]

> Engine-specialist agents exist for Godot, Unity, and Unreal with dedicated
> sub-specialists. Use the set matching your engine.

## Project Context — read these files when relevant

ZCode does not expand `@import` directives. Read the following files with the
Read tool at the start of a relevant task:

| Topic | File |
|---|---|
| Project structure | `.claude/docs/directory-structure.md` (also mirrored under `.zcode/docs/`) |
| Engine version reference | `docs/engine-reference/godot/VERSION.md` |
| Technical preferences | `.claude/docs/technical-preferences.md` |
| Coordination rules | `.claude/docs/coordination-rules.md` |
| Coding standards | `.claude/docs/coding-standards.md` |
| Context management | `.claude/docs/context-management.md` |
| Domain rules (code/data/design/audio/tests) | `.claude/rules/<domain>.md` |

`.zcode/` mirrors `docs/` and `rules/` for self-containment (ZCode has no
Claude-compatible scan). `.claude/` is the single source of truth for
OpenCode and Claude Code.

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for the full protocol and examples.

> **First session?** If the project has no engine configured and no game concept,
> invoke the `start` skill (`$start` in ZCode, `/start` in Claude Code) to begin
> the guided onboarding flow.

## Studio System Layout

- **Subagents**: `.zcode/agents/*.md` (49) — ZCode workspace subagents;
  `.opencode/agents/*.md` (49) — OpenCode subagents (`@producer` to invoke);
  `.claude/agents/` is the Claude Code source of truth
- **Skills**: single source `.claude/skills/` — Claude Code runs them as
  `/` commands, OpenCode scans the same folder natively (verified at runtime;
  just ask for the workflow by name), ZCode needs its own mirror at
  `.zcode/skills/` (invoke `$skill-name`) because it has no Claude-compatible scan
- **Hooks**: ZCode → `vcgs-studio-hooks` plugin (`.zcode/zcode-plugin/`);
  OpenCode → `.opencode/plugins/hooks.ts` (auto-loaded); scripts live in
  `.zcode/hooks/` and `.opencode/hooks/`
- **Permissions**: OpenCode → `.opencode/opencode.json` (deny rules ported
  from `.claude/settings.json`); ZCode → deny-guard hook in the plugin
