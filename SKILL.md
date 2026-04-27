---
name: workspace-organizer
description: >
  Organize workspace files, clean up clutter, archive finished projects,
  and enforce directory structure. Triggers on "organize", "tidy up",
  "cleanup", "archive project", "create project", "messy workspace".
  Also triggers on Chinese: "整理工作区", "清理文件", "归档项目",
  "太乱了", "帮我整理一下", "创建项目".
---

# Workspace Organizer

Automated workspace hygiene for AI agents.

## Overview

Workspaces accumulate clutter over time: stray files in root, expired temp files, unarchived projects, chaotic naming. This skill provides rules and executable flows to keep the workspace clean.

## When to Use

- "organize my workspace" / "tidy up" / "cleanup"
- "archive project xxx" / "done with xxx"
- "create project xxx"
- "workspace check" / "too messy"

## Directory Structure

Standard layout, using `<home>` as the workspace root:

```
<home>/
├── active/              # Projects currently in development
├── skills/              # Reusable skill files
├── memory/              # Agent persistent state (notes, logs)
├── docs/                # User documents, articles, references
├── scripts/             # Global utility scripts (shared across projects)
├── assets/              # Active resources (images, audio, PPT, PDF)
├── archives/            # Cold storage
│   ├── projects/        # Completed or abandoned projects
│   └── assets/          # Retired resource files
├── cache/               # Temporary cache (auto-expire, ≤7 days)
├── tmp/                 # Scratch space (delete when task is done)
└── [config files]       # .env, *.yaml, *.json, etc.
```

**Routing rules**:
- Agent's own state/notes → `memory/` (not project data)
- User-authored articles, references → `docs/`
- Non-text resources (images, audio, video, PPT, PDF) → `assets/`
- Active development → `active/<project-name>/`
- Finished or abandoned work → `archives/projects/`
- Uncertain → list options for user to decide; never assume

Only create directories as needed. Do not scaffold empty directories on first run.

## Flows

Execute the matching flow based on user intent.

**Safety rule: all move/delete operations must be shown as a plan table first. Execute only after user confirms.**

---

### Flow A: Organize Workspace

Trigger: "organize" / "tidy up" / "clean up" / "messy"

1. Scan root directory with `bash ls -la` and `glob`
2. Classify each file per the Classification Rules below
3. Build a plan table:

   | File | Current | Target | Action | Reason |
   |------|---------|--------|--------|--------|
   | image.png | root | assets/ | move | non-text resource |
   | \_\_pycache\_\_/ | root | — | delete | build artifact |
   | test.py | root | — | ask user | ambiguous name |

4. Present plan, wait for confirmation
   - User approves → execute
   - User excludes items → update plan, re-confirm
5. Execute with `bash mv` / `bash rm -rf`
6. Report results: moved N, deleted M, skipped K
7. Append summary to `memory/workspace-log.md`:
   ```
   ## {YYYY-MM-DD} Organize
   - Moved N files, deleted M, skipped K
   - Key changes: {brief list}
   ```

---

### Flow B: Create Project

Trigger: "create project xxx" / "new project"

1. Convert project name to kebab-case
2. Create directory under `active/`
3. Create `README.md`:

   ```markdown
   # {Project Name}

   **Status**: active
   **Created**: {YYYY-MM-DD}

   ## Purpose
   {brief description, from user or left blank}

   ## Key Files
   - (to be added)
   ```

4. Tell user: all project files go in `active/{project-name}/`, temp outputs go in `tmp/`

---

### Flow C: Archive Project

Trigger: "archive xxx" / "done with xxx" / "project xxx is finished"

1. Locate project directory with `glob` (usually under `active/`)
   - Not found → ask user to confirm name and location
2. Build archive plan:
   - Deliverables → move to `assets/` (if user wants)
   - Project directory → move to `archives/projects/{project-name}/`
   - Related `tmp/`, `cache/` files → delete
   - Build artifacts (`node_modules/`, `__pycache__/`, etc.) → delete
3. Update README.md: status → "archived", add archive date
4. Present plan, execute after user confirms
5. Append record to `memory/workspace-log.md`:
   ```
   ## {YYYY-MM-DD} Archive
   - Project: {project-name}
   - Archived to: archives/projects/{project-name}/
   - Cleaned: {deleted temp files and build artifacts}
   ```

---

### Flow D: Hygiene Check

Trigger: "check" / "cleanup" / "audit"

Scan and report:

```
□ Root contains only config files and directories
□ No forbidden file types in root (images, docs, scripts)
□ No files older than 7 days in cache/
□ Backup count per config file ≤ 3
□ No bad names (test.py, temp, untitled, non-ASCII directory names)
□ No leftover build artifacts (__pycache__/, node_modules/)
□ Every project in active/ has README.md with status = active
□ No empty directories
```

Output format:
- Pass items → ✅, violations → ❌ with fix suggestion
- Summary: "Found N issues, suggested fixes:" + fix plan table
- Execute fixes after user confirms

## Classification Rules

### Allowed in Root

- Config files: `.env`, `*.yaml`, `*.toml`, `*.json`, `*.ini`, `*.conf`
- Special markdown: `README.md`, `LICENSE`, `CHANGELOG.md`
- Directories

### Forbidden in Root (move on sight)

| File Type | Target |
|-----------|--------|
| Images (png/jpg/gif/svg/webp/ico) | `assets/` |
| Audio/Video (mp3/mp4/wav/avi/mov) | `assets/` |
| Documents (ppt/pptx/pdf/doc/docx/xlsx/xls) | `assets/` or `docs/` |
| Scripts (py/sh/js/ts) | `scripts/` (global) or `active/{project}/` (project-specific) |
| Temp files (*.tmp/*.temp/*.log) | `tmp/` or delete |
| Build artifacts | delete |

### Naming Convention

**Directories**: lowercase English, hyphens, semantic
- ✅ `market-analysis`, `weekly-reports`, `image-generator`
- ❌ `temp`, `aaa`, `stuff`, `misc`

**Files**: semantic name + extension, ASCII only (letters, digits, `-`, `_`, `.`)
- ✅ `market-analysis-2026-04.md`, `config-v2.yaml`
- ❌ `1.py`, `test.py`, `report@latest.docx`

**Dates**: `YYYY-MM-DD` or `YYYYMMDD` only

When encountering bad names, suggest a new name for user to confirm. Never rename silently.

### Build Artifacts (delete by default)

```
node_modules/, __pycache__/, *.pyc, *.pyo
.pytest_cache/, dist/, build/, *.egg-info/
.venv/, venv/, env/
.parcel-cache/, .next/, .nuxt/
```

Exception: keep if user explicitly says so.

### Backup Discipline

Max 3 backup versions per config file:

```
config.yaml           (current)
config.yaml.bak       (previous)
config.yaml.bak.1     (two versions ago)
```

Delete older backups automatically. Only config files get backups — not data, not projects.

## Safety

### Protected Paths (never touch)

```
.git/, .svn/, .hg/              # Version control
.env                             # Environment variables (check location, don't move)
*.key, *.pem, *.p12             # Certificates and keys
Agent config directories         # e.g. .claude/, .cursor/, platform-specific dirs
```

Skip these during scans. Never suggest moving or deleting them.

### Dry-run First

All destructive operations must show a plan first:
- Format: table with file / action / reason
- Execute only after user confirms
- If user excludes items, update plan and re-confirm

### Name Collision

When moving a file to a location that already has the same name:
- Append date suffix: `image.png` → `image-20260427.png`
- Never overwrite existing files

### Error Handling

- Auto-create target directory if missing (`mkdir -p`)
- If one file operation fails, log the error and continue with the rest
- Final report: N succeeded, M failed (with failure reasons)

## Notes

- Never delete user files without confirmation
- `memory/` is for agent state, `docs/` is for user content — do not mix
- Do not force-create directories the user doesn't need
- When a file's destination is unclear, list options and let user decide
- All suggestions must be based on actual scan results, not assumptions
