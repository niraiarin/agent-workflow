# Agentic Development Workflow Guide

> **出典**: https://github.com/daniel-butler-irl/sample-agentic-workflows/tree/main/docs

## Core Philosophy

> このセクションは運用レベルの指針である。使命レベルのビジョンは [manifesto.md](explanation/manifesto.md) を参照。

Working with AI coding agents is like managing a team of highly capable but amnesiac junior developers. They can write excellent code, but they:

- Forget everything between sessions
- Get dumber as conversations get longer (context pollution)
- Will claim work is "done" when it isn't
- Cut corners unless explicitly prevented
- Leave messes behind (debug logs, dead code, temporary comments)

This workflow is designed to maximize AI productivity while mitigating these failure modes.

### The Cardinal Rule: Fresh Sessions Are Free, Polluted Context Is Expensive

**Start a new session constantly.** Not per phase. Not per issue. Per task.

Sessions are like sticky notes, not notebooks. Use one for a focused thought, throw it away, grab a new one.

| Cost of new session | ~30 seconds to set context |
|---------------------|---------------------------|
| Cost of polluted context | Forgotten instructions, confused responses, wasted iterations, wrong output |

The math always favors fresh sessions. When in doubt, start over.

---

## Design Principles

This workflow is deliberately designed around two constraints that other methodologies ignore:

### 1. Human Cognitive Load

**Problem:** If humans cannot realistically review something, they will rubber-stamp it.

Spec-heavy approaches (walls of markdown, detailed upfront plans, comprehensive documentation) create review fatigue. Engineers skim, approve, and move on -- defeating the purpose of human oversight.

**How this workflow addresses it:**

- **One issue at a time** -- Each issue definition fits in working memory
- **One task = one commit** -- Diffs are reviewable in minutes, not hours
- **Gate-based verification** -- Clear pass/fail criteria, not subjective review
- **Three-phase cleanup** -- Audit, fix, then validate success criteria
- **Lightweight design docs** -- 50-100 lines, not 2,000

The goal: units of work sized for actual human attention, not theoretical thoroughness.

### 2. LLM Context Limits

**Problem:** LLM performance degrades as context grows -- and not gracefully.

Research shows a U-shaped attention curve: models attend well to the beginning and end of context but lose information in the middle. At around 50% of the context window, measurable degradation begins. By 65% of advertised maximum, reliability drops significantly. Instructions given early in a session fade. The model contradicts its earlier work. It claims completion prematurely.

**The 50% rule of thumb:** When you are past 50% of the context window, you are in the degradation zone. This is not a hard cutoff -- finish what you are doing. But wrap up the current task and start a fresh session rather than continuing.

**How this workflow addresses it:**

- **Fresh session per task** -- Context is bounded by design, not discipline
- **Small task files** -- Minimal context injection per session
- **Implementation Notes** -- Targeted memory, not full conversation history
- **Iterative planning (when complex)** -- Avoids filling context with stale plans
- **On-demand design** -- Design when needed, not comprehensive upfront specs
- **Summarise for handoff** -- Checkpoint progress before context degrades

The workflow treats context management as architecture, not advice. You don't need to monitor token counts -- the structure enforces hygiene automatically.

---

## Subagent Research Directory

Research-heavy phases (investigation, design, ADR) use subagents to gather external context without polluting the coordinator's context window.

### Directory Structure

```
.agents/
  research/
    github-issue-123.md       # Fetched GitHub issue
    github-pr-456.md          # Fetched pull request
    codebase-auth-patterns.md # Codebase exploration results
    industry-patterns-api-versioning.md  # Web research
    adr-option-jwt.md         # ADR option research
    test-patterns-validation.md # Test pattern exploration
```

### Research File Format

```markdown
# Research: [Type] - [Identifier]

**Source:** [URL or "Codebase exploration"]
**Fetched:** [ISO timestamp]

## Summary
[1-2 sentences - coordinator reads this to decide if deep dive needed]

## Key Points
- [Point 1]
- [Point 2]
- [Point 3]

## Sub-Items Found
- [URL or reference needing additional investigation]
- [Related issue or PR discovered]

## Raw Notes
[Detailed extraction, code snippets, full context]
```

### Two-Tier Access Pattern

Subagents provide **two outputs**:

1. **Full research** → Written to `.agents/research/<type>-<id>.md`
   - Complete extraction, all details
   - Persists across sessions
   - Reusable by future investigations

2. **Summary return** → 1-2 sentences back to coordinator
   - Keeps coordinator context lightweight
   - Enough to decide if deep read needed

**Coordinator workflow:**
1. Spawn subagent with file output path
2. Receive summary in tool response
3. If summary sufficient → continue synthesizing
4. If more detail needed → Read specific `.agents/research/` file
5. Synthesize from summaries + selective deep reads

### When to Spawn vs Inline

| Condition | Action |
|-----------|--------|
| External URL fetch | Spawn subagent |
| Codebase exploration (>3 searches) | Spawn Explore subagent |
| Single file read | Inline |
| Web search for options | Spawn subagent |
| Synthesizing findings | Always coordinator |
| User interaction (MANDATORY STOP) | Always coordinator |

---

## Issues vs Tasks vs Gates

Understanding these three levels is critical:

| | Issues | Gates | Tasks |
|---|--------|-------|-------|
| **What** | What we're trying to achieve | How we verify completion | How we achieve it, one step at a time |
| **Where** | GitHub or `.agents/issues/` | `.agents/tasks/<issue>/gates.md` | `.agents/tasks/<issue>/task-N.md` |
| **Lifecycle** | Living document -- evolves as scope changes | Defined once, may be refined | Completed and committed |
| **Contains** | Objective, success criteria, scope boundaries | Verification strategy, complexity assessment | Implementation steps, completion gate |

**Issues can evolve.** When discoveries reveal scope changes, update the issue. This is agile -- the plan adapts to reality.

**Gates define "done".** Verification strategy for each success criterion, assessed once upfront.

**Tasks capture what happened.** Implementation notes become memory for subsequent task planning.

---

## Phase 0: AI Context File Setup

### What You Do

Create an `AGENTS.md` file (or equivalent like `CLAUDE.md`, `.cursorrules`) containing your non-negotiable project requirements. This file is injected into every AI session automatically.

### Without Explicit Constraints

AI assistants optimize for appearing helpful, which sometimes means taking shortcuts. Without explicit constraints, they will:

- Skip tests to "finish faster"
- Use deprecated patterns from training data
- Make inconsistent architectural decisions across sessions
- Leave behind debug code and temporary comments
- Break existing interfaces while "improving" code
- Add unnecessary dependencies

The AGENTS.md file acts as persistent memory across the amnesia boundary.

### Guidelines

- Keep it under ~200 lines -- longer files get ignored as context fills up
- Focus on non-negotiables only
- Be specific and actionable, not aspirational
- Update it when you discover new failure modes

### Base Template

Start with this template (~110 lines), then add project-specific rules:

```markdown
# AGENTS.md

## Testing Requirements

- Every new function requires tests
- Tests must pass before a task is considered complete
- Never delete, skip, or disable existing tests to make code "work"
- Never mock the thing you're testing
- If a test fails, fix the code or the test -- never remove it
- Never modify test assertions to match broken implementation
- Hardcoding expected values to force tests green is unacceptable
- Test behavior, not implementation details
- Include edge cases: empty inputs, nulls, boundary values
- Run the full test suite before claiming done
- If you added a feature, show the test that proves it works
- If you fixed a bug, show the test that would have caught it

## Test Hygiene

- Before writing a new test, check if an existing test already covers the scenario
- Prefer extending existing test files over creating new ones
- Consolidate tests that verify similar scenarios
- One test file per module/component (unless complexity requires splitting)
- Parameterized tests over copy-paste variations
- If a test file has multiple tests doing nearly the same thing, consolidate them
- Test file names should match the module they test (e.g., auth.test.ts for auth.ts)
- Redundant tests add maintenance burden without improving coverage -- remove them

## Code Quality

- Prefer simple, readable code over cleverness
- Make the minimal change necessary -- no unrequested features or refactors
- Don't refactor unrelated code without asking
- Before writing new code, check if existing code, libraries, or platform built-ins already do it
- If writing a utility that feels generic, check if it exists first
- Use the project's established patterns
- Composition over inheritance
- Keep functions and files small -- if getting long, split it

## Code Is Truth

- The codebase is the source of truth -- read code to understand behavior, don't assume
- Before modifying code, read and understand what it currently does

## Interface Stability

- Existing public interfaces are frozen unless explicitly approved
- Extend via new optional properties, not breaking changes
- Don't merge independent modules into coupled code
- Don't change function signatures that have existing callers

## Dependencies

- Never add new dependencies without asking
- When approved, use well-maintained libraries with active support
- Never use deprecated libraries or patterns
- If you identify a deprecated dependency, flag it immediately
- Prefer libraries with strong TypeScript/type support

## Documentation Hygiene

- Remove temporary comments before completing a task:
  - `// TODO`, `// FIXME`, `// HACK` (unless tracked in issue system)
  - `// testing`, `// new`, `// updated`, `// old code`
  - Commented-out code blocks
- Comments explain "why", not "what"
- When modifying a function, verify existing comments are still accurate
- When changing behavior, update relevant docs in the same task

## Completion Standards

A task is not complete until:
- All implementation steps are checked off
- All completion gates pass and are checked off
- Tests pass
- Code is committed and PR is created (by your AI agent); paid AI reviews automatically, human makes final Merge decision
- No temporary code, debug logs, or commented-out code remains

## The Rules

1. **Agent proposes, human approves** -- All scope changes, dependency additions, and architectural decisions require explicit human approval. Commits and PR creation are performed autonomously by your AI agent; human approval is required for Merge only.
2. **Never bypass the human** -- When uncertain, ask rather than guessing
3. **Protect the tests** -- Never modify test assertions to make tests pass; fix the implementation
4. **One task, one commit** -- Each task must be completable in a single reviewable commit
5. **Fresh session per task** -- When context feels polluted or after three failures, start a fresh session
```

---

## The Workflow Phases

### Phase 1: Define Verification Gates (MANDATORY)

Before planning tasks, explicitly define how you'll verify each success criterion.

**Command:** `/wf-01-define-gates <issue-identifier>`

**What it does:**

1. Reads the issue (GitHub or markdown)
2. Analyzes success criteria
3. Proposes verification strategy for each criterion
4. Assesses complexity (SIMPLE vs COMPLEX)
5. Detects if issue should be split (optional recommendation)
6. Creates `gates.md` after human approval

**Output:** `.agents/tasks/<issue>/gates.md`

**Why this is mandatory:**

- Forces clarity about what "done" means before implementation
- Catches scope bloat early
- Determines if tasks can be planned upfront or need iterative approach
- Prevents test maintenance bloat by choosing appropriate verification

**Gate Verification Types:**

1. **Test-based** -- New or extended test cases
   - Example: "Unit tests in user.test.ts verify email validation"

2. **Command-based** -- Run a command, verify output
   - Example: "`terraform plan` shows expected resources, no surprises"

3. **Manual review** -- When automation isn't appropriate
   - Example: "Security architecture review checklist: [specific items]"

**Complexity Assessment:**

**SIMPLE** -- Plan all tasks upfront:

- Single component or closely related components
- Established patterns exist in codebase
- Clear implementation path
- Low uncertainty about approach

**COMPLEX** -- Plan tasks iteratively:

- Multiple independent components
- New patterns needed
- High uncertainty
- Needs investigation or discovery

**Splitting Detection:**

The command identifies when an issue contains multiple independent features and suggests splitting:

- Independent gate groups that don't depend on each other
- Natural domain boundaries (database vs API vs UI)
- Opportunities for parallel development

**Example gates.md:**

```markdown
# Verification Gates for Issue #47: User Email Validation

## Gate 1: Email validation enforced on save
**From criteria:** "Email validated on save"
**Verification type:** Test-based
**Strategy:** Extend tests/models/user.test.ts with validation test cases
**Specifics:**
- Test valid email formats accepted
- Test invalid email formats rejected
- Test null/empty values rejected
- Verify validation error thrown with correct message

## Gate 2: Clear error messages returned
**From criteria:** "Clear error messages"
**Verification type:** Test-based
**Strategy:** Error format assertions in same test file
**Specifics:**
- Test error message format matches spec
- Test error includes field name
- Test error is user-friendly

## Gate 3: Existing user flows unaffected
**From criteria:** "No regressions"
**Verification type:** Test-based (existing tests)
**Strategy:** Run existing integration test suite
**Specifics:**
- All 23 existing user integration tests pass
- No new tests required (existing coverage sufficient)

---

## Complexity Assessment: SIMPLE

**Reasoning:**
- Single component (user model)
- Established validation pattern exists in codebase
- Clear implementation path
- All gates use same verification type (tests)
- Gates 1-2 related (can be same task)
- Gate 3 is regression check only

**Recommended approach:** Plan all tasks upfront

**Estimated tasks:** 2 tasks, 2 commits
- Task 1: Implement validation (Gates 1, 2)
- Task 2: Verify regressions (Gate 3)
```

**Example with splitting recommendation:**

```markdown
# Verification Gates for Issue #52: Authentication System

## [Gates 1-3 for database schema...]
## [Gates 4-6 for API endpoints...]
## [Gates 7-9 for frontend UI...]
## [Gates 10-11 for permissions...]

---

## Splitting Opportunity Detected

**Pattern:** Multiple independent features bundled together

**Observation:**
- Four distinct gate groups identified
- Database schema is prerequisite, but API/Frontend/Permissions are independent
- Each group forms coherent unit of work
- Splitting would enable parallel development and clearer commit history

**Suggested split:**
- Issue #52a: Auth database schema (Gates 1-3, prerequisite)
- Issue #52b: Login/logout API endpoints (Gates 4-6)
- Issue #52c: Frontend auth components (Gates 7-9)
- Issue #52d: Authorization middleware (Gates 10-11)

**Recommendation:** STOP and re-plan with smaller issues

---
Human decision required: Proceed with current scope or split?
```

---

### Phase 1.5: Test Case Definition (CONDITIONAL)

Define concrete test cases for Test-based Gates before task planning.

**When to execute:** Only when Test-based Gates exist in gates.md

**Command:** `/wf-15-define-test-cases <issue-identifier>`

**What it does:**

1. Reads gates.md and identifies Test-based Gates
2. Expands "Specifics" into concrete test cases
3. Creates test-cases.md with structured test definitions
4. Determines Local vs CI execution strategy
5. Updates gates.md with test case references

**Output:** `.agents/tasks/<issue>/test-cases.md`

**Skip Logic:** Automatically skips to Phase 2 if no Test-based Gates exist

**Why this phase exists:**

- Clarifies test implementation before coding begins
- Supports Test-Driven Development (TDD)
- Separates "what to test" from "how to implement"
- Provides clear test case estimates for task planning
- Enables efficient test execution strategy (Local/CI split)

**Test Case Structure:**

```markdown
#### TC-X.Y: [Test case description]
- **Type:** Unit | Integration | E2E
- **Execution:** Local | CI | Both
- **Given:** [Preconditions]
- **When:** [Action]
- **Then:** [Expected outcome]
- **Estimated LOC:** ~N lines
```

**Local vs CI Execution:**

**Local Execution (< 10 seconds):**
- Unit tests with no external dependencies
- Fast integration tests with mocks
- Purpose: High-speed feedback during development

**CI Execution (10+ seconds):**
- Integration tests with real dependencies (DB, API)
- E2E tests requiring full application stack
- Purpose: Comprehensive verification before merge

**gates.md Update:**

After test-cases.md is created, each Test-based Gate is updated:

```markdown
**Test Cases:** TC-1.1, TC-1.2, TC-1.3 (see test-cases.md)
**Status:** Test cases defined ✓
```

---

### Phase 2: Task Planning

Plan implementation tasks based on the gates.

**Command:** `/wf-02-task-plan <issue-identifier>`

**What it does:**

1. Reads `gates.md` for the issue
2. Checks existing task files
3. Based on complexity assessment:
   - **SIMPLE:** Plans all tasks at once (if no tasks exist)
   - **COMPLEX:** Plans next task only (iterative)
4. Creates task file(s) in `.agents/tasks/<issue>/`

**Each task:**

- Completes one or more gates
- Fits in a single commit (50-200 lines, 1-5 files)
- Has clear completion criteria

**Task template:**

```markdown
# Task N: [Brief description]

**Issue:** [reference]
**Branch:** [detected from git]
**Completes:** Gate N [, Gate M]

## Objective
What this task accomplishes

## Implementation Steps
- [ ] Step one
- [ ] Step two
- [ ] Step three

## Completion Gate
- [ ] Assigned gate(s) verification passes
- [ ] No regressions (existing tests still pass)
- [ ] Changes fit in single commit

## Commit Message Template
[type]([scope]): [description]

- [detail]
- [detail]

Completes: Gate N of #[issue]

## Implementation Notes
[To be filled during implementation]
```

**SIMPLE issue example (all tasks planned):**

```bash
$ /wf-02-task-plan issue-47-user-email

Reading gates.md...
Complexity: SIMPLE
No existing tasks found.

Planning all tasks for this issue...

Created:
  - task-1.md (completes Gates 1, 2)
  - task-2.md (completes Gate 3)

Next: /wf-03-implement issue-47 task-1
```

**COMPLEX issue example (iterative planning):**

```bash
$ /wf-02-task-plan issue-52-auth-system

Reading gates.md...
Complexity: COMPLEX
No existing tasks found.

Planning first task based on gate analysis...

Created:
  - task-1.md (completes Gate 1: Database schema)

Next: /wf-03-implement issue-52 task-1

After task-1 completes, return here to plan task-2 based on learnings.
```

---

### Phase 3: Task Execution

Implement a specific task.

**Command:** `/wf-03-implement <issue-identifier> <task-identifier>`

**Process:**

1. Read task file
2. Follow implementation steps
3. Check off steps as completed
4. Verify completion gates
5. Add implementation notes
6. Commit and create PR (your AI agent performs this autonomously)

**The agent:**

- Makes code changes
- Checks off implementation steps
- Runs verification commands
- Records any discoveries or direction changes in Implementation Notes
- **Commits and creates PR** after all gates pass

**The human:**

- Reviews the PR
- Merges or Closes (human has final Merge authority)

**Example:**

```bash
$ /wf-03-implement issue-47 task-1

Reading task-1.md...
Completes: Gates 1, 2

[Agent works through implementation steps]
[Agent checks off completion gates]
[Agent adds implementation notes]

Task complete. Review changes:
  - Modified: src/models/user.ts (45 lines)
  - Modified: tests/models/user.test.ts (67 lines)

Gates verified:
  [x] Gate 1: Email validation tests pass
  [x] Gate 2: Error message tests pass
  [x] No regressions

Ready for commit. Suggested message:
  feat(user): add email validation

  - Validates email format on user save
  - Rejects null, empty, invalid formats
  - Clear error messages for validation failures

  Completes: Gates 1, 2 of #47
```

---

### Phase 4: Next Task or Cleanup

After implementing and committing a task, decide next step:

**If more gates remain:**

```bash
/wf-02-task-plan <issue-identifier>
```

- **SIMPLE:** Reports on remaining tasks already planned
- **COMPLEX:** Plans next task based on previous task's Implementation Notes

**If all gates complete:**

```bash
/wf-04-cleanup <issue-identifier>
```

Proceed to cleanup phase.

---

### Phase 5: Cleanup and Verification

Review the branch before PR, validate all gates, fix quality issues.

**Command:** `/wf-04-cleanup <issue-identifier>`

**Three-phase process:**

**Phase 1 - Audit:** Agent reviews all changes in branch, creates numbered audit list:

- Temporary comments left behind
- Debug code or console logs
- Inconsistent naming
- Missing error handling
- Documentation gaps
- Code quality issues
- Undocumented architectural decisions (may need ADR)

**Phase 2 - Fix:** Human selects which items to fix:

- "all" -- fix everything
- "1,3,4,5" -- fix specific items
- "all except 2,6" -- fix most, skip some

Agent fixes approved items.

**Phase 3 - Validate:** Agent:

- Re-verifies ALL gates from gates.md
- Checks off each gate as verified
- Runs full test suite
- Reports final status
- **Commits cleanup changes and creates PR** after all gates pass (your AI agent's responsibility)

**Human:**

- Reviews the PR
- Merges or Closes (human has final Merge authority)

---

## Optional On-Demand Phases

### Issue Planning (when starting from scratch)

**When to use:**

- Starting a new feature or change from scratch
- Need to define scope and success criteria for a body of work
- Want structured issue definition before defining gates

**Command:** `/wf-issue-plan`

**Output:** Issue definition (GitHub issue or markdown file in `.agents/issues/`)

**Key principle:** Focus on one issue at a time, re-evaluate after completion.

**Issue template:**

```markdown
## Issue: [Title]

**Objective:**
What does "done" look like for this issue?

**Success Criteria:**
- [ ] Specific, verifiable condition 1
- [ ] Specific, verifiable condition 2
- [ ] Specific, verifiable condition 3

**Gates:** (optional -- can define here or during gate definition phase)
- Gate 1: [rough description]
- Gate 2: [rough description]

**Scope Boundaries:**
What is NOT included in this issue?
- Out: Feature X (separate issue)
- Out: Performance optimization (later)
- Out: Pre-existing bugs (file separately)
```

**Note:** Many teams already have issues defined in GitHub or other tracking systems. Use this command when you need to create a new issue from scratch. If an issue already exists, skip directly to `/wf-01-define-gates`.

---

### Design (when needed)

**When to use:**

- Can't write meaningful gates (interface undefined)
- Multiple implementation approaches with significant tradeoffs
- New module/component with no established pattern

**Command:** `/wf-design <issue-identifier>`

**Output:** Lightweight design doc (50-100 lines) in `docs/design/<issue>.md` (feature branch, included in PR)

**Contains:**

- Problem statement
- Key decisions and tradeoffs
- Interface signatures (no implementation)
- Integration points
- What's deliberately out of scope

**Rule:** Design phase produces NO code. Signatures and types only.

**Note:** For decisions with significant tradeoffs that need formal documentation, consider `/wf-adr` instead of or in addition to design.

---

### ADR (when architectural decisions need recording)

**When to use:**

- New abstraction or pattern being introduced
- Multiple viable approaches with significant tradeoffs
- Technology or dependency choice
- Interface design that will be hard to change later
- Deviation from established codebase patterns
- Agent flags "this requires a decision" during implementation

**Command:** `/wf-adr <decision-title>`

**Output:** ADR document in `docs/adr/NNNN-<decision-title>.md` (MADR format)

**Contains:**

- Context and decision drivers
- Options considered with pros/cons
- Agent recommendation with caveats
- Human decision and rationale
- Expected consequences

**Rule:** Agent researches and presents options; human selects and provides rationale. Prevents decision delegation.

See `/wf-adr` command specification for full details.

---

### Investigate (when confused)

**When to use:**

- Don't understand existing code well enough to plan
- Need to understand current state before defining gates
- Working with stubs or incomplete implementations

**Command:** `/wf-investigate <issue-identifier>`

**Output:** Investigation notes recorded as Issue comment (also saved to `.agents/tasks/<issue>/investigation.md` if needed for cross-session reference)

**Agent:**

- Explores codebase
- Documents findings
- Asks clarifying questions
- Suggests approach
- Does NOT write implementation code

---

### Summarise (when stuck or switching contexts)

**When to use:**

- Context feels polluted (confused responses)
- After three failures on same problem
- Need to switch contexts (end of day, interruption)
- Before starting fresh session

**Command:** `/wf-summarise <issue-identifier> <task-identifier>`

Or simply: `/wf-summarise` (auto-detects context)

**Output:** Handoff notes — recorded in task file's Implementation Notes section (if implementing), or as Issue comment (if designing, investigating, or context unclear)

**Contains:**

- What was being worked on
- What's complete
- What's in progress
- What's blocking
- Next steps
- Handoff prompt for new session

---

## Command Reference

All commands use slash-command syntax (no arguments like `--flag`):

### Core Workflow

```
/wf-01-define-gates <issue-identifier>
/wf-02-task-plan <issue-identifier>
/wf-03-implement <issue-identifier> <task-identifier>
/wf-04-cleanup <issue-identifier>
```

### Optional On-Demand

```
/wf-issue-plan
/wf-design <issue-identifier>
/wf-adr <decision-title>
/wf-investigate <issue-identifier>
/wf-summarise <issue-identifier> <task-identifier>
/wf-summarise
```

### Example Flow (Simple Issue)

```
# Start from an existing issue (GitHub, markdown, etc.)

/wf-01-define-gates issue-47-user-email-validation
# Creates gates.md (SIMPLE complexity, 2 tasks recommended)

/wf-02-task-plan issue-47-user-email-validation
# Creates task-1.md, task-2.md

/wf-03-implement issue-47-user-email-validation task-1
# Agent commits and creates PR; human makes final Merge decision

/wf-03-implement issue-47-user-email-validation task-2
# Agent commits and creates PR; human makes final Merge decision

/wf-04-cleanup issue-47-user-email-validation
# Agent commits cleanup and creates PR; human makes final Merge decision
```

### Example Flow (Complex Issue)

```
# Start from an existing issue

/wf-investigate issue-52-terraform-rds
# Explores existing infrastructure

/wf-01-define-gates issue-52-terraform-rds
# Creates gates.md (COMPLEX complexity)

/wf-02-task-plan issue-52-terraform-rds
# Creates task-1.md only

/wf-03-implement issue-52-terraform-rds task-1
# Agent commits and creates PR; human makes final Merge decision

/wf-02-task-plan issue-52-terraform-rds
# Creates task-2.md based on task-1 learnings

/wf-03-implement issue-52-terraform-rds task-2
# Agent commits and creates PR; human makes final Merge decision

/wf-04-cleanup issue-52-terraform-rds
```

### Example Flow (With ADR)

```
# Start from an existing issue

/wf-adr api-versioning-pattern
# Agent researches options, human selects approach
# Creates docs/adr/0022-api-versioning-pattern.md

/wf-01-define-gates issue-63-api-versioning
# Creates gates.md informed by ADR decision

/wf-02-task-plan issue-63-api-versioning
# Creates tasks based on chosen approach

...
```

### Example Flow (New Issue from Scratch)

```
/wf-issue-plan
# Creates issue-47-user-email-validation (on-demand)

/wf-01-define-gates issue-47-user-email-validation
# Creates gates.md

/wf-02-task-plan issue-47-user-email-validation
# Creates tasks

...
```

---

## Workflow Optimization Strategies

This section describes advanced optimization strategies for the agentic workflow, particularly focused on cost efficiency and quality management.

### Local Review Integration

**Problem:** Running paid AI reviews on GitHub Actions consumes free tier quota and incurs costs.

**Solution:** Shift quality reviews to local environment, use GitHub Actions only for automated testing.

**Implementation:**
- **Commit-level reviews**: Paid AI reviews each commit locally before push
- **Review storage**: Results saved to `.agents/reviews/{commit-hash}.json`
- **Iterative refinement**: Local LLM fixes issues based on review feedback (max 3 iterations)
- **PR creation**: Paid AI creates PR only after all local reviews pass
- **CI/CD role**: GitHub Actions runs tests only, not code reviews

**Benefits:**
- Reduced GitHub Actions usage (stays within free tier)
- Earlier bug detection (before push)
- Faster feedback loop (no CI/CD wait time)
- Lower overall costs (local reviews vs cloud reviews)

### Staged Review Strategy

**Problem:** Reviewing every commit with paid AI is expensive.

**Solution:** Three-tier review approach balancing cost and quality.

**Tiers:**
1. **Lightweight (free)**: Local static analysis tools (linters, type checkers)
   - Run on every file save
   - Catches syntax errors, style violations

2. **Medium (paid, selective)**: Paid AI review at task completion
   - Reviews complete feature implementation
   - Focuses on architecture and design

3. **Comprehensive (paid, final)**: Full review before PR creation
   - Reviews all changes holistically
   - Validates gates and integration

**When to use each tier:**
- Tier 1: Always (automated)
- Tier 2: After each task completion
- Tier 3: Before PR creation (Cleanup phase)

### Review Result Caching

**Problem:** Re-reviewing unchanged code wastes API calls and time.

**Solution:** Cache review results by file hash.

**Structure:**
```
.agents/review-cache/
├── {file-hash}.json      # File-level review results
└── {commit-hash}.json    # Commit-level review results
```

**Cache invalidation:**
- File hash changes → re-review that file only
- Dependencies change → re-review dependent files
- Review rules change → invalidate all cache

**Benefits:**
- Reduced API calls (skip unchanged files)
- Faster review cycles
- Lower costs

### Parallel Review Execution

**Problem:** Sequential reviews slow down large changes.

**Solution:** Review multiple files in parallel.

**Implementation:**
```
File A → Review A ┐
File B → Review B ├→ Aggregate → Consolidated feedback
File C → Review C ┘
```

**Considerations:**
- Group related files (same module/feature)
- Limit parallelism (API rate limits)
- Aggregate results intelligently (avoid duplicate feedback)

**Benefits:**
- Faster reviews for multi-file changes
- Better resource utilization
- Reduced wall-clock time

### Incremental PR Strategy

**Problem:** Large PRs are hard to review and risky to merge.

**Solution:** Create smaller, incremental PRs based on complexity assessment.

**Strategy by complexity:**

**SIMPLE issues:**
- Single PR after all tasks complete
- All changes reviewed together
- Lower overhead

**COMPLEX issues:**
- Multiple PRs, one per major milestone
- Each PR is independently testable
- Reduces blast radius of failures

**Benefits:**
- Easier human review (smaller diffs)
- Faster feedback (don't wait for everything)
- Lower risk (incremental integration)
- Better git history (logical chunks)

### Smart Iteration Control

**Problem:** Infinite loops when AI can't fix issues.

**Solution:** Intelligent iteration limits with escalation.

**Rules:**
1. **Max 3 iterations** per review cycle
2. **Confidence scoring**: Track review confidence (0-100%)
   - 90%+ → proceed to next step
   - 70-89% → one more iteration
   - <70% → escalate to human
3. **Pattern detection**: Identify repeated failures
   - Same error 3 times → escalate
   - Oscillating changes → escalate

**Escalation triggers:**
- Iteration limit reached
- Low confidence score
- Repeated failure pattern
- Contradictory feedback

**Benefits:**
- Prevents wasted API calls
- Faster human intervention when needed
- Better resource allocation

### Test Failure Pattern Database

**Problem:** Same test failures require repeated AI analysis.

**Solution:** Build database of known failure patterns and fixes.

**Structure:**
```
.agents/test-failures/
└── patterns.json
    ├── pattern: "TypeError: Cannot read property 'x' of undefined"
    ├── cause: "Null check missing"
    ├── fix_template: "Add null check before accessing property"
    └── auto_fixable: true
```

**Workflow:**
1. Test fails → check pattern database
2. If known pattern → apply fix automatically
3. If unknown → paid AI analyzes → add to database
4. Over time, database grows → fewer AI calls needed

**Benefits:**
- Faster fixes for known issues
- Reduced AI analysis costs
- Accumulated project knowledge
- Improved over time

### Metrics Collection

**Problem:** Can't optimize what you don't measure.

**Solution:** Collect metrics at each workflow stage.

**Key metrics:**
- **Review metrics**:
  - Reviews per commit
  - Iterations per review
  - Review time
  - Issues found per review

- **Cost metrics**:
  - API calls per task
  - Tokens consumed
  - Cost per feature

- **Quality metrics**:
  - Test failure rate
  - Bugs found in review vs production
  - Time to fix issues

- **Efficiency metrics**:
  - Time per task
  - Human review time
  - Merge time

**Storage:**
```
.agents/metrics/
├── reviews.jsonl       # Review events
├── costs.jsonl         # Cost tracking
└── quality.jsonl       # Quality events
```

**Benefits:**
- Data-driven optimization
- Cost tracking and budgeting
- Identify bottlenecks
- Continuous improvement

### Implementation Priority

Recommended order for adopting these strategies:

1. **Local Review Integration** (immediate impact on costs)
2. **Smart Iteration Control** (prevents runaway costs)
3. **Staged Review Strategy** (balances cost and quality)
4. **Incremental PR Strategy** (reduces risk)
5. **Metrics Collection** (enables long-term optimization)
6. **Review Result Caching** (optimization for mature projects)
7. **Test Failure Pattern Database** (long-term investment)
8. **Parallel Review Execution** (advanced optimization)

Start with strategies 1-4 for immediate benefits, then add others as the project matures.

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Instead |
|--------------|--------------|---------|
| Long sessions across multiple tasks | Context pollution, forgotten instructions | Fresh session per task |
| Massive AGENTS.md (500+ lines) | Gets ignored as context fills | Under 200 lines, non-negotiables only |
| **Skipping gate definition** | Vague completion criteria, rubber-stamp risk | Always run `/wf-01-define-gates` |
| **Writing tests when commands work better** | Maintenance burden for no value | Choose verification type based on domain |
| **Multiple commits per task** | Unreviewable diffs, tangled changes | Each task = one commit |
| **Comprehensive upfront design** | Goes stale, creates review burden | Design on-demand when gaps emerge |
| **Skipping design when confused** | Gates encode wrong assumptions | Pause, design, then continue |
| **500-line design docs** | Won't be read or maintained | Keep under 100 lines |
| **Writing code in design phase** | Premature commitment, wrong phase | Signatures and types only |
| **Skipping investigation on stubs** | Can't define meaningful gates | Investigate first, then define gates |
| Planning many issues at once | Later issues will be wrong | One issue at a time, re-evaluate after each |
| **Planning all tasks when complex** | Later tasks will be wrong, stale definitions | Respect complexity assessment |
| **Never updating issue scope** | Reality diverges from plan | Update issue when discoveries warrant |
| Trusting "it's done" | AI optimizes for appearing complete | Verify gates yourself |
| **Continuing after context degrades** | Responses get confused, quality drops | Summarise, start fresh session |
| **Losing progress when switching sessions** | Have to re-discover everything | Summarise before ending session |
| Vague success criteria | Allows AI to claim success prematurely | Specific, verifiable conditions |
| Skipping cleanup review | Litterbug accumulation, tech debt | Always review branch before PR |
| **Creating redundant tests** | Maintenance overhead, no coverage gain | Gate definition catches this early |
| **Not capturing Implementation Notes** | Lost context for next task | Note direction changes, discoveries |
| **Merging PR without human review** | Bypasses human review gate | Agent commits and creates PR; human reviews and merges |
| **Modifying tests to make them pass** | Masks bugs, tests lose value | Fix implementation, not tests |
| **Adding dependencies without asking** | Bloat, security risk, maintenance burden | Agent proposes, human approves |
| **Updating scope without approval** | Scope creep, lost accountability | Agent proposes changes, human approves |
| **Fixing pre-existing bugs in cleanup** | Scope creep, untested changes | Open separate bug issue |
| **Reinventing the wheel** | Maintenance burden, security risk, likely bugs | Use libraries or platform built-ins |
| **Using numbered lists instead of checkboxes** | Can't track completion status | Always use `- [ ]` for trackable items |
| **Skipping gate validation in cleanup** | Issue may not be complete | Phase 3 of cleanup validates all gates |
| **Ignoring splitting recommendations** | Long-running branches, merge conflicts | Consider suggested splits seriously |
| **Making architectural decisions silently** | Decision delegation, no audit trail | Use `/wf-adr` for significant decisions |
| **Single-option ADRs** | No real decision, just documentation | Require minimum 2 viable options |

---

## When to Take Manual Control

The agent is powerful but not universal. Take over manually when:

1. **Repeated failure after fresh session** -- If 3+ failures, Summarise and try fresh session. If fresh session ALSO fails on the same focused problem, that confirms AI blind spot -- take manual control.

2. **Configuration/environment issues** -- Build tools, CI/CD, environment setup are often undertrained

3. **Highly domain-specific work** -- Niche frameworks, proprietary systems, unusual patterns

4. **Security-critical code** -- Always human-review auth, encryption, access control

5. **Context feels muddy** -- If responses feel confused or repetitive, Summarise first. Fresh session might fix it. If not, take over.

Taking manual control isn't failure -- it is recognizing the right tool for the job.

**The Three Failures Recovery Path:**

```
3 failures on focused problem
        |
        v
    Summarise (checkpoint current state)
        |
        v
    Fresh session (same approach)
        |
    +---+---+
    |       |
 succeeds  fails again
    |       |
    v       v
 continue  Take manual control
           (confirmed AI blind spot)
```

---

## Key Principles Summary

1. **Fresh sessions are cheap, polluted context is expensive** -- Default to starting new sessions, not continuing

2. **Hard gates, no exceptions** -- A task isn't done until its gate passes, verified by you

3. **Human review at every phase boundary** -- You are the quality gate

4. **Gates first, always** -- Define verification strategy before planning tasks

5. **Flexible verification** -- Tests when appropriate, commands when better, manual when necessary

6. **One task, one commit** -- Each task must fit in a reviewable unit

7. **Complexity-aware planning** -- Simple issues plan all tasks upfront, complex issues plan iteratively

8. **Respect splitting recommendations** -- When agent detects bundled features, consider the split

9. **Issues evolve, gates define done, tasks capture work** -- Update issue scope when needed; gates stay stable; Implementation Notes preserve context

10. **Agent proposes, human approves** -- Scope changes, dependencies, and architectural decisions require explicit approval. Commits and PR creation are performed autonomously by your AI agent; human approval is required for Merge only.

11. **Protect the tests** -- Never modify test logic to make tests pass; fix the implementation

12. **When stuck, ask** -- Agent stops and asks rather than guessing or trying workarounds

13. **Cleanup before PR, not after** -- Review your own branch with fresh AI eyes before merge

14. **One issue at a time, constant re-evaluation** -- Focus on a single issue, respond to what you learn

15. **Know when to take the wheel** -- 3 failures on a focused task, Summarise first, then manual if still failing

16. **Don't reinvent the wheel** -- Use libraries and platform built-ins instead of custom implementations

17. **Summarise when context degrades** -- Checkpoint progress before starting fresh; enables recovery without losing work

18. **Use checkboxes for tracking** -- All success criteria, implementation steps, and gates use `- [ ]` format

19. **Validate before declaring done** -- Cleanup Phase 3 verifies and checks off all issue gates

20. **Record architectural decisions** -- Use `/wf-adr` when introducing patterns, choosing technologies, or deviating from established approaches
