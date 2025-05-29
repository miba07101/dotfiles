function PhotoFileRename {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    if (-not (Test-Path $Path -PathType Container)) {
        Write-Error "'$Path' is not a valid directory."
        return
    }

    Get-ChildItem -Path $Path -File | ForEach-Object {
        $nameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $ext = $_.Extension

        if ($nameNoExt -match '\((\d+)\)') {
            $num = $matches[1]
            $newName = ($nameNoExt -replace "\($num\)", "-$num") -replace '\s', ''
            $newFile = "$newName$ext"

            $newPath = Join-Path $Path $newFile
            if (-not (Test-Path $newPath)) {
                Rename-Item $_.FullName -NewName $newFile
                Write-Host "Renamed '$($_.Name)' → '$newFile'"
            } else {
                Write-Warning "Skipping '$($_.Name)': '$newFile' already exists."
            }
        }
    }
}
