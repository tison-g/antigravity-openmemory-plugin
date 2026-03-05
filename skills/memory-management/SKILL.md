---
name: memory-management
description: Always use when starting a new conversation or when making significant decisions, bug fixes, or observations that should be remembered across sessions.
---

# Global Memory Management Skill (OpenMemory)

You are equipped with the OpenMemory Model Context Protocol (MCP) server, granting you the ability to remember facts, preferences, code contexts, and project history across different chat sessions.

## Core Directives

1. **Be Proactive**: Do not wait for the user to explicitly tell you to remember or recall something. Anticipate when past context is needed and when new context is valuable enough to save.
2. **Be Token-Efficient**: Never dump raw logs or huge code blocks into memory. Always compress information into concise summaries before storing.
3. **Be Incremental**: Recall memories progressively (summary first, details only if needed).

---

## 📥 WHEN to Retrieve Memory (Recall)

Always call `openmemory_query` implicitly when:
- **Starting a new task or conversation** (e.g., query the current project name or general topic to gain context).
- The user refers to "yesterday", "last time", "the previous bug", etc.
- You are about to touch a complex module and want to see if there are historical architectural decisions or known bugs.

### Token-Efficient Retrieval Strategy (The 2-Step Process)

> **WARNING**: Unnecessary memory reading consumes valuable context tokens.

- **Step 1 (Index/Summary)**: Use `openmemory_query` to search using targeted keywords. This returns a list of matching memories with summaries.
- **Step 2 (Details)**: ONLY IF a resulting memory seems directly critical to your current task, use `openmemory_get` on its specific ID to read the full details. Otherwise, just rely on the summary from step 1.

---

## 📤 WHEN to Store Memory (Save)

Call `openmemory_store` implicitly when:
- You finish debugging a tricky issue (store the root cause and the fix).
- You and the user agree on a new architectural pattern, coding convention, or preference.
- At the end of a long task, to summarize what was accomplished so the next session can pick up easily.

### Token-Efficient Storage Strategy (Compression)

> **WARNING**: Never store raw tracebacks, entire file contents, or uncompressed logs. 

Before storing, you MUST compress the information into a high-density factual summary.

- **Bad Example (Do not do this)**: Storing 200 lines of a `git diff` showing every minor change made to a CSS file.
- **Good Example**: "Refactored the AppHeader component to use flexbox instead of grid to fix mobile alignment issues. The new convention for the header is `display: flex; justify-content: space-between;`."

### Storing Best Practices

- Always use the `tags` array parameter in `openmemory_store` to categorize the memory (e.g., `["bugfix", "frontend", "auth"]`).
- Explicitly set `user_id` if known (otherwise use a generic default like `"self"` or `"user"` based on your context, but keep it consistent).
- Keep the `content` concise and factual.

---

## Maintenance

If you discover that an existing memory is outdated or no longer true (e.g., the user changed their preference or refactored an architecture away):
- Feel free to overwrite or reinforce it using `openmemory_reinforce`, or store a new memory that explicitly deprecates the old one.
