# Clase 7: Monitoreo y Profiling

## Objetivos de la Clase
- Dominar técnicas de monitoreo de rendimiento
- Implementar profiling de consultas SQL
- Identificar cuellos de botella y problemas de rendimiento
- Aplicar herramientas de análisis de base de datos

## 1. Introducción al Monitoreo y Profiling

### ¿Qué es el Monitoreo y Profiling?
El monitoreo y profiling son técnicas que permiten analizar el rendimiento de las consultas SQL y operaciones de base de datos para identificar problemas y optimizar el rendimiento.

### Objetivos del Monitoreo
- **Identificar Cuellos de Botella**: Encontrar operaciones lentas
- **Optimizar Consultas**: Mejorar el rendimiento de consultas específicas
- **Prevenir Problemas**: Detectar problemas antes de que afecten a los usuarios
- **Planificar Capacidad**: Entender el crecimiento y necesidades futuras

## 2. Herramientas de Monitoreo

### SHOW PROCESSLIST
```sql
-- Ver procesos activos
SHOW PROCESSLIST;

-- Ver procesos con información detallada
SHOW FULL PROCESSLIST;

-- Filtrar procesos por usuario
SHOW PROCESSLIST WHERE User = 'usuario_especifico';
```

**Información proporcionada:**
- **Id**: ID del proceso
- **User**: Usuario que ejecuta la consulta
- **Host**: Host desde donde se conecta
- **db**: Base de datos en uso
- **Command**: Tipo de comando
- **Time**: Tiempo de ejecución en segundos
- **State**: Estado actual del proceso
- **Info**: Consulta SQL que se está ejecutando

### SHOW ENGINE INNODB STATUS
```sql
-- Ver estado detallado de InnoDB
SHOW ENGINE INNODB STATUS;

-- Información clave incluida:
-- - TRANSACTIONS: Transacciones activas
-- - FILE I/O: Estadísticas de I/O
-- - INSERT BUFFER AND ADAPTIVE HASH INDEX: Buffer de inserción
-- - LOG: Información del log de transacciones
-- - BUFFER POOL AND MEMORY: Estado del buffer pool
-- - ROW OPERATIONS: Operaciones de filas
```

## 3. Profiling de Consultas

### Habilitar Profiling
```sql
-- Habilitar profiling
SET profiling = 1;

-- Ejecutar consulta
SELECT 
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total
FROM productos p
JOIN ventas v ON p.id = v.producto_id
GROUP BY p.categoria
ORDER BY monto_total DESC;

-- Ver perfiles de consultas
SHOW PROFILES;

-- Ver perfil detallado de una consulta específica
SHOW PROFILE FOR QUERY 1;
```

### Análisis de Perfil
```sql
-- Ver perfil con información de CPU
SHOW PROFILE CPU FOR QUERY 1;

-- Ver perfil con información de I/O
SHOW PROFILE BLOCK IO FOR QUERY 1;

-- Ver perfil con información de contexto
SHOW PROFILE CONTEXT SWITCHES FOR QUERY 1;

-- Ver perfil completo
SHOW PROFILE ALL FOR QUERY 1;
```

## 4. Análisis de Rendimiento

### EXPLAIN ANALYZE
```sql
-- Análisis detallado con métricas reales
EXPLAIN ANALYZE SELECT 
    c.nombre,
    COUNT(v.id) AS total_compras,
    SUM(v.monto) AS monto_total
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
WHERE c.fecha_registro >= '2023-01-01'
GROUP BY c.id, c.nombre
HAVING COUNT(v.id) > 5
ORDER BY monto_total DESC;
```

**Información adicional:**
- **Tiempo real de ejecución**: Tiempo exacto de cada operación
- **Filas reales procesadas**: Número exacto de filas
- **Costos de operaciones**: Costo relativo de cada paso

### Análisis de Índices
```sql
-- Ver uso de índices
SHOW INDEX FROM ventas;

-- Análisis de uso de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas'
ORDER BY CARDINALITY DESC;
```

## 5. Monitoreo de Variables de Estado

### Variables de Rendimiento
```sql
-- Ver variables de estado importantes
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME IN (
    'Innodb_buffer_pool_hit_rate',
    'Qcache_hit_rate',
    'Slow_queries',
    'Questions',
    'Uptime'
);
```

### Análisis de Conexiones
```sql
-- Ver estadísticas de conexiones
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME LIKE '%connection%'
    OR VARIABLE_NAME LIKE '%thread%';
```

## 6. Slow Query Log

### Configuración del Slow Query Log
```sql
-- Configurar slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2; -- Log queries > 2 segundos
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
SET GLOBAL log_queries_not_using_indexes = 'ON';
```

### Análisis de Slow Queries
```sql
-- Ver configuración del slow query log
SHOW VARIABLES LIKE 'slow_query%';
SHOW VARIABLES LIKE 'long_query_time';

-- Ver estadísticas de slow queries
SHOW STATUS LIKE 'Slow_queries';
```

## 7. Performance Schema

### Habilitar Performance Schema
```sql
-- Ver configuración del Performance Schema
SHOW VARIABLES LIKE 'performance_schema';

-- Ver tablas disponibles
SHOW TABLES FROM performance_schema LIKE '%events%';
```

### Análisis de Eventos
```sql
-- Ver eventos de consultas
SELECT 
    EVENT_NAME,
    COUNT_STAR,
    SUM_TIMER_WAIT/1000000000000 AS total_time_seconds,
    AVG_TIMER_WAIT/1000000000 AS avg_time_milliseconds
FROM performance_schema.events_statements_summary_by_event_name
WHERE EVENT_NAME LIKE '%SELECT%'
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;
```

## 8. Monitoreo de Transacciones

### Análisis de Transacciones Activas
```sql
-- Ver transacciones activas
SELECT 
    trx_id,
    trx_state,
    trx_started,
    trx_mysql_thread_id,
    trx_query
FROM information_schema.INNODB_TRX;
```

### Análisis de Bloqueos
```sql
-- Ver bloqueos activos
SELECT 
    r.trx_id AS waiting_trx_id,
    r.trx_mysql_thread_id AS waiting_thread,
    r.trx_query AS waiting_query,
    b.trx_id AS blocking_trx_id,
    b.trx_mysql_thread_id AS blocking_thread,
    b.trx_query AS blocking_query
FROM information_schema.INNODB_LOCK_WAITS w
INNER JOIN information_schema.INNODB_TRX b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.INNODB_TRX r ON r.trx_id = w.requesting_trx_id;
```

## 9. Monitoreo de I/O

### Análisis de I/O de Archivos
```sql
-- Ver estadísticas de I/O
SELECT 
    FILE_NAME,
    EVENT_NAME,
    COUNT_READ,
    COUNT_WRITE,
    SUM_NUMBER_OF_BYTES_READ,
    SUM_NUMBER_OF_BYTES_WRITE
FROM performance_schema.file_summary_by_instance
WHERE FILE_NAME LIKE '%ibdata%'
    OR FILE_NAME LIKE '%ib_logfile%'
ORDER BY SUM_NUMBER_OF_BYTES_READ + SUM_NUMBER_OF_BYTES_WRITE DESC;
```

### Análisis de I/O de Tablas
```sql
-- Ver I/O por tabla
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COUNT_READ,
    COUNT_WRITE,
    SUM_NUMBER_OF_BYTES_READ,
    SUM_NUMBER_OF_BYTES_WRITE
FROM performance_schema.table_io_waits_summary_by_table
ORDER BY SUM_NUMBER_OF_BYTES_READ + SUM_NUMBER_OF_BYTES_WRITE DESC
LIMIT 10;
```

## 10. Herramientas de Monitoreo Externas

### MySQL Workbench
```sql
-- Consultas para análisis en MySQL Workbench
-- 1. Visual Explain
EXPLAIN FORMAT=JSON SELECT 
    c.nombre,
    COUNT(v.id) AS total_compras
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
GROUP BY c.id, c.nombre;

-- 2. Performance Dashboard
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME IN (
    'Innodb_buffer_pool_hit_rate',
    'Qcache_hit_rate',
    'Slow_queries'
);
```

### Scripts de Monitoreo
```sql
-- Script de monitoreo completo
SELECT 
    NOW() AS timestamp,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Questions') AS total_queries,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Slow_queries') AS slow_queries,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_hit_rate') AS buffer_pool_hit_rate,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Qcache_hit_rate') AS query_cache_hit_rate;
```

## Ejercicios Prácticos

### Ejercicio 1: Análisis de Procesos Activos
```sql
-- Ver procesos activos y identificar consultas lentas
SHOW FULL PROCESSLIST;

-- Filtrar procesos que llevan más de 10 segundos
SHOW PROCESSLIST WHERE Time > 10;
```

### Ejercicio 2: Profiling de Consulta
```sql
-- Habilitar profiling
SET profiling = 1;

-- Ejecutar consulta compleja
SELECT 
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total,
    AVG(v.monto) AS ticket_promedio
FROM productos p
JOIN ventas v ON p.id = v.producto_id
WHERE v.fecha >= '2023-01-01'
GROUP BY p.categoria
ORDER BY monto_total DESC;

-- Ver perfil de la consulta
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

### Ejercicio 3: Análisis de Rendimiento con EXPLAIN ANALYZE
```sql
-- Análisis detallado de consulta
EXPLAIN ANALYZE SELECT 
    c.nombre,
    COUNT(v.id) AS total_compras,
    SUM(v.monto) AS monto_total
FROM clientes c
LEFT JOIN ventas v ON c.id = v.cliente_id
WHERE c.fecha_registro >= '2023-01-01'
GROUP BY c.id, c.nombre
HAVING COUNT(v.id) > 3
ORDER BY monto_total DESC;
```

### Ejercicio 4: Monitoreo de Variables de Estado
```sql
-- Ver variables de estado importantes
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME IN (
    'Innodb_buffer_pool_hit_rate',
    'Qcache_hit_rate',
    'Slow_queries',
    'Questions',
    'Uptime',
    'Threads_connected',
    'Threads_running'
);
```

### Ejercicio 5: Análisis de Índices
```sql
-- Ver uso de índices en una tabla
SHOW INDEX FROM ventas;

-- Análisis detallado de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas'
ORDER BY CARDINALITY DESC;
```

### Ejercicio 6: Configuración de Slow Query Log
```sql
-- Configurar slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1; -- Log queries > 1 segundo
SET GLOBAL log_queries_not_using_indexes = 'ON';

-- Ver configuración
SHOW VARIABLES LIKE 'slow_query%';
SHOW VARIABLES LIKE 'long_query_time';
```

### Ejercicio 7: Análisis de Transacciones
```sql
-- Ver transacciones activas
SELECT 
    trx_id,
    trx_state,
    trx_started,
    trx_mysql_thread_id,
    trx_query
FROM information_schema.INNODB_TRX;

-- Ver bloqueos
SELECT 
    r.trx_id AS waiting_trx_id,
    r.trx_mysql_thread_id AS waiting_thread,
    b.trx_id AS blocking_trx_id,
    b.trx_mysql_thread_id AS blocking_thread
FROM information_schema.INNODB_LOCK_WAITS w
INNER JOIN information_schema.INNODB_TRX b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.INNODB_TRX r ON r.trx_id = w.requesting_trx_id;
```

### Ejercicio 8: Análisis de I/O
```sql
-- Ver estadísticas de I/O de archivos
SELECT 
    FILE_NAME,
    EVENT_NAME,
    COUNT_READ,
    COUNT_WRITE,
    SUM_NUMBER_OF_BYTES_READ,
    SUM_NUMBER_OF_BYTES_WRITE
FROM performance_schema.file_summary_by_instance
WHERE FILE_NAME LIKE '%ibdata%'
    OR FILE_NAME LIKE '%ib_logfile%'
ORDER BY SUM_NUMBER_OF_BYTES_READ + SUM_NUMBER_OF_BYTES_WRITE DESC;
```

### Ejercicio 9: Monitoreo de Conexiones
```sql
-- Ver estadísticas de conexiones
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME LIKE '%connection%'
    OR VARIABLE_NAME LIKE '%thread%'
    OR VARIABLE_NAME LIKE '%abort%';
```

### Ejercicio 10: Script de Monitoreo Completo
```sql
-- Script de monitoreo completo
SELECT 
    NOW() AS timestamp,
    'Estado del Sistema' AS seccion,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Uptime') AS uptime_seconds,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Threads_connected') AS conexiones_activas,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Threads_running') AS threads_ejecutandose,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Questions') AS total_queries,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Slow_queries') AS slow_queries;
```

## Resumen de la Clase

En esta clase hemos cubierto:

1. **Herramientas de Monitoreo**: SHOW PROCESSLIST, SHOW ENGINE INNODB STATUS
2. **Profiling de Consultas**: Habilitar profiling y analizar resultados
3. **Análisis de Rendimiento**: EXPLAIN ANALYZE y análisis de índices
4. **Variables de Estado**: Monitoreo de variables de rendimiento
5. **Slow Query Log**: Configuración y análisis de consultas lentas
6. **Performance Schema**: Análisis de eventos y estadísticas
7. **Monitoreo de Transacciones**: Análisis de transacciones y bloqueos
8. **Monitoreo de I/O**: Análisis de I/O de archivos y tablas
9. **Herramientas Externas**: MySQL Workbench y scripts de monitoreo
10. **Scripts de Monitoreo**: Automatización del monitoreo

## Próxima Clase
En la siguiente clase exploraremos técnicas de consultas distribuidas para manejar datos en múltiples servidores.

## Recursos Adicionales
- Documentación de Performance Schema
- Guías de monitoreo de MySQL
- Herramientas de profiling
- Mejores prácticas de monitoreo
