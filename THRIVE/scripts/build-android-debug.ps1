[CmdletBinding()]
param(
    [switch]$EnableDevelopmentIdentity,
    [uri]$ApiBaseUrl = 'http://10.0.2.2:5280',
    [ValidateSet('android-arm', 'android-arm64', 'android-x64')]
    [string]$TargetPlatform = 'android-arm64'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($ApiBaseUrl.Scheme -ne 'http' -or $ApiBaseUrl.Port -ne 5280 -or
    $ApiBaseUrl.Host -notin @('localhost', '127.0.0.1', '10.0.2.2') -or $ApiBaseUrl.UserInfo) {
    throw 'THRIVE Test APK builds require the isolated local API on port 5280. Original/remote API URLs are refused.'
}
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'lib/FlutterEnvironment.ps1')
$tooling = Get-ThriveFlutterTooling -ProjectRoot $projectRoot
$toolchainRoot = Join-Path $env:USERPROFILE '.cache/thrive-toolchains'
$state = Get-ThriveTestStateDirectory $projectRoot
$portableJava = Get-ChildItem (Join-Path $toolchainRoot 'java17') -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
$javaRoot = if ($env:JAVA_HOME) { $env:JAVA_HOME } elseif ($portableJava) { $portableJava.FullName } else { throw 'Configure JAVA_HOME for JDK17 or newer.' }
$sdkRoot = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $toolchainRoot 'android-sdk' }
if (-not (Test-Path -LiteralPath $sdkRoot)) { throw 'Configure an installed Android SDK using ANDROID_HOME.' }

# Build only this copy. The original project's shared mirror is never used.
$androidWorkspace = $tooling.Workspace

$environment = @{ JAVA_HOME = $javaRoot; ANDROID_HOME = $sdkRoot; GRADLE_USER_HOME = (Join-Path (Get-ThriveTestWorkspaceDrive $projectRoot) '.local/thrive-test/tooling/gradle') }
$previous = @{}
foreach ($key in $environment.Keys) {
    $previous[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
    [Environment]::SetEnvironmentVariable($key, $environment[$key], 'Process')
}
Push-Location $androidWorkspace
try {
    & $tooling.Executable pub get
    if ($LASTEXITCODE -ne 0) { throw 'Unable to restore Android build dependencies.' }
    $demoFlag = $EnableDevelopmentIdentity.IsPresent.ToString().ToLowerInvariant()
    & $tooling.Executable build apk --debug --target-platform $TargetPlatform "--dart-define=ENABLE_DEVELOPMENT_IDENTITY=$demoFlag" "--dart-define=API_BASE_URL=$($ApiBaseUrl.AbsoluteUri.TrimEnd('/'))"
    if ($LASTEXITCODE -ne 0) { throw 'Android debug build failed.' }
    $output = Join-Path $projectRoot 'output/android'
    New-Item -ItemType Directory -Force -Path $output | Out-Null
    $apkName = "THRIVE-Test-development-$($TargetPlatform.Replace('android-', '')).apk"
    Copy-Item -LiteralPath 'build/app/outputs/flutter-apk/app-debug.apk' -Destination (Join-Path $output $apkName)
    Write-Host "Created output/android/$apkName (debug signing, development use only)."
} finally {
    Pop-Location
    foreach ($key in $previous.Keys) { [Environment]::SetEnvironmentVariable($key, $previous[$key], 'Process') }
}
