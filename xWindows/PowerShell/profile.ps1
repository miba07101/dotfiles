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

$scriptPath = "C:\Users\$env:UserName\Documents\PowerShell\Scripts"

function push {
    if ($env:UserName -eq "mech") {
        . "$scriptPath\vuz-copy-dotfiles.ps1"
        CopyGitRepoReverse
        . "$scriptPath\push-pull-git-repos.ps1"
        PushAllGitRepos
    } else {
        . "$scriptPath\push-pull-git-repos.ps1"
        PushAllGitRepos
    }
}

function pull {
    if ($env:UserName -eq "mech") {
        . "$scriptPath\push-pull-git-repos.ps1"
        PullAllGitRepos
        . "$scriptPath\vuz-copy-dotfiles.ps1"
        CopyGitRepo
    } else {
        . "$scriptPath\push-pull-git-repos.ps1"
        PullAllGitRepos
    }
}

# function on {
# param (
#     [Parameter(Mandatory = $true)]
#     [string]$NoteTitle
#   )

#   # Call the function from the script with the correct parameter
#   . "$scriptPath\obsidian-create-note.ps1"
#   New-ObsidianNote -NoteTitle $NoteTitle
# }

function nk {
  . "$scriptPath\notes-categorize.ps1"
  NotesCategorize
}

# download youtube videos
# yt-dlp must be installed
function ytd {
  . "$scriptPath\youtube-download.ps1"
    YoutubeDownload
}

# firefox copy prefs.js to user.js for sync
# pouzivam na synchronizaciu ulozenuych serialov
function fireup {
  . "$scriptPath\firefox-backup.ps1"
    FirefoxBackup
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

# premenna pre zk notes default vault notebook
$env:ZK_NOTEBOOK_DIR = "C:\Users\$env:UserName\OneDrive\Dokumenty\zPoznamky\Obsidian"

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
