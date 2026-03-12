# Skill: wf-03-implement

タスク実装担当。計画に従い実行し、ゲートを検証し、コミット・PRを作成する。

## 前提条件（必須）

1. `.agents/tasks/<issue>/<task>.md` 存在確認 → なければ STOP
2. `git branch --show-current` がタスクのブランチと一致 → 不一致なら STOP
3. 完了ゲートが全て `[x]` → STOP「既に完了」

## プロセス

1. タスクファイルを読む（ゲート・ステップ把握）
2. 実装ステップを順番に実行: 1ステップ→`[x]`チェックオフ→次へ
   - 不明・スコープ問題 → STOP して人間に確認
   - 禁止: スキップ・未依頼機能追加・スコープ変更
3. 完了ゲートを検証: 各ゲート実行→通過`[x]`→失敗はSTOP報告
4. Implementation Notes をタスクファイルに記録（方向変更・発見事項）
5. コミットサイズ確認: `git diff --stat`（期待: 50〜200行、1〜5ファイル）
6. コミット・PR作成（自律実行）:
   `git add -A && git commit -m "[msg]" && git push origin <branch>`
   `gh pr create --title "[title]" --body "[PRテンプレートに従う]"`

## ルール

- **コミット・PR作成は自律実行**（vibe-localの責務）
- **PRをMergeしない**（人間の最終権限）
- ゲートを変更しない（実装を修正する）
- 同じ問題で3回失敗 → `/wf-summarise` で新セッション

## 完了後

```
Task <task> 実装完了 / ステップ[N/N] / ゲート[N/N] / PR:#<番号>
次: 残Gatesあり→/wf-02-task-plan <issue> / 全完了→/wf-04-cleanup <issue>
人間: PRをレビュー・Merge（最終権限は人間）
```