# monthly-assessment 安装指令

这份说明是给其他智能体读取和执行的。

目标：从 GitHub 下载 `monthly-assessment` 项目，并把它安装到本机技能目录。

仓库地址：

- GitHub: `https://github.com/ujvu/monthly-assessment-skill`
- 默认分支: `main`

## 最简安装方式

如果本机已经有 `git`，直接执行：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ujvu/monthly-assessment-skill/main/scripts/install_from_github.sh)"
```

## 智能体执行规则

1. 先检查 `git` 是否可用。
2. 默认安装到：
   - `~/.hermes/skills/productivity/monthly-assessment`
3. 如果该目录已存在：
   - 且是 Git 仓库：执行更新
   - 否则：先备份为 `monthly-assessment.bak.<timestamp>`
4. 安装完成后，确认以下文件存在：
   - `SKILL.md`
   - `README.md`
   - `references/月考核作业.md`
   - `scripts/append_motion_table.sh`
   - `scripts/gen_batch.py`
5. 再检查本机是否已有这些辅助技能：
   - `officecli`
   - `officecli-recipes`
   - `document-processing`
   - `pdf-tools`

## 手动安装方式

```bash
mkdir -p ~/.hermes/skills/productivity
git clone https://github.com/ujvu/monthly-assessment-skill.git \
  ~/.hermes/skills/productivity/monthly-assessment
```

如果目录已存在，改为：

```bash
git -C ~/.hermes/skills/productivity/monthly-assessment pull --ff-only
```

## 可选：接入其他智能体目录

如果需要让其他本地智能体直接发现这个技能，可以建立软链接：

```bash
mkdir -p ~/.agents/skills/monthly-assessment
ln -sfn ~/.hermes/skills/productivity/monthly-assessment/SKILL.md \
  ~/.agents/skills/monthly-assessment/SKILL.md
```

如果需要接入别的技能目录，也使用同样模式：链接它的 `SKILL.md` 即可。

## 辅助技能整合

这个项目不是孤立使用的。安装后，其他智能体还应该优先读取这些本地技能：

| 技能 | 默认本地路径 | 用途 |
|---|---|---|
| `officecli` | `~/.hermes/skills/officecli/SKILL.md` | 主文档编辑能力 |
| `officecli-recipes` | `~/.hermes/skills/productivity/officecli-recipes/SKILL.md` | 本机实战配方 |
| `document-processing` | `~/.hermes/skills/document/document-processing/SKILL.md` | 共享盘死锁、python-docx、解析兜底 |
| `pdf-tools` | `~/.hermes/skills/productivity/pdf-tools/SKILL.md` | PDF / OCR / 扫描件处理 |

推荐读取顺序：

1. `monthly-assessment/SKILL.md`
2. `monthly-assessment/references/月考核作业.md`
3. `officecli/SKILL.md`
4. `officecli-recipes/SKILL.md`
5. `document-processing/SKILL.md`
6. `pdf-tools/SKILL.md`（仅在 PDF 输入时需要）

## 安装后验证

```bash
test -f ~/.hermes/skills/productivity/monthly-assessment/SKILL.md
test -f ~/.hermes/skills/productivity/monthly-assessment/references/月考核作业.md
test -x ~/.hermes/skills/productivity/monthly-assessment/scripts/append_motion_table.sh
python3 ~/.hermes/skills/productivity/monthly-assessment/scripts/gen_batch.py --help || true
test -f ~/.hermes/skills/officecli/SKILL.md || true
test -f ~/.hermes/skills/productivity/officecli-recipes/SKILL.md || true
test -f ~/.hermes/skills/document/document-processing/SKILL.md || true
test -f ~/.hermes/skills/productivity/pdf-tools/SKILL.md || true
```

## 更新指令

```bash
bash ~/.hermes/skills/productivity/monthly-assessment/scripts/install_from_github.sh
```

## 依赖说明

- 运行脚本依赖：`bash`、`git`
- 使用技能时通常还需要：`python3`、`officecli`

## 给智能体的简版指令

如果你是其他智能体，可以直接执行下面这段：

```bash
curl -fsSL https://raw.githubusercontent.com/ujvu/monthly-assessment-skill/main/scripts/install_from_github.sh | bash
```

更完整的智能体专用提示词见 [`AGENT_PROMPT.md`](./AGENT_PROMPT.md)。
