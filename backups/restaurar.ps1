# =============================================================
# TecnoMarket - Restauracion de Respaldos (Windows)
# USO:
#   .\restaurar.ps1 -UltimoSemanal
#   .\restaurar.ps1 -UltimoDiario
#   .\restaurar.ps1 -Archivo "semanales\completo_2026-W21_...sql.gz"
#   .\restaurar.ps1 -ListarRespaldos
# =============================================================

param(
    [string]$Archivo         = "",
    [switch]$UltimoSemanal,
    [switch]$UltimoDiario,
    [switch]$ListarRespaldos,
    [switch]$ForzarSinConfirmar
)

. "$PSScriptRoot\_lib.ps1"
Import-BackupConfig

Ensure-Dir "$BACKUP_BASE\logs"
Ensure-Dir "$BACKUP_BASE\emergency"
Set-LogFile "$BACKUP_BASE\logs\restauraciones.log"

# --- Listar respaldos disponibles ----------------------------
function Show-Backups {
    Write-Host "`n=== RESPALDOS DISPONIBLES ===" -ForegroundColor Cyan

    Write-Host "`n-- SEMANALES (completos) --" -ForegroundColor Yellow
    $s = Get-ChildItem "$BACKUP_BASE\semanales" -Filter "*.sql*" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending
    if ($s.Count -eq 0) { Write-Host "  (ninguno)" -ForegroundColor DarkGray }
    else { $i=1; foreach ($f in $s) {
        Write-Host "  [$i] $($f.Name)  ($(Format-FileSize $f.Length))  $($f.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))"
        $i++
    }}

    Write-Host "`n-- DIARIOS (incrementales, ultimos 15) --" -ForegroundColor Yellow
    $d = Get-ChildItem "$BACKUP_BASE\diarios" -Filter "*.sql*" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 15
    if ($d.Count -eq 0) { Write-Host "  (ninguno)" -ForegroundColor DarkGray }
    else { $i=1; foreach ($f in $d) {
        Write-Host "  [$i] $($f.Name)  ($(Format-FileSize $f.Length))  $($f.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))"
        $i++
    }}
    Write-Host ""
}

if ($ListarRespaldos) { Show-Backups; exit 0 }

# --- Seleccionar archivo --------------------------------------
if ($UltimoSemanal) {
    $f = Get-ChildItem "$BACKUP_BASE\semanales" -Filter "*.sql*" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $f) { Write-Host "[ERROR] No hay respaldos semanales." -ForegroundColor Red; exit 1 }
    $Archivo = $f.FullName
} elseif ($UltimoDiario) {
    $f = Get-ChildItem "$BACKUP_BASE\diarios" -Filter "*.sql*" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $f) { Write-Host "[ERROR] No hay respaldos diarios." -ForegroundColor Red; exit 1 }
    $Archivo = $f.FullName
} elseif (-not $Archivo) {
    Write-Host "`nUSO:" -ForegroundColor Cyan
    Write-Host "  .\restaurar.ps1 -UltimoSemanal"
    Write-Host "  .\restaurar.ps1 -UltimoDiario"
    Write-Host "  .\restaurar.ps1 -Archivo 'ruta\archivo.sql.gz'"
    Write-Host "  .\restaurar.ps1 -ListarRespaldos"
    exit 0
}

# Resolver ruta relativa
if (-not [System.IO.Path]::IsPathRooted($Archivo)) {
    $Archivo = Join-Path $BACKUP_BASE $Archivo
}
if (-not (Test-Path $Archivo)) {
    Write-Host "[ERROR] Archivo no encontrado: $Archivo" -ForegroundColor Red; exit 1
}

# --- Confirmacion --------------------------------------------
$item = Get-Item $Archivo
$tipo = if ($Archivo -match 'completo|semanal') { "COMPLETO (sobreescribira toda la BD)" } else { "INCREMENTAL (aplica sobre BD actual)" }

Write-Host "`n============================================" -ForegroundColor Red
Write-Host "  !  RESTAURACION DE BASE DE DATOS  !" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host "  Archivo : $($item.Name)"
Write-Host "  Tamano  : $(Format-FileSize $item.Length)"
Write-Host "  Fecha   : $($item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host "  BD      : $DB_NAME @ $DB_HOST`:$DB_PORT"
Write-Host "  Tipo    : $tipo" -ForegroundColor Yellow
Write-Host ""

if (-not $ForzarSinConfirmar) {
    $c = Read-Host "  Escribe 'SI' para continuar"
    if ($c -ne 'SI') { Write-Host "Cancelado."; exit 0 }
}

Write-Log "========================================"
Write-Log "Iniciando RESTAURACION: $Archivo"
Write-Log "========================================"

# --- Respaldo de emergencia antes de restaurar ---------------
Write-Log "Creando respaldo de emergencia previo ..."
$MYSQLDUMP_BIN = Find-MySQLBinary 'mysqldump'
$MYSQL_BIN     = Find-MySQLBinary 'mysql'

$safety_sql = "$BACKUP_BASE\emergency\pre_restore_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').sql"
$args_safety = @("-h",$DB_HOST,"-P",$DB_PORT,"-u",$DB_USER)
$pass = Get-MySQLPassArg; if ($pass) { $args_safety += $pass }
$args_safety += @("--single-transaction","--skip-lock-tables","--no-tablespaces","--routines","--triggers","--databases",$DB_NAME)

$safety_out = & $MYSQLDUMP_BIN @args_safety 2>&1
if ($LASTEXITCODE -eq 0) {
    Set-Content $safety_sql ($safety_out | Out-String) -Encoding UTF8
    $safety_gz = Compress-SqlFile $safety_sql
    Write-Log "Emergencia guardada: $safety_gz"
} else {
    Write-Log "No se pudo crear respaldo de emergencia - continuando" "WARN"
    $safety_gz = "(no creado)"
}

# --- Descomprimir si es .gz ----------------------------------
$sql_to_import = $Archivo
$temp_sql      = $null
if ($Archivo.EndsWith(".gz")) {
    Write-Log "Descomprimiendo ..."
    $temp_sql = "$env:TEMP\tecnomarket_restore_$(Get-Date -Format 'yyyyMMddHHmmss').sql"
    try {
        Decompress-GzFile -GzPath $Archivo -OutPath $temp_sql
        $sql_to_import = $temp_sql
        Write-Log "Descomprimido: $(Format-FileSize (Get-Item $temp_sql).Length)"
    } catch {
        Write-Log "Error al descomprimir: $_" "ERROR"; exit 1
    }
}

# --- Ejecutar restauracion -----------------------------------
Write-Log "Aplicando respaldo ..."
$args_restore = @("-h",$DB_HOST,"-P",$DB_PORT,"-u",$DB_USER)
if ($pass) { $args_restore += $pass }

# Respaldo completo incluye CREATE DATABASE; incremental necesita la BD destino
if ($Archivo -notmatch 'completo|semanal') { $args_restore += $DB_NAME }

$content = Get-Content $sql_to_import -Raw
$restore_out = $content | & $MYSQL_BIN @args_restore 2>&1

if ($temp_sql) { Remove-Item $temp_sql -Force -ErrorAction SilentlyContinue }

if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR en la restauracion: $restore_out" "ERROR"
    Write-Log "Tus datos previos estan en: $safety_gz" "WARN"
    exit 1
}

Write-Log "Restauracion aplicada correctamente"

# --- Verificacion post-restauracion --------------------------
$check = (Invoke-MySQL @("-N","-e","SELECT CONCAT(COUNT(*),' ventas') FROM ventas;", $DB_NAME) | Out-String).Trim()
Write-Log "Estado BD post-restauracion: $check"

Write-Log "========================================"
Write-Log "RESTAURACION COMPLETADA - OK"
Write-Log "========================================"
Write-Host "`n  ✓ Restauracion completada" -ForegroundColor Green
Write-Host "  Respaldo de emergencia en: $safety_gz" -ForegroundColor Gray
