# Clase 4: Particionamiento

## Objetivos de la Clase
- Dominar técnicas de particionamiento de tablas
- Implementar estrategias de particionamiento por rango, hash y lista
- Optimizar consultas en tablas particionadas
- Gestionar el mantenimiento de particiones

## 1. Introducción al Particionamiento

### ¿Qué es el Particionamiento?
El particionamiento es una técnica que divide una tabla grande en múltiples partes más pequeñas y manejables, llamadas particiones. Cada partición se almacena por separado pero se accede como una sola tabla lógica.

### Beneficios del Particionamiento
- **Mejor Rendimiento**: Consultas más rápidas en datos específicos
- **Mantenimiento Simplificado**: Operaciones en particiones individuales
- **Escalabilidad**: Manejo de grandes volúmenes de datos
- **Disponibilidad**: Fallos aislados por partición
- **Paralelización**: Operaciones simultáneas en múltiples particiones

### Tipos de Particionamiento
- **Particionamiento por Rango**: Basado en rangos de valores
- **Particionamiento por Hash**: Distribución uniforme
- **Particionamiento por Lista**: Valores específicos
- **Particionamiento Compuesto**: Combinación de métodos

## 2. Particionamiento por Rango

### Particionamiento por Fecha
```sql
-- Crear tabla particionada por fecha
CREATE TABLE ventas_particionadas (
    id INT AUTO_INCREMENT,
    fecha DATE NOT NULL,
    producto_id INT,
    monto DECIMAL(10,2),
    cliente_id INT,
    PRIMARY KEY (id, fecha)
) PARTITION BY RANGE (YEAR(fecha)) (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);
```

**Explicación línea por línea:**
- `PARTITION BY RANGE (YEAR(fecha))`: Define particionamiento por rango usando el año de la fecha
- `PARTITION p2021 VALUES LESS THAN (2022)`: Crea partición para datos de 2021
- `PARTITION p_futuro VALUES LESS THAN MAXVALUE`: Partición para datos futuros

### Consultas en Tablas Particionadas
```sql
-- Consulta que aprovecha el particionamiento
SELECT 
    YEAR(fecha) AS año,
    COUNT(*) AS total_ventas,
    SUM(monto) AS monto_total
FROM ventas_particionadas
WHERE fecha >= '2023-01-01'
    AND fecha <= '2023-12-31'
GROUP BY YEAR(fecha);
```

**Ventajas:**
- **Partition Pruning**: Solo accede a particiones relevantes
- **Mejor Rendimiento**: Menos datos para procesar
- **Paralelización**: Múltiples particiones pueden procesarse simultáneamente

## 3. Particionamiento por Hash

### Distribución Uniforme
```sql
-- Crear tabla particionada por hash
CREATE TABLE productos_particionados (
    id INT AUTO_INCREMENT,
    nombre VARCHAR(100),
    categoria VARCHAR(50),
    precio DECIMAL(10,2),
    PRIMARY KEY (id)
) PARTITION BY HASH(id) PARTITIONS 4;
```

**Características:**
- **Distribución Uniforme**: Datos distribuidos equitativamente
- **Balanceo Automático**: No requiere gestión manual
- **Escalabilidad**: Fácil agregar más particiones

### Consultas en Particiones Hash
```sql
-- Consulta en tabla particionada por hash
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos_particionados
WHERE categoria = 'Electrónicos'
GROUP BY categoria;
```

## 4. Particionamiento por Lista

### Valores Específicos
```sql
-- Crear tabla particionada por lista
CREATE TABLE ventas_por_region (
    id INT AUTO_INCREMENT,
    fecha DATE,
    region VARCHAR(50),
    monto DECIMAL(10,2),
    PRIMARY KEY (id, region)
) PARTITION BY LIST COLUMNS(region) (
    PARTITION p_norte VALUES IN ('Norte', 'Noroeste'),
    PARTITION p_sur VALUES IN ('Sur', 'Sureste'),
    PARTITION p_centro VALUES IN ('Centro', 'Centro-Oeste'),
    PARTITION p_otras VALUES IN ('Internacional', 'Online')
);
```

**Ventajas:**
- **Control Granular**: Particiones específicas por valores
- **Mantenimiento Fácil**: Operaciones en regiones específicas
- **Consultas Optimizadas**: Acceso directo a particiones relevantes

## 5. Particionamiento Compuesto

### Rango y Hash Combinados
```sql
-- Crear tabla con particionamiento compuesto
CREATE TABLE ventas_compuestas (
    id INT AUTO_INCREMENT,
    fecha DATE NOT NULL,
    cliente_id INT,
    monto DECIMAL(10,2),
    PRIMARY KEY (id, fecha, cliente_id)
) PARTITION BY RANGE (YEAR(fecha))
  SUBPARTITION BY HASH(cliente_id) SUBPARTITIONS 4 (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025)
);
```

**Estructura resultante:**
- **4 particiones principales**: Por año
- **4 subparticiones cada una**: Por hash de cliente_id
- **Total**: 16 particiones (4 x 4)

## 6. Gestión de Particiones

### Agregar Nuevas Particiones
```sql
-- Agregar nueva partición para 2025
ALTER TABLE ventas_particionadas 
ADD PARTITION (
    PARTITION p2025 VALUES LESS THAN (2026)
);
```

### Eliminar Particiones
```sql
-- Eliminar partición antigua
ALTER TABLE ventas_particionadas 
DROP PARTITION p2021;
```

### Reorganizar Particiones
```sql
-- Reorganizar partición para dividirla
ALTER TABLE ventas_particionadas 
REORGANIZE PARTITION p_futuro INTO (
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);
```

## 7. Consultas Optimizadas en Particiones

### Partition Pruning
```sql
-- Consulta que aprovecha partition pruning
EXPLAIN PARTITIONS SELECT 
    COUNT(*) AS total_ventas
FROM ventas_particionadas
WHERE fecha >= '2023-01-01'
    AND fecha <= '2023-12-31';
```

**Resultado del EXPLAIN:**
- Solo muestra particiones relevantes en la columna `partitions`
- Mejora significativa en rendimiento

### Consultas con Múltiples Particiones
```sql
-- Consulta que accede a múltiples particiones
SELECT 
    YEAR(fecha) AS año,
    COUNT(*) AS total_ventas
FROM ventas_particionadas
WHERE fecha >= '2022-01-01'
    AND fecha <= '2023-12-31'
GROUP BY YEAR(fecha)
ORDER BY año;
```

## 8. Mantenimiento de Particiones

### Análisis de Particiones
```sql
-- Ver información de particiones
SELECT 
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas_particionadas'
ORDER BY PARTITION_ORDINAL_POSITION;
```

### Optimización de Particiones
```sql
-- Optimizar partición específica
ALTER TABLE ventas_particionadas 
OPTIMIZE PARTITION p2023;

-- Analizar partición
ALTER TABLE ventas_particionadas 
ANALYZE PARTITION p2023;
```

### Reparación de Particiones
```sql
-- Reparar partición si es necesario
ALTER TABLE ventas_particionadas 
REPAIR PARTITION p2023;
```

## 9. Estrategias de Particionamiento

### Particionamiento por Tiempo
```sql
-- Estrategia de particionamiento temporal
CREATE TABLE logs_sistema (
    id BIGINT AUTO_INCREMENT,
    timestamp DATETIME NOT NULL,
    nivel VARCHAR(20),
    mensaje TEXT,
    PRIMARY KEY (id, timestamp)
) PARTITION BY RANGE (TO_DAYS(timestamp)) (
    PARTITION p_enero VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p_febrero VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p_marzo VALUES LESS THAN (TO_DAYS('2024-04-01')),
    PARTITION p_abril VALUES LESS THAN (TO_DAYS('2024-05-01')),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);
```

### Particionamiento por Usuario
```sql
-- Particionamiento por rango de usuarios
CREATE TABLE actividad_usuario (
    id BIGINT AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    accion VARCHAR(100),
    timestamp DATETIME,
    PRIMARY KEY (id, usuario_id)
) PARTITION BY RANGE (usuario_id) (
    PARTITION p_usuarios_1_1000 VALUES LESS THAN (1001),
    PARTITION p_usuarios_1001_2000 VALUES LESS THAN (2001),
    PARTITION p_usuarios_2001_3000 VALUES LESS THAN (3001),
    PARTITION p_usuarios_3001_4000 VALUES LESS THAN (4001),
    PARTITION p_usuarios_resto VALUES LESS THAN MAXVALUE
);
```

## 10. Monitoreo y Tuning de Particiones

### Análisis de Rendimiento
```sql
-- Habilitar profiling
SET profiling = 1;

-- Ejecutar consulta en tabla particionada
SELECT 
    COUNT(*) AS total_ventas
FROM ventas_particionadas
WHERE fecha >= '2023-01-01'
    AND fecha <= '2023-12-31';

-- Analizar perfil
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;
```

### Análisis de Uso de Particiones
```sql
-- Ver qué particiones se usan en consultas
EXPLAIN PARTITIONS SELECT 
    COUNT(*) AS total_ventas
FROM ventas_particionadas
WHERE fecha >= '2023-01-01'
    AND fecha <= '2023-12-31';
```

## Ejercicios Prácticos

### Ejercicio 1: Crear Tabla Particionada por Rango
```sql
-- Crear tabla de ventas particionada por año
CREATE TABLE ventas_anuales (
    id INT AUTO_INCREMENT,
    fecha DATE NOT NULL,
    producto_id INT,
    cliente_id INT,
    monto DECIMAL(10,2),
    PRIMARY KEY (id, fecha)
) PARTITION BY RANGE (YEAR(fecha)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- Insertar datos de prueba
INSERT INTO ventas_anuales (fecha, producto_id, cliente_id, monto) VALUES
('2023-01-15', 1, 100, 150.00),
('2023-06-20', 2, 101, 200.00),
('2024-03-10', 3, 102, 300.00);
```

### Ejercicio 2: Consulta con Partition Pruning
```sql
-- Consulta que aprovecha el particionamiento
EXPLAIN PARTITIONS SELECT 
    COUNT(*) AS total_ventas,
    SUM(monto) AS monto_total
FROM ventas_anuales
WHERE fecha >= '2023-01-01'
    AND fecha <= '2023-12-31';

-- Verificar que solo se accede a la partición p2023
```

### Ejercicio 3: Particionamiento por Hash
```sql
-- Crear tabla particionada por hash
CREATE TABLE productos_hash (
    id INT AUTO_INCREMENT,
    nombre VARCHAR(100),
    categoria VARCHAR(50),
    precio DECIMAL(10,2),
    PRIMARY KEY (id)
) PARTITION BY HASH(id) PARTITIONS 6;

-- Insertar datos de prueba
INSERT INTO productos_hash (nombre, categoria, precio) VALUES
('Smartphone', 'Electrónicos', 500.00),
('Laptop', 'Electrónicos', 1200.00),
('Libro', 'Educación', 25.00);
```

### Ejercicio 4: Particionamiento por Lista
```sql
-- Crear tabla particionada por región
CREATE TABLE ventas_regionales (
    id INT AUTO_INCREMENT,
    fecha DATE,
    region VARCHAR(50),
    monto DECIMAL(10,2),
    PRIMARY KEY (id, region)
) PARTITION BY LIST COLUMNS(region) (
    PARTITION p_norte VALUES IN ('Norte', 'Noroeste'),
    PARTITION p_sur VALUES IN ('Sur', 'Sureste'),
    PARTITION p_centro VALUES IN ('Centro', 'Centro-Oeste'),
    PARTITION p_otras VALUES IN ('Internacional', 'Online')
);

-- Insertar datos de prueba
INSERT INTO ventas_regionales (fecha, region, monto) VALUES
('2023-01-15', 'Norte', 150.00),
('2023-02-20', 'Sur', 200.00),
('2023-03-10', 'Centro', 300.00);
```

### Ejercicio 5: Particionamiento Compuesto
```sql
-- Crear tabla con particionamiento compuesto
CREATE TABLE ventas_compuestas (
    id INT AUTO_INCREMENT,
    fecha DATE NOT NULL,
    cliente_id INT,
    monto DECIMAL(10,2),
    PRIMARY KEY (id, fecha, cliente_id)
) PARTITION BY RANGE (YEAR(fecha))
  SUBPARTITION BY HASH(cliente_id) SUBPARTITIONS 3 (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- Verificar estructura de particiones
SELECT 
    PARTITION_NAME,
    SUBPARTITION_NAME,
    TABLE_ROWS
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas_compuestas'
ORDER BY PARTITION_ORDINAL_POSITION, SUBPARTITION_ORDINAL_POSITION;
```

### Ejercicio 6: Gestión de Particiones
```sql
-- Agregar nueva partición
ALTER TABLE ventas_anuales 
ADD PARTITION (
    PARTITION p2025 VALUES LESS THAN (2026)
);

-- Verificar particiones existentes
SHOW CREATE TABLE ventas_anuales;
```

### Ejercicio 7: Consulta Optimizada
```sql
-- Consulta que aprovecha múltiples particiones
SELECT 
    YEAR(fecha) AS año,
    COUNT(*) AS total_ventas,
    AVG(monto) AS monto_promedio
FROM ventas_anuales
WHERE fecha >= '2022-01-01'
    AND fecha <= '2024-12-31'
GROUP BY YEAR(fecha)
ORDER BY año;
```

### Ejercicio 8: Análisis de Particiones
```sql
-- Analizar información de particiones
SELECT 
    PARTITION_NAME,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas_anuales'
ORDER BY PARTITION_ORDINAL_POSITION;
```

### Ejercicio 9: Mantenimiento de Particiones
```sql
-- Optimizar partición específica
ALTER TABLE ventas_anuales 
OPTIMIZE PARTITION p2023;

-- Analizar partición
ALTER TABLE ventas_anuales 
ANALYZE PARTITION p2023;

-- Verificar estadísticas actualizadas
SELECT 
    PARTITION_NAME,
    TABLE_ROWS
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = 'tu_base_datos'
    AND TABLE_NAME = 'ventas_anuales'
    AND PARTITION_NAME = 'p2023';
```

### Ejercicio 10: Consulta Compleja en Particiones
```sql
-- Consulta compleja que aprovecha el particionamiento
SELECT 
    YEAR(v.fecha) AS año,
    p.categoria,
    COUNT(*) AS total_ventas,
    SUM(v.monto) AS monto_total,
    AVG(v.monto) AS ticket_promedio
FROM ventas_anuales v
JOIN productos p ON v.producto_id = p.id
WHERE v.fecha >= '2023-01-01'
    AND v.fecha <= '2023-12-31'
    AND p.categoria = 'Electrónicos'
GROUP BY YEAR(v.fecha), p.categoria
ORDER BY monto_total DESC;
```

## Resumen de la Clase

En esta clase hemos cubierto:

1. **Conceptos Básicos**: Qué es el particionamiento y sus beneficios
2. **Particionamiento por Rango**: Para datos temporales y numéricos
3. **Particionamiento por Hash**: Distribución uniforme
4. **Particionamiento por Lista**: Valores específicos
5. **Particionamiento Compuesto**: Combinación de métodos
6. **Gestión de Particiones**: Agregar, eliminar, reorganizar
7. **Consultas Optimizadas**: Partition pruning y paralelización
8. **Mantenimiento**: Análisis, optimización y reparación
9. **Estrategias**: Particionamiento por tiempo y usuario
10. **Monitoreo**: Análisis de rendimiento y uso

## Próxima Clase
En la siguiente clase exploraremos consultas analíticas avanzadas, incluyendo funciones de ventana complejas y análisis de datos.

## Recursos Adicionales
- Documentación de particionamiento de MySQL
- Guías de diseño de particiones
- Herramientas de monitoreo de particiones
- Mejores prácticas de particionamiento
