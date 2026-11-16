[CmdletBinding()]
param([switch]$RotateCopiedEnvironment)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/LocalEnvironment.ps1')
$environmentFile = Assert-ThriveTestPath $projectRoot (Join-Path $projectRoot 'infrastructure/local/.env.local')
$state = Assert-ThriveTestPath $projectRoot (Join-Path $projectRoot '.local/thrive-test')
$ownerFile = Assert-ThriveTestPath $projectRoot (Join-Path $state 'owner.json')

if (Test-Path -LiteralPath $environmentFile) {
    try {
        $settings = Get-ThriveLocalDatabaseSettings $projectRoot
        $null = Get-ThriveTestStateDirectory $projectRoot
        Write-Host 'Existing THRIVE Test credentials and workspace ownership verified; preserved.'
        return
    } catch {
        if (-not $RotateCopiedEnvironment) { throw 'Copied/shared environment detected. Run initialize-local.ps1 -RotateCopiedEnvironment to replace only this copy''s credentials.' }
        if ((Test-Path -LiteralPath $ownerFile) -or (Test-Path -LiteralPath (Join-Path $state 'postgresql/data/PG_VERSION'))) {
            throw 'Refusing credential rotation for an existing owned test cluster.'
        }
    }
}

$bytes = New-Object byte[] 32
$generator = [Security.Cryptography.RandomNumberGenerator]::Create()
try { $generator.GetBytes($bytes) } finally { $generator.Dispose() }
$password = [BitConverter]::ToString($bytes).Replace('-', '').ToLowerInvariant()
$instance = [guid]::NewGuid().ToString('N')
New-Item -ItemType Directory -Force -Path $state | Out-Null
$lines = @('POSTGRES_DB=thrive_test', 'POSTGRES_USER=thrive_test_local', "POSTGRES_PASSWORD=$password", "THRIVE_TEST_INSTANCE=$instance")
[IO.File]::WriteAllText($environmentFile, ($lines -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
@{ application = 'THRIVE Test'; projectRoot = [IO.Path]::GetFullPath($projectRoot); instanceId = $instance } |
    ConvertTo-Json | Set-Content -LiteralPath $ownerFile -Encoding utf8
Write-Host 'Created independent THRIVE Test credentials and owner record inside this copy. No database was accessed.'
