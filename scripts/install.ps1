[CmdletBinding()]
param(
    [string]$CodexHome
)

$ErrorActionPreference = "Stop"

# Resolve the default Codex home without hardcoding a username. A caller can
# supply -CodexHome when Codex uses a custom location.
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $CodexHome = $env:CODEX_HOME
    }
    else {
        $CodexHome = Join-Path $env:USERPROFILE ".codex"
    }
}

$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$SourcePetDirectory = Join-Path $RepositoryRoot "pet\johnny5i"
$PetsDirectory = Join-Path $CodexHome "pets"
$TargetPetDirectory = Join-Path $PetsDirectory "johnny5i"

if (-not (Test-Path -LiteralPath (Join-Path $SourcePetDirectory "pet.json"))) {
    throw "The source package is missing pet.json: $SourcePetDirectory"
}

if (-not (Test-Path -LiteralPath (Join-Path $SourcePetDirectory "spritesheet.webp"))) {
    throw "The source package is missing spritesheet.webp: $SourcePetDirectory"
}

New-Item -ItemType Directory -Path $PetsDirectory -Force | Out-Null

# Preserve an existing installation before replacing it. The timestamp makes
# repeat installations safe and keeps the prior package recoverable.
if (Test-Path -LiteralPath $TargetPetDirectory) {
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $ArchiveDirectory = Join-Path $PetsDirectory "johnny5i.archive-$Timestamp"
    Move-Item -LiteralPath $TargetPetDirectory -Destination $ArchiveDirectory
    Write-Host "Archived the previous Johnny5i installation to: $ArchiveDirectory"
}

Copy-Item -LiteralPath $SourcePetDirectory -Destination $TargetPetDirectory -Recurse

$Manifest = Get-Content -Raw -LiteralPath (Join-Path $TargetPetDirectory "pet.json") | ConvertFrom-Json
if ($Manifest.id -ne "johnny5i" -or $Manifest.spriteVersionNumber -ne 2) {
    throw "The installed pet manifest did not pass the Johnny5i v2 verification."
}

Write-Host "Johnny5i was installed successfully at: $TargetPetDirectory"
Write-Host "Restart Codex or refresh Settings > Pets, then select johnny5i."
