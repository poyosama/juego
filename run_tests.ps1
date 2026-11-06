# Corre los tests del juego en modo headless y muestra la salida en consola.
param(
    [string]$Godot = $env:GODOT
)
if (-not $Godot) {
    $Godot = "E:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe"
}

$tmpOut = [System.IO.Path]::GetTempFileName()
$tmpErr = [System.IO.Path]::GetTempFileName()

try {
    $p = Start-Process -FilePath $Godot -ArgumentList "--headless", "--path", $PSScriptRoot, "-s", "res://tests/run_tests.gd" -NoNewWindow -Wait -PassThru -RedirectStandardOutput $tmpOut -RedirectStandardError $tmpErr
    if (Test-Path $tmpOut) { Get-Content $tmpOut }
    if (Test-Path $tmpErr) {
        $errContent = Get-Content $tmpErr
        if ($errContent) { Write-Error ($errContent -join "`n") }
    }
    exit $p.ExitCode
} finally {
    Remove-Item $tmpOut -ErrorAction SilentlyContinue
    Remove-Item $tmpErr -ErrorAction SilentlyContinue
}
