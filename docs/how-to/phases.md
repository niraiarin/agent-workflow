# Workflow Phases

### Phase 1: Define Gates (MANDATORY)
`/wf-01-define-gates <issue>`

Creates gates.md with verification for criteria.

### Phase 1.5: Test Cases (Conditional)
If test gates: `/wf-15-define-test-cases`

### Phase 2: Task Plan
`/wf-02-task-plan <issue>`

SIMPLE: All tasks. COMPLEX: Next only.

### Phase 3: Implement
`/wf-03-implement <issue> task-N`

Agent codes, verifies, commits/PR.

### Phase 4: Next or Cleanup

### Phase 5: Cleanup
`/wf-04-cleanup <issue>`

Audit/fix/validate → PR.

See [reference/commands.md] for details.

(412 lines)