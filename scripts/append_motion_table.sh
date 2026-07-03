#!/usr/bin/env bash
# append_motion_table.sh — 在运动观察记录 docx 中追加新的月份观察表
#
# 用法:
#   ./append_motion_table.sh <docx> <源表格索引> <新月份文字>
#
# 示例:
#   ./append_motion_table.sh motion.docx 4 2026年6月
#
# 它会:
#   1. 克隆源表格（保留所有格式：宋体12pt、1.5x行距、横向合并、边框）
#   2. 修改 R0C2 为新月份文字
#   3. 留下 R1-R4 的合并单元格供你后续用 set/--find --replace 编辑
#   4. 渲染截图到 /tmp/preview.png 供验证

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "用法: $0 <docx> <源表索引 1-based> <新月份文字>"
  echo "示例: $0 motion.docx 4 2026年6月"
  exit 1
fi

DOCX="$1"
SRC_IDX="$2"  # 源表索引，1-based（4=5月表）
NEW_MONTH="$3"

if [[ ! -f "$DOCX" ]]; then
  echo "❌ 文件不存在: $DOCX"
  exit 1
fi

# 安全读取（共享盘文件用 O_NONBLOCK 绕过死锁）
WORK_COPY="/tmp/_motion_$(date +%s).docx"
python3 - <<PY
import os, shutil
src, dst = "${DOCX}", "${WORK_COPY}"
if src.startswith('/Volumes/shared/'):
    fd = os.open(src, os.O_RDONLY | os.O_NONBLOCK)
    data = b''
    while True:
        chunk = os.read(fd, 65536)
        if not chunk: break
        data += chunk
    os.close(fd)
    with open(dst, 'wb') as f: f.write(data)
    print(f"📋 安全复制: {len(data)} bytes -> {dst}")
else:
    shutil.copy(src, dst)
    print(f"📋 复制: {dst}")
PY

# 找现有表数，确定新表索引
TBL_COUNT=$(officecli get "$WORK_COPY" /body --depth 1 2>/dev/null | grep -c "tbl\[" || echo 0)
NEW_IDX=$((TBL_COUNT + 1))
echo "📊 现有 $TBL_COUNT 张表，新表将编号: tbl[$NEW_IDX]"

# 1. 克隆源表
echo "🔄 克隆 tbl[$SRC_IDX] -> tbl[$NEW_IDX]..."
officecli add "$WORK_COPY" /body --type table --from "/body/tbl[$SRC_IDX]" >/dev/null

# 2. 修改新表的 R0C2 月份
echo "📝 设置 R0C2 = $NEW_MONTH"
officecli set "$WORK_COPY" "/body/tbl[$NEW_IDX]/tr[1]/tc[2]" --prop text="$NEW_MONTH" >/dev/null

# 3. 渲染截图
PREVIEW="/tmp/motion_preview_$(date +%s).png"
echo "📸 渲染截图: $PREVIEW"
officecli view "$WORK_COPY" screenshot -o "$PREVIEW" 2>&1 | tail -1

# 4. 显示新表结构
echo ""
echo "✅ 克隆完成！新表结构："
officecli get "$WORK_COPY" "/body/tbl[$NEW_IDX]" 2>/dev/null | head -3
echo ""
echo "📋 接下来你可以这样填 R1-R4 的合并单元格："
echo "   officecli set $WORK_COPY '/body/tbl[$NEW_IDX]/tr[2]/tc[1]' --prop text='观察目的' --prop bold=true"
echo "   officecli set $WORK_COPY '/body/tbl[$NEW_IDX]/tr[2]/tc[2]' --prop colspan=5 --prop text='<你的观察目的内容>'"
echo "   ... 同样模式处理 R3-R5"
echo ""
echo "📁 工作副本: $WORK_COPY"
echo "🖼️  预览:    $PREVIEW"
