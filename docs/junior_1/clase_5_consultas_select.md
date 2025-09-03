# Clase 5: Consultas SELECT Avanzadas - Filtros y Ordenamiento

## 📚 Descripción de la Clase
En esta clase profundizaremos en el comando SELECT, aprendiendo a crear consultas más sofisticadas y útiles. Aprenderás a filtrar datos con precisión, ordenar resultados, limitar la cantidad de registros y usar alias para hacer tus consultas más legibles y profesionales.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Crear consultas SELECT con filtros avanzados
- Usar operadores de comparación y lógicos
- Ordenar resultados con ORDER BY
- Limitar resultados con LIMIT y OFFSET
- Usar alias para columnas y tablas
- Combinar múltiples condiciones en WHERE
- Crear consultas eficientes y legibles

## ⏱️ Duración Estimada
**2-3 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### El Comando SELECT - Fundamentos Avanzados

El comando **SELECT** es el más importante en SQL, ya que permite extraer información específica de las bases de datos. Una consulta SELECT bien estructurada puede responder preguntas complejas sobre los datos.

#### Sintaxis Completa de SELECT

```sql
SELECT [DISTINCT] columnas
FROM tabla
[WHERE condiciones]
[ORDER BY columnas [ASC|DESC]]
[LIMIT cantidad]
[OFFSET inicio];
```

**Explicación línea por línea:**
- `SELECT`: comando para consultar datos
- `[DISTINCT]`: palabra clave opcional para eliminar duplicados
- `columnas`: columnas que queremos ver (puede ser * para todas)
- `FROM tabla`: tabla de donde obtenemos los datos
- `[WHERE condiciones]`: condiciones opcionales para filtrar
- `[ORDER BY columnas]`: ordenamiento opcional de los resultados
- `[LIMIT cantidad]`: límite opcional de registros a mostrar
- `[OFFSET inicio]`: desplazamiento opcional para paginación

### 1. Filtros con WHERE - Operadores de Comparación

La cláusula **WHERE** permite filtrar registros basándose en condiciones específicas. Es fundamental para obtener solo los datos que necesitas.

#### Operadores de Comparación Básicos

##### 1. Igualdad (=)
```sql
-- Buscar productos de una categoría específica
SELECT nombre, precio 
FROM productos 
WHERE categoria = 'Electrónicos';
```

**Explicación línea por línea:**
- `SELECT nombre, precio`: solo queremos ver estas columnas
- `FROM productos`: de la tabla productos
- `WHERE categoria = 'Electrónicos'`: solo productos donde categoria sea igual a 'Electrónicos'
- `=`: operador de igualdad

##### 2. Desigualdad (!= o <>)
```sql
-- Buscar productos que NO sean de electrónicos
SELECT nombre, precio 
FROM productos 
WHERE categoria != 'Electrónicos';

-- Alternativa con <>
SELECT nombre, precio 
FROM productos 
WHERE categoria <> 'Electrónicos';
```

**Explicación línea por línea:**
- `WHERE categoria != 'Electrónicos'`: productos donde categoria NO sea igual a 'Electrónicos'
- `!=`: operador de desigualdad (también se puede usar `<>`)

##### 3. Mayor que (>)
```sql
-- Buscar productos caros
SELECT nombre, precio 
FROM productos 
WHERE precio > 100;
```

**Explicación línea por línea:**
- `WHERE precio > 100`: solo productos con precio mayor a 100
- `>`: operador "mayor que"

##### 4. Menor que (<)
```sql
-- Buscar productos baratos
SELECT nombre, precio 
FROM productos 
WHERE precio < 50;
```

**Explicación línea por línea:**
- `WHERE precio < 50`: solo productos con precio menor a 50
- `<`: operador "menor que"

##### 5. Mayor o igual que (>=)
```sql
-- Buscar productos con precio de 100 o más
SELECT nombre, precio 
FROM productos 
WHERE precio >= 100;
```

**Explicación línea por línea:**
- `WHERE precio >= 100`: productos con precio mayor o igual a 100
- `>=`: operador "mayor o igual que"

##### 6. Menor o igual que (<=)
```sql
-- Buscar productos con precio de 50 o menos
SELECT nombre, precio 
FROM productos 
WHERE precio <= 50;
```

**Explicación línea por línea:**
- `WHERE precio <= 50`: productos con precio menor o igual a 50
- `<=`: operador "menor o igual que"

### 2. Operadores Lógicos - Combinar Condiciones

Los operadores lógicos permiten combinar múltiples condiciones para crear filtros más complejos.

#### 1. AND (Y)
```sql
-- Buscar productos de electrónicos Y con precio mayor a 200
SELECT nombre, precio, categoria 
FROM productos 
WHERE categoria = 'Electrónicos' AND precio > 200;
```

**Explicación línea por línea:**
- `WHERE categoria = 'Electrónicos' AND precio > 200`: productos que cumplan AMBAS condiciones
- `AND`: operador lógico que significa "y también"
- Ambas condiciones deben ser verdaderas para que el registro se incluya

#### 2. OR (O)
```sql
-- Buscar productos de electrónicos O con precio mayor a 200
SELECT nombre, precio, categoria 
FROM productos 
WHERE categoria = 'Electrónicos' OR precio > 200;
```

**Explicación línea por línea:**
- `WHERE categoria = 'Electrónicos' OR precio > 200`: productos que cumplan AL MENOS UNA de las condiciones
- `OR`: operador lógico que significa "o"
- Si cualquiera de las condiciones es verdadera, el registro se incluye

#### 3. NOT (NO)
```sql
-- Buscar productos que NO sean de electrónicos
SELECT nombre, precio, categoria 
FROM productos 
WHERE NOT categoria = 'Electrónicos';
```

**Explicación línea por línea:**
- `WHERE NOT categoria = 'Electrónicos'`: productos donde la condición NO sea verdadera
- `NOT`: operador lógico que niega la condición
- Incluye todos los productos excepto los de electrónicos

### 3. Operadores Especiales

#### 1. BETWEEN (Entre)
```sql
-- Buscar productos con precio entre 50 y 200
SELECT nombre, precio 
FROM productos 
WHERE precio BETWEEN 50 AND 200;
```

**Explicación línea por línea:**
- `WHERE precio BETWEEN 50 AND 200`: productos con precio entre 50 y 200 (incluyendo los límites)
- `BETWEEN`: operador que significa "entre" (incluye los valores límite)
- Equivale a: `WHERE precio >= 50 AND precio <= 200`

#### 2. IN (En)
```sql
-- Buscar productos de categorías específicas
SELECT nombre, precio, categoria 
FROM productos 
WHERE categoria IN ('Electrónicos', 'Accesorios', 'Ropa');
```

**Explicación línea por línea:**
- `WHERE categoria IN ('Electrónicos', 'Accesorios', 'Ropa')`: productos cuya categoría esté en la lista
- `IN`: operador que significa "en" o "pertenece a"
- Equivale a: `WHERE categoria = 'Electrónicos' OR categoria = 'Accesorios' OR categoria = 'Ropa'`

#### 3. LIKE (Como)
```sql
-- Buscar productos cuyo nombre contenga "Laptop"
SELECT nombre, precio 
FROM productos 
WHERE nombre LIKE '%Laptop%';
```

**Explicación línea por línea:**
- `WHERE nombre LIKE '%Laptop%'`: productos cuyo nombre contenga "Laptop" en cualquier posición
- `LIKE`: operador para búsquedas de texto con patrones
- `%`: comodín que representa cualquier cantidad de caracteres (incluyendo cero)

##### Patrones con LIKE:
```sql
-- Productos que empiecen con "L"
SELECT nombre FROM productos WHERE nombre LIKE 'L%';

-- Productos que terminen con "Pro"
SELECT nombre FROM productos WHERE nombre LIKE '%Pro';

-- Productos con exactamente 5 caracteres
SELECT nombre FROM productos WHERE nombre LIKE '_____';

-- Productos que empiecen con "L" y terminen con "o"
SELECT nombre FROM productos WHERE nombre LIKE 'L%o';
```

**Explicación de patrones:**
- `'L%'`: empieza con "L" seguido de cualquier cosa
- `'%Pro'`: termina con "Pro" precedido de cualquier cosa
- `'_____'`: exactamente 5 caracteres (cada _ representa un carácter)
- `'L%o'`: empieza con "L" y termina con "o"

#### 4. IS NULL / IS NOT NULL
```sql
-- Buscar productos sin descripción
SELECT nombre, descripcion 
FROM productos 
WHERE descripcion IS NULL;

-- Buscar productos con descripción
SELECT nombre, descripcion 
FROM productos 
WHERE descripcion IS NOT NULL;
```

**Explicación línea por línea:**
- `WHERE descripcion IS NULL`: productos donde descripcion sea nula (vacía)
- `IS NULL`: operador para verificar valores nulos
- `WHERE descripcion IS NOT NULL`: productos donde descripcion NO sea nula
- `IS NOT NULL`: operador para verificar valores no nulos

### 4. Ordenamiento con ORDER BY

La cláusula **ORDER BY** permite ordenar los resultados de una consulta.

#### Sintaxis de ORDER BY

```sql
SELECT columnas
FROM tabla
WHERE condiciones
ORDER BY columna1 [ASC|DESC], columna2 [ASC|DESC], ...;
```

**Explicación línea por línea:**
- `ORDER BY`: cláusula para ordenar resultados
- `columna1`: primera columna por la que ordenar
- `[ASC|DESC]`: dirección del ordenamiento (ASC = ascendente, DESC = descendente)
- `, columna2`: segunda columna para ordenamiento secundario

#### Ejemplos de ORDER BY

##### 1. Ordenamiento Ascendente (ASC)
```sql
-- Ordenar productos por precio (menor a mayor)
SELECT nombre, precio 
FROM productos 
ORDER BY precio ASC;
```

**Explicación línea por línea:**
- `ORDER BY precio ASC`: ordenar por precio de menor a mayor
- `ASC`: ascendente (por defecto, se puede omitir)

##### 2. Ordenamiento Descendente (DESC)
```sql
-- Ordenar productos por precio (mayor a menor)
SELECT nombre, precio 
FROM productos 
ORDER BY precio DESC;
```

**Explicación línea por línea:**
- `ORDER BY precio DESC`: ordenar por precio de mayor a menor
- `DESC`: descendente

##### 3. Ordenamiento Múltiple
```sql
-- Ordenar por categoría y luego por precio
SELECT nombre, categoria, precio 
FROM productos 
ORDER BY categoria ASC, precio DESC;
```

**Explicación línea por línea:**
- `ORDER BY categoria ASC, precio DESC`: ordenar primero por categoría (A-Z), luego por precio (mayor a menor)
- Cuando hay empates en la primera columna, se usa la segunda para desempatar

### 5. Límites con LIMIT y OFFSET

#### LIMIT - Limitar Resultados
```sql
-- Mostrar solo los 5 productos más caros
SELECT nombre, precio 
FROM productos 
ORDER BY precio DESC 
LIMIT 5;
```

**Explicación línea por línea:**
- `ORDER BY precio DESC`: ordenar por precio de mayor a menor
- `LIMIT 5`: mostrar solo los primeros 5 resultados

#### OFFSET - Saltar Registros
```sql
-- Mostrar productos del 6 al 10 más caros
SELECT nombre, precio 
FROM productos 
ORDER BY precio DESC 
LIMIT 5 OFFSET 5;
```

**Explicación línea por línea:**
- `ORDER BY precio DESC`: ordenar por precio de mayor a menor
- `LIMIT 5`: mostrar 5 resultados
- `OFFSET 5`: saltar los primeros 5 resultados

### 6. Alias - Nombres Alternativos

Los **alias** permiten dar nombres alternativos a columnas y tablas, haciendo las consultas más legibles.

#### Alias para Columnas
```sql
-- Usar alias para columnas
SELECT 
    nombre AS producto,
    precio AS precio_unitario,
    stock AS cantidad_disponible
FROM productos;
```

**Explicación línea por línea:**
- `nombre AS producto`: columna nombre con alias "producto"
- `precio AS precio_unitario`: columna precio con alias "precio_unitario"
- `stock AS cantidad_disponible`: columna stock con alias "cantidad_disponible"
- `AS`: palabra clave para definir alias (opcional)

#### Alias para Tablas
```sql
-- Usar alias para tablas
SELECT p.nombre, p.precio, p.categoria
FROM productos p
WHERE p.precio > 100;
```

**Explicación línea por línea:**
- `FROM productos p`: tabla productos con alias "p"
- `p.nombre`: columna nombre de la tabla p (productos)
- `p.precio`: columna precio de la tabla p (productos)
- `p.categoria`: columna categoria de la tabla p (productos)

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Sistema de Consultas de Productos

```sql
-- Crear base de datos para el ejemplo
CREATE DATABASE consultas_productos;
USE consultas_productos;

-- Crear tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    categoria VARCHAR(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
('Laptop HP Pavilion', 'Laptop de 15 pulgadas con procesador Intel i5', 899.99, 10, 'Electrónicos'),
('Mouse Logitech', 'Mouse óptico inalámbrico', 25.50, 50, 'Accesorios'),
('Teclado Mecánico RGB', 'Teclado mecánico con iluminación RGB', 89.99, 15, 'Accesorios'),
('Monitor Samsung 24"', 'Monitor LED de 24 pulgadas Full HD', 199.99, 8, 'Electrónicos'),
('Auriculares Sony WH-1000XM4', 'Auriculares inalámbricos con cancelación de ruido', 349.99, 20, 'Accesorios'),
('Tablet iPad Air', 'Tablet Apple de 10.9 pulgadas', 599.99, 12, 'Electrónicos'),
('Cargador USB-C 65W', 'Cargador rápido de 65W para laptop', 29.99, 30, 'Accesorios'),
('Smartphone iPhone 14', 'Smartphone Apple con cámara de 48MP', 999.99, 5, 'Electrónicos'),
('Cámara Canon EOS R5', 'Cámara mirrorless profesional', 3899.99, 3, 'Electrónicos'),
('Impresora HP LaserJet', 'Impresora láser monocromática', 149.99, 7, 'Electrónicos');
```

### Ejemplo 2: Consultas con Filtros Avanzados

```sql
-- Consulta 1: Productos de electrónicos con precio mayor a 500
SELECT nombre, precio, stock
FROM productos
WHERE categoria = 'Electrónicos' AND precio > 500;

-- Explicación línea por línea:
-- SELECT nombre, precio, stock: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE categoria = 'Electrónicos' AND precio > 500: productos de electrónicos Y precio mayor a 500
-- AND: operador lógico que significa "y también"

-- Consulta 2: Productos con precio entre 50 y 200
SELECT nombre, precio, categoria
FROM productos
WHERE precio BETWEEN 50 AND 200;

-- Explicación línea por línea:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE precio BETWEEN 50 AND 200: productos con precio entre 50 y 200 (incluyendo límites)
-- BETWEEN: operador que significa "entre"

-- Consulta 3: Productos de categorías específicas
SELECT nombre, precio, categoria
FROM productos
WHERE categoria IN ('Electrónicos', 'Accesorios');

-- Explicación línea por línea:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE categoria IN ('Electrónicos', 'Accesorios'): productos cuya categoría esté en la lista
-- IN: operador que significa "en" o "pertenece a"

-- Consulta 4: Productos cuyo nombre contenga "HP"
SELECT nombre, precio, categoria
FROM productos
WHERE nombre LIKE '%HP%';

-- Explicación línea por línea:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE nombre LIKE '%HP%': productos cuyo nombre contenga "HP" en cualquier posición
-- LIKE: operador para búsquedas de texto con patrones
-- %: comodín que representa cualquier cantidad de caracteres

-- Consulta 5: Productos sin descripción
SELECT nombre, precio, categoria
FROM productos
WHERE descripcion IS NULL;

-- Explicación línea por línea:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE descripcion IS NULL: productos donde descripcion sea nula
-- IS NULL: operador para verificar valores nulos
```

### Ejemplo 3: Consultas con Ordenamiento y Límites

```sql
-- Consulta 1: Los 5 productos más caros
SELECT nombre, precio, categoria
FROM productos
ORDER BY precio DESC
LIMIT 5;

-- Explicación línea por línea:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY precio DESC: ordenar por precio de mayor a menor
-- DESC: descendente
-- LIMIT 5: mostrar solo los primeros 5 resultados

-- Consulta 2: Productos ordenados por categoría y precio
SELECT nombre, categoria, precio
FROM productos
ORDER BY categoria ASC, precio DESC;

-- Explicación línea por línea:
-- SELECT nombre, categoria, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY categoria ASC, precio DESC: ordenar primero por categoría (A-Z), luego por precio (mayor a menor)
-- ASC: ascendente (por defecto)
-- DESC: descendente

-- Consulta 3: Productos del 6 al 10 más caros (paginación)
SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 5 OFFSET 5;

-- Explicación línea por línea:
-- SELECT nombre, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY precio DESC: ordenar por precio de mayor a menor
-- LIMIT 5: mostrar 5 resultados
-- OFFSET 5: saltar los primeros 5 resultados

-- Consulta 4: Productos con stock bajo, ordenados por stock
SELECT nombre, stock, precio
FROM productos
WHERE stock < 10
ORDER BY stock ASC;

-- Explicación línea por línea:
-- SELECT nombre, stock, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE stock < 10: solo productos con stock menor a 10
-- ORDER BY stock ASC: ordenar por stock de menor a mayor
-- ASC: ascendente
```

### Ejemplo 4: Consultas con Alias

```sql
-- Consulta 1: Usar alias para columnas
SELECT 
    nombre AS producto,
    precio AS precio_unitario,
    stock AS cantidad_disponible,
    categoria AS tipo_producto
FROM productos
WHERE precio > 100;

-- Explicación línea por línea:
-- SELECT: comando para consultar
-- nombre AS producto: columna nombre con alias "producto"
-- precio AS precio_unitario: columna precio con alias "precio_unitario"
-- stock AS cantidad_disponible: columna stock con alias "cantidad_disponible"
-- categoria AS tipo_producto: columna categoria con alias "tipo_producto"
-- FROM productos: de la tabla productos
-- WHERE precio > 100: solo productos con precio mayor a 100

-- Consulta 2: Usar alias para tablas
SELECT p.nombre, p.precio, p.categoria
FROM productos p
WHERE p.precio BETWEEN 50 AND 500
ORDER BY p.precio DESC;

-- Explicación línea por línea:
-- SELECT p.nombre, p.precio, p.categoria: columnas de la tabla p (productos)
-- FROM productos p: tabla productos con alias "p"
-- WHERE p.precio BETWEEN 50 AND 500: productos con precio entre 50 y 500
-- ORDER BY p.precio DESC: ordenar por precio de mayor a menor

-- Consulta 3: Alias con cálculos
SELECT 
    nombre AS producto,
    precio AS precio_original,
    (precio * 1.21) AS precio_con_iva,
    stock AS cantidad
FROM productos
WHERE categoria = 'Electrónicos';

-- Explicación línea por línea:
-- SELECT: comando para consultar
-- nombre AS producto: columna nombre con alias "producto"
-- precio AS precio_original: columna precio con alias "precio_original"
-- (precio * 1.21) AS precio_con_iva: cálculo del precio con IVA (21%) con alias
-- stock AS cantidad: columna stock con alias "cantidad"
-- FROM productos: de la tabla productos
-- WHERE categoria = 'Electrónicos': solo productos de electrónicos
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Consultas de Filtrado
**Objetivo**: Practicar diferentes tipos de filtros con WHERE.

**Instrucciones**:
Usando la tabla `productos` del ejemplo anterior, crea las siguientes consultas:
1. Productos con precio mayor a 300
2. Productos de accesorios con stock mayor a 20
3. Productos cuyo nombre empiece con "L"
4. Productos con precio entre 100 y 500

**Solución paso a paso:**

```sql
-- Consulta 1: Productos con precio mayor a 300
SELECT nombre, precio, categoria
FROM productos
WHERE precio > 300;

-- Explicación:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE precio > 300: solo productos con precio mayor a 300
-- >: operador "mayor que"

-- Consulta 2: Productos de accesorios con stock mayor a 20
SELECT nombre, stock, precio
FROM productos
WHERE categoria = 'Accesorios' AND stock > 20;

-- Explicación:
-- SELECT nombre, stock, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE categoria = 'Accesorios' AND stock > 20: productos de accesorios Y stock mayor a 20
-- AND: operador lógico que significa "y también"

-- Consulta 3: Productos cuyo nombre empiece con "L"
SELECT nombre, precio, categoria
FROM productos
WHERE nombre LIKE 'L%';

-- Explicación:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE nombre LIKE 'L%': productos cuyo nombre empiece con "L"
-- LIKE: operador para búsquedas de texto con patrones
-- 'L%': patrón que significa "empieza con L seguido de cualquier cosa"

-- Consulta 4: Productos con precio entre 100 y 500
SELECT nombre, precio, categoria
FROM productos
WHERE precio BETWEEN 100 AND 500;

-- Explicación:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE precio BETWEEN 100 AND 500: productos con precio entre 100 y 500 (incluyendo límites)
-- BETWEEN: operador que significa "entre"
```

### Ejercicio 2: Ordenamiento y Límites
**Objetivo**: Practicar ORDER BY, LIMIT y OFFSET.

**Instrucciones**:
1. Los 3 productos más baratos
2. Productos ordenados por categoría (A-Z) y luego por precio (mayor a menor)
3. Productos del 4 al 6 más caros
4. Productos con stock bajo ordenados por stock

**Solución paso a paso:**

```sql
-- Consulta 1: Los 3 productos más baratos
SELECT nombre, precio, categoria
FROM productos
ORDER BY precio ASC
LIMIT 3;

-- Explicación:
-- SELECT nombre, precio, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY precio ASC: ordenar por precio de menor a mayor
-- ASC: ascendente
-- LIMIT 3: mostrar solo los primeros 3 resultados

-- Consulta 2: Productos ordenados por categoría y precio
SELECT nombre, categoria, precio
FROM productos
ORDER BY categoria ASC, precio DESC;

-- Explicación:
-- SELECT nombre, categoria, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY categoria ASC, precio DESC: ordenar primero por categoría (A-Z), luego por precio (mayor a menor)
-- ASC: ascendente (por defecto)
-- DESC: descendente

-- Consulta 3: Productos del 4 al 6 más caros
SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 3 OFFSET 3;

-- Explicación:
-- SELECT nombre, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY precio DESC: ordenar por precio de mayor a menor
-- LIMIT 3: mostrar 3 resultados
-- OFFSET 3: saltar los primeros 3 resultados

-- Consulta 4: Productos con stock bajo ordenados por stock
SELECT nombre, stock, precio
FROM productos
WHERE stock < 10
ORDER BY stock ASC;

-- Explicación:
-- SELECT nombre, stock, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE stock < 10: solo productos con stock menor a 10
-- ORDER BY stock ASC: ordenar por stock de menor a mayor
-- ASC: ascendente
```

### Ejercicio 3: Consultas con Alias y Cálculos
**Objetivo**: Practicar el uso de alias y cálculos en consultas.

**Instrucciones**:
1. Productos con alias para columnas
2. Calcular el valor total del inventario por producto
3. Productos con descuento del 10% aplicado
4. Usar alias para tablas en consultas complejas

**Solución paso a paso:**

```sql
-- Consulta 1: Productos con alias para columnas
SELECT 
    nombre AS producto,
    precio AS precio_unitario,
    stock AS cantidad_disponible,
    categoria AS tipo
FROM productos
WHERE precio > 200;

-- Explicación:
-- SELECT: comando para consultar
-- nombre AS producto: columna nombre con alias "producto"
-- precio AS precio_unitario: columna precio con alias "precio_unitario"
-- stock AS cantidad_disponible: columna stock con alias "cantidad_disponible"
-- categoria AS tipo: columna categoria con alias "tipo"
-- FROM productos: de la tabla productos
-- WHERE precio > 200: solo productos con precio mayor a 200

-- Consulta 2: Valor total del inventario por producto
SELECT 
    nombre AS producto,
    precio AS precio_unitario,
    stock AS cantidad,
    (precio * stock) AS valor_total_inventario
FROM productos
ORDER BY valor_total_inventario DESC;

-- Explicación:
-- SELECT: comando para consultar
-- nombre AS producto: columna nombre con alias "producto"
-- precio AS precio_unitario: columna precio con alias "precio_unitario"
-- stock AS cantidad: columna stock con alias "cantidad"
-- (precio * stock) AS valor_total_inventario: cálculo del valor total con alias
-- FROM productos: de la tabla productos
-- ORDER BY valor_total_inventario DESC: ordenar por valor total de mayor a menor

-- Consulta 3: Productos con descuento del 10%
SELECT 
    nombre AS producto,
    precio AS precio_original,
    (precio * 0.9) AS precio_con_descuento,
    (precio - (precio * 0.9)) AS ahorro
FROM productos
WHERE categoria = 'Electrónicos';

-- Explicación:
-- SELECT: comando para consultar
-- nombre AS producto: columna nombre con alias "producto"
-- precio AS precio_original: columna precio con alias "precio_original"
-- (precio * 0.9) AS precio_con_descuento: precio con 10% de descuento
-- (precio - (precio * 0.9)) AS ahorro: cantidad ahorrada
-- FROM productos: de la tabla productos
-- WHERE categoria = 'Electrónicos': solo productos de electrónicos

-- Consulta 4: Usar alias para tablas
SELECT p.nombre, p.precio, p.stock
FROM productos p
WHERE p.categoria IN ('Electrónicos', 'Accesorios')
  AND p.precio BETWEEN 50 AND 1000
ORDER BY p.categoria ASC, p.precio DESC;

-- Explicación:
-- SELECT p.nombre, p.precio, p.stock: columnas de la tabla p (productos)
-- FROM productos p: tabla productos con alias "p"
-- WHERE p.categoria IN ('Electrónicos', 'Accesorios'): categorías específicas
-- AND p.precio BETWEEN 50 AND 1000: precio entre 50 y 1000
-- ORDER BY p.categoria ASC, p.precio DESC: ordenar por categoría y precio
```

---

## 📝 Resumen de Conceptos Clave

### Operadores de Comparación:
- `=`: Igualdad
- `!=` o `<>`: Desigualdad
- `>`: Mayor que
- `<`: Menor que
- `>=`: Mayor o igual que
- `<=`: Menor o igual que

### Operadores Lógicos:
- `AND`: Y (ambas condiciones deben ser verdaderas)
- `OR`: O (al menos una condición debe ser verdadera)
- `NOT`: NO (niega la condición)

### Operadores Especiales:
- `BETWEEN`: Entre dos valores (incluye límites)
- `IN`: En una lista de valores
- `LIKE`: Búsqueda de texto con patrones
- `IS NULL`: Verificar valores nulos
- `IS NOT NULL`: Verificar valores no nulos

### Patrones con LIKE:
- `%`: Cualquier cantidad de caracteres
- `_`: Exactamente un carácter
- `'L%'`: Empieza con "L"
- `'%Pro'`: Termina con "Pro"
- `'%HP%'`: Contiene "HP"

### Ordenamiento:
- `ORDER BY columna ASC`: Ascendente (menor a mayor)
- `ORDER BY columna DESC`: Descendente (mayor a menor)
- `ORDER BY col1, col2`: Ordenamiento múltiple

### Límites:
- `LIMIT n`: Mostrar solo n registros
- `OFFSET n`: Saltar n registros
- `LIMIT n OFFSET m`: Mostrar n registros saltando m

### Alias:
- `columna AS alias`: Alias para columnas
- `tabla alias`: Alias para tablas
- `AS` es opcional en la mayoría de casos

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Funciones básicas de SQL
- Funciones de texto (CONCAT, UPPER, LOWER)
- Funciones numéricas (SUM, AVG, COUNT)
- Funciones de fecha (NOW, DATE, YEAR)

---

## 💡 Consejos para el Éxito

1. **Practica con datos reales**: Usa ejemplos que te interesen
2. **Combina operadores**: Experimenta con múltiples condiciones
3. **Usa alias descriptivos**: Hace las consultas más legibles
4. **Ordena tus resultados**: Siempre que sea relevante
5. **Prueba diferentes patrones**: Experimenta con LIKE y otros operadores

---

## 🧭 Navegación

**← Anterior**: [Clase 4: Operaciones Básicas CRUD](clase_4_operaciones_basicas.md)  
**Siguiente →**: [Clase 6: Funciones Básicas de SQL](clase_6_funciones_basicas.md)

---

*¡Excelente trabajo! Ahora dominas las consultas SELECT avanzadas. 🚀*
