#!/usr/bin/env python3
"""
gen_batch.py — 生成 officecli batch JSON 用于批量填充观察表单元格

用法:
    python3 gen_batch.py <docx> <new_tbl_idx> <content.json> > batch.json
    cat batch.json | officecli batch <docx> --json

content.json 格式:
    {
        "R0": {  // 第 1 行：6 个独立单元格（不合并）
            "C1": "观察时间",     // 标签
            "C2": "2026年6月",   // 内容
            "C3": "观察者",
            "C4": "教师A",
            "C5": "观察对象",
            "C6": "幼儿A"
        },
        "R1_label": "观察目的",     // R2 行的标签
        "R1_content": "通过户外...",  // R2 行的合并单元格内容（5 列合并）
        "R2_content": "6月12日...",  // R3 行的合并单元格内容
        "R2_paragraphs": ["段落1", "段落2", "段落3"],  // 或者多段落
        "R3_content": "1. ...\n2. ...\n3. ...",  // R4 行（支持 \n 自动分段落）
        "R4_content": "..."           // R5 行
    }

所有的内容单元格都会自动应用：宋体、12pt、1.5倍行距、首行缩进 2 字符
"""

import json
import sys
import re
from pathlib import Path


def make_set_ops(tbl_idx, r0_data):
    """R0 是 6 个独立单元格，只更新偶数位的 C2/C4/C6（值），奇数位是标签"""
    ops = []
    for cidx, val in [(2, r0_data.get("C2")), (4, r0_data.get("C4")), (6, r0_data.get("C6"))]:
        if val:
            ops.append({
                "command": "set",
                "path": f"/body/tbl[{tbl_idx}]/tr[1]/tc[{cidx}]",
                "props": {"text": val}
            })
    return ops


def count_existing_paragraphs(docx, cell_path):
    """查询指定单元格当前有多少个段落（用 officecli query --json 计数）"""
    import subprocess, json
    res = subprocess.run(
        ["officecli", "query", docx, f"{cell_path}/p", "--json"],
        capture_output=True, text=True
    )
    try:
        data = json.loads(res.stdout)
        return data.get("data", {}).get("matches", 0)
    except (json.JSONDecodeError, KeyError):
        # fallback: 文本模式计数
        return res.stdout.count("(paragraph)")


def make_merged_row_ops(docx, tbl_idx, row_num, label, content):
    """生成一行：标签（不缩进）+ 内容（合并 5 列、缩进 2 字符）的操作序列

    Args:
        docx: 用于查询现有段落数
        row_num: 表格内的行号（1-based）
        content: 字符串（含 \\n 自动拆段）或字符串列表
    """
    ops = []
    label_path = f"/body/tbl[{tbl_idx}]/tr[{row_num}]/tc[1]"

    # 1. 设置标签
    ops.append({
        "command": "set",
        "path": label_path,
        "props": {"text": label, "bold": "true", "align": "center"}
    })

    # 2. 把现有 tc[2] 设为合并 5 列
    content_path = f"/body/tbl[{tbl_idx}]/tr[{row_num}]/tc[2]"
    ops.append({
        "command": "set",
        "path": content_path,
        "props": {"colspan": 5, "align": "left"}
    })

    # 3. 清空旧段落（克隆表格后旧段落会保留，必须先清除）
    #    先查询实际段落数，再生成精确的 remove ops
    existing_count = count_existing_paragraphs(docx, content_path)
    for _ in range(existing_count):
        ops.append({
            "command": "remove",
            "path": f"{content_path}/p[1]"
        })

    # 4. 拆分多段内容
    if isinstance(content, str):
        paragraphs = [p.strip() for p in content.split("\n") if p.strip()]
    else:
        paragraphs = content

    for para_text in paragraphs:
        ops.append({
            "command": "add",
            "parent": content_path,
            "type": "paragraph",
            "props": {
                "text": para_text,
                "font.latin": "宋体",
                "font.ea": "宋体",
                "size": "12pt",
                "lineSpacing": "1.5x",
                "firstLineChars": 200,  # 2 字符缩进
            }
        })

    return ops


def main():
    if len(sys.argv) != 4:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    docx, tbl_idx_str, content_json_path = sys.argv[1], sys.argv[2], sys.argv[3]
    tbl_idx = int(tbl_idx_str)

    if not Path(docx).exists():
        print(f"❌ 文件不存在: {docx}", file=sys.stderr)
        sys.exit(1)

    content = json.loads(Path(content_json_path).read_text(encoding="utf-8"))

    ops = []
    # R0：6 个独立单元格
    if "R0" in content:
        ops.extend(make_set_ops(tbl_idx, content["R0"]))

    # R1-R4：合并单元格
    # 运动观察模板: tbl[N]/tr[1]=R0, tr[2]=R1(观察目的), tr[3]=R2(观察记录), tr[4]=R3(分析), tr[5]=R4(策略)
    for row_num, label_key, content_key in [
        (2, "R1_label", "R1_content"),
        (3, "R2_label", "R2_content"),
        (4, "R3_label", "R3_content"),
        (5, "R4_label", "R4_content"),
    ]:
        if label_key in content and content_key in content:
            label = content[label_key]
            body = content[content_key]
            ops.extend(make_merged_row_ops(docx, tbl_idx, row_num, label, body))

    print(json.dumps(ops, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
