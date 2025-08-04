#!/bin/sh

INPUT_DIR="input"
OUTPUT_DIR="docs"
TEMPLATE="template.html"

mkdir -p "$INPUT_DIR" "$OUTPUT_DIR"

generate_index() {
  INDEX_MD="$INPUT_DIR/index.md"
  echo "% Home" > "$INDEX_MD"
  echo "" >> "$INDEX_MD"
  cat about.md >> "$INDEX_MD"
  echo "" >> "$INDEX_MD"
  echo "# Posts" >> "$INDEX_MD"
  echo "" >> "$INDEX_MD"

  # List .md files with modification times, excluding index.md
  find "$INPUT_DIR" -type f -name '*.md' ! -name 'index.md' \
    -exec stat -c "%Y %n" {} + \
    | sort -nr \
    | while read -r timestamp path; do
        filename=$(basename "$path" .md)
        title=$(grep '^%' "$path" | head -n 1 | sed 's/^% *//')
        [ -z "$title" ] && title="$filename"
        date=$(date -d @"$timestamp" "+%Y-%m-%d")
        printf -- "- [%s](%s.html) — %s\n" "$title" "$filename" "$date" >> "$INDEX_MD"
      done
}

create_new_post() {
  printf "Enter new post name (without .md): "
  read -r name
  # Escape backslashes and replace spaces with underscores
  safe_name=$(echo "$name" | tr -d '\\' | tr ' ' '_')
  echo $safe_name
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
  ${EDITOR:-nvim} "$filepath"
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

