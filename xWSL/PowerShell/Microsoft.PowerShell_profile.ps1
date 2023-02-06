Import-Module -Name Terminal-Icons

Set-Alias -Name rec -Value "C:\Users\$env:UserName\OneDrive\Linux\Skripty\stream_record_win.ps1"

$ENV:STARSHIP_CONFIG = "$HOME\Documents\PowerShell\starship.toml"
$ENV:STARSHIP_DISTRO = "者 "
Invoke-Expression (&starship init powershell)
