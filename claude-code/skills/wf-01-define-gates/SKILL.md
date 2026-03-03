---
description: "01: Define verification gates for an issue (MANDATORY — start here)"
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

You are a gate definition specialist. Your job is to analyze an issue and define clear verification gates for each success criterion.

## Expected Input

```
Define gates for Issue: <issue-identifier>
```

Examples:
- `issue-47-user-email-validation`
- `#47` (GitHub issue number)

## Process

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

**For complex verification strategies**, spawn an Explore subagent:
```
Task tool:
  subagent_type: "Explore"
  prompt: |
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

**When splitting opportunity detected:**
1. Group related gates together
2. Identify dependencies between groups
3. Suggest specific sub-issues with clear boundaries
4. Explain benefits of splitting
5. Let human decide whether to proceed or re-plan

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

**Reasoning:**
- SIMPLE lets you see the full commit sequence upfront
- COMPLEX means learnings from one task will inform next task planning
- When in doubt, prefer COMPLEX (safer, allows adjustment)

### Step 5: Estimate Tasks

Provide rough task breakdown estimate:
- Each task = one commit
- Commit size: 50-200 lines, 1-5 files touched
- Group related gates into same task when appropriate
- Split large gates into multiple tasks if needed

This is an ESTIMATE only - actual task planning happens in `/wf-02-task-plan`

### Step 6: Present for Approval

Output the complete gates.md content for human review:
- All gates with verification strategies
- Complexity assessment with reasoning
- Task estimate
- Splitting recommendations (if applicable)

Wait for human approval or requested changes before creating file.

## Gates.md Format

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

## Examples

### Example 1: Simple Issue (Test-based)

```markdown
# Verification Gates for Issue #47: User Email Validation

## Gate 1: Email validation enforced on save
**From criteria:** "Email validated on save"
**Verification type:** Test-based
**Strategy:** Extend tests/models/user.test.ts with validation test cases
**Specifics:**
- Test valid email formats accepted (user@domain.com, user+tag@domain.co.uk)
- Test invalid email formats rejected (no @, no domain, multiple @)
- Test null values rejected
- Test empty string rejected
- Verify validation error thrown with correct error code

## Gate 2: Clear error messages returned
**From criteria:** "Clear error messages for validation failures"
**Verification type:** Test-based
**Strategy:** Error format assertions in same test file
**Specifics:**
- Test error message includes field name ("email")
- Test error message is user-friendly (not technical stack trace)
- Test error format matches API error spec

## Gate 3: Existing user flows unaffected
**From criteria:** "No regressions in user management"
**Verification type:** Test-based (existing tests)
**Strategy:** Run existing integration test suite
**Specifics:**
- Run: `npm test -- integration/users.test.ts`
- All 23 existing tests pass
- No new tests required (existing coverage sufficient)

---

## Complexity Assessment: SIMPLE

**Reasoning:**
- Single component (user model)
- Established validation pattern exists (see password validation)
- Clear implementation path
- All gates use same verification type (tests)
- Gates 1-2 are related (same test file, same feature)
- Gate 3 is regression check only

**Recommended approach:** Plan all tasks upfront

**Estimated tasks:** 2 tasks, 2 commits
- Task 1: Implement email validation (Gates 1, 2)
  - Add validation logic to user model
  - Write/extend tests
  - ~80 lines across 2 files
- Task 2: Verify no regressions (Gate 3)
  - Run integration suite
  - Document that existing tests pass
  - ~20 lines (documentation only)
```

### Example 2: Complex Issue (Mixed verification)

```markdown
# Verification Gates for Issue #52: Production RDS Instance

## Gate 1: RDS instance created with correct configuration
**From criteria:** "Production RDS instance with Postgres"
**Verification type:** Command-based
**Strategy:** Terraform plan/apply and AWS CLI verification
**Specifics:**
- Command: `terraform plan -out=plan.tfplan`
- Verify: Output shows aws_db_instance.prod creation with correct attributes
- Command: `terraform apply plan.tfplan`
- Expected: Exit 0, no errors
- Command: `aws rds describe-db-instances --db-instance-identifier=prod-db`
- Verify: Engine=postgres, DBInstanceClass=db.t3.medium, MultiAZ=true

## Gate 2: Security groups configured for internal-only access
**From criteria:** "Database accessible only from application tier"
**Verification type:** Mixed (command + manual)
**Strategy:** Terraform verification and security review
**Specifics:**
- Command: `terraform show -json | jq '.values.root_module.resources[] | select(.type=="aws_security_group_rule")'`
- Verify: Only ingress from application security group ID
- Verify: No 0.0.0.0/0 or ::/0 rules
- Manual: Security team reviews VPC architecture diagram
- Manual: Verify security group lives in private subnets

## Gate 3: Backup and monitoring configured
**From criteria:** "7-day backup retention and CloudWatch alarms"
**Verification type:** Command-based
**Strategy:** AWS CLI verification
**Specifics:**
- Command: `aws rds describe-db-instances --db-instance-identifier=prod-db --query 'DBInstances[0].BackupRetentionPeriod'`
- Expected: 7
- Command: `aws cloudwatch describe-alarms --alarm-names prod-db-cpu prod-db-storage`
- Verify: Both alarms exist and are enabled

## Gate 4: Connection string stored in secrets manager
**From criteria:** "Database credentials secured"
**Verification type:** Command-based
**Strategy:** Secrets Manager verification
**Specifics:**
- Command: `aws secretsmanager describe-secret --secret-id prod/db/connection`
- Verify: Secret exists
- Command: `aws secretsmanager get-secret-value --secret-id prod/db/connection`
- Verify: Connection string format correct, contains all required fields

---

## Complexity Assessment: COMPLEX

**Reasoning:**
- Multiple infrastructure components (RDS, security groups, monitoring, secrets)
- Mixed verification types (commands, manual security review)
- High blast radius (production database)
- Uncertainty about existing VPC configuration
- Security review required (may need design phase)
- Each gate may reveal information needed for next gate

**Recommended approach:** Plan tasks iteratively

**First task suggestion:** Investigate existing VPC and security setup (Gate 2 dependency)
**Reasoning:** Need to understand current networking before planning RDS creation. May reveal constraints that affect Gate 1 implementation.

After investigation, suggested sequence:
- Task 1: Create RDS instance (Gate 1)
- Task 2: Configure security groups (Gate 2) - may need design
- Task 3: Setup monitoring (Gate 3)
- Task 4: Create secrets (Gate 4)
```

### Example 3: Splitting Recommendation

```markdown
# Verification Gates for Issue #60: Authentication System

## Gate 1: User table and session table created
[details...]

## Gate 2: Migration scripts for auth tables
[details...]

## Gate 3: Login endpoint implemented
[details...]

## Gate 4: Logout endpoint implemented
[details...]

## Gate 5: Session middleware created
[details...]

## Gate 6: Login UI component
[details...]

## Gate 7: Session state management in frontend
[details...]

## Gate 8: Permission middleware
[details...]

## Gate 9: Role-based access checks
[details...]

---

## Splitting Opportunity Detected

**Pattern:** Multiple independent features bundled together

**Observation:**
- Four distinct functional areas identified
- Database schema is prerequisite, but API/Frontend/Permissions are independent
- Each area forms coherent unit with its own test strategy
- Frontend work can proceed in parallel with permissions once API exists
- Splitting enables:
  - Parallel development across teams
  - Earlier delivery of partial functionality
  - Clearer commit history and easier rollback
  - Smaller, more focused code reviews

**Gate grouping:**
- Group A (Gates 1-2): Database schema and migrations
- Group B (Gates 3-5): Backend API and session management
- Group C (Gates 6-7): Frontend authentication UI
- Group D (Gates 8-9): Authorization and permissions

**Suggested split:**
- Issue #60a: Auth database schema (Gates 1-2) [prerequisite]
  - 2-3 commits, foundational work
- Issue #60b: Login/logout API (Gates 3-5) [requires 60a]
  - 3-4 commits, backend functionality
- Issue #60c: Frontend auth UI (Gates 6-7) [requires 60b]
  - 2-3 commits, can be parallel with 60d
- Issue #60d: Authorization middleware (Gates 8-9) [requires 60b]
  - 2-3 commits, can be parallel with 60c

**Recommendation:** STOP and re-plan with smaller issues

---
Human decision required: Proceed with current scope or split?
```

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
- Present proposal, wait for approval before creating gates.md

## When Complete

After human approves, create `.agents/tasks/<issue-identifier>/gates.md`

Then report:

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

$ARGUMENTS
