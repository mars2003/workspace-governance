# workspace-governance

[English](README.md)

一个通用的 AI Agent 工作区整理技能。

适用于任何支持 skill/rule 文件的 AI 编码助手 — Claude Code、Cursor、Windsurf、AlphaEngine 等。

## 解决什么问题

AI Agent 在工作过程中不断创建文件 — 脚本、图片、报告、临时输出。没有规则约束的工作区很快变成一团糟：

- 根目录堆满杂七杂八的文件
- 做完的项目没人归档
- 备份文件越攒越多
- 命名混乱（`test1.py`、`未命名`、各种中文目录名）
- 构建产物（`node_modules/`、`__pycache__/`）到处都是

## 怎么用

给 Agent 下一个简单指令，它自己处理：

| 你说 | Agent 做什么 |
|------|------------|
| "整理一下" | 扫描根目录、分类文件、展示计划、确认后执行 |
| "创建项目 xxx" | 在 `active/xxx/` 下创建项目骨架 |
| "xxx 做完了" | 归档项目、清理临时文件、记录日志 |
| "清理" | 跑一遍卫生检查清单、报告违规项、建议修复 |

**安全第一** — 所有移动和删除操作都会先展示为 dry-run 计划表格，确认后才执行。

## 目录结构

```
<workspace>/
├── active/          # 活跃项目
├── scripts/         # 全局工具脚本
├── docs/            # 文档、参考资料
├── assets/          # 图片、音视频、文档资源
├── archives/        # 归档区
│   ├── projects/
│   └── assets/
├── memory/          # Agent 状态和日志
├── cache/           # 自动过期缓存（≤7 天）
└── tmp/             # 临时工作空间
```

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

## 核心设计决策

**默认 Dry-run。** 所有破坏性操作先展示计划。Agent 不能在未经确认的情况下删除或移动文件。

**受保护路径。** 版本控制（`.git/`）、环境变量（`.env`）、密钥证书（`*.key`、`*.pem`）、Agent 配置目录永远不会被触碰。

**同名冲突安全。** 往已有 `image.png` 的目录移入同名文件？自动变成 `image-20260427.png`。绝不覆盖。

**操作日志。** 每次整理/归档操作都记录到 `memory/workspace-log.md`，带日期和摘要，留有痕迹。

**按需创建目录。** 不会一上来就创建所有空目录。用到哪个建哪个。

## 示例

**整理前：**
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

**你说：** "帮我整理一下"

**Agent 展示计划：**

| 文件 | 操作 | 目标 | 原因 |
|------|------|------|------|
| image.png | 移动 | assets/ | 非文本资源 |
| report.pptx | 移动 | assets/ | 文档 |
| notes.txt | 移动 | docs/ | 用户内容 |
| test.py | 移动 | scripts/ | 脚本（建议重命名） |
| config.yaml.bak.3 | 删除 | — | 超过 3 份备份上限 |
| \_\_pycache\_\_/ | 删除 | — | 构建产物 |
| node_modules/ | 删除 | — | 构建产物 |

**你说：** "执行"

**整理后：**
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

## 许可

MIT
