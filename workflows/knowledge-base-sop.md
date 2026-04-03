# Knowledge Base Management SOP
**Serving Good Vibes | Social Entertainment**
Lafayette, Louisiana

*Version 1.0 — Review quarterly*

---

## Purpose

This SOP describes how to maintain and use the SGV LLM-compiled knowledge base. The knowledge base collects raw source material (articles, transcripts, notes, data) and uses an LLM to compile it into a structured, interlinked markdown wiki. The wiki supports research, decision-making, and content generation across all SGV business lines.

---

## Roles & Responsibilities

| Role | Responsibilities |
|---|---|
| **Knowledge Base Owner** | Ingests new sources, triggers compilations, runs health checks |
| **LLM Agent** | Compiles wiki articles, maintains indexes, answers queries, generates outputs |
| **Team Members** | Submit raw sources (meeting notes, articles, data) for ingestion |

---

## Phase 1: Source Ingestion

### 1.1 Collecting Raw Sources
- [ ] Identify valuable source material: articles, research papers, meeting transcripts (from Otter.ai), vendor proposals, event data, industry reports
- [ ] Save source files in markdown format when possible (use Claude browser extension to convert web articles)
- [ ] Download related images locally alongside the markdown file
- [ ] Name files descriptively: `YYYY-MM-topic-description.md`

### 1.2 Registering Sources
- [ ] Run the ingest script to copy and register the source:
  ```
  bash knowledge-base/tools/ingest.sh path/to/file.md "Description" type
  ```
- [ ] Verify the source appears in `knowledge-base/raw/_sources.md` with status "unprocessed"
- [ ] For bulk ingestion, repeat for each file

### 1.3 Source Types
| Type | Examples |
|---|---|
| article | Web articles, blog posts, news pieces |
| paper | Research papers, industry reports |
| transcript | Otter.ai meeting transcripts, interview notes |
| dataset | Spreadsheets, CSV data, financial records |
| notes | Personal notes, brainstorm outputs, meeting summaries |
| image | Photos, diagrams, infographics |
| repo | Code repositories, tool documentation |

---

## Phase 2: Wiki Compilation

### 2.1 Triggering Compilation
- [ ] Run `bash knowledge-base/tools/compile.sh` to check for unprocessed sources
- [ ] Copy the generated prompt into your LLM session (or ask directly):
  > "Compile the latest raw sources into the SGV knowledge base wiki."
- [ ] The LLM will:
  - Read each unprocessed source
  - Create source summaries in `wiki/sources/`
  - Extract and define concepts in `wiki/concepts/`
  - Write or update articles in `wiki/articles/`
  - Update `_index.md` with new entries
  - Mark sources as "compiled" in `_sources.md`

### 2.2 Compilation Quality Checks
- [ ] Review the LLM's compilation report
- [ ] Spot-check 1-2 source summaries against the originals for accuracy
- [ ] Verify new concepts are properly defined and linked
- [ ] Confirm `_index.md` is up to date

### 2.3 Incremental Updates
- [ ] When new sources relate to existing articles, ask the LLM to update (not replace) existing content
- [ ] The LLM should add new information while preserving existing analysis
- [ ] Backlinks and cross-references should be updated in all affected files

---

## Phase 3: Querying the Knowledge Base

### 3.1 Research Queries
- [ ] Ask the LLM research questions with the knowledge base as context:
  > "Using the SGV knowledge base, research: [question]"
- [ ] The LLM reads `_index.md` to identify relevant articles, then reads them in detail
- [ ] For complex queries, the LLM may chain multiple articles together

### 3.2 Example Query Types
- **Factual:** "What are our standard staffing ratios for buffet events?"
- **Analytical:** "Compare food costs across our last 10 catering events"
- **Strategic:** "What emerging food trends should we consider for 2026 festival season?"
- **Creative:** "Generate a sponsorship pitch for a local brewery partnership"
- **Operational:** "What SOPs need updating based on our recent event debriefs?"

### 3.3 Filing Query Outputs
- [ ] When a query produces useful analysis, file it back into the wiki:
  > "File this analysis as a new article in the knowledge base."
- [ ] This compounds the knowledge base — your explorations enhance future queries

---

## Phase 4: Generating Outputs

### 4.1 Output Formats
| Format | Use Case | Output Directory |
|---|---|---|
| Markdown report | Detailed analysis, proposals | `output/reports/` |
| Marp slides | Presentations, pitches, team briefings | `output/slides/` |
| Data visualizations | Charts, graphs, comparisons | `output/visualizations/` |

### 4.2 Creating Slide Decks
- [ ] Ask the LLM to generate Marp-format slides:
  > "Create a Marp slide deck on [topic] using the knowledge base. Save to output/slides/"
- [ ] View in Obsidian with Marp plugin, or export to PDF

### 4.3 Creating Reports
- [ ] Ask the LLM to compile a report from wiki data:
  > "Generate a quarterly vendor performance report from the knowledge base."
- [ ] Reports are saved as markdown in `output/reports/`

---

## Phase 5: Maintenance & Health Checks

### 5.1 Regular Health Checks (Monthly)
- [ ] Run `bash knowledge-base/tools/healthcheck.sh`
- [ ] Review automated checks: broken links, unregistered files, unprocessed sources
- [ ] Ask the LLM for a deep health check:
  > "Run a deep health check on the SGV knowledge base. Find inconsistencies, suggest improvements."

### 5.2 LLM Health Check Tasks
- [ ] Find and fix inconsistent data across articles
- [ ] Identify missing backlinks between related content
- [ ] Suggest new article candidates based on gaps
- [ ] Flag stale information that needs updating
- [ ] Impute missing data with web searches where appropriate

### 5.3 Wiki Cleanup
- [ ] Merge articles that substantially overlap
- [ ] Split articles that cover too many distinct topics
- [ ] Update statistics in `_index.md`
- [ ] Archive outdated content (move to `wiki/archive/` if needed)

---

## Phase 6: Viewing in Obsidian

### 6.1 Setup
- [ ] Open `knowledge-base/` as an Obsidian vault
- [ ] Install recommended plugins: Marp Slides, Dataview
- [ ] Set `_index.md` as the home page

### 6.2 Navigation
- Use the graph view to visualize connections between articles
- Use `[[wikilinks]]` to navigate between articles
- Use the search function for quick lookups
- Use Dataview queries to create dynamic views of the wiki content

---

## Standards

- **Tone:** Professional, clear, community-focused — consistent with all SGV documents
- **File naming:** Lowercase, hyphens for spaces: `food-cost-analysis.md`
- **Frontmatter:** Every wiki file includes YAML frontmatter with title, type, dates, and references
- **Links:** Use `[[wikilinks]]` for internal references; standard markdown links for external URLs
- **Templates:** Use templates in `wiki/_template-*.md` for consistent formatting
- **Raw sources are immutable:** Never modify files in `raw/` after ingestion

---

## Emergency Contacts & Escalation

| Situation | Action |
|---|---|
| LLM produces inaccurate data | Flag in health check; correct in next compilation cycle |
| Broken wiki links | Run healthcheck.sh; ask LLM to repair |
| Lost or corrupted files | Restore from git history |
| Knowledge base too large for LLM context | Split into sub-wikis by topic; improve index summaries |

---

*Last updated: April 2026 | Owner: Social Entertainment — Serving Good Vibes*
