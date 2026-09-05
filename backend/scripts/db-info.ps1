# ============================================================
#  db-info.ps1 - Resumen profesional del estado de la base de
#  datos e-commerce (equivalente a la "oja de esquema" que
#  muestra MySQL Workbench).
#
#  USO:
#    .\scripts\db-info.ps1                    # resumen del servidor + BD ecommerce
#    .\scripts\db-info.ps1 -Database otraBD
#    .\scripts\db-info.ps1 -Full              # incluye columnas e índices por tabla
#
#  Requiere la contraseña vía $env:MYSQL_PWD o la solicita.
# ============================================================

[CmdletBinding()]
param(
    [string]$Database = "ecommerce",
    [switch]$Full
)

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $scriptRoot "mysql.ps1") -Database "" -Sql @"
SELECT 'SERVIDOR' AS seccion, CONCAT('MySQL ', VERSION()) AS valor, '127.0.0.1:3306' AS detalle;
"@

Write-Host "`n===== BASE DE DATOS: $Database =====" -ForegroundColor Cyan
& (Join-Path $scriptRoot "mysql.ps1") -Database "" -Sql @"
SELECT TABLE_NAME AS tabla, TABLE_ROWS AS filas_estimadas, ENGINE AS motor
FROM information_schema.tables
WHERE table_schema = '$Database'
ORDER BY TABLE_NAME;
"@

if ($Full) {
    Write-Host "`n===== COLUMNAS E ÍNDICES =====" -ForegroundColor Cyan
    & (Join-Path $scriptRoot "mysql.ps1") -Database "" -Sql @"
SELECT TABLE_NAME tabla, COLUMN_NAME columna, COLUMN_TYPE tipo,
       IS_NULLABLE nullable, COLUMN_KEY llave
FROM information_schema.columns
WHERE table_schema = '$Database'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
"@
}