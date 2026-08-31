[CmdletBinding()]
param(
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$sourceRoot = Split-Path -Parent $PSCommandPath
$targetRoot = Join-Path $env:USERPROFILE '.local\share\sql-beautify-zed'
$targetBin = Join-Path $env:USERPROFILE '.local\bin'
$targetCommand = Join-Path $targetBin 'sql-beautify-zed.cmd'
$settingsPath = Join-Path $env:APPDATA 'Zed\settings.json'

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw 'Node.js was not found on PATH. Install Node.js LTS from https://nodejs.org/ and reopen PowerShell.'
}

Write-Host "Formatter target: $targetCommand"
Write-Host "Zed settings:     $settingsPath"
if (-not $Apply) {
    Write-Host 'Dry run only. Re-run with: .\install.ps1 -Apply'
    exit 0
}

New-Item -ItemType Directory -Force -Path $targetRoot, $targetBin | Out-Null
Copy-Item -Recurse -Force (Join-Path $sourceRoot 'vendor') (Join-Path $targetRoot 'vendor')
Copy-Item -Force (Join-Path $sourceRoot 'sql-beautify-zed.js') (Join-Path $targetRoot 'sql-beautify-zed.js')
Copy-Item -Force (Join-Path $sourceRoot 'configure-zed.js') (Join-Path $targetRoot 'configure-zed.js')
Copy-Item -Force (Join-Path $sourceRoot 'bin\sql-beautify-zed.cmd') $targetCommand

if (Test-Path $settingsPath) {
    $backupPath = "$settingsPath.sql-beautify-zed-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Force $settingsPath $backupPath
    Write-Host "Settings backup:  $backupPath"
}

node (Join-Path $targetRoot 'configure-zed.js') $settingsPath $targetCommand
'select id,case when status=1 then ''正常'' else ''异常'' end as status_name from orders where id=1;' |
    & $targetCommand

Write-Host 'Installed. Restart Zed if it was already running.'
