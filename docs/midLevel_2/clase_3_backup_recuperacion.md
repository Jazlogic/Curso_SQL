# Clase 3: Backup y Recuperación - Nivel Mid-Level

## Introducción
Las estrategias de backup y recuperación son fundamentales para proteger los datos críticos de una organización. En esta clase aprenderemos sobre diferentes tipos de backup, planes de recuperación y herramientas de respaldo.

## Conceptos Clave

### Tipos de Backup
**Definición**: Diferentes estrategias para realizar copias de seguridad de los datos.
**Tipos**:
- Backup completo
- Backup incremental
- Backup diferencial
- Backup de transacciones
- Backup en caliente/frío

### Planes de Recuperación
**Definición**: Estrategias documentadas para restaurar datos después de una pérdida.
**Componentes**:
- RTO (Recovery Time Objective)
- RPO (Recovery Point Objective)
- Procedimientos de recuperación
- Pruebas de recuperación

### Herramientas de Backup
**Definición**: Software y utilidades para automatizar y gestionar backups.
**Categorías**:
- Herramientas nativas del SGBD
- Herramientas de terceros
- Scripts personalizados
- Soluciones en la nube

## Ejemplos Prácticos

### 1. Backup Completo de Base de Datos

```sql
-- Backup completo usando mysqldump
-- Comando desde línea de comandos:
-- mysqldump -u root -p --single-transaction --routines --triggers empresa > backup_completo.sql

-- Crear procedimiento para backup programado
DELIMITER //
CREATE PROCEDURE realizar_backup_completo()
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    DECLARE nombre_archivo VARCHAR(100);
    
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET nombre_archivo = CONCAT('/backups/backup_completo_', fecha_backup, '.sql');
    
    -- Registrar inicio del backup
    INSERT INTO log_backups (tipo, fecha_inicio, archivo, estado)
    VALUES ('COMPLETO', NOW(), nombre_archivo, 'INICIADO');
    
    -- Aquí se ejecutaría el comando mysqldump
    -- SET @sql = CONCAT('mysqldump -u root -p empresa > ', nombre_archivo);
    
    -- Actualizar estado
    UPDATE log_backups 
    SET estado = 'COMPLETADO', fecha_fin = NOW()
    WHERE archivo = nombre_archivo;
END //
DELIMITER ;
```

**Explicación línea por línea**:
- `mysqldump`: Herramienta nativa de MySQL para backups
- `--single-transaction`: Mantiene consistencia durante el backup
- `--routines`: Incluye procedimientos almacenados
- `--triggers`: Incluye triggers
- `DATE_FORMAT()`: Formatea fecha para nombre de archivo
- `log_backups`: Tabla para registrar operaciones de backup

### 2. Backup Incremental con Binlog

```sql
-- Configurar binlog para backups incrementales
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';
SET GLOBAL expire_logs_days = 7;

-- Crear tabla de control de backups
CREATE TABLE control_backups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo_backup VARCHAR(255),
    posicion_binlog VARCHAR(50),
    archivo_binlog VARCHAR(100),
    tamaño_mb DECIMAL(10,2),
    estado ENUM('INICIADO', 'COMPLETADO', 'ERROR') DEFAULT 'INICIADO'
);

-- Procedimiento para backup incremental
DELIMITER //
CREATE PROCEDURE realizar_backup_incremental()
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    DECLARE nombre_archivo VARCHAR(100);
    DECLARE posicion_actual VARCHAR(50);
    DECLARE archivo_binlog_actual VARCHAR(100);
    
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET nombre_archivo = CONCAT('/backups/backup_incremental_', fecha_backup, '.sql');
    
    -- Obtener posición actual del binlog
    SHOW MASTER STATUS INTO @posicion, @archivo;
    SET posicion_actual = @posicion;
    SET archivo_binlog_actual = @archivo;
    
    -- Registrar backup incremental
    INSERT INTO control_backups (tipo_backup, archivo_backup, posicion_binlog, archivo_binlog)
    VALUES ('INCREMENTAL', nombre_archivo, posicion_actual, archivo_binlog_actual);
    
    -- Aquí se ejecutaría el backup incremental
    -- mysqlbinlog --start-position=posicion_anterior archivo_binlog > nombre_archivo
    
    UPDATE control_backups 
    SET estado = 'COMPLETADO'
    WHERE archivo_backup = nombre_archivo;
END //
DELIMITER ;
```

**Explicación línea por línea**:
- `log_bin = ON`: Habilita el registro binario
- `binlog_format = 'ROW'`: Formato de registro por filas
- `expire_logs_days`: Días para mantener logs binarios
- `SHOW MASTER STATUS`: Muestra posición actual del binlog
- `mysqlbinlog`: Herramienta para procesar logs binarios

### 3. Sistema de Backup Automatizado

```sql
-- Crear tabla de configuración de backups
CREATE TABLE configuracion_backups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    dias_semana SET('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'),
    activo BOOLEAN DEFAULT TRUE,
    retencion_dias INT DEFAULT 30
);

-- Insertar configuraciones
INSERT INTO configuracion_backups (tipo_backup, frecuencia, hora_ejecucion, dias_semana)
VALUES 
('COMPLETO', 'SEMANAL', '02:00:00', 'domingo'),
('INCREMENTAL', 'DIARIO', '01:00:00', 'lunes,martes,miercoles,jueves,viernes,sabado');

-- Evento para backup automático
CREATE EVENT backup_automatico
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 01:00:00'
DO
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tipo VARCHAR(20);
    DECLARE v_frecuencia VARCHAR(20);
    DECLARE v_hora TIME;
    DECLARE v_dias SET('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo');
    
    DECLARE cur CURSOR FOR
        SELECT tipo_backup, frecuencia, hora_ejecucion, dias_semana
        FROM configuracion_backups
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tipo, v_frecuencia, v_hora, v_dias;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Verificar si es hora de ejecutar
        IF TIME(NOW()) = v_hora AND 
           (v_frecuencia = 'DIARIO' OR 
            (v_frecuencia = 'SEMANAL' AND DAYNAME(NOW()) IN (v_dias))) THEN
            
            IF v_tipo = 'COMPLETO' THEN
                CALL realizar_backup_completo();
            ELSEIF v_tipo = 'INCREMENTAL' THEN
                CALL realizar_backup_incremental();
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur;
END;
```

**Explicación línea por línea**:
- `configuracion_backups`: Tabla para configurar backups automáticos
- `SET`: Tipo de dato para múltiples valores
- `CREATE EVENT`: Crea evento programado
- `ON SCHEDULE`: Define cuándo ejecutar el evento
- `CURSOR`: Permite iterar sobre resultados de consulta

### 4. Procedimientos de Recuperación

```sql
-- Crear tabla de procedimientos de recuperación
CREATE TABLE procedimientos_recuperacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_procedimiento VARCHAR(100),
    descripcion TEXT,
    pasos JSON,
    tiempo_estimado_minutos INT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO')
);

-- Insertar procedimientos
INSERT INTO procedimientos_recuperacion (nombre_procedimiento, descripcion, pasos, tiempo_estimado_minutos, nivel_critico)
VALUES 
('Recuperación Completa', 'Restaurar base de datos completa desde backup',
 JSON_ARRAY(
     '1. Detener aplicaciones',
     '2. Restaurar backup completo',
     '3. Aplicar logs incrementales',
     '4. Verificar integridad',
     '5. Reiniciar aplicaciones'
 ), 60, 'CRITICO'),
 
('Recuperación Punto en Tiempo', 'Restaurar hasta un momento específico',
 JSON_ARRAY(
     '1. Restaurar backup completo',
     '2. Aplicar binlogs hasta punto específico',
     '3. Verificar datos',
     '4. Notificar usuarios'
 ), 30, 'ALTO');

-- Procedimiento para recuperación automática
DELIMITER //
CREATE PROCEDURE ejecutar_recuperacion(
    IN p_procedimiento_id INT,
    IN p_fecha_recuperacion DATETIME
)
BEGIN
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_pasos JSON;
    DECLARE v_tiempo_estimado INT;
    DECLARE v_nivel VARCHAR(20);
    DECLARE i INT DEFAULT 0;
    DECLARE total_pasos INT;
    DECLARE paso_actual TEXT;
    
    -- Obtener información del procedimiento
    SELECT nombre_procedimiento, pasos, tiempo_estimado_minutos, nivel_critico
    INTO v_nombre, v_pasos, v_tiempo_estimado, v_nivel
    FROM procedimientos_recuperacion
    WHERE id = p_procedimiento_id;
    
    -- Registrar inicio de recuperación
    INSERT INTO log_recuperaciones (procedimiento_id, fecha_inicio, fecha_objetivo, estado)
    VALUES (p_procedimiento_id, NOW(), p_fecha_recuperacion, 'INICIADO');
    
    -- Obtener número total de pasos
    SET total_pasos = JSON_LENGTH(v_pasos);
    
    -- Ejecutar cada paso
    WHILE i < total_pasos DO
        SET paso_actual = JSON_UNQUOTE(JSON_EXTRACT(v_pasos, CONCAT('$[', i, ']')));
        
        -- Registrar paso
        INSERT INTO log_pasos_recuperacion (procedimiento_id, numero_paso, descripcion, fecha_inicio)
        VALUES (p_procedimiento_id, i + 1, paso_actual, NOW());
        
        -- Aquí se ejecutarían los comandos reales de recuperación
        -- Ejemplo: SOURCE /backups/backup_completo.sql;
        
        SET i = i + 1;
    END WHILE;
    
    -- Marcar como completado
    UPDATE log_recuperaciones 
    SET estado = 'COMPLETADO', fecha_fin = NOW()
    WHERE procedimiento_id = p_procedimiento_id;
END //
DELIMITER ;
```

**Explicación línea por línea**:
- `procedimientos_recuperacion`: Tabla con procedimientos documentados
- `JSON_ARRAY()`: Crea array JSON con pasos
- `JSON_LENGTH()`: Obtiene longitud del array JSON
- `JSON_EXTRACT()`: Extrae elemento específico del JSON
- `WHILE`: Bucle para ejecutar pasos secuencialmente

### 5. Monitoreo de Backups

```sql
-- Crear tabla de monitoreo
CREATE TABLE monitoreo_backups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_backup VARCHAR(20),
    archivo VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    duracion_segundos INT,
    estado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA'),
    mensaje_error TEXT,
    checksum VARCHAR(64)
);

-- Función para calcular checksum
DELIMITER //
CREATE FUNCTION calcular_checksum(archivo VARCHAR(255))
RETURNS VARCHAR(64)
READS SQL DATA
BEGIN
    DECLARE resultado VARCHAR(64);
    -- En implementación real, se calcularía el checksum del archivo
    SET resultado = SHA2(CONCAT(archivo, NOW()), 256);
    RETURN resultado;
END //
DELIMITER ;

-- Procedimiento para verificar integridad de backups
DELIMITER //
CREATE PROCEDURE verificar_integridad_backups()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_archivo VARCHAR(255);
    DECLARE v_checksum VARCHAR(64);
    DECLARE v_checksum_calculado VARCHAR(64);
    
    DECLARE cur CURSOR FOR
        SELECT id, archivo, checksum
        FROM monitoreo_backups
        WHERE estado = 'EXITOSO' 
        AND fecha_backup > DATE_SUB(NOW(), INTERVAL 7 DAY);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_id, v_archivo, v_checksum;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Calcular checksum actual
        SET v_checksum_calculado = calcular_checksum(v_archivo);
        
        -- Verificar integridad
        IF v_checksum != v_checksum_calculado THEN
            UPDATE monitoreo_backups 
            SET estado = 'ADVERTENCIA', 
                mensaje_error = 'Checksum no coincide - posible corrupción'
            WHERE id = v_id;
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;

-- Evento para verificación automática
CREATE EVENT verificar_backups_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 03:00:00'
DO
  CALL verificar_integridad_backups();
```

**Explicación línea por línea**:
- `monitoreo_backups`: Tabla para rastrear estado de backups
- `checksum`: Valor hash para verificar integridad
- `SHA2()`: Función de hash criptográfico
- `DATE_SUB()`: Resta tiempo de fecha actual
- `verificar_integridad_backups()`: Procedimiento para validar backups

## Ejercicios Prácticos

### Ejercicio 1: Sistema de Backup Completo
```sql
-- Crear estructura para backup completo
CREATE TABLE backup_completo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    duracion_minutos INT,
    estado ENUM('INICIADO', 'COMPLETADO', 'ERROR') DEFAULT 'INICIADO'
);

-- Procedimiento para backup completo
DELIMITER //
CREATE PROCEDURE backup_completo_empresa()
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    DECLARE nombre_archivo VARCHAR(100);
    DECLARE inicio_backup TIMESTAMP;
    
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET nombre_archivo = CONCAT('/backups/empresa_completo_', fecha_backup, '.sql');
    SET inicio_backup = NOW();
    
    -- Registrar inicio
    INSERT INTO backup_completo (archivo, fecha_backup)
    VALUES (nombre_archivo, inicio_backup);
    
    -- Simular backup (en realidad sería mysqldump)
    -- SET @sql = CONCAT('mysqldump -u root -p --single-transaction empresa > ', nombre_archivo);
    
    -- Calcular duración
    UPDATE backup_completo 
    SET duracion_minutos = TIMESTAMPDIFF(MINUTE, fecha_backup, NOW()),
        estado = 'COMPLETADO'
    WHERE archivo = nombre_archivo;
END //
DELIMITER ;
```

### Ejercicio 2: Backup Incremental con Control
```sql
-- Crear tabla de control incremental
CREATE TABLE backup_incremental (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo VARCHAR(255),
    posicion_binlog_inicio VARCHAR(50),
    posicion_binlog_fin VARCHAR(50),
    archivo_binlog VARCHAR(100),
    tamaño_mb DECIMAL(10,2),
    estado ENUM('INICIADO', 'COMPLETADO', 'ERROR') DEFAULT 'INICIADO'
);

-- Procedimiento para backup incremental
DELIMITER //
CREATE PROCEDURE backup_incremental_empresa()
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    DECLARE nombre_archivo VARCHAR(100);
    DECLARE posicion_inicio VARCHAR(50);
    DECLARE posicion_fin VARCHAR(50);
    DECLARE archivo_binlog VARCHAR(100);
    
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET nombre_archivo = CONCAT('/backups/empresa_incremental_', fecha_backup, '.sql');
    
    -- Obtener posición actual del binlog
    SHOW MASTER STATUS INTO @pos, @file;
    SET posicion_inicio = @pos;
    SET archivo_binlog = @file;
    
    -- Registrar inicio
    INSERT INTO backup_incremental (archivo, posicion_binlog_inicio, archivo_binlog)
    VALUES (nombre_archivo, posicion_inicio, archivo_binlog);
    
    -- Simular backup incremental
    -- SET @sql = CONCAT('mysqlbinlog --start-position=', posicion_anterior, ' ', archivo_binlog, ' > ', nombre_archivo);
    
    -- Obtener posición final
    SHOW MASTER STATUS INTO @pos, @file;
    SET posicion_fin = @pos;
    
    -- Actualizar registro
    UPDATE backup_incremental 
    SET posicion_binlog_fin = posicion_fin,
        estado = 'COMPLETADO'
    WHERE archivo = nombre_archivo;
END //
DELIMITER ;
```

### Ejercicio 3: Sistema de Retención de Backups
```sql
-- Crear tabla de políticas de retención
CREATE TABLE politicas_retencion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    retencion_dias INT,
    comprimir BOOLEAN DEFAULT TRUE,
    mover_archivo BOOLEAN DEFAULT FALSE,
    ubicacion_archivo VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar políticas
INSERT INTO politicas_retencion (tipo_backup, retencion_dias, comprimir, mover_archivo, ubicacion_archivo)
VALUES 
('COMPLETO', 90, TRUE, TRUE, '/backups/largo_plazo/'),
('INCREMENTAL', 30, TRUE, FALSE, NULL),
('DIFERENCIAL', 60, TRUE, TRUE, '/backups/medio_plazo/');

-- Procedimiento para limpieza de backups
DELIMITER //
CREATE PROCEDURE limpiar_backups_antiguos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tipo VARCHAR(20);
    DECLARE v_retencion INT;
    DECLARE v_comprimir BOOLEAN;
    DECLARE v_mover BOOLEAN;
    DECLARE v_ubicacion VARCHAR(255);
    
    DECLARE cur CURSOR FOR
        SELECT tipo_backup, retencion_dias, comprimir, mover_archivo, ubicacion_archivo
        FROM politicas_retencion
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tipo, v_retencion, v_comprimir, v_mover, v_ubicacion;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Eliminar backups antiguos
        DELETE FROM backup_completo 
        WHERE tipo_backup = v_tipo 
        AND fecha_backup < DATE_SUB(NOW(), INTERVAL v_retencion DAY);
        
        DELETE FROM backup_incremental 
        WHERE fecha_backup < DATE_SUB(NOW(), INTERVAL v_retencion DAY);
        
        -- Aquí se ejecutarían comandos del sistema para mover/comprimir archivos
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 4: Recuperación Punto en Tiempo
```sql
-- Crear tabla de recuperaciones
CREATE TABLE recuperaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_objetivo DATETIME,
    tipo_recuperacion ENUM('COMPLETA', 'PUNTO_TIEMPO', 'TABLA_ESPECIFICA'),
    base_datos VARCHAR(100),
    tabla_especifica VARCHAR(100),
    estado ENUM('SOLICITADA', 'EN_PROCESO', 'COMPLETADA', 'ERROR'),
    usuario_solicitante VARCHAR(100),
    observaciones TEXT
);

-- Procedimiento para recuperación punto en tiempo
DELIMITER //
CREATE PROCEDURE recuperar_punto_tiempo(
    IN p_fecha_objetivo DATETIME,
    IN p_base_datos VARCHAR(100),
    IN p_usuario VARCHAR(100)
)
BEGIN
    DECLARE v_backup_completo VARCHAR(255);
    DECLARE v_fecha_backup DATETIME;
    
    -- Registrar solicitud
    INSERT INTO recuperaciones (fecha_objetivo, tipo_recuperacion, base_datos, usuario_solicitante, estado)
    VALUES (p_fecha_objetivo, 'PUNTO_TIEMPO', p_base_datos, p_usuario, 'SOLICITADA');
    
    -- Buscar backup completo más reciente antes de la fecha objetivo
    SELECT archivo, fecha_backup INTO v_backup_completo, v_fecha_backup
    FROM backup_completo
    WHERE fecha_backup <= p_fecha_objetivo
    AND estado = 'COMPLETADO'
    ORDER BY fecha_backup DESC
    LIMIT 1;
    
    -- Actualizar estado
    UPDATE recuperaciones 
    SET estado = 'EN_PROCESO'
    WHERE fecha_objetivo = p_fecha_objetivo AND base_datos = p_base_datos;
    
    -- Aquí se ejecutarían los comandos de recuperación:
    -- 1. Restaurar backup completo
    -- 2. Aplicar binlogs hasta fecha objetivo
    -- 3. Verificar integridad
    
    -- Marcar como completada
    UPDATE recuperaciones 
    SET estado = 'COMPLETADA',
        observaciones = CONCAT('Recuperación completada desde backup: ', v_backup_completo)
    WHERE fecha_objetivo = p_fecha_objetivo AND base_datos = p_base_datos;
END //
DELIMITER ;
```

### Ejercicio 5: Monitoreo y Alertas de Backup
```sql
-- Crear tabla de alertas
CREATE TABLE alertas_backup (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta ENUM('BACKUP_FALLIDO', 'BACKUP_TARDIO', 'ESPACIO_INSUFICIENTE', 'CHECKSUM_ERROR'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    resuelto BOOLEAN DEFAULT FALSE,
    fecha_resolucion TIMESTAMP NULL
);

-- Procedimiento para verificar estado de backups
DELIMITER //
CREATE PROCEDURE verificar_estado_backups()
BEGIN
    DECLARE v_backups_fallidos INT;
    DECLARE v_backups_tardios INT;
    DECLARE v_espacio_disponible DECIMAL(10,2);
    
    -- Verificar backups fallidos en las últimas 24 horas
    SELECT COUNT(*) INTO v_backups_fallidos
    FROM backup_completo
    WHERE fecha_backup > DATE_SUB(NOW(), INTERVAL 24 HOUR)
    AND estado = 'ERROR';
    
    IF v_backups_fallidos > 0 THEN
        INSERT INTO alertas_backup (tipo_alerta, descripcion, nivel_critico)
        VALUES ('BACKUP_FALLIDO', CONCAT('Se detectaron ', v_backups_fallidos, ' backups fallidos en las últimas 24 horas'), 'ALTO');
    END IF;
    
    -- Verificar backups tardíos (más de 2 horas de retraso)
    SELECT COUNT(*) INTO v_backups_tardios
    FROM backup_completo
    WHERE fecha_backup < DATE_SUB(NOW(), INTERVAL 26 HOUR)
    AND estado = 'INICIADO';
    
    IF v_backups_tardios > 0 THEN
        INSERT INTO alertas_backup (tipo_alerta, descripcion, nivel_critico)
        VALUES ('BACKUP_TARDIO', CONCAT('Se detectaron ', v_backups_tardios, ' backups con más de 2 horas de retraso'), 'MEDIO');
    END IF;
    
    -- Verificar espacio en disco (simulado)
    SET v_espacio_disponible = 1000; -- MB disponibles
    
    IF v_espacio_disponible < 100 THEN
        INSERT INTO alertas_backup (tipo_alerta, descripcion, nivel_critico)
        VALUES ('ESPACIO_INSUFICIENTE', CONCAT('Espacio disponible: ', v_espacio_disponible, ' MB'), 'CRITICO');
    END IF;
END //
DELIMITER ;

-- Evento para verificación automática
CREATE EVENT verificar_backups_horario
ON SCHEDULE EVERY 1 HOUR
STARTS '2024-01-01 00:00:00'
DO
  CALL verificar_estado_backups();
```

### Ejercicio 6: Backup de Tablas Específicas
```sql
-- Crear tabla de configuración de tablas
CREATE TABLE configuracion_tablas_backup (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tabla VARCHAR(100),
    frecuencia_backup ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_backup TIME,
    activo BOOLEAN DEFAULT TRUE,
    incluir_datos BOOLEAN DEFAULT TRUE,
    incluir_estructura BOOLEAN DEFAULT TRUE
);

-- Insertar configuraciones
INSERT INTO configuracion_tablas_backup (nombre_tabla, frecuencia_backup, hora_backup, incluir_datos, incluir_estructura)
VALUES 
('clientes', 'DIARIO', '01:30:00', TRUE, TRUE),
('ventas', 'DIARIO', '01:45:00', TRUE, TRUE),
('productos', 'SEMANAL', '02:00:00', TRUE, TRUE);

-- Procedimiento para backup de tabla específica
DELIMITER //
CREATE PROCEDURE backup_tabla_especifica(IN p_tabla VARCHAR(100))
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    DECLARE nombre_archivo VARCHAR(100);
    DECLARE incluir_datos BOOLEAN;
    DECLARE incluir_estructura BOOLEAN;
    
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET nombre_archivo = CONCAT('/backups/tabla_', p_tabla, '_', fecha_backup, '.sql');
    
    -- Obtener configuración de la tabla
    SELECT incluir_datos, incluir_estructura INTO incluir_datos, incluir_estructura
    FROM configuracion_tablas_backup
    WHERE nombre_tabla = p_tabla AND activo = TRUE;
    
    -- Registrar backup
    INSERT INTO backup_tablas (tabla, archivo, fecha_backup, estado)
    VALUES (p_tabla, nombre_archivo, NOW(), 'INICIADO');
    
    -- Construir comando mysqldump
    SET @comando = CONCAT('mysqldump -u root -p empresa ', p_tabla);
    
    IF incluir_estructura = FALSE THEN
        SET @comando = CONCAT(@comando, ' --no-create-info');
    END IF;
    
    IF incluir_datos = FALSE THEN
        SET @comando = CONCAT(@comando, ' --no-data');
    END IF;
    
    SET @comando = CONCAT(@comando, ' > ', nombre_archivo);
    
    -- Ejecutar backup (simulado)
    -- PREPARE stmt FROM @comando;
    -- EXECUTE stmt;
    -- DEALLOCATE PREPARE stmt;
    
    -- Actualizar estado
    UPDATE backup_tablas 
    SET estado = 'COMPLETADO'
    WHERE tabla = p_tabla AND archivo = nombre_archivo;
END //
DELIMITER ;
```

### Ejercicio 7: Sistema de Compresión de Backups
```sql
-- Crear tabla de backups comprimidos
CREATE TABLE backups_comprimidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    archivo_original VARCHAR(255),
    archivo_comprimido VARCHAR(255),
    fecha_compresion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tamaño_original_mb DECIMAL(10,2),
    tamaño_comprimido_mb DECIMAL(10,2),
    ratio_compresion DECIMAL(5,2),
    estado ENUM('COMPRIMIENDO', 'COMPLETADO', 'ERROR') DEFAULT 'COMPRIMIENDO'
);

-- Procedimiento para comprimir backups
DELIMITER //
CREATE PROCEDURE comprimir_backup(IN p_archivo_original VARCHAR(255))
BEGIN
    DECLARE v_archivo_comprimido VARCHAR(255);
    DECLARE v_tamaño_original DECIMAL(10,2);
    DECLARE v_tamaño_comprimido DECIMAL(10,2);
    DECLARE v_ratio DECIMAL(5,2);
    
    -- Generar nombre del archivo comprimido
    SET v_archivo_comprimido = CONCAT(p_archivo_original, '.gz');
    
    -- Registrar inicio de compresión
    INSERT INTO backups_comprimidos (archivo_original, archivo_comprimido, tamaño_original_mb)
    VALUES (p_archivo_original, v_archivo_comprimido, 100); -- Simulado
    
    -- Simular compresión
    -- SET @comando = CONCAT('gzip ', p_archivo_original);
    -- PREPARE stmt FROM @comando;
    -- EXECUTE stmt;
    -- DEALLOCATE PREPARE stmt;
    
    -- Calcular tamaños (simulado)
    SET v_tamaño_original = 100;
    SET v_tamaño_comprimido = 25;
    SET v_ratio = (v_tamaño_comprimido / v_tamaño_original) * 100;
    
    -- Actualizar registro
    UPDATE backups_comprimidos 
    SET tamaño_comprimido_mb = v_tamaño_comprimido,
        ratio_compresion = v_ratio,
        estado = 'COMPLETADO'
    WHERE archivo_original = p_archivo_original;
END //
DELIMITER ;
```

### Ejercicio 8: Backup en la Nube
```sql
-- Crear tabla de configuración de nube
CREATE TABLE configuracion_nube (
    id INT PRIMARY KEY AUTO_INCREMENT,
    proveedor ENUM('AWS_S3', 'GOOGLE_CLOUD', 'AZURE_BLOB'),
    bucket_nombre VARCHAR(100),
    region VARCHAR(50),
    credenciales JSON,
    activo BOOLEAN DEFAULT TRUE,
    encriptacion BOOLEAN DEFAULT TRUE
);

-- Insertar configuración
INSERT INTO configuracion_nube (proveedor, bucket_nombre, region, credenciales, encriptacion)
VALUES ('AWS_S3', 'mi-backup-bucket', 'us-east-1', 
        JSON_OBJECT('access_key', 'AKIA...', 'secret_key', '...'), TRUE);

-- Procedimiento para subir backup a la nube
DELIMITER //
CREATE PROCEDURE subir_backup_nube(IN p_archivo_local VARCHAR(255))
BEGIN
    DECLARE v_proveedor VARCHAR(20);
    DECLARE v_bucket VARCHAR(100);
    DECLARE v_region VARCHAR(50);
    DECLARE v_encriptacion BOOLEAN;
    
    -- Obtener configuración
    SELECT proveedor, bucket_nombre, region, encriptacion
    INTO v_proveedor, v_bucket, v_region, v_encriptacion
    FROM configuracion_nube
    WHERE activo = TRUE
    LIMIT 1;
    
    -- Registrar inicio de subida
    INSERT INTO backup_nube (archivo_local, proveedor, bucket, fecha_subida, estado)
    VALUES (p_archivo_local, v_proveedor, v_bucket, NOW(), 'SUBIENDO');
    
    -- Construir comando de subida según proveedor
    IF v_proveedor = 'AWS_S3' THEN
        SET @comando = CONCAT('aws s3 cp ', p_archivo_local, ' s3://', v_bucket, '/');
    ELSEIF v_proveedor = 'GOOGLE_CLOUD' THEN
        SET @comando = CONCAT('gsutil cp ', p_archivo_local, ' gs://', v_bucket, '/');
    END IF;
    
    -- Agregar encriptación si está habilitada
    IF v_encriptacion = TRUE THEN
        SET @comando = CONCAT(@comando, ' --sse');
    END IF;
    
    -- Ejecutar comando (simulado)
    -- PREPARE stmt FROM @comando;
    -- EXECUTE stmt;
    -- DEALLOCATE PREPARE stmt;
    
    -- Actualizar estado
    UPDATE backup_nube 
    SET estado = 'COMPLETADO'
    WHERE archivo_local = p_archivo_local;
END //
DELIMITER ;
```

### Ejercicio 9: Sistema de Pruebas de Recuperación
```sql
-- Crear tabla de pruebas de recuperación
CREATE TABLE pruebas_recuperacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_prueba TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_prueba ENUM('COMPLETA', 'PUNTO_TIEMPO', 'TABLA_ESPECIFICA'),
    backup_utilizado VARCHAR(255),
    tiempo_recuperacion_minutos INT,
    datos_verificados BOOLEAN DEFAULT FALSE,
    integridad_ok BOOLEAN DEFAULT FALSE,
    observaciones TEXT,
    estado ENUM('INICIADA', 'COMPLETADA', 'FALLIDA') DEFAULT 'INICIADA'
);

-- Procedimiento para prueba de recuperación
DELIMITER //
CREATE PROCEDURE ejecutar_prueba_recuperacion(
    IN p_tipo_prueba VARCHAR(20),
    IN p_backup_archivo VARCHAR(255)
)
BEGIN
    DECLARE v_inicio TIMESTAMP;
    DECLARE v_fin TIMESTAMP;
    DECLARE v_tiempo_minutos INT;
    
    SET v_inicio = NOW();
    
    -- Registrar inicio de prueba
    INSERT INTO pruebas_recuperacion (tipo_prueba, backup_utilizado, fecha_prueba)
    VALUES (p_tipo_prueba, p_backup_archivo, v_inicio);
    
    -- Ejecutar recuperación de prueba
    IF p_tipo_prueba = 'COMPLETA' THEN
        -- Restaurar backup completo en base de datos de prueba
        -- SET @sql = CONCAT('mysql -u root -p empresa_prueba < ', p_backup_archivo);
    ELSEIF p_tipo_prueba = 'PUNTO_TIEMPO' THEN
        -- Restaurar hasta punto específico
        -- Ejecutar comandos de recuperación punto en tiempo
    END IF;
    
    -- Verificar integridad de datos
    CALL verificar_integridad_datos('empresa_prueba');
    
    SET v_fin = NOW();
    SET v_tiempo_minutos = TIMESTAMPDIFF(MINUTE, v_inicio, v_fin);
    
    -- Actualizar resultados
    UPDATE pruebas_recuperacion 
    SET tiempo_recuperacion_minutos = v_tiempo_minutos,
        datos_verificados = TRUE,
        integridad_ok = TRUE,
        estado = 'COMPLETADA',
        observaciones = 'Prueba de recuperación exitosa'
    WHERE backup_utilizado = p_backup_archivo 
    AND fecha_prueba = v_inicio;
END //
DELIMITER ;

-- Procedimiento para verificar integridad
DELIMITER //
CREATE PROCEDURE verificar_integridad_datos(IN p_base_datos VARCHAR(100))
BEGIN
    DECLARE v_tablas_verificadas INT DEFAULT 0;
    DECLARE v_errores_encontrados INT DEFAULT 0;
    
    -- Verificar integridad referencial
    -- Verificar checksums de tablas
    -- Verificar índices
    
    -- Simular verificación
    SET v_tablas_verificadas = 10;
    SET v_errores_encontrados = 0;
    
    -- Registrar resultados
    INSERT INTO verificaciones_integridad (base_datos, fecha_verificacion, tablas_verificadas, errores_encontrados)
    VALUES (p_base_datos, NOW(), v_tablas_verificadas, v_errores_encontrados);
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Gestión de Backups
```sql
-- Crear tabla de dashboard de backups
CREATE TABLE dashboard_backups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_backups_hoy INT,
    backups_exitosos_hoy INT,
    backups_fallidos_hoy INT,
    espacio_utilizado_gb DECIMAL(10,2),
    proximo_backup DATETIME,
    estado_sistema ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Procedimiento para actualizar dashboard
DELIMITER //
CREATE PROCEDURE actualizar_dashboard_backups()
BEGIN
    DECLARE v_total_backups INT;
    DECLARE v_backups_exitosos INT;
    DECLARE v_backups_fallidos INT;
    DECLARE v_espacio_utilizado DECIMAL(10,2);
    DECLARE v_proximo_backup DATETIME;
    DECLARE v_estado VARCHAR(20);
    
    -- Calcular estadísticas del día
    SELECT COUNT(*) INTO v_total_backups
    FROM backup_completo
    WHERE DATE(fecha_backup) = CURDATE();
    
    SELECT COUNT(*) INTO v_backups_exitosos
    FROM backup_completo
    WHERE DATE(fecha_backup) = CURDATE() AND estado = 'COMPLETADO';
    
    SELECT COUNT(*) INTO v_backups_fallidos
    FROM backup_completo
    WHERE DATE(fecha_backup) = CURDATE() AND estado = 'ERROR';
    
    -- Calcular espacio utilizado (simulado)
    SELECT COALESCE(SUM(tamaño_mb), 0) / 1024 INTO v_espacio_utilizado
    FROM backup_completo
    WHERE fecha_backup > DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- Obtener próximo backup programado
    SELECT MIN(DATE_ADD(CURDATE(), INTERVAL 1 DAY) + INTERVAL 2 HOUR) INTO v_proximo_backup;
    
    -- Determinar estado del sistema
    IF v_backups_fallidos > 0 THEN
        SET v_estado = 'CRITICO';
    ELSEIF v_backups_exitosos < v_total_backups THEN
        SET v_estado = 'ADVERTENCIA';
    ELSE
        SET v_estado = 'NORMAL';
    END IF;
    
    -- Actualizar dashboard
    INSERT INTO dashboard_backups (
        total_backups_hoy, backups_exitosos_hoy, backups_fallidos_hoy,
        espacio_utilizado_gb, proximo_backup, estado_sistema
    ) VALUES (
        v_total_backups, v_backups_exitosos, v_backups_fallidos,
        v_espacio_utilizado, v_proximo_backup, v_estado
    );
END //
DELIMITER ;

-- Evento para actualización automática del dashboard
CREATE EVENT actualizar_dashboard_horario
ON SCHEDULE EVERY 1 HOUR
STARTS '2024-01-01 00:00:00'
DO
  CALL actualizar_dashboard_backups();

-- Vista para reporte de backups
CREATE VIEW reporte_backups AS
SELECT 
    DATE(fecha_backup) as fecha,
    COUNT(*) as total_backups,
    SUM(CASE WHEN estado = 'COMPLETADO' THEN 1 ELSE 0 END) as exitosos,
    SUM(CASE WHEN estado = 'ERROR' THEN 1 ELSE 0 END) as fallidos,
    AVG(duracion_minutos) as duracion_promedio,
    SUM(tamaño_mb) as tamaño_total_mb
FROM backup_completo
WHERE fecha_backup > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(fecha_backup)
ORDER BY fecha DESC;
```

## Resumen
En esta clase hemos aprendido sobre:
- Tipos de backup (completo, incremental, diferencial)
- Configuración de binlogs para backups incrementales
- Automatización de backups con eventos
- Procedimientos de recuperación documentados
- Monitoreo y verificación de integridad
- Sistemas de retención y limpieza
- Backup de tablas específicas
- Compresión y almacenamiento en la nube
- Pruebas de recuperación
- Dashboards y reportes de backup

## Próxima Clase
En la siguiente clase aprenderemos sobre replicación de bases de datos, incluyendo configuración de replicación maestro-esclavo, replicación circular y gestión de conflictos.
