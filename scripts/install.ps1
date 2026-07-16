[CmdletBinding()]
param(
    [ValidateSet("johnny5i", "pixypi", "all")]
    [string]$Pet,

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

# Keep the simple no-argument installation experience while letting a friend
# choose one pet or install the complete collection.
if ([string]::IsNullOrWhiteSpace($Pet)) {
    Write-Host ""
    Write-Host "Choose which Codex pet to install:"
    Write-Host "  1. Johnny5i"
    Write-Host "  2. PixyPi"
    Write-Host "  3. Both pets"
    $Selection = Read-Host "Enter 1, 2, or 3 (default: 3)"

    $Pet = switch ($Selection) {
        "1" { "johnny5i" }
        "2" { "pixypi" }
        ""  { "all" }
        "3" { "all" }
        default { throw "Invalid selection. Run the installer again and choose 1, 2, or 3." }
    }
}

$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$PetsDirectory = Join-Path $CodexHome "pets"

# Backups stay outside the active pets directory. This prevents Codex from
# scanning archived manifests as additional custom pets.
$PetBackupsDirectory = Join-Path $CodexHome "pet-backups"

$PetIds = if ($Pet -eq "all") {
    @("johnny5i", "pixypi")
}
else {
    @($Pet)
}

New-Item -ItemType Directory -Path $PetsDirectory -Force | Out-Null

foreach ($PetId in $PetIds) {
    $SourcePetDirectory = Join-Path $RepositoryRoot "pet\$PetId"
    $SourceManifestPath = Join-Path $SourcePetDirectory "pet.json"
    $SourceSpritesheetPath = Join-Path $SourcePetDirectory "spritesheet.webp"
    $TargetPetDirectory = Join-Path $PetsDirectory $PetId

    if (-not (Test-Path -LiteralPath $SourceManifestPath -PathType Leaf)) {
        throw "The source package is missing pet.json: $SourcePetDirectory"
    }

    if (-not (Test-Path -LiteralPath $SourceSpritesheetPath -PathType Leaf)) {
        throw "The source package is missing spritesheet.webp: $SourcePetDirectory"
    }

    $SourceManifest = Get-Content -Raw -LiteralPath $SourceManifestPath | ConvertFrom-Json
    if (
        $SourceManifest.id -ne $PetId -or
        $SourceManifest.spriteVersionNumber -ne 2 -or
        $SourceManifest.spritesheetPath -ne "spritesheet.webp"
    ) {
        throw "The source manifest did not pass v2 validation: $SourceManifestPath"
    }

    # Preserve an existing installation before replacing it. Milliseconds in
    # the timestamp make repeated installations safely distinguishable.
    if (Test-Path -LiteralPath $TargetPetDirectory) {
        New-Item -ItemType Directory -Path $PetBackupsDirectory -Force | Out-Null
        $Timestamp = Get-Date -Format "yyyyMMdd-HHmmssfff"
        $ArchiveDirectory = Join-Path $PetBackupsDirectory "$PetId.archive-$Timestamp"
        Move-Item -LiteralPath $TargetPetDirectory -Destination $ArchiveDirectory
        Write-Host "Archived the previous $PetId installation to: $ArchiveDirectory"
    }

    Copy-Item -LiteralPath $SourcePetDirectory -Destination $TargetPetDirectory -Recurse

    $InstalledManifestPath = Join-Path $TargetPetDirectory "pet.json"
    $InstalledSpritesheetPath = Join-Path $TargetPetDirectory "spritesheet.webp"
    $InstalledManifest = Get-Content -Raw -LiteralPath $InstalledManifestPath | ConvertFrom-Json

    if (
        $InstalledManifest.id -ne $PetId -or
        $InstalledManifest.spriteVersionNumber -ne 2 -or
        $InstalledManifest.spritesheetPath -ne "spritesheet.webp" -or
        -not (Test-Path -LiteralPath $InstalledSpritesheetPath -PathType Leaf)
    ) {
        throw "The installed $PetId package did not pass v2 verification."
    }

    Write-Host "Installed $PetId successfully at: $TargetPetDirectory"
}

Write-Host ""
Write-Host "Restart Codex or refresh Settings > Appearance > Pets."
Write-Host "Select Johnny5i or PixyPi, then choose Wake Pet."
