# Clase 5: Oracle Database: Instalación y Configuración

## Objetivos de la Clase
- Instalar Oracle Database en diferentes sistemas operativos
- Configurar Oracle Database para desarrollo y producción
- Conocer las herramientas de administración
- Entender la arquitectura de Oracle Database
- Configurar usuarios, roles y permisos

## Introducción a Oracle Database

**Oracle Database** es un sistema de gestión de bases de datos relacional de Oracle Corporation, conocido por su robustez, escalabilidad y capacidades empresariales avanzadas.

### Características principales:
- **Enterprise Grade**: Diseñado para aplicaciones empresariales críticas
- **Alta Disponibilidad**: RAC, Data Guard, GoldenGate
- **Escalabilidad**: Soporte para grandes volúmenes de datos
- **Seguridad Avanzada**: Transparent Data Encryption, Database Vault
- **Multitenancy**: Oracle Multitenant Architecture

## Instalación en Windows

### Método 1: Oracle Database Installer (Recomendado)

1. **Descargar Oracle Database**
   - Ir a [oracle.com/database](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html)
   - Descargar "Oracle Database 19c Enterprise Edition" o "Express Edition"

2. **Ejecutar el instalador**
   ```bash
   # Ejecutar setup.exe
   # Seleccionar tipo de instalación:
   # - Enterprise Edition: Completa
   # - Standard Edition: Básica
   # - Express Edition: Gratuita
   ```

3. **Configuración inicial**
   ```sql
   -- Configurar contraseña para usuarios SYS y SYSTEM
   -- Configurar puerto (default: 1521)
   -- Configurar SID (default: ORCL)
   -- Configurar tablespace inicial
   ```

### Método 2: Oracle Express Edition (XE)
```bash
# Descargar Oracle XE desde oracle.com
# Instalación simplificada para desarrollo
# Incluye Oracle Application Express (APEX)
```

## Instalación en Linux

### Oracle Linux / RHEL / CentOS
```bash
# Configurar repositorio Oracle
sudo yum install oracle-database-preinstall-19c

# Descargar Oracle Database
# wget [URL del archivo de Oracle Database]

# Ejecutar instalación
sudo -u oracle ./runInstaller

# Ejecutar scripts de configuración
sudo /u01/app/oraInventory/orainstRoot.sh
sudo /u01/app/oracle/product/19.0.0/dbhome_1/root.sh
```

### Ubuntu/Debian
```bash
# Instalar dependencias
sudo apt-get update
sudo apt-get install alien libaio1 unixodbc

# Convertir paquetes RPM a DEB
sudo alien -d oracle-instantclient19.3-basic-19.3.0.0.0-1.x86_64.rpm

# Instalar paquetes
sudo dpkg -i oracle-instantclient19.3-basic_19.3.0.0.0-2_amd64.deb
```

## Instalación en Docker

### Oracle Database en Docker
```bash
# Ejecutar Oracle Database en Docker
docker run -d --name oracle-db \
  -p 1521:1521 -p 5500:5500 \
  -e ORACLE_PWD=Oracle123 \
  -e ORACLE_CHARACTERSET=AL32UTF8 \
  oracle/database:19.3.0-ee

# Conectar desde otro contenedor
docker exec -it oracle-db sqlplus sys/Oracle123@//localhost:1521/ORCLPDB1 as sysdba
```

## Configuración Inicial

### 1. Conectar por primera vez
```bash
# Usando sqlplus
sqlplus sys/Oracle123@//localhost:1521/ORCLPDB1 as sysdba

# Usando SQL Developer
# Host: localhost
# Port: 1521
# Service Name: ORCLPDB1
# Username: SYS
# Password: [contraseña configurada]
# Role: SYSDBA
```

### 2. Configuración básica
```sql
-- Conectar como SYS
CONNECT sys/Oracle123@//localhost:1521/ORCLPDB1 as sysdba;

-- Crear usuario administrativo
CREATE USER admin IDENTIFIED BY AdminPass123;
GRANT DBA TO admin;

-- Crear usuario para desarrollo
CREATE USER developer IDENTIFIED BY DevPass123;
GRANT CONNECT, RESOURCE TO developer;
GRANT CREATE SESSION TO developer;

-- Crear tablespace para desarrollo
CREATE TABLESPACE dev_data
DATAFILE '/u01/app/oracle/oradata/ORCL/dev_data01.dbf'
SIZE 100M AUTOEXTEND ON;

-- Asignar tablespace al usuario
ALTER USER developer DEFAULT TABLESPACE dev_data;
ALTER USER developer QUOTA UNLIMITED ON dev_data;
```

## Arquitectura de Oracle Database

### Componentes principales:
- **Oracle Instance**: Procesos y memoria del servidor
- **Oracle Database**: Archivos físicos de datos
- **System Global Area (SGA)**: Memoria compartida
- **Program Global Area (PGA)**: Memoria privada de procesos
- **Background Processes**: Procesos del sistema

### Estructura de archivos:
```
/u01/app/oracle/                    # Directorio Oracle Home
/u01/app/oracle/oradata/            # Archivos de datos
/u01/app/oracle/flash_recovery_area/ # Área de recuperación
/u01/app/oracle/admin/              # Archivos de administración
/u01/app/oracle/diag/               # Archivos de diagnóstico
```

## Configuración Avanzada

### Configuración del servidor
```sql
-- Ver configuración actual
SELECT * FROM v$parameter WHERE name IN ('sga_target', 'pga_aggregate_target', 'db_block_size');

-- Configurar memoria SGA
ALTER SYSTEM SET sga_target=1G SCOPE=SPFILE;
ALTER SYSTEM SET pga_aggregate_target=500M SCOPE=SPFILE;

-- Configurar conexiones máximas
ALTER SYSTEM SET processes=300 SCOPE=SPFILE;
ALTER SYSTEM SET sessions=335 SCOPE=SPFILE;

-- Reiniciar instancia para aplicar cambios
SHUTDOWN IMMEDIATE;
STARTUP;
```

### Configuración de base de datos
```sql
-- Configurar tablespace
ALTER TABLESPACE dev_data ADD DATAFILE 
'/u01/app/oracle/oradata/ORCL/dev_data02.dbf' SIZE 100M AUTOEXTEND ON;

-- Configurar usuario
ALTER USER developer QUOTA 500M ON dev_data;

-- Configurar perfil de usuario
CREATE PROFILE dev_profile LIMIT
    SESSIONS_PER_USER 5
    CPU_PER_SESSION 10000
    CONNECT_TIME 480
    IDLE_TIME 30;

ALTER USER developer PROFILE dev_profile;
```

## Herramientas de Administración

### 1. Oracle SQL Developer
- **Descripción**: Herramienta gráfica oficial de Oracle
- **Características**: Desarrollo, administración, modelado
- **Descarga**: [oracle.com/sql-developer](https://www.oracle.com/database/technologies/appdev/sql-developer.html)

### 2. Oracle Enterprise Manager (OEM)
- **Descripción**: Consola de administración web
- **Características**: Monitoreo, administración, tuning
- **Acceso**: https://localhost:5500/em

### 3. sqlplus (Command Line)
```bash
# Conectar a Oracle
sqlplus usuario/contraseña@//host:puerto/servicio

# Ejecutar script
sqlplus sys/Oracle123@//localhost:1521/ORCLPDB1 as sysdba @script.sql

# Opciones útiles
sqlplus -S sys/Oracle123@//localhost:1521/ORCLPDB1 as sysdba @script.sql
```

## Comandos de Administración

### Gestión de servicios
```bash
# Linux (systemd)
sudo systemctl start oracle-19c
sudo systemctl stop oracle-19c
sudo systemctl restart oracle-19c
sudo systemctl status oracle-19c

# Windows (Services)
net start OracleServiceORCL
net stop OracleServiceORCL
```

### Comandos Oracle útiles
```sql
-- Ver información del servidor
SELECT * FROM v$version;
SELECT * FROM v$instance;

-- Ver bases de datos (PDBs)
SELECT name, open_mode FROM v$pdbs;

-- Ver usuarios/roles
SELECT username FROM dba_users;
SELECT role FROM dba_roles;

-- Ver procesos activos
SELECT * FROM v$session;
SELECT * FROM v$process;
```

## Ejercicios Prácticos

### Ejercicio 1: Instalación y Verificación
```sql
-- Verificar instalación
SELECT 
    'Oracle Version' as info,
    banner as valor
FROM v$version
WHERE rownum = 1
UNION ALL
SELECT 
    'Instance Name',
    instance_name
FROM v$instance
UNION ALL
SELECT 
    'Database Name',
    name
FROM v$database;
```

### Ejercicio 2: Configuración de Usuarios y Roles
```sql
-- Crear base de datos para ejercicios
CREATE TABLESPACE ejercicios_data
DATAFILE '/u01/app/oracle/oradata/ORCL/ejercicios_data01.dbf'
SIZE 50M AUTOEXTEND ON;

-- Crear tabla de usuarios del sistema
CREATE TABLE usuarios_sistema (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) NOT NULL,
    account_status VARCHAR2(20),
    created DATE,
    default_tablespace VARCHAR2(30),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar usuarios actuales
INSERT INTO usuarios_sistema (username, account_status, created, default_tablespace)
SELECT 
    username,
    account_status,
    created,
    default_tablespace
FROM dba_users
WHERE username NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'DIP', 'TSMSYS', 'DBSNMP', 'WMSYS', 'EXFSYS', 'CTXSYS', 'XDB', 'ANONYMOUS', 'ORDSYS', 'ORDPLUGINS', 'SI_INFORMTN_SCHEMA', 'MDSYS', 'OLAPSYS', 'MDDATA', 'SPATIAL_CSW_ADMIN_USR', 'SPATIAL_WFS_ADMIN_USR');
```

### Ejercicio 3: Análisis de Configuración
```sql
-- Crear tabla de configuración
CREATE TABLE configuracion_oracle (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    parametro VARCHAR2(100) NOT NULL,
    valor VARCHAR2(4000),
    categoria VARCHAR2(50),
    descripcion VARCHAR2(4000)
);

-- Insertar parámetros importantes
INSERT INTO configuracion_oracle (parametro, valor, categoria, descripcion) VALUES
('version', (SELECT banner FROM v$version WHERE rownum = 1), 'Sistema', 'Versión de Oracle Database'),
('instance_name', (SELECT instance_name FROM v$instance), 'Sistema', 'Nombre de la instancia'),
('db_name', (SELECT name FROM v$database), 'Sistema', 'Nombre de la base de datos'),
('sga_target', (SELECT value FROM v$parameter WHERE name = 'sga_target'), 'Memoria', 'Tamaño del SGA');
```

### Ejercicio 4: Monitoreo de Conexiones
```sql
-- Crear tabla de monitoreo
CREATE TABLE monitoreo_conexiones (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sid NUMBER,
    serial# NUMBER,
    username VARCHAR2(50),
    machine VARCHAR2(100),
    program VARCHAR2(100),
    status VARCHAR2(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para registrar conexiones
CREATE OR REPLACE PROCEDURE registrar_conexiones
AS
BEGIN
    INSERT INTO monitoreo_conexiones (sid, serial#, username, machine, program, status)
    SELECT 
        sid,
        serial#,
        username,
        machine,
        program,
        status
    FROM v$session
    WHERE username IS NOT NULL;
END;
/
```

### Ejercicio 5: Análisis de Rendimiento
```sql
-- Crear tabla de métricas
CREATE TABLE metricas_rendimiento (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    metrica VARCHAR2(100) NOT NULL,
    valor NUMBER,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar métricas básicas
INSERT INTO metricas_rendimiento (metrica, valor) VALUES
('active_sessions', (SELECT COUNT(*) FROM v$session WHERE status = 'ACTIVE')),
('total_sessions', (SELECT COUNT(*) FROM v$session)),
('db_size_mb', (SELECT SUM(bytes)/1024/1024 FROM dba_data_files));
```

### Ejercicio 6: Configuración de Logs
```sql
-- Verificar configuración de logs
SELECT 
    'Alert Log' as configuracion,
    value as valor,
    'Ubicación del log de alertas' as descripcion
FROM v$parameter 
WHERE name = 'background_dump_dest'
UNION ALL
SELECT 
    'Trace Directory',
    value,
    'Directorio de archivos de trace'
FROM v$parameter 
WHERE name = 'user_dump_dest'
UNION ALL
SELECT 
    'Core Dump Directory',
    value,
    'Directorio de core dumps'
FROM v$parameter 
WHERE name = 'core_dump_dest';
```

### Ejercicio 7: Análisis de Bases de Datos
```sql
-- Crear vista de análisis de bases de datos
CREATE VIEW analisis_bases_datos AS
SELECT 
    d.name as nombre_bd,
    d.dbid,
    d.created as fecha_creacion,
    d.log_mode,
    (SELECT COUNT(*) FROM dba_tables WHERE owner = 'SYSTEM') as cantidad_tablas_sistema,
    (SELECT SUM(bytes)/1024/1024 FROM dba_data_files) as tamaño_mb
FROM v$database d;

-- Consultar la vista
SELECT * FROM analisis_bases_datos;
```

### Ejercicio 8: Configuración de Seguridad
```sql
-- Crear tabla de auditoría de seguridad
CREATE TABLE auditoria_seguridad (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    evento VARCHAR2(100) NOT NULL,
    usuario VARCHAR2(50),
    detalles VARCHAR2(4000),
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para auditoría
CREATE OR REPLACE TRIGGER tr_audit_usuarios
AFTER INSERT OR UPDATE ON usuarios_sistema
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_seguridad (evento, usuario, detalles)
    VALUES ('Cambio de Usuario', :NEW.username, 'Usuario modificado en el sistema');
END;
/
```

### Ejercicio 9: Optimización de Configuración
```sql
-- Crear tabla de recomendaciones
CREATE TABLE recomendaciones_configuracion (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    categoria VARCHAR2(50) NOT NULL,
    parametro VARCHAR2(100) NOT NULL,
    valor_actual VARCHAR2(100),
    valor_recomendado VARCHAR2(100),
    razon VARCHAR2(4000),
    prioridad VARCHAR2(20) DEFAULT 'Media'
);

-- Insertar recomendaciones básicas
INSERT INTO recomendaciones_configuracion (categoria, parametro, valor_actual, valor_recomendado, razon, prioridad) VALUES
('Memoria', 'sga_target', (SELECT value FROM v$parameter WHERE name = 'sga_target'), '40-60% de RAM', 'Mejora rendimiento general', 'Alta'),
('Conexiones', 'processes', (SELECT value FROM v$parameter WHERE name = 'processes'), '200-500', 'Adecuado para aplicaciones web', 'Media'),
('Logs', 'log_archive_dest_1', (SELECT value FROM v$parameter WHERE name = 'log_archive_dest_1'), 'Configurado', 'Importante para recuperación', 'Alta');
```

### Ejercicio 10: Reporte Completo del Sistema
```sql
-- Crear procedimiento para reporte completo
CREATE OR REPLACE PROCEDURE generar_reporte_sistema
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== REPORTE DEL SISTEMA ORACLE DATABASE ===');
    
    DBMS_OUTPUT.PUT_LINE('Información General:');
    FOR rec IN (SELECT 'Versión' as parametro, banner as valor FROM v$version WHERE rownum = 1
                UNION ALL
                SELECT 'Instancia', instance_name FROM v$instance
                UNION ALL
                SELECT 'Base de Datos', name FROM v$database) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.parametro || ': ' || rec.valor);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Configuración de Memoria:');
    FOR rec IN (SELECT 'SGA Target' as parametro, value as valor FROM v$parameter WHERE name = 'sga_target'
                UNION ALL
                SELECT 'PGA Target', value FROM v$parameter WHERE name = 'pga_aggregate_target') LOOP
        DBMS_OUTPUT.PUT_LINE(rec.parametro || ': ' || rec.valor);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Estadísticas de Uso:');
    FOR rec IN (SELECT 'Sesiones Activas' as parametro, COUNT(*) as valor FROM v$session WHERE status = 'ACTIVE') LOOP
        DBMS_OUTPUT.PUT_LINE(rec.parametro || ': ' || rec.valor);
    END LOOP;
END;
/

-- Ejecutar reporte
SET SERVEROUTPUT ON;
EXEC generar_reporte_sistema;
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Cómo instalar Oracle Database en diferentes sistemas operativos
- Configuración inicial y creación de usuarios/roles
- Arquitectura y estructura de Oracle Database
- Herramientas de administración disponibles
- Comandos básicos de administración
- Configuración avanzada del servidor

## Próxima Clase
[Clase 6: Herramientas de Administración](clase_6_herramientas_administracion.md)

## Recursos Adicionales
- [Oracle Database Installation Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/install/)
- [Oracle Database Configuration](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/)
- [Oracle SQL Developer](https://docs.oracle.com/en/database/oracle/sql-developer/)
