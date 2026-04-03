#!/usr/bin/env bash
# healthcheck.sh — Check knowledge base integrity and suggest improvements
#
# Usage: bash healthcheck.sh

set -euo pipefail

KB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WIKI_DIR="$KB_DIR/wiki"
RAW_DIR="$KB_DIR/raw"
INDEX_FILE="$KB_DIR/_index.md"
ISSUES=0

echo "============================================"
echo " SGV Knowledge Base — Health Check"
echo "============================================"
echo ""

# 1. Count files
RAW_COUNT=$(find "$RAW_DIR" -type f ! -name '_*' | wc -l)
CONCEPT_COUNT=$(find "$WIKI_DIR/concepts" -name '*.md' 2>/dev/null | wc -l)
ARTICLE_COUNT=$(find "$WIKI_DIR/articles" -name '*.md' 2>/dev/null | wc -l)
SOURCE_COUNT=$(find "$WIKI_DIR/sources" -name '*.md' 2>/dev/null | wc -l)

echo "File counts:"
echo "  Raw sources:      $RAW_COUNT"
echo "  Source summaries:  $SOURCE_COUNT"
echo "  Concepts:          $CONCEPT_COUNT"
echo "  Articles:          $ARTICLE_COUNT"
echo ""

# 2. Check for unprocessed sources
UNPROCESSED=$(grep -c '^\- \*\*Status:\*\* unprocessed$' "$RAW_DIR/_sources.md" 2>/dev/null || true)
UNPROCESSED=${UNPROCESSED:-0}
if [ "$UNPROCESSED" -gt 0 ]; then
    echo "[!] $UNPROCESSED unprocessed source(s) — run compilation"
    ISSUES=$((ISSUES + 1))
fi

# 3. Check for raw files not in registry
echo ""
echo "Checking for unregistered raw files..."
for f in "$RAW_DIR"/*; do
    [ -f "$f" ] || continue
    BASENAME=$(basename "$f")
    [ "$BASENAME" = "_sources.md" ] && continue
    if ! grep -q "$BASENAME" "$RAW_DIR/_sources.md" 2>/dev/null; then
        echo "  [!] Unregistered: raw/$BASENAME"
        ISSUES=$((ISSUES + 1))
    fi
done

# 4. Check for broken wikilinks
echo ""
echo "Checking for broken wikilinks..."
BROKEN_LINKS=0
for f in $(find "$WIKI_DIR" -name '*.md' ! -name '_template-*' 2>/dev/null); do
    # Extract [[wikilinks]] from file
    LINKS=$(grep -oP '\[\[([^\]]+)\]\]' "$f" 2>/dev/null | sed 's/\[\[//;s/\]\]//' || true)
    for link in $LINKS; do
        # Check if a matching .md file exists anywhere in wiki/
        FOUND=$(find "$WIKI_DIR" -name "${link}.md" -o -name "$(echo "$link" | tr ' ' '-').md" 2>/dev/null | head -1)
        if [ -z "$FOUND" ]; then
            echo "  [!] Broken link: [[$link]] in $(basename "$f")"
            BROKEN_LINKS=$((BROKEN_LINKS + 1))
        fi
    done
done
if [ "$BROKEN_LINKS" -eq 0 ]; then
    echo "  No broken wikilinks found."
fi
ISSUES=$((ISSUES + BROKEN_LINKS))

# 5. Check index freshness
echo ""
echo "Checking index..."
if [ ! -f "$INDEX_FILE" ]; then
    echo "  [!] Missing _index.md"
    ISSUES=$((ISSUES + 1))
else
    echo "  _index.md exists"
fi

# 6. Word count
echo ""
TOTAL_WORDS=0
for f in $(find "$WIKI_DIR" -name '*.md' ! -name '_template-*' 2>/dev/null); do
    WC=$(wc -w < "$f")
    TOTAL_WORDS=$((TOTAL_WORDS + WC))
done
echo "Total wiki word count: $TOTAL_WORDS"

# Summary
echo ""
echo "============================================"
if [ "$ISSUES" -eq 0 ]; then
    echo " Health check passed — no issues found"
else
    echo " Found $ISSUES issue(s) — review above"
fi
echo "============================================"
echo ""

# Generate LLM prompt for deeper check
if [ "$CONCEPT_COUNT" -gt 0 ] || [ "$ARTICLE_COUNT" -gt 0 ]; then
    echo "For a deeper LLM-powered health check, use this prompt:"
    echo ""
    echo "------- COPY BELOW -------"
    cat << 'PROMPT'
Run a deep health check on the SGV knowledge base:

1. Read `knowledge-base/_index.md` and all wiki articles
2. Check for:
   - Inconsistent data across articles (conflicting facts, dates, numbers)
   - Missing backlinks between related articles
   - Concepts mentioned but not defined
   - Articles that could be split or merged
   - Stale information that may need updating
3. Suggest:
   - New article candidates based on gaps in coverage
   - Interesting connections between existing articles
   - Data that could be enriched with web searches
   - Questions worth investigating further
4. Update any broken links or missing metadata you find
5. Report findings as a health check report in knowledge-base/output/reports/
PROMPT
    echo ""
    echo "------- END PROMPT -------"
fi
