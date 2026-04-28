---
name: workspace-governance
description: >
  A methodology-first workspace governance skill for AI agents.
  Focuses on principles, decision framework, and safe execution patterns
  instead of fixed directory templates. Triggers on "organize", "cleanup",
  "archive", "workspace check", "整理工作区", "清理文件", "归档项目", "太乱了".
---

# Workspace Governance

Methodology-first workspace governance for AI agents.

## Purpose

This skill teaches an agent how to design a workspace management strategy that fits its own runtime, platform, and user preferences.

This is not a single directory template and not a rigid SOP.  
The agent should adapt based on context, then execute safely.

## Core Principles

1. Boundary before structure: define what can be touched first.
2. Plan before action: generate a governance plan before file operations.
3. Reversible before optimized: preserve rollback paths and avoid irreversible changes.
4. Fit current system first: reuse existing conventions when they are workable.
5. User control at key points: destructive operations require explicit confirmation.
6. Evidence-driven decisions: only propose actions based on real scan results.

## When to Use

- Workspace is messy and needs cleanup or reorganization.
- User asks to archive/close finished work.
- User asks to create a new project with clear boundaries.
- User asks for workspace audit/health check.
- Agent needs to establish sustainable file governance rules.

## Scope and Boundaries

The agent must define these before execution:

- `workspace_root`: the manageable boundary for this task.
- `immutable_dirs`: directories that must never be moved/deleted/renamed.
- `protected_files`: sensitive files (keys, env, certs, VCS metadata).
- `risk_level`: low/medium/high based on destructive potential.

If `workspace_root` is too broad (for example home root), require explicit confirmation before scanning.

## Adaptation Model (Platform-Agnostic)

The agent should adapt strategy using this order:

1. User explicit constraints and preferences.
2. Current repository/project conventions.
3. Platform/runtime restrictions.
4. Conservative fallback defaults.

Do not force a fixed folder structure unless the user requests standardization.

### Optional Adapt Block

```yaml
SKILL_ADAPT:
  workspace_root: <path>
  immutable_dirs: [dir1, dir2]
  protected_files: [pattern1, pattern2]
  cache_policy: separate # separate | consolidate
  naming_policy: inherit # inherit | enforce
```

## Decision Framework

Before any move/delete action, produce a governance plan with:

1. **Current State Summary**
   - What is cluttered
   - What is ambiguous
   - What is sensitive
2. **Target Strategy**
   - Keep, move, rename, archive, delete policy
   - Naming and lifecycle policy
   - Cache/temp policy
3. **Risk and Rollback**
   - Risks per action class
   - Rollback method and checkpoints
4. **User Confirmation Items**
   - Items that need user decision
   - Items excluded from automation

### Plan Output Template

| Item | Current | Proposed Action | Target | Risk | Reason |
|------|---------|-----------------|--------|------|--------|
| example.tmp | root | delete | — | medium | temporary artifact |
| report-final.docx | root | ask user | docs or archive | low | destination ambiguous |

## Execution Pattern (Generic)

Use this pattern regardless of platform:

1. Detect context and boundaries.
2. Scan inside `workspace_root` only.
3. Classify findings: keep/move/rename/archive/delete/ask-user.
4. Generate plan table with reasons and risks.
5. Get confirmation for destructive or ambiguous actions.
6. Execute in small batches.
7. Report results and failures.
8. Record governance log for traceability.

If multiple user intents exist, process sequentially and reconfirm between destructive batches.

## Classification Heuristics (Flexible)

Use heuristics, not hard-coded folders:

- **Project artifacts**: source code, configs, tests, docs tied to one project.
- **Reusable assets**: media or references used across projects.
- **Ephemeral data**: cache/tmp/build artifacts/log leftovers.
- **Agent/runtime state**: tool configs, sessions, internal runtime files.
- **Ambiguous items**: unclear ownership or destination.

Rules:
- Ambiguous items must be escalated to user decisions.
- Never silently rename if semantic meaning may change.
- Never overwrite existing files on move.

## Safety Baseline (Mandatory)

### Never Touch Without Explicit User Approval

- Version control metadata (`.git/`, `.svn/`, `.hg/`)
- Secret material (`*.key`, `*.pem`, `*.p12`, private credentials)
- Environment files (`.env` and equivalents)
- Agent/runtime configuration directories

### Destructive Action Guardrails

- Always show dry-run plan first.
- Require explicit confirmation for delete and bulk move.
- Use collision-safe naming on move.
- Keep operation logs and failure reasons.
- Stop and ask user if unexpected high-risk patterns are detected.

## Standard Operation Modes

### 1) Organize

Goal: improve discoverability and reduce clutter with minimal disturbance.

### 2) Create Project

Goal: initialize a new work area aligned with existing conventions.

### 3) Archive Project

Goal: transition inactive work into retrievable cold storage with metadata.

### 4) Hygiene Check

Goal: audit quality signals and output fix recommendations.

Note: The agent should choose implementation details based on local system constraints, not this document's examples.

## Quality Signals for Audit

Recommended checks:

- Boundary clarity (what is managed vs protected)
- Root clutter level
- Naming consistency
- Build/cache residue
- Archive lifecycle completeness
- Recoverability (rollback/readability of logs)

Output style:
- Pass items with clear evidence.
- Violations with fix suggestion and risk level.
- Summary with actionable next steps.

## Logging and Traceability

The agent should keep a lightweight operation record, including:

- Date (`YYYY-MM-DD`)
- Intent type (organize/create/archive/audit)
- Planned changes vs executed changes
- Success/failure counts
- Unresolved decisions pending user input

## Anti-Patterns to Avoid

- Forcing a universal directory layout on every system
- Performing bulk cleanup without a dry-run plan
- Treating unknown files as disposable
- Optimizing structure while ignoring user workflow habits
- Mixing agent state and user business content without explicit mapping

## Minimal Example (Reference Only)

Example principles in action:

1. Detect workspace boundary and immutable dirs.
2. Scan only within boundary.
3. Mark ambiguous files as `ask-user`.
4. Confirm plan before delete/move.
5. Execute and log.

This example is illustrative, not normative.

## Author

- 作者: Mars2003 （GitHub）
- 日期: 2026-04-28
