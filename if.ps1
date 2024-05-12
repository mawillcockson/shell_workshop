If ((-not (Test-Path -Path 'variable:\ShellId')) -or (-not ($ShellId -ilike '*powershell*')) {
    Write-Host 'shell is not PowerShell'
} ElseIf (Test-Path -Path '.\if.ps1') {
    Write-Host 'shell is PowerShell and .\if.ps1 exists'
} Else {
    Write-Host 'shell is PowerShell'
}
