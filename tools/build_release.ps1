# JWAIO 0.3_Alpha - archive installable publique, sans journaux personnels.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$projectRoot = Split-Path -Parent $PSScriptRoot
$outputRoot = Join-Path $projectRoot "outputs"
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
$archive = Join-Path $outputRoot "JWAIO 0.3_Alpha.zip"
if (Test-Path -LiteralPath $archive) { throw "Archive deja presente : $archive" }
$entries = @{}
$sdRoot = Join-Path $projectRoot "sdcard"
foreach ($file in Get-ChildItem -LiteralPath $sdRoot -File -Recurse) {
    $relative = $file.FullName.Substring($sdRoot.Length + 1).Replace('\', '/')
    # Une distribution officielle ne collecte jamais les skins personnels.
    if ($relative -match '^WIDGETS/JWAIO/skins/' -and
        $relative -notmatch '^WIDGETS/JWAIO/skins/jwaio/') { continue }
    if ($relative -match '^LOGS/' -and $relative -ne 'LOGS/JWAIO/README.txt') { continue }
    if ($file.Extension -in @('.luac', '.csv', '.pyc')) { continue }
    $entries[$relative] = $file.FullName
}
foreach ($name in @('LICENSE', 'NOTICE', 'LICENSE-ASSETS.md', 'MODE_EMPLOI.txt')) {
    $entries[$name] = Join-Path $projectRoot $name
}
foreach ($required in @('WIDGETS/JWAIO/main.lua', 'WIDGETS/JWAIO/lib/skin.lua',
    'WIDGETS/JWAIO/lib/diagnostics.lua', 'WIDGETS/JWAIO/skins/jwaio/skin.lua',
    'WIDGETS/JWAIO/skins/jwaio/background.png', 'WIDGETS/JWAIO/skins/jwaio/logo.png',
    'SOUNDS/fr/JWAIO/finder_bip.wav', 'LOGS/JWAIO/README.txt')) {
    if (-not $entries.ContainsKey($required)) { throw "Fichier absent : $required" }
}
$zip = [IO.Compression.ZipFile]::Open($archive, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($name in ($entries.Keys | Sort-Object)) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $entries[$name], $name, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally { $zip.Dispose() }
Get-FileHash -Algorithm SHA256 -LiteralPath $archive
