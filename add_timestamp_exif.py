#!/usr/bin/env python3
"""
Script to parse timestamps from IMG_/VID_ filenames and add them as EXIF data.
Example filename: IMG_20250731_102852_00_068.jpg -> 2025-07-31 10:28:52
"""

import os
import re
import glob
from datetime import datetime
from PIL import Image
from PIL.ExifTags import TAGS
import piexif
import subprocess
import sys
import time

def parse_timestamp_from_filename(filename):
    """
    Parse timestamp from filename format: IMG_YYYYMMDD_HHMMSS or VID_YYYYMMDD_HHMMSS
    Returns datetime object or None if parsing fails
    """
    # Remove path and get just the filename
    basename = os.path.basename(filename)
    
    # Pattern to match IMG_/VID_ followed by YYYYMMDD_HHMMSS
    pattern = r'^(?:IMG|VID)_(\d{8})_(\d{6})'
    match = re.match(pattern, basename)
    
    if not match:
        return None
    
    date_str = match.group(1)  # YYYYMMDD
    time_str = match.group(2)  # HHMMSS
    
    try:
        # Parse date: YYYYMMDD
        year = int(date_str[:4])
        month = int(date_str[4:6])
        day = int(date_str[6:8])
        
        # Parse time: HHMMSS
        hour = int(time_str[:2])
        minute = int(time_str[2:4])
        second = int(time_str[4:6])
        
        return datetime(year, month, day, hour, minute, second)
    except ValueError as e:
        print(f"Error parsing timestamp from {filename}: {e}")
        return None

def add_exif_to_image(image_path, timestamp):
    """
    Add timestamp to image EXIF data
    """
    try:
        # Load existing EXIF data
        img = Image.open(image_path)
        
        # Get existing EXIF data or create new
        if 'exif' in img.info:
            exif_dict = piexif.load(img.info['exif'])
        else:
            exif_dict = {"0th": {}, "Exif": {}, "GPS": {}, "1st": {}, "thumbnail": None}
        
        # Format timestamp for EXIF (YYYY:MM:DD HH:MM:SS)
        timestamp_str = timestamp.strftime("%Y:%m:%d %H:%M:%S")
        
        # Add timestamp to EXIF data
        exif_dict['Exif'][piexif.ExifIFD.DateTimeOriginal] = timestamp_str
        exif_dict['Exif'][piexif.ExifIFD.DateTimeDigitized] = timestamp_str
        exif_dict['0th'][piexif.ImageIFD.DateTime] = timestamp_str
        
        # Convert back to bytes
        exif_bytes = piexif.dump(exif_dict)
        
        # Save image with new EXIF data
        img.save(image_path, exif=exif_bytes)
        print(f"✓ Updated EXIF for {os.path.basename(image_path)}: {timestamp_str}")
        
    except Exception as e:
        print(f"✗ Error updating EXIF for {image_path}: {e}")

def add_timestamp_to_video(video_path, timestamp):
    """
    Add timestamp metadata to video using ffmpeg
    """
    try:
        # Create temporary output file
        temp_path = video_path + ".temp"
        
        # Format timestamp for video metadata (ISO 8601)
        timestamp_str = timestamp.strftime("%Y-%m-%dT%H:%M:%S")
        
        # Use ffmpeg to add creation_time metadata
        cmd = [
            'ffmpeg', '-i', video_path,
            '-c', 'copy',  # Don't re-encode
            '-metadata', f'creation_time={timestamp_str}',
            '-y',  # Overwrite output
            temp_path
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            # Replace original with updated file
            os.replace(temp_path, video_path)
            print(f"✓ Updated metadata for {os.path.basename(video_path)}: {timestamp_str}")
        else:
            print(f"✗ Error updating metadata for {video_path}: {result.stderr}")
            # Clean up temp file if it exists
            if os.path.exists(temp_path):
                os.remove(temp_path)
                
    except Exception as e:
        print(f"✗ Error updating metadata for {video_path}: {e}")

def update_file_timestamps(file_path, timestamp):
    """
    Update filesystem creation and modification times
    """
    try:
        # Convert datetime to timestamp
        timestamp_epoch = timestamp.timestamp()
        
        # Update access time and modification time
        os.utime(file_path, (timestamp_epoch, timestamp_epoch))
        
        print(f"✓ Updated filesystem timestamps for {os.path.basename(file_path)}")
        
    except Exception as e:
        print(f"✗ Error updating filesystem timestamps for {file_path}: {e}")

def check_dependencies():
    """
    Check if required dependencies are available
    """
    try:
        import PIL
        import piexif
    except ImportError as e:
        print(f"Missing Python dependency: {e}")
        print("Install with: pip install Pillow piexif")
        return False
    
    # Check for ffmpeg
    try:
        subprocess.run(['ffmpeg', '-version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("ffmpeg not found. Please install ffmpeg for video processing.")
        print("Video files will be skipped.")
        return "no_ffmpeg"
    
    return True

def main():
    """
    Main function to process all .jpg and .mp4 files in current directory
    """
    print("Timestamp EXIF Data Updater")
    print("=" * 40)
    
    # Check dependencies
    deps_status = check_dependencies()
    if deps_status is False:
        sys.exit(1)
    
    process_videos = deps_status is True
    
    # Find all .jpg and .mp4 files
    image_files = glob.glob("*.jpg") + glob.glob("*.JPG")
    video_files = glob.glob("*.mp4") + glob.glob("*.MP4") if process_videos else []
    
    all_files = image_files + video_files
    
    if not all_files:
        print("No .jpg or .mp4 files found in current directory.")
        return
    
    print(f"Found {len(image_files)} image files and {len(video_files)} video files.")
    print()
    
    processed = 0
    skipped = 0
    
    for file_path in all_files:
        timestamp = parse_timestamp_from_filename(file_path)
        
        if timestamp is None:
            print(f"⚠ Skipping {file_path}: Could not parse timestamp from filename")
            skipped += 1
            continue
        
        file_ext = os.path.splitext(file_path)[1].lower()
        
        if file_ext in ['.jpg', '.jpeg']:
            add_exif_to_image(file_path, timestamp)
        elif file_ext == '.mp4' and process_videos:
            add_timestamp_to_video(file_path, timestamp)
        
        # Update filesystem timestamps for all files
        update_file_timestamps(file_path, timestamp)
        
        processed += 1
    
    print()
    print(f"Processing complete: {processed} files updated, {skipped} files skipped.")

if __name__ == "__main__":
    main()