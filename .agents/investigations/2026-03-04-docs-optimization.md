## Investigation Findings

**Investigated:** 2026-03-04

### Context
User request: Optimize /docs directory documents as AI-driven development workflow. Scrutinize if sufficient consideration given to AI dev flow, surface improvement points. Trigger: understanding + enrich (assess current docs structure/content for AI workflow completeness, identify gaps/optimizations).

No external GitHub issue; treating user message as stub issue to enrich. Original source: https://github.com/daniel-butler-irl/sample-agentic-workflows/tree/main/docs (fetched via subagent; summary in .agents/research/original-agentic-workflow-guide.md).

### Current State
docs/ contains 2 main files (total ~65kB):
- **docs/agentic-workflow-guide.md** (/Users/nirarin/work/agent-workflow/docs/agentic-workflow-guide.md:1): ~1089 lines. Extended original guide with Japanese notes, project-specific adaptations (e.g., vibe-local commits/PRs, human merge only). Covers core philosophy (fresh sessions, 50% context rule), design principles (human load, LLM limits), phases (gates, tasks, cleanup), anti-patterns, optimizations (local reviews, metrics).
- **docs/methodology.md** (/Users/nirarin/work/agent-workflow/docs/methodology.md:1): ~1089 lines (highly similar/duplicate to guide.md). Adds subagent research (.agents/research/), optimization strategies (staged reviews, caching, incremental PRs), Japanese/English bilingual.

Supporting:
- **README.md** (/Users/nirarin/work/agent-workflow/README.md:1): Project overview, quickstart, agent setup, doc generation architecture (docs/ as Single Source of Truth; AI-regenerate agent files).
- Recent git commit: badd6dc docs: add workflow documentation and generalize project-specific references.

Key patterns:
- Single Source of Truth: docs/ manual-edited → AI-generate agent skills/commands.
- Bilingual (EN/JP notes).
- Phased workflow (/wf-01-* to /wf-04-*), gates/tasks, AGENTS.md rules.

### Gap Analysis
**Strengths (sufficient consideration):**
- Comprehensive AI dev flow coverage: context mgmt, gates, complexity assessment, subagents, anti-patterns, optimizations (reviews, metrics).
- Maintenance process: doc generation flow, validation steps, quality standards.
- Adaptations: vibe-local integration, multi-agent support.

**Gaps/Improvement Opportunities:**
- **Heavy duplication** (~80% overlap between guide.md and methodology.md): Core phases, principles repeated verbatim → reader confusion, maintenance burden.
- **Excessive length**: Both MDs >1000 lines → exceeds Claude MEMORY.md 200-line limit; hard to parse in LLM context; violates "lightweight docs" principle ironically.
- **Inconsistent bilingualism**: English base + JP notes in guide.md; methodology.md mixed → translation gaps, readability issues.
- **No cross-references**: Duplicate sections lack links (e.g., "see methodology.md").
- **Outdated/missing updates**: Original source fetched lacks some extensions (e.g., Phase 1.5 test-cases); sync status unclear.
- **Missing metrics/feedback loop**: Doc generation process lacks auto-validation (e.g., diff checks post-regen).
- **No visual aids beyond tables**: Mermaid in README good, but phases lack unified diagram in docs/.
- **Accessibility**: No ToC anchors; long scrolls.
- **AI-specific optimizations underexplored**: e.g., prompt templates for doc regen not in docs/; vibe-local 2000-char limits handled ad-hoc.

Root cause: Evolutionary growth (fork + extensions) without periodic consolidation.

### Affected Components
- **docs/agentic-workflow-guide.md**: Primary guide; needs trimming/dupe removal.
- **docs/methodology.md**: Detailed extensions; merge into guide or reference-only.
- **README.md**: Good overview; update doc structure refs.
- **Agent skills/commands dirs** (bob/, claude-code/, etc.): Indirectly affected via regen process.
- **.agents/research/**: Subagent pattern well-defined.

### Scope Assessment
- [x] **Large**: Requires design consideration (doc restructure, bilingual consistency).
- [ ] Medium: Multiple files, straightforward
- [ ] Small: Isolated change
- [ ] Complex: Systemic, needs decomposition (regen process touches all agents)

### Proposed Success Criteria
- [ ] Duplicates removed: <20% content overlap between files (grep/diff verify).
- [ ] Length optimized: No MD >500 lines; MEMORY.md-compatible summaries (git wc -l).
- [ ] Cross-references/link ToC: All sections navigable (markdown links/anchors).
- [ ] Bilingual consistency: JP sections parallel EN or separated; no mixed paras.
- [ ] Visual unified diagram: Mermaid workflow in guide.md covering all phases.
- [ ] Regen validation automated: Script/checks for post-gen consistency (new in MAINT.md?).
- [ ] Source sync: Diff vs original repo confirmed/updates pulled.

### Recommended Next Step
Large scope → Needs `/wf-design` first (doc hierarchy/interfaces), then `/wf-issue-plan` for split (e.g., core-guide.md, optimizations.md, maint-process.md).