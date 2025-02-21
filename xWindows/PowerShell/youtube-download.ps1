function YoutubeDownload {
    # Get the YouTube link from clipboard
    $link = Get-Clipboard

    # Check if the link looks like a YouTube URL
    if ($link -match "^(https?://)?(www\.)?(youtube\.com|youtu\.be)/") {
        # Change directory to Downloads folder
        Set-Location "$HOME/Downloads"

        Write-Host "Download started for: $link" -ForegroundColor Green

        # Download the video using yt-dlp
        yt-dlp $link

    } else {
        Write-Host "No valid YouTube link found in clipboard." --ForegroundColor Red
    }
}
