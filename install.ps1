param(
    [string]$UserDirectory = (Join-Path $env:APPDATA 'Code\User'),
    [switch]$SkipExtensions
)
$ErrorActionPreference = 'Stop'

function Read-Settings([string]$Path) {
    if (!(Test-Path -LiteralPath $Path)) { return [pscustomobject]@{} }
    $raw = [IO.File]::ReadAllText($Path)
    # Preserve quoted strings while removing JSONC comments and trailing commas.
    $strings = '"(?:\\.|[^"\\])*"'
    $raw = [regex]::Replace($raw, "$strings|(?s:/\*.*?\*/)|//[^\r\n]*", {
        param($match)
        if ($match.Value.StartsWith('"')) { return $match.Value }
        return ' '
    })
    $raw = [regex]::Replace($raw, "$strings|,\s*(?=[}\]])", {
        param($match)
        if ($match.Value.StartsWith('"')) { return $match.Value }
        return ''
    })
    if ([string]::IsNullOrWhiteSpace($raw)) { return [pscustomobject]@{} }
    $value = ConvertFrom-Json -InputObject $raw
    if ($value -isnot [pscustomobject]) { throw "Expected a settings object in $Path" }
    return $value
}

function Merge-Settings($Target, $Source) {
    foreach ($property in $Source.PSObject.Properties) {
        $existing = $Target.PSObject.Properties[$property.Name]
        if ($null -ne $existing -and $existing.Value -is [pscustomobject] -and $property.Value -is [pscustomobject]) {
            Merge-Settings $existing.Value $property.Value
        } else {
            $Target | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value -Force
        }
    }
}

$preset = Read-Settings (Join-Path $PSScriptRoot 'settings.json')
$destination = Join-Path $UserDirectory 'settings.json'
$current = Read-Settings $destination
Merge-Settings $current $preset
$json = $current | ConvertTo-Json -Depth 100
$null = ConvertFrom-Json -InputObject $json

if (!$SkipExtensions) {
    $code = Get-Command code -ErrorAction SilentlyContinue
    if (!$code) { throw 'VS Code CLI not found. Install VS Code with Add to PATH, then reopen the terminal, or use -SkipExtensions.' }
    foreach ($extension in Get-Content -LiteralPath (Join-Path $PSScriptRoot 'extensions.txt')) {
        if (![string]::IsNullOrWhiteSpace($extension)) {
            & $code.Source --install-extension $extension.Trim()
            if ($LASTEXITCODE -ne 0) { throw "Could not install extension: $extension. Settings have not been changed." }
        }
    }
}

$null = New-Item -ItemType Directory -Path $UserDirectory -Force
if (Test-Path -LiteralPath $destination) {
    $backup = $destination + '.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff')
    Copy-Item -LiteralPath $destination -Destination $backup
    Write-Host "Backup: $backup"
}
[IO.File]::WriteAllText($destination, $json + [Environment]::NewLine, (New-Object Text.UTF8Encoding($false)))
Write-Host "Applied: $destination"
Write-Host 'Reload VS Code. Install JetBrains Mono separately if needed; Consolas is the fallback.'
