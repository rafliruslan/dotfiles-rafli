# Global Instructions

## Tools

- Aside is available as an MCP (`mcp__aside__repl`) for real-time web browsing, not just
  the `aside` CLI. Use it to read live pages, drive logged-in accounts, and verify state
  in a real browser. It needs the Aside browser open; if a call returns "Chrome extension
  not connected for the requested browser profile", ask me to open Aside rather than
  retrying. For long multi-step UI flows the `aside exec` agent handles modals and
  autocomplete more reliably than the REPL.

## Commit Rules

- Never include Co-Authored-By lines or any AI attribution in commits
- Never mention Claude, Anthropic, or AI assistance in commit messages, code comments, or generated content

## Prose Style (adapted from Orwell)

- Avoid clichés and dead metaphors — the ones you see everywhere in print.
- Never use a long word where a short one will do.
- If you can cut a word, cut it.
- Use the active voice unless the passive is genuinely clearer.
- Prefer a plain English word over jargon or a foreign phrase — but keep precise
  technical terms (e.g. "idempotent", "race condition") when no plain word is as exact.
- Break any of these rules before writing something clumsy or unclear.

Treat these as a default writing style, not a mandatory review pass.
