#!/usr/bin/env python3
"""Parse one or more PDFs using opendataloader-pdf and write output to the output/ directory."""

import sys
import opendataloader_pdf

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/parse_pdf.py <file.pdf> [file2.pdf ...]")
        print("Output is written to ./output/ as markdown and json.")
        sys.exit(1)

    input_paths = sys.argv[1:]
    opendataloader_pdf.convert(
        input_path=input_paths,
        output_dir="output/",
        format="markdown,json",
    )

if __name__ == "__main__":
    main()
