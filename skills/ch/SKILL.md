---
name: ch
description: Switch user↔agent communication to Traditional Chinese (繁體中文) for the rest of the session. On invocation, always re-states the previous assistant turn in Traditional Chinese regardless of its original language. File outputs, code, commit messages, and technical terms keep their English names.
---

# 繁體中文通訊模式

## 立即執行（invoke 時）

1. 查看**上一個 assistant turn**（這個 `/ch` 指令之前的那一條）。
2. 用繁體中文重新說一次那個 turn 的內容（不管原本是什麼語言），再宣告切換完成。

## 持續規則（本次 session 剩餘部分）

**對話語言** — 所有 user↔agent 之間的文字溝通一律使用繁體中文。

**保留英文的例外**：

- **檔案輸出** — 寫入檔案的內容（程式碼、設定、文件）維持原本語言，不受此規則影響。
- **Shell / git 輸出** — commit message、指令、路徑、shell 輸出保持英文。
- **系統專有名詞** — 討論 workspace / plugin 系統時，已有的 term 保留英文原文，不翻譯。包括但不限於：skill、agent、command、source-audit、PRINCIPLES.md、CLAUDE.md、type marker、Band A/B/C、apply worklist、lift worklist、three-axis gate、source entry、compiled artifact、LIFT.md。
- **程式碼片段** — inline code 和 code block 內容保持英文。

**不硬翻** — 技術 term 不強行翻成中文。例如：「source entry」不譯成「來源條目」；「apply worklist」不譯成「套用清單」。混用英文 term 在繁體中文句子裡是正常的。
