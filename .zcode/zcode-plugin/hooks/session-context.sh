#!/usr/bin/env bash
# ZCode SessionStart bridge for Vibe Code Game Studios.
#
# Claude Code adds plain-text stdout of SessionStart hooks to the model context.
# ZCode does NOT: non-JSON stdout is treated as diagnostics only. This wrapper
# runs the studio session scripts and repackages their output as the ZCode
# additionalContext JSON envelope.
set -u

INPUT=$(cat)

# --- resolve workspace cwd (jq first, grep fallback) ---
CWD=""
if command -v jq >/dev/null 2>&1; then
    CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
fi
if [ -z "$CWD" ]; then
    CWD=$(printf '%s' "$INPUT" | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
fi
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    cd "$CWD" 2>/dev/null || true
fi

# --- run the studio session scripts (workspace copies, kept live-editable) ---
OUT=""
OUT+="$(bash .zcode/hooks/session-start.sh 2>/dev/null || true)"
OUT+=$'\n'
OUT+="$(bash .zcode/hooks/detect-gaps.sh 2>/dev/null || true)"

# keep the injected context bounded
OUT=$(printf '%s' "$OUT" | head -c 24000)

if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))' <<< "$OUT"
else
    # best-effort fallback without python3
    ESC=$(printf '%s' "$OUT" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk '{printf "%s\\n", $0}')
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$ESC"
fi
