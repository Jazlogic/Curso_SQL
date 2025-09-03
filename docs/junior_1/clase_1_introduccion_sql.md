# Clase 1: Introducción a SQL - Fundamentos Básicos

## 📚 Descripción de la Clase
Esta es la primera clase del curso de SQL, donde aprenderás los conceptos fundamentales de las bases de datos y el lenguaje SQL. Comenzaremos desde cero, explicando qué es SQL, por qué es importante, y cómo se estructura una base de datos.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Comprender qué es SQL y su importancia en el desarrollo de software
- Entender los conceptos básicos de bases de datos relacionales
- Conocer los diferentes tipos de sistemas de gestión de bases de datos
- Identificar los componentes principales de una base de datos
- Preparar tu entorno de desarrollo para trabajar con SQL

## ⏱️ Duración Estimada
**2-3 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué es SQL?

**SQL** (Structured Query Language) es un lenguaje de programación especializado diseñado para gestionar y manipular bases de datos relacionales. Es el estándar internacional para interactuar con bases de datos.

#### Características principales de SQL:
- **Declarativo**: Describes qué quieres obtener, no cómo obtenerlo
- **Estándar**: Funciona en múltiples sistemas de bases de datos
- **Potente**: Permite operaciones complejas con pocas líneas de código
- **Legible**: Su sintaxis es similar al lenguaje natural

### ¿Por qué es importante SQL?

SQL es fundamental en el desarrollo de software porque:

1. **Almacenamiento de datos**: Las aplicaciones necesitan guardar información de forma persistente
2. **Consultas eficientes**: Permite buscar y filtrar datos de manera rápida
3. **Integridad de datos**: Asegura que los datos sean consistentes y válidos
4. **Escalabilidad**: Maneja grandes volúmenes de información
5. **Estándar de la industria**: Es el lenguaje más utilizado para bases de datos

### ¿Qué es una Base de Datos?

Una **base de datos** es una colección organizada de información estructurada, almacenada electrónicamente en un sistema informático. Es como una biblioteca digital donde puedes almacenar, organizar y recuperar información de manera eficiente.

#### Analogía con una biblioteca:
- **Base de datos** = La biblioteca completa
- **Tabla** = Una estantería específica (ej: "Libros de Historia")
- **Registro/Fila** = Un libro individual
- **Campo/Columna** = Una característica del libro (título, autor, año)

### Tipos de Bases de Datos Relacionales

#### 1. **MySQL**
- **Descripción**: Sistema de gestión de bases de datos de código abierto
- **Características**: 
  - Muy popular para aplicaciones web
  - Fácil de instalar y configurar
  - Excelente rendimiento
  - Amplia comunidad de soporte
- **Casos de uso**: Sitios web, aplicaciones pequeñas y medianas

#### 2. **PostgreSQL**
- **Descripción**: Sistema de bases de datos objeto-relacional de código abierto
- **Características**:
  - Muy robusto y confiable
  - Soporte avanzado para tipos de datos complejos
  - Excelente para aplicaciones empresariales
  - Cumple con estándares SQL
- **Casos de uso**: Aplicaciones empresariales, análisis de datos

#### 3. **SQL Server**
- **Descripción**: Sistema de gestión de bases de datos de Microsoft
- **Características**:
  - Integración perfecta con productos Microsoft
  - Herramientas avanzadas de administración
  - Excelente para entornos empresariales
  - Soporte para análisis de datos
- **Casos de uso**: Aplicaciones empresariales, Business Intelligence

#### 4. **Oracle**
- **Descripción**: Sistema de gestión de bases de datos empresarial
- **Características**:
  - Muy potente y escalable
  - Amplias funcionalidades empresariales
  - Alto rendimiento
  - Soporte 24/7
- **Casos de uso**: Grandes empresas, aplicaciones críticas

#### 5. **SQLite**
- **Descripción**: Motor de base de datos embebido
- **Características**:
  - Muy ligero (solo unos MB)
  - No requiere servidor
  - Perfecto para aplicaciones móviles
  - Archivo único de base de datos
- **Casos de uso**: Aplicaciones móviles, prototipos, aplicaciones pequeñas

### Conceptos Básicos de Bases de Datos

#### 1. **Tabla (Table)**
Una tabla es una estructura que almacena datos organizados en filas y columnas. Es como una hoja de cálculo, pero con reglas más estrictas.

**Ejemplo de tabla "productos":**
```
| id | nombre      | precio | stock |
|----|-------------|--------|-------|
| 1  | Laptop      | 999.99 | 10    |
| 2  | Mouse       | 25.50  | 50    |
| 3  | Teclado     | 89.99  | 15    |
```

#### 2. **Fila/Registro (Row/Record)**
Cada fila representa una entrada individual en la tabla. En el ejemplo anterior, cada fila representa un producto diferente.

#### 3. **Columna/Campo (Column/Field)**
Cada columna representa un tipo específico de dato. En el ejemplo:
- `id`: Identificador único del producto
- `nombre`: Nombre del producto
- `precio`: Precio del producto
- `stock`: Cantidad disponible

#### 4. **Base de Datos (Database)**
Una base de datos es un conjunto de tablas relacionadas que almacenan información sobre un tema específico.

#### 5. **Clave Primaria (Primary Key)**
Es un campo (o combinación de campos) que identifica de manera única cada registro en una tabla. En nuestro ejemplo, `id` es la clave primaria.

#### 6. **Restricciones (Constraints)**
Son reglas que definen qué datos pueden almacenarse en una tabla:
- **NOT NULL**: El campo no puede estar vacío
- **UNIQUE**: El valor debe ser único en toda la tabla
- **PRIMARY KEY**: Identificador único y obligatorio
- **FOREIGN KEY**: Referencia a otra tabla

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Crear tu Primera Base de Datos

Vamos a crear una base de datos para una tienda de productos electrónicos.

```sql
-- Línea 1: Crear una nueva base de datos
CREATE DATABASE tienda_electronica;

-- Explicación línea por línea:
-- CREATE DATABASE: Comando SQL para crear una nueva base de datos
-- tienda_electronica: Nombre que le damos a nuestra base de datos
-- ; : Punto y coma indica el final de la instrucción SQL
```

**Conceptos técnicos explicados:**
- **CREATE**: Palabra clave que indica que vamos a crear algo nuevo
- **DATABASE**: Tipo de objeto que estamos creando
- **tienda_electronica**: Identificador (nombre) de la base de datos
- **Punto y coma (;)**: Delimitador que indica el final de una instrucción SQL

### Ejemplo 2: Seleccionar la Base de Datos

```sql
-- Línea 2: Seleccionar la base de datos para trabajar con ella
USE tienda_electronica;

-- Explicación línea por línea:
-- USE: Comando SQL para seleccionar una base de datos específica
-- tienda_electronica: Nombre de la base de datos que queremos usar
-- ; : Final de la instrucción
```

**Conceptos técnicos explicados:**
- **USE**: Comando que activa una base de datos específica
- **Contexto de base de datos**: Una vez ejecutado USE, todas las operaciones se realizan en esa base de datos

### Ejemplo 3: Crear tu Primera Tabla

```sql
-- Líneas 3-8: Crear una tabla para almacenar productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0
);

-- Explicación línea por línea:
-- Línea 3: CREATE TABLE productos (
--   CREATE TABLE: Comando para crear una nueva tabla
--   productos: Nombre de la tabla que estamos creando
--   ( : Inicio de la definición de columnas

-- Línea 4: id INT PRIMARY KEY AUTO_INCREMENT,
--   id: Nombre de la primera columna
--   INT: Tipo de dato entero (números sin decimales)
--   PRIMARY KEY: Esta columna será la clave primaria
--   AUTO_INCREMENT: El valor se incrementa automáticamente
--   , : Separador entre columnas

-- Línea 5: nombre VARCHAR(100) NOT NULL,
--   nombre: Nombre de la segunda columna
--   VARCHAR(100): Tipo de dato texto con máximo 100 caracteres
--   NOT NULL: Esta columna no puede estar vacía
--   , : Separador entre columnas

-- Línea 6: precio DECIMAL(10,2) NOT NULL,
--   precio: Nombre de la tercera columna
--   DECIMAL(10,2): Tipo de dato decimal con 10 dígitos totales y 2 decimales
--   NOT NULL: Esta columna no puede estar vacía
--   , : Separador entre columnas

-- Línea 7: stock INT DEFAULT 0
--   stock: Nombre de la cuarta columna
--   INT: Tipo de dato entero
--   DEFAULT 0: Valor por defecto es 0 si no se especifica
--   (sin coma porque es la última columna)

-- Línea 8: );
--   ) : Cierre de la definición de columnas
--   ; : Final de la instrucción
```

**Conceptos técnicos explicados:**

#### Tipos de Datos:
- **INT**: Entero (números como 1, 2, 100, -5)
- **VARCHAR(n)**: Texto variable de hasta n caracteres
- **DECIMAL(p,s)**: Número decimal con p dígitos totales y s decimales
- **DATE**: Fecha (YYYY-MM-DD)
- **BOOLEAN**: Verdadero o falso

#### Restricciones:
- **PRIMARY KEY**: Identificador único de cada fila
- **AUTO_INCREMENT**: Incrementa automáticamente el valor
- **NOT NULL**: El campo no puede estar vacío
- **DEFAULT**: Valor por defecto si no se especifica

### Ejemplo 4: Insertar Datos en la Tabla

```sql
-- Líneas 9-12: Insertar productos en la tabla
INSERT INTO productos (nombre, precio, stock) VALUES
('Laptop HP', 899.99, 10),
('Mouse Inalámbrico', 25.50, 50),
('Teclado Mecánico', 89.99, 15);

-- Explicación línea por línea:
-- Línea 9: INSERT INTO productos (nombre, precio, stock) VALUES
--   INSERT INTO: Comando para insertar datos en una tabla
--   productos: Nombre de la tabla donde insertamos
--   (nombre, precio, stock): Columnas donde insertaremos datos
--   VALUES: Palabra clave que indica que vienen los valores

-- Línea 10: ('Laptop HP', 899.99, 10),
--   'Laptop HP': Valor para la columna nombre (texto entre comillas)
--   899.99: Valor para la columna precio (número decimal)
--   10: Valor para la columna stock (número entero)
--   , : Separador entre filas (indica que hay más datos)

-- Línea 11: ('Mouse Inalámbrico', 25.50, 50),
--   Segunda fila de datos con los mismos tipos de columnas
--   , : Separador entre filas

-- Línea 12: ('Teclado Mecánico', 89.99, 15);
--   Tercera fila de datos
--   ; : Final de la instrucción (sin coma porque es la última fila)
```

**Conceptos técnicos explicados:**
- **INSERT INTO**: Comando para agregar nuevos registros
- **Valores literales**: 
  - Texto: entre comillas simples ('texto')
  - Números: sin comillas (123, 45.67)
  - Fechas: formato 'YYYY-MM-DD'

### Ejemplo 5: Consultar los Datos

```sql
-- Línea 13: Ver todos los productos insertados
SELECT * FROM productos;

-- Explicación línea por línea:
-- SELECT: Comando para consultar/obtener datos
-- * : Significa "todas las columnas"
-- FROM: Palabra clave que indica de qué tabla obtener los datos
-- productos: Nombre de la tabla
-- ; : Final de la instrucción
```

**Resultado esperado:**
```
| id | nombre            | precio | stock |
|----|-------------------|--------|-------|
| 1  | Laptop HP         | 899.99 | 10    |
| 2  | Mouse Inalámbrico | 25.50  | 50    |
| 3  | Teclado Mecánico  | 89.99  | 15    |
```

**Conceptos técnicos explicados:**
- **SELECT**: Comando fundamental para consultar datos
- **Asterisco (*)**: Comodín que significa "todas las columnas"
- **FROM**: Especifica la tabla de origen de los datos
- **Resultado**: La consulta devuelve un conjunto de filas

### Ejemplo 6: Ver la Estructura de la Tabla

```sql
-- Línea 14: Ver la estructura de la tabla productos
DESCRIBE productos;

-- Explicación línea por línea:
-- DESCRIBE: Comando para mostrar la estructura de una tabla
-- productos: Nombre de la tabla a describir
-- ; : Final de la instrucción
```

**Resultado esperado:**
```
| Field  | Type         | Null | Key | Default | Extra          |
|--------|--------------|------|-----|---------|----------------|
| id     | int          | NO   | PRI | NULL    | auto_increment |
| nombre | varchar(100) | NO   |     | NULL    |                |
| precio | decimal(10,2)| NO   |     | NULL    |                |
| stock  | int          | YES  |     | 0       |                |
```

**Conceptos técnicos explicados:**
- **DESCRIBE**: Comando para ver la estructura de una tabla
- **Field**: Nombre de la columna
- **Type**: Tipo de dato de la columna
- **Null**: Si permite valores nulos (NO = no permite, YES = permite)
- **Key**: Tipo de clave (PRI = Primary Key)
- **Default**: Valor por defecto
- **Extra**: Información adicional (auto_increment)

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Crear Base de Datos de Biblioteca
**Objetivo**: Practicar la creación de una base de datos y tabla básica.

**Instrucciones**:
1. Crea una base de datos llamada `biblioteca`
2. Selecciona esa base de datos
3. Crea una tabla llamada `libros` con las siguientes columnas:
   - `id`: número entero, clave primaria, auto-incremento
   - `titulo`: texto de máximo 200 caracteres, obligatorio
   - `autor`: texto de máximo 100 caracteres, obligatorio
   - `año_publicacion`: número entero
   - `genero`: texto de máximo 50 caracteres

**Solución paso a paso:**

```sql
-- Paso 1: Crear la base de datos
CREATE DATABASE biblioteca;

-- Explicación: 
-- CREATE DATABASE es el comando para crear una nueva base de datos
-- biblioteca es el nombre que le damos a nuestra base de datos
-- El punto y coma (;) indica el final de la instrucción

-- Paso 2: Seleccionar la base de datos
USE biblioteca;

-- Explicación:
-- USE selecciona la base de datos para trabajar con ella
-- A partir de este momento, todas las operaciones se realizan en 'biblioteca'

-- Paso 3: Crear la tabla libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    año_publicacion INT,
    genero VARCHAR(50)
);

-- Explicación línea por línea:
-- CREATE TABLE libros ( : Inicia la creación de la tabla 'libros'
-- id INT PRIMARY KEY AUTO_INCREMENT, : 
--   - id: nombre de la columna
--   - INT: tipo de dato entero
--   - PRIMARY KEY: esta columna será la clave primaria (identificador único)
--   - AUTO_INCREMENT: el valor se incrementa automáticamente (1, 2, 3...)
-- titulo VARCHAR(200) NOT NULL, :
--   - titulo: nombre de la columna
--   - VARCHAR(200): texto de máximo 200 caracteres
--   - NOT NULL: esta columna no puede estar vacía
-- autor VARCHAR(100) NOT NULL, :
--   - autor: nombre de la columna
--   - VARCHAR(100): texto de máximo 100 caracteres
--   - NOT NULL: esta columna no puede estar vacía
-- año_publicacion INT, :
--   - año_publicacion: nombre de la columna
--   - INT: tipo de dato entero
--   - (sin NOT NULL, por lo que puede estar vacía)
-- genero VARCHAR(50) :
--   - genero: nombre de la columna
--   - VARCHAR(50): texto de máximo 50 caracteres
--   - (sin NOT NULL, por lo que puede estar vacía)
-- ); : Cierra la definición de la tabla
```

### Ejercicio 2: Insertar Datos de Ejemplo
**Objetivo**: Practicar la inserción de datos en la tabla.

**Instrucciones**:
Inserta los siguientes libros en la tabla `libros`:
- "El Quijote" por Miguel de Cervantes, año 1605, género "Novela"
- "Cien años de soledad" por Gabriel García Márquez, año 1967, género "Realismo mágico"
- "1984" por George Orwell, año 1949, género "Ciencia ficción"

**Solución paso a paso:**

```sql
-- Insertar múltiples libros en una sola instrucción
INSERT INTO libros (titulo, autor, año_publicacion, genero) VALUES
('El Quijote', 'Miguel de Cervantes', 1605, 'Novela'),
('Cien años de soledad', 'Gabriel García Márquez', 1967, 'Realismo mágico'),
('1984', 'George Orwell', 1949, 'Ciencia ficción');

-- Explicación línea por línea:
-- INSERT INTO libros (titulo, autor, año_publicacion, genero) VALUES
--   - INSERT INTO: comando para insertar datos
--   - libros: nombre de la tabla
--   - (titulo, autor, año_publicacion, genero): columnas donde insertaremos
--   - VALUES: palabra clave que indica que vienen los valores

-- ('El Quijote', 'Miguel de Cervantes', 1605, 'Novela'),
--   - 'El Quijote': valor para titulo (texto entre comillas simples)
--   - 'Miguel de Cervantes': valor para autor (texto entre comillas simples)
--   - 1605: valor para año_publicacion (número sin comillas)
--   - 'Novela': valor para genero (texto entre comillas simples)
--   - , : coma indica que hay más filas

-- ('Cien años de soledad', 'Gabriel García Márquez', 1967, 'Realismo mágico'),
--   - Segunda fila de datos con el mismo formato
--   - , : coma indica que hay más filas

-- ('1984', 'George Orwell', 1949, 'Ciencia ficción');
--   - Tercera fila de datos
--   - ; : punto y coma indica el final (sin coma porque es la última fila)
```

### Ejercicio 3: Consultar los Datos
**Objetivo**: Practicar la consulta básica de datos.

**Instrucciones**:
1. Muestra todos los libros de la tabla
2. Muestra solo los títulos de los libros
3. Muestra la estructura de la tabla

**Solución paso a paso:**

```sql
-- Consulta 1: Ver todos los libros
SELECT * FROM libros;

-- Explicación:
-- SELECT: comando para consultar datos
-- * : comodín que significa "todas las columnas"
-- FROM libros: especifica que queremos datos de la tabla 'libros'

-- Resultado esperado:
-- | id | titulo                | autor                  | año_publicacion | genero        |
-- |----|-----------------------|------------------------|-----------------|---------------|
-- | 1  | El Quijote            | Miguel de Cervantes    | 1605            | Novela        |
-- | 2  | Cien años de soledad  | Gabriel García Márquez | 1967            | Realismo mágico|
-- | 3  | 1984                  | George Orwell          | 1949            | Ciencia ficción|

-- Consulta 2: Ver solo los títulos
SELECT titulo FROM libros;

-- Explicación:
-- SELECT titulo: especifica que solo queremos la columna 'titulo'
-- FROM libros: de la tabla 'libros'

-- Resultado esperado:
-- | titulo                |
-- |-----------------------|
-- | El Quijote            |
-- | Cien años de soledad  |
-- | 1984                  |

-- Consulta 3: Ver la estructura de la tabla
DESCRIBE libros;

-- Explicación:
-- DESCRIBE: comando para mostrar la estructura de una tabla
-- libros: nombre de la tabla a describir

-- Resultado esperado:
-- | Field            | Type         | Null | Key | Default | Extra          |
-- |------------------|--------------|------|-----|---------|----------------|
-- | id               | int          | NO   | PRI | NULL    | auto_increment |
-- | titulo           | varchar(200) | NO   |     | NULL    |                |
-- | autor            | varchar(100) | NO   |     | NULL    |                |
-- | año_publicacion  | int          | YES  |     | NULL    |                |
-- | genero           | varchar(50)  | YES  |     | NULL    |                |
```

---

## 📝 Resumen de Conceptos Clave

### Comandos SQL Aprendidos:
- **CREATE DATABASE**: Crea una nueva base de datos
- **USE**: Selecciona una base de datos para trabajar
- **CREATE TABLE**: Crea una nueva tabla con sus columnas
- **INSERT INTO**: Inserta nuevos registros en una tabla
- **SELECT**: Consulta datos de una tabla
- **DESCRIBE**: Muestra la estructura de una tabla

### Tipos de Datos:
- **INT**: Números enteros (1, 2, 100, -5)
- **VARCHAR(n)**: Texto de máximo n caracteres
- **DECIMAL(p,s)**: Números decimales con p dígitos totales y s decimales

### Restricciones:
- **PRIMARY KEY**: Identificador único de cada fila
- **AUTO_INCREMENT**: Incrementa automáticamente el valor
- **NOT NULL**: El campo no puede estar vacío
- **DEFAULT**: Valor por defecto si no se especifica

### Conceptos de Base de Datos:
- **Base de datos**: Colección de tablas relacionadas
- **Tabla**: Estructura que almacena datos en filas y columnas
- **Fila/Registro**: Cada entrada individual en una tabla
- **Columna/Campo**: Cada tipo de dato en una tabla
- **Clave primaria**: Campo que identifica únicamente cada registro

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Cómo crear tablas más complejas
- Diferentes tipos de datos y cuándo usarlos
- Más restricciones y su importancia
- Cómo insertar datos de diferentes formas

---

## 💡 Consejos para el Éxito

1. **Practica cada comando**: No solo leas, ejecuta cada ejemplo
2. **Experimenta**: Modifica los ejemplos y observa qué pasa
3. **Usa nombres descriptivos**: Para bases de datos, tablas y columnas
4. **Sigue las convenciones**: Usa minúsculas y guiones bajos para nombres
5. **Documenta tu código**: Usa comentarios para explicar lo que haces

---

## 🧭 Navegación

**← Anterior**: [🏠 Inicio del Curso](../README.md)  
**Siguiente →**: [Clase 2: Tipos de Datos y Restricciones](clase_2_tipos_datos_restricciones.md)

---

*¡Excelente trabajo! Has dado tus primeros pasos en el mundo de SQL. 🚀*
