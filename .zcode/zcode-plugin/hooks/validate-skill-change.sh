#!/usr/bin/env bash
# ZCode PostToolUse hook: advises running skill-test after skill file changes.
# Ported from Claude Code .claude/hooks/validate-skill-change.sh — this variant
# watches both .zcode/skills/ (ZCode) and .claude/skills/ (Claude Code).
#
# Exit behavior: exit 0 = advisory only (non-blocking)
set -u

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
else
    FILE_PATH=$(printf '%s' "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
fi

# Normalize path separators
FILE_PATH=$(echo "$FILE_PATH" | sed 's|\\|/|g')

# Only act on skill files
if ! echo "$FILE_PATH" | grep -qE '(^|/)\.(zcode|claude)/skills/'; then
    exit 0
fi

SKILL_NAME=$(echo "$FILE_PATH" | grep -oE '\.(zcode|claude)/skills/[^/]+' | sed 's|\.[a-z]*/skills/||')

if [ -z "$SKILL_NAME" ]; then
    exit 0
fi

echo "=== Skill Modified: $SKILL_NAME ===" >&2
echo "Advisory: consider running the skill-test skill to validate '$SKILL_NAME'." >&2
exit 0
