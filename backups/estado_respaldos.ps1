# =============================================================
# TecnoMarket - Monitor de Estado del Sistema de Respaldos
# =============================================================

. "$PSScriptRoot\_lib.ps1"
Import-BackupConfig

function Get-TaskInfo {
    param([string]$TaskName)
    $t = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if (-not $t) { return $null }
    $info = $t | Get-ScheduledTaskInfo
    return @{
        Estado      = $t.State
        UltimaEjec  = $info.LastRunTime
        Resultado   = $info.LastTaskResult
        ProximaEjec = $info.NextRunTime
    }
}

# Clear-Host
Write-Host ""
Write-Host "+==================================================+" -ForegroundColor Cyan
Write-Host "|   TecnoMarket - Monitor de Respaldos Automaticos |" -ForegroundColor Cyan
Write-Host "+==================================================+" -ForegroundColor Cyan
Write-Host "  Hora: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | BD: $DB_NAME @ $DB_HOST`:$DB_PORT" -ForegroundColor Gray
Write-Host ""

# --- Conexion MySQL ------------------------------------------
Write-Host "  ESTADO DE MYSQL" -ForegroundColor Yellow
Write-Host "  -------------------------------------------------"
try {
    $MYSQL_BIN = Find-MySQLBinary 'mysql'
    if (Test-MySQLConnection) {
        Write-Host "  ✓ Conexion OK  ($MYSQL_BIN)" -ForegroundColor Green
    } else {
        Write-Host "  X Sin conexion  - ¿esta corriendo el servicio MySQL?" -ForegroundColor Red
    }
} catch {
    Write-Host "  X mysql.exe no encontrado  - configura MYSQL_PATH en config.env" -ForegroundColor Red
}
Write-Host ""

# --- Tareas programadas --------------------------------------
Write-Host "  TAREAS PROGRAMADAS" -ForegroundColor Yellow
Write-Host "  -------------------------------------------------"
$tareas_cfg = @(
    @{ Nombre = "TecnoMarket_Backup_Diario";  Label = "Diario   (02:00 todos los dias)" },
    @{ Nombre = "TecnoMarket_Backup_Semanal"; Label = "Semanal  (01:00 cada Domingo)" }
)
foreach ($tc in $tareas_cfg) {
    $t = Get-TaskInfo $tc.Nombre
    Write-Host "  $($tc.Label)" -ForegroundColor White
    if ($t) {
        $resOK = ($t.Resultado -eq 0)
        $resColor = if ($resOK) { "Green" } else { "Red" }
        $resText  = if ($resOK) { "✓ OK" } else { "X Error (codigo $($t.Resultado))" }
        Write-Host "    Estado   : $($t.Estado)"           -ForegroundColor Gray
        Write-Host "    Ultima   : $($t.UltimaEjec.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
        Write-Host "    Resultado: $resText"               -ForegroundColor $resColor
        Write-Host "    Proxima  : $($t.ProximaEjec.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
    } else {
        Write-Host "    X No instalada - ejecuta instalar_tareas.ps1 como Admin" -ForegroundColor Red
    }
    Write-Host ""
}

# --- Ultimo semanal ------------------------------------------
Write-Host "  ULTIMO RESPALDO SEMANAL (Completo)" -ForegroundColor Yellow
Write-Host "  -------------------------------------------------"
$ult_s = Get-ChildItem "$BACKUP_BASE\semanales" -Filter "*.sql*" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($ult_s) {
    $dias = [math]::Round(((Get-Date) - $ult_s.LastWriteTime).TotalDays, 1)
    $col  = if ($dias -le 7) { "Green" } elseif ($dias -le 14) { "Yellow" } else { "Red" }
    Write-Host "  Archivo   : $($ult_s.Name)" -ForegroundColor White
    Write-Host "  Tamano    : $(Format-FileSize $ult_s.Length)" -ForegroundColor Gray
    Write-Host "  Fecha     : $($ult_s.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
    Write-Host "  Antiguedad: $dias dias" -ForegroundColor $col
} else {
    Write-Host "  X Sin respaldos semanales - ejecuta: .\backup_semanal.ps1" -ForegroundColor Red
}
Write-Host ""

# --- Ultimo diario -------------------------------------------
Write-Host "  ULTIMO RESPALDO DIARIO (Incremental)" -ForegroundColor Yellow
Write-Host "  -------------------------------------------------"
$ult_d = Get-ChildItem "$BACKUP_BASE\diarios" -Filter "*.sql*" -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($ult_d) {
    $horas = [math]::Round(((Get-Date) - $ult_d.LastWriteTime).TotalHours, 1)
    $col   = if ($horas -le 25) { "Green" } elseif ($horas -le 50) { "Yellow" } else { "Red" }
    Write-Host "  Archivo   : $($ult_d.Name)" -ForegroundColor White
    Write-Host "  Tamano    : $(Format-FileSize $ult_d.Length)" -ForegroundColor Gray
    Write-Host "  Fecha     : $($ult_d.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
    Write-Host "  Antiguedad: $horas horas" -ForegroundColor $col
} else {
    Write-Host "  X Sin respaldos diarios - ejecuta: .\backup_diario.ps1" -ForegroundColor Red
}
Write-Host ""

# --- Espacio en disco ----------------------------------------
Write-Host "  ESPACIO UTILIZADO" -ForegroundColor Yellow
Write-Host "  -------------------------------------------------"
$total = 0
foreach ($d in @("semanales","diarios","emergency")) {
    $dir = "$BACKUP_BASE\$d"
    if (Test-Path $dir) {
        $bytes = (Get-ChildItem $dir -File -Recurse -ErrorAction SilentlyContinue |
                  Measure-Object Length -Sum).Sum
        $total += $bytes
        Write-Host "  $($d.PadRight(12)): $(Format-FileSize $bytes)" -ForegroundColor Gray
    } else {
        Write-Host "  $($d.PadRight(12)): (aun no creado)" -ForegroundColor DarkGray
    }
}
Write-Host "  $('TOTAL'.PadRight(12)): $(Format-FileSize $total)" -ForegroundColor White

# Espacio libre del disco donde estan los respaldos
$drive = Split-Path $BACKUP_BASE -Qualifier
$disk  = Get-PSDrive ($drive.TrimEnd(':')) -ErrorAction SilentlyContinue
if ($disk) {
    Write-Host "  $('Libre'.PadRight(12)): $(Format-FileSize $disk.Free)" -ForegroundColor Gray
}
Write-Host ""

# --- Historial reciente --------------------------------------
$historial = "$BACKUP_BASE\logs\historial_respaldos.csv"
if (Test-Path $historial) {
    Write-Host "  HISTORIAL SEMANALES (ultimos 5)" -ForegroundColor Yellow
    Write-Host "  -------------------------------------------------"
    $rows = Import-Csv $historial | Sort-Object fecha -Descending | Select-Object -First 5
    foreach ($r in $rows) {
        Write-Host "  $($r.fecha)  Sem:$($r.semana)  $($r.tamano_mb) MB  V:$($r.ventas) C:$($r.clientes) P:$($r.productos)" -ForegroundColor Gray
    }
    Write-Host ""
}

# --- Comandos rapidos ----------------------------------------
Write-Host "  COMANDOS RAPIDOS" -ForegroundColor Yellow
Write-Host "  -------------------------------------------------"
@(
    ".\backup_diario.ps1                     Ejecutar incremental ahora",
    ".\backup_semanal.ps1                    Ejecutar completo ahora",
    ".\restaurar.ps1 -UltimoSemanal          Restaurar ultimo completo",
    ".\restaurar.ps1 -ListarRespaldos        Ver todos los respaldos",
    ".\instalar_tareas.ps1                   (Re)instalar tareas programadas"
) | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
Write-Host ""
Write-Host "+==================================================+" -ForegroundColor Cyan
Write-Host ""
