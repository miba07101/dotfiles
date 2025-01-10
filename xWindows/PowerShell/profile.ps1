# terminal icons
# install: Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons

# oh-my-posh
# oh-my-posh init pwsh --config 'C:\Users\mech\AppData\Local\Programs\oh-my-posh\themes\spaceship-my.omp.json' | Invoke-Expression

# enviroment variables
# premenna pre python virtual enviroments priecinok, pouzitie v neovime
$env:VENV_HOME = "C:\Users\$env:UserName\.py-venv\"

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
