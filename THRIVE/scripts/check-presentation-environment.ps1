[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$toolchain = Join-Path $env:USERPROFILE '.cache/thrive-toolchains'
$missing = @()
Write-Output 'THRIVE Test presentation prerequisites (read-only)'
Write-Output ('PowerShell: ' + $PSVersionTable.PSVersion.ToString())
Write-Output ('64-bit operating system: ' + [Environment]::Is64BitOperatingSystem)

$tools = @(
    @{ Name = 'dotnet'; Label = '.NET SDK 10.0.403 (or compatible patch)'; Portable = (Join-Path $toolchain 'dotnet/dotnet.exe') },
    @{ Name = 'node'; Label = 'Node.js version allowed by apps/university-admin/package.json'; Portable = (Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node.exe') },
    @{ Name = 'npm'; Label = 'npm for locked Angular dependency installation'; Portable = '' },
    @{ Name = 'flutter'; Label = 'Flutter 3.47.9'; Portable = (Join-Path $toolchain 'flutter/bin/flutter.bat') },
    @{ Name = 'psql'; Label = 'PostgreSQL 17 binaries (including initdb, pg_ctl and createdb)'; Portable = (Join-Path $toolchain 'postgresql/pgsql/bin/psql.exe') }
)
foreach ($tool in $tools) {
    $found = (-not [string]::IsNullOrEmpty($tool.Portable) -and (Test-Path -LiteralPath $tool.Portable -PathType Leaf)) -or
        [bool](Get-Command $tool.Name -CommandType Application,ExternalScript -ErrorAction SilentlyContinue)
    if ($found) { Write-Output ('FOUND executable: ' + $tool.Label + ' (version not verified)') }
    else { $missing += $tool.Name; Write-Output ('MISSING executable: ' + $tool.Label) }
}

$smartAppControl = Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' -Name VerifiedAndReputablePolicyState -ErrorAction SilentlyContinue
$enforced = $null -ne $smartAppControl -and $smartAppControl.VerifiedAndReputablePolicyState -eq 1
if ($enforced) {
    Write-Output 'BLOCKER: Smart App Control is enabled and can block the unsigned local Backend. No security setting was changed.'
} else {
    Write-Output 'Smart App Control enforcement was not observed; other execution restrictions are still possible.'
}

$listeners = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue)
foreach ($port in @(5280, 5400, 4300, 55432)) {
    $occupied = @($listeners | Where-Object { $_.LocalPort -eq $port }).Count -gt 0
    Write-Output (('Port {0}: ' -f $port) + $(if ($occupied) { 'listener exists; verify its ownership before use' } else { 'no listener observed; startup must still check availability' }))
}
if ($missing.Count -gt 0 -or $enforced -or -not [Environment]::Is64BitOperatingSystem) {
    Write-Output 'Setup/blockers remain. This computer is not confirmed ready for the demonstration.'
    exit 2
}
Write-Output 'Executable discovery completed. Verify exact versions, restore locked dependencies, start the isolated Test environment and complete the documented smoke test before the demonstration.'
Write-Output 'This diagnostic does not establish successful application or database startup.'
exit 0
