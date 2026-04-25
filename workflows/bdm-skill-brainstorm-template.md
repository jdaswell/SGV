# BDM Skill Construction — Brainstorm & Plan Template
**Legal-Tech Agent Build | Superpowers Framework (Selective Adoption)**
Lafayette, Louisiana | Louisiana Jurisdiction

*Version 1.0 — Apply to new skill/agent construction only; not case execution workflows*

---

## Purpose

This template guides the pre-build planning phase for new BDM orchestrator skills and sub-agents. It enforces clarity on scope, edge cases, and acceptance criteria *before* any skill body is written. Apply to high-risk builds (Prescription Sentinel tier) and high-complexity builds (Demand Package Agent tier). Skip for mature, already-deployed case execution skills.

---

## How to Use

Complete **all sections** in order. Do not begin writing the skill body (`SKILL.md` or skill logic) until Sections 1–5 are finished. For high-risk skills, a human review of Section 4 (edge cases + acceptance criteria) is required before proceeding.

---

## Section 1 — Brainstorm (9-Step)

### 1. What problem does this skill solve?
*(One sentence. If you can't write one sentence, the scope is not defined yet.)*

- [ ] Problem statement written: ___________________________________________

### 2. Who triggers this skill, and when?
*(Describe the triggering condition precisely. Trigger-only descriptions — no task narration.)*

- [ ] Trigger condition: ___________________________________________
- [ ] Trigger is a discrete event, not a process stage: Yes / No

### 3. What does success look like to the attorney or coordinator?
*(Describe the output they receive, not the internal steps.)*

- [ ] Success output: ___________________________________________

### 4. What data/files does this skill read?
*(List every input source: case file path, external DB, MCP tool, etc.)*

| Input | Source | Format | Required? |
|---|---|---|---|
| | | | |

### 5. What does this skill write or mutate?
*(List every output: files created/updated, logs written, downstream agents triggered.)*

| Output | Destination | Format | Notes |
|---|---|---|---|
| | | | |

### 6. What are the Louisiana-specific legal constraints?
*(Cite the specific statute, rule, or deadline. Vague entries are not acceptable.)*

- [ ] Relevant statutes/rules listed:
  - ___________________________________________
  - ___________________________________________
- [ ] Prescription periods identified (if applicable): ___________________________________________
- [ ] Jurisdiction-specific filing requirements noted: ___________________________________________

### 7. What are the case-file integrity requirements?
*(What must be true about the case record before and after this skill runs?)*

- [ ] Pre-conditions (file state before execution):
  - ___________________________________________
- [ ] Post-conditions (file state after execution):
  - ___________________________________________
- [ ] Immutable fields (must never be overwritten): ___________________________________________

### 8. What could go wrong? (Risk enumeration)
*(At least 3 failure modes. For Prescription Sentinel tier: at least 5.)*

| # | Failure Mode | Severity (High/Med/Low) | Mitigation |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

### 9. What adjacent skills or agents does this interact with?
*(Map dependencies. Circular dependencies are a build blocker.)*

- [ ] Upstream skills (this skill depends on): ___________________________________________
- [ ] Downstream skills (depend on this skill): ___________________________________________
- [ ] Circular dependencies: None confirmed / Identified (BLOCKER — resolve before proceeding)

---

## Section 2 — Structured Plan

### Skill Identity

| Field | Value |
|---|---|
| **Skill name** | |
| **Skill file path** | `/mnt/skills/user/` |
| **Skill tier** | High-Risk / High-Complexity / Standard |
| **Orchestrator priority** | (from build queue) |
| **Dependencies** | (other skills that must exist first) |

### Phases & Steps

*(Break the skill into discrete, testable phases. Each phase should produce a verifiable output.)*

| Phase | Description | Acceptance Signal |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |

### File & Path Map

*(List every file this skill touches, reads, or creates.)*

```
/mnt/user/cases/<case-id>/
├── (file read)          — purpose
├── (file written)       — purpose
└── (log entry)          — purpose
```

### Context Window Budget

*(Estimate tokens consumed. Flag if brainstorm overhead exceeds ~15% of available context for this skill's typical run.)*

- [ ] Estimated brainstorm + plan tokens: ___________________________________________
- [ ] Acceptable for case-execution context budget: Yes / No / Marginal

---

## Section 3 — Acceptance Criteria (TDD Anchor)

Write failing-test-first assertions. Each criterion must be falsifiable — vague criteria are rejected.

### Format: `GIVEN / WHEN / THEN`

**Criterion 1 — Happy path**
- GIVEN: ___________________________________________
- WHEN: ___________________________________________
- THEN: ___________________________________________

**Criterion 2 — Louisiana prescription deadline edge case**
- GIVEN: a case where the prescriptive period expires within ___ days
- WHEN: the skill runs
- THEN: ___________________________________________

**Criterion 3 — Missing or corrupt input file**
- GIVEN: a required input file is absent or malformed
- WHEN: the skill runs
- THEN: skill halts gracefully, logs error to `ORCHESTRATOR_LOG.md`, does NOT mutate case record

**Criterion 4 — Concurrent case execution (if applicable)**
- GIVEN: the orchestrator is running this skill across multiple cases simultaneously
- WHEN: ___________________________________________
- THEN: no case record cross-contamination; each log entry is case-scoped

**Criterion 5 — (High-risk tier only) Citation verification**
- GIVEN: the skill generates a legal citation or document reference
- WHEN: the output is produced
- THEN: citation format conforms to Louisiana courts' citation standards; unverifiable citations are flagged, not omitted silently

*(Add additional criteria as needed. Minimum: 3 for Standard, 5 for High-Risk.)*

---

## Section 4 — Two-Pass Review Checklist

Complete before writing any skill body code.

### Pass 1 — Spec Compliance
- [ ] Skill description is trigger-only (no task narration in description field)
- [ ] All Section 1 fields completed with no blank or placeholder entries
- [ ] Louisiana-specific constraints cited with statute/rule references
- [ ] Acceptance criteria are falsifiable (no vague "works correctly" language)
- [ ] Risk enumeration meets tier minimums
- [ ] No circular dependencies

### Pass 2 — Code Quality (run after skill body is written)
- [ ] Skill reads only the inputs declared in Section 2
- [ ] Skill writes only the outputs declared in Section 2
- [ ] Dual-log pattern confirmed: entry in `ORCHESTRATOR_LOG.md` AND `ORCHESTRATOR_INDEX.md`
- [ ] Graceful halt on missing inputs (does not silently continue)
- [ ] No hardcoded case IDs, paths, or attorney names
- [ ] Acceptance criteria tests written and failing before skill logic is added (TDD)

---

## Section 5 — Gate Decision

| Gate | Status |
|---|---|
| Brainstorm (Section 1) complete | Pending / Pass / Fail |
| Plan (Section 2) complete | Pending / Pass / Fail |
| Acceptance criteria (Section 3) written | Pending / Pass / Fail |
| Pass 1 review (Section 4) complete | Pending / Pass / Fail |
| **CLEARED TO BUILD** | Yes / No |

> **Approval gate applies to new skill construction only.** Case execution workflows (`bdm-case-open`, `bdm-med-records`, intake processing) bypass this gate entirely and run autonomously with end-of-workflow reporting.

---

## Appendix — Louisiana Jurisdiction Reference

Quick-reference items for acceptance criteria and constraint fields. Update as statutes change.

| Area | Rule / Statute | Key Deadline |
|---|---|---|
| Personal injury prescription | La. C.C. Art. 3492 | 1 year from injury/discovery |
| Medical malpractice prescription | La. R.S. 9:5628 | 1 year from act; 3-year peremptive |
| Wrongful death / survival | La. C.C. Art. 2315.1–2315.2 | 1 year from death |
| Workers' comp prescription | La. R.S. 23:1209 | 1 year from accident or last payment |
| FMLA/discrimination (federal overlay) | 29 C.F.R. § 825 | 2 years (3 if willful) |
| UM/UIM claims | La. R.S. 22:1295 | Follows underlying tort prescription |

*(Add entries as new practice areas are onboarded.)*

---

*Version 1.0 — Last updated: 2026-04-25*
*Apply to: Demand Package Agent, Prescription Sentinel, and all future high-tier skill builds*
*Do not apply to: deployed case execution skills (`bdm-case-open`, `bdm-med-records`, intake processing)*
