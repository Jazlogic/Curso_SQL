-- =====================================================
-- EJERCICIOS PRÁCTICOS - MÓDULO 1: INTRODUCCIÓN A SQL
-- =====================================================

-- Ejercicio 1: Crear Base de Datos de Biblioteca
-- ================================================
CREATE DATABASE biblioteca;
USE biblioteca;

CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    año_publicacion INT,
    genero VARCHAR(50)
);

-- Insertar datos de ejemplo
INSERT INTO libros (titulo, autor, año_publicacion, genero) VALUES
('El Quijote', 'Miguel de Cervantes', 1605, 'Novela'),
('Cien años de soledad', 'Gabriel García Márquez', 1967, 'Realismo mágico'),
('1984', 'George Orwell', 1949, 'Ciencia ficción'),
('Don Juan Tenorio', 'José Zorrilla', 1844, 'Teatro'),
('La casa de los espíritus', 'Isabel Allende', 1982, 'Novela');

-- Ver los datos insertados
SELECT * FROM libros;

-- =====================================================

-- Ejercicio 2: Crear Base de Datos de Escuela
-- ============================================
CREATE DATABASE escuela;
USE escuela;

CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    edad INT,
    grado INT
);

-- Insertar datos de ejemplo
INSERT INTO estudiantes (nombre, apellido, edad, grado) VALUES
('Ana', 'García', 15, 10),
('Carlos', 'López', 16, 11),
('María', 'Rodríguez', 14, 9),
('Pedro', 'Martínez', 17, 12),
('Laura', 'Fernández', 15, 10);

-- Ver los datos insertados
SELECT * FROM estudiantes;

-- =====================================================

-- Ejercicio 3: Crear Base de Datos de Restaurante
-- ================================================
CREATE DATABASE restaurante;
USE restaurante;

CREATE TABLE platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500),
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50)
);

-- Insertar datos de ejemplo
INSERT INTO platos (nombre, descripcion, precio, categoria) VALUES
('Paella Valenciana', 'Arroz con pollo, conejo y verduras', 18.50, 'Arroces'),
('Gazpacho Andaluz', 'Sopa fría de tomate y verduras', 8.00, 'Sopas'),
('Tortilla Española', 'Tortilla de patatas tradicional', 12.00, 'Tapas'),
('Pulpo a la Gallega', 'Pulpo cocido con patatas y pimentón', 22.00, 'Mariscos'),
('Churros con Chocolate', 'Churros fritos con chocolate caliente', 6.50, 'Postres');

-- Ver los datos insertados
SELECT * FROM platos;

-- =====================================================

-- Ejercicio 4: Crear Base de Datos de Hospital
-- =============================================
CREATE DATABASE hospital;
USE hospital;

CREATE TABLE pacientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    direccion VARCHAR(200)
);

-- Insertar datos de ejemplo
INSERT INTO pacientes (nombre, apellido, fecha_nacimiento, telefono, direccion) VALUES
('Juan', 'Pérez', '1985-03-15', '612345678', 'Calle Mayor 123'),
('Carmen', 'González', '1990-07-22', '623456789', 'Avenida de la Paz 45'),
('Antonio', 'Ruiz', '1978-11-08', '634567890', 'Plaza España 12'),
('Isabel', 'Morales', '1995-01-30', '645678901', 'Calle del Sol 78'),
('Francisco', 'Jiménez', '1982-09-14', '656789012', 'Carrera de San Jerónimo 34');

-- Ver los datos insertados
SELECT * FROM pacientes;

-- =====================================================

-- Ejercicio 5: Crear Base de Datos de Gimnasio
-- =============================================
CREATE DATABASE gimnasio;
USE gimnasio;

CREATE TABLE miembros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    fecha_inscripcion DATE DEFAULT CURRENT_DATE,
    plan_membresia VARCHAR(50)
);

-- Insertar datos de ejemplo
INSERT INTO miembros (nombre, apellido, email, plan_membresia) VALUES
('Roberto', 'Sánchez', 'roberto.sanchez@email.com', 'Premium'),
('Elena', 'Vargas', 'elena.vargas@email.com', 'Básico'),
('Miguel', 'Torres', 'miguel.torres@email.com', 'VIP'),
('Sofía', 'Herrera', 'sofia.herrera@email.com', 'Premium'),
('Diego', 'Castro', 'diego.castro@email.com', 'Básico');

-- Ver los datos insertados
SELECT * FROM miembros;

-- =====================================================

-- Ejercicio 6: Crear Base de Datos de Tienda Online
-- ==================================================
CREATE DATABASE tienda_online;
USE tienda_online;

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(1000),
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50),
    stock INT DEFAULT 0,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES
('iPhone 14', 'Smartphone Apple con cámara de 48MP', 999.99, 'Electrónicos', 25),
('Samsung Galaxy S23', 'Smartphone Android con pantalla AMOLED', 899.99, 'Electrónicos', 30),
('MacBook Air M2', 'Laptop Apple con chip M2', 1299.99, 'Computadoras', 15),
('Dell XPS 13', 'Laptop Windows con pantalla 4K', 1199.99, 'Computadoras', 20),
('AirPods Pro', 'Auriculares inalámbricos con cancelación de ruido', 249.99, 'Accesorios', 50);

-- Ver los datos insertados
SELECT * FROM productos;

-- =====================================================

-- Ejercicio 7: Crear Base de Datos de Banco
-- ==========================================
CREATE DATABASE banco;
USE banco;

CREATE TABLE cuentas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_cuenta VARCHAR(20) UNIQUE NOT NULL,
    titular VARCHAR(200) NOT NULL,
    saldo DECIMAL(15,2) DEFAULT 0.00,
    tipo_cuenta VARCHAR(20),
    fecha_apertura DATE DEFAULT CURRENT_DATE
);

-- Insertar datos de ejemplo
INSERT INTO cuentas (numero_cuenta, titular, saldo, tipo_cuenta) VALUES
('ES12345678901234567890', 'María González López', 2500.75, 'Corriente'),
('ES23456789012345678901', 'Carlos Ruiz Martín', 15000.00, 'Ahorro'),
('ES34567890123456789012', 'Ana Fernández García', 850.50, 'Corriente'),
('ES45678901234567890123', 'Pedro Sánchez Rodríguez', 50000.00, 'Inversión'),
('ES56789012345678901234', 'Laura Jiménez Pérez', 3200.25, 'Corriente');

-- Ver los datos insertados
SELECT * FROM cuentas;

-- =====================================================

-- Ejercicio 8: Crear Base de Datos de Agencia de Viajes
-- =====================================================
CREATE DATABASE agencia_viajes;
USE agencia_viajes;

CREATE TABLE destinos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    precio_persona DECIMAL(10,2) NOT NULL,
    duracion_dias INT,
    descripcion VARCHAR(500)
);

-- Insertar datos de ejemplo
INSERT INTO destinos (nombre, pais, ciudad, precio_persona, duracion_dias, descripcion) VALUES
('París Romántico', 'Francia', 'París', 1200.00, 7, 'Tour por la ciudad del amor'),
('Roma Imperial', 'Italia', 'Roma', 950.00, 5, 'Historia y arte en la capital italiana'),
('Tokio Moderno', 'Japón', 'Tokio', 2500.00, 10, 'Cultura tradicional y tecnología'),
('Nueva York', 'Estados Unidos', 'Nueva York', 1800.00, 8, 'La ciudad que nunca duerme'),
('Londres Clásico', 'Reino Unido', 'Londres', 1100.00, 6, 'Tradición británica y modernidad');

-- Ver los datos insertados
SELECT * FROM destinos;

-- =====================================================

-- Ejercicio 9: Crear Base de Datos de Cine
-- =========================================
CREATE DATABASE cine;
USE cine;

CREATE TABLE peliculas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    director VARCHAR(100) NOT NULL,
    año_estreno INT,
    genero VARCHAR(50),
    duracion_minutos INT,
    calificacion DECIMAL(2,1) CHECK (calificacion >= 0.0 AND calificacion <= 10.0)
);

-- Insertar datos de ejemplo
INSERT INTO peliculas (titulo, director, año_estreno, genero, duracion_minutos, calificacion) VALUES
('El Padrino', 'Francis Ford Coppola', 1972, 'Drama', 175, 9.2),
('Pulp Fiction', 'Quentin Tarantino', 1994, 'Crimen', 154, 8.9),
('El Señor de los Anillos', 'Peter Jackson', 2001, 'Fantasía', 178, 8.8),
('Titanic', 'James Cameron', 1997, 'Romance', 194, 7.8),
('Inception', 'Christopher Nolan', 2010, 'Ciencia ficción', 148, 8.8);

-- Ver los datos insertados
SELECT * FROM peliculas;

-- =====================================================

-- Ejercicio 10: Crear Base de Datos de Red Social
-- ================================================
CREATE DATABASE red_social;
USE red_social;

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    nombre_completo VARCHAR(200) NOT NULL,
    fecha_nacimiento DATE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar datos de ejemplo
INSERT INTO usuarios (username, email, nombre_completo, fecha_nacimiento) VALUES
('alex_garcia', 'alex.garcia@email.com', 'Alejandro García Martínez', '1995-05-15'),
('maria_lopez', 'maria.lopez@email.com', 'María López Fernández', '1992-08-22'),
('carlos_ruiz', 'carlos.ruiz@email.com', 'Carlos Ruiz Sánchez', '1988-12-03'),
('ana_martin', 'ana.martin@email.com', 'Ana Martín González', '1997-03-18'),
('pedro_hernandez', 'pedro.hernandez@email.com', 'Pedro Hernández Torres', '1990-11-25');

-- Ver los datos insertados
SELECT * FROM usuarios;

-- =====================================================

-- PROYECTO INTEGRADOR: Sistema de Gestión de Biblioteca Completo
-- ==============================================================
CREATE DATABASE biblioteca_completa;
USE biblioteca_completa;

-- Tabla de libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    editorial VARCHAR(100),
    año_publicacion INT,
    genero VARCHAR(50),
    disponible BOOLEAN DEFAULT TRUE
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT CURRENT_DATE
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    libro_id INT,
    usuario_id INT,
    fecha_prestamo DATE DEFAULT CURRENT_DATE,
    fecha_devolucion DATE,
    devuelto BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (libro_id) REFERENCES libros(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Insertar datos de ejemplo en libros
INSERT INTO libros (isbn, titulo, autor, editorial, año_publicacion, genero) VALUES
('978-84-376-0494-7', 'Cien años de soledad', 'Gabriel García Márquez', 'Cátedra', 1967, 'Realismo mágico'),
('978-84-376-0495-4', 'El Quijote', 'Miguel de Cervantes', 'Cátedra', 1605, 'Novela'),
('978-84-376-0496-1', '1984', 'George Orwell', 'Debolsillo', 1949, 'Ciencia ficción'),
('978-84-376-0497-8', 'La casa de los espíritus', 'Isabel Allende', 'Plaza & Janés', 1982, 'Novela'),
('978-84-376-0498-5', 'Rayuela', 'Julio Cortázar', 'Alfaguara', 1963, 'Novela experimental');

-- Insertar datos de ejemplo en usuarios
INSERT INTO usuarios (nombre, apellido, email, telefono) VALUES
('Ana', 'García', 'ana.garcia@email.com', '612345678'),
('Carlos', 'López', 'carlos.lopez@email.com', '623456789'),
('María', 'Rodríguez', 'maria.rodriguez@email.com', '634567890'),
('Pedro', 'Martínez', 'pedro.martinez@email.com', '645678901'),
('Laura', 'Fernández', 'laura.fernandez@email.com', '656789012');

-- Insertar datos de ejemplo en préstamos
INSERT INTO prestamos (libro_id, usuario_id, fecha_prestamo, fecha_devolucion, devuelto) VALUES
(1, 1, '2024-01-15', '2024-02-15', FALSE),
(2, 2, '2024-01-20', '2024-02-20', FALSE),
(3, 3, '2024-01-10', '2024-02-10', TRUE),
(4, 4, '2024-01-25', '2024-02-25', FALSE),
(5, 5, '2024-01-30', '2024-02-28', FALSE);

-- Consultas básicas para ver los datos
SELECT '=== LIBROS ===' as seccion;
SELECT * FROM libros;

SELECT '=== USUARIOS ===' as seccion;
SELECT * FROM usuarios;

SELECT '=== PRÉSTAMOS ===' as seccion;
SELECT * FROM prestamos;

-- Consulta combinada para ver préstamos con información de libros y usuarios
SELECT '=== PRÉSTAMOS CON DETALLES ===' as seccion;
SELECT 
    p.id as prestamo_id,
    l.titulo as libro,
    l.autor,
    CONCAT(u.nombre, ' ', u.apellido) as usuario,
    p.fecha_prestamo,
    p.fecha_devolucion,
    CASE WHEN p.devuelto THEN 'Sí' ELSE 'No' END as devuelto
FROM prestamos p
JOIN libros l ON p.libro_id = l.id
JOIN usuarios u ON p.usuario_id = u.id;

-- =====================================================
-- CONSULTAS ADICIONALES PARA PRÁCTICA
-- =====================================================

-- Ver solo libros disponibles
SELECT '=== LIBROS DISPONIBLES ===' as seccion;
SELECT titulo, autor, genero FROM libros WHERE disponible = TRUE;

-- Ver usuarios registrados en 2024
SELECT '=== USUARIOS REGISTRADOS EN 2024 ===' as seccion;
SELECT nombre, apellido, email, fecha_registro FROM usuarios 
WHERE YEAR(fecha_registro) = 2024;

-- Ver préstamos no devueltos
SELECT '=== PRÉSTAMOS PENDIENTES ===' as seccion;
SELECT 
    l.titulo as libro,
    CONCAT(u.nombre, ' ', u.apellido) as usuario,
    p.fecha_prestamo,
    DATEDIFF(CURDATE(), p.fecha_prestamo) as dias_prestado
FROM prestamos p
JOIN libros l ON p.libro_id = l.id
JOIN usuarios u ON p.usuario_id = u.id
WHERE p.devuelto = FALSE;

-- =====================================================
-- EJERCICIOS DE LA CLASE 6: FUNCIONES BÁSICAS
-- =====================================================

-- Ejercicio 1: Funciones de Texto
-- Concatenar nombre y categoría con un separador
SELECT 
    CONCAT(nombre, ' | ', categoria) AS producto_categoria
FROM productos;

-- Nombres en mayúsculas y minúsculas
SELECT 
    nombre,
    UPPER(nombre) AS nombre_mayusculas,
    LOWER(nombre) AS nombre_minusculas
FROM productos;

-- Primeras 10 letras del nombre
SELECT 
    nombre,
    SUBSTRING(nombre, 1, 10) AS primeras_10_letras
FROM productos;

-- Reemplazar espacios con guiones bajos
SELECT 
    nombre,
    REPLACE(nombre, ' ', '_') AS nombre_con_guiones
FROM productos;

-- Ejercicio 2: Funciones Numéricas
-- Redondear precios a 1 decimal
SELECT 
    nombre,
    precio,
    ROUND(precio, 1) AS precio_redondeado
FROM productos;

-- Valor total del inventario
SELECT 
    nombre,
    precio,
    stock,
    (precio * stock) AS valor_total_inventario
FROM productos;

-- Descuento del 15% a productos caros
SELECT 
    nombre,
    precio AS precio_original,
    CASE 
        WHEN precio > 100 THEN ROUND(precio * 0.85, 2)
        ELSE precio
    END AS precio_con_descuento
FROM productos;

-- Resto de división
SELECT 
    nombre,
    stock,
    MOD(stock, 3) AS resto_division_3
FROM productos;

-- Ejercicio 3: Funciones de Fecha
-- Partes de la fecha
SELECT 
    nombre,
    fecha_creacion,
    YEAR(fecha_creacion) AS año,
    MONTH(fecha_creacion) AS mes,
    DAY(fecha_creacion) AS dia
FROM productos;

-- Días transcurridos
SELECT 
    nombre,
    fecha_creacion,
    DATEDIFF(NOW(), fecha_creacion) AS dias_transcurridos
FROM productos;

-- Fecha más 45 días
SELECT 
    nombre,
    fecha_creacion,
    DATE_ADD(fecha_creacion, INTERVAL 45 DAY) AS fecha_mas_45_dias
FROM productos;

-- Categorizar por antigüedad
SELECT 
    nombre,
    fecha_creacion,
    DATEDIFF(NOW(), fecha_creacion) AS dias_antiguedad,
    CASE 
        WHEN DATEDIFF(NOW(), fecha_creacion) > 30 THEN 'Antiguo'
        WHEN DATEDIFF(NOW(), fecha_creacion) > 7 THEN 'Reciente'
        ELSE 'Nuevo'
    END AS categoria_antiguedad
FROM productos;

-- =====================================================
-- EJERCICIOS DE LA CLASE 7: FILTROS AVANZADOS
-- =====================================================

-- Ejercicio 1: Búsquedas con LIKE
-- Productos que empiecen con 'L'
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE nombre LIKE 'L%';

-- Productos que contengan 'Apple'
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE nombre LIKE '%Apple%';

-- Productos que terminen con 'g'
SELECT 
    nombre,
    categoria
FROM productos 
WHERE nombre LIKE '%g';

-- Productos con nombres de exactamente 8 caracteres
SELECT 
    nombre,
    LENGTH(nombre) AS longitud
FROM productos 
WHERE nombre LIKE '________';

-- Ejercicio 2: Filtros con IN
-- Productos de marcas específicas
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca IN ('Apple', 'Samsung', 'Sony');

-- Productos con precios específicos
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio IN (25.50, 89.99, 199.99);

-- Productos de categorías específicas
SELECT 
    nombre,
    categoria,
    stock
FROM productos 
WHERE categoria IN ('Electrónicos', 'Accesorios');

-- Excluir productos de marcas específicas
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca NOT IN ('Apple', 'Samsung');

-- Ejercicio 3: Filtros con BETWEEN
-- Productos con precios entre 50 y 300
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio BETWEEN 50 AND 300;

-- Productos con stock entre 10 y 25
SELECT 
    nombre,
    stock,
    precio
FROM productos 
WHERE stock BETWEEN 10 AND 25;

-- Productos creados en un rango de fechas
SELECT 
    nombre,
    fecha_creacion,
    categoria
FROM productos 
WHERE fecha_creacion BETWEEN '2024-01-01' AND '2024-12-31';

-- Excluir productos con precios entre 100 y 500
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio NOT BETWEEN 100 AND 500;

-- Ejercicio 4: Manejo de Valores NULL
-- Productos sin descripción
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE descripcion IS NULL;

-- Productos con descripción
SELECT 
    nombre,
    descripcion,
    precio
FROM productos 
WHERE descripcion IS NOT NULL;

-- Productos sin marca
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE marca IS NULL;

-- Productos con marca
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca IS NOT NULL;

-- Ejercicio 5: Combinaciones Complejas
-- Productos caros de electrónicos con stock alto
SELECT 
    nombre,
    categoria,
    precio,
    stock
FROM productos 
WHERE categoria = 'Electrónicos' 
  AND precio > 500 
  AND stock > 10;

-- Productos que empiecen con 'L' o 'M' y tengan precio entre 50 y 200
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE (nombre LIKE 'L%' OR nombre LIKE 'M%') 
  AND precio BETWEEN 50 AND 200;

-- Productos de marcas específicas con stock bajo
SELECT 
    nombre,
    marca,
    stock,
    precio
FROM productos 
WHERE marca IN ('Apple', 'Samsung', 'Sony') 
  AND stock < 10;

-- Productos con descripción y que NO sean de electrónicos
SELECT 
    nombre,
    categoria,
    descripcion,
    precio
FROM productos 
WHERE descripcion IS NOT NULL 
  AND NOT categoria = 'Electrónicos';

-- =====================================================
-- EJERCICIOS DE LA CLASE 8: ORDENAMIENTO Y AGRUPACIÓN
-- =====================================================

-- Ejercicio 1: Ordenamiento Básico
-- Ordenar por nombre ascendente
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
ORDER BY nombre ASC;

-- Ordenar por precio descendente
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
ORDER BY precio DESC;

-- Ordenar por categoría y precio
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
ORDER BY categoria ASC, precio DESC;

-- Ordenar por longitud del nombre
SELECT 
    nombre,
    LENGTH(nombre) AS longitud_nombre
FROM productos 
ORDER BY LENGTH(nombre) DESC;

-- Ejercicio 2: Agrupación Básica
-- Contar productos por categoría
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos 
GROUP BY categoria;

-- Sumar stock por marca
SELECT 
    marca,
    SUM(stock) AS stock_total
FROM productos 
GROUP BY marca;

-- Precio promedio por categoría
SELECT 
    categoria,
    AVG(precio) AS precio_promedio
FROM productos 
GROUP BY categoria;

-- Agrupar por categoría y marca
SELECT 
    categoria,
    marca,
    COUNT(*) AS total_productos
FROM productos 
GROUP BY categoria, marca;

-- Ejercicio 3: Funciones Agregadas
-- Estadísticas completas por categoría
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    SUM(stock) AS stock_total,
    AVG(precio) AS precio_promedio,
    MIN(precio) AS precio_minimo,
    MAX(precio) AS precio_maximo
FROM productos 
GROUP BY categoria;

-- Valor total del inventario por marca
SELECT 
    marca,
    COUNT(*) AS total_productos,
    SUM(precio * stock) AS valor_inventario
FROM productos 
GROUP BY marca;

-- Precios mínimo y máximo por categoría
SELECT 
    categoria,
    MIN(precio) AS precio_minimo,
    MAX(precio) AS precio_maximo
FROM productos 
GROUP BY categoria;

-- Estadísticas de stock por marca
SELECT 
    marca,
    COUNT(*) AS total_productos,
    AVG(stock) AS stock_promedio,
    MIN(stock) AS stock_minimo,
    MAX(stock) AS stock_maximo
FROM productos 
GROUP BY marca;

-- Ejercicio 4: Filtrado de Grupos
-- Categorías con más de 2 productos
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos 
GROUP BY categoria 
HAVING COUNT(*) > 2;

-- Marcas con stock total mayor a 50
SELECT 
    marca,
    SUM(stock) AS stock_total
FROM productos 
GROUP BY marca 
HAVING SUM(stock) > 50;

-- Categorías con precio promedio mayor a 100
SELECT 
    categoria,
    AVG(precio) AS precio_promedio
FROM productos 
GROUP BY categoria 
HAVING AVG(precio) > 100;

-- Marcas con múltiples condiciones
SELECT 
    marca,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos 
GROUP BY marca 
HAVING COUNT(*) > 1 AND AVG(precio) > 50;

-- Ejercicio 5: Combinación Compleja
-- Top 3 categorías por número de productos
SELECT 
    categoria,
    COUNT(*) AS total_productos
FROM productos 
GROUP BY categoria 
ORDER BY COUNT(*) DESC 
LIMIT 3;

-- Marcas ordenadas por stock total
SELECT 
    marca,
    SUM(stock) AS stock_total
FROM productos 
GROUP BY marca 
ORDER BY SUM(stock) DESC;

-- Categorías con precio promedio mayor a 100, ordenadas por precio
SELECT 
    categoria,
    AVG(precio) AS precio_promedio
FROM productos 
GROUP BY categoria 
HAVING AVG(precio) > 100 
ORDER BY AVG(precio) DESC;

-- Marcas con stock total mayor a 30, ordenadas por stock
SELECT 
    marca,
    SUM(stock) AS stock_total
FROM productos 
GROUP BY marca 
HAVING SUM(stock) > 30 
ORDER BY SUM(stock) DESC;

-- =====================================================
-- EJERCICIOS DE LA CLASE 9: ÍNDICES Y OPTIMIZACIÓN
-- =====================================================

-- Ejercicio 1: Crear Índices Básicos
-- Crear índice en columna nombre
CREATE INDEX idx_nombre ON productos (nombre);

-- Crear índice en columna precio
CREATE INDEX idx_precio ON productos (precio);

-- Crear índice en columna categoria
CREATE INDEX idx_categoria ON productos (categoria);

-- Crear índice en columna fecha_creacion
CREATE INDEX idx_fecha_creacion ON productos (fecha_creacion);

-- Ejercicio 2: Crear Índices Compuestos
-- Crear índice compuesto en categoria y precio
CREATE INDEX idx_categoria_precio ON productos (categoria, precio);

-- Crear índice compuesto en marca y categoria
CREATE INDEX idx_marca_categoria ON productos (marca, categoria);

-- Crear índice compuesto en categoria, marca y precio
CREATE INDEX idx_categoria_marca_precio ON productos (categoria, marca, precio);

-- Verificar índices creados
SHOW INDEX FROM productos;

-- Ejercicio 3: Análisis con EXPLAIN
-- Analizar consulta simple
EXPLAIN SELECT * FROM productos WHERE nombre = 'iPhone 14';

-- Analizar consulta con filtro por categoría
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos';

-- Analizar consulta con filtro por precio
EXPLAIN SELECT * FROM productos WHERE precio > 100;

-- Analizar consulta con filtro compuesto
EXPLAIN SELECT * FROM productos WHERE categoria = 'Electrónicos' AND precio > 100;

-- Ejercicio 4: Optimización de Consultas
-- Analizar consulta lenta
EXPLAIN SELECT * FROM productos WHERE descripcion LIKE '%smartphone%';

-- Crear índice de texto completo
CREATE FULLTEXT INDEX idx_descripcion ON productos (descripcion);

-- Analizar consulta optimizada
EXPLAIN SELECT * FROM productos WHERE MATCH(descripcion) AGAINST('smartphone');

-- Ejercicio 5: Monitoreo y Mantenimiento
-- Ver todos los índices de la tabla
SHOW INDEX FROM productos;

-- Ver información detallada de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'tienda_online' 
  AND TABLE_NAME = 'productos';

-- Eliminar índice innecesario
DROP INDEX idx_nombre ON productos;

-- Verificar que el índice fue eliminado
SHOW INDEX FROM productos;

-- =====================================================
-- EJERCICIOS DE LA CLASE 10: PROYECTO INTEGRADOR
-- =====================================================

-- Crear base de datos del proyecto integrador
CREATE DATABASE biblioteca_sistema;
USE biblioteca_sistema;

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de autores
CREATE TABLE autores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad VARCHAR(50),
    biografia TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    categoria_id INT,
    autor_id INT,
    año_publicacion YEAR,
    editorial VARCHAR(100),
    paginas INT,
    precio DECIMAL(8,2),
    stock INT DEFAULT 1,
    disponible BOOLEAN DEFAULT TRUE,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    FOREIGN KEY (autor_id) REFERENCES autores(id)
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_nacimiento DATE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    libro_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_prestamo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_devolucion_esperada DATE,
    fecha_devolucion_real DATE NULL,
    estado ENUM('activo', 'devuelto', 'vencido') DEFAULT 'activo',
    multa DECIMAL(8,2) DEFAULT 0.00,
    FOREIGN KEY (libro_id) REFERENCES libros(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Insertar datos de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES
('Ficción', 'Novelas y cuentos de ficción'),
('Ciencia', 'Libros de ciencias exactas y naturales'),
('Historia', 'Libros de historia universal y local'),
('Tecnología', 'Libros de programación y tecnología'),
('Filosofía', 'Libros de pensamiento filosófico'),
('Arte', 'Libros de arte y diseño');

INSERT INTO autores (nombre, apellido, fecha_nacimiento, nacionalidad, biografia) VALUES
('Gabriel', 'García Márquez', '1927-03-06', 'Colombiana', 'Premio Nobel de Literatura 1982'),
('Isaac', 'Asimov', '1920-01-02', 'Estadounidense', 'Escritor de ciencia ficción y divulgación científica'),
('Yuval', 'Harari', '1976-02-24', 'Israelí', 'Historiador y filósofo especializado en historia mundial'),
('Robert', 'Martin', '1952-12-05', 'Estadounidense', 'Desarrollador de software y autor de Clean Code'),
('Platón', 'Atenas', '0428-01-01', 'Griega', 'Filósofo griego, discípulo de Sócrates'),
('Leonardo', 'da Vinci', '1452-04-15', 'Italiana', 'Polímata del Renacimiento italiano');

INSERT INTO libros (titulo, isbn, categoria_id, autor_id, año_publicacion, editorial, paginas, precio, stock) VALUES
('Cien años de soledad', '978-84-376-0494-7', 1, 1, 1967, 'Editorial Sudamericana', 471, 15.99, 3),
('Fundación', '978-84-376-0495-4', 1, 2, 1951, 'Gnome Press', 244, 12.99, 2),
('Sapiens', '978-84-376-0496-1', 3, 3, 2011, 'Harper', 443, 18.99, 4),
('Clean Code', '978-84-376-0497-8', 4, 4, 2008, 'Prentice Hall', 464, 25.99, 2),
('La República', '978-84-376-0498-5', 5, 5, -380, 'Ediciones Clásicas', 416, 14.99, 1),
('Tratado de la pintura', '978-84-376-0499-2', 6, 6, 1651, 'Editorial Arte', 320, 22.99, 1);

INSERT INTO usuarios (nombre, apellido, email, telefono, direccion, fecha_nacimiento) VALUES
('Ana', 'García', 'ana.garcia@email.com', '555-0101', 'Calle Mayor 123, Madrid', '1990-05-15'),
('Carlos', 'López', 'carlos.lopez@email.com', '555-0102', 'Avenida Libertad 456, Barcelona', '1985-08-22'),
('María', 'Rodríguez', 'maria.rodriguez@email.com', '555-0103', 'Plaza España 789, Valencia', '1992-12-03'),
('José', 'Martín', 'jose.martin@email.com', '555-0104', 'Calle Sol 321, Sevilla', '1988-03-18'),
('Laura', 'Sánchez', 'laura.sanchez@email.com', '555-0105', 'Avenida Paz 654, Bilbao', '1995-07-25');

INSERT INTO prestamos (libro_id, usuario_id, fecha_devolucion_esperada, estado) VALUES
(1, 1, '2024-02-15', 'devuelto'),
(2, 2, '2024-02-20', 'activo'),
(3, 3, '2024-02-18', 'activo'),
(4, 1, '2024-02-25', 'activo'),
(5, 4, '2024-02-12', 'vencido');

-- Consultas del proyecto integrador
-- Consulta 1: Libros Disponibles por Categoría
SELECT 
    c.nombre AS categoria,
    COUNT(l.id) AS total_libros,
    COUNT(CASE WHEN l.disponible = TRUE THEN 1 END) AS libros_disponibles
FROM categorias c
LEFT JOIN libros l ON c.id = l.categoria_id
GROUP BY c.id, c.nombre
ORDER BY total_libros DESC;

-- Consulta 2: Top 5 Autores Más Populares
SELECT 
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    COUNT(l.id) AS total_libros,
    SUM(l.stock) AS total_ejemplares
FROM autores a
LEFT JOIN libros l ON a.id = l.autor_id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY total_libros DESC
LIMIT 5;

-- Consulta 3: Usuarios con Préstamos Activos
SELECT 
    CONCAT(u.nombre, ' ', u.apellido) AS usuario,
    u.email,
    COUNT(p.id) AS prestamos_activos,
    MAX(p.fecha_devolucion_esperada) AS proxima_devolucion
FROM usuarios u
INNER JOIN prestamos p ON u.id = p.usuario_id
WHERE p.estado = 'activo'
GROUP BY u.id, u.nombre, u.apellido, u.email
ORDER BY prestamos_activos DESC;

-- Consulta 4: Libros Más Prestados
SELECT 
    l.titulo,
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    c.nombre AS categoria,
    COUNT(p.id) AS veces_prestado
FROM libros l
INNER JOIN prestamos p ON l.id = p.libro_id
INNER JOIN autores a ON l.autor_id = a.id
INNER JOIN categorias c ON l.categoria_id = c.id
GROUP BY l.id, l.titulo, a.nombre, a.apellido, c.nombre
ORDER BY veces_prestado DESC
LIMIT 10;

-- Consulta 5: Reporte de Préstamos por Mes
SELECT 
    YEAR(fecha_prestamo) AS año,
    MONTH(fecha_prestamo) AS mes,
    COUNT(*) AS total_prestamos,
    COUNT(CASE WHEN estado = 'devuelto' THEN 1 END) AS devueltos,
    COUNT(CASE WHEN estado = 'vencido' THEN 1 END) AS vencidos
FROM prestamos
GROUP BY YEAR(fecha_prestamo), MONTH(fecha_prestamo)
ORDER BY año DESC, mes DESC;
