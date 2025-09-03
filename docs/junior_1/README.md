# Módulo 1: Introducción a SQL y Bases de Datos - Nivel Junior

## Descripción
Módulo introductorio que cubre los conceptos fundamentales de SQL y bases de datos, incluyendo la creación de bases de datos, tablas, tipos de datos básicos, y operaciones fundamentales de inserción y consulta.

## Objetivos del Módulo
- Comprender qué es SQL y su importancia
- Conocer los tipos de bases de datos relacionales
- Dominar la creación de bases de datos y tablas
- Entender los tipos de datos básicos en SQL
- Realizar operaciones básicas de INSERT y SELECT
- Aplicar restricciones básicas (PRIMARY KEY, NOT NULL)
- Crear sistemas de gestión básicos

## Prerrequisitos
- Conocimientos básicos de informática
- Acceso a un servidor de base de datos (MySQL, PostgreSQL, SQL Server)
- Editor de código o cliente de base de datos

## Tecnologías y Herramientas
- **MySQL/PostgreSQL**: Sistema de gestión de bases de datos
- **MySQL Workbench/pgAdmin**: Cliente de base de datos
- **SQL**: Lenguaje de consulta estructurado
- **Terminal/Command Line**: Línea de comandos

## Estructura del Módulo

### 📚 Clases Disponibles

| Clase | Título | Descripción | Duración Estimada |
|-------|--------|-------------|-------------------|
| [Clase 1](clase_1_introduccion_sql.md) | Introducción a SQL - Fundamentos Básicos | ¿Qué es SQL?, tipos de bases de datos, conceptos básicos, primer programa | 2-3 horas |
| [Clase 2](clase_2_tipos_datos_restricciones.md) | Tipos de Datos y Restricciones | Tipos de datos numéricos, texto, fecha, booleanos, restricciones | 2-3 horas |
| [Clase 3](clase_3_relaciones_tablas.md) | Relaciones entre Tablas | Claves primarias, foráneas, relaciones 1:1, 1:N, N:N | 3-4 horas |
| [Clase 4](clase_4_operaciones_basicas.md) | Operaciones Básicas CRUD | INSERT, SELECT, UPDATE, DELETE básicos | 3-4 horas |
| [Clase 5](clase_5_consultas_select.md) | Consultas SELECT Avanzadas | SELECT con WHERE, ORDER BY, LIMIT, alias | 2-3 horas |
| [Clase 6](clase_6_funciones_basicas.md) | Funciones Básicas de SQL | Funciones de texto, numéricas, fecha, conversión | 3-4 horas |
| [Clase 7](clase_7_filtros_avanzados.md) | Filtros Avanzados | WHERE con operadores, LIKE, IN, BETWEEN | 2-3 horas |
| [Clase 8](clase_8_ordenamiento_agrupacion.md) | Ordenamiento y Agrupación | ORDER BY, GROUP BY, funciones agregadas básicas | 3-4 horas |
| [Clase 9](clase_9_indices_optimizacion.md) | Índices y Optimización Básica | CREATE INDEX, optimización básica, EXPLAIN | 2-3 horas |
| [Clase 10](clase_10_proyecto_integrador.md) | Proyecto Integrador | Sistema completo de gestión de biblioteca | 4-5 horas |

## 🚀 Navegación Rápida

### **Empezar Aquí** → [Clase 1: Introducción a SQL](clase_1_introduccion_sql.md)

### **Continuar con** → [Clase 2: Tipos de Datos y Restricciones](clase_2_tipos_datos_restricciones.md)

### **Conceptos Fundamentales** → [Clase 3: Relaciones entre Tablas](clase_3_relaciones_tablas.md) → [Clase 4: Operaciones Básicas](clase_4_operaciones_basicas.md)

### **Consultas y Funciones** → [Clase 5: Consultas SELECT](clase_5_consultas_select.md) → [Clase 6: Funciones Básicas](clase_6_funciones_basicas.md)

### **Filtros y Optimización** → [Clase 7: Filtros Avanzados](clase_7_filtros_avanzados.md) → [Clase 8: Ordenamiento](clase_8_ordenamiento_agrupacion.md)

### **Optimización** → [Clase 9: Índices y Optimización](clase_9_indices_optimizacion.md)

### **Proyecto Final** → [Clase 10: Proyecto Integrador](clase_10_proyecto_integrador.md)

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

## 🎯 Ejercicios Prácticos (10 Ejercicios)

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

### Ejercicio 6: Crear Base de Datos de Tienda Online
Crea una base de datos llamada `tienda_online` y una tabla llamada `productos` con:
- id (número entero, clave primaria, auto-incremento)
- nombre (texto, máximo 150 caracteres, obligatorio)
- descripcion (texto, máximo 1000 caracteres)
- precio (decimal con 2 decimales, obligatorio)
- categoria (texto, máximo 50 caracteres)
- stock (número entero, por defecto 0)
- fecha_creacion (fecha y hora, por defecto actual)

**Solución:**
```sql
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
```

### Ejercicio 7: Crear Base de Datos de Banco
Crea una base de datos llamada `banco` y una tabla llamada `cuentas` con:
- id (número entero, clave primaria, auto-incremento)
- numero_cuenta (texto, máximo 20 caracteres, único, obligatorio)
- titular (texto, máximo 200 caracteres, obligatorio)
- saldo (decimal con 2 decimales, por defecto 0.00)
- tipo_cuenta (texto, máximo 20 caracteres)
- fecha_apertura (fecha, por defecto fecha actual)

**Solución:**
```sql
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
```

### Ejercicio 8: Crear Base de Datos de Agencia de Viajes
Crea una base de datos llamada `agencia_viajes` y una tabla llamada `destinos` con:
- id (número entero, clave primaria, auto-incremento)
- nombre (texto, máximo 100 caracteres, obligatorio)
- pais (texto, máximo 50 caracteres, obligatorio)
- ciudad (texto, máximo 50 caracteres, obligatorio)
- precio_persona (decimal con 2 decimales, obligatorio)
- duracion_dias (número entero)
- descripcion (texto, máximo 500 caracteres)

**Solución:**
```sql
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
```

### Ejercicio 9: Crear Base de Datos de Cine
Crea una base de datos llamada `cine` y una tabla llamada `peliculas` con:
- id (número entero, clave primaria, auto-incremento)
- titulo (texto, máximo 200 caracteres, obligatorio)
- director (texto, máximo 100 caracteres, obligatorio)
- año_estreno (número entero)
- genero (texto, máximo 50 caracteres)
- duracion_minutos (número entero)
- calificacion (decimal con 1 decimal, rango 0.0 a 10.0)

**Solución:**
```sql
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
```

### Ejercicio 10: Crear Base de Datos de Red Social
Crea una base de datos llamada `red_social` y una tabla llamada `usuarios` con:
- id (número entero, clave primaria, auto-incremento)
- username (texto, máximo 50 caracteres, único, obligatorio)
- email (texto, máximo 150 caracteres, único, obligatorio)
- nombre_completo (texto, máximo 200 caracteres, obligatorio)
- fecha_nacimiento (fecha)
- fecha_registro (fecha y hora, por defecto actual)
- activo (booleano, por defecto true)

**Solución:**
```sql
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
```

## 🏆 Proyecto Integrador: Sistema de Gestión de Biblioteca Básico

Crea un sistema completo de gestión de biblioteca que incluya:

1. **Base de datos**: `biblioteca_completa`
2. **Tabla de libros** con todos los campos necesarios
3. **Tabla de usuarios** para gestionar miembros
4. **Tabla de préstamos** para registrar libros prestados
5. **Insertar datos de ejemplo** en todas las tablas
6. **Consultas básicas** para ver los datos

**Estructura sugerida:**
```sql
-- Base de datos
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
```

## 📝 Resumen de Conceptos Clave
- ✅ SQL es el lenguaje estándar para bases de datos relacionales
- ✅ Una base de datos contiene tablas organizadas
- ✅ Las tablas tienen filas (registros) y columnas (campos)
- ✅ CREATE DATABASE crea una nueva base de datos
- ✅ CREATE TABLE crea una nueva tabla con estructura definida
- ✅ INSERT INTO agrega datos a las tablas
- ✅ SELECT muestra datos de las tablas
- ✅ Las restricciones (PRIMARY KEY, NOT NULL, UNIQUE) aseguran la integridad de los datos
- ✅ Los tipos de datos (VARCHAR, INT, DECIMAL, DATE) definen el formato de almacenamiento

## 🎯 Resultados del Aprendizaje

Al completar este módulo, serás capaz de:

✅ **Crear bases de datos** desde cero  
✅ **Diseñar tablas** con estructura apropiada  
✅ **Aplicar restricciones** para integridad de datos  
✅ **Insertar datos** en las tablas  
✅ **Consultar datos** básicos con SELECT  
✅ **Entender tipos de datos** y su uso apropiado  
✅ **Crear sistemas básicos** de gestión de información  

## 🛠️ Herramientas y Recursos

### **Entorno de Desarrollo**
- [MySQL](https://www.mysql.com/downloads/) - Base de datos relacional
- [PostgreSQL](https://www.postgresql.org/download/) - Base de datos avanzada
- [MySQL Workbench](https://www.mysql.com/products/workbench/) - Cliente visual
- [pgAdmin](https://www.pgadmin.org/) - Cliente para PostgreSQL

### **Recursos de Aprendizaje**
- [Documentación oficial de MySQL](https://dev.mysql.com/doc/)
- [Documentación oficial de PostgreSQL](https://www.postgresql.org/docs/)
- [W3Schools SQL Tutorial](https://www.w3schools.com/sql/)
- [SQLBolt - Interactive SQL Tutorial](https://sqlbolt.com/)

### **Comunidad y Soporte**
- [Stack Overflow - SQL](https://stackoverflow.com/questions/tagged/sql)
- [Reddit - r/SQL](https://www.reddit.com/r/SQL/)
- [MySQL Community](https://forums.mysql.com/)

## 📝 Evaluación y Práctica

### **Ejercicios por Módulo**
Cada ejercicio incluye:
- Enunciado claro del problema
- Solución completa con código SQL
- Explicación de conceptos aplicados
- Variaciones para práctica adicional

### **Proyecto Final del Módulo**
El proyecto integrador combina todos los conceptos aprendidos en un sistema real de gestión de biblioteca.

## 🚀 Próximos Pasos

Después de completar este módulo, estarás listo para continuar con:

- **Módulo 2**: Consultas SELECT Básicas
- **Módulo 3**: Filtros Avanzados y Ordenamiento
- **Módulo 4**: Operaciones CRUD
- **Módulo 5**: Funciones Básicas de SQL

## 💡 Consejos para el Éxito

1. **Practica regularmente** - Dedica tiempo diario a escribir SQL
2. **Completa todos los ejercicios** - Refuerza tu comprensión con práctica
3. **Experimenta** - Modifica las consultas y crea nuevas
4. **Usa datos reales** - Crea tus propias bases de datos de práctica
5. **Documenta tu aprendizaje** - Toma notas de conceptos clave

---

## 🧭 Navegación del Curso

**← Anterior**: [🏠 Inicio del Curso](../README.md)  
**Siguiente →**: [Módulo 2: Consultas SELECT Básicas](../junior_2/README.md)

---

## 🎉 ¡Comienza tu viaje en SQL!

**Primera clase**: Este módulo - Introducción a SQL y Bases de Datos

**Duración total del módulo**: 15-20 horas (dependiendo de tu ritmo de aprendizaje)

**Nivel de dificultad**: Principiante

**Requisitos previos**: Ninguno

---

*¡Bienvenido al mundo de las bases de datos con SQL! 🚀*

