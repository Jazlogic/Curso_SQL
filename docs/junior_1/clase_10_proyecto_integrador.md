# Clase 10: Proyecto Integrador - Sistema de Gestión de Biblioteca

## 📚 Descripción de la Clase
En esta clase aplicarás todos los conceptos aprendidos en el módulo para crear un sistema completo de gestión de biblioteca. Este proyecto integrador te permitirá consolidar tus conocimientos de SQL, desde la creación de bases de datos hasta consultas avanzadas.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Diseñar y crear una base de datos completa
- Aplicar todos los conceptos de SQL aprendidos
- Crear consultas complejas y útiles
- Implementar un sistema funcional de gestión
- Documentar y presentar tu proyecto

## ⏱️ Duración Estimada
**4-5 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### Diseño del Sistema de Biblioteca

El sistema de gestión de biblioteca incluirá:
- **Libros**: Información de títulos, autores, categorías
- **Usuarios**: Datos de miembros de la biblioteca
- **Préstamos**: Registro de libros prestados
- **Categorías**: Clasificación de libros
- **Autores**: Información de escritores

### Estructura de la Base de Datos

```sql
-- Crear base de datos
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
```

---

## 💻 Implementación del Sistema

### Paso 1: Crear la Base de Datos

```sql
-- Crear base de datos
CREATE DATABASE biblioteca_sistema;
USE biblioteca_sistema;

-- Crear todas las tablas
-- (Código de creación de tablas del contenido teórico)
```

### Paso 2: Insertar Datos de Ejemplo

```sql
-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Ficción', 'Novelas y cuentos de ficción'),
('Ciencia', 'Libros de ciencias exactas y naturales'),
('Historia', 'Libros de historia universal y local'),
('Tecnología', 'Libros de programación y tecnología'),
('Filosofía', 'Libros de pensamiento filosófico'),
('Arte', 'Libros de arte y diseño');

-- Insertar autores
INSERT INTO autores (nombre, apellido, fecha_nacimiento, nacionalidad, biografia) VALUES
('Gabriel', 'García Márquez', '1927-03-06', 'Colombiana', 'Premio Nobel de Literatura 1982'),
('Isaac', 'Asimov', '1920-01-02', 'Estadounidense', 'Escritor de ciencia ficción y divulgación científica'),
('Yuval', 'Harari', '1976-02-24', 'Israelí', 'Historiador y filósofo especializado en historia mundial'),
('Robert', 'Martin', '1952-12-05', 'Estadounidense', 'Desarrollador de software y autor de Clean Code'),
('Platón', 'Atenas', '0428-01-01', 'Griega', 'Filósofo griego, discípulo de Sócrates'),
('Leonardo', 'da Vinci', '1452-04-15', 'Italiana', 'Polímata del Renacimiento italiano');

-- Insertar libros
INSERT INTO libros (titulo, isbn, categoria_id, autor_id, año_publicacion, editorial, paginas, precio, stock) VALUES
('Cien años de soledad', '978-84-376-0494-7', 1, 1, 1967, 'Editorial Sudamericana', 471, 15.99, 3),
('Fundación', '978-84-376-0495-4', 1, 2, 1951, 'Gnome Press', 244, 12.99, 2),
('Sapiens', '978-84-376-0496-1', 3, 3, 2011, 'Harper', 443, 18.99, 4),
('Clean Code', '978-84-376-0497-8', 4, 4, 2008, 'Prentice Hall', 464, 25.99, 2),
('La República', '978-84-376-0498-5', 5, 5, -380, 'Ediciones Clásicas', 416, 14.99, 1),
('Tratado de la pintura', '978-84-376-0499-2', 6, 6, 1651, 'Editorial Arte', 320, 22.99, 1);

-- Insertar usuarios
INSERT INTO usuarios (nombre, apellido, email, telefono, direccion, fecha_nacimiento) VALUES
('Ana', 'García', 'ana.garcia@email.com', '555-0101', 'Calle Mayor 123, Madrid', '1990-05-15'),
('Carlos', 'López', 'carlos.lopez@email.com', '555-0102', 'Avenida Libertad 456, Barcelona', '1985-08-22'),
('María', 'Rodríguez', 'maria.rodriguez@email.com', '555-0103', 'Plaza España 789, Valencia', '1992-12-03'),
('José', 'Martín', 'jose.martin@email.com', '555-0104', 'Calle Sol 321, Sevilla', '1988-03-18'),
('Laura', 'Sánchez', 'laura.sanchez@email.com', '555-0105', 'Avenida Paz 654, Bilbao', '1995-07-25');

-- Insertar préstamos
INSERT INTO prestamos (libro_id, usuario_id, fecha_devolucion_esperada, estado) VALUES
(1, 1, '2024-02-15', 'devuelto'),
(2, 2, '2024-02-20', 'activo'),
(3, 3, '2024-02-18', 'activo'),
(4, 1, '2024-02-25', 'activo'),
(5, 4, '2024-02-12', 'vencido');
```

### Paso 3: Crear Índices para Optimización

```sql
-- Índices para optimizar consultas
CREATE INDEX idx_libros_titulo ON libros (titulo);
CREATE INDEX idx_libros_categoria ON libros (categoria_id);
CREATE INDEX idx_libros_autor ON libros (autor_id);
CREATE INDEX idx_libros_disponible ON libros (disponible);
CREATE INDEX idx_prestamos_usuario ON prestamos (usuario_id);
CREATE INDEX idx_prestamos_libro ON prestamos (libro_id);
CREATE INDEX idx_prestamos_estado ON prestamos (estado);
CREATE INDEX idx_prestamos_fecha ON prestamos (fecha_prestamo);
```

---

## 🎯 Consultas del Sistema

### Consulta 1: Libros Disponibles por Categoría

```sql
SELECT 
    c.nombre AS categoria,
    COUNT(l.id) AS total_libros,
    COUNT(CASE WHEN l.disponible = TRUE THEN 1 END) AS libros_disponibles
FROM categorias c
LEFT JOIN libros l ON c.id = l.categoria_id
GROUP BY c.id, c.nombre
ORDER BY total_libros DESC;
```

### Consulta 2: Top 5 Autores Más Populares

```sql
SELECT 
    CONCAT(a.nombre, ' ', a.apellido) AS autor,
    COUNT(l.id) AS total_libros,
    SUM(l.stock) AS total_ejemplares
FROM autores a
LEFT JOIN libros l ON a.id = l.autor_id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY total_libros DESC
LIMIT 5;
```

### Consulta 3: Usuarios con Préstamos Activos

```sql
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
```

### Consulta 4: Libros Más Prestados

```sql
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
```

### Consulta 5: Reporte de Préstamos por Mes

```sql
SELECT 
    YEAR(fecha_prestamo) AS año,
    MONTH(fecha_prestamo) AS mes,
    COUNT(*) AS total_prestamos,
    COUNT(CASE WHEN estado = 'devuelto' THEN 1 END) AS devueltos,
    COUNT(CASE WHEN estado = 'vencido' THEN 1 END) AS vencidos
FROM prestamos
GROUP BY YEAR(fecha_prestamo), MONTH(fecha_prestamo)
ORDER BY año DESC, mes DESC;
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Gestión de Libros
**Objetivo**: Crear consultas para gestionar el catálogo de libros.

**Instrucciones**:
1. Buscar libros por título
2. Listar libros por categoría
3. Mostrar libros de un autor específico
4. Encontrar libros disponibles

### Ejercicio 2: Gestión de Usuarios
**Objetivo**: Crear consultas para gestionar usuarios.

**Instrucciones**:
1. Buscar usuarios por nombre
2. Listar usuarios activos
3. Mostrar usuarios con préstamos
4. Encontrar usuarios por email

### Ejercicio 3: Gestión de Préstamos
**Objetivo**: Crear consultas para gestionar préstamos.

**Instrucciones**:
1. Mostrar préstamos activos
2. Listar préstamos vencidos
3. Calcular multas
4. Generar reportes de préstamos

### Ejercicio 4: Reportes y Estadísticas
**Objetivo**: Crear consultas para generar reportes.

**Instrucciones**:
1. Estadísticas por categoría
2. Top autores más populares
3. Usuarios más activos
4. Libros más prestados

### Ejercicio 5: Optimización y Mantenimiento
**Objetivo**: Optimizar el sistema.

**Instrucciones**:
1. Crear índices apropiados
2. Analizar consultas con EXPLAIN
3. Optimizar consultas lentas
4. Documentar el sistema

---

## 📝 Resumen del Proyecto

### Lo que has aprendido:
- **Diseño de base de datos**: Crear estructura completa
- **Relaciones**: Implementar claves foráneas
- **Consultas complejas**: JOINs, agregaciones, subconsultas
- **Optimización**: Índices y análisis de rendimiento
- **Documentación**: Explicar cada parte del sistema

### Habilidades desarrolladas:
- **Pensamiento lógico**: Diseñar soluciones completas
- **Resolución de problemas**: Implementar funcionalidades
- **Análisis de datos**: Crear reportes útiles
- **Optimización**: Mejorar rendimiento
- **Comunicación**: Documentar y explicar

---

## 🚀 Próximos Pasos

En el siguiente módulo aprenderás:
- Consultas avanzadas con JOINs
- Subconsultas y consultas anidadas
- Funciones de ventana
- Triggers y procedimientos almacenados

---

## 💡 Consejos para el Éxito

1. **Practica regularmente**: Repite los ejercicios
2. **Experimenta**: Modifica las consultas
3. **Documenta**: Explica lo que haces
4. **Optimiza**: Busca mejorar el rendimiento
5. **Comparte**: Enseña a otros lo que aprendes

---

## 🧭 Navegación

**← Anterior**: [Clase 9: Índices y Optimización Básica](clase_9_indices_optimizacion.md)  
**Siguiente →**: [Módulo 2: Consultas Avanzadas](../junior_2/README.md)

---

*¡Felicitaciones! Has completado el Módulo 1 de SQL. 🎉*
