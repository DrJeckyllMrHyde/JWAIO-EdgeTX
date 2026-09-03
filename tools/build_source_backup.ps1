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
    Copy-Item -LiteralPath (Join-Path $projectRoot $name) -Destination $stagingRoot -Recurse
}

$pdfOutput = Join-Path $stagingRoot "output\pdf"
New-Item -ItemType Directory -Force -Path $pdfOutput | Out-Null
Copy-Item -Path (Join-Path $projectRoot "output\pdf\*") -Destination $pdfOutput

$qaRoot = Join-Path $stagingRoot "work"
$qaLuaRoot = Join-Path $qaRoot "lua-check"
New-Item -ItemType Directory -Force -Path $qaLuaRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $projectRoot "work\validate_release.py") -Destination $qaRoot
Copy-Item -LiteralPath (Join-Path $projectRoot "work\generate_assets.py") -Destination $qaRoot
foreach ($name in @("check.mjs", "runtime_harness.lua", "package.json", "pnpm-lock.yaml")) {
    Copy-Item -LiteralPath (Join-Path $projectRoot ("work\lua-check\" + $name)) -Destination $qaLuaRoot
}
Compress-Archive -Path (Join-Path $stagingRoot "*") -DestinationPath $archive -CompressionLevel Optimal -Force
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive).Hash.ToLowerInvariant()
Set-Content -LiteralPath $hashFile -Value ("$hash  " + [IO.Path]::GetFileName($archive)) -Encoding ascii

Write-Output $archive
Write-Output $hashFile
