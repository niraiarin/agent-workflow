# Task 1: Diátaxis Structure & Content Migration

**Issue:** docs-optimization-diataxis
**Branch:** feature/docs-optimization-diataxis (main fallback)
**Completes:** Gates 001, 002, 003

## Objective
Create Diátaxis subdirs and migrate content from current long MDs to focused files, eliminating duplication and ensuring length &lt;500L/file.

## Implementation Steps
- [ ] Create subdirs: mkdir -p docs/{tutorials,how-to,reference,explanation}
- [ ] Split guide.md/methodology.md content to new files (e.g., how-to/gates.md, reference/commands.md)
- [ ] Remove duplicated sections (use grep/diff to identify)
- [ ] Trim to &lt;500L per file
- [ ] Add index.md in docs/ with ToC links to quadrants
- [ ] Verify: tree docs/, wc -l *.md

## Completion Gate

From gates.md:
- [ ] Gate 001: Dupe &lt;20% (grep check)
- [ ] Gate 002: No file &gt;500L (wc)
- [ ] Gate 003: Structure/tree matches Diátaxis (tree grep)
- [ ] No regressions: Existing docs content findable (grep key terms)
- [ ] Single commit (~200L, 10 files)

## Commit Message Template
docs(docs): restructure to Diátaxis framework

- Created tutorials/how-to/reference/explanation subdirs
- Migrated content, removed ~80% duplication
- All files &lt;500 lines, ToC added

Completes: Gates 001-003 of docs-optimization-diataxis

## Implementation Notes
**Direction changes:**
**Discoveries:**
**For next task:**