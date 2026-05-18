---
name: external-agent-review
description: "外部エージェントにブランチ差分のコードレビューを依頼し、High/Medium/Low 形式で指摘を取得します"
context: fork
---

# 外部エージェントによるコードレビュー

自分が **Claude Code** である場合は Cursor CLI (`agent`) を使ってレビューを取得します。

## 手順

### ステップ 1: 実行環境の確認

Bash ツールで以下を実行し、`agent` コマンドが利用可能か確認する：

```bash
which agent
```

- **見つかった場合** → Cursor CLI が使える環境（Claude Code）。ステップ 2 へ進む。
- **見つからない場合** → ユーザーに「`agent` コマンドが見つかりません」と伝えて中断する。

### ステップ 2: Cursor CLI でレビューを実行

Bash ツールで以下を実行する。**timeout は 600000 ms（10 分）を必ず指定すること**。

```bash
agent -p "このブランチの分岐元との差分を見てコードレビューしてください。改善点や問題点があればHigh,Medium,Lowの3段階でレベルをつけて具体的に指摘してください"
```

### ステップ 3: 結果を返す

レビュー結果の全文をそのまま出力する。
