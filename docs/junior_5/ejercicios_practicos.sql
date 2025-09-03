-- =====================================================
-- EJERCICIOS PRÁCTICOS - MÓDULO 5: SISTEMAS DE GESTIÓN DE BASES DE DATOS
-- =====================================================

-- =====================================================
-- EJERCICIOS DE LA CLASE 1: INTRODUCCIÓN A LOS SGBD
-- =====================================================

-- Ejercicio 1: Investigación de SGBD
CREATE TABLE comparacion_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    desarrollador VARCHAR(100),
    licencia VARCHAR(50),
    plataforma VARCHAR(100),
    año_lanzamiento YEAR,
    ultima_version VARCHAR(20)
);

-- Ejercicio 2: Análisis de Características
INSERT INTO comparacion_sgbd VALUES
(1, 'MySQL', 'Oracle Corporation', 'GPL/Comercial', 'Multi-plataforma', 1995, '8.0'),
(2, 'PostgreSQL', 'PostgreSQL Global Development Group', 'BSD', 'Multi-plataforma', 1996, '15.0'),
(3, 'SQL Server', 'Microsoft', 'Comercial', 'Windows/Linux', 1989, '2022'),
(4, 'Oracle Database', 'Oracle Corporation', 'Comercial', 'Multi-plataforma', 1979, '19c');

-- Ejercicio 3: Consultas de Análisis
SELECT nombre, desarrollador, licencia 
FROM comparacion_sgbd 
WHERE licencia IN ('GPL', 'BSD', 'Open Source');

-- Ejercicio 4: Casos de Uso
CREATE TABLE casos_uso_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd_id INT,
    caso_uso VARCHAR(100),
    descripcion TEXT,
    FOREIGN KEY (sgbd_id) REFERENCES comparacion_sgbd(id)
);

-- Ejercicio 5: Análisis de Tendencias
SELECT 
    CASE 
        WHEN año_lanzamiento < 1990 THEN '1980s'
        WHEN año_lanzamiento < 2000 THEN '1990s'
        WHEN año_lanzamiento < 2010 THEN '2000s'
        ELSE '2010s+'
    END as decada,
    COUNT(*) as cantidad,
    GROUP_CONCAT(nombre) as sgbd
FROM comparacion_sgbd 
GROUP BY decada
ORDER BY decada;

-- =====================================================
-- EJERCICIOS DE LA CLASE 2: MYSQL: INSTALACIÓN Y CONFIGURACIÓN
-- =====================================================

-- Ejercicio 1: Instalación y Verificación
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

-- Ejercicio 2: Configuración de Usuarios
CREATE DATABASE ejercicios_mysql;
USE ejercicios_mysql;

CREATE TABLE usuarios_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(50) NOT NULL,
    host VARCHAR(100) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 3: Análisis de Configuración
CREATE TABLE configuracion_mysql (
    id INT PRIMARY KEY AUTO_INCREMENT,
    variable VARCHAR(100) NOT NULL,
    valor TEXT,
    categoria VARCHAR(50),
    descripcion TEXT
);

-- Ejercicio 4: Monitoreo de Conexiones
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

-- Ejercicio 5: Análisis de Rendimiento
CREATE TABLE metricas_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metrica VARCHAR(100) NOT NULL,
    valor BIGINT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 3: POSTGRESQL: INSTALACIÓN Y CONFIGURACIÓN
-- =====================================================

-- Ejercicio 1: Instalación y Verificación
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

-- Ejercicio 2: Configuración de Roles y Usuarios
CREATE DATABASE ejercicios_postgres;
\c ejercicios_postgres

CREATE TABLE roles_sistema (
    id SERIAL PRIMARY KEY,
    rol_name VARCHAR(50) NOT NULL,
    rol_superuser BOOLEAN,
    rol_createdb BOOLEAN,
    rol_createrole BOOLEAN,
    rol_login BOOLEAN,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 3: Análisis de Configuración
CREATE TABLE configuracion_postgres (
    id SERIAL PRIMARY KEY,
    parametro VARCHAR(100) NOT NULL,
    valor TEXT,
    categoria VARCHAR(50),
    descripcion TEXT
);

-- Ejercicio 4: Monitoreo de Conexiones
CREATE TABLE monitoreo_conexiones (
    id SERIAL PRIMARY KEY,
    sid NUMBER,
    serial# NUMBER,
    username VARCHAR(50),
    machine VARCHAR(100),
    program VARCHAR(100),
    status VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 5: Análisis de Rendimiento
CREATE TABLE metricas_rendimiento (
    id SERIAL PRIMARY KEY,
    metrica VARCHAR(100) NOT NULL,
    valor BIGINT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 4: SQL SERVER: INSTALACIÓN Y CONFIGURACIÓN
-- =====================================================

-- Ejercicio 1: Instalación y Verificación
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

-- Ejercicio 2: Configuración de Usuarios y Roles
CREATE DATABASE ejercicios_sqlserver;
USE ejercicios_sqlserver;

CREATE TABLE usuarios_sistema (
    id INT IDENTITY(1,1) PRIMARY KEY,
    login_name NVARCHAR(50) NOT NULL,
    is_disabled BIT,
    is_policy_checked BIT,
    is_expiration_checked BIT,
    fecha_creacion DATETIME2 DEFAULT GETDATE()
);

-- Ejercicio 3: Análisis de Configuración
CREATE TABLE configuracion_sqlserver (
    id INT IDENTITY(1,1) PRIMARY KEY,
    parametro NVARCHAR(100) NOT NULL,
    valor NVARCHAR(MAX),
    categoria NVARCHAR(50),
    descripcion NVARCHAR(MAX)
);

-- Ejercicio 4: Monitoreo de Conexiones
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

-- Ejercicio 5: Análisis de Rendimiento
CREATE TABLE metricas_rendimiento (
    id INT IDENTITY(1,1) PRIMARY KEY,
    metrica NVARCHAR(100) NOT NULL,
    valor BIGINT,
    fecha_registro DATETIME2 DEFAULT GETDATE()
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 5: ORACLE DATABASE: INSTALACIÓN Y CONFIGURACIÓN
-- =====================================================

-- Ejercicio 1: Instalación y Verificación
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

-- Ejercicio 2: Configuración de Usuarios y Roles
CREATE TABLESPACE ejercicios_data
DATAFILE '/u01/app/oracle/oradata/ORCL/ejercicios_data01.dbf'
SIZE 50M AUTOEXTEND ON;

CREATE TABLE usuarios_sistema (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) NOT NULL,
    account_status VARCHAR2(20),
    created DATE,
    default_tablespace VARCHAR2(30),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 3: Análisis de Configuración
CREATE TABLE configuracion_oracle (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    parametro VARCHAR2(100) NOT NULL,
    valor VARCHAR2(4000),
    categoria VARCHAR2(50),
    descripcion VARCHAR2(4000)
);

-- Ejercicio 4: Monitoreo de Conexiones
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

-- Ejercicio 5: Análisis de Rendimiento
CREATE TABLE metricas_rendimiento (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    metrica VARCHAR2(100) NOT NULL,
    valor NUMBER,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 6: HERRAMIENTAS DE ADMINISTRACIÓN
-- =====================================================

-- Ejercicio 1: Comparación de Herramientas
CREATE TABLE comparacion_herramientas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    herramienta VARCHAR(100) NOT NULL,
    sgbd_soportado VARCHAR(100),
    tipo VARCHAR(50),
    caracteristicas TEXT,
    precio VARCHAR(50),
    plataforma VARCHAR(100)
);

-- Ejercicio 2: Análisis de Características
CREATE TABLE caracteristicas_herramientas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    herramienta_id INT,
    caracteristica VARCHAR(100),
    disponible BOOLEAN,
    FOREIGN KEY (herramienta_id) REFERENCES comparacion_herramientas(id)
);

-- Ejercicio 3: Configuración de Entornos
CREATE TABLE configuraciones_entorno (
    id INT PRIMARY KEY AUTO_INCREMENT,
    herramienta VARCHAR(100),
    entorno VARCHAR(50),
    host VARCHAR(100),
    puerto INT,
    usuario VARCHAR(50),
    base_datos VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 4: Análisis de Uso
CREATE TABLE uso_herramientas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    herramienta_id INT,
    fecha_uso DATE,
    tiempo_uso_minutos INT,
    operacion VARCHAR(100),
    FOREIGN KEY (herramienta_id) REFERENCES comparacion_herramientas(id)
);

-- Ejercicio 5: Recomendaciones por Escenario
CREATE TABLE recomendaciones_herramientas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    escenario VARCHAR(100),
    herramienta_recomendada VARCHAR(100),
    razon TEXT,
    alternativas VARCHAR(200)
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 7: CARACTERÍSTICAS ESPECÍFICAS POR SGBD
-- =====================================================

-- Ejercicio 1: Comparación de Sintaxis
CREATE TABLE comparacion_sintaxis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    operacion VARCHAR(100) NOT NULL,
    mysql_sintaxis TEXT,
    postgresql_sintaxis TEXT,
    sqlserver_sintaxis TEXT,
    oracle_sintaxis TEXT
);

-- Ejercicio 2: Análisis de Rendimiento
CREATE TABLE rendimiento_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    operacion VARCHAR(100),
    tiempo_ms INT,
    memoria_mb INT,
    concurrencia_usuarios INT,
    fecha_prueba TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 3: Análisis de Características
CREATE TABLE caracteristicas_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    caracteristica VARCHAR(100),
    disponible BOOLEAN,
    version_minima VARCHAR(20),
    descripcion TEXT
);

-- Ejercicio 4: Casos de Uso por SGBD
CREATE TABLE casos_uso_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    caso_uso VARCHAR(100) NOT NULL,
    sgbd_recomendado VARCHAR(50),
    razon TEXT,
    alternativas VARCHAR(200)
);

-- Ejercicio 5: Análisis de Costos
CREATE TABLE costos_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    version VARCHAR(50),
    tipo_licencia VARCHAR(50),
    costo_anual_usd DECIMAL(10,2),
    limite_usuarios INT,
    caracteristicas_incluidas TEXT
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 8: MEJORES PRÁCTICAS DE ADMINISTRACIÓN
-- =====================================================

-- Ejercicio 1: Implementación de Seguridad
CREATE DATABASE seguridad_db;
USE seguridad_db;

CREATE TABLE usuarios_seguridad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL
);

-- Ejercicio 2: Sistema de Backup
CREATE TABLE registro_backups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL') NOT NULL,
    base_datos VARCHAR(100) NOT NULL,
    archivo_backup VARCHAR(255) NOT NULL,
    tamaño_bytes BIGINT,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    estado ENUM('EN_PROGRESO', 'COMPLETADO', 'FALLIDO') DEFAULT 'EN_PROGRESO',
    ubicacion VARCHAR(255)
);

-- Ejercicio 3: Monitoreo de Rendimiento
CREATE TABLE metricas_rendimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metrica VARCHAR(100) NOT NULL,
    valor DECIMAL(15,4),
    unidad VARCHAR(20),
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidor VARCHAR(100) DEFAULT 'localhost'
);

-- Ejercicio 4: Sistema de Alertas
CREATE TABLE alertas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_alerta VARCHAR(50) NOT NULL,
    severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA') NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    fecha_resolucion TIMESTAMP NULL,
    resuelta_por VARCHAR(100)
);

-- Ejercicio 5: Mantenimiento Automatizado
CREATE TABLE tareas_mantenimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tarea VARCHAR(100) NOT NULL,
    descripcion TEXT,
    frecuencia ENUM('DIARIA', 'SEMANAL', 'MENSUAL') NOT NULL,
    ultima_ejecucion TIMESTAMP NULL,
    proxima_ejecucion TIMESTAMP NULL,
    activa BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 9: MIGRACIÓN ENTRE SGBD
-- =====================================================

-- Ejercicio 1: Análisis de Migración
CREATE DATABASE migracion_ejercicios;
USE migracion_ejercicios;

CREATE TABLE inventario_bd_origen (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tabla VARCHAR(100) NOT NULL,
    numero_registros BIGINT,
    tamaño_mb DECIMAL(10,2),
    complejidad ENUM('BAJA', 'MEDIA', 'ALTA') NOT NULL,
    dependencias TEXT,
    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 2: Plan de Migración
CREATE TABLE plan_migracion_detallado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fase VARCHAR(50) NOT NULL,
    tarea VARCHAR(200) NOT NULL,
    tabla_afectada VARCHAR(100),
    tiempo_estimado_horas DECIMAL(4,2),
    recursos_requeridos VARCHAR(200),
    dependencias VARCHAR(200),
    riesgo ENUM('BAJO', 'MEDIO', 'ALTO') NOT NULL,
    fecha_planificada DATE,
    estado ENUM('PENDIENTE', 'EN_PROGRESO', 'COMPLETADO', 'BLOQUEADO') DEFAULT 'PENDIENTE'
);

-- Ejercicio 3: Herramientas de Migración
CREATE TABLE herramientas_migracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('NATIVA', 'TERCEROS', 'OPEN_SOURCE') NOT NULL,
    sgbd_origen VARCHAR(50),
    sgbd_destino VARCHAR(50),
    costo VARCHAR(50),
    facilidad_uso ENUM('BAJA', 'MEDIA', 'ALTA') NOT NULL,
    caracteristicas TEXT
);

-- Ejercicio 4: Conversión de Esquemas
CREATE TABLE conversion_esquemas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla_origen VARCHAR(100) NOT NULL,
    sgbd_origen VARCHAR(50) NOT NULL,
    sgbd_destino VARCHAR(50) NOT NULL,
    ddl_origen TEXT NOT NULL,
    ddl_destino TEXT NOT NULL,
    cambios_aplicados TEXT,
    fecha_conversion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 5: Validación de Datos
CREATE TABLE validaciones_datos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(100) NOT NULL,
    tipo_validacion VARCHAR(100) NOT NULL,
    valor_esperado VARCHAR(200),
    valor_actual VARCHAR(200),
    resultado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA') NOT NULL,
    fecha_validacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 10: PROYECTO INTEGRADOR
-- =====================================================

-- Ejercicio 1: Implementación del Sistema Base
CREATE DATABASE sistema_multi_sgbd;
USE sistema_multi_sgbd;

CREATE TABLE configuracion_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sgbd_activo ENUM('MySQL', 'PostgreSQL', 'SQL Server', 'Oracle') NOT NULL,
    version_sgbd VARCHAR(50),
    configuracion JSON,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 2: Módulo de Usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol ENUM('ADMIN', 'GERENTE', 'EMPLEADO', 'CLIENTE') NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL
);

-- Ejercicio 3: Módulo de Productos
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria_padre_id INT NULL,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_padre_id) REFERENCES categorias(id)
);

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    categoria_id INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Ejercicio 4: Módulo de Ventas
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_cliente VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_venta VARCHAR(50) UNIQUE NOT NULL,
    cliente_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    impuestos DECIMAL(10,2) DEFAULT 0,
    descuento DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('PENDIENTE', 'CONFIRMADA', 'ENVIADA', 'ENTREGADA', 'CANCELADA') DEFAULT 'PENDIENTE',
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (vendedor_id) REFERENCES usuarios(id)
);

-- Ejercicio 5: Sistema de Monitoreo
CREATE TABLE metricas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    metrica VARCHAR(100) NOT NULL,
    valor DECIMAL(15,4),
    unidad VARCHAR(20),
    categoria VARCHAR(50),
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE alertas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_alerta VARCHAR(50) NOT NULL,
    severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    datos_adicionales JSON,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    fecha_resolucion TIMESTAMP NULL,
    resuelta_por VARCHAR(100)
);

-- =====================================================
-- CONSULTAS DE ANÁLISIS Y REPORTES
-- =====================================================

-- Análisis de rendimiento por SGBD
SELECT 
    sgbd,
    operacion,
    AVG(tiempo_ms) as tiempo_promedio_ms,
    AVG(memoria_mb) as memoria_promedio_mb
FROM rendimiento_sgbd 
GROUP BY sgbd, operacion
ORDER BY sgbd, operacion;

-- Dashboard de administración
SELECT 
    'Usuarios Activos' as metrica,
    (SELECT COUNT(*) FROM usuarios WHERE activo = TRUE) as valor_actual,
    'usuarios' as unidad
UNION ALL
SELECT 
    'Productos Activos',
    (SELECT COUNT(*) FROM productos WHERE activo = TRUE),
    'productos'
UNION ALL
SELECT 
    'Ventas Hoy',
    (SELECT COUNT(*) FROM ventas WHERE DATE(fecha_venta) = CURDATE()),
    'ventas';

-- Análisis de costos por SGBD
SELECT 
    sgbd,
    MIN(costo_anual_usd) as costo_minimo,
    MAX(costo_anual_usd) as costo_maximo,
    AVG(costo_anual_usd) as costo_promedio
FROM costos_sgbd 
GROUP BY sgbd;

-- Reporte de migración
SELECT 
    sgbd_origen,
    sgbd_destino,
    tipo_script,
    COUNT(*) as cantidad_scripts
FROM scripts_migracion
GROUP BY sgbd_origen, sgbd_destino, tipo_script
ORDER BY sgbd_origen, sgbd_destino;

-- Análisis de herramientas
SELECT 
    herramienta,
    sgbd_soportado,
    tipo,
    precio,
    facilidad_uso
FROM comparacion_herramientas
ORDER BY facilidad_uso DESC, herramienta;
