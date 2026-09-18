# JWAIO v0.3.1 Alpha - Python 3 requis ; trois archives, sans journaux personnels.
param([string]$Python = "python", [string]$Output = "")
$ErrorActionPreference = "Stop"
$builder = Join-Path $PSScriptRoot "build_release.py"
if ($Output) { & $Python $builder --output $Output } else { & $Python $builder }
if ($LASTEXITCODE -ne 0) { throw "Echec de creation des archives" }
