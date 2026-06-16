# Claude Code → Codex にレビューを依頼する

レビュー依頼元が **Claude Code** の場合の手順。Codex のスキル `/codex:review --wait` を使ってレビューを依頼する。

## 手順

Skill ツールで `codex:review` スキルを `--wait` 引数付きで呼び出す。

- skill: `codex:review`
- args: `--wait`

`--wait` を指定することで、バックグラウンドではなくフォアグラウンドで実行し、レビュー結果が返るまで待つ。

`codex:review` スキルが利用できない場合は、ユーザーに「`codex:review` スキルが見つかりません」と伝えて中断する。

## 結果

得られたレビュー結果の全文をそのまま SKILL.md の呼び出し元に返す。
