[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/LocalEnvironment.ps1')
$projectRoot = Split-Path -Parent $PSScriptRoot
$state = Get-ThriveTestStateDirectory $projectRoot
$fixture = Assert-ThriveTestPath $projectRoot (Join-Path $state ('audit/local-encoding-' + [guid]::NewGuid().ToString('N')))
$fixtureState = Join-Path $fixture '.local/thrive-test'
$fixtureEnvironment = Join-Path $fixture 'infrastructure/local'
foreach ($directory in @($fixtureState, $fixtureEnvironment)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
}

# The real workspace path contains Arabic. Use BOM-less UTF-8, as PowerShell 7 does.
$utf8 = New-Object Text.UTF8Encoding($false)
$instance = [guid]::NewGuid().ToString('N')
$settings = @('POSTGRES_DB=thrive_test', 'POSTGRES_USER=thrive_test_local', ('POSTGRES_PASSWORD=' + ('a' * 64)), "THRIVE_TEST_INSTANCE=$instance")
[IO.File]::WriteAllText((Join-Path $fixtureEnvironment '.env.local'), ($settings -join "`n"), $utf8)
$ownerFile = Join-Path $fixtureState 'owner.json'
$owner = @{ application = 'THRIVE Test'; projectRoot = $fixture; instanceId = $instance }
[IO.File]::WriteAllText($ownerFile, ($owner | ConvertTo-Json), $utf8)
if ((Get-ThriveTestStateDirectory $fixture) -ine $fixtureState) {
    throw 'UTF-8 owner record did not resolve to its actual workspace.'
}
Write-Host 'PASS BOM-less UTF-8 owner record with a Unicode workspace path.'

$recordFile = Join-Path $fixtureState 'test-processes.json'
[IO.File]::WriteAllText($recordFile, ($owner | ConvertTo-Json), $utf8)
$record = Get-Content -LiteralPath $recordFile -Raw -Encoding UTF8 | ConvertFrom-Json
Assert-ThriveTestProcessRecord $fixture $record
Write-Host 'PASS UTF-8 lifecycle record retains the exact workspace identity.'

foreach ($field in @('projectRoot', 'instanceId', 'application')) {
    $foreign = $owner.Clone()
    $foreign[$field] = if ($field -eq 'projectRoot') { Join-Path $fixture 'other-workspace' } elseif ($field -eq 'instanceId') { [guid]::NewGuid().ToString('N') } else { 'THRIVE' }
    [IO.File]::WriteAllText($ownerFile, ($foreign | ConvertTo-Json), $utf8)
    $rejected = $false
    try { $null = Get-ThriveTestStateDirectory $fixture } catch {
        if ($_.Exception.Message -ne 'THRIVE Test owner record belongs to another workspace. No resources were changed.') { throw }
        $rejected = $true
    }
    if (-not $rejected) { throw "Foreign owner $field was accepted." }
    $rejected = $false
    try { Assert-ThriveTestProcessRecord $fixture ([pscustomobject]$foreign) } catch {
        if ($_.Exception.Message -ne 'Refusing process records copied from another application or workspace.') { throw }
        $rejected = $true
    }
    if (-not $rejected) { throw "Foreign lifecycle $field was accepted." }
    Write-Host "PASS foreign $field remains rejected in owner and lifecycle records."
}
Write-Host '5/5 encoding/ownership checks passed; only disposable fixture files were written.'
