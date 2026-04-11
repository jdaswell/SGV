# Catering Proposal Draft

**Category:** catering
**Use case:** Draft a client-ready catering proposal from a short event brief
**Tools:** Claude Code / ChatGPT
**Last updated:** 2026-04-11

## Inputs
- Client name and contact
- Event date, time, and location
- Guest count and service style (buffet, plated, stations, passed)
- Menu preferences or dietary notes
- Budget range (if known)

## Prompt
```
You are drafting a catering proposal on behalf of Serving Good Vibes (SGV), a Lafayette, LA catering and event company under the Social Entertainment umbrella. Our voice is vibrant, inclusive, authentic, and community-focused — professional but never corporate.

Draft a one-page catering proposal for the following event:

- Client: {{ client_name }}
- Event: {{ event_type }} on {{ event_date }} at {{ venue }}
- Guest count: {{ guest_count }}
- Service style: {{ service_style }}
- Menu preferences: {{ menu_notes }}
- Budget range: {{ budget }}

Include these sections:
1. Warm opening paragraph that reflects the SGV vibe
2. Proposed menu (with short, appetizing descriptions)
3. Staffing plan (servers, bartenders, lead, kitchen)
4. Timeline of service (load-in, service windows, breakdown)
5. Pricing summary (itemized, with a clear total)
6. Next steps and a friendly close

Use plain language. No jargon. Keep it under 500 words.
```

## Notes
- Pair with `workflows/catering-event-sop.md` for standards reference.
- Always have the Catering Coordinator review before sending to the client.
