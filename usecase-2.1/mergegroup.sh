#!/bin/bash

output="merged_group.tsv"
> "$output"  

for folder in $(ls | grep -E 'group-[0-9]+' | sort -t'-' -k2 -n); do
    file="${folder}/group/results.tsv"
    
    if [[ -f "$file" ]]; then
        echo "Processing: $file"
        
        row=$(cat "$file")
        
        if [[ -n "$row" ]]; then
            echo -e "$row" >> "$output"
        else
            echo "Warning: $file is empty"
        fi
    else
        echo "Warning: $file not found"
    fi
done

if [[ -s "$output" ]]; then
    echo "Matrix created successfully."
else
    echo "No valid data found."
fi

