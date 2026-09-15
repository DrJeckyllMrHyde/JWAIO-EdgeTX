param([string]$OutputDirectory = (Join-Path $PSScriptRoot 'dist'))
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$output = Join-Path $OutputDirectory 'JWAIO-Cleaner.exe'
& $compiler /nologo /target:winexe /platform:anycpu /optimize+ "/out:$output" "/win32icon:$PSScriptRoot\assets\app.ico" "/win32manifest:$PSScriptRoot\app.manifest" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Core.dll "/resource:$PSScriptRoot\assets\background.png,background.png" "/resource:$PSScriptRoot\assets\logo.png,logo.png" "$PSScriptRoot\Engine.cs" "$PSScriptRoot\Program.cs"
if ($LASTEXITCODE -ne 0) { throw 'Compilation échouée' }
$digest = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $OutputDirectory 'JWAIO-Cleaner.sha256'), "$digest  JWAIO-Cleaner.exe`n", [Text.Encoding]::ASCII)
