# =============================================================
# TecnoMarket - Instalador de Tareas Programadas (Windows)
# Ejecutar UNA VEZ como Administrador.
# Las credenciales se leen de config.env - no se hardcodean aqui.
# =============================================================

param([switch]$Desinstalar)

$SCRIPT_DIR    = $PSScriptRoot
$TAREA_DIARIA  = "TecnoMarket_Backup_Diario"
$TAREA_SEMANAL = "TecnoMarket_Backup_Semanal"
$PS_EXE        = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

# --- Verificar Admin -----------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] Requiere permisos de Administrador." -ForegroundColor Red
    Write-Host "        Clic derecho en PowerShell → 'Ejecutar como administrador'" -ForegroundColor Yellow
    exit 1
}

# --- Verificar que config.env existe -------------------------
if (-not (Test-Path "$SCRIPT_DIR\config.env")) {
    if (Test-Path "$SCRIPT_DIR\config.env.example") {
        Write-Host "[AVISO] No existe config.env. Copiando plantilla ..." -ForegroundColor Yellow
        Copy-Item "$SCRIPT_DIR\config.env.example" "$SCRIPT_DIR\config.env"
        Write-Host "        Edita '$SCRIPT_DIR\config.env' antes de continuar." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "[ERROR] Falta config.env y config.env.example." -ForegroundColor Red
    exit 1
}

# --- Desinstalacion ------------------------------------------
if ($Desinstalar) {
    Write-Host "Desinstalando tareas de TecnoMarket ..." -ForegroundColor Yellow
    foreach ($t in @($TAREA_DIARIA, $TAREA_SEMANAL)) {
        if (Get-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $t -Confirm:$false
            Write-Host "  ✓ Eliminada: $t" -ForegroundColor Green
        } else {
            Write-Host "  - No instalada: $t" -ForegroundColor Gray
        }
    }
    exit 0
}

# --- Verificar scripts ---------------------------------------
foreach ($s in @("backup_diario.ps1","backup_semanal.ps1","_lib.ps1")) {
    if (-not (Test-Path "$SCRIPT_DIR\$s")) {
        Write-Host "[ERROR] Falta el archivo: $s" -ForegroundColor Red; exit 1
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  TecnoMarket - Instalador de Respaldos    " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ps_args_base = "-NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File"

# --- Tarea diaria (02:00) -------------------------------------
Write-Host "[1/2] Registrando tarea DIARIA ..." -ForegroundColor Yellow
if (Get-ScheduledTask -TaskName $TAREA_DIARIA -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TAREA_DIARIA -Confirm:$false
}
$accion  = New-ScheduledTaskAction -Execute $PS_EXE `
               -Argument "$ps_args_base `"$SCRIPT_DIR\backup_diario.ps1`"" `
               -WorkingDirectory $SCRIPT_DIR
$trigger = New-ScheduledTaskTrigger -Daily -At "02:00"
$config  = New-ScheduledTaskSettingsSet `
               -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
               -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 10) `
               -StartWhenAvailable -MultipleInstances IgnoreNew
$princ   = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $TAREA_DIARIA -Action $accion -Trigger $trigger `
    -Settings $config -Principal $princ `
    -Description "TecnoMarket: Respaldo incremental diario MySQL (02:00)" -Force | Out-Null
Write-Host "  ✓ '$TAREA_DIARIA' - 02:00 todos los dias" -ForegroundColor Green

# --- Tarea semanal (Domingo 01:00) --------------------------
Write-Host "[2/2] Registrando tarea SEMANAL ..." -ForegroundColor Yellow
if (Get-ScheduledTask -TaskName $TAREA_SEMANAL -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TAREA_SEMANAL -Confirm:$false
}
$accion2  = New-ScheduledTaskAction -Execute $PS_EXE `
                -Argument "$ps_args_base `"$SCRIPT_DIR\backup_semanal.ps1`"" `
                -WorkingDirectory $SCRIPT_DIR
$trigger2 = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "01:00"
$config2  = New-ScheduledTaskSettingsSet `
                -ExecutionTimeLimit (New-TimeSpan -Hours 2) `
                -RestartCount 2 -RestartInterval (New-TimeSpan -Minutes 15) `
                -StartWhenAvailable -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $TAREA_SEMANAL -Action $accion2 -Trigger $trigger2 `
    -Settings $config2 -Principal $princ `
    -Description "TecnoMarket: Respaldo completo semanal MySQL (01:00 Domingo)" -Force | Out-Null
Write-Host "  ✓ '$TAREA_SEMANAL' - 01:00 cada Domingo" -ForegroundColor Green

# --- Verificacion final --------------------------------------
Write-Host ""
Write-Host "  Proximas ejecuciones:" -ForegroundColor Cyan
foreach ($tn in @($TAREA_DIARIA, $TAREA_SEMANAL)) {
    $info = Get-ScheduledTask -TaskName $tn | Get-ScheduledTaskInfo
    Write-Host "  [$tn]  →  $($info.NextRunTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Instalacion completada                    " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Respaldos en  : $SCRIPT_DIR\{diarios,semanales,emergency}\"
Write-Host "  Logs en       : $SCRIPT_DIR\logs\"
Write-Host "  Configuracion : $SCRIPT_DIR\config.env"
Write-Host ""
Write-Host "  Para probar ahora:"                   -ForegroundColor White
Write-Host "    .\backup_semanal.ps1"              -ForegroundColor Yellow
Write-Host "    .\estado_respaldos.ps1"            -ForegroundColor Yellow
Write-Host "  Para desinstalar:"                    -ForegroundColor White
Write-Host "    .\instalar_tareas.ps1 -Desinstalar" -ForegroundColor Yellow
Write-Host ""
