# OfficeCLI v2.2 升级说明

> 本说明仅保留与脚本修复直接相关的匿名化技术信息。

## 升级内容

### Bug 1：克隆表后旧段落不清理

症状：克隆上一月表格后，新内容写入成功，但旧段落仍然残留在合并单元格中。

修复：在 `make_merged_row_ops()` 中增加段落计数与批量 `remove /p[1]` 逻辑，先清空旧内容再写入新内容。

### Bug 2：段落计数 JSON 解析错误

症状：即使单元格里存在旧段落，计数结果仍返回 0。

修复：改用 `json.loads()` 解析 `officecli query --json` 的输出，不再依赖脆弱的字符串匹配。

## 验证结果

| 验证项 | 结果 |
|---|---|
| 安全读取共享盘文件 | 通过 |
| 克隆表 | 通过 |
| 智能清空旧段落 | 通过 |
| 批量写入新段落 | 通过 |
| `officecli validate` | 通过 |
| 截图渲染 | 通过 |

## 使用方式

```bash
python3 scripts/gen_batch.py motion.docx 5 /tmp/content.json \
  | officecli batch motion.docx --json
```

## 验证建议

```bash
officecli query motion.docx "/body/tbl[5]/tr[N]/tc[2]/p" --json
officecli validate motion.docx
```
