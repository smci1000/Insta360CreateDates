#!/bin/bash
# Unit test for parse_timestamp in update_timestamps.sh

source ../../update_timestamps.sh

test_parse_timestamp() {
    local filename="$1"
    local expected="$2"
    local result
    result=$(parse_timestamp "$filename")
    if [[ "$result" == "$expected" ]]; then
        echo "PASS: $filename -> $result"
    else
        echo "FAIL: $filename -> $result (expected: $expected)"
    fi
}

test_parse_timestamp "IMG_20250731_102852_00_068.jpg" "202507311028.52"
test_parse_timestamp "VID_20240815_143027_01_001.mp4" "202408151430.27"
test_parse_timestamp "IMG_20251331_102852_00_068.jpg" ""
test_parse_timestamp "IMG_20250731_00_068.jpg" ""
test_parse_timestamp "random_photo.jpg" ""
test_parse_timestamp "VID_20231201_235959_01_001.mp4" "202312012359.59"
test_parse_timestamp "IMG_20250815_153036_00_017.jpg" "202508151530.36"