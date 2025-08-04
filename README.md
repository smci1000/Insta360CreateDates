This entire repo was built by claude code.

# Insta 360 Exif and Create Data

A collection of cross-platform scripts to parse timestamps from filenames of exported images and videos from Insta 360 Studio and apply them to file metadata and filesystem timestamps.

## Overview

These scripts parse timestamps from filenames with the format `IMG_YYYYMMDD_HHMMSS_*.jpg` or `VID_YYYYMMDD_HHMMSS_*.mp4` and apply the extracted timestamps to:
- EXIF data within images
- Video metadata 
- Filesystem creation and modification times

## Filename Format

The scripts expect filenames in this format:
```
IMG_20250731_102852_00_068.jpg  → July 31, 2025 at 10:28:52 AM
VID_20240815_143027_01_001.mp4  → August 15, 2024 at 2:30:27 PM
```

**Format breakdown:**
- `IMG_` or `VID_` prefix (ignored)
- `YYYYMMDD` - Date (year, month, day)
- `HHMMSS` - Time in 24-hour format (hour, minute, second)
- Additional suffix (ignored)

## Scripts

### 1. Bash Script (Lightweight) - `update_timestamps.sh`

**Features:**
- ✅ Updates filesystem timestamps only
- ✅ No external dependencies
- ✅ Works on Linux, macOS, and WSL

**Usage:**
```bash
chmod +x update_timestamps.sh
./update_timestamps.sh
```

### 2. PowerShell Script (Windows) - `Update-Timestamps.ps1`

**Features:**
- ✅ Updates filesystem timestamps only
- ✅ No external dependencies
- ✅ Works on Windows PowerShell and PowerShell Core

**Usage:**
```powershell
.\Update-Timestamps.ps1
```

### 3. Python Script (Advanced Users) - `add_timestamp_exif.py`

**Features:**
- ✅ Updates EXIF data in JPEG images
- ✅ Updates metadata in MP4 videos (requires ffmpeg)
- ✅ Updates filesystem timestamps
- ✅ Comprehensive error handling and reporting

**Dependencies:**
```bash
pip install Pillow piexif
```

**Optional (for video processing):**
- `ffmpeg` - Install from [ffmpeg.org](https://ffmpeg.org/download.html)

**Usage:**
```bash
python add_timestamp_exif.py
```

## Installation

1. **Clone or download** the scripts to your target directory
2. **For most users:** No additional setup required - use the bash or PowerShell scripts 
3. **For advanced users (Python script only):**
   ```bash
   pip install Pillow piexif
   ```
4. **Install ffmpeg** (optional, for Python video metadata):
   - Windows: Download from [ffmpeg.org](https://ffmpeg.org/download.html)
   - macOS: `brew install ffmpeg`
   - Linux: `sudo apt install ffmpeg` (Ubuntu/Debian) or equivalent

## Usage Examples

### Process files in current directory:
```bash
# Bash (filesystem timestamps - recommended for Linux/macOS/WSL)
./update_timestamps.sh

# PowerShell (filesystem timestamps - recommended for Windows)
.\Update-Timestamps.ps1

# Python (advanced users - full EXIF/metadata features)
python add_timestamp_exif.py
```

### Example output:
```
Timestamp EXIF Data Updater
============================
Found 5 image files and 2 video files.

✓ Updated EXIF for IMG_20250731_102852_00_068.jpg: 2025:07:31 10:28:52
✓ Updated filesystem timestamps for IMG_20250731_102852_00_068.jpg
✓ Updated metadata for VID_20240815_143027_01_001.mp4: 2024-08-15T14:30:27
✓ Updated filesystem timestamps for VID_20240815_143027_01_001.mp4
⚠ Skipping random_photo.jpg: Could not parse timestamp from filename

Processing complete: 6 files updated, 1 files skipped.
```

## What Gets Updated

| Script | EXIF Data | Video Metadata | Filesystem Timestamps |
|--------|-----------|----------------|----------------------|
| Bash | ❌ No | ❌ No | ✅ Yes |
| PowerShell | ❌ No | ❌ No | ✅ Yes |
| Python | ✅ Yes | ✅ Yes (with ffmpeg) | ✅ Yes |

### EXIF Data Fields Updated (Python script):
- `DateTimeOriginal` - When the photo was taken
- `DateTimeDigitized` - When the photo was digitized
- `DateTime` - General timestamp

### Video Metadata Updated (Python script):
- `creation_time` - Video creation timestamp

### Filesystem Timestamps Updated (All scripts):
- **Creation time** - When the file was created
- **Modification time** - When the file was last modified
- **Access time** - When the file was last accessed

## Platform Compatibility

| Platform | Python Script | Bash Script | PowerShell Script |
|----------|---------------|-------------|-------------------|
| Windows | ✅ Yes | ✅ WSL only | ✅ Yes |
| macOS | ✅ Yes | ✅ Yes | ✅ PowerShell Core |
| Linux | ✅ Yes | ✅ Yes | ✅ PowerShell Core |

## Error Handling

All scripts include comprehensive error handling:
- **Invalid filenames** are skipped with warnings
- **Missing dependencies** are detected and reported
- **File access errors** are logged but don't stop processing
- **Malformed timestamps** are validated before processing

## Troubleshooting

### Python Script Issues

**"No module named 'PIL'"**
```bash
pip install Pillow piexif
```

**"ffmpeg not found"**
- Videos will be skipped
- Install ffmpeg or run script without video files

**"Permission denied"**
- Ensure files are not read-only
- Run with appropriate permissions

### Bash Script Issues

**"Permission denied"**
```bash
chmod +x update_timestamps.sh
```

**"touch: invalid date format"**
- Check filename format matches expected pattern
- Ensure date components are valid

### PowerShell Script Issues

**"Execution policy restriction"**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**"UnauthorizedAccessException"**
- Ensure files are not read-only
- Run PowerShell as Administrator if needed

## File Safety

- All scripts work **in-place** on original files
- **No backup copies** are created automatically
- Test on copies of important files first
- The Python script creates temporary files for video processing but cleans them up

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve these scripts.

## License

These scripts are provided as-is for educational and personal use.
