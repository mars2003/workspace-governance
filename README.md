# workspace-governance

[中文文档](README.zh-CN.md)

A universal skill that keeps your AI agent's workspace clean and organized.

Works with any AI coding agent that supports skill/rule files — Claude Code, Cursor, Windsurf, AlphaEngine, or similar.

## The Problem

AI agents create files constantly — scripts, images, reports, temporary outputs. Without structure, the workspace becomes a mess:

- Root directory filled with random files
- Duplicate or orphaned directories
- Finished projects never archived
- Backup files piling up
- Naming chaos (`test1.py`, `Untitled`, non-ASCII names)
- Build artifacts (`node_modules/`, `__pycache__/`) cluttering everything

## What It Does

Give your agent a simple command, and it handles the rest:

| You say | Agent does |
|---------|-----------|
| "organize" | Scan root, classify files, show plan, execute after confirmation |
| "create project x" | Scaffold `active/x/` with README |
| "done with x" | Archive project, clean temp files, log the action |
| "cleanup" | Run hygiene checklist, report violations, suggest fixes |

**Safety first** — every move/delete operation is shown as a dry-run plan table. Nothing happens until you confirm.

## Directory Structure

```
<workspace>/
├── active/          # Current projects
├── scripts/         # Global utility scripts
├── docs/            # Articles, references
├── assets/          # Images, audio, documents
├── archives/        # Finished work
│   ├── projects/
│   └── assets/
├── memory/          # Agent state & logs
├── cache/           # Auto-expire temp (≤7 days)
└── tmp/             # Scratch space
```

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

### AlphaEngine

```bash
mkdir -p ~/.alphaclaw/skills/workspace-governance
cp SKILL.md ~/.alphaclaw/skills/workspace-governance/
```

### Other Agents

Place `SKILL.md` wherever your agent reads skill/rule files. The content is platform-agnostic — it uses standard shell commands (`mv`, `rm`, `mkdir -p`, `ls`) that work on any Unix-like system.

## Key Design Decisions

**Dry-run by default.** Every destructive operation shows a plan first. The agent cannot delete or move files without user confirmation.

**Protected paths.** Version control (`.git/`), environment files (`.env`), certificates (`*.key`, `*.pem`), and agent config directories are never touched.

**Name collision safety.** Moving `image.png` to a folder that already has one? It becomes `image-20260427.png`. Never overwrites.

**Operation logging.** Every organize/archive action is logged to `memory/workspace-log.md` with date and summary, so you have a trail.

**Minimal scaffolding.** Directories are created on-demand, not all at once. No empty `archives/assets/` sitting around from day one.

## Example

**Before:**
```
~/workspace/
├── test.py
├── image.png
├── report.pptx
├── notes.txt
├── config.yaml
├── config.yaml.bak
├── config.yaml.bak.1
├── config.yaml.bak.2
├── config.yaml.bak.3
├── __pycache__/
└── node_modules/
```

**You say:** "organize"

**Agent shows plan:**

| File | Action | Target | Reason |
|------|--------|--------|--------|
| image.png | move | assets/ | non-text resource |
| report.pptx | move | assets/ | document |
| notes.txt | move | docs/ | user content |
| test.py | move | scripts/ | script (suggest rename) |
| config.yaml.bak.3 | delete | — | exceeds 3-backup limit |
| \_\_pycache\_\_/ | delete | — | build artifact |
| node_modules/ | delete | — | build artifact |

**You say:** "go"

**After:**
```
~/workspace/
├── active/
├── assets/
│   ├── image.png
│   └── report.pptx
├── docs/
│   └── notes.txt
├── scripts/
│   └── test.py
├── config.yaml
├── config.yaml.bak
├── config.yaml.bak.1
└── config.yaml.bak.2
```

## License

MIT
