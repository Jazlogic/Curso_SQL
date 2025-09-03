# Clase 5: Relaciones y Claves Foráneas

## Objetivos de la Clase
- Comprender los tipos de relaciones entre tablas
- Implementar claves foráneas correctamente
- Manejar restricciones de integridad referencial
- Aplicar acciones de cascada y restricciones

## Contenido Teórico

### 1. ¿Qué son las Relaciones?

**Relaciones** son conexiones lógicas entre tablas que permiten establecer vínculos entre datos relacionados, manteniendo la integridad y consistencia de la información.

#### Propósito de las Relaciones:
- **Eliminar redundancia**: Evitar datos duplicados
- **Mantener integridad**: Garantizar consistencia de datos
- **Facilitar consultas**: Permitir JOINs entre tablas
- **Estructurar datos**: Organizar información de manera lógica

### 2. Tipos de Relaciones

#### Relación Uno a Uno (1:1)
```sql
-- Un registro de la tabla A se relaciona con máximo un registro de la tabla B
-- Ejemplo: EMPLEADO ↔ CUENTA_USUARIO

-- Implementación:
CREATE TABLE empleados (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE cuentas_usuario (
    id INT PRIMARY KEY,
    empleado_id INT UNIQUE,  -- UNIQUE para garantizar 1:1
    username VARCHAR(50),
    password_hash VARCHAR(255),
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);
```

#### Relación Uno a Muchos (1:N)
```sql
-- Un registro de la tabla A se relaciona con varios registros de la tabla B
-- Ejemplo: CLIENTE → PEDIDOS

-- Implementación:
CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY,
    cliente_id INT,  -- Sin UNIQUE para permitir múltiples
    fecha_pedido DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

#### Relación Muchos a Muchos (N:N)
```sql
-- Varios registros de la tabla A se relacionan con varios registros de la tabla B
-- Ejemplo: ESTUDIANTES ↔ CURSOS

-- Implementación con tabla intermedia:
CREATE TABLE estudiantes (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE cursos (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    creditos INT
);

CREATE TABLE inscripciones (
    estudiante_id INT,
    curso_id INT,
    fecha_inscripcion DATE,
    calificacion DECIMAL(3,2),
    PRIMARY KEY (estudiante_id, curso_id),  -- Clave compuesta
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
);
```

### 3. Claves Foráneas (Foreign Keys)

#### Definición
Una **clave foránea** es un atributo (o conjunto de atributos) que referencia la clave primaria de otra tabla, estableciendo una relación entre ambas tablas.

#### Características:
- **Referencia única**: Apunta a una clave primaria
- **Integridad referencial**: Garantiza consistencia
- **Restricciones**: Puede ser NULL o NOT NULL
- **Acciones**: Define qué hacer en caso de cambios

#### Sintaxis Básica:
```sql
-- Crear clave foránea al crear tabla
CREATE TABLE tabla_hija (
    id INT PRIMARY KEY,
    padre_id INT,
    nombre VARCHAR(100),
    FOREIGN KEY (padre_id) REFERENCES tabla_padre(id)
);

-- Agregar clave foránea a tabla existente
ALTER TABLE tabla_hija 
ADD FOREIGN KEY (padre_id) REFERENCES tabla_padre(id);
```

### 4. Restricciones de Integridad Referencial

#### Tipos de Restricciones:

##### RESTRICT (Restricción)
```sql
-- No permite eliminar/actualizar si existen referencias
CREATE TABLE pedidos_restrict (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
);

-- Error si intentas eliminar cliente con pedidos
-- DELETE FROM clientes WHERE id = 1; -- ERROR
```

##### CASCADE (Cascada)
```sql
-- Elimina/actualiza automáticamente los registros relacionados
CREATE TABLE pedidos_cascade (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- Elimina automáticamente todos los pedidos del cliente
-- DELETE FROM clientes WHERE id = 1; -- Elimina cliente y sus pedidos
```

##### SET NULL
```sql
-- Establece NULL en la clave foránea
CREATE TABLE pedidos_set_null (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL
);

-- Establece cliente_id = NULL en los pedidos
-- DELETE FROM clientes WHERE id = 1; -- Establece cliente_id = NULL
```

##### NO ACTION
```sql
-- No hace nada (comportamiento por defecto)
CREATE TABLE pedidos_no_action (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE NO ACTION
);
```

### 5. Acciones de Cascada

#### ON DELETE CASCADE
```sql
-- Eliminar en cascada
CREATE TABLE departamentos (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE empleados (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    departamento_id INT,
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE CASCADE
);

-- Al eliminar departamento, se eliminan todos sus empleados
DELETE FROM departamentos WHERE id = 1;
```

#### ON UPDATE CASCADE
```sql
-- Actualizar en cascada
CREATE TABLE clientes (
    id INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON UPDATE CASCADE
);

-- Al actualizar ID del cliente, se actualiza en pedidos
UPDATE clientes SET id = 100 WHERE id = 1;
```

### 6. Índices en Claves Foráneas

#### Importancia de los Índices:
```sql
-- MySQL crea automáticamente índices en claves foráneas
-- Pero es recomendable verificar y optimizar

-- Verificar índices existentes
SHOW INDEX FROM pedidos;

-- Crear índice explícito si es necesario
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de Biblioteca

#### Estructura de Relaciones:
```sql
-- Crear base de datos
CREATE DATABASE biblioteca_relaciones;
USE biblioteca_relaciones;

-- Tabla de autores (1:N con libros)
CREATE TABLE autores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50),
    fecha_nacimiento DATE
);

-- Tabla de categorías (1:N con libros)
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de libros (N:1 con autores y categorías)
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    año_publicacion YEAR,
    paginas INT,
    autor_id INT,
    categoria_id INT,
    FOREIGN KEY (autor_id) REFERENCES autores(id) ON DELETE SET NULL,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT
);

-- Tabla de usuarios (1:N con préstamos)
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de préstamos (N:1 con usuarios y libros)
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE,
    estado ENUM('activo', 'devuelto', 'vencido') DEFAULT 'activo',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (libro_id) REFERENCES libros(id) ON DELETE RESTRICT
);
```

### Ejemplo 2: Sistema de Ventas

#### Relaciones Complejas:
```sql
-- Crear base de datos
CREATE DATABASE ventas_relaciones;
USE ventas_relaciones;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de categorías de productos
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    categoria_id INT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL
);

-- Tabla de vendedores
CREATE TABLE vendedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    comision DECIMAL(5,2) DEFAULT 0.00,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de ventas
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    vendedor_id INT,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(id) ON DELETE SET NULL
);

-- Tabla de detalle de ventas (N:N entre ventas y productos)
CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id),
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
);
```

## Ejercicios Prácticos

### Ejercicio 1: Crear Relación 1:1
**Objetivo**: Implementar relación uno a uno entre EMPLEADO y CUENTA_USUARIO.

```sql
-- Crear tablas con relación 1:1
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_contratacion DATE,
    salario DECIMAL(10,2)
);

CREATE TABLE cuentas_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT UNIQUE,  -- UNIQUE para relación 1:1
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id) ON DELETE CASCADE
);

-- Insertar datos de ejemplo
INSERT INTO empleados (nombre, apellido, email, fecha_contratacion, salario) VALUES
('Juan', 'Pérez', 'juan.perez@empresa.com', '2023-01-15', 50000.00),
('María', 'García', 'maria.garcia@empresa.com', '2023-02-20', 55000.00),
('Carlos', 'López', 'carlos.lopez@empresa.com', '2023-03-10', 48000.00);

INSERT INTO cuentas_usuario (empleado_id, username, password_hash) VALUES
(1, 'jperez', 'hash_password_1'),
(2, 'mgarcia', 'hash_password_2'),
(3, 'clopez', 'hash_password_3');
```

### Ejercicio 2: Crear Relación 1:N
**Objetivo**: Implementar relación uno a muchos entre CLIENTE y PEDIDO.

```sql
-- Crear tablas con relación 1:N
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado') DEFAULT 'pendiente',
    notas TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
);

-- Insertar datos de ejemplo
INSERT INTO clientes (nombre, apellido, email, telefono) VALUES
('Ana', 'López', 'ana.lopez@email.com', '555-0101'),
('Pedro', 'Martínez', 'pedro.martinez@email.com', '555-0102'),
('Sofia', 'Herrera', 'sofia.herrera@email.com', '555-0103');

INSERT INTO pedidos (cliente_id, fecha_pedido, total, estado) VALUES
(1, '2024-01-15', 150.00, 'entregado'),
(1, '2024-01-20', 75.50, 'enviado'),
(1, '2024-01-25', 200.00, 'procesando'),
(2, '2024-01-18', 300.00, 'entregado'),
(2, '2024-01-22', 125.00, 'enviado'),
(3, '2024-01-19', 80.00, 'procesando');
```

### Ejercicio 3: Crear Relación N:N
**Objetivo**: Implementar relación muchos a muchos entre ESTUDIANTE y CURSO.

```sql
-- Crear tablas con relación N:N
CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_nacimiento DATE,
    carrera VARCHAR(100)
);

CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    creditos INT NOT NULL,
    profesor VARCHAR(100),
    semestre ENUM('primavera', 'verano', 'otoño') DEFAULT 'primavera'
);

CREATE TABLE inscripciones (
    estudiante_id INT,
    curso_id INT,
    fecha_inscripcion DATE DEFAULT (CURRENT_DATE),
    calificacion DECIMAL(3,2),
    estado ENUM('activo', 'completado', 'cancelado') DEFAULT 'activo',
    PRIMARY KEY (estudiante_id, curso_id),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
    FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE CASCADE
);

-- Insertar datos de ejemplo
INSERT INTO estudiantes (nombre, apellido, email, carrera) VALUES
('Laura', 'Martínez', 'laura.martinez@universidad.edu', 'Ingeniería'),
('Pedro', 'Sánchez', 'pedro.sanchez@universidad.edu', 'Medicina'),
('Ana', 'González', 'ana.gonzalez@universidad.edu', 'Derecho');

INSERT INTO cursos (nombre, descripcion, creditos, profesor) VALUES
('Base de Datos', 'Fundamentos de bases de datos relacionales', 4, 'Dr. García'),
('Programación', 'Programación orientada a objetos', 3, 'Dra. López'),
('Matemáticas', 'Cálculo diferencial e integral', 5, 'Dr. Rodríguez');

INSERT INTO inscripciones (estudiante_id, curso_id, calificacion, estado) VALUES
(1, 1, 8.5, 'completado'),
(1, 2, 9.0, 'completado'),
(1, 3, 7.8, 'activo'),
(2, 1, 8.0, 'completado'),
(2, 3, 9.2, 'activo'),
(3, 2, 8.7, 'completado'),
(3, 3, 8.9, 'activo');
```

### Ejercicio 4: Implementar Acciones de Cascada
**Objetivo**: Crear sistema con diferentes tipos de cascada.

```sql
-- Crear sistema con diferentes acciones de cascada
CREATE TABLE departamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    presupuesto DECIMAL(12,2),
    jefe_departamento VARCHAR(100)
);

CREATE TABLE empleados_cascade (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento_id INT,
    salario DECIMAL(10,2),
    -- CASCADE: Al eliminar departamento, se eliminan empleados
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE CASCADE
);

CREATE TABLE proyectos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    departamento_id INT,
    fecha_inicio DATE,
    fecha_fin DATE,
    -- SET NULL: Al eliminar departamento, se establece NULL
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE SET NULL
);

CREATE TABLE equipos_trabajo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento_id INT,
    lider VARCHAR(100),
    -- RESTRICT: No permite eliminar departamento si hay equipos
    FOREIGN KEY (departamento_id) REFERENCES departamentos(id) ON DELETE RESTRICT
);

-- Insertar datos de ejemplo
INSERT INTO departamentos (nombre, presupuesto, jefe_departamento) VALUES
('Ventas', 100000.00, 'María García'),
('Marketing', 75000.00, 'Carlos López'),
('IT', 150000.00, 'Ana Martínez');

INSERT INTO empleados_cascade (nombre, departamento_id, salario) VALUES
('Juan Pérez', 1, 45000.00),
('Sofia Herrera', 1, 50000.00),
('Pedro Ruiz', 2, 42000.00),
('Laura Vega', 3, 60000.00);

INSERT INTO proyectos (nombre, departamento_id, fecha_inicio, fecha_fin) VALUES
('Proyecto Web', 3, '2024-01-01', '2024-06-30'),
('Campaña Digital', 2, '2024-02-01', '2024-05-31'),
('Expansión Ventas', 1, '2024-03-01', '2024-12-31');

INSERT INTO equipos_trabajo (nombre, departamento_id, lider) VALUES
('Equipo Desarrollo', 3, 'Laura Vega'),
('Equipo Creativo', 2, 'Pedro Ruiz'),
('Equipo Comercial', 1, 'Juan Pérez');
```

### Ejercicio 5: Manejar Restricciones de Integridad
**Objetivo**: Crear sistema con restricciones complejas.

```sql
-- Crear sistema con restricciones de integridad
CREATE TABLE categorias_productos (
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
    -- RESTRICT: No permite eliminar categoría si hay productos
    FOREIGN KEY (categoria_id) REFERENCES categorias_productos(id) ON DELETE RESTRICT
);

CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'completada', 'cancelada') DEFAULT 'pendiente',
    -- RESTRICT: No permite eliminar cliente si hay ventas
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
);

CREATE TABLE detalle_ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id),
    -- CASCADE: Al eliminar venta, se eliminan detalles
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
    -- RESTRICT: No permite eliminar producto si está en ventas
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
);

-- Insertar datos de ejemplo
INSERT INTO categorias_productos (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Hogar', 'Artículos para el hogar'),
('Deportes', 'Equipos y accesorios deportivos');

INSERT INTO productos (nombre, descripcion, precio, categoria_id, stock) VALUES
('Laptop', 'Computadora portátil', 15000.00, 1, 10),
('Mouse', 'Mouse inalámbrico', 500.00, 1, 50),
('Sofá', 'Sofá de 3 plazas', 8000.00, 2, 5),
('Pelota', 'Pelota de fútbol', 200.00, 3, 20);

INSERT INTO clientes (nombre, email, telefono) VALUES
('Ana López', 'ana.lopez@email.com', '555-0101'),
('Carlos Ruiz', 'carlos.ruiz@email.com', '555-0102');

INSERT INTO ventas (cliente_id, fecha_venta, total, estado) VALUES
(1, '2024-01-15', 15500.00, 'completada'),
(2, '2024-01-16', 8200.00, 'completada');

INSERT INTO detalle_ventas VALUES
(1, 1, 1, 15000.00, 15000.00),  -- Laptop
(1, 2, 1, 500.00, 500.00),      -- Mouse
(2, 3, 1, 8000.00, 8000.00),    -- Sofá
(2, 4, 1, 200.00, 200.00);      -- Pelota
```

### Ejercicio 6: Crear Índices en Claves Foráneas
**Objetivo**: Optimizar rendimiento con índices.

```sql
-- Verificar índices existentes
SHOW INDEX FROM ventas;
SHOW INDEX FROM detalle_ventas;

-- Crear índices adicionales para optimizar consultas
CREATE INDEX idx_ventas_cliente_fecha ON ventas(cliente_id, fecha_venta);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_detalle_ventas_producto ON detalle_ventas(producto_id);
CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_productos_activo ON productos(activo);

-- Consulta optimizada con índices
EXPLAIN SELECT v.id, c.nombre, v.fecha_venta, v.total
FROM ventas v
JOIN clientes c ON v.cliente_id = c.id
WHERE v.estado = 'completada'
AND v.fecha_venta >= '2024-01-01';
```

### Ejercicio 7: Validar Integridad Referencial
**Objetivo**: Crear procedimiento para validar integridad.

```sql
-- Procedimiento para validar integridad referencial
DELIMITER //
CREATE PROCEDURE validar_integridad_referencial()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tabla_nombre VARCHAR(100);
    DECLARE cur CURSOR FOR 
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = DATABASE();
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Verificar claves foráneas huérfanas
    SELECT 'Verificando integridad referencial...' AS mensaje;
    
    -- Verificar ventas sin cliente válido
    SELECT COUNT(*) AS ventas_sin_cliente
    FROM ventas v
    LEFT JOIN clientes c ON v.cliente_id = c.id
    WHERE c.id IS NULL;
    
    -- Verificar detalles sin venta válida
    SELECT COUNT(*) AS detalles_sin_venta
    FROM detalle_ventas dv
    LEFT JOIN ventas v ON dv.venta_id = v.id
    WHERE v.id IS NULL;
    
    -- Verificar detalles sin producto válido
    SELECT COUNT(*) AS detalles_sin_producto
    FROM detalle_ventas dv
    LEFT JOIN productos p ON dv.producto_id = p.id
    WHERE p.id IS NULL;
    
    SELECT 'Validación completada' AS resultado;
END//
DELIMITER ;

-- Ejecutar validación
CALL validar_integridad_referencial();
```

### Ejercicio 8: Manejar Violaciones de Integridad
**Objetivo**: Crear triggers para mantener integridad.

```sql
-- Trigger para validar stock antes de venta
DELIMITER //
CREATE TRIGGER validar_stock_antes_venta
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    
    SELECT stock INTO stock_actual
    FROM productos
    WHERE id = NEW.producto_id;
    
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para el producto';
    END IF;
END//
DELIMITER ;

-- Trigger para actualizar stock después de venta
DELIMITER //
CREATE TRIGGER actualizar_stock_despues_venta
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.producto_id;
END//
DELIMITER ;

-- Trigger para restaurar stock al eliminar venta
DELIMITER //
CREATE TRIGGER restaurar_stock_eliminar_venta
AFTER DELETE ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock + OLD.cantidad
    WHERE id = OLD.producto_id;
END//
DELIMITER ;
```

### Ejercicio 9: Caso de Estudio Completo
**Objetivo**: Crear sistema completo de gestión de restaurante.

```sql
-- Crear base de datos completa
CREATE DATABASE restaurante_completo;
USE restaurante_completo;

-- Tabla de ubicaciones de mesas
CREATE TABLE ubicaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Tabla de mesas
CREATE TABLE mesas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero INT NOT NULL UNIQUE,
    capacidad INT NOT NULL,
    ubicacion_id INT,
    activa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ubicacion_id) REFERENCES ubicaciones(id) ON DELETE SET NULL
);

-- Tabla de categorías de platos
CREATE TABLE categorias_platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activa BOOLEAN DEFAULT TRUE
);

-- Tabla de platos
CREATE TABLE platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(8,2) NOT NULL,
    categoria_id INT,
    tiempo_preparacion INT, -- en minutos
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_platos(id) ON DELETE SET NULL
);

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de meseros
CREATE TABLE meseros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de reservas
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    mesa_id INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    hora_reserva TIME NOT NULL,
    numero_personas INT NOT NULL,
    estado ENUM('confirmada', 'cancelada', 'completada') DEFAULT 'confirmada',
    notas TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL,
    FOREIGN KEY (mesa_id) REFERENCES mesas(id) ON DELETE RESTRICT
);

-- Tabla de órdenes
CREATE TABLE ordenes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reserva_id INT,
    mesa_id INT NOT NULL,
    mesero_id INT,
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    estado ENUM('pendiente', 'preparando', 'lista', 'servida', 'pagada') DEFAULT 'pendiente',
    FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON DELETE SET NULL,
    FOREIGN KEY (mesa_id) REFERENCES mesas(id) ON DELETE RESTRICT,
    FOREIGN KEY (mesero_id) REFERENCES meseros(id) ON DELETE SET NULL
);

-- Tabla de detalle de órdenes
CREATE TABLE detalle_ordenes (
    orden_id INT,
    plato_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(8,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    notas TEXT,
    PRIMARY KEY (orden_id, plato_id),
    FOREIGN KEY (orden_id) REFERENCES ordenes(id) ON DELETE CASCADE,
    FOREIGN KEY (plato_id) REFERENCES platos(id) ON DELETE RESTRICT
);

-- Insertar datos de ejemplo
INSERT INTO ubicaciones (nombre, descripcion) VALUES
('Interior', 'Área interior del restaurante'),
('Exterior', 'Área exterior con vista al jardín'),
('Terraza', 'Terraza con vista panorámica');

INSERT INTO categorias_platos (nombre, descripcion) VALUES
('Entradas', 'Platos de entrada y aperitivos'),
('Platos Principales', 'Platos principales y especialidades'),
('Postres', 'Postres y dulces'),
('Bebidas', 'Bebidas y refrescos');

INSERT INTO mesas (numero, capacidad, ubicacion_id) VALUES
(1, 4, 1), (2, 2, 1), (3, 6, 1), (4, 4, 2), (5, 8, 3);

INSERT INTO platos (nombre, descripcion, precio, categoria_id, tiempo_preparacion) VALUES
('Ensalada César', 'Lechuga, crutones, parmesano', 120.00, 1, 10),
('Pizza Margherita', 'Tomate, mozzarella, albahaca', 180.00, 2, 20),
('Pasta Carbonara', 'Pasta con crema y panceta', 160.00, 2, 15),
('Tiramisú', 'Postre italiano con café', 90.00, 3, 5),
('Coca Cola', 'Bebida gaseosa', 25.00, 4, 1);

INSERT INTO clientes (nombre, apellido, telefono, email) VALUES
('Juan', 'Pérez', '555-1234', 'juan.perez@email.com'),
('María', 'García', '555-5678', 'maria.garcia@email.com');

INSERT INTO meseros (nombre, apellido, telefono) VALUES
('Carlos', 'López', '555-9999'),
('Ana', 'Martínez', '555-8888');

INSERT INTO reservas (cliente_id, mesa_id, fecha_reserva, hora_reserva, numero_personas) VALUES
(1, 1, '2024-01-15', '18:30:00', 4),
(2, 2, '2024-01-15', '19:00:00', 2);

INSERT INTO ordenes (reserva_id, mesa_id, mesero_id, total, estado) VALUES
(1, 1, 1, 485.00, 'pagada'),
(2, 2, 2, 205.00, 'servida');

INSERT INTO detalle_ordenes VALUES
(1, 1, 1, 120.00, 120.00, NULL),  -- Ensalada
(1, 2, 1, 180.00, 180.00, NULL),  -- Pizza
(1, 5, 4, 25.00, 100.00, NULL),   -- Bebidas
(1, 4, 1, 90.00, 90.00, NULL),    -- Postre
(2, 3, 1, 160.00, 160.00, NULL),  -- Pasta
(2, 5, 2, 25.00, 50.00, NULL),    -- Bebidas
(2, 4, 1, 90.00, 90.00, NULL);    -- Postre
```

### Ejercicio 10: Consultas con Relaciones
**Objetivo**: Realizar consultas complejas con JOINs.

```sql
-- Consulta 1: Órdenes con información completa
SELECT 
    o.id as orden_id,
    o.fecha_orden,
    m.numero as mesa,
    u.nombre as ubicacion,
    me.nombre as mesero,
    c.nombre as cliente,
    o.total,
    o.estado
FROM ordenes o
JOIN mesas m ON o.mesa_id = m.id
JOIN ubicaciones u ON m.ubicacion_id = u.id
LEFT JOIN meseros me ON o.mesero_id = me.id
LEFT JOIN reservas r ON o.reserva_id = r.id
LEFT JOIN clientes c ON r.cliente_id = c.id
ORDER BY o.fecha_orden DESC;

-- Consulta 2: Detalle de órdenes con información de platos
SELECT 
    do.orden_id,
    p.nombre as plato,
    cp.nombre as categoria,
    do.cantidad,
    do.precio_unitario,
    do.subtotal
FROM detalle_ordenes do
JOIN platos p ON do.plato_id = p.id
JOIN categorias_platos cp ON p.categoria_id = cp.id
ORDER BY do.orden_id, p.nombre;

-- Consulta 3: Resumen de ventas por categoría
SELECT 
    cp.nombre as categoria,
    COUNT(do.plato_id) as total_platos_vendidos,
    SUM(do.cantidad) as total_cantidad,
    SUM(do.subtotal) as total_ventas
FROM detalle_ordenes do
JOIN platos p ON do.plato_id = p.id
JOIN categorias_platos cp ON p.categoria_id = cp.id
GROUP BY cp.id, cp.nombre
ORDER BY total_ventas DESC;

-- Consulta 4: Meseros con sus ventas
SELECT 
    m.nombre as mesero,
    COUNT(o.id) as total_ordenes,
    SUM(o.total) as total_ventas,
    AVG(o.total) as promedio_venta
FROM meseros m
LEFT JOIN ordenes o ON m.id = o.mesero_id
WHERE o.estado = 'pagada'
GROUP BY m.id, m.nombre
ORDER BY total_ventas DESC;
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Relaciones**: Conexiones lógicas entre tablas
2. **Tipos de Relaciones**: 1:1, 1:N, N:N
3. **Claves Foráneas**: Referencias entre tablas
4. **Restricciones de Integridad**: RESTRICT, CASCADE, SET NULL
5. **Acciones de Cascada**: ON DELETE, ON UPDATE
6. **Índices**: Optimización de rendimiento

### Próximos Pasos:
- Aprender integridad referencial avanzada
- Estudiar triggers y procedimientos
- Practicar con casos complejos de relaciones

### Recursos Adicionales:
- Documentación sobre claves foráneas
- Herramientas de modelado de relaciones
- Casos de estudio de integridad referencial
