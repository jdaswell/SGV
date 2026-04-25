# BDM Orchestrator SKILL.md — Patch

> **Insert this block after the "Sub-Agent Registry" section and before the autonomous chain logic.**
> Copy the content between the `--- BEGIN PATCH ---` and `--- END PATCH ---` markers.

---

--- BEGIN PATCH ---

## Agent Folder Architecture

Each sub-agent operates out of a dedicated folder inside the case directory.
The orchestrator creates this structure when a case is opened or retrofitted.

### Folder Structure (per case)

```
[CASE_FOLDER]/
├── _AGENT_LIFECYCLE/
│   ├── CONTEXT.md          ← case facts relevant to lifecycle management
│   ├── TODO.md             ← lifecycle agent's current task queue
│   └── HANDOFFS/           ← handoff files received from other agents
│
├── _AGENT_DISCOVERY/
│   ├── CONTEXT.md
│   ├── TODO.md
│   └── HANDOFFS/
│
├── _AGENT_M365/
│   ├── CONTEXT.md
│   ├── TODO.md
│   └── HANDOFFS/
│
└── _AGENT_LKR/
    ├── CONTEXT.md
    ├── TODO.md
    └── HANDOFFS/
```

### Agent Spawn Protocol

When the orchestrator dispatches a sub-agent, it MUST follow this sequence:

1. **Read `CONTEXT.md`** — load case facts, parties, flags, and standing instructions
2. **Read `TODO.md`** — identify the current task queue and any blockers
3. **Check `HANDOFFS/`** — process any unacknowledged handoff files (newest first)
4. **Execute** — work the TODO queue using context from all three sources
5. **Update `TODO.md`** — mark completed tasks, add notes/decisions, update status block
6. **Write handoff if needed** — if work triggers another agent, create a handoff file in that agent's `HANDOFFS/` folder using the naming convention `HANDOFF_FROM_[ROLE]_[YYYYMMDD].md`

The orchestrator MUST NOT dispatch a sub-agent without a populated `CONTEXT.md`.
A missing or empty `CONTEXT.md` is a hard stop — surface to human before proceeding.

### Handoff Rules

- Handoffs are one-directional files: the sending agent writes, the receiving agent reads
- Handoff files are never deleted — they become the case's decision log
- A handoff marked `Priority: Urgent` triggers an immediate orchestrator notification
- The receiving agent acknowledges the handoff by checking the box in the Acknowledgment section of the handoff file and adding a date

### Human Escalation Triggers

The orchestrator surfaces to human (does not auto-proceed) when:

- `CONTEXT.md` is missing or has unfilled `[bracketed]` fields in required rows
- `TODO.md` has one or more tasks with `Blocked on: @[owner]`
- A handoff is marked `Priority: Urgent`
- Any agent's TODO queue is empty and no handoff is pending (may mean case is complete or stalled)
- A standing instruction in `CONTEXT.md` contradicts the current task

### Template Locations

Templates for all three files live in:
`JDA BDM CLAUDE FILES\00_BDM_TEMPLATES\AGENT_FOLDER_TEMPLATE\`

Copy the entire `AGENT_FOLDER_TEMPLATE\` folder and rename it `_AGENT_[ROLE]` when setting up a new agent for a case.

--- END PATCH ---
