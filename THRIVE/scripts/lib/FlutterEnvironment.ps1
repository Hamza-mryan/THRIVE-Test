. (Join-Path $PSScriptRoot 'GeneratedWorkspace.ps1')

function Get-ThriveFlutterTooling {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$ProjectRoot)
    $state = Get-ThriveTestStateDirectory $ProjectRoot
    # Keep dependency restoration inside Test, independent from shared cache cleanup.
    $env:PUB_CACHE = Assert-ThriveTestPath $ProjectRoot (Join-Path $state 'tooling/pub-cache')
    Initialize-ThriveTestGeneratedWorkspace $ProjectRoot -Component Flutter
    $studentRoot = Assert-ThriveTestPath $ProjectRoot (Join-Path $ProjectRoot 'apps/student-mobile')
    $portableFlutter = Join-Path $env:USERPROFILE '.cache/thrive-toolchains/flutter/bin/flutter.bat'
    $flutterCommand = if (Test-Path -LiteralPath $portableFlutter) { $portableFlutter } else { (Get-Command flutter -ErrorAction Stop).Source }
    # Never reuse the original project's global tooling junction.
    $nativeRoot = Get-ThriveTestWorkspaceDrive $ProjectRoot
    return [pscustomobject]@{ Executable = $flutterCommand; Workspace = (Join-Path $nativeRoot 'apps/student-mobile') }
}
