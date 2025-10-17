<#
.SYNOPSIS
    Extracts a range of pages from a PDF file using qpdf.
.DESCRIPTION
    This script takes an input PDF file and a page range, and creates a new
    PDF containing only the specified pages. The output file is automatically named.
.PARAMETER InputPdf
    The path to the source PDF file.
.PARAMETER PageRange
    The range of pages to extract (e.g., "1-5", "7", "9-12").
.EXAMPLE
    .\qpdf-extract-pages.ps1 "my-document.pdf" "3-5"
    This command extracts pages 3 through 5 from "my-document.pdf" and saves them
    to a new file named "my-document_pages_3-5.pdf".
#>
function QpdfExtractPages {
param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$InputPdf,

        [Parameter(Mandatory=$true, Position=1)]
        [string]$PageRange
    )

    # Check if qpdf is available in the system's PATH
    if (-not (Get-Command qpdf -ErrorAction SilentlyContinue)) {
        Write-Error "qpdf command not found. Please ensure qpdf is installed and in your system's PATH."
        exit 1
    }

    # Resolve the full path for the input file
    try {
        $resolvedInputPath = Resolve-Path -Path $InputPdf -ErrorAction Stop
    }
    catch {
        Write-Error "Input file not found: $_"
        exit 1
    }

    # Construct the output file name
    $inputBaseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInputPath)
    $outputFileName = "${inputBaseName}_pages_${PageRange}.pdf"
    $outputFilePath = Join-Path -Path (Split-Path -Path $resolvedInputPath -Parent) -ChildPath $outputFileName

    # Construct the qpdf command
    $command = "qpdf `"$resolvedInputPath`" --pages . `"$PageRange`" -- `"$outputFilePath`""

    Write-Host "Running command: $command"

    # Execute the command
    try {
        Invoke-Expression -Command $command -ErrorAction Stop
        Write-Host "Successfully extracted pages to: $outputFilePath"
    }
    catch {
        Write-Error "An error occurred while running qpdf: $_"
        exit 1
    }
}
