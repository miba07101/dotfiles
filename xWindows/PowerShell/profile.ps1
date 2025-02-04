# Disable PowerShell update notifications
$env:POWERSHELL_UPDATECHECK = "Off"

# terminal icons
# install: Install-Module -Name Terminal-Icons -Repository PSGallery
# Import-Module -Name Terminal-Icons

function Enable-TerminalIcons {
    if (-not (Get-Module -Name Terminal-Icons)) {
        Import-Module Terminal-Icons
    }
}

function Ls-WithIcons {
    Enable-TerminalIcons
    Get-ChildItem @args
}
Set-Alias lsi Ls-WithIcons

# oh-my-posh
# oh-my-posh init pwsh --config 'C:\Users\mech\AppData\Local\Programs\oh-my-posh\themes\spaceship-my.omp.json' | Invoke-Expression

# kopirovanie config suborov - potrebne pre vuz pc - nedaju sa vytvorit symlinky bez admin
. "$PSScriptRoot\vuz-copy-git-repo.ps1"

# environment variables

# premenna pre python virtual enviroments priecinok, pouzitie v neovime
$env:VENV_HOME = "C:\Users\$($env:UserName)\.py-venv"

# premenna pre onedrive priecinok, pouzitie v neovime pre obsidian
function Set-OneDrivePath {
    # Determine the OneDrive directory based on the username
    if ($env:UserName -eq "mech") {
        $env:OneDrive_DIR = "C:\Users\$($env:UserName)\OneDrive - VUZ\"
    } else {
        $env:OneDrive_DIR = "C:\Users\$($env:UserName)\OneDrive\"
    }
}
# Call the function to set the environment variable
Set-OneDrivePath

# Obsidian create note
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
Set-Alias okn Obsidian-KategorizeNotes

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
function NeovimInit {
    nvim C:\Users\$env:USERNAME\AppData\Local\nvim\init.lua
}
Set-Alias vv NeovimInit

# python virtual enviroment
function PythonVenvActivate {
    . "C:\Users\$env:USERNAME\.py-venv\base-venv\Scripts\Activate.ps1"
}
Set-Alias -Name base -Value PythonVenvActivate
Set-Alias dea deactivate

# function PythonVuzEnviroment {
#     cd C:\Users\$env:USERNAME\github\python
#     .\.venv\Scripts\Activate.ps1
# }
# Set-Alias pv PythonVuzEnviroment
# Set-Alias dea deactivate

# jupyter lab
# Function JupyterLab {
# 	cd C:\Users\$env:USERNAME\github\python
#     	.\.venv\Scripts\Activate.ps1
# 	jupyter lab
# }
# Set-Alias jupy JupyterLab

# lazygit
Set-Alias lg lazygit
Set-Alias lazy lazygit

# recording stream video
# uz velmi nefunguje
Set-Alias -Name rec -Value "C:\Users\$env:UserName\OneDrive\Linux\Skripty\stream_record_win.ps1"

# ollama ai
Function AiOllama {
	ollama run phi3:medium
}
Set-Alias ai AiOllama

Function AiOllamaStop {
	ollama stop phi3:medium
}
Set-Alias ais AiOllamaStop

Function AiOllamaCode {
	ollama run deepseek-coder-v2:latest
}
Set-Alias aic AiOllamaCode

Function AiOllamaCodeStop {
	ollama stop deepseek-coder-v2:latest
}
Set-Alias aics AiOllamaCodeStop

# starship prompt
$ENV:STARSHIP_CONFIG = "$HOME\Documents\PowerShell\starship.toml"
# $ENV:STARSHIP_DISTRO = "  "
# Invoke-Expression (&starship init powershell)
starship init powershell --print-full-init | Out-String | Invoke-Expression
