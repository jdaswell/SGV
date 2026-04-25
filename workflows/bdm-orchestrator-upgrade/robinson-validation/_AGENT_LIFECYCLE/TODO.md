# Agent TODO — LIFECYCLE | Robinson v. CleanBlast

---

## Status

| Field | Value |
|---|---|
| Last dispatched | [TBD] |
| Last completed task | [TBD] |
| Blocking on | [TBD — None / describe] |
| Next scheduled dispatch | [TBD] |

---

## Queue — Active Tasks

- [ ] **Confirm and log statute of limitations date**
  - Context: Calculate from DOI. Louisiana general SOL for personal injury is 1 year from date of injury (La. C.C. art. 3492). Confirm no interruption/suspension applies.
  - Output expected: SOL date logged in Notes & Decisions; 90/60/30-day warning dates set
  - Deadline: ASAP
  - Blocked on: [TBD — DOI must be entered in CONTEXT.md first]

- [ ] **Document the "under protest" designation**
  - Context: Case is flagged "under protest." Record what the protest governs, who designated it, and what it restricts.
  - Output expected: Standing instruction updated in CONTEXT.md with full protest context
  - Deadline: Before next phase transition
  - Blocked on: @[owner] — confirm what the protest designation covers

- [ ] **Confirm current case phase and last phase-change date**
  - Context: CONTEXT.md shows phase as TBD. Verify current status and log.
  - Output expected: Phase field updated in CONTEXT.md; phase-change date logged
  - Deadline: Before next dispatch
  - Blocked on: None

- [ ] **Identify next hard deadline (hearing, response, or discovery cutoff)**
  - Context: Surface any upcoming court-ordered or agreed deadline that requires calendar entry.
  - Output expected: Deadline logged and handed off to `_AGENT_M365` for calendar entry
  - Deadline: [TBD]
  - Blocked on: None

---

## Queue — Waiting on Human (@owner items)

- [ ] @[owner] — Provide DOI so SOL date can be calculated — needed ASAP
- [ ] @[owner] — Confirm what "under protest" governs in this case

---

## Queue — Pending Handoff

- [ ] Hand off to `_AGENT_M365`: calendar entry for next hard deadline once identified

---

## Done

*(empty — initial backfill)*

---

## Notes & Decisions

- [TBD — log phase transitions and SOL warnings here as they occur]

---

## Last Updated

| Field | Value |
|---|---|
| Updated by | Initial backfill |
| Date | 2026-04-25 |
