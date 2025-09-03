# Clase 2: MySQL: Instalación y Configuración

## Objetivos de la Clase
- Instalar MySQL en diferentes sistemas operativos
- Configurar MySQL para desarrollo y producción
- Conocer las herramientas de administración
- Entender la estructura de archivos de MySQL
- Configurar usuarios y permisos básicos

## Introducción a MySQL

**MySQL** es un sistema de gestión de bases de datos relacional de código abierto, desarrollado originalmente por MySQL AB y actualmente propiedad de Oracle Corporation.

### Características principales:
- **Open Source**: Licencia GPL para uso comunitario
- **Multiplataforma**: Windows, Linux, macOS
- **Alto rendimiento**: Optimizado para aplicaciones web
- **Fácil de usar**: Sintaxis SQL estándar
- **Escalable**: Desde aplicaciones pequeñas hasta grandes sistemas

## Instalación en Windows

### Método 1: MySQL Installer (Recomendado)

1. **Descargar MySQL Installer**
   - Ir a [mysql.com/downloads](https://dev.mysql.com/downloads/installer/)
   - Descargar "MySQL Installer for Windows"

2. **Ejecutar el instalador**
   ```bash
   # El instalador guiará a través del proceso
   # Seleccionar "Developer Default" para desarrollo
   # O "Server Only" para solo el servidor
   ```

3. **Configuración inicial**
   ```sql
   -- Configurar contraseña root
   -- Crear usuario administrativo
   -- Configurar puerto (default: 3306)
   ```

### Método 2: Chocolatey
```powershell
# Instalar Chocolatey si no está instalado
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar MySQL
choco install mysql
```

## Instalación en Linux (Ubuntu/Debian)

### Método 1: APT (Recomendado)
```bash
# Actualizar repositorios
sudo apt update

# Instalar MySQL Server
sudo apt install mysql-server

# Configurar seguridad
sudo mysql_secure_installation

# Iniciar servicio
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Método 2: Repositorio oficial
```bash
# Descargar paquete de configuración
wget https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb

# Instalar configuración
sudo dpkg -i mysql-apt-config_0.8.24-1_all.deb

# Actualizar repositorios
sudo apt update

# Instalar MySQL
sudo apt install mysql-server
```

## Instalación en macOS

### Método 1: Homebrew (Recomendado)
```bash
# Instalar Homebrew si no está instalado
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar MySQL
brew install mysql

# Iniciar servicio
brew services start mysql
```

### Método 2: DMG oficial
```bash
# Descargar desde mysql.com
# Ejecutar el archivo .dmg
# Seguir el asistente de instalación
```

## Configuración Inicial

### 1. Conectar por primera vez
```bash
# En Linux/macOS
mysql -u root -p

# En Windows (desde línea de comandos)
mysql -u root -p
```

### 2. Configuración básica
```sql
-- Cambiar contraseña root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'nueva_contraseña';

-- Crear usuario administrativo
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'contraseña_admin';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;

-- Crear usuario para desarrollo
CREATE USER 'developer'@'localhost' IDENTIFIED BY 'contraseña_dev';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON *.* TO 'developer'@'localhost';

-- Aplicar cambios
FLUSH PRIVILEGES;
```

## Estructura de Archivos MySQL

### Directorios principales:
```
/var/lib/mysql/          # Datos de las bases de datos
/var/log/mysql/          # Archivos de log
/etc/mysql/              # Archivos de configuración
/usr/bin/                # Binarios ejecutables
/usr/share/mysql/        # Archivos de ayuda y ejemplos
```

### Archivos de configuración importantes:
- **my.cnf** (Linux/macOS) o **my.ini** (Windows)
- **mysql.cnf**: Configuración global
- **mysqld.cnf**: Configuración del servidor

## Configuración Avanzada

### Archivo my.cnf básico
```ini
[mysqld]
# Configuración básica
port = 3306
bind-address = 127.0.0.1
datadir = /var/lib/mysql
socket = /var/run/mysqld/mysqld.sock

# Configuración de memoria
innodb_buffer_pool_size = 128M
key_buffer_size = 32M
max_connections = 100

# Configuración de logs
log-error = /var/log/mysql/error.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2

# Configuración de seguridad
local-infile = 0
```

## Herramientas de Administración

### 1. MySQL Workbench
- **Descripción**: Herramienta visual oficial de MySQL
- **Características**: Diseño de bases de datos, administración, desarrollo
- **Descarga**: [mysql.com/products/workbench](https://dev.mysql.com/downloads/workbench/)

### 2. phpMyAdmin
- **Descripción**: Interfaz web para administración
- **Instalación**:
```bash
# Ubuntu/Debian
sudo apt install phpmyadmin

# Configurar Apache/Nginx
# Acceder via http://localhost/phpmyadmin
```

### 3. MySQL Command Line
```bash
# Conectar a MySQL
mysql -u usuario -p -h host -P puerto

# Opciones útiles
mysql -u root -p --verbose    # Modo verboso
mysql -u root -p --safe-mode  # Modo seguro
```

## Comandos de Administración

### Gestión de servicios
```bash
# Linux (systemd)
sudo systemctl start mysql
sudo systemctl stop mysql
sudo systemctl restart mysql
sudo systemctl status mysql

# Windows (Services)
net start mysql
net stop mysql

# macOS (Homebrew)
brew services start mysql
brew services stop mysql
brew services restart mysql
```

### Comandos MySQL útiles
```sql
-- Ver información del servidor
SELECT VERSION();
SHOW VARIABLES LIKE 'version%';

-- Ver bases de datos
SHOW DATABASES;

-- Ver usuarios
SELECT User, Host FROM mysql.user;

-- Ver procesos activos
SHOW PROCESSLIST;

-- Ver configuración
SHOW VARIABLES;
SHOW STATUS;
```

## Ejercicios Prácticos

### Ejercicio 1: Instalación y Verificación
```sql
-- Verificar instalación
SELECT 
    'MySQL Version' as info,
    VERSION() as valor
UNION ALL
SELECT 
    'Installation Date',
    CREATE_TIME
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'mysql' 
LIMIT 1;
```

### Ejercicio 2: Configuración de Usuarios
```sql
-- Crear base de datos para ejercicios
CREATE DATABASE ejercicios_mysql;
USE ejercicios_mysql;

-- Crear tabla de usuarios del sistema
CREATE TABLE usuarios_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(50) NOT NULL,
    host VARCHAR(100) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar usuarios actuales
INSERT INTO usuarios_sistema (usuario, host)
SELECT User, Host FROM mysql.user;
```

### Ejercicio 3: Análisis de Configuración
```sql
-- Crear tabla de configuración
CREATE TABLE configuracion_mysql (
    id INT PRIMARY KEY AUTO_INCREMENT,
    variable VARCHAR(100) NOT NULL,
    valor TEXT,
    categoria VARCHAR(50),
    descripcion TEXT
);

-- Insertar variables importantes
INSERT INTO configuracion_mysql (variable, valor, categoria, descripcion) VALUES
('version', VERSION(), 'Sistema', 'Versión de MySQL'),
('port', @@port, 'Red', 'Puerto de conexión'),
('max_connections', @@max_connections, 'Conexiones', 'Máximo de conexiones'),
('innodb_buffer_pool_size', @@innodb_buffer_pool_size, 'Memoria', 'Buffer pool de InnoDB');
```

### Ejercicio 4: Monitoreo de Conexiones
```sql
-- Crear tabla de monitoreo
CREATE TABLE monitoreo_conexiones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(50),
    host VARCHAR(100),
    comando VARCHAR(50),
    tiempo_activo INT,
    estado VARCHAR(50),
    info TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Función para registrar conexiones
DELIMITER //
CREATE PROCEDURE registrar_conexiones()
BEGIN
    INSERT INTO monitoreo_conexiones (usuario, host, comando, tiempo_activo, estado, info)
    SELECT 
        USER,
        HOST,
        COMMAND,
        TIME,
        STATE,
        INFO
    FROM information_schema.PROCESSLIST
    WHERE USER IS NOT NULL;
END //
DELIMITER ;
```

### Ejercicio 5: Análisis de Rendimiento
```sql
-- Crear tabla de métricas
CREATE TABLE metricas_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metrica VARCHAR(100) NOT NULL,
    valor BIGINT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar métricas básicas
INSERT INTO metricas_rendimiento (metrica, valor) VALUES
('connections', (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Connections')),
('uptime', (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Uptime')),
('questions', (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Questions')),
('slow_queries', (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Slow_queries'));
```

### Ejercicio 6: Configuración de Logs
```sql
-- Verificar configuración de logs
SELECT 
    'Error Log' as tipo_log,
    @@log_error as ubicacion,
    'Errores del servidor' as descripcion
UNION ALL
SELECT 
    'Slow Query Log',
    @@slow_query_log_file,
    'Consultas lentas'
UNION ALL
SELECT 
    'General Log',
    @@general_log_file,
    'Todas las consultas';
```

### Ejercicio 7: Análisis de Bases de Datos
```sql
-- Crear vista de análisis de bases de datos
CREATE VIEW analisis_bases_datos AS
SELECT 
    SCHEMA_NAME as nombre_bd,
    DEFAULT_CHARACTER_SET_NAME as charset,
    DEFAULT_COLLATION_NAME as collation,
    (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = SCHEMA_NAME) as cantidad_tablas,
    (SELECT SUM(DATA_LENGTH + INDEX_LENGTH) FROM information_schema.TABLES WHERE TABLE_SCHEMA = SCHEMA_NAME) as tamaño_bytes
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME NOT IN ('information_schema', 'performance_schema', 'mysql', 'sys');

-- Consultar la vista
SELECT * FROM analisis_bases_datos;
```

### Ejercicio 8: Configuración de Seguridad
```sql
-- Crear tabla de auditoría de seguridad
CREATE TABLE auditoria_seguridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evento VARCHAR(100) NOT NULL,
    usuario VARCHAR(50),
    host VARCHAR(100),
    detalles TEXT,
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger para auditoría de conexiones
DELIMITER //
CREATE TRIGGER audit_conexiones
AFTER INSERT ON usuarios_sistema
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_seguridad (evento, usuario, host, detalles)
    VALUES ('Nuevo Usuario', NEW.usuario, NEW.host, 'Usuario creado en el sistema');
END //
DELIMITER ;
```

### Ejercicio 9: Optimización de Configuración
```sql
-- Crear tabla de recomendaciones
CREATE TABLE recomendaciones_configuracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria VARCHAR(50) NOT NULL,
    parametro VARCHAR(100) NOT NULL,
    valor_actual VARCHAR(100),
    valor_recomendado VARCHAR(100),
    razon TEXT,
    prioridad ENUM('Alta', 'Media', 'Baja') DEFAULT 'Media'
);

-- Insertar recomendaciones básicas
INSERT INTO recomendaciones_configuracion (categoria, parametro, valor_actual, valor_recomendado, razon, prioridad) VALUES
('Memoria', 'innodb_buffer_pool_size', @@innodb_buffer_pool_size, '70% de RAM', 'Mejora rendimiento de InnoDB', 'Alta'),
('Conexiones', 'max_connections', @@max_connections, '200-500', 'Adecuado para aplicaciones web', 'Media'),
('Logs', 'slow_query_log', @@slow_query_log, 'ON', 'Importante para optimización', 'Alta');
```

### Ejercicio 10: Reporte Completo del Sistema
```sql
-- Crear procedimiento para reporte completo
DELIMITER //
CREATE PROCEDURE generar_reporte_sistema()
BEGIN
    SELECT '=== REPORTE DEL SISTEMA MYSQL ===' as titulo;
    
    SELECT 'Información General' as seccion;
    SELECT 
        'Versión' as parametro,
        VERSION() as valor
    UNION ALL
    SELECT 
        'Puerto',
        @@port
    UNION ALL
    SELECT 
        'Directorio de Datos',
        @@datadir;
    
    SELECT 'Configuración de Memoria' as seccion;
    SELECT 
        'Buffer Pool InnoDB' as parametro,
        @@innodb_buffer_pool_size as valor
    UNION ALL
    SELECT 
        'Key Buffer',
        @@key_buffer_size;
    
    SELECT 'Estadísticas de Uso' as seccion;
    SELECT 
        'Conexiones Totales' as parametro,
        VARIABLE_VALUE as valor
    FROM information_schema.GLOBAL_STATUS 
    WHERE VARIABLE_NAME = 'Connections'
    UNION ALL
    SELECT 
        'Consultas Totales',
        VARIABLE_VALUE
    FROM information_schema.GLOBAL_STATUS 
    WHERE VARIABLE_NAME = 'Questions';
END //
DELIMITER ;

-- Ejecutar reporte
CALL generar_reporte_sistema();
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Cómo instalar MySQL en diferentes sistemas operativos
- Configuración inicial y creación de usuarios
- Estructura de archivos y directorios de MySQL
- Herramientas de administración disponibles
- Comandos básicos de administración
- Configuración avanzada del servidor

## Próxima Clase
[Clase 3: PostgreSQL: Instalación y Configuración](clase_3_postgresql_instalacion.md)

## Recursos Adicionales
- [MySQL Installation Guide](https://dev.mysql.com/doc/refman/8.0/en/installing.html)
- [MySQL Configuration Reference](https://dev.mysql.com/doc/refman/8.0/en/server-configuration.html)
- [MySQL Workbench Documentation](https://dev.mysql.com/doc/workbench/en/)
