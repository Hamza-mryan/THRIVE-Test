[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/LocalEnvironment.ps1')
$state = Get-ThriveTestStateDirectory $projectRoot
$stateFile = Assert-ThriveTestPath $projectRoot (Join-Path $state 'test-processes.json')
if (-not (Test-Path -LiteralPath $stateFile)) { Write-Host 'No THRIVE Test application processes are recorded.'; return }
$record = Get-Content -LiteralPath $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
Assert-ThriveTestProcessRecord $projectRoot $record
foreach ($entry in $record.processes) {
    $process = Get-Process -Id $entry.id -ErrorAction SilentlyContinue
    if ($process -and $process.StartTime.ToUniversalTime().Ticks.ToString() -eq $entry.startedAtUtcTicks) {
        & taskkill /PID $entry.id /T /F | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Unable to stop recorded test process $($entry.component)." }
    }
}
Remove-Item -LiteralPath $stateFile
Write-Host 'Stopped only recorded THRIVE Test applications. PostgreSQL and original applications were preserved.'
