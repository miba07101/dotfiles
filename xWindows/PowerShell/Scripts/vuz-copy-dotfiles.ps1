function CopyGitRepo {
  param (
      [switch]$Reverse # Toggle reverse copying
      )

# Define source-to-destination mappings
    $PathMappings = @{
      "C:\Users\mech\git-repos\dotfiles\config\nvim-single\init.lua" = "C:\Users\mech\AppData\Local\nvim\init.lua"
      "C:\Users\mech\git-repos\dotfiles\config\nvim-single\init-backup.lua" = "C:\Users\mech\AppData\Local\nvim\init-backup.lua"
      "C:\Users\mech\git-repos\dotfiles\config\nvim-single\snippets" = "C:\Users\mech\AppData\Local\nvim\snippets"
      "C:\Users\mech\git-repos\dotfiles\config\nvim-single\after" = "C:\Users\mech\AppData\Local\nvim\after"  
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

      # If source is a folder, replace the destination folder contents
      if ((Test-Path $Source) -and ((Get-Item $Source).PSIsContainer)) {
        if (Test-Path $Destination) {
          # Remove the destination folder if it exists, to avoid copying the folder as a subfolder
          Remove-Item -Path $Destination -Recurse -Force
        }

        # Now copy the source folder (not just its contents) to the destination
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Write-Host "Copied folder: $Source -> $Destination"
      } else {
        # If it's a file, simply copy it
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-Host "Copied: $Source -> $Destination"
      }

    } else {
      Write-Host "Skipping missing file/folder: $Source" -ForegroundColor Yellow
    }
  }

  Write-Host "`nCopying completed!" -ForegroundColor Green
}

function CopyGitRepoReverse {
  CopyGitRepo -Reverse
}
