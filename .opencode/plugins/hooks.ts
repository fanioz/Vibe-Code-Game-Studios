import type { Plugin } from "@opencode-ai/plugin"

/**
 * Bridge Claude Code shell hooks (.claude/hooks/*.sh) to OpenCode plugin hooks.
 * Preserves all 12 hooks — maps SessionStart/PreToolUse/PostToolUse/etc. to
 * OpenCode's tool.execute.* / event / experimental.session.compacting.
 *
 * Scripts themselves stay in .opencode/hooks/ (mirrored from .claude/hooks/).
 * This plugin pipes the equivalent JSON input via stdin just like Claude Code does.
 */
export const HooksPlugin: Plugin = async ({ directory, $, client }) => {
  const log = async (level: "info" | "warn" | "error", message: string, extra?: Record<string, unknown>) => {
    try {
      await client.app.log({ body: { service: "hooks", level, message, extra } })
    } catch {}
  }

  // Helper: run a shell hook with optional JSON on stdin. Never throws — hooks are advisory/blocking via exit code.
  const runHook = async (script: string, input?: unknown, opts?: { blockOnExit2?: boolean }): Promise<void> => {
    const scriptPath = `${directory}/${script}`
    try {
      // Use Bun shell: pipe JSON input if provided, otherwise just run.
      if (input !== undefined) {
        const json = JSON.stringify(input)
        // Escape single quotes for sh -c 'echo ... | bash ...'
        await $`bash -c ${`echo ${JSON.stringify(json)} | bash ${JSON.stringify(scriptPath)}`}`.quiet().nothrow()
      } else {
        await $`bash ${scriptPath}`.quiet().nothrow()
      }
    } catch (e) {
      await log("warn", `Hook ${script} failed`, { error: String(e) })
    }
    // For PreToolUse validators we need to surface exit-code-2 as an error to the model.
    // That enforcement is handled per-hook below by checking output.
    void opts
  }

  // Variant that respects blocking semantics: if script exits 2, throw to block tool execution.
  const runBlockingHook = async (script: string, input: unknown): Promise<void> => {
    const scriptPath = `${directory}/${script}`
    const json = JSON.stringify(input)
    try {
      const result = await $`bash -c ${`echo ${JSON.stringify(json)} | bash ${JSON.stringify(scriptPath)}`}`.quiet().nothrow()
      const exitCode = (result as unknown as { exitCode?: number }).exitCode ?? 0
      if (exitCode === 2) {
        const stdout = (result as unknown as { text?: () => string })?.text?.() ?? ""
        const msg = (stdout || `Hook ${script} blocked execution (exit 2)`).trim()
        throw new Error(msg)
      }
      if (exitCode !== 0 && exitCode !== 1) {
        const out = (result as unknown as { text?: () => string })?.text?.() ?? ""
        if (out.trim()) await log("info", `Hook ${script} output`, { output: out.trim().slice(0, 2000) })
      }
    } catch (e) {
      // Re-throw blocking errors, swallow others
      if (e instanceof Error && e.message.includes("blocked execution")) throw e
      await log("warn", `Hook ${script} error`, { error: String(e) })
    }
  }

  return {
    // ── SessionStart → session.created (covers session-start.sh + detect-gaps.sh) ──
    event: async ({ event }) => {
      try {
        if (event.type === "session.created") {
          await log("info", "SessionStart hooks firing")
          await runHook(".opencode/hooks/session-start.sh")
          await runHook(".opencode/hooks/detect-gaps.sh")
        }
        if (event.type === "session.compacted") {
          await runHook(".opencode/hooks/post-compact.sh")
        }
        if (event.type === "session.idle") {
          // Maps Claude's Stop hook — session idle means the agent finished turnaround.
          // session-stop.sh archives active.md and logs git activity.
          await runHook(".opencode/hooks/session-stop.sh")
        }
        if (event.type === "session.error") {
          await log("error", "Session error", { event: (event as unknown as Record<string, unknown>).properties as Record<string, unknown> })
        }
        // Subagent lifecycle → use tool execution as proxy; log via tool events instead (see tool.execute.*).
        // OpenCode has no SubagentStart/Stop events — we also listen to tool events below.

        if ((event.type as string) === "tui.toast.show" || (event.type as string) === "permission.asked") {
          const props = (event as unknown as { properties?: Record<string, unknown> }).properties ?? {}
          const message = (props.message as string) ?? (props.text as string) ?? "OpenCode needs your attention"
          await runHook(".opencode/hooks/notify.sh", { message, ...props })
        }
      } catch (e) {
        await log("warn", "event hook error", { error: String(e) })
      }
    },

    // ── PreToolUse (Bash) → tool.execute.before ──
    "tool.execute.before": async (input, output) => {
      const tool = (input as unknown as { tool?: string }).tool ?? (output as unknown as { tool?: string }).tool
      const args = (output as unknown as { args?: Record<string, unknown> })?.args ?? (input as unknown as { args?: Record<string, unknown> })?.args

      // SubagentStart audit — any tool execution is a proxy for agent activity start
      // We log lightweight; the full Claude SubagentStart payload isn't available.
      // Use output.tool to identify which tool triggered.
      if (tool) {
        // Fire-and-forget log-agent (non-blocking)
        runHook(".opencode/hooks/log-agent.sh", {
          session_id: "opencode",
          agent_type: tool,
          tool,
          args,
        }).catch(() => {})
      }

      // Only validate Bash commands
      if (tool !== "bash") return

      const command = (args?.command as string) ?? ""
      if (!command) return

      // Mirror Claude's PreToolUse matcher: Bash
      // validate-commit.sh and validate-push.sh filter internally on `git commit` / `git push`
      if (command.includes("git commit")) {
        await runBlockingHook(".opencode/hooks/validate-commit.sh", {
          tool_name: "Bash",
          tool_input: { command },
        })
      }
      if (command.includes("git push")) {
        await runBlockingHook(".opencode/hooks/validate-push.sh", {
          tool_name: "Bash",
          tool_input: { command },
        })
      }
    },

    // ── PostToolUse (Write|Edit) → tool.execute.after ──
    "tool.execute.after": async (input, output) => {
      const tool = (input as unknown as { tool?: string }).tool ?? (output as unknown as { tool?: string }).tool
      const args = (output as unknown as { args?: Record<string, unknown> })?.args ?? (input as unknown as { args?: Record<string, unknown> })?.args

      // SubagentStop audit
      if (tool) {
        runHook(".opencode/hooks/log-agent-stop.sh", {
          session_id: "opencode",
          agent_type: tool,
          tool,
        }).catch(() => {})
      }

      // Mirror Claude's PostToolUse matcher: Write|Edit
      if (tool !== "write" && tool !== "edit") return

      const filePath = (args?.filePath as string) ?? (args?.file_path as string) ?? ""
      if (!filePath) return

      const payload = { tool_name: tool === "write" ? "Write" : "Edit", tool_input: { file_path: filePath, filePath } }

      // validate-assets.sh filters on assets/ internally
      await runHook(".opencode/hooks/validate-assets.sh", payload)
      // validate-skill-change.sh watches .claude/skills/ and .zcode/skills/
      await runHook(".opencode/hooks/validate-skill-change.sh", payload)
      // Mirror to .opencode/skills as well (advisory)
      if (filePath.includes(".claude/skills/") || filePath.includes(".zcode/skills/")) {
        await log("info", "Skill file changed (.opencode)", { filePath })
      }
    },

    "experimental.session.compacting": async (_input, output) => {
      try {
        const result = await $`bash ${directory}/.opencode/hooks/pre-compact.sh`.quiet().nothrow()
        const stdout = (result as unknown as { text?: () => string })?.text?.() ?? ""
        if (stdout.trim()) {
          output.context.push(`## Session State Before Compaction (from pre-compact.sh)\n${stdout.trim().slice(0, 8000)}`)
        }
      } catch (e) {
        await log("warn", "pre-compact hook failed", { error: String(e) })
      }
    },
  }
}
