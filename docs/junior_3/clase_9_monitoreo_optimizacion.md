# Clase 9: Monitoreo y Optimización

## 📋 Descripción

En esta clase aprenderás sobre el monitoreo y optimización de bases de datos MySQL. El monitoreo es esencial para mantener el rendimiento óptimo y detectar problemas antes de que afecten a los usuarios. Aprenderás a usar herramientas de monitoreo, analizar métricas de rendimiento y aplicar técnicas de optimización.

## 🎯 Objetivos de la Clase

- Comprender la importancia del monitoreo de bases de datos
- Aprender a usar herramientas de monitoreo de MySQL
- Analizar métricas de rendimiento
- Identificar cuellos de botella
- Aplicar técnicas de optimización
- Configurar alertas y notificaciones

## 📚 Conceptos Clave

### ¿Qué es el Monitoreo de Bases de Datos?

El **monitoreo de bases de datos** es el proceso de observar y analizar el rendimiento, uso de recursos y comportamiento de la base de datos para asegurar su funcionamiento óptimo.

### Métricas Importantes

1. **Rendimiento**: Tiempo de respuesta, throughput
2. **Recursos**: CPU, memoria, disco, red
3. **Concurrencia**: Conexiones, bloqueos, deadlocks
4. **Disponibilidad**: Uptime, errores, fallos

### Herramientas de Monitoreo

- **Performance Schema**: Métricas internas de MySQL
- **sys schema**: Vistas simplificadas de Performance Schema
- **SHOW STATUS**: Variables de estado del servidor
- **SHOW PROCESSLIST**: Procesos activos
- **EXPLAIN**: Análisis de consultas

## 🔧 Sintaxis y Comandos

### Performance Schema

```sql
-- Habilitar Performance Schema
-- En my.cnf: performance_schema=ON

-- Ver tablas disponibles
SHOW TABLES FROM performance_schema;

-- Consultar métricas de rendimiento
SELECT * FROM performance_schema.events_statements_summary_by_digest;
```

### sys Schema

```sql
-- Ver métricas de rendimiento
SELECT * FROM sys.statement_analysis;

-- Ver conexiones activas
SELECT * FROM sys.session;

-- Ver uso de memoria
SELECT * FROM sys.memory_global_total;
```

### Comandos de Monitoreo

```sql
-- Ver estado del servidor
SHOW STATUS;

-- Ver variables de configuración
SHOW VARIABLES;

-- Ver procesos activos
SHOW PROCESSLIST;

-- Ver información de conexiones
SHOW STATUS LIKE 'Connections';
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Monitoreo Básico de Rendimiento

```sql
-- Crear base de datos para monitoreo
CREATE DATABASE monitoreo_db;
USE monitoreo_db;

-- Crear tabla de ejemplo
CREATE TABLE productos_monitoreo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO productos_monitoreo (nombre, precio, stock) VALUES 
('Laptop', 999.99, 10),
('Mouse', 25.50, 50),
('Teclado', 75.00, 30),
('Monitor', 299.99, 15),
('Auriculares', 89.99, 25);

-- Ver métricas básicas de rendimiento
SHOW STATUS LIKE 'Questions';
SHOW STATUS LIKE 'Uptime';
SHOW STATUS LIKE 'Connections';
```

**Explicación línea por línea:**

1. `CREATE DATABASE monitoreo_db;` - Crea base de datos para ejemplos
2. `CREATE TABLE productos_monitoreo (...)` - Crea tabla con datos de ejemplo
3. `INSERT INTO productos_monitoreo (...)` - Inserta datos para pruebas
4. `SHOW STATUS LIKE 'Questions'` - Muestra número de consultas ejecutadas
5. `SHOW STATUS LIKE 'Uptime'` - Muestra tiempo de funcionamiento del servidor
6. `SHOW STATUS LIKE 'Connections'` - Muestra número de conexiones

### Ejemplo 2: Análisis de Consultas con Performance Schema

```sql
-- Habilitar recolección de métricas
UPDATE performance_schema.setup_instruments 
SET ENABLED = 'YES' 
WHERE NAME LIKE '%statement%';

UPDATE performance_schema.setup_consumers 
SET ENABLED = 'YES' 
WHERE NAME LIKE '%events_statements%';

-- Ejecutar consultas de ejemplo
SELECT * FROM productos_monitoreo WHERE precio > 100;
SELECT COUNT(*) FROM productos_monitoreo;
SELECT AVG(precio) FROM productos_monitoreo;

-- Analizar rendimiento de consultas
SELECT 
    DIGEST_TEXT,
    COUNT_STAR,
    AVG_TIMER_WAIT/1000000000 as avg_time_seconds,
    MAX_TIMER_WAIT/1000000000 as max_time_seconds
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT IS NOT NULL
ORDER BY AVG_TIMER_WAIT DESC;
```

### Ejemplo 3: Monitoreo de Conexiones

```sql
-- Ver conexiones activas
SELECT 
    ID,
    USER,
    HOST,
    DB,
    COMMAND,
    TIME,
    STATE,
    INFO
FROM information_schema.PROCESSLIST
WHERE COMMAND != 'Sleep';

-- Ver estadísticas de conexiones
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME IN (
    'Connections',
    'Max_used_connections',
    'Aborted_connects',
    'Aborted_clients'
);
```

### Ejemplo 4: Análisis de Uso de Memoria

```sql
-- Ver uso de memoria por componente
SELECT 
    EVENT_NAME,
    CURRENT_NUMBER_OF_BYTES_USED/1024/1024 as MB_USED
FROM performance_schema.memory_summary_global_by_event_name
WHERE CURRENT_NUMBER_OF_BYTES_USED > 0
ORDER BY CURRENT_NUMBER_OF_BYTES_USED DESC;

-- Ver configuración de memoria
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_VARIABLES
WHERE VARIABLE_NAME LIKE '%buffer%' 
   OR VARIABLE_NAME LIKE '%cache%'
   OR VARIABLE_NAME LIKE '%memory%';
```

### Ejemplo 5: Monitoreo de Bloqueos y Deadlocks

```sql
-- Ver información de bloqueos
SELECT 
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;

-- Ver estadísticas de deadlocks
SHOW STATUS LIKE 'Innodb_deadlocks';
```

### Ejemplo 6: Análisis de Índices

```sql
-- Ver uso de índices
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'monitoreo_db'
ORDER BY CARDINALITY DESC;

-- Analizar consultas que no usan índices
SELECT 
    DIGEST_TEXT,
    COUNT_STAR,
    SUM_ROWS_EXAMINED,
    SUM_ROWS_SENT
FROM performance_schema.events_statements_summary_by_digest
WHERE SUM_ROWS_EXAMINED > SUM_ROWS_SENT * 10
ORDER BY SUM_ROWS_EXAMINED DESC;
```

### Ejemplo 7: Monitoreo de Transacciones

```sql
-- Ver transacciones activas
SELECT 
    trx_id,
    trx_state,
    trx_started,
    trx_mysql_thread_id,
    trx_query
FROM information_schema.innodb_trx;

-- Ver estadísticas de transacciones
SELECT 
    VARIABLE_NAME,
    VARIABLE_VALUE
FROM information_schema.GLOBAL_STATUS
WHERE VARIABLE_NAME LIKE '%trx%' 
   OR VARIABLE_NAME LIKE '%commit%'
   OR VARIABLE_NAME LIKE '%rollback%';
```

### Ejemplo 8: Configuración de Alertas

```sql
-- Crear tabla de alertas
CREATE TABLE alertas_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta VARCHAR(50),
    mensaje TEXT,
    valor_actual DECIMAL(10,2),
    umbral DECIMAL(10,2),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'ACTIVA'
);

-- Procedimiento para verificar alertas
DELIMITER //
CREATE PROCEDURE VerificarAlertas()
BEGIN
    DECLARE conexiones_actuales INT;
    DECLARE conexiones_maximas INT;
    
    -- Obtener métricas actuales
    SELECT VARIABLE_VALUE INTO conexiones_actuales
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Threads_connected';
    
    SELECT VARIABLE_VALUE INTO conexiones_maximas
    FROM information_schema.GLOBAL_VARIABLES
    WHERE VARIABLE_NAME = 'max_connections';
    
    -- Verificar umbral de conexiones (80% del máximo)
    IF conexiones_actuales > (conexiones_maximas * 0.8) THEN
        INSERT INTO alertas_sistema (tipo_alerta, mensaje, valor_actual, umbral)
        VALUES (
            'CONEXIONES',
            'Alto número de conexiones activas',
            conexiones_actuales,
            conexiones_maximas * 0.8
        );
    END IF;
END //
DELIMITER ;

-- Ejecutar verificación de alertas
CALL VerificarAlertas();
SELECT * FROM alertas_sistema;
```

### Ejemplo 9: Optimización de Consultas

```sql
-- Analizar consulta con EXPLAIN
EXPLAIN SELECT * FROM productos_monitoreo WHERE precio > 100;

-- Crear índice para optimizar consulta
CREATE INDEX idx_precio ON productos_monitoreo(precio);

-- Analizar consulta optimizada
EXPLAIN SELECT * FROM productos_monitoreo WHERE precio > 100;

-- Ver estadísticas de uso del índice
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    NULLABLE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'monitoreo_db' 
  AND TABLE_NAME = 'productos_monitoreo';
```

### Ejemplo 10: Dashboard de Monitoreo

```sql
-- Crear vista para dashboard de monitoreo
CREATE VIEW dashboard_monitoreo AS
SELECT 
    'Conexiones' as metrica,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Threads_connected') as valor_actual,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_VARIABLES WHERE VARIABLE_NAME = 'max_connections') as valor_maximo
UNION ALL
SELECT 
    'Consultas por segundo' as metrica,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Questions') as valor_actual,
    NULL as valor_maximo
UNION ALL
SELECT 
    'Tiempo de funcionamiento' as metrica,
    (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Uptime') as valor_actual,
    NULL as valor_maximo;

-- Consultar dashboard
SELECT * FROM dashboard_monitoreo;
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Monitoreo Básico
Implementa un sistema básico de monitoreo de métricas de rendimiento.

### Ejercicio 2: Análisis de Consultas
Crea un sistema para analizar el rendimiento de consultas SQL.

### Ejercicio 3: Monitoreo de Conexiones
Implementa monitoreo de conexiones activas y estadísticas.

### Ejercicio 4: Análisis de Memoria
Crea un sistema para monitorear el uso de memoria de la base de datos.

### Ejercicio 5: Detección de Bloqueos
Implementa un sistema para detectar y analizar bloqueos.

### Ejercicio 6: Análisis de Índices
Crea un sistema para analizar el uso y eficiencia de índices.

### Ejercicio 7: Monitoreo de Transacciones
Implementa monitoreo de transacciones activas y estadísticas.

### Ejercicio 8: Sistema de Alertas
Crea un sistema de alertas automáticas para métricas críticas.

### Ejercicio 9: Optimización Automática
Implementa un sistema para identificar consultas que necesitan optimización.

### Ejercicio 10: Dashboard Completo
Crea un dashboard completo de monitoreo con múltiples métricas.

## 📝 Resumen

En esta clase has aprendido:

- **Monitoreo de bases de datos**: Observación y análisis del rendimiento
- **Herramientas**: Performance Schema, sys schema, SHOW STATUS
- **Métricas importantes**: Rendimiento, recursos, concurrencia
- **Análisis de consultas**: EXPLAIN, optimización de índices
- **Sistemas de alertas**: Detección automática de problemas
- **Optimización**: Técnicas para mejorar el rendimiento

## 🔗 Próximos Pasos

- [Clase 10: Proyecto Integrador](clase_10_proyecto_integrador.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 9!** 🎉 Continúa con la última clase del módulo para el proyecto integrador.
