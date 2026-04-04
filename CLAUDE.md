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
- **Knowledge base operations:** ingesting sources, compiling wiki articles, answering research queries, generating reports/slides, and running health checks (see Knowledge Base section below)

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
├── knowledge-base/            # LLM-compiled knowledge wiki
│   ├── _index.md              # Master index (LLM-maintained)
│   ├── raw/                   # Source documents (immutable after ingestion)
│   │   └── _sources.md        # Source registry
│   ├── wiki/                  # Compiled wiki articles, concepts, source summaries
│   ├── output/                # Generated reports, slides, visualizations
│   └── tools/                 # CLI scripts (ingest, compile, healthcheck, search)
└── workflows/
    ├── catering-event-sop.md  # Catering event standard operating procedure
    └── knowledge-base-sop.md  # Knowledge base management SOP
```

### Key Directories

- **`workflows/`** — Operational documents: SOPs, checklists, and process guides. New SOPs and workflow documents should be added here.
- **`knowledge-base/`** — LLM-compiled knowledge wiki. Raw sources go in `raw/`, the LLM compiles them into `wiki/`, and query outputs go in `output/`. See `knowledge-base/README.md` and `workflows/knowledge-base-sop.md` for usage.
- **`.claude/`** — Claude Code configuration. Contains `settings.json` with enabled plugins (`frontend-design`, `claude-md-management`).

### File Conventions

- All documents are written in **Markdown** (`.md`)
- SOPs use a **checklist format** (`- [ ]`) so they can be copied into Asana or used as printable checklists
- Documents include version info and a "Last updated" footer
- Tone: professional, clear, community-focused — avoid corporate jargon

---

## Knowledge Base

The `knowledge-base/` directory is an LLM-compiled wiki. **Claude maintains the wiki — humans rarely edit it directly.** Raw sources are the ground truth; the wiki is a compiled, interlinked layer on top.

### How It Works

1. **Ingest:** Raw sources (articles, transcripts, data, images) go into `knowledge-base/raw/` and are registered in `raw/_sources.md`
2. **Compile:** Claude reads unprocessed sources and compiles them into `wiki/` — creating source summaries, concept definitions, and synthesized articles with `[[wikilinks]]`
3. **Query:** Claude reads `_index.md` to navigate the wiki, then reads relevant articles to answer research questions
4. **Output:** Results are rendered as markdown reports, Marp slides, or visualizations in `output/`
5. **File back:** Useful outputs get filed back into the wiki, compounding the knowledge base
6. **Lint:** Periodic health checks find broken links, inconsistencies, and gaps

### Claude's Knowledge Base Responsibilities

When working with the knowledge base, Claude should:

- **Always read `_index.md` first** when answering questions against the wiki — it contains the master index of all content with brief summaries
- **Always read `raw/_sources.md`** before compilation to identify unprocessed sources
- **Never modify files in `raw/`** — raw sources are immutable after ingestion
- **Maintain `[[wikilinks]]`** in all wiki content for Obsidian compatibility
- **Include YAML frontmatter** in every wiki file (use templates in `wiki/_template-*.md`)
- **Update `_index.md`** after every compilation with new entries and updated statistics
- **Update `raw/_sources.md`** status from "unprocessed" to "compiled" after processing a source
- **Add backlinks** — when Article A references Article B, ensure B links back to A
- **File query outputs back** into the wiki when they contain reusable analysis

### Knowledge Base Commands

These are the CLI tools available in `knowledge-base/tools/`:

| Command | Purpose |
|---|---|
| `bash knowledge-base/tools/ingest.sh <file> "<desc>" [type]` | Register a new source document |
| `bash knowledge-base/tools/compile.sh` | Check for unprocessed sources, generate compilation prompt |
| `bash knowledge-base/tools/search.sh "<query>"` | Search the wiki from the command line |
| `bash knowledge-base/tools/healthcheck.sh` | Run integrity checks (broken links, missing files, stats) |

### Compilation Workflow

When asked to compile, Claude should:

1. Read `raw/_sources.md` — find entries with `**Status:** unprocessed`
2. For each unprocessed source, read the raw file and:
   - Create a source summary in `wiki/sources/` (use `_template-source-summary.md`)
   - Extract concepts into `wiki/concepts/` (use `_template-concept.md`)
   - Write or update articles in `wiki/articles/` (use `_template-article.md`)
3. Mark the source as `**Status:** compiled` in `raw/_sources.md`
4. Update `_index.md` with new entries and refreshed statistics
5. Report what was compiled and suggest follow-up actions

### Health Check Workflow

When asked to run a deep health check, Claude should:

1. Run `bash knowledge-base/tools/healthcheck.sh` for automated checks
2. Read all wiki articles and check for:
   - Inconsistent or conflicting data across articles
   - Missing backlinks between related content
   - Concepts mentioned but not yet defined
   - Stale information that needs updating
3. Suggest new article candidates based on coverage gaps
4. Save findings as a report in `output/reports/`

### Output Formats

| Format | Directory | Use Case |
|---|---|---|
| Markdown report | `output/reports/` | Analysis, proposals, comparisons |
| Marp slides | `output/slides/` | Presentations, pitches, briefings |
| Visualizations | `output/visualizations/` | Charts, diagrams (matplotlib, mermaid) |

Full SOP: `workflows/knowledge-base-sop.md`

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
