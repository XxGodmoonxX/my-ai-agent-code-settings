---
name: external-agent-review
description: "外部エージェントにブランチ差分のコードレビューを依頼し、High/Medium/Low 形式で指摘を取得します"
context: fork
---

# 外部エージェントによるコードレビュー

レビューは常に **Codex** に依頼します。依頼方法はこのスキルを実行しているエージェント（＝レビュー依頼元）によって異なります。

## ステップ 1: レビュー依頼元を判定し、対応するドキュメントを読む

自分自身がどのエージェントとして動作しているかを判定し、対応する手順書を Read ツールで読んでその手順に従う。

| レビュー依頼元 | 読む手順書 |
| --- | --- |
| **Claude Code** | `references/review-codex-from-claude-code.md` |
| **それ以外**（Cursor など） | `references/review-codex-from-non-claude-code.md` |

（パスはこの SKILL.md があるディレクトリからの相対パス）

## ステップ 2: 結果を返す

手順書に従って取得したレビュー結果の全文を、そのまま出力する。要約や加筆はしない。
