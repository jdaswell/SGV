# Serving Good Vibes (SGV)
## A Social Entertainment Company | Lafayette, Louisiana

---

## Company Overview

**Serving Good Vibes (SGV)** operates under the **Social Entertainment** umbrella — a 15-year-old Lafayette, LA-based company that creates and coordinates businesses and events specializing in music, food, and drink. Social Entertainment's mission is to curate unforgettable moments that celebrate music, art, and culture while empowering local talent and elevating the cities they serve.

**Headquarters:** 200 Rue Louis XIV, Lafayette, LA 70508

---

## Business Lines

### Restaurants & Catering (SGV Core Focus)
- Professional catering and event staffing: servers, bartenders, event coordinators
- Restaurant brands including **Central Pizza** — wood-fired pizzas and cocktails in Downtown Lafayette
- Full-service event execution from start to finish

### SE Talent
- Connects musicians, DJs, and entertainers with events and audiences
- High-energy, memorable live experiences

### Social Circle (Vendors)
- Curated vendor marketplace for food, beverage, and pop-up retail
- Connects vendors with engaged event audiences

### Live Events & Music
- Signature concert series and community events
- Short-term venue rentals

### Sponsorships & Community Partners
- Brand exposure through event and merchandise sponsorships
- Community partner programs supporting local artists and social initiatives

### SE Development
- Business development arm of the Social Entertainment group

---

## Mission & Values

- Curate unforgettable experiences through music, food, culture, and community
- Empower local talent and vendors
- Elevate Lafayette and the surrounding region
- Unite communities through shared experience

---

## Claude Code Usage Guidelines

### Common Tasks Claude Will Assist With
- Drafting event workflows and SOPs
- Generating vendor agreements, proposals, and catering contracts
- Analyzing financial data (event revenue, food costs, staffing costs)
- Creating staff schedules and event run-of-show documents
- Drafting marketing copy and sponsorship decks
- Building budget templates and P&L summaries

### Preferred Document Style
- Clear, professional, and community-focused tone
- Use plain language; avoid corporate jargon
- Documents should reflect the brand's energy: vibrant, inclusive, authentic

### Tools & Platforms (update as needed)
- [ ] POS system (e.g., Square, Toast)
- [ ] Accounting software (e.g., QuickBooks, Wave)
- [x] Project Management: **Asana** — used for event planning, task tracking, and team coordination across SGV and Social Entertainment
  - Workspace: *(add workspace name/URL)*
  - Key projects: Catering Events, Staff Scheduling, Vendor Management, Live Events
  - When drafting tasks, checklists, or workflows, format output in a way that can be directly copied into Asana (task name, description, assignee placeholder, due date placeholder)
- [ ] Scheduling tools
- [x] Meeting Notes & Transcription: **Otter.ai** — used for recording and transcribing client calls, event debriefs, and team meetings
  - Workspace: **SGV Otter.ai**
  - Use cases: client intake calls, post-event debriefs, staff briefings, vendor negotiations
  - When summarizing or processing meeting content, format output as: key decisions, action items (owner + due date), and follow-up notes
- [ ] Communication (e.g., Slack, email)
- [ ] File storage (e.g., Google Drive, Dropbox)

---

## Repository Structure

This is a documentation and operations repository for Serving Good Vibes (SGV) — it contains no application code. The repo is used to store company workflows, SOPs, and operational documents managed with Claude Code.

```
SGV/
├── CLAUDE.md                  # Project instructions and company context for AI assistants
├── .claude/
│   └── settings.json          # Claude Code plugin configuration
└── workflows/
    └── catering-event-sop.md  # Catering event standard operating procedure
```

### Key Directories

- **`workflows/`** — Operational documents: SOPs, checklists, and process guides. New SOPs and workflow documents should be added here.
- **`.claude/`** — Claude Code configuration. Contains `settings.json` with enabled plugins (`frontend-design`, `claude-md-management`).

### File Conventions

- All documents are written in **Markdown** (`.md`)
- SOPs use a **checklist format** (`- [ ]`) so they can be copied into Asana or used as printable checklists
- Documents include version info and a "Last updated" footer
- Tone: professional, clear, community-focused — avoid corporate jargon

---

## Development Workflow

### Branch Strategy
- `master` is the default branch
- Feature branches follow the pattern `claude/<description>-<id>` for Claude Code sessions
- All changes should be committed with clear, descriptive messages

### Adding New Documents
1. Place SOPs and process documents in `workflows/`
2. Use the existing catering SOP (`workflows/catering-event-sop.md`) as a formatting template
3. Include: purpose, roles & responsibilities, phased steps with checklists, standards, and emergency contacts
4. Update this `CLAUDE.md` file if new directories or major documents are added

### Plugins
The following Claude Code plugins are enabled (configured in `.claude/settings.json`):
- `frontend-design` — for design-related assistance
- `claude-md-management` — for managing CLAUDE.md files

---

## Key Contacts (update as needed)
- Leadership / Owner: TBD
- Catering Coordinator: TBD
- Talent Booking: TBD
- Vendor Relations: TBD
