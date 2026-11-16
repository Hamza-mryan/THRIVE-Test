[CmdletBinding()]
param([switch]$EnableDevelopmentIdentity)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/FlutterEnvironment.ps1')
$tooling = Get-ThriveFlutterTooling -ProjectRoot $projectRoot

Push-Location $tooling.Workspace
try {
    $demoFlag = $EnableDevelopmentIdentity.IsPresent.ToString().ToLowerInvariant()
    & $tooling.Executable run -d web-server --web-hostname localhost --web-port 5400 "--dart-define=ENABLE_DEVELOPMENT_IDENTITY=$demoFlag" --dart-define=API_BASE_URL=http://localhost:5280
    $applicationExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $applicationExitCode
