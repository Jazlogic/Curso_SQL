# Clase 7: Características Específicas por SGBD

## Objetivos de la Clase
- Entender las características únicas de cada SGBD
- Conocer las ventajas y desventajas de cada sistema
- Aprender cuándo usar cada SGBD según el caso de uso
- Comprender las diferencias en sintaxis SQL
- Analizar el rendimiento y escalabilidad de cada sistema

## Introducción a las Características Específicas

Cada **Sistema de Gestión de Bases de Datos (SGBD)** tiene características únicas que lo hacen más adecuado para ciertos tipos de aplicaciones y casos de uso específicos.

### Factores a considerar:
- **Rendimiento**: Velocidad de consultas y transacciones
- **Escalabilidad**: Capacidad de crecer con la demanda
- **Características**: Funcionalidades específicas del sistema
- **Licenciamiento**: Costos y restricciones de uso
- **Ecosistema**: Herramientas y tecnologías relacionadas

## MySQL: Características Específicas

### Ventajas
- **Simplicidad**: Fácil de instalar y configurar
- **Rendimiento**: Optimizado para aplicaciones web
- **Comunidad**: Gran comunidad de desarrolladores
- **Replicación**: Fácil configuración de réplicas
- **Particionamiento**: Soporte nativo para particiones

### Desventajas
- **Estándares SQL**: Cumplimiento parcial de estándares
- **Transacciones**: Limitaciones en algunos motores
- **Escalabilidad**: Limitaciones en aplicaciones muy grandes
- **Características avanzadas**: Menos funcionalidades que otros SGBD

### Casos de uso ideales
```sql
-- Aplicaciones web
-- CMS (WordPress, Drupal)
-- E-commerce
-- Desarrollo rápido de prototipos
-- Aplicaciones con muchas lecturas

-- Ejemplo de uso típico
CREATE TABLE usuarios_web (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB;
```

### Características únicas
```sql
-- Auto increment
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- Múltiples motores de almacenamiento
CREATE TABLE tabla_myisam (
    id INT PRIMARY KEY,
    datos TEXT
) ENGINE=MyISAM;

CREATE TABLE tabla_innodb (
    id INT PRIMARY KEY,
    datos TEXT
) ENGINE=InnoDB;

-- Funciones específicas
SELECT 
    CONCAT(nombre, ' - ', precio) as producto_precio,
    IF(precio > 100, 'Caro', 'Barato') as categoria_precio
FROM productos;
```

## PostgreSQL: Características Específicas

### Ventajas
- **Estándares SQL**: Excelente cumplimiento de estándares
- **Extensibilidad**: Múltiples tipos de datos y funciones
- **ACID**: Transacciones completamente ACID
- **Concurrencia**: MVCC (Multi-Version Concurrency Control)
- **JSON**: Soporte nativo para JSON y JSONB

### Desventajas
- **Complejidad**: Más complejo de configurar
- **Memoria**: Mayor uso de memoria
- **Herramientas**: Menos herramientas de terceros
- **Curva de aprendizaje**: Más empinada que MySQL

### Casos de uso ideales
```sql
-- Aplicaciones empresariales
-- Data Science y Analytics
-- Aplicaciones con datos complejos
-- Sistemas que requieren integridad de datos
-- Aplicaciones con consultas complejas

-- Ejemplo de uso típico
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    datos_personales JSONB,
    fecha_contratacion DATE,
    salario DECIMAL(10,2),
    CONSTRAINT chk_salario CHECK (salario > 0)
);
```

### Características únicas
```sql
-- Tipos de datos avanzados
CREATE TABLE productos_avanzados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    precio MONEY,
    coordenadas POINT,
    tags TEXT[],
    metadata JSONB,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW()
);

-- Funciones de ventana avanzadas
SELECT 
    nombre,
    precio,
    ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio) as ranking,
    LAG(precio) OVER (ORDER BY precio) as precio_anterior
FROM productos;

-- Arrays y operadores
SELECT * FROM productos_avanzados 
WHERE 'electronica' = ANY(tags);

-- JSON queries
SELECT nombre, metadata->>'marca' as marca
FROM productos_avanzados
WHERE metadata @> '{"categoria": "electronica"}';
```

## SQL Server: Características Específicas

### Ventajas
- **Integración Microsoft**: Excelente integración con .NET y Windows
- **Business Intelligence**: Herramientas avanzadas de BI
- **Alta Disponibilidad**: Always On, Clustering
- **Seguridad**: Integración con Active Directory
- **Herramientas**: Excelentes herramientas de administración

### Desventajas
- **Plataforma**: Principalmente Windows
- **Costo**: Licenciamiento costoso
- **Complejidad**: Configuración compleja
- **Dependencia Microsoft**: Ligado al ecosistema Microsoft

### Casos de uso ideales
```sql
-- Aplicaciones .NET
-- Business Intelligence
-- Aplicaciones empresariales Windows
-- Sistemas que requieren alta disponibilidad
-- Integración con SharePoint y Office

-- Ejemplo de uso típico
CREATE TABLE ventas_empresa (
    id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2),
    fecha_venta DATETIME2 DEFAULT GETDATE(),
    total AS (cantidad * precio_unitario) PERSISTED
);
```

### Características únicas
```sql
-- Identity columns
CREATE TABLE productos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL
);

-- Computed columns
CREATE TABLE ventas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    cantidad INT,
    precio DECIMAL(10,2),
    total AS (cantidad * precio) PERSISTED
);

-- Common Table Expressions (CTEs)
WITH VentasPorMes AS (
    SELECT 
        YEAR(fecha_venta) as año,
        MONTH(fecha_venta) as mes,
        SUM(total) as total_ventas
    FROM ventas
    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
)
SELECT * FROM VentasPorMes ORDER BY año, mes;

-- Window functions
SELECT 
    nombre,
    precio,
    ROW_NUMBER() OVER (ORDER BY precio DESC) as ranking,
    AVG(precio) OVER (PARTITION BY categoria) as precio_promedio_categoria
FROM productos;
```

## Oracle Database: Características Específicas

### Ventajas
- **Robustez**: Extremadamente robusto y confiable
- **Escalabilidad**: Soporte para aplicaciones muy grandes
- **Características avanzadas**: Funcionalidades empresariales avanzadas
- **Alta Disponibilidad**: RAC, Data Guard, GoldenGate
- **Seguridad**: Características de seguridad avanzadas

### Desventajas
- **Costo**: Muy costoso
- **Complejidad**: Muy complejo de administrar
- **Recursos**: Requiere muchos recursos
- **Curva de aprendizaje**: Muy empinada

### Casos de uso ideales
```sql
-- Aplicaciones críticas empresariales
-- Sistemas bancarios y financieros
-- ERP y sistemas legacy
-- Aplicaciones que requieren alta disponibilidad
-- Sistemas con grandes volúmenes de datos

-- Ejemplo de uso típico
CREATE TABLE transacciones_bancarias (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    cuenta_origen VARCHAR2(20) NOT NULL,
    cuenta_destino VARCHAR2(20) NOT NULL,
    monto NUMBER(15,2) NOT NULL,
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR2(20) DEFAULT 'PENDIENTE',
    CONSTRAINT chk_monto CHECK (monto > 0)
);
```

### Características únicas
```sql
-- Sequences
CREATE SEQUENCE seq_productos START WITH 1 INCREMENT BY 1;

CREATE TABLE productos (
    id NUMBER DEFAULT seq_productos.NEXTVAL PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL
);

-- Advanced analytics
SELECT 
    nombre,
    precio,
    RANK() OVER (ORDER BY precio DESC) as ranking_precio,
    PERCENT_RANK() OVER (ORDER BY precio) as percentil_precio
FROM productos;

-- Hierarchical queries
SELECT 
    LEVEL,
    LPAD(' ', 2*(LEVEL-1)) || nombre as jerarquia
FROM empleados
START WITH manager_id IS NULL
CONNECT BY PRIOR id = manager_id;

-- Flashback queries
SELECT * FROM productos 
AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '1' HOUR)
WHERE id = 1;
```

## Ejercicios Prácticos

### Ejercicio 1: Comparación de Sintaxis
```sql
-- Crear tabla de comparación de sintaxis
CREATE TABLE comparacion_sintaxis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    operacion VARCHAR(100) NOT NULL,
    mysql_sintaxis TEXT,
    postgresql_sintaxis TEXT,
    sqlserver_sintaxis TEXT,
    oracle_sintaxis TEXT
);

-- Insertar comparaciones
INSERT INTO comparacion_sintaxis VALUES
(1, 'Auto Increment', 
 'AUTO_INCREMENT', 
 'SERIAL o GENERATED BY DEFAULT AS IDENTITY', 
 'IDENTITY(1,1)', 
 'SEQUENCE + TRIGGER o GENERATED BY DEFAULT AS IDENTITY'),
(2, 'Concatenación', 
 'CONCAT()', 
 '|| o CONCAT()', 
 '+ o CONCAT()', 
 '|| o CONCAT()'),
(3, 'Fecha Actual', 
 'NOW()', 
 'NOW() o CURRENT_TIMESTAMP', 
 'GETDATE()', 
 'SYSDATE o CURRENT_TIMESTAMP');
```

### Ejercicio 2: Análisis de Rendimiento
```sql
-- Crear tabla de rendimiento
CREATE TABLE rendimiento_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    operacion VARCHAR(100),
    tiempo_ms INT,
    memoria_mb INT,
    concurrencia_usuarios INT,
    fecha_prueba TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de rendimiento
INSERT INTO rendimiento_sgbd VALUES
(1, 'MySQL', 'SELECT Simple', 10, 50, 100, NOW()),
(2, 'MySQL', 'INSERT', 5, 30, 100, NOW()),
(3, 'MySQL', 'UPDATE', 8, 40, 100, NOW()),
(4, 'PostgreSQL', 'SELECT Simple', 12, 80, 100, NOW()),
(5, 'PostgreSQL', 'INSERT', 7, 60, 100, NOW()),
(6, 'PostgreSQL', 'UPDATE', 10, 70, 100, NOW()),
(7, 'SQL Server', 'SELECT Simple', 8, 100, 100, NOW()),
(8, 'SQL Server', 'INSERT', 6, 80, 100, NOW()),
(9, 'Oracle', 'SELECT Simple', 6, 120, 100, NOW()),
(10, 'Oracle', 'INSERT', 4, 100, 100, NOW());
```

### Ejercicio 3: Análisis de Características
```sql
-- Crear tabla de características
CREATE TABLE caracteristicas_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    caracteristica VARCHAR(100),
    disponible BOOLEAN,
    version_minima VARCHAR(20),
    descripcion TEXT
);

-- Insertar características
INSERT INTO caracteristicas_sgbd VALUES
(1, 'MySQL', 'JSON Support', TRUE, '5.7', 'Soporte básico para JSON'),
(2, 'MySQL', 'Window Functions', TRUE, '8.0', 'Funciones de ventana'),
(3, 'MySQL', 'CTE', TRUE, '8.0', 'Common Table Expressions'),
(4, 'PostgreSQL', 'JSON Support', TRUE, '9.2', 'Soporte completo para JSON/JSONB'),
(5, 'PostgreSQL', 'Window Functions', TRUE, '8.4', 'Funciones de ventana avanzadas'),
(6, 'PostgreSQL', 'CTE', TRUE, '8.4', 'CTEs recursivas'),
(7, 'SQL Server', 'JSON Support', TRUE, '2016', 'Soporte para JSON'),
(8, 'SQL Server', 'Window Functions', TRUE, '2005', 'Funciones de ventana'),
(9, 'Oracle', 'JSON Support', TRUE, '12c', 'Soporte para JSON'),
(10, 'Oracle', 'Window Functions', TRUE, '8i', 'Funciones de ventana avanzadas');
```

### Ejercicio 4: Casos de Uso por SGBD
```sql
-- Crear tabla de casos de uso
CREATE TABLE casos_uso_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    caso_uso VARCHAR(100) NOT NULL,
    sgbd_recomendado VARCHAR(50),
    razon TEXT,
    alternativas VARCHAR(200)
);

-- Insertar casos de uso
INSERT INTO casos_uso_sgbd VALUES
(1, 'Aplicación Web Simple', 'MySQL', 'Fácil de usar, buen rendimiento para web', 'PostgreSQL, SQLite'),
(2, 'Aplicación Empresarial', 'PostgreSQL', 'Estándares SQL, robustez', 'SQL Server, Oracle'),
(3, 'Ecosistema Microsoft', 'SQL Server', 'Integración nativa con .NET', 'PostgreSQL'),
(4, 'Sistema Crítico', 'Oracle', 'Máxima robustez y disponibilidad', 'SQL Server'),
(5, 'Data Science', 'PostgreSQL', 'Tipos de datos avanzados, extensibilidad', 'MySQL, SQL Server'),
(6, 'Desarrollo Rápido', 'MySQL', 'Configuración simple', 'SQLite, PostgreSQL');
```

### Ejercicio 5: Análisis de Costos
```sql
-- Crear tabla de costos
CREATE TABLE costos_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    version VARCHAR(50),
    tipo_licencia VARCHAR(50),
    costo_anual_usd DECIMAL(10,2),
    limite_usuarios INT,
    caracteristicas_incluidas TEXT
);

-- Insertar costos
INSERT INTO costos_sgbd VALUES
(1, 'MySQL', 'Community', 'GPL', 0.00, NULL, 'Uso básico, sin soporte comercial'),
(2, 'MySQL', 'Enterprise', 'Comercial', 5000.00, NULL, 'Soporte comercial, características avanzadas'),
(3, 'PostgreSQL', 'Standard', 'BSD', 0.00, NULL, 'Uso completo, sin restricciones'),
(4, 'SQL Server', 'Express', 'Gratuita', 0.00, 1, 'Limitado a 1 instancia, 10GB'),
(5, 'SQL Server', 'Standard', 'Comercial', 15000.00, NULL, 'Características empresariales'),
(6, 'Oracle', 'Express', 'Gratuita', 0.00, 1, 'Limitado a 12GB, 1 instancia'),
(7, 'Oracle', 'Enterprise', 'Comercial', 50000.00, NULL, 'Todas las características');
```

### Ejercicio 6: Análisis de Escalabilidad
```sql
-- Crear tabla de escalabilidad
CREATE TABLE escalabilidad_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    tipo_escalabilidad VARCHAR(50),
    limite_teorico VARCHAR(100),
    limite_practico VARCHAR(100),
    caracteristicas_escalabilidad TEXT
);

-- Insertar datos de escalabilidad
INSERT INTO escalabilidad_sgbd VALUES
(1, 'MySQL', 'Vertical', 'Hasta 8TB', 'Hasta 1TB', 'Particionamiento, replicación'),
(2, 'MySQL', 'Horizontal', 'Sharding manual', 'Sharding manual', 'Replicación master-slave'),
(3, 'PostgreSQL', 'Vertical', 'Hasta 32TB', 'Hasta 4TB', 'Particionamiento, replicación'),
(4, 'PostgreSQL', 'Horizontal', 'Sharding manual', 'Sharding manual', 'Replicación streaming'),
(5, 'SQL Server', 'Vertical', 'Hasta 524PB', 'Hasta 100TB', 'Always On, Clustering'),
(6, 'SQL Server', 'Horizontal', 'Federación', 'Federación', 'Distributed queries'),
(7, 'Oracle', 'Vertical', 'Hasta 8EB', 'Hasta 100TB', 'RAC, Partitioning'),
(8, 'Oracle', 'Horizontal', 'RAC, Sharding', 'RAC, Sharding', 'Real Application Clusters');
```

### Ejercicio 7: Análisis de Seguridad
```sql
-- Crear tabla de seguridad
CREATE TABLE seguridad_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    caracteristica_seguridad VARCHAR(100),
    disponible BOOLEAN,
    version_minima VARCHAR(20),
    descripcion TEXT
);

-- Insertar características de seguridad
INSERT INTO seguridad_sgbd VALUES
(1, 'MySQL', 'SSL/TLS', TRUE, '4.0', 'Conexiones encriptadas'),
(2, 'MySQL', 'Row Level Security', FALSE, NULL, 'No disponible nativamente'),
(3, 'MySQL', 'Audit Logging', TRUE, '5.5', 'Logging básico de auditoría'),
(4, 'PostgreSQL', 'SSL/TLS', TRUE, '7.0', 'Conexiones encriptadas'),
(5, 'PostgreSQL', 'Row Level Security', TRUE, '9.5', 'Seguridad a nivel de fila'),
(6, 'PostgreSQL', 'Audit Logging', TRUE, '8.0', 'Logging avanzado'),
(7, 'SQL Server', 'SSL/TLS', TRUE, '2000', 'Conexiones encriptadas'),
(8, 'SQL Server', 'Row Level Security', TRUE, '2016', 'Seguridad a nivel de fila'),
(9, 'Oracle', 'SSL/TLS', TRUE, '8i', 'Conexiones encriptadas'),
(10, 'Oracle', 'Row Level Security', TRUE, '8i', 'Virtual Private Database');
```

### Ejercicio 8: Análisis de Herramientas
```sql
-- Crear tabla de herramientas
CREATE TABLE herramientas_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    herramienta VARCHAR(100),
    tipo VARCHAR(50),
    costo VARCHAR(50),
    descripcion TEXT
);

-- Insertar herramientas
INSERT INTO herramientas_sgbd VALUES
(1, 'MySQL', 'MySQL Workbench', 'Nativa', 'Gratuita', 'Herramienta oficial de desarrollo'),
(2, 'MySQL', 'phpMyAdmin', 'Web', 'Gratuita', 'Interfaz web para administración'),
(3, 'PostgreSQL', 'pgAdmin', 'Nativa', 'Gratuita', 'Herramienta oficial de administración'),
(4, 'PostgreSQL', 'DBeaver', 'Multiplataforma', 'Gratuita/Comercial', 'Herramienta universal'),
(5, 'SQL Server', 'SSMS', 'Nativa', 'Gratuita', 'Herramienta oficial de administración'),
(6, 'SQL Server', 'Azure Data Studio', 'Multiplataforma', 'Gratuita', 'Herramienta moderna'),
(7, 'Oracle', 'SQL Developer', 'Nativa', 'Gratuita', 'Herramienta oficial de desarrollo'),
(8, 'Oracle', 'Enterprise Manager', 'Web', 'Incluida', 'Consola de administración empresarial');
```

### Ejercicio 9: Análisis de Comunidad y Soporte
```sql
-- Crear tabla de comunidad
CREATE TABLE comunidad_sgbd (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sgbd VARCHAR(50) NOT NULL,
    tipo_soporte VARCHAR(50),
    disponibilidad VARCHAR(100),
    costo VARCHAR(50),
    calidad VARCHAR(50)
);

-- Insertar datos de comunidad
INSERT INTO comunidad_sgbd VALUES
(1, 'MySQL', 'Comunidad', '24/7 Online', 'Gratuita', 'Buena'),
(2, 'MySQL', 'Comercial', '24/7 Phone/Email', 'Alto', 'Excelente'),
(3, 'PostgreSQL', 'Comunidad', '24/7 Online', 'Gratuita', 'Excelente'),
(4, 'PostgreSQL', 'Comercial', 'Business Hours', 'Medio', 'Muy Buena'),
(5, 'SQL Server', 'Comercial', '24/7 Phone/Email', 'Alto', 'Excelente'),
(6, 'SQL Server', 'Comunidad', 'Online Forums', 'Gratuita', 'Buena'),
(7, 'Oracle', 'Comercial', '24/7 Phone/Email', 'Muy Alto', 'Excelente'),
(8, 'Oracle', 'Comunidad', 'Online Forums', 'Gratuita', 'Buena');
```

### Ejercicio 10: Reporte Completo de Características
```sql
-- Crear procedimiento para reporte completo
DELIMITER //
CREATE PROCEDURE generar_reporte_caracteristicas()
BEGIN
    SELECT '=== REPORTE DE CARACTERÍSTICAS POR SGBD ===' as titulo;
    
    SELECT 'Resumen por SGBD' as seccion;
    SELECT 
        sgbd,
        COUNT(*) as total_caracteristicas,
        SUM(CASE WHEN disponible = TRUE THEN 1 ELSE 0 END) as caracteristicas_disponibles,
        ROUND(SUM(CASE WHEN disponible = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as porcentaje_disponible
    FROM caracteristicas_sgbd 
    GROUP BY sgbd;
    
    SELECT 'Análisis de Costos' as seccion;
    SELECT 
        sgbd,
        MIN(costo_anual_usd) as costo_minimo,
        MAX(costo_anual_usd) as costo_maximo,
        AVG(costo_anual_usd) as costo_promedio
    FROM costos_sgbd 
    GROUP BY sgbd;
    
    SELECT 'Recomendaciones por Caso de Uso' as seccion;
    SELECT 
        caso_uso,
        sgbd_recomendado,
        razon
    FROM casos_uso_sgbd
    ORDER BY caso_uso;
END //
DELIMITER ;

-- Ejecutar reporte
CALL generar_reporte_caracteristicas();
```

## Resumen de la Clase

En esta clase hemos aprendido:
- Las características únicas de cada SGBD
- Ventajas y desventajas de cada sistema
- Casos de uso ideales para cada SGBD
- Diferencias en sintaxis SQL entre sistemas
- Análisis de rendimiento, escalabilidad y costos
- Cómo elegir el SGBD adecuado para cada proyecto

## Próxima Clase
[Clase 8: Mejores Prácticas de Administración](clase_8_mejores_practicas.md)

## Recursos Adicionales
- [MySQL Features](https://dev.mysql.com/doc/refman/8.0/en/features.html)
- [PostgreSQL Features](https://www.postgresql.org/about/featurematrix/)
- [SQL Server Features](https://docs.microsoft.com/en-us/sql/sql-server/)
- [Oracle Database Features](https://www.oracle.com/database/technologies/)
