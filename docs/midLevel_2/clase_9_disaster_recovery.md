# Clase 9: Disaster Recovery - Nivel Mid-Level

## Introducción
El disaster recovery es fundamental para garantizar la continuidad del negocio ante desastres. En esta clase aprenderemos sobre planes de recuperación, procedimientos de emergencia y sistemas de recuperación ante desastres.

## Conceptos Clave

### Disaster Recovery
**Definición**: Conjunto de políticas y procedimientos para recuperar sistemas después de un desastre.
**Componentes**:
- Plan de recuperación
- Procedimientos de emergencia
- Sistemas de respaldo
- Centros de recuperación

### RTO y RPO
**Definición**: Métricas clave para disaster recovery.
**RTO (Recovery Time Objective)**: Tiempo máximo para recuperar el sistema.
**RPO (Recovery Point Objective)**: Pérdida máxima de datos aceptable.

### Tipos de Desastres
**Definición**: Diferentes escenarios que pueden afectar los sistemas.
**Categorías**:
- Desastres naturales
- Fallos de hardware
- Errores humanos
- Ataques cibernéticos

## Ejemplos Prácticos

### 1. Plan de Disaster Recovery

```sql
-- Crear tabla de planes de disaster recovery
CREATE TABLE planes_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_plan VARCHAR(100),
    descripcion TEXT,
    rto_minutos INT,
    rpo_minutos INT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar planes
INSERT INTO planes_disaster_recovery (nombre_plan, descripcion, rto_minutos, rpo_minutos, nivel_critico)
VALUES 
('Plan_Sistema_Critico', 'Recuperación del sistema crítico de producción', 60, 15, 'CRITICO'),
('Plan_Sistema_Desarrollo', 'Recuperación del sistema de desarrollo', 240, 60, 'MEDIO'),
('Plan_Sistema_Pruebas', 'Recuperación del sistema de pruebas', 480, 120, 'BAJO');

-- Procedimiento para activar plan de disaster recovery
DELIMITER //
CREATE PROCEDURE activar_plan_disaster_recovery(IN p_plan_id INT)
BEGIN
    DECLARE v_nombre_plan VARCHAR(100);
    DECLARE v_rto_minutos INT;
    DECLARE v_rpo_minutos INT;
    DECLARE v_nivel_critico VARCHAR(20);
    
    -- Obtener información del plan
    SELECT nombre_plan, rto_minutos, rpo_minutos, nivel_critico
    INTO v_nombre_plan, v_rto_minutos, v_rpo_minutos, v_nivel_critico
    FROM planes_disaster_recovery
    WHERE id = p_plan_id;
    
    -- Registrar activación
    INSERT INTO log_disaster_recovery (plan_id, accion, fecha_accion, estado)
    VALUES (p_plan_id, 'ACTIVACION', NOW(), 'INICIADO');
    
    -- Ejecutar procedimientos de recuperación
    CALL ejecutar_procedimientos_recuperacion(p_plan_id);
    
    -- Marcar como completado
    UPDATE log_disaster_recovery 
    SET estado = 'COMPLETADO'
    WHERE plan_id = p_plan_id AND accion = 'ACTIVACION';
END //
DELIMITER ;
```

### 2. Procedimientos de Recuperación

```sql
-- Crear tabla de procedimientos de recuperación
CREATE TABLE procedimientos_recuperacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    nombre_procedimiento VARCHAR(100),
    descripcion TEXT,
    orden_ejecucion INT,
    tiempo_estimado_minutos INT,
    dependencias JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar procedimientos
INSERT INTO procedimientos_recuperacion (plan_id, nombre_procedimiento, descripcion, orden_ejecucion, tiempo_estimado_minutos)
VALUES 
(1, 'Verificar_Estado_Sistema', 'Verificar el estado actual del sistema', 1, 5),
(1, 'Restaurar_Backup_Completo', 'Restaurar backup completo de la base de datos', 2, 30),
(1, 'Aplicar_Logs_Incrementales', 'Aplicar logs incrementales hasta el punto de fallo', 3, 15),
(1, 'Verificar_Integridad_Datos', 'Verificar integridad de los datos restaurados', 4, 10),
(1, 'Reiniciar_Aplicaciones', 'Reiniciar aplicaciones y servicios', 5, 5);

-- Procedimiento para ejecutar procedimientos de recuperación
DELIMITER //
CREATE PROCEDURE ejecutar_procedimientos_recuperacion(IN p_plan_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_procedimiento_id INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_descripcion TEXT;
    DECLARE v_orden INT;
    DECLARE v_tiempo_estimado INT;
    
    DECLARE cur CURSOR FOR
        SELECT id, nombre_procedimiento, descripcion, orden_ejecucion, tiempo_estimado_minutos
        FROM procedimientos_recuperacion
        WHERE plan_id = p_plan_id AND activo = TRUE
        ORDER BY orden_ejecucion;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_procedimiento_id, v_nombre, v_descripcion, v_orden, v_tiempo_estimado;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Registrar inicio del procedimiento
        INSERT INTO log_procedimientos_recuperacion (procedimiento_id, accion, fecha_inicio, estado)
        VALUES (v_procedimiento_id, 'INICIO', NOW(), 'EJECUTANDO');
        
        -- Ejecutar procedimiento según el tipo
        IF v_nombre = 'Verificar_Estado_Sistema' THEN
            CALL verificar_estado_sistema();
        ELSEIF v_nombre = 'Restaurar_Backup_Completo' THEN
            CALL restaurar_backup_completo();
        ELSEIF v_nombre = 'Aplicar_Logs_Incrementales' THEN
            CALL aplicar_logs_incrementales();
        ELSEIF v_nombre = 'Verificar_Integridad_Datos' THEN
            CALL verificar_integridad_datos();
        ELSEIF v_nombre = 'Reiniciar_Aplicaciones' THEN
            CALL reiniciar_aplicaciones();
        END IF;
        
        -- Marcar como completado
        UPDATE log_procedimientos_recuperacion 
        SET estado = 'COMPLETADO', fecha_fin = NOW()
        WHERE procedimiento_id = v_procedimiento_id AND accion = 'INICIO';
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### 3. Sistema de Monitoreo de Disaster Recovery

```sql
-- Crear tabla de monitoreo de disaster recovery
CREATE TABLE monitoreo_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_sistema ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO', 'FALLO'),
    tiempo_respuesta_ms INT,
    disponibilidad_porcentaje DECIMAL(5,2),
    observaciones TEXT
);

-- Procedimiento para monitorear disaster recovery
DELIMITER //
CREATE PROCEDURE monitorear_disaster_recovery()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_plan_id INT;
    DECLARE v_nombre_plan VARCHAR(100);
    DECLARE v_rto_minutos INT;
    DECLARE v_estado_sistema VARCHAR(20);
    DECLARE v_tiempo_respuesta INT;
    DECLARE v_disponibilidad DECIMAL(5,2);
    
    DECLARE cur CURSOR FOR
        SELECT id, nombre_plan, rto_minutos
        FROM planes_disaster_recovery
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_plan_id, v_nombre_plan, v_rto_minutos;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Simular verificación del sistema
        SET v_tiempo_respuesta = FLOOR(RAND() * 1000);
        SET v_disponibilidad = ROUND(RAND() * 100, 2);
        
        -- Determinar estado del sistema
        IF v_disponibilidad >= 99.9 THEN
            SET v_estado_sistema = 'NORMAL';
        ELSEIF v_disponibilidad >= 95.0 THEN
            SET v_estado_sistema = 'ADVERTENCIA';
        ELSEIF v_disponibilidad >= 90.0 THEN
            SET v_estado_sistema = 'CRITICO';
        ELSE
            SET v_estado_sistema = 'FALLO';
        END IF;
        
        -- Registrar monitoreo
        INSERT INTO monitoreo_disaster_recovery (plan_id, estado_sistema, tiempo_respuesta_ms, disponibilidad_porcentaje)
        VALUES (v_plan_id, v_estado_sistema, v_tiempo_respuesta, v_disponibilidad);
        
        -- Generar alertas si es necesario
        IF v_estado_sistema IN ('CRITICO', 'FALLO') THEN
            INSERT INTO alertas_disaster_recovery (plan_id, tipo_alerta, descripcion, nivel_critico)
            VALUES (v_plan_id, 'SISTEMA_CRITICO', 
                    CONCAT('Sistema en estado ', v_estado_sistema, ' - Disponibilidad: ', v_disponibilidad, '%'), 
                    'CRITICO');
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Plan de Recuperación Automático
```sql
-- Crear tabla de configuración de recuperación automática
CREATE TABLE configuracion_recuperacion_automatica (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    umbral_disponibilidad DECIMAL(5,2),
    tiempo_espera_minutos INT,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración
INSERT INTO configuracion_recuperacion_automatica (plan_id, umbral_disponibilidad, tiempo_espera_minutos)
VALUES (1, 95.0, 5);

-- Procedimiento para recuperación automática
DELIMITER //
CREATE PROCEDURE ejecutar_recuperacion_automatica()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_plan_id INT;
    DECLARE v_umbral DECIMAL(5,2);
    DECLARE v_tiempo_espera INT;
    DECLARE v_disponibilidad_actual DECIMAL(5,2);
    DECLARE v_estado_actual VARCHAR(20);
    
    DECLARE cur CURSOR FOR
        SELECT plan_id, umbral_disponibilidad, tiempo_espera_minutos
        FROM configuracion_recuperacion_automatica
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_plan_id, v_umbral, v_tiempo_espera;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Obtener disponibilidad actual
        SELECT disponibilidad_porcentaje, estado_sistema
        INTO v_disponibilidad_actual, v_estado_actual
        FROM monitoreo_disaster_recovery
        WHERE plan_id = v_plan_id
        ORDER BY fecha_verificacion DESC
        LIMIT 1;
        
        -- Verificar si se debe activar recuperación
        IF v_disponibilidad_actual < v_umbral AND v_estado_actual = 'FALLO' THEN
            -- Esperar tiempo configurado
            SELECT SLEEP(v_tiempo_espera * 60);
            
            -- Verificar nuevamente
            SELECT disponibilidad_porcentaje, estado_sistema
            INTO v_disponibilidad_actual, v_estado_actual
            FROM monitoreo_disaster_recovery
            WHERE plan_id = v_plan_id
            ORDER BY fecha_verificacion DESC
            LIMIT 1;
            
            -- Si sigue en fallo, activar recuperación
            IF v_disponibilidad_actual < v_umbral AND v_estado_actual = 'FALLO' THEN
                CALL activar_plan_disaster_recovery(v_plan_id);
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 2: Sistema de Alertas de Disaster Recovery
```sql
-- Crear tabla de alertas
CREATE TABLE alertas_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_alerta VARCHAR(100),
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelto BOOLEAN DEFAULT FALSE
);

-- Procedimiento para generar alertas
DELIMITER //
CREATE PROCEDURE generar_alertas_disaster_recovery()
BEGIN
    DECLARE v_planes_criticos INT;
    DECLARE v_planes_fallo INT;
    DECLARE v_tiempo_respuesta_alto INT;
    
    -- Verificar planes en estado crítico
    SELECT COUNT(*) INTO v_planes_criticos
    FROM monitoreo_disaster_recovery
    WHERE estado_sistema = 'CRITICO'
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_planes_criticos > 0 THEN
        INSERT INTO alertas_disaster_recovery (plan_id, tipo_alerta, descripcion, nivel_critico)
        VALUES (NULL, 'PLANES_CRITICOS', CONCAT('Se detectaron ', v_planes_criticos, ' planes en estado crítico'), 'ALTO');
    END IF;
    
    -- Verificar planes en fallo
    SELECT COUNT(*) INTO v_planes_fallo
    FROM monitoreo_disaster_recovery
    WHERE estado_sistema = 'FALLO'
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_planes_fallo > 0 THEN
        INSERT INTO alertas_disaster_recovery (plan_id, tipo_alerta, descripcion, nivel_critico)
        VALUES (NULL, 'PLANES_FALLO', CONCAT('Se detectaron ', v_planes_fallo, ' planes en fallo'), 'CRITICO');
    END IF;
    
    -- Verificar tiempo de respuesta alto
    SELECT COUNT(*) INTO v_tiempo_respuesta_alto
    FROM monitoreo_disaster_recovery
    WHERE tiempo_respuesta_ms > 5000
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_tiempo_respuesta_alto > 0 THEN
        INSERT INTO alertas_disaster_recovery (plan_id, tipo_alerta, descripcion, nivel_critico)
        VALUES (NULL, 'TIEMPO_RESPUESTA_ALTO', CONCAT('Se detectaron ', v_tiempo_respuesta_alto, ' planes con tiempo de respuesta alto'), 'MEDIO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 3: Pruebas de Disaster Recovery
```sql
-- Crear tabla de pruebas de disaster recovery
CREATE TABLE pruebas_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_prueba ENUM('COMPLETA', 'PARCIAL', 'SIMULADA'),
    fecha_prueba TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duracion_minutos INT,
    resultado ENUM('EXITOSA', 'FALLIDA', 'PARCIAL'),
    observaciones TEXT
);

-- Procedimiento para ejecutar pruebas
DELIMITER //
CREATE PROCEDURE ejecutar_prueba_disaster_recovery(IN p_plan_id INT, IN p_tipo_prueba VARCHAR(20))
BEGIN
    DECLARE v_inicio TIMESTAMP;
    DECLARE v_fin TIMESTAMP;
    DECLARE v_duracion INT;
    DECLARE v_resultado VARCHAR(20);
    DECLARE v_observaciones TEXT;
    
    SET v_inicio = NOW();
    
    -- Registrar inicio de prueba
    INSERT INTO pruebas_disaster_recovery (plan_id, tipo_prueba, fecha_prueba)
    VALUES (p_plan_id, p_tipo_prueba, v_inicio);
    
    -- Ejecutar prueba según el tipo
    IF p_tipo_prueba = 'COMPLETA' THEN
        CALL ejecutar_procedimientos_recuperacion(p_plan_id);
        SET v_resultado = 'EXITOSA';
        SET v_observaciones = 'Prueba completa ejecutada exitosamente';
    ELSEIF p_tipo_prueba = 'PARCIAL' THEN
        -- Ejecutar solo algunos procedimientos
        CALL verificar_estado_sistema();
        CALL verificar_integridad_datos();
        SET v_resultado = 'EXITOSA';
        SET v_observaciones = 'Prueba parcial ejecutada exitosamente';
    ELSEIF p_tipo_prueba = 'SIMULADA' THEN
        -- Simular ejecución
        SELECT SLEEP(1);
        SET v_resultado = 'EXITOSA';
        SET v_observaciones = 'Prueba simulada ejecutada exitosamente';
    END IF;
    
    SET v_fin = NOW();
    SET v_duracion = TIMESTAMPDIFF(MINUTE, v_inicio, v_fin);
    
    -- Actualizar resultado de la prueba
    UPDATE pruebas_disaster_recovery 
    SET duracion_minutos = v_duracion,
        resultado = v_resultado,
        observaciones = v_observaciones
    WHERE plan_id = p_plan_id AND fecha_prueba = v_inicio;
END //
DELIMITER ;
```

### Ejercicio 4: Sistema de Notificaciones de Emergencia
```sql
-- Crear tabla de notificaciones de emergencia
CREATE TABLE notificaciones_emergencia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_notificacion ENUM('EMAIL', 'SMS', 'WEBHOOK', 'TELEFONO'),
    destinatario VARCHAR(100),
    mensaje TEXT,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'ENVIADO', 'FALLIDO') DEFAULT 'PENDIENTE'
);

-- Procedimiento para enviar notificaciones de emergencia
DELIMITER //
CREATE PROCEDURE enviar_notificaciones_emergencia(IN p_plan_id INT)
BEGIN
    DECLARE v_nombre_plan VARCHAR(100);
    DECLARE v_nivel_critico VARCHAR(20);
    DECLARE v_mensaje TEXT;
    
    -- Obtener información del plan
    SELECT nombre_plan, nivel_critico
    INTO v_nombre_plan, v_nivel_critico
    FROM planes_disaster_recovery
    WHERE id = p_plan_id;
    
    -- Construir mensaje de emergencia
    SET v_mensaje = CONCAT(
        'ALERTA DE EMERGENCIA - DISASTER RECOVERY\n',
        'Plan: ', v_nombre_plan, '\n',
        'Nivel: ', v_nivel_critico, '\n',
        'Fecha: ', NOW(), '\n',
        'Se ha activado el plan de disaster recovery. Por favor, verifique el estado del sistema.'
    );
    
    -- Enviar notificaciones
    INSERT INTO notificaciones_emergencia (plan_id, tipo_notificacion, destinatario, mensaje)
    VALUES 
    (p_plan_id, 'EMAIL', 'admin@empresa.com', v_mensaje),
    (p_plan_id, 'SMS', '+1234567890', v_mensaje),
    (p_plan_id, 'WEBHOOK', 'https://hooks.slack.com/...', v_mensaje);
    
    -- Marcar como enviadas
    UPDATE notificaciones_emergencia 
    SET estado = 'ENVIADO'
    WHERE plan_id = p_plan_id;
END //
DELIMITER ;
```

### Ejercicio 5: Dashboard de Disaster Recovery
```sql
-- Crear tabla de dashboard
CREATE TABLE dashboard_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    planes_activos INT,
    planes_criticos INT,
    planes_fallo INT,
    disponibilidad_promedio DECIMAL(5,2),
    tiempo_respuesta_promedio_ms INT,
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Procedimiento para actualizar dashboard
DELIMITER //
CREATE PROCEDURE actualizar_dashboard_disaster_recovery()
BEGIN
    DECLARE v_planes_activos INT;
    DECLARE v_planes_criticos INT;
    DECLARE v_planes_fallo INT;
    DECLARE v_disponibilidad_promedio DECIMAL(5,2);
    DECLARE v_tiempo_respuesta_promedio INT;
    DECLARE v_estado_general VARCHAR(20);
    
    -- Contar planes activos
    SELECT COUNT(*) INTO v_planes_activos
    FROM planes_disaster_recovery
    WHERE activo = TRUE;
    
    -- Contar planes críticos
    SELECT COUNT(*) INTO v_planes_criticos
    FROM monitoreo_disaster_recovery
    WHERE estado_sistema = 'CRITICO'
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    -- Contar planes en fallo
    SELECT COUNT(*) INTO v_planes_fallo
    FROM monitoreo_disaster_recovery
    WHERE estado_sistema = 'FALLO'
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    -- Calcular promedios
    SELECT 
        AVG(disponibilidad_porcentaje),
        AVG(tiempo_respuesta_ms)
    INTO v_disponibilidad_promedio, v_tiempo_respuesta_promedio
    FROM monitoreo_disaster_recovery
    WHERE fecha_verificacion > DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Determinar estado general
    IF v_planes_fallo > 0 THEN
        SET v_estado_general = 'CRITICO';
    ELSEIF v_planes_criticos > 0 THEN
        SET v_estado_general = 'ADVERTENCIA';
    ELSE
        SET v_estado_general = 'NORMAL';
    END IF;
    
    -- Actualizar dashboard
    INSERT INTO dashboard_disaster_recovery (
        planes_activos, planes_criticos, planes_fallo,
        disponibilidad_promedio, tiempo_respuesta_promedio, estado_general
    ) VALUES (
        v_planes_activos, v_planes_criticos, v_planes_fallo,
        v_disponibilidad_promedio, v_tiempo_respuesta_promedio, v_estado_general
    );
END //
DELIMITER ;
```

### Ejercicio 6: Sistema de Backup para Disaster Recovery
```sql
-- Crear tabla de backups de disaster recovery
CREATE TABLE backups_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    ubicacion_backup VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('CREANDO', 'COMPLETADO', 'ERROR') DEFAULT 'CREANDO'
);

-- Procedimiento para crear backup de disaster recovery
DELIMITER //
CREATE PROCEDURE crear_backup_disaster_recovery(IN p_plan_id INT)
BEGIN
    DECLARE v_tipo_backup VARCHAR(20);
    DECLARE v_ubicacion VARCHAR(255);
    DECLARE v_archivo_backup VARCHAR(255);
    DECLARE v_fecha_backup VARCHAR(20);
    
    -- Determinar tipo de backup
    SET v_tipo_backup = 'COMPLETO';
    SET v_fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET v_archivo_backup = CONCAT('backup_dr_', p_plan_id, '_', v_fecha_backup, '.sql');
    SET v_ubicacion = CONCAT('/backups/disaster_recovery/', v_archivo_backup);
    
    -- Registrar backup
    INSERT INTO backups_disaster_recovery (plan_id, tipo_backup, ubicacion_backup)
    VALUES (p_plan_id, v_tipo_backup, v_ubicacion);
    
    -- Simular creación de backup
    -- En implementación real: mysqldump, rsync, etc.
    
    -- Marcar como completado
    UPDATE backups_disaster_recovery 
    SET estado = 'COMPLETADO', tamaño_mb = 2048
    WHERE plan_id = p_plan_id AND ubicacion_backup = v_ubicacion;
END //
DELIMITER ;
```

### Ejercicio 7: Sistema de Validación de Disaster Recovery
```sql
-- Crear tabla de validación
CREATE TABLE validacion_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_validacion VARCHAR(100),
    resultado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA'),
    detalles TEXT,
    fecha_validacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para validar disaster recovery
DELIMITER //
CREATE PROCEDURE validar_disaster_recovery(IN p_plan_id INT)
BEGIN
    DECLARE v_rto_minutos INT;
    DECLARE v_rpo_minutos INT;
    DECLARE v_tiempo_recuperacion INT;
    DECLARE v_perdida_datos INT;
    
    -- Obtener objetivos del plan
    SELECT rto_minutos, rpo_minutos
    INTO v_rto_minutos, v_rpo_minutos
    FROM planes_disaster_recovery
    WHERE id = p_plan_id;
    
    -- Simular tiempo de recuperación
    SET v_tiempo_recuperacion = FLOOR(RAND() * 120) + 30; -- 30-150 minutos
    
    -- Simular pérdida de datos
    SET v_perdida_datos = FLOOR(RAND() * 30) + 5; -- 5-35 minutos
    
    -- Validar RTO
    IF v_tiempo_recuperacion <= v_rto_minutos THEN
        INSERT INTO validacion_disaster_recovery (plan_id, tipo_validacion, resultado, detalles)
        VALUES (p_plan_id, 'RTO', 'EXITOSO', CONCAT('Tiempo de recuperación: ', v_tiempo_recuperacion, ' minutos (objetivo: ', v_rto_minutos, ')'));
    ELSE
        INSERT INTO validacion_disaster_recovery (plan_id, tipo_validacion, resultado, detalles)
        VALUES (p_plan_id, 'RTO', 'FALLIDO', CONCAT('Tiempo de recuperación: ', v_tiempo_recuperacion, ' minutos (objetivo: ', v_rto_minutos, ')'));
    END IF;
    
    -- Validar RPO
    IF v_perdida_datos <= v_rpo_minutos THEN
        INSERT INTO validacion_disaster_recovery (plan_id, tipo_validacion, resultado, detalles)
        VALUES (p_plan_id, 'RPO', 'EXITOSO', CONCAT('Pérdida de datos: ', v_perdida_datos, ' minutos (objetivo: ', v_rpo_minutos, ')'));
    ELSE
        INSERT INTO validacion_disaster_recovery (plan_id, tipo_validacion, resultado, detalles)
        VALUES (p_plan_id, 'RPO', 'FALLIDO', CONCAT('Pérdida de datos: ', v_perdida_datos, ' minutos (objetivo: ', v_rpo_minutos, ')'));
    END IF;
END //
DELIMITER ;
```

### Ejercicio 8: Sistema de Escalamiento de Emergencia
```sql
-- Crear tabla de escalamiento
CREATE TABLE escalamiento_emergencia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    nivel_escalamiento INT,
    contacto VARCHAR(100),
    metodo_contacto ENUM('EMAIL', 'SMS', 'TELEFONO'),
    tiempo_espera_minutos INT,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar niveles de escalamiento
INSERT INTO escalamiento_emergencia (plan_id, nivel_escalamiento, contacto, metodo_contacto, tiempo_espera_minutos)
VALUES 
(1, 1, 'admin@empresa.com', 'EMAIL', 5),
(1, 2, '+1234567890', 'SMS', 10),
(1, 3, '+0987654321', 'TELEFONO', 15);

-- Procedimiento para escalamiento de emergencia
DELIMITER //
CREATE PROCEDURE ejecutar_escalamiento_emergencia(IN p_plan_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_nivel INT;
    DECLARE v_contacto VARCHAR(100);
    DECLARE v_metodo VARCHAR(20);
    DECLARE v_tiempo_espera INT;
    
    DECLARE cur CURSOR FOR
        SELECT nivel_escalamiento, contacto, metodo_contacto, tiempo_espera_minutos
        FROM escalamiento_emergencia
        WHERE plan_id = p_plan_id AND activo = TRUE
        ORDER BY nivel_escalamiento;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_nivel, v_contacto, v_metodo, v_tiempo_espera;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Enviar notificación
        INSERT INTO notificaciones_emergencia (plan_id, tipo_notificacion, destinatario, mensaje)
        VALUES (p_plan_id, v_metodo, v_contacto, 
                CONCAT('Nivel de escalamiento: ', v_nivel, ' - Plan de disaster recovery activado'));
        
        -- Esperar tiempo configurado
        SELECT SLEEP(v_tiempo_espera * 60);
        
        -- Verificar si se resolvió
        -- En implementación real: verificar estado del sistema
        -- Si no se resolvió, continuar con el siguiente nivel
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 9: Sistema de Reportes de Disaster Recovery
```sql
-- Crear tabla de reportes
CREATE TABLE reportes_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_reporte VARCHAR(100),
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    periodo_inicio DATETIME,
    periodo_fin DATETIME,
    archivo_reporte VARCHAR(255),
    estado ENUM('GENERANDO', 'COMPLETADO', 'ERROR') DEFAULT 'GENERANDO'
);

-- Procedimiento para generar reporte
DELIMITER //
CREATE PROCEDURE generar_reporte_disaster_recovery(IN p_tipo_reporte VARCHAR(100))
BEGIN
    DECLARE v_archivo VARCHAR(255);
    DECLARE v_fecha_inicio DATETIME;
    DECLARE v_fecha_fin DATETIME;
    
    SET v_fecha_inicio = DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
    SET v_fecha_fin = CURDATE();
    SET v_archivo = CONCAT('/reportes/dr_', p_tipo_reporte, '_', DATE_FORMAT(v_fecha_inicio, '%Y%m%d'), '.pdf');
    
    -- Registrar inicio del reporte
    INSERT INTO reportes_disaster_recovery (tipo_reporte, periodo_inicio, periodo_fin, archivo_reporte)
    VALUES (p_tipo_reporte, v_fecha_inicio, v_fecha_fin, v_archivo);
    
    -- Simular generación del reporte
    -- En implementación real: generar PDF con estadísticas de disaster recovery
    
    -- Marcar como completado
    UPDATE reportes_disaster_recovery 
    SET estado = 'COMPLETADO'
    WHERE archivo_reporte = v_archivo;
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Disaster Recovery
```sql
-- Crear tabla de configuración completa
CREATE TABLE configuracion_disaster_recovery_completa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_sistema VARCHAR(100),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuración completa
INSERT INTO configuracion_disaster_recovery_completa (nombre_sistema, configuracion)
VALUES ('Sistema_Disaster_Recovery', JSON_OBJECT(
    'planes', JSON_ARRAY('Plan_Sistema_Critico', 'Plan_Sistema_Desarrollo'),
    'monitoreo', JSON_OBJECT('intervalo', 60, 'alertas', true),
    'backup', JSON_OBJECT('frecuencia', 'DIARIO', 'retencion', 30),
    'pruebas', JSON_OBJECT('frecuencia', 'MENSUAL', 'tipo', 'SIMULADA')
));

-- Procedimiento para gestión completa de disaster recovery
DELIMITER //
CREATE PROCEDURE gestionar_disaster_recovery_completo()
BEGIN
    -- Ejecutar todas las tareas de disaster recovery
    CALL monitorear_disaster_recovery();
    CALL generar_alertas_disaster_recovery();
    CALL actualizar_dashboard_disaster_recovery();
    CALL ejecutar_recuperacion_automatica();
    
    -- Registrar actividad
    INSERT INTO log_actividad_disaster_recovery (actividad, fecha_ejecucion, estado)
    VALUES ('DISASTER_RECOVERY_COMPLETO', NOW(), 'COMPLETADA');
END //
DELIMITER ;

-- Evento para disaster recovery automático
CREATE EVENT disaster_recovery_automatico
ON SCHEDULE EVERY 1 HOUR
STARTS '2024-01-01 00:00:00'
DO
  CALL gestionar_disaster_recovery_completo();
```

## Resumen
En esta clase hemos aprendido sobre:
- Planes de disaster recovery y procedimientos
- Métricas RTO y RPO
- Sistemas de monitoreo y alertas
- Pruebas de disaster recovery
- Notificaciones de emergencia
- Dashboards de estado
- Backups para disaster recovery
- Validación de objetivos
- Escalamiento de emergencia
- Reportes y gestión completa

## Próxima Clase
En la siguiente clase aprenderemos sobre el proyecto integrador, donde aplicaremos todos los conceptos aprendidos en un sistema completo de administración de bases de datos.
