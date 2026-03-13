# Skill: wf-02-task-plan

ゲートに基づくタスク計画担当。実装コードは書かない。

## 前提条件（必須）

1. `.agents/tasks/<issue>/gates.md` 存在確認 → なければ STOP「先に `/wf-01-define-gates <issue>` を実行」
2. Test-based Gateがある場合: `.agents/tasks/<issue>/test-cases.md` 存在確認
   → なければ WARNING「test-cases.md が未定義です。`/wf-15-define-test-cases <issue>` で事前定義を推奨」
   → 人間が続行を選択した場合: 理由をタスクファイルの Implementation Notes に記録して続行
   → 人間が STOP を選択した場合: STOP「先に `/wf-15-define-test-cases <issue>` を実行」
3. `git branch --show-current` → main/masterなら STOP「featureブランチを作成」
4. 未完了タスクがある → STOP「先に `/wf-03-implement <issue> task-N` を完了」

## 判断ロジック

- **SIMPLE**: タスクなし→全タスク一括計画 / 全完了→「`/wf-04-cleanup` へ」
- **COMPLEX**: タスクなし→task-1のみ / 前タスク完了→Implementation Notes読んで次タスク計画 / 全完了→「`/wf-04-cleanup` へ」

## タスクサイズ原則: 1タスク=1コミット（50〜200行、1〜5ファイル）

## タスクファイル形式

`.agents/tasks/<issue>/task-N.md` に保存：
```
# Task N: [説明]
**Issue:** <ref> / **Branch:** <branch> / **完了するゲート:** Gate N
## 目的: [1〜2文]
## 実装ステップ
- [ ] ステップ1
## 完了ゲート
- [ ] [gates.mdから検証をコピー]
- [ ] リグレッションなし: [テストコマンド]
## コミットメッセージ: [type]([scope]): [説明] / Completes: Gate N of #[issue]
## Implementation Notes（実装中に記入）
方向変更: / 発見事項: / 次のタスクへ:
```

## ルール

- gates.mdを先に読む / 複雑度評価を尊重 / 検証を正確にコピー
- test-cases.mdが存在する場合、テスト実装ステップを参照
- 前タスクのImplementation Notesを活用 / 実装コードを書かない

## 完了後

```
SIMPLE: 全タスク計画完了 / task-1.md(GateX,Y), task-2.md(GateZ) / 次:/wf-03-implement <issue> task-1
COMPLEX: Task N計画完了 / task-N完了後 /wf-02-task-plan で次タスク / 次:/wf-03-implement <issue> task-N
```