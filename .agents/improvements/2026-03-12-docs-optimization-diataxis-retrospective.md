# Retrospective: docs-optimization-diataxis

**Date:** 2026-03-12
**Analyst:** wf-self-improve
**Issue:** docs-optimization-diataxis
**Branch:** feature/docs-optimization-diataxis

## Metrics Summary

| メトリクス | 値 | 基準 | 判定 |
|-----------|------|------|------|
| タスク数 (計画) | 3 | - | - |
| タスク数 (実行) | 不明（タスク完了記録なし） | - | ⚠️ |
| ゲート数 | 7 | - | - |
| ゲート合格率 | 2/7 (28.6%) | 100% | ⚠️ |
| 総変更行数 | +3,720 / -10,359 | - | - |
| 変更ファイル数 | 86 | - | - |
| コミット数 | 2 | 3 (計画) | ⚠️ |
| Cleanup指摘数 | N/A（task-cleanup.md 欠損） | - | ⚠️ |
| Implementation Notes | 全て空白 | 記入あり | ⚠️ |

## Anti-Patterns Detected

### 1. ゲートスキップ（Gate Skip）
- **重大度:** High
- **証拠:** 全7ゲートのチェックボックスが未チェック (`- [ ]`)。ゲート検証記録が一切ない。
- **実態検証:**
  - **G-001 (重複<20%):** FAILING — methodology.md (1088行) と agentic-workflow-guide.md (868行) が20%超の重複
  - **G-002 (500行以下):** FAILING — 3ファイルが違反: architecture.md (1410行), methodology.md (1088行), agentic-workflow-guide.md (868行)
  - **G-003 (Diátaxis構造):** PARTIAL — 4ディレクトリ存在するが tutorials/ が空、ルートに未移行ファイル残存
  - **G-004 (クロスリファレンス):** PASSING — リンク先は全て存在
  - **G-005 (バイリンガル):** NOT STARTED — docs/ja/ が空
  - **G-006 (regen.sh):** FAILING — docs/regen.sh が存在しない
  - **G-007 (既存ワークフロー):** 未検証
- **影響:** issueの7つのSuccess Criteriaのうち、達成が確認できたのは1つ (G-004) のみ。V4 (ゲート通過率) = 14.3%

### 2. 成果物欠損（Missing Artifacts）
- **重大度:** High
- **証拠:**
  - `test-cases.md` が存在しない
  - `task-cleanup.md` が存在しない（wf-04-cleanup が実行されていない）
  - 全タスクファイルの Implementation Notes が空白
- **影響:** 振り返りに必要な情報が著しく不足。V6 (知識構造の質) の劣化。

### 3. タスク計画と実行の乖離
- **重大度:** High
- **証拠:**
  - 計画: 3タスク × 各1コミット = 3コミット
  - 実行: 2コミット（計画とは異なるスコープ）
  - Task-2 (バイリンガル + クロスリファレンス) と Task-3 (regen.sh) は未実行
  - 代わりにスコープ外の wf-self-improve スキル開発が Commit 2 に含まれる
- **影響:** 計画されたワークフローが途中で放棄され、別の作業に移行した。

### 4. タスク肥大化
- **重大度:** Medium
- **証拠:**
  - Commit 1: 73ファイル変更、+1,512 / -17,491行
  - Commit 2: 34ファイル変更、+9,340行
- **影響:** 基準（50-200行/タスク、1-5ファイル/タスク）を大幅に超過。レビュー困難。

### 5. 虚偽の行数表記
- **重大度:** Medium
- **証拠:**
  - docs/explanation/principles.md: 末尾に「(298 lines)」と記載 → 実際は20行
  - docs/how-to/phases.md: 末尾に「(412 lines)」と記載 → 実際は29行
  - docs/reference/commands.md: 末尾に「(187 lines)」と記載 → 実際は19行
- **影響:** ドキュメントの信頼性を損なう。未完成ファイルがプレースホルダー行数を残したまま出荷。

## Strengths

- **プラットフォーム統合の方向性は正しい**: 5つの重複ディレクトリ (-17,491行) をsubmodule + .claude/skills/ に統合した設計判断は適切
- **Diátaxisディレクトリ構造の実現**: tutorials/, how-to/, reference/, explanation/ の4象限が全て作成済み
- **explanation/ の充実**: manifesto.md (409行), constraints-taxonomy.md (326行), implementation-boundaries.md (403行) は高品質な説明文書
- **docs内のクロスリファレンスが機能**: 全マークダウンリンクのターゲットが存在する
- **新スキル (wf-self-improve) の追加**: 5フェーズ・7探索軸の構造化された自己改善スキルを実装

## Exploration Findings (Phase 3)

### 3-A: 接続探索（Connectivity）

- **発見 1:** wf-00-intake が wf-workflow のスキル一覧テーブルに未掲載
  - **影響:** ワークフローの入口が公式リストから欠落。新規ユーザーが intake フェーズの存在を知らない
  - **アクション:** 即時修正

- **発見 2:** wf-01-define-gates が上流 (wf-00-intake) を明示的に参照していない
  - **影響:** スキル間の依存関係が暗黙的。wf-03-implement も同様に wf-02 を参照せず
  - **アクション:** 改善提案

- **発見 3:** wf-04-cleanup が wf-self-improve を次ステップとして案内していない
  - **影響:** 実際にはSKILL.md内に参照あり (line 301) → 前回のiter-2で修正済みと確認
  - **アクション:** 記録のみ（修正済み）— ただし探索エージェントが検出できなかったことは注記

### 3-B: 環境変化検出（Drift Detection）

- **発見:** docs/index.md が「All files <500L, dupe-free」と主張しているが、実態と不一致
  - **影響:** ドキュメントの主張と実態の乖離。信頼性の問題
  - **アクション:** 即時修正

### 3-C: インフラ整合性（Infrastructure Integrity）

- **発見 1:** .grok/ に3スキルが欠損（wf-00-intake, wf-15-define-test-cases, wf-self-improve）
  - **影響:** Grokユーザーがこれらのスキルにアクセスできない。プラットフォームパリティの問題
  - **アクション:** 改善提案

- **発見 2:** docs/regen.sh が存在しない（G-006の前提）
  - **影響:** SSOTパイプラインの自動検証が不可能
  - **アクション:** 改善提案（Task-3で計画されていたが未実行）

- **発見 3:** docs/tutorials/ が空ディレクトリ
  - **影響:** Diátaxisの4象限のうち1つが完全に空。index.md からリンクされるが中身なし
  - **アクション:** 改善提案

### 3-D: 境界探査（Boundary Probing）

- **発見:** 今回のissueでは7ゲート中5ゲートが未達成。これは L6（設計規約）の問題ではなく、ワークフロー自体が途中放棄された結果
  - **影響:** V4 (ゲート通過率) = 14.3%。ただしこれはスキルの問題ではなく、人間の判断でスコープが変更された結果
  - **アクション:** 記録のみ — 境界条件の変更提案ではなく、スコープ変更プロセスの改善提案

### 3-E: 自己参照分析（Self-Referential Analysis）

- **発見:** wf-self-improve 自体はこのissue分析を正常に実行できている。ただし:
  - 探索エージェントが wf-04-cleanup の wf-self-improve 参照を検出できなかった（line 301に存在）
  - 探索の精度にばらつきがある
- **影響:** Phase 3 の探索結果に偽陰性（実際は修正済みだが未検出）が混入しうる
- **アクション:** 記録のみ — 探索結果は常にアナリスト（このスキル自身）が検証すべき

### 3-F: 不在検出（Absence Detection）

- **発見 1:** docs/methodology.md (1088行) と docs/agentic-workflow-guide.md (868行) がDiátaxisカテゴリに未分類
  - **影響:** 旧コンテンツがルートに残存。新しいDiátaxis構造との二重管理
  - **アクション:** 改善提案

- **発見 2:** benchmarkデータの蓄積基盤がない
  - **影響:** wf-self-improve のevalデータ (iteration-1, iteration-2) は wf-self-improve-workspace/ にあるが、プロジェクト全体のメトリクス蓄積は未整備
  - **アクション:** 記録のみ（Horizon 2 の課題）

### 3-G: 投資サイクル追跡（Investment Cycle Tracking）

- **発見:** wf-self-improve スキルの開発自体が投資サイクルの実例
  - V1 (スキル品質): eval pass rate 68.3% → 76.7% → 100%
  - V5 (提案精度): 偽陽性率が反復で改善
  - 人間への利益: 構造化された振り返りがレビュー負荷を軽減
  - 境界拡張: まだ明示的なL4拡張には至っていないが、データは蓄積中
- **影響:** 投資サイクルの最初のイテレーションが完了。次のサイクルで信頼→境界拡張の接続を実証する必要がある
- **アクション:** 記録のみ

## Improvement Proposals

### Proposal 1: 未完了ゲートの完了（残タスク実行）
- **カテゴリ:** ワークフロー調整
- **優先度:** Quick Win (High Impact / Low Effort for G-002) — Major Project (for G-005, G-006)
- **根拠:** 7ゲート中5ゲートが未達成。特にG-002 (500行制限) は3ファイルが違反
- **提案内容:**
  - G-002: methodology.md と agentic-workflow-guide.md を統合・分割し500行以下に。architecture.md をコア+付録に分割
  - G-003: tutorials/ にコンテンツ追加、またはディレクトリ削除の判断
  - G-005: docs/ja/ のバイリンガル実装
  - G-006: regen.sh の作成
- **期待効果:** V4 (ゲート通過率) が14.3% → 100%に改善

#### Issue Draft (wf-00-intake 互換)

> **Objective:** docs-optimization-diataxis の未完了ゲート (G-001, G-002, G-003, G-005, G-006) を達成する
>
> **Success Criteria:**
> - [ ] docs/ 配下の全 .md ファイルが500行以下
> - [ ] methodology.md と agentic-workflow-guide.md の重複が20%未満
> - [ ] docs/ja/ にEN構造のミラーが存在
> - [ ] docs/regen.sh が存在し、exit 0で終了

### Proposal 2: wf-00-intake を wf-workflow テーブルに追加
- **カテゴリ:** ドキュメントギャップ
- **優先度:** Quick Win (High Impact / Low Effort)
- **根拠:** Phase 3-A で検出。ワークフローの入口スキルが公式リストに未掲載
- **提案内容:** wf-workflow/SKILL.md のスキルテーブルに wf-00-intake を追加
- **期待効果:** V6 (知識構造の質) 改善。新規ユーザーのオンボーディング改善

#### Issue Draft (wf-00-intake 互換)

> **Objective:** wf-workflow のスキル一覧テーブルに wf-00-intake を追加
>
> **Success Criteria:**
> - [ ] wf-workflow/SKILL.md のMain Workflowセクションにwf-00-intakeが掲載

### Proposal 3: プレースホルダー行数表記の修正
- **カテゴリ:** ドキュメントギャップ
- **優先度:** Quick Win (High Impact / Low Effort)
- **根拠:** Phase 2 で検出。3ファイルに虚偽の行数表記
- **提案内容:** principles.md, phases.md, commands.md の末尾にある「(N lines)」表記を削除または実際の行数に修正
- **期待効果:** V3 (出力品質) 改善

#### Issue Draft (wf-00-intake 互換)

> **Objective:** docs/ 内のプレースホルダー行数表記を修正
>
> **Success Criteria:**
> - [ ] docs/ 内の全ファイルの行数表記が実態と一致、またはプレースホルダー表記が削除

### Proposal 4: .grok/ プラットフォームパリティ
- **カテゴリ:** インフラ修正
- **優先度:** Fill-in (Medium Impact / Medium Effort)
- **根拠:** Phase 3-C で検出。.grok/ に3スキルが欠損
- **提案内容:** wf-00-intake, wf-15-define-test-cases, wf-self-improve の .grok/commands/ 版を作成
- **期待効果:** プラットフォーム間の機能パリティ

#### Issue Draft (wf-00-intake 互換)

> **Objective:** .grok/commands/ に欠損スキル3つを追加
>
> **Success Criteria:**
> - [ ] wf-00-intake.toml が存在
> - [ ] wf-15-define-test-cases.toml が存在
> - [ ] wf-self-improve.toml が存在

### Proposal 5: スキル間の上流・下流参照の明示化
- **カテゴリ:** スキル改善
- **優先度:** Fill-in (Medium Impact / Medium Effort)
- **根拠:** Phase 3-A で検出。wf-01, wf-03 が上流スキルを明示的に参照していない
- **提案内容:** 各スキルの冒頭に `Upstream:` / `Downstream:` セクションを追加
- **期待効果:** V6 (知識構造の質) 改善。スキル間のナビゲーション明確化

#### Issue Draft (wf-00-intake 互換)

> **Objective:** 全ワークフロースキルに上流/下流の明示的参照を追加
>
> **Success Criteria:**
> - [ ] wf-01 が wf-00-intake を上流として参照
> - [ ] wf-03 が wf-02 を上流として参照
> - [ ] 全スキルが次ステップへの案内を含む

### Proposal 6: docs/index.md の主張修正
- **カテゴリ:** ドキュメントギャップ
- **優先度:** Quick Win (High Impact / Low Effort)
- **根拠:** Phase 3-B で検出。「All files <500L, dupe-free」の主張が虚偽
- **提案内容:** index.md の内容を実態に合わせて更新
- **期待効果:** V3 (出力品質) 改善

#### Issue Draft (wf-00-intake 互換)

> **Objective:** docs/index.md の記載内容を実態と整合させる
>
> **Success Criteria:**
> - [ ] index.md の記述が現在のファイル構造と一致

### Proposal 7: スコープ変更プロセスの確立
- **カテゴリ:** ワークフロー調整
- **優先度:** Major Project (High Impact / High Effort)
- **根拠:** 今回のissueでは計画された3タスクのうち Task-2, Task-3 が未実行のままスコープ外の作業（wf-self-improve開発）に移行した。この変更が成果物に記録されていない
- **提案内容:**
  - wf-03-implement または wf-02-task-plan に「スコープ変更時の記録プロセス」を追加
  - スコープ変更が発生した場合、gates.md に「DEFERRED: [理由]」を記録する仕組み
- **期待効果:** V4 (ゲート通過率) の正確な測定。計画と実行の乖離の可視化

#### Issue Draft (wf-00-intake 互換)

> **Objective:** issueスコープ変更時の記録プロセスをワークフローに組み込む
>
> **Success Criteria:**
> - [ ] wf-02-task-plan にスコープ変更の記録手順が記載
> - [ ] gates.md に DEFERRED ステータスが使用可能
> - [ ] スコープ変更の理由が追跡可能

## Self-Evaluation (Phase 6)

### マニフェスト整合性

**合致した点:**
- 制約は進化圧（Section 3）: 成果物欠損・ゲートスキップの検出が構造改善（スコープ変更プロトコル）を駆動した
- V1（スキル品質）の直接改善: 4スキルに上流/下流参照追加、wf-workflowにwf-00-intake追加
- V6（知識構造の質）の改善: ドキュメントの虚偽主張修正、スキル間依存関係の明示化

**不足した点:**
- **投資サイクル（Loop 5）への接続が欠如**: 変数改善→人間への利益→信頼蓄積→境界拡張の追跡を行わなかった。提案は全てV1/V6改善で止まり、それが人間にどう利益をもたらすかを明示しなかった
- **メトリクスの欠如**: 改善前後の定量データがない。「ナビゲーション改善」は主張であり測定ではない
- **L6変更の根拠が弱い**: スコープ変更プロトコルの追加は1 issueの観察のみで規約化した。本来は複数issueの横断データが必要
- **マニフェスト自体の更新を行わなかった**: Section 7 違反。Loop 6 の追加とHorizon進捗の記録が必要だった（自己評価後に実施）
- **Proposal 1 の混同**: 「未完了ゲートの完了」はissueの残作業であり、ワークフロー改善ではなかった

### 今回の実行で学んだこと

1. **issueの成果物の問題 ≠ ワークフローの問題**の区別が最も重要。「ゲートが未達成」はissue固有の事実。「ゲート未達成を防ぐ構造がない」がワークフロー改善の対象
2. **Phase 3 探索エージェントの結果には偽陰性が混入する**。wf-04-cleanup のwf-self-improve参照（line 301）を探索エージェントが検出できなかった。探索結果はアナリストが検証すべき
3. **マニフェスト更新は Phase 5 の一部であるべき**。レポート出力後ではなく、レポートの分析がマニフェストの更新を駆動すべき
4. **投資サイクルへの接続なしに提案しても、改善の「なぜ」が不完全**。V1を改善した→だから何？まで追跡する必要がある

### スキル改善提案（自己適用）

1. **Phase 4 の提案テンプレートに「投資サイクルへの接続」欄を追加**: 各提案が「人間のどの利益に繋がるか」「どの境界条件の拡張を正当化しうるか」を記述させる
2. **Phase 2 に「issueの問題 vs ワークフローの問題」の分離ステップを追加**: アンチパターン検出後、各検出項目を「issue固有」と「ワークフロー構造的」に分類する
3. **Phase 5 にマニフェスト・constraints-taxonomy の同期チェックを追加**: レポート出力時に、分析結果がマニフェストの更新を要求するか判定する
