# terminal icons
# install: Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons

# oh-my-posh
# oh-my-posh init pwsh --config 'C:\Users\mech\AppData\Local\Programs\oh-my-posh\themes\spaceship-my.omp.json' | Invoke-Expression

# enviroment variables
# premenna pre python virtual enviroments priecinok, pouzitie v neovime
$env:VENV_HOME = "C:\Users\$($env:UserName)\.py-venv\"
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

# create hard-symlinks to folders and files on Windows10 without admin privileges in Powershell
# https://gist.github.com/letmaik/91dff56e160da34dc148a9cc46b93c69
function hard-symlink ([String] $real, [String] $link) {
    if (Test-Path $real -pathType container) {
        cmd /c mklink /j $link.Replace("/", "\") $real.Replace("/", "\")
    } else {
        cmd /c mklink /h $link.Replace("/", "\") $real.Replace("/", "\")
    }
}

# kpirovanie config suborov - potrebne pre vuz pc - nedaju sa vytvorit symlinky bez admin
function CopyGitRepo {
    param (
        [switch]$Reverse # Add a switch to toggle reverse copying
    )

    # Define source-to-destination mappings
    $PathMappings = @{
        "C:\Users\mech\git-repos\dotfiles\xWindows\PowerShell\profile.ps1" = "C:\Users\mech\Documents\PowerShell\profile.ps1"
        "C:\Users\mech\git-repos\dotfiles\config\starship.toml" = "C:\Users\mech\Documents\PowerShell\starship.toml"
        "C:\Users\mech\git-repos\dotfiles\config\wezterm" = "C:\Users\mech\.config\wezterm"
        "C:\Users\mech\git-repos\dotfiles\config\nvim-single\init.lua" = "C:\Users\mech\AppData\Local\nvim\init.lua"
        "C:\Users\mech\git-repos\dotfiles\config\nvim-single\snippets" = "C:\Users\mech\AppData\Local\nvim\snippets"
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
                    $CommitMessage = "Update dotfiles from PC ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
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
Set-Alias pull CopyGitRepo

function CopyGitRepoReverse {
    CopyGitRepo -Reverse
}
Set-Alias push CopyGitRepoReverse


# neovim config init.lua
function NeovimInit {
    nvim C:\Users\$env:USERNAME\AppData\Local\nvim\init.lua
}
Set-Alias vv NeovimInit

# python virtual enviroment
function PythonVenvActivate {
    cd $env:USERPROFILE\.py-venv\base-venv\
    .\Scripts\Activate
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
$ENV:STARSHIP_DISTRO = "  "
Invoke-Expression (&starship init powershell)
