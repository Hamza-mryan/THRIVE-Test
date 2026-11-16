. (Join-Path $PSScriptRoot 'LocalEnvironment.ps1')

function Assert-ThriveTestFlutterOutputs {
    param([Parameter(Mandatory)][string]$ProjectRoot)
    $state = Get-ThriveTestStateDirectory $ProjectRoot
    $roots = @([IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\') + '\')
    if (Test-Path -LiteralPath (Join-Path $state 'workspace-drive.json')) {
        $roots += (Get-ThriveTestWorkspaceDrive $ProjectRoot)
    }
    $buildState = Assert-ThriveTestPath $ProjectRoot (Join-Path $ProjectRoot 'apps/student-mobile/.dart_tool/flutter_build')
    if (-not (Test-Path -LiteralPath $buildState)) { return }
    foreach ($file in Get-ChildItem -LiteralPath $buildState -Recurse -File) {
        if ($file.Extension -ne '.stamp' -and $file.Name -notin @('outputs.json', 'gen_l10n_inputs_and_outputs.json')) { continue }
        $data = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        $outputs = if ($file.Name -eq 'outputs.json') { @($data) } else { @($data.outputs) }
        foreach ($output in $outputs) {
            if ([string]::IsNullOrWhiteSpace([string]$output)) { continue }
            $outputPath = [IO.Path]::GetFullPath(([string]$output).Replace('*', ''))
            $owned = $false
            foreach ($root in $roots) { if ($outputPath.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { $owned = $true } }
            if (-not $owned) { throw 'Unowned Flutter output found in cached build metadata. Refusing to run Flutter; quarantine the copied generated state first.' }
        }
    }
}

function Initialize-ThriveTestGeneratedWorkspace {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$ProjectRoot, [Parameter(Mandatory)][ValidateSet('Flutter', 'Backend', 'Admin')][string]$Component)
    $state = Get-ThriveTestStateDirectory $ProjectRoot
    $settings = Get-ThriveLocalDatabaseSettings $ProjectRoot
    $ownerFile = Assert-ThriveTestPath $ProjectRoot (Join-Path $state ("generated-$($Component.ToLowerInvariant()).json"))
    if (Test-Path -LiteralPath $ownerFile) {
        Assert-ThriveTestProcessRecord $ProjectRoot (Get-Content -LiteralPath $ownerFile -Raw -Encoding UTF8 | ConvertFrom-Json)
        if ($Component -eq 'Flutter') { Assert-ThriveTestFlutterOutputs $ProjectRoot }
        return
    }
    $targets = switch ($Component) {
        Flutter {
            @('apps/student-mobile/.dart_tool', 'apps/student-mobile/build', 'apps/student-mobile/android/.gradle',
              'apps/student-mobile/android/app/.cxx', 'apps/student-mobile/android/local.properties',
              'apps/student-mobile/.flutter-plugins-dependencies', 'apps/student-mobile/.flutter-plugins',
              'apps/student-mobile/ios/Flutter/ephemeral', 'apps/student-mobile/ios/Flutter/Generated.xcconfig',
              'apps/student-mobile/ios/Flutter/flutter_export_environment.sh')
        }
        Backend {
            foreach ($area in @('services/backend/src', 'services/backend/tests')) {
                foreach ($directory in Get-ChildItem -LiteralPath (Join-Path $ProjectRoot $area) -Directory) {
                    "$area/$($directory.Name)/obj"
                    "$area/$($directory.Name)/bin"
                }
            }
        }
        Admin { @('apps/university-admin/.angular', 'apps/university-admin/dist') }
    }
    $archive = Assert-ThriveTestPath $ProjectRoot (Join-Path $state ('quarantine/' + $Component.ToLowerInvariant() + '-' + [guid]::NewGuid().ToString('N')))
    foreach ($relative in $targets) {
        $source = Assert-ThriveTestPath $ProjectRoot (Join-Path $ProjectRoot $relative)
        if (-not (Test-Path -LiteralPath $source)) { continue }
        if ((Get-Item -LiteralPath $source).PSIsContainer -and
            (Get-ChildItem -LiteralPath $source -Recurse -Force -Attributes ReparsePoint -ErrorAction Stop | Select-Object -First 1)) {
            throw 'Refusing to move generated state containing filesystem links.'
        }
        $destination = Assert-ThriveTestPath $ProjectRoot (Join-Path $archive ($relative.Replace('/', '_')))
        New-Item -ItemType Directory -Force -Path $archive | Out-Null
        Move-Item -LiteralPath $source -Destination $destination
    }
    @{ application = 'THRIVE Test'; projectRoot = [IO.Path]::GetFullPath($ProjectRoot); instanceId = $settings.THRIVE_TEST_INSTANCE } |
        ConvertTo-Json | Set-Content -LiteralPath $ownerFile -Encoding utf8
    if ($Component -eq 'Flutter') { Assert-ThriveTestFlutterOutputs $ProjectRoot }
    Write-Host "Prepared owned $Component generated state; copied caches were archived inside this test workspace."
}
