<#
.SYNOPSIS
    Deletes all __pycache__ directories in the specified path and its subdirectories.

.DESCRIPTION
    The pydel script recursively searches for and removes __pycache__ directories
    created by Python. By default, it searches in the current directory, but you can
    specify a different path using the -Path parameter.

.PARAMETER Path
    The directory path to search for __pycache__ directories. Defaults to current directory.

.PARAMETER Force
    Skip confirmation prompts and delete directories immediately.

.PARAMETER WhatIf
    Show what would be deleted without actually deleting.

.EXAMPLE
    pydel
    Deletes all __pycache__ directories in the current directory and subdirectories.

.EXAMPLE
    pydel -Path "C:\MyProject"
    Deletes all __pycache__ directories in the C:\MyProject directory.

.EXAMPLE
    pydel -Force
    Deletes all __pycache__ directories without confirmation prompts.

.EXAMPLE
    pydel -WhatIf
    Shows what would be deleted without actually deleting.
#>

function PycacheDelete {
    param(
        [Parameter(Position=0)]
        [string]$Path = ".",

        [switch]$Force,

        [switch]$WhatIf
    )

    # Convert relative path to absolute path
    $AbsolutePath = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $AbsolutePath) {
        Write-Error "Path '$Path' does not exist."
        return
    }

    Write-Host "Searching for __pycache__ directories in: $AbsolutePath" -ForegroundColor Cyan

    # Find all __pycache__ directories
    $PyCacheDirs = Get-ChildItem -Path $AbsolutePath -Recurse -Directory -Name "__pycache__" -ErrorAction SilentlyContinue

    if ($PyCacheDirs.Count -eq 0) {
        Write-Host "No __pycache__ directories found." -ForegroundColor Green
        return
    }

    Write-Host "Found $($PyCacheDirs.Count) __pycache__ director(y/ies):" -ForegroundColor Yellow
    $PyCacheDirs | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

    # WhatIf mode
    if ($WhatIf) {
        Write-Host "`nWhatIf: Would delete the following directories:" -ForegroundColor Cyan
        $PyCacheDirs | ForEach-Object {
            $FullPath = Join-Path $AbsolutePath $_
            Write-Host "  $FullPath" -ForegroundColor Gray
        }
        return
    }

    # Confirmation prompt (unless Force is used)
    if (-not $Force) {
        $Response = Read-Host "`nDelete all __pycache__ directories? (y/N)"
        if ($Response -notmatch '^[Yy]$') {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            return
        }
    }

    # Delete the directories
    $DeletedCount = 0
    $FailedCount = 0

    Write-Host "`nDeleting __pycache__ directories..." -ForegroundColor Cyan

    $PyCacheDirs | ForEach-Object {
        $FullPath = Join-Path $AbsolutePath $_
        try {
            Remove-Item -Path $FullPath -Recurse -Force -ErrorAction Stop
            Write-Host "  Deleted: $FullPath" -ForegroundColor Green
            $DeletedCount++
        }
        catch {
            Write-Host "  Failed to delete: $FullPath" -ForegroundColor Red
            Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
            $FailedCount++
        }
    }

    # Summary
    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Deleted: $DeletedCount directories" -ForegroundColor Green
    if ($FailedCount -gt 0) {
        Write-Host "  Failed: $FailedCount directories" -ForegroundColor Red
    }
}
