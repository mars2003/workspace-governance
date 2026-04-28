# workspace-governance

[中文文档](README.zh-CN.md)

A methodology-first workspace governance skill for AI agents.

Works with any AI coding agent that supports skill/rule files — Claude Code, Cursor, Windsurf, OpenClaw, Hermes Agent, or similar.

## Why This Skill

AI agents generate files constantly. Over time, clutter and ambiguous ownership make workspaces harder to maintain and riskier to clean.

This skill does not enforce one fixed directory layout.  
It teaches the agent how to design a governance strategy that fits local constraints and user preferences.

## Core Positioning

`workspace-governance` is a governance framework, not a folder template.

- Boundary before structure
- Plan before action
- Reversible before optimized
- Context-fit before standardization
- User confirmation for destructive decisions

## What the Agent Learns to Do

Instead of hard-coding folders, the agent should:

1. Define manageable boundaries (`workspace_root`, immutable/protected areas).
2. Scan and classify real files (keep/move/rename/archive/delete/ask-user).
3. Build a governance plan with risk and rollback notes.
4. Confirm destructive or ambiguous operations with the user.
5. Execute in batches and record traceable logs.

## Install

### Claude Code / Cursor / Windsurf

Copy `SKILL.md` to your agent's skill directory:

```bash
# Claude Code (global)
mkdir -p ~/.claude/skills/workspace-governance
cp SKILL.md ~/.claude/skills/workspace-governance/

# Cursor (project-level)
mkdir -p .cursor/skills/workspace-governance
cp SKILL.md .cursor/skills/workspace-governance/
```

### Other Agents

Place `SKILL.md` wherever your agent reads skill/rule files. The content is platform-agnostic — it uses standard shell commands (`mv`, `rm`, `mkdir -p`, `ls`) that work on any Unix-like system.

## Recommended Interaction Intents

- "organize workspace"
- "archive project <name>"
- "create project <name>"
- "workspace audit" / "hygiene check"
- "cleanup with plan first"

The exact implementation should depend on local system constraints, not a fixed path recipe.

## Safety Baseline

- Dry-run plan before destructive actions.
- Explicit user confirmation for delete and bulk move.
- Never touch version-control metadata and sensitive credentials by default.
- Never overwrite on name collision.
- Keep operation summaries for traceability.

## Governance Plan Template

Before execution, the agent should provide a plan table:

| Item | Current | Proposed Action | Target | Risk | Reason |
|------|---------|-----------------|--------|------|--------|
| example.tmp | root | delete | — | medium | temporary artifact |
| report-final.docx | root | ask-user | docs or archive | low | destination ambiguous |

## Notes

- This repository intentionally avoids prescribing one universal directory tree.
- If you need strict standardization, define it explicitly through `SKILL_ADAPT` or project rules.
- Default behavior should remain conservative and reversible.

## License

MIT
