function CopyGitRepo {
  param (
      [switch]$Reverse # Toggle reverse copying
      )

# Define source-to-destination mappings
    $PathMappings = @{
      "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\profile.ps1" = "C:\Users\mech\Documents\PowerShell\profile.ps1"
      "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\vuz-git-auto-all.ps1" = "C:\Users\mech\Documents\PowerShell\vuz-git-auto-all.ps1"
      "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\vuz-copy-git-repo.ps1" = "C:\Users\mech\Documents\PowerShell\vuz-copy-git-repo.ps1"
      "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\vuz-copy-dotfiles.ps1" = "C:\Users\mech\Documents\PowerShell\vuz-copy-dotfiles.ps1"
      "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\obsidian-create-note.ps1" = "C:\Users\mech\Documents\PowerShell\obsidian-create-note.ps1"
      "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\obsidian-categorize-notes.ps1" = "C:\Users\mech\Documents\PowerShell\obsidian-categorize-notes.ps1"
      "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\youtube-download.ps1" = "C:\Users\mech\Documents\PowerShell\youtube-download.ps1"
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

  Write-Host "`nCopying files..." -ForegroundColor Cyan

    foreach ($Mapping in $PathMappings.GetEnumerator()) {
      if ($Reverse) {
        $Source = $Mapping.Value
          $Destination = $Mapping.Key
      } else {
        $Source = $Mapping.Key
          $Destination = $Mapping.Value
      }

# Ensure source exists before copying
      if (Test-Path -Path $Source) {
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
          Write-Host "Copied: $Source -> $Destination"
      } else {
        Write-Host "Skipping missing file: $Source" -ForegroundColor Yellow
      }
    }

  Write-Host "`nCopying completed!" -ForegroundColor Green
}

function CopyGitRepoReverse {
  CopyGitRepo -Reverse
}
