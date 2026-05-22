# =============================================================
# TecnoMarket - Libreria compartida PowerShell
# Usar con:  . "$PSScriptRoot\_lib.ps1"
# =============================================================

# --- Cargar config.env ---------------------------------------
function Import-BackupConfig {
    $config_file = "$PSScriptRoot\config.env"
    $example     = "$PSScriptRoot\config.env.example"

    if (-not (Test-Path $config_file)) {
        if (Test-Path $example) {
            Copy-Item $example $config_file
            Write-Host "[AVISO] Se creo config.env desde la plantilla." -ForegroundColor Yellow
            Write-Host "        Edita '$config_file' con tus credenciales y vuelve a ejecutar." -ForegroundColor Yellow
            exit 1
        }
        Write-Host "[ERROR] No existe config.env ni config.env.example." -ForegroundColor Red
        exit 1
    }

    $cfg = @{}
    foreach ($line in (Get-Content $config_file -Encoding UTF8)) {
        if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
        if ($line -match '^([^=]+)=(.*)$') {
            $k = $Matches[1].Trim()
            $v = ($Matches[2] -split '#')[0].Trim()   # quitar comentarios inline
            $cfg[$k] = $v
        }
    }

    # Valores con fallback
    $script:DB_HOST              = if ($cfg['DB_HOST'])              { $cfg['DB_HOST'] }              else { 'localhost' }
    $script:DB_PORT              = if ($cfg['DB_PORT'])              { $cfg['DB_PORT'] }              else { '3306' }
    $script:DB_USER              = if ($cfg['DB_USER'])              { $cfg['DB_USER'] }              else { 'root' }
    $script:DB_PASS              = if ($cfg['DB_PASS'])              { $cfg['DB_PASS'] }              else { '' }
    $script:DB_NAME              = if ($cfg['DB_NAME'])              { $cfg['DB_NAME'] }              else { 'tecnomarket_db' }
    $script:RETENTION_DAILY_DAYS = if ($cfg['RETENTION_DAILY_DAYS']) { [int]$cfg['RETENTION_DAILY_DAYS'] } else { 30 }
    $script:RETENTION_WEEKLY_WEEKS = if ($cfg['RETENTION_WEEKLY_WEEKS']) { [int]$cfg['RETENTION_WEEKLY_WEEKS'] } else { 12 }
    $script:NOTIFY_EMAIL         = if ($cfg['NOTIFY_EMAIL'])         { $cfg['NOTIFY_EMAIL'] }         else { '' }

    # Directorio base de respaldos
    $base = if ($cfg['BACKUP_BASE'] -and $cfg['BACKUP_BASE'] -ne '') { $cfg['BACKUP_BASE'] } else { $PSScriptRoot }
    $script:BACKUP_BASE = $base

    # Rutas de binarios (pueden estar vacias → autodeteccion)
    $script:CFG_MYSQLDUMP = if ($cfg['MYSQLDUMP_PATH']) { $cfg['MYSQLDUMP_PATH'] } else { '' }
    $script:CFG_MYSQL     = if ($cfg['MYSQL_PATH'])     { $cfg['MYSQL_PATH'] }     else { '' }
}

# --- Autodeteccion de binarios MySQL en Windows --------------
function Find-MySQLBinary {
    param([string]$Name)   # 'mysqldump' o 'mysql'

    $exe = "$Name.exe"

    # 1. Ruta configurada explicitamente en config.env
    $configured = if ($Name -eq 'mysqldump') { $script:CFG_MYSQLDUMP } else { $script:CFG_MYSQL }
    if ($configured -and (Test-Path $configured)) { return $configured }

    # 2. PATH del sistema
    $inPath = Get-Command $exe -ErrorAction SilentlyContinue
    if ($inPath) { return $inPath.Source }

    # 3. Ubicaciones comunes en Windows (orden de prioridad)
    $candidates = @(
        # XAMPP (varias letras de unidad)
        "C:\xampp\mysql\bin\$exe",
        "D:\xampp\mysql\bin\$exe",
        "E:\xampp\mysql\bin\$exe",
        # WAMP64
        "C:\wamp64\bin\mysql\bin\$exe",
        # WAMP (detectar version dinamica)
        (Get-ChildItem "C:\wamp64\bin\mysql" -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending | Select-Object -First 1 |
            ForEach-Object { "$($_.FullName)\bin\$exe" }),
        # MySQL Installer standalone (multiples versiones)
        (Get-ChildItem "C:\Program Files\MySQL" -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending | Select-Object -First 1 |
            ForEach-Object { "$($_.FullName)\bin\$exe" }),
        "C:\Program Files\MySQL\MySQL Server 8.4\bin\$exe",
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\$exe",
        "C:\Program Files\MySQL\MySQL Server 5.7\bin\$exe",
        # Laragon
        (Get-ChildItem "C:\laragon\bin\mysql" -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending | Select-Object -First 1 |
            ForEach-Object { "$($_.FullName)\bin\$exe" }),
        "C:\laragon\bin\mysql\bin\$exe",
        # Chocolatey / Scoop
        "$env:ProgramData\chocolatey\bin\$exe",
        "$env:USERPROFILE\scoop\shims\$exe",
        # MariaDB
        "C:\Program Files\MariaDB 11.4\bin\$exe",
        "C:\Program Files\MariaDB 10.11\bin\$exe",
        (Get-ChildItem "C:\Program Files\MariaDB*" -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending | Select-Object -First 1 |
            ForEach-Object { "$($_.FullName)\bin\$exe" })
    )

    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) { return $path }
    }

    Write-Host "[ERROR] No se encontro '$exe'." -ForegroundColor Red
    Write-Host "        Instala MySQL/MariaDB o configura MYSQLDUMP_PATH en config.env" -ForegroundColor Yellow
    exit 1
}

# --- Logging -------------------------------------------------
$script:LOG_FILE = ""

function Set-LogFile { param([string]$Path)
    $script:LOG_FILE = $Path
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

function Write-Log {
    param([string]$Mensaje, [string]$Nivel = "INFO")
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Nivel] $Mensaje"
    $color = switch ($Nivel) {
        "ERROR" { "Red" }; "WARN" { "Yellow" }; default { "Gray" }
    }
    Write-Host $line -ForegroundColor $color
    if ($script:LOG_FILE) { Add-Content -Path $script:LOG_FILE -Value $line -Encoding UTF8 }
}

# --- Helpers -------------------------------------------------
function Ensure-Dir { param([string]$Path)
    if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
}

function Get-MySQLPassArg {
    if ($script:DB_PASS -ne '') { return "-p$($script:DB_PASS)" } else { return $null }
}

function Invoke-MySQL {
    param([string[]]$ExtraArgs)
    $mysql = Find-MySQLBinary 'mysql'
    $args  = @("-h", $script:DB_HOST, "-P", $script:DB_PORT, "-u", $script:DB_USER)
    $pass  = Get-MySQLPassArg
    if ($pass) { $args += $pass }
    return & $mysql @($args + $ExtraArgs) 2>&1
}

function Test-MySQLConnection {
    $result = Invoke-MySQL @("-e", "SELECT 1;", $script:DB_NAME) 2>&1
    return ($LASTEXITCODE -eq 0)
}

function Compress-SqlFile {
    param([string]$SqlPath)
    $gzPath = "$SqlPath.gz"
    try {
        $in  = [System.IO.File]::OpenRead($SqlPath)
        $out = [System.IO.File]::Create($gzPath)
        $gz  = [System.IO.Compression.GZipStream]::new($out, [System.IO.Compression.CompressionMode]::Compress)
        $in.CopyTo($gz)
        $gz.Dispose(); $out.Dispose(); $in.Dispose()
        Remove-Item $SqlPath -Force
        return $gzPath
    } catch {
        Write-Log "No se pudo comprimir: $_" "WARN"
        return $SqlPath
    }
}

function Decompress-GzFile {
    param([string]$GzPath, [string]$OutPath)
    $in  = [System.IO.File]::OpenRead($GzPath)
    $out = [System.IO.File]::Create($OutPath)
    $gz  = [System.IO.Compression.GZipStream]::new($in, [System.IO.Compression.CompressionMode]::Decompress)
    $gz.CopyTo($out)
    $gz.Dispose(); $out.Dispose(); $in.Dispose()
}

function Remove-OldBackups {
    param([string]$Dir, [int]$OlderThanDays, [string]$Pattern = "*.sql*")
    if (-not (Test-Path $Dir)) { return }
    $cutoff = (Get-Date).AddDays(-$OlderThanDays)
    $old = Get-ChildItem -Path $Dir -Filter $Pattern |
           Where-Object { $_.LastWriteTime -lt $cutoff }
    foreach ($f in $old) {
        Remove-Item $f.FullName -Force
        Write-Log "  Eliminado antiguo: $($f.Name)"
    }
    if ($old.Count -gt 0) { Write-Log "  $($old.Count) archivo(s) eliminado(s)" }
}

function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1MB) { return "$([math]::Round($Bytes/1MB,2)) MB" }
    elseif ($Bytes -ge 1KB) { return "$([math]::Round($Bytes/1KB,1)) KB" }
    else { return "$Bytes B" }
}

function Get-TimestampColumn {
    # Devuelve la columna de timestamp de una tabla, o cadena vacia si no tiene
    param([string]$Tabla)
    $result = Invoke-MySQL @(
        "-N", "-e",
        "SELECT IFNULL((SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='$($script:DB_NAME)' AND TABLE_NAME='$Tabla' AND COLUMN_NAME IN ('updated_at','created_at','fecha','fecha_venta','fecha_registro') ORDER BY FIELD(COLUMN_NAME,'updated_at','created_at','fecha_venta','fecha','fecha_registro') LIMIT 1),'');",
        "information_schema"
    )
    return ($result | Out-String).Trim()
}
