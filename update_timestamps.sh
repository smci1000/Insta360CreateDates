#!/bin/bash

# Bash script to parse timestamps from IMG_/VID_ filenames and update filesystem timestamps
# Example: IMG_20250731_102852_00_068.jpg -> 2025-07-31 10:28:52

echo "Filesystem Timestamp Updater (Bash)"
echo "===================================="

# Function to parse timestamp from filename
parse_timestamp() {
    local filename="$1"
    local basename=$(basename "$filename")
    
    # Use regex to extract YYYYMMDD_HHMMSS from IMG_/VID_ prefix
    if [[ $basename =~ ^(IMG|VID)_([0-9]{8})_([0-9]{6}) ]]; then
        local date_str="${BASH_REMATCH[2]}"  # YYYYMMDD
        local time_str="${BASH_REMATCH[3]}"  # HHMMSS
        
        # Extract components
        local year="${date_str:0:4}"
        local month="${date_str:4:2}"
        local day="${date_str:6:2}"
        local hour="${time_str:0:2}"
        local minute="${time_str:2:2}"
        local second="${time_str:4:2}"
        
        # Validate date components
        if ((10#$month >= 1 && 10#$month <= 12 && 10#$day >= 1 && 10#$day <= 31 &&
              10#$hour >= 0 && 10#$hour <= 23 && 10#$minute >= 0 && 10#$minute <= 59 &&
              10#$second >= 0 && 10#$second <= 59)); then
            # Format for touch command: [[CC]YY]MMDDhhmm[.ss]
            local touch_format="${year}${month}${day}${hour}${minute}.${second}"
            echo "$touch_format"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Function to update file timestamps
update_file_timestamp() {
    local file="$1"
    local timestamp_format="$2"
    
    if [ -n "$timestamp_format" ]; then
        if touch -t "$timestamp_format" "$file" 2>/dev/null; then
            echo "✓ Updated timestamps for $(basename "$file")"
        else
            echo "✗ Error updating timestamps for $(basename "$file")"
        fi
    else
        echo "⚠ Skipping $(basename "$file"): Could not parse timestamp from filename"
    fi
}

# Count files
image_count=$(find . -maxdepth 1 -name "*.jpg" -o -name "*.JPG" | wc -l)
video_count=$(find . -maxdepth 1 -name "*.mp4" -o -name "*.MP4" | wc -l)
total_files=$((image_count + video_count))

if [ $total_files -eq 0 ]; then
    echo "No .jpg or .mp4 files found in current directory."
    exit 0
fi

echo "Found $image_count image files and $video_count video files."
echo ""

processed=0
skipped=0

# Process .jpg files
for file in *.jpg *.JPG; do
    # Skip if glob doesn't match any files
    [ ! -f "$file" ] && continue
    
    timestamp_format=$(parse_timestamp "$file")
    
    if [ -n "$timestamp_format" ]; then
        update_file_timestamp "$file" "$timestamp_format"
        ((processed++))
    else
        echo "⚠ Skipping $file: Could not parse timestamp from filename"
        ((skipped++))
    fi
done

# Process .mp4 files
for file in *.mp4 *.MP4; do
    # Skip if glob doesn't match any files
    [ ! -f "$file" ] && continue
    
    timestamp_format=$(parse_timestamp "$file")
    
    if [ -n "$timestamp_format" ]; then
        update_file_timestamp "$file" "$timestamp_format"
        ((processed++))
    else
        echo "⚠ Skipping $file: Could not parse timestamp from filename"
        ((skipped++))
    fi
done

echo ""
echo "Processing complete: $processed files updated, $skipped files skipped."