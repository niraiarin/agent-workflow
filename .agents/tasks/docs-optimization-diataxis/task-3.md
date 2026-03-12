# Task 3: Regen Script & Final Verification

**Issue:** docs-optimization-diataxis
**Branch:** feature/docs-optimization-diataxis
**Completes:** Gates 006, 007

## Objective
Create/validate regen.sh for SSOT → agent files, smoke test skills.

## Implementation Steps
- [ ] Write docs/regen.sh: lint MD, gen agent files (prompt template)
- [ ] Add validation: dupe check, length, parse
- [ ] Run: ./regen.sh --validate
- [ ] Smoke test /wf-workflow in agent dirs
- [ ] Document in MAINT.md

## Completion Gate

From gates.md:
- [ ] Gate 006: regen.sh exits 0, consistent
- [ ] Gate 007: Agent skills parse/execute OK
- [ ] No regressions: Existing regen works
- [ ] Single commit (~100L, 3 files)

## Commit Message Template
docs(tools): add regen.sh for docs SSOT validation

- Validates dupe/length/lint
- Smoke tests agent skills
- MAINT.md updated

Completes: Gates 006-007 of docs-optimization-diataxis

## Implementation Notes
**Direction changes:**
**Discoveries:**
**For next task:**