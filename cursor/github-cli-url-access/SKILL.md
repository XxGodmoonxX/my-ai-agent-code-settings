---
name: github-cli-url-access
description: GitHubのURL（github.com または raw.githubusercontent.com）が入力に含まれるタスクで、Web fetchではなくGitHub CLI（gh）経由で情報取得・確認を行うための手順
disable-model-invocation: false
---
# GitHub URLアクセスをghで行う

## 基本方針

- 入力にGitHub URLが含まれる場合は、ページを直接fetchしない。
- まずURLを解析し、`owner/repo` と対象種別（repo / issue / pull / commit / file）を特定する。
- 取得・確認は `gh` コマンドを優先して実行する。

## 事前確認

- `gh --version` でCLIの利用可否を確認する。
- 必要に応じて `gh auth status` で認証状態を確認する。
- 未認証や権限不足で失敗した場合は、エラー内容をそのまま共有し、必要な認証手順を案内する。

## URL種別ごとの実行手順

- リポジトリ: `https://github.com/<owner>/<repo>`
  - `gh repo view <owner>/<repo>`
- Issue: `https://github.com/<owner>/<repo>/issues/<number>`
  - `gh issue view <number> --repo <owner>/<repo>`
- Pull Request: `https://github.com/<owner>/<repo>/pull/<number>`
  - `gh pr view <number> --repo <owner>/<repo>`
- Commit: `https://github.com/<owner>/<repo>/commit/<sha>`
  - `gh api repos/<owner>/<repo>/commits/<sha>`
- ファイル(blob): `https://github.com/<owner>/<repo>/blob/<ref>/<path>`
  - `gh api repos/<owner>/<repo>/contents/<path>?ref=<ref>`
- Raw URL: `https://raw.githubusercontent.com/<owner>/<repo>/<ref>/<path>`
  - `gh api repos/<owner>/<repo>/contents/<path>?ref=<ref>`

## 運用ルール

- `gh` で必要情報が取得できる限り、fetch系の手段へフォールバックしない。
- URLから判定できない情報がある場合は、`gh repo view` や `gh api` で補完してから処理する。
- 出力時は、どの `gh` コマンドで取得した情報かを簡潔に明記する。

