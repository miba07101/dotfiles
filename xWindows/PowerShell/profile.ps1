#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
#If (Test-Path "C:\Users\mech\miniconda3\Scripts\conda.exe") {
#    (& "C:\Users\mech\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
#}
#endregion

#conda config --set changeps1 False
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1

#oh-my-posh
oh-my-posh init pwsh --config 'C:\Users\mech\AppData\Local\Programs\oh-my-posh\themes\spaceship-my.omp.json' | Invoke-Expression

#create symlinks to folders and files on Windows without admin privileges in Powershell
#https://gist.github.com/letmaik/91dff56e160da34dc148a9cc46b93c69
function symlink ([String] $real, [String] $link) {
    if (Test-Path $real -pathType container) {
        cmd /c mklink /j $link.Replace("/", "\") $real.Replace("/", "\")
    } else {
        cmd /c mklink /h $link.Replace("/", "\") $real.Replace("/", "\")
    }
}

#shorcuts
function PythonVuzEnviroment {
    cd C:\Users\$env:USERNAME\github\python
    .\.venv\Scripts\Activate.ps1
}

Set-Alias pv PythonVuzEnviroment
Set-Alias dea deactivate

Function JupyterLab {
	cd C:\Users\$env:USERNAME\github\python
    	.\.venv\Scripts\Activate.ps1 
	jupyter lab
}
Set-Alias jupy JupyterLab

Set-Alias lg lazygit
Set-Alias lazy lazygit

#yazi file manager
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

#ollama
Function AiOllama {
	ollama run phi3:medium
}
Set-Alias olr AiOllama

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