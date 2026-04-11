# Otter.ai Transcript Processing Workflow
**Serving Good Vibes | Social Entertainment**
Lafayette, Louisiana

*Version 1.0 — Review quarterly or when meeting formats change*

---

## Purpose

This workflow defines how the SGV team captures, processes, and acts on Otter.ai recordings from client calls, event debriefs, staff briefings, and vendor negotiations. The goal is to turn raw conversations into clear decisions, assigned action items, and searchable records — without losing the energy or intent of the original conversation.

Every meeting recorded in Otter.ai should produce three things: a decisions log, an action items list (with owners and due dates), and a short narrative summary. Claude is used to accelerate this process.

---

## Roles & Responsibilities

| Role | Responsibilities |
|---|---|
| **Meeting Host** | Starts Otter.ai recording, announces recording to participants, confirms attendees, ends recording cleanly |
| **Notetaker** | Reviews raw transcript within 24 hours, runs Claude processing, publishes clean summary to Asana and team channel |
| **Action Owners** | Accept assigned tasks in Asana, confirm due dates, flag blockers within 48 hours |
| **Event Coordinator** | Ensures event debrief transcripts feed into the post-event record and inform future planning |

---

## Meeting Types & Use Cases

| Meeting Type | Record in Otter? | Primary Output |
|---|---|---|
| Client intake call | Yes — with client consent | Scope summary, agreed menu/service style, next steps |
| Post-event debrief | Yes | Decisions log, improvements list, update to event record |
| Staff briefing (pre-event huddle) | Optional | Key points for absent staff |
| Vendor negotiation | Yes — with vendor consent | Pricing agreed, delivery terms, follow-up items |
| Internal planning / standups | Yes | Action items into Asana |
| 1:1 coaching or HR conversations | **No** — do not record |

---

## Phase 1: Before the Meeting

### 1.1 Consent & Setup
- [ ] Confirm every participant consents to being recorded — Louisiana is a one-party consent state, but SGV policy requires all-party consent
- [ ] Announce recording verbally at the start of the meeting
- [ ] Name the Otter.ai conversation with this format: `YYYY-MM-DD | Meeting Type | Primary Contact or Event Name`
  - Example: `2026-04-11 | Client Intake | Boudreaux Wedding`
- [ ] Assign the meeting to the correct Otter.ai folder (Client Calls, Event Debriefs, Vendor, Internal)

### 1.2 Agenda
- [ ] Share a written agenda in advance — it helps Otter.ai speaker labeling and gives Claude structure to work with
- [ ] Identify the notetaker for this meeting before it starts

---

## Phase 2: During the Meeting

- [ ] Meeting host introduces each speaker by name at least once in the first five minutes — this trains Otter.ai speaker separation
- [ ] Verbally flag decisions as they happen ("So the decision is…") — this makes them easy to extract later
- [ ] Verbally flag action items ("Action item for [name]: …") with the owner's name spoken out loud
- [ ] Avoid talking over one another; Otter.ai transcript quality drops sharply on overlapping speech
- [ ] If a sensitive topic comes up that shouldn't be recorded, pause the recording and resume after

---

## Phase 3: Transcript Review (Within 24 Hours)

### 3.1 Raw Transcript Cleanup in Otter.ai
- [ ] Open the conversation in Otter.ai
- [ ] Fix speaker labels where Otter.ai misattributed lines
- [ ] Correct obvious transcription errors in names, menu items, dollar amounts, and dates — these are the highest-cost mistakes
- [ ] Highlight or star any segments that contain decisions or action items
- [ ] Export the cleaned transcript as plain text

### 3.2 Processing with Claude
Paste the cleaned transcript into Claude with a prompt like:

> Process this Otter.ai transcript from a [meeting type] on [date] with [participants]. Format the output as:
> 1. **Key decisions** — bullet list, each decision standalone and unambiguous
> 2. **Action items** — table with owner, task, due date (use TBD if not stated)
> 3. **Follow-up notes** — anything raised but not resolved, flagged for the next conversation
> 4. **Narrative summary** — 3–5 sentences capturing the tone and outcome of the meeting

Claude should:
- [ ] Strip filler words, false starts, and repetition
- [ ] Preserve the speaker's intent — do not soften disagreements or invent agreement that wasn't there
- [ ] Flag anything unclear rather than guessing (e.g., "unclear whether deposit is due on signing or two weeks out")
- [ ] Use SGV's voice: clear, professional, community-focused — no corporate jargon

---

## Phase 4: Distribution & Action

### 4.1 Publish the Summary
- [ ] Post the Claude-processed summary to the relevant Asana project as a task comment or linked doc:
  - Client calls → **Catering Events** project, on the client's event task
  - Event debriefs → **Catering Events** project, on the event task
  - Vendor negotiations → **Vendor Management** project
  - Internal planning → the relevant project
- [ ] Link back to the Otter.ai conversation URL for anyone who needs the full context

### 4.2 Create Action Items in Asana
- [ ] For each action item, create an Asana task with:
  - **Task name:** short, verb-first (e.g., "Send Boudreaux wedding menu proposal")
  - **Description:** context pulled from the transcript
  - **Assignee:** the owner named in the meeting
  - **Due date:** the date committed during the meeting, or a placeholder flagged for confirmation
- [ ] Tag tasks with the event, client, or vendor name

### 4.3 Client or Vendor Recap (External Meetings Only)
- [ ] Send a short recap email to the client or vendor within 24 hours of the meeting, covering agreed decisions and next steps
- [ ] Do **not** forward the raw Otter.ai transcript — it often contains internal side conversations
- [ ] Keep the external recap in the brand voice: warm, clear, confident

---

## Phase 5: Archive & Retention

- [ ] Leave the processed summary linked in Asana indefinitely
- [ ] Keep raw Otter.ai recordings for 90 days for client-facing meetings, 30 days for internal meetings, then delete unless flagged for legal or HR reasons
- [ ] Move event debrief summaries into the event's final record for future reference
- [ ] Quarterly: review Otter.ai folder hygiene — delete anything past retention, confirm tags and folders are still accurate

---

## Privacy & Compliance Standards

- **Consent first, always.** If a participant objects, do not record.
- **Do not record HR, disciplinary, or personal conversations** in Otter.ai.
- **Sensitive client details** (dietary restrictions tied to medical conditions, payment information, personal contact info) must be handled per the client's expectation and never shared outside the SGV team.
- **Vendor pricing** from recorded negotiations is confidential — do not share across vendors.
- **Transcripts are working documents**, not legal records. Signed contracts and written agreements still control.

---

## Quality Standards for Processed Summaries

Every Claude-processed summary published by the team should meet these standards:

- Decisions are unambiguous and standalone — a reader who wasn't in the meeting understands them
- Every action item has an owner and a due date (or an explicit TBD flag)
- Dollar amounts, dates, menu items, and names are double-checked against the transcript
- The narrative summary reflects the actual tone of the meeting — don't over-polish a difficult conversation
- Nothing is invented; if the transcript is unclear, flag it rather than guess

---

## Troubleshooting

| Problem | Action |
|---|---|
| Otter.ai missed large portions of the meeting | Note the gap in the summary; follow up with attendees to fill in |
| Speaker labels are unusable | Process the transcript generically ("Participant 1 said…") and ask the host to re-verify critical attributions |
| Participant asks for recording to be deleted | Delete from Otter.ai within 24 hours; confirm deletion in writing |
| Sensitive information was accidentally recorded | Trim that section in Otter.ai before processing; do not include in the summary |
| Action item owner is unclear | Default to the meeting host as temporary owner; flag for confirmation within 24 hours |

---

*Last updated: April 2026 | Owner: Social Entertainment — Serving Good Vibes*
