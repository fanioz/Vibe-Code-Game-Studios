# Vibe Code Game Studios — Agent Instructions (AGENTS.md)

Indie game development managed through 49 coordinated studio subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

> This file is the ZCode entry point (ZCode reads `AGENTS.md`, not `CLAUDE.md`,
> and does not expand `@import` references). Claude Code users: see `CLAUDE.md`.
> The two files describe the same system.

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
| Project structure | `.zcode/docs/directory-structure.md` |
| Engine version reference | `docs/engine-reference/godot/VERSION.md` |
| Technical preferences | `.zcode/docs/technical-preferences.md` |
| Coordination rules | `.zcode/docs/coordination-rules.md` |
| Coding standards | `.zcode/docs/coding-standards.md` |
| Context management | `.zcode/docs/context-management.md` |
| Domain rules (code/data/design/audio/tests) | `.zcode/rules/<domain>.md` |

Claude Code equivalents live under `.claude/` with identical content.

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

- **Subagents**: `.zcode/agents/*.md` (49 roles) — ZCode workspace subagents;
  `.claude/agents/` is the Claude Code source of truth
- **Skills**: `.zcode/skills/<name>/SKILL.md` — invoke with `$skill-name` in ZCode
- **Hooks**: delivered through the `vcgs-studio-hooks` plugin
  (`.zcode/zcode-plugin/`); scripts live in `.zcode/hooks/`
