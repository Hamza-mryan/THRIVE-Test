[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/LocalEnvironment.ps1')
$state = Get-ThriveTestStateDirectory $projectRoot
Assert-ThriveTestDatabase $projectRoot
$data = Join-Path (Get-ThriveTestWorkspaceDrive $projectRoot) '.local/thrive-test/postgresql/data'
& (Join-Path (Get-ThriveTestPostgresBin) 'pg_ctl.exe') -D $data -m fast -w stop
if ($LASTEXITCODE -ne 0) { throw 'Unable to stop the verified THRIVE Test database.' }
