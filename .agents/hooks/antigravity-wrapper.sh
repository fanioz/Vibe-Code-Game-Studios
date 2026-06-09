#!/bin/bash
# antigravity-wrapper.sh
# Translates Antigravity's Hook I/O contract to Claude Code's Hook I/O contract

HOOK_SCRIPT=$1
if [ -z "$HOOK_SCRIPT" ]; then
    echo '{"decision": "allow"}'
    exit 0
fi

# 1. Read Antigravity JSON payload
INPUT=$(cat)

# 2. Extract command string for Claude
# In Antigravity PreToolUse, toolCall.args.CommandLine exists for run_command
CMD=$(echo "$INPUT" | jq -r '.toolCall.args.CommandLine // empty')

# 3. Construct Claude-compatible JSON payload
if [ -n "$CMD" ]; then
    CLAUDE_INPUT=$(jq -n --arg cmd "$CMD" '{tool_input: {command: $cmd}}')
else
    CLAUDE_INPUT="$INPUT"
fi

# 4. Execute original Claude hook
OUTPUT=$(echo "$CLAUDE_INPUT" | bash ".claude/hooks/$HOOK_SCRIPT" 2>&1)
EXIT_CODE=$?

# 5. Translate exit code back to Antigravity JSON decision
if [ "$HOOK_SCRIPT" == "session-stop.sh" ]; then
    if [ $EXIT_CODE -eq 0 ]; then
        echo '{"decision": "continue", "reason": "Not done yet"}'
    else
        echo '{"decision": "stop"}'
    fi
    exit 0
fi

# For PreToolUse and PostToolUse
if [ $EXIT_CODE -eq 0 ]; then
    echo '{"decision": "allow"}'
elif [ $EXIT_CODE -eq 2 ]; then
    # Exit 2 meant blocked in Claude
    # Safely escape stderr output to JSON string
    REASON=$(echo "$OUTPUT" | jq -R -s -c '.')
    echo "{\"decision\": \"deny\", \"reason\": $REASON}"
else
    echo '{"decision": "allow"}'
fi
