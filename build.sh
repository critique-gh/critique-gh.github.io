#!/bin/sh

INPUT_DIR="input"
OUTPUT_DIR="output"
TEMPLATE="template.html"
STYLE="style.css"

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.md; do
  filename=$(basename "$file" .md)
  pandoc "$file" --standalone --template="$TEMPLATE" -o "$OUTPUT_DIR/$filename.html" --css="../$STYLE"
done

