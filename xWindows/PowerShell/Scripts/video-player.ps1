function Create-MpvPlaylist {
    param(
        [array]$VideoFiles,
        [object]$SelectedVideo
    )
    
    # Create temporary playlist file
    $playlistPath = [System.IO.Path]::GetTempFileName().Replace(".tmp", ".m3u")
    
    # Clear the temp file
    Clear-Content -Path $playlistPath -ErrorAction SilentlyContinue
    
    # Add all video files to playlist in proper format for Windows
    $VideoFiles | ForEach-Object {
        $videoPath = $_.FullName
        # Use Windows path format directly - mpv.net handles Windows paths correctly
        Add-Content -Path $playlistPath -Value $videoPath
    }
    
    return $playlistPath
}

function VideoPlayer {
    param(
        [string]$MediaPath = "D:\Media\Filmy"
    )
    
    # Check if fzf is available
    $fzfCommand = Get-Command fzf -ErrorAction SilentlyContinue
    if (-not $fzfCommand) {
        Write-Error "fzf not found. Install with: scoop install fzf"
        return
    }
    
    # Check if mpv.net is available
    $mpvCommand = Get-Command mpvnet -ErrorAction SilentlyContinue
    if (-not $mpvCommand) {
        Write-Error "mpv.net not found. Install with: scoop install mpv.net"
        return
    }
    
    # Check if media path exists and is not null or empty
    if ([string]::IsNullOrWhiteSpace($MediaPath)) {
        Write-Error "Media path is null or empty"
        return
    }
    
    if (-not (Test-Path $MediaPath)) {
        Write-Error "Media path not found: $MediaPath"
        return
    }
    
    # Check for video files directly in MediaPath
    $videoExtensions = @(".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".webm", ".m4v", ".3gp", ".ogv")
    $rootVideos = Get-ChildItem -Path $MediaPath -File | Where-Object { $videoExtensions -contains $_.Extension.ToLower() }
    
    # Get directories for selection
    $directories = Get-ChildItem -Path $MediaPath -Recurse -Directory | ForEach-Object { $_.FullName }
    
    # Add root directory option if there are videos in root
    if ($rootVideos.Count -gt 0) {
        $directories = @($MediaPath) + $directories
    }
    
    if ($directories.Count -eq 0) {
        Write-Host "No directories or videos found in: $MediaPath" -ForegroundColor Yellow
        return
    }
    
    # Select directory using fzf
    Write-Host "Selecting directory from: $MediaPath" -ForegroundColor Cyan
    $selectedDir = $directories | fzf --prompt "Select Directory> " --height 40% --border --header="Use arrow keys, ENTER to select"
    
    if ([string]::IsNullOrWhiteSpace($selectedDir)) {
        Write-Host "No directory selected." -ForegroundColor Yellow
        return
    }
    
    Write-Host "Selected directory: $selectedDir" -ForegroundColor Green
    
    # Find video files in selected directory
    try {
        $videoFiles = Get-ChildItem -Path $selectedDir -Recurse -File | Where-Object { $videoExtensions -contains $_.Extension.ToLower() }
        
        if ($videoFiles.Count -eq 0) {
            Write-Host "No video files found in: $selectedDir" -ForegroundColor Yellow
            return
        }
        
        Write-Host "Found $($videoFiles.Count) video files" -ForegroundColor Green
        
        # Create playlist format with file names and sizes
        $playlist = $videoFiles | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 1)
            "$($_.Name) ($($sizeMB) MB)"
        }
        
        # Select video using fzf
        $selectedVideoName = $playlist | fzf --prompt "Select Video> " --height 50% --border --preview="echo 'Press ENTER to play'" --header="Use arrow keys, TAB to multi-select"
        
        if ([string]::IsNullOrWhiteSpace($selectedVideoName)) {
            Write-Host "No video selected." -ForegroundColor Yellow
            return
        }
        
        # Extract filename from selection (remove size info)
        if ($selectedVideoName -match '^(.+?)\s+\(\d+\.?\d*\s+MB\)$') {
            $fileName = $matches[1].Trim()
            
            # Try to find the video file using multiple approaches
            $selectedVideo = $null
            
            # First try exact name match
            $selectedVideo = $videoFiles | Where-Object { $_.Name -eq $fileName }
            
            # If not found, try case-insensitive match
            if (-not $selectedVideo) {
                $selectedVideo = $videoFiles | Where-Object { $_.Name -eq $fileName -or $_.Name.ToLower() -eq $fileName.ToLower() }
            }
            
            # If still not found, try partial match (first part before encoding issues)
            if (-not $selectedVideo) {
                $cleanName = $fileName -split ' ' | Select-Object -First 1
                $selectedVideo = $videoFiles | Where-Object { $_.Name -like "$cleanName*" }
            }
            
            if ($selectedVideo) {
                Write-Host "Playing: $($selectedVideo.Name)" -ForegroundColor Green
                
                # Try to create playlist-like experience by passing multiple files
                $selectedVideoIndex = $videoFiles.IndexOf($selectedVideo)
                $videosToPlay = @()
                
                # Add videos from selected video onwards (creates playlist-like order)
                for ($i = $selectedVideoIndex; $i -lt $videoFiles.Count; $i++) {
                    $videosToPlay += "`"$($videoFiles[$i].FullName)`""
                }
                
                # Add videos from beginning to selected video (creates circular playlist)
                for ($i = 0; $i -lt $selectedVideoIndex; $i++) {
                    $videosToPlay += "`"$($videoFiles[$i].FullName)`""
                }
                
                Write-Host "  (Playlist with $($videoFiles.Count) videos created)" -ForegroundColor Gray
                
                # Start mpv.net with all videos as arguments (playlist-like behavior)
                Start-Process -FilePath "mpvnet" -ArgumentList $videosToPlay -NoNewWindow
            } else {
                Write-Error "Could not find video file for: $fileName"
                Write-Host "Available files:" -ForegroundColor Yellow
                $videoFiles | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Cyan }
            }
        } else {
            Write-Error "Invalid selection format: $selectedVideoName"
        }
        
    } catch {
        Write-Error "Error processing video files: $($_.Exception.Message)"
    }
}

function VideoPlayerInteractive {
    param(
        [string]$MediaPath = "D:\Media\Filmy"
    )
    
    # Check if fzf is available
    $fzfCommand = Get-Command fzf -ErrorAction SilentlyContinue
    if (-not $fzfCommand) {
        Write-Error "fzf not found. Install with: scoop install fzf"
        return
    }
    
    # Check if mpv.net is available
    $mpvCommand = Get-Command mpvnet -ErrorAction SilentlyContinue
    if (-not $mpvCommand) {
        Write-Error "mpv.net not found. Install with: scoop install mpv.net"
        return
    }
    
    # Check if media path exists and is not null or empty
    if ([string]::IsNullOrWhiteSpace($MediaPath)) {
        Write-Error "Media path is null or empty"
        return
    }
    
    if (-not (Test-Path $MediaPath)) {
        Write-Error "Media path not found: $MediaPath"
        return
    }
    
    # Video extensions
    $videoExtensions = @(".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".webm", ".m4v", ".3gp", ".ogv")
    
    # Directory navigation loop
    $currentDir = $MediaPath
    
    while ($true) {
        Write-Host "Current directory: $currentDir" -ForegroundColor Cyan
        
        # Check for video files directly in current directory
        $rootVideos = Get-ChildItem -Path $currentDir -File | Where-Object { $videoExtensions -contains $_.Extension.ToLower() }
        
        # Get directories for selection
        $directories = Get-ChildItem -Path $currentDir -Recurse -Directory | ForEach-Object { $_.FullName }
        
        # Add current directory option if there are videos in root
        if ($rootVideos.Count -gt 0) {
            $directories = @($currentDir) + $directories
        }
        
        # Add parent directory option (except for root media path)
        if ($currentDir -ne $MediaPath) {
            $parentDir = Split-Path -Path $currentDir -Parent
            $directories = @("../ (Go up)") + $directories
        }
        
        if ($directories.Count -eq 0) {
            Write-Host "No directories or videos found in: $currentDir" -ForegroundColor Yellow
            # Go up if possible
            if ($currentDir -ne $MediaPath) {
                $currentDir = Split-Path -Path $currentDir -Parent
                continue
            } else {
                return
            }
        }
        
        # Select directory using fzf
        $selectedDir = $directories | fzf --prompt "Select Directory> " --height 40% --border --header="Use arrow keys, ENTER to select"
        
        if ([string]::IsNullOrWhiteSpace($selectedDir)) {
            Write-Host "No directory selected." -ForegroundColor Yellow
            continue
        }
        
        # Handle navigation up
        if ($selectedDir -eq "../ (Go up)") {
            $currentDir = Split-Path -Path $currentDir -Parent
            continue
        }
        
        $currentDir = $selectedDir
        Write-Host "Selected directory: $currentDir" -ForegroundColor Green
        
        # Find video files in selected directory
        $videoFiles = Get-ChildItem -Path $currentDir -Recurse -File | Where-Object { $videoExtensions -contains $_.Extension.ToLower() }
        
        if ($videoFiles.Count -eq 0) {
            Write-Host "No video files found in: $currentDir" -ForegroundColor Yellow
            continue
        }
        
        Write-Host "Found $($videoFiles.Count) video files" -ForegroundColor Green
        Write-Host "Loading interactive playlist... (Ctrl+C to exit, '..' to go back)" -ForegroundColor Cyan
        
        # Create playlist format with file names and sizes
        $playlist = $videoFiles | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 1)
            "$($_.Name) ($($sizeMB) MB)"
        }
        
        # Start interactive playlist loop
        while ($true) {
            # Create playlist with navigation option
            $playlistWithNav = @(".. (Back to directory selection)") + $playlist
            
            $selectedVideoName = $playlistWithNav | fzf --prompt "Select Video> " --height 50% --border --preview="echo 'ENTER to play, or go back to directory selection'" --header="Interactive Playlist - Use arrow keys, ENTER to play"
            
            if ([string]::IsNullOrWhiteSpace($selectedVideoName)) {
                Write-Host "No selection made." -ForegroundColor Yellow
                continue
            }
            
            # Handle navigation back
            if ($selectedVideoName -eq ".. (Back to directory selection)") {
                Write-Host "Going back to directory selection..." -ForegroundColor Gray
                break  # Exit playlist loop, return to directory selection
            }
            
            # Extract filename from selection (remove size info)
            if ($selectedVideoName -match '^(.+?)\s+\(\d+\.?\d*\s+MB\)$') {
                $fileName = $matches[1].Trim()
                
                # Try to find the video file using multiple approaches
                $selectedVideo = $null
                
                # First try exact name match
                $selectedVideo = $videoFiles | Where-Object { $_.Name -eq $fileName }
                
                # If not found, try case-insensitive match
                if (-not $selectedVideo) {
                    $selectedVideo = $videoFiles | Where-Object { $_.Name -eq $fileName -or $_.Name.ToLower() -eq $fileName.ToLower() }
                }
                
                # If still not found, try partial match
                if (-not $selectedVideo) {
                    $cleanName = $fileName -split ' ' | Select-Object -First 1
                    $selectedVideo = $videoFiles | Where-Object { $_.Name -like "$cleanName*" }
                }
                
                if ($selectedVideo) {
                    # Stop existing mpv.net processes
                    $existingMpv = Get-Process -Name "mpvnet" -ErrorAction SilentlyContinue
                    if ($existingMpv) {
                        Write-Host "  Stopping existing video..." -ForegroundColor Gray
                        $existingMpv | Stop-Process -Force
                        Start-Sleep -Milliseconds 300
                    }
                    
                    Write-Host "▶ Playing: $($selectedVideo.Name)" -ForegroundColor Green
                    
                    # Try to create playlist-like experience by passing multiple files
                    $selectedVideoIndex = $videoFiles.IndexOf($selectedVideo)
                    $videosToPlay = @()
                    
                    # Add videos from selected video onwards (creates playlist-like order)
                    for ($i = $selectedVideoIndex; $i -lt $videoFiles.Count; $i++) {
                        $videosToPlay += "`"$($videoFiles[$i].FullName)`""
                    }
                    
                    # Add videos from beginning to selected video (creates circular playlist)
                    for ($i = 0; $i -lt $selectedVideoIndex; $i++) {
                        $videosToPlay += "`"$($videoFiles[$i].FullName)`""
                    }
                    
                    Write-Host "  (Playlist with $($videoFiles.Count) videos created)" -ForegroundColor Gray
                    
                    # Start mpv.net with all videos as arguments (playlist-like behavior)
                    Start-Process -FilePath "mpvnet" -ArgumentList $videosToPlay -WindowStyle Minimized
                    
                    # Brief pause to allow video to start
                    Start-Sleep -Milliseconds 500
                    
                    Write-Host "✓ Video launched with $($videoFiles.Count) video playlist. Select next video, go back, or Ctrl+C to exit" -ForegroundColor Cyan
                } else {
                    Write-Error "Could not find video file for: $fileName"
                }
            } else {
                Write-Error "Invalid selection format: $selectedVideoName"
            }
        }
    }
    
    try {
        # This is for try-catch block at the end
    } catch {
        if ($_.Exception.Message -notlike "*was terminated*") {
            Write-Error "Error processing video files: $($_.Exception.Message)"
        }
    }
}