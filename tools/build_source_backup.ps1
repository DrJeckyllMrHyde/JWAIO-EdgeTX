param(
    [string]$Version = "0.2.1"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$outputRoot = Join-Path $projectRoot "outputs"
$stagingToken = [guid]::NewGuid().ToString("N").Substring(0, 8)
$stagingRoot = Join-Path $projectRoot ("work\source-backup-v" + $Version + "-" + $stagingToken)
$archive = Join-Path $outputRoot ("JWAIO-v" + $Version + "-SOURCE-BACKUP.zip")
$hashFile = $archive + ".sha256"

$resolvedProject = [IO.Path]::GetFullPath($projectRoot)
$resolvedStaging = [IO.Path]::GetFullPath($stagingRoot)
if (-not $resolvedStaging.StartsWith($resolvedProject + [IO.Path]::DirectorySeparatorChar)) {
    throw "Dossier temporaire hors du projet : $resolvedStaging"
}

if (Test-Path -LiteralPath $stagingRoot) {
    throw "Le dossier temporaire existe deja : $resolvedStaging"
}
New-Item -ItemType Directory -Force -Path $stagingRoot, $outputRoot | Out-Null

foreach ($name in @(
    "README.md", "CHANGELOG.md", "MODE_EMPLOI.txt", "LICENSE", "LICENSE-ASSETS.md",
    "NOTICE", "AUTHORS.md", ".gitignore", ".gitattributes", "sdcard", "docs",
    "tools", "tests"
)) {
    $source = Join-Path $projectRoot $name
    if (Test-Path -LiteralPath $source -PathType Container) {
        # Exclure les caches generes par les tests, sans modifier les sources.
        Get-ChildItem -LiteralPath $source -Recurse -File | Where-Object {
            $_.FullName -notmatch '[\\/]__pycache__[\\/]' -and
            $_.Extension -notin @('.pyc', '.pyo')
        } | ForEach-Object {
            $relative = $_.FullName.Substring($projectRoot.Length + 1)
            $destination = Join-Path $stagingRoot $relative
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $_.FullName -Destination $destination
        }
    } else {
        Copy-Item -LiteralPath $source -Destination $stagingRoot
    }
}

$pdfOutput = Join-Path $stagingRoot "output\pdf"
New-Item -ItemType Directory -Force -Path $pdfOutput | Out-Null
Copy-Item -Path (Join-Path $projectRoot "output\pdf\*") -Destination $pdfOutput

# La sauvegarde se construit depuis un clone propre. Les tests sont dans tests/ ;
# ne jamais inclure le dossier work/ local (brouillons, journaux ou skins prives).
Compress-Archive -Path (Join-Path $stagingRoot "*") -DestinationPath $archive -CompressionLevel Optimal -Force
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive).Hash.ToLowerInvariant()
Set-Content -LiteralPath $hashFile -Value ("$hash  " + [IO.Path]::GetFileName($archive)) -Encoding ascii

Write-Output $archive
Write-Output $hashFile
