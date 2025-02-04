function New-ObsidianNote {
    param (
        [Parameter(Mandatory = $true)]
        [string]$NoteTitle
    )

    # Check if NoteTitle is provided
    if (-not $NoteTitle) {
        Write-Host "Error: A file name must be set, e.g. 'the wonderful thing about tiggers'." -ForegroundColor Red
        return
    }

    # Replace spaces with dashes to create the file name
    $FileName = $NoteTitle -replace ' ', '-'
    $FormattedFileName = "$FileName.md"

    # Define the path to the Obsidian inbox folder
    if ($env:UserName -eq "mech") {
        $ObsidianPath = Join-Path $env:OneDrive_DIR "Poznámkové bloky\Obsidian"
    } else {
        $ObsidianPath = Join-Path $env:OneDrive_DIR "Dokumenty\zPoznamky\Obsidian"
    }
    $InboxPath = Join-Path $ObsidianPath "inbox"

    # Ensure the inbox folder exists
    if (-not (Test-Path $InboxPath)) {
        Write-Host "Error: Inbox folder not found at $InboxPath." -ForegroundColor Red
        return
    }

    # Create the new note file
    $FilePath = Join-Path $InboxPath $FormattedFileName
    New-Item -ItemType File -Path $FilePath -Force | Out-Null
    Write-Host "Created file: $FilePath"

    # Open the file in Neovim
    nvim $FilePath
}
Set-Alias on New-ObsidianNote
