#!/usr/bin/env bash
# ZCode PreToolUse deny-guard for Vibe Code Game Studios.
#
# Ports the "permissions.deny" rules from Claude Code settings.json:
#   Bash(rm -rf *), Bash(git push --force*), Bash(git push -f *),
#   Bash(git reset --hard*), Bash(git clean -f*), Bash(sudo *),
#   Bash(chmod 777*), Bash(*>.env*), Bash(cat *.env*), Bash(type *.env*),
#   Read(**/.env*)
#
# Exit 0 = allow; Exit 2 = block (ZCode blocking shortcut, stderr = reason).
set -u

INPUT=$(cat)

get() {
    key="$1"
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$INPUT" | jq -r "$key // empty" 2>/dev/null || true
    else
        leaf=${key##*.}
        printf '%s' "$INPUT" | grep -oE "\"$leaf\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*: *"//;s/"$//'
    fi
}

block() {
    echo "[deny-guard] Blocked by project policy: $1" >&2
    exit 2
}

TOOL=$(get '.tool_name')
case "$TOOL" in
    Bash)
        CMD=$(get '.tool_input.command')
        [ -z "$CMD" ] && exit 0
        case "$CMD" in
            *"rm -rf"*)          block "rm -rf is denied" ;;
            *"git push --force"*) block "force push is denied" ;;
            *"git push -f "*)    block "force push is denied" ;;
            *"git reset --hard"*) block "git reset --hard is denied" ;;
            *"git clean -f"*)    block "git clean -f is denied" ;;
            *"sudo "*)           block "sudo is denied" ;;
            *"chmod 777"*)       block "chmod 777 is denied" ;;
            *">.env"*|*"> .env"*|*">>.env"*|*">> .env"*) block "writing .env files is denied" ;;
            *"cat "*.env*|*"type "*.env*) block "reading .env files via shell is denied" ;;
        esac
        ;;
    Read)
        FP=$(get '.tool_input.file_path')
        [ -z "$FP" ] && exit 0
        BASE=$(basename "$FP")
        case "$BASE" in
            .env*|*.env)
                echo "[deny-guard] Reading .env files is denied by project policy" >&2
                exit 2
                ;;
        esac
        ;;
esac
exit 0
