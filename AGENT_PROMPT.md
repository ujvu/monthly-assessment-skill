# monthly-assessment 智能体专用提示词

把下面这段直接交给其他智能体即可：

```text
你现在需要接入并使用 monthly-assessment 技能。

先执行安装：
curl -fsSL https://raw.githubusercontent.com/ujvu/monthly-assessment-skill/main/scripts/install_from_github.sh | bash

安装后，按下面顺序读取技能：
1. ~/.hermes/skills/productivity/monthly-assessment/SKILL.md
2. ~/.hermes/skills/productivity/monthly-assessment/references/月考核作业.md
3. ~/.hermes/skills/officecli/SKILL.md
4. ~/.hermes/skills/productivity/officecli-recipes/SKILL.md
5. ~/.hermes/skills/document/document-processing/SKILL.md
6. ~/.hermes/skills/productivity/pdf-tools/SKILL.md（仅当输入文件是 PDF、扫描件或图片时）

执行规则：
- 月考核相关任务，优先使用 monthly-assessment 作为主技能。
- 修改 `.docx` 时，优先使用 officecli。
- 如果遇到共享盘死锁、超大文档、officecli 卡死、批量填表问题，切到 officecli-recipes。
- 如果需要 python-docx、文档解析、格式转换、共享盘低层读取，切到 document-processing。
- 如果输入材料来自 PDF 或扫描件，先经过 pdf-tools，再回到 monthly-assessment 工作流。

输出要求：
- 先说明你当前读取了哪些技能。
- 再说明这次任务会走哪条技能链路。
- 改文档时优先保留原格式，不要随意重建结构。
- 如果路径在共享盘下，优先使用安全读取或本机已有稳定方案。
```

## 极简版

如果只想给其他智能体一行入口，用这段：

```text
先运行 curl -fsSL https://raw.githubusercontent.com/ujvu/monthly-assessment-skill/main/scripts/install_from_github.sh | bash ，然后按顺序读取 monthly-assessment → 月考核作业 → officecli → officecli-recipes → document-processing；如果输入是 PDF 或扫描件，再补读 pdf-tools。
```
