---
name: monthly-assessment
description: 学前教育场景月度考核工作流：基于 OfficeCLI 的文档生成（游戏观察记录、运动观察记录、半日备课）+ Excel 考核表计算（奖励、扣款、补贴）
license: MIT
metadata:
  hermes:
    related_skills: [officecli, officecli-recipes, document-processing]
---

# 月考核（匿名示例）v2 — OfficeCLI 版

适用于学前教育场景的月度材料工作流。仓库中的示例、路径、人物与机构信息均已做匿名化处理。**v2 (2026-06)** 全面从 `python-docx` 迁到 [`officecli`](https://officecli.ai) — 单二进制、无 Office 依赖、可视化预览，Agent 友好。

## 触发词

- "月考核" / "月度考核" / "考核文档"
- "游戏观察记录" / "运动观察记录" / "半日活动备课"
- "考核奖励" / "考核扣款" / "补贴" / "顶班费"

## 目录结构

```
monthly-assessment/
├── SKILL.md                    ← 本文件：总览和索引
├── references/
│   ├── 月考核计算.md            ← Excel 考核表计算规则（2026年新结构）
│   ├── 月考核作业.md            ← 文档生成的 officecli 工作流（v2 全新）
│   ├── 月考核-匿名运动观察案例.md
│   └── officecli-v2.2-升级说明.md  ← gen_batch.py 智能清空升级背景 (2026-06-13)
└── scripts/
    ├── append_motion_table.sh   ← 运动观察记录：追加新月份表（最常用）
    └── gen_batch.py             ← 生成 officecli batch JSON（v2.2 智能清空）
```

## v2 重大改进（vs. python-docx 版）

| 维度 | v1 (python-docx) | v2 (officecli) |
|---|---|---|
| Office 依赖 | python-docx + lxml | **无**（单二进制） |
| `cell.text = x` 破坏合并 | 必踩坑 | `colspan=5` 自动合并，**不再有** |
| 跨段落多行内容 | 手动 add_paragraph + format | `add --type paragraph` + `--prop` 一次完成 |
| 实时预览 | 必须开 Word/LibreOffice | `officecli watch <file>` 自动刷新 |
| 视觉验证 | 无（Agent 盲改） | `view html/screenshot` 渲染 |
| 命令行友好度 | 50 行 Python | **1-3 行 shell** |
| 与共享盘死锁 | 频繁 | 同样适用 O_NONBLOCK 读取（见 v1 文档） |

## 两大工作流

### 工作流一：文档生成（officecli）

**核心规范**（文档生成必须遵守）：
- 字体：宋体（SimSun），字号：12pt（小四）
- 行距：1.5 倍（`lineSpacing=1.5x`）
- 内容列首行缩进：2 字符（`firstLineChars=200`）
- 标签列无首行缩进
- 横向合并：用 `--prop colspan=N`（不要再用 `cell.text=`，会破坏合并）
- 现有表格追加新月份：**用 `--from /body/tbl[N]` 克隆**，保证格式 100% 复用

**三大文档生成模板**：
- **游戏观察记录表**（6 行 4 列）：标题 + 5 行内容
- **运动观察记录表**（5 行 6 列）：第 1 行 6 列无合并，2-5 行第 1 列标签 + 第 2 列 5 列合并
- **半日活动备课**（27 行大表格）：行 0-3 基础信息 + 4-23 分段模板

**标准操作流程**（运动观察 6月 追加，1 分钟完成）：
```bash
# 1. 打开现有文件（officecli auto-resident）
# 2. 克隆 5月 表为新 6月 表
officecli add motion.docx /body --type table --from /body/tbl[4]

# 3. 修改 R0 时间 + 填充 R1-R4 合并单元格
officecli set motion.docx '/body/tbl[5]/tr[1]/tc[2]' --prop text="2026年6月"
officecli set motion.docx '/body/tbl[5]/tr[2]/tc[1]' --prop text="观察目的" --prop bold=true
officecli set motion.docx '/body/tbl[5]/tr[2]/tc[2]' --prop colspan=5 --prop text="..."

# 4. 验证
officecli view motion.docx screenshot -o /tmp/preview.png
```

完整命令集 + 多段落内容 + 完整示例见 `references/月考核作业.md`。

> 💡 **遇到 officecli 环境问题**（OOM、codesign 卡死、空段落、Excel range 语法）→ 切到 `officecli-recipes` skill，那里有一份**这个 macOS 环境的实战坑位清单**（坑 1-9）。

### 工作流二：Excel 考核表计算（保持原样）

修改月考核相关 Excel 文件（2026 年新结构），用 Python `openpyxl` 计算奖励、扣款、补贴等：

- 在编考核表（月考核 + 月绩效）
- 月考核表（园区 A / 园区 B / 园区 C）
- 非编考核表（劳务派遣）
- 代课考核表

**2026年结构要点**（与 v1 一致）：
- 教师月考核基数：1000元/月
- 后勤月考核基数：900元/月
- 请假扣款基数：3800元（应发）+ 1000元（月考核）
- 每月工作天数：20.67天

> 💡 **未来考虑**：v3 可用 `officecli` 直接读/写 Excel（`xlsx add cell --ref A1 --prop value=...`），但当前 v2 暂保留 openpyxl 写法以最小化风险。

See `references/月考核计算.md` for full calculation rules.

## ⚠️ 常见坑（2026-06 v2 实战后补，v2.2 修复智能清空）

| 坑 | 后果 | 正确做法 |
|---|---|---|
| 把往期模板当当前文件读 | 用户纠错：`你读取错误了` | **永远先找当前学期**的 `{学期}月考核/`，往期资料只做格式参考 |
| 共享盘路径写错 | 路径不存在 / 死锁 | 使用你本机实际挂载点，如 `/Volumes/shared/` |
| `cell.text = "..."` 直接赋值 | v1 必踩坑（破坏横向合并） | **v2 用 `--prop colspan=N`** 一步到位 |
| 用 `add paragraph` 时忘了 `--prop font.ea=宋体` | 中文回退到 Calibri | 三件套必加：`font.latin=宋体 font.ea=宋体 size=12pt` |
| `find /Volumes/shared/` 全盘扫描 | 共享盘死锁（>5min 卡死） | 用 Python `os.walk` + `signal.alarm(25)` 分批扫描 + 25s 超时 |
| 44MB 的 docx 用 officecli `get /` 一次拉全树 | OOM killed (exit 137) | 用 `get /body/tbl[N]` 单表读取 |
| 半日备课 27 行模板里混用 5/6 列结构 | 合并错位 | **135上午模板用 6 行 6 列结构，24 下午模板用 5 行 5 列结构**（见 references） |
| 雨天备课忘了改"户外→室内" | 写错了 5 个单元格的"场地/材料/要点" | 按 `月考核作业.md` 雨天模板的 5 步改写清单逐条核对 |
| officecli 无输出/卡死 5+ 分钟 | `codesign -v` 挂起（首次安装后） | `pkill -9 -f "codesign.*officecli"` 再重试。详见 `officecli-recipes` skill 坑 7 |
| ~~合并 cell 多余空行~~ ✅ v2.2 修复 | ~~`set --prop text=""` 留旧空段落~~ | **`gen_batch.py` v2.2 已内置智能清空**（`query --json` 查段落数 + N 次 `remove /p[1]`）。详见 `officecli-recipes` 坑 8 "省事方案 B" |
| `gen_batch.py` count_existing_paragraphs 字符串匹配 JSON | count=0 → 不清空 → 旧内容残留 | 永远用 `json.loads(res.stdout)["data"]["matches"]` 解析（详见 `officecli-recipes` 坑 8b） |

## 🚀 快速验证

```bash
# 1. 确认 officecli 已装
officecli --version    # 应回 1.0.x

# 2. 一键 demo：把第 4 张表克隆成 6月 表
./scripts/append_motion_table.sh /tmp/test-motion.docx 4 2026年6月

# 3. 渲染验证
officecli view /tmp/test-motion.docx screenshot -o /tmp/preview.png
```

## 完整命令参考

| 任务 | 命令 |
|---|---|
| 打开文件 | `officecli open <file>`（auto-resident 也可） |
| 克隆现有表 | `officecli add <file> /body --type table --from /body/tbl[N]` |
| 设置单元格文字 | `officecli set <file> /body/tbl[M]/tr[R]/tc[C] --prop text="..."` |
| 横向合并 | `officecli set <file> /body/tbl[M]/tr[R]/tc[C] --prop colspan=N` |
| 单元格格式化 | `--prop font=宋体 size=12pt bold=true align=left` |
| 添加段落 | `officecli add <file> <parent> --type paragraph --prop text="..." font.ea=宋体` |
| 查找替换 | `officecli set <file> /body --find "old" --replace "new"` |
| 删除元素 | `officecli remove <file> <path>` |
| 实时预览 | `officecli watch <file>` → http://localhost:26315 |
| HTML 渲染 | `officecli view <file> html > /tmp/out.html` |
| 截图验证 | `officecli view <file> screenshot -o /tmp/out.png` |
| 批量操作 | `officecli batch <file> --input batch.json` |
| 验证格式 | `officecli validate <file>` |
| 帮助查询 | `officecli help docx table-cell`（任何不确定的属性先查 help） |

## 迁移检查清单（v1 → v2）

- [x] 安装 officecli
- [x] 三大文档模板的 officecli 命令序列
- [x] 横向合并 + 字体 + 行距 + 首行缩进的统一参数
- [x] 雨天/24下午/135上午三种变体的处理
- [x] 现有共享盘 docx 的安全读取（O_NONBLOCK 仍适用）
- [x] 写入后的视觉验证（screenshot）
- [ ] 半日备课 27 行完整命令（v2.1 待补）
- [ ] Excel 计算也迁到 officecli（v3 计划）
