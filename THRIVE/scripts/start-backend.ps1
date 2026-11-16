[CmdletBinding()]
param(
    [switch]$EnableDevelopmentIdentity,
    [switch]$ApplyMigrations
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$backendRoot = Join-Path $projectRoot 'services/backend'
. (Join-Path $PSScriptRoot 'lib/GeneratedWorkspace.ps1')
$databaseSettings = Get-ThriveLocalDatabaseSettings -ProjectRoot $projectRoot
$state = Get-ThriveTestStateDirectory $projectRoot
Assert-ThriveTestPortAvailable 5280
Assert-ThriveTestDatabase $projectRoot
Initialize-ThriveTestGeneratedWorkspace $projectRoot -Component Backend

$portableDotnet = Join-Path $env:USERPROFILE '.cache/thrive-toolchains/dotnet/dotnet.exe'
$dotnetCommand = if (Test-Path -LiteralPath $portableDotnet) {
    $portableDotnet
}
else {
    (Get-Command dotnet -ErrorAction Stop).Source
}

$developmentEnvironment = @{
    ASPNETCORE_ENVIRONMENT = 'Development'
    ASPNETCORE_URLS = 'http://localhost:5280'
    ConnectionStrings__Thrive = "Host=127.0.0.1;Port=55432;Database=$($databaseSettings.POSTGRES_DB);Username=$($databaseSettings.POSTGRES_USER);Password=$($databaseSettings.POSTGRES_PASSWORD);Include Error Detail=false"
    DevelopmentIdentity__Enabled = $EnableDevelopmentIdentity.IsPresent.ToString().ToLowerInvariant()
    Identity__Authority = ''
    Identity__Audience = ''
    DOTNET_CLI_HOME = (Join-Path $state 'tooling/dotnet-home')
    DOTNET_CLI_TELEMETRY_OPTOUT = '1'
    DOTNET_GENERATE_ASPNET_CERTIFICATE = 'false'
    DOTNET_ADD_GLOBAL_TOOLS_TO_PATH = 'false'
    NUGET_HTTP_CACHE_PATH = (Join-Path $state 'tooling/nuget-http')
    NUGET_PACKAGES = (Join-Path $state 'tooling/nuget-packages')
    NUGET_SCRATCH = (Join-Path $state 'tooling/nuget-scratch')
}

$previousEnvironment = @{}
foreach ($key in $developmentEnvironment.Keys) {
    $previousEnvironment[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
    [Environment]::SetEnvironmentVariable($key, $developmentEnvironment[$key], 'Process')
}

Push-Location $backendRoot
try {
    if ($ApplyMigrations) {
        Assert-ThriveTestDatabase $projectRoot
        & $dotnetCommand tool restore
        if ($LASTEXITCODE -ne 0) { throw 'Unable to restore local EF tools.' }
        & $dotnetCommand ef database update --project src/Thrive.Infrastructure --startup-project src/Thrive.Api
        if ($LASTEXITCODE -ne 0) { throw 'Unable to apply development migrations.' }
    }
    # Framework-dependent launch uses the official dotnet host on every platform.
    & $dotnetCommand run --project src/Thrive.Api --no-launch-profile --property:UseAppHost=false
    $applicationExitCode = $LASTEXITCODE
}
finally {
    Pop-Location
    foreach ($key in $previousEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($key, $previousEnvironment[$key], 'Process')
    }
}

exit $applicationExitCode
