# Clase 6: Monitoreo y Alertas - Nivel Mid-Level

## Introducción
El monitoreo y las alertas son fundamentales para mantener sistemas de bases de datos saludables. En esta clase aprenderemos sobre herramientas de monitoreo, sistemas de alertas y dashboards de rendimiento.

## Conceptos Clave

### Monitoreo de Rendimiento
**Definición**: Proceso de observar y medir el rendimiento del sistema en tiempo real.
**Métricas clave**:
- CPU, memoria, disco
- Conexiones activas
- Consultas por segundo
- Tiempo de respuesta

### Sistemas de Alertas
**Definición**: Mecanismos para notificar sobre condiciones anómalas o críticas.
**Tipos**:
- Alertas por umbral
- Alertas por tendencia
- Alertas por anomalía

### Dashboards
**Definición**: Interfaces visuales que muestran métricas y estado del sistema.
**Componentes**:
- Gráficos en tiempo real
- Indicadores de estado
- Métricas históricas

## Ejemplos Prácticos

### 1. Sistema de Monitoreo Básico

```sql
-- Crear tabla de métricas del sistema
CREATE TABLE metricas_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_porcentaje DECIMAL(5,2),
    memoria_porcentaje DECIMAL(5,2),
    disco_porcentaje DECIMAL(5,2),
    conexiones_activas INT,
    consultas_por_segundo DECIMAL(10,2)
);

-- Procedimiento para recopilar métricas
DELIMITER //
CREATE PROCEDURE recopilar_metricas()
BEGIN
    DECLARE v_cpu DECIMAL(5,2);
    DECLARE v_memoria DECIMAL(5,2);
    DECLARE v_disco DECIMAL(5,2);
    DECLARE v_conexiones INT;
    DECLARE v_qps DECIMAL(10,2);
    
    -- Simular obtención de métricas
    SET v_cpu = ROUND(RAND() * 100, 2);
    SET v_memoria = ROUND(RAND() * 100, 2);
    SET v_disco = ROUND(RAND() * 100, 2);
    SET v_conexiones = FLOOR(RAND() * 1000);
    SET v_qps = ROUND(RAND() * 1000, 2);
    
    -- Insertar métricas
    INSERT INTO metricas_sistema (cpu_porcentaje, memoria_porcentaje, disco_porcentaje, conexiones_activas, consultas_por_segundo)
    VALUES (v_cpu, v_memoria, v_disco, v_conexiones, v_qps);
END //
DELIMITER ;
```

### 2. Sistema de Alertas

```sql
-- Crear tabla de alertas
CREATE TABLE alertas_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta VARCHAR(50),
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelto BOOLEAN DEFAULT FALSE
);

-- Procedimiento para generar alertas
DELIMITER //
CREATE PROCEDURE generar_alertas()
BEGIN
    DECLARE v_cpu_alto INT;
    DECLARE v_memoria_alta INT;
    DECLARE v_disco_alto INT;
    
    -- Verificar CPU alta
    SELECT COUNT(*) INTO v_cpu_alto
    FROM metricas_sistema
    WHERE cpu_porcentaje > 90
    AND fecha_medicion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_cpu_alto > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, descripcion, nivel_critico)
        VALUES ('CPU_ALTA', 'Uso de CPU superior al 90%', 'ALTO');
    END IF;
    
    -- Verificar memoria alta
    SELECT COUNT(*) INTO v_memoria_alta
    FROM metricas_sistema
    WHERE memoria_porcentaje > 90
    AND fecha_medicion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_memoria_alta > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, descripcion, nivel_critico)
        VALUES ('MEMORIA_ALTA', 'Uso de memoria superior al 90%', 'ALTO');
    END IF;
    
    -- Verificar disco alto
    SELECT COUNT(*) INTO v_disco_alto
    FROM metricas_sistema
    WHERE disco_porcentaje > 90
    AND fecha_medicion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_disco_alto > 0 THEN
        INSERT INTO alertas_sistema (tipo_alerta, descripcion, nivel_critico)
        VALUES ('DISCO_ALTO', 'Uso de disco superior al 90%', 'CRITICO');
    END IF;
END //
DELIMITER ;
```

### 3. Dashboard de Rendimiento

```sql
-- Crear tabla de dashboard
CREATE TABLE dashboard_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_promedio DECIMAL(5,2),
    memoria_promedio DECIMAL(5,2),
    disco_promedio DECIMAL(5,2),
    conexiones_promedio INT,
    qps_promedio DECIMAL(10,2),
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Procedimiento para actualizar dashboard
DELIMITER //
CREATE PROCEDURE actualizar_dashboard()
BEGIN
    DECLARE v_cpu DECIMAL(5,2);
    DECLARE v_memoria DECIMAL(5,2);
    DECLARE v_disco DECIMAL(5,2);
    DECLARE v_conexiones INT;
    DECLARE v_qps DECIMAL(10,2);
    DECLARE v_estado VARCHAR(20);
    
    -- Calcular promedios de la última hora
    SELECT 
        AVG(cpu_porcentaje),
        AVG(memoria_porcentaje),
        AVG(disco_porcentaje),
        AVG(conexiones_activas),
        AVG(consultas_por_segundo)
    INTO v_cpu, v_memoria, v_disco, v_conexiones, v_qps
    FROM metricas_sistema
    WHERE fecha_medicion > DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Determinar estado general
    IF v_cpu > 90 OR v_memoria > 90 OR v_disco > 90 THEN
        SET v_estado = 'CRITICO';
    ELSEIF v_cpu > 70 OR v_memoria > 70 OR v_disco > 70 THEN
        SET v_estado = 'ADVERTENCIA';
    ELSE
        SET v_estado = 'NORMAL';
    END IF;
    
    -- Insertar datos del dashboard
    INSERT INTO dashboard_rendimiento (
        cpu_promedio, memoria_promedio, disco_promedio,
        conexiones_promedio, qps_promedio, estado_general
    ) VALUES (
        v_cpu, v_memoria, v_disco, v_conexiones, v_qps, v_estado
    );
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Monitoreo de Consultas
```sql
-- Crear tabla de monitoreo de consultas
CREATE TABLE monitoreo_consultas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_consulta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_consulta ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE'),
    tiempo_ejecucion_ms INT,
    filas_afectadas INT,
    usuario VARCHAR(100)
);

-- Trigger para monitorear consultas
DELIMITER //
CREATE TRIGGER monitorear_select
AFTER SELECT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO monitoreo_consultas (tipo_consulta, tiempo_ejecucion_ms, usuario)
    VALUES ('SELECT', 0, USER());
END //
DELIMITER ;
```

### Ejercicio 2: Alertas por Tendencia
```sql
-- Crear tabla de tendencias
CREATE TABLE tendencias_metricas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metrica VARCHAR(50),
    valor_actual DECIMAL(10,2),
    valor_anterior DECIMAL(10,2),
    cambio_porcentual DECIMAL(5,2),
    tendencia ENUM('CRECIENTE', 'DECRECIENTE', 'ESTABLE')
);

-- Procedimiento para calcular tendencias
DELIMITER //
CREATE PROCEDURE calcular_tendencias()
BEGIN
    DECLARE v_cpu_actual DECIMAL(5,2);
    DECLARE v_cpu_anterior DECIMAL(5,2);
    DECLARE v_cambio DECIMAL(5,2);
    DECLARE v_tendencia VARCHAR(20);
    
    -- Obtener valores actual y anterior
    SELECT cpu_porcentaje INTO v_cpu_actual
    FROM metricas_sistema
    ORDER BY fecha_medicion DESC
    LIMIT 1;
    
    SELECT cpu_porcentaje INTO v_cpu_anterior
    FROM metricas_sistema
    ORDER BY fecha_medicion DESC
    LIMIT 1 OFFSET 1;
    
    -- Calcular cambio porcentual
    SET v_cambio = ((v_cpu_actual - v_cpu_anterior) / v_cpu_anterior) * 100;
    
    -- Determinar tendencia
    IF v_cambio > 10 THEN
        SET v_tendencia = 'CRECIENTE';
    ELSEIF v_cambio < -10 THEN
        SET v_tendencia = 'DECRECIENTE';
    ELSE
        SET v_tendencia = 'ESTABLE';
    END IF;
    
    -- Insertar tendencia
    INSERT INTO tendencias_metricas (metrica, valor_actual, valor_anterior, cambio_porcentual, tendencia)
    VALUES ('CPU', v_cpu_actual, v_cpu_anterior, v_cambio, v_tendencia);
END //
DELIMITER ;
```

### Ejercicio 3: Sistema de Notificaciones
```sql
-- Crear tabla de notificaciones
CREATE TABLE notificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_notificacion VARCHAR(50),
    mensaje TEXT,
    destinatario VARCHAR(100),
    metodo ENUM('EMAIL', 'SMS', 'WEBHOOK'),
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'ENVIADO', 'FALLIDO') DEFAULT 'PENDIENTE'
);

-- Procedimiento para enviar notificaciones
DELIMITER //
CREATE PROCEDURE enviar_notificaciones()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tipo VARCHAR(50);
    DECLARE v_mensaje TEXT;
    DECLARE v_destinatario VARCHAR(100);
    DECLARE v_metodo VARCHAR(20);
    
    DECLARE cur CURSOR FOR
        SELECT tipo_alerta, descripcion, 'admin@empresa.com', 'EMAIL'
        FROM alertas_sistema
        WHERE resuelto = FALSE
        AND nivel_critico IN ('ALTO', 'CRITICO');
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tipo, v_mensaje, v_destinatario, v_metodo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Insertar notificación
        INSERT INTO notificaciones (tipo_notificacion, mensaje, destinatario, metodo)
        VALUES (v_tipo, v_mensaje, v_destinatario, v_metodo);
        
        -- Marcar alerta como resuelta
        UPDATE alertas_sistema 
        SET resuelto = TRUE
        WHERE tipo_alerta = v_tipo AND descripcion = v_mensaje;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 4: Monitoreo de Recursos
```sql
-- Crear tabla de recursos
CREATE TABLE recursos_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_cores INT,
    memoria_total_gb DECIMAL(10,2),
    disco_total_gb DECIMAL(10,2),
    red_entrada_mbps DECIMAL(10,2),
    red_salida_mbps DECIMAL(10,2)
);

-- Procedimiento para medir recursos
DELIMITER //
CREATE PROCEDURE medir_recursos()
BEGIN
    -- Simular medición de recursos
    INSERT INTO recursos_sistema (cpu_cores, memoria_total_gb, disco_total_gb, red_entrada_mbps, red_salida_mbps)
    VALUES (8, 32.0, 1000.0, 100.5, 50.2);
END //
DELIMITER ;
```

### Ejercicio 5: Dashboard en Tiempo Real
```sql
-- Crear vista para dashboard en tiempo real
CREATE VIEW dashboard_tiempo_real AS
SELECT 
    'CPU' as metrica,
    cpu_porcentaje as valor,
    CASE 
        WHEN cpu_porcentaje > 90 THEN 'CRITICO'
        WHEN cpu_porcentaje > 70 THEN 'ADVERTENCIA'
        ELSE 'NORMAL'
    END as estado
FROM metricas_sistema
WHERE fecha_medicion = (
    SELECT MAX(fecha_medicion) FROM metricas_sistema
)

UNION ALL

SELECT 
    'MEMORIA' as metrica,
    memoria_porcentaje as valor,
    CASE 
        WHEN memoria_porcentaje > 90 THEN 'CRITICO'
        WHEN memoria_porcentaje > 70 THEN 'ADVERTENCIA'
        ELSE 'NORMAL'
    END as estado
FROM metricas_sistema
WHERE fecha_medicion = (
    SELECT MAX(fecha_medicion) FROM metricas_sistema
);
```

### Ejercicio 6: Sistema de Umbrales Dinámicos
```sql
-- Crear tabla de umbrales
CREATE TABLE umbrales_alertas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metrica VARCHAR(50),
    umbral_warning DECIMAL(10,2),
    umbral_critical DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar umbrales
INSERT INTO umbrales_alertas (metrica, umbral_warning, umbral_critical)
VALUES 
('CPU', 70.0, 90.0),
('MEMORIA', 80.0, 95.0),
('DISCO', 85.0, 95.0);

-- Procedimiento para verificar umbrales
DELIMITER //
CREATE PROCEDURE verificar_umbrales()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_metrica VARCHAR(50);
    DECLARE v_warning DECIMAL(10,2);
    DECLARE v_critical DECIMAL(10,2);
    DECLARE v_valor_actual DECIMAL(10,2);
    
    DECLARE cur CURSOR FOR
        SELECT metrica, umbral_warning, umbral_critical
        FROM umbrales_alertas
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_metrica, v_warning, v_critical;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Obtener valor actual
        IF v_metrica = 'CPU' THEN
            SELECT cpu_porcentaje INTO v_valor_actual
            FROM metricas_sistema
            ORDER BY fecha_medicion DESC
            LIMIT 1;
        ELSEIF v_metrica = 'MEMORIA' THEN
            SELECT memoria_porcentaje INTO v_valor_actual
            FROM metricas_sistema
            ORDER BY fecha_medicion DESC
            LIMIT 1;
        END IF;
        
        -- Verificar umbrales
        IF v_valor_actual >= v_critical THEN
            INSERT INTO alertas_sistema (tipo_alerta, descripcion, nivel_critico)
            VALUES (CONCAT(v_metrica, '_CRITICAL'), CONCAT(v_metrica, ' en nivel crítico: ', v_valor_actual, '%'), 'CRITICO');
        ELSEIF v_valor_actual >= v_warning THEN
            INSERT INTO alertas_sistema (tipo_alerta, descripcion, nivel_critico)
            VALUES (CONCAT(v_metrica, '_WARNING'), CONCAT(v_metrica, ' en nivel de advertencia: ', v_valor_actual, '%'), 'MEDIO');
        END IF;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 7: Monitoreo de Aplicaciones
```sql
-- Crear tabla de monitoreo de aplicaciones
CREATE TABLE monitoreo_aplicaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    aplicacion VARCHAR(100),
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuarios_activos INT,
    transacciones_por_minuto INT,
    tiempo_respuesta_promedio_ms INT,
    errores_por_minuto INT
);

-- Procedimiento para monitorear aplicaciones
DELIMITER //
CREATE PROCEDURE monitorear_aplicaciones()
BEGIN
    -- Simular métricas de aplicaciones
    INSERT INTO monitoreo_aplicaciones (aplicacion, usuarios_activos, transacciones_por_minuto, tiempo_respuesta_promedio_ms, errores_por_minuto)
    VALUES 
    ('Sistema_Ventas', 150, 45, 250, 2),
    ('Sistema_Inventario', 75, 30, 180, 1),
    ('Sistema_Reportes', 25, 10, 500, 0);
END //
DELIMITER ;
```

### Ejercicio 8: Sistema de Reportes Automáticos
```sql
-- Crear tabla de reportes
CREATE TABLE reportes_automaticos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_reporte VARCHAR(50),
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    periodo_inicio DATETIME,
    periodo_fin DATETIME,
    archivo_reporte VARCHAR(255),
    estado ENUM('GENERANDO', 'COMPLETADO', 'ERROR') DEFAULT 'GENERANDO'
);

-- Procedimiento para generar reportes
DELIMITER //
CREATE PROCEDURE generar_reporte_diario()
BEGIN
    DECLARE v_archivo VARCHAR(255);
    DECLARE v_fecha_inicio DATETIME;
    DECLARE v_fecha_fin DATETIME;
    
    SET v_fecha_inicio = DATE_SUB(CURDATE(), INTERVAL 1 DAY);
    SET v_fecha_fin = CURDATE();
    SET v_archivo = CONCAT('/reportes/reporte_diario_', DATE_FORMAT(v_fecha_inicio, '%Y%m%d'), '.pdf');
    
    -- Registrar inicio del reporte
    INSERT INTO reportes_automaticos (tipo_reporte, periodo_inicio, periodo_fin, archivo_reporte)
    VALUES ('REPORTE_DIARIO', v_fecha_inicio, v_fecha_fin, v_archivo);
    
    -- Simular generación del reporte
    -- En implementación real: generar PDF con métricas, gráficos, etc.
    
    -- Marcar como completado
    UPDATE reportes_automaticos 
    SET estado = 'COMPLETADO'
    WHERE archivo_reporte = v_archivo;
END //
DELIMITER ;
```

### Ejercicio 9: Monitoreo de Seguridad
```sql
-- Crear tabla de monitoreo de seguridad
CREATE TABLE monitoreo_seguridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_evento ENUM('LOGIN_FALLIDO', 'ACCESO_DENEGADO', 'CONSULTA_SOSPECHOSA', 'CAMBIO_PERMISOS'),
    usuario VARCHAR(100),
    ip_origen VARCHAR(45),
    detalles JSON,
    nivel_riesgo ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO')
);

-- Procedimiento para monitorear seguridad
DELIMITER //
CREATE PROCEDURE monitorear_seguridad()
BEGIN
    -- Simular eventos de seguridad
    INSERT INTO monitoreo_seguridad (tipo_evento, usuario, ip_origen, detalles, nivel_riesgo)
    VALUES 
    ('LOGIN_FALLIDO', 'usuario_sospechoso', '192.168.1.200', 
     JSON_OBJECT('intentos', 5, 'ultimo_intento', NOW()), 'ALTO'),
    ('CONSULTA_SOSPECHOSA', 'usuario_normal', '192.168.1.100',
     JSON_OBJECT('consulta', 'SELECT * FROM usuarios', 'patron', 'SELECT_ALL'), 'MEDIO');
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Monitoreo
```sql
-- Crear tabla de configuración de monitoreo
CREATE TABLE configuracion_monitoreo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    metrica VARCHAR(100),
    intervalo_segundos INT,
    umbral_warning DECIMAL(10,2),
    umbral_critical DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración
INSERT INTO configuracion_monitoreo (componente, metrica, intervalo_segundos, umbral_warning, umbral_critical)
VALUES 
('SISTEMA', 'CPU', 60, 70.0, 90.0),
('SISTEMA', 'MEMORIA', 60, 80.0, 95.0),
('BASE_DATOS', 'CONEXIONES', 30, 80.0, 95.0),
('APLICACION', 'TIEMPO_RESPUESTA', 30, 1000.0, 5000.0);

-- Procedimiento para gestión completa de monitoreo
DELIMITER //
CREATE PROCEDURE gestionar_monitoreo_completo()
BEGIN
    -- Ejecutar todas las tareas de monitoreo
    CALL recopilar_metricas();
    CALL medir_recursos();
    CALL monitorear_aplicaciones();
    CALL monitorear_seguridad();
    CALL verificar_umbrales();
    CALL generar_alertas();
    CALL actualizar_dashboard();
    CALL enviar_notificaciones();
    
    -- Registrar actividad
    INSERT INTO log_actividad_monitoreo (actividad, fecha_ejecucion, estado)
    VALUES ('MONITOREO_COMPLETO', NOW(), 'COMPLETADA');
END //
DELIMITER ;

-- Evento para monitoreo automático
CREATE EVENT monitoreo_automatico
ON SCHEDULE EVERY 1 MINUTE
STARTS '2024-01-01 00:00:00'
DO
  CALL gestionar_monitoreo_completo();
```

## Resumen
En esta clase hemos aprendido sobre:
- Sistemas de monitoreo de rendimiento
- Métricas del sistema y aplicaciones
- Sistemas de alertas y notificaciones
- Dashboards en tiempo real
- Monitoreo de tendencias y umbrales
- Reportes automáticos
- Monitoreo de seguridad
- Gestión completa de monitoreo

## Próxima Clase
En la siguiente clase aprenderemos sobre mantenimiento y tuning, incluyendo optimización de consultas, mantenimiento de índices y limpieza de datos.
