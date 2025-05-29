function ffmpegMetadata {
    # Define source and destination directories
    $dir = "D:\Media\Tutorialy\.capture\a\LiveCentral\Handbrake"
    $destDir = "D:\Media\Tutorialy\.capture\a\LiveCentral\0"

    # Get all .mp4 files in the source directory
    Get-ChildItem -Path $dir -Filter *.mp4 -File | ForEach-Object {
        $file = $_.FullName
        $filename = $_.Name
        $outputFile = Join-Path $destDir $filename

        # Run ffmpeg to copy metadata-stripped video
        ffmpeg -i "$file" -map_metadata -1 -metadata title="$filename" -c:v copy -c:a copy -c:s copy "$outputFile"
    }
}
