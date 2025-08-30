# 🔶 Mid-Level 1: JOINs y Relaciones entre Tablas

## 📖 Teoría

### ¿Qué son los JOINs?
Los JOINs son operaciones que combinan filas de dos o más tablas basándose en una condición de relación entre ellas. Son fundamentales para consultas que requieren datos de múltiples tablas.

### Tipos de JOINs
1. **INNER JOIN**: Retorna solo las filas que tienen coincidencias en ambas tablas
2. **LEFT JOIN**: Retorna todas las filas de la tabla izquierda y las coincidencias de la derecha
3. **RIGHT JOIN**: Retorna todas las filas de la tabla derecha y las coincidencias de la izquierda
4. **FULL JOIN**: Retorna todas las filas de ambas tablas (no disponible en MySQL)
5. **CROSS JOIN**: Producto cartesiano de ambas tablas

### Sintaxis Básica
```sql
SELECT columnas
FROM tabla1
JOIN tabla2 ON tabla1.columna = tabla2.columna;
```

### Relaciones entre Tablas
- **Clave Primaria (PK)**: Identifica únicamente cada fila
- **Clave Foránea (FK)**: Referencia a la clave primaria de otra tabla
- **Relación 1:1**: Una fila de A se relaciona con una fila de B
- **Relación 1:N**: Una fila de A se relaciona con múltiples filas de B
- **Relación N:M**: Múltiples filas de A se relacionan con múltiples filas de B

## 💡 Ejemplos Prácticos

### Ejemplo 1: INNER JOIN Básico
```sql
-- Unir productos con sus categorías
SELECT p.nombre, p.precio, c.nombre_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;
```

### Ejemplo 2: LEFT JOIN
```sql
-- Mostrar todos los clientes y sus pedidos (si los tienen)
SELECT c.nombre, c.apellido, p.fecha_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;
```

### Ejemplo 3: Múltiples JOINs
```sql
-- Unir clientes, pedidos y productos
SELECT c.nombre, p.fecha_pedido, pr.nombre_producto
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
INNER JOIN productos_pedido pp ON p.id = pp.pedido_id
INNER JOIN productos pr ON pp.producto_id = pr.id;
```

### Ejemplo 4: JOIN con Condiciones
```sql
-- Productos con categoría y stock mayor a 10
SELECT p.nombre, p.precio, c.nombre_categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.stock > 10;
```

### Ejemplo 5: JOIN con Alias
```sql
-- Usar alias para tablas y columnas
SELECT 
    e.nombre AS 'Nombre Estudiante',
    c.nombre AS 'Nombre Curso',
    p.nota AS 'Calificación'
FROM estudiantes e
INNER JOIN cursos_estudiantes ce ON e.id = ce.estudiante_id
INNER JOIN cursos c ON ce.curso_id = c.id
INNER JOIN progreso p ON e.id = p.estudiante_id;
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Tienda Online
Crea las siguientes tablas y realiza consultas con JOINs:

**Tablas:**
```sql
-- Crear base de datos
CREATE DATABASE tienda_online;
USE tienda_online;

-- Tabla de categorías
CREATE TABLE categorias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Tabla de clientes
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    fecha_registro DATE DEFAULT CURRENT_DATE
);

-- Tabla de pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    estado VARCHAR(50) DEFAULT 'Pendiente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabla de productos en pedidos
CREATE TABLE productos_pedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);
```

**Consultas con JOINs:**
1. Mostrar todos los productos con su categoría
2. Mostrar todos los clientes y sus pedidos (incluyendo clientes sin pedidos)
3. Mostrar pedidos con información del cliente y productos
4. Mostrar productos que nunca han sido pedidos
5. Calcular el total de ventas por categoría

**Solución:**
```sql
-- 1. Productos con categoría
SELECT p.nombre, p.precio, c.nombre AS categoria
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- 2. Clientes y pedidos (LEFT JOIN)
SELECT c.nombre, c.apellido, p.fecha_pedido, p.total
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id;

-- 3. Pedidos completos
SELECT 
    c.nombre, c.apellido,
    p.fecha_pedido, p.total,
    pr.nombre AS producto, pp.cantidad
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.id
INNER JOIN productos_pedido pp ON p.id = pp.pedido_id
INNER JOIN productos pr ON pp.producto_id = pr.id;

-- 4. Productos nunca pedidos
SELECT p.nombre, p.precio
FROM productos p
LEFT JOIN productos_pedido pp ON p.id = pp.producto_id
WHERE pp.id IS NULL;

-- 5. Total de ventas por categoría
SELECT 
    c.nombre AS categoria,
    SUM(pp.cantidad * pp.precio_unitario) AS total_ventas
FROM categorias c
INNER JOIN productos p ON c.id = p.categoria_id
INNER JOIN productos_pedido pp ON p.id = pp.producto_id
GROUP BY c.id, c.nombre;
```

### Ejercicio 2: Sistema de Biblioteca
Crea las siguientes tablas y realiza consultas con JOINs:

**Tablas:**
```sql
-- Crear base de datos
CREATE DATABASE biblioteca_completa;
USE biblioteca_completa;

-- Tabla de autores
CREATE TABLE autores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    pais VARCHAR(100),
    fecha_nacimiento DATE
);

-- Tabla de libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    autor_id INT,
    isbn VARCHAR(13) UNIQUE,
    año_publicacion INT,
    genero VARCHAR(100),
    FOREIGN KEY (autor_id) REFERENCES autores(id)
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    fecha_registro DATE DEFAULT CURRENT_DATE
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT,
    libro_id INT,
    fecha_prestamo DATE DEFAULT CURRENT_DATE,
    fecha_devolucion DATE,
    estado VARCHAR(50) DEFAULT 'Prestado',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (libro_id) REFERENCES libros(id)
);
```

**Consultas con JOINs:**
1. Mostrar todos los libros con información del autor
2. Mostrar usuarios y libros que han prestado
3. Mostrar libros que nunca han sido prestados
4. Mostrar préstamos vencidos (más de 30 días)
5. Calcular cuántos libros ha prestado cada usuario

**Solución:**
```sql
-- 1. Libros con autor
SELECT l.titulo, l.isbn, l.genero,
       CONCAT(a.nombre, ' ', a.apellido) AS autor
FROM libros l
INNER JOIN autores a ON l.autor_id = a.id;

-- 2. Usuarios y préstamos
SELECT u.nombre, u.apellido, l.titulo, p.fecha_prestamo
FROM usuarios u
LEFT JOIN prestamos p ON u.id = p.usuario_id
LEFT JOIN libros l ON p.libro_id = l.id;

-- 3. Libros nunca prestados
SELECT l.titulo, l.isbn
FROM libros l
LEFT JOIN prestamos p ON l.id = p.libro_id
WHERE p.id IS NULL;

-- 4. Préstamos vencidos
SELECT 
    u.nombre, u.apellido,
    l.titulo,
    p.fecha_prestamo,
    DATEDIFF(CURDATE(), p.fecha_prestamo) AS dias_vencido
FROM prestamos p
INNER JOIN usuarios u ON p.usuario_id = u.id
INNER JOIN libros l ON p.libro_id = l.id
WHERE DATEDIFF(CURDATE(), p.fecha_prestamo) > 30;

-- 5. Conteo de préstamos por usuario
SELECT 
    u.nombre, u.apellido,
    COUNT(p.id) AS total_prestamos
FROM usuarios u
LEFT JOIN prestamos p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.apellido;
```

### Ejercicio 3: Sistema de Escuela
Crea las siguientes tablas y realiza consultas con JOINs:

**Tablas:**
```sql
-- Crear base de datos
CREATE DATABASE escuela_completa;
USE escuela_completa;

-- Tabla de profesores
CREATE TABLE profesores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    email VARCHAR(150) UNIQUE
);

-- Tabla de cursos
CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    profesor_id INT,
    creditos INT DEFAULT 3,
    horario VARCHAR(100),
    FOREIGN KEY (profesor_id) REFERENCES profesores(id)
);

-- Tabla de estudiantes
CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    grado INT,
    email VARCHAR(150) UNIQUE
);

-- Tabla de inscripciones
CREATE TABLE inscripciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudiante_id INT,
    curso_id INT,
    fecha_inscripcion DATE DEFAULT CURRENT_DATE,
    calificacion DECIMAL(3,2),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
);
```

**Consultas con JOINs:**
1. Mostrar todos los cursos con información del profesor
2. Mostrar estudiantes y cursos en los que están inscritos
3. Mostrar cursos sin estudiantes inscritos
4. Mostrar calificaciones de todos los estudiantes
5. Calcular el promedio de calificaciones por curso

**Solución:**
```sql
-- 1. Cursos con profesor
SELECT c.nombre, c.creditos, c.horario,
       CONCAT(p.nombre, ' ', p.apellido) AS profesor
FROM cursos c
INNER JOIN profesores p ON c.profesor_id = p.id;

-- 2. Estudiantes y cursos
SELECT 
    e.nombre, e.apellido, e.grado,
    c.nombre AS curso, i.calificacion
FROM estudiantes e
LEFT JOIN inscripciones i ON e.id = i.estudiante_id
LEFT JOIN cursos c ON i.curso_id = c.id;

-- 3. Cursos sin estudiantes
SELECT c.nombre, c.creditos
FROM cursos c
LEFT JOIN inscripciones i ON c.id = i.curso_id
WHERE i.id IS NULL;

-- 4. Calificaciones completas
SELECT 
    e.nombre, e.apellido,
    c.nombre AS curso,
    i.calificacion,
    p.nombre AS profesor
FROM inscripciones i
INNER JOIN estudiantes e ON i.estudiante_id = e.id
INNER JOIN cursos c ON i.curso_id = c.id
INNER JOIN profesores p ON c.profesor_id = p.id;

-- 5. Promedio por curso
SELECT 
    c.nombre AS curso,
    ROUND(AVG(i.calificacion), 2) AS promedio_calificaciones,
    COUNT(i.estudiante_id) AS total_estudiantes
FROM cursos c
LEFT JOIN inscripciones i ON c.id = i.curso_id
GROUP BY c.id, c.nombre;
```

### Ejercicio 4: Sistema de Restaurante
Crea las siguientes tablas y realiza consultas con JOINs:

**Tablas:**
```sql
-- Crear base de datos
CREATE DATABASE restaurante_completo;
USE restaurante_completo;

-- Tabla de categorías de platos
CREATE TABLE categorias_platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de platos
CREATE TABLE platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    categoria_id INT,
    precio DECIMAL(10,2) NOT NULL,
    descripcion TEXT,
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias_platos(id)
);

-- Tabla de mesas
CREATE TABLE mesas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero INT UNIQUE NOT NULL,
    capacidad INT DEFAULT 4,
    estado VARCHAR(50) DEFAULT 'Libre'
);

-- Tabla de pedidos
CREATE TABLE pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mesa_id INT,
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    estado VARCHAR(50) DEFAULT 'Activo',
    FOREIGN KEY (mesa_id) REFERENCES mesas(id)
);

-- Tabla de platos en pedidos
CREATE TABLE platos_pedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    plato_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2),
    notas TEXT,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (plato_id) REFERENCES platos(id)
);
```

**Consultas con JOINs:**
1. Mostrar todos los platos con su categoría
2. Mostrar mesas y pedidos activos
3. Mostrar platos que nunca han sido pedidos
4. Mostrar pedidos con información completa de mesa y platos
5. Calcular el total de ventas por categoría de plato

**Solución:**
```sql
-- 1. Platos con categoría
SELECT p.nombre, p.precio, c.nombre AS categoria
FROM platos p
INNER JOIN categorias_platos c ON p.categoria_id = c.id;

-- 2. Mesas y pedidos
SELECT m.numero, m.capacidad, p.fecha_pedido, p.total
FROM mesas m
LEFT JOIN pedidos p ON m.id = p.mesa_id AND p.estado = 'Activo';

-- 3. Platos nunca pedidos
SELECT p.nombre, p.precio
FROM platos p
LEFT JOIN platos_pedido pp ON p.id = pp.plato_id
WHERE pp.id IS NULL;

-- 4. Pedidos completos
SELECT 
    m.numero AS mesa,
    p.fecha_pedido,
    pl.nombre AS plato,
    pp.cantidad,
    pp.precio_unitario
FROM pedidos p
INNER JOIN mesas m ON p.mesa_id = m.id
INNER JOIN platos_pedido pp ON p.id = pp.pedido_id
INNER JOIN platos pl ON pp.plato_id = pl.id;

-- 5. Total de ventas por categoría
SELECT 
    c.nombre AS categoria,
    SUM(pp.cantidad * pp.precio_unitario) AS total_ventas
FROM categorias_platos c
INNER JOIN platos p ON c.id = p.categoria_id
INNER JOIN platos_pedido pp ON p.id = pp.plato_id
GROUP BY c.id, c.nombre;
```

### Ejercicio 5: Sistema de Hospital
Crea las siguientes tablas y realiza consultas con JOINs:

**Tablas:**
```sql
-- Crear base de datos
CREATE DATABASE hospital_completo;
USE hospital_completo;

-- Tabla de doctores
CREATE TABLE doctores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    licencia VARCHAR(50) UNIQUE
);

-- Tabla de pacientes
CREATE TABLE pacientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    direccion TEXT
);

-- Tabla de citas
CREATE TABLE citas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paciente_id INT,
    doctor_id INT,
    fecha_cita DATETIME,
    motivo TEXT,
    estado VARCHAR(50) DEFAULT 'Programada',
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id),
    FOREIGN KEY (doctor_id) REFERENCES doctores(id)
);

-- Tabla de tratamientos
CREATE TABLE tratamientos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    costo DECIMAL(10,2)
);

-- Tabla de tratamientos aplicados
CREATE TABLE tratamientos_aplicados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cita_id INT,
    tratamiento_id INT,
    fecha_aplicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    notas TEXT,
    FOREIGN KEY (cita_id) REFERENCES citas(id),
    FOREIGN KEY (tratamiento_id) REFERENCES tratamientos(id)
);
```

**Consultas con JOINs:**
1. Mostrar todas las citas con información del paciente y doctor
2. Mostrar doctores y sus citas programadas
3. Mostrar tratamientos que nunca han sido aplicados
4. Mostrar citas con tratamientos aplicados
5. Calcular el total de costos por especialidad médica

**Solución:**
```sql
-- 1. Citas completas
SELECT 
    c.fecha_cita,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente,
    CONCAT(d.nombre, ' ', d.apellido) AS doctor,
    d.especialidad
FROM citas c
INNER JOIN pacientes p ON c.paciente_id = p.id
INNER JOIN doctores d ON c.doctor_id = d.id;

-- 2. Doctores y citas
SELECT 
    d.nombre, d.apellido, d.especialidad,
    c.fecha_cita, c.motivo
FROM doctores d
LEFT JOIN citas c ON d.id = c.doctor_id AND c.estado = 'Programada';

-- 3. Tratamientos nunca aplicados
SELECT t.nombre, t.descripcion
FROM tratamientos t
LEFT JOIN tratamientos_aplicados ta ON t.id = ta.tratamiento_id
WHERE ta.id IS NULL;

-- 4. Citas con tratamientos
SELECT 
    c.fecha_cita,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente,
    t.nombre AS tratamiento,
    ta.fecha_aplicacion
FROM citas c
INNER JOIN pacientes p ON c.paciente_id = p.id
INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id;

-- 5. Total de costos por especialidad
SELECT 
    d.especialidad,
    SUM(t.costo) AS total_costos
FROM doctores d
INNER JOIN citas c ON d.id = c.doctor_id
INNER JOIN tratamientos_aplicados ta ON c.id = ta.cita_id
INNER JOIN tratamientos t ON ta.tratamiento_id = t.id
GROUP BY d.especialidad;
```

## 📝 Resumen de Conceptos Clave
- ✅ INNER JOIN retorna solo filas con coincidencias en ambas tablas
- ✅ LEFT JOIN retorna todas las filas de la tabla izquierda
- ✅ RIGHT JOIN retorna todas las filas de la tabla derecha
- ✅ Los JOINs se basan en relaciones entre claves primarias y foráneas
- ✅ Puedes usar múltiples JOINs en una sola consulta
- ✅ Los alias de tabla hacen las consultas más legibles
- ✅ Los JOINs son fundamentales para consultas complejas

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/midLevel_2` para aprender sobre subconsultas y consultas anidadas.

---

**💡 Consejo: Practica creando diferentes escenarios de bases de datos. Los JOINs son la base para consultas complejas y reportes empresariales.**
