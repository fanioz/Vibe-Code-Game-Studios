# Codex Compatibility Bridge

This repository is Claude-first, but Codex can still benefit from the same studio system by treating the Claude artifacts as source of truth.

## Start Here

1. Read [CLAUDE.md](/Users/fanioz/code/Vibe-Code-Game-Studios/CLAUDE.md) for the project-level operating rules.
2. Treat `.claude/agents/*.md` as role briefs.
3. Treat `.claude/skills/*/SKILL.md` as workflow specifications.
4. Treat `.claude/hooks/*` as validation and lifecycle scripts.
5. Treat `.claude/docs/*` and `docs/*` as policy, architecture, and workflow references.

## How Codex Should Use This System

- Follow the same collaboration model: ask clarifying questions when scope is unclear, present options with tradeoffs, show drafts before finalizing, and request approval before writing files when the change is non-trivial.
- When a task maps to a Claude slash command like `/design-system` or `/team-qa`, read the matching skill file and execute the workflow directly instead of expecting the slash command to exist.
- Use the agent hierarchy as a routing guide: directors define intent, leads own domains, specialists handle implementation details.
- Preserve the project's validation habits. If a skill or hook implies checks, run the equivalent local validation before declaring work done.

## Practical Mapping

- `CLAUDE.md` -> repo-wide collaboration and governance
- `.claude/skills/*` -> task playbooks
- `.claude/agents/*` -> domain-specific voices and constraints
- `.claude/hooks/*` -> pre/post action safeguards
- `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` -> user-driven interaction protocol

## Working Rule

Codex should treat the Claude spec as the project operating system, not as a UI dependency. If a Claude-native feature cannot be invoked directly, follow the underlying documented workflow instead.
