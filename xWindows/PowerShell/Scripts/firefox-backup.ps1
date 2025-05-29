function FirefoxBackup {
    # $firefoxDir = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory |
    #     Where-Object { $_.Name -like "*default-release*" } |
    #     Select-Object -First 1 -ExpandProperty FullName

    $firefoxDir = "C:\Users\$env:Username\scoop\persist\firefox\profile"

    if (-not $firefoxDir) {
        Write-Host "Firefox profile directory not found."
        exit 1
    }

    Write-Host "Full Firefox path: $firefoxDir"

    $userJsPath = Join-Path $firefoxDir "user.js"
    $prefsJsPath = Join-Path $firefoxDir "prefs.js"

    if (-not (Test-Path $userJsPath)) {
        New-Item -Path $userJsPath -ItemType File | Out-Null
    }

    # Remove lines containing "browser.newtabpage.pinned"
    (Get-Content $userJsPath) | Where-Object { $_ -notmatch "browser\.newtabpage\.pinned" } | Set-Content $userJsPath

    # Append matching lines from prefs.js to user.js
    Get-Content $prefsJsPath | Where-Object { $_ -match "browser\.newtabpage\.pinned" } | Add-Content $userJsPath

    Write-Host "Firefox prefs.js and user.js updated"
}
