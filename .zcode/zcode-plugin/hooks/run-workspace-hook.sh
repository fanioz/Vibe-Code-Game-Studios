#!/usr/bin/env bash
# Generic ZCode hook bridge.
#
# ZCode only executes hooks from user config or plugins (project-level hooks are
# ignored for security), and a hook process may not start in the workspace
# directory. This wrapper:
#   1. reads the ZCode hook JSON from stdin,
#   2. resolves the workspace from the "cwd" field and cds into it,
#   3. re-feeds the original stdin to a workspace hook script,
# so the original Claude Code hooks keep working unchanged.
#
# Usage: run-workspace-hook.sh <workspace-relative-script> [args...]
set -u

SCRIPT_REL="${1:-}"
if [ -z "$SCRIPT_REL" ]; then
    echo "[vcgs-bridge] no hook script given" >&2
    exit 0
fi
shift || true

INPUT=$(cat)

# --- resolve workspace cwd (jq first, grep fallback) ---
CWD=""
if command -v jq >/dev/null 2>&1; then
    CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
fi
if [ -z "$CWD" ]; then
    CWD=$(printf '%s' "$INPUT" | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
fi
if [ -z "$CWD" ] && [ -n "${ZCODE_CWD:-}" ]; then
    CWD="$ZCODE_CWD"
fi
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    cd "$CWD" 2>/dev/null || true
fi

if [ ! -f "$SCRIPT_REL" ]; then
    echo "[vcgs-bridge] hook script not found: $SCRIPT_REL (run from repo root?)" >&2
    exit 0
fi

# --- pass the original stdin through to the workspace hook ---
printf '%s\n' "$INPUT" | bash "$SCRIPT_REL" "$@"
exit $?
