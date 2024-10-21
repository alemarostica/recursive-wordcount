#!/bin/bash

# Display usage info
usage() {
  printf "Usage: %s [options]\n" "$0"
  echo "Options:"
  echo "  -h, --help                    Show this help message"
  echo "  -v, --verbose                 Print word count for each file"
  echo "  -e, --ext <ext1> <ext2> ...   The file extensions to count lines"
  echo "  -d, --dir <directory>         The directory to operate in, cwd if absent"
  exit 1
}

# Settings
verbose=false

# Total counter
lines_count=0

# Extensions
exts=()

# Directory
dir="$PWD"

# Input parsing
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    ;;
  -v | --verbose)
    verbose=true
    ;;
  -e | --ext)
    shift
    while [[ "$#" -gt 0 && -n "$1" ]]; do
      if [[ "$1" =~ ^- ]]; then
        break
      fi
      # echo "$1"
      exts+=("$1")
      shift
    done
    if [[ "$1" =~ ^- ]]; then
      continue
    fi
    ;;
  -d | --dir)
    # echo "dir: $1"
    shift
    if [[ -n "$1" && -d "$1" ]]; then
      dir="$1"
    else
      echo "Error: Directory '$1' does not exist or is not a directory."
      exit 1
    fi
    ;;
  *)
    echo "Invalid argument: '$1'"
    exit 1
    ;;
  esac
  shift
done

echo "Directory: $dir"
echo -n "Extensions: "
for item in "${exts[@]}"; do
  echo -n "$item"
done
printf "\n"

for ext in "${exts[@]}"; do
  # echo "trying $ext"
  while IFS= read -r file; do
    if [ -f "$file" ] && [[ "$file" == *."$ext" ]]; then
      lines=$(wc -l <"$file")
      [[ $verbose == true ]] && printf "File: %s, Lines: %d\n" "$file" "$lines"
      lines_count=$((lines_count + lines))
    fi
  done < <(find "$dir" -type f)
done

echo "Total lines: $lines_count"
