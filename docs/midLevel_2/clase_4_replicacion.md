# Clase 4: Replicación de Bases de Datos - Nivel Mid-Level

## Introducción
La replicación de bases de datos es una técnica fundamental para mejorar la disponibilidad, rendimiento y confiabilidad de los sistemas. En esta clase aprenderemos sobre diferentes tipos de replicación, configuración y gestión de conflictos.

## Conceptos Clave

### Tipos de Replicación
**Definición**: Diferentes estrategias para mantener copias sincronizadas de datos.
**Tipos**:
- Replicación maestro-esclavo
- Replicación maestro-maestro
- Replicación circular
- Replicación en cadena

### Configuración de Replicación
**Definición**: Proceso de configurar servidores para mantener datos sincronizados.
**Componentes**:
- Servidor maestro (master)
- Servidor esclavo (slave)
- Logs binarios
- Posiciones de replicación

### Gestión de Conflictos
**Definición**: Proceso de resolver discrepancias cuando múltiples servidores modifican los mismos datos.
**Estrategias**:
- Resolución por timestamp
- Resolución por servidor
- Resolución manual
- Prevención de conflictos

## Ejemplos Prácticos

### 1. Configuración de Replicación Maestro-Esclavo

```sql
-- En el servidor MAESTRO
-- Configurar ID único del servidor
SET GLOBAL server_id = 1;

-- Habilitar logs binarios
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';

-- Crear usuario para replicación
CREATE USER 'replicador'@'%' IDENTIFIED BY 'ReplicaPass123!';
GRANT REPLICATION SLAVE ON *.* TO 'replicador'@'%';

-- Obtener posición actual del binlog
SHOW MASTER STATUS;

-- En el servidor ESCLAVO
-- Configurar ID único del servidor
SET GLOBAL server_id = 2;

-- Configurar replicación
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'replicador',
    MASTER_PASSWORD = 'ReplicaPass123!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

-- Iniciar replicación
START SLAVE;

-- Verificar estado de replicación
SHOW SLAVE STATUS\G;
```

**Explicación línea por línea**:
- `server_id`: Identificador único para cada servidor
- `log_bin = ON`: Habilita registro binario en el maestro
- `binlog_format = 'ROW'`: Formato de registro por filas
- `REPLICATION SLAVE`: Permiso específico para replicación
- `CHANGE MASTER TO`: Configura conexión al servidor maestro
- `START SLAVE`: Inicia el proceso de replicación
- `SHOW SLAVE STATUS`: Muestra estado detallado de replicación

### 2. Monitoreo de Replicación

```sql
-- Crear tabla para monitoreo de replicación
CREATE TABLE monitoreo_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_replicacion ENUM('FUNCIONANDO', 'DETENIDO', 'ERROR', 'RETRASADO'),
    posicion_maestro VARCHAR(50),
    posicion_esclavo VARCHAR(50),
    retraso_segundos INT,
    errores_encontrados INT,
    mensaje_error TEXT
);

-- Procedimiento para verificar estado de replicación
DELIMITER //
CREATE PROCEDURE verificar_estado_replicacion()
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_posicion_maestro VARCHAR(50);
    DECLARE v_posicion_esclavo VARCHAR(50);
    DECLARE v_retraso INT;
    DECLARE v_errores INT;
    DECLARE v_mensaje TEXT;
    
    -- Obtener información del estado de replicación
    SELECT 
        CASE 
            WHEN Slave_IO_Running = 'Yes' AND Slave_SQL_Running = 'Yes' THEN 'FUNCIONANDO'
            WHEN Slave_IO_Running = 'No' OR Slave_SQL_Running = 'No' THEN 'DETENIDO'
            WHEN Last_IO_Error != '' OR Last_SQL_Error != '' THEN 'ERROR'
            ELSE 'RETRASADO'
        END,
        Master_Log_File,
        Read_Master_Log_Pos,
        Seconds_Behind_Master,
        Last_IO_Errno + Last_SQL_Errno,
        CONCAT(IFNULL(Last_IO_Error, ''), ' ', IFNULL(Last_SQL_Error, ''))
    INTO v_estado, v_posicion_maestro, v_posicion_esclavo, v_retraso, v_errores, v_mensaje
    FROM (
        SHOW SLAVE STATUS
    ) AS slave_status;
    
    -- Registrar estado
    INSERT INTO monitoreo_replicacion (
        servidor_id, estado_replicacion, posicion_maestro, posicion_esclavo,
        retraso_segundos, errores_encontrados, mensaje_error
    ) VALUES (
        @@server_id, v_estado, v_posicion_maestro, v_posicion_esclavo,
        v_retraso, v_errores, v_mensaje
    );
    
    -- Generar alertas si es necesario
    IF v_estado != 'FUNCIONANDO' THEN
        INSERT INTO alertas_replicacion (tipo_alerta, descripcion, nivel_critico)
        VALUES ('REPLICACION_ERROR', CONCAT('Estado: ', v_estado, ' - ', v_mensaje), 'ALTO');
    END IF;
END //
DELIMITER ;
```

**Explicación línea por línea**:
- `monitoreo_replicacion`: Tabla para registrar estado de replicación
- `Slave_IO_Running`: Estado del hilo de I/O del esclavo
- `Slave_SQL_Running`: Estado del hilo SQL del esclavo
- `Seconds_Behind_Master`: Retraso en segundos respecto al maestro
- `Last_IO_Error`: Último error de I/O
- `Last_SQL_Error`: Último error SQL

### 3. Replicación Maestro-Maestro

```sql
-- Configuración en SERVIDOR 1
SET GLOBAL server_id = 1;
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';
SET GLOBAL auto_increment_increment = 2;
SET GLOBAL auto_increment_offset = 1;

-- Crear usuario para replicación
CREATE USER 'replicador1'@'192.168.1.101' IDENTIFIED BY 'ReplicaPass123!';
GRANT REPLICATION SLAVE ON *.* TO 'replicador1'@'192.168.1.101';

-- Configurar como esclavo del servidor 2
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.101',
    MASTER_USER = 'replicador1',
    MASTER_PASSWORD = 'ReplicaPass123!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;

-- Configuración en SERVIDOR 2
SET GLOBAL server_id = 2;
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';
SET GLOBAL auto_increment_increment = 2;
SET GLOBAL auto_increment_offset = 2;

-- Crear usuario para replicación
CREATE USER 'replicador2'@'192.168.1.100' IDENTIFIED BY 'ReplicaPass123!';
GRANT REPLICATION SLAVE ON *.* TO 'replicador2'@'192.168.1.100';

-- Configurar como esclavo del servidor 1
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'replicador2',
    MASTER_PASSWORD = 'ReplicaPass123!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;
```

**Explicación línea por línea**:
- `auto_increment_increment = 2`: Incrementa IDs de 2 en 2
- `auto_increment_offset = 1`: Servidor 1 usa IDs impares (1,3,5...)
- `auto_increment_offset = 2`: Servidor 2 usa IDs pares (2,4,6...)
- Configuración bidireccional: cada servidor es maestro y esclavo del otro

### 4. Gestión de Conflictos

```sql
-- Crear tabla para registro de conflictos
CREATE TABLE conflictos_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_conflicto TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tabla_afectada VARCHAR(100),
    clave_primaria VARCHAR(100),
    servidor_origen INT,
    accion_conflicto ENUM('INSERT', 'UPDATE', 'DELETE'),
    datos_originales JSON,
    datos_nuevos JSON,
    resolucion ENUM('AUTOMATICA', 'MANUAL', 'PENDIENTE') DEFAULT 'PENDIENTE',
    servidor_resolucion INT,
    observaciones TEXT
);

-- Función para resolver conflictos automáticamente
DELIMITER //
CREATE FUNCTION resolver_conflicto_automatico(
    p_tabla VARCHAR(100),
    p_clave VARCHAR(100),
    p_datos_servidor1 JSON,
    p_datos_servidor2 JSON,
    p_timestamp1 TIMESTAMP,
    p_timestamp2 TIMESTAMP
)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE resultado JSON;
    
    -- Estrategia: usar el timestamp más reciente
    IF p_timestamp1 > p_timestamp2 THEN
        SET resultado = p_datos_servidor1;
    ELSE
        SET resultado = p_datos_servidor2;
    END IF;
    
    -- Registrar conflicto resuelto
    INSERT INTO conflictos_replicacion (
        tabla_afectada, clave_primaria, accion_conflicto,
        datos_originales, datos_nuevos, resolucion
    ) VALUES (
        p_tabla, p_clave, 'UPDATE',
        p_datos_servidor1, resultado, 'AUTOMATICA'
    );
    
    RETURN resultado;
END //
DELIMITER ;

-- Trigger para detectar y resolver conflictos
DELIMITER //
CREATE TRIGGER detectar_conflicto_update
BEFORE UPDATE ON clientes
FOR EACH ROW
BEGIN
    DECLARE v_timestamp_servidor TIMESTAMP;
    DECLARE v_timestamp_remoto TIMESTAMP;
    
    -- Obtener timestamp del servidor actual
    SET v_timestamp_servidor = NEW.ultima_modificacion;
    
    -- Simular obtención de timestamp remoto
    SELECT ultima_modificacion INTO v_timestamp_remoto
    FROM clientes_remoto
    WHERE id = NEW.id;
    
    -- Si hay conflicto, resolver automáticamente
    IF v_timestamp_servidor != v_timestamp_remoto THEN
        SET NEW.datos = resolver_conflicto_automatico(
            'clientes', 
            NEW.id, 
            JSON_OBJECT('datos', OLD.datos, 'timestamp', v_timestamp_servidor),
            JSON_OBJECT('datos', NEW.datos, 'timestamp', v_timestamp_remoto),
            v_timestamp_servidor,
            v_timestamp_remoto
        );
    END IF;
END //
DELIMITER ;
```

**Explicación línea por línea**:
- `conflictos_replicacion`: Tabla para registrar conflictos
- `resolver_conflicto_automatico()`: Función para resolver conflictos
- `BEFORE UPDATE`: Trigger que se ejecuta antes de actualizar
- Estrategia de resolución por timestamp más reciente

### 5. Replicación Circular

```sql
-- Configuración de replicación circular (3 servidores)
-- SERVIDOR A (192.168.1.100)
SET GLOBAL server_id = 1;
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';

CREATE USER 'replicador_a'@'192.168.1.101' IDENTIFIED BY 'ReplicaPass123!';
GRANT REPLICATION SLAVE ON *.* TO 'replicador_a'@'192.168.1.101';

CHANGE MASTER TO
    MASTER_HOST = '192.168.1.102',
    MASTER_USER = 'replicador_c',
    MASTER_PASSWORD = 'ReplicaPass123!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;

-- SERVIDOR B (192.168.1.101)
SET GLOBAL server_id = 2;
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';

CREATE USER 'replicador_b'@'192.168.1.102' IDENTIFIED BY 'ReplicaPass123!';
GRANT REPLICATION SLAVE ON *.* TO 'replicador_b'@'192.168.1.102';

CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'replicador_a',
    MASTER_PASSWORD = 'ReplicaPass123!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;

-- SERVIDOR C (192.168.1.102)
SET GLOBAL server_id = 3;
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';

CREATE USER 'replicador_c'@'192.168.1.100' IDENTIFIED BY 'ReplicaPass123!';
GRANT REPLICATION SLAVE ON *.* TO 'replicador_c'@'192.168.1.100';

CHANGE MASTER TO
    MASTER_HOST = '192.168.1.101',
    MASTER_USER = 'replicador_b',
    MASTER_PASSWORD = 'ReplicaPass123!',
    MASTER_LOG_FILE = 'mysql-bin.000001',
    MASTER_LOG_POS = 154;

START SLAVE;
```

**Explicación línea por línea**:
- Replicación circular: A → B → C → A
- Cada servidor replica al siguiente en la cadena
- Útil para distribución geográfica
- Requiere manejo cuidadoso de conflictos

## Ejercicios Prácticos

### Ejercicio 1: Configuración Básica de Replicación
```sql
-- Crear tabla de configuración de replicación
CREATE TABLE configuracion_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    tipo_replicacion ENUM('MAESTRO_ESCLAVO', 'MAESTRO_MAESTRO', 'CIRCULAR'),
    servidor_maestro VARCHAR(100),
    usuario_replicacion VARCHAR(100),
    estado ENUM('ACTIVO', 'INACTIVO', 'ERROR') DEFAULT 'INACTIVO',
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para configurar replicación
DELIMITER //
CREATE PROCEDURE configurar_replicacion(
    IN p_servidor_maestro VARCHAR(100),
    IN p_usuario VARCHAR(100),
    IN p_password VARCHAR(100),
    IN p_log_file VARCHAR(100),
    IN p_log_pos INT
)
BEGIN
    -- Configurar replicación
    SET @sql = CONCAT(
        'CHANGE MASTER TO ',
        'MASTER_HOST = ''', p_servidor_maestro, ''', ',
        'MASTER_USER = ''', p_usuario, ''', ',
        'MASTER_PASSWORD = ''', p_password, ''', ',
        'MASTER_LOG_FILE = ''', p_log_file, ''', ',
        'MASTER_LOG_POS = ', p_log_pos
    );
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Iniciar replicación
    START SLAVE;
    
    -- Registrar configuración
    INSERT INTO configuracion_replicacion (servidor_id, servidor_maestro, usuario_replicacion, estado)
    VALUES (@@server_id, p_servidor_maestro, p_usuario, 'ACTIVO');
END //
DELIMITER ;
```

### Ejercicio 2: Monitoreo Avanzado de Replicación
```sql
-- Crear tabla de métricas de replicación
CREATE TABLE metricas_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    retraso_segundos INT,
    bytes_recibidos BIGINT,
    eventos_procesados INT,
    errores_io INT,
    errores_sql INT,
    throughput_mb_por_segundo DECIMAL(10,2)
);

-- Procedimiento para recopilar métricas
DELIMITER //
CREATE PROCEDURE recopilar_metricas_replicacion()
BEGIN
    DECLARE v_retraso INT;
    DECLARE v_bytes_recibidos BIGINT;
    DECLARE v_eventos_procesados INT;
    DECLARE v_errores_io INT;
    DECLARE v_errores_sql INT;
    DECLARE v_throughput DECIMAL(10,2);
    
    -- Obtener métricas del estado de replicación
    SELECT 
        Seconds_Behind_Master,
        Master_Log_Pos - Read_Master_Log_Pos,
        Exec_Master_Log_Pos,
        Last_IO_Errno,
        Last_SQL_Errno
    INTO v_retraso, v_bytes_recibidos, v_eventos_procesados, v_errores_io, v_errores_sql
    FROM (
        SHOW SLAVE STATUS
    ) AS slave_status;
    
    -- Calcular throughput (simulado)
    SET v_throughput = v_bytes_recibidos / 1024 / 1024; -- MB por segundo
    
    -- Insertar métricas
    INSERT INTO metricas_replicacion (
        servidor_id, retraso_segundos, bytes_recibidos, eventos_procesados,
        errores_io, errores_sql, throughput_mb_por_segundo
    ) VALUES (
        @@server_id, v_retraso, v_bytes_recibidos, v_eventos_procesados,
        v_errores_io, v_errores_sql, v_throughput
    );
    
    -- Generar alertas si las métricas están fuera de rango
    IF v_retraso > 300 THEN -- Más de 5 minutos de retraso
        INSERT INTO alertas_replicacion (tipo_alerta, descripcion, nivel_critico)
        VALUES ('RETRASO_ALTO', CONCAT('Retraso de ', v_retraso, ' segundos'), 'ALTO');
    END IF;
    
    IF v_errores_io > 0 OR v_errores_sql > 0 THEN
        INSERT INTO alertas_replicacion (tipo_alerta, descripcion, nivel_critico)
        VALUES ('ERRORES_REPLICACION', CONCAT('Errores IO: ', v_errores_io, ', Errores SQL: ', v_errores_sql), 'CRITICO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 3: Sistema de Failover Automático
```sql
-- Crear tabla de configuración de failover
CREATE TABLE configuracion_failover (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_primario VARCHAR(100),
    servidor_secundario VARCHAR(100),
    tiempo_espera_segundos INT DEFAULT 30,
    activo BOOLEAN DEFAULT TRUE,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuración
INSERT INTO configuracion_failover (servidor_primario, servidor_secundario, tiempo_espera_segundos)
VALUES ('192.168.1.100', '192.168.1.101', 30);

-- Procedimiento para failover automático
DELIMITER //
CREATE PROCEDURE ejecutar_failover()
BEGIN
    DECLARE v_servidor_primario VARCHAR(100);
    DECLARE v_servidor_secundario VARCHAR(100);
    DECLARE v_tiempo_espera INT;
    DECLARE v_estado_primario VARCHAR(20);
    
    -- Obtener configuración
    SELECT servidor_primario, servidor_secundario, tiempo_espera_segundos
    INTO v_servidor_primario, v_servidor_secundario, v_tiempo_espera
    FROM configuracion_failover
    WHERE activo = TRUE
    LIMIT 1;
    
    -- Verificar estado del servidor primario
    -- (En implementación real, se haría ping o conexión)
    SET v_estado_primario = 'INACTIVO'; -- Simulado
    
    IF v_estado_primario = 'INACTIVO' THEN
        -- Detener replicación
        STOP SLAVE;
        
        -- Promover servidor secundario a maestro
        RESET SLAVE;
        
        -- Configurar como nuevo maestro
        SET GLOBAL read_only = OFF;
        
        -- Registrar failover
        INSERT INTO log_failover (servidor_anterior, servidor_nuevo, fecha_failover, tipo)
        VALUES (v_servidor_primario, v_servidor_secundario, NOW(), 'AUTOMATICO');
        
        -- Notificar administradores
        INSERT INTO notificaciones (tipo, mensaje, nivel_critico)
        VALUES ('FAILOVER', CONCAT('Failover ejecutado: ', v_servidor_secundario, ' es ahora el maestro'), 'CRITICO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 4: Replicación Selectiva por Tabla
```sql
-- Crear tabla de configuración de replicación selectiva
CREATE TABLE replicacion_selectiva (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tabla VARCHAR(100),
    replicar BOOLEAN DEFAULT TRUE,
    filtro_where TEXT,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar configuraciones
INSERT INTO replicacion_selectiva (nombre_tabla, replicar, filtro_where)
VALUES 
('clientes', TRUE, NULL),
('ventas', TRUE, 'fecha >= CURDATE() - INTERVAL 30 DAY'),
('logs', FALSE, NULL),
('productos', TRUE, 'activo = 1');

-- Procedimiento para configurar replicación selectiva
DELIMITER //
CREATE PROCEDURE configurar_replicacion_selectiva()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_tabla VARCHAR(100);
    DECLARE v_replicar BOOLEAN;
    DECLARE v_filtro TEXT;
    
    DECLARE cur CURSOR FOR
        SELECT nombre_tabla, replicar, filtro_where
        FROM replicacion_selectiva;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_tabla, v_replicar, v_filtro;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF v_replicar = TRUE THEN
            -- Configurar replicación para la tabla
            IF v_filtro IS NOT NULL THEN
                -- Replicación con filtro
                SET @sql = CONCAT('CHANGE REPLICATION FILTER REPLICATE_DO_TABLE = (', v_tabla, ')');
            ELSE
                -- Replicación completa de la tabla
                SET @sql = CONCAT('CHANGE REPLICATION FILTER REPLICATE_DO_TABLE = (', v_tabla, ')');
            END IF;
        ELSE
            -- Excluir tabla de replicación
            SET @sql = CONCAT('CHANGE REPLICATION FILTER REPLICATE_IGNORE_TABLE = (', v_tabla, ')');
        END IF;
        
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 5: Replicación con Compresión
```sql
-- Configurar replicación con compresión
SET GLOBAL slave_compressed_protocol = ON;

-- Crear tabla de estadísticas de compresión
CREATE TABLE estadisticas_compresion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bytes_sin_comprimir BIGINT,
    bytes_comprimidos BIGINT,
    ratio_compresion DECIMAL(5,2),
    tiempo_compresion_ms INT
);

-- Procedimiento para medir eficiencia de compresión
DELIMITER //
CREATE PROCEDURE medir_compresion()
BEGIN
    DECLARE v_bytes_sin_comprimir BIGINT;
    DECLARE v_bytes_comprimidos BIGINT;
    DECLARE v_ratio DECIMAL(5,2);
    DECLARE v_tiempo_ms INT;
    
    -- Simular medición de compresión
    SET v_bytes_sin_comprimir = 1048576; -- 1MB
    SET v_bytes_comprimidos = 262144;    -- 256KB
    SET v_ratio = (v_bytes_comprimidos / v_bytes_sin_comprimir) * 100;
    SET v_tiempo_ms = 50;
    
    -- Insertar estadísticas
    INSERT INTO estadisticas_compresion (
        bytes_sin_comprimir, bytes_comprimidos, ratio_compresion, tiempo_compresion_ms
    ) VALUES (
        v_bytes_sin_comprimir, v_bytes_comprimidos, v_ratio, v_tiempo_ms
    );
    
    -- Generar alerta si la compresión es ineficiente
    IF v_ratio > 80 THEN
        INSERT INTO alertas_replicacion (tipo_alerta, descripcion, nivel_critico)
        VALUES ('COMPRESION_INEFICIENTE', CONCAT('Ratio de compresión: ', v_ratio, '%'), 'MEDIO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 6: Replicación Multi-Maestro con Resolución de Conflictos
```sql
-- Crear tabla de configuración multi-maestro
CREATE TABLE configuracion_multi_maestro (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    servidor_maestro VARCHAR(100),
    prioridad INT DEFAULT 1,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar configuración
INSERT INTO configuracion_multi_maestro (servidor_id, servidor_maestro, prioridad)
VALUES 
(1, '192.168.1.100', 1),
(2, '192.168.1.101', 2),
(3, '192.168.1.102', 3);

-- Función para resolver conflictos por prioridad
DELIMITER //
CREATE FUNCTION resolver_conflicto_prioridad(
    p_servidor1 INT,
    p_servidor2 INT,
    p_datos1 JSON,
    p_datos2 JSON
)
RETURNS JSON
READS SQL DATA
BEGIN
    DECLARE v_prioridad1 INT;
    DECLARE v_prioridad2 INT;
    DECLARE resultado JSON;
    
    -- Obtener prioridades
    SELECT prioridad INTO v_prioridad1
    FROM configuracion_multi_maestro
    WHERE servidor_id = p_servidor1;
    
    SELECT prioridad INTO v_prioridad2
    FROM configuracion_multi_maestro
    WHERE servidor_id = p_servidor2;
    
    -- Resolver por prioridad (menor número = mayor prioridad)
    IF v_prioridad1 <= v_prioridad2 THEN
        SET resultado = p_datos1;
    ELSE
        SET resultado = p_datos2;
    END IF;
    
    -- Registrar resolución
    INSERT INTO conflictos_replicacion (
        tabla_afectada, servidor_origen, accion_conflicto,
        datos_originales, datos_nuevos, resolucion, observaciones
    ) VALUES (
        'multi_maestro', p_servidor1, 'UPDATE',
        p_datos1, resultado, 'AUTOMATICA',
        CONCAT('Resuelto por prioridad: Servidor ', p_servidor1, ' (', v_prioridad1, ') vs Servidor ', p_servidor2, ' (', v_prioridad2, ')')
    );
    
    RETURN resultado;
END //
DELIMITER ;
```

### Ejercicio 7: Replicación con Encriptación
```sql
-- Configurar replicación con SSL
CHANGE MASTER TO
    MASTER_HOST = '192.168.1.100',
    MASTER_USER = 'replicador',
    MASTER_PASSWORD = 'ReplicaPass123!',
    MASTER_SSL = 1,
    MASTER_SSL_CA = '/path/to/ca.pem',
    MASTER_SSL_CERT = '/path/to/client-cert.pem',
    MASTER_SSL_KEY = '/path/to/client-key.pem';

-- Crear tabla de configuración SSL
CREATE TABLE configuracion_ssl_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    ssl_habilitado BOOLEAN DEFAULT TRUE,
    certificado_ca VARCHAR(255),
    certificado_cliente VARCHAR(255),
    clave_privada VARCHAR(255),
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedimiento para verificar SSL
DELIMITER //
CREATE PROCEDURE verificar_ssl_replicacion()
BEGIN
    DECLARE v_ssl_activo BOOLEAN;
    DECLARE v_cipher VARCHAR(100);
    
    -- Verificar estado SSL
    SELECT 
        CASE WHEN Master_SSL_Allowed = 'Yes' THEN TRUE ELSE FALSE END,
        Master_SSL_Cipher
    INTO v_ssl_activo, v_cipher
    FROM (
        SHOW SLAVE STATUS
    ) AS slave_status;
    
    -- Registrar estado SSL
    INSERT INTO log_ssl_replicacion (servidor_id, ssl_activo, cipher_usado, fecha_verificacion)
    VALUES (@@server_id, v_ssl_activo, v_cipher, NOW());
    
    -- Generar alerta si SSL no está activo
    IF v_ssl_activo = FALSE THEN
        INSERT INTO alertas_replicacion (tipo_alerta, descripcion, nivel_critico)
        VALUES ('SSL_DESHABILITADO', 'Replicación sin encriptación SSL', 'ALTO');
    END IF;
END //
DELIMITER ;
```

### Ejercicio 8: Replicación con Filtros de Datos
```sql
-- Crear tabla de filtros de replicación
CREATE TABLE filtros_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_filtro VARCHAR(100),
    tabla_origen VARCHAR(100),
    tabla_destino VARCHAR(100),
    condicion_where TEXT,
    transformacion JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar filtros
INSERT INTO filtros_replicacion (nombre_filtro, tabla_origen, tabla_destino, condicion_where, transformacion)
VALUES 
('clientes_activos', 'clientes', 'clientes_replica', 'activo = 1', 
 JSON_OBJECT('campos', JSON_ARRAY('id', 'nombre', 'email'), 'excluir', JSON_ARRAY('telefono'))),
('ventas_recientes', 'ventas', 'ventas_replica', 'fecha >= CURDATE() - INTERVAL 90 DAY',
 JSON_OBJECT('campos', JSON_ARRAY('id', 'cliente_id', 'monto', 'fecha')));

-- Procedimiento para aplicar filtros
DELIMITER //
CREATE PROCEDURE aplicar_filtros_replicacion()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_filtro VARCHAR(100);
    DECLARE v_tabla_origen VARCHAR(100);
    DECLARE v_tabla_destino VARCHAR(100);
    DECLARE v_condicion TEXT;
    DECLARE v_transformacion JSON;
    
    DECLARE cur CURSOR FOR
        SELECT nombre_filtro, tabla_origen, tabla_destino, condicion_where, transformacion
        FROM filtros_replicacion
        WHERE activo = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_filtro, v_tabla_origen, v_tabla_destino, v_condicion, v_transformacion;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Aplicar filtro de replicación
        SET @sql = CONCAT(
            'CHANGE REPLICATION FILTER REPLICATE_DO_TABLE = (', v_tabla_origen, ')'
        );
        
        IF v_condicion IS NOT NULL THEN
            SET @sql = CONCAT(@sql, ' WHERE ', v_condicion);
        END IF;
        
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Registrar aplicación del filtro
        INSERT INTO log_filtros_replicacion (filtro, tabla_origen, tabla_destino, fecha_aplicacion)
        VALUES (v_filtro, v_tabla_origen, v_tabla_destino, NOW());
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 9: Sistema de Balanceo de Carga con Replicación
```sql
-- Crear tabla de configuración de balanceo
CREATE TABLE configuracion_balanceo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    peso_balanceo INT DEFAULT 1,
    estado ENUM('ACTIVO', 'INACTIVO', 'MANTENIMIENTO') DEFAULT 'ACTIVO',
    conexiones_activas INT DEFAULT 0,
    capacidad_maxima INT DEFAULT 100
);

-- Insertar configuración
INSERT INTO configuracion_balanceo (servidor_id, peso_balanceo, capacidad_maxima)
VALUES 
(1, 3, 100),
(2, 2, 80),
(3, 1, 60);

-- Función para seleccionar servidor óptimo
DELIMITER //
CREATE FUNCTION seleccionar_servidor_balanceo()
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_servidor_id INT;
    DECLARE v_peso_total INT;
    DECLARE v_peso_aleatorio INT;
    DECLARE v_peso_acumulado INT DEFAULT 0;
    
    -- Calcular peso total
    SELECT SUM(peso_balanceo) INTO v_peso_total
    FROM configuracion_balanceo
    WHERE estado = 'ACTIVO' AND conexiones_activas < capacidad_maxima;
    
    -- Generar número aleatorio
    SET v_peso_aleatorio = FLOOR(RAND() * v_peso_total) + 1;
    
    -- Seleccionar servidor basado en peso
    SELECT servidor_id INTO v_servidor_id
    FROM (
        SELECT 
            servidor_id,
            @peso_acumulado := @peso_acumulado + peso_balanceo as peso_acumulado
        FROM configuracion_balanceo,
        (SELECT @peso_acumulado := 0) r
        WHERE estado = 'ACTIVO' AND conexiones_activas < capacidad_maxima
        ORDER BY servidor_id
    ) AS weighted_servers
    WHERE peso_acumulado >= v_peso_aleatorio
    LIMIT 1;
    
    -- Incrementar contador de conexiones
    UPDATE configuracion_balanceo 
    SET conexiones_activas = conexiones_activas + 1
    WHERE servidor_id = v_servidor_id;
    
    RETURN v_servidor_id;
END //
DELIMITER ;
```

### Ejercicio 10: Sistema Completo de Gestión de Replicación
```sql
-- Crear tabla de dashboard de replicación
CREATE TABLE dashboard_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidores_activos INT,
    servidores_con_error INT,
    retraso_promedio_segundos INT,
    throughput_total_mb_por_segundo DECIMAL(10,2),
    conflictos_resueltos_hoy INT,
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Procedimiento para actualizar dashboard
DELIMITER //
CREATE PROCEDURE actualizar_dashboard_replicacion()
BEGIN
    DECLARE v_servidores_activos INT;
    DECLARE v_servidores_error INT;
    DECLARE v_retraso_promedio INT;
    DECLARE v_throughput_total DECIMAL(10,2);
    DECLARE v_conflictos_hoy INT;
    DECLARE v_estado_general VARCHAR(20);
    
    -- Contar servidores activos
    SELECT COUNT(*) INTO v_servidores_activos
    FROM monitoreo_replicacion
    WHERE estado_replicacion = 'FUNCIONANDO'
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    -- Contar servidores con error
    SELECT COUNT(*) INTO v_servidores_error
    FROM monitoreo_replicacion
    WHERE estado_replicacion IN ('ERROR', 'DETENIDO')
    AND fecha_verificacion > DATE_SUB(NOW(), INTERVAL 5 MINUTE);
    
    -- Calcular retraso promedio
    SELECT AVG(retraso_segundos) INTO v_retraso_promedio
    FROM metricas_replicacion
    WHERE fecha_medicion > DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Calcular throughput total
    SELECT SUM(throughput_mb_por_segundo) INTO v_throughput_total
    FROM metricas_replicacion
    WHERE fecha_medicion > DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Contar conflictos resueltos hoy
    SELECT COUNT(*) INTO v_conflictos_hoy
    FROM conflictos_replicacion
    WHERE DATE(fecha_conflicto) = CURDATE()
    AND resolucion = 'AUTOMATICA';
    
    -- Determinar estado general
    IF v_servidores_error > 0 THEN
        SET v_estado_general = 'CRITICO';
    ELSEIF v_retraso_promedio > 300 THEN
        SET v_estado_general = 'ADVERTENCIA';
    ELSE
        SET v_estado_general = 'NORMAL';
    END IF;
    
    -- Actualizar dashboard
    INSERT INTO dashboard_replicacion (
        servidores_activos, servidores_con_error, retraso_promedio_segundos,
        throughput_total_mb_por_segundo, conflictos_resueltos_hoy, estado_general
    ) VALUES (
        v_servidores_activos, v_servidores_error, v_retraso_promedio,
        v_throughput_total, v_conflictos_hoy, v_estado_general
    );
END //
DELIMITER ;

-- Evento para actualización automática
CREATE EVENT actualizar_dashboard_replicacion_horario
ON SCHEDULE EVERY 5 MINUTE
STARTS '2024-01-01 00:00:00'
DO
  CALL actualizar_dashboard_replicacion();

-- Vista para reporte de replicación
CREATE VIEW reporte_replicacion AS
SELECT 
    DATE(fecha_verificacion) as fecha,
    COUNT(*) as total_verificaciones,
    SUM(CASE WHEN estado_replicacion = 'FUNCIONANDO' THEN 1 ELSE 0 END) as servidores_ok,
    SUM(CASE WHEN estado_replicacion = 'ERROR' THEN 1 ELSE 0 END) as servidores_error,
    AVG(retraso_segundos) as retraso_promedio,
    MAX(retraso_segundos) as retraso_maximo
FROM monitoreo_replicacion
WHERE fecha_verificacion > DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(fecha_verificacion)
ORDER BY fecha DESC;
```

## Resumen
En esta clase hemos aprendido sobre:
- Configuración de replicación maestro-esclavo
- Replicación maestro-maestro y circular
- Monitoreo y métricas de replicación
- Gestión de conflictos y resolución automática
- Sistemas de failover automático
- Replicación selectiva y con filtros
- Compresión y encriptación en replicación
- Balanceo de carga con replicación
- Dashboards y reportes de replicación

## Próxima Clase
En la siguiente clase aprenderemos sobre clustering y alta disponibilidad, incluyendo configuración de clusters, balanceo de carga y sistemas de alta disponibilidad.
