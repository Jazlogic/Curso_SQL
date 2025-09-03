# Clase 9: Migración entre SGBD

## Objetivos de la Clase
- Entender los procesos de migración entre diferentes SGBD
- Conocer las herramientas disponibles para migración
- Aprender a planificar y ejecutar migraciones
- Identificar desafíos y soluciones comunes
- Implementar estrategias de validación post-migración

## Introducción a la Migración de SGBD

La **migración de SGBD** es el proceso de transferir datos, esquemas y aplicaciones de un sistema de gestión de bases de datos a otro, manteniendo la integridad y funcionalidad de los datos.

### Tipos de migración:
- **Migración de datos**: Transferencia de datos entre sistemas
- **Migración de esquema**: Conversión de estructuras de base de datos
- **Migración de aplicaciones**: Adaptación de código de aplicación
- **Migración completa**: Migración integral de todo el sistema

## Planificación de Migración

### 1. Análisis de Requerimientos

#### Evaluación del Sistema Actual
```sql
-- Crear tabla de análisis del sistema actual
CREATE TABLE analisis_sistema_actual (
    id INT AUTO_INCREMENT PRIMARY KEY,
    componente VARCHAR(100) NOT NULL,
    tipo VARCHAR(50),
    complejidad ENUM('BAJA', 'MEDIA', 'ALTA') NOT NULL,
    dependencias TEXT,
    observaciones TEXT,
    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar análisis de componentes
INSERT INTO analisis_sistema_actual (componente, tipo, complejidad, dependencias, observaciones) VALUES
('Base de Datos Principal', 'DATABASE', 'ALTA', 'Aplicaciones web, reportes', 'Contiene datos críticos de producción'),
('Sistema de Reportes', 'APPLICATION', 'MEDIA', 'Base de datos principal', 'Usa consultas complejas'),
('Aplicación Web', 'APPLICATION', 'ALTA', 'Base de datos principal', 'Múltiples conexiones simultáneas'),
('Procedimientos Almacenados', 'STORED_PROCEDURES', 'ALTA', 'Base de datos principal', 'Lógica de negocio crítica');
```

### 2. Evaluación de Compatibilidad

#### Matriz de Compatibilidad
```sql
-- Crear tabla de compatibilidad
CREATE TABLE matriz_compatibilidad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sgbd_origen VARCHAR(50) NOT NULL,
    sgbd_destino VARCHAR(50) NOT NULL,
    caracteristica VARCHAR(100) NOT NULL,
    compatibilidad ENUM('COMPATIBLE', 'PARCIAL', 'NO_COMPATIBLE') NOT NULL,
    solucion_alternativa TEXT,
    esfuerzo_migracion ENUM('BAJO', 'MEDIO', 'ALTO') NOT NULL
);

-- Insertar matriz de compatibilidad
INSERT INTO matriz_compatibilidad (sgbd_origen, sgbd_destino, caracteristica, compatibilidad, solucion_alternativa, esfuerzo_migracion) VALUES
('MySQL', 'PostgreSQL', 'AUTO_INCREMENT', 'NO_COMPATIBLE', 'Usar SERIAL o SEQUENCE', 'MEDIO'),
('MySQL', 'PostgreSQL', 'ENUM', 'PARCIAL', 'Usar CHECK constraints', 'BAJO'),
('MySQL', 'PostgreSQL', 'JSON', 'COMPATIBLE', 'Sintaxis similar', 'BAJO'),
('MySQL', 'SQL Server', 'AUTO_INCREMENT', 'NO_COMPATIBLE', 'Usar IDENTITY', 'MEDIO'),
('MySQL', 'SQL Server', 'LIMIT', 'NO_COMPATIBLE', 'Usar TOP o OFFSET/FETCH', 'BAJO'),
('PostgreSQL', 'MySQL', 'SERIAL', 'NO_COMPATIBLE', 'Usar AUTO_INCREMENT', 'MEDIO'),
('PostgreSQL', 'MySQL', 'ARRAY', 'NO_COMPATIBLE', 'Usar tabla separada', 'ALTO');
```

## Herramientas de Migración

### 1. Herramientas Específicas por SGBD

#### MySQL Workbench Migration Wizard
```sql
-- Configuración para migración desde MySQL
-- 1. Conectar a base de datos origen
-- 2. Seleccionar esquemas a migrar
-- 3. Mapear tipos de datos
-- 4. Configurar opciones de migración
-- 5. Ejecutar migración

-- Ejemplo de mapeo de tipos de datos
CREATE TABLE mapeo_tipos_datos (
    tipo_mysql VARCHAR(50),
    tipo_postgresql VARCHAR(50),
    tipo_sqlserver VARCHAR(50),
    tipo_oracle VARCHAR(50),
    observaciones TEXT
);

INSERT INTO mapeo_tipos_datos VALUES
('INT', 'INTEGER', 'INT', 'NUMBER(10)', 'Tipos enteros básicos'),
('VARCHAR(255)', 'VARCHAR(255)', 'NVARCHAR(255)', 'VARCHAR2(255)', 'Cadenas de texto'),
('TEXT', 'TEXT', 'NTEXT', 'CLOB', 'Texto largo'),
('DATETIME', 'TIMESTAMP', 'DATETIME2', 'TIMESTAMP', 'Fechas y horas'),
('DECIMAL(10,2)', 'DECIMAL(10,2)', 'DECIMAL(10,2)', 'NUMBER(10,2)', 'Números decimales');
```

#### pgLoader (PostgreSQL)
```bash
# Migración desde MySQL a PostgreSQL
pgloader mysql://user:password@localhost/source_db postgresql://user:password@localhost/target_db

# Archivo de configuración pgloader
LOAD DATABASE
    FROM mysql://user:password@localhost/source_db
    INTO postgresql://user:password@localhost/target_db

WITH include drop, create tables, create indexes, reset sequences

SET work_mem to '256MB',
    maintenance_work_mem to '512 MB';
```

### 2. Herramientas Multiplataforma

#### DBeaver
```sql
-- Proceso de migración con DBeaver
-- 1. Conectar a base de datos origen
-- 2. Exportar esquema y datos
-- 3. Conectar a base de datos destino
-- 4. Importar y adaptar esquema
-- 5. Importar datos

-- Script de exportación
CREATE TABLE scripts_migracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_script ENUM('SCHEMA', 'DATA', 'INDEXES', 'CONSTRAINTS') NOT NULL,
    contenido TEXT NOT NULL,
    orden_ejecucion INT,
    sgbd_destino VARCHAR(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Estrategias de Migración

### 1. Migración Big Bang

#### Características
- Migración completa en una sola ventana de mantenimiento
- Tiempo de inactividad total durante la migración
- Riesgo alto pero proceso más simple

#### Implementación
```sql
-- Crear tabla de plan de migración big bang
CREATE TABLE plan_migracion_bigbang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paso INT NOT NULL,
    descripcion TEXT NOT NULL,
    tiempo_estimado_minutos INT,
    dependencias VARCHAR(200),
    responsable VARCHAR(100),
    completado BOOLEAN DEFAULT FALSE
);

-- Insertar pasos del plan
INSERT INTO plan_migracion_bigbang (paso, descripcion, tiempo_estimado_minutos, dependencias, responsable) VALUES
(1, 'Backup completo de base de datos origen', 60, NULL, 'DBA Team'),
(2, 'Detener aplicaciones', 15, '1', 'DevOps Team'),
(3, 'Exportar esquema', 30, '2', 'DBA Team'),
(4, 'Convertir esquema para SGBD destino', 120, '3', 'DBA Team'),
(5, 'Crear base de datos destino', 15, '4', 'DBA Team'),
(6, 'Importar esquema', 45, '5', 'DBA Team'),
(7, 'Exportar datos', 180, '6', 'DBA Team'),
(8, 'Importar datos', 240, '7', 'DBA Team'),
(9, 'Verificar integridad', 60, '8', 'QA Team'),
(10, 'Reiniciar aplicaciones', 30, '9', 'DevOps Team');
```

### 2. Migración Gradual

#### Características
- Migración por módulos o tablas
- Tiempo de inactividad mínimo
- Mayor complejidad pero menor riesgo

#### Implementación
```sql
-- Crear tabla de plan de migración gradual
CREATE TABLE plan_migracion_gradual (
    id INT AUTO_INCREMENT PRIMARY KEY,
    modulo VARCHAR(100) NOT NULL,
    tabla VARCHAR(100),
    prioridad ENUM('ALTA', 'MEDIA', 'BAJA') NOT NULL,
    dependencias VARCHAR(200),
    fecha_migracion DATE,
    estado ENUM('PENDIENTE', 'EN_PROGRESO', 'COMPLETADO', 'FALLIDO') DEFAULT 'PENDIENTE',
    observaciones TEXT
);

-- Insertar módulos para migración
INSERT INTO plan_migracion_gradual (modulo, tabla, prioridad, dependencias, fecha_migracion) VALUES
('Usuarios', 'usuarios', 'ALTA', NULL, '2024-02-01'),
('Productos', 'productos', 'ALTA', NULL, '2024-02-02'),
('Pedidos', 'pedidos', 'MEDIA', 'usuarios,productos', '2024-02-05'),
('Inventario', 'inventario', 'MEDIA', 'productos', '2024-02-06'),
('Reportes', 'vista_ventas', 'BAJA', 'pedidos,inventario', '2024-02-10');
```

### 3. Migración con Replicación

#### Características
- Sincronización en tiempo real
- Migración sin tiempo de inactividad
- Mayor complejidad técnica

#### Implementación
```sql
-- Crear tabla de configuración de replicación
CREATE TABLE configuracion_replicacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(100) NOT NULL,
    sgbd_origen VARCHAR(50) NOT NULL,
    sgbd_destino VARCHAR(50) NOT NULL,
    metodo_replicacion ENUM('TRIGGER', 'LOG_BASED', 'APPLICATION') NOT NULL,
    estado ENUM('ACTIVA', 'PAUSADA', 'DETENIDA') DEFAULT 'ACTIVA',
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuraciones de replicación
INSERT INTO configuracion_replicacion (tabla, sgbd_origen, sgbd_destino, metodo_replicacion) VALUES
('usuarios', 'MySQL', 'PostgreSQL', 'TRIGGER'),
('productos', 'MySQL', 'PostgreSQL', 'TRIGGER'),
('pedidos', 'MySQL', 'PostgreSQL', 'LOG_BASED');
```

## Conversión de Esquemas

### 1. Conversión de Tipos de Datos

#### Script de Conversión MySQL a PostgreSQL
```sql
-- Crear tabla de conversión de tipos
CREATE TABLE conversion_tipos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_origen VARCHAR(50) NOT NULL,
    tipo_destino VARCHAR(50) NOT NULL,
    regla_conversion TEXT NOT NULL,
    ejemplo_origen TEXT,
    ejemplo_destino TEXT
);

-- Insertar reglas de conversión
INSERT INTO conversion_tipos (tipo_origen, tipo_destino, regla_conversion, ejemplo_origen, ejemplo_destino) VALUES
('AUTO_INCREMENT', 'SERIAL', 'Reemplazar AUTO_INCREMENT con SERIAL', 'id INT AUTO_INCREMENT PRIMARY KEY', 'id SERIAL PRIMARY KEY'),
('ENUM', 'CHECK', 'Convertir ENUM a CHECK constraint', 'status ENUM("activo","inactivo")', 'status VARCHAR(20) CHECK (status IN ("activo","inactivo"))'),
('DATETIME', 'TIMESTAMP', 'DATETIME se convierte a TIMESTAMP', 'fecha DATETIME', 'fecha TIMESTAMP'),
('TEXT', 'TEXT', 'TEXT es compatible', 'descripcion TEXT', 'descripcion TEXT');
```

### 2. Conversión de Funciones y Procedimientos

#### Conversión de Funciones MySQL a PostgreSQL
```sql
-- Función MySQL original
DELIMITER //
CREATE FUNCTION calcular_total(cantidad INT, precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SET total = cantidad * precio;
    RETURN total;
END //
DELIMITER ;

-- Función PostgreSQL convertida
CREATE OR REPLACE FUNCTION calcular_total(cantidad INTEGER, precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    total := cantidad * precio;
    RETURN total;
END;
$$;
```

## Validación Post-Migración

### 1. Verificación de Integridad

#### Script de Validación
```sql
-- Crear tabla de validaciones
CREATE TABLE validaciones_migracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_validacion VARCHAR(100) NOT NULL,
    tabla VARCHAR(100),
    resultado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA') NOT NULL,
    detalles TEXT,
    fecha_validacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para validar conteo de registros
DELIMITER //
CREATE PROCEDURE validar_conteo_registros(
    IN p_tabla VARCHAR(100),
    IN p_conteo_esperado INT
)
BEGIN
    DECLARE v_conteo_actual INT;
    DECLARE v_resultado ENUM('EXITOSO', 'FALLIDO');
    
    -- Obtener conteo actual
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', p_tabla);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET v_conteo_actual = @count;
    
    -- Determinar resultado
    IF v_conteo_actual = p_conteo_esperado THEN
        SET v_resultado = 'EXITOSO';
    ELSE
        SET v_resultado = 'FALLIDO';
    END IF;
    
    -- Registrar validación
    INSERT INTO validaciones_migracion (tipo_validacion, tabla, resultado, detalles)
    VALUES ('CONTEO_REGISTROS', p_tabla, v_resultado, 
            CONCAT('Esperado: ', p_conteo_esperado, ', Actual: ', v_conteo_actual));
END //
DELIMITER ;
```

### 2. Pruebas de Funcionalidad

#### Script de Pruebas
```sql
-- Crear tabla de pruebas
CREATE TABLE pruebas_funcionalidad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_prueba VARCHAR(100) NOT NULL,
    descripcion TEXT,
    resultado ENUM('PASO', 'FALLO', 'ERROR') NOT NULL,
    tiempo_ejecucion_ms INT,
    fecha_prueba TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para ejecutar pruebas
DELIMITER //
CREATE PROCEDURE ejecutar_pruebas_funcionalidad()
BEGIN
    DECLARE v_inicio TIMESTAMP;
    DECLARE v_fin TIMESTAMP;
    DECLARE v_tiempo INT;
    
    -- Prueba 1: Inserción de datos
    SET v_inicio = NOW(3);
    INSERT INTO usuarios (nombre, email) VALUES ('Usuario Prueba', 'prueba@test.com');
    SET v_fin = NOW(3);
    SET v_tiempo = TIMESTAMPDIFF(MICROSECOND, v_inicio, v_fin) / 1000;
    
    INSERT INTO pruebas_funcionalidad (nombre_prueba, descripcion, resultado, tiempo_ejecucion_ms)
    VALUES ('INSERCION_DATOS', 'Prueba de inserción de datos', 'PASO', v_tiempo);
    
    -- Prueba 2: Consulta de datos
    SET v_inicio = NOW(3);
    SELECT COUNT(*) FROM usuarios WHERE email = 'prueba@test.com';
    SET v_fin = NOW(3);
    SET v_tiempo = TIMESTAMPDIFF(MICROSECOND, v_inicio, v_fin) / 1000;
    
    INSERT INTO pruebas_funcionalidad (nombre_prueba, descripcion, resultado, tiempo_ejecucion_ms)
    VALUES ('CONSULTA_DATOS', 'Prueba de consulta de datos', 'PASO', v_tiempo);
    
    -- Limpiar datos de prueba
    DELETE FROM usuarios WHERE email = 'prueba@test.com';
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Análisis de Migración
```sql
-- Crear base de datos para ejercicios de migración
CREATE DATABASE migracion_ejercicios;
USE migracion_ejercicios;

-- Crear tabla de inventario de base de datos origen
CREATE TABLE inventario_bd_origen (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tabla VARCHAR(100) NOT NULL,
    numero_registros BIGINT,
    tamaño_mb DECIMAL(10,2),
    complejidad ENUM('BAJA', 'MEDIA', 'ALTA') NOT NULL,
    dependencias TEXT,
    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar inventario
INSERT INTO inventario_bd_origen (nombre_tabla, numero_registros, tamaño_mb, complejidad, dependencias) VALUES
('usuarios', 10000, 5.2, 'BAJA', NULL),
('productos', 50000, 25.8, 'MEDIA', NULL),
('pedidos', 100000, 45.3, 'ALTA', 'usuarios,productos'),
('detalles_pedido', 500000, 120.5, 'ALTA', 'pedidos,productos'),
('categorias', 1000, 0.8, 'BAJA', NULL);
```

### Ejercicio 2: Plan de Migración
```sql
-- Crear tabla de plan de migración
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

-- Insertar plan detallado
INSERT INTO plan_migracion_detallado (fase, tarea, tabla_afectada, tiempo_estimado_horas, recursos_requeridos, dependencias, riesgo, fecha_planificada) VALUES
('PREPARACION', 'Análisis de esquema', NULL, 8.0, 'DBA Senior', NULL, 'BAJO', '2024-01-15'),
('PREPARACION', 'Backup completo', NULL, 4.0, 'DBA, Storage', NULL, 'BAJO', '2024-01-16'),
('CONVERSION', 'Convertir esquema usuarios', 'usuarios', 2.0, 'DBA', 'Análisis de esquema', 'BAJO', '2024-01-17'),
('CONVERSION', 'Convertir esquema productos', 'productos', 3.0, 'DBA', 'Análisis de esquema', 'MEDIO', '2024-01-18'),
('MIGRACION', 'Migrar datos usuarios', 'usuarios', 1.0, 'DBA', 'Convertir esquema usuarios', 'BAJO', '2024-01-19'),
('MIGRACION', 'Migrar datos productos', 'productos', 2.0, 'DBA', 'Convertir esquema productos', 'MEDIO', '2024-01-20'),
('VALIDACION', 'Pruebas de integridad', NULL, 4.0, 'QA, DBA', 'Migrar datos productos', 'MEDIO', '2024-01-21');
```

### Ejercicio 3: Herramientas de Migración
```sql
-- Crear tabla de herramientas de migración
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

-- Insertar herramientas
INSERT INTO herramientas_migracion (nombre, tipo, sgbd_origen, sgbd_destino, costo, facilidad_uso, caracteristicas) VALUES
('MySQL Workbench', 'NATIVA', 'MySQL', 'PostgreSQL', 'Gratuita', 'ALTA', 'Wizard de migración, conversión automática'),
('pgLoader', 'OPEN_SOURCE', 'MySQL', 'PostgreSQL', 'Gratuita', 'MEDIA', 'Migración directa, alta velocidad'),
('DBeaver', 'TERCEROS', 'Universal', 'Universal', 'Gratuita/Comercial', 'ALTA', 'Interfaz gráfica, múltiples SGBD'),
('AWS DMS', 'TERCEROS', 'Universal', 'Universal', 'Pago por uso', 'ALTA', 'Migración en la nube, replicación'),
('Oracle SQL Developer', 'NATIVA', 'Oracle', 'Universal', 'Gratuita', 'MEDIA', 'Herramienta oficial Oracle');
```

### Ejercicio 4: Conversión de Esquemas
```sql
-- Crear tabla de conversión de esquemas
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

-- Ejemplo de conversión
INSERT INTO conversion_esquemas (tabla_origen, sgbd_origen, sgbd_destino, ddl_origen, ddl_destino, cambios_aplicados) VALUES
('usuarios', 'MySQL', 'PostgreSQL', 
 'CREATE TABLE usuarios (id INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(100), email VARCHAR(255) UNIQUE, fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP)',
 'CREATE TABLE usuarios (id SERIAL PRIMARY KEY, nombre VARCHAR(100), email VARCHAR(255) UNIQUE, fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP)',
 'AUTO_INCREMENT -> SERIAL, DATETIME -> TIMESTAMP');

-- Procedimiento para generar DDL convertido
DELIMITER //
CREATE PROCEDURE convertir_ddl(
    IN p_ddl_origen TEXT,
    IN p_sgbd_destino VARCHAR(50)
)
BEGIN
    DECLARE v_ddl_convertido TEXT;
    
    SET v_ddl_convertido = p_ddl_origen;
    
    -- Aplicar conversiones según SGBD destino
    CASE p_sgbd_destino
        WHEN 'PostgreSQL' THEN
            SET v_ddl_convertido = REPLACE(v_ddl_convertido, 'AUTO_INCREMENT', 'SERIAL');
            SET v_ddl_convertido = REPLACE(v_ddl_convertido, 'DATETIME', 'TIMESTAMP');
            SET v_ddl_convertido = REPLACE(v_ddl_convertido, 'ENGINE=InnoDB', '');
        WHEN 'SQL Server' THEN
            SET v_ddl_convertido = REPLACE(v_ddl_convertido, 'AUTO_INCREMENT', 'IDENTITY(1,1)');
            SET v_ddl_convertido = REPLACE(v_ddl_convertido, 'DATETIME', 'DATETIME2');
    END CASE;
    
    SELECT v_ddl_convertido as ddl_convertido;
END //
DELIMITER ;
```

### Ejercicio 5: Validación de Datos
```sql
-- Crear tabla de validaciones
CREATE TABLE validaciones_datos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(100) NOT NULL,
    tipo_validacion VARCHAR(100) NOT NULL,
    valor_esperado VARCHAR(200),
    valor_actual VARCHAR(200),
    resultado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA') NOT NULL,
    fecha_validacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para validar integridad referencial
DELIMITER //
CREATE PROCEDURE validar_integridad_referencial()
BEGIN
    DECLARE v_huérfanos INT;
    
    -- Validar pedidos sin usuario válido
    SELECT COUNT(*) INTO v_huérfanos
    FROM pedidos p
    LEFT JOIN usuarios u ON p.usuario_id = u.id
    WHERE u.id IS NULL;
    
    INSERT INTO validaciones_datos (tabla, tipo_validacion, valor_esperado, valor_actual, resultado)
    VALUES ('pedidos', 'INTEGRIDAD_REFERENCIAL', '0', v_huérfanos, 
            CASE WHEN v_huérfanos = 0 THEN 'EXITOSO' ELSE 'FALLIDO' END);
    
    -- Validar detalles de pedido sin pedido válido
    SELECT COUNT(*) INTO v_huérfanos
    FROM detalles_pedido dp
    LEFT JOIN pedidos p ON dp.pedido_id = p.id
    WHERE p.id IS NULL;
    
    INSERT INTO validaciones_datos (tabla, tipo_validacion, valor_esperado, valor_actual, resultado)
    VALUES ('detalles_pedido', 'INTEGRIDAD_REFERENCIAL', '0', v_huérfanos,
            CASE WHEN v_huérfanos = 0 THEN 'EXITOSO' ELSE 'FALLIDO' END);
END //
DELIMITER ;
```

### Ejercicio 6: Monitoreo de Migración
```sql
-- Crear tabla de monitoreo
CREATE TABLE monitoreo_migracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fase VARCHAR(50) NOT NULL,
    progreso_porcentaje DECIMAL(5,2) NOT NULL,
    registros_procesados BIGINT,
    registros_totales BIGINT,
    velocidad_registros_por_segundo DECIMAL(10,2),
    tiempo_restante_estimado_minutos INT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para actualizar progreso
DELIMITER //
CREATE PROCEDURE actualizar_progreso_migracion(
    IN p_fase VARCHAR(50),
    IN p_registros_procesados BIGINT,
    IN p_registros_totales BIGINT
)
BEGIN
    DECLARE v_progreso DECIMAL(5,2);
    DECLARE v_velocidad DECIMAL(10,2);
    DECLARE v_tiempo_restante INT;
    
    -- Calcular progreso
    SET v_progreso = (p_registros_procesados * 100.0) / p_registros_totales;
    
    -- Calcular velocidad (simplificado)
    SET v_velocidad = p_registros_procesados / 60.0; -- registros por segundo
    
    -- Calcular tiempo restante
    IF v_velocidad > 0 THEN
        SET v_tiempo_restante = (p_registros_totales - p_registros_procesados) / (v_velocidad * 60);
    ELSE
        SET v_tiempo_restante = 0;
    END IF;
    
    -- Insertar o actualizar registro
    INSERT INTO monitoreo_migracion (fase, progreso_porcentaje, registros_procesados, registros_totales, velocidad_registros_por_segundo, tiempo_restante_estimado_minutos)
    VALUES (p_fase, v_progreso, p_registros_procesados, p_registros_totales, v_velocidad, v_tiempo_restante)
    ON DUPLICATE KEY UPDATE
        progreso_porcentaje = v_progreso,
        registros_procesados = p_registros_procesados,
        velocidad_registros_por_segundo = v_velocidad,
        tiempo_restante_estimado_minutos = v_tiempo_restante,
        fecha_actualizacion = CURRENT_TIMESTAMP;
END //
DELIMITER ;
```

### Ejercicio 7: Rollback Plan
```sql
-- Crear tabla de plan de rollback
CREATE TABLE plan_rollback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    escenario VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    pasos TEXT NOT NULL,
    tiempo_estimado_minutos INT,
    recursos_requeridos VARCHAR(200),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar escenarios de rollback
INSERT INTO plan_rollback (escenario, descripcion, pasos, tiempo_estimado_minutos, recursos_requeridos) VALUES
('FALLO_MIGRACION_DATOS', 'Falló la migración de datos principales',
 '1. Detener aplicaciones\n2. Restaurar backup de origen\n3. Verificar integridad\n4. Reiniciar aplicaciones',
 120, 'DBA Team, DevOps Team'),
('FALLO_CONVERSION_ESQUEMA', 'Falló la conversión del esquema',
 '1. Detener aplicaciones\n2. Eliminar esquema destino\n3. Recrear esquema origen\n4. Restaurar datos\n5. Reiniciar aplicaciones',
 180, 'DBA Team, DevOps Team'),
('PROBLEMAS_RENDIMIENTO', 'Problemas de rendimiento post-migración',
 '1. Analizar consultas lentas\n2. Optimizar índices\n3. Ajustar configuración\n4. Monitorear mejoras',
 240, 'DBA Team, Performance Team');
```

### Ejercicio 8: Análisis de Riesgos
```sql
-- Crear tabla de análisis de riesgos
CREATE TABLE analisis_riesgos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    riesgo VARCHAR(100) NOT NULL,
    probabilidad ENUM('BAJA', 'MEDIA', 'ALTA') NOT NULL,
    impacto ENUM('BAJO', 'MEDIO', 'ALTO') NOT NULL,
    mitigacion TEXT,
    plan_contingencia TEXT,
    responsable VARCHAR(100)
);

-- Insertar riesgos identificados
INSERT INTO analisis_riesgos (riesgo, probabilidad, impacto, mitigacion, plan_contingencia, responsable) VALUES
('Pérdida de datos', 'BAJA', 'ALTO', 'Backups completos y validación', 'Restaurar desde backup', 'DBA Team'),
('Tiempo de inactividad excesivo', 'MEDIA', 'ALTO', 'Migración gradual, pruebas previas', 'Rollback plan', 'DevOps Team'),
('Problemas de rendimiento', 'ALTA', 'MEDIO', 'Optimización previa, monitoreo', 'Ajustes de configuración', 'Performance Team'),
('Incompatibilidad de aplicaciones', 'MEDIA', 'ALTO', 'Pruebas exhaustivas', 'Adaptación de código', 'Development Team');
```

### Ejercicio 9: Reporte de Migración
```sql
-- Crear vista de reporte de migración
CREATE VIEW reporte_migracion AS
SELECT 
    'Progreso General' as seccion,
    CONCAT(ROUND(AVG(progreso_porcentaje), 2), '%') as valor,
    'Progreso promedio de todas las fases' as descripcion
FROM monitoreo_migracion
UNION ALL
SELECT 
    'Tareas Completadas',
    CONCAT(COUNT(*), ' de ', (SELECT COUNT(*) FROM plan_migracion_detallado)) as valor,
    'Tareas completadas del plan total'
FROM plan_migracion_detallado 
WHERE estado = 'COMPLETADO'
UNION ALL
SELECT 
    'Validaciones Exitosas',
    CONCAT(COUNT(*), ' de ', (SELECT COUNT(*) FROM validaciones_datos)) as valor,
    'Validaciones exitosas del total'
FROM validaciones_datos 
WHERE resultado = 'EXITOSO';

-- Consultar reporte
SELECT * FROM reporte_migracion;
```

### Ejercicio 10: Dashboard de Migración
```sql
-- Crear procedimiento para dashboard
DELIMITER //
CREATE PROCEDURE dashboard_migracion()
BEGIN
    SELECT '=== DASHBOARD DE MIGRACIÓN ===' as titulo;
    
    -- Estado general
    SELECT 'Estado General' as seccion;
    SELECT 
        fase,
        CONCAT(ROUND(progreso_porcentaje, 2), '%') as progreso,
        CONCAT(FORMAT(registros_procesados, 0), ' / ', FORMAT(registros_totales, 0)) as registros,
        CONCAT(tiempo_restante_estimado_minutos, ' min') as tiempo_restante
    FROM monitoreo_migracion
    ORDER BY fecha_actualizacion DESC
    LIMIT 1;
    
    -- Tareas pendientes
    SELECT 'Tareas Pendientes' as seccion;
    SELECT 
        tarea,
        tabla_afectada,
        fecha_planificada,
        riesgo
    FROM plan_migracion_detallado
    WHERE estado = 'PENDIENTE'
    ORDER BY fecha_planificada;
    
    -- Validaciones recientes
    SELECT 'Validaciones Recientes' as seccion;
    SELECT 
        tabla,
        tipo_validacion,
        resultado,
        fecha_validacion
    FROM validaciones_datos
    ORDER BY fecha_validacion DESC
    LIMIT 5;
END //
DELIMITER ;

-- Ejecutar dashboard
CALL dashboard_migracion();
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Procesos de planificación de migración entre SGBD
- Herramientas disponibles para migración
- Estrategias de migración (Big Bang, Gradual, con Replicación)
- Conversión de esquemas y tipos de datos
- Validación y pruebas post-migración
- Análisis de riesgos y planes de rollback
- Monitoreo y reportes de migración

## Próxima Clase
[Clase 10: Proyecto Integrador](clase_10_proyecto_integrador.md)

## Recursos Adicionales
- [MySQL Migration Guide](https://dev.mysql.com/doc/mysql-enterprise-migration-guide/en/)
- [PostgreSQL Migration Guide](https://www.postgresql.org/docs/current/migration.html)
- [AWS Database Migration Service](https://aws.amazon.com/dms/)
- [Oracle Migration Tools](https://www.oracle.com/database/technologies/migration.html)
