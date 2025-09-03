# Clase 9: Automatización

## Objetivos de la Clase
- Dominar técnicas de automatización de tareas SQL
- Implementar scripts de mantenimiento automático
- Crear procedimientos de monitoreo automatizado
- Aplicar técnicas de optimización automática

## 1. Introducción a la Automatización

### ¿Qué es la Automatización en SQL?
La automatización en SQL es el proceso de crear scripts, procedimientos y sistemas que ejecuten tareas de base de datos de manera automática, reduciendo la intervención manual y mejorando la eficiencia.

### Beneficios de la Automatización
- **Reducción de Errores**: Eliminación de errores humanos
- **Eficiencia**: Ejecución 24/7 sin supervisión
- **Consistencia**: Tareas ejecutadas de manera uniforme
- **Escalabilidad**: Manejo de grandes volúmenes de datos
- **Monitoreo**: Detección automática de problemas

## 2. Event Scheduler

### Configuración del Event Scheduler
```sql
-- Habilitar el event scheduler
SET GLOBAL event_scheduler = ON;

-- Verificar estado
SHOW VARIABLES LIKE 'event_scheduler';

-- Ver eventos existentes
SHOW EVENTS;
```

### Crear Eventos Automáticos
```sql
-- Evento para limpiar logs antiguos
CREATE EVENT limpiar_logs_antiguos
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 02:00:00'
DO
BEGIN
    -- Eliminar logs más antiguos de 30 días
    DELETE FROM log_consultas 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- Eliminar logs de errores más antiguos de 7 días
    DELETE FROM log_errores 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 7 DAY);
END;
```

### Eventos con Condiciones
```sql
-- Evento para optimizar tablas cuando sea necesario
CREATE EVENT optimizar_tablas_automatico
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-01-01 03:00:00'
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tabla_name VARCHAR(64);
    DECLARE tabla_cursor CURSOR FOR 
        SELECT TABLE_NAME 
        FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA = 'tu_base_datos'
            AND TABLE_ROWS > 100000;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN tabla_cursor;
    
    read_loop: LOOP
        FETCH tabla_cursor INTO tabla_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Optimizar tabla si tiene más de 100,000 filas
        SET @sql = CONCAT('OPTIMIZE TABLE ', tabla_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    
    CLOSE tabla_cursor;
END;
```

## 3. Stored Procedures Automatizadas

### Procedimiento de Mantenimiento
```sql
DELIMITER //
CREATE PROCEDURE MantenimientoAutomatico()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Log del error
        INSERT INTO log_errores (procedimiento, error, fecha)
        VALUES ('MantenimientoAutomatico', 'Error en mantenimiento', NOW());
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- 1. Analizar tablas
    ANALYZE TABLE productos, ventas, clientes;
    
    -- 2. Optimizar tablas grandes
    OPTIMIZE TABLE ventas;
    
    -- 3. Limpiar cache de consultas
    FLUSH QUERY CACHE;
    
    -- 4. Actualizar estadísticas
    UPDATE information_schema.TABLES 
    SET TABLE_ROWS = (
        SELECT COUNT(*) FROM productos
    ) WHERE TABLE_NAME = 'productos';
    
    -- 5. Log de mantenimiento exitoso
    INSERT INTO log_mantenimiento (tipo, fecha, estado)
    VALUES ('MantenimientoAutomatico', NOW(), 'EXITOSO');
    
    COMMIT;
END //
DELIMITER ;
```

### Procedimiento de Monitoreo
```sql
DELIMITER //
CREATE PROCEDURE MonitoreoAutomatico()
BEGIN
    DECLARE total_consultas INT DEFAULT 0;
    DECLARE consultas_lentas INT DEFAULT 0;
    DECLARE hit_ratio_buffer DECIMAL(5,2) DEFAULT 0;
    DECLARE hit_ratio_cache DECIMAL(5,2) DEFAULT 0;
    
    -- Obtener métricas
    SELECT VARIABLE_VALUE INTO total_consultas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Questions';
    
    SELECT VARIABLE_VALUE INTO consultas_lentas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Slow_queries';
    
    -- Calcular hit ratio del buffer pool
    SELECT 
        (1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)) * 100 
        INTO hit_ratio_buffer
    FROM (
        SELECT 
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') AS Innodb_buffer_pool_reads,
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests') AS Innodb_buffer_pool_read_requests
    ) AS stats;
    
    -- Calcular hit ratio del query cache
    SELECT 
        Qcache_hits / (Qcache_hits + Qcache_inserts) * 100 
        INTO hit_ratio_cache
    FROM (
        SELECT 
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_hits') AS Qcache_hits,
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_inserts') AS Qcache_inserts
    ) AS stats;
    
    -- Insertar métricas en tabla de monitoreo
    INSERT INTO metricas_rendimiento (
        fecha,
        total_consultas,
        consultas_lentas,
        hit_ratio_buffer,
        hit_ratio_cache
    ) VALUES (
        NOW(),
        total_consultas,
        consultas_lentas,
        hit_ratio_buffer,
        hit_ratio_cache
    );
    
    -- Alertas automáticas
    IF hit_ratio_buffer < 95 THEN
        INSERT INTO alertas (tipo, mensaje, fecha)
        VALUES ('RENDIMIENTO', 'Buffer pool hit ratio bajo', NOW());
    END IF;
    
    IF consultas_lentas > 100 THEN
        INSERT INTO alertas (tipo, mensaje, fecha)
        VALUES ('RENDIMIENTO', 'Muchas consultas lentas detectadas', NOW());
    END IF;
END //
DELIMITER ;
```

## 4. Triggers Automatizados

### Trigger de Auditoría
```sql
-- Trigger para auditoría automática de cambios
DELIMITER //
CREATE TRIGGER auditoria_productos_insert
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        accion,
        id_producto,
        nombre_anterior,
        nombre_nuevo,
        precio_anterior,
        precio_nuevo,
        usuario,
        fecha
    ) VALUES (
        'INSERT',
        NEW.id,
        NULL,
        NEW.nombre,
        NULL,
        NEW.precio,
        USER(),
        NOW()
    );
END //

CREATE TRIGGER auditoria_productos_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        accion,
        id_producto,
        nombre_anterior,
        nombre_nuevo,
        precio_anterior,
        precio_nuevo,
        usuario,
        fecha
    ) VALUES (
        'UPDATE',
        NEW.id,
        OLD.nombre,
        NEW.nombre,
        OLD.precio,
        NEW.precio,
        USER(),
        NOW()
    );
END //

CREATE TRIGGER auditoria_productos_delete
AFTER DELETE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        accion,
        id_producto,
        nombre_anterior,
        nombre_nuevo,
        precio_anterior,
        precio_nuevo,
        usuario,
        fecha
    ) VALUES (
        'DELETE',
        OLD.id,
        OLD.nombre,
        NULL,
        OLD.precio,
        NULL,
        USER(),
        NOW()
    );
END //
DELIMITER ;
```

### Trigger de Validación Automática
```sql
-- Trigger para validación automática de datos
DELIMITER //
CREATE TRIGGER validar_precio_producto
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    -- Validar que el precio sea positivo
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio debe ser mayor que 0';
    END IF;
    
    -- Validar que el nombre no esté vacío
    IF NEW.nombre IS NULL OR NEW.nombre = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del producto no puede estar vacío';
    END IF;
    
    -- Auto-generar fecha de creación si no se proporciona
    IF NEW.fecha_creacion IS NULL THEN
        SET NEW.fecha_creacion = NOW();
    END IF;
END //
DELIMITER ;
```

## 5. Scripts de Backup Automatizado

### Procedimiento de Backup
```sql
DELIMITER //
CREATE PROCEDURE BackupAutomatico()
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    DECLARE ruta_backup VARCHAR(255);
    
    -- Generar nombre de archivo con fecha
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');
    SET ruta_backup = CONCAT('/backup/mysql_backup_', fecha_backup, '.sql');
    
    -- Crear backup usando mysqldump (esto se ejecutaría desde el sistema)
    -- En un entorno real, esto se haría con un script del sistema operativo
    
    -- Log del backup
    INSERT INTO log_backups (fecha, archivo, estado)
    VALUES (NOW(), ruta_backup, 'INICIADO');
    
    -- Aquí iría la lógica para ejecutar mysqldump
    -- Por ejemplo, usando sys_exec() o un script externo
    
    -- Actualizar log
    UPDATE log_backups 
    SET estado = 'COMPLETADO'
    WHERE archivo = ruta_backup;
END //
DELIMITER ;
```

### Evento de Backup Automático
```sql
-- Evento para backup diario
CREATE EVENT backup_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 01:00:00'
DO
BEGIN
    CALL BackupAutomatico();
END;
```

## 6. Automatización de Optimización

### Procedimiento de Optimización Automática
```sql
DELIMITER //
CREATE PROCEDURE OptimizacionAutomatica()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tabla_name VARCHAR(64);
    DECLARE tabla_rows BIGINT;
    DECLARE tabla_cursor CURSOR FOR 
        SELECT TABLE_NAME, TABLE_ROWS
        FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA = 'tu_base_datos'
            AND TABLE_TYPE = 'BASE TABLE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN tabla_cursor;
    
    read_loop: LOOP
        FETCH tabla_cursor INTO tabla_name, tabla_rows;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Optimizar tablas grandes
        IF tabla_rows > 100000 THEN
            SET @sql = CONCAT('OPTIMIZE TABLE ', tabla_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            -- Log de optimización
            INSERT INTO log_optimizacion (tabla, filas, fecha)
            VALUES (tabla_name, tabla_rows, NOW());
        END IF;
        
        -- Analizar tablas con muchas filas
        IF tabla_rows > 10000 THEN
            SET @sql = CONCAT('ANALYZE TABLE ', tabla_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END LOOP;
    
    CLOSE tabla_cursor;
END //
DELIMITER ;
```

## 7. Automatización de Limpieza

### Procedimiento de Limpieza Automática
```sql
DELIMITER //
CREATE PROCEDURE LimpiezaAutomatica()
BEGIN
    DECLARE filas_eliminadas INT DEFAULT 0;
    
    -- Limpiar logs antiguos
    DELETE FROM log_consultas 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 30 DAY);
    SET filas_eliminadas = ROW_COUNT();
    
    -- Limpiar logs de errores antiguos
    DELETE FROM log_errores 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 7 DAY);
    SET filas_eliminadas = filas_eliminadas + ROW_COUNT();
    
    -- Limpiar cache de consultas antiguo
    DELETE FROM cache_consultas 
    WHERE fecha_expiracion < NOW();
    SET filas_eliminadas = filas_eliminadas + ROW_COUNT();
    
    -- Limpiar sesiones expiradas
    DELETE FROM sesiones_usuarios 
    WHERE fecha_expiracion < NOW();
    SET filas_eliminadas = filas_eliminadas + ROW_COUNT();
    
    -- Log de limpieza
    INSERT INTO log_limpieza (fecha, filas_eliminadas, estado)
    VALUES (NOW(), filas_eliminadas, 'COMPLETADO');
END //
DELIMITER ;
```

## 8. Automatización de Alertas

### Sistema de Alertas Automáticas
```sql
DELIMITER //
CREATE PROCEDURE VerificarAlertas()
BEGIN
    DECLARE total_consultas INT DEFAULT 0;
    DECLARE consultas_lentas INT DEFAULT 0;
    DECLARE conexiones_activas INT DEFAULT 0;
    DECLARE espacio_libre DECIMAL(10,2) DEFAULT 0;
    
    -- Obtener métricas
    SELECT VARIABLE_VALUE INTO total_consultas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Questions';
    
    SELECT VARIABLE_VALUE INTO consultas_lentas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Slow_queries';
    
    SELECT VARIABLE_VALUE INTO conexiones_activas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Threads_connected';
    
    -- Verificar espacio en disco (esto requeriría una función del sistema)
    -- SET espacio_libre = sys_exec('df -h /var/lib/mysql | tail -1 | awk \'{print $4}\'');
    
    -- Alertas de rendimiento
    IF consultas_lentas > 50 THEN
        INSERT INTO alertas (tipo, severidad, mensaje, fecha)
        VALUES ('RENDIMIENTO', 'ALTA', 'Muchas consultas lentas detectadas', NOW());
    END IF;
    
    -- Alertas de conexiones
    IF conexiones_activas > 100 THEN
        INSERT INTO alertas (tipo, severidad, mensaje, fecha)
        VALUES ('CONEXIONES', 'MEDIA', 'Muchas conexiones activas', NOW());
    END IF;
    
    -- Alertas de espacio
    IF espacio_libre < 10 THEN
        INSERT INTO alertas (tipo, severidad, mensaje, fecha)
        VALUES ('ESPACIO', 'CRITICA', 'Poco espacio en disco disponible', NOW());
    END IF;
END //
DELIMITER ;
```

## 9. Automatización de Reportes

### Generación Automática de Reportes
```sql
DELIMITER //
CREATE PROCEDURE GenerarReporteDiario()
BEGIN
    DECLARE fecha_reporte DATE DEFAULT CURDATE();
    
    -- Crear tabla temporal para el reporte
    CREATE TEMPORARY TABLE reporte_diario AS
    SELECT 
        fecha_reporte AS fecha,
        COUNT(*) AS total_ventas,
        SUM(monto) AS monto_total,
        AVG(monto) AS ticket_promedio,
        COUNT(DISTINCT cliente_id) AS clientes_unicos,
        COUNT(DISTINCT producto_id) AS productos_vendidos
    FROM ventas
    WHERE DATE(fecha) = fecha_reporte;
    
    -- Insertar reporte en tabla permanente
    INSERT INTO reportes_diarios 
    SELECT * FROM reporte_diario;
    
    -- Generar reporte por categoría
    INSERT INTO reportes_categorias_diarios
    SELECT 
        fecha_reporte AS fecha,
        p.categoria,
        COUNT(*) AS total_ventas,
        SUM(v.monto) AS monto_total
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    WHERE DATE(v.fecha) = fecha_reporte
    GROUP BY p.categoria;
    
    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE reporte_diario;
END //
DELIMITER ;
```

## 10. Monitoreo de Automatización

### Tabla de Log de Automatización
```sql
-- Crear tabla para monitorear automatización
CREATE TABLE log_automatizacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    procedimiento VARCHAR(100),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    estado ENUM('EXITOSO', 'ERROR', 'EN_PROGRESO'),
    mensaje TEXT,
    duracion_segundos INT
);

-- Procedimiento para monitorear otros procedimientos
DELIMITER //
CREATE PROCEDURE MonitorearProcedimiento(
    IN p_procedimiento VARCHAR(100)
)
BEGIN
    DECLARE fecha_inicio TIMESTAMP DEFAULT NOW();
    DECLARE fecha_fin TIMESTAMP;
    DECLARE duracion INT;
    
    -- Insertar registro de inicio
    INSERT INTO log_automatizacion (procedimiento, fecha_inicio, estado)
    VALUES (p_procedimiento, fecha_inicio, 'EN_PROGRESO');
    
    -- Aquí se ejecutaría el procedimiento a monitorear
    -- Por ejemplo: CALL p_procedimiento();
    
    -- Calcular duración
    SET fecha_fin = NOW();
    SET duracion = TIMESTAMPDIFF(SECOND, fecha_inicio, fecha_fin);
    
    -- Actualizar registro
    UPDATE log_automatizacion 
    SET fecha_fin = fecha_fin,
        estado = 'EXITOSO',
        duracion_segundos = duracion
    WHERE procedimiento = p_procedimiento 
        AND fecha_inicio = fecha_inicio;
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Evento de Limpieza Automática
```sql
-- Crear evento para limpieza automática
CREATE EVENT limpieza_automatica
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 02:00:00'
DO
BEGIN
    -- Eliminar logs antiguos
    DELETE FROM log_consultas 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- Eliminar cache expirado
    DELETE FROM cache_consultas 
    WHERE fecha_expiracion < NOW();
    
    -- Log de limpieza
    INSERT INTO log_limpieza (fecha, estado)
    VALUES (NOW(), 'COMPLETADO');
END;
```

### Ejercicio 2: Procedimiento de Mantenimiento
```sql
-- Procedimiento de mantenimiento automático
DELIMITER //
CREATE PROCEDURE MantenimientoCompleto()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO log_errores (procedimiento, error, fecha)
        VALUES ('MantenimientoCompleto', 'Error en mantenimiento', NOW());
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Analizar todas las tablas
    ANALYZE TABLE productos, ventas, clientes;
    
    -- Optimizar tablas grandes
    OPTIMIZE TABLE ventas;
    
    -- Limpiar cache
    FLUSH QUERY CACHE;
    
    -- Log exitoso
    INSERT INTO log_mantenimiento (tipo, fecha, estado)
    VALUES ('MantenimientoCompleto', NOW(), 'EXITOSO');
    
    COMMIT;
END //
DELIMITER ;
```

### Ejercicio 3: Trigger de Auditoría
```sql
-- Trigger para auditoría de ventas
DELIMITER //
CREATE TRIGGER auditoria_ventas_insert
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_ventas (
        accion,
        id_venta,
        cliente_id,
        producto_id,
        monto,
        usuario,
        fecha
    ) VALUES (
        'INSERT',
        NEW.id,
        NEW.cliente_id,
        NEW.producto_id,
        NEW.monto,
        USER(),
        NOW()
    );
END //
DELIMITER ;
```

### Ejercicio 4: Procedimiento de Monitoreo
```sql
-- Procedimiento de monitoreo automático
DELIMITER //
CREATE PROCEDURE MonitoreoCompleto()
BEGIN
    DECLARE total_consultas INT DEFAULT 0;
    DECLARE consultas_lentas INT DEFAULT 0;
    DECLARE hit_ratio DECIMAL(5,2) DEFAULT 0;
    
    -- Obtener métricas
    SELECT VARIABLE_VALUE INTO total_consultas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Questions';
    
    SELECT VARIABLE_VALUE INTO consultas_lentas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Slow_queries';
    
    -- Calcular hit ratio
    SELECT 
        (1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)) * 100 
        INTO hit_ratio
    FROM (
        SELECT 
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') AS Innodb_buffer_pool_reads,
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests') AS Innodb_buffer_pool_read_requests
    ) AS stats;
    
    -- Insertar métricas
    INSERT INTO metricas_rendimiento (
        fecha,
        total_consultas,
        consultas_lentas,
        hit_ratio_buffer
    ) VALUES (
        NOW(),
        total_consultas,
        consultas_lentas,
        hit_ratio
    );
    
    -- Generar alertas
    IF hit_ratio < 95 THEN
        INSERT INTO alertas (tipo, mensaje, fecha)
        VALUES ('RENDIMIENTO', 'Buffer pool hit ratio bajo', NOW());
    END IF;
END //
DELIMITER ;
```

### Ejercicio 5: Evento de Monitoreo
```sql
-- Evento para monitoreo cada 5 minutos
CREATE EVENT monitoreo_continuo
ON SCHEDULE EVERY 5 MINUTE
STARTS '2024-01-01 00:00:00'
DO
BEGIN
    CALL MonitoreoCompleto();
END;
```

### Ejercicio 6: Procedimiento de Optimización
```sql
-- Procedimiento de optimización automática
DELIMITER //
CREATE PROCEDURE OptimizacionInteligente()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tabla_name VARCHAR(64);
    DECLARE tabla_rows BIGINT;
    DECLARE tabla_cursor CURSOR FOR 
        SELECT TABLE_NAME, TABLE_ROWS
        FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA = 'tu_base_datos'
            AND TABLE_ROWS > 10000;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN tabla_cursor;
    
    read_loop: LOOP
        FETCH tabla_cursor INTO tabla_name, tabla_rows;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Optimizar tablas grandes
        IF tabla_rows > 100000 THEN
            SET @sql = CONCAT('OPTIMIZE TABLE ', tabla_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
        
        -- Analizar tablas
        SET @sql = CONCAT('ANALYZE TABLE ', tabla_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Log de optimización
        INSERT INTO log_optimizacion (tabla, filas, fecha)
        VALUES (tabla_name, tabla_rows, NOW());
    END LOOP;
    
    CLOSE tabla_cursor;
END //
DELIMITER ;
```

### Ejercicio 7: Sistema de Alertas
```sql
-- Procedimiento de verificación de alertas
DELIMITER //
CREATE PROCEDURE VerificarAlertasCompleto()
BEGIN
    DECLARE consultas_lentas INT DEFAULT 0;
    DECLARE conexiones_activas INT DEFAULT 0;
    
    -- Obtener métricas
    SELECT VARIABLE_VALUE INTO consultas_lentas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Slow_queries';
    
    SELECT VARIABLE_VALUE INTO conexiones_activas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Threads_connected';
    
    -- Alertas de rendimiento
    IF consultas_lentas > 50 THEN
        INSERT INTO alertas (tipo, severidad, mensaje, fecha)
        VALUES ('RENDIMIENTO', 'ALTA', 'Muchas consultas lentas', NOW());
    END IF;
    
    -- Alertas de conexiones
    IF conexiones_activas > 100 THEN
        INSERT INTO alertas (tipo, severidad, mensaje, fecha)
        VALUES ('CONEXIONES', 'MEDIA', 'Muchas conexiones activas', NOW());
    END IF;
END //
DELIMITER ;
```

### Ejercicio 8: Generación de Reportes
```sql
-- Procedimiento de generación de reportes
DELIMITER //
CREATE PROCEDURE GenerarReportesDiarios()
BEGIN
    DECLARE fecha_reporte DATE DEFAULT CURDATE();
    
    -- Reporte general
    INSERT INTO reportes_diarios
    SELECT 
        fecha_reporte AS fecha,
        COUNT(*) AS total_ventas,
        SUM(monto) AS monto_total,
        AVG(monto) AS ticket_promedio
    FROM ventas
    WHERE DATE(fecha) = fecha_reporte;
    
    -- Reporte por categoría
    INSERT INTO reportes_categorias_diarios
    SELECT 
        fecha_reporte AS fecha,
        p.categoria,
        COUNT(*) AS total_ventas,
        SUM(v.monto) AS monto_total
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    WHERE DATE(v.fecha) = fecha_reporte
    GROUP BY p.categoria;
END //
DELIMITER ;
```

### Ejercicio 9: Evento de Reportes
```sql
-- Evento para generar reportes diarios
CREATE EVENT reportes_diarios
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 23:59:00'
DO
BEGIN
    CALL GenerarReportesDiarios();
END;
```

### Ejercicio 10: Monitoreo de Automatización
```sql
-- Procedimiento para monitorear automatización
DELIMITER //
CREATE PROCEDURE MonitorearAutomatizacion()
BEGIN
    DECLARE fecha_inicio TIMESTAMP DEFAULT NOW();
    DECLARE fecha_fin TIMESTAMP;
    DECLARE duracion INT;
    
    -- Insertar registro de inicio
    INSERT INTO log_automatizacion (procedimiento, fecha_inicio, estado)
    VALUES ('MonitorearAutomatizacion', fecha_inicio, 'EN_PROGRESO');
    
    -- Ejecutar tareas de automatización
    CALL MantenimientoCompleto();
    CALL MonitoreoCompleto();
    CALL VerificarAlertasCompleto();
    
    -- Calcular duración
    SET fecha_fin = NOW();
    SET duracion = TIMESTAMPDIFF(SECOND, fecha_inicio, fecha_fin);
    
    -- Actualizar registro
    UPDATE log_automatizacion 
    SET fecha_fin = fecha_fin,
        estado = 'EXITOSO',
        duracion_segundos = duracion
    WHERE procedimiento = 'MonitorearAutomatizacion' 
        AND fecha_inicio = fecha_inicio;
END //
DELIMITER ;
```

## Resumen de la Clase

En esta clase hemos cubierto:

1. **Event Scheduler**: Configuración y creación de eventos automáticos
2. **Stored Procedures**: Procedimientos automatizados para mantenimiento
3. **Triggers**: Automatización de auditoría y validación
4. **Backup Automatizado**: Scripts de backup automático
5. **Optimización Automática**: Procedimientos de optimización inteligente
6. **Limpieza Automática**: Scripts de limpieza de datos antiguos
7. **Sistema de Alertas**: Monitoreo y alertas automáticas
8. **Generación de Reportes**: Reportes automáticos
9. **Monitoreo de Automatización**: Seguimiento de tareas automatizadas
10. **Mejores Prácticas**: Estrategias de automatización efectiva

## Próxima Clase
En la siguiente clase exploraremos el proyecto integrador que combina todas las técnicas aprendidas en el módulo.

## Recursos Adicionales
- Documentación del Event Scheduler de MySQL
- Guías de automatización de bases de datos
- Mejores prácticas de triggers y procedimientos
- Herramientas de monitoreo automatizado
