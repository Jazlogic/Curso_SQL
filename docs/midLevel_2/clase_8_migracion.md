# Clase 8: Migración de Datos - Nivel Mid-Level

## Introducción
La migración de datos es un proceso crítico que requiere planificación cuidadosa. En esta clase aprenderemos sobre estrategias de migración, herramientas y procedimientos para migrar datos de manera segura y eficiente.

## Conceptos Clave

### Tipos de Migración
**Definición**: Diferentes enfoques para mover datos entre sistemas.
**Tipos**:
- Migración completa
- Migración incremental
- Migración en paralelo
- Migración por lotes

### Estrategias de Migración
**Definición**: Planes estructurados para ejecutar migraciones.
**Componentes**:
- Análisis de datos
- Mapeo de campos
- Validación de datos
- Rollback plan

### Herramientas de Migración
**Definición**: Software y utilidades para automatizar migraciones.
**Categorías**:
- Herramientas nativas
- Herramientas de terceros
- Scripts personalizados
- ETL tools

## Ejemplos Prácticos

### 1. Sistema de Migración Básico

```sql
-- Crear tabla de configuración de migración
CREATE TABLE configuracion_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_migracion VARCHAR(100),
    tabla_origen VARCHAR(100),
    tabla_destino VARCHAR(100),
    estado ENUM('PENDIENTE', 'EN_PROCESO', 'COMPLETADA', 'ERROR') DEFAULT 'PENDIENTE',
    fecha_inicio TIMESTAMP NULL,
    fecha_fin TIMESTAMP NULL,
    registros_migrados INT DEFAULT 0,
    registros_totales INT DEFAULT 0
);

-- Insertar configuración de migración
INSERT INTO configuracion_migracion (nombre_migracion, tabla_origen, tabla_destino, registros_totales)
VALUES 
('Migracion_Clientes', 'clientes_old', 'clientes_new', 10000),
('Migracion_Ventas', 'ventas_old', 'ventas_new', 50000),
('Migracion_Productos', 'productos_old', 'productos_new', 5000);

-- Procedimiento para migración básica
DELIMITER //
CREATE PROCEDURE ejecutar_migracion_basica(IN p_migracion_id INT)
BEGIN
    DECLARE v_tabla_origen VARCHAR(100);
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_registros_totales INT;
    DECLARE v_registros_migrados INT;
    DECLARE v_batch_size INT DEFAULT 1000;
    DECLARE v_offset INT DEFAULT 0;
    
    -- Obtener configuración
    SELECT tabla_origen, tabla_destino, registros_totales
    INTO v_tabla_origen, v_tabla_destino, v_registros_totales
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Actualizar estado
    UPDATE configuracion_migracion 
    SET estado = 'EN_PROCESO', fecha_inicio = NOW()
    WHERE id = p_migracion_id;
    
    -- Migrar datos por lotes
    WHILE v_offset < v_registros_totales DO
        -- Migrar lote de datos
        SET @sql = CONCAT(
            'INSERT INTO ', v_tabla_destino, 
            ' SELECT * FROM ', v_tabla_origen,
            ' LIMIT ', v_batch_size, ' OFFSET ', v_offset
        );
        
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET v_registros_migrados = v_registros_migrados + ROW_COUNT();
        SET v_offset = v_offset + v_batch_size;
        
        -- Actualizar progreso
        UPDATE configuracion_migracion 
        SET registros_migrados = v_registros_migrados
        WHERE id = p_migracion_id;
    END WHILE;
    
    -- Marcar como completada
    UPDATE configuracion_migracion 
    SET estado = 'COMPLETADA', fecha_fin = NOW()
    WHERE id = p_migracion_id;
END //
DELIMITER ;
```

### 2. Migración con Validación

```sql
-- Crear tabla de validación de migración
CREATE TABLE validacion_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    tipo_validacion ENUM('CONTEO', 'INTEGRIDAD', 'FORMATO', 'REFERENCIAL'),
    resultado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA'),
    detalles TEXT,
    fecha_validacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para validar migración
DELIMITER //
CREATE PROCEDURE validar_migracion(IN p_migracion_id INT)
BEGIN
    DECLARE v_tabla_origen VARCHAR(100);
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_registros_origen INT;
    DECLARE v_registros_destino INT;
    DECLARE v_diferencia INT;
    
    -- Obtener configuración
    SELECT tabla_origen, tabla_destino
    INTO v_tabla_origen, v_tabla_destino
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Validar conteo de registros
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_origen);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_origen = @count;
    
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_destino);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_destino = @count;
    
    SET v_diferencia = v_registros_origen - v_registros_destino;
    
    -- Registrar resultado de validación
    IF v_diferencia = 0 THEN
        INSERT INTO validacion_migracion (migracion_id, tipo_validacion, resultado, detalles)
        VALUES (p_migracion_id, 'CONTEO', 'EXITOSO', 'Conteo de registros coincide');
    ELSE
        INSERT INTO validacion_migracion (migracion_id, tipo_validacion, resultado, detalles)
        VALUES (p_migracion_id, 'CONTEO', 'FALLIDO', CONCAT('Diferencia de registros: ', v_diferencia));
    END IF;
    
    -- Validar integridad de datos
    CALL validar_integridad_datos(p_migracion_id);
    
    -- Validar formato de datos
    CALL validar_formato_datos(p_migracion_id);
    
    -- Validar integridad referencial
    CALL validar_integridad_referencial(p_migracion_id);
END //
DELIMITER ;
```

### 3. Migración Incremental

```sql
-- Crear tabla de migración incremental
CREATE TABLE migracion_incremental (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    ultima_migracion TIMESTAMP,
    registros_migrados INT,
    estado ENUM('ACTIVO', 'PAUSADO', 'COMPLETADO') DEFAULT 'ACTIVO'
);

-- Procedimiento para migración incremental
DELIMITER //
CREATE PROCEDURE ejecutar_migracion_incremental(IN p_tabla VARCHAR(100))
BEGIN
    DECLARE v_ultima_migracion TIMESTAMP;
    DECLARE v_registros_migrados INT;
    DECLARE v_batch_size INT DEFAULT 1000;
    
    -- Obtener última migración
    SELECT ultima_migracion INTO v_ultima_migracion
    FROM migracion_incremental
    WHERE tabla = p_tabla;
    
    -- Si es la primera migración, usar fecha muy antigua
    IF v_ultima_migracion IS NULL THEN
        SET v_ultima_migracion = '1900-01-01 00:00:00';
    END IF;
    
    -- Migrar registros nuevos o modificados
    SET @sql = CONCAT(
        'INSERT INTO ', p_tabla, '_new ',
        'SELECT * FROM ', p_tabla, '_old ',
        'WHERE fecha_modificacion > ''', v_ultima_migracion, ''' ',
        'LIMIT ', v_batch_size
    );
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    SET v_registros_migrados = ROW_COUNT();
    DEALLOCATE PREPARE stmt;
    
    -- Actualizar registro de migración
    UPDATE migracion_incremental 
    SET ultima_migracion = NOW(),
        registros_migrados = registros_migrados + v_registros_migrados
    WHERE tabla = p_tabla;
    
    -- Si no hay más registros, marcar como completado
    IF v_registros_migrados = 0 THEN
        UPDATE migracion_incremental 
        SET estado = 'COMPLETADO'
        WHERE tabla = p_tabla;
    END IF;
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Migración por Lotes
```sql
-- Crear tabla de control de lotes
CREATE TABLE control_lotes_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    numero_lote INT,
    registros_lote INT,
    fecha_procesamiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'PROCESANDO', 'COMPLETADO', 'ERROR') DEFAULT 'PENDIENTE'
);

-- Procedimiento para migración por lotes
DELIMITER //
CREATE PROCEDURE migrar_por_lotes(IN p_migracion_id INT, IN p_tamaño_lote INT)
BEGIN
    DECLARE v_tabla_origen VARCHAR(100);
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_registros_totales INT;
    DECLARE v_numero_lotes INT;
    DECLARE v_lote_actual INT DEFAULT 1;
    DECLARE v_offset INT;
    
    -- Obtener configuración
    SELECT tabla_origen, tabla_destino, registros_totales
    INTO v_tabla_origen, v_tabla_destino, v_registros_totales
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Calcular número de lotes
    SET v_numero_lotes = CEIL(v_registros_totales / p_tamaño_lote);
    
    -- Procesar cada lote
    WHILE v_lote_actual <= v_numero_lotes DO
        SET v_offset = (v_lote_actual - 1) * p_tamaño_lote;
        
        -- Registrar lote
        INSERT INTO control_lotes_migracion (migracion_id, numero_lote, registros_lote, estado)
        VALUES (p_migracion_id, v_lote_actual, p_tamaño_lote, 'PROCESANDO');
        
        -- Migrar lote
        SET @sql = CONCAT(
            'INSERT INTO ', v_tabla_destino,
            ' SELECT * FROM ', v_tabla_origen,
            ' LIMIT ', p_tamaño_lote, ' OFFSET ', v_offset
        );
        
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Actualizar estado del lote
        UPDATE control_lotes_migracion 
        SET estado = 'COMPLETADO'
        WHERE migracion_id = p_migracion_id AND numero_lote = v_lote_actual;
        
        SET v_lote_actual = v_lote_actual + 1;
    END WHILE;
END //
DELIMITER ;
```

### Ejercicio 2: Migración con Mapeo de Campos
```sql
-- Crear tabla de mapeo de campos
CREATE TABLE mapeo_campos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    campo_origen VARCHAR(100),
    campo_destino VARCHAR(100),
    transformacion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar mapeos
INSERT INTO mapeo_campos (migracion_id, campo_origen, campo_destino, transformacion)
VALUES 
(1, 'nombre_completo', 'nombre', 'UPPER(nombre_completo)'),
(1, 'fecha_nacimiento', 'edad', 'YEAR(CURDATE()) - YEAR(fecha_nacimiento)'),
(1, 'telefono', 'telefono', 'REPLACE(telefono, ''-'', '''')');

-- Procedimiento para migración con mapeo
DELIMITER //
CREATE PROCEDURE migrar_con_mapeo(IN p_migracion_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_campo_origen VARCHAR(100);
    DECLARE v_campo_destino VARCHAR(100);
    DECLARE v_transformacion TEXT;
    DECLARE v_campos_origen TEXT DEFAULT '';
    DECLARE v_campos_destino TEXT DEFAULT '';
    DECLARE v_transformaciones TEXT DEFAULT '';
    
    DECLARE cur CURSOR FOR
        SELECT campo_origen, campo_destino, transformacion
        FROM mapeo_campos
        WHERE migracion_id = p_migracion_id AND activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_campo_origen, v_campo_destino, v_transformacion;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Construir listas de campos
        IF v_campos_origen = '' THEN
            SET v_campos_origen = v_campo_origen;
            SET v_campos_destino = v_campo_destino;
            SET v_transformaciones = v_transformacion;
        ELSE
            SET v_campos_origen = CONCAT(v_campos_origen, ', ', v_campo_origen);
            SET v_campos_destino = CONCAT(v_campos_destino, ', ', v_campo_destino);
            SET v_transformaciones = CONCAT(v_transformaciones, ', ', v_transformacion);
        END IF;
    END LOOP;
    
    CLOSE cur;
    
    -- Construir consulta de migración
    SET @sql = CONCAT(
        'INSERT INTO tabla_destino (', v_campos_destino, ') ',
        'SELECT ', v_transformaciones, ' FROM tabla_origen'
    );
    
    -- Ejecutar migración
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
```

### Ejercicio 3: Migración con Rollback
```sql
-- Crear tabla de rollback
CREATE TABLE rollback_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    fecha_rollback TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    estado ENUM('INICIADO', 'COMPLETADO', 'FALLIDO') DEFAULT 'INICIADO'
);

-- Procedimiento para rollback
DELIMITER //
CREATE PROCEDURE ejecutar_rollback(IN p_migracion_id INT, IN p_motivo TEXT)
BEGIN
    DECLARE v_tabla_origen VARCHAR(100);
    DECLARE v_tabla_destino VARCHAR(100);
    
    -- Registrar inicio de rollback
    INSERT INTO rollback_migracion (migracion_id, motivo)
    VALUES (p_migracion_id, p_motivo);
    
    -- Obtener configuración
    SELECT tabla_origen, tabla_destino
    INTO v_tabla_origen, v_tabla_destino
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Eliminar datos migrados
    SET @sql = CONCAT('DELETE FROM ', v_tabla_destino);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Actualizar estado de migración
    UPDATE configuracion_migracion 
    SET estado = 'ERROR'
    WHERE id = p_migracion_id;
    
    -- Marcar rollback como completado
    UPDATE rollback_migracion 
    SET estado = 'COMPLETADO'
    WHERE migracion_id = p_migracion_id;
END //
DELIMITER ;
```

### Ejercicio 4: Migración con Verificación de Integridad
```sql
-- Crear tabla de verificación de integridad
CREATE TABLE verificacion_integridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    tabla VARCHAR(100),
    tipo_verificacion VARCHAR(100),
    resultado ENUM('EXITOSO', 'FALLIDO'),
    detalles TEXT,
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para verificar integridad
DELIMITER //
CREATE PROCEDURE verificar_integridad_completa(IN p_migracion_id INT)
BEGIN
    DECLARE v_tabla_origen VARCHAR(100);
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_registros_origen INT;
    DECLARE v_registros_destino INT;
    DECLARE v_checksum_origen VARCHAR(64);
    DECLARE v_checksum_destino VARCHAR(64);
    
    -- Obtener configuración
    SELECT tabla_origen, tabla_destino
    INTO v_tabla_origen, v_tabla_destino
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Verificar conteo de registros
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_origen);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_origen = @count;
    
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_destino);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_destino = @count;
    
    -- Registrar resultado
    IF v_registros_origen = v_registros_destino THEN
        INSERT INTO verificacion_integridad (migracion_id, tabla, tipo_verificacion, resultado, detalles)
        VALUES (p_migracion_id, v_tabla_destino, 'CONTEO', 'EXITOSO', 'Conteo de registros coincide');
    ELSE
        INSERT INTO verificacion_integridad (migracion_id, tabla, tipo_verificacion, resultado, detalles)
        VALUES (p_migracion_id, v_tabla_destino, 'CONTEO', 'FALLIDO', 
                CONCAT('Diferencia: ', v_registros_origen - v_registros_destino));
    END IF;
    
    -- Verificar checksums
    SET @sql = CONCAT('SELECT MD5(GROUP_CONCAT(*)) INTO @checksum FROM ', v_tabla_origen);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_checksum_origen = @checksum;
    
    SET @sql = CONCAT('SELECT MD5(GROUP_CONCAT(*)) INTO @checksum FROM ', v_tabla_destino);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_checksum_destino = @checksum;
    
    -- Registrar resultado de checksum
    IF v_checksum_origen = v_checksum_destino THEN
        INSERT INTO verificacion_integridad (migracion_id, tabla, tipo_verificacion, resultado, detalles)
        VALUES (p_migracion_id, v_tabla_destino, 'CHECKSUM', 'EXITOSO', 'Checksums coinciden');
    ELSE
        INSERT INTO verificacion_integridad (migracion_id, tabla, tipo_verificacion, resultado, detalles)
        VALUES (p_migracion_id, v_tabla_destino, 'CHECKSUM', 'FALLIDO', 'Checksums no coinciden');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 5: Migración con Logging Detallado
```sql
-- Crear tabla de logging de migración
CREATE TABLE log_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    nivel_log ENUM('INFO', 'WARNING', 'ERROR'),
    mensaje TEXT,
    fecha_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para logging
DELIMITER //
CREATE PROCEDURE log_migracion(IN p_migracion_id INT, IN p_nivel VARCHAR(20), IN p_mensaje TEXT)
BEGIN
    INSERT INTO log_migracion (migracion_id, nivel_log, mensaje)
    VALUES (p_migracion_id, p_nivel, p_mensaje);
END //
DELIMITER ;

-- Procedimiento para migración con logging
DELIMITER //
CREATE PROCEDURE migrar_con_logging(IN p_migracion_id INT)
BEGIN
    DECLARE v_tabla_origen VARCHAR(100);
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_registros_totales INT;
    DECLARE v_registros_migrados INT;
    DECLARE v_batch_size INT DEFAULT 1000;
    DECLARE v_offset INT DEFAULT 0;
    
    -- Obtener configuración
    SELECT tabla_origen, tabla_destino, registros_totales
    INTO v_tabla_origen, v_tabla_destino, v_registros_totales
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Log inicio
    CALL log_migracion(p_migracion_id, 'INFO', CONCAT('Iniciando migración de ', v_tabla_origen, ' a ', v_tabla_destino));
    
    -- Migrar datos por lotes
    WHILE v_offset < v_registros_totales DO
        -- Log progreso
        CALL log_migracion(p_migracion_id, 'INFO', CONCAT('Procesando lote: ', v_offset, ' - ', v_offset + v_batch_size));
        
        -- Migrar lote
        SET @sql = CONCAT(
            'INSERT INTO ', v_tabla_destino,
            ' SELECT * FROM ', v_tabla_origen,
            ' LIMIT ', v_batch_size, ' OFFSET ', v_offset
        );
        
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        SET v_registros_migrados = v_registros_migrados + ROW_COUNT();
        DEALLOCATE PREPARE stmt;
        
        SET v_offset = v_offset + v_batch_size;
    END WHILE;
    
    -- Log finalización
    CALL log_migracion(p_migracion_id, 'INFO', CONCAT('Migración completada. Registros migrados: ', v_registros_migrados));
END //
DELIMITER ;
```

### Ejercicio 6: Migración con Resolución de Conflictos
```sql
-- Crear tabla de conflictos
CREATE TABLE conflictos_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    registro_id VARCHAR(100),
    tipo_conflicto ENUM('DUPLICADO', 'FORMATO', 'REFERENCIAL'),
    descripcion TEXT,
    resolucion ENUM('AUTOMATICA', 'MANUAL', 'PENDIENTE') DEFAULT 'PENDIENTE',
    fecha_conflicto TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para resolver conflictos
DELIMITER //
CREATE PROCEDURE resolver_conflictos_migracion(IN p_migracion_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_conflicto_id INT;
    DECLARE v_tipo_conflicto VARCHAR(20);
    DECLARE v_registro_id VARCHAR(100);
    
    DECLARE cur CURSOR FOR
        SELECT id, tipo_conflicto, registro_id
        FROM conflictos_migracion
        WHERE migracion_id = p_migracion_id AND resolucion = 'PENDIENTE';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_conflicto_id, v_tipo_conflicto, v_registro_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Resolver conflicto según tipo
        IF v_tipo_conflicto = 'DUPLICADO' THEN
            -- Eliminar duplicado más antiguo
            SET @sql = CONCAT('DELETE FROM tabla_destino WHERE id = ', v_registro_id, ' ORDER BY fecha_creacion ASC LIMIT 1');
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
        ELSEIF v_tipo_conflicto = 'FORMATO' THEN
            -- Corregir formato
            SET @sql = CONCAT('UPDATE tabla_destino SET campo = TRIM(campo) WHERE id = ', v_registro_id);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
        
        -- Marcar conflicto como resuelto
        UPDATE conflictos_migracion 
        SET resolucion = 'AUTOMATICA'
        WHERE id = v_conflicto_id;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 7: Migración con Monitoreo de Progreso
```sql
-- Crear tabla de progreso
CREATE TABLE progreso_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    porcentaje_completado DECIMAL(5,2),
    registros_procesados INT,
    tiempo_estimado_restante INT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para actualizar progreso
DELIMITER //
CREATE PROCEDURE actualizar_progreso_migracion(IN p_migracion_id INT)
BEGIN
    DECLARE v_registros_migrados INT;
    DECLARE v_registros_totales INT;
    DECLARE v_porcentaje DECIMAL(5,2);
    DECLARE v_tiempo_inicio TIMESTAMP;
    DECLARE v_tiempo_actual TIMESTAMP;
    DECLARE v_tiempo_transcurrido INT;
    DECLARE v_tiempo_estimado INT;
    
    -- Obtener datos de progreso
    SELECT registros_migrados, registros_totales, fecha_inicio
    INTO v_registros_migrados, v_registros_totales, v_tiempo_inicio
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Calcular porcentaje
    SET v_porcentaje = (v_registros_migrados / v_registros_totales) * 100;
    
    -- Calcular tiempo estimado
    SET v_tiempo_actual = NOW();
    SET v_tiempo_transcurrido = TIMESTAMPDIFF(SECOND, v_tiempo_inicio, v_tiempo_actual);
    
    IF v_porcentaje > 0 THEN
        SET v_tiempo_estimado = (v_tiempo_transcurrido / v_porcentaje) * (100 - v_porcentaje);
    ELSE
        SET v_tiempo_estimado = 0;
    END IF;
    
    -- Insertar progreso
    INSERT INTO progreso_migracion (migracion_id, porcentaje_completado, registros_procesados, tiempo_estimado_restante)
    VALUES (p_migracion_id, v_porcentaje, v_registros_migrados, v_tiempo_estimado);
END //
DELIMITER ;
```

### Ejercicio 8: Migración con Backup Automático
```sql
-- Crear tabla de backups de migración
CREATE TABLE backup_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    archivo_backup VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('CREANDO', 'COMPLETADO', 'ERROR') DEFAULT 'CREANDO'
);

-- Procedimiento para crear backup antes de migración
DELIMITER //
CREATE PROCEDURE crear_backup_migracion(IN p_migracion_id INT)
BEGIN
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_archivo_backup VARCHAR(255);
    DECLARE v_fecha_backup VARCHAR(20);
    
    -- Obtener tabla destino
    SELECT tabla_destino INTO v_tabla_destino
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Generar nombre de archivo
    SET v_fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET v_archivo_backup = CONCAT('/backups/migracion_', p_migracion_id, '_', v_fecha_backup, '.sql');
    
    -- Registrar backup
    INSERT INTO backup_migracion (migracion_id, archivo_backup)
    VALUES (p_migracion_id, v_archivo_backup);
    
    -- Simular creación de backup
    -- En implementación real: mysqldump tabla_destino > archivo_backup
    
    -- Marcar como completado
    UPDATE backup_migracion 
    SET estado = 'COMPLETADO', tamaño_mb = 1024
    WHERE migracion_id = p_migracion_id AND archivo_backup = v_archivo_backup;
END //
DELIMITER ;
```

### Ejercicio 9: Migración con Validación de Datos
```sql
-- Crear tabla de validación de datos
CREATE TABLE validacion_datos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    campo VARCHAR(100),
    tipo_validacion VARCHAR(100),
    registros_validos INT,
    registros_invalidos INT,
    errores_encontrados TEXT,
    fecha_validacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para validar datos
DELIMITER //
CREATE PROCEDURE validar_datos_migracion(IN p_migracion_id INT)
BEGIN
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_registros_validos INT;
    DECLARE v_registros_invalidos INT;
    
    -- Obtener tabla destino
    SELECT tabla_destino INTO v_tabla_destino
    FROM configuracion_migracion
    WHERE id = p_migracion_id;
    
    -- Validar email
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_destino, ' WHERE email REGEXP ''^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_validos = @count;
    
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_destino, ' WHERE email NOT REGEXP ''^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_invalidos = @count;
    
    -- Registrar validación
    INSERT INTO validacion_datos (migracion_id, campo, tipo_validacion, registros_validos, registros_invalidos)
    VALUES (p_migracion_id, 'email', 'FORMATO_EMAIL', v_registros_validos, v_registros_invalidos);
    
    -- Validar teléfono
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_destino, ' WHERE telefono REGEXP ''^[0-9]{10}$''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_validos = @count;
    
    SET @sql = CONCAT('SELECT COUNT(*) INTO @count FROM ', v_tabla_destino, ' WHERE telefono NOT REGEXP ''^[0-9]{10}$''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET v_registros_invalidos = @count;
    
    -- Registrar validación
    INSERT INTO validacion_datos (migracion_id, campo, tipo_validacion, registros_validos, registros_invalidos)
    VALUES (p_migracion_id, 'telefono', 'FORMATO_TELEFONO', v_registros_validos, v_registros_invalidos);
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Migración
```sql
-- Crear tabla de configuración completa
CREATE TABLE configuracion_migracion_completa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proyecto VARCHAR(100),
    descripcion TEXT,
    configuracion JSON,
    estado ENUM('PLANIFICADO', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO') DEFAULT 'PLANIFICADO',
    fecha_inicio TIMESTAMP NULL,
    fecha_fin TIMESTAMP NULL
);

-- Insertar configuración completa
INSERT INTO configuracion_migracion_completa (nombre_proyecto, descripcion, configuracion)
VALUES ('Migracion_Sistema_Legacy', 'Migración completa del sistema legacy al nuevo sistema', 
        JSON_OBJECT(
            'tablas', JSON_ARRAY('clientes', 'ventas', 'productos'),
            'validaciones', JSON_ARRAY('formato_email', 'formato_telefono', 'integridad_referencial'),
            'backup', JSON_OBJECT('habilitado', true, 'ubicacion', '/backups/migracion/'),
            'rollback', JSON_OBJECT('habilitado', true, 'tiempo_limite', 24)
        ));

-- Procedimiento para gestión completa de migración
DELIMITER //
CREATE PROCEDURE gestionar_migracion_completa(IN p_proyecto_id INT)
BEGIN
    -- Ejecutar todas las fases de migración
    CALL crear_backup_migracion(p_proyecto_id);
    CALL migrar_con_logging(p_proyecto_id);
    CALL validar_migracion(p_proyecto_id);
    CALL verificar_integridad_completa(p_proyecto_id);
    CALL validar_datos_migracion(p_proyecto_id);
    CALL resolver_conflictos_migracion(p_proyecto_id);
    CALL actualizar_progreso_migracion(p_proyecto_id);
    
    -- Registrar actividad
    INSERT INTO log_actividad_migracion (proyecto_id, actividad, fecha_ejecucion, estado)
    VALUES (p_proyecto_id, 'MIGRACION_COMPLETA', NOW(), 'COMPLETADA');
END //
DELIMITER ;

-- Evento para migración automática
CREATE EVENT migracion_automatica
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 02:00:00'
DO
  CALL gestionar_migracion_completa(1);
```

## Resumen
En esta clase hemos aprendido sobre:
- Tipos de migración (completa, incremental, por lotes)
- Estrategias de migración con validación
- Mapeo de campos y transformaciones
- Sistemas de rollback y recuperación
- Verificación de integridad y checksums
- Logging detallado de migraciones
- Resolución de conflictos
- Monitoreo de progreso
- Backup automático
- Validación de datos
- Gestión completa de migraciones

## Próxima Clase
En la siguiente clase aprenderemos sobre disaster recovery, incluyendo planes de recuperación, procedimientos de emergencia y sistemas de recuperación ante desastres.
