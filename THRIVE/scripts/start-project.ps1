[CmdletBinding()]
param(
    [switch]$EnableDevelopmentIdentity,
    [ValidateRange(30, 600)][int]$StartupTimeoutSeconds = 240
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/LocalEnvironment.ps1')
& (Join-Path $PSScriptRoot 'initialize-local.ps1')
$settings = Get-ThriveLocalDatabaseSettings $projectRoot
$stateDirectory = Get-ThriveTestStateDirectory $projectRoot
$stateFile = Assert-ThriveTestPath $projectRoot (Join-Path $stateDirectory 'test-processes.json')
foreach ($port in @(5280, 5400, 4300)) { Assert-ThriveTestPortAvailable $port }
if (Test-Path -LiteralPath $stateFile) {
    $record = Get-Content -LiteralPath $stateFile -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-ThriveTestProcessRecord $projectRoot $record
    foreach ($entry in $record.processes) {
        $child = Get-Process -Id $entry.id -ErrorAction SilentlyContinue
        if ($child -and $child.StartTime.ToUniversalTime().Ticks.ToString() -eq $entry.startedAtUtcTicks) {
            throw 'A THRIVE Test process is already recorded. Use this copy''s stop-project.ps1.'
        }
    }
    Remove-Item -LiteralPath $stateFile
}
& (Join-Path $PSScriptRoot 'start-database.ps1')
if ($LASTEXITCODE -ne 0) { throw 'THRIVE Test PostgreSQL startup failed.' }
$shellPath = (Get-Process -Id $PID).Path
$processes = @()
try {
    foreach ($component in @('backend', 'student', 'admin')) {
        $script = Join-Path $PSScriptRoot "start-$component.ps1"
        $arguments = @('-NoProfile', '-File', ('"{0}"' -f $script))
        if ($EnableDevelopmentIdentity) { $arguments += '-EnableDevelopmentIdentity' }
        if ($component -eq 'backend') { $arguments += '-ApplyMigrations' }
        $process = Start-Process -FilePath $shellPath -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $stateDirectory "$component.log") -RedirectStandardError (Join-Path $stateDirectory "$component.error.log")
        $processes += [pscustomobject]@{ component = $component; id = $process.Id; startedAtUtcTicks = $process.StartTime.ToUniversalTime().Ticks.ToString() }
    }
    @{ application = 'THRIVE Test'; projectRoot = $projectRoot; instanceId = $settings.THRIVE_TEST_INSTANCE; processes = $processes } |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $stateFile -Encoding utf8
    $pending = @{ backend = 'http://localhost:5280/health/ready'; student = 'http://localhost:5400'; admin = 'http://localhost:4300' }
    $deadline = [DateTime]::UtcNow.AddSeconds($StartupTimeoutSeconds)
    while ($pending.Count -gt 0) {
        foreach ($entry in $processes) {
            $child = Get-Process -Id $entry.id -ErrorAction SilentlyContinue
            if (-not $child -or $child.StartTime.ToUniversalTime().Ticks.ToString() -ne $entry.startedAtUtcTicks) {
                throw "The $($entry.component) test process stopped. Inspect .local/thrive-test logs."
            }
        }
        foreach ($component in @($pending.Keys)) {
            try {
                if ($component -eq 'backend') { $ready = (Invoke-RestMethod -Uri $pending[$component] -TimeoutSec 5).status -eq 'Healthy' }
                else { $ready = (Invoke-WebRequest -Uri $pending[$component] -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200 }
                if ($ready) { $pending.Remove($component) }
            } catch { }
        }
        if ($pending.Count -gt 0) {
            if ([DateTime]::UtcNow -ge $deadline) { throw "Startup timed out: $($pending.Keys -join ', '). Inspect .local/thrive-test logs." }
            Start-Sleep -Milliseconds 500
        }
    }
    $identity = Invoke-RestMethod -Uri 'http://localhost:5280/health/isolation'
    if ($identity.application -cne 'THRIVE Test' -or $identity.database -cne 'thrive_test' -or $identity.databasePort -ne 55432) {
        throw 'Live API identity does not match THRIVE Test.'
    }
} catch {
    foreach ($entry in $processes) {
        $child = Get-Process -Id $entry.id -ErrorAction SilentlyContinue
        if ($child -and $child.StartTime.ToUniversalTime().Ticks.ToString() -eq $entry.startedAtUtcTicks) {
            & taskkill /PID $entry.id /T /F | Out-Null
        }
    }
    if (Test-Path -LiteralPath $stateFile) { Remove-Item -LiteralPath $stateFile }
    throw
}
Write-Host 'THRIVE Test: student http://localhost:5400; admin http://localhost:4300; API http://localhost:5280.'
Write-Host 'Logs: .local/thrive-test. Stop only this copy with scripts/stop-project.ps1.'
