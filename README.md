# workspace-organizer

A universal skill to keep your agent's workspace clean and organized.

## What This Is

A skill for AI agents (OpenClaw, Hermes, Claude Code, Cursor, or any AI agent platform) that defines rules for keeping the workspace clean and organized.

## Installation

Copy `SKILL.md` to your agent's skills directory:
- OpenClaw: `~/.openclaw/workspace/skills/workspace-organizer/SKILL.md`
- Hermes: `<hermes-home>/skills/workspace-organizer/SKILL.md`
- Others: `<agent-home>/skills/workspace-organizer/SKILL.md`

## The Rules

1. Root directory is sacred (only config files allowed)
2. Naming convention (kebab-case, English only)
3. Project lifecycle (Create → Develop → Complete → Archive)
4. Asset management (images/audio/docs in assets/)
5. Backup discipline (max 3 per config)
6. Cache & temp management (≤7 days)
7. Build artifacts (delete by default)
8. Forbidden patterns
9. Softlinks (allowed in archives only)

## Weekly Hygiene Check

See `SKILL.md` for the complete checklist.

## License

MIT
