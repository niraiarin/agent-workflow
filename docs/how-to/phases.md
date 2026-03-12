# Workflow Phases — How-To Guide

各フェーズの実行タイミング、前提条件、出力物、次のステップ。
詳細は [agentic-workflow-guide.md](../agentic-workflow-guide.md) を参照。

---

## Phase 1: Define Gates (MANDATORY)

| Item | Detail |
|------|--------|
| **Command** | `/wf-01-define-gates <issue-identifier>` |
| **When** | Always first — before any planning or implementation |
| **Prerequisites** | Issue exists (GitHub or `.agents/issues/`) |
| **Output** | `.agents/tasks/<issue>/gates.md` |
| **Next step** | Phase 1.5 (if Test-based Gates exist) or Phase 2 |

**What happens:**
1. Reads the issue and analyzes success criteria
2. Proposes verification strategy for each criterion (Test-based / Command-based / Manual review)
3. Assesses complexity (SIMPLE vs COMPLEX)
4. Optionally detects splitting opportunities
5. Creates `gates.md` after human approval

> See [guide: Phase 1](../agentic-workflow-guide.md#phase-1-define-verification-gates-mandatory) for gate types, complexity assessment criteria, and examples.

---

## Phase 1.5: Test Case Definition (CONDITIONAL)

| Item | Detail |
|------|--------|
| **Command** | `/wf-15-define-test-cases <issue-identifier>` |
| **When** | Only when Test-based Gates exist in gates.md |
| **Prerequisites** | `gates.md` exists with at least one Test-based Gate |
| **Output** | `.agents/tasks/<issue>/test-cases.md` |
| **Next step** | Phase 2 |

**What happens:**
1. Expands Test-based Gate "Specifics" into concrete test cases (TC-X.Y format)
2. Determines Local vs CI execution strategy
3. Updates gates.md with test case references

**Skip logic:** If no Test-based Gates exist, skip directly to Phase 2.

> See [guide: Phase 1.5](../agentic-workflow-guide.md#phase-15-test-case-definition-conditional) for test case structure and execution strategy.

---

## Phase 2: Task Planning

| Item | Detail |
|------|--------|
| **Command** | `/wf-02-task-plan <issue-identifier>` |
| **When** | After gates (and test cases, if applicable) are defined |
| **Prerequisites** | `gates.md` exists |
| **Output** | `.agents/tasks/<issue>/task-N.md` |
| **Next step** | Phase 3 |

**What happens:**
- **SIMPLE:** Plans all tasks at once
- **COMPLEX:** Plans next task only (iterative, informed by previous Implementation Notes)

Each task: completes 1+ gates, fits in a single commit (50-200 lines, 1-5 files).

> See [guide: Phase 2](../agentic-workflow-guide.md#phase-2-task-planning) for task template and planning examples.

---

## Phase 3: Implement

| Item | Detail |
|------|--------|
| **Command** | `/wf-03-implement <issue-identifier> <task-identifier>` |
| **When** | After task file exists |
| **Prerequisites** | `task-N.md` exists |
| **Output** | Code changes, commit, PR |
| **Next step** | Phase 4 |

**What happens:**
1. Agent follows implementation steps in task file
2. Checks off steps as completed
3. Verifies completion gates
4. Records discoveries in Implementation Notes
5. Commits and creates PR

> See [guide: Phase 3](../agentic-workflow-guide.md#phase-3-task-execution) for execution details and examples.

---

## Phase 4: Next Task or Cleanup

| Condition | Action |
|-----------|--------|
| More gates remain | `/wf-02-task-plan <issue>` → plan next task |
| All gates complete | `/wf-04-cleanup <issue>` → proceed to cleanup |

---

## Phase 5: Cleanup

| Item | Detail |
|------|--------|
| **Command** | `/wf-04-cleanup <issue-identifier>` |
| **When** | All gates are complete |
| **Prerequisites** | All tasks committed |
| **Output** | Cleanup commit, final PR |
| **Next step** | Human review and merge |

**Three-phase process:**
1. **Audit** — Agent reviews all branch changes, creates numbered issue list
2. **Fix** — Human selects items to fix ("all", "1,3,4", "all except 2")
3. **Validate** — Agent re-verifies ALL gates, runs full test suite, creates PR

> See [guide: Phase 5](../agentic-workflow-guide.md#phase-5-cleanup-and-verification) for audit checklist and validation details.

---

## Optional Phases

| Phase | Command | When to use |
|-------|---------|-------------|
| Issue Plan | `/wf-issue-plan` | Starting a new feature from scratch |
| Investigate | `/wf-investigate <issue>` | Don't understand existing code well enough |
| Design | `/wf-design <issue>` | Interface undefined, multiple approaches |
| ADR | `/wf-adr <title>` | Architectural decisions need recording |
| Summarise | `/wf-summarise [<issue> <task>]` | Context degraded, switching sessions |
| Workflow | `/wf-workflow` | Questions about the methodology |

> See [guide: Optional Phases](../agentic-workflow-guide.md#optional-on-demand-phases) for detailed descriptions.
