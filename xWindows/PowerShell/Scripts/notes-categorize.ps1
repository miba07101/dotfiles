function NotesCategorize {
  # Vault paths
  if ($env:UserName -eq "mech") {
    $VaultDir = "$HOME\Sync\Obsidian"
  } else {
    $VaultDir = Join-Path $env:OneDrive_DIR "Dokumenty\zPoznamky\Obsidian"
  }

  $SourceDir = "inbox"
  $PersonalDir = Join-Path $VaultDir "personal"
  $WorkDir = Join-Path $VaultDir "work"
  $ContactsDir = Join-Path $VaultDir "contacts"

  function Move-Images {
    param (
      [string]$NotePath,
      [string]$TargetDir
    )

    $NoteBaseName = [System.IO.Path]::GetFileNameWithoutExtension($NotePath)
    $NoteDir = Split-Path $NotePath
    $ImagePattern = "$NoteBaseName-??????.png"

    $ImageFiles = Get-ChildItem -Path $NoteDir -Filter $ImagePattern -ErrorAction SilentlyContinue
    if ($ImageFiles.Count -eq 0) { return }

    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    foreach ($img in $ImageFiles) {
      Move-Item -Path $img.FullName -Destination $TargetDir
    }
  }

  $InboxPath = Join-Path $VaultDir $SourceDir
  $MarkdownFiles = Get-ChildItem -Path $InboxPath -Filter "*.md" -Recurse

  foreach ($file in $MarkdownFiles) {
    $Lines = Get-Content $file.FullName

    # Extract area
    $AreaLine = $Lines | Where-Object { $_ -match '^area:' } | Select-Object -First 1
    if (-not $AreaLine) {
      Write-Warning "⚠️  [$($file.Name)] Missing area. Skipping."
      continue
    }

    $Area = $AreaLine -replace '^area:\s*', '' -replace '#.*$', '' -replace '"', ''
    $Area = $Area.Trim().ToLower()

    $TargetDir = $null

    if ($Area -eq "personal") {
      $TagsLine = $Lines | Where-Object { $_ -match '^tags:' } | Select-Object -First 1
      if (-not $TagsLine -or $TagsLine -notmatch '\[([^\]]+)\]') {
        Write-Warning "⚠️  [$($file.Name)] Missing or malformed tags. Skipping."
        continue
      }

      $Parts = $Matches[1] -split ',' | ForEach-Object { $_.Trim() }
      if ($Parts.Count -lt 1) {
        Write-Warning "⚠️  [$($file.Name)] No tags found. Skipping."
        continue
      }

      $TargetDir = $PersonalDir
      foreach ($part in $Parts) {
        $TargetDir = Join-Path $TargetDir $part
      }

    } elseif ($Area -eq "work") {
      $TagsLine = $Lines | Where-Object { $_ -match '^tags:' } | Select-Object -First 1
      if (-not $TagsLine -or $TagsLine -notmatch '\[([^\]]+)\]') {
        Write-Warning "⚠️  [$($file.Name)] Missing or malformed tags. Skipping."
        continue
      }

      $Parts = $Matches[1] -split ',' | ForEach-Object { $_.Trim() }
      if ($Parts.Count -lt 1) {
        Write-Warning "⚠️  [$($file.Name)] No tags found. Skipping."
        continue
      }

      $TargetDir = Join-Path $WorkDir $Parts[0]

    } elseif ($Area -eq "contacts") {
      $TargetDir = $ContactsDir
    } else {
      Write-Warning "⚠️  [$($file.Name)] Unknown area: $Area. Skipping."
      continue
    }

    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Move-Item -Path $file.FullName -Destination $TargetDir
    Move-Images -NotePath $file.FullName -TargetDir $TargetDir
  }

  Write-Host "🎉 All notes processed!"
}
# Set-Alias okn Obsidian-KategorizeNotes
