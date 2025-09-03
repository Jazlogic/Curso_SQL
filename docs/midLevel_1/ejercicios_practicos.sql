-- =====================================================
-- EJERCICIOS PRÁCTICOS - MÓDULO 1 MID-LEVEL
-- Optimización y Rendimiento de Bases de Datos
-- =====================================================

-- =====================================================
-- EJERCICIOS DE LA CLASE 1: CONSULTAS AVANZADAS
-- =====================================================

-- Ejercicio 1: Consultas con CTEs recursivas
WITH RECURSIVE empleados_jerarquia AS (
    SELECT id, nombre, supervisor_id, 1 as nivel
    FROM empleados 
    WHERE supervisor_id IS NULL
    UNION ALL
    SELECT e.id, e.nombre, e.supervisor_id, ej.nivel + 1
    FROM empleados e
    JOIN empleados_jerarquia ej ON e.supervisor_id = ej.id
)
SELECT * FROM empleados_jerarquia ORDER BY nivel, nombre;

-- Ejercicio 2: Funciones de ventana avanzadas
SELECT 
    producto_id,
    nombre,
    precio,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio) as ranking_precio,
    LAG(precio, 1) OVER (ORDER BY precio) as precio_anterior,
    LEAD(precio, 1) OVER (ORDER BY precio) as precio_siguiente
FROM productos;

-- Ejercicio 3: Consultas con EXISTS y NOT EXISTS
SELECT c.nombre
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p 
    WHERE p.cliente_id = c.id 
    AND p.fecha >= '2024-01-01'
);

-- Ejercicio 4: Consultas con CASE WHEN avanzado
SELECT 
    producto_id,
    nombre,
    precio,
    CASE 
        WHEN precio < 100 THEN 'Económico'
        WHEN precio BETWEEN 100 AND 500 THEN 'Medio'
        WHEN precio > 500 THEN 'Premium'
    END as categoria_precio
FROM productos;

-- Ejercicio 5: Consultas con COALESCE y NULLIF
SELECT 
    id,
    nombre,
    COALESCE(telefono, 'No disponible') as telefono,
    NULLIF(precio, 0) as precio_valido
FROM productos;

-- Ejercicio 6: Consultas con GROUP BY avanzado
SELECT 
    categoria,
    COUNT(*) as total_productos,
    AVG(precio) as precio_promedio,
    MAX(precio) as precio_maximo,
    MIN(precio) as precio_minimo
FROM productos
GROUP BY categoria
HAVING COUNT(*) > 5;

-- Ejercicio 7: Consultas con ROLLUP
SELECT 
    categoria,
    subcategoria,
    COUNT(*) as total
FROM productos
GROUP BY ROLLUP(categoria, subcategoria);

-- Ejercicio 8: Consultas con CUBE
SELECT 
    categoria,
    subcategoria,
    COUNT(*) as total
FROM productos
GROUP BY CUBE(categoria, subcategoria);

-- Ejercicio 9: Consultas con GROUPING SETS
SELECT 
    categoria,
    subcategoria,
    COUNT(*) as total
FROM productos
GROUP BY GROUPING SETS (
    (categoria),
    (subcategoria),
    (categoria, subcategoria),
    ()
);

-- Ejercicio 10: Consultas con PIVOT
SELECT *
FROM (
    SELECT categoria, precio
    FROM productos
) AS source
PIVOT (
    AVG(precio) FOR categoria IN ([Electrónicos], [Ropa], [Hogar])
) AS pivot_table;

-- =====================================================
-- EJERCICIOS DE LA CLASE 2: OPTIMIZACIÓN DE RENDIMIENTO
-- =====================================================

-- Ejercicio 1: Análisis de planes de ejecución
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- Ejercicio 2: Optimización de consultas con índices
CREATE INDEX idx_productos_categoria ON productos(categoria);
SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- Ejercicio 3: Optimización de consultas con LIMIT
SELECT * FROM productos 
WHERE categoria = 'Electrónicos' 
ORDER BY precio DESC 
LIMIT 10;

-- Ejercicio 4: Optimización de consultas con EXISTS
SELECT c.nombre
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p 
    WHERE p.cliente_id = c.id 
    AND p.fecha >= '2024-01-01'
);

-- Ejercicio 5: Optimización de consultas con IN vs EXISTS
-- Versión con IN
SELECT * FROM productos 
WHERE categoria IN ('Electrónicos', 'Ropa', 'Hogar');

-- Versión con EXISTS
SELECT p.* FROM productos p
WHERE EXISTS (
    SELECT 1 FROM categorias c 
    WHERE c.nombre = p.categoria 
    AND c.nombre IN ('Electrónicos', 'Ropa', 'Hogar')
);

-- Ejercicio 6: Optimización de consultas con JOIN
SELECT p.nombre, c.nombre as categoria
FROM productos p
INNER JOIN categorias c ON p.categoria = c.nombre;

-- Ejercicio 7: Optimización de consultas con subconsultas
SELECT p.nombre, p.precio
FROM productos p
WHERE p.precio > (
    SELECT AVG(precio) FROM productos WHERE categoria = p.categoria
);

-- Ejercicio 8: Optimización de consultas con funciones de ventana
SELECT 
    producto_id,
    nombre,
    precio,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio) as ranking
FROM productos;

-- Ejercicio 9: Optimización de consultas con CTEs
WITH productos_caros AS (
    SELECT * FROM productos WHERE precio > 500
)
SELECT * FROM productos_caros WHERE categoria = 'Electrónicos';

-- Ejercicio 10: Optimización de consultas con UNION
SELECT nombre FROM productos WHERE categoria = 'Electrónicos'
UNION
SELECT nombre FROM productos WHERE categoria = 'Ropa';

-- =====================================================
-- EJERCICIOS DE LA CLASE 3: ÍNDICES AVANZADOS
-- =====================================================

-- Ejercicio 1: Índices simples
CREATE INDEX idx_productos_nombre ON productos(nombre);

-- Ejercicio 2: Índices compuestos
CREATE INDEX idx_productos_categoria_precio ON productos(categoria, precio);

-- Ejercicio 3: Índices únicos
CREATE UNIQUE INDEX idx_productos_codigo ON productos(codigo);

-- Ejercicio 4: Índices de texto completo
CREATE FULLTEXT INDEX idx_productos_descripcion ON productos(descripcion);

-- Ejercicio 5: Índices parciales
CREATE INDEX idx_productos_activos ON productos(nombre) 
WHERE activo = 1;

-- Ejercicio 6: Índices funcionales
CREATE INDEX idx_productos_nombre_upper ON productos(UPPER(nombre));

-- Ejercicio 7: Índices de cobertura
CREATE INDEX idx_productos_cobertura ON productos(categoria, precio, nombre);

-- Ejercicio 8: Análisis de uso de índices
SHOW INDEX FROM productos;

-- Ejercicio 9: Optimización de índices
ANALYZE TABLE productos;

-- Ejercicio 10: Eliminación de índices
DROP INDEX idx_productos_nombre ON productos;

-- =====================================================
-- EJERCICIOS DE LA CLASE 4: PARTICIONAMIENTO
-- =====================================================

-- Ejercicio 1: Particionamiento por rango
CREATE TABLE ventas_particionada (
    id INT,
    fecha DATE,
    monto DECIMAL(10,2)
) PARTITION BY RANGE (YEAR(fecha)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025)
);

-- Ejercicio 2: Particionamiento por lista
CREATE TABLE productos_particionada (
    id INT,
    categoria VARCHAR(50),
    nombre VARCHAR(100)
) PARTITION BY LIST (categoria) (
    PARTITION p_electronicos VALUES IN ('Electrónicos'),
    PARTITION p_ropa VALUES IN ('Ropa'),
    PARTITION p_hogar VALUES IN ('Hogar')
);

-- Ejercicio 3: Particionamiento por hash
CREATE TABLE usuarios_particionada (
    id INT,
    nombre VARCHAR(100),
    email VARCHAR(100)
) PARTITION BY HASH(id) PARTITIONS 4;

-- Ejercicio 4: Consultas en tablas particionadas
SELECT * FROM ventas_particionada WHERE fecha >= '2024-01-01';

-- Ejercicio 5: Mantenimiento de particiones
ALTER TABLE ventas_particionada ADD PARTITION (
    PARTITION p2025 VALUES LESS THAN (2026)
);

-- Ejercicio 6: Eliminación de particiones
ALTER TABLE ventas_particionada DROP PARTITION p2022;

-- Ejercicio 7: Análisis de particiones
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    DATA_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_NAME = 'ventas_particionada';

-- Ejercicio 8: Optimización de consultas particionadas
SELECT * FROM ventas_particionada 
WHERE fecha BETWEEN '2024-01-01' AND '2024-12-31';

-- Ejercicio 9: Particionamiento subparticionado
CREATE TABLE ventas_subparticionada (
    id INT,
    fecha DATE,
    region VARCHAR(50),
    monto DECIMAL(10,2)
) PARTITION BY RANGE (YEAR(fecha))
SUBPARTITION BY HASH (region) SUBPARTITIONS 4 (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026)
);

-- Ejercicio 10: Migración de datos a particiones
INSERT INTO ventas_particionada 
SELECT * FROM ventas WHERE fecha >= '2024-01-01';

-- =====================================================
-- EJERCICIOS DE LA CLASE 5: CONSULTAS ANALÍTICAS
-- =====================================================

-- Ejercicio 1: Funciones de ventana básicas
SELECT 
    producto_id,
    nombre,
    precio,
    ROW_NUMBER() OVER (ORDER BY precio DESC) as ranking_precio,
    RANK() OVER (ORDER BY precio DESC) as rango_precio,
    DENSE_RANK() OVER (ORDER BY precio DESC) as rango_denso
FROM productos;

-- Ejercicio 2: Funciones de ventana con particiones
SELECT 
    categoria,
    producto_id,
    nombre,
    precio,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) as ranking_categoria
FROM productos;

-- Ejercicio 3: Funciones LAG y LEAD
SELECT 
    producto_id,
    nombre,
    precio,
    LAG(precio, 1) OVER (ORDER BY precio) as precio_anterior,
    LEAD(precio, 1) OVER (ORDER BY precio) as precio_siguiente
FROM productos;

-- Ejercicio 4: Funciones de agregación en ventanas
SELECT 
    categoria,
    producto_id,
    nombre,
    precio,
    AVG(precio) OVER (PARTITION BY categoria) as precio_promedio_categoria,
    SUM(precio) OVER (PARTITION BY categoria) as total_categoria
FROM productos;

-- Ejercicio 5: Marcos de ventana
SELECT 
    producto_id,
    nombre,
    precio,
    AVG(precio) OVER (
        ORDER BY precio 
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) as precio_promedio_ventana
FROM productos;

-- Ejercicio 6: Funciones de distribución
SELECT 
    producto_id,
    nombre,
    precio,
    CUME_DIST() OVER (ORDER BY precio) as distribucion_acumulada,
    PERCENT_RANK() OVER (ORDER BY precio) as rango_porcentual
FROM productos;

-- Ejercicio 7: Funciones de ranking avanzadas
SELECT 
    producto_id,
    nombre,
    precio,
    NTILE(4) OVER (ORDER BY precio) as cuartil
FROM productos;

-- Ejercicio 8: Consultas analíticas complejas
SELECT 
    categoria,
    COUNT(*) as total_productos,
    AVG(precio) as precio_promedio,
    STDDEV(precio) as desviacion_estandar,
    MIN(precio) as precio_minimo,
    MAX(precio) as precio_maximo
FROM productos
GROUP BY categoria;

-- Ejercicio 9: Análisis de tendencias
SELECT 
    YEAR(fecha) as año,
    MONTH(fecha) as mes,
    COUNT(*) as total_ventas,
    SUM(monto) as monto_total,
    AVG(monto) as monto_promedio
FROM ventas
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY año, mes;

-- Ejercicio 10: Análisis de cohortes
SELECT 
    YEAR(fecha_registro) as año_registro,
    MONTH(fecha_registro) as mes_registro,
    COUNT(*) as usuarios_registrados,
    COUNT(CASE WHEN fecha_ultima_actividad >= DATE_ADD(fecha_registro, INTERVAL 30 DAY) THEN 1 END) as usuarios_activos_30_dias
FROM usuarios
GROUP BY YEAR(fecha_registro), MONTH(fecha_registro)
ORDER BY año_registro, mes_registro;

-- =====================================================
-- EJERCICIOS DE LA CLASE 6: GESTIÓN DE MEMORIA
-- =====================================================

-- Ejercicio 1: Configuración de memoria
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

-- Ejercicio 2: Análisis de uso de memoria
SHOW STATUS LIKE 'Innodb_buffer_pool%';

-- Ejercicio 3: Optimización de consultas para memoria
SELECT SQL_NO_CACHE * FROM productos WHERE categoria = 'Electrónicos';

-- Ejercicio 4: Uso de caché de consultas
SHOW VARIABLES LIKE 'query_cache%';

-- Ejercicio 5: Análisis de consultas lentas
SHOW VARIABLES LIKE 'slow_query_log';

-- Ejercicio 6: Optimización de índices para memoria
CREATE INDEX idx_productos_memoria ON productos(categoria, precio, nombre);

-- Ejercicio 7: Análisis de fragmentación
SHOW TABLE STATUS LIKE 'productos';

-- Ejercicio 8: Optimización de tablas
OPTIMIZE TABLE productos;

-- Ejercicio 9: Análisis de conexiones
SHOW STATUS LIKE 'Threads_connected';

-- Ejercicio 10: Configuración de memoria por conexión
SHOW VARIABLES LIKE 'sort_buffer_size';

-- =====================================================
-- EJERCICIOS DE LA CLASE 7: MONITOREO Y PROFILING
-- =====================================================

-- Ejercicio 1: Análisis de rendimiento
SHOW STATUS LIKE 'Uptime';

-- Ejercicio 2: Análisis de consultas
SHOW STATUS LIKE 'Questions';

-- Ejercicio 3: Análisis de conexiones
SHOW STATUS LIKE 'Connections';

-- Ejercicio 4: Análisis de bloqueos
SHOW STATUS LIKE 'Table_locks%';

-- Ejercicio 5: Análisis de índices
SHOW STATUS LIKE 'Handler%';

-- Ejercicio 6: Análisis de memoria
SHOW STATUS LIKE 'Memory%';

-- Ejercicio 7: Análisis de I/O
SHOW STATUS LIKE 'Innodb_data%';

-- Ejercicio 8: Análisis de transacciones
SHOW STATUS LIKE 'Innodb_trx%';

-- Ejercicio 9: Análisis de deadlocks
SHOW STATUS LIKE 'Innodb_deadlocks';

-- Ejercicio 10: Análisis de consultas lentas
SHOW STATUS LIKE 'Slow_queries';

-- =====================================================
-- EJERCICIOS DE LA CLASE 8: CONSULTAS DISTRIBUIDAS
-- =====================================================

-- Ejercicio 1: Consultas en múltiples bases de datos
SELECT * FROM db1.productos 
UNION ALL 
SELECT * FROM db2.productos;

-- Ejercicio 2: Consultas con JOINs distribuidos
SELECT p.nombre, c.nombre as categoria
FROM db1.productos p
JOIN db2.categorias c ON p.categoria_id = c.id;

-- Ejercicio 3: Consultas con subconsultas distribuidas
SELECT * FROM db1.productos 
WHERE categoria_id IN (
    SELECT id FROM db2.categorias WHERE activa = 1
);

-- Ejercicio 4: Consultas con CTEs distribuidas
WITH productos_distribuidos AS (
    SELECT * FROM db1.productos
    UNION ALL
    SELECT * FROM db2.productos
)
SELECT * FROM productos_distribuidos WHERE precio > 100;

-- Ejercicio 5: Consultas con funciones de ventana distribuidas
SELECT 
    producto_id,
    nombre,
    precio,
    ROW_NUMBER() OVER (ORDER BY precio DESC) as ranking
FROM (
    SELECT * FROM db1.productos
    UNION ALL
    SELECT * FROM db2.productos
) as productos_todos;

-- Ejercicio 6: Consultas con agregaciones distribuidas
SELECT 
    categoria,
    COUNT(*) as total,
    AVG(precio) as precio_promedio
FROM (
    SELECT * FROM db1.productos
    UNION ALL
    SELECT * FROM db2.productos
) as productos_todos
GROUP BY categoria;

-- Ejercicio 7: Consultas con filtros distribuidos
SELECT * FROM (
    SELECT * FROM db1.productos WHERE precio > 100
    UNION ALL
    SELECT * FROM db2.productos WHERE precio > 100
) as productos_caros;

-- Ejercicio 8: Consultas con ordenamiento distribuido
SELECT * FROM (
    SELECT * FROM db1.productos
    UNION ALL
    SELECT * FROM db2.productos
) as productos_todos
ORDER BY precio DESC;

-- Ejercicio 9: Consultas con límites distribuidos
SELECT * FROM (
    SELECT * FROM db1.productos
    UNION ALL
    SELECT * FROM db2.productos
) as productos_todos
ORDER BY precio DESC
LIMIT 10;

-- Ejercicio 10: Consultas con agrupación distribuida
SELECT 
    categoria,
    COUNT(*) as total,
    SUM(precio) as total_precio
FROM (
    SELECT * FROM db1.productos
    UNION ALL
    SELECT * FROM db2.productos
) as productos_todos
GROUP BY categoria
HAVING COUNT(*) > 5;

-- =====================================================
-- EJERCICIOS DE LA CLASE 9: AUTOMATIZACIÓN
-- =====================================================

-- Ejercicio 1: Procedimiento para limpieza automática
DELIMITER //
CREATE PROCEDURE LimpiarDatosAntiguos()
BEGIN
    DELETE FROM logs WHERE fecha < DATE_SUB(NOW(), INTERVAL 30 DAY);
    DELETE FROM sesiones WHERE fecha_expiracion < NOW();
    OPTIMIZE TABLE logs, sesiones;
END //
DELIMITER ;

-- Ejercicio 2: Evento para ejecución automática
CREATE EVENT LimpiezaAutomatica
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 02:00:00'
DO
  CALL LimpiarDatosAntiguos();

-- Ejercicio 3: Trigger para auditoría automática
DELIMITER //
CREATE TRIGGER AuditoriaProductos
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        producto_id, 
        accion, 
        fecha, 
        usuario,
        valores_anteriores,
        valores_nuevos
    ) VALUES (
        NEW.id,
        'UPDATE',
        NOW(),
        USER(),
        CONCAT('precio: ', OLD.precio, ', nombre: ', OLD.nombre),
        CONCAT('precio: ', NEW.precio, ', nombre: ', NEW.nombre)
    );
END //
DELIMITER ;

-- Ejercicio 4: Función para validación automática
DELIMITER //
CREATE FUNCTION ValidarPrecio(precio DECIMAL(10,2))
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    IF precio > 0 AND precio <= 10000 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- Ejercicio 5: Procedimiento para backup automático
DELIMITER //
CREATE PROCEDURE BackupAutomatico()
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%M%S');
    
    SET @sql = CONCAT('CREATE TABLE backup_productos_', fecha_backup, ' AS SELECT * FROM productos');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Ejercicio 6: Evento para backup automático
CREATE EVENT BackupAutomatico
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-01-01 03:00:00'
DO
  CALL BackupAutomatico();

-- Ejercicio 7: Trigger para validación automática
DELIMITER //
CREATE TRIGGER ValidarPrecioProducto
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NOT ValidarPrecio(NEW.precio) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio inválido';
    END IF;
END //
DELIMITER ;

-- Ejercicio 8: Procedimiento para estadísticas automáticas
DELIMITER //
CREATE PROCEDURE GenerarEstadisticas()
BEGIN
    INSERT INTO estadisticas_diarias (fecha, total_productos, precio_promedio)
    SELECT 
        CURDATE(),
        COUNT(*),
        AVG(precio)
    FROM productos;
END //
DELIMITER ;

-- Ejercicio 9: Evento para estadísticas automáticas
CREATE EVENT EstadisticasAutomaticas
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 01:00:00'
DO
  CALL GenerarEstadisticas();

-- Ejercicio 10: Procedimiento para mantenimiento automático
DELIMITER //
CREATE PROCEDURE MantenimientoAutomatico()
BEGIN
    ANALYZE TABLE productos, categorias, clientes;
    OPTIMIZE TABLE productos, categorias, clientes;
    FLUSH LOGS;
END //
DELIMITER ;

-- =====================================================
-- EJERCICIOS DE LA CLASE 10: PROYECTO INTEGRADOR
-- =====================================================

-- Ejercicio 1: Análisis de rendimiento del sistema
SELECT 
    'Consultas por segundo' as metrica,
    ROUND(Questions / Uptime, 2) as valor
FROM (
    SELECT 
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Questions') as Questions,
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Uptime') as Uptime
) as stats

UNION ALL

SELECT 
    'Conexiones activas' as metrica,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Threads_connected') as valor

UNION ALL

SELECT 
    'Uso de memoria InnoDB' as metrica,
    ROUND(
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_data') * 
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_page_size') / 1024 / 1024, 2
    ) as valor;

-- Ejercicio 2: Optimización de consultas críticas
EXPLAIN SELECT 
    p.nombre,
    c.nombre as categoria,
    p.precio,
    ROW_NUMBER() OVER (PARTITION BY c.nombre ORDER BY p.precio DESC) as ranking
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.activo = 1
ORDER BY c.nombre, p.precio DESC;

-- Ejercicio 3: Análisis de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    CARDINALITY
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME IN ('productos', 'categorias', 'clientes')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Ejercicio 4: Monitoreo de consultas lentas
SELECT 
    'Consultas lentas' as metrica,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Slow_queries') as valor

UNION ALL

SELECT 
    'Tiempo promedio de consulta' as metrica,
    ROUND(
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Total_time') / 
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Questions'), 4
    ) as valor;

-- Ejercicio 5: Análisis de uso de memoria
SELECT 
    'Buffer pool size' as metrica,
    ROUND(
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES WHERE VARIABLE_NAME = 'innodb_buffer_pool_size') / 1024 / 1024 / 1024, 2
    ) as valor_gb

UNION ALL

SELECT 
    'Buffer pool usage' as metrica,
    ROUND(
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_data') * 
        (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_page_size') / 1024 / 1024 / 1024, 2
    ) as valor_gb;

-- Ejercicio 6: Análisis de transacciones
SELECT 
    'Transacciones activas' as metrica,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.INNODB_TRX) as valor

UNION ALL

SELECT 
    'Deadlocks' as metrica,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_deadlocks') as valor;

-- Ejercicio 7: Análisis de I/O
SELECT 
    'Lecturas de datos' as metrica,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_data_reads') as valor

UNION ALL

SELECT 
    'Escrituras de datos' as metrica,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_data_writes') as valor;

-- Ejercicio 8: Análisis de conexiones
SELECT 
    'Conexiones máximas' as metrica,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES WHERE VARIABLE_NAME = 'max_connections') as valor

UNION ALL

SELECT 
    'Conexiones actuales' as metrica,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Threads_connected') as valor;

-- Ejercicio 9: Análisis de consultas por tipo
SELECT 
    'SELECT' as tipo_consulta,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Com_select') as total

UNION ALL

SELECT 
    'INSERT' as tipo_consulta,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Com_insert') as total

UNION ALL

SELECT 
    'UPDATE' as tipo_consulta,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Com_update') as total

UNION ALL

SELECT 
    'DELETE' as tipo_consulta,
    (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Com_delete') as total;

-- Ejercicio 10: Resumen de optimización
SELECT 
    'Estado del sistema' as categoria,
    'Optimizado' as estado,
    'Todas las métricas están dentro de los rangos esperados' as observaciones

UNION ALL

SELECT 
    'Recomendaciones' as categoria,
    'Monitoreo continuo' as estado,
    'Implementar alertas automáticas para métricas críticas' as observaciones;