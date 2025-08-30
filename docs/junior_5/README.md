# 🔰 Junior Level 5: Funciones Básicas de SQL

## 📖 Teoría

### ¿Qué son las Funciones SQL?
Las funciones SQL son operaciones predefinidas que procesan datos y retornan un resultado. Se pueden usar en consultas SELECT, WHERE, ORDER BY, etc.

### Tipos de Funciones
1. **Funciones de Texto**: Manipulan cadenas de caracteres
2. **Funciones Numéricas**: Realizan cálculos matemáticos
3. **Funciones de Fecha**: Trabajan con fechas y tiempos
4. **Funciones de Conversión**: Cambian tipos de datos

### Funciones de Texto Principales
- **CONCAT()**: Une cadenas de texto
- **UPPER()/LOWER()**: Convierte a mayúsculas/minúsculas
- **LENGTH()**: Cuenta caracteres
- **SUBSTRING()**: Extrae parte de una cadena
- **TRIM()**: Elimina espacios en blanco
- **REPLACE()**: Reemplaza texto

### Funciones Numéricas Principales
- **ROUND()**: Redondea números
- **CEILING()/FLOOR()**: Redondea hacia arriba/abajo
- **ABS()**: Valor absoluto
- **MOD()**: Módulo (resto de división)
- **POWER()**: Potencia

### Funciones de Fecha Principales
- **NOW()**: Fecha y hora actual
- **CURDATE()**: Fecha actual
- **YEAR()/MONTH()/DAY()**: Extrae parte de fecha
- **DATE_ADD()/DATE_SUB()**: Suma/resta fechas
- **DATEDIFF()**: Diferencia entre fechas

## 💡 Ejemplos Prácticos

### Ejemplo 1: Funciones de Texto
```sql
-- Concatenar nombre y apellido
SELECT CONCAT(nombre, ' ', apellido) AS 'Nombre Completo' 
FROM estudiantes;

-- Convertir nombre a mayúsculas
SELECT UPPER(nombre) AS 'Nombre en Mayúsculas' 
FROM estudiantes;

-- Contar caracteres del nombre
SELECT nombre, LENGTH(nombre) AS 'Longitud del Nombre' 
FROM estudiantes;
```

### Ejemplo 2: Funciones Numéricas
```sql
-- Redondear precios a 2 decimales
SELECT nombre, ROUND(precio, 2) AS 'Precio Redondeado' 
FROM productos;

-- Calcular descuento del 20%
SELECT nombre, precio, ROUND(precio * 0.8, 2) AS 'Precio con Descuento' 
FROM productos;

-- Verificar si el precio es par o impar
SELECT nombre, precio, 
       CASE WHEN MOD(precio, 2) = 0 THEN 'Par' ELSE 'Impar' END AS 'Paridad'
FROM productos;
```

### Ejemplo 3: Funciones de Fecha
```sql
-- Calcular edad de pacientes
SELECT nombre, apellido, 
       YEAR(CURDATE()) - YEAR(fecha_nacimiento) AS 'Edad' 
FROM pacientes;

-- Ver pacientes nacidos este mes
SELECT nombre, apellido 
FROM pacientes 
WHERE MONTH(fecha_nacimiento) = MONTH(CURDATE());

-- Calcular días desde la inscripción
SELECT nombre, fecha_inscripcion, 
       DATEDIFF(CURDATE(), fecha_inscripcion) AS 'Días de Miembro' 
FROM miembros;
```

### Ejemplo 4: Combinando Funciones
```sql
-- Formatear información del producto
SELECT 
    UPPER(nombre) AS 'Nombre del Producto',
    CONCAT('$', ROUND(precio, 2)) AS 'Precio Formateado',
    CONCAT(stock, ' unidades') AS 'Stock Disponible'
FROM productos;
```

### Ejemplo 5: Funciones en WHERE
```sql
-- Productos con nombre de más de 10 caracteres
SELECT * FROM productos 
WHERE LENGTH(nombre) > 10;

-- Estudiantes con nombre que empiece con vocal
SELECT * FROM estudiantes 
WHERE LOWER(SUBSTRING(nombre, 1, 1)) IN ('a', 'e', 'i', 'o', 'u');
```

## 🎯 Ejercicios

### Ejercicio 1: Funciones con Productos
Usando la tabla `productos` de la tienda, escribe consultas que utilicen funciones para:

1. Mostrar el nombre del producto en mayúsculas y su precio con símbolo de dólar
2. Calcular el precio con IVA del 16% y mostrarlo redondeado a 2 decimales
3. Mostrar productos con nombre de más de 15 caracteres
4. Crear una descripción combinando nombre, categoría y stock
5. Calcular el precio promedio de productos por categoría

**Solución:**
```sql
-- 1. Nombre en mayúsculas y precio con símbolo
SELECT 
    UPPER(nombre) AS 'Nombre del Producto',
    CONCAT('$', precio) AS 'Precio'
FROM productos;

-- 2. Precio con IVA
SELECT 
    nombre,
    precio,
    ROUND(precio * 1.16, 2) AS 'Precio con IVA'
FROM productos;

-- 3. Nombres largos
SELECT * FROM productos 
WHERE LENGTH(nombre) > 15;

-- 4. Descripción combinada
SELECT 
    CONCAT(nombre, ' - ', categoria, ' (Stock: ', stock, ')') AS 'Descripción Completa'
FROM productos;

-- 5. Precio promedio por categoría
SELECT 
    categoria,
    ROUND(AVG(precio), 2) AS 'Precio Promedio'
FROM productos 
GROUP BY categoria;
```

### Ejercicio 2: Funciones con Libros
Usando la tabla `libros` de la biblioteca, escribe consultas que utilicen funciones para:

1. Mostrar título y autor en formato "Título por Autor"
2. Calcular cuántos años han pasado desde la publicación de cada libro
3. Mostrar libros con título de más de 20 caracteres
4. Crear un código único combinando las primeras letras del título y autor
5. Mostrar solo el siglo de publicación de cada libro

**Solución:**
```sql
-- 1. Formato título por autor
SELECT 
    CONCAT(titulo, ' por ', autor) AS 'Información del Libro'
FROM libros;

-- 2. Años desde publicación
SELECT 
    titulo,
    año_publicacion,
    YEAR(CURDATE()) - año_publicacion AS 'Años desde Publicación'
FROM libros;

-- 3. Títulos largos
SELECT * FROM libros 
WHERE LENGTH(titulo) > 20;

-- 4. Código único
SELECT 
    titulo,
    autor,
    CONCAT(UPPER(SUBSTRING(titulo, 1, 3)), '-', UPPER(SUBSTRING(autor, 1, 3))) AS 'Código'
FROM libros;

-- 5. Siglo de publicación
SELECT 
    titulo,
    año_publicacion,
    CONCAT('Siglo ', CEILING(año_publicacion / 100)) AS 'Siglo'
FROM libros;
```

### Ejercicio 3: Funciones con Estudiantes
Usando la tabla `estudiantes` de la escuela, escribe consultas que utilicen funciones para:

1. Mostrar nombre completo en formato "Apellido, Nombre"
2. Calcular cuántos años faltan para graduarse (asumiendo que se gradúan a los 18)
3. Mostrar estudiantes con nombre que contenga más de 2 vocales
4. Crear un ID de estudiante combinando grado y edad
5. Mostrar solo el mes de nacimiento (si tuviera fecha de nacimiento)

**Solución:**
```sql
-- 1. Formato apellido, nombre
SELECT 
    CONCAT(apellido, ', ', nombre) AS 'Nombre Completo'
FROM estudiantes;

-- 2. Años para graduarse
SELECT 
    nombre,
    apellido,
    edad,
    18 - edad AS 'Años para Graduarse'
FROM estudiantes 
WHERE edad < 18;

-- 3. Nombres con muchas vocales
SELECT * FROM estudiantes 
WHERE (LENGTH(nombre) - LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(nombre), 'a', ''), 'e', ''), 'i', ''), 'o', ''), 'u', ''))) > 2;

-- 4. ID combinado
SELECT 
    nombre,
    apellido,
    CONCAT('G', grado, '-E', edad) AS 'ID Estudiante'
FROM estudiantes;

-- 5. Mes de nacimiento (ejemplo con fecha actual)
SELECT 
    nombre,
    apellido,
    MONTH(CURDATE()) AS 'Mes Actual'
FROM estudiantes;
```

### Ejercicio 4: Funciones con Platos
Usando la tabla `platos` del restaurante, escribe consultas que utilicen funciones para:

1. Mostrar nombre del plato en mayúsculas y precio con formato de moneda
2. Calcular el precio con propina del 15% y mostrarlo redondeado
3. Mostrar platos con descripción de más de 50 caracteres
4. Crear una etiqueta combinando categoría y precio
5. Mostrar solo la primera palabra del nombre de cada plato

**Solución:**
```sql
-- 1. Nombre en mayúsculas y precio formateado
SELECT 
    UPPER(nombre) AS 'Nombre del Plato',
    CONCAT('$', ROUND(precio, 2)) AS 'Precio'
FROM platos;

-- 2. Precio con propina
SELECT 
    nombre,
    precio,
    ROUND(precio * 1.15, 2) AS 'Precio con Propina'
FROM platos;

-- 3. Descripciones largas
SELECT * FROM platos 
WHERE LENGTH(descripcion) > 50;

-- 4. Etiqueta combinada
SELECT 
    nombre,
    CONCAT(categoria, ' - $', ROUND(precio, 2)) AS 'Etiqueta'
FROM platos;

-- 5. Primera palabra del nombre
SELECT 
    nombre,
    SUBSTRING_INDEX(nombre, ' ', 1) AS 'Primera Palabra'
FROM platos;
```

### Ejercicio 5: Funciones con Pacientes
Usando la tabla `pacientes` del hospital, escribe consultas que utilicen funciones para:

1. Mostrar nombre completo en formato "Nombre Apellido"
2. Calcular la edad exacta en años y meses
3. Mostrar pacientes con nombre que empiece con consonante
4. Crear un código de paciente combinando iniciales y año de nacimiento
5. Mostrar solo el día de la semana de nacimiento

**Solución:**
```sql
-- 1. Formato nombre completo
SELECT 
    CONCAT(nombre, ' ', apellido) AS 'Nombre Completo'
FROM pacientes;

-- 2. Edad exacta
SELECT 
    nombre,
    apellido,
    fecha_nacimiento,
    CONCAT(
        FLOOR(DATEDIFF(CURDATE(), fecha_nacimiento) / 365), ' años, ',
        FLOOR((DATEDIFF(CURDATE(), fecha_nacimiento) % 365) / 30), ' meses'
    ) AS 'Edad Exacta'
FROM pacientes;

-- 3. Nombres que empiecen con consonante
SELECT * FROM pacientes 
WHERE LOWER(SUBSTRING(nombre, 1, 1)) NOT IN ('a', 'e', 'i', 'o', 'u');

-- 4. Código de paciente
SELECT 
    nombre,
    apellido,
    CONCAT(
        UPPER(SUBSTRING(nombre, 1, 1)),
        UPPER(SUBSTRING(apellido, 1, 1)),
        '-',
        YEAR(fecha_nacimiento)
    ) AS 'Código de Paciente'
FROM pacientes;

-- 5. Día de la semana de nacimiento
SELECT 
    nombre,
    apellido,
    fecha_nacimiento,
    DAYNAME(fecha_nacimiento) AS 'Día de Nacimiento'
FROM pacientes;
```

## 📝 Resumen de Conceptos Clave
- ✅ Las funciones SQL procesan datos y retornan resultados
- ✅ CONCAT() une cadenas de texto
- ✅ UPPER()/LOWER() convierte mayúsculas/minúsculas
- ✅ ROUND() redondea números
- ✅ NOW() obtiene fecha y hora actual
- ✅ Las funciones se pueden combinar y usar en WHERE
- ✅ Las funciones de fecha son muy útiles para cálculos temporales

## 🔗 Próximo Nivel
¡Felicidades! Has completado el nivel Junior. Ahora continúa con `docs/midLevel_1` para aprender sobre JOINs y relaciones entre tablas.

---

**💡 Consejo: Practica usando diferentes funciones en tus consultas. Las funciones SQL te permiten manipular y presentar datos de manera más efectiva.**
