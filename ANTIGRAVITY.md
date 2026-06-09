# Antigravity Compatibility Bridge

This repository is Claude-first, but is fully compatible with **Antigravity (Gemini CLI)** by treating the Claude artifacts as the source of truth, loaded via a symlink as a native Antigravity plugin.

## How it works

The `install.sh` script automatically creates symlinks so that Antigravity can read the Claude configurations natively:
- `.gemini/` -> `.claude/`
- `.agents/` -> `.claude/`
- `GEMINI.md` -> `CLAUDE.md`

By having a `plugin.json` file inside `.claude/` (which resolves to `.gemini/plugin.json`), Antigravity treats this directory as a native **Plugin**. This means:
1. All `.claude/skills/*/SKILL.md` are natively registered as Antigravity Skills.
2. All `.claude/agents/*.md` are natively registered as Antigravity Subagents, which you can spawn using the `invoke_subagent` tool.

## Start Here

1. Read `GEMINI.md` (symlinked to `CLAUDE.md`) for the project-level operating rules.
2. Treat `.gemini/agents/*.md` as role briefs and subagents.
3. Treat `.gemini/skills/*/SKILL.md` as workflow specifications.
4. Treat `.gemini/hooks/*` as validation and lifecycle scripts.
5. Treat `.gemini/docs/*` and `docs/*` as policy, architecture, and workflow references.

## How Antigravity Should Use This System

- Follow the same collaboration model: ask clarifying questions when scope is unclear, present options with tradeoffs, show drafts before finalizing, and request approval before writing files when the change is non-trivial.
- When a task maps to a slash command like `/design-system` or `/team-qa`, you can load the matching skill file from `.gemini/skills/` and execute the workflow natively.
- Use the agent hierarchy as a routing guide: directors define intent, leads own domains, specialists handle implementation details. You can delegate tasks to these specialists using the `invoke_subagent` tool.
- Preserve the project's validation habits. If a skill or hook implies checks, run the equivalent local bash validation before declaring work done.

## Practical Mapping

- `GEMINI.md` -> repo-wide collaboration and governance
- `.gemini/plugin.json` -> registers the repository as an Antigravity plugin
- `.gemini/skills/*` -> task playbooks / native Antigravity skills
- `.gemini/agents/*` -> domain-specific voices / native Antigravity subagents
- `.gemini/hooks/*` -> pre/post action safeguards

## Working Rule

Antigravity should treat the Claude spec as the project operating system. Leverage native features like `invoke_subagent` to orchestrate the 49 defined game development agents, while respecting the collaboration and validation protocols outlined in the documentation.
