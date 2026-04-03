# SGV Knowledge Base

**An LLM-compiled knowledge wiki for Serving Good Vibes and Social Entertainment**

---

## Overview

This knowledge base follows the **LLM-compiled wiki** pattern: raw source material is ingested, then an LLM incrementally compiles it into a structured, interlinked markdown wiki. You rarely edit the wiki directly — the LLM maintains it.

## Directory Structure

```
knowledge-base/
├── README.md              # You are here
├── _index.md              # Master index of all wiki content (LLM-maintained)
├── raw/                   # Source documents — articles, notes, data, images
│   └── _sources.md        # Registry of all ingested sources
├── wiki/                  # LLM-compiled wiki articles
│   ├── concepts/          # Core concept definitions and explainers
│   ├── articles/          # In-depth articles on specific topics
│   └── sources/           # Summaries and notes on each raw source
├── output/                # Rendered outputs from queries
│   ├── slides/            # Marp-format slide decks
│   ├── visualizations/    # Charts, diagrams, matplotlib outputs
│   └── reports/           # Formatted reports and analysis documents
└── tools/                 # CLI scripts for wiki management
    ├── compile.sh         # Compile raw sources into wiki articles
    ├── healthcheck.sh     # Run integrity checks on the wiki
    ├── search.sh          # Search the wiki from CLI
    └── ingest.sh          # Ingest a new source document
```

## Workflow

### 1. Ingest Raw Data

Place source documents (articles, PDFs, notes, images, meeting transcripts) into `raw/`:

```bash
# Copy a file into raw/
cp ~/Downloads/article.md knowledge-base/raw/

# Or use the ingest script to register it
bash knowledge-base/tools/ingest.sh path/to/source.md "Description of the source"
```

Every source gets registered in `raw/_sources.md` with metadata (date added, type, brief description).

### 2. Compile the Wiki

Ask the LLM to compile new raw sources into wiki content:

```
"Compile the latest raw sources into the knowledge base wiki. 
Read raw/_sources.md for new unprocessed entries, summarize each 
into wiki/sources/, extract concepts into wiki/concepts/, and 
write or update articles in wiki/articles/. Update _index.md."
```

Or run the compile script which prompts the LLM:

```bash
bash knowledge-base/tools/compile.sh
```

### 3. Query the Wiki

Ask questions against the compiled wiki:

```
"Using the SGV knowledge base, research: What are the top 
food trends for outdoor festival catering in 2026?"
```

The LLM reads `_index.md` to find relevant articles, then dives deeper as needed.

### 4. Generate Outputs

Request specific output formats:

```
"Create a Marp slide deck summarizing our vendor partnerships. 
Save to knowledge-base/output/slides/"
```

```
"Generate a comparison report of our last 5 catering events. 
Save to knowledge-base/output/reports/"
```

### 5. File Outputs Back

Good outputs get filed back into the wiki to enhance future queries:

```
"File the vendor comparison report back into the wiki as an article."
```

### 6. Run Health Checks

Periodically lint the wiki for quality:

```bash
bash knowledge-base/tools/healthcheck.sh
```

Or ask the LLM directly:

```
"Run a health check on the knowledge base. Find broken links, 
missing summaries, inconsistent data, and suggest new articles."
```

## Viewing in Obsidian

The `wiki/` directory is designed to work as an Obsidian vault:

- All internal links use `[[wikilink]]` format
- Articles include YAML frontmatter for metadata
- The `_index.md` serves as the entry point / home page
- Backlinks are maintained by the LLM during compilation

To view: Open the `knowledge-base/` folder as an Obsidian vault.

## Key Principles

1. **The LLM writes the wiki, not you.** Your job is to ingest sources and ask questions.
2. **Everything compounds.** Query outputs get filed back, making future queries richer.
3. **Index files are critical.** The LLM uses `_index.md` and `_sources.md` to navigate — keep them current.
4. **Raw sources are immutable.** Never modify files in `raw/` — that's the ground truth.
5. **Wiki articles are disposable.** They can always be recompiled from raw sources.

---

*Last updated: April 2026 | Serving Good Vibes — Social Entertainment*
