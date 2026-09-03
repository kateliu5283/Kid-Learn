#!/usr/bin/env python3
"""在 chinese_lessons.dart 中，於尚未含 objectives 的 Lesson 內，summary 之後插入 objectives/keyPoints/vocabulary。"""
from __future__ import annotations

import pathlib

BLOCK = """    objectives: [
      '能理解本單元課文或語料的重點，並正確朗讀',
      '能辨識與運用相關字詞於簡單句子中',
      '能口述或寫出一句與主題相關的完整語句',
    ],
    keyPoints: [
      '閱讀時先掌握段落大意，再標示細節與生字',
      '書寫時注意筆順、間架與標點',
      '口語發表要語句完整、條理清楚',
    ],
    vocabulary: [
      VocabItem(term: '課文', meaning: '共同閱讀的教材文章', example: '朗讀課文兩次'),
      VocabItem(term: '段落', meaning: '依意思分段的文章單位', example: '第一段寫景物'),
      VocabItem(term: '語感', meaning: '對語句是否通順的敏銳度', example: '大聲朗讀培養語感'),
    ],
"""


def main() -> None:
    root = pathlib.Path(__file__).resolve().parents[1]
    path = root / "lib" / "curriculum" / "chinese" / "chinese_lessons.dart"
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    insert_after_summary_line: set[int] = set()

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if stripped.startswith("summary:") and stripped.endswith(","):
            j = i + 1
            found_objectives = False
            while j < len(lines) and j < i + 120:
                s = lines[j].strip()
                if s.startswith("objectives:"):
                    found_objectives = True
                if s.startswith("questions:"):
                    break
                j += 1
            if not found_objectives:
                insert_after_summary_line.add(i)
        i += 1

    out: list[str] = []
    for idx, line in enumerate(lines):
        out.append(line)
        if idx in insert_after_summary_line:
            out.append(BLOCK)

    path.write_text("".join(out), encoding="utf-8")
    print("inserted blocks after", len(insert_after_summary_line), "summary lines ->", path)


if __name__ == "__main__":
    main()
