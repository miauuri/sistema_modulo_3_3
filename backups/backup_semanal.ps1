# =============================================================
# TecnoMarket - Respaldo Completo Semanal (Windows)
# Ejecutar: Tarea Programada, cada Domingo a las 01:00
# Configura tus credenciales en backups\config.env
# =============================================================

. "$PSScriptRoot\_lib.ps1"

# --- Inicializacion ------------------------------------------
Import-BackupConfig

$DIR_SEMANALES = "$BACKUP_BASE\semanales"
Ensure-Dir $DIR_SEMANALES
Ensure-Dir "$BACKUP_BASE\logs"
Set-LogFile "$BACKUP_BASE\logs\backup_semanal.log"

$SEMANA  = Get-Date -UFormat "%Y-W%V"
$FECHA   = Get-Date -Format "yyyy-MM-dd"
$HORA    = Get-Date -Format "HH-mm-ss"
$SQL_TMP = "$DIR_SEMANALES\completo_${SEMANA}_${FECHA}_${HORA}.sql"

Write-Log "========================================"
Write-Log "Iniciando respaldo COMPLETO semanal"
Write-Log "BD: $DB_NAME @ $DB_HOST | Semana: $SEMANA"
Write-Log "========================================"

# --- Verificaciones ------------------------------------------
$MYSQLDUMP_BIN = Find-MySQLBinary 'mysqldump'
$MYSQL_BIN     = Find-MySQLBinary 'mysql'
Write-Log "mysqldump : $MYSQLDUMP_BIN"
Write-Log "mysql     : $MYSQL_BIN"

if (-not (Test-MySQLConnection)) {
    Write-Log "No se puede conectar a MySQL en $DB_HOST`:$DB_PORT" "ERROR"
    exit 1
}
Write-Log "Conexion MySQL: OK"

# --- Estadisticas pre-respaldo -------------------------------
$m_ventas   = (Invoke-MySQL @("-N","-e","SELECT COUNT(*) FROM ventas;", $DB_NAME) | Out-String).Trim()
$m_clientes = (Invoke-MySQL @("-N","-e","SELECT COUNT(*) FROM clientes;", $DB_NAME) | Out-String).Trim()
$m_prods    = (Invoke-MySQL @("-N","-e","SELECT COUNT(*) FROM productos;", $DB_NAME) | Out-String).Trim()
$m_size     = (Invoke-MySQL @("-N","-e","SELECT ROUND(SUM(data_length+index_length)/1024/1024,2) FROM information_schema.TABLES WHERE table_schema='$DB_NAME';","information_schema") | Out-String).Trim()

Write-Log "Estadisticas: $m_ventas ventas | $m_clientes clientes | $m_prods productos | $m_size MB"

# --- Ejecutar mysqldump completo -----------------------------
Write-Log "Ejecutando mysqldump completo ..."
$args_dump = @("-h",$DB_HOST,"-P",$DB_PORT,"-u",$DB_USER)
$pass = Get-MySQLPassArg
if ($pass) { $args_dump += $pass }
$args_dump += @(
    "--single-transaction",
    "--skip-lock-tables",
    "--no-tablespaces",
    "--routines",
    "--triggers",
    "--events",
    "--add-drop-database",
    "--add-drop-table",
    "--create-options",
    "--extended-insert",
    "--complete-insert",
    "--hex-blob",
    "--databases", $DB_NAME
)

$dump_out = & $MYSQLDUMP_BIN @args_dump 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR en mysqldump: $dump_out" "ERROR"
    exit 1
}

# Escribir con cabecera de metadatos
$cabecera = @"
-- ============================================================
-- TecnoMarket - Respaldo COMPLETO Semanal
-- Generado   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- BD         : $DB_NAME @ $DB_HOST
-- Semana ISO : $SEMANA
-- Ventas     : $m_ventas  | Clientes: $m_clientes  | Productos: $m_prods
-- Tamano DB  : $m_size MB
-- ============================================================

"@
Set-Content  -Path $SQL_TMP -Value $cabecera      -Encoding UTF8
Add-Content  -Path $SQL_TMP -Value ($dump_out | Out-String) -Encoding UTF8

$size_raw = (Get-Item $SQL_TMP).Length
Write-Log "SQL generado: $(Format-FileSize $size_raw)"

# --- Comprimir -----------------------------------------------
Write-Log "Comprimiendo ..."
$archivo_final = Compress-SqlFile $SQL_TMP
$size_gz = (Get-Item $archivo_final).Length
$reduccion = [math]::Round((1 - $size_gz / $size_raw) * 100, 1)
Write-Log "Comprimido: $archivo_final ($(Format-FileSize $size_gz) - $reduccion pct reduccion)"

# --- Historial CSV -------------------------------------------
$historial = "$BACKUP_BASE\logs\historial_respaldos.csv"
if (-not (Test-Path $historial)) {
    Set-Content $historial "fecha,semana,archivo,tamano_mb,ventas,clientes,productos" -Encoding UTF8
}
$fname  = Split-Path $archivo_final -Leaf
$sz_mb  = [math]::Round($size_gz / 1MB, 2)
Add-Content $historial "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),$SEMANA,$fname,$sz_mb,$m_ventas,$m_clientes,$m_prods" -Encoding UTF8
Write-Log "Historial actualizado"

# --- Limpieza ------------------------------------------------
$dias_retencion = $RETENTION_WEEKLY_WEEKS * 7
Write-Log "Limpiando respaldos con mas de $RETENTION_WEEKLY_WEEKS semanas ..."
Remove-OldBackups -Dir $DIR_SEMANALES -OlderThanDays $dias_retencion

# --- Resultado -----------------------------------------------
Write-Log "========================================"
Write-Log "SEMANAL COMPLETO - OK | $archivo_final"
Write-Log "========================================"
exit 0
