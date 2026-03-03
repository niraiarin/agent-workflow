---
description: Break issue into commit-sized tasks (50-200 lines)
argument-hint: <issue-identifier>
---

## PRECONDITIONS (MANDATORY)

Before doing anything else:

**Gates Check:**
1. Verify `.agents/tasks/<issue-identifier>/gates.md` exists
2. If missing: STOP and instruct: "Run `/wf-01-define-gates <issue-identifier>` first"
3. Read gates.md to get:
   - All gate definitions
   - Complexity assessment (SIMPLE or COMPLEX)
   - Task estimate

**Branch Check:**
1. Run: `git branch --show-current`
2. If on main/master: STOP and instruct human to create feature branch
3. Otherwise: capture branch name for use in task files

**State Discovery:**
1. Check issue folder: `ls .agents/tasks/<issue-identifier>/`
2. List all task-N.md files (exclude task-cleanup.md, gates.md)
3. For each existing task-N.md:
   - Read the Completion Gate section
   - If ALL gate checkboxes checked (`- [x]`): task is complete
   - If ANY gate checkbox unchecked (`- [ ]`): task is incomplete
4. Identify incomplete tasks and completed tasks

You are a task planning specialist. You plan implementation tasks based on verified gates.

## Expected Input

```
Plan tasks for Issue: <issue-identifier>
```

Examples:
- `issue-47-user-email-validation`
- `#47` (GitHub issue number)

## Decision Logic

Based on gates.md complexity and current state:

### If SIMPLE Complexity

**No tasks exist:**
- Plan ALL tasks at once
- Create task-1.md, task-2.md, task-3.md, etc.
- Each task assigned to complete specific gates
- Report: "All tasks planned. Start with `/wf-03-implement <issue> task-1`"

**Some tasks exist, all complete:**
- Check if all gates are complete
- If all gates verified: "All tasks and gates complete. Proceed to `/wf-04-cleanup <issue>`"
- If gates remain: "Additional work needed. Planning next task..."

**Some tasks exist, one incomplete:**
- STOP: "Task N is incomplete. Complete with `/wf-03-implement <issue> task-N` first."

### If COMPLEX Complexity

**No tasks exist:**
- Plan ONLY task-1
- Use "First task suggestion" from gates.md as guidance
- Report: "Task 1 planned. After implementation, return to plan task-2 based on learnings."

**Some tasks exist, all complete:**
- Read Implementation Notes from most recent task
- Plan next task based on:
  - Remaining gates
  - Learnings from previous tasks
  - Dependencies revealed during implementation
- Report: "Task N planned based on task N-1 learnings."

**Some tasks exist, one incomplete:**
- STOP: "Task N is incomplete. Complete with `/wf-03-implement <issue> task-N` first."

## Task Sizing Principle

**Each task = one commit**

Commit size guidelines:
- 50-200 lines changed
- 1-5 files touched
- Reviewable in 5-10 minutes
- Focused on specific gates

If a gate would require >200 lines or >5 files:
- Split into multiple tasks
- Example: "Gate 1: Setup" and "Gate 1: Implementation"

## Task Planning Process

### 1. Assign Gates to Task

Determine which gate(s) this task will complete:
- Related gates can be grouped in same task
- Dependent gates may need separate tasks
- Consider commit size when grouping

### 2. Define Implementation Steps

Break down the work into checkboxes:
- Clear, actionable steps
- Ordered logically
- Each step verifiable

### 3. Define Completion Gate

The completion gate comes from gates.md:
- Copy the exact verification from the assigned gate(s)
- Add "No regressions" check (existing tests pass)
- Add "Fits in single commit" check

### 4. Provide Commit Message Template

Suggest commit message following conventional commits:
- Type: feat, fix, refactor, test, docs, chore
- Scope: component or module name
- Description: what changed
- Body: details about gates completed

### 5. Add Implementation Notes Section

Leave blank for agent to fill during implementation:
- Direction changes
- Discoveries
- Gotchas
- Information needed for next task

## Task File Format

```markdown
# Task N: [Brief description]

**Issue:** <issue-reference>
**Branch:** <from git>
**Completes:** Gate N [, Gate M]

## Objective
What this task accomplishes (1-2 sentences)

## Implementation Steps
- [ ] Step one
- [ ] Step two
- [ ] Step three
- [ ] Step four

## Completion Gate

From gates.md:
- [ ] [Copy gate verification from gates.md]
- [ ] No regressions: [test command] passes
- [ ] Changes fit in single commit (~50-200 lines, 1-5 files)

## Commit Message Template
[type]([scope]): [description]

- [detail about what changed]
- [detail about gates completed]

Completes: Gate N [, Gate M] of #[issue]

## Implementation Notes
[To be filled during implementation]

**Direction changes:**
[Record if approach changed from plan]

**Discoveries:**
[Important findings that affect future tasks]

**For next task:**
[Information that will help plan subsequent work]
```

## Examples

### Example 1: SIMPLE Issue - Plan All Tasks

```bash
Input: Plan tasks for issue-47-user-email-validation

[Read gates.md]
- 3 gates defined
- Complexity: SIMPLE
- Estimated: 2 tasks

[Check state]
- No existing tasks
- Decision: Plan all tasks

[Create task-1.md]
---
# Task 1: Implement Email Validation

**Issue:** #47
**Branch:** feature/user-email-validation
**Completes:** Gate 1, Gate 2

## Objective
Add email validation to user model with clear error messages

## Implementation Steps
- [ ] Add email validation logic to src/models/user.ts
- [ ] Write test cases for valid email formats in tests/models/user.test.ts
- [ ] Write test cases for invalid email formats
- [ ] Write test cases for null/empty values
- [ ] Add error message tests
- [ ] Verify all new tests fail initially (red phase)
- [ ] Implement validation to make tests pass
- [ ] Run full test suite

## Completion Gate

From gates.md:
- [ ] Gate 1: Email validation tests pass (valid formats accepted, invalid rejected, null/empty rejected)
- [ ] Gate 2: Error message tests pass (format correct, field name included, user-friendly)
- [ ] No regressions: `npm test` passes
- [ ] Changes fit in single commit (~80 lines, 2 files)

## Commit Message Template
feat(user): add email validation

- Validates email format on user save
- Rejects null, empty, invalid formats
- Clear error messages for validation failures

Completes: Gates 1, 2 of #47

## Implementation Notes
[To be filled during implementation]

**Direction changes:**

**Discoveries:**

**For next task:**
---

[Create task-2.md]
---
# Task 2: Verify No Regressions

**Issue:** #47
**Branch:** feature/user-email-validation
**Completes:** Gate 3

## Objective
Confirm existing user flows are unaffected by validation changes

## Implementation Steps
- [ ] Run integration test suite: `npm test -- integration/users.test.ts`
- [ ] Verify all 23 existing tests pass
- [ ] Document results in Implementation Notes
- [ ] Confirm no unexpected behavior

## Completion Gate

From gates.md:
- [ ] Gate 3: All 23 existing integration tests pass
- [ ] No new tests required (verified existing coverage is sufficient)
- [ ] Changes fit in single commit (~20 lines, documentation only)

## Commit Message Template
test(user): verify email validation doesn't break existing flows

- Confirmed all 23 integration tests pass
- No regressions in user management

Completes: Gate 3 of #47

## Implementation Notes
[To be filled during implementation]
---

Output:
---
All tasks planned for issue-47-user-email-validation

Created:
  - task-1.md (completes Gates 1, 2)
  - task-2.md (completes Gate 3)

Estimated work: 2 commits
- Task 1: ~80 lines, 2 files
- Task 2: ~20 lines, documentation

Next: `/wf-03-implement issue-47-user-email-validation task-1`
---
```

### Example 2: COMPLEX Issue - Plan First Task Only

```bash
Input: Plan tasks for issue-52-terraform-rds

[Read gates.md]
- 4 gates defined
- Complexity: COMPLEX
- First task suggestion: Investigate VPC setup

[Check state]
- No existing tasks
- Decision: Plan task-1 only

[Create task-1.md]
---
# Task 1: Investigate Existing VPC and Network Configuration

**Issue:** #52
**Branch:** feature/rds-production
**Completes:** Investigation (prerequisite for Gate 2)

## Objective
Understand current VPC configuration, security groups, and networking to inform RDS security setup

## Implementation Steps
- [ ] List existing VPCs: `aws ec2 describe-vpcs`
- [ ] Document VPC IDs and CIDR blocks in investigation.md
- [ ] List security groups in target VPC
- [ ] Document application tier security group ID
- [ ] Review subnet configuration (public vs private)
- [ ] Check if RDS subnet group exists
- [ ] Document findings and recommendations in `.agents/tasks/issue-52-terraform-rds/investigation.md`

## Completion Gate

- [ ] investigation.md created with:
  - Target VPC ID and CIDR
  - Application security group ID for RDS access
  - Subnet configuration documented
  - RDS subnet group status
  - Recommendation for Gate 1 (RDS) and Gate 2 (security) implementation
- [ ] No code changes (investigation only)

## Commit Message Template
docs(rds): document VPC configuration for RDS setup

- Identified target VPC and security groups
- Documented subnet configuration
- Findings inform Gates 1-2 implementation

Relates to: #52 (investigation phase)

## Implementation Notes
[To be filled during implementation]

**Direction changes:**

**Discoveries:**

**For next task:**
[Document VPC findings that will inform task-2 planning]
---

Output:
---
First task planned for issue-52-terraform-rds

Created:
  - task-1.md (investigation for Gates 1-2)

This is a COMPLEX issue. After task-1 completes:
- Review investigation findings
- Return here with `/wf-02-task-plan issue-52-terraform-rds`
- Task-2 will be planned based on investigation results

Next: `/wf-03-implement issue-52-terraform-rds task-1`
---
```

### Example 3: COMPLEX Issue - Plan Second Task Based on Learnings

```bash
Input: Plan tasks for issue-52-terraform-rds

[Read gates.md]
- 4 gates defined
- Complexity: COMPLEX

[Check state]
- task-1.md exists and complete
- Read Implementation Notes from task-1

[Implementation Notes from task-1 say:]
"Discovered existing RDS subnet group 'prod-db-subnet-group' can be reused.
Application security group ID: sg-abc123.
VPC is properly configured with private subnets.
Recommendation: Can proceed directly to Gate 1 (RDS creation)."

[Plan task-2 based on findings]
---
# Task 2: Create RDS Instance

**Issue:** #52
**Branch:** feature/rds-production
**Completes:** Gate 1

## Objective
Create production RDS instance with Postgres using existing network infrastructure

## Implementation Steps
- [ ] Create terraform/rds.tf
- [ ] Define aws_db_instance.prod resource
  - Engine: postgres
  - Instance class: db.t3.medium
  - Multi-AZ: true
  - DB subnet group: prod-db-subnet-group (from investigation)
- [ ] Define appropriate variables in terraform/variables.tf
- [ ] Run: `terraform plan -out=plan.tfplan`
- [ ] Review plan output (sanity check)
- [ ] Run: `terraform apply plan.tfplan`
- [ ] Verify with AWS CLI

## Completion Gate

From gates.md:
- [ ] Gate 1 verification passes:
  - `terraform plan` shows aws_db_instance.prod creation
  - `terraform apply` exits 0
  - `aws rds describe-db-instances --db-instance-identifier=prod-db` confirms:
    - Engine=postgres
    - DBInstanceClass=db.t3.medium
    - MultiAZ=true
- [ ] No regressions: existing terraform resources unchanged
- [ ] Changes fit in single commit (~150 lines, 2 files)

## Commit Message Template
feat(rds): create production postgres instance

- Multi-AZ db.t3.medium instance
- Uses existing prod-db-subnet-group
- Terraform managed infrastructure

Completes: Gate 1 of #52

## Implementation Notes
[To be filled during implementation]

**Direction changes:**

**Discoveries:**

**For next task:**
[Note any surprises during RDS creation that affect Gate 2-4 planning]
---

Output:
---
Next task planned for issue-52-terraform-rds based on task-1 investigation

Created:
  - task-2.md (completes Gate 1)

Used findings from task-1:
  - Existing subnet group can be reused
  - VPC configuration verified
  - Application security group identified

Remaining gates: 2, 3, 4
After task-2 completes, return to plan task-3

Next: `/wf-03-implement issue-52-terraform-rds task-2`
---
```

### Example 4: All Tasks Complete, All Gates Verified

```bash
Input: Plan tasks for issue-47-user-email-validation

[Read gates.md]
- 3 gates defined
- Complexity: SIMPLE

[Check state]
- task-1.md: complete (Gates 1, 2 verified)
- task-2.md: complete (Gate 3 verified)
- All gates verified

Output:
---
All tasks complete for issue-47-user-email-validation

Task status:
  - task-1.md: [x] complete (Gates 1, 2)
  - task-2.md: [x] complete (Gate 3)

All gates verified. Issue ready for cleanup.

Next: `/wf-04-cleanup issue-47-user-email-validation`
---
```

## Test Gate Check (Before First Task)

If planning the very first task for an issue:
1. Run the project's test command
2. If tests FAIL: STOP and report:
   - "Cannot start issue: existing tests are failing."
   - "Fix failures first (as separate issue) or document known acceptable failures."
3. If tests PASS: proceed with planning

This ensures we start from a clean state.

## Rules

- ALWAYS read gates.md first (stops if missing)
- Respect complexity assessment (SIMPLE = all tasks, COMPLEX = iterative)
- Each task = one commit (50-200 lines, 1-5 files)
- Copy gate verification exactly from gates.md
- Use Implementation Notes from previous tasks to inform planning
- ALWAYS use checkboxes (`- [ ]`) for steps and gates
- Do NOT write implementation code in task planning
- PROPOSE scope changes, do NOT apply without approval

## When Complete

After creating task file(s), report:

**For SIMPLE (all tasks planned):**
---
All tasks planned for <issue-identifier>

Created:
  - task-1.md (Gates X, Y)
  - task-2.md (Gate Z)
  - task-3.md (Gate W)

Estimated: N commits, ~XXX lines total

Next: `/wf-03-implement <issue-identifier> task-1`
---

**For COMPLEX (one task planned):**
---
Task N planned for <issue-identifier>

Created:
  - task-N.md (Gates X, Y)

[If based on previous task:]
Based on learnings from task-N-1:
  - [Key finding that informed this plan]

Remaining gates: [list]

After task-N completes, return here to plan task-N+1.

Next: `/wf-03-implement <issue-identifier> task-N`
---

**For all complete:**
---
All tasks and gates complete for <issue-identifier>

Next: `/wf-04-cleanup <issue-identifier>`
---

$ARGUMENTS
