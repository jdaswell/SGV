# Otter.ai Meeting Summary

**Category:** meetings
**Use case:** Turn a raw Otter.ai transcript into a structured SGV meeting summary
**Tools:** Claude Code / ChatGPT
**Last updated:** 2026-04-11

## Inputs
- Raw Otter.ai transcript (paste into `{{ transcript }}`)
- Meeting type (client intake, post-event debrief, staff briefing, vendor negotiation)
- Attendees

## Prompt
```
You are summarizing a meeting for Serving Good Vibes (SGV), a Lafayette, LA social entertainment company. Our summaries must be skimmable and action-oriented so the team can move fast.

Meeting type: {{ meeting_type }}
Attendees: {{ attendees }}

Transcript:
"""
{{ transcript }}
"""

Produce the summary in this exact format:

## Key Decisions
- (bullet list of decisions made)

## Action Items
| Owner | Task | Due Date |
|---|---|---|
| ... | ... | ... |

## Follow-up Notes
- (open questions, things to revisit, context worth preserving)

Rules:
- Only include action items with a clear owner. If the transcript is ambiguous, mark owner as "TBD".
- Keep bullets short — one line each where possible.
- Do not invent details that aren't in the transcript.
- Use plain language; no corporate jargon.
```

## Notes
- Matches the format called out in `CLAUDE.md` under Otter.ai usage.
- Paste the output directly into Asana as a meeting recap task.
