[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/LocalEnvironment.ps1')
$settings = Get-ThriveLocalDatabaseSettings $projectRoot
$state = Get-ThriveTestStateDirectory $projectRoot
$databaseBin = Get-ThriveTestPostgresBin
$clusterRoot = Assert-ThriveTestPath $projectRoot (Join-Path $state 'postgresql')
$databaseData = Assert-ThriveTestPath $projectRoot (Join-Path $clusterRoot 'data')
$clusterOwner = Assert-ThriveTestPath $projectRoot (Join-Path $clusterRoot 'cluster-owner.json')
$nativeRoot = Get-ThriveTestWorkspaceDrive $projectRoot
$nativeData = Join-Path $nativeRoot '.local/thrive-test/postgresql/data'
$nativeClusterRoot = Join-Path $nativeRoot '.local/thrive-test/postgresql'

if (-not (Test-Path -LiteralPath (Join-Path $databaseData 'PG_VERSION'))) {
    Assert-ThriveTestPortAvailable 55432
    if ((Test-Path -LiteralPath $databaseData) -and (Get-ChildItem -LiteralPath $databaseData -Force | Select-Object -First 1)) {
        throw 'Refusing to initialize a nonempty PostgreSQL directory.'
    }
    New-Item -ItemType Directory -Force -Path $clusterRoot | Out-Null
    $passwordFile = Join-Path $nativeClusterRoot ('password-' + [guid]::NewGuid().ToString('N') + '.tmp')
    [IO.File]::WriteAllText($passwordFile, $settings.POSTGRES_PASSWORD, [Text.UTF8Encoding]::new($false))
    try {
        & (Join-Path $databaseBin 'initdb.exe') -D $nativeData -U $settings.POSTGRES_USER --pwfile=$passwordFile -A scram-sha-256 -E UTF8 --locale=C
        if ($LASTEXITCODE -ne 0) { throw 'Unable to initialize the new test PostgreSQL cluster.' }
        @{ instanceId = $settings.THRIVE_TEST_INSTANCE; dataDirectory = $databaseData } |
            ConvertTo-Json | Set-Content -LiteralPath $clusterOwner -Encoding utf8
    } finally { Remove-Item -LiteralPath $passwordFile }
}

if (-not (Test-Path -LiteralPath $clusterOwner)) { throw 'Missing test-cluster owner record; no server was started.' }
$marker = Get-Content -LiteralPath $clusterOwner -Raw -Encoding UTF8 | ConvertFrom-Json
if ($marker.instanceId -cne $settings.THRIVE_TEST_INSTANCE -or $marker.dataDirectory -ine $databaseData) {
    throw 'Test-cluster ownership mismatch; no server was started.'
}
& (Join-Path $databaseBin 'pg_ctl.exe') -D $nativeData status | Out-Null
if ($LASTEXITCODE -ne 0) {
    Assert-ThriveTestPortAvailable 55432
    & (Join-Path $databaseBin 'pg_ctl.exe') -D $nativeData -l (Join-Path $nativeClusterRoot 'postgres.log') -o '-h 127.0.0.1 -p 55432' -w start
    if ($LASTEXITCODE -ne 0) { throw 'Unable to start THRIVE Test PostgreSQL.' }
}
Assert-ThriveTestDatabase $projectRoot -Database postgres
$previousPassword = [Environment]::GetEnvironmentVariable('PGPASSWORD', 'Process')
$previousOptions = [Environment]::GetEnvironmentVariable('PGOPTIONS', 'Process')
try {
    $env:PGPASSWORD = $settings.POSTGRES_PASSWORD
    $env:PGOPTIONS = ''
    $exists = & (Join-Path $databaseBin 'psql.exe') -X -w -h 127.0.0.1 -p 55432 -U $settings.POSTGRES_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = 'thrive_test'"
    if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect the owned test cluster.' }
    if ($exists -ne '1') {
        & (Join-Path $databaseBin 'createdb.exe') -w -h 127.0.0.1 -p 55432 -U $settings.POSTGRES_USER thrive_test
        if ($LASTEXITCODE -ne 0) { throw 'Unable to create thrive_test in the verified test cluster.' }
    }
} finally {
    [Environment]::SetEnvironmentVariable('PGPASSWORD', $previousPassword, 'Process')
    [Environment]::SetEnvironmentVariable('PGOPTIONS', $previousOptions, 'Process')
}
Assert-ThriveTestDatabase $projectRoot
