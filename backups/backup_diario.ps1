# =============================================================
# TecnoMarket - Respaldo Incremental Diario (Windows)
# Ejecutar: Tarea Programada, cada dia a las 02:00
# Configura tus credenciales en backups\config.env
# =============================================================

. "$PSScriptRoot\_lib.ps1"

# --- Inicializacion ------------------------------------------
Import-BackupConfig

$DIR_DIARIOS = "$BACKUP_BASE\diarios"
Ensure-Dir $DIR_DIARIOS
Ensure-Dir "$BACKUP_BASE\logs"
Set-LogFile "$BACKUP_BASE\logs\backup_diario.log"

$FECHA   = Get-Date -Format "yyyy-MM-dd"
$HORA    = Get-Date -Format "HH-mm-ss"
$AYER    = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
$SQL_TMP = "$DIR_DIARIOS\incremental_${FECHA}_${HORA}.sql"

# Tablas a respaldar en modo incremental
$TABLAS = @("ventas", "detalle_venta", "clientes", "productos", "auditoria")

Write-Log "========================================"
Write-Log "Iniciando respaldo INCREMENTAL diario"
Write-Log "BD: $DB_NAME @ $DB_HOST | Ventana: desde $AYER 00:00:00"
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

# --- Cabecera del archivo SQL ---------------------------------
$cabecera = @"
-- ============================================================
-- TecnoMarket - Respaldo INCREMENTAL Diario
-- Generado   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
-- BD         : $DB_NAME @ $DB_HOST
-- Ventana    : desde $AYER 00:00:00
-- ============================================================
SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;

"@
Set-Content -Path $SQL_TMP -Value $cabecera -Encoding UTF8

# --- Argumentos base de mysqldump ----------------------------
$args_base = @(
    "-h", $DB_HOST, "-P", $DB_PORT, "-u", $DB_USER
)
$pass = Get-MySQLPassArg
if ($pass) { $args_base += $pass }
$args_base += @(
    "--single-transaction",
    "--skip-lock-tables",
    "--no-tablespaces",
    "--routines=0",
    "--triggers=0",
    "--add-drop-table=0",
    "--insert-ignore",    # evita duplicados al re-aplicar
    $DB_NAME
)

# --- Exportar cada tabla -------------------------------------
$errores = 0
foreach ($tabla in $TABLAS) {
    Write-Log "  Exportando: $tabla ..."
    $col_ts = Get-TimestampColumn $tabla
    $args_tabla = $args_base + $tabla

    if ($col_ts) {
        $where = "${col_ts} >= '$AYER 00:00:00'"
        $args_tabla += "--where=$where"
        Write-Log "    WHERE $where"
    } else {
        Write-Log "    Sin columna de timestamp - exportando completa" "WARN"
    }

    $output = & $MYSQLDUMP_BIN @args_tabla 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "    ERROR: $output" "ERROR"
        $errores++
    } else {
        Add-Content -Path $SQL_TMP -Value "`n-- Tabla: $tabla`n" -Encoding UTF8
        Add-Content -Path $SQL_TMP -Value ($output | Out-String) -Encoding UTF8
        Write-Log "    OK"
    }
}

Add-Content -Path $SQL_TMP -Value "`nSET FOREIGN_KEY_CHECKS=1;`n-- FIN INCREMENTAL`n" -Encoding UTF8

# --- Comprimir -----------------------------------------------
Write-Log "Comprimiendo ..."
$archivo_final = Compress-SqlFile $SQL_TMP
$size = Format-FileSize (Get-Item $archivo_final).Length
Write-Log "Archivo final: $archivo_final ($size)"

# --- Limpieza de archivos viejos -----------------------------
Write-Log "Limpiando respaldos con mas de $RETENTION_DAILY_DAYS dias ..."
Remove-OldBackups -Dir $DIR_DIARIOS -OlderThanDays $RETENTION_DAILY_DAYS

# --- Resultado -----------------------------------------------
Write-Log "========================================"
if ($errores -eq 0) {
    Write-Log "INCREMENTAL DIARIO COMPLETADO - OK"
    exit 0
} else {
    Write-Log "COMPLETADO CON $errores ERROR(ES) - revisa el log" "WARN"
    exit 1
}
