# Disable PowerShell update notifications
$env:POWERSHELL_UPDATECHECK = "Off"

# -----------------------------------------------------------------------------
# modules
# -----------------------------------------------------------------------------
# terminal icons
# install: Install-Module -Name Terminal-Icons -Repository PSGallery

# enable terminal icons
function Enable-TerminalIcons {
  if (-not (Get-Module -Name Terminal-Icons)) {
    Import-Module Terminal-Icons
  }
}

# show/list directory content with terminal icons
function lsi {
  Enable-TerminalIcons
  Get-ChildItem @args
}

# -----------------------------------------------------------------------------
# load scripts/functions
# -----------------------------------------------------------------------------

$scriptPath = "C:\Users\$env:UserName\Documents\PowerShell"

function pull {
  # dot-source the script
  . "$scriptPath\vuz-copy-git-repo.ps1"
  # call function
  CopyGitRepo
}

function push {
  . "$scriptPath\vuz-copy-git-repo.ps1"
  CopyGitRepoReverse
}

function pushall {
  . "$scriptPath\git-auto-all.ps1"
    PushAllGitRepos
}

function pullall {
  . "$scriptPath\git-auto-all.ps1"
    PullAllGitRepos
}

function on {
param (
    [Parameter(Mandatory = $true)]
    [string]$NoteTitle
  )

  # Call the function from the script with the correct parameter
  . "$scriptPath\obsidian-create-note.ps1"
  New-ObsidianNote -NoteTitle $NoteTitle
}

#TODO este otestovat
function okn {
  . "$scriptPath\obsidian-categorize-notes.ps1"
  Obsidian-KategorizeNotes
}

# -----------------------------------------------------------------------------
# environment variables
# -----------------------------------------------------------------------------
# premenna pre python virtual enviroments priecinok, pouzitie v neovime
if (-not $env:VENV_HOME) {
  $env:VENV_HOME = "C:\Users\$($env:UserName)\.py-venv"
}

# premenna pre onedrive priecinok, pouzitie v neovime pre obsidian
if (-not $env:OneDrive_DIR) {
  $env:OneDrive_DIR = if ($env:UserName -eq "mech") {
    "C:\Users\$env:UserName\OneDrive - VUZ\"
  } else {
    "C:\Users\$env:UserName\OneDrive\"
  }
}

# -----------------------------------------------------------------------------
# aliases
# -----------------------------------------------------------------------------
# yazi file manager
function y {
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
    Set-Location -LiteralPath $cwd
  }
  Remove-Item -Path $tmp
}

# neovim config init.lua
function vv {
  nvim C:\Users\$env:USERNAME\AppData\Local\nvim\init.lua
}

# python virtual enviroment
function base {
  . "C:\Users\$env:USERNAME\.py-venv\base-venv\Scripts\Activate.ps1"
}

function io {
  . "C:\Users\$env:USERNAME\.py-venv\io-venv\Scripts\Activate.ps1"
}
Set-Alias dea deactivate

# lazygit
function lg {
  lazygit
}
function lazy {
  lazygit
}

# which/where
function which {
  param (
    [string]$command
  )
  Get-Command $command | Select-Object -ExpandProperty Path
}

function whereis {
    param (
        [string[]]$commands
    )
    & where.exe $commands
}


# recording stream video
# uz velmi nefunguje
# Set-Alias -Name rec -Value "C:\Users\$env:UserName\OneDrive\Linux\Skripty\stream_record_win.ps1"

# -----------------------------------------------------------------------------
# starship
# -----------------------------------------------------------------------------
$ENV:STARSHIP_CONFIG = "$HOME\Documents\PowerShell\starship.toml"
# Invoke-Expression (&starship init powershell)
starship init powershell --print-full-init | Out-String | Invoke-Expression
