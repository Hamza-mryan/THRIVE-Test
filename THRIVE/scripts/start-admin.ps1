[CmdletBinding()]
param([switch]$EnableDevelopmentIdentity)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/GeneratedWorkspace.ps1')
Initialize-ThriveTestGeneratedWorkspace $projectRoot -Component Admin
$adminRoot = Join-Path $projectRoot 'apps/university-admin'
$installedNode = Get-Command node -ErrorAction SilentlyContinue
$bundledNode = Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node.exe'
$nodeCommand = if ($installedNode) { $installedNode.Source } elseif (Test-Path -LiteralPath $bundledNode) { $bundledNode } else { throw 'Install a supported Node.js version first.' }
$configuration = if ($EnableDevelopmentIdentity) { 'demo' } else { 'development' }

Push-Location $adminRoot
try {
    if (-not (Test-Path -LiteralPath 'node_modules/@angular/cli/bin/ng.js')) {
        throw 'Install university-admin dependencies with npm ci first.'
    }
    & $nodeCommand node_modules/@angular/cli/bin/ng.js serve --host localhost --port 4300 --configuration $configuration
    $applicationExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $applicationExitCode
