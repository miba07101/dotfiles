function Obsidian-KategorizeNotes {
    # Define the directories
    if ($env:UserName -eq "mech") {
        $VaultDir = Join-Path $env:OneDrive_DIR "Poznámkové bloky\Obsidian"
    } else {
        $ObsidianPath = Join-Path $env:OneDrive_DIR "Dokumenty\zPoznamky\Obsidian"
    }
    $HubsDir = Join-Path $VaultDir "hubs"
    $SourceDir = Join-Path $VaultDir "inbox"
    $DestDir = Join-Path $VaultDir "notes"

    # Get all markdown files in the source directory
    Get-ChildItem -Path $SourceDir -Recurse -Filter "*.md" | ForEach-Object {
        $File = $_.FullName
        Write-Host "Processing $File"

        # Extract the hub from the file (assumes the hub is on the line after "hubs:")
        $Keyword = Select-String -Path $File -Pattern "hubs:" -Context 0,1 |
            ForEach-Object { $_.Context.PostContext -replace '^ *- *\[\[', '' -replace '\]\]$', '' -replace '^ *', '' -replace ' *$', '' }

        if ($Keyword) {
            Write-Host "Found hub/tag: $Keyword"

            # Ensure the hub file exists in the hubs directory
            $HubFile = Join-Path $HubsDir "$Keyword.md"
            if (-not (Test-Path -Path $HubFile)) {
                New-Item -ItemType File -Path $HubFile -Force | Out-Null
                Write-Host "Created file $Keyword.md in $HubsDir"
            }

            # Create the target directory if it doesn't exist
            $TargetDir = Join-Path $DestDir $Keyword
            if (-not (Test-Path -Path $TargetDir)) {
                New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
                Write-Host "Created directory: $TargetDir"
            }

            # Move the file to the target directory
            Move-Item -Path $File -Destination $TargetDir -Force
            Write-Host "Moved $File to $TargetDir"
        } else {
            Write-Host "No hub/tag found for $File"
        }
    }

    Write-Host "Done"
}
# Set-Alias okn Obsidian-KategorizeNotes
