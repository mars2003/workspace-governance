# scripts

存放治理辅助脚本，例如：

- 目录结构检查
- 批量审计导出
- 日志归档

建议脚本命名：`check_*.sh`、`check_*.py`。

## 现有脚本

- `check_skill_contract.sh`：检查 `SKILL.md` 是否包含关键治理契约段落

## 使用示例

```bash
# 在仓库根目录执行
bash scripts/check_skill_contract.sh

# 检查指定文件
bash scripts/check_skill_contract.sh ./SKILL.md
```
