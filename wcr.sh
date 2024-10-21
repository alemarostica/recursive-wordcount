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
  printf "Usage: %s [options]\n" "$0"
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

# Settings
verbose=false
lines=false
chars=false
words=false
bytes=false

# Counters
lines_count=0
words_count=0

# Extensions
exts=()

# Directory
dir="$PWD"

# Misc
mode_args=0

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

if [[ $mode_args == 0 ]]; then
  lines=true
fi

echo "Directory: $dir"
echo -n "Extensions: "
for item in "${exts[@]}"; do
  echo -n "$item "
done
printf "\n"

for ext in "${exts[@]}"; do
  # echo "trying $ext"
  while IFS= read -r file; do
    if [ -f "$file" ] && [[ "$file" == *."$ext" ]]; then
      if $lines; then 
        lines_c=$(wc -l <"$file")
        lines_count=$((lines_count + lines_c))
      fi
      if $words; then
        words_c=$(wc -w <"$file")
        words_count=$((words_count + words_c))
      fi
      if $chars; then
        chars_c=$(wc -c <"$file")
        chars_count=$((chars_count + chars_c))
      fi
      if $bytes; then
        bytes_c=$(wc --bytes <"$file")
        bytes_count=$((bytes_count + bytes_c))
      fi
      [[ $verbose == true && $lines == true ]] && printf "%s: %d lines\n" "$file" "$lines_count"
      [[ $verbose == true && $words == true ]] && printf "%s: %d words\n" "$file" "$words_count"
      [[ $verbose == true && $chars == true ]] && printf "%s: %d chars\n" "$file" "$chars_count"
      [[ $verbose == true && $bytes == true ]] && printf "%s: %d bytes\n" "$file" "$bytes_count"
    fi
  done < <(find "$dir" -type f)
done

[[ $lines == true ]] && echo "Total lines: $lines_count"
[[ $words == true ]] && echo "Total words: $words_count"
[[ $chars == true ]] && echo "Total chars: $chars_count"
[[ $bytes == true ]] && echo "Total bytes: $bytes_count"
