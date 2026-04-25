# Agent TODO — [AGENT_ROLE] | [CASE_NAME]

> **How to use this file:** This is the agent's execution surface.
> Tasks are worked top-to-bottom. Move completed items to the Done section.
> The orchestrator reads this file to determine what to run next.
> Tag items with `@owner` when human action is required before the agent can proceed.

---

## Status

| Field | Value |
|---|---|
| Last dispatched | [MM/DD/YYYY HH:MM] |
| Last completed task | [short description] |
| Blocking on | [None / describe blocker] |
| Next scheduled dispatch | [MM/DD/YYYY or "on trigger"] |

---

## Queue — Active Tasks

> Ordered by priority. Agent works these in sequence unless a task is blocked.

- [ ] **[Task title]**
  - Context: [one sentence]
  - Output expected: [document / email draft / log entry / decision]
  - Deadline: [date or "ASAP" or "none"]
  - Blocked on: [None / @owner to provide X]

- [ ] **[Task title]**
  - Context:
  - Output expected:
  - Deadline:
  - Blocked on:

- [ ] **[Task title]**
  - Context:
  - Output expected:
  - Deadline:
  - Blocked on:

---

## Queue — Waiting on Human (@owner items)

> These tasks cannot proceed until the tagged person completes the action.

- [ ] @[owner] — [Action needed] — needed by [date]
- [ ] @[owner] — [Action needed] — needed by [date]

---

## Queue — Pending Handoff

> Tasks that will be handed off to another agent when this agent's work is done.

- [ ] Hand off to `_AGENT_[ROLE]`: [description of what to pass and why]

---

## Done

> Move completed tasks here. Keep the log — it feeds the post-event debrief.

- [x] **[Completed task]** — completed [date] — output: [file name or "logged"]
- [x] **[Completed task]** — completed [date] — output: [file name or "logged"]

---

## Notes & Decisions

> Log any decisions made during execution that future agents or the orchestrator need to know.

- [Date] — [Decision or finding]
- [Date] — [Decision or finding]

---

## Last Updated

| Field | Value |
|---|---|
| Updated by | [Name / Agent / Session ID] |
| Date | [MM/DD/YYYY] |
