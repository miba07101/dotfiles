function CopyGitRepo {
    param (
        [switch]$Reverse # Add a switch to toggle reverse copying
    )

    # Define source-to-destination mappings
    $PathMappings = @{
        "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\profile.ps1" = "C:\Users\mech\Documents\PowerShell\profile.ps1"
        "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\vuz-copy-git-repo.ps1" = "C:\Users\mech\Documents\PowerShell\vuz-copy-git-repo.ps1"
        "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\obsidian-create-note.ps1" = "C:\Users\mech\Documents\PowerShell\obsidian-create-note.ps1"
        "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\obsidian-categorize-notes.ps1" = "C:\Users\mech\Documents\PowerShell\obsidian-categorize-notes.ps1"
        "C:\Users\mech\git-repos\dotfiles\config\starship.toml" = "C:\Users\mech\Documents\PowerShell\starship.toml"
        "C:\Users\mech\git-repos\dotfiles\config\wezterm" = "C:\Users\mech\.config\wezterm"
        "C:\Users\mech\git-repos\dotfiles\config\nvim-single\init.lua" = "C:\Users\mech\AppData\Local\nvim\init.lua"
        "C:\Users\mech\git-repos\dotfiles\config\nvim-single\snippets" = "C:\Users\mech\AppData\Local\nvim\snippets"
        "C:\Users\mech\git-repos\dotfiles\config\nvim-single\after" = "C:\Users\mech\AppData\Local\nvim\after"
        "C:\Users\mech\git-repos\dotfiles\config\VSCodium\settings.json" = "C:\Users\mech\scoop\persist\vscodium\data\user-data\User\settings.json"
        "C:\Users\mech\git-repos\dotfiles\config\VSCodium\keybindings.json" = "C:\Users\mech\scoop\persist\vscodium\data\user-data\User\keybindings.json"
        "C:\Users\mech\git-repos\dotfiles\config\yazi\keymap.toml" = "C:\Users\mech\AppData\Roaming\yazi\config\keymap.toml"
        "C:\Users\mech\git-repos\dotfiles\config\yazi\theme.toml" = "C:\Users\mech\AppData\Roaming\yazi\config\theme.toml"
        "C:\Users\mech\git-repos\dotfiles\config\yazi\yazi.toml" = "C:\Users\mech\AppData\Roaming\yazi\config\yazi.toml"
    }

    # Navigate to the dotfiles repository
    $RepoPath = "C:\Users\$env:USERNAME\git-repos\dotfiles"
    Push-Location $RepoPath

    try {
            if ($Reverse) {
                # Reverse copying: destination -> source
                foreach ($Mapping in $PathMappings.GetEnumerator()) {
                    $Source = $Mapping.Value
                    $Destination = $Mapping.Key

                    # Remove the destination folder/file if it exists
                    if (Test-Path -Path $Destination) {
                        Remove-Item -Path $Destination -Recurse -Force
                        Write-Host "Cleared existing destination: $Destination"
                    }

                    # Copy the source to the destination
                    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
                    Write-Host "Copied: $Source -> $Destination"
                }

                # Ask for a commit message dynamically
                $CommitMessage = Read-Host "Enter a commit message (or press Enter for default)"
                if (-not $CommitMessage) {
                    $CommitMessage = "up dotfiles vuz ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
                }

                # Perform git add, commit, and push
                git add .
                git commit -m $CommitMessage
                git push
                Write-Host "Changes pushed to the repository with commit message: '$CommitMessage'."
            } else {
                # Normal copying: source -> destination
                # Perform a git pull
                git pull
                Write-Host "Repository updated with the latest changes."

                foreach ($Mapping in $PathMappings.GetEnumerator()) {
                    $Source = $Mapping.Key
                    $Destination = $Mapping.Value

                    # Remove the destination folder/file if it exists
                    if (Test-Path -Path $Destination) {
                        Remove-Item -Path $Destination -Recurse -Force
                        Write-Host "Cleared existing destination: $Destination"
                    }

                    # Copy the source to the destination
                    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
                    Write-Host "Copied: $Source -> $Destination"
                }
            }
        } catch {
            Write-Host "An error occurred: $_" -ForegroundColor Red
        } finally {
            Pop-Location
        }

}

function CopyGitRepoReverse {
    CopyGitRepo -Reverse
}

# Set-Alias pull CopyGitRepo
# Set-Alias push CopyGitRepoReverse
