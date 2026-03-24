# Daily Briefing — Serving Good Vibes

Generate a morning briefing for the SGV / Social Entertainment team. Today's date is available in your context as `currentDate`.

## Instructions

Pull together the following sections and present them in a clean, scannable format. Use the available MCP tools to fetch live data where possible.

### 1. Today at a Glance
- State today's date and day of the week
- Note any major events, catering jobs, or concerts happening today (from Google Calendar)

### 2. Upcoming Events (Next 7 Days)
- Use `gcal_list_events` to pull calendar events for the next 7 days
- Highlight events that need active coordination: catering jobs, live events, vendor pop-ups, client meetings
- Flag anything with missing details (no location, no confirmed headcount, etc.)

### 3. Inbox Highlights
- Use `gmail_search_messages` to find unread or recent messages (last 24–48 hours) related to:
  - Catering inquiries or confirmations
  - Vendor communications
  - Talent / SE Talent bookings
  - Sponsorship or partner follow-ups
- Summarize each relevant thread in one line

### 4. Action Items
- List any clear action items surfaced from the calendar or inbox
- Format each as: **[Owner TBD]** — Task description — Due: date or "Today"

### 5. Priorities for Today
- Based on everything above, call out the top 3–5 things the team should focus on today

---

## Output Format

Use this structure:

```
# SGV Daily Briefing — [Day, Date]

## Today at a Glance
...

## Upcoming Events (Next 7 Days)
...

## Inbox Highlights
...

## Action Items
...

## Today's Priorities
1.
2.
3.
```

Keep the tone professional but energetic — this is SGV, not a law firm. Be concise. If data isn't available from a tool, say so briefly and move on.
