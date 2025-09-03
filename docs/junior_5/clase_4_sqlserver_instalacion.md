# Clase 4: SQL Server: Instalación y Configuración

## Objetivos de la Clase
- Instalar SQL Server en diferentes sistemas operativos
- Configurar SQL Server para desarrollo y producción
- Conocer las herramientas de administración
- Entender la arquitectura de SQL Server
- Configurar usuarios, roles y permisos

## Introducción a SQL Server

**SQL Server** es un sistema de gestión de bases de datos relacional desarrollado por Microsoft, conocido por su integración con el ecosistema Microsoft y sus capacidades empresariales.

### Características principales:
- **Integración Microsoft**: Excelente integración con Windows y .NET
- **Business Intelligence**: Herramientas avanzadas de BI
- **Alta Disponibilidad**: Always On, Clustering, Mirroring
- **Seguridad**: Autenticación integrada con Active Directory
- **Escalabilidad**: Desde Express hasta Enterprise

## Instalación en Windows

### Método 1: SQL Server Installer (Recomendado)

1. **Descargar SQL Server**
   - Ir a [microsoft.com/sql-server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
   - Descargar "SQL Server 2022 Developer Edition" (gratuito)

2. **Ejecutar el instalador**
   ```bash
   # Seleccionar tipo de instalación:
   # - Basic: Instalación básica
   # - Custom: Instalación personalizada
   # - Download Media: Descargar medios
   ```

3. **Configuración inicial**
   ```sql
   -- Configurar instancia (default: MSSQLSERVER)
   -- Configurar autenticación (Windows + SQL Server)
   -- Configurar contraseña SA
   -- Configurar puerto (default: 1433)
   ```

### Método 2: Chocolatey
```powershell
# Instalar SQL Server Express
choco install sql-server-express

# Instalar SQL Server Management Studio
choco install sql-server-management-studio
```

## Instalación en Linux

### Ubuntu/Debian
```bash
# Importar clave pública
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Registrar repositorio
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list)"

# Instalar SQL Server
sudo apt-get update
sudo apt-get install -y mssql-server

# Configurar SQL Server
sudo /opt/mssql/bin/mssql-conf setup
```

### CentOS/RHEL
```bash
# Descargar repositorio
sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/8/mssql-server-2022.repo

# Instalar SQL Server
sudo yum install -y mssql-server

# Configurar SQL Server
sudo /opt/mssql/bin/mssql-conf setup
```

## Instalación en Docker

### SQL Server en Docker
```bash
# Ejecutar SQL Server en Docker
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Passw0rd" \
   -p 1433:1433 --name sql1 --hostname sql1 \
   -d mcr.microsoft.com/mssql/server:2022-latest

# Conectar desde otro contenedor
docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P "YourStrong@Passw0rd"
```

## Configuración Inicial

### 1. Conectar por primera vez
```bash
# Usando sqlcmd
sqlcmd -S localhost -U SA -P "YourStrong@Passw0rd"

# Usando SQL Server Management Studio
# Servidor: localhost
# Autenticación: SQL Server Authentication
# Login: SA
# Password: [contraseña configurada]
```

### 2. Configuración básica
```sql
-- Cambiar contraseña SA
ALTER LOGIN SA WITH PASSWORD = 'NuevaContraseña123!';

-- Crear usuario administrativo
CREATE LOGIN admin WITH PASSWORD = 'AdminPass123!';
ALTER SERVER ROLE sysadmin ADD MEMBER admin;

-- Crear usuario para desarrollo
CREATE LOGIN developer WITH PASSWORD = 'DevPass123!';
CREATE USER developer FOR LOGIN developer;
ALTER ROLE db_owner ADD MEMBER developer;

-- Crear base de datos de ejemplo
CREATE DATABASE ejercicios_sqlserver;
USE ejercicios_sqlserver;
```

## Arquitectura de SQL Server

### Componentes principales:
- **SQL Server Database Engine**: Motor principal de base de datos
- **SQL Server Agent**: Servicio de automatización
- **SQL Server Browser**: Servicio de resolución de nombres
- **SQL Server Reporting Services**: Servicio de reportes
- **SQL Server Analysis Services**: Servicio de análisis

### Estructura de archivos:
```
C:\Program Files\Microsoft SQL Server\     # Archivos del programa
C:\Program Files (x86)\Microsoft SQL Server\  # Herramientas de 32-bit
C:\ProgramData\Microsoft\Microsoft SQL Server\ # Datos del programa
C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\  # Archivos de datos
```

## Configuración Avanzada

### Configuración del servidor
```sql
-- Ver configuración actual
EXEC sp_configure;

-- Configurar memoria máxima
EXEC sp_configure 'max server memory (MB)', 2048;
RECONFIGURE;

-- Configurar conexiones máximas
EXEC sp_configure 'user connections', 100;
RECONFIGURE;

-- Configurar timeout de consultas
EXEC sp_configure 'remote query timeout (s)', 600;
RECONFIGURE;
```

### Configuración de base de datos
```sql
-- Configurar base de datos
USE ejercicios_sqlserver;

-- Configurar tamaño inicial
ALTER DATABASE ejercicios_sqlserver 
MODIFY FILE (NAME = 'ejercicios_sqlserver', SIZE = 100MB);

-- Configurar crecimiento automático
ALTER DATABASE ejercicios_sqlserver 
MODIFY FILE (NAME = 'ejercicios_sqlserver', 
             FILEGROWTH = 10MB, 
             MAXSIZE = 1GB);
```

## Herramientas de Administración

### 1. SQL Server Management Studio (SSMS)
- **Descripción**: Herramienta gráfica oficial de Microsoft
- **Características**: Administración completa, desarrollo, monitoreo
- **Descarga**: [docs.microsoft.com/ssms](https://docs.microsoft.com/en-us/sql/ssms/)

### 2. Azure Data Studio
- **Descripción**: Herramienta multiplataforma moderna
- **Características**: Desarrollo, administración, visualización
- **Descarga**: [docs.microsoft.com/azure-data-studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/)

### 3. sqlcmd (Command Line)
```bash
# Conectar a SQL Server
sqlcmd -S servidor -U usuario -P contraseña -d base_datos

# Ejecutar script
sqlcmd -S localhost -U SA -P "Password123!" -i script.sql

# Opciones útiles
sqlcmd -S localhost -U SA -P "Password123!" -Q "SELECT @@VERSION" -W
```

## Comandos de Administración

### Gestión de servicios
```bash
# Windows (Services)
net start MSSQLSERVER
net stop MSSQLSERVER
net pause MSSQLSERVER
net continue MSSQLSERVER

# PowerShell
Start-Service MSSQLSERVER
Stop-Service MSSQLSERVER
Restart-Service MSSQLSERVER
```

### Comandos SQL Server útiles
```sql
-- Ver información del servidor
SELECT @@VERSION;
SELECT SERVERPROPERTY('ProductVersion');
SELECT SERVERPROPERTY('ProductLevel');

-- Ver bases de datos
SELECT name FROM sys.databases;

-- Ver usuarios/roles
SELECT name FROM sys.server_principals WHERE type = 'S';

-- Ver procesos activos
SELECT * FROM sys.dm_exec_sessions;
SELECT * FROM sys.dm_exec_requests;
```

## Ejercicios Prácticos

### Ejercicio 1: Instalación y Verificación
```sql
-- Verificar instalación
SELECT 
    'SQL Server Version' as info,
    @@VERSION as valor
UNION ALL
SELECT 
    'Server Name',
    @@SERVERNAME
UNION ALL
SELECT 
    'Instance Name',
    SERVERPROPERTY('InstanceName')
UNION ALL
SELECT 
    'Service Pack',
    SERVERPROPERTY('ProductLevel');
```

### Ejercicio 2: Configuración de Usuarios y Roles
```sql
-- Crear base de datos para ejercicios
CREATE DATABASE ejercicios_sqlserver;
USE ejercicios_sqlserver;

-- Crear tabla de usuarios del sistema
CREATE TABLE usuarios_sistema (
    id INT IDENTITY(1,1) PRIMARY KEY,
    login_name NVARCHAR(50) NOT NULL,
    is_disabled BIT,
    is_policy_checked BIT,
    is_expiration_checked BIT,
    fecha_creacion DATETIME2 DEFAULT GETDATE()
);

-- Insertar usuarios actuales
INSERT INTO usuarios_sistema (login_name, is_disabled, is_policy_checked, is_expiration_checked)
SELECT 
    name,
    is_disabled,
    is_policy_checked,
    is_expiration_checked
FROM sys.server_principals 
WHERE type = 'S' AND name NOT LIKE '##%';
```

### Ejercicio 3: Análisis de Configuración
```sql
-- Crear tabla de configuración
CREATE TABLE configuracion_sqlserver (
    id INT IDENTITY(1,1) PRIMARY KEY,
    parametro NVARCHAR(100) NOT NULL,
    valor NVARCHAR(MAX),
    categoria NVARCHAR(50),
    descripcion NVARCHAR(MAX)
);

-- Insertar parámetros importantes
INSERT INTO configuracion_sqlserver (parametro, valor, categoria, descripcion) VALUES
('version', @@VERSION, 'Sistema', 'Versión de SQL Server'),
('server_name', @@SERVERNAME, 'Sistema', 'Nombre del servidor'),
('max_connections', CAST(@@MAX_CONNECTIONS AS NVARCHAR(10)), 'Conexiones', 'Máximo de conexiones'),
('max_memory', (SELECT CAST(value AS NVARCHAR(10)) FROM sys.configurations WHERE name = 'max server memory (MB)'), 'Memoria', 'Memoria máxima del servidor');
```

### Ejercicio 4: Monitoreo de Conexiones
```sql
-- Crear tabla de monitoreo
CREATE TABLE monitoreo_conexiones (
    id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT,
    login_name NVARCHAR(50),
    host_name NVARCHAR(50),
    program_name NVARCHAR(100),
    status NVARCHAR(30),
    cpu_time INT,
    memory_usage INT,
    fecha_registro DATETIME2 DEFAULT GETDATE()
);

-- Procedimiento para registrar conexiones
CREATE PROCEDURE registrar_conexiones
AS
BEGIN
    INSERT INTO monitoreo_conexiones (session_id, login_name, host_name, program_name, status, cpu_time, memory_usage)
    SELECT 
        session_id,
        login_name,
        host_name,
        program_name,
        status,
        cpu_time,
        memory_usage
    FROM sys.dm_exec_sessions
    WHERE is_user_process = 1;
END;
```

### Ejercicio 5: Análisis de Rendimiento
```sql
-- Crear tabla de métricas
CREATE TABLE metricas_rendimiento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    metrica NVARCHAR(100) NOT NULL,
    valor BIGINT,
    fecha_registro DATETIME2 DEFAULT GETDATE()
);

-- Insertar métricas básicas
INSERT INTO metricas_rendimiento (metrica, valor) VALUES
('total_connections', (SELECT COUNT(*) FROM sys.dm_exec_sessions)),
('active_connections', (SELECT COUNT(*) FROM sys.dm_exec_sessions WHERE status = 'running')),
('database_size_mb', (SELECT SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS BIGINT) * 8.0 / 1024) FROM sys.database_files));
```

### Ejercicio 6: Configuración de Logs
```sql
-- Verificar configuración de logs
SELECT 
    'Error Log Path' as configuracion,
    SERVERPROPERTY('ErrorLogFileName') as valor,
    'Ubicación del log de errores' as descripcion
UNION ALL
SELECT 
    'Default Log Path',
    SERVERPROPERTY('DefaultLogPath'),
    'Directorio por defecto de logs'
UNION ALL
SELECT 
    'Default Data Path',
    SERVERPROPERTY('DefaultDataPath'),
    'Directorio por defecto de datos';
```

### Ejercicio 7: Análisis de Bases de Datos
```sql
-- Crear vista de análisis de bases de datos
CREATE VIEW analisis_bases_datos AS
SELECT 
    d.name as nombre_bd,
    d.database_id,
    d.collation_name,
    d.compatibility_level,
    (SELECT COUNT(*) FROM sys.tables WHERE type = 'U') as cantidad_tablas,
    CAST(SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS BIGINT) * 8.0 / 1024) AS DECIMAL(10,2)) as tamaño_mb
FROM sys.databases d
LEFT JOIN sys.database_files df ON d.database_id = DB_ID()
WHERE d.name NOT IN ('master', 'tempdb', 'model', 'msdb')
GROUP BY d.name, d.database_id, d.collation_name, d.compatibility_level;

-- Consultar la vista
SELECT * FROM analisis_bases_datos;
```

### Ejercicio 8: Configuración de Seguridad
```sql
-- Crear tabla de auditoría de seguridad
CREATE TABLE auditoria_seguridad (
    id INT IDENTITY(1,1) PRIMARY KEY,
    evento NVARCHAR(100) NOT NULL,
    usuario NVARCHAR(50),
    detalles NVARCHAR(MAX),
    fecha_evento DATETIME2 DEFAULT GETDATE()
);

-- Trigger para auditoría
CREATE TRIGGER tr_audit_usuarios
ON usuarios_sistema
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO auditoria_seguridad (evento, usuario, detalles)
    SELECT 
        'Cambio de Usuario',
        ISNULL(i.login_name, d.login_name),
        'Usuario modificado en el sistema'
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id = d.id;
END;
```

### Ejercicio 9: Optimización de Configuración
```sql
-- Crear tabla de recomendaciones
CREATE TABLE recomendaciones_configuracion (
    id INT IDENTITY(1,1) PRIMARY KEY,
    categoria NVARCHAR(50) NOT NULL,
    parametro NVARCHAR(100) NOT NULL,
    valor_actual NVARCHAR(100),
    valor_recomendado NVARCHAR(100),
    razon NVARCHAR(MAX),
    prioridad NVARCHAR(20) DEFAULT 'Media'
);

-- Insertar recomendaciones básicas
INSERT INTO recomendaciones_configuracion (categoria, parametro, valor_actual, valor_recomendado, razon, prioridad) VALUES
('Memoria', 'max server memory', (SELECT CAST(value AS NVARCHAR(10)) FROM sys.configurations WHERE name = 'max server memory (MB)'), '80% de RAM', 'Mejora rendimiento general', 'Alta'),
('Conexiones', 'user connections', (SELECT CAST(value AS NVARCHAR(10)) FROM sys.configurations WHERE name = 'user connections'), '0 (ilimitado)', 'Para aplicaciones web', 'Media'),
('Logs', 'recovery model', (SELECT recovery_model_desc FROM sys.databases WHERE name = DB_NAME()), 'SIMPLE', 'Para desarrollo', 'Alta');
```

### Ejercicio 10: Reporte Completo del Sistema
```sql
-- Crear procedimiento para reporte completo
CREATE PROCEDURE generar_reporte_sistema
AS
BEGIN
    SELECT '=== REPORTE DEL SISTEMA SQL SERVER ===' as titulo;
    
    SELECT 'Información General' as seccion;
    SELECT 
        'Versión' as parametro,
        @@VERSION as valor
    UNION ALL
    SELECT 
        'Nombre del Servidor',
        @@SERVERNAME
    UNION ALL
    SELECT 
        'Instancia',
        SERVERPROPERTY('InstanceName');
    
    SELECT 'Configuración de Memoria' as seccion;
    SELECT 
        'Memoria Máxima (MB)' as parametro,
        CAST(value AS NVARCHAR(20)) as valor
    FROM sys.configurations 
    WHERE name = 'max server memory (MB)'
    UNION ALL
    SELECT 
        'Memoria Mínima (MB)',
        CAST(value AS NVARCHAR(20))
    FROM sys.configurations 
    WHERE name = 'min server memory (MB)';
    
    SELECT 'Estadísticas de Uso' as seccion;
    SELECT 
        'Conexiones Activas' as parametro,
        CAST(COUNT(*) AS NVARCHAR(20)) as valor
    FROM sys.dm_exec_sessions
    WHERE is_user_process = 1;
END;

-- Ejecutar reporte
EXEC generar_reporte_sistema;
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Cómo instalar SQL Server en diferentes sistemas operativos
- Configuración inicial y creación de usuarios/roles
- Arquitectura y estructura de SQL Server
- Herramientas de administración disponibles
- Comandos básicos de administración
- Configuración avanzada del servidor

## Próxima Clase
[Clase 5: Oracle Database: Instalación y Configuración](clase_5_oracle_instalacion.md)

## Recursos Adicionales
- [SQL Server Installation Guide](https://docs.microsoft.com/en-us/sql/database-engine/install-windows/)
- [SQL Server Configuration](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/)
- [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/)
