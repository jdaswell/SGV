#!/usr/bin/env bash
# search.sh — Search the knowledge base wiki
#
# Usage: bash search.sh <query> [--context N]
#
# Examples:
#   bash search.sh "catering"
#   bash search.sh "vendor agreement" --context 3
#   bash search.sh "food cost" --context 5

set -euo pipefail

KB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WIKI_DIR="$KB_DIR/wiki"
CONTEXT=2

if [ $# -lt 1 ]; then
    echo "Usage: bash search.sh <query> [--context N]"
    exit 1
fi

QUERY="$1"
shift

while [ $# -gt 0 ]; do
    case "$1" in
        --context)
            CONTEXT="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

echo "============================================"
echo " SGV Knowledge Base — Search"
echo " Query: \"$QUERY\""
echo "============================================"
echo ""

# Search wiki files
RESULTS=0
for f in $(find "$WIKI_DIR" -name '*.md' 2>/dev/null | sort); do
    MATCHES=$(grep -i -n "$QUERY" "$f" 2>/dev/null || true)
    if [ -n "$MATCHES" ]; then
        REL_PATH="${f#$KB_DIR/}"
        echo "--- $REL_PATH ---"
        grep -i -C "$CONTEXT" "$QUERY" "$f" 2>/dev/null || true
        echo ""
        RESULTS=$((RESULTS + 1))
    fi
done

# Also search raw sources
for f in $(find "$KB_DIR/raw" -name '*.md' 2>/dev/null | sort); do
    MATCHES=$(grep -i -n "$QUERY" "$f" 2>/dev/null || true)
    if [ -n "$MATCHES" ]; then
        REL_PATH="${f#$KB_DIR/}"
        echo "--- $REL_PATH (raw) ---"
        grep -i -C "$CONTEXT" "$QUERY" "$f" 2>/dev/null || true
        echo ""
        RESULTS=$((RESULTS + 1))
    fi
done

# Also search index
if grep -i -q "$QUERY" "$KB_DIR/_index.md" 2>/dev/null; then
    echo "--- _index.md ---"
    grep -i -C "$CONTEXT" "$QUERY" "$KB_DIR/_index.md" 2>/dev/null || true
    echo ""
    RESULTS=$((RESULTS + 1))
fi

echo "============================================"
echo " Found matches in $RESULTS file(s)"
echo "============================================"
