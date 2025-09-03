-- =====================================================
-- EJERCICIOS PRÁCTICOS - MÓDULO 4: DISEÑO DE BASES DE DATOS
-- =====================================================

-- =====================================================
-- EJERCICIOS DE LA CLASE 1: INTRODUCCIÓN AL DISEÑO
-- =====================================================

-- Ejercicio 1: Identificar entidades para sistema de hospital
CREATE DATABASE hospital_diseno;
USE hospital_diseno;

-- Entidades identificadas: PACIENTE, DOCTOR, CITA, ESPECIALIDAD, HISTORIAL_MEDICO
CREATE TABLE pacientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    direccion TEXT
);

CREATE TABLE especialidades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE doctores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    especialidad_id INT,
    consultorio VARCHAR(20),
    telefono VARCHAR(20),
    FOREIGN KEY (especialidad_id) REFERENCES especialidades(id)
);

-- Ejercicio 2: Analizar redundancia en esquema
CREATE TABLE ventas_redundante (
    id INT PRIMARY KEY,
    cliente_nombre VARCHAR(100),
    cliente_telefono VARCHAR(20),
    producto_nombre VARCHAR(100),
    producto_precio DECIMAL(10,2),
    vendedor_nombre VARCHAR(100),
    vendedor_departamento VARCHAR(50)
);

-- Problemas identificados: información del cliente, producto y vendedor repetida

-- Ejercicio 3: Diseño de esquema básico para restaurante
CREATE DATABASE restaurante_basico;
USE restaurante_basico;

CREATE TABLE mesas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero INT NOT NULL UNIQUE,
    capacidad INT NOT NULL,
    ubicacion VARCHAR(50)
);

CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    mesa_id INT,
    fecha_reserva DATE,
    hora_reserva TIME,
    numero_personas INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (mesa_id) REFERENCES mesas(id)
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 2: MODELADO ER
-- =====================================================

-- Ejercicio 4: Relación 1:1 entre EMPLEADO y CUENTA_USUARIO
CREATE DATABASE empresa_er;
USE empresa_er;

CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_contratacion DATE
);

CREATE TABLE cuentas_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT UNIQUE,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);

-- Ejercicio 5: Relación 1:N entre CLIENTE y PEDIDO
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado'),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Ejercicio 6: Relación N:N entre ESTUDIANTE y CURSO
CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    creditos INT
);

CREATE TABLE inscripciones (
    estudiante_id INT,
    curso_id INT,
    fecha_inscripcion DATE,
    calificacion DECIMAL(3,2),
    estado ENUM('activo', 'completado', 'cancelado'),
    PRIMARY KEY (estudiante_id, curso_id),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 3: PRIMERA FORMA NORMAL
-- =====================================================

-- Ejercicio 7: Aplicar 1FN a tabla de empleados
CREATE DATABASE empleados_1fn;
USE empleados_1fn;

-- Tabla original con violaciones de 1FN
CREATE TABLE empleados_violacion (
    id INT PRIMARY KEY,
    nombre_completo VARCHAR(200),
    telefonos VARCHAR(200),
    direccion TEXT,
    habilidades VARCHAR(300)
);

-- Solución normalizada
CREATE TABLE empleados_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    fecha_contratacion DATE,
    salario_actual DECIMAL(10,2)
);

CREATE TABLE telefonos_empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT NOT NULL,
    numero VARCHAR(20) NOT NULL,
    tipo ENUM('personal', 'trabajo', 'emergencia'),
    es_principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (empleado_id) REFERENCES empleados_1fn(id)
);

-- Ejercicio 8: Normalizar sistema de inventario
CREATE TABLE productos_inventario_1fn (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio_actual DECIMAL(10,2) NOT NULL,
    stock_actual INT DEFAULT 0
);

CREATE TABLE categorias_productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE productos_categorias (
    producto_id INT,
    categoria_id INT,
    PRIMARY KEY (producto_id, categoria_id),
    FOREIGN KEY (producto_id) REFERENCES productos_inventario_1fn(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias_productos(id)
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 4: SEGUNDA Y TERCERA FORMA NORMAL
-- =====================================================

-- Ejercicio 9: Aplicar 2FN a sistema de ventas
CREATE DATABASE ventas_2fn_3fn;
USE ventas_2fn_3fn;

-- Tabla con violaciones de 2FN
CREATE TABLE ventas_productos_violacion (
    venta_id INT,
    producto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    nombre_producto VARCHAR(200),
    categoria_producto VARCHAR(100),
    fecha_venta DATE,
    cliente_id INT,
    PRIMARY KEY (venta_id, producto_id)
);

-- Solución en 2FN
CREATE TABLE ventas_2fn (
    venta_id INT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    cliente_id INT NOT NULL,
    total DECIMAL(10,2)
);

CREATE TABLE productos_2fn (
    producto_id INT PRIMARY KEY,
    nombre_producto VARCHAR(200) NOT NULL,
    categoria_producto VARCHAR(100),
    precio_base DECIMAL(10,2)
);

CREATE TABLE detalle_ventas_2fn (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas_2fn(venta_id),
    FOREIGN KEY (producto_id) REFERENCES productos_2fn(producto_id)
);

-- Ejercicio 10: Aplicar 3FN a sistema de empleados
CREATE TABLE departamentos_3fn (
    departamento_id INT PRIMARY KEY,
    nombre_departamento VARCHAR(100) NOT NULL,
    jefe_departamento VARCHAR(100),
    presupuesto_departamento DECIMAL(12,2)
);

CREATE TABLE empleados_3fn (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamentos_3fn(departamento_id)
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 5: RELACIONES Y CLAVES FORÁNEAS
-- =====================================================

-- Ejercicio 11: Implementar diferentes tipos de cascada
CREATE DATABASE cascada_ejemplos;
USE cascada_ejemplos;

CREATE TABLE departamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    presupuesto DECIMAL(12,2)
);

-- CASCADE: Al eliminar departamento, se eliminan empleados
CREATE TABLE empleados_cascade (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento_id INT,
    salario DECIMAL(10,2),
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE CASCADE
);

-- SET NULL: Al eliminar departamento, se establece NULL
CREATE TABLE proyectos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    departamento_id INT,
    fecha_inicio DATE,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE SET NULL
);

-- RESTRICT: No permite eliminar departamento si hay equipos
CREATE TABLE equipos_trabajo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento_id INT,
    lider VARCHAR(100),
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE RESTRICT
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 6: INTEGRIDAD REFERENCIAL
-- =====================================================

-- Ejercicio 12: Sistema con integridad referencial completa
CREATE DATABASE integridad_completa;
USE integridad_completa;

CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE
);

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    CONSTRAINT chk_precio_positivo CHECK (precio > 0)
);

CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    CONSTRAINT chk_total_positivo CHECK (total >= 0)
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 7: ÍNDICES Y RENDIMIENTO
-- =====================================================

-- Ejercicio 13: Crear índices para optimización
CREATE DATABASE indices_optimizacion;
USE indices_optimizacion;

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

-- Índices simples
CREATE INDEX idx_empleados_departamento ON empleados(departamento);
CREATE INDEX idx_empleados_salario ON empleados(salario);
CREATE INDEX idx_empleados_fecha_contratacion ON empleados(fecha_contratacion);
CREATE INDEX idx_empleados_activo ON empleados(activo);

-- Índices compuestos
CREATE INDEX idx_empleados_departamento_activo ON empleados(departamento, activo);
CREATE INDEX idx_empleados_salario_activo ON empleados(salario, activo);

-- Ejercicio 14: Analizar rendimiento con EXPLAIN
-- Consulta 1: Buscar empleados por departamento
EXPLAIN SELECT * FROM empleados WHERE departamento = 'IT';

-- Consulta 2: Buscar empleados con salario alto
EXPLAIN SELECT * FROM empleados WHERE salario > 50000;

-- Consulta 3: Buscar empleados activos en un departamento
EXPLAIN SELECT * FROM empleados WHERE departamento = 'Ventas' AND activo = TRUE;

-- =====================================================
-- EJERCICIOS DE LA CLASE 8: ESQUEMAS ESCALABLES
-- =====================================================

-- Ejercicio 15: Sistema escalable para red social
CREATE DATABASE red_social_escalable;
USE red_social_escalable;

-- Tabla de usuarios (datos principales)
CREATE TABLE usuarios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_usuarios_username (username),
    INDEX idx_usuarios_email (email),
    INDEX idx_usuarios_activo (activo)
);

-- Tabla de publicaciones (particionada por fecha)
CREATE TABLE publicaciones (
    id BIGINT AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    contenido TEXT NOT NULL,
    tipo ENUM('texto', 'imagen', 'video', 'enlace') DEFAULT 'texto',
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    likes_count INT DEFAULT 0,
    comentarios_count INT DEFAULT 0,
    PRIMARY KEY (id, fecha_publicacion),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_publicaciones_usuario (usuario_id),
    INDEX idx_publicaciones_fecha (fecha_publicacion)
) PARTITION BY RANGE (UNIX_TIMESTAMP(fecha_publicacion)) (
    PARTITION p_2024_01 VALUES LESS THAN (UNIX_TIMESTAMP('2024-02-01')),
    PARTITION p_2024_02 VALUES LESS THAN (UNIX_TIMESTAMP('2024-03-01')),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 9: OPTIMIZACIÓN DE CONSULTAS
-- =====================================================

-- Ejercicio 16: Optimizar JOINs complejos
CREATE DATABASE consultas_optimizadas;
USE consultas_optimizadas;

CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50)
);

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(100)
);

CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente'
);

CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id)
);

-- Crear índices para optimizar JOINs
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_detalle_ventas_venta ON detalle_ventas(venta_id);
CREATE INDEX idx_detalle_ventas_producto ON detalle_ventas(producto_id);

-- Consulta optimizada
EXPLAIN SELECT 
    c.nombre as cliente,
    p.nombre as producto,
    v.fecha_venta,
    v.total,
    dv.cantidad,
    dv.precio_unitario
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
JOIN detalle_ventas dv ON v.id = dv.venta_id
JOIN productos p ON dv.producto_id = p.id
WHERE v.fecha_venta >= '2024-01-01'
AND v.estado = 'completada'
ORDER BY v.fecha_venta DESC;

-- =====================================================
-- EJERCICIOS DE LA CLASE 10: PROYECTO INTEGRADOR
-- =====================================================

-- Ejercicio 17: Sistema completo de gestión empresarial
CREATE DATABASE gestion_empresarial_completa;
USE gestion_empresarial_completa;

-- Tabla de departamentos
CREATE TABLE departamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    presupuesto DECIMAL(12,2),
    jefe_departamento_id INT,
    fecha_creacion DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de empleados
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_contratacion DATE NOT NULL,
    salario_base DECIMAL(10,2) NOT NULL,
    departamento_id INT,
    cargo VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE SET NULL,
    CONSTRAINT chk_salario_positivo CHECK (salario_base > 0)
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock_minimo INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_precio_positivo CHECK (precio > 0)
);

-- Tabla de inventario
CREATE TABLE inventario (
    producto_id INT PRIMARY KEY,
    stock_actual INT DEFAULT 0,
    ubicacion VARCHAR(100),
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    CONSTRAINT chk_stock_actual_no_negativo CHECK (stock_actual >= 0)
);

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
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    empleado_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    metodo_pago VARCHAR(50),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE RESTRICT,
    CONSTRAINT chk_total_positivo CHECK (total > 0)
);

-- Tabla de detalle de ventas
CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
    CONSTRAINT chk_cantidad_positiva CHECK (cantidad > 0)
);

-- Crear índices para optimización
CREATE INDEX idx_empleados_departamento ON empleados(departamento_id);
CREATE INDEX idx_empleados_email ON empleados(email);
CREATE INDEX idx_empleados_activo ON empleados(activo);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_codigo ON productos(codigo);
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);
CREATE INDEX idx_ventas_empleado ON ventas(empleado_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX idx_ventas_estado ON ventas(estado);

-- Trigger para actualizar stock
DELIMITER //
CREATE TRIGGER actualizar_stock_despues_venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE inventario
    SET stock_actual = stock_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id;
END//
DELIMITER ;

-- Consultas del sistema
-- 1. Empleados por departamento
SELECT 
    d.nombre as departamento,
    COUNT(e.id) as total_empleados,
    AVG(e.salario_base) as salario_promedio
FROM departamentos d
LEFT JOIN empleados e ON d.id = e.departamento_id
WHERE d.activo = TRUE AND (e.activo = TRUE OR e.activo IS NULL)
GROUP BY d.id, d.nombre
ORDER BY total_empleados DESC;

-- 2. Productos con stock bajo
SELECT 
    p.codigo,
    p.nombre,
    p.precio,
    i.stock_actual,
    p.stock_minimo
FROM productos p
JOIN inventario i ON p.id = i.producto_id
WHERE i.stock_actual <= p.stock_minimo
AND p.activo = TRUE
ORDER BY (i.stock_actual - p.stock_minimo) ASC;

-- 3. Ventas por empleado
SELECT 
    e.nombre,
    e.apellido,
    d.nombre as departamento,
    COUNT(v.id) as total_ventas,
    SUM(v.total) as ingresos_totales
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
LEFT JOIN ventas v ON e.id = v.empleado_id
WHERE e.activo = TRUE
GROUP BY e.id, e.nombre, e.apellido, d.nombre
ORDER BY ingresos_totales DESC;
