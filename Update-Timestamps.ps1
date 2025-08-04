# PowerShell script to parse timestamps from IMG_/VID_ filenames and update filesystem timestamps
# Example: IMG_20250731_102852_00_068.jpg -> 2025-07-31 10:28:52

Write-Host "Filesystem Timestamp Updater (PowerShell)" -ForegroundColor Cyan
Write-Host "=========================================="

function Parse-TimestampFromFilename {
    param([string]$Filename)
    
    $basename = [System.IO.Path]::GetFileName($Filename)
    
    # Regex to match IMG_/VID_ followed by YYYYMMDD_HHMMSS
    if ($basename -match '^(IMG|VID)_(\d{8})_(\d{6})') {
        $dateStr = $matches[2]  # YYYYMMDD
        $timeStr = $matches[3]  # HHMMSS
        
        # Extract components
        $year = [int]$dateStr.Substring(0, 4)
        $month = [int]$dateStr.Substring(4, 2)
        $day = [int]$dateStr.Substring(6, 2)
        $hour = [int]$timeStr.Substring(0, 2)
        $minute = [int]$timeStr.Substring(2, 2)
        $second = [int]$timeStr.Substring(4, 2)
        
        try {
            # Create DateTime object and validate
            $timestamp = New-Object DateTime($year, $month, $day, $hour, $minute, $second)
            return $timestamp
        }
        catch {
            return $null
        }
    }
    else {
        return $null
    }
}

function Update-FileTimestamp {
    param(
        [string]$FilePath,
        [DateTime]$Timestamp
    )
    
    try {
        $file = Get-Item $FilePath
        $file.CreationTime = $Timestamp
        $file.LastWriteTime = $Timestamp
        $file.LastAccessTime = $Timestamp
        
        Write-Host "✓ Updated timestamps for $($file.Name)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Error updating timestamps for $(Split-Path $FilePath -Leaf): $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Find all .jpg and .mp4 files in current directory
$imageFiles = Get-ChildItem -Path . -Name "*.jpg" -File
$imageFiles += Get-ChildItem -Path . -Name "*.JPG" -File
$videoFiles = Get-ChildItem -Path . -Name "*.mp4" -File
$videoFiles += Get-ChildItem -Path . -Name "*.MP4" -File

$allFiles = @($imageFiles) + @($videoFiles)
$imageCount = @($imageFiles).Count
$videoCount = @($videoFiles).Count

if ($allFiles.Count -eq 0) {
    Write-Host "No .jpg or .mp4 files found in current directory." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $imageCount image files and $videoCount video files."
Write-Host ""

$processed = 0
$skipped = 0

foreach ($file in $allFiles) {
    $timestamp = Parse-TimestampFromFilename -Filename $file
    
    if ($timestamp -ne $null) {
        $success = Update-FileTimestamp -FilePath $file -Timestamp $timestamp
        if ($success) {
            $processed++
        }
    }
    else {
        Write-Host "⚠ Skipping $file`: Could not parse timestamp from filename" -ForegroundColor Yellow
        $skipped++
    }
}

Write-Host ""
Write-Host "Processing complete: $processed files updated, $skipped files skipped." -ForegroundColor Cyan