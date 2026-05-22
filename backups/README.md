# TecnoMarket — Sistema de Respaldos Automáticos (Windows)

Sistema de respaldos para la base de datos MySQL de TecnoMarket, compatible con cualquier entorno Windows (XAMPP, WAMP, MySQL standalone, Laragon, MariaDB, etc.).

## Archivos del sistema

```
backups/
├── config.env.example      ← Plantilla de configuración (copiar a config.env)
├── config.env              ← Tu configuración local (en .gitignore, no se sube)
├── _lib.ps1                ← Librería compartida (auto-detección, logging, helpers)
│
├── backup_diario.ps1       ← Respaldo incremental diario
├── backup_semanal.ps1      ← Respaldo completo semanal
├── restaurar.ps1           ← Restauración segura
├── estado_respaldos.ps1    ← Monitor de estado en consola
├── instalar_tareas.ps1     ← Instala/desinstala tareas en el Programador de Windows
│
├── diarios/                (auto) Incrementales comprimidos .sql.gz
├── semanales/              (auto) Completos comprimidos .sql.gz
├── emergency/              (auto) Respaldo de seguridad antes de cada restauración
└── logs/
    ├── backup_diario.log
    ├── backup_semanal.log
    ├── restauraciones.log
    └── historial_respaldos.csv
```

---

## Estrategia

| Tipo | Cuándo | Horario | Retención | Contenido |
|------|--------|---------|-----------|-----------|
| **Incremental** | Diario | 02:00 | 30 días | Filas modificadas/nuevas desde ayer |
| **Completo** | Semanal | Dom 01:00 | 12 semanas | Toda la BD: esquema + datos + rutinas + triggers |

---

## Configuración inicial (una sola vez)

### Paso 1 — Crear tu `config.env`

```powershell
cd C:\ruta\a\tecnomarket\backups

# Copiar la plantilla
Copy-Item config.env.example config.env

# Editar con tus credenciales
notepad config.env
```

**Parámetros importantes en `config.env`:**

```ini
DB_HOST=localhost          # Servidor MySQL
DB_PORT=3306               # Puerto (3306 por defecto)
DB_USER=root               # Usuario MySQL
DB_PASS=                   # Contraseña (vacía en XAMPP local)
DB_NAME=tecnomarket_db     # Nombre de la base de datos

# Retención
RETENTION_DAILY_DAYS=30
RETENTION_WEEKLY_WEEKS=12

# Rutas de binarios (dejar vacío para autodetección automática)
# Solo necesario si MySQL no está en el PATH ni en rutas estándar
MYSQLDUMP_PATH=
MYSQL_PATH=

# Directorio base de respaldos (vacío = misma carpeta que los scripts)
BACKUP_BASE=
```

> **`config.env` está en `.gitignore`** — tus credenciales nunca se subirán al repositorio.

### Paso 2 — Habilitar scripts PowerShell (solo la primera vez)

```powershell
# Abrir PowerShell como Administrador
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### Paso 3 — Instalar las tareas programadas

```powershell
# Abrir PowerShell como Administrador en la carpeta backups\
.\instalar_tareas.ps1
```

Registra dos tareas en el Programador de Tareas de Windows:
- **`TecnoMarket_Backup_Diario`** — todos los días a las 02:00
- **`TecnoMarket_Backup_Semanal`** — cada Domingo a las 01:00

Las tareas corren bajo `SYSTEM`, funcionan aunque no haya usuario conectado.

### Paso 4 — Probar que funciona

```powershell
.\backup_semanal.ps1      # Ejecutar un respaldo completo ahora
.\estado_respaldos.ps1    # Ver el estado del sistema
```

---

## Autodetección de MySQL

El sistema detecta automáticamente `mysqldump.exe` y `mysql.exe` en este orden:

1. Ruta configurada en `config.env` (`MYSQLDUMP_PATH` / `MYSQL_PATH`)
2. Variable de entorno `PATH` del sistema
3. **XAMPP** — `C:\xampp\mysql\bin\`
4. **WAMP64** — `C:\wamp64\bin\mysql\*\bin\`
5. **MySQL Installer** — `C:\Program Files\MySQL\MySQL Server *\bin\`
6. **Laragon** — `C:\laragon\bin\mysql\*\bin\`
7. **MariaDB** — `C:\Program Files\MariaDB *\bin\`
8. **Chocolatey** — `C:\ProgramData\chocolatey\bin\`
9. **Scoop** — `%USERPROFILE%\scoop\shims\`

Si ninguna ruta funciona, el script indica exactamente qué configurar en `config.env`.

---

## Uso diario

```powershell
# Ver estado general (conexión, tareas, últimos respaldos, espacio)
.\estado_respaldos.ps1

# Ejecutar respaldo manual
.\backup_diario.ps1
.\backup_semanal.ps1

# Ver todos los respaldos disponibles
.\restaurar.ps1 -ListarRespaldos
```

---

## Restauración

> ⚠️ El script crea un **respaldo de emergencia automático** en `emergency\` antes de cualquier restauración.

```powershell
# Restaurar el último respaldo completo (semanal)
.\restaurar.ps1 -UltimoSemanal

# Restaurar el último incremental (diario)
.\restaurar.ps1 -UltimoDiario

# Restaurar un archivo específico
.\restaurar.ps1 -Archivo "semanales\completo_2026-W21_2026-05-24_01-00-00.sql.gz"

# Sin confirmación interactiva (para scripts automatizados)
.\restaurar.ps1 -UltimoSemanal -ForzarSinConfirmar
```

### Restauración ante desastre total

```powershell
# 1. Restaurar el último completo (base limpia)
.\restaurar.ps1 -UltimoSemanal

# 2. Aplicar los incrementales en orden (del más antiguo al más reciente)
.\restaurar.ps1 -Archivo "diarios\incremental_2026-05-20_02-00-00.sql.gz"
.\restaurar.ps1 -Archivo "diarios\incremental_2026-05-21_02-00-00.sql.gz"
```

---

## Desinstalar

```powershell
.\instalar_tareas.ps1 -Desinstalar
```

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---------|---------------|----------|
| "Script no puede ejecutarse" | ExecutionPolicy bloqueada | `Set-ExecutionPolicy RemoteSigned` como Admin |
| "mysqldump no encontrado" | Binario fuera del PATH | Configurar `MYSQLDUMP_PATH` en `config.env` |
| "Error de conexión" | MySQL no iniciado | Iniciar el servicio MySQL / XAMPP |
| "Acceso denegado" al instalar | Sin permisos Admin | Ejecutar PowerShell como Administrador |
| Tarea no se ejecuta | PC estaba apagada | Las tareas tienen `StartWhenAvailable`, se ejecutan al encender |
| Respaldo muy pequeño | Sin cambios incrementales | Normal — si no hubo actividad, el incremental exporta poco |
