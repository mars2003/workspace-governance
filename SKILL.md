# workspace-organizer

A universal skill to keep your agent's workspace clean and organized. Works with OpenClaw, Hermes, Claude Code, Cursor, or any AI agent platform.

## The Problem

Agents create files constantly — scripts, images, reports, temporary outputs. Without rules, the workspace becomes a mess:
- Root directory filled with random files
- Duplicate directories scattered around
- Old projects never archived
- Backup files pile up indefinitely
- Naming chaos (`test1.py`, `Untitled`, non-ASCII names)
- Build artifacts (`node_modules/`, `__pycache__/`) cluttering the workspace

## Core Principles

```
Root = Entrypoint, Not Storage
Every file belongs somewhere
Projects have beginnings and ends
Naming is communication, not reminder
Cache is ephemeral, assets are persistent
```

## Directory Structure (Default Template)

Apply this structure to your platform's home directory. Adapt directory names to match your platform's conventions, but keep the organizational logic.

```
<home>/
├── skills/              # Reusable capabilities (agent knows how to do)
├── active/              # Active projects (currently in use)
├── memory/              # Persistent memory files (agent's notes, user prefs)
├── docs/                # Documentation, articles, references
├── scripts/             # Global utility scripts (shared across projects)
├── archives/            # Finished or abandoned work
│   ├── projects/       # Archived projects (by project name)
│   ├── by-date/        # Chronological archive (YYYY-MM/ or YYYY/)
│   └── assets/         # Old images, audio, documents
├── assets/             # Active resources (images, audio, documents, downloads)
├── cache/              # Temporary files (auto-cleanup, ≤7 days)
├── tmp/                # Ephemeral work files (deleted when done)
└── [bootstrap files]   # Config, identity, system files
```

**Logic:**
- `skills/` — things the agent can do (reusable capabilities)
- `active/` — projects currently being developed or used
- `memory/` — agent's persistent state (not project data)
- `archives/projects/` — completed or abandoned projects (out of active use)
- `cache/` — temporary files with automatic expiration
- `tmp/` — scratch space for active work
- Root — only config, bootstrap, and identity files

## The Rules

### Rule 1: Root Directory Is Sacred

**Allowed in root:**
- Configuration files (`*.md`, `.env`, `.json`, `.yaml`, `.toml`, `.ini`)
- Directory entries (folders)
- Bootstrap/identity files (platform-specific)
- README, LICENSE, CHANGELOG

**Forbidden in root:**
- Images, audio, video files
- Documents (PPT, PDF, DOC, XLSX)
- Scripts unless globally shared
- Temporary or test outputs
- Backup files
- Build artifacts
- Non-text files

**If a file appears in root:** Move it to the appropriate directory immediately.

### Rule 2: Naming Convention

**Directories:**
- Lowercase, hyphens, English only
- Semantic and descriptive
- ✅ `work-notes`, `image-generator`, `weekly-reports`, `project-alpha`
- ❌ `temp`, `新建文件夹`, `aaa`, `stuff`, `misc`

**Files:**
- Semantic name + version/date when useful
- Include extension (always)
- Platform-safe characters only (ASCII alphanumerics, `-`, `_`, `.`)
- ✅ `market-analysis-2026-04.md`, `feishu-voice-sender.py`, `config-v2.yaml`
- ❌ `1.py`, `test.py`, `output_final.pptx`, `新建文件`, `report@latest.docx`

**Never use in names:**
- Spaces, special characters, emoji
- `test`, `temp`, `untitled`, `copy`, `backup` as primary identifiers
- Date formats other than `YYYY-MM-DD` or `YYYYMMDD`

### Rule 3: Project Lifecycle

```
Create → Develop → Complete → Archive
        or
Create → Develop → Abandon → Archive
```

**Create:**
```
1. Create a dedicated directory under active/
2. Add README.md with: purpose, status, key files
3. All project files stay inside until complete
```

**Develop:**
```
1. All files in active/<project-name>/
2. Temporary outputs to /tmp/ or cache/, never to home root
3. Build artifacts (__pycache__/, node_modules/) are temporary by default
```

**Complete:**
```
1. Deliverables to assets/ or keep in project
2. Move project to archives/projects/<project-name>/
3. Clean: /tmp/, cache/, build artifacts (unless user says keep)
4. Update README.md status to "archived"
```

**Abandon:**
```
1. Move entire project to archives/projects/
2. Mark README.md status as "abandoned"
3. Do not leave orphaned files scattered
```

### Rule 4: Asset Management

| File Type | Primary Location | Archive Location |
|-----------|-----------------|-----------------|
| Images | `assets/` | `archives/assets/` |
| Audio/Video | `assets/` | `archives/assets/` |
| Documents (PPT, PDF) | `assets/` | `archives/assets/` |
| Downloads | `assets/downloads/` | `archives/assets/` |
| Temporary outputs | `cache/` or `/tmp/` | — (delete) |
| Build artifacts | — (delete) | never archive |

### Rule 5: Backup Discipline

```
Maximum 3 backups per config file:
  config.yaml           (current)
  config.yaml.bak       (1 version ago)
  config.yaml.bak.1     (2 versions ago)

Delete config.yaml.bak.2 and older automatically.
```

**Backup rules:**
- Only config files get backups (not data, not projects)
- Use timestamp if needed: `config-2026-04-27.yaml`
- Never backup `node_modules/`, `cache/`, `/tmp/`

### Rule 6: Cache & Temp Management

```
Cache lifecycle: ≤ 7 days
Temp lifecycle: until task complete

Detection:
  - Directories named: cache/, tmp/, temp/, .cache/
  - File patterns: *.tmp, *.temp, *.cache
  - System temp: /tmp/, /var/tmp/

Cleanup trigger:
  - On startup (low priority)
  - After project completion
  - When storage exceeds threshold
```

### Rule 7: Build Artifacts — Delete by Default

**Default: delete immediately**
```
- node_modules/
- __pycache__/
- *.pyc, *.pyo
- .pytest_cache/
- dist/, build/, *.egg-info/
- .venv/, venv/, env/
- .parcel-cache/, .next/, .nuxt/
```

**Exception: keep if user explicitly requests**
```
Some deployment scenarios need node_modules/ preserved.
If user says "keep node_modules for deployment", respect it.
Otherwise: always delete, never archive.
```

**Never archive:**
- Build artifacts are output, not source
- They can be recreated from source/requirements

### Rule 8: Forbidden Patterns

**Files that should never exist:**
```
- /tmp/ with non-temporary names
- Files with non-ASCII characters in path
- Symbolic links pointing to active work (allowed in archives)
- Files older than 30 days in cache/
- Empty directories (delete if found)
```

### Rule 9: Softlinks

```
Allowed:
  - In archives/ only (for organizing by-date links)
  - Pointing to external storage

Forbidden:
  - In root, skills/, apps/, memory/, assets/
  - Pointing to /tmp/ or cache/
  - Circular links
```

## Weekly Hygiene Check

Run this checklist regularly (or when user says "organize"):

```
□ Root has only config/directory files
□ No forbidden file types in root
□ System temp (/tmp/) is clean
□ cache/ files are ≤ 7 days old
□ Backup count per config ≤ 3
□ No non-ASCII directory/file names
□ No test.py, temp.py, untitled files
□ No build artifacts (__pycache__/, node_modules/)
□ All projects have README.md with status
□ archives/ organized (by-name or by-date)
□ No empty directories
□ No symbolic links outside archives/
```

**If violations found:** Fix immediately. Log to memory. Ask user if uncertain.

## Quick Reference

```
USER SAYS "organize"
  → Run hygiene check
  → Sort files by type
  → Move to appropriate directories
  → Create archives/ if missing
  → Delete build artifacts
  → Report what was done

USER SAYS "create project <name>"
  → Create <home>/projects/<name>/
  → Add README.md (purpose, status: active)
  → All files stay inside

USER SAYS "done with <project>"
  → Move deliverables to assets/
  → Move project to archives/projects/
  → Clean: /tmp/, cache/, build artifacts
  → Update README.md status: archived

USER SAYS "write article / save notes"
  → docs/ for articles and documentation
  → memory/ for agent's own notes
  → Use semantic filename with date

USER SAYS "cleanup"
  → Delete build artifacts
  → Clear cache/ older than 7 days
  → Remove empty directories
  → Verify backup count ≤ 3
```

## Platform Detection

Your agent should detect the home directory automatically:

```python
import os

def find_home():
    candidates = [
        os.environ.get('WORKSPACE'),
        os.environ.get('AGENT_HOME'),
        os.environ.get('HERMES_HOME'),
        os.environ.get('HOME'),
        os.environ.get('AGENT_ROOT'),
        os.path.expanduser('~'),
    ]
    for candidate in candidates:
        if candidate and os.path.isdir(candidate):
            return candidate
    return os.getcwd()
```

## Examples

### Example 1: A Messy Root

**Before:**
```
<home>/
├── test.py
├── notes.txt
├── image.png
├── report.pptx
├── backup.json.bak
├── backup.json.bak.1
├── backup.json.bak.2
├── backup.json.bak.3
├── node_modules/
└── __pycache__/
```

**After:**
```
<home>/
├── scripts/
│   └── test.py
├── assets/
│   ├── image.png
│   └── report.pptx
├── memory/
│   └── notes.txt
├── cache/
└── ...
```
Deleted: node_modules/, __pycache__/, extra backups

### Example 2: Creating a New Capability

**User:** "Create a stock screener capability"

**Agent:**
```
1. mkdir active/stock-screener/
2. Add README.md (purpose, usage, status: active)
3. All files stay inside until stable
4. When complete: mv to archives/projects/
```

### Example 3: Archiving a Finished Project

**User:** "The market analysis project is complete"

**Agent:**
```
1. Move deliverables to assets/
2. mv projects/market-analysis/ archives/projects/
3. Update archives/projects/market-analysis/README.md (status: archived)
4. rm -rf /tmp/market-analysis-*
5. Done
```

### Example 4: Cache Cleanup

**Agent runs on startup or on demand:**
```
1. Find files in cache/ older than 7 days
2. Delete them
3. Find empty directories, delete
4. Log: "Cleaned N files from cache/"
```

## Version

1.4.0 — Renamed apps/ to active/, clarified archives/projects/, made build artifact deletion opt-out

## License

MIT — Use, modify, share freely.
