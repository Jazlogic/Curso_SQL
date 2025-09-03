# Clase 8: Ordenamiento y Agrupación - Organizando y Resumiendo Datos

## 📚 Descripción de la Clase
En esta clase aprenderás a organizar y resumir datos usando ORDER BY para ordenar resultados y GROUP BY para agrupar registros. También dominarás las funciones agregadas básicas como COUNT, SUM, AVG, MIN y MAX, que te permitirán realizar cálculos estadísticos y crear reportes más informativos.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Ordenar resultados con ORDER BY (ascendente y descendente)
- Agrupar registros con GROUP BY
- Usar funciones agregadas básicas (COUNT, SUM, AVG, MIN, MAX)
- Combinar ordenamiento y agrupación
- Crear consultas con múltiples niveles de agrupación
- Filtrar grupos con HAVING
- Optimizar consultas con ordenamiento y agrupación

## ⏱️ Duración Estimada
**3-4 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué es el Ordenamiento y Agrupación?

El **ordenamiento** y **agrupación** son técnicas fundamentales en SQL que permiten:

- **Ordenamiento (ORDER BY)**: Organizar los resultados en un orden específico
- **Agrupación (GROUP BY)**: Agrupar registros similares para análisis
- **Funciones Agregadas**: Realizar cálculos sobre grupos de datos
- **Filtrado de Grupos (HAVING)**: Filtrar grupos basándose en condiciones

### Sintaxis General de Ordenamiento

```sql
SELECT columnas
FROM tabla
WHERE condicion
ORDER BY columna [ASC|DESC];
```

**Explicación línea por línea:**
- `SELECT columnas`: columnas a mostrar
- `FROM tabla`: tabla de donde obtener los datos
- `WHERE condicion`: condición para filtrar (opcional)
- `ORDER BY columna`: columna por la cual ordenar
- `[ASC|DESC]`: orden ascendente (por defecto) o descendente

### Sintaxis General de Agrupación

```sql
SELECT columna_agrupacion, funcion_agregada(columna)
FROM tabla
WHERE condicion
GROUP BY columna_agrupacion
HAVING condicion_grupo
ORDER BY columna;
```

**Explicación línea por línea:**
- `SELECT columna_agrupacion`: columna por la cual agrupar
- `funcion_agregada(columna)`: función agregada a aplicar
- `FROM tabla`: tabla de donde obtener los datos
- `WHERE condicion`: condición para filtrar registros (opcional)
- `GROUP BY columna_agrupacion`: agrupa por esta columna
- `HAVING condicion_grupo`: filtra grupos (opcional)
- `ORDER BY columna`: ordena resultados (opcional)

### 1. Ordenamiento con ORDER BY

El ordenamiento permite organizar los resultados en un orden específico.

#### 1.1 Ordenamiento Ascendente (ASC)
```sql
-- Ordenar por nombre ascendente (A-Z)
SELECT * FROM productos ORDER BY nombre ASC;

-- Ordenar por precio ascendente (menor a mayor)
SELECT * FROM productos ORDER BY precio ASC;

-- Ordenar por fecha ascendente (más antiguo a más reciente)
SELECT * FROM productos ORDER BY fecha_creacion ASC;
```

**Explicación línea por línea:**
- `ORDER BY nombre ASC`: ordena por nombre en orden ascendente
- `ASC`: orden ascendente (por defecto, se puede omitir)
- `ORDER BY precio ASC`: ordena por precio de menor a mayor
- `ORDER BY fecha_creacion ASC`: ordena por fecha de más antiguo a más reciente

#### 1.2 Ordenamiento Descendente (DESC)
```sql
-- Ordenar por nombre descendente (Z-A)
SELECT * FROM productos ORDER BY nombre DESC;

-- Ordenar por precio descendente (mayor a menor)
SELECT * FROM productos ORDER BY precio DESC;

-- Ordenar por fecha descendente (más reciente a más antiguo)
SELECT * FROM productos ORDER BY fecha_creacion DESC;
```

**Explicación línea por línea:**
- `ORDER BY nombre DESC`: ordena por nombre en orden descendente
- `DESC`: orden descendente (debe especificarse)
- `ORDER BY precio DESC`: ordena por precio de mayor a menor
- `ORDER BY fecha_creacion DESC`: ordena por fecha de más reciente a más antiguo

#### 1.3 Ordenamiento Múltiple
```sql
-- Ordenar por categoría y luego por precio
SELECT * FROM productos ORDER BY categoria ASC, precio DESC;

-- Ordenar por marca, categoría y precio
SELECT * FROM productos ORDER BY marca ASC, categoria ASC, precio DESC;

-- Ordenar por stock descendente y nombre ascendente
SELECT * FROM productos ORDER BY stock DESC, nombre ASC;
```

**Explicación línea por línea:**
- `ORDER BY categoria ASC, precio DESC`: ordena por categoría ascendente, luego por precio descendente
- `ORDER BY marca ASC, categoria ASC, precio DESC`: ordena por marca, categoría y precio
- `ORDER BY stock DESC, nombre ASC`: ordena por stock descendente, luego por nombre ascendente

#### 1.4 Ordenamiento con Funciones
```sql
-- Ordenar por longitud del nombre
SELECT * FROM productos ORDER BY LENGTH(nombre) DESC;

-- Ordenar por año de creación
SELECT * FROM productos ORDER BY YEAR(fecha_creacion) DESC;

-- Ordenar por precio redondeado
SELECT * FROM productos ORDER BY ROUND(precio) DESC;
```

**Explicación línea por línea:**
- `ORDER BY LENGTH(nombre) DESC`: ordena por longitud del nombre
- `ORDER BY YEAR(fecha_creacion) DESC`: ordena por año de creación
- `ORDER BY ROUND(precio) DESC`: ordena por precio redondeado

### 2. Agrupación con GROUP BY

La agrupación permite agrupar registros similares para análisis.

#### 2.1 Agrupación Básica
```sql
-- Agrupar por categoría
SELECT categoria, COUNT(*) FROM productos GROUP BY categoria;

-- Agrupar por marca
SELECT marca, COUNT(*) FROM productos GROUP BY marca;

-- Agrupar por año de creación
SELECT YEAR(fecha_creacion) as año, COUNT(*) FROM productos GROUP BY YEAR(fecha_creacion);
```

**Explicación línea por línea:**
- `GROUP BY categoria`: agrupa registros por categoría
- `COUNT(*)`: cuenta el número de registros en cada grupo
- `GROUP BY marca`: agrupa registros por marca
- `GROUP BY YEAR(fecha_creacion)`: agrupa por año de creación

#### 2.2 Agrupación Múltiple
```sql
-- Agrupar por categoría y marca
SELECT categoria, marca, COUNT(*) FROM productos GROUP BY categoria, marca;

-- Agrupar por categoría y año
SELECT categoria, YEAR(fecha_creacion) as año, COUNT(*) FROM productos GROUP BY categoria, YEAR(fecha_creacion);

-- Agrupar por marca y categoría
SELECT marca, categoria, COUNT(*) FROM productos GROUP BY marca, categoria;
```

**Explicación línea por línea:**
- `GROUP BY categoria, marca`: agrupa por categoría y marca
- `GROUP BY categoria, YEAR(fecha_creacion)`: agrupa por categoría y año
- `GROUP BY marca, categoria`: agrupa por marca y categoría

### 3. Funciones Agregadas Básicas

Las funciones agregadas realizan cálculos sobre grupos de datos.

#### 3.1 COUNT - Contar Registros
```sql
-- Contar total de productos
SELECT COUNT(*) FROM productos;

-- Contar productos por categoría
SELECT categoria, COUNT(*) FROM productos GROUP BY categoria;

-- Contar productos con stock
SELECT COUNT(stock) FROM productos WHERE stock > 0;

-- Contar productos únicos por marca
SELECT marca, COUNT(DISTINCT nombre) FROM productos GROUP BY marca;
```

**Explicación línea por línea:**
- `COUNT(*)`: cuenta todos los registros
- `COUNT(stock)`: cuenta registros donde stock no sea NULL
- `COUNT(DISTINCT nombre)`: cuenta nombres únicos
- `GROUP BY categoria`: agrupa por categoría

#### 3.2 SUM - Sumar Valores
```sql
-- Sumar total de stock
SELECT SUM(stock) FROM productos;

-- Sumar stock por categoría
SELECT categoria, SUM(stock) FROM productos GROUP BY categoria;

-- Sumar valor total del inventario
SELECT SUM(precio * stock) FROM productos;

-- Sumar stock por marca
SELECT marca, SUM(stock) FROM productos GROUP BY marca;
```

**Explicación línea por línea:**
- `SUM(stock)`: suma todos los valores de stock
- `SUM(precio * stock)`: suma el valor total del inventario
- `GROUP BY categoria`: agrupa por categoría
- `GROUP BY marca`: agrupa por marca

#### 3.3 AVG - Promedio
```sql
-- Promedio de precios
SELECT AVG(precio) FROM productos;

-- Promedio de precios por categoría
SELECT categoria, AVG(precio) FROM productos GROUP BY categoria;

-- Promedio de stock por marca
SELECT marca, AVG(stock) FROM productos GROUP BY marca;

-- Promedio redondeado
SELECT categoria, ROUND(AVG(precio), 2) FROM productos GROUP BY categoria;
```

**Explicación línea por línea:**
- `AVG(precio)`: calcula el promedio de precios
- `AVG(stock)`: calcula el promedio de stock
- `ROUND(AVG(precio), 2)`: redondea el promedio a 2 decimales
- `GROUP BY categoria`: agrupa por categoría

#### 3.4 MIN y MAX - Valores Mínimos y Máximos
```sql
-- Precio mínimo y máximo
SELECT MIN(precio), MAX(precio) FROM productos;

-- Precio mínimo y máximo por categoría
SELECT categoria, MIN(precio), MAX(precio) FROM productos GROUP BY categoria;

-- Stock mínimo y máximo por marca
SELECT marca, MIN(stock), MAX(stock) FROM productos GROUP BY marca;

-- Producto más caro y más barato
SELECT MIN(nombre), MAX(nombre) FROM productos;
```

**Explicación línea por línea:**
- `MIN(precio)`: encuentra el precio mínimo
- `MAX(precio)`: encuentra el precio máximo
- `MIN(stock)`: encuentra el stock mínimo
- `MAX(stock)`: encuentra el stock máximo

### 4. Filtrado de Grupos con HAVING

HAVING permite filtrar grupos basándose en condiciones.

#### 4.1 HAVING Básico
```sql
-- Categorías con más de 2 productos
SELECT categoria, COUNT(*) FROM productos GROUP BY categoria HAVING COUNT(*) > 2;

-- Marcas con stock total mayor a 50
SELECT marca, SUM(stock) FROM productos GROUP BY marca HAVING SUM(stock) > 50;

-- Categorías con precio promedio mayor a 100
SELECT categoria, AVG(precio) FROM productos GROUP BY categoria HAVING AVG(precio) > 100;
```

**Explicación línea por línea:**
- `HAVING COUNT(*) > 2`: filtra grupos con más de 2 productos
- `HAVING SUM(stock) > 50`: filtra grupos con stock total mayor a 50
- `HAVING AVG(precio) > 100`: filtra grupos con precio promedio mayor a 100

#### 4.2 HAVING con Múltiples Condiciones
```sql
-- Categorías con más de 2 productos y precio promedio mayor a 100
SELECT categoria, COUNT(*), AVG(precio) FROM productos 
GROUP BY categoria 
HAVING COUNT(*) > 2 AND AVG(precio) > 100;

-- Marcas con stock total entre 20 y 100
SELECT marca, SUM(stock) FROM productos 
GROUP BY marca 
HAVING SUM(stock) BETWEEN 20 AND 100;
```

**Explicación línea por línea:**
- `HAVING COUNT(*) > 2 AND AVG(precio) > 100`: múltiples condiciones
- `HAVING SUM(stock) BETWEEN 20 AND 100`: rango de valores
- `GROUP BY categoria`: agrupa por categoría

### 5. Combinación de Ordenamiento y Agrupación

Se pueden combinar ordenamiento y agrupación para crear consultas más complejas.

#### 5.1 Agrupación con Ordenamiento
```sql
-- Categorías ordenadas por número de productos
SELECT categoria, COUNT(*) FROM productos 
GROUP BY categoria 
ORDER BY COUNT(*) DESC;

-- Marcas ordenadas por stock total
SELECT marca, SUM(stock) FROM productos 
GROUP BY marca 
ORDER BY SUM(stock) DESC;

-- Categorías ordenadas por precio promedio
SELECT categoria, AVG(precio) FROM productos 
GROUP BY categoria 
ORDER BY AVG(precio) DESC;
```

**Explicación línea por línea:**
- `GROUP BY categoria`: agrupa por categoría
- `ORDER BY COUNT(*) DESC`: ordena por número de productos descendente
- `ORDER BY SUM(stock) DESC`: ordena por stock total descendente
- `ORDER BY AVG(precio) DESC`: ordena por precio promedio descendente

#### 5.2 Consultas Complejas
```sql
-- Top 3 categorías por número de productos
SELECT categoria, COUNT(*) as total_productos FROM productos 
GROUP BY categoria 
ORDER BY COUNT(*) DESC 
LIMIT 3;

-- Marcas con stock total mayor a 30, ordenadas por stock
SELECT marca, SUM(stock) as stock_total FROM productos 
GROUP BY marca 
HAVING SUM(stock) > 30 
ORDER BY SUM(stock) DESC;

-- Categorías con precio promedio mayor a 100, ordenadas por precio
SELECT categoria, AVG(precio) as precio_promedio FROM productos 
GROUP BY categoria 
HAVING AVG(precio) > 100 
ORDER BY AVG(precio) DESC;
```

**Explicación línea por línea:**
- `LIMIT 3`: limita a 3 resultados
- `HAVING SUM(stock) > 30`: filtra grupos con stock total mayor a 30
- `ORDER BY SUM(stock) DESC`: ordena por stock total descendente
- `HAVING AVG(precio) > 100`: filtra grupos con precio promedio mayor a 100

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Sistema de Análisis de Productos

```sql
-- Crear base de datos para el ejemplo
CREATE DATABASE ordenamiento_agrupacion;
USE ordenamiento_agrupacion;

-- Crear tabla de productos
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    categoria VARCHAR(50),
    marca VARCHAR(50),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, descripcion, precio, stock, categoria, marca) VALUES
('Laptop HP Pavilion', 'Laptop de 15 pulgadas con procesador Intel i5', 899.99, 10, 'Electrónicos', 'HP'),
('Mouse Logitech', 'Mouse óptico inalámbrico', 25.50, 50, 'Accesorios', 'Logitech'),
('Teclado Mecánico RGB', 'Teclado mecánico con iluminación RGB', 89.99, 15, 'Accesorios', 'Corsair'),
('Monitor Samsung 24"', 'Monitor LED de 24 pulgadas Full HD', 199.99, 8, 'Electrónicos', 'Samsung'),
('Auriculares Sony WH-1000XM4', 'Auriculares inalámbricos con cancelación de ruido', 349.99, 20, 'Accesorios', 'Sony'),
('Tablet iPad Air', 'Tablet Apple de 10.9 pulgadas', 599.99, 12, 'Electrónicos', 'Apple'),
('Cargador USB-C 65W', 'Cargador rápido de 65W para laptop', 29.99, 30, 'Accesorios', 'Anker'),
('Smartphone iPhone 14', 'Smartphone Apple con cámara de 48MP', 999.99, 5, 'Electrónicos', 'Apple'),
('Laptop Dell XPS 13', 'Laptop ultrabook de 13 pulgadas', 1299.99, 3, 'Electrónicos', 'Dell'),
('Mousepad Gaming', 'Mousepad para gaming con superficie optimizada', 19.99, 25, 'Accesorios', 'SteelSeries'),
('Laptop Lenovo ThinkPad', 'Laptop empresarial de 14 pulgadas', 799.99, 7, 'Electrónicos', 'Lenovo'),
('Teclado Inalámbrico Logitech', 'Teclado inalámbrico compacto', 45.99, 18, 'Accesorios', 'Logitech');
```

### Ejemplo 2: Ordenamiento de Productos

```sql
-- Consulta 1: Ordenar productos por nombre
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
ORDER BY nombre ASC;

-- Explicación línea por línea:
-- ORDER BY nombre ASC: ordena por nombre en orden ascendente
-- ASC: orden ascendente (por defecto, se puede omitir)

-- Consulta 2: Ordenar productos por precio descendente
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
ORDER BY precio DESC;

-- Explicación línea por línea:
-- ORDER BY precio DESC: ordena por precio en orden descendente
-- DESC: orden descendente (debe especificarse)

-- Consulta 3: Ordenar por categoría y luego por precio
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
ORDER BY categoria ASC, precio DESC;

-- Explicación línea por línea:
-- ORDER BY categoria ASC, precio DESC: ordena por categoría ascendente, luego por precio descendente
-- Múltiples columnas de ordenamiento

-- Consulta 4: Ordenar por longitud del nombre
SELECT 
    nombre,
    LENGTH(nombre) as longitud_nombre,
    categoria
FROM productos 
ORDER BY LENGTH(nombre) DESC;

-- Explicación línea por línea:
-- LENGTH(nombre): función para calcular longitud del nombre
-- ORDER BY LENGTH(nombre) DESC: ordena por longitud descendente
-- as longitud_nombre: alias para la columna calculada
```

### Ejemplo 3: Agrupación de Productos

```sql
-- Consulta 1: Contar productos por categoría
SELECT 
    categoria,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria;

-- Explicación línea por línea:
-- GROUP BY categoria: agrupa registros por categoría
-- COUNT(*): cuenta el número de registros en cada grupo
-- as total_productos: alias para la columna calculada

-- Consulta 2: Sumar stock por marca
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca;

-- Explicación línea por línea:
-- GROUP BY marca: agrupa registros por marca
-- SUM(stock): suma el stock de cada grupo
-- as stock_total: alias para la columna calculada

-- Consulta 3: Promedio de precios por categoría
SELECT 
    categoria,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY categoria;

-- Explicación línea por línea:
-- GROUP BY categoria: agrupa registros por categoría
-- AVG(precio): calcula el promedio de precios en cada grupo
-- as precio_promedio: alias para la columna calculada

-- Consulta 4: Agrupar por categoría y marca
SELECT 
    categoria,
    marca,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria, marca;

-- Explicación línea por línea:
-- GROUP BY categoria, marca: agrupa por categoría y marca
-- COUNT(*): cuenta productos en cada combinación
-- as total_productos: alias para la columna calculada
```

### Ejemplo 4: Funciones Agregadas Avanzadas

```sql
-- Consulta 1: Estadísticas completas por categoría
SELECT 
    categoria,
    COUNT(*) as total_productos,
    SUM(stock) as stock_total,
    AVG(precio) as precio_promedio,
    MIN(precio) as precio_minimo,
    MAX(precio) as precio_maximo
FROM productos 
GROUP BY categoria;

-- Explicación línea por línea:
-- COUNT(*): cuenta productos
-- SUM(stock): suma stock total
-- AVG(precio): precio promedio
-- MIN(precio): precio mínimo
-- MAX(precio): precio máximo
-- GROUP BY categoria: agrupa por categoría

-- Consulta 2: Valor total del inventario por marca
SELECT 
    marca,
    COUNT(*) as total_productos,
    SUM(precio * stock) as valor_inventario
FROM productos 
GROUP BY marca;

-- Explicación línea por línea:
-- COUNT(*): cuenta productos por marca
-- SUM(precio * stock): calcula valor total del inventario
-- GROUP BY marca: agrupa por marca

-- Consulta 3: Productos por año de creación
SELECT 
    YEAR(fecha_creacion) as año,
    COUNT(*) as productos_creados
FROM productos 
GROUP BY YEAR(fecha_creacion);

-- Explicación línea por línea:
-- YEAR(fecha_creacion): extrae el año de la fecha
-- COUNT(*): cuenta productos creados en cada año
-- GROUP BY YEAR(fecha_creacion): agrupa por año

-- Consulta 4: Estadísticas de stock por categoría
SELECT 
    categoria,
    COUNT(*) as total_productos,
    AVG(stock) as stock_promedio,
    MIN(stock) as stock_minimo,
    MAX(stock) as stock_maximo
FROM productos 
GROUP BY categoria;

-- Explicación línea por línea:
-- COUNT(*): cuenta productos
-- AVG(stock): stock promedio
-- MIN(stock): stock mínimo
-- MAX(stock): stock máximo
-- GROUP BY categoria: agrupa por categoría
```

### Ejemplo 5: Filtrado de Grupos con HAVING

```sql
-- Consulta 1: Categorías con más de 2 productos
SELECT 
    categoria,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria 
HAVING COUNT(*) > 2;

-- Explicación línea por línea:
-- GROUP BY categoria: agrupa por categoría
-- HAVING COUNT(*) > 2: filtra grupos con más de 2 productos
-- HAVING: filtra grupos después de la agrupación

-- Consulta 2: Marcas con stock total mayor a 50
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca 
HAVING SUM(stock) > 50;

-- Explicación línea por línea:
-- GROUP BY marca: agrupa por marca
-- HAVING SUM(stock) > 50: filtra grupos con stock total mayor a 50
-- HAVING: filtra grupos basándose en función agregada

-- Consulta 3: Categorías con precio promedio mayor a 100
SELECT 
    categoria,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY categoria 
HAVING AVG(precio) > 100;

-- Explicación línea por línea:
-- GROUP BY categoria: agrupa por categoría
-- HAVING AVG(precio) > 100: filtra grupos con precio promedio mayor a 100
-- HAVING: filtra grupos basándose en función agregada

-- Consulta 4: Marcas con múltiples condiciones
SELECT 
    marca,
    COUNT(*) as total_productos,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY marca 
HAVING COUNT(*) > 1 AND AVG(precio) > 50;

-- Explicación línea por línea:
-- GROUP BY marca: agrupa por marca
-- HAVING COUNT(*) > 1: filtra grupos con más de 1 producto
-- AND AVG(precio) > 50: y precio promedio mayor a 50
-- HAVING: filtra grupos con múltiples condiciones
```

### Ejemplo 6: Combinación de Ordenamiento y Agrupación

```sql
-- Consulta 1: Top 3 categorías por número de productos
SELECT 
    categoria,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria 
ORDER BY COUNT(*) DESC 
LIMIT 3;

-- Explicación línea por línea:
-- GROUP BY categoria: agrupa por categoría
-- ORDER BY COUNT(*) DESC: ordena por número de productos descendente
-- LIMIT 3: limita a 3 resultados

-- Consulta 2: Marcas ordenadas por stock total
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca 
ORDER BY SUM(stock) DESC;

-- Explicación línea por línea:
-- GROUP BY marca: agrupa por marca
-- ORDER BY SUM(stock) DESC: ordena por stock total descendente
-- as stock_total: alias para la columna calculada

-- Consulta 3: Categorías con precio promedio mayor a 100, ordenadas por precio
SELECT 
    categoria,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY categoria 
HAVING AVG(precio) > 100 
ORDER BY AVG(precio) DESC;

-- Explicación línea por línea:
-- GROUP BY categoria: agrupa por categoría
-- HAVING AVG(precio) > 100: filtra grupos con precio promedio mayor a 100
-- ORDER BY AVG(precio) DESC: ordena por precio promedio descendente

-- Consulta 4: Marcas con stock total mayor a 30, ordenadas por stock
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca 
HAVING SUM(stock) > 30 
ORDER BY SUM(stock) DESC;

-- Explicación línea por línea:
-- GROUP BY marca: agrupa por marca
-- HAVING SUM(stock) > 30: filtra grupos con stock total mayor a 30
-- ORDER BY SUM(stock) DESC: ordena por stock total descendente
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Ordenamiento Básico
**Objetivo**: Practicar ordenamiento de resultados.

**Instrucciones**:
1. Ordenar productos por nombre ascendente
2. Ordenar productos por precio descendente
3. Ordenar por categoría y luego por precio
4. Ordenar por longitud del nombre

**Solución paso a paso:**

```sql
-- Consulta 1: Ordenar por nombre ascendente
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
ORDER BY nombre ASC;

-- Explicación:
-- ORDER BY nombre ASC: ordena por nombre en orden ascendente
-- ASC: orden ascendente (por defecto, se puede omitir)

-- Consulta 2: Ordenar por precio descendente
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
ORDER BY precio DESC;

-- Explicación:
-- ORDER BY precio DESC: ordena por precio en orden descendente
-- DESC: orden descendente (debe especificarse)

-- Consulta 3: Ordenar por categoría y precio
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
ORDER BY categoria ASC, precio DESC;

-- Explicación:
-- ORDER BY categoria ASC, precio DESC: ordena por categoría ascendente, luego por precio descendente
-- Múltiples columnas de ordenamiento

-- Consulta 4: Ordenar por longitud del nombre
SELECT 
    nombre,
    LENGTH(nombre) as longitud_nombre
FROM productos 
ORDER BY LENGTH(nombre) DESC;

-- Explicación:
-- LENGTH(nombre): función para calcular longitud del nombre
-- ORDER BY LENGTH(nombre) DESC: ordena por longitud descendente
-- as longitud_nombre: alias para la columna calculada
```

### Ejercicio 2: Agrupación Básica
**Objetivo**: Practicar agrupación de registros.

**Instrucciones**:
1. Contar productos por categoría
2. Sumar stock por marca
3. Calcular precio promedio por categoría
4. Agrupar por categoría y marca

**Solución paso a paso:**

```sql
-- Consulta 1: Contar productos por categoría
SELECT 
    categoria,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria;

-- Explicación:
-- GROUP BY categoria: agrupa registros por categoría
-- COUNT(*): cuenta el número de registros en cada grupo
-- as total_productos: alias para la columna calculada

-- Consulta 2: Sumar stock por marca
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca;

-- Explicación:
-- GROUP BY marca: agrupa registros por marca
-- SUM(stock): suma el stock de cada grupo
-- as stock_total: alias para la columna calculada

-- Consulta 3: Precio promedio por categoría
SELECT 
    categoria,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY categoria;

-- Explicación:
-- GROUP BY categoria: agrupa registros por categoría
-- AVG(precio): calcula el promedio de precios en cada grupo
-- as precio_promedio: alias para la columna calculada

-- Consulta 4: Agrupar por categoría y marca
SELECT 
    categoria,
    marca,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria, marca;

-- Explicación:
-- GROUP BY categoria, marca: agrupa por categoría y marca
-- COUNT(*): cuenta productos en cada combinación
-- as total_productos: alias para la columna calculada
```

### Ejercicio 3: Funciones Agregadas
**Objetivo**: Practicar funciones agregadas básicas.

**Instrucciones**:
1. Calcular estadísticas completas por categoría
2. Calcular valor total del inventario por marca
3. Encontrar precios mínimo y máximo por categoría
4. Calcular estadísticas de stock por marca

**Solución paso a paso:**

```sql
-- Consulta 1: Estadísticas completas por categoría
SELECT 
    categoria,
    COUNT(*) as total_productos,
    SUM(stock) as stock_total,
    AVG(precio) as precio_promedio,
    MIN(precio) as precio_minimo,
    MAX(precio) as precio_maximo
FROM productos 
GROUP BY categoria;

-- Explicación:
-- COUNT(*): cuenta productos
-- SUM(stock): suma stock total
-- AVG(precio): precio promedio
-- MIN(precio): precio mínimo
-- MAX(precio): precio máximo
-- GROUP BY categoria: agrupa por categoría

-- Consulta 2: Valor total del inventario por marca
SELECT 
    marca,
    COUNT(*) as total_productos,
    SUM(precio * stock) as valor_inventario
FROM productos 
GROUP BY marca;

-- Explicación:
-- COUNT(*): cuenta productos por marca
-- SUM(precio * stock): calcula valor total del inventario
-- GROUP BY marca: agrupa por marca

-- Consulta 3: Precios mínimo y máximo por categoría
SELECT 
    categoria,
    MIN(precio) as precio_minimo,
    MAX(precio) as precio_maximo
FROM productos 
GROUP BY categoria;

-- Explicación:
-- MIN(precio): encuentra el precio mínimo en cada grupo
-- MAX(precio): encuentra el precio máximo en cada grupo
-- GROUP BY categoria: agrupa por categoría

-- Consulta 4: Estadísticas de stock por marca
SELECT 
    marca,
    COUNT(*) as total_productos,
    AVG(stock) as stock_promedio,
    MIN(stock) as stock_minimo,
    MAX(stock) as stock_maximo
FROM productos 
GROUP BY marca;

-- Explicación:
-- COUNT(*): cuenta productos
-- AVG(stock): stock promedio
-- MIN(stock): stock mínimo
-- MAX(stock): stock máximo
-- GROUP BY marca: agrupa por marca
```

### Ejercicio 4: Filtrado de Grupos
**Objetivo**: Practicar filtrado de grupos con HAVING.

**Instrucciones**:
1. Encontrar categorías con más de 2 productos
2. Encontrar marcas con stock total mayor a 50
3. Encontrar categorías con precio promedio mayor a 100
4. Encontrar marcas con múltiples condiciones

**Solución paso a paso:**

```sql
-- Consulta 1: Categorías con más de 2 productos
SELECT 
    categoria,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria 
HAVING COUNT(*) > 2;

-- Explicación:
-- GROUP BY categoria: agrupa por categoría
-- HAVING COUNT(*) > 2: filtra grupos con más de 2 productos
-- HAVING: filtra grupos después de la agrupación

-- Consulta 2: Marcas con stock total mayor a 50
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca 
HAVING SUM(stock) > 50;

-- Explicación:
-- GROUP BY marca: agrupa por marca
-- HAVING SUM(stock) > 50: filtra grupos con stock total mayor a 50
-- HAVING: filtra grupos basándose en función agregada

-- Consulta 3: Categorías con precio promedio mayor a 100
SELECT 
    categoria,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY categoria 
HAVING AVG(precio) > 100;

-- Explicación:
-- GROUP BY categoria: agrupa por categoría
-- HAVING AVG(precio) > 100: filtra grupos con precio promedio mayor a 100
-- HAVING: filtra grupos basándose en función agregada

-- Consulta 4: Marcas con múltiples condiciones
SELECT 
    marca,
    COUNT(*) as total_productos,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY marca 
HAVING COUNT(*) > 1 AND AVG(precio) > 50;

-- Explicación:
-- GROUP BY marca: agrupa por marca
-- HAVING COUNT(*) > 1: filtra grupos con más de 1 producto
-- AND AVG(precio) > 50: y precio promedio mayor a 50
-- HAVING: filtra grupos con múltiples condiciones
```

### Ejercicio 5: Combinación Compleja
**Objetivo**: Practicar combinación de ordenamiento y agrupación.

**Instrucciones**:
1. Top 3 categorías por número de productos
2. Marcas ordenadas por stock total
3. Categorías con precio promedio mayor a 100, ordenadas por precio
4. Marcas con stock total mayor a 30, ordenadas por stock

**Solución paso a paso:**

```sql
-- Consulta 1: Top 3 categorías por número de productos
SELECT 
    categoria,
    COUNT(*) as total_productos
FROM productos 
GROUP BY categoria 
ORDER BY COUNT(*) DESC 
LIMIT 3;

-- Explicación:
-- GROUP BY categoria: agrupa por categoría
-- ORDER BY COUNT(*) DESC: ordena por número de productos descendente
-- LIMIT 3: limita a 3 resultados

-- Consulta 2: Marcas ordenadas por stock total
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca 
ORDER BY SUM(stock) DESC;

-- Explicación:
-- GROUP BY marca: agrupa por marca
-- ORDER BY SUM(stock) DESC: ordena por stock total descendente
-- as stock_total: alias para la columna calculada

-- Consulta 3: Categorías con precio promedio mayor a 100, ordenadas por precio
SELECT 
    categoria,
    AVG(precio) as precio_promedio
FROM productos 
GROUP BY categoria 
HAVING AVG(precio) > 100 
ORDER BY AVG(precio) DESC;

-- Explicación:
-- GROUP BY categoria: agrupa por categoría
-- HAVING AVG(precio) > 100: filtra grupos con precio promedio mayor a 100
-- ORDER BY AVG(precio) DESC: ordena por precio promedio descendente

-- Consulta 4: Marcas con stock total mayor a 30, ordenadas por stock
SELECT 
    marca,
    SUM(stock) as stock_total
FROM productos 
GROUP BY marca 
HAVING SUM(stock) > 30 
ORDER BY SUM(stock) DESC;

-- Explicación:
-- GROUP BY marca: agrupa por marca
-- HAVING SUM(stock) > 30: filtra grupos con stock total mayor a 30
-- ORDER BY SUM(stock) DESC: ordena por stock total descendente
```

---

## 📝 Resumen de Conceptos Clave

### Ordenamiento (ORDER BY):
- **ASC**: Orden ascendente (por defecto)
- **DESC**: Orden descendente
- **Múltiples columnas**: Ordena por varias columnas
- **Funciones**: Ordena por resultados de funciones

### Agrupación (GROUP BY):
- **Agrupa registros similares** para análisis
- **Múltiples columnas**: Agrupa por varias columnas
- **Funciones**: Agrupa por resultados de funciones

### Funciones Agregadas:
- **COUNT()**: Cuenta registros
- **SUM()**: Suma valores
- **AVG()**: Calcula promedio
- **MIN()**: Encuentra valor mínimo
- **MAX()**: Encuentra valor máximo

### Filtrado de Grupos (HAVING):
- **Filtra grupos** después de la agrupación
- **Múltiples condiciones**: Combina condiciones con AND/OR
- **Funciones agregadas**: Usa funciones agregadas en condiciones

### Combinaciones:
- **GROUP BY + ORDER BY**: Agrupa y ordena resultados
- **GROUP BY + HAVING**: Agrupa y filtra grupos
- **GROUP BY + HAVING + ORDER BY**: Agrupa, filtra y ordena

### Mejores Prácticas:
1. **Usa alias descriptivos** para columnas calculadas
2. **Agrupa por columnas** que no sean funciones agregadas
3. **Usa HAVING** para filtrar grupos, WHERE para filtrar registros
4. **Ordena resultados** para mejor legibilidad
5. **Optimiza consultas** usando índices apropiados

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Índices y optimización básica
- CREATE INDEX para mejorar rendimiento
- EXPLAIN para analizar consultas
- Mejores prácticas de optimización

---

## 💡 Consejos para el Éxito

1. **Practica con datos reales**: Usa ejemplos que te interesen
2. **Combina funciones**: Experimenta con múltiples funciones agregadas
3. **Usa alias descriptivos**: Hace las consultas más legibles
4. **Prueba diferentes agrupaciones**: Experimenta con múltiples columnas
5. **Documenta tus consultas**: Comenta qué hace cada parte

---

## 🧭 Navegación

**← Anterior**: [Clase 7: Filtros Avanzados](clase_7_filtros_avanzados.md)  
**Siguiente →**: [Clase 9: Índices y Optimización Básica](clase_9_indices_optimizacion.md)

---

*¡Excelente trabajo! Ahora dominas el ordenamiento y agrupación en SQL. 🚀*
