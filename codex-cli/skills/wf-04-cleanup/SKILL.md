---
description: 04 Cleanup - Three-phase review before PR (audit, fix, validate gates)
---


## PRECONDITIONS (MANDATORY)

Before doing anything else:

**Branch Check:**
1. Run: `git branch --show-current`
2. If on main/master: STOP "Cannot cleanup main/master branch"
3. Capture branch name

**Issue Check:**
1. Verify issue folder exists: `.agents/tasks/<issue-identifier>/`
2. Verify gates.md exists in issue folder
3. If missing: STOP and report error

**Task Completion Check:**
1. List all task-N.md files (exclude task-cleanup.md)
2. For each task:
   - Read Completion Gate section
   - Verify ALL checkboxes are checked (`- [x]`)
3. If ANY task incomplete: STOP "Task N is incomplete. Complete before cleanup."

**Gates Check:**
1. Read gates.md
2. Count total gates defined
3. Prepare for Phase 3 verification

You are a cleanup specialist. Your job is to audit a branch for quality issues, fix approved items, and validate all gates before PR.

## Expected Input

```
Review changes for Issue: <issue-identifier>
```

Examples:
- `issue-47-user-email-validation`
- `#47`

## Three-Phase Process

### Phase 1: Audit

**What to audit:**

Run comprehensive review of all changes in the branch:
```bash
git diff main...<branch-name>
```

Create numbered audit list of issues found:

1. **Temporary comments**
   - `// TODO`, `// FIXME`, `// HACK` (unless tracked)
   - `// testing`, `// debug`, `// temporary`
   - Commented-out code blocks

2. **Debug artifacts**
   - Console.log, print statements
   - Debug flags or environment checks
   - Temporary test data
   - Leftover breakpoints

3. **Code quality**
   - Inconsistent naming
   - Magic numbers without explanation
   - Copy-paste duplication
   - Overly complex functions (>50 lines)
   - Missing error handling

4. **Documentation**
   - Outdated comments
   - Missing JSDoc/docstrings for public APIs
   - README updates needed
   - Changelog entries needed

5. **Testing**
   - Test descriptions unclear
   - Redundant test cases
   - Tests testing implementation instead of behavior
   - Missing edge case coverage

6. **Dependencies**
   - Unused imports
   - Deprecated API usage
   - Version mismatches

7. **Architectural decisions**
   - New abstractions or patterns introduced without ADR
   - Deviations from established codebase patterns
   - Technology choices that should be documented

**Output format:**

```markdown
# Cleanup Audit for Issue <issue-identifier>

Branch: <branch-name>
Files changed: N files, +XXX -YYY lines

## Audit Results

### Critical Issues (must fix)
1. user.ts:45 - console.log left in production code
2. user.test.ts:89 - commented-out test case

### Quality Issues (recommended)
3. user.ts:23 - magic number 256 (should be EMAIL_MAX_LENGTH constant)
4. user.ts:67 - function validateUser too long (78 lines, suggest split)
5. user.test.ts:12 - test description unclear "it works" 

### Documentation
6. README.md - add email validation section
7. user.ts:45 - JSDoc missing for validateEmail function

### Architectural Decisions
8. New UserPermissionResolver pattern introduced - consider ADR to document rationale

### No issues found
[If clean]

## Recommendation
Fix items: [list or "all" or "none needed"]
```

Present audit to human and WAIT for response.

### Phase 2: Fix

**Human will respond with what to fix:**
- "all" - fix everything
- "1,2,3" - fix specific items
- "all except 4,6" - fix most, skip some
- "none" - skip fixes, proceed to Phase 3

**For architectural decision items:**
If human approves creating an ADR:
- Note: "Create ADR for [item] after cleanup completes"
- Or human may say: "Create ADR now with `/adr <title>`"

**Fix approved items:**

For each item to fix:
1. Make the change
2. Mark item as fixed in task-cleanup.md
3. Record what was done

**Create task-cleanup.md:**

```markdown
# Cleanup Task for Issue <issue-identifier>

**Branch:** <branch-name>

## Approved Fixes
- [x] Item 1: Removed console.log from user.ts:45
- [x] Item 2: Uncommented test case (was actually needed)
- [x] Item 3: Extracted EMAIL_MAX_LENGTH constant
- [ ] Item 4: Skipped - function length acceptable for this case
- [x] Item 5: Improved test description

## Architectural Decisions Noted
- Item 8: UserPermissionResolver pattern - ADR to be created post-merge

## Changes Made
- Modified: src/models/user.ts (12 lines)
  - Removed debug logging
  - Extracted magic number to constant
- Modified: tests/models/user.test.ts (3 lines)
  - Uncommented edge case test
  - Clarified test description

## Commit Message
chore(user): code cleanup before PR

- Remove debug logging
- Extract EMAIL_MAX_LENGTH constant  
- Improve test descriptions
- Uncomment needed edge case test

Relates to: #47 (cleanup phase)
```

After fixes complete, report:
```
Phase 2 complete: N items fixed

Changes:
  - Modified: [files]
  
Ready for Phase 3 (gate validation)
Proceed? [Wait for human approval]
```

### Phase 3: Validate All Gates

**Re-verify EVERY gate from gates.md:**

This is the final checkpoint - confirm all gates still pass after cleanup fixes.

1. Read gates.md
2. For EACH gate defined:
   - Run the verification specified
   - Record result
   - Check off if passes: `- [ ]` to `- [x]`
   - STOP if fails

**Add gate validation section to task-cleanup.md:**

```markdown
## Gate Validation (Phase 3)

All gates re-verified after cleanup:

### Gate 1: Email validation enforced
- [x] Tests pass: npm test -- user.test.ts (15 tests, all pass)

### Gate 2: Error messages clear
- [x] Error format tests pass (verified in test output)

### Gate 3: No regressions
- [x] Integration tests pass: npm test -- integration/users.test.ts (23 tests)

### Full test suite
- [x] npm test (142 tests, all pass, no warnings)

## Final Status
All gates verified: [3/3]
Issue #47 complete and ready for PR
```

**If ANY gate fails:**
```
STOP: Gate X failed during final validation

Gate X: [description]
Verification: [command]
Expected: [expected result]
Actual: [actual result]

This gate passed in task implementation but fails now.
Possible causes:
- Cleanup changes broke something
- Flaky test
- Environment issue

Recommend:
1. Investigate what changed
2. Fix the issue
3. Re-run Phase 3 validation

Do not proceed to PR until all gates pass.
```

**When all gates pass:**

Paid AI (Claude Code/Bob) commits cleanup changes and creates PR:

```bash
# Commit cleanup changes
git add -A
git commit -m "[use message from task-cleanup.md]"

# Push and create PR
git push origin <branch>
gh pr create --title "[PR title]" --body "[PR body following .github/pull_request_template.md, include gate verification results]"
```

Present final summary:
```
=== CLEANUP COMPLETE ===

Issue: <issue-identifier>
Branch: <branch-name>

Phase 1: Audit completed (N items found)
Phase 2: Fixes applied (M items fixed)
Phase 3: All gates verified [X/X]

Files changed: N files, +XXX -YYY lines
Commits: N commits

Gate verification:
[x] Gate 1: [description]
[x] Gate 2: [description]
[x] Gate 3: [description]

Committed and PR created:
  Commit: chore(<scope>): code cleanup before PR
  PR: #<PR番号> - <PR title>

Human next steps:
1. Review PR: <PR URL>
2. Merge or Close (human has final Merge authority)

Post-merge actions (if any):
- Create ADR for: [any noted architectural decisions]
```

## Gate ID Consistency Check

Verify the following consistency:

1. **Gate IDs in gates.md:**
   - Format: `G-<issue>-<seq>`
   - Sequence number continuity (gaps are acceptable)
   - No duplicates

2. **Consistency with test-cases.md:**
   - Test IDs exist for Test-based Gates
   - Test ID format: `TC-<issue>-<gate-seq>-<test-seq>`
   - "Test Cases" column in gates.md matches test-cases.md content

3. **Traceability:**
   - Issue → Gate ID → Test ID → Task → Commit traceability
   - Tasks exist for each Gate ID

## Rules

- ALWAYS complete all three phases in order
- DO NOT skip Phase 3 gate validation
- If ANY gate fails in Phase 3: STOP, fix, re-validate
- **Commit cleanup changes and create PR autonomously** after all gates pass (vibe-local's responsibility)
- DO NOT merge the PR (human has final Merge authority)
- DO NOT proceed to PR if gates fail
- Record all work in task-cleanup.md
- If stuck, use `/wf-summarise` and fresh session
- Note undocumented architectural decisions for potential ADR

## Example Interaction

```bash
Input: Review changes for issue-47-user-email-validation

[Check preconditions]
Branch: feature/user-email-validation (OK)
Gates file: exists (OK)
Tasks: task-1.md [x] complete, task-2.md [x] complete (OK)

[Phase 1: Audit]
Running git diff main...feature/user-email-validation

Audit findings:
---
# Cleanup Audit for Issue #47

Branch: feature/user-email-validation
Files changed: 2 files, +112 -34 lines

## Audit Results

### Critical Issues
1. user.ts:67 - console.log('validating email:', email) left in code

### Quality Issues  
2. user.ts:89 - magic number 256 (email max length)
3. user.test.ts:45 - test description "test 1" is unclear

### Documentation
4. user.ts:55 - validateEmail function missing JSDoc

### Good findings
- No commented-out code
- No temporary TODOs
- Error handling consistent
- Test coverage comprehensive
---

Waiting for human decision: which items to fix?

[Human responds: "all"]

[Phase 2: Fix]
Fixing all 4 items...

Created task-cleanup.md:
---
# Cleanup Task for Issue #47

**Branch:** feature/user-email-validation

## Approved Fixes
- [x] Item 1: Removed console.log from user.ts:67
- [x] Item 2: Extracted EMAIL_MAX_LENGTH constant (value: 256)
- [x] Item 3: Improved test description to "rejects email exceeding max length"
- [x] Item 4: Added JSDoc to validateEmail function

## Changes Made
- Modified: src/models/user.ts (8 lines)
  - Removed debug console.log
  - Extracted EMAIL_MAX_LENGTH = 256 constant
  - Added JSDoc documentation
- Modified: tests/models/user.test.ts (2 lines)
  - Improved test description

## Commit Message
chore(user): code cleanup before PR

- Remove debug console.log
- Extract EMAIL_MAX_LENGTH constant
- Add JSDoc for validateEmail
- Clarify test descriptions

Relates to: #47 (cleanup phase)
---

Phase 2 complete: 4 items fixed
Changes: 2 files modified
Ready for Phase 3 (gate validation)

[Human approves]

[Phase 3: Validate All Gates]
Re-verifying all gates from gates.md...

Gate 1: Email validation enforced
  Command: npm test -- user.test.ts
  Result: 15 tests, all pass [check]

Gate 2: Error messages clear  
  Verification: Error format in tests
  Result: Verified [check]

Gate 3: No regressions
  Command: npm test -- integration/users.test.ts
  Result: 23 tests, all pass [check]

Full test suite:
  Command: npm test
  Result: 142 tests, all pass, no warnings [check]

Updated task-cleanup.md with gate validation results.

=== CLEANUP COMPLETE ===

Issue: #47 - User Email Validation
Branch: feature/user-email-validation

Phase 1: Audit completed (4 items found)
Phase 2: Fixes applied (4 items fixed)
Phase 3: All gates verified [3/3]

Files changed: 2 files, +120 -36 lines
Commits: 3 commits
- feat(user): enhance email validation
- test(user): verify no regressions  
- chore(user): code cleanup

Gate verification:
[x] Gate 1: Email validation enforced
[x] Gate 2: Error messages clear
[x] Gate 3: No regressions

This issue is complete and ready for PR.

Committed and PR created:
  Commit: chore(user): code cleanup before PR
  PR: #<PR番号> - chore(user): code cleanup before PR

Human next steps:
1. Review PR: <PR URL>
2. Merge or Close (human has final Merge authority)
```

$ARGUMENTS
