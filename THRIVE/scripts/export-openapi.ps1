[CmdletBinding()]
param([uri]$ApiBaseUrl = 'http://localhost:5280')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$documentUrl = [uri]::new($ApiBaseUrl, '/openapi/v1.json')
$response = Invoke-WebRequest -Uri $documentUrl
$document = $response.Content | ConvertFrom-Json -AsHashtable
if (-not $document.ContainsKey('openapi') -or -not $document.ContainsKey('paths')) {
    throw 'The server did not return an OpenAPI document.'
}

# A local listener address is environment configuration, not part of the shared contract.
$document.Remove('servers') | Out-Null
$outputDirectory = Join-Path $projectRoot 'contracts/openapi'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$outputFile = Join-Path $outputDirectory 'thrive-v1.json'
$json = ($document | ConvertTo-Json -Depth 100) + "`n"
[System.IO.File]::WriteAllText($outputFile, $json, [System.Text.UTF8Encoding]::new($false))
Write-Host 'Exported contracts/openapi/thrive-v1.json from the running development API.'
