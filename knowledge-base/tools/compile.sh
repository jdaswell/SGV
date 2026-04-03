#!/usr/bin/env bash
# compile.sh — Guide for LLM wiki compilation
#
# This script identifies unprocessed sources and outputs a prompt
# for the LLM to compile them into wiki articles.
#
# Usage: bash compile.sh

set -euo pipefail

KB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCES_FILE="$KB_DIR/raw/_sources.md"

echo "============================================"
echo " SGV Knowledge Base — Compilation Check"
echo "============================================"
echo ""

# Count unprocessed sources
UNPROCESSED=$(grep -c '^\- \*\*Status:\*\* unprocessed$' "$SOURCES_FILE" 2>/dev/null || true)
UNPROCESSED=${UNPROCESSED:-0}
TOTAL=$(grep -c "^### " "$SOURCES_FILE" 2>/dev/null || echo "0")

echo "Total sources registered: $TOTAL"
echo "Unprocessed sources:      $UNPROCESSED"
echo ""

if [ "$UNPROCESSED" -eq 0 ]; then
    echo "All sources are compiled. Nothing to do."
    echo ""
    echo "To add new sources, run:"
    echo "  bash tools/ingest.sh <file> \"<description>\" [type]"
    exit 0
fi

echo "Unprocessed sources found. Use the following prompt with your LLM:"
echo ""
echo "------- COPY BELOW -------"
echo ""
cat << 'PROMPT'
Compile the SGV knowledge base. Steps:

1. Read `knowledge-base/raw/_sources.md` and find all entries with status "unprocessed"
2. For each unprocessed source:
   a. Read the raw file from `knowledge-base/raw/`
   b. Create a source summary in `knowledge-base/wiki/sources/` with:
      - YAML frontmatter (title, source_file, type, date_ingested, date_compiled)
      - Executive summary (2-3 paragraphs)
      - Key takeaways (bullet list)
      - Relevant concepts (linked with [[wikilinks]])
      - Quotes or data points worth preserving
   c. Extract concepts — create or update files in `knowledge-base/wiki/concepts/`:
      - One file per concept
      - Include definition, context, related concepts as [[wikilinks]]
      - Add backlinks to the source
   d. Write or update articles in `knowledge-base/wiki/articles/`:
      - Longer-form pieces that synthesize multiple sources
      - Include [[wikilinks]] to concepts and sources
      - Add backlinks
3. Update the source's status to "compiled" in `raw/_sources.md`
4. Update `knowledge-base/_index.md` with new entries and statistics
5. Report what was compiled and any suggested follow-up actions
PROMPT
echo ""
echo "------- END PROMPT -------"
