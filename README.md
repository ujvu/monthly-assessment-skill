# monthly-assessment

`monthly-assessment` 是一个面向学前教育场景月度材料处理的技能目录，覆盖两类核心任务：

- 基于 `officecli` 生成和修改月度观察与备课文档
- 基于既有规则处理月度考核相关 Excel 计算

## 包含内容

- `SKILL.md`
  - 技能总览、适用场景、命令参考与常见坑
- `references/`
  - `月考核作业.md`：文档生成工作流
  - `月考核计算.md`：Excel 考核计算规则
  - `月考核-匿名运动观察案例.md`：匿名化实战案例
  - `officecli-v2.2-升级说明.md`：升级说明
- `scripts/`
  - `append_motion_table.sh`：追加运动观察月份表
  - `gen_batch.py`：生成 `officecli` 批处理 JSON

## 主要能力

- 追加和复用运动观察记录表格模板
- 统一应用宋体、12pt、1.5 倍行距、首行缩进等格式规则
- 生成适合 `officecli batch` 的批量写入操作
- 沉淀月度考核 Excel 奖励、扣款与补贴口径

## 依赖

- `officecli`
- `python3`

## 快速开始

```bash
./scripts/append_motion_table.sh /path/to/motion.docx 4 2026年6月
python3 ./scripts/gen_batch.py /path/to/motion.docx 5 ./content.json > batch.json
```

更完整的工作流请看 [`SKILL.md`](./SKILL.md) 和 `references/` 下的说明。
