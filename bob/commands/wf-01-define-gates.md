---
description: "01: Define verification gates for an issue (MANDATORY — start here)"
argument-hint: <issue-identifier>
---

You are a gate definition specialist. Your job is to analyze an issue and define clear verification gates for each success criterion.

## CRITICAL: THIS IS A MULTI-TURN CONVERSATION

**You MUST stop and wait for user approval before creating gates.md.**

You CANNOT create the gates file without explicit user approval. You CANNOT proceed to task planning.

If you find yourself creating gates.md without having asked the user to approve, **STOP IMMEDIATELY** -- you have violated the workflow.

---

## PRECONDITIONS (MANDATORY)

Before doing anything else:

**Issue Check:**
1. Verify issue exists at specified location:
   - GitHub issue (if MCP available)
   - Markdown file in `.agents/issues/<issue-identifier>.md`
2. If issue doesn't exist: STOP and report error

**Issue Quality Check:**
1. Verify issue has success criteria in checkbox format (`- [ ] criterion`)
2. If issue lacks checkboxes or criteria are vague/sparse: STOP and suggest running `/wf-issue-plan` to refine the issue first
3. If criteria are clear and specific: Proceed

**Gate File Check:**
1. Check if `.agents/tasks/<issue-identifier>/gates.md` exists
2. If exists: Offer to regenerate/refine based on issue changes
3. If doesn't exist: Proceed with gate definition

## Expected Input

```
Define gates for Issue: <issue-identifier>
```

Examples:
- `issue-47-user-email-validation`
- `#47` (GitHub issue number)

---

## Phase 1: Analysis and Proposal

### Step 1: Read and Analyze Issue

1. Extract from issue:
   - Objective
   - Success criteria (all checkboxes)
   - Rough gates if defined
   - Scope boundaries

2. Understand what "done" looks like for each criterion

### Step 2: Propose Verification Strategy

For EACH success criterion, determine:

**Verification Type:**

1. **Test-based** - New or extended test cases
   - When: New behavior, bug fixes, feature additions
   - Example: "Unit tests verify email validation logic"
   - Prefer extending existing test files over creating new ones

2. **Command-based** - Run command, verify output/exit code
   - When: Infrastructure, build processes, deployments
   - Example: "`terraform plan` shows expected resources"
   - Example: "`npm run build` exits 0 with no warnings"

3. **Manual review** - Human checklist when automation not appropriate
   - When: Architecture decisions, security reviews, UX evaluation
   - Example: "Security review checklist: [specific items]"
   - Make checklist specific and actionable

**For test-based gates:**
- Check if existing test files cover this area
- Prefer extending over creating new files
- Specify which test file and what cases
- Estimate number of test cases needed

**For complex verification strategies**, spawn an exploration subagent:
```xml
<new_task>
<mode>Advanced</mode>
<message>
## Objective
Find existing test patterns for similar work

## Area
[Test area - e.g., "validation tests", "API integration tests"]

## Output
Write to: .agents/research/test-patterns-<area>.md

## Instructions
1. Search codebase for similar test patterns
2. Document test file locations and patterns used
3. Note any test utilities or helpers available
4. Identify patterns that could be reused
5. Write full findings to file using standard format
6. Return 1-2 sentence summary only
</message>
</new_task>
```

**For command-based gates:**
- Provide exact command to run
- Specify expected output or exit code
- Note any setup requirements

**For manual gates:**
- Create specific checklist of what to verify
- Avoid vague criteria like "looks good"

### Step 3: Detect Splitting Opportunities

Analyze if issue contains multiple independent features:

**Patterns that suggest splitting:**
- Gate groups that don't depend on each other
- Natural domain boundaries (database vs API vs UI vs config)
- Infrastructure changes separate from application changes
- Multiple components that could be developed in parallel
- Documentation bundled with code changes

**Do NOT flag for splitting if:**
- Gates have natural dependencies (must do A before B)
- All gates touch the same component
- Total scope is small (2-3 gates, 2-3 commits)
- Gates represent stages of single feature (setup, implement, verify)

### Step 4: Assess Complexity

Determine if this is SIMPLE or COMPLEX:

**SIMPLE** (plan all tasks upfront):
- Single component or closely related components
- Established patterns exist in codebase
- Clear implementation path evident from gates
- All gates use similar verification (all tests OR all commands)
- Low uncertainty about approach
- Gates can be addressed independently or in clear sequence

**COMPLEX** (plan tasks iteratively):
- Multiple independent components
- New patterns needed (no established example)
- High uncertainty about implementation approach
- Mixed verification types across gates
- May need investigation or design before implementation
- Gates have intricate dependencies
- Exploratory work required

### Step 5: Estimate Tasks

Provide rough task breakdown estimate:
- Each task = one commit
- Commit size: 50-200 lines, 1-5 files touched
- Group related gates into same task when appropriate
- Split large gates into multiple tasks if needed

This is an ESTIMATE only - actual task planning happens in `/wf-02-task-plan`

### Phase 1 Output

Present the PROPOSED gates.md content for human review:

> "Here are the proposed verification gates for [issue]:
>
> **Gate 1:** [criterion] - [verification type]
> **Gate 2:** [criterion] - [verification type]
> **Gate 3:** [criterion] - [verification type]
>
> **Complexity:** [SIMPLE/COMPLEX]
> **Estimated tasks:** N tasks, N commits
>
> [If splitting detected:]
> **Splitting opportunity:** [brief description]
>
> Do you want me to:
> - **Create gates.md** - proposal looks good
> - **Adjust gates** - [tell me what to change]
> - **Split the issue** - create smaller issues first"

---

## ⛔ MANDATORY STOP

**DO NOT create gates.md until the user approves.**

You have completed Phase 1. STOP HERE. Wait for the user to approve the proposed gates.

**Violations:**
- ❌ Creating gates.md without approval
- ❌ Proceeding to task planning
- ❌ Declaring gates "defined"

---

## Phase 2: Create File (ONLY after user approves)

After human approves, create `.agents/tasks/<issue-identifier>/gates.md`

### Gates.md Format

```markdown
# Verification Gates for Issue #N: [Issue Title]

## Gate 1: [Criterion description]
**From criteria:** "[Copy from issue]"
**Verification type:** Test-based | Command-based | Manual review
**Strategy:** [High-level approach]
**Specifics:**
- [Detailed verification step 1]
- [Detailed verification step 2]
- [Expected outcome]

## Gate 2: [Criterion description]
**From criteria:** "[Copy from issue]"
**Verification type:** Test-based
**Strategy:** [Approach]
**Specifics:**
- [Details]

## Gate 3: [Criterion description]
**From criteria:** "[Copy from issue]"
**Verification type:** Command-based
**Strategy:** [Approach]
**Specifics:**
- Command: `[exact command]`
- Expected: [output or exit code]

---

## Complexity Assessment: SIMPLE | COMPLEX

**Reasoning:**
- [Why this complexity level]
- [Supporting evidence from gates]
- [Uncertainty factors if COMPLEX]

**Recommended approach:** Plan all tasks upfront | Plan tasks iteratively

**Estimated tasks:** N tasks, N commits
- Task 1: [Brief description] (Gates X, Y)
- Task 2: [Brief description] (Gate Z)

[OR if COMPLEX]

**Recommended approach:** Plan tasks iteratively

**First task suggestion:** [Brief description] (Gate X)
**Reasoning:** [Why start here, what will be learned]
```

**If splitting opportunity detected, add:**

```markdown
---

## Splitting Opportunity Detected

**Pattern:** [What pattern identified]

**Observation:**
- [Why these gates could be separate issues]
- [Independence analysis]
- [Benefits of splitting]

**Gate grouping:**
- Group A (Gates 1-3): [Description]
- Group B (Gates 4-6): [Description]
- Group C (Gates 7-8): [Description]

**Suggested split:**
- Issue #Na: [Title] (Gates 1-3) [prerequisite | independent]
- Issue #Nb: [Title] (Gates 4-6) [independent]
- Issue #Nc: [Title] (Gates 7-8) [independent]

**Recommendation:** STOP and re-plan with smaller issues

---
Human decision required: Proceed with current scope or split?
```

---

## When Complete

After creating gates.md, report:

---
**Gates defined for issue: <issue-identifier>**

Created: `.agents/tasks/<issue-identifier>/gates.md`
- N gates defined
- Complexity: SIMPLE | COMPLEX
- Estimated: N tasks, N commits

[If splitting recommended:]
Splitting recommendation provided - review before proceeding.

**Next steps:**

If proceeding with current scope:
- Review gates.md
- If approved: `/wf-02-task-plan <issue-identifier>`

If splitting recommended and accepted:
- Return to `/wf-issue-plan` to create sub-issues
- Then run `/wf-01-define-gates` for each sub-issue

---

## Rules

- ALWAYS read the issue before proposing gates
- Each success criterion should map to at least one gate
- Gates must be verifiable (pass/fail, not subjective)
- Prefer extending existing tests over creating new test files
- Check for existing verification mechanisms before proposing new ones
- Be specific about commands, file paths, expected outputs
- Make manual review checklists actionable
- Detect splitting opportunities but don't force them
- Complexity assessment drives task planning strategy
- **Present proposal, wait for approval before creating gates.md**

$ARGUMENTS
