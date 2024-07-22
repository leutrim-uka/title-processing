#!/bin/bash

# Directory containing json.xz files
input_dir="/app/data"

# Directory to store the output JSON files
output_dir="/app/title_jsons"

# Create the output directory if it does not exist
mkdir -p "$output_dir"

# Define a function to process each file
process_file() {
  local file="$1"
  local output_dir="$2"

  # Get the base name of the file without extension
  local base_name
  base_name=$(basename "$file" .json.xz)
  
  # Output file path in the new directory
  local output_file="$output_dir/$base_name.json"

  # Initialize an empty JSON object
  echo "{}" > "$output_file"

  # Decompress the file, extract id and title, and format as JSON pairs
  xzcat "$file" | jq -c '{id: .coreId, title: .title} | select(.coreId and .title)' | while IFS= read -r line; do
    local coreId
    local title
    coreId=$(echo "$line" | jq -r '.coreId')
    title=$(echo "$line" | jq -r '.title')
    
    # Add the coreId-title pair to the JSON object
    jq --arg coreId "$coreId" --arg title "$title" \
       '. + {($coreId): $title}' "$output_file" > "$output_file.tmp" && mv "$output_file.tmp" "$output_file"
  done
}

export -f process_file

# Find all .json.xz files in the input directory
shopt -s nullglob
json_xz_files=("$input_dir"/*.json.xz)

# Check if there are any .json.xz files
if [ ${#json_xz_files[@]} -eq 0 ]; then
  echo "No .json.xz files found in the input directory."
  exit 1
fi

# Run the processing in parallel without progress reporting
printf "%s\n" "${json_xz_files[@]}" | parallel -j 40 process_file {} "$output_dir"

echo "Processing completed."
