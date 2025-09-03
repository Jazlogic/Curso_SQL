# Clase 7: Índices y Rendimiento

## Objetivos de la Clase
- Comprender qué son los índices y su importancia
- Crear diferentes tipos de índices
- Optimizar consultas con índices
- Monitorear y analizar rendimiento

## Contenido Teórico

### 1. ¿Qué son los Índices?

**Índices** son estructuras de datos que mejoran la velocidad de las operaciones de consulta en una base de datos, actuando como un "índice" que permite encontrar rápidamente los datos sin tener que examinar cada fila.

#### Analogía del Índice:
- **Libro sin índice**: Buscar una palabra específica requiere leer todo el libro
- **Libro con índice**: Buscar en el índice te lleva directamente a la página correcta

#### Beneficios de los Índices:
- **Velocidad de consultas**: Acceso rápido a datos específicos
- **Eficiencia de JOINs**: Mejora el rendimiento de uniones
- **Ordenamiento**: Acelera operaciones ORDER BY
- **Agrupación**: Optimiza operaciones GROUP BY

### 2. Tipos de Índices

#### Índice Primario (Primary Key)
```sql
-- Se crea automáticamente con la clave primaria
CREATE TABLE empleados (
    id INT PRIMARY KEY,  -- Índice primario automático
    nombre VARCHAR(100),
    email VARCHAR(100)
);

-- Verificar índices existentes
SHOW INDEX FROM empleados;
```

#### Índice Único (Unique Index)
```sql
-- Garantiza unicidad y mejora rendimiento
CREATE TABLE usuarios (
    id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,  -- Índice único automático
    email VARCHAR(100) UNIQUE     -- Índice único automático
);

-- Crear índice único manualmente
CREATE UNIQUE INDEX idx_usuarios_username ON usuarios(username);
```

#### Índice Simple (Single Column Index)
```sql
-- Índice en una sola columna
CREATE TABLE productos (
    id INT PRIMARY KEY,
    nombre VARCHAR(200),
    precio DECIMAL(10,2),
    categoria VARCHAR(100)
);

-- Crear índice simple
CREATE INDEX idx_productos_precio ON productos(precio);
CREATE INDEX idx_productos_categoria ON productos(categoria);
```

#### Índice Compuesto (Composite Index)
```sql
-- Índice en múltiples columnas
CREATE TABLE ventas (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_venta DATE,
    total DECIMAL(10,2),
    estado VARCHAR(20)
);

-- Crear índice compuesto
CREATE INDEX idx_ventas_cliente_fecha ON ventas(cliente_id, fecha_venta);
CREATE INDEX idx_ventas_fecha_estado ON ventas(fecha_venta, estado);
```

#### Índice de Texto Completo (Full-Text Index)
```sql
-- Para búsquedas de texto completo
CREATE TABLE articulos (
    id INT PRIMARY KEY,
    titulo VARCHAR(200),
    contenido TEXT,
    autor VARCHAR(100)
);

-- Crear índice de texto completo
CREATE FULLTEXT INDEX idx_articulos_contenido ON articulos(titulo, contenido);
```

### 3. Cuándo Crear Índices

#### Columnas Candidatas para Índices:
- **Claves foráneas**: Para optimizar JOINs
- **Columnas de filtrado**: WHERE frecuente
- **Columnas de ordenamiento**: ORDER BY
- **Columnas de agrupación**: GROUP BY
- **Columnas de búsqueda**: LIKE, =, <, >

#### Ejemplo de Análisis:
```sql
-- Consulta que se beneficiaría de índices
SELECT p.nombre, p.precio, c.nombre as categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > 100
AND p.activo = TRUE
ORDER BY p.precio DESC;

-- Índices recomendados:
CREATE INDEX idx_productos_precio_activo ON productos(precio, activo);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
```

### 4. Análisis de Rendimiento

#### EXPLAIN - Análisis de Consultas
```sql
-- Analizar cómo MySQL ejecuta una consulta
EXPLAIN SELECT * FROM productos WHERE precio > 100;

-- EXPLAIN con formato detallado
EXPLAIN FORMAT=JSON SELECT * FROM productos WHERE precio > 100;

-- EXPLAIN ANALYZE (MySQL 8.0+)
EXPLAIN ANALYZE SELECT * FROM productos WHERE precio > 100;
```

#### Interpretación de EXPLAIN:
- **type**: Tipo de acceso (ALL, index, range, ref, const)
- **key**: Índice utilizado
- **rows**: Número de filas examinadas
- **Extra**: Información adicional sobre la ejecución

### 5. Optimización de Consultas

#### Estrategias de Optimización:
1. **Usar índices apropiados**
2. **Escribir consultas eficientes**
3. **Evitar SELECT ***
4. **Usar LIMIT cuando sea apropiado**
5. **Optimizar JOINs**

#### Ejemplo de Optimización:
```sql
-- Consulta no optimizada
SELECT * FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > 100
ORDER BY p.nombre;

-- Consulta optimizada
SELECT p.id, p.nombre, p.precio, c.nombre as categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > 100
ORDER BY p.nombre
LIMIT 100;

-- Índices para optimización
CREATE INDEX idx_productos_precio ON productos(precio);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_nombre ON productos(nombre);
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Ventas

#### Crear Índices para Optimización:
```sql
-- Crear base de datos
CREATE DATABASE ventas_optimizado;
USE ventas_optimizado;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente'
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id)
);

-- Crear índices para optimización
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_clientes_activo ON clientes(activo);
CREATE INDEX idx_clientes_fecha_registro ON clientes(fecha_registro);

CREATE INDEX idx_productos_precio ON productos(precio);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_precio_activo ON productos(precio, activo);

CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_ventas_cliente_fecha ON ventas(cliente_id, fecha_venta);

CREATE INDEX idx_detalle_ventas_producto ON detalle_ventas(producto_id);
```

### Ejemplo 2: Sistema de Biblioteca

#### Índices para Consultas Frecuentes:
```sql
-- Crear base de datos
CREATE DATABASE biblioteca_optimizada;
USE biblioteca_optimizada;

-- Tabla de libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    autor VARCHAR(200),
    año_publicacion YEAR,
    categoria VARCHAR(100),
    disponible BOOLEAN DEFAULT TRUE
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado ENUM('activo', 'devuelto', 'vencido') DEFAULT 'activo'
);

-- Crear índices para consultas frecuentes
CREATE INDEX idx_libros_titulo ON libros(titulo);
CREATE INDEX idx_libros_autor ON libros(autor);
CREATE INDEX idx_libros_categoria ON libros(categoria);
CREATE INDEX idx_libros_disponible ON libros(disponible);
CREATE INDEX idx_libros_año ON libros(año_publicacion);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_nombre ON usuarios(nombre);

CREATE INDEX idx_prestamos_usuario ON prestamos(usuario_id);
CREATE INDEX idx_prestamos_libro ON prestamos(libro_id);
CREATE INDEX idx_prestamos_fecha_prestamo ON prestamos(fecha_prestamo);
CREATE INDEX idx_prestamos_estado ON prestamos(estado);
CREATE INDEX idx_prestamos_fecha_devolucion ON prestamos(fecha_devolucion_esperada);

-- Índice compuesto para consultas complejas
CREATE INDEX idx_prestamos_usuario_estado ON prestamos(usuario_id, estado);
CREATE INDEX idx_prestamos_fecha_estado ON prestamos(fecha_prestamo, estado);
```

## Ejercicios Prácticos

### Ejercicio 1: Crear Índices Básicos
**Objetivo**: Crear índices para optimizar consultas básicas.

```sql
-- Crear tabla de empleados
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    departamento VARCHAR(50),
    salario DECIMAL(10,2),
    fecha_contratacion DATE,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar datos de ejemplo
INSERT INTO empleados (nombre, apellido, email, departamento, salario, fecha_contratacion) VALUES
('Juan', 'Pérez', 'juan.perez@empresa.com', 'Ventas', 45000.00, '2023-01-15'),
('María', 'García', 'maria.garcia@empresa.com', 'Marketing', 50000.00, '2023-02-20'),
('Carlos', 'López', 'carlos.lopez@empresa.com', 'IT', 60000.00, '2023-03-10'),
('Ana', 'Martínez', 'ana.martinez@empresa.com', 'Ventas', 48000.00, '2023-04-05'),
('Pedro', 'Sánchez', 'pedro.sanchez@empresa.com', 'IT', 55000.00, '2023-05-12');

-- Crear índices para optimizar consultas frecuentes
CREATE INDEX idx_empleados_departamento ON empleados(departamento);
CREATE INDEX idx_empleados_salario ON empleados(salario);
CREATE INDEX idx_empleados_fecha_contratacion ON empleados(fecha_contratacion);
CREATE INDEX idx_empleados_activo ON empleados(activo);

-- Índice compuesto para consultas complejas
CREATE INDEX idx_empleados_departamento_activo ON empleados(departamento, activo);
CREATE INDEX idx_empleados_salario_activo ON empleados(salario, activo);
```

### Ejercicio 2: Analizar Rendimiento con EXPLAIN
**Objetivo**: Usar EXPLAIN para analizar consultas.

```sql
-- Consulta 1: Buscar empleados por departamento
EXPLAIN SELECT * FROM empleados WHERE departamento = 'IT';

-- Consulta 2: Buscar empleados con salario alto
EXPLAIN SELECT * FROM empleados WHERE salario > 50000;

-- Consulta 3: Buscar empleados activos en un departamento
EXPLAIN SELECT * FROM empleados WHERE departamento = 'Ventas' AND activo = TRUE;

-- Consulta 4: Ordenar por salario
EXPLAIN SELECT * FROM empleados ORDER BY salario DESC;

-- Consulta 5: Agrupar por departamento
EXPLAIN SELECT departamento, COUNT(*) FROM empleados GROUP BY departamento;

-- Analizar con formato JSON para más detalles
EXPLAIN FORMAT=JSON SELECT * FROM empleados WHERE departamento = 'IT' AND activo = TRUE;
```

### Ejercicio 3: Optimizar Consultas con Índices
**Objetivo**: Crear índices para optimizar consultas específicas.

```sql
-- Crear tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(100),
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES
('Laptop', 'Computadora portátil', 15000.00, 'Electrónicos', 10),
('Mouse', 'Mouse inalámbrico', 500.00, 'Electrónicos', 50),
('Sofá', 'Sofá de 3 plazas', 8000.00, 'Hogar', 5),
('Pelota', 'Pelota de fútbol', 200.00, 'Deportes', 20),
('Libro', 'Libro de programación', 300.00, 'Libros', 15);

-- Consultas que necesitan optimización
-- 1. Buscar productos por categoría
-- 2. Buscar productos por rango de precio
-- 3. Buscar productos activos en una categoría
-- 4. Ordenar productos por precio
-- 5. Buscar productos con stock bajo

-- Crear índices para optimizar estas consultas
CREATE INDEX idx_productos_categoria ON productos(categoria);
CREATE INDEX idx_productos_precio ON productos(precio);
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_stock ON productos(stock);

-- Índices compuestos para consultas complejas
CREATE INDEX idx_productos_categoria_activo ON productos(categoria, activo);
CREATE INDEX idx_productos_precio_activo ON productos(precio, activo);
CREATE INDEX idx_productos_stock_activo ON productos(stock, activo);

-- Analizar rendimiento antes y después
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos' AND activo = TRUE;
EXPLAIN SELECT * FROM productos WHERE precio BETWEEN 100 AND 1000 AND activo = TRUE;
EXPLAIN SELECT * FROM productos WHERE stock < 10 AND activo = TRUE;
```

### Ejercicio 4: Crear Índices Compuestos
**Objetivo**: Crear índices compuestos para consultas complejas.

```sql
-- Crear tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    vendedor_id INT,
    region VARCHAR(50)
);

-- Insertar datos de ejemplo
INSERT INTO ventas (cliente_id, fecha_venta, total, estado, vendedor_id, region) VALUES
(1, '2024-01-15', 1500.00, 'completada', 1, 'Norte'),
(2, '2024-01-16', 2000.00, 'completada', 2, 'Sur'),
(3, '2024-01-17', 800.00, 'pendiente', 1, 'Norte'),
(4, '2024-01-18', 3000.00, 'completada', 3, 'Este'),
(5, '2024-01-19', 1200.00, 'cancelada', 2, 'Sur');

-- Consultas que se beneficiarán de índices compuestos
-- 1. Ventas por cliente y fecha
-- 2. Ventas por vendedor y estado
-- 3. Ventas por región y fecha
-- 4. Ventas por estado y rango de fecha

-- Crear índices compuestos
CREATE INDEX idx_ventas_cliente_fecha ON ventas(cliente_id, fecha_venta);
CREATE INDEX idx_ventas_vendedor_estado ON ventas(vendedor_id, estado);
CREATE INDEX idx_ventas_region_fecha ON ventas(region, fecha_venta);
CREATE INDEX idx_ventas_estado_fecha ON ventas(estado, fecha_venta);
CREATE INDEX idx_ventas_fecha_total ON ventas(fecha_venta, total);

-- Analizar rendimiento
EXPLAIN SELECT * FROM ventas WHERE cliente_id = 1 AND fecha_venta >= '2024-01-01';
EXPLAIN SELECT * FROM ventas WHERE vendedor_id = 1 AND estado = 'completada';
EXPLAIN SELECT * FROM ventas WHERE region = 'Norte' AND fecha_venta BETWEEN '2024-01-01' AND '2024-01-31';
```

### Ejercicio 5: Crear Índices de Texto Completo
**Objetivo**: Crear índices de texto completo para búsquedas.

```sql
-- Crear tabla de artículos
CREATE TABLE articulos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT,
    autor VARCHAR(100),
    fecha_publicacion DATE,
    categoria VARCHAR(100)
);

-- Insertar datos de ejemplo
INSERT INTO articulos (titulo, contenido, autor, fecha_publicacion, categoria) VALUES
('Introducción a SQL', 'SQL es un lenguaje de consulta estructurado...', 'Juan Pérez', '2024-01-15', 'Tecnología'),
('Optimización de Bases de Datos', 'Las bases de datos requieren optimización...', 'María García', '2024-01-16', 'Tecnología'),
('Diseño de Interfaces', 'El diseño de interfaces es fundamental...', 'Carlos López', '2024-01-17', 'Diseño'),
('Marketing Digital', 'El marketing digital ha revolucionado...', 'Ana Martínez', '2024-01-18', 'Marketing');

-- Crear índice de texto completo
CREATE FULLTEXT INDEX idx_articulos_contenido ON articulos(titulo, contenido);

-- Consultas de texto completo
-- 1. Búsqueda simple
SELECT * FROM articulos WHERE MATCH(titulo, contenido) AGAINST('SQL' IN NATURAL LANGUAGE MODE);

-- 2. Búsqueda con operadores booleanos
SELECT * FROM articulos WHERE MATCH(titulo, contenido) AGAINST('+SQL +optimización' IN BOOLEAN MODE);

-- 3. Búsqueda con relevancia
SELECT *, MATCH(titulo, contenido) AGAINST('bases de datos' IN NATURAL LANGUAGE MODE) AS relevancia
FROM articulos
WHERE MATCH(titulo, contenido) AGAINST('bases de datos' IN NATURAL LANGUAGE MODE)
ORDER BY relevancia DESC;

-- Analizar rendimiento
EXPLAIN SELECT * FROM articulos WHERE MATCH(titulo, contenido) AGAINST('SQL' IN NATURAL LANGUAGE MODE);
```

### Ejercicio 6: Monitorear Rendimiento de Índices
**Objetivo**: Crear sistema de monitoreo de rendimiento.

```sql
-- Crear tabla de monitoreo
CREATE TABLE monitoreo_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    consulta TEXT,
    tiempo_ejecucion DECIMAL(10,6),
    filas_examinadas INT,
    filas_devueltas INT,
    fecha_ejecucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    indices_utilizados TEXT
);

-- Procedimiento para monitorear consultas
DELIMITER //
CREATE PROCEDURE monitorear_consulta(
    IN consulta_sql TEXT
)
BEGIN
    DECLARE tiempo_inicio DECIMAL(20,6);
    DECLARE tiempo_fin DECIMAL(20,6);
    DECLARE tiempo_ejecucion DECIMAL(10,6);
    DECLARE filas_examinadas INT;
    DECLARE filas_devueltas INT;
    DECLARE indices_utilizados TEXT;
    
    -- Obtener tiempo de inicio
    SET tiempo_inicio = UNIX_TIMESTAMP(NOW(6));
    
    -- Ejecutar consulta (simplificado)
    SET @sql = consulta_sql;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Obtener tiempo de fin
    SET tiempo_fin = UNIX_TIMESTAMP(NOW(6));
    SET tiempo_ejecucion = tiempo_fin - tiempo_inicio;
    
    -- Obtener información de EXPLAIN
    SET @explain_sql = CONCAT('EXPLAIN ', consulta_sql);
    PREPARE stmt FROM @explain_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Registrar en monitoreo
    INSERT INTO monitoreo_rendimiento (consulta, tiempo_ejecucion, filas_examinadas, filas_devueltas)
    VALUES (consulta_sql, tiempo_ejecucion, 0, 0);
    
    SELECT 'Consulta monitoreada' AS resultado;
END//
DELIMITER ;

-- Ejemplo de uso
CALL monitorear_consulta('SELECT * FROM productos WHERE categoria = "Electrónicos"');
```

### Ejercicio 7: Optimizar Consultas Complejas
**Objetivo**: Optimizar consultas con múltiples JOINs.

```sql
-- Crear tablas relacionadas
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    region VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    categoria VARCHAR(100),
    precio DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    producto_id INT,
    fecha_venta DATE,
    cantidad INT,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente'
);

-- Insertar datos de ejemplo
INSERT INTO clientes (nombre, email, region) VALUES
('Juan Pérez', 'juan@email.com', 'Norte'),
('María García', 'maria@email.com', 'Sur'),
('Carlos López', 'carlos@email.com', 'Este');

INSERT INTO productos (nombre, categoria, precio) VALUES
('Laptop', 'Electrónicos', 15000.00),
('Mouse', 'Electrónicos', 500.00),
('Sofá', 'Hogar', 8000.00);

INSERT INTO ventas (cliente_id, producto_id, fecha_venta, cantidad, total, estado) VALUES
(1, 1, '2024-01-15', 1, 15000.00, 'completada'),
(2, 2, '2024-01-16', 2, 1000.00, 'completada'),
(3, 3, '2024-01-17', 1, 8000.00, 'pendiente');

-- Consulta compleja que necesita optimización
SELECT 
    c.nombre as cliente,
    c.region,
    p.nombre as producto,
    p.categoria,
    v.fecha_venta,
    v.cantidad,
    v.total,
    v.estado
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN productos p ON v.producto_id = p.id
WHERE c.region = 'Norte'
AND p.categoria = 'Electrónicos'
AND v.estado = 'completada'
AND v.fecha_venta >= '2024-01-01'
ORDER BY v.fecha_venta DESC;

-- Crear índices para optimizar esta consulta
CREATE INDEX idx_clientes_region ON clientes(region);
CREATE INDEX idx_productos_categoria ON productos(categoria);
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_producto ON ventas(producto_id);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);

-- Índices compuestos para optimizar JOINs
CREATE INDEX idx_ventas_cliente_estado ON ventas(cliente_id, estado);
CREATE INDEX idx_ventas_producto_estado ON ventas(producto_id, estado);
CREATE INDEX idx_ventas_fecha_estado ON ventas(fecha_venta, estado);

-- Analizar rendimiento
EXPLAIN SELECT 
    c.nombre as cliente,
    c.region,
    p.nombre as producto,
    p.categoria,
    v.fecha_venta,
    v.cantidad,
    v.total,
    v.estado
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN productos p ON v.producto_id = p.id
WHERE c.region = 'Norte'
AND p.categoria = 'Electrónicos'
AND v.estado = 'completada'
AND v.fecha_venta >= '2024-01-01'
ORDER BY v.fecha_venta DESC;
```

### Ejercicio 8: Gestionar Índices
**Objetivo**: Crear sistema de gestión de índices.

```sql
-- Procedimiento para analizar índices existentes
DELIMITER //
CREATE PROCEDURE analizar_indices()
BEGIN
    -- Mostrar todos los índices de la base de datos actual
    SELECT 
        TABLE_NAME as tabla,
        INDEX_NAME as indice,
        COLUMN_NAME as columna,
        NON_UNIQUE as no_unico,
        INDEX_TYPE as tipo
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
    ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
    
    -- Mostrar estadísticas de uso de índices
    SELECT 
        TABLE_NAME as tabla,
        INDEX_NAME as indice,
        CARDINALITY as cardinalidad
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
    AND INDEX_NAME != 'PRIMARY'
    ORDER BY CARDINALITY DESC;
END//
DELIMITER ;

-- Procedimiento para recomendar índices
DELIMITER //
CREATE PROCEDURE recomendar_indices()
BEGIN
    -- Analizar consultas lentas (simplificado)
    SELECT 
        'Recomendaciones de índices:' AS mensaje,
        '1. Crear índices en columnas de WHERE frecuentes' AS recomendacion_1,
        '2. Crear índices en columnas de JOIN' AS recomendacion_2,
        '3. Crear índices en columnas de ORDER BY' AS recomendacion_3,
        '4. Crear índices compuestos para consultas complejas' AS recomendacion_4,
        '5. Monitorear el uso de índices regularmente' AS recomendacion_5;
END//
DELIMITER ;

-- Ejecutar análisis
CALL analizar_indices();
CALL recomendar_indices();
```

### Ejercicio 9: Caso de Estudio Completo
**Objetivo**: Optimizar sistema completo de e-commerce.

```sql
-- Crear sistema de e-commerce optimizado
CREATE DATABASE ecommerce_optimizado;
USE ecommerce_optimizado;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(50),
    estado VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(50),
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    fecha_envio DATE,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    metodo_pago VARCHAR(50),
    direccion_envio TEXT
);

-- Tabla de detalle de pedidos
CREATE TABLE detalle_pedidos (
    pedido_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (pedido_id, producto_id)
);

-- Crear índices para optimización
-- Índices para clientes
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_clientes_ciudad ON clientes(ciudad);
CREATE INDEX idx_clientes_estado ON clientes(estado);
CREATE INDEX idx_clientes_activo ON clientes(activo);
CREATE INDEX idx_clientes_fecha_registro ON clientes(fecha_registro);

-- Índices para productos
CREATE INDEX idx_productos_precio ON productos(precio);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_stock ON productos(stock);
CREATE INDEX idx_productos_fecha_creacion ON productos(fecha_creacion);

-- Índices compuestos para productos
CREATE INDEX idx_productos_categoria_activo ON productos(categoria_id, activo);
CREATE INDEX idx_productos_precio_activo ON productos(precio, activo);
CREATE INDEX idx_productos_stock_activo ON productos(stock, activo);

-- Índices para pedidos
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_pedidos_estado ON pedidos(estado);
CREATE INDEX idx_pedidos_fecha_envio ON pedidos(fecha_envio);

-- Índices compuestos para pedidos
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos(cliente_id, fecha_pedido);
CREATE INDEX idx_pedidos_estado_fecha ON pedidos(estado, fecha_pedido);
CREATE INDEX idx_pedidos_cliente_estado ON pedidos(cliente_id, estado);

-- Índices para detalle de pedidos
CREATE INDEX idx_detalle_pedidos_producto ON detalle_pedidos(producto_id);

-- Insertar datos de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Hogar', 'Artículos para el hogar'),
('Deportes', 'Equipos y accesorios deportivos'),
('Libros', 'Libros y material educativo');

INSERT INTO productos (nombre, descripcion, precio, categoria_id, stock) VALUES
('Laptop', 'Computadora portátil', 15000.00, 1, 10),
('Mouse', 'Mouse inalámbrico', 500.00, 1, 50),
('Sofá', 'Sofá de 3 plazas', 8000.00, 2, 5),
('Pelota', 'Pelota de fútbol', 200.00, 3, 20),
('Libro SQL', 'Libro de programación SQL', 300.00, 4, 15);

INSERT INTO clientes (nombre, apellido, email, ciudad, estado) VALUES
('Juan', 'Pérez', 'juan.perez@email.com', 'Ciudad de México', 'CDMX'),
('María', 'García', 'maria.garcia@email.com', 'Guadalajara', 'Jalisco'),
('Carlos', 'López', 'carlos.lopez@email.com', 'Monterrey', 'Nuevo León');

INSERT INTO pedidos (cliente_id, fecha_pedido, total, estado) VALUES
(1, '2024-01-15', 15500.00, 'entregado'),
(2, '2024-01-16', 1000.00, 'enviado'),
(3, '2024-01-17', 8000.00, 'procesando');

INSERT INTO detalle_pedidos VALUES
(1, 1, 1, 15000.00, 15000.00),  -- Laptop
(1, 2, 1, 500.00, 500.00),      -- Mouse
(2, 2, 2, 500.00, 1000.00),     -- Mouse x2
(3, 3, 1, 8000.00, 8000.00);    -- Sofá
```

### Ejercicio 10: Consultas Optimizadas
**Objetivo**: Crear consultas optimizadas para el sistema de e-commerce.

```sql
-- Consulta 1: Productos más vendidos
SELECT 
    p.nombre,
    p.precio,
    c.nombre as categoria,
    SUM(dp.cantidad) as total_vendido,
    SUM(dp.subtotal) as ingresos_totales
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
JOIN detalle_pedidos dp ON p.id = dp.producto_id
JOIN pedidos ped ON dp.pedido_id = ped.id
WHERE ped.estado = 'entregado'
GROUP BY p.id, p.nombre, p.precio, c.nombre
ORDER BY total_vendido DESC;

-- Consulta 2: Clientes por región
SELECT 
    c.estado,
    c.ciudad,
    COUNT(DISTINCT c.id) as total_clientes,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as ingresos_totales
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE c.activo = TRUE
GROUP BY c.estado, c.ciudad
ORDER BY ingresos_totales DESC;

-- Consulta 3: Productos con stock bajo
SELECT 
    p.nombre,
    p.stock,
    p.precio,
    c.nombre as categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock < 10
AND p.activo = TRUE
ORDER BY p.stock ASC;

-- Consulta 4: Ventas por mes
SELECT 
    YEAR(p.fecha_pedido) as año,
    MONTH(p.fecha_pedido) as mes,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as ingresos_totales,
    AVG(p.total) as promedio_pedido
FROM pedidos p
WHERE p.estado = 'entregado'
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido)
ORDER BY año DESC, mes DESC;

-- Consulta 5: Clientes con más compras
SELECT 
    c.nombre,
    c.apellido,
    c.email,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as total_gastado,
    AVG(p.total) as promedio_pedido
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.estado = 'entregado'
GROUP BY c.id, c.nombre, c.apellido, c.email
ORDER BY total_gastado DESC
LIMIT 10;

-- Analizar rendimiento de consultas
EXPLAIN SELECT 
    p.nombre,
    p.precio,
    c.nombre as categoria,
    SUM(dp.cantidad) as total_vendido
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
JOIN detalle_pedidos dp ON p.id = dp.producto_id
JOIN pedidos ped ON dp.pedido_id = ped.id
WHERE ped.estado = 'entregado'
GROUP BY p.id, p.nombre, p.precio, c.nombre
ORDER BY total_vendido DESC;
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Índices**: Estructuras que mejoran la velocidad de consultas
2. **Tipos de Índices**: Primario, único, simple, compuesto, texto completo
3. **EXPLAIN**: Herramienta para analizar rendimiento
4. **Optimización**: Estrategias para mejorar consultas
5. **Monitoreo**: Seguimiento del rendimiento de índices

### Próximos Pasos:
- Aprender diseño de esquemas escalables
- Estudiar optimización avanzada de consultas
- Practicar con casos complejos de rendimiento

### Recursos Adicionales:
- Documentación sobre índices en MySQL
- Herramientas de análisis de rendimiento
- Casos de estudio de optimización
