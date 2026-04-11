# Vendor Agreement Draft

**Category:** vendors
**Use case:** Draft a plain-language vendor agreement for Social Circle pop-ups and event vendors
**Tools:** Claude Code / ChatGPT
**Last updated:** 2026-04-11

## Inputs
- Vendor business name and contact
- Event name, date, location
- Booth / space assignment and size
- Fee structure (flat fee, revenue share, or comped)
- Load-in / load-out times
- Insurance / permit requirements

## Prompt
```
You are drafting a vendor agreement for Social Circle, the curated vendor marketplace under Serving Good Vibes (SGV) in Lafayette, LA. The agreement should be legally clear but still friendly and community-focused — we want vendors to feel welcomed, not lawyered at.

Vendor and event details:
- Vendor: {{ vendor_name }}
- Vendor contact: {{ vendor_contact }}
- Event: {{ event_name }} on {{ event_date }} at {{ location }}
- Space: {{ booth_assignment }} ({{ booth_size }})
- Fee: {{ fee_structure }}
- Load-in: {{ load_in_time }}
- Load-out: {{ load_out_time }}
- Insurance / permits required: {{ insurance_requirements }}

Draft the agreement with these sections:
1. Parties and purpose
2. Event overview
3. Space, setup, and breakdown expectations
4. Fees and payment terms
5. Insurance, permits, and compliance
6. Cancellation and weather policy
7. Code of conduct (keep it warm but firm)
8. Signatures

Rules:
- Use plain language. No legalese beyond what's necessary.
- Keep it under two pages.
- End with a short, warm closing paragraph welcoming the vendor to the Social Circle community.
```

## Notes
- Always route to SGV leadership for sign-off before sending to the vendor.
