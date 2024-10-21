#!/bin/bash

# Recursive Wordcount counts lines or words recursively for specified file types
# Copyright (C) 2024 Alessandro Marostica - me@alessandromarostica.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Display usage info
usage() {
  echo "Recursive Word Count"
  printf "Usage: %s [options] -d <ext1> <ext2> ...\n" "$0"
  echo "Defaults to only count lines"
  echo "Options:"
  echo "  -h, --help                    Show this help message"
  echo "  -v, --verbose                 Print word count for each file"
  echo "  -e, --ext <ext1> <ext2> ...   The file extensions to count lines"
  echo "  -d, --dir <directory>         The directory to operate in, cwd if absent"
  echo "  -l, --lines                   Count lines"
  echo "  -w, --words                   Count words"
  echo "  -c, --chars                   Count characters"
  echo "  -b, --bytes                   Count bytes"
  exit 1
}

# Counters
lines_count=0
words_count=0

# Settings
verbose=false
lines=false
chars=false
words=false
bytes=false

# Extensions
exts=()

# Directory
dir="$PWD"

# Misc
mode_args=0

process_file() {
  local file="$1"
  local local_lines_count=0
  local local_words_count=0
  local local_chars_count=0
  local local_bytes_count=0

  if [ -f "$file" ] && [[ "$file" == *."$ext" ]]; then
    if $lines; then 
      local_lines_count=$(wc -l <"$file")
    fi
    if $words; then
      local_words_count=$(wc -w <"$file")
    fi
    if $chars; then
      local_chars_count=$(wc -c <"$file")
    fi
    if $bytes; then
      local_bytes_count=$(wc --bytes <"$file")
    fi

    echo "$local_lines_count $local_words_count $local_chars_count $local_bytes_count" >> results.tmp

    if  [[ $verbose == true ]]; then
      output="$1: "

      [[ $lines == true ]] && output+="$local_lines_count lines "
      [[ $words == true ]] && output+="$local_words_count words "
      [[ $chars == true ]] && output+="$local_chars_count chars "
      [[ $bytes == true ]] && output+="$local_bytes_count bytes "

      echo "$output"
    fi
  fi
}

# Input parsing
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    ;;
  -v | --verbose)
    verbose=true
    ;;
  -l | --lines)
    lines=true
    mode_args=$((mode_args + 1))
    ;;
  -w | --words)
    words=true
    mode_args=$((mode_args + 1))
    ;;
  -c | --chars)
    chars=true
    mode_args=$((mode_args + 1))
    ;;
  -b | --bytes)
    bytes=true
    mode_args=$((mode_args + 1))
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

if [[ $mode_args -eq 0 ]]; then
  lines=true
fi
if [ ${#exts[@]} -eq 0 ]; then
  echo "No specified extension"
  exit 1
fi

echo "Directory: $dir"
echo -n "Extensions: "
for item in "${exts[@]}"; do
  echo -n "$item "
done
printf "\n"

true > results.tmp

for ext in "${exts[@]}"; do
  # echo "trying $ext"
  while IFS= read -r file; do
    process_file "$file" &
  done < <(find "$dir" -type f)
done

# Wait for all background jobs to finish
wait

while read -r line; do
  read l w c b <<< "$line"
  lines_count=$((lines_count + l))
  words_count=$((words_count + w))
  chars_count=$((chars_count + c))
  bytes_count=$((bytes_count + b))
done < results.tmp

[[ $lines == true ]] && echo "Total lines: $lines_count"
[[ $words == true ]] && echo "Total words: $words_count"
[[ $chars == true ]] && echo "Total chars: $chars_count"
[[ $bytes == true ]] && echo "Total bytes: $bytes_count"

rm results.tmp
