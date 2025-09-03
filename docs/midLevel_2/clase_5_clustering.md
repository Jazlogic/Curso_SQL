# Clase 5: Clustering y Alta Disponibilidad - Nivel Mid-Level

## Introducción
El clustering y la alta disponibilidad son fundamentales para sistemas críticos. En esta clase aprenderemos sobre configuración de clusters, balanceo de carga y sistemas de alta disponibilidad.

## Conceptos Clave

### Clustering
**Definición**: Agrupación de múltiples servidores que trabajan juntos como un sistema único.
**Tipos**:
- Clusters activo-pasivo
- Clusters activo-activo
- Clusters de balanceo de carga

### Alta Disponibilidad
**Definición**: Capacidad de un sistema para mantenerse operativo durante fallos.
**Métricas**:
- Uptime (tiempo de actividad)
- MTBF (Mean Time Between Failures)
- MTTR (Mean Time To Recovery)

### Balanceo de Carga
**Definición**: Distribución de trabajo entre múltiples servidores.
**Algoritmos**:
- Round Robin
- Least Connections
- Weighted Round Robin

## Ejemplos Prácticos

### 1. Configuración de Cluster Activo-Pasivo

```sql
-- Configuración en SERVIDOR PRIMARIO
SET GLOBAL server_id = 1;
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';

-- Crear usuario para replicación
CREATE USER 'cluster_user'@'192.168.1.101' IDENTIFIED BY 'ClusterPass123!';
GRANT REPLICATION SLAVE ON *.* TO 'cluster_user'@'192.168.1.101';

-- Configuración en SERVIDOR SECUNDARIO
SET GLOBAL server_id = 2;
SET GLOBAL read_only = ON;

-- Configurar como esclavo
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'cluster_user',
    MASTER_PASSWORD = 'ClusterPass123!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;
```

**Explicación línea por línea**:
- `server_id`: Identificador único para cada servidor
- `read_only = ON`: Servidor secundario en modo solo lectura
- `CHANGE MASTER TO`: Configuración de replicación
- `START SLAVE`: Inicia el proceso de replicación

### 2. Sistema de Monitoreo de Cluster

```sql
-- Crear tabla de monitoreo de cluster
CREATE TABLE monitoreo_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_servidor ENUM('ACTIVO', 'PASIVO', 'ERROR', 'MANTENIMIENTO'),
    carga_cpu DECIMAL(5,2),
    memoria_utilizada DECIMAL(5,2),
    conexiones_activas INT,
    tiempo_respuesta_ms INT
);

-- Procedimiento para verificar estado del cluster
DELIMITER //
CREATE PROCEDURE verificar_estado_cluster()
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_carga_cpu DECIMAL(5,2);
    DECLARE v_memoria DECIMAL(5,2);
    DECLARE v_conexiones INT;
    DECLARE v_tiempo_respuesta INT;
    
    -- Simular obtención de métricas del sistema
    SET v_carga_cpu = ROUND(RAND() * 100, 2);
    SET v_memoria = ROUND(RAND() * 100, 2);
    SET v_conexiones = FLOOR(RAND() * 1000);
    SET v_tiempo_respuesta = FLOOR(RAND() * 100);
    
    -- Determinar estado basado en métricas
    IF v_carga_cpu > 90 OR v_memoria > 90 THEN
        SET v_estado = 'ERROR';
    ELSEIF @@read_only = 1 THEN
        SET v_estado = 'PASIVO';
    ELSE
        SET v_estado = 'ACTIVO';
    END IF;
    
    -- Registrar métricas
    INSERT INTO monitoreo_cluster (
        servidor_id, estado_servidor, carga_cpu, memoria_utilizada,
        conexiones_activas, tiempo_respuesta_ms
    ) VALUES (
        @@server_id, v_estado, v_carga_cpu, v_memoria,
        v_conexiones, v_tiempo_respuesta
    );
    
    -- Generar alertas si es necesario
    IF v_estado = 'ERROR' THEN
        INSERT INTO alertas_cluster (tipo_alerta, descripcion, nivel_critico)
        VALUES ('SERVIDOR_ERROR', CONCAT('Servidor ', @@server_id, ' en estado de error'), 'CRITICO');
    END IF;
END //
DELIMITER ;
```

### 3. Sistema de Failover Automático

```sql
-- Crear tabla de configuración de failover
CREATE TABLE configuracion_failover (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_primario INT,
    servidor_secundario INT,
    tiempo_espera_segundos INT DEFAULT 30,
    activo BOOLEAN DEFAULT TRUE
);

-- Procedimiento para failover automático
DELIMITER //
CREATE PROCEDURE ejecutar_failover_cluster()
BEGIN
    DECLARE v_servidor_primario INT;
    DECLARE v_servidor_secundario INT;
    DECLARE v_tiempo_espera INT;
    DECLARE v_estado_primario VARCHAR(20);
    
    -- Obtener configuración
    SELECT servidor_primario, servidor_secundario, tiempo_espera_segundos
    INTO v_servidor_primario, v_servidor_secundario, v_tiempo_espera
    FROM configuracion_failover
    WHERE activo = TRUE
    LIMIT 1;
    
    -- Verificar estado del servidor primario
    SELECT estado_servidor INTO v_estado_primario
    FROM monitoreo_cluster
    WHERE servidor_id = v_servidor_primario
    ORDER BY fecha_verificacion DESC
    LIMIT 1;
    
    -- Si el primario está en error, ejecutar failover
    IF v_estado_primario = 'ERROR' THEN
        -- Promover servidor secundario
        SET GLOBAL read_only = OFF;
        
        -- Registrar failover
        INSERT INTO log_failover (servidor_anterior, servidor_nuevo, fecha_failover, tipo)
        VALUES (v_servidor_primario, v_servidor_secundario, NOW(), 'AUTOMATICO');
        
        -- Notificar administradores
        INSERT INTO notificaciones (tipo, mensaje, nivel_critico)
        VALUES ('FAILOVER', CONCAT('Failover ejecutado: Servidor ', v_servidor_secundario, ' es ahora primario'), 'CRITICO');
    END IF;
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Configuración de Cluster Básico
```sql
-- Crear tabla de configuración de cluster
CREATE TABLE configuracion_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    rol ENUM('PRIMARIO', 'SECUNDARIO', 'TERCIARIO'),
    ip_servidor VARCHAR(15),
    puerto INT DEFAULT 3306,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración
INSERT INTO configuracion_cluster (servidor_id, rol, ip_servidor, puerto)
VALUES 
(1, 'PRIMARIO', '192.168.1.100', 3306),
(2, 'SECUNDARIO', '192.168.1.101', 3306),
(3, 'TERCIARIO', '192.168.1.102', 3306);
```

### Ejercicio 2: Balanceo de Carga
```sql
-- Crear tabla de balanceo de carga
CREATE TABLE balanceo_carga (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    peso INT DEFAULT 1,
    conexiones_activas INT DEFAULT 0,
    capacidad_maxima INT DEFAULT 100,
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO'
);

-- Función para seleccionar servidor
DELIMITER //
CREATE FUNCTION seleccionar_servidor_balanceo()
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_servidor_id INT;
    
    -- Seleccionar servidor con menor carga
    SELECT servidor_id INTO v_servidor_id
    FROM balanceo_carga
    WHERE estado = 'ACTIVO' 
    AND conexiones_activas < capacidad_maxima
    ORDER BY (conexiones_activas / capacidad_maxima) ASC
    LIMIT 1;
    
    -- Incrementar contador
    UPDATE balanceo_carga 
    SET conexiones_activas = conexiones_activas + 1
    WHERE servidor_id = v_servidor_id;
    
    RETURN v_servidor_id;
END //
DELIMITER ;
```

### Ejercicio 3: Monitoreo de Alta Disponibilidad
```sql
-- Crear tabla de métricas de disponibilidad
CREATE TABLE metricas_disponibilidad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uptime_porcentaje DECIMAL(5,2),
    tiempo_respuesta_promedio_ms INT,
    errores_por_hora INT,
    disponibilidad_objetivo DECIMAL(5,2) DEFAULT 99.9
);

-- Procedimiento para calcular disponibilidad
DELIMITER //
CREATE PROCEDURE calcular_disponibilidad()
BEGIN
    DECLARE v_uptime DECIMAL(5,2);
    DECLARE v_tiempo_respuesta INT;
    DECLARE v_errores INT;
    
    -- Calcular uptime (simulado)
    SET v_uptime = 99.95;
    SET v_tiempo_respuesta = 50;
    SET v_errores = 2;
    
    -- Insertar métricas
    INSERT INTO metricas_disponibilidad (uptime_porcentaje, tiempo_respuesta_promedio_ms, errores_por_hora)
    VALUES (v_uptime, v_tiempo_respuesta, v_errores);
    
    -- Generar alerta si no se cumple el objetivo
    IF v_uptime < 99.9 THEN
        INSERT INTO alertas_cluster (tipo_alerta, descripcion, nivel_critico)
        VALUES ('DISPONIBILIDAD_BAJA', CONCAT('Disponibilidad: ', v_uptime, '%'), 'ALTO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 4: Sistema de Health Check
```sql
-- Crear tabla de health checks
CREATE TABLE health_checks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('OK', 'WARNING', 'ERROR'),
    tiempo_respuesta_ms INT,
    detalles JSON
);

-- Procedimiento para health check
DELIMITER //
CREATE PROCEDURE ejecutar_health_check()
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_tiempo_respuesta INT;
    DECLARE v_detalles JSON;
    
    -- Simular health check
    SET v_tiempo_respuesta = FLOOR(RAND() * 100);
    
    IF v_tiempo_respuesta < 50 THEN
        SET v_estado = 'OK';
    ELSEIF v_tiempo_respuesta < 100 THEN
        SET v_estado = 'WARNING';
    ELSE
        SET v_estado = 'ERROR';
    END IF;
    
    SET v_detalles = JSON_OBJECT(
        'cpu_usage', ROUND(RAND() * 100, 2),
        'memory_usage', ROUND(RAND() * 100, 2),
        'disk_usage', ROUND(RAND() * 100, 2)
    );
    
    -- Registrar health check
    INSERT INTO health_checks (servidor_id, estado, tiempo_respuesta_ms, detalles)
    VALUES (@@server_id, v_estado, v_tiempo_respuesta, v_detalles);
END //
DELIMITER ;
```

### Ejercicio 5: Sistema de Recuperación Automática
```sql
-- Crear tabla de recuperación
CREATE TABLE recuperacion_automatica (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_recuperacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_recuperacion ENUM('REINICIO', 'REPARACION', 'RESTAURACION'),
    estado ENUM('INICIADA', 'COMPLETADA', 'FALLIDA'),
    tiempo_recuperacion_minutos INT
);

-- Procedimiento para recuperación automática
DELIMITER //
CREATE PROCEDURE ejecutar_recuperacion_automatica(IN p_servidor_id INT)
BEGIN
    DECLARE v_tipo_recuperacion VARCHAR(20);
    DECLARE v_inicio TIMESTAMP;
    DECLARE v_fin TIMESTAMP;
    
    SET v_inicio = NOW();
    
    -- Determinar tipo de recuperación
    SET v_tipo_recuperacion = 'REINICIO';
    
    -- Registrar inicio
    INSERT INTO recuperacion_automatica (servidor_id, tipo_recuperacion, estado)
    VALUES (p_servidor_id, v_tipo_recuperacion, 'INICIADA');
    
    -- Simular recuperación
    -- En implementación real: reiniciar servicios, reparar datos, etc.
    
    SET v_fin = NOW();
    
    -- Actualizar estado
    UPDATE recuperacion_automatica 
    SET estado = 'COMPLETADA',
        tiempo_recuperacion_minutos = TIMESTAMPDIFF(MINUTE, v_inicio, v_fin)
    WHERE servidor_id = p_servidor_id AND fecha_recuperacion = v_inicio;
END //
DELIMITER ;
```

### Ejercicio 6: Dashboard de Cluster
```sql
-- Crear tabla de dashboard
CREATE TABLE dashboard_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidores_activos INT,
    servidores_inactivos INT,
    disponibilidad_promedio DECIMAL(5,2),
    carga_promedio DECIMAL(5,2),
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Procedimiento para actualizar dashboard
DELIMITER //
CREATE PROCEDURE actualizar_dashboard_cluster()
BEGIN
    DECLARE v_servidores_activos INT;
    DECLARE v_servidores_inactivos INT;
    DECLARE v_disponibilidad DECIMAL(5,2);
    DECLARE v_carga DECIMAL(5,2);
    DECLARE v_estado VARCHAR(20);
    
    -- Contar servidores
    SELECT 
        SUM(CASE WHEN estado_servidor = 'ACTIVO' THEN 1 ELSE 0 END),
        SUM(CASE WHEN estado_servidor != 'ACTIVO' THEN 1 ELSE 0 END)
    INTO v_servidores_activos, v_servidores_inactivos
    FROM monitoreo_cluster
    WHERE fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    -- Calcular promedios
    SELECT AVG(100 - carga_cpu), AVG(carga_cpu)
    INTO v_disponibilidad, v_carga
    FROM monitoreo_cluster
    WHERE fecha_verificacion > DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Determinar estado
    IF v_servidores_inactivos > 0 THEN
        SET v_estado = 'CRITICO';
    ELSEIF v_carga > 80 THEN
        SET v_estado = 'ADVERTENCIA';
    ELSE
        SET v_estado = 'NORMAL';
    END IF;
    
    -- Actualizar dashboard
    INSERT INTO dashboard_cluster (
        servidores_activos, servidores_inactivos, disponibilidad_promedio,
        carga_promedio, estado_general
    ) VALUES (
        v_servidores_activos, v_servidores_inactivos, v_disponibilidad,
        v_carga, v_estado
    );
END //
DELIMITER ;
```

### Ejercicio 7: Sistema de Alertas Inteligentes
```sql
-- Crear tabla de alertas
CREATE TABLE alertas_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta VARCHAR(50),
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelto BOOLEAN DEFAULT FALSE
);

-- Procedimiento para generar alertas
DELIMITER //
CREATE PROCEDURE generar_alertas_cluster()
BEGIN
    DECLARE v_carga_alta INT;
    DECLARE v_memoria_alta INT;
    DECLARE v_servidores_error INT;
    
    -- Verificar carga alta
    SELECT COUNT(*) INTO v_carga_alta
    FROM monitoreo_cluster
    WHERE carga_cpu > 90
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_carga_alta > 0 THEN
        INSERT INTO alertas_cluster (tipo_alerta, descripcion, nivel_critico)
        VALUES ('CARGA_ALTA', CONCAT('Se detectaron ', v_carga_alta, ' servidores con carga alta'), 'ALTO');
    END IF;
    
    -- Verificar memoria alta
    SELECT COUNT(*) INTO v_memoria_alta
    FROM monitoreo_cluster
    WHERE memoria_utilizada > 90
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_memoria_alta > 0 THEN
        INSERT INTO alertas_cluster (tipo_alerta, descripcion, nivel_critico)
        VALUES ('MEMORIA_ALTA', CONCAT('Se detectaron ', v_memoria_alta, ' servidores con memoria alta'), 'ALTO');
    END IF;
    
    -- Verificar servidores en error
    SELECT COUNT(*) INTO v_servidores_error
    FROM monitoreo_cluster
    WHERE estado_servidor = 'ERROR'
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    IF v_servidores_error > 0 THEN
        INSERT INTO alertas_cluster (tipo_alerta, descripcion, nivel_critico)
        VALUES ('SERVIDORES_ERROR', CONCAT('Se detectaron ', v_servidores_error, ' servidores en error'), 'CRITICO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 8: Sistema de Escalado Automático
```sql
-- Crear tabla de escalado
CREATE TABLE escalado_automatico (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_escalado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_escalado ENUM('ESCALAR_ARRIBA', 'ESCALAR_ABAJO'),
    servidores_afectados INT,
    razon TEXT,
    estado ENUM('INICIADO', 'COMPLETADO', 'FALLIDO') DEFAULT 'INICIADO'
);

-- Procedimiento para escalado automático
DELIMITER //
CREATE PROCEDURE ejecutar_escalado_automatico()
BEGIN
    DECLARE v_carga_promedio DECIMAL(5,2);
    DECLARE v_servidores_activos INT;
    DECLARE v_tipo_escalado VARCHAR(20);
    
    -- Calcular carga promedio
    SELECT AVG(carga_cpu) INTO v_carga_promedio
    FROM monitoreo_cluster
    WHERE fecha_verificacion > DATE_SUB(NOW(), INTERVAL 10 MINUTE);
    
    -- Contar servidores activos
    SELECT COUNT(*) INTO v_servidores_activos
    FROM configuracion_cluster
    WHERE activo = TRUE;
    
    -- Decidir escalado
    IF v_carga_promedio > 80 AND v_servidores_activos < 5 THEN
        SET v_tipo_escalado = 'ESCALAR_ARRIBA';
        
        -- Registrar escalado
        INSERT INTO escalado_automatico (tipo_escalado, servidores_afectados, razon)
        VALUES (v_tipo_escalado, 1, CONCAT('Carga promedio: ', v_carga_promedio, '%'));
        
    ELSEIF v_carga_promedio < 30 AND v_servidores_activos > 2 THEN
        SET v_tipo_escalado = 'ESCALAR_ABAJO';
        
        -- Registrar escalado
        INSERT INTO escalado_automatico (tipo_escalado, servidores_afectados, razon)
        VALUES (v_tipo_escalado, 1, CONCAT('Carga promedio: ', v_carga_promedio, '%'));
    END IF;
END //
DELIMITER ;
```

### Ejercicio 9: Sistema de Backup en Cluster
```sql
-- Crear tabla de backup cluster
CREATE TABLE backup_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidor_origen INT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL'),
    archivo_backup VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    estado ENUM('INICIADO', 'COMPLETADO', 'ERROR') DEFAULT 'INICIADO'
);

-- Procedimiento para backup coordinado
DELIMITER //
CREATE PROCEDURE ejecutar_backup_cluster()
BEGIN
    DECLARE v_servidor_primario INT;
    DECLARE v_archivo_backup VARCHAR(255);
    DECLARE v_fecha_backup VARCHAR(20);
    
    -- Obtener servidor primario
    SELECT servidor_id INTO v_servidor_primario
    FROM configuracion_cluster
    WHERE rol = 'PRIMARIO' AND activo = TRUE
    LIMIT 1;
    
    SET v_fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    SET v_archivo_backup = CONCAT('/backups/cluster_backup_', v_fecha_backup, '.sql');
    
    -- Registrar backup
    INSERT INTO backup_cluster (servidor_origen, tipo_backup, archivo_backup)
    VALUES (v_servidor_primario, 'COMPLETO', v_archivo_backup);
    
    -- Simular backup
    -- En implementación real: mysqldump, rsync a otros servidores, etc.
    
    -- Actualizar estado
    UPDATE backup_cluster 
    SET estado = 'COMPLETADO', tamaño_mb = 1024
    WHERE archivo_backup = v_archivo_backup;
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Gestión de Cluster
```sql
-- Crear tabla de configuración completa
CREATE TABLE configuracion_completa_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_cluster VARCHAR(100),
    version_configuracion VARCHAR(20),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuración completa
INSERT INTO configuracion_completa_cluster (nombre_cluster, version_configuracion, configuracion)
VALUES ('Cluster_Produccion', '1.0', JSON_OBJECT(
    'servidores', JSON_ARRAY(
        JSON_OBJECT('id', 1, 'rol', 'PRIMARIO', 'ip', '192.168.1.100'),
        JSON_OBJECT('id', 2, 'rol', 'SECUNDARIO', 'ip', '192.168.1.101'),
        JSON_OBJECT('id', 3, 'rol', 'TERCIARIO', 'ip', '192.168.1.102')
    ),
    'balanceo_carga', JSON_OBJECT('algoritmo', 'ROUND_ROBIN', 'pesos', JSON_ARRAY(3, 2, 1)),
    'failover', JSON_OBJECT('tiempo_espera', 30, 'automatico', true),
    'monitoreo', JSON_OBJECT('intervalo', 60, 'alertas', true)
));

-- Procedimiento para gestión completa
DELIMITER //
CREATE PROCEDURE gestionar_cluster_completo()
BEGIN
    -- Ejecutar todas las tareas de gestión
    CALL verificar_estado_cluster();
    CALL ejecutar_health_check();
    CALL generar_alertas_cluster();
    CALL actualizar_dashboard_cluster();
    CALL ejecutar_escalado_automatico();
    
    -- Registrar actividad
    INSERT INTO log_actividad_cluster (actividad, fecha_ejecucion, estado)
    VALUES ('GESTION_COMPLETA', NOW(), 'COMPLETADA');
END //
DELIMITER ;

-- Evento para gestión automática
CREATE EVENT gestion_automatica_cluster
ON SCHEDULE EVERY 1 MINUTE
STARTS '2024-01-01 00:00:00'
DO
  CALL gestionar_cluster_completo();
```

## Resumen
En esta clase hemos aprendido sobre:
- Configuración de clusters activo-pasivo y activo-activo
- Sistemas de monitoreo y health checks
- Failover automático y recuperación
- Balanceo de carga y escalado automático
- Métricas de alta disponibilidad
- Sistemas de alertas inteligentes
- Backup coordinado en clusters
- Gestión completa de clusters

## Próxima Clase
En la siguiente clase aprenderemos sobre monitoreo y alertas, incluyendo herramientas de monitoreo, sistemas de alertas y dashboards de rendimiento.
