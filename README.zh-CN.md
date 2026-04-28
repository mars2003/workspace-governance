# workspace-governance

[English](README.md)

一个方法论优先的 AI Agent 工作区治理技能。

适用于任何支持 skill/rule 文件的 AI 编码助手 — Claude Code、Cursor、Windsurf、AlphaEngine 等。

## 为什么需要它

AI Agent 会持续生成脚本、文档、媒体和临时文件。随着时间推移，工作区会出现杂乱、归属不清、清理风险高的问题。

这个技能不主张“一刀切目录模板”，而是让智能体根据环境和偏好设计可落地、可回滚的治理方案。

## 核心定位

`workspace-governance` 是治理框架，不是固定目录脚手架。

- 先边界，后结构
- 先方案，后执行
- 可逆优先，而不是一步到位优化
- 先贴合现有系统，再谈标准化
- 破坏性动作必须用户确认

## 智能体会学到什么

它会学会按以下模式工作，而不是硬编码目录：

1. 先定义管理边界（`workspace_root`、不可变目录、受保护文件）。
2. 扫描真实文件并分类（keep/move/rename/archive/delete/ask-user）。
3. 先生成治理计划，说明风险与回滚方式。
4. 对删除/批量移动/歧义项先征求确认。
5. 分批执行并记录可追溯日志。

## 安装

### Claude Code / Cursor / Windsurf

把 `SKILL.md` 复制到对应的 skill 目录：

```bash
# Claude Code（全局）
mkdir -p ~/.claude/skills/workspace-governance
cp SKILL.md ~/.claude/skills/workspace-governance/

# Cursor（项目级）
mkdir -p .cursor/skills/workspace-governance
cp SKILL.md .cursor/skills/workspace-governance/
```

### AlphaEngine

```bash
mkdir -p ~/.alphaclaw/skills/workspace-governance
cp SKILL.md ~/.alphaclaw/skills/workspace-governance/
```

### 其他 Agent

把 `SKILL.md` 放到你的 Agent 读取 skill/rule 文件的位置。内容是平台无关的 — 使用标准 shell 命令（`mv`、`rm`、`mkdir -p`、`ls`），在任何类 Unix 系统上都能工作。

## 推荐触发意图

- "整理工作区"
- "归档项目 <名称>"
- "创建项目 <名称>"
- "工作区审计" / "卫生检查"
- "先出计划再清理"

具体落地方式应由智能体结合本地系统约束决定，而不是照搬固定路径。

## 安全基线

- 破坏性动作先 dry-run 计划。
- 删除和批量移动必须显式确认。
- 默认不触碰版本控制元数据和敏感凭据。
- 同名冲突禁止覆盖。
- 每次执行保留摘要日志，便于回溯。

## 治理计划模板

执行前建议输出如下表格：

| 项目 | 当前状态 | 建议动作 | 目标位置 | 风险 | 原因 |
|------|----------|----------|----------|------|------|
| example.tmp | root | delete | — | 中 | 临时产物 |
| report-final.docx | root | ask-user | docs 或 archive | 低 | 目标归属不明确 |

## 说明

- 本仓库有意避免规定唯一目录树，强调“因地制宜”的治理策略。
- 若你需要强标准化，可通过 `SKILL_ADAPT` 或项目规则显式声明。
- 默认行为应保持保守、可逆、可追溯。

## 许可

MIT
