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

This skill separates **platform directories** from **workspace directories**.

Use `<home>` as the host root, but only reorganize inside `{WORKSPACE_ROOT}`.

```
<home>/
├── {PLATFORM_DIRS}/     # Auto-detected, immutable, never move/delete
├── {WORKSPACE_ROOT}/    # Reorganizable scope for this skill
│   ├── active/              # Projects currently in development
│   ├── skills/              # Reusable skill files
│   ├── memory/              # Agent persistent state (notes, logs)
│   ├── docs/                # User documents, articles, references
│   ├── scripts/             # Global utility scripts (shared across projects)
│   ├── assets/              # Active resources (images, audio, PPT, PDF)
│   ├── archives/            # Cold storage
│   │   ├── projects/        # Completed or abandoned projects
│   │   └── assets/          # Retired resource files
│   ├── cache/               # Temporary cache (auto-expire, ≤7 days)
│   ├── tmp/                 # Scratch space (delete when task is done)
│   └── [config files]       # .env, *.yaml, *.json, etc.
```

**Routing rules**:
- Agent's own state/notes → `memory/` (not project data)
- User-authored articles, references → `docs/`
- Non-text resources (images, audio, video, PPT, PDF) → `assets/`
- Active development → `active/<project-name>/`
- Finished or abandoned work → `archives/projects/`
- Platform-native files/directories → leave as-is (never suggest moving)
- Uncertain → list options for user to decide; never assume

Only create directories as needed. Do not scaffold empty directories on first run.

## Platform Adaptation

Detect the current platform before running any flow.

For each platform, identify:
1. Workspace root (where rules apply)
2. Platform-native directories (immutable, never touch)
3. Cache locations (unified or separate, based on platform constraints)

| Platform | Workspace Root | Immutable Dirs |
|----------|----------------|----------------|
| Hermes | `~/.hermes/` | `hermes-agent/`, `bin/`, `cron/`, `sessions/`, `logs/` |
| Claude Code | `~/.claude/` | `.claude/`, `.cache/` |
| OpenClaw | `~/` | (none by default; detect dynamically) |

If platform is unknown:
- Auto-detect immutable directories by heuristics (agent/runtime/system dirs)
- Show detected result to user before any move/delete operations
- Ask user to confirm `{WORKSPACE_ROOT}`

### SKILL_ADAPT Block (per-platform override)

```yaml
SKILL_ADAPT:
  platform: hermes
  workspace_root: ~/.hermes/workspace
  immutable_dirs:
    - hermes-agent/
    - bin/
    - cron/
    - sessions/
    - logs/
  cache_dirs:
    - cache/
    - audio_cache/
    - image_cache/
  cache_policy: separate # separate | consolidate
```

### Platform Detection Decision Tree (reference)

Use the following order to avoid false positives and accidental moves:

1. If `SKILL_ADAPT` is explicitly provided by user/project:
   - Use `workspace_root`, `immutable_dirs`, `cache_dirs`, `cache_policy` directly
2. Else try known platform signatures:
   - Hermes: `~/.hermes/` exists or dirs like `hermes-agent/`, `cron/`, `sessions/`
   - Claude Code: `~/.claude/` exists or dirs like `.claude/`
   - OpenClaw/Generic: fallback to user home or current repo root
3. Derive immutable dirs:
   - Start with platform defaults
   - Add safety-critical dirs (`.git/`, keys/certs, agent config dirs)
4. Derive cache dirs:
   - Collect existing cache-like dirs (`cache/`, `*_cache/`, `.cache/`)
   - Apply platform requirement first; then apply `cache_policy`
5. Show detection summary and ask for confirmation before any destructive action

### Platform Detection Pseudocode (reference)

```python
def detect_platform_context(input_hint=None):
    ctx = {
        "platform": "unknown",
        "workspace_root": None,
        "immutable_dirs": set(),
        "cache_dirs": [],
        "cache_policy": "separate",
    }

    adapt = load_skill_adapt_if_any(input_hint)
    if adapt:
        ctx["platform"] = adapt.get("platform", "custom")
        ctx["workspace_root"] = expand(adapt["workspace_root"])
        ctx["immutable_dirs"].update(adapt.get("immutable_dirs", []))
        ctx["cache_dirs"] = adapt.get("cache_dirs", [])
        ctx["cache_policy"] = adapt.get("cache_policy", "separate")
        return ctx

    if exists("~/.hermes/") or has_dirs(["hermes-agent", "cron", "sessions"]):
        ctx["platform"] = "hermes"
        ctx["workspace_root"] = choose_existing([
            "~/.hermes/workspace", "~/.hermes/"
        ])
        ctx["immutable_dirs"].update([
            "hermes-agent/", "bin/", "cron/", "sessions/", "logs/"
        ])
        ctx["cache_dirs"] = existing_dirs(["cache/", "audio_cache/", "image_cache/"])
        ctx["cache_policy"] = "separate"
    elif exists("~/.claude/") or has_dirs([".claude"]):
        ctx["platform"] = "claude-code"
        ctx["workspace_root"] = "~/.claude/"
        ctx["immutable_dirs"].update([".claude/", ".cache/"])
        ctx["cache_dirs"] = existing_dirs(["cache/", ".cache/"])
        ctx["cache_policy"] = "separate"
    else:
        ctx["platform"] = "generic"
        ctx["workspace_root"] = detect_repo_or_home()
        ctx["immutable_dirs"].update(detect_agent_runtime_dirs())
        ctx["cache_dirs"] = detect_cache_dirs(ctx["workspace_root"])
        ctx["cache_policy"] = "separate"

    ctx["immutable_dirs"].update(global_protected_paths())
    return ctx
```

Detection output template (show before execution):

| Key | Value |
|-----|-------|
| Platform | `{platform}` |
| Workspace Root | `{workspace_root}` |
| Immutable Dirs | `{immutable_dirs}` |
| Cache Dirs | `{cache_dirs}` |
| Cache Policy | `{cache_policy}` |

## Flows

Execute the matching flow based on user intent.

**Safety rule: all move/delete operations must be shown as a plan table first. Execute only after user confirms.**

---

### Flow A: Organize Workspace

Trigger: "organize" / "tidy up" / "clean up" / "messy"

1. Run platform detection (resolve `{WORKSPACE_ROOT}` and immutable dirs)
2. Scan `{WORKSPACE_ROOT}` with `bash ls -la` and `glob` (skip immutable dirs)
3. Classify each file per the Classification Rules below
4. Build a plan table:

   | File | Current | Target | Action | Reason |
   |------|---------|--------|--------|--------|
   | image.png | root | assets/ | move | non-text resource |
   | \_\_pycache\_\_/ | root | — | delete | build artifact |
   | test.py | root | — | ask user | ambiguous name |

5. Present plan, wait for confirmation
   - User approves → execute
   - User excludes items → update plan, re-confirm
6. Execute with `bash mv` / `bash rm -rf`
7. Report results: moved N, deleted M, skipped K
8. Append summary to `memory/workspace-log.md`:
   ```
   ## {YYYY-MM-DD} Organize
   - Moved N files, deleted M, skipped K
   - Key changes: {brief list}
   ```

---

### Flow B: Create Project

Trigger: "create project xxx" / "new project"

1. Convert project name to kebab-case
2. Create directory under `{WORKSPACE_ROOT}/active/`
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

4. Tell user: all project files go in `{WORKSPACE_ROOT}/active/{project-name}/`, temp outputs go in `{WORKSPACE_ROOT}/tmp/`

---

### Flow C: Archive Project

Trigger: "archive xxx" / "done with xxx" / "project xxx is finished"

1. Locate project directory with `glob` (usually under `{WORKSPACE_ROOT}/active/`)
   - Not found → ask user to confirm name and location
2. Build archive plan:
   - Deliverables → move to `{WORKSPACE_ROOT}/assets/` (if user wants)
   - Project directory → move to `{WORKSPACE_ROOT}/archives/projects/{project-name}/`
   - Related `{WORKSPACE_ROOT}/tmp/`, cache files → delete
   - Build artifacts (`node_modules/`, `__pycache__/`, etc.) → delete
3. Update README.md: status → "archived", add archive date
4. Present plan, execute after user confirms
5. Append record to `memory/workspace-log.md`:
   ```
   ## {YYYY-MM-DD} Archive
   - Project: {project-name}
   - Archived to: {WORKSPACE_ROOT}/archives/projects/{project-name}/
   - Cleaned: {deleted temp files and build artifacts}
   ```

---

### Flow D: Hygiene Check

Trigger: "check" / "cleanup" / "audit"

Scan and report:

```
□ `{WORKSPACE_ROOT}` root contains only config files and directories
□ No forbidden file types in `{WORKSPACE_ROOT}` root (images, docs, scripts)
□ No files older than 7 days in cache dirs (or unified `cache/`)
□ Backup count per config file ≤ 3
□ No bad names (test.py, temp, untitled, non-ASCII directory names)
□ No leftover build artifacts (__pycache__/, node_modules/)
□ Every project in `{WORKSPACE_ROOT}/active/` has README.md with status = active
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

### Scope Rule

All classification/move/delete rules apply to `{WORKSPACE_ROOT}` only.

Never classify, move, rename, or delete files inside `{PLATFORM_DIRS}`.

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

### Cache Consolidation

When multiple cache directories exist (for example `cache/`, `audio_cache/`, `image_cache/`):
- If platform policy is `consolidate`, suggest merging into `cache/` with subdirs:
  - `cache/audio/`
  - `cache/image/`
  - `cache/misc/`
- If platform policy is `separate`, keep current directories and apply expiration checks per directory
- Never force consolidation when platform requires fixed cache paths

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
