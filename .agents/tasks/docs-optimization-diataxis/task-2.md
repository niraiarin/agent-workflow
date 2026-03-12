# Task 2: Bilingual & Cross-References

**Issue:** docs-optimization-diataxis
**Branch:** feature/docs-optimization-diataxis
**Completes:** Gates 004, 005

## Objective
Add JP mirrors in docs/ja/, ensure bilingual consistency, add internal cross-links/anchors.

## Implementation Steps
- [ ] mkdir docs/ja/{tutorials,how-to,...}
- [ ] Copy EN files to ja/ and translate key sections (manual)
- [ ] Add anchors to headings (## heading {#anchor})
- [ ] Cross-links: [See how-to/gates.md] in relevant files
- [ ] Verify links (pandoc or manual)

## Completion Gate

From gates.md:
- [ ] Gate 004: Links/ToC navigable
- [ ] Gate 005: ja/ mirrors structure, parallel content
- [ ] No regressions: EN unchanged, grep works
- [ ] Single commit (~150L, 15 files)

## Commit Message Template
docs(docs): add bilingual JP mirrors & cross-refs

- docs/ja/ parallel to EN
- Internal links/anchors for navigation
- Spot-checked translations

Completes: Gates 004-005 of docs-optimization-diataxis

## Implementation Notes
**Direction changes:**
**Discoveries:**
**For next task:**