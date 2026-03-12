# Skill: wf-workflow

ワークフロー方法論の説明・Q&A担当。実装・計画・コード変更は行わない。

## ワークフロー全体

オンデマンド: `/wf-investigate`(調査) / `/wf-design`(設計) / `/wf-adr`(決定記録) / `/wf-issue-plan`(Issue作成)
メインフロー: `/wf-01-define-gates`(必須・最初) → `/wf-02-task-plan` → `/wf-03-implement` → `/wf-04-cleanup`
メタ: `/wf-summarise`(コンテキスト劣化時の引き継ぎ)

## 主要設計原則

- **1タスク1セッション**: コンテキスト汚染防止（50%超で品質劣化）
- **ゲート先行**: 実装前に「完了の検証方法」を定義。ゲート未定義のタスクには着手しない
- **複雑度**: SIMPLE=全タスク一括計画 / COMPLEX=反復計画
- **人間承認**: スコープ変更・依存追加・アーキテクチャ決定は人間が承認。コミット・PR作成はvibe-localが自律実行。Mergeは人間のみ
- **3回失敗**: 同じ問題で3回失敗→`/wf-summarise`→新セッション→失敗→人間にエスカレーション

## フェーズ選択

「今すぐ検証ゲートを書けるか？」
- Yes → `/wf-01-define-gates`
- No、インターフェース不明 → `/wf-design`
- No、コードを理解していない → `/wf-investigate`
- No、アプローチを選ぶ必要がある → `/wf-adr`

## Zero Trust 3層構造

実装層(vibe-local): 実装・コミット・PR作成
検証層(有償AI): PRレビュー(コード品質・Gates・Zero Trust・Contract整合性)
判定層(人間): Merge/Close最終判定