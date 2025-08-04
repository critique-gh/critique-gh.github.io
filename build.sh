#!/bin/sh

INPUT_DIR="input"
OUTPUT_DIR="docs"
TEMPLATE="template.html"

mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

generate_index() {
  INDEX_MD="$INPUT_DIR/index.md"
  echo "% Home" > "$INDEX_MD"
  echo "" >> "$INDEX_MD"
  echo "# Posts" >> "$INDEX_MD"
  echo "" >> "$INDEX_MD"

  for file in "$INPUT_DIR"/*.md; do
    [ "$file" = "$INDEX_MD" ] && continue
    filename=$(basename "$file" .md)
    title=$(grep '^%' "$file" | head -n 1 | sed 's/^% *//')
    timestamp=$(stat -c %y "$file" 2>/dev/null | cut -d'.' -f1)
    echo "- [$title]($filename.html) — $timestamp" >> "$INDEX_MD"
  done
}

create_new_post() {
  printf "Enter new post name (without .md): "
  read -r name
  # Escape backslashes and replace spaces with underscores
  safe_name=$(echo "$name" | tr -d '\\' | tr '[:space:]' '_')
  filepath="$INPUT_DIR/$safe_name.md"

  if [ -f "$filepath" ]; then
    echo "File already exists: $filepath"
    exit 1
  fi

  title=$(basename "$name")
  echo "% $title" > "$filepath"
  echo "" >> "$filepath"
  echo "# $title" >> "$filepath"
  echo "" >> "$filepath"
  echo "(Write your post below...)" >> "$filepath"
  ${EDITOR:-vi} "$filepath"
  echo "Created: $filepath"
}


build_all() {
  for file in "$INPUT_DIR"/*.md; do
    filename=$(basename "$file" .md)
    title=$(grep '^%' "$file" | head -n 1 | sed 's/^% *//')
    [ -z "$title" ] && title="$filename"

    pandoc "$file" \
      --template="$TEMPLATE" \
      -o "$OUTPUT_DIR/$filename.html" \
      --metadata title="$title"
  done
  echo "Site built in $OUTPUT_DIR/"
}

# Main logic
case "$1" in
  --new)
    create_new_post
    ;;
  *)
    generate_index
    build_all
    ;;
esac

