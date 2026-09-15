param([string]$TestDirectory)
$ErrorActionPreference = 'Stop'
if (-not $TestDirectory) { $TestDirectory = Join-Path $env:TEMP ('JWAIO-Cleaner-tests-' + [Guid]::NewGuid().ToString('N')) }
if (Test-Path -LiteralPath $TestDirectory) { throw 'Choisissez un nouveau dossier de test vide.' }
New-Item -ItemType Directory -Path $TestDirectory | Out-Null
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$testExe = Join-Path $TestDirectory 'Tests.exe'
& $compiler /nologo /target:exe "/out:$testExe" /reference:System.Core.dll "$PSScriptRoot\Engine.cs" "$PSScriptRoot\Tests.cs"
if ($LASTEXITCODE -ne 0) { throw 'Compilation des tests échouée' }
$linkRoot = Join-Path $TestDirectory 'link-radio'
$outsideRoot = Join-Path $TestDirectory 'outside'
New-Item -ItemType Directory -Force -Path (Join-Path $linkRoot 'WIDGETS'), $outsideRoot | Out-Null
Set-Content -LiteralPath (Join-Path $outsideRoot 'untouched.txt') -Value 'unchanged'
New-Item -ItemType Junction -Path (Join-Path $linkRoot 'WIDGETS\JWAIO') -Target $outsideRoot | Out-Null
& $testExe (Join-Path $TestDirectory 'fixtures') $linkRoot
if ($LASTEXITCODE -ne 0) { throw 'Tests échoués' }
if ((Get-Content -LiteralPath (Join-Path $outsideRoot 'untouched.txt') -Raw).Trim() -ne 'unchanged') { throw 'Fichier extérieur altéré' }
Write-Output "Tests terminés. Données de test conservées pour inspection : $TestDirectory"
