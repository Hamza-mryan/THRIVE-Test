[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/GeneratedWorkspace.ps1')
$projectRoot = Split-Path -Parent $PSScriptRoot
$state = Get-ThriveTestStateDirectory $projectRoot
$fixture = Assert-ThriveTestPath $projectRoot (Join-Path $state ('audit/generated-fixture-' + [guid]::NewGuid().ToString('N')))
$fixtureRoot = Join-Path $fixture 'copy'
$metadata = Join-Path $fixtureRoot 'apps/student-mobile/.dart_tool/flutter_build/stale'
$fixtureState = Join-Path $fixtureRoot '.local/thrive-test'
foreach ($directory in @($metadata, $fixtureState, (Join-Path $fixtureRoot 'infrastructure/local'))) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
}
$instance = [guid]::NewGuid().ToString('N')
@('POSTGRES_DB=thrive_test', 'POSTGRES_USER=thrive_test_local', ('POSTGRES_PASSWORD=' + ('a' * 64)), "THRIVE_TEST_INSTANCE=$instance") |
    Set-Content -LiteralPath (Join-Path $fixtureRoot 'infrastructure/local/.env.local') -Encoding UTF8
@{application='THRIVE Test'; projectRoot=$fixtureRoot; instanceId=$instance} | ConvertTo-Json |
    Set-Content -LiteralPath (Join-Path $fixtureState 'owner.json') -Encoding UTF8
$sentinel = Join-Path $fixture 'original-output-sentinel.txt'
[IO.File]::WriteAllText($sentinel, 'preserve-original-bytes')
@{ inputs=@(); outputs=@($sentinel) } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $metadata 'gen_localizations.stamp') -Encoding UTF8
Initialize-ThriveTestGeneratedWorkspace $fixtureRoot -Component Flutter
if ((Get-Content -LiteralPath $sentinel -Raw -Encoding UTF8) -cne 'preserve-original-bytes' -or (Test-Path -LiteralPath $metadata)) {
    throw 'Copied Flutter metadata was not quarantined safely.'
}
Write-Host 'PASS copied output manifests quarantined before Flutter; external sentinel preserved.'
New-Item -ItemType Directory -Force -Path $metadata | Out-Null
@{ inputs=@(); outputs=@($sentinel) } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $metadata 'gen_localizations.stamp') -Encoding UTF8
$rejected = $false
try { Initialize-ThriveTestGeneratedWorkspace $fixtureRoot -Component Flutter } catch { $rejected = $true }
if (-not $rejected -or (Get-Content -LiteralPath $sentinel -Raw -Encoding UTF8) -cne 'preserve-original-bytes') {
    throw 'Foreign output metadata was not rejected before tool execution.'
}
Write-Host 'PASS reintroduced foreign output manifests rejected; external sentinel preserved.'
