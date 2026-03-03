# agent-workflow / vibe-local

vibe-local（ローカルLLMエージェント）向けのコンパクトなワークフロースキル集。

## 概要

vibe-localのスキルシステムは `.md` ファイルをシステムプロンプトに自動注入しますが、
**各スキルは2000文字に切り詰められます**。このディレクトリのスキルはその制限に合わせて
要点を凝縮したvibe-local専用バージョンです。

## セットアップ

プロジェクトルートで以下を実行：

```bash
mkdir -p .vibe-local/skills
cp agent-workflow/vibe-local/skills/*.md .vibe-local/skills/
```

vibe-localを起動すると `/skills` コマンドでロード確認できます。

## スキル一覧

| ファイル | コマンド | 用途 |
|---------|---------|------|
| `wf-workflow.md` | `/wf-workflow` | ワークフロー説明・Q&A |
| `wf-issue-plan.md` | `/wf-issue-plan` | Issue作成・成功基準定義 |
| `wf-investigate.md` | `/wf-investigate` | コード調査・Issue詳細化 |
| `wf-design.md` | `/wf-design` | インターフェース設計（実装なし） |
| `wf-adr.md` | `/wf-adr` | アーキテクチャ決定記録 |
| `wf-01-define-gates.md` | `/wf-01-define-gates` | 検証ゲート定義（必須） |
| `wf-02-task-plan.md` | `/wf-02-task-plan` | タスク計画 |
| `wf-03-implement.md` | `/wf-03-implement` | タスク実装 |
| `wf-04-cleanup.md` | `/wf-04-cleanup` | PR前クリーンアップ |
| `wf-summarise.md` | `/wf-summarise` | セッション引き継ぎ |

## ワークフロー全体像

```
[オプション] wf-investigate → wf-design → wf-adr → wf-issue-plan
                                                          ↓
                                              wf-01-define-gates (必須)
                                                          ↓
                                              wf-02-task-plan
                                                          ↓
                                              wf-03-implement (繰り返し)
                                                          ↓
                                              wf-04-cleanup → PR → 人間がMerge
```

## 起動方法

### 初回セットアップ

```bash
# 1. サブモジュールを初期化（vibe-local/ が空の場合）
git submodule update --init

# 2. スキルをコピー
mkdir -p .vibe-local/skills
cp agent-workflow/vibe-local/skills/*.md .vibe-local/skills/

# 3. CLAUDE.md がプロジェクトルートにあることを確認（vibe-coderが自動読み込み）
ls CLAUDE.md

# 4. 起動スクリプトに実行権限を付与（初回のみ）
chmod +x vibe-start.sh
```

### 起動コマンド

```bash
# 新規セッション（Contract.mdを読んでフェーズ判断・作業開始）
./vibe-start.sh

# 前回セッションを再開
./vibe-start.sh --resume

# モデルを指定して起動
./vibe-start.sh --model qwen3:8b
```

> **vibe-local コマンドの解決順序:**
> 1. インストール済み `vibe-local` コマンド
> 2. サブモジュール `vibe-local/vibe-local.sh`（インストール不要）
> 3. `python3 vibe-local/vibe-coder.py`（直接実行）

### 動作フロー

```
./vibe-start.sh
  → vibe-local -p "セッション開始..."
    → CLAUDE.md（自動注入）: ルール・フェーズ判断ロジック
    → .vibe-local/skills/（自動注入）: wf-01〜wf-04 等
    → docs/Contract.md を読んでフェーズ判断
    → 対応スキルを実行（Define Gates / Task Plan / Implement / Cleanup）
    → 実装・コミット・PR作成
    → セッション保存・終了
```

## 注意事項

- シンボリックリンクはvibe-localのセキュリティ制限で無視されるため、実ファイルをコピーしてください
- スキルを更新した場合は再度コピーが必要です: `cp agent-workflow/vibe-local/skills/*.md .vibe-local/skills/`
- 元のフルバージョンは `agent-workflow/claude-code/skills/` または `agent-workflow/codex-cli/skills/` にあります
- `CLAUDE.md` はvibe-coderが `CLAUDE.md` / `.vibe-coder.json` のみ自動読み込みするため、`AGENTS.md` ではなく `CLAUDE.md` として配置しています