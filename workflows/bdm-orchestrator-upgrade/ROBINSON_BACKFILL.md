# Robinson v. CleanBlast — Agent Folder Backfill

> **Purpose:** Retrofit the Robinson case with the new agent folder pattern as the validation case.
> Complete this after the templates are deployed and SKILL.md is patched.
> Check off each item as you go — do not skip ahead.

---

## Pre-Flight

- [ ] `Deploy-AgentFolderTemplates.ps1` has been run successfully
- [ ] CONTEXT.md and TODO.md stubs replaced with real template content
- [ ] `bdm-orchestrator/SKILL.md` has been patched
- [ ] Claude Desktop has been restarted
- [ ] Robinson case folder is fully synced in OneDrive (no pending uploads)

---

## Step 1 — Create Agent Folders

Copy `AGENT_FOLDER_TEMPLATE\` four times into the Robinson case folder and rename:

```
Robinson v. CleanBlast/
├── _AGENT_LIFECYCLE/
├── _AGENT_DISCOVERY/
├── _AGENT_M365/
└── _AGENT_LKR/
```

Each folder should contain `CONTEXT.md`, `TODO.md`, and `HANDOFFS\`.

- [ ] `_AGENT_LIFECYCLE/` created with CONTEXT.md, TODO.md, HANDOFFS\
- [ ] `_AGENT_DISCOVERY/` created with CONTEXT.md, TODO.md, HANDOFFS\
- [ ] `_AGENT_M365/` created with CONTEXT.md, TODO.md, HANDOFFS\
- [ ] `_AGENT_LKR/` created with CONTEXT.md, TODO.md, HANDOFFS\

---

## Step 2 — Populate CONTEXT.md Files

### `_AGENT_LIFECYCLE/CONTEXT.md`

Fill in the Case Identity table with:

| Field | Value |
|---|---|
| Case Name | Robinson v. CleanBlast |
| Current Phase | [confirm: Pre-Lit / Litigation] |
| Flags | under protest |

Key facts for lifecycle agent:
- [ ] DOI entered
- [ ] File number entered
- [ ] Statute of limitations date calculated and entered
- [ ] Defense counsel name and firm entered
- [ ] Adjuster / carrier entered
- [ ] "Under protest" flag documented with reason in Standing Instructions

### `_AGENT_DISCOVERY/CONTEXT.md`

Key facts for discovery agent:
- [ ] Johnathan Robinson's outstanding discovery items listed in Agent-Specific Facts
- [ ] Prescription details (drug name, prescribing provider, dates) entered
- [ ] Any outstanding medical record requests noted
- [ ] Defense counsel contact for discovery correspondence entered

### `_AGENT_M365/CONTEXT.md`

Key facts for M365 agent:
- [ ] Chris Williams' email address entered in Key Parties table
- [ ] Chris Williams' role confirmed (defense counsel / adjuster / other)
- [ ] Any standing email instructions entered (CC requirements, tone flags)
- [ ] M365 mailbox access confirmed

### `_AGENT_LKR/CONTEXT.md`

Key facts for LKR agent:
- [ ] LexTrack matter number entered
- [ ] Billing timekeeper(s) entered
- [ ] Any open LKR task flags noted

---

## Step 3 — Populate TODO.md Files

### `_AGENT_DISCOVERY/TODO.md`

Load the outstanding Johnathan Robinson discovery items:

- [ ] Add each outstanding discovery item as a task in the Queue — Active Tasks section
- [ ] Mark any items blocked on client response with `Blocked on: @[owner]`
- [ ] Set the Status block: Last dispatched, Blocking on

### `_AGENT_M365/TODO.md`

Load the queued Chris Williams follow-up:

- [ ] Add "Draft follow-up email to Chris Williams re: [subject]" as the top task
- [ ] Include in the task's Context field: what the prior communication was, what response is needed
- [ ] Set Output expected: "Email draft saved to Robinson Drafts folder"
- [ ] Set Deadline
- [ ] Update Status block

---

## Step 4 — Validation Test

Dispatch the M365 agent on Robinson. Confirm it:

- [ ] Reads `_AGENT_M365/CONTEXT.md` before drafting
- [ ] Reads `_AGENT_M365/TODO.md` and picks up the Chris Williams task
- [ ] Checks `_AGENT_M365/HANDOFFS/` for any unacknowledged handoffs
- [ ] Produces a draft that reflects the case-specific context (not a generic template)
- [ ] Updates `TODO.md` to mark the task complete with output location noted
- [ ] Does NOT require the human to re-supply case facts mid-session

**Validation result:** [ ] Pass   [ ] Fail — note issue: _______________

---

## Step 5 — Roll Forward (after validation passes)

Retrofit remaining active cases in this order:

- [ ] Brown
- [ ] Clark
- [ ] Hopkins
- [ ] Dunn
- [ ] Damon

For each: create four agent folders, populate CONTEXT.md with case-specific facts, load any known pending tasks into the relevant TODO.md files.

---

## Open Questions (resolve during backfill)

- [ ] **SharePoint sync:** Should `_AGENT_*` folders sync to SharePoint, or stay local-only?
  - Current recommendation: **sync** — agent infrastructure is part of the case file
  - Decision: _______________

- [ ] **LexTrack integration:** Should LexTrack pull `@derek` / `@vicki` / `@charise` / `@faith` tagged tasks automatically from agent TODO.md files, or keep manual for v1?
  - Current recommendation: **manual for v1** — validate the pattern before automating
  - Decision: _______________

---

*Last updated: 2026-04-25*
