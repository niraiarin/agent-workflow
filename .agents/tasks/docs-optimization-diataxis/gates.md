# Verification Gates for Issue: docs-optimization-diataxis

## Gate 001: Duplicates removed (&lt;20% overlap)
**Gate ID:** G-docs-optimization-diataxis-001
**From criteria:** \"Duplicates removed: &lt;20% content overlap between files (grep/diff verify).\"

**Verification type:** Command-based
**Strategy:** Automated overlap detection
**Specifics:**
- Create phrase list from guide.md: `grep -o '\\b\\w{4,}\\b' docs/agentic-workflow-guide.md | sort | uniq -c | sort -rn | head -50 &gt; key-phrases.txt`
- Check: `grep -r -f key-phrases.txt docs/ --exclude-dir=ja | awk '{sum+=$1} END {print sum/NR}'` &lt; 0.2
- Diff: `diff --minimal docs/agentic-workflow-guide.md docs/methodology.md | grep -E '^>|^<' | wc -l` low

## Gate 002: Length optimized (No MD &gt;500 lines)
**Gate ID:** G-docs-optimization-diataxis-002
**From criteria:** \"Length optimized: No MD &gt;500 lines (wc -l).\"

**Verification type:** Command-based
**Strategy:** Line count validation
**Specifics:**
- Command: `find docs/ -name '*.md' ! -path 'docs/ja/*' -exec wc -l {} + | awk '$1 &gt; 500 {print $2}'`
- Expected: No output

## Gate 003: Diátaxis structure implemented
**Gate ID:** G-docs-optimization-diataxis-003
**From criteria:** \"Diátaxis structure: tutorials/how-to/reference/explanation subdirs with content migrated.\"

**Verification type:** Command-based + Manual review
**Strategy:** Directory tree + content checklist
**Specifics:**
- Command: `tree docs/ | grep -E 'tutorials|how-to|reference|explanation'`
- Expected: All 4 dirs exist, non-empty
- Manual: Checklist - content migrated from old files, no loss (grep key terms)

## Gate 004: Cross-references/ToC navigable
**Gate ID:** G-docs-optimization-diataxis-004
**From criteria:** \"Cross-refs/ToC: All sections navigable (markdown links/anchors).\"

**Verification type:** Manual review
**Strategy:** Navigation checklist
**Specifics:**
- Each file has ## headings with anchors
- Links between quadrants work (e.g., [See how-to/gates])
- Top-level ToC.md or index.md links all key sections
- No broken links (pandoc or linkcheck)

## Gate 005: Bilingual consistency
**Gate ID:** G-docs-optimization-diataxis-005
**From criteria:** \"Bilingual: EN masters + JP mirrors (manual/parallel).\"

**Verification type:** Manual review + Command
**Strategy:** Parallel check
**Specifics:**
- docs/ja/ mirrors docs/ structure
- JP files cover same headings (diff --ignore-case ja/en)
- Manual: Spot-check translations accurate/user-friendly

## Gate 006: Regen validation automated
**Gate ID:** G-docs-optimization-diataxis-006
**From criteria:** \"Regen validation: Script/checks for post-gen consistency.\"

**Verification type:** Command-based
**Strategy:** Script execution
**Specifics:**
- Command: `./docs/regen.sh --validate`
- Expected: Exit 0, \"All agent files consistent\"
- Covers YAML/TOML lint, length limits, content hash match

## Gate 007: Existing workflows unaffected
**Gate ID:** G-docs-optimization-diataxis-007
**From criteria:** \"Existing workflows unaffected: All agent skills parse/execute unchanged.\"

**Verification type:** Command-based
**Strategy:** Smoke test skills
**Specifics:**
- Run sample `/wf-workflow` in each agent dir
- Expected: No parse errors, expected output
- git diff agent dirs pre/post-regen = empty

---

## Complexity Assessment: SIMPLE

**Reasoning:**
- Docs-only changes, no code
- Command/manual gates, established patterns (SSOT from README)
- Gates sequential/natural (structure → content → bilingual → script → verify)
- Design doc provides clear path
- Low uncertainty

**Recommended approach:** Plan all tasks upfront

**Estimated tasks:** 3 tasks, 3 commits
- Task 1: Diátaxis dirs + migrate content (Gates 001-003)
- Task 2: Bilingual + cross-refs (Gates 004-005)
- Task 3: Regen script + final verify (Gates 006-007)