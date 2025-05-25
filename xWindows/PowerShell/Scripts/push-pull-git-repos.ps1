function PushAllGitRepos {
param (
        [string]$baseDir = "$HOME\git-repos"  # Default path, change if needed
    )

    # Ensure the directory exists
    if (!(Test-Path $baseDir)) {
        Write-Host "Error: Directory '$baseDir' not found!" -ForegroundColor Red
        return
    }

    # Get all subdirectories (assuming each is a git repo)
    $repos = Get-ChildItem -Path $baseDir -Directory

    foreach ($repo in $repos) {
        $repoPath = $repo.FullName
        Write-Host "`nProcessing repository: $repoPath" -ForegroundColor Cyan

        # Check if it's a valid Git repository
        if (!(Test-Path "$repoPath\.git")) {
            Write-Host "Skipping: Not a Git repository" -ForegroundColor Yellow
            continue
        }

        # Change to the repo directory
        Set-Location $repoPath

        # Check for changes
        $status = git status --porcelain
        if (-not $status) {
            Write-Host "No changes to commit in $repoPath" -ForegroundColor Green
            continue
        }

        # Get a dynamic commit message based on changed files
        $changes = git diff --name-only
        $commitMessage = Read-Host "Enter a commit message for $repo (or press Enter for default)"
        if (-not $commitMessage) {
            # $commitMessage = "up vuz $($changes -join ', ') ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
            $commitMessage = "up $env:UserName $($changes -join ', ') ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"

        }

        # Perform Git operations
        git add .
        git commit -m $commitMessage
        if ($?) {
            Write-Host "Committed changes in $repoPath" -ForegroundColor Green
        } else {
            Write-Host "Commit failed in $repoPath" -ForegroundColor Red
            continue
        }

        # Push to remote
        git push
        if ($?) {
            Write-Host "Pushed changes for $repoPath" -ForegroundColor Green
        } else {
            Write-Host "Push failed in $repoPath" -ForegroundColor Red
        }
    }

    # Return to original location
    Set-Location $baseDir
}

function PullAllGitRepos {
param (
        [string]$baseDir = "$HOME\git-repos"  # Default path, change if needed
    )

    # Ensure the directory exists
    if (!(Test-Path $baseDir)) {
        Write-Host "Error: Directory '$baseDir' not found!" -ForegroundColor Red
        return
    }

    # Get all subdirectories (assuming each is a git repo)
    $repos = Get-ChildItem -Path $baseDir -Directory

    foreach ($repo in $repos) {
        $repoPath = $repo.FullName
        Write-Host "`nProcessing repository: $repoPath" -ForegroundColor Cyan

        # Check if it's a valid Git repository
        if (!(Test-Path "$repoPath\.git")) {
            Write-Host "Skipping: Not a Git repository" -ForegroundColor Yellow
            continue
        }

        # Change to the repo directory
        Set-Location $repoPath

        # Pull latest changes from remote
        Write-Host "Pulling latest changes for $repoPath..." -ForegroundColor Blue
        git pull
        if ($?) {
            Write-Host "Successfully pulled changes for $repoPath" -ForegroundColor Green
        } else {
            Write-Host "Pull failed in $repoPath" -ForegroundColor Red
        }
    }

    # Return to original location
    Set-Location $baseDir
}
