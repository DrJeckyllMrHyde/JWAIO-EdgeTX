# JWAIO 0.3_Alpha - sauvegarde des sources publiques ; aucun dossier work/ ou outputs/.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$projectRoot = Split-Path -Parent $PSScriptRoot
$outputRoot = Join-Path $projectRoot "outputs"
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
$archive = Join-Path $outputRoot "JWAIO 0.3_Alpha SOURCE-BACKUP.zip"
if (Test-Path -LiteralPath $archive) { throw "Archive deja presente : $archive" }
$zip = [IO.Compression.ZipFile]::Open($archive, [IO.Compression.ZipArchiveMode]::Create)
try {
    $files = @(Get-ChildItem -LiteralPath $projectRoot -File -Force)
    foreach ($folder in @('sdcard', 'docs', 'tools', 'tests')) {
        $files += Get-ChildItem -LiteralPath (Join-Path $projectRoot $folder) -File -Recurse
    }
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($projectRoot.Length + 1).Replace('\', '/')
        if ($relative -match '__pycache__' -or $file.Extension -in @('.pyc','.luac','.csv')) { continue }
        if ($relative -match '^sdcard/LOGS/' -and $relative -ne 'sdcard/LOGS/JWAIO/README.txt') { continue }
        if ($relative -match '^sdcard/WIDGETS/JWAIO/skins/' -and
            $relative -notmatch '^sdcard/WIDGETS/JWAIO/skins/jwaio/') { continue }
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $file.FullName, $relative, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally { $zip.Dispose() }
Get-FileHash -Algorithm SHA256 -LiteralPath $archive
