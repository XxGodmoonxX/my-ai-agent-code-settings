---
name: external-agent-review
description: "外部エージェントにブランチ差分のコードレビューを依頼し、High/Medium/Low 形式で指摘を取得します"
context: fork
---

# 外部エージェントによるコードレビュー

レビューは常に **Codex** に依頼します。依頼方法はこのスキルを実行しているエージェント（＝レビュー依頼元）によって異なります。

自分自身がどのエージェントとして動作しているかを判定し、対応する手順に従ってください。

- **Claude Code** の場合 → 「手順 A」
- **それ以外**（Cursor など）の場合 → 「手順 B」

いずれの場合も、得られたレビュー結果の全文をそのまま出力する。要約や加筆はしない。

## 手順 A: Claude Code → Codex にレビューを依頼する

Codex の `/codex:review --wait` スキルは `disable-model-invocation: true` のため Skill ツールから自動呼び出しできない。そのため、そのスキルが内部で実行している `codex-companion.mjs` を Bash ツールで直接叩く。

### ステップ A-1: companion スクリプトのバージョンを解決

Bash ツールで以下を**この形のまま**（パイプ・グロブ・リダイレクトを足さずに）実行する。

```bash
ls -t ~/.claude/plugins/cache/openai-codex/codex/
```

出力は Codex プラグインのバージョンディレクトリ名（例: `1.0.4`）が更新日時の新しい順に並ぶ。

- **出力があった場合** → 1 行目（最新バージョン）を読み取り、ステップ A-2 へ進む。
- **出力が空、またはディレクトリが存在しない場合** → ユーザーに「Codex プラグイン（codex-companion.mjs）が見つかりません」と伝えて中断する。

### ステップ A-2: `review --wait` を実行

ステップ A-1 で読み取ったバージョンを `<バージョン>` に埋め込み、Bash ツールで以下を実行する。**パスは必ず `~/` 始まりで書き、クォートしない**。**timeout は 600000 ms（10 分）を必ず指定すること**。

```bash
node ~/.claude/plugins/cache/openai-codex/codex/<バージョン>/scripts/codex-companion.mjs review --wait
```

`--wait` でフォアグラウンド実行し、レビュー結果が返るまで待つ。

## 手順 B: Claude Code 以外（Cursor など）→ Codex にレビューを依頼する

`codex -p` コマンドでレビューを依頼する。

### ステップ B-1: 実行環境の確認

Bash ツールで `which codex` を実行し、`codex` コマンドが利用可能か確認する。

- **見つかった場合** → ステップ B-2 へ進む。
- **見つからない場合** → ユーザーに「`codex` コマンドが見つかりません」と伝えて中断する。

### ステップ B-2: `codex -p` でレビューを実行

Bash ツールで以下を実行する。**timeout は 600000 ms（10 分）を必ず指定すること**。

```bash
codex -p "このブランチの分岐元との差分を見てコードレビューしてください。改善点や問題点があればHigh,Medium,Lowの3段階でレベルをつけて具体的に指摘してください"
```
