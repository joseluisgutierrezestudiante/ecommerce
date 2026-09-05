# ============================================================
#  mysql.ps1 - Acceso CLI a MySQL para el proyecto e-commerce
#  Permite a opencode / la terminal consultar y administrar la
#  misma base de datos que gestiona MySQL Workbench.
#
#  USO:
#    .\scripts\mysql.ps1 -Sql "SELECT * FROM categories;"
#    .\scripts\mysql.ps1 -Sql "SHOW TABLES;" -Database ecommerce
#    .\scripts\mysql.ps1 -File .\database\ecommerce_schema.sql
#
#  CONTRASEÑA (por orden de prioridad):
#    1. Variable de entorno  MYSQL_PWD   (recomendada)
#    2. Parámetro  -Password
#    3. Solicitud interactiva (nunca se guarda en disco)
#
#  NUNCA se coloca la contraseña en este script ni en el repo.
# ============================================================

[CmdletBinding()]
param(
    [string]$HostName = "127.0.0.1",
    [int]$Port = 3306,
    [string]$User = "root",
    [string]$Database = "ecommerce",
    [string]$Sql,
    [string]$File,
    [string]$Password = $env:MYSQL_PWD
)

$ErrorActionPreference = "Stop"

# --- Localización del cliente mysql -------------------------
$mysql = (Get-Command mysql -ErrorAction SilentlyContinue).Source
if (-not $mysql) {
    $candidates = @(
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql",
        "${env:ProgramFiles(x86)}\MySQL\MySQL Server 8.0\bin\mysql.exe"
    )
    $mysql = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $mysql) {
    throw "No se encontró el cliente mysql.exe. Instale MySQL o use -Password con Get-Command."
}

# --- Credenciales seguras ------------------------------------
$promptedPassword = $false
if (-not $Password) {
    Write-Host "Contraseña MySQL para el usuario '$User':" -ForegroundColor Yellow
    $secure = Read-Host -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $promptedPassword = $true
}

# --- Construcción de argumentos ------------------------------
# La contraseña viaja por la variable de entorno MYSQL_PWD:
# el cliente la lee sin exponerla en la línea de comandos.
if ($promptedPassword) { $env:MYSQL_PWD = $Password }

$mysqlArgs = @("-h", $HostName, "-P", "$Port", "-u", $User)
if ($Database) { $mysqlArgs += $Database }

if ($Sql)    { $mysqlArgs += "-e"; $mysqlArgs += $Sql }

# --- Ejecución ------------------------------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ($File) {
    # El archivo se pasa a mysql mediante redirección del shell (cmd /c < ):
    # los bytes llegan exactamente como están en disco (UTF-8), sin que
    # PowerShell convierta codificaciones en el pipe.
    $tmpFile = Join-Path $env:TEMP "ecommerce_mysql_$PID.sql"
    $utf8WithBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText(
        $tmpFile,
        (Get-Content -LiteralPath $File -Raw -Encoding UTF8),
        $utf8WithBom)
    $cmdLine = "`"$mysql`" $($mysqlArgs -join ' ') --default-character-set=utf8mb4 < `"$tmpFile`""
    cmd /c $cmdLine
    $exitCode = $LASTEXITCODE
    Remove-Item -LiteralPath $tmpFile -Force -ErrorAction SilentlyContinue
}
else {
    & $mysql @mysqlArgs
    $exitCode = $LASTEXITCODE
}

if ($exitCode -ne 0) {
    if ($promptedPassword) { Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue }
    Write-Error "mysql terminó con código $exitCode."
    exit $exitCode
}

if ($promptedPassword) { Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue }