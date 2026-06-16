# Claude Code → Codex にレビューを依頼する

レビュー依頼元が **Claude Code** の場合の手順。

Codex の `/codex:review --wait` スキルは `disable-model-invocation: true` のため Skill ツールから自動呼び出しできない。そのため、そのスキルが内部で実行している `codex-companion.mjs` を Bash ツールで直接叩く。

## 手順

### ステップ 1: companion スクリプトのパスを解決

Bash ツールで以下を実行し、最新版の `codex-companion.mjs` のパスを得る。

```bash
ls -t ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null | head -1
```

- **見つかった場合** → ステップ 2 へ進む。
- **見つからない（空）場合** → ユーザーに「Codex プラグイン（codex-companion.mjs）が見つかりません」と伝えて中断する。

### ステップ 2: `review --wait` を実行

ステップ 1 で得たパスを使い、Bash ツールで以下を実行する。**timeout は 600000 ms（10 分）を必ず指定すること**。

```bash
node "$(ls -t ~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs | head -1)" review --wait
```

`--wait` でフォアグラウンド実行し、レビュー結果が返るまで待つ。

## 結果

得られたレビュー結果の全文をそのまま SKILL.md の呼び出し元に返す。
