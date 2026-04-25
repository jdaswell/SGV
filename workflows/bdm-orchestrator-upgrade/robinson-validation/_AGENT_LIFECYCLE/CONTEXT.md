# Agent Context — LIFECYCLE | Robinson v. CleanBlast

---

## Case Identity

| Field | Value |
|---|---|
| Case Name | Robinson v. CleanBlast |
| File Number | [TBD] |
| Date of Injury (DOI) | [TBD — MM/DD/YYYY] |
| Date Opened | [TBD — MM/DD/YYYY] |
| Current Phase | [TBD — Pre-Lit / Litigation] |
| Flags | **under protest** |

---

## Agent Role & Scope

**Agent:** `_AGENT_LIFECYCLE/`
**Responsible for:**
- [ ] Monitor statute of limitations deadline and surface warnings at 90 / 60 / 30 days
- [ ] Track case phase transitions and trigger appropriate agent handoffs
- [ ] Maintain the master case timeline and milestone log
- [ ] Flag any court deadlines, scheduling orders, or discovery cutoffs

**Out of scope for this agent:**
- Drafting correspondence (→ `_AGENT_M365`)
- Managing discovery requests/responses (→ `_AGENT_DISCOVERY`)
- LexTrack entries and billing (→ `_AGENT_LKR`)

---

## Key Parties

| Role | Name | Contact | Notes |
|---|---|---|---|
| Client | Johnathan Robinson | [TBD] | |
| Defendant | CleanBlast | | |
| Defense Counsel | [TBD — Name / Firm] | [TBD — Email] | |
| Adjuster | [TBD — Name / Carrier] | [TBD — Email] | |
| Treating Provider | [TBD — Name / Facility] | [TBD — Fax] | |

---

## Agent-Specific Facts

| Item | Detail |
|---|---|
| Statute of Limitations date | [TBD — calculate from DOI] |
| SOL warning triggered | [TBD — Yes / No] |
| Last phase change | [TBD — date and from/to] |
| Next scheduled hearing / deadline | [TBD] |
| Court / venue | [TBD — if litigation] |

---

## Standing Instructions for This Agent

1. **"Under protest" flag** — This case has an "under protest" designation. Before any phase transition, confirm with human what the protest governs and whether it affects filing strategy. Do NOT auto-advance the phase without human sign-off.
2. Surface any SOL date within 90 days as an immediate escalation — do not queue it.
3. Log every phase transition in the Notes & Decisions section of TODO.md with a timestamp.

---

## Last Updated

| Field | Value |
|---|---|
| Updated by | [TBD — Name / Session ID] |
| Date | [TBD — MM/DD/YYYY] |
| Reason | Initial backfill |
