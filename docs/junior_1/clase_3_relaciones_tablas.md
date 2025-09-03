# Clase 3: Relaciones entre Tablas - Diseño de Base de Datos

## 📚 Descripción de la Clase
En esta clase aprenderás cómo crear relaciones entre tablas en una base de datos. Comprenderás los diferentes tipos de relaciones, cómo implementarlas usando claves primarias y foráneas, y por qué son fundamentales para el diseño de bases de datos eficientes y sin redundancia.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son las relaciones entre tablas
- Identificar los diferentes tipos de relaciones (1:1, 1:N, N:N)
- Crear claves primarias y foráneas
- Diseñar bases de datos normalizadas
- Implementar integridad referencial
- Resolver problemas de redundancia de datos

## ⏱️ Duración Estimada
**3-4 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son las Relaciones entre Tablas?

Una **relación** es una conexión lógica entre dos tablas basada en datos comunes. Las relaciones permiten:
- **Eliminar redundancia**: Evitar duplicar información
- **Mantener integridad**: Asegurar consistencia de datos
- **Facilitar consultas**: Combinar información de múltiples tablas
- **Optimizar almacenamiento**: Usar el espacio de manera eficiente

### Analogía con el Mundo Real

Imagina una biblioteca:
- **Tabla "Libros"**: Información de cada libro (título, autor, ISBN)
- **Tabla "Autores"**: Información de cada autor (nombre, biografía, nacionalidad)
- **Relación**: Un autor puede escribir muchos libros, pero cada libro tiene un autor principal

### Tipos de Relaciones

#### 1. Relación Uno a Uno (1:1)
- **Descripción**: Cada registro de la tabla A se relaciona con exactamente un registro de la tabla B
- **Ejemplo**: Una persona tiene exactamente un pasaporte
- **Uso**: Cuando quieres separar información sensible o dividir tablas muy grandes

```sql
-- Ejemplo: Persona y Pasaporte (1:1)
CREATE TABLE personas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE
);

CREATE TABLE pasaportes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(20) UNIQUE NOT NULL,
    fecha_emision DATE,
    fecha_vencimiento DATE,
    persona_id INT UNIQUE,  -- UNIQUE asegura la relación 1:1
    FOREIGN KEY (persona_id) REFERENCES personas(id)
);
```

**Explicación línea por línea:**
- `persona_id INT UNIQUE`: 
  - `persona_id`: nombre de la columna que almacenará el ID de la persona
  - `INT`: tipo de dato entero
  - `UNIQUE`: restricción que asegura que cada persona solo puede tener un pasaporte
- `FOREIGN KEY (persona_id) REFERENCES personas(id)`:
  - `FOREIGN KEY`: define que persona_id es una clave foránea
  - `(persona_id)`: especifica la columna que es clave foránea
  - `REFERENCES personas(id)`: referencia a la columna id de la tabla personas

#### 2. Relación Uno a Muchos (1:N)
- **Descripción**: Un registro de la tabla A se relaciona con muchos registros de la tabla B
- **Ejemplo**: Un cliente puede tener muchos pedidos
- **Uso**: La relación más común en bases de datos

```sql
-- Ejemplo: Cliente y Pedidos (1:N)
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20)
);

CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    fecha_pedido DATE DEFAULT (CURRENT_DATE),
    total DECIMAL(10,2) NOT NULL,
    cliente_id INT NOT NULL,  -- Sin UNIQUE para permitir múltiples pedidos
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

**Explicación línea por línea:**
- `cliente_id INT NOT NULL`:
  - `cliente_id`: nombre de la columna que almacenará el ID del cliente
  - `INT`: tipo de dato entero
  - `NOT NULL`: el pedido debe tener un cliente asociado
  - (sin UNIQUE, permite que un cliente tenga múltiples pedidos)
- `FOREIGN KEY (cliente_id) REFERENCES clientes(id)`:
  - `FOREIGN KEY`: define que cliente_id es una clave foránea
  - `(cliente_id)`: especifica la columna que es clave foránea
  - `REFERENCES clientes(id)`: referencia a la columna id de la tabla clientes

#### 3. Relación Muchos a Muchos (N:N)
- **Descripción**: Muchos registros de la tabla A se relacionan con muchos registros de la tabla B
- **Ejemplo**: Un estudiante puede tomar muchos cursos, y un curso puede tener muchos estudiantes
- **Implementación**: Requiere una tabla intermedia (tabla de unión)

```sql
-- Ejemplo: Estudiantes y Cursos (N:N)
CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    creditos INT NOT NULL
);

-- Tabla intermedia para la relación N:N
CREATE TABLE inscripciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudiante_id INT NOT NULL,
    curso_id INT NOT NULL,
    fecha_inscripcion DATE DEFAULT (CURRENT_DATE),
    calificacion DECIMAL(3,1),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id),
    UNIQUE(estudiante_id, curso_id)  -- Evita inscripciones duplicadas
);
```

**Explicación línea por línea:**
- `estudiante_id INT NOT NULL`:
  - `estudiante_id`: ID del estudiante
  - `INT`: tipo de dato entero
  - `NOT NULL`: debe tener un estudiante asociado
- `curso_id INT NOT NULL`:
  - `curso_id`: ID del curso
  - `INT`: tipo de dato entero
  - `NOT NULL`: debe tener un curso asociado
- `fecha_inscripcion DATE DEFAULT (CURRENT_DATE)`:
  - `fecha_inscripcion`: fecha cuando se inscribió
  - `DATE`: tipo de dato fecha
  - `DEFAULT (CURRENT_DATE)`: fecha actual por defecto
- `calificacion DECIMAL(3,1)`:
  - `calificacion`: nota del estudiante en el curso
  - `DECIMAL(3,1)`: número decimal con 3 dígitos totales y 1 decimal
- `FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id)`:
  - Clave foránea que referencia a la tabla estudiantes
- `FOREIGN KEY (curso_id) REFERENCES cursos(id)`:
  - Clave foránea que referencia a la tabla cursos
- `UNIQUE(estudiante_id, curso_id)`:
  - Restricción que evita que un estudiante se inscriba dos veces al mismo curso

### Claves Primarias y Foráneas

#### Clave Primaria (Primary Key)
- **Definición**: Campo o conjunto de campos que identifica de manera única cada registro
- **Características**:
  - No puede ser NULL
  - Debe ser único
  - Solo puede haber una por tabla
  - Se crea automáticamente un índice

```sql
-- Ejemplo de clave primaria
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,  -- Clave primaria
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
);
```

#### Clave Foránea (Foreign Key)
- **Definición**: Campo que referencia a la clave primaria de otra tabla
- **Propósito**: Establecer relaciones entre tablas
- **Beneficios**:
  - Mantiene integridad referencial
  - Evita datos huérfanos
  - Facilita consultas entre tablas

```sql
-- Ejemplo de clave foránea
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    cliente_id INT NOT NULL,  -- Clave foránea
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

### Integridad Referencial

La **integridad referencial** asegura que las relaciones entre tablas sean consistentes. Incluye:

#### 1. Restricciones de Integridad
- **NOT NULL**: La clave foránea no puede estar vacía
- **UNIQUE**: Evita duplicados cuando es necesario
- **FOREIGN KEY**: Asegura que la referencia existe

#### 2. Acciones de Integridad Referencial
```sql
-- Ejemplo con acciones de integridad
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        ON DELETE CASCADE      -- Si se elimina el cliente, se eliminan sus pedidos
        ON UPDATE CASCADE      -- Si se actualiza el ID del cliente, se actualiza en pedidos
);
```

**Explicación línea por línea:**
- `ON DELETE CASCADE`:
  - `ON DELETE`: especifica qué hacer cuando se elimina el registro referenciado
  - `CASCADE`: elimina automáticamente los registros relacionados
- `ON UPDATE CASCADE`:
  - `ON UPDATE`: especifica qué hacer cuando se actualiza el registro referenciado
  - `CASCADE`: actualiza automáticamente las referencias

#### 3. Otras Acciones Disponibles
- **RESTRICT**: Impide la operación si hay registros relacionados
- **SET NULL**: Establece la clave foránea como NULL
- **NO ACTION**: No hace nada (comportamiento por defecto)

### Normalización de Bases de Datos

La **normalización** es el proceso de organizar los datos para reducir la redundancia y mejorar la integridad.

#### Problemas sin Normalización
```sql
-- Ejemplo de tabla NO normalizada (con redundancia)
CREATE TABLE pedidos_no_normalizados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    cliente_nombre VARCHAR(100) NOT NULL,      -- Redundante
    cliente_email VARCHAR(255) NOT NULL,       -- Redundante
    cliente_telefono VARCHAR(20),              -- Redundante
    producto_nombre VARCHAR(200) NOT NULL,     -- Redundante
    producto_precio DECIMAL(10,2) NOT NULL,    -- Redundante
    cantidad INT NOT NULL,
    fecha_pedido DATE DEFAULT (CURRENT_DATE)
);
```

**Problemas identificados:**
- **Redundancia**: Los datos del cliente se repiten en cada pedido
- **Inconsistencia**: Si cambia el email del cliente, hay que actualizar todos sus pedidos
- **Espacio**: Se desperdicia espacio almacenando datos repetidos
- **Mantenimiento**: Es difícil mantener la consistencia

#### Solución Normalizada
```sql
-- Tabla de clientes (normalizada)
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20)
);

-- Tabla de productos (normalizada)
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0
);

-- Tabla de pedidos (normalizada)
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    cliente_id INT NOT NULL,
    fecha_pedido DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabla de detalles de pedidos (normalizada)
CREATE TABLE detalles_pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);
```

**Beneficios de la normalización:**
- **Sin redundancia**: Cada dato se almacena una sola vez
- **Consistencia**: Los cambios se reflejan automáticamente
- **Eficiencia**: Menos espacio de almacenamiento
- **Mantenimiento**: Más fácil de mantener y actualizar

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Sistema de Biblioteca con Relaciones

```sql
-- Crear base de datos para biblioteca
CREATE DATABASE biblioteca_relacional;
USE biblioteca_relacional;

-- Tabla de autores
CREATE TABLE autores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    nacionalidad VARCHAR(50),
    biografia TEXT
);

-- Tabla de editoriales
CREATE TABLE editoriales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    email VARCHAR(255)
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Tabla de libros (con múltiples relaciones)
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    autor_id INT NOT NULL,           -- Relación 1:N con autores
    editorial_id INT NOT NULL,       -- Relación 1:N con editoriales
    categoria_id INT NOT NULL,       -- Relación 1:N con categorías
    año_publicacion INT,
    numero_paginas INT,
    precio DECIMAL(8,2),
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (autor_id) REFERENCES autores(id),
    FOREIGN KEY (editorial_id) REFERENCES editoriales(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);

-- Tabla de préstamos (relación N:N entre usuarios y libros)
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_prestamo DATE DEFAULT (CURRENT_DATE),
    fecha_devolucion_esperada DATE,
    fecha_devolucion_real DATE,
    devuelto BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (libro_id) REFERENCES libros(id),
    UNIQUE(usuario_id, libro_id, fecha_prestamo)  -- Evita préstamos duplicados
);
```

**Explicación de las relaciones:**

```sql
-- Relación 1:N entre autores y libros
-- Un autor puede escribir muchos libros, pero cada libro tiene un autor principal
autor_id INT NOT NULL,
FOREIGN KEY (autor_id) REFERENCES autores(id)

-- Relación 1:N entre editoriales y libros
-- Una editorial puede publicar muchos libros, pero cada libro tiene una editorial
editorial_id INT NOT NULL,
FOREIGN KEY (editorial_id) REFERENCES editoriales(id)

-- Relación 1:N entre categorías y libros
-- Una categoría puede contener muchos libros, pero cada libro pertenece a una categoría
categoria_id INT NOT NULL,
FOREIGN KEY (categoria_id) REFERENCES categorias(id)

-- Relación N:N entre usuarios y libros (a través de préstamos)
-- Un usuario puede pedir prestados muchos libros, y un libro puede ser prestado a muchos usuarios
usuario_id INT NOT NULL,
libro_id INT NOT NULL,
FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
FOREIGN KEY (libro_id) REFERENCES libros(id)
```

### Ejemplo 2: Insertar Datos con Relaciones

```sql
-- Insertar autores
INSERT INTO autores (nombre, apellido, fecha_nacimiento, nacionalidad) VALUES
('Gabriel', 'García Márquez', '1927-03-06', 'Colombiano'),
('Miguel', 'de Cervantes', '1547-09-29', 'Español'),
('George', 'Orwell', '1903-06-25', 'Británico');

-- Insertar editoriales
INSERT INTO editoriales (nombre, direccion, telefono, email) VALUES
('Cátedra', 'Calle Alcalá 95, Madrid', '915 31 22 00', 'info@catedra.com'),
('Debolsillo', 'Calle Torrelaguna 60, Madrid', '915 33 03 00', 'info@debolsillo.com'),
('Plaza & Janés', 'Calle Provenza 260, Barcelona', '934 88 00 00', 'info@plazayjanes.com');

-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Novela', 'Obras de ficción narrativa'),
('Ciencia Ficción', 'Obras de ficción con elementos científicos'),
('Realismo Mágico', 'Género literario que combina realidad y fantasía');

-- Insertar libros (con referencias a las tablas relacionadas)
INSERT INTO libros (isbn, titulo, autor_id, editorial_id, categoria_id, año_publicacion, numero_paginas, precio) VALUES
('978-84-376-0494-7', 'Cien años de soledad', 1, 1, 3, 1967, 471, 12.95),
('978-84-376-0495-4', 'El Quijote', 2, 1, 1, 1605, 863, 15.50),
('978-84-376-0496-1', '1984', 3, 2, 2, 1949, 326, 9.95);

-- Insertar usuarios
INSERT INTO usuarios (nombre, apellido, email, telefono) VALUES
('Ana', 'García', 'ana.garcia@email.com', '612345678'),
('Carlos', 'López', 'carlos.lopez@email.com', '623456789'),
('María', 'Rodríguez', 'maria.rodriguez@email.com', '634567890');

-- Insertar préstamos (relaciones N:N)
INSERT INTO prestamos (usuario_id, libro_id, fecha_prestamo, fecha_devolucion_esperada) VALUES
(1, 1, '2024-01-15', '2024-02-15'),  -- Ana presta "Cien años de soledad"
(2, 2, '2024-01-20', '2024-02-20'),  -- Carlos presta "El Quijote"
(3, 3, '2024-01-10', '2024-02-10'),  -- María presta "1984"
(1, 3, '2024-01-25', '2024-02-25');  -- Ana también presta "1984"
```

### Ejemplo 3: Consultas con Relaciones (JOIN)

```sql
-- Consulta 1: Ver libros con información de autor y editorial
SELECT 
    l.titulo,
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    e.nombre AS editorial,
    c.nombre AS categoria,
    l.año_publicacion,
    l.precio
FROM libros l
JOIN autores a ON l.autor_id = a.id
JOIN editoriales e ON l.editorial_id = e.id
JOIN categorias c ON l.categoria_id = c.id;

-- Explicación línea por línea:
-- SELECT: comando para consultar datos
-- l.titulo: título del libro (l es alias de libros)
-- CONCAT(a.nombre, ' ', a.apellido) AS autor: concatena nombre y apellido del autor
-- e.nombre AS editorial: nombre de la editorial
-- c.nombre AS categoria: nombre de la categoría
-- l.año_publicacion: año de publicación del libro
-- l.precio: precio del libro
-- FROM libros l: especifica la tabla principal (libros) con alias l
-- JOIN autores a ON l.autor_id = a.id: une con la tabla autores donde las claves coinciden
-- JOIN editoriales e ON l.editorial_id = e.id: une con la tabla editoriales
-- JOIN categorias c ON l.categoria_id = c.id: une con la tabla categorías

-- Consulta 2: Ver préstamos con información de usuario y libro
SELECT 
    p.id AS prestamo_id,
    CONCAT(u.nombre, ' ', u.apellido) AS usuario,
    l.titulo AS libro,
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    p.fecha_prestamo,
    p.fecha_devolucion_esperada,
    CASE WHEN p.devuelto THEN 'Devuelto' ELSE 'Pendiente' END AS estado
FROM prestamos p
JOIN usuarios u ON p.usuario_id = u.id
JOIN libros l ON p.libro_id = l.id
JOIN autores a ON l.autor_id = a.id;

-- Explicación línea por línea:
-- p.id AS prestamo_id: ID del préstamo con alias
-- CONCAT(u.nombre, ' ', u.apellido) AS usuario: nombre completo del usuario
-- l.titulo AS libro: título del libro
-- CONCAT(a.nombre, ' ', a.apellido) AS autor: nombre completo del autor
-- p.fecha_prestamo: fecha del préstamo
-- p.fecha_devolucion_esperada: fecha esperada de devolución
-- CASE WHEN p.devuelto THEN 'Devuelto' ELSE 'Pendiente' END AS estado: estado del préstamo
-- FROM prestamos p: tabla principal (préstamos) con alias p
-- JOIN usuarios u ON p.usuario_id = u.id: une con usuarios
-- JOIN libros l ON p.libro_id = l.id: une con libros
-- JOIN autores a ON l.autor_id = a.id: une con autores (a través de libros)

-- Consulta 3: Contar libros por categoría
SELECT 
    c.nombre AS categoria,
    COUNT(l.id) AS total_libros,
    AVG(l.precio) AS precio_promedio
FROM categorias c
LEFT JOIN libros l ON c.id = l.categoria_id
GROUP BY c.id, c.nombre;

-- Explicación línea por línea:
-- c.nombre AS categoria: nombre de la categoría
-- COUNT(l.id) AS total_libros: cuenta cuántos libros hay en cada categoría
-- AVG(l.precio) AS precio_promedio: calcula el precio promedio de los libros
-- FROM categorias c: tabla principal (categorías) con alias c
-- LEFT JOIN libros l ON c.id = l.categoria_id: une con libros (incluye categorías sin libros)
-- GROUP BY c.id, c.nombre: agrupa por categoría para hacer los cálculos
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Sistema de Tienda Online
**Objetivo**: Crear un sistema de tienda online con relaciones entre tablas.

**Instrucciones**:
Crea las siguientes tablas con sus relaciones:
1. **clientes**: id, nombre, email, telefono, direccion
2. **categorias**: id, nombre, descripcion
3. **productos**: id, nombre, descripcion, precio, stock, categoria_id
4. **pedidos**: id, numero_pedido, cliente_id, fecha_pedido, total
5. **detalles_pedidos**: id, pedido_id, producto_id, cantidad, precio_unitario

**Solución paso a paso:**

```sql
-- Paso 1: Crear base de datos
CREATE DATABASE tienda_online;
USE tienda_online;

-- Paso 2: Crear tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(200)
);

-- Explicación:
-- id INT PRIMARY KEY AUTO_INCREMENT: clave primaria auto-incremento
-- nombre VARCHAR(100) NOT NULL: nombre del cliente, obligatorio
-- email VARCHAR(255) UNIQUE NOT NULL: email único y obligatorio
-- telefono VARCHAR(20): teléfono opcional
-- direccion VARCHAR(200): dirección opcional

-- Paso 3: Crear tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT
);

-- Explicación:
-- id INT PRIMARY KEY AUTO_INCREMENT: clave primaria auto-incremento
-- nombre VARCHAR(50) NOT NULL: nombre de la categoría, obligatorio
-- descripcion TEXT: descripción opcional (texto largo)

-- Paso 4: Crear tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    categoria_id INT NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Explicación:
-- id INT PRIMARY KEY AUTO_INCREMENT: clave primaria auto-incremento
-- nombre VARCHAR(200) NOT NULL: nombre del producto, obligatorio
-- descripcion TEXT: descripción opcional
-- precio DECIMAL(10,2) NOT NULL CHECK (precio > 0): precio obligatorio y positivo
-- stock INT DEFAULT 0 CHECK (stock >= 0): stock con valor por defecto 0 y no negativo
-- categoria_id INT NOT NULL: ID de la categoría, obligatorio
-- FOREIGN KEY (categoria_id) REFERENCES categorias(id): clave foránea que referencia categorías

-- Paso 5: Crear tabla de pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    cliente_id INT NOT NULL,
    fecha_pedido DATE DEFAULT (CURRENT_DATE),
    total DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Explicación:
-- id INT PRIMARY KEY AUTO_INCREMENT: clave primaria auto-incremento
-- numero_pedido VARCHAR(20) UNIQUE NOT NULL: número único del pedido
-- cliente_id INT NOT NULL: ID del cliente, obligatorio
-- fecha_pedido DATE DEFAULT (CURRENT_DATE): fecha del pedido, actual por defecto
-- total DECIMAL(10,2) DEFAULT 0.00: total del pedido, 0 por defecto
-- FOREIGN KEY (cliente_id) REFERENCES clientes(id): clave foránea que referencia clientes

-- Paso 6: Crear tabla de detalles de pedidos
CREATE TABLE detalles_pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

-- Explicación:
-- id INT PRIMARY KEY AUTO_INCREMENT: clave primaria auto-incremento
-- pedido_id INT NOT NULL: ID del pedido, obligatorio
-- producto_id INT NOT NULL: ID del producto, obligatorio
-- cantidad INT NOT NULL CHECK (cantidad > 0): cantidad obligatoria y positiva
-- precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0): precio unitario obligatorio y positivo
-- FOREIGN KEY (pedido_id) REFERENCES pedidos(id): clave foránea que referencia pedidos
-- FOREIGN KEY (producto_id) REFERENCES productos(id): clave foránea que referencia productos
```

### Ejercicio 2: Insertar Datos con Relaciones
**Objetivo**: Practicar la inserción de datos en tablas relacionadas.

**Instrucciones**:
Inserta datos de ejemplo en todas las tablas, asegurándote de que las relaciones sean correctas.

**Solución paso a paso:**

```sql
-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Ropa', 'Vestimenta y accesorios de moda'),
('Hogar', 'Artículos para el hogar y decoración');

-- Insertar clientes
INSERT INTO clientes (nombre, email, telefono, direccion) VALUES
('Juan Pérez', 'juan.perez@email.com', '612345678', 'Calle Mayor 123, Madrid'),
('María García', 'maria.garcia@email.com', '623456789', 'Avenida de la Paz 45, Barcelona'),
('Carlos López', 'carlos.lopez@email.com', '634567890', 'Plaza España 12, Valencia');

-- Insertar productos
INSERT INTO productos (nombre, descripcion, precio, stock, categoria_id) VALUES
('iPhone 14', 'Smartphone Apple con cámara de 48MP', 999.99, 25, 1),
('Samsung Galaxy S23', 'Smartphone Android con pantalla AMOLED', 899.99, 30, 1),
('Camiseta Algodón', 'Camiseta 100% algodón, varios colores', 19.99, 100, 2),
('Pantalón Vaquero', 'Pantalón vaquero clásico, corte regular', 49.99, 50, 2),
('Lámpara LED', 'Lámpara LED de escritorio, luz blanca', 29.99, 75, 3),
('Cafetera Eléctrica', 'Cafetera automática con molinillo', 89.99, 20, 3);

-- Insertar pedidos
INSERT INTO pedidos (numero_pedido, cliente_id, fecha_pedido, total) VALUES
('PED-001', 1, '2024-01-15', 1019.98),
('PED-002', 2, '2024-01-16', 69.98),
('PED-003', 3, '2024-01-17', 119.98);

-- Insertar detalles de pedidos
INSERT INTO detalles_pedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
-- Detalles del pedido 1 (Juan Pérez)
(1, 1, 1, 999.99),  -- iPhone 14
(1, 3, 1, 19.99),   -- Camiseta Algodón

-- Detalles del pedido 2 (María García)
(2, 3, 2, 19.99),   -- 2 Camisetas Algodón
(2, 4, 1, 49.99),   -- 1 Pantalón Vaquero

-- Detalles del pedido 3 (Carlos López)
(3, 5, 2, 29.99),   -- 2 Lámparas LED
(3, 6, 1, 89.99);   -- 1 Cafetera Eléctrica
```

### Ejercicio 3: Consultas con Múltiples Relaciones
**Objetivo**: Practicar consultas que combinen información de múltiples tablas.

**Instrucciones**:
Crea consultas que muestren:
1. Todos los pedidos con información del cliente
2. Detalles de cada pedido con productos
3. Resumen de ventas por categoría

**Solución paso a paso:**

```sql
-- Consulta 1: Pedidos con información del cliente
SELECT 
    p.numero_pedido,
    c.nombre AS cliente,
    c.email,
    p.fecha_pedido,
    p.total
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
ORDER BY p.fecha_pedido DESC;

-- Explicación:
-- p.numero_pedido: número del pedido
-- c.nombre AS cliente: nombre del cliente
-- c.email: email del cliente
-- p.fecha_pedido: fecha del pedido
-- p.total: total del pedido
-- FROM pedidos p: tabla principal (pedidos) con alias p
-- JOIN clientes c ON p.cliente_id = c.id: une con clientes
-- ORDER BY p.fecha_pedido DESC: ordena por fecha descendente

-- Consulta 2: Detalles de pedidos con productos
SELECT 
    p.numero_pedido,
    c.nombre AS cliente,
    pr.nombre AS producto,
    cat.nombre AS categoria,
    dp.cantidad,
    dp.precio_unitario,
    (dp.cantidad * dp.precio_unitario) AS subtotal
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
JOIN detalles_pedidos dp ON p.id = dp.pedido_id
JOIN productos pr ON dp.producto_id = pr.id
JOIN categorias cat ON pr.categoria_id = cat.id
ORDER BY p.numero_pedido, pr.nombre;

-- Explicación:
-- p.numero_pedido: número del pedido
-- c.nombre AS cliente: nombre del cliente
-- pr.nombre AS producto: nombre del producto
-- cat.nombre AS categoria: nombre de la categoría
-- dp.cantidad: cantidad del producto
-- dp.precio_unitario: precio unitario
-- (dp.cantidad * dp.precio_unitario) AS subtotal: cálculo del subtotal
-- FROM pedidos p: tabla principal (pedidos)
-- JOIN clientes c ON p.cliente_id = c.id: une con clientes
-- JOIN detalles_pedidos dp ON p.id = dp.pedido_id: une con detalles de pedidos
-- JOIN productos pr ON dp.producto_id = pr.id: une con productos
-- JOIN categorias cat ON pr.categoria_id = cat.id: une con categorías
-- ORDER BY p.numero_pedido, pr.nombre: ordena por número de pedido y nombre de producto

-- Consulta 3: Resumen de ventas por categoría
SELECT 
    cat.nombre AS categoria,
    COUNT(DISTINCT p.id) AS total_pedidos,
    COUNT(dp.id) AS total_productos_vendidos,
    SUM(dp.cantidad) AS total_cantidad,
    SUM(dp.cantidad * dp.precio_unitario) AS total_ventas
FROM categorias cat
JOIN productos pr ON cat.id = pr.categoria_id
JOIN detalles_pedidos dp ON pr.id = dp.producto_id
JOIN pedidos p ON dp.pedido_id = p.id
GROUP BY cat.id, cat.nombre
ORDER BY total_ventas DESC;

-- Explicación:
-- cat.nombre AS categoria: nombre de la categoría
-- COUNT(DISTINCT p.id) AS total_pedidos: cuenta pedidos únicos por categoría
-- COUNT(dp.id) AS total_productos_vendidos: cuenta productos vendidos
-- SUM(dp.cantidad) AS total_cantidad: suma total de cantidades
-- SUM(dp.cantidad * dp.precio_unitario) AS total_ventas: suma total de ventas
-- FROM categorias cat: tabla principal (categorías)
-- JOIN productos pr ON cat.id = pr.categoria_id: une con productos
-- JOIN detalles_pedidos dp ON pr.id = dp.producto_id: une con detalles de pedidos
-- JOIN pedidos p ON dp.pedido_id = p.id: une con pedidos
-- GROUP BY cat.id, cat.nombre: agrupa por categoría
-- ORDER BY total_ventas DESC: ordena por ventas descendente
```

---

## 📝 Resumen de Conceptos Clave

### Tipos de Relaciones:
- **1:1 (Uno a Uno)**: Cada registro de A se relaciona con exactamente un registro de B
- **1:N (Uno a Muchos)**: Un registro de A se relaciona con muchos registros de B
- **N:N (Muchos a Muchos)**: Muchos registros de A se relacionan con muchos registros de B

### Claves:
- **Clave Primaria**: Identificador único de cada registro
- **Clave Foránea**: Referencia a la clave primaria de otra tabla

### Integridad Referencial:
- **ON DELETE CASCADE**: Elimina registros relacionados automáticamente
- **ON UPDATE CASCADE**: Actualiza referencias automáticamente
- **RESTRICT**: Impide operaciones si hay registros relacionados
- **SET NULL**: Establece la clave foránea como NULL

### Normalización:
- **Elimina redundancia**: Cada dato se almacena una sola vez
- **Mantiene consistencia**: Los cambios se reflejan automáticamente
- **Optimiza espacio**: Usa el almacenamiento de manera eficiente
- **Facilita mantenimiento**: Más fácil de actualizar y mantener

### Comandos Aprendidos:
- **FOREIGN KEY**: Define claves foráneas
- **REFERENCES**: Especifica la tabla y columna referenciada
- **JOIN**: Une tablas en consultas
- **UNIQUE**: Evita duplicados en relaciones 1:1

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Operaciones CRUD básicas (INSERT, SELECT, UPDATE, DELETE)
- Cómo insertar, consultar, actualizar y eliminar datos
- Mejores prácticas para operaciones de datos

---

## 💡 Consejos para el Éxito

1. **Diseña primero**: Planifica las relaciones antes de crear las tablas
2. **Usa nombres descriptivos**: Para tablas, columnas y relaciones
3. **Mantén la integridad**: Usa claves foráneas y restricciones
4. **Normaliza apropiadamente**: Evita redundancia pero no sobre-normalices
5. **Documenta las relaciones**: Comenta por qué existen las relaciones

---

## 🧭 Navegación

**← Anterior**: [Clase 2: Tipos de Datos y Restricciones](clase_2_tipos_datos_restricciones.md)  
**Siguiente →**: [Clase 4: Operaciones Básicas CRUD](clase_4_operaciones_basicas.md)

---

*¡Excelente trabajo! Ahora entiendes cómo diseñar bases de datos con relaciones. 🚀*
