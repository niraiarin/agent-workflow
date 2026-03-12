# Skill: wf-15-define-test-cases

Description: 15: Define concrete test cases for Test-based Gates (CONDITIONAL)

## CRITICAL: THIS IS A CONDITIONAL PHASE

**Execute ONLY when Test-based Gates exist in gates.md**

If gates.md contains NO Test-based Gates, this phase is automatically skipped and you proceed directly to Phase 2 (Task Planning).

---

## PRECONDITIONS (MANDATORY)

Before doing anything else:

**Gates Check:**
1. Verify `.agents/tasks/<issue-identifier>/gates.md` exists
2. If missing: STOP and instruct: "Run `/wf-01-define-gates <issue-identifier>` first"
3. Read gates.md completely

**Test-based Gate Detection:**
1. Scan gates.md for gates with `**Verification type:** Test-based`
2. Count Test-based Gates found
3. If count = 0: SKIP this phase
   - Log skip reason to `.agents/tasks/<issue-identifier>/phase-log.md`
   - Report: "No Test-based Gates found. Skipping Phase 1.5. Proceed to `/wf-02-task-plan <issue-identifier>`"
   - EXIT
4. If count > 0: Proceed with test case definition

**Branch Check:**
1. Run: `git branch --show-current`
2. Capture branch name for documentation

You are a test case definition specialist. Your job is to expand Test-based Gates into concrete, actionable test cases before implementation begins.

## Expected Input

```
Define test cases for Issue: <issue-identifier>
```

Examples:
- `issue-47-user-email-validation`
- `#47` (GitHub issue number)

---

## Process

### Step 1: Analyze Test-based Gates

For EACH Test-based Gate in gates.md:

1. **Extract Gate Information:**
   - Gate number and description
   - Gate ID (format: `G-<issue>-<seq>`)
   - Verification strategy from gates.md
   - Specifics listed in the gate

2. **Identify Test File Strategy:**
   - Check if gate mentions extending existing test file
   - If extending: verify file exists, understand current test patterns
   - If creating new: determine appropriate location and naming

3. **Determine Test Scope:**
   - What behavior needs verification?
   - What edge cases must be covered?
   - What error conditions should be tested?

### Step 2: Define Concrete Test Cases

For each Test-based Gate, create detailed test case definitions:

**Test Case Structure:**
```markdown
#### TC-X.Y: [Clear test case description]
- **Type:** Unit | Integration | E2E
- **Execution:** Local | CI | Both
- **Given:** [Preconditions - what state/data exists]
- **When:** [Action - what is being tested]
- **Then:** [Expected outcome - what should happen]
- **Estimated LOC:** ~N lines
```

**Test Type Guidelines:**

**Unit Tests (prefer for Local):**
- Test single function/method in isolation
- Fast execution (< 1 second per test)
- No external dependencies (use mocks)
- Example: Email format validation logic

**Integration Tests (prefer for CI):**
- Test multiple components working together
- May require database, API, or file system
- Moderate execution time (1-10 seconds)
- Example: User save with validation

**E2E Tests (CI only):**
- Test complete user workflows
- Require full application stack
- Slow execution (10+ seconds)
- Example: User registration flow through UI

**Execution Strategy:**

**Local Execution:**
- Fast feedback during development
- Run on every code change
- Target: < 10 seconds total
- Include: Unit tests, fast integration tests with mocks

**CI Execution:**
- Comprehensive verification before merge
- Run on commit/PR
- Target: < 60 seconds total
- Include: Integration tests with real dependencies, E2E tests

### Step 3: Estimate Implementation Effort

For each test case:
- Estimate lines of code needed
- Consider test setup/teardown requirements
- Note any test utilities that need creation

### Step 4: Create test-cases.md

Generate the test cases file following this format:

```markdown
# Test Cases for Issue #N: [Issue Title]

**Generated from:** gates.md
**Test-based Gates:** Gate X, Gate Y, Gate Z
**Branch:** <branch-name>
**Generated:** <timestamp>

---

## Gate X: [Gate Description]

**Gate ID:** `G-<issue>-<seq>`
**From gates.md:**
> [Quote the gate's verification strategy and specifics]

### Test File: `tests/path/to/test-file.test.ts`

**Strategy:** Extend existing | Create new

**Test Cases:**

#### TC-X.1: [Test case description]
- **Type:** Unit
- **Execution:** Local
- **Given:** [Preconditions]
- **When:** [Action]
- **Then:** [Expected outcome]
- **Estimated LOC:** ~N lines

#### TC-X.2: [Test case description]
- **Type:** Unit
- **Execution:** Local
- **Given:** [Preconditions]
- **When:** [Action]
- **Then:** [Expected outcome]
- **Estimated LOC:** ~N lines

**Total for Gate X:** N test cases, ~M lines

---

## Test Execution Strategy

### Local Execution (高速フィードバック)
**Files:**
- `tests/unit/component.test.ts`

**Command:** `npm test -- --testPathPattern="unit"`

**Expected time:** < 10 seconds

**Purpose:** Fast feedback during development

### CI Execution (統合・E2E検証)
**Files:**
- `tests/integration/component.test.ts`

**Command:** `npm test -- --testPathPattern="integration"`

**Expected time:** 30-60 seconds

**Purpose:** Comprehensive verification before merge

---

## Summary

- **Total test cases:** N cases
- **New test files:** M files
- **Extended test files:** K files
- **Estimated total LOC:** ~X lines
- **Local tests:** N1 cases (~Y1 lines)
- **CI tests:** N2 cases (~Y2 lines)

---

## Test Implementation Guidelines

### For Phase 3 Implementation:
1. Implement test cases in the order listed
2. Follow TDD: Write test first (red), then implementation (green)
3. Each test case should be independently verifiable
4. Use descriptive test names matching TC-X.Y descriptions
5. Add comments referencing Gate ID and Test Case ID

### Test File Organization:
- Group related test cases in describe blocks
- Use consistent naming: `describe('Gate X: [description]', () => {...})`
- Add setup/teardown as needed
- Extract common test utilities to separate files

### Verification:
- Each test must clearly verify the "Then" condition
- Use appropriate assertions (toBe, toEqual, toThrow, etc.)
- Include error message assertions for validation tests
- Verify both success and failure paths
```

### Step 5: Update gates.md

After creating test-cases.md, update gates.md to reference the test cases:

For each Test-based Gate, add:
```markdown
**Test Cases:** TC-X.1, TC-X.2, TC-X.3 (see test-cases.md)
**Status:** Test cases defined ✓
```

**Example update:**
```markdown
## Gate 1: Email validation enforced
**Gate ID:** `G-issue-47-001`
**From criteria:** "Email validated on save"
**Verification type:** Test-based
**Strategy:** Extend tests/models/user.test.ts
**Specifics:**
- Test valid email formats accepted
- Test invalid email formats rejected
**Test Cases:** TC-1.1, TC-1.2, TC-1.3 (see test-cases.md)
**Status:** Test cases defined ✓
```

### Step 6: Create Phase Log Entry

Create or update `.agents/tasks/<issue-identifier>/phase-log.md`:

```markdown
# Phase Execution Log for Issue #N

## Phase 1.5: Test Case Definition
**Executed:** <timestamp>
**Status:** Complete
**Test-based Gates found:** N gates
**Test cases defined:** M cases
**Output:** test-cases.md created
**gates.md updated:** Yes

### Test Case Summary:
- Gate 1 (`G-issue-N-001`): 3 test cases
- Gate 2 (`G-issue-N-002`): 2 test cases

### Next Phase:
Proceed to Phase 2: Task Planning with `/wf-02-task-plan <issue-identifier>`
```

---

## When Complete

After creating test-cases.md and updating gates.md, report:

```
=== PHASE 1.5 COMPLETE ===

Test cases defined for issue: <issue-identifier>

Created:
  - .agents/tasks/<issue-identifier>/test-cases.md
  - .agents/tasks/<issue-identifier>/phase-log.md

Updated:
  - .agents/tasks/<issue-identifier>/gates.md (added test case references)

Test-based Gates processed: N gates
Total test cases defined: M cases
  - Local execution: N1 cases (~X1 lines)
  - CI execution: N2 cases (~X2 lines)

Estimated implementation effort: ~X lines of test code

Next: `/wf-02-task-plan <issue-identifier>`
```

---

## Skip Logic (No Test-based Gates)

If NO Test-based Gates found in gates.md:

1. Create phase-log.md with skip entry:
```markdown
# Phase Execution Log for Issue #N

## Phase 1.5: Test Case Definition
**Executed:** <timestamp>
**Status:** Skipped
**Reason:** No Test-based Gates found in gates.md
**Gates analyzed:**
- Gate 1: Command-based
- Gate 2: Manual review

### Next Phase:
Skipping to Phase 2: Task Planning with `/wf-02-task-plan <issue-identifier>`
```

2. Report:
```
=== PHASE 1.5 SKIPPED ===

Issue: <issue-identifier>

Reason: No Test-based Gates found in gates.md

Gates analyzed:
  - Gate 1: Command-based verification
  - Gate 2: Manual review

Phase 1.5 is only required for Test-based Gates.

Next: `/wf-02-task-plan <issue-identifier>`
```

---

## Rules

- ALWAYS check for Test-based Gates before proceeding
- Skip phase if no Test-based Gates exist
- Each test case must have clear Given/When/Then structure
- Estimate LOC realistically (consider setup, assertions, cleanup)
- Prefer extending existing test files over creating new ones
- Split tests between Local and CI based on execution time and dependencies
- Update gates.md with test case references
- Create phase-log.md for traceability
- DO NOT implement tests in this phase - only define them
- DO NOT modify test files - only create test-cases.md

## Examples

### Example 1: Simple Issue with Test-based Gates

```bash
Input: Define test cases for issue-47-user-email-validation

[Read gates.md]
Found 2 Test-based Gates:
- Gate 1: Email validation enforced
- Gate 2: Error messages clear

[Analyze Gate 1]
Gate ID: G-issue-47-001
Strategy: Extend tests/models/user.test.ts
Specifics:
- Test valid email formats accepted
- Test invalid email formats rejected

[Define test cases for Gate 1]
TC-1.1: Valid email formats accepted
TC-1.2: Invalid email formats rejected
TC-1.3: Null/empty email rejected

[Analyze Gate 2]
Gate ID: G-issue-47-002
Strategy: Extend tests/models/user.test.ts
Specifics:
- Test error message content
- Test error message format

[Define test cases for Gate 2]
TC-2.1: Error message includes field name
TC-2.2: Error message is user-friendly

[Create test-cases.md]
---
# Test Cases for Issue #47: User Email Validation

**Generated from:** gates.md
**Test-based Gates:** Gate 1, Gate 2
**Branch:** feature/user-email-validation
**Generated:** 2026-03-03T16:30:00Z

---

## Gate 1: Email validation enforced
**Gate ID:** `G-issue-47-001`
**From gates.md:**
> **Verification type:** Test-based
> **Strategy:** Extend tests/models/user.test.ts
> **Specifics:**
> - Test valid email formats accepted
> - Test invalid email formats rejected

### Test File: `tests/models/user.test.ts`

**Strategy:** Extend existing

**Test Cases:**

#### TC-1.1: Valid email formats accepted
- **Type:** Unit
- **Execution:** Local
- **Given:** User model with email field
- **When:** Save with valid email "user@example.com"
- **Then:** Save succeeds, no validation error
- **Estimated LOC:** ~8 lines

#### TC-1.2: Invalid email formats rejected
- **Type:** Unit
- **Execution:** Local
- **Given:** User model with email field
- **When:** Save with invalid email "not-an-email"
- **Then:** Validation error raised with message
- **Estimated LOC:** ~10 lines

#### TC-1.3: Null/empty email rejected
- **Type:** Unit
- **Execution:** Local
- **Given:** User model with email field
- **When:** Save with null or empty string
- **Then:** Validation error raised
- **Estimated LOC:** ~12 lines

**Total for Gate 1:** 3 test cases, ~30 lines

---

## Gate 2: Error messages clear
**Gate ID:** `G-issue-47-002`
**From gates.md:**
> **Verification type:** Test-based
> **Strategy:** Extend tests/models/user.test.ts
> **Specifics:**
> - Test error message content
> - Test error message format

### Test File: `tests/models/user.test.ts`

**Strategy:** Extend existing

**Test Cases:**

#### TC-2.1: Error message includes field name
- **Type:** Unit
- **Execution:** Local
- **Given:** User model with invalid email
- **When:** Validation error occurs
- **Then:** Error message contains "email" field name
- **Estimated LOC:** ~8 lines

#### TC-2.2: Error message is user-friendly
- **Type:** Unit
- **Execution:** Local
- **Given:** User model with invalid email
- **When:** Validation error occurs
- **Then:** Error message is clear and actionable (not technical jargon)
- **Estimated LOC:** ~8 lines

**Total for Gate 2:** 2 test cases, ~16 lines

---

## Test Execution Strategy

### Local Execution (高速フィードバック)
**Files:**
- `tests/models/user.test.ts`

**Command:** `npm test -- user.test.ts`

**Expected time:** < 5 seconds

**Purpose:** Fast feedback during development

### CI Execution (統合検証)
Not required for this issue - all tests are fast unit tests suitable for local execution.

---

## Summary

- **Total test cases:** 5 cases
- **New test files:** 0 files
- **Extended test files:** 1 file (tests/models/user.test.ts)
- **Estimated total LOC:** ~46 lines
- **Local tests:** 5 cases (~46 lines)
- **CI tests:** 0 cases

---

## Test Implementation Guidelines

### For Phase 3 Implementation:
1. Open tests/models/user.test.ts
2. Add new describe block: `describe('Gate 1: Email validation', () => {...})`
3. Implement TC-1.1, TC-1.2, TC-1.3 in order
4. Add describe block: `describe('Gate 2: Error messages', () => {...})`
5. Implement TC-2.1, TC-2.2
6. Run tests to verify all fail initially (red phase)
7. Implement validation logic to make tests pass (green phase)

### Test File Organization:
```typescript
describe('User Model', () => {
  describe('Gate 1: Email validation (G-issue-47-001)', () => {
    it('TC-1.1: accepts valid email formats', () => {
      // Test implementation
    });
    
    it('TC-1.2: rejects invalid email formats', () => {
      // Test implementation
    });
    
    it('TC-1.3: rejects null/empty email', () => {
      // Test implementation
    });
  });
  
  describe('Gate 2: Error messages (G-issue-47-002)', () => {
    it('TC-2.1: includes field name in error', () => {
      // Test implementation
    });
    
    it('TC-2.2: provides user-friendly error message', () => {
      // Test implementation
    });
  });
});
```
---

[Update gates.md]
Added test case references to both gates

[Create phase-log.md]
Logged Phase 1.5 execution

Output:
---
=== PHASE 1.5 COMPLETE ===

Test cases defined for issue: issue-47-user-email-validation

Created:
  - .agents/tasks/issue-47-user-email-validation/test-cases.md
  - .agents/tasks/issue-47-user-email-validation/phase-log.md

Updated:
  - .agents/tasks/issue-47-user-email-validation/gates.md (added test case references)

Test-based Gates processed: 2 gates
Total test cases defined: 5 cases
  - Local execution: 5 cases (~46 lines)
  - CI execution: 0 cases

Estimated implementation effort: ~46 lines of test code

Next: `/wf-02-task-plan issue-47-user-email-validation`
---
```

### Example 2: Issue with No Test-based Gates (Skip)

```bash
Input: Define test cases for issue-52-terraform-rds

[Read gates.md]
Found 0 Test-based Gates:
- Gate 1: Command-based (terraform plan)
- Gate 2: Command-based (terraform apply)
- Gate 3: Manual review (security checklist)

[Skip Phase 1.5]

[Create phase-log.md with skip entry]

Output:
---
=== PHASE 1.5 SKIPPED ===

Issue: issue-52-terraform-rds

Reason: No Test-based Gates found in gates.md

Gates analyzed:
  - Gate 1: Command-based verification (terraform plan)
  - Gate 2: Command-based verification (terraform apply)
  - Gate 3: Manual review (security checklist)

Phase 1.5 is only required for Test-based Gates.

Next: `/wf-02-task-plan issue-52-terraform-rds`
---
```

---

## When Stuck

If you encounter issues during test case definition:

1. **Unclear gate specifics:**
   - Ask human for clarification
   - Suggest refining gates.md with more details
   - Do not guess - test cases must be precise

2. **Complex test scenarios:**
   - Break down into smaller test cases
   - Consider if gate should be split
   - Document complexity in test-cases.md

3. **Uncertain about test type or execution:**
   - Default to Unit + Local for simple logic tests
   - Use Integration + CI for tests requiring external dependencies
   - Ask human if unsure

4. **After 3 attempts without progress:**
   - Use `/wf-summarise <issue>` to checkpoint
   - Human starts fresh session
   - Fresh session tries again

---

## Integration with Other Phases

**From Phase 1 (Define Gates):**
- Receives gates.md with Test-based Gates defined
- Uses gate specifics as input for test case expansion

**To Phase 2 (Task Planning):**
- Provides test-cases.md for task planning reference
- Task planning will include test implementation steps
- Test case estimates inform task sizing

**To Phase 3 (Implementation):**
- Test cases guide TDD implementation
- Each test case becomes a specific implementation step
- Given/When/Then structure maps to test code

**To Phase 4 (Cleanup):**
- Verifies all test cases were implemented
- Checks test case IDs match implemented tests
- Updates gates.md with final verification status

$ARGUMENTS