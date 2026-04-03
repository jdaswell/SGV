#!/usr/bin/env bash
# ingest.sh — Register a new source document into the knowledge base
#
# Usage: bash ingest.sh <file_path> "<description>" [type]
# Types: article, paper, transcript, dataset, notes, image, repo
#
# Example: bash ingest.sh ~/Downloads/food-trends-2026.md "Food trend predictions for 2026" article

set -euo pipefail

KB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RAW_DIR="$KB_DIR/raw"
SOURCES_FILE="$RAW_DIR/_sources.md"

if [ $# -lt 2 ]; then
    echo "Usage: bash ingest.sh <file_path> \"<description>\" [type]"
    echo "Types: article, paper, transcript, dataset, notes, image, repo"
    exit 1
fi

SOURCE_FILE="$1"
DESCRIPTION="$2"
SOURCE_TYPE="${3:-notes}"
DATE=$(date +%Y-%m-%d)

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: File not found: $SOURCE_FILE"
    exit 1
fi

# Copy file to raw/
FILENAME=$(basename "$SOURCE_FILE")
cp "$SOURCE_FILE" "$RAW_DIR/$FILENAME"
echo "Copied $FILENAME to raw/"

# Generate source ID from filename
SOURCE_ID=$(echo "$FILENAME" | sed 's/\.[^.]*$//' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

# Append to sources registry
cat >> "$SOURCES_FILE" << EOF

### $SOURCE_ID — $FILENAME
- **File:** \`raw/$FILENAME\`
- **Type:** $SOURCE_TYPE
- **Date ingested:** $DATE
- **Description:** $DESCRIPTION
- **Status:** unprocessed
- **Wiki links:** *pending compilation*
EOF

echo "Registered source: $SOURCE_ID"
echo "Type: $SOURCE_TYPE"
echo "Status: unprocessed — run compilation to process into wiki"
