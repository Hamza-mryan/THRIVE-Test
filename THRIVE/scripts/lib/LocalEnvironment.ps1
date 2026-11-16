function Assert-ThriveTestPath {
    param([Parameter(Mandatory)][string]$ProjectRoot, [Parameter(Mandatory)][string]$Path)
    $root = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\', '/')
    $target = [IO.Path]::GetFullPath($Path)
    if (-not $target.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'THRIVE Test mutable paths must stay inside this project.'
    }
    $cursor = $target
    while ($cursor -and $cursor.Length -ge $root.Length) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw 'THRIVE Test refuses mutable paths through filesystem links.'
            }
        }
        $cursor = Split-Path -Parent $cursor
    }
    return $target
}

function Get-ThriveLocalDatabaseSettings {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$ProjectRoot)
    $environmentFile = Assert-ThriveTestPath $ProjectRoot (Join-Path $ProjectRoot 'infrastructure/local/.env.local')
    if (-not (Test-Path -LiteralPath $environmentFile)) { throw 'Run scripts/initialize-local.ps1 first.' }
    $settings = @{}
    foreach ($line in Get-Content -LiteralPath $environmentFile -Encoding UTF8) {
        if ($line -match '^(POSTGRES_DB|POSTGRES_USER|POSTGRES_PASSWORD|THRIVE_TEST_INSTANCE)=([^\r\n]+)$') {
            $settings[$Matches[1]] = $Matches[2]
        }
    }
    foreach ($key in @('POSTGRES_DB', 'POSTGRES_USER', 'POSTGRES_PASSWORD', 'THRIVE_TEST_INSTANCE')) {
        if (-not $settings.ContainsKey($key) -or $settings[$key] -notmatch '^[a-zA-Z0-9_]+$') {
            throw "Missing or invalid isolated setting: $key. Run initialize-local.ps1."
        }
    }
    if ($settings.POSTGRES_DB -cne 'thrive_test' -or $settings.POSTGRES_USER -cne 'thrive_test_local' -or
        $settings.POSTGRES_PASSWORD -notmatch '^[a-f0-9]{64}$' -or
        $settings.THRIVE_TEST_INSTANCE -notmatch '^[a-f0-9]{32}$') {
        throw 'THRIVE Test refuses copied/shared database settings. Initialize a new test environment.'
    }
    return $settings
}

function Get-ThriveTestStateDirectory {
    param([Parameter(Mandatory)][string]$ProjectRoot)
    $settings = Get-ThriveLocalDatabaseSettings $ProjectRoot
    $state = Assert-ThriveTestPath $ProjectRoot (Join-Path $ProjectRoot '.local/thrive-test')
    $ownerFile = Assert-ThriveTestPath $ProjectRoot (Join-Path $state 'owner.json')
    if (-not (Test-Path -LiteralPath $ownerFile)) { throw 'Missing THRIVE Test owner record. Run initialize-local.ps1.' }
    # PowerShell 5.1 otherwise treats BOM-less UTF-8 paths as ANSI.
    $owner = Get-Content -LiteralPath $ownerFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($owner.application -cne 'THRIVE Test' -or $owner.projectRoot -ine [IO.Path]::GetFullPath($ProjectRoot) -or
        $owner.instanceId -cne $settings.THRIVE_TEST_INSTANCE) {
        throw 'THRIVE Test owner record belongs to another workspace. No resources were changed.'
    }
    return $state
}

function Assert-ThriveTestPortAvailable {
    param([Parameter(Mandatory)][int]$Port)
    foreach ($address in @([Net.IPAddress]::Loopback, [Net.IPAddress]::IPv6Loopback)) {
        $listener = [Net.Sockets.TcpListener]::new($address, $Port)
        try { $listener.Start() }
        catch { throw "Port $Port is occupied or unavailable. THRIVE Test will not stop its owner." }
        finally { $listener.Stop() }
    }
}

function Get-ThriveTestWorkspaceDrive {
    param([Parameter(Mandatory)][string]$ProjectRoot)
    $state = Get-ThriveTestStateDirectory $ProjectRoot
    $settings = Get-ThriveLocalDatabaseSettings $ProjectRoot
    $recordFile = Assert-ThriveTestPath $ProjectRoot (Join-Path $state 'workspace-drive.json')
    # subst.exe prints non-ASCII targets as question marks on this Windows locale.
    # Query the Unicode device target instead of trusting its console output.
    if (-not ('ThriveTestNativeDrive' -as [type])) {
        Add-Type -TypeDefinition 'using System.Text; using System.Runtime.InteropServices; public static class ThriveTestNativeDrive { [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] public static extern uint QueryDosDevice(string name, StringBuilder target, int max); }'
    }
    $mappings = @{}
    foreach ($candidate in @('Q:', 'R:', 'S:', 'T:', 'U:', 'V:', 'W:', 'X:', 'Y:', 'Z:')) {
        $buffer = [Text.StringBuilder]::new(32768)
        if ([ThriveTestNativeDrive]::QueryDosDevice($candidate, $buffer, $buffer.Capacity)) {
            $target = $buffer.ToString()
            $mappings[$candidate] = if ($target.StartsWith('\??\')) { $target.Substring(4) } else { $target }
        }
    }
    if (Test-Path -LiteralPath $recordFile) {
        $record = Get-Content -LiteralPath $recordFile -Raw -Encoding UTF8 | ConvertFrom-Json
        Assert-ThriveTestProcessRecord $ProjectRoot $record
        $drive = [string]$record.drive
        if ($drive -notmatch '^[Q-Z]:$') { throw 'Invalid test workspace drive record.' }
    } else {
        $occupied = @([IO.Directory]::GetLogicalDrives() | ForEach-Object { $_.Substring(0, 2) })
        $drive = @('T:', 'U:', 'V:', 'W:', 'X:', 'Y:', 'Z:', 'S:', 'R:', 'Q:') |
            Where-Object { $_ -notin $occupied -and -not $mappings.ContainsKey($_) } | Select-Object -First 1
        if (-not $drive) { throw 'No unused ASCII workspace drive is available.' }
    }
    if ($mappings.ContainsKey($drive)) {
        if ($mappings[$drive] -ine [IO.Path]::GetFullPath($ProjectRoot)) { throw 'Test drive belongs to another workspace; refusing to change it.' }
    } else {
        if ([IO.Directory]::Exists($drive + '\')) { throw 'Recorded test drive is occupied by another resource.' }
        & subst.exe $drive ([IO.Path]::GetFullPath($ProjectRoot))
        if ($LASTEXITCODE -ne 0) { throw 'Unable to map the test-only ASCII workspace drive.' }
    }
    if (-not (Test-Path -LiteralPath ($drive + '\infrastructure\local\.env.local'))) { throw 'Test drive did not resolve to this project.' }
    @{ application = 'THRIVE Test'; projectRoot = [IO.Path]::GetFullPath($ProjectRoot); instanceId = $settings.THRIVE_TEST_INSTANCE; drive = $drive } |
        ConvertTo-Json | Set-Content -LiteralPath $recordFile -Encoding utf8
    return ($drive + '\')
}

function Get-ThriveTestPostgresBin {
    $portable = Join-Path $env:USERPROFILE '.cache/thrive-toolchains/postgresql/pgsql/bin'
    if (Test-Path -LiteralPath (Join-Path $portable 'psql.exe')) { return $portable }
    $command = Get-Command psql -ErrorAction Stop
    return Split-Path -Parent $command.Source
}

function Assert-ThriveTestDatabase {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$ProjectRoot, [ValidateSet('postgres', 'thrive_test')][string]$Database = 'thrive_test')
    $settings = Get-ThriveLocalDatabaseSettings $ProjectRoot
    $state = Get-ThriveTestStateDirectory $ProjectRoot
    $data = Assert-ThriveTestPath $ProjectRoot (Join-Path $state 'postgresql/data')
    $nativeData = Join-Path (Get-ThriveTestWorkspaceDrive $ProjectRoot) '.local/thrive-test/postgresql/data'
    $markerFile = Assert-ThriveTestPath $ProjectRoot (Join-Path $state 'postgresql/cluster-owner.json')
    if (-not (Test-Path -LiteralPath $markerFile)) { throw 'Refusing PostgreSQL without its test-cluster owner record.' }
    $marker = Get-Content -LiteralPath $markerFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($marker.instanceId -cne $settings.THRIVE_TEST_INSTANCE -or $marker.dataDirectory -ine $data) {
        throw 'PostgreSQL cluster ownership does not match this test workspace.'
    }
    $databaseBin = Get-ThriveTestPostgresBin
    $previousPassword = [Environment]::GetEnvironmentVariable('PGPASSWORD', 'Process')
    $previousOptions = [Environment]::GetEnvironmentVariable('PGOPTIONS', 'Process')
    try {
        $env:PGPASSWORD = $settings.POSTGRES_PASSWORD
        $env:PGOPTIONS = '-c default_transaction_read_only=on'
        $result = & (Join-Path $databaseBin 'psql.exe') -X -w -h 127.0.0.1 -p 55432 -U $settings.POSTGRES_USER -d $Database -A -t -F '|' -v ON_ERROR_STOP=1 -c "SELECT current_database(), current_user, inet_server_port(), current_setting('data_directory')"
        if ($LASTEXITCODE -ne 0) { throw 'Unable to verify the isolated PostgreSQL server. No migrations are allowed.' }
        $identity = ([string]$result).Trim().Split('|')
        if ($identity.Count -ne 4 -or $identity[0] -cne $Database -or $identity[1] -cne 'thrive_test_local' -or
            $identity[2] -ne '55432' -or [IO.Path]::GetFullPath($identity[3]) -ine [IO.Path]::GetFullPath($nativeData)) {
            throw 'Actual PostgreSQL identity/directory differs from the owned test cluster. Refusing all writes.'
        }
    } finally {
        [Environment]::SetEnvironmentVariable('PGPASSWORD', $previousPassword, 'Process')
        [Environment]::SetEnvironmentVariable('PGOPTIONS', $previousOptions, 'Process')
    }
    Write-Host "Verified owned THRIVE Test PostgreSQL: $Database at 127.0.0.1:55432."
}

function Assert-ThriveTestProcessRecord {
    param([Parameter(Mandatory)][string]$ProjectRoot, [Parameter(Mandatory)]$Record)
    $settings = Get-ThriveLocalDatabaseSettings $ProjectRoot
    if ($Record.application -cne 'THRIVE Test' -or $Record.projectRoot -ine [IO.Path]::GetFullPath($ProjectRoot) -or
        $Record.instanceId -cne $settings.THRIVE_TEST_INSTANCE) {
        throw 'Refusing process records copied from another application or workspace.'
    }
}
