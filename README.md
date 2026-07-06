# monthly-assessment

`monthly-assessment` 是一个面向学前教育场景月度材料处理的技能目录，覆盖两类核心任务：

- 基于 `officecli` 生成和修改月度观察文档
- 支持月考核备课相关材料整理

## 包含内容

- `SKILL.md`
  - 技能总览、适用场景、命令参考与常见坑
- `references/`
  - `月考核作业.md`：文档生成工作流
  - `月考核-匿名运动观察案例.md`：匿名化实战案例
  - `officecli-v2.2-升级说明.md`：升级说明
- `scripts/`
  - `append_motion_table.sh`：追加运动观察月份表
  - `gen_batch.py`：生成 `officecli` 批处理 JSON

## 主要能力

- 追加和复用运动观察记录表格模板
- 统一应用宋体、12pt、1.5 倍行距、首行缩进等格式规则
- 生成适合 `officecli batch` 的批量写入操作
- 为月考核作业与备课材料提供可复用工作流

## 推荐搭配技能

- `officecli`
  - 负责 `.docx` 的主编辑流程
- `officecli-recipes`
  - 负责当前这台机器上的实战配方和常见坑处理
- `document-processing`
  - 负责共享盘死锁绕过、`python-docx` 兜底、文档解析
- `pdf-tools`
  - 当输入材料是 PDF 或扫描件时先做提取或 OCR

## 依赖

- `officecli`
- `python3`

## 安装

可直接使用仓库内置安装脚本：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ujvu/monthly-assessment-skill/main/scripts/install_from_github.sh)"
```

完整说明见 [`INSTALL.md`](./INSTALL.md)。

给其他智能体直接使用的提示词见 [`AGENT_PROMPT.md`](./AGENT_PROMPT.md)。

## 快速开始

```bash
./scripts/append_motion_table.sh /path/to/motion.docx 4 2026年6月
python3 ./scripts/gen_batch.py /path/to/motion.docx 5 ./content.json > batch.json
```

更完整的工作流请看 [`SKILL.md`](./SKILL.md) 和 `references/` 下的说明。
