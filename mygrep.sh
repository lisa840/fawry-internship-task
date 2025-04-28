#!/bin/bash

# Function to display usage instructions
usage() {
  echo "Usage: $0 [OPTIONS] SEARCH_STRING FILE"
  echo "Options:"
  echo "  -n        Show line numbers for matches"
  echo "  -v        Invert the match (print lines that do NOT match)"
  echo "  --help    Display this help message"
  exit 1
}

# Check if the --help flag is used anywhere
for arg in "$@"; do
  if [ "$arg" = "--help" ]; then
    usage
  fi
done

# Ensure there are enough arguments (at least a search string and a filename)
if [ "$#" -lt 2 ]; then
  echo "Error: Not enough arguments provided."
  usage
fi

# Initialize option flags
show_line_numbers=0
invert_match=0

# Parse options using getopts
while getopts "nv" opt; do
  case $opt in
    n)
      show_line_numbers=1
      ;;
    v)
      invert_match=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      ;;
  esac
done

# Remove parsed options from the arguments list
shift $((OPTIND - 1))

# Check again after shifting that we have a search string and a filename
if [ "$#" -lt 2 ]; then
  echo "Error: Missing search string or file."
  usage
fi

# Assign the arguments to variables
search_string=$1
file=$2

# Check if the file exists
if [ ! -f "$file" ]; then
  echo "Error: File '$file' not found."
  exit 1
fi

# Read the file line by line and process each line
line_number=0
while IFS= read -r line; do
  line_number=$((line_number + 1))
  
  # Perform a case-insensitive search
  echo "$line" | grep -qi "$search_string"
  result=$?

  # If the invert flag (-v) is set, flip the match result
  if [ $invert_match -eq 1 ]; then
    result=$((! result))
  fi

  # If a match (or inverted match) is found, print it (with line numbers if specified)
  if [ $result -eq 0 ]; then
    if [ $show_line_numbers -eq 1 ]; then
      echo "$line_number:$line"
    else
      echo "$line"
    fi
  fi
done < "$file"
