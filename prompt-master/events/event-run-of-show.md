# Event Run-of-Show

**Category:** events
**Use case:** Generate a minute-by-minute run-of-show for an SGV live event or catering gig
**Tools:** Claude Code / ChatGPT
**Last updated:** 2026-04-11

## Inputs
- Event name, date, venue
- Start and end time
- Service style and guest count
- Key moments (speeches, performances, toasts, special menu drops)
- On-site team roster

## Prompt
```
You are building a run-of-show for a Serving Good Vibes (SGV) event in Lafayette, LA. The document will be printed and handed to the on-site team, so it must be clear, tight, and scannable.

Event details:
- Name: {{ event_name }}
- Date: {{ event_date }}
- Venue: {{ venue }}
- Doors / start: {{ start_time }}
- End: {{ end_time }}
- Guest count: {{ guest_count }}
- Service style: {{ service_style }}
- Key moments: {{ key_moments }}
- Team on site: {{ team_roster }}

Produce the run-of-show as a Markdown table with columns:
| Time | Activity | Owner | Notes |

Rules:
- Include load-in, pre-service setup, doors, service windows, key moments, breakdown, and load-out.
- Every row must have an owner from the roster above.
- Call out any hard deadlines or compliance moments (alcohol service cutoff, noise ordinance, etc.).
- Keep the "Notes" column short — one line per row.
- Use plain language and SGV's vibrant, community-focused tone where appropriate (e.g., in welcome moments).
```

## Notes
- Cross-check against `workflows/catering-event-sop.md` Phase 3 (Day of Event) before finalizing.
