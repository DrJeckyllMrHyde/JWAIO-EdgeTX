param(
    [string]$Version = "0.2.1"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$sdRoot = Join-Path $projectRoot "sdcard"
$outputRoot = Join-Path $projectRoot "outputs"
$stagingToken = [guid]::NewGuid().ToString("N").Substring(0, 8)
$stagingRoot = Join-Path $projectRoot ("work\release-v" + $Version + "-" + $stagingToken)
$archive = Join-Path $outputRoot ("JWAIO-v" + $Version + ".zip")
$hashFile = $archive + ".sha256"

$required = @(
    "THIRD_PARTY_NOTICES.txt",
    "WIDGETS\JWAIO\main.lua",
    "WIDGETS\JWAIO\config.lua",
    "WIDGETS\JWAIO\lib\util.lua",
    "WIDGETS\JWAIO\lib\data.lua",
    "WIDGETS\JWAIO\lib\distance.lua",
    "WIDGETS\JWAIO\lib\logger.lua",
    "WIDGETS\JWAIO\lib\flight.lua",
    "WIDGETS\JWAIO\lib\audio.lua",
    "WIDGETS\JWAIO\lib\finder.lua",
    "WIDGETS\JWAIO\lib\ui.lua",
    "WIDGETS\JWAIO\img\logo.png",
    "WIDGETS\JWAIO\img\thr0.png",
    "WIDGETS\JWAIO\img\thr1.png",
    "WIDGETS\JWAIO\img\thr2.png",
    "WIDGETS\JWAIO\img\thr3.png",
    "WIDGETS\JWAIO\img\thr4.png",
    "SOUNDS\fr\JWAIO\batlow.wav",
    "SOUNDS\fr\JWAIO\batcrt.wav",
    "SOUNDS\fr\JWAIO\Acro.wav",
    "SOUNDS\fr\JWAIO\Altitude.wav",
    "SOUNDS\fr\JWAIO\angle.wav",
    "SOUNDS\fr\JWAIO\arm.wav",
    "SOUNDS\fr\JWAIO\beeper.wav",
    "SOUNDS\fr\JWAIO\elrs.wav",
    "SOUNDS\fr\JWAIO\finder_bip.wav",
    "SOUNDS\fr\JWAIO\flip.wav",
    "SOUNDS\fr\JWAIO\gps.wav",
    "SOUNDS\fr\JWAIO\Lihv_Full.wav",
    "SOUNDS\fr\JWAIO\Lipo_Liion_Full.wav",
    "SOUNDS\fr\JWAIO\pre_arm.wav",
    "SOUNDS\fr\JWAIO\RTH.wav",
    "SOUNDS\fr\JWAIO\Satellite.wav",
    "SOUNDS\fr\JWAIO\thr.wav",
    "LOGS\JWAIO\README.txt"
)

foreach ($relative in $required) {
    $target = Join-Path $sdRoot $relative
    if (-not (Test-Path -LiteralPath $target)) {
        throw "Fichier requis absent : $relative"
    }
}

$configText = Get-Content -LiteralPath (Join-Path $sdRoot "WIDGETS\JWAIO\config.lua") -Raw
if ($configText -notmatch ('version\s*=\s*"' + [regex]::Escape($Version) + '"')) {
    throw "La version demandee ne correspond pas a config.lua : $Version"
}

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

# Construire dans un dossier intermediaire permet d'ajouter les licences et le
# mode d'emploi a l'archive sans polluer la racine de la carte SD de travail.
$resolvedProject = [IO.Path]::GetFullPath($projectRoot)
$resolvedStaging = [IO.Path]::GetFullPath($stagingRoot)
if (-not $resolvedStaging.StartsWith($resolvedProject + [IO.Path]::DirectorySeparatorChar)) {
    throw "Dossier temporaire hors du projet : $resolvedStaging"
}
if (Test-Path -LiteralPath $stagingRoot) {
    throw "Le dossier temporaire existe deja : $resolvedStaging"
}
New-Item -ItemType Directory -Force -Path $stagingRoot | Out-Null
Copy-Item -Path (Join-Path $sdRoot "*") -Destination $stagingRoot -Recurse
Copy-Item -LiteralPath (Join-Path $projectRoot "LICENSE") -Destination $stagingRoot
Copy-Item -LiteralPath (Join-Path $projectRoot "NOTICE") -Destination $stagingRoot
Copy-Item -LiteralPath (Join-Path $projectRoot "LICENSE-ASSETS.md") -Destination $stagingRoot
Copy-Item -LiteralPath (Join-Path $projectRoot "MODE_EMPLOI.txt") -Destination $stagingRoot

Compress-Archive -Path (Join-Path $stagingRoot "*") -DestinationPath $archive -CompressionLevel Optimal -Force

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive).Hash.ToLowerInvariant()
Set-Content -LiteralPath $hashFile -Value ("$hash  " + [IO.Path]::GetFileName($archive)) -Encoding ascii

Write-Output $archive
Write-Output $hashFile
