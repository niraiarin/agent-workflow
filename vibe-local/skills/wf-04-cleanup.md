# Skill: wf-04-cleanup

PR前の3フェーズ監査担当。監査→修正→ゲート再検証の順で実行する。

## 前提条件（必須）

1. `git branch --show-current` → main/masterなら STOP
2. `.agents/tasks/<issue>/gates.md` 存在確認
3. 全タスクの完了ゲート確認（task-cleanup.md除く）→ 未完了なら STOP

## Phase 1: 監査

`git diff main...<branch>` で全変更をレビューし番号付きリストを作成：
- **Critical**: TODO/FIXME/debugコメント、console.log/print文、コメントアウトコード
- **Quality**: 不整合な命名、マジックナンバー、重複コード、長関数(>50行)
- **Documentation**: 古いコメント、JSDoc欠如、README更新箇所
- **ADR**: ADRなしで導入された新しい抽象化

監査結果を提示し**ユーザーの応答を待つ。**

## Phase 2: 修正

ユーザーが指定（「all」「1,2,3」「none」）→ 各修正を実施し `task-cleanup.md` に記録。
修正完了後「Phase 3に進みますか？」と確認し**承認を待つ。**

## Phase 3: 全ゲートを再検証

`gates.md` の全ゲートを再検証（cleanup後も通るか確認）：
- gates.md読む→各ゲート実行→通過`[x]`→失敗はSTOP修正後再実行

全ゲート通過後、コミット・PR作成（自律実行）：
`git add -A && git commit -m "chore: cleanup" && git push origin <branch>`
`gh pr create --title "[title]" --body "[ゲート検証結果を含める]"`

## ルール

- 3フェーズを順番に実行・Phase 3スキップ禁止
- **コミット・PR作成は自律実行** / **PRをMergeしない**（人間の最終権限）

## 完了後

```
CLEANUP完了: Phase1(N項目)/Phase2(M修正)/Phase3(全ゲート[X/X])/PR:#<番号>
人間: PRをレビュー・Merge（最終権限は人間）
```