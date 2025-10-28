#!/bin/bash

start_date="2022-12-22"
end_date="2023-05-01"

current_date="$start_date"

while [[ "$current_date" < "$end_date" ]] || [[ "$current_date" == "$end_date" ]]; do
  for hour in $(seq -w 0 23); do
    filename="obs:${current_date}_${hour}"
    if [[ ! -f "$filename" ]]; then
      touch "$filename"
      echo "Created missing file: $filename"
    else
      echo "File exists: $filename"
    fi
  done
  # Move to next day
  current_date=$(date -I -d "$current_date + 1 day")
done

