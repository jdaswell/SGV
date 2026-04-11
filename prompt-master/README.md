# Prompt Master
**Serving Good Vibes | Social Entertainment**
Lafayette, Louisiana

*Version 1.0 — Master repository of reusable AI prompts for SGV operations*

---

## Purpose

`prompt-master/` is the central library of reusable AI prompts used across Serving Good Vibes (SGV) and Social Entertainment operations. It standardizes how the team asks Claude Code (and other AI tools) for help with recurring tasks — drafting contracts, summarizing meetings, building event run-of-shows, analyzing financials, and more.

The goal: one consistent, on-brand voice and one source of truth for prompts the team can copy, paste, and adapt.

---

## How to Use

1. Browse the category folders below for a prompt that fits your task.
2. Copy the prompt file contents into Claude Code, ChatGPT, or your tool of choice.
3. Replace the `{{ placeholder }}` tokens with your real event, client, or vendor details.
4. Review the AI output against SGV tone standards (vibrant, inclusive, authentic, plain language).

When a prompt produces consistently great results, promote it here so the rest of the team can benefit.

---

## Categories

| Folder | What's Inside |
|---|---|
| `catering/` | Catering proposals, client intake summaries, event run-of-shows |
| `events/` | Live event planning, concert series, venue rental workflows |
| `vendors/` | Vendor agreements, Social Circle onboarding, vendor communications |
| `talent/` | SE Talent booking outreach, performer contracts, hospitality riders |
| `marketing/` | Marketing copy, social posts, sponsorship decks |
| `finance/` | P&L summaries, event revenue analysis, food and staffing cost breakdowns |
| `meetings/` | Otter.ai transcript summarization, action item extraction, debriefs |
| `operations/` | SOP drafting, staff scheduling, checklist generation |

---

## Prompt File Conventions

Each prompt lives in its own Markdown file and follows this template:

```markdown
# {{ Prompt Title }}

**Category:** {{ category }}
**Use case:** {{ one-line description }}
**Tools:** Claude Code / ChatGPT / etc.
**Last updated:** {{ YYYY-MM-DD }}

## Inputs
- {{ input 1 }}
- {{ input 2 }}

## Prompt
```
{{ the actual prompt text with {{ placeholders }} }}
```

## Example Output
{{ optional — short sample of what good output looks like }}

## Notes
{{ optional — tips, gotchas, related prompts }}
```

---

## Contributing a New Prompt

1. Pick the right category folder (or create a new one if needed).
2. Name the file with kebab-case: `catering-proposal-draft.md`, `otter-meeting-summary.md`.
3. Use the template above.
4. Test the prompt at least once against a real SGV task before committing.
5. Commit with a clear message: `Add catering proposal draft prompt`.
6. If you add a new category, update the table in this README.

---

## Style & Tone Reminders

All prompts should steer AI output toward the SGV brand voice:

- **Clear and professional** — no corporate jargon
- **Community-focused** — Lafayette and the people we serve come first
- **Vibrant, inclusive, authentic** — the energy of a great SGV event
- **Plain language** — write like you'd talk to a client over coffee

---

*Last updated: 2026-04-11*
