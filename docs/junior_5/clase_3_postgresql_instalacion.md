# Clase 3: PostgreSQL: Instalación y Configuración

## Objetivos de la Clase
- Instalar PostgreSQL en diferentes sistemas operativos
- Configurar PostgreSQL para desarrollo y producción
- Conocer las herramientas de administración
- Entender la arquitectura de PostgreSQL
- Configurar usuarios, roles y permisos

## Introducción a PostgreSQL

**PostgreSQL** es un sistema de gestión de bases de datos relacional de código abierto, conocido por su robustez, extensibilidad y cumplimiento de estándares SQL.

### Características principales:
- **Open Source**: Licencia PostgreSQL (BSD-like)
- **Estándares SQL**: Excelente cumplimiento de SQL estándar
- **Extensible**: Múltiples tipos de datos y funciones
- **ACID**: Transacciones completamente ACID
- **Concurrencia**: Control de concurrencia multiversión (MVCC)

## Instalación en Windows

### Método 1: PostgreSQL Installer (Recomendado)

1. **Descargar PostgreSQL Installer**
   - Ir a [postgresql.org/download/windows](https://www.postgresql.org/download/windows/)
   - Descargar "PostgreSQL Installer"

2. **Ejecutar el instalador**
   ```bash
   # Seleccionar componentes:
   # - PostgreSQL Server
   # - pgAdmin 4 (herramienta gráfica)
   # - Stack Builder (herramientas adicionales)
   ```

3. **Configuración inicial**
   ```sql
   -- Configurar contraseña para usuario postgres
   -- Configurar puerto (default: 5432)
   -- Configurar locale
   ```

### Método 2: Chocolatey
```powershell
# Instalar PostgreSQL
choco install postgresql

# Instalar pgAdmin
choco install pgadmin4
```

## Instalación en Linux (Ubuntu/Debian)

### Método 1: APT (Recomendado)
```bash
# Actualizar repositorios
sudo apt update

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib

# Instalar herramientas adicionales
sudo apt install postgresql-client pgadmin4

# Iniciar servicio
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Método 2: Repositorio oficial
```bash
# Agregar repositorio oficial
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Actualizar e instalar
sudo apt update
sudo apt install postgresql-15 postgresql-client-15
```

## Instalación en macOS

### Método 1: Homebrew (Recomendado)
```bash
# Instalar PostgreSQL
brew install postgresql@15

# Iniciar servicio
brew services start postgresql@15

# Crear base de datos inicial
createdb
```

### Método 2: Postgres.app
```bash
# Descargar desde postgresapp.com
# Aplicación que incluye PostgreSQL y herramientas
# Fácil de usar para desarrollo local
```

## Configuración Inicial

### 1. Conectar por primera vez
```bash
# Cambiar a usuario postgres
sudo -u postgres psql

# O conectar directamente
psql -U postgres -h localhost
```

### 2. Configuración básica
```sql
-- Cambiar contraseña del usuario postgres
ALTER USER postgres PASSWORD 'nueva_contraseña';

-- Crear usuario administrativo
CREATE USER admin WITH SUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD 'contraseña_admin';

-- Crear usuario para desarrollo
CREATE USER developer WITH CREATEDB LOGIN PASSWORD 'contraseña_dev';

-- Crear base de datos de ejemplo
CREATE DATABASE ejercicios_postgres OWNER developer;

-- Conceder permisos
GRANT ALL PRIVILEGES ON DATABASE ejercicios_postgres TO developer;
```

## Arquitectura de PostgreSQL

### Componentes principales:
- **Postmaster**: Proceso principal del servidor
- **Backend Processes**: Procesos que manejan conexiones
- **Shared Memory**: Memoria compartida entre procesos
- **WAL (Write-Ahead Logging)**: Log de transacciones
- **Background Processes**: Procesos auxiliares

### Estructura de directorios:
```
/var/lib/postgresql/     # Datos de las bases de datos
/var/log/postgresql/     # Archivos de log
/etc/postgresql/         # Archivos de configuración
/usr/bin/                # Binarios ejecutables
/usr/share/postgresql/   # Archivos de ayuda
```

## Configuración Avanzada

### Archivo postgresql.conf
```ini
# Configuración básica
listen_addresses = 'localhost'
port = 5432
max_connections = 100

# Configuración de memoria
shared_buffers = 128MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB

# Configuración de logs
log_destination = 'stderr'
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_min_duration_statement = 1000

# Configuración de WAL
wal_level = replica
max_wal_size = 1GB
checkpoint_completion_target = 0.9
```

### Archivo pg_hba.conf (Autenticación)
```ini
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
```

## Herramientas de Administración

### 1. pgAdmin 4
- **Descripción**: Herramienta gráfica oficial de PostgreSQL
- **Características**: Administración completa, desarrollo, monitoreo
- **Acceso**: http://localhost/pgadmin4

### 2. psql (Command Line)
```bash
# Conectar a PostgreSQL
psql -U usuario -d base_datos -h host -p puerto

# Opciones útiles
psql -U postgres -d postgres --echo-all    # Mostrar comandos
psql -U postgres -d postgres --timing      # Mostrar tiempos
```

### 3. DBeaver
- **Descripción**: Herramienta universal de bases de datos
- **Características**: Soporte para múltiples SGBD
- **Descarga**: [dbeaver.io](https://dbeaver.io/)

## Comandos de Administración

### Gestión de servicios
```bash
# Linux (systemd)
sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql
sudo systemctl status postgresql

# macOS (Homebrew)
brew services start postgresql@15
brew services stop postgresql@15
brew services restart postgresql@15
```

### Comandos PostgreSQL útiles
```sql
-- Ver información del servidor
SELECT version();
SHOW server_version;

-- Ver bases de datos
\l
SELECT datname FROM pg_database;

-- Ver usuarios/roles
\du
SELECT rolname FROM pg_roles;

-- Ver procesos activos
SELECT * FROM pg_stat_activity;

-- Ver configuración
SHOW ALL;
```

## Ejercicios Prácticos

### Ejercicio 1: Instalación y Verificación
```sql
-- Conectar a PostgreSQL
\c postgres

-- Verificar instalación
SELECT 
    'PostgreSQL Version' as info,
    version() as valor
UNION ALL
SELECT 
    'Server Encoding',
    current_setting('server_encoding')
UNION ALL
SELECT 
    'Data Directory',
    current_setting('data_directory');
```

### Ejercicio 2: Configuración de Roles y Usuarios
```sql
-- Crear base de datos para ejercicios
CREATE DATABASE ejercicios_postgres;
\c ejercicios_postgres

-- Crear tabla de roles del sistema
CREATE TABLE roles_sistema (
    id SERIAL PRIMARY KEY,
    rol_name VARCHAR(50) NOT NULL,
    rol_superuser BOOLEAN,
    rol_createdb BOOLEAN,
    rol_createrole BOOLEAN,
    rol_login BOOLEAN,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar roles actuales
INSERT INTO roles_sistema (rol_name, rol_superuser, rol_createdb, rol_createrole, rol_login)
SELECT 
    rolname,
    rolsuper,
    rolcreatedb,
    rolcreaterole,
    rolcanlogin
FROM pg_roles;
```

### Ejercicio 3: Análisis de Configuración
```sql
-- Crear tabla de configuración
CREATE TABLE configuracion_postgres (
    id SERIAL PRIMARY KEY,
    parametro VARCHAR(100) NOT NULL,
    valor TEXT,
    categoria VARCHAR(50),
    descripcion TEXT
);

-- Insertar parámetros importantes
INSERT INTO configuracion_postgres (parametro, valor, categoria, descripcion) VALUES
('version', current_setting('server_version'), 'Sistema', 'Versión de PostgreSQL'),
('port', current_setting('port'), 'Red', 'Puerto de conexión'),
('max_connections', current_setting('max_connections'), 'Conexiones', 'Máximo de conexiones'),
('shared_buffers', current_setting('shared_buffers'), 'Memoria', 'Buffer compartido');
```

### Ejercicio 4: Monitoreo de Conexiones
```sql
-- Crear tabla de monitoreo
CREATE TABLE monitoreo_conexiones (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(50),
    base_datos VARCHAR(50),
    estado VARCHAR(50),
    query TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Función para registrar conexiones
CREATE OR REPLACE FUNCTION registrar_conexiones()
RETURNS VOID AS $$
BEGIN
    INSERT INTO monitoreo_conexiones (usuario, base_datos, estado, query)
    SELECT 
        usename,
        datname,
        state,
        query
    FROM pg_stat_activity
    WHERE usename IS NOT NULL;
END;
$$ LANGUAGE plpgsql;
```

### Ejercicio 5: Análisis de Rendimiento
```sql
-- Crear tabla de métricas
CREATE TABLE metricas_rendimiento (
    id SERIAL PRIMARY KEY,
    metrica VARCHAR(100) NOT NULL,
    valor BIGINT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar métricas básicas
INSERT INTO metricas_rendimiento (metrica, valor) VALUES
('total_connections', (SELECT setting::bigint FROM pg_settings WHERE name = 'max_connections')),
('active_connections', (SELECT count(*) FROM pg_stat_activity)),
('database_size', (SELECT pg_database_size(current_database())));
```

### Ejercicio 6: Configuración de Logs
```sql
-- Verificar configuración de logs
SELECT 
    'Log Directory' as configuracion,
    current_setting('log_directory') as valor,
    'Directorio de archivos de log' as descripcion
UNION ALL
SELECT 
    'Log Filename',
    current_setting('log_filename'),
    'Patrón de nombres de archivos de log'
UNION ALL
SELECT 
    'Log Min Duration',
    current_setting('log_min_duration_statement'),
    'Duración mínima para log de consultas';
```

### Ejercicio 7: Análisis de Bases de Datos
```sql
-- Crear vista de análisis de bases de datos
CREATE VIEW analisis_bases_datos AS
SELECT 
    d.datname as nombre_bd,
    pg_encoding_to_char(d.encoding) as encoding,
    d.datcollate as collate,
    d.datctype as ctype,
    (SELECT count(*) FROM pg_tables WHERE schemaname = 'public') as cantidad_tablas,
    pg_size_pretty(pg_database_size(d.datname)) as tamaño
FROM pg_database d
WHERE d.datname NOT IN ('template0', 'template1', 'postgres');

-- Consultar la vista
SELECT * FROM analisis_bases_datos;
```

### Ejercicio 8: Configuración de Seguridad
```sql
-- Crear tabla de auditoría de seguridad
CREATE TABLE auditoria_seguridad (
    id SERIAL PRIMARY KEY,
    evento VARCHAR(100) NOT NULL,
    usuario VARCHAR(50),
    detalles TEXT,
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Función para auditoría
CREATE OR REPLACE FUNCTION audit_roles()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria_seguridad (evento, usuario, detalles)
    VALUES ('Cambio de Rol', NEW.rol_name, 'Rol modificado en el sistema');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para auditoría
CREATE TRIGGER trigger_audit_roles
    AFTER INSERT OR UPDATE ON roles_sistema
    FOR EACH ROW
    EXECUTE FUNCTION audit_roles();
```

### Ejercicio 9: Optimización de Configuración
```sql
-- Crear tabla de recomendaciones
CREATE TABLE recomendaciones_configuracion (
    id SERIAL PRIMARY KEY,
    categoria VARCHAR(50) NOT NULL,
    parametro VARCHAR(100) NOT NULL,
    valor_actual VARCHAR(100),
    valor_recomendado VARCHAR(100),
    razon TEXT,
    prioridad VARCHAR(20) DEFAULT 'Media'
);

-- Insertar recomendaciones básicas
INSERT INTO recomendaciones_configuracion (categoria, parametro, valor_actual, valor_recomendado, razon, prioridad) VALUES
('Memoria', 'shared_buffers', current_setting('shared_buffers'), '25% de RAM', 'Mejora rendimiento general', 'Alta'),
('Conexiones', 'max_connections', current_setting('max_connections'), '200-500', 'Adecuado para aplicaciones web', 'Media'),
('Logs', 'log_min_duration_statement', current_setting('log_min_duration_statement'), '1000ms', 'Importante para optimización', 'Alta');
```

### Ejercicio 10: Reporte Completo del Sistema
```sql
-- Crear función para reporte completo
CREATE OR REPLACE FUNCTION generar_reporte_sistema()
RETURNS TABLE(
    seccion TEXT,
    parametro TEXT,
    valor TEXT
) AS $$
BEGIN
    -- Información General
    RETURN QUERY
    SELECT 'Información General'::TEXT, 'Versión'::TEXT, version()::TEXT
    UNION ALL
    SELECT 'Información General'::TEXT, 'Puerto'::TEXT, current_setting('port')::TEXT
    UNION ALL
    SELECT 'Información General'::TEXT, 'Data Directory'::TEXT, current_setting('data_directory')::TEXT;
    
    -- Configuración de Memoria
    RETURN QUERY
    SELECT 'Configuración de Memoria'::TEXT, 'Shared Buffers'::TEXT, current_setting('shared_buffers')::TEXT
    UNION ALL
    SELECT 'Configuración de Memoria'::TEXT, 'Work Memory'::TEXT, current_setting('work_mem')::TEXT;
    
    -- Estadísticas de Uso
    RETURN QUERY
    SELECT 'Estadísticas de Uso'::TEXT, 'Conexiones Activas'::TEXT, count(*)::TEXT
    FROM pg_stat_activity
    UNION ALL
    SELECT 'Estadísticas de Uso'::TEXT, 'Tamaño de BD'::TEXT, pg_size_pretty(pg_database_size(current_database()))::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar reporte
SELECT * FROM generar_reporte_sistema();
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Cómo instalar PostgreSQL en diferentes sistemas operativos
- Configuración inicial y creación de roles/usuarios
- Arquitectura y estructura de PostgreSQL
- Herramientas de administración disponibles
- Comandos básicos de administración
- Configuración avanzada del servidor

## Próxima Clase
[Clase 4: SQL Server: Instalación y Configuración](clase_4_sqlserver_instalacion.md)

## Recursos Adicionales
- [PostgreSQL Installation Guide](https://www.postgresql.org/docs/current/installation.html)
- [PostgreSQL Configuration](https://www.postgresql.org/docs/current/config-setting.html)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
