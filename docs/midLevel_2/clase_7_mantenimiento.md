# Clase 7: Mantenimiento y Tuning - Nivel Mid-Level

## Introducción
El mantenimiento y tuning son esenciales para mantener el rendimiento óptimo de las bases de datos. En esta clase aprenderemos sobre optimización de consultas, mantenimiento de índices y limpieza de datos.

## Conceptos Clave

### Mantenimiento Preventivo
**Definición**: Actividades programadas para prevenir problemas de rendimiento.
**Tareas**:
- Optimización de consultas
- Mantenimiento de índices
- Limpieza de datos
- Actualización de estadísticas

### Tuning de Rendimiento
**Definición**: Proceso de optimizar el rendimiento del sistema.
**Áreas**:
- Optimización de consultas
- Configuración de parámetros
- Gestión de memoria
- Optimización de I/O

### Limpieza de Datos
**Definición**: Proceso de eliminar datos obsoletos o innecesarios.
**Tipos**:
- Limpieza de logs
- Archivo de datos históricos
- Eliminación de duplicados
- Compresión de datos

## Ejemplos Prácticos

### 1. Sistema de Mantenimiento Automático

```sql
-- Crear tabla de tareas de mantenimiento
CREATE TABLE tareas_mantenimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tarea VARCHAR(100),
    descripcion TEXT,
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    activo BOOLEAN DEFAULT TRUE,
    ultima_ejecucion TIMESTAMP NULL,
    proxima_ejecucion TIMESTAMP NULL
);

-- Insertar tareas de mantenimiento
INSERT INTO tareas_mantenimiento (nombre_tarea, descripcion, frecuencia, hora_ejecucion)
VALUES 
('OPTIMIZAR_TABLAS', 'Optimizar todas las tablas', 'SEMANAL', '02:00:00'),
('ANALIZAR_INDICES', 'Analizar y optimizar índices', 'DIARIO', '01:00:00'),
('LIMPIAR_LOGS', 'Limpiar logs antiguos', 'DIARIO', '03:00:00'),
('ACTUALIZAR_ESTADISTICAS', 'Actualizar estadísticas de tablas', 'SEMANAL', '01:30:00');

-- Procedimiento para ejecutar mantenimiento
DELIMITER //
CREATE PROCEDURE ejecutar_mantenimiento()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tarea VARCHAR(100);
    DECLARE v_descripcion TEXT;
    DECLARE v_frecuencia VARCHAR(20);
    DECLARE v_hora TIME;
    
    DECLARE cur CURSOR FOR
        SELECT nombre_tarea, descripcion, frecuencia, hora_ejecucion
        FROM tareas_mantenimiento
        WHERE activo = TRUE
        AND (proxima_ejecucion IS NULL OR proxima_ejecucion <= NOW());
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tarea, v_descripcion, v_frecuencia, v_hora;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Ejecutar tarea según el tipo
        IF v_tarea = 'OPTIMIZAR_TABLAS' THEN
            CALL optimizar_todas_tablas();
        ELSEIF v_tarea = 'ANALIZAR_INDICES' THEN
            CALL analizar_indices();
        ELSEIF v_tarea = 'LIMPIAR_LOGS' THEN
            CALL limpiar_logs_antiguos();
        ELSEIF v_tarea = 'ACTUALIZAR_ESTADISTICAS' THEN
            CALL actualizar_estadisticas();
        END IF;
        
        -- Actualizar próxima ejecución
        UPDATE tareas_mantenimiento 
        SET ultima_ejecucion = NOW(),
            proxima_ejecucion = CASE 
                WHEN frecuencia = 'DIARIO' THEN DATE_ADD(NOW(), INTERVAL 1 DAY)
                WHEN frecuencia = 'SEMANAL' THEN DATE_ADD(NOW(), INTERVAL 1 WEEK)
                WHEN frecuencia = 'MENSUAL' THEN DATE_ADD(NOW(), INTERVAL 1 MONTH)
            END
        WHERE nombre_tarea = v_tarea;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### 2. Optimización de Consultas

```sql
-- Crear tabla de consultas lentas
CREATE TABLE consultas_lentas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    consulta_sql TEXT,
    tiempo_ejecucion_ms INT,
    filas_examinadas INT,
    filas_enviadas INT,
    usuario VARCHAR(100),
    base_datos VARCHAR(100)
);

-- Procedimiento para identificar consultas lentas
DELIMITER //
CREATE PROCEDURE identificar_consultas_lentas()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_consulta TEXT;
    DECLARE v_tiempo INT;
    DECLARE v_filas_examinadas INT;
    DECLARE v_filas_enviadas INT;
    DECLARE v_usuario VARCHAR(100);
    DECLARE v_base_datos VARCHAR(100);
    
    -- Simular identificación de consultas lentas
    -- En implementación real, se consultaría information_schema.processlist
    
    -- Ejemplo de consulta lenta detectada
    INSERT INTO consultas_lentas (consulta_sql, tiempo_ejecucion_ms, filas_examinadas, filas_enviadas, usuario, base_datos)
    VALUES (
        'SELECT * FROM clientes WHERE nombre LIKE "%a%"',
        5000,
        10000,
        100,
        'usuario_consulta',
        'empresa'
    );
    
    -- Generar recomendaciones
    CALL generar_recomendaciones_optimizacion();
END //
DELIMITER ;

-- Procedimiento para generar recomendaciones
DELIMITER //
CREATE PROCEDURE generar_recomendaciones_optimizacion()
BEGIN
    DECLARE v_consulta TEXT;
    DECLARE v_recomendacion TEXT;
    
    -- Obtener consulta más lenta
    SELECT consulta_sql INTO v_consulta
    FROM consultas_lentas
    ORDER BY tiempo_ejecucion_ms DESC
    LIMIT 1;
    
    -- Generar recomendación basada en la consulta
    IF v_consulta LIKE '%LIKE "%a%"%' THEN
        SET v_recomendacion = 'Considerar usar índice de texto completo o reescribir la consulta';
    ELSEIF v_consulta LIKE '%SELECT *%' THEN
        SET v_recomendacion = 'Especificar solo las columnas necesarias en lugar de SELECT *';
    ELSE
        SET v_recomendacion = 'Revisar índices y estructura de la consulta';
    END IF;
    
    -- Insertar recomendación
    INSERT INTO recomendaciones_optimizacion (consulta_id, recomendacion, fecha_generacion)
    VALUES (LAST_INSERT_ID(), v_recomendacion, NOW());
END //
DELIMITER ;
```

### 3. Mantenimiento de Índices

```sql
-- Crear tabla de análisis de índices
CREATE TABLE analisis_indices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    indice VARCHAR(100),
    cardinalidad INT,
    fragmentacion DECIMAL(5,2),
    uso_porcentaje DECIMAL(5,2),
    recomendacion TEXT,
    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para analizar índices
DELIMITER //
CREATE PROCEDURE analizar_indices()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tabla VARCHAR(100);
    DECLARE v_indice VARCHAR(100);
    DECLARE v_cardinalidad INT;
    DECLARE v_fragmentacion DECIMAL(5,2);
    DECLARE v_uso DECIMAL(5,2);
    DECLARE v_recomendacion TEXT;
    
    -- Simular análisis de índices
    -- En implementación real, se consultaría information_schema.statistics
    
    -- Ejemplo de análisis
    INSERT INTO analisis_indices (tabla, indice, cardinalidad, fragmentacion, uso_porcentaje, recomendacion)
    VALUES 
    ('clientes', 'idx_nombre', 1000, 15.5, 85.2, 'Índice en buen estado'),
    ('ventas', 'idx_fecha', 5000, 45.2, 95.8, 'Considerar reconstruir índice por alta fragmentación'),
    ('productos', 'idx_categoria', 50, 5.1, 60.3, 'Índice poco utilizado, considerar eliminar');
    
    -- Ejecutar mantenimiento según recomendaciones
    CALL ejecutar_mantenimiento_indices();
END //
DELIMITER ;

-- Procedimiento para ejecutar mantenimiento de índices
DELIMITER //
CREATE PROCEDURE ejecutar_mantenimiento_indices()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tabla VARCHAR(100);
    DECLARE v_indice VARCHAR(100);
    DECLARE v_fragmentacion DECIMAL(5,2);
    DECLARE v_recomendacion TEXT;
    
    DECLARE cur CURSOR FOR
        SELECT tabla, indice, fragmentacion, recomendacion
        FROM analisis_indices
        WHERE fecha_analisis = (
            SELECT MAX(fecha_analisis) FROM analisis_indices
        );
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tabla, v_indice, v_fragmentacion, v_recomendacion;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Reconstruir índice si fragmentación > 30%
        IF v_fragmentacion > 30 THEN
            SET @sql = CONCAT('ALTER TABLE ', v_tabla, ' REBUILD INDEX ', v_indice);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            -- Registrar acción
            INSERT INTO log_mantenimiento_indices (tabla, indice, accion, fecha_ejecucion)
            VALUES (v_tabla, v_indice, 'REBUILD', NOW());
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Limpieza de Datos Antiguos
```sql
-- Crear tabla de configuración de limpieza
CREATE TABLE configuracion_limpieza (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    columna_fecha VARCHAR(100),
    retencion_dias INT,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración
INSERT INTO configuracion_limpieza (tabla, columna_fecha, retencion_dias)
VALUES 
('logs_sistema', 'fecha_creacion', 30),
('sesiones_usuarios', 'fecha_inicio', 7),
('auditoria', 'fecha_evento', 90);

-- Procedimiento para limpieza automática
DELIMITER //
CREATE PROCEDURE limpiar_datos_antiguos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tabla VARCHAR(100);
    DECLARE v_columna VARCHAR(100);
    DECLARE v_retencion INT;
    DECLARE v_fecha_limite DATE;
    DECLARE v_registros_eliminados INT;
    
    DECLARE cur CURSOR FOR
        SELECT tabla, columna_fecha, retencion_dias
        FROM configuracion_limpieza
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tabla, v_columna, v_retencion;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET v_fecha_limite = DATE_SUB(CURDATE(), INTERVAL v_retencion DAY);
        
        -- Eliminar registros antiguos
        SET @sql = CONCAT('DELETE FROM ', v_tabla, ' WHERE ', v_columna, ' < ''', v_fecha_limite, '''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        SET v_registros_eliminados = ROW_COUNT();
        DEALLOCATE PREPARE stmt;
        
        -- Registrar limpieza
        INSERT INTO log_limpieza_datos (tabla, fecha_limite, registros_eliminados, fecha_limpieza)
        VALUES (v_tabla, v_fecha_limite, v_registros_eliminados, NOW());
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 2: Optimización de Parámetros
```sql
-- Crear tabla de configuración de parámetros
CREATE TABLE configuracion_parametros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parametro VARCHAR(100),
    valor_actual VARCHAR(100),
    valor_recomendado VARCHAR(100),
    descripcion TEXT,
    impacto ENUM('BAJO', 'MEDIO', 'ALTO') DEFAULT 'MEDIO'
);

-- Insertar configuraciones
INSERT INTO configuracion_parametros (parametro, valor_actual, valor_recomendado, descripcion, impacto)
VALUES 
('innodb_buffer_pool_size', '128M', '1G', 'Tamaño del buffer pool de InnoDB', 'ALTO'),
('max_connections', '100', '200', 'Número máximo de conexiones', 'MEDIO'),
('query_cache_size', '0', '64M', 'Tamaño de la caché de consultas', 'MEDIO');

-- Procedimiento para optimizar parámetros
DELIMITER //
CREATE PROCEDURE optimizar_parametros()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_parametro VARCHAR(100);
    DECLARE v_valor_actual VARCHAR(100);
    DECLARE v_valor_recomendado VARCHAR(100);
    DECLARE v_impacto VARCHAR(20);
    
    DECLARE cur CURSOR FOR
        SELECT parametro, valor_actual, valor_recomendado, impacto
        FROM configuracion_parametros
        WHERE valor_actual != valor_recomendado;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_parametro, v_valor_actual, v_valor_recomendado, v_impacto;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Generar recomendación
        INSERT INTO recomendaciones_parametros (parametro, valor_actual, valor_recomendado, impacto, fecha_recomendacion)
        VALUES (v_parametro, v_valor_actual, v_valor_recomendado, v_impacto, NOW());
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 3: Compresión de Datos
```sql
-- Crear tabla de configuración de compresión
CREATE TABLE configuracion_compresion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    comprimir BOOLEAN DEFAULT FALSE,
    algoritmo ENUM('ROW', 'PAGE', 'NONE') DEFAULT 'ROW',
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para comprimir tablas
DELIMITER //
CREATE PROCEDURE comprimir_tablas()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tabla VARCHAR(100);
    DECLARE v_algoritmo VARCHAR(20);
    
    DECLARE cur CURSOR FOR
        SELECT tabla, algoritmo
        FROM configuracion_compresion
        WHERE comprimir = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tabla, v_algoritmo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Aplicar compresión
        SET @sql = CONCAT('ALTER TABLE ', v_tabla, ' ROW_FORMAT=COMPRESSED');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Registrar compresión
        INSERT INTO log_compresion (tabla, algoritmo, fecha_compresion)
        VALUES (v_tabla, v_algoritmo, NOW());
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 4: Actualización de Estadísticas
```sql
-- Crear tabla de estadísticas
CREATE TABLE estadisticas_tablas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    filas_estimadas BIGINT,
    tamaño_mb DECIMAL(10,2),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para actualizar estadísticas
DELIMITER //
CREATE PROCEDURE actualizar_estadisticas()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tabla VARCHAR(100);
    
    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_TYPE = 'BASE TABLE';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tabla;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Actualizar estadísticas
        SET @sql = CONCAT('ANALYZE TABLE ', v_tabla);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Registrar actualización
        INSERT INTO estadisticas_tablas (tabla, fecha_actualizacion)
        VALUES (v_tabla, NOW());
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 5: Sistema de Tuning Automático
```sql
-- Crear tabla de tuning automático
CREATE TABLE tuning_automatico (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metrica VARCHAR(100),
    valor_actual DECIMAL(10,2),
    valor_objetivo DECIMAL(10,2),
    accion_recomendada TEXT,
    ejecutado BOOLEAN DEFAULT FALSE
);

-- Procedimiento para tuning automático
DELIMITER //
CREATE PROCEDURE ejecutar_tuning_automatico()
BEGIN
    DECLARE v_cpu DECIMAL(5,2);
    DECLARE v_memoria DECIMAL(5,2);
    DECLARE v_conexiones INT;
    DECLARE v_qps DECIMAL(10,2);
    
    -- Obtener métricas actuales
    SELECT 
        AVG(cpu_porcentaje),
        AVG(memoria_porcentaje),
        AVG(conexiones_activas),
        AVG(consultas_por_segundo)
    INTO v_cpu, v_memoria, v_conexiones, v_qps
    FROM metricas_sistema
    WHERE fecha_medicion > DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Analizar CPU
    IF v_cpu > 80 THEN
        INSERT INTO tuning_automatico (metrica, valor_actual, valor_objetivo, accion_recomendada)
        VALUES ('CPU', v_cpu, 70.0, 'Optimizar consultas o aumentar recursos');
    END IF;
    
    -- Analizar memoria
    IF v_memoria > 85 THEN
        INSERT INTO tuning_automatico (metrica, valor_actual, valor_objetivo, accion_recomendada)
        VALUES ('MEMORIA', v_memoria, 75.0, 'Aumentar buffer pool o optimizar consultas');
    END IF;
    
    -- Analizar conexiones
    IF v_conexiones > 80 THEN
        INSERT INTO tuning_automatico (metrica, valor_actual, valor_objetivo, accion_recomendada)
        VALUES ('CONEXIONES', v_conexiones, 60.0, 'Revisar conexiones inactivas o aumentar límite');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 6: Mantenimiento de Logs
```sql
-- Crear tabla de configuración de logs
CREATE TABLE configuracion_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_log VARCHAR(100),
    ubicacion VARCHAR(255),
    retencion_dias INT,
    comprimir BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración
INSERT INTO configuracion_logs (tipo_log, ubicacion, retencion_dias, comprimir)
VALUES 
('ERROR_LOG', '/var/log/mysql/error.log', 30, TRUE),
('SLOW_QUERY_LOG', '/var/log/mysql/slow.log', 7, TRUE),
('BINARY_LOG', '/var/log/mysql/binlog', 7, FALSE);

-- Procedimiento para mantenimiento de logs
DELIMITER //
CREATE PROCEDURE mantener_logs()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tipo VARCHAR(100);
    DECLARE v_ubicacion VARCHAR(255);
    DECLARE v_retencion INT;
    DECLARE v_comprimir BOOLEAN;
    
    DECLARE cur CURSOR FOR
        SELECT tipo_log, ubicacion, retencion_dias, comprimir
        FROM configuracion_logs
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tipo, v_ubicacion, v_retencion, v_comprimir;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Simular mantenimiento de logs
        -- En implementación real: rotar, comprimir, eliminar logs antiguos
        
        -- Registrar mantenimiento
        INSERT INTO log_mantenimiento_logs (tipo_log, ubicacion, accion, fecha_mantenimiento)
        VALUES (v_tipo, v_ubicacion, 'ROTACION', NOW());
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 7: Optimización de Consultas Automática
```sql
-- Crear tabla de consultas optimizadas
CREATE TABLE consultas_optimizadas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    consulta_original TEXT,
    consulta_optimizada TEXT,
    mejora_porcentual DECIMAL(5,2),
    fecha_optimizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para optimizar consultas
DELIMITER //
CREATE PROCEDURE optimizar_consultas_automatico()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_consulta_original TEXT;
    DECLARE v_consulta_optimizada TEXT;
    DECLARE v_mejora DECIMAL(5,2);
    
    DECLARE cur CURSOR FOR
        SELECT consulta_sql
        FROM consultas_lentas
        WHERE tiempo_ejecucion_ms > 1000
        ORDER BY tiempo_ejecucion_ms DESC
        LIMIT 10;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_consulta_original;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Simular optimización
        IF v_consulta_original LIKE '%SELECT *%' THEN
            SET v_consulta_optimizada = REPLACE(v_consulta_original, 'SELECT *', 'SELECT id, nombre');
            SET v_mejora = 25.0;
        ELSEIF v_consulta_original LIKE '%LIKE "%a%"%' THEN
            SET v_consulta_optimizada = REPLACE(v_consulta_original, 'LIKE "%a%"', 'LIKE "a%"');
            SET v_mejora = 40.0;
        ELSE
            SET v_consulta_optimizada = v_consulta_original;
            SET v_mejora = 0.0;
        END IF;
        
        -- Registrar optimización
        INSERT INTO consultas_optimizadas (consulta_original, consulta_optimizada, mejora_porcentual)
        VALUES (v_consulta_original, v_consulta_optimizada, v_mejora);
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 8: Sistema de Reportes de Mantenimiento
```sql
-- Crear tabla de reportes de mantenimiento
CREATE TABLE reportes_mantenimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_reporte VARCHAR(100),
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    periodo_inicio DATETIME,
    periodo_fin DATETIME,
    archivo_reporte VARCHAR(255),
    estado ENUM('GENERANDO', 'COMPLETADO', 'ERROR') DEFAULT 'GENERANDO'
);

-- Procedimiento para generar reporte de mantenimiento
DELIMITER //
CREATE PROCEDURE generar_reporte_mantenimiento()
BEGIN
    DECLARE v_archivo VARCHAR(255);
    DECLARE v_fecha_inicio DATETIME;
    DECLARE v_fecha_fin DATETIME;
    
    SET v_fecha_inicio = DATE_SUB(CURDATE(), INTERVAL 1 WEEK);
    SET v_fecha_fin = CURDATE();
    SET v_archivo = CONCAT('/reportes/mantenimiento_', DATE_FORMAT(v_fecha_inicio, '%Y%m%d'), '.pdf');
    
    -- Registrar inicio del reporte
    INSERT INTO reportes_mantenimiento (tipo_reporte, periodo_inicio, periodo_fin, archivo_reporte)
    VALUES ('REPORTE_MANTENIMIENTO', v_fecha_inicio, v_fecha_fin, v_archivo);
    
    -- Simular generación del reporte
    -- En implementación real: generar PDF con estadísticas de mantenimiento
    
    -- Marcar como completado
    UPDATE reportes_mantenimiento 
    SET estado = 'COMPLETADO'
    WHERE archivo_reporte = v_archivo;
END //
DELIMITER ;
```

### Ejercicio 9: Monitoreo de Mantenimiento
```sql
-- Crear tabla de monitoreo de mantenimiento
CREATE TABLE monitoreo_mantenimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tarea VARCHAR(100),
    fecha_ejecucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duracion_segundos INT,
    estado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA') DEFAULT 'EXITOSO',
    registros_afectados INT,
    observaciones TEXT
);

-- Procedimiento para monitorear mantenimiento
DELIMITER //
CREATE PROCEDURE monitorear_mantenimiento()
BEGIN
    DECLARE v_tareas_ejecutadas INT;
    DECLARE v_tareas_fallidas INT;
    DECLARE v_tiempo_promedio INT;
    
    -- Contar tareas ejecutadas
    SELECT COUNT(*) INTO v_tareas_ejecutadas
    FROM monitoreo_mantenimiento
    WHERE DATE(fecha_ejecucion) = CURDATE();
    
    -- Contar tareas fallidas
    SELECT COUNT(*) INTO v_tareas_fallidas
    FROM monitoreo_mantenimiento
    WHERE DATE(fecha_ejecucion) = CURDATE()
    AND estado = 'FALLIDO';
    
    -- Calcular tiempo promedio
    SELECT AVG(duracion_segundos) INTO v_tiempo_promedio
    FROM monitoreo_mantenimiento
    WHERE DATE(fecha_ejecucion) = CURDATE();
    
    -- Generar alertas si es necesario
    IF v_tareas_fallidas > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, descripcion, nivel_critico)
        VALUES ('MANTENIMIENTO_FALLIDO', CONCAT('Se detectaron ', v_tareas_fallidas, ' tareas de mantenimiento fallidas'), 'ALTO');
    END IF;
    
    IF v_tiempo_promedio > 3600 THEN -- Más de 1 hora
        INSERT INTO alertas_sistema (tipo_alerta, descripcion, nivel_critico)
        VALUES ('MANTENIMIENTO_LENTO', CONCAT('Tiempo promedio de mantenimiento: ', v_tiempo_promedio, ' segundos'), 'MEDIO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Mantenimiento
```sql
-- Crear tabla de configuración completa
CREATE TABLE configuracion_mantenimiento_completo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    tarea VARCHAR(100),
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    activo BOOLEAN DEFAULT TRUE,
    configuracion JSON
);

-- Insertar configuración completa
INSERT INTO configuracion_mantenimiento_completo (componente, tarea, frecuencia, hora_ejecucion, configuracion)
VALUES 
('SISTEMA', 'OPTIMIZAR_TABLAS', 'SEMANAL', '02:00:00', 
 JSON_OBJECT('tablas', JSON_ARRAY('clientes', 'ventas', 'productos'))),
('INDICES', 'ANALIZAR_INDICES', 'DIARIO', '01:00:00',
 JSON_OBJECT('fragmentacion_maxima', 30, 'uso_minimo', 50)),
('DATOS', 'LIMPIAR_DATOS', 'DIARIO', '03:00:00',
 JSON_OBJECT('retencion_dias', 30, 'comprimir', true));

-- Procedimiento para gestión completa de mantenimiento
DELIMITER //
CREATE PROCEDURE gestionar_mantenimiento_completo()
BEGIN
    -- Ejecutar todas las tareas de mantenimiento
    CALL ejecutar_mantenimiento();
    CALL identificar_consultas_lentas();
    CALL analizar_indices();
    CALL limpiar_datos_antiguos();
    CALL optimizar_parametros();
    CALL actualizar_estadisticas();
    CALL mantener_logs();
    CALL monitorear_mantenimiento();
    
    -- Registrar actividad
    INSERT INTO log_actividad_mantenimiento (actividad, fecha_ejecucion, estado)
    VALUES ('MANTENIMIENTO_COMPLETO', NOW(), 'COMPLETADA');
END //
DELIMITER ;

-- Evento para mantenimiento automático
CREATE EVENT mantenimiento_automatico
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 01:00:00'
DO
  CALL gestionar_mantenimiento_completo();
```

## Resumen
En esta clase hemos aprendido sobre:
- Sistemas de mantenimiento automático
- Optimización de consultas y parámetros
- Mantenimiento de índices y estadísticas
- Limpieza de datos y compresión
- Tuning automático de rendimiento
- Mantenimiento de logs
- Monitoreo de mantenimiento
- Reportes de mantenimiento

## Próxima Clase
En la siguiente clase aprenderemos sobre migración de datos, incluyendo estrategias de migración, herramientas y procedimientos de migración.
