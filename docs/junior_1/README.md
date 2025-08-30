# 🔰 Junior Level 1: Introducción a SQL y Bases de Datos

## 📖 Teoría

### ¿Qué es SQL?
SQL (Structured Query Language) es un lenguaje estándar para acceder y manipular bases de datos relacionales. Es el lenguaje más utilizado para trabajar con bases de datos.

### ¿Qué es una Base de Datos?
Una base de datos es una colección organizada de información estructurada, almacenada electrónicamente en un sistema informático.

### Tipos de Bases de Datos Relacionales
- **MySQL**: Open source, muy popular para aplicaciones web
- **PostgreSQL**: Open source, muy robusto y con características avanzadas
- **SQL Server**: De Microsoft, muy usado en entornos empresariales
- **Oracle**: Muy potente, usado en grandes empresas
- **SQLite**: Ligera, perfecta para aplicaciones móviles y pequeñas

### Conceptos Básicos
- **Tabla**: Estructura que almacena datos organizados en filas y columnas
- **Fila (Registro)**: Cada entrada individual en una tabla
- **Columna (Campo)**: Cada tipo de dato en una tabla
- **Base de Datos**: Conjunto de tablas relacionadas

## 💡 Ejemplos Prácticos

### Ejemplo 1: Crear una Base de Datos
```sql
-- Crear una base de datos para una tienda
CREATE DATABASE tienda;
USE tienda;
```

### Ejemplo 2: Crear una Tabla
```sql
-- Crear tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0
);
```

### Ejemplo 3: Insertar Datos
```sql
-- Insertar productos en la tabla
INSERT INTO productos (nombre, precio, stock) VALUES
('Laptop HP', 899.99, 10),
('Mouse Inalámbrico', 25.50, 50),
('Teclado Mecánico', 89.99, 15);
```

### Ejemplo 4: Ver Datos
```sql
-- Ver todos los productos
SELECT * FROM productos;
```

### Ejemplo 5: Ver Estructura de la Tabla
```sql
-- Ver la estructura de la tabla productos
DESCRIBE productos;
```

## 🎯 Ejercicios

### Ejercicio 1: Crear Base de Datos de Biblioteca
Crea una base de datos llamada `biblioteca` y una tabla llamada `libros` con las siguientes columnas:
- id (número entero, clave primaria, auto-incremento)
- titulo (texto, máximo 200 caracteres, obligatorio)
- autor (texto, máximo 100 caracteres, obligatorio)
- año_publicacion (número entero)
- genero (texto, máximo 50 caracteres)

**Solución:**
```sql
CREATE DATABASE biblioteca;
USE biblioteca;

CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    año_publicacion INT,
    genero VARCHAR(50)
);
```

### Ejercicio 2: Crear Base de Datos de Escuela
Crea una base de datos llamada `escuela` y una tabla llamada `estudiantes` con:
- id (número entero, clave primaria, auto-incremento)
- nombre (texto, máximo 100 caracteres, obligatorio)
- apellido (texto, máximo 100 caracteres, obligatorio)
- edad (número entero)
- grado (número entero)

**Solución:**
```sql
CREATE DATABASE escuela;
USE escuela;

CREATE TABLE estudiantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    edad INT,
    grado INT
);
```

### Ejercicio 3: Crear Base de Datos de Restaurante
Crea una base de datos llamada `restaurante` y una tabla llamada `platos` con:
- id (número entero, clave primaria, auto-incremento)
- nombre (texto, máximo 150 caracteres, obligatorio)
- descripcion (texto, máximo 500 caracteres)
- precio (decimal con 2 decimales, obligatorio)
- categoria (texto, máximo 50 caracteres)

**Solución:**
```sql
CREATE DATABASE restaurante;
USE restaurante;

CREATE TABLE platos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500),
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50)
);
```

### Ejercicio 4: Crear Base de Datos de Hospital
Crea una base de datos llamada `hospital` y una tabla llamada `pacientes` con:
- id (número entero, clave primaria, auto-incremento)
- nombre (texto, máximo 100 caracteres, obligatorio)
- apellido (texto, máximo 100 caracteres, obligatorio)
- fecha_nacimiento (fecha)
- telefono (texto, máximo 20 caracteres)
- direccion (texto, máximo 200 caracteres)

**Solución:**
```sql
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
```

### Ejercicio 5: Crear Base de Datos de Gimnasio
Crea una base de datos llamada `gimnasio` y una tabla llamada `miembros` con:
- id (número entero, clave primaria, auto-incremento)
- nombre (texto, máximo 100 caracteres, obligatorio)
- apellido (texto, máximo 100 caracteres, obligatorio)
- email (texto, máximo 150 caracteres, único)
- fecha_inscripcion (fecha, por defecto fecha actual)
- plan_membresia (texto, máximo 50 caracteres)

**Solución:**
```sql
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
```

## 📝 Resumen de Conceptos Clave
- ✅ SQL es el lenguaje estándar para bases de datos relacionales
- ✅ Una base de datos contiene tablas organizadas
- ✅ Las tablas tienen filas (registros) y columnas (campos)
- ✅ CREATE DATABASE crea una nueva base de datos
- ✅ CREATE TABLE crea una nueva tabla con estructura definida
- ✅ INSERT INTO agrega datos a las tablas
- ✅ SELECT muestra datos de las tablas

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/junior_2` para aprender sobre consultas SELECT básicas.

---

**💡 Consejo: Practica creando diferentes bases de datos y tablas para familiarizarte con la sintaxis. ¡La práctica es la clave del aprendizaje!**
