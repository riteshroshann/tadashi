---
name: models
description: Model and effort policy for every session. Use before spawning any subagent, Agent call, fork or workflow, and whenever deciding how hard to think. The lead runs on Opus 5.5 at low effort, rising to medium only for important work; every subagent runs on Sonnet 5.5, never Opus.
---

# Models

## The lead session

- **Default: Opus 5.5 at low effort.** Set in `settings.json` (`model`, `modelSettings.claude-opus-5-5.effortLevel`).
- **Medium only when it matters**: architecture or design decisions, hard bugs, security, data loss risk, anything shipped to others (a submission, a release, a public repo). If the task needs it, tell the user in one line to run `/effort medium`, and drop back to low after.
- **Never high, xhigh or max** unless the user asks for it by name.

## Subagents: always Sonnet

`CLAUDE_CODE_SUBAGENT_MODEL=claude-sonnet-5-5` in `settings.json` makes Sonnet the default for every subagent. Make it explicit too:

- **Every Agent call passes `model: "sonnet"`.** Builds, searches, reviews, research, tests: all Sonnet.
- **Never pass `model: "opus"`** and never pick an agent type whose frontmatter pins Opus without overriding it to `sonnet`.
- **Leave `effort` unset** on subagents, so they run at their usual level.
- **Workflows:** every `agent()` call in a script passes `{model: "sonnet"}`.
- **Forks** (`subagent_type: "fork"`) always inherit the lead model, so don't fork. Spawn a fresh Sonnet agent with a clear brief instead.

If a subagent result looks too weak, re-brief it more precisely rather than escalating to Opus.

**The one exception:** when the user explicitly says a subagent task is crucial and asks for Opus, use `model: "opus"` for that task only, then return to Sonnet. Never decide this yourself.
