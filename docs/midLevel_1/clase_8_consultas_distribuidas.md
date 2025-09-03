# Clase 8: Consultas Distribuidas

## Objetivos de la Clase
- Dominar técnicas de consultas distribuidas
- Implementar estrategias de replicación y sharding
- Manejar consultas en múltiples bases de datos
- Optimizar rendimiento en entornos distribuidos

## 1. Introducción a Consultas Distribuidas

### ¿Qué son las Consultas Distribuidas?
Las consultas distribuidas son operaciones SQL que involucran múltiples bases de datos, servidores o particiones, permitiendo procesar datos que están distribuidos en diferentes ubicaciones.

### Desafíos de las Consultas Distribuidas
- **Latencia de Red**: Tiempo de comunicación entre servidores
- **Consistencia**: Mantener coherencia entre múltiples fuentes
- **Disponibilidad**: Manejar fallos de servidores individuales
- **Escalabilidad**: Distribuir carga entre múltiples nodos

## 2. Replicación de Bases de Datos

### Configuración de Replicación
```sql
-- En el servidor maestro (Master)
-- Configurar binlog
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = 'ROW';

-- Crear usuario para replicación
CREATE USER 'replicator'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- Ver estado del binlog
SHOW MASTER STATUS;
```

### Consultas en Entorno de Replicación
```sql
-- Consultas de lectura en esclavo
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos
GROUP BY categoria;

-- Consultas de escritura en maestro
INSERT INTO productos (nombre, categoria, precio) 
VALUES ('Nuevo Producto', 'Electrónicos', 299.99);
```

## 3. Sharding Horizontal

### Estrategias de Sharding
```sql
-- Sharding por rango de ID
-- Shard 1: IDs 1-1000000
SELECT 
    id,
    nombre,
    precio
FROM productos_shard1
WHERE id BETWEEN 1 AND 1000000;

-- Shard 2: IDs 1000001-2000000
SELECT 
    id,
    nombre,
    precio
FROM productos_shard2
WHERE id BETWEEN 1000001 AND 2000000;

-- Sharding por hash
-- Determinar shard basado en hash del ID
SELECT 
    id,
    nombre,
    precio
FROM productos_shard_${hash(id) % num_shards}
WHERE id = 12345;
```

### Consultas Cross-Shard
```sql
-- Consulta que requiere datos de múltiples shards
-- Usar UNION para combinar resultados
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM (
    SELECT categoria FROM productos_shard1
    UNION ALL
    SELECT categoria FROM productos_shard2
    UNION ALL
    SELECT categoria FROM productos_shard3
) AS all_products
GROUP BY categoria;
```

## 4. Federated Tables

### Configuración de Federated Tables
```sql
-- Crear tabla federada
CREATE TABLE productos_remotos (
    id INT AUTO_INCREMENT,
    nombre VARCHAR(100),
    categoria VARCHAR(50),
    precio DECIMAL(10,2),
    PRIMARY KEY (id)
) ENGINE=FEDERATED
CONNECTION='mysql://usuario:password@servidor_remoto:3306/base_datos/productos';

-- Consulta en tabla federada
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos_remotos
GROUP BY categoria;
```

### Consultas con Tablas Federadas
```sql
-- JOIN entre tabla local y federada
SELECT 
    l.nombre AS producto_local,
    r.nombre AS producto_remoto,
    l.precio AS precio_local,
    r.precio AS precio_remoto
FROM productos_locales l
JOIN productos_remotos r ON l.categoria = r.categoria
WHERE l.precio > r.precio;
```

## 5. Partitioning Distribuido

### Particionamiento por Servidor
```sql
-- Crear vistas que combinen particiones distribuidas
CREATE VIEW productos_distribuidos AS
SELECT * FROM productos_servidor1
UNION ALL
SELECT * FROM productos_servidor2
UNION ALL
SELECT * FROM productos_servidor3;

-- Consulta en vista distribuida
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos_distribuidos
GROUP BY categoria;
```

### Consultas Optimizadas para Particionamiento
```sql
-- Consulta que aprovecha el particionamiento
-- Solo acceder a particiones relevantes
SELECT 
    nombre,
    precio
FROM productos_servidor1  -- Solo servidor 1
WHERE categoria = 'Electrónicos'
    AND precio > 100;
```

## 6. Stored Procedures Distribuidas

### Procedimientos para Consultas Distribuidas
```sql
DELIMITER //
CREATE PROCEDURE GetProductosDistribuidos(
    IN p_categoria VARCHAR(50),
    IN p_precio_min DECIMAL(10,2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE total_productos INT DEFAULT 0;
    
    -- Consulta en servidor 1
    SELECT COUNT(*) INTO @count1
    FROM productos_servidor1
    WHERE categoria = p_categoria AND precio >= p_precio_min;
    
    -- Consulta en servidor 2
    SELECT COUNT(*) INTO @count2
    FROM productos_servidor2
    WHERE categoria = p_categoria AND precio >= p_precio_min;
    
    -- Consulta en servidor 3
    SELECT COUNT(*) INTO @count3
    FROM productos_servidor3
    WHERE categoria = p_categoria AND precio >= p_precio_min;
    
    -- Combinar resultados
    SET total_productos = @count1 + @count2 + @count3;
    
    SELECT total_productos AS total_productos_encontrados;
END //
DELIMITER ;
```

## 7. Optimización de Consultas Distribuidas

### Reducir Latencia de Red
```sql
-- Consulta optimizada para reducir roundtrips
-- Usar batch operations
INSERT INTO productos_servidor1 (nombre, categoria, precio)
VALUES 
    ('Producto 1', 'Electrónicos', 100.00),
    ('Producto 2', 'Electrónicos', 200.00),
    ('Producto 3', 'Electrónicos', 300.00);
```

### Caching de Resultados
```sql
-- Crear tabla de cache para resultados distribuidos
CREATE TABLE cache_resultados_distribuidos (
    consulta_hash VARCHAR(64) PRIMARY KEY,
    resultado JSON,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP
);

-- Función para obtener resultado cacheado
DELIMITER //
CREATE FUNCTION GetResultadoCacheado(consulta_hash VARCHAR(64))
RETURNS JSON
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE resultado JSON;
    
    SELECT cache.resultado INTO resultado
    FROM cache_resultados_distribuidos cache
    WHERE cache.consulta_hash = consulta_hash
        AND cache.fecha_expiracion > NOW();
    
    RETURN resultado;
END //
DELIMITER ;
```

## 8. Manejo de Transacciones Distribuidas

### Transacciones XA
```sql
-- Iniciar transacción distribuida
XA START 'transaccion_distribuida';

-- Operaciones en servidor 1
INSERT INTO productos_servidor1 (nombre, categoria, precio)
VALUES ('Producto Distribuido', 'Electrónicos', 150.00);

-- Operaciones en servidor 2
INSERT INTO productos_servidor2 (nombre, categoria, precio)
VALUES ('Producto Distribuido', 'Electrónicos', 150.00);

-- Preparar transacción
XA END 'transaccion_distribuida';
XA PREPARE 'transaccion_distribuida';

-- Commit o rollback
XA COMMIT 'transaccion_distribuida';
-- O en caso de error:
-- XA ROLLBACK 'transaccion_distribuida';
```

### Compensación de Transacciones
```sql
-- Procedimiento para compensar transacciones fallidas
DELIMITER //
CREATE PROCEDURE CompensarTransaccion(
    IN p_transaccion_id VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Revertir cambios en servidor 1
    DELETE FROM productos_servidor1 
    WHERE transaccion_id = p_transaccion_id;
    
    -- Revertir cambios en servidor 2
    DELETE FROM productos_servidor2 
    WHERE transaccion_id = p_transaccion_id;
    
    -- Marcar transacción como compensada
    INSERT INTO log_compensaciones (transaccion_id, fecha_compensacion)
    VALUES (p_transaccion_id, NOW());
    
    COMMIT;
END //
DELIMITER ;
```

## 9. Monitoreo de Consultas Distribuidas

### Análisis de Rendimiento
```sql
-- Monitorear latencia de consultas distribuidas
SELECT 
    'Servidor 1' AS servidor,
    COUNT(*) AS total_consultas,
    AVG(tiempo_ejecucion) AS tiempo_promedio,
    MAX(tiempo_ejecucion) AS tiempo_maximo
FROM log_consultas_servidor1
WHERE fecha >= DATE_SUB(NOW(), INTERVAL 1 HOUR)

UNION ALL

SELECT 
    'Servidor 2' AS servidor,
    COUNT(*) AS total_consultas,
    AVG(tiempo_ejecucion) AS tiempo_promedio,
    MAX(tiempo_ejecucion) AS tiempo_maximo
FROM log_consultas_servidor2
WHERE fecha >= DATE_SUB(NOW(), INTERVAL 1 HOUR);
```

### Detección de Problemas
```sql
-- Detectar servidores con problemas de rendimiento
SELECT 
    servidor,
    fecha,
    COUNT(*) AS consultas_lentas
FROM (
    SELECT 'Servidor 1' AS servidor, fecha, tiempo_ejecucion
    FROM log_consultas_servidor1
    WHERE tiempo_ejecucion > 5
    
    UNION ALL
    
    SELECT 'Servidor 2' AS servidor, fecha, tiempo_ejecucion
    FROM log_consultas_servidor2
    WHERE tiempo_ejecucion > 5
) AS consultas_lentas
GROUP BY servidor, fecha
ORDER BY fecha DESC, consultas_lentas DESC;
```

## 10. Estrategias de Fallback

### Consultas con Fallback
```sql
-- Procedimiento con estrategia de fallback
DELIMITER //
CREATE PROCEDURE GetProductosConFallback(
    IN p_categoria VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Fallback a servidor secundario
        SELECT 
            nombre,
            precio
        FROM productos_servidor_backup
        WHERE categoria = p_categoria;
    END;
    
    -- Intentar consulta en servidor principal
    SELECT 
        nombre,
        precio
    FROM productos_servidor_principal
    WHERE categoria = p_categoria;
END //
DELIMITER ;
```

### Balanceo de Carga
```sql
-- Función para seleccionar servidor basado en carga
DELIMITER //
CREATE FUNCTION SeleccionarServidor()
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE servidor_seleccionado VARCHAR(50);
    
    -- Seleccionar servidor con menor carga
    SELECT servidor INTO servidor_seleccionado
    FROM (
        SELECT 'servidor1' AS servidor, COUNT(*) AS carga
        FROM log_consultas_servidor1
        WHERE fecha >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
        
        UNION ALL
        
        SELECT 'servidor2' AS servidor, COUNT(*) AS carga
        FROM log_consultas_servidor2
        WHERE fecha >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
    ) AS carga_servidores
    ORDER BY carga ASC
    LIMIT 1;
    
    RETURN servidor_seleccionado;
END //
DELIMITER ;
```

## Ejercicios Prácticos

### Ejercicio 1: Consulta Cross-Shard
```sql
-- Consulta que combina datos de múltiples shards
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM (
    SELECT categoria, precio FROM productos_shard1
    UNION ALL
    SELECT categoria, precio FROM productos_shard2
    UNION ALL
    SELECT categoria, precio FROM productos_shard3
) AS productos_todos
GROUP BY categoria
ORDER BY total_productos DESC;
```

### Ejercicio 2: Tabla Federada
```sql
-- Crear tabla federada para productos remotos
CREATE TABLE productos_remotos (
    id INT AUTO_INCREMENT,
    nombre VARCHAR(100),
    categoria VARCHAR(50),
    precio DECIMAL(10,2),
    PRIMARY KEY (id)
) ENGINE=FEDERATED
CONNECTION='mysql://usuario:password@servidor_remoto:3306/base_datos/productos';

-- Consulta comparativa entre local y remoto
SELECT 
    l.categoria,
    l.precio AS precio_local,
    r.precio AS precio_remoto,
    (l.precio - r.precio) AS diferencia_precio
FROM productos_locales l
JOIN productos_remotos r ON l.categoria = r.categoria
WHERE ABS(l.precio - r.precio) > 10;
```

### Ejercicio 3: Procedimiento Distribuido
```sql
-- Procedimiento para consulta distribuida
DELIMITER //
CREATE PROCEDURE GetEstadisticasDistribuidas()
BEGIN
    DECLARE total_servidor1 INT DEFAULT 0;
    DECLARE total_servidor2 INT DEFAULT 0;
    DECLARE total_servidor3 INT DEFAULT 0;
    
    -- Obtener totales de cada servidor
    SELECT COUNT(*) INTO total_servidor1 FROM productos_servidor1;
    SELECT COUNT(*) INTO total_servidor2 FROM productos_servidor2;
    SELECT COUNT(*) INTO total_servidor3 FROM productos_servidor3;
    
    -- Mostrar estadísticas
    SELECT 
        'Servidor 1' AS servidor,
        total_servidor1 AS total_productos
    
    UNION ALL
    
    SELECT 
        'Servidor 2' AS servidor,
        total_servidor2 AS total_productos
    
    UNION ALL
    
    SELECT 
        'Servidor 3' AS servidor,
        total_servidor3 AS total_productos
    
    UNION ALL
    
    SELECT 
        'TOTAL' AS servidor,
        (total_servidor1 + total_servidor2 + total_servidor3) AS total_productos;
END //
DELIMITER ;
```

### Ejercicio 4: Transacción Distribuida
```sql
-- Transacción distribuida con XA
XA START 'transaccion_productos';

-- Insertar en servidor 1
INSERT INTO productos_servidor1 (nombre, categoria, precio)
VALUES ('Producto Distribuido 1', 'Electrónicos', 100.00);

-- Insertar en servidor 2
INSERT INTO productos_servidor2 (nombre, categoria, precio)
VALUES ('Producto Distribuido 2', 'Electrónicos', 200.00);

-- Finalizar transacción
XA END 'transaccion_productos';
XA PREPARE 'transaccion_productos';
XA COMMIT 'transaccion_productos';
```

### Ejercicio 5: Monitoreo de Rendimiento
```sql
-- Monitorear rendimiento de consultas distribuidas
SELECT 
    servidor,
    fecha,
    COUNT(*) AS total_consultas,
    AVG(tiempo_ejecucion) AS tiempo_promedio,
    MAX(tiempo_ejecucion) AS tiempo_maximo,
    COUNT(CASE WHEN tiempo_ejecucion > 5 THEN 1 END) AS consultas_lentas
FROM (
    SELECT 'Servidor 1' AS servidor, fecha, tiempo_ejecucion
    FROM log_consultas_servidor1
    WHERE fecha >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
    
    UNION ALL
    
    SELECT 'Servidor 2' AS servidor, fecha, tiempo_ejecucion
    FROM log_consultas_servidor2
    WHERE fecha >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
) AS consultas_distribuidas
GROUP BY servidor, fecha
ORDER BY fecha DESC;
```

### Ejercicio 6: Estrategia de Fallback
```sql
-- Procedimiento con fallback automático
DELIMITER //
CREATE PROCEDURE GetProductosConFallback(
    IN p_categoria VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Fallback a servidor secundario
        SELECT 
            'FALLBACK' AS origen,
            nombre,
            precio
        FROM productos_servidor_backup
        WHERE categoria = p_categoria;
    END;
    
    -- Intentar consulta en servidor principal
    SELECT 
        'PRINCIPAL' AS origen,
        nombre,
        precio
    FROM productos_servidor_principal
    WHERE categoria = p_categoria;
END //
DELIMITER ;
```

### Ejercicio 7: Balanceo de Carga
```sql
-- Función para balanceo de carga
DELIMITER //
CREATE FUNCTION SeleccionarServidorOptimo()
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE servidor_seleccionado VARCHAR(50);
    
    -- Seleccionar servidor con menor carga
    SELECT servidor INTO servidor_seleccionado
    FROM (
        SELECT 'servidor1' AS servidor, 
               COUNT(*) AS carga_actual
        FROM log_consultas_servidor1
        WHERE fecha >= DATE_SUB(NOW(), INTERVAL 1 MINUTE)
        
        UNION ALL
        
        SELECT 'servidor2' AS servidor, 
               COUNT(*) AS carga_actual
        FROM log_consultas_servidor2
        WHERE fecha >= DATE_SUB(NOW(), INTERVAL 1 MINUTE)
    ) AS carga_servidores
    ORDER BY carga_actual ASC
    LIMIT 1;
    
    RETURN servidor_seleccionado;
END //
DELIMITER ;
```

### Ejercicio 8: Cache de Resultados Distribuidos
```sql
-- Crear sistema de cache para consultas distribuidas
CREATE TABLE cache_consultas_distribuidas (
    consulta_hash VARCHAR(64) PRIMARY KEY,
    resultado JSON,
    servidores_involucrados JSON,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP
);

-- Función para obtener resultado cacheado
DELIMITER //
CREATE FUNCTION GetResultadoCacheado(consulta_hash VARCHAR(64))
RETURNS JSON
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE resultado JSON;
    
    SELECT cache.resultado INTO resultado
    FROM cache_consultas_distribuidas cache
    WHERE cache.consulta_hash = consulta_hash
        AND cache.fecha_expiracion > NOW();
    
    RETURN resultado;
END //
DELIMITER ;
```

### Ejercicio 9: Detección de Problemas
```sql
-- Detectar problemas en servidores distribuidos
SELECT 
    servidor,
    fecha,
    COUNT(*) AS consultas_lentas,
    AVG(tiempo_ejecucion) AS tiempo_promedio,
    MAX(tiempo_ejecucion) AS tiempo_maximo
FROM (
    SELECT 'Servidor 1' AS servidor, fecha, tiempo_ejecucion
    FROM log_consultas_servidor1
    WHERE tiempo_ejecucion > 3
        AND fecha >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
    
    UNION ALL
    
    SELECT 'Servidor 2' AS servidor, fecha, tiempo_ejecucion
    FROM log_consultas_servidor2
    WHERE tiempo_ejecucion > 3
        AND fecha >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
) AS consultas_problematicas
GROUP BY servidor, fecha
HAVING COUNT(*) > 10
ORDER BY consultas_lentas DESC;
```

### Ejercicio 10: Consulta Distribuida Compleja
```sql
-- Consulta compleja que combina múltiples servidores
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio,
    MIN(precio) AS precio_minimo,
    MAX(precio) AS precio_maximo,
    STDDEV(precio) AS desviacion_precio
FROM (
    SELECT categoria, precio FROM productos_servidor1
    UNION ALL
    SELECT categoria, precio FROM productos_servidor2
    UNION ALL
    SELECT categoria, precio FROM productos_servidor3
) AS productos_distribuidos
WHERE precio > 50
GROUP BY categoria
HAVING COUNT(*) > 10
ORDER BY precio_promedio DESC;
```

## Resumen de la Clase

En esta clase hemos cubierto:

1. **Replicación**: Configuración y consultas en entornos de replicación
2. **Sharding**: Estrategias de particionamiento horizontal
3. **Federated Tables**: Consultas en bases de datos remotas
4. **Partitioning Distribuido**: Particionamiento por servidor
5. **Stored Procedures**: Procedimientos para consultas distribuidas
6. **Optimización**: Reducir latencia y usar caching
7. **Transacciones Distribuidas**: XA transactions y compensación
8. **Monitoreo**: Análisis de rendimiento en entornos distribuidos
9. **Estrategias de Fallback**: Manejo de fallos y balanceo de carga
10. **Técnicas Avanzadas**: Cache distribuido y detección de problemas

## Próxima Clase
En la siguiente clase exploraremos técnicas de automatización para optimizar y mantener bases de datos.

## Recursos Adicionales
- Documentación de replicación de MySQL
- Guías de sharding y particionamiento
- Herramientas de monitoreo distribuido
- Mejores prácticas de consultas distribuidas
