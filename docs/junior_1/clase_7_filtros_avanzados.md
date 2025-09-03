# Clase 7: Filtros Avanzados - WHERE con Operadores Especiales

## 📚 Descripción de la Clase
En esta clase aprenderás a usar filtros avanzados en SQL que te permitirán crear consultas más precisas y potentes. Dominarás operadores especiales como LIKE, IN, BETWEEN, IS NULL, IS NOT NULL y combinaciones complejas de condiciones que te darán un control total sobre los datos que recuperas.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Usar el operador LIKE con patrones de búsqueda
- Aplicar filtros con IN para múltiples valores
- Usar BETWEEN para rangos de valores
- Manejar valores NULL con IS NULL e IS NOT NULL
- Combinar múltiples condiciones con AND, OR y NOT
- Crear consultas complejas con filtros anidados
- Optimizar consultas con filtros eficientes

## ⏱️ Duración Estimada
**2-3 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son los Filtros Avanzados?

Los **filtros avanzados** en SQL son operadores especiales que permiten crear condiciones más sofisticadas en la cláusula WHERE. Van más allá de las comparaciones simples (>, <, =) y ofrecen:

- **Búsquedas por patrones**: Encontrar texto que coincida con un patrón
- **Filtros por múltiples valores**: Buscar en una lista de valores
- **Filtros por rangos**: Buscar valores dentro de un rango
- **Manejo de valores nulos**: Filtrar registros con o sin valores NULL
- **Lógica compleja**: Combinar múltiples condiciones

### Sintaxis General de Filtros Avanzados

```sql
SELECT columnas
FROM tabla
WHERE condicion_avanzada
ORDER BY columna;
```

**Explicación línea por línea:**
- `SELECT columnas`: columnas a mostrar
- `FROM tabla`: tabla de donde obtener los datos
- `WHERE condicion_avanzada`: condición con operadores especiales
- `ORDER BY columna`: ordenamiento de resultados (opcional)

### 1. Operador LIKE - Búsqueda por Patrones

El operador LIKE permite buscar texto que coincida con un patrón usando comodines.

#### 1.1 Comodines Básicos
```sql
-- % (porcentaje): Cualquier secuencia de caracteres (incluyendo cero)
-- _ (guión bajo): Exactamente un carácter

-- Buscar nombres que empiecen con 'L'
SELECT * FROM productos WHERE nombre LIKE 'L%';

-- Buscar nombres que terminen con 'g'
SELECT * FROM productos WHERE nombre LIKE '%g';

-- Buscar nombres que contengan 'HP'
SELECT * FROM productos WHERE nombre LIKE '%HP%';

-- Buscar nombres con exactamente 5 caracteres
SELECT * FROM productos WHERE nombre LIKE '_____';
```

**Explicación línea por línea:**
- `LIKE 'L%'`: busca nombres que empiecen con 'L' seguido de cualquier cosa
- `LIKE '%g'`: busca nombres que terminen con 'g'
- `LIKE '%HP%'`: busca nombres que contengan 'HP' en cualquier posición
- `LIKE '_____'`: busca nombres con exactamente 5 caracteres (5 guiones bajos)

#### 1.2 Patrones Complejos
```sql
-- Buscar nombres que empiecen con 'L' y terminen con 'g'
SELECT * FROM productos WHERE nombre LIKE 'L%g';

-- Buscar nombres con 'a' en la segunda posición
SELECT * FROM productos WHERE nombre LIKE '_a%';

-- Buscar nombres que empiecen con 'L' o 'M'
SELECT * FROM productos WHERE nombre LIKE 'L%' OR nombre LIKE 'M%';

-- Buscar nombres que NO empiecen con 'L'
SELECT * FROM productos WHERE nombre NOT LIKE 'L%';
```

**Explicación línea por línea:**
- `LIKE 'L%g'`: empieza con 'L', termina con 'g', cualquier cosa en el medio
- `LIKE '_a%'`: segundo carácter es 'a', cualquier cosa antes y después
- `OR nombre LIKE 'M%'`: combina dos condiciones con OR
- `NOT LIKE 'L%'`: excluye nombres que empiecen con 'L'

#### 1.3 Búsqueda Insensible a Mayúsculas
```sql
-- En MySQL, LIKE es insensible a mayúsculas por defecto
SELECT * FROM productos WHERE nombre LIKE '%hp%';

-- Para búsqueda sensible a mayúsculas
SELECT * FROM productos WHERE BINARY nombre LIKE '%HP%';
```

**Explicación línea por línea:**
- `LIKE '%hp%'`: busca 'hp' en minúsculas o mayúsculas
- `BINARY nombre LIKE '%HP%'`: busca exactamente 'HP' en mayúsculas

### 2. Operador IN - Múltiples Valores

El operador IN permite buscar valores que estén en una lista específica.

#### 2.1 Uso Básico de IN
```sql
-- Buscar productos de categorías específicas
SELECT * FROM productos WHERE categoria IN ('Electrónicos', 'Accesorios');

-- Buscar productos con precios específicos
SELECT * FROM productos WHERE precio IN (25.50, 89.99, 199.99);

-- Buscar productos con stock específico
SELECT * FROM productos WHERE stock IN (5, 10, 15, 20);
```

**Explicación línea por línea:**
- `IN ('Electrónicos', 'Accesorios')`: busca en estas dos categorías
- `IN (25.50, 89.99, 199.99)`: busca estos precios exactos
- `IN (5, 10, 15, 20)`: busca estos valores de stock

#### 2.2 IN con Subconsultas
```sql
-- Buscar productos de categorías que tengan más de 5 productos
SELECT * FROM productos 
WHERE categoria IN (
    SELECT categoria 
    FROM productos 
    GROUP BY categoria 
    HAVING COUNT(*) > 5
);
```

**Explicación línea por línea:**
- `IN (subconsulta)`: usa el resultado de una subconsulta
- `SELECT categoria FROM productos`: obtiene todas las categorías
- `GROUP BY categoria`: agrupa por categoría
- `HAVING COUNT(*) > 5`: solo categorías con más de 5 productos

#### 2.3 NOT IN - Excluir Valores
```sql
-- Excluir categorías específicas
SELECT * FROM productos WHERE categoria NOT IN ('Electrónicos', 'Accesorios');

-- Excluir precios específicos
SELECT * FROM productos WHERE precio NOT IN (25.50, 89.99);
```

**Explicación línea por línea:**
- `NOT IN ('Electrónicos', 'Accesorios')`: excluye estas categorías
- `NOT IN (25.50, 89.99)`: excluye estos precios

### 3. Operador BETWEEN - Rangos de Valores

El operador BETWEEN permite buscar valores dentro de un rango específico.

#### 3.1 Uso Básico de BETWEEN
```sql
-- Buscar productos con precios entre 50 y 200
SELECT * FROM productos WHERE precio BETWEEN 50 AND 200;

-- Buscar productos con stock entre 10 y 30
SELECT * FROM productos WHERE stock BETWEEN 10 AND 30;

-- Buscar productos creados en un rango de fechas
SELECT * FROM productos WHERE fecha_creacion BETWEEN '2024-01-01' AND '2024-12-31';
```

**Explicación línea por línea:**
- `BETWEEN 50 AND 200`: incluye valores desde 50 hasta 200 (inclusive)
- `BETWEEN 10 AND 30`: incluye valores desde 10 hasta 30 (inclusive)
- `BETWEEN '2024-01-01' AND '2024-12-31'`: incluye fechas en este rango

#### 3.2 NOT BETWEEN - Excluir Rangos
```sql
-- Excluir precios entre 50 y 200
SELECT * FROM productos WHERE precio NOT BETWEEN 50 AND 200;

-- Excluir stock entre 10 y 30
SELECT * FROM productos WHERE stock NOT BETWEEN 10 AND 30;
```

**Explicación línea por línea:**
- `NOT BETWEEN 50 AND 200`: excluye valores en este rango
- `NOT BETWEEN 10 AND 30`: excluye valores en este rango

#### 3.3 BETWEEN con Fechas
```sql
-- Buscar productos creados en los últimos 30 días
SELECT * FROM productos 
WHERE fecha_creacion BETWEEN DATE_SUB(NOW(), INTERVAL 30 DAY) AND NOW();

-- Buscar productos creados en un mes específico
SELECT * FROM productos 
WHERE fecha_creacion BETWEEN '2024-01-01' AND '2024-01-31';
```

**Explicación línea por línea:**
- `DATE_SUB(NOW(), INTERVAL 30 DAY)`: fecha de hace 30 días
- `NOW()`: fecha actual
- `BETWEEN ... AND ...`: rango de fechas

### 4. Operadores IS NULL e IS NOT NULL

Estos operadores permiten manejar valores NULL (nulos) en las consultas.

#### 4.1 IS NULL - Buscar Valores Nulos
```sql
-- Buscar productos sin descripción
SELECT * FROM productos WHERE descripcion IS NULL;

-- Buscar productos sin categoría
SELECT * FROM productos WHERE categoria IS NULL;

-- Buscar productos sin stock
SELECT * FROM productos WHERE stock IS NULL;
```

**Explicación línea por línea:**
- `IS NULL`: busca registros donde la columna sea NULL
- `descripcion IS NULL`: productos sin descripción
- `categoria IS NULL`: productos sin categoría

#### 4.2 IS NOT NULL - Excluir Valores Nulos
```sql
-- Buscar productos con descripción
SELECT * FROM productos WHERE descripcion IS NOT NULL;

-- Buscar productos con categoría
SELECT * FROM productos WHERE categoria IS NOT NULL;

-- Buscar productos con stock
SELECT * FROM productos WHERE stock IS NOT NULL;
```

**Explicación línea por línea:**
- `IS NOT NULL`: busca registros donde la columna NO sea NULL
- `descripcion IS NOT NULL`: productos con descripción
- `categoria IS NOT NULL`: productos con categoría

### 5. Combinación de Operadores

Los operadores avanzados se pueden combinar para crear condiciones complejas.

#### 5.1 Combinaciones con AND
```sql
-- Buscar productos caros de electrónicos
SELECT * FROM productos 
WHERE categoria = 'Electrónicos' AND precio > 500;

-- Buscar productos con stock bajo y precio alto
SELECT * FROM productos 
WHERE stock < 10 AND precio > 100;

-- Buscar productos que empiecen con 'L' y tengan stock alto
SELECT * FROM productos 
WHERE nombre LIKE 'L%' AND stock > 15;
```

**Explicación línea por línea:**
- `categoria = 'Electrónicos' AND precio > 500`: ambas condiciones deben ser verdaderas
- `stock < 10 AND precio > 100`: stock bajo Y precio alto
- `nombre LIKE 'L%' AND stock > 15`: nombre que empiece con 'L' Y stock alto

#### 5.2 Combinaciones con OR
```sql
-- Buscar productos de electrónicos o accesorios
SELECT * FROM productos 
WHERE categoria = 'Electrónicos' OR categoria = 'Accesorios';

-- Buscar productos caros o con stock bajo
SELECT * FROM productos 
WHERE precio > 500 OR stock < 5;

-- Buscar productos que empiecen con 'L' o 'M'
SELECT * FROM productos 
WHERE nombre LIKE 'L%' OR nombre LIKE 'M%';
```

**Explicación línea por línea:**
- `categoria = 'Electrónicos' OR categoria = 'Accesorios'`: una u otra condición
- `precio > 500 OR stock < 5`: precio alto O stock bajo
- `nombre LIKE 'L%' OR nombre LIKE 'M%'`: nombre que empiece con 'L' O 'M'

#### 5.3 Combinaciones con NOT
```sql
-- Buscar productos que NO sean de electrónicos
SELECT * FROM productos WHERE NOT categoria = 'Electrónicos';

-- Buscar productos que NO empiecen con 'L'
SELECT * FROM productos WHERE NOT nombre LIKE 'L%';

-- Buscar productos que NO tengan stock bajo
SELECT * FROM productos WHERE NOT stock < 10;
```

**Explicación línea por línea:**
- `NOT categoria = 'Electrónicos'`: excluye productos de electrónicos
- `NOT nombre LIKE 'L%'`: excluye nombres que empiecen con 'L'
- `NOT stock < 10`: excluye productos con stock bajo

#### 5.4 Combinaciones Complejas
```sql
-- Buscar productos caros de electrónicos o accesorios con stock alto
SELECT * FROM productos 
WHERE (categoria = 'Electrónicos' OR categoria = 'Accesorios') 
  AND precio > 100 
  AND stock > 10;

-- Buscar productos que empiecen con 'L' o 'M' y tengan precio entre 50 y 200
SELECT * FROM productos 
WHERE (nombre LIKE 'L%' OR nombre LIKE 'M%') 
  AND precio BETWEEN 50 AND 200;

-- Buscar productos con descripción y que NO sean de electrónicos
SELECT * FROM productos 
WHERE descripcion IS NOT NULL 
  AND NOT categoria = 'Electrónicos';
```

**Explicación línea por línea:**
- `(categoria = 'Electrónicos' OR categoria = 'Accesorios')`: agrupa condiciones con paréntesis
- `AND precio > 100`: añade condición adicional
- `AND stock > 10`: añade otra condición
- `(nombre LIKE 'L%' OR nombre LIKE 'M%')`: agrupa condiciones de nombre
- `AND precio BETWEEN 50 AND 200`: añade condición de precio
- `descripcion IS NOT NULL`: productos con descripción
- `AND NOT categoria = 'Electrónicos'`: excluye electrónicos

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Sistema de Búsqueda Avanzada

```sql
-- Crear base de datos para el ejemplo
CREATE DATABASE filtros_avanzados;
USE filtros_avanzados;

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
('Mousepad Gaming', 'Mousepad para gaming con superficie optimizada', 19.99, 25, 'Accesorios', 'SteelSeries');
```

### Ejemplo 2: Búsquedas con LIKE

```sql
-- Consulta 1: Buscar productos que empiecen con 'L'
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE nombre LIKE 'L%';

-- Explicación línea por línea:
-- LIKE 'L%': busca nombres que empiecen con 'L'
-- %: comodín para cualquier secuencia de caracteres

-- Consulta 2: Buscar productos que contengan 'Apple'
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE nombre LIKE '%Apple%' OR marca LIKE '%Apple%';

-- Explicación línea por línea:
-- LIKE '%Apple%': busca 'Apple' en cualquier posición del nombre
-- OR marca LIKE '%Apple%': también busca en la columna marca

-- Consulta 3: Buscar productos con nombres de exactamente 10 caracteres
SELECT 
    nombre,
    LENGTH(nombre) AS longitud_nombre
FROM productos 
WHERE nombre LIKE '__________';

-- Explicación línea por línea:
-- LIKE '__________': 10 guiones bajos = exactamente 10 caracteres
-- LENGTH(nombre): función para verificar la longitud

-- Consulta 4: Buscar productos que empiecen con 'L' y terminen con 'g'
SELECT 
    nombre,
    categoria
FROM productos 
WHERE nombre LIKE 'L%g';

-- Explicación línea por línea:
-- LIKE 'L%g': empieza con 'L', termina con 'g', cualquier cosa en el medio
```

### Ejemplo 3: Filtros con IN

```sql
-- Consulta 1: Buscar productos de marcas específicas
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca IN ('Apple', 'Samsung', 'Sony');

-- Explicación línea por línea:
-- IN ('Apple', 'Samsung', 'Sony'): busca en estas tres marcas
-- Equivale a: marca = 'Apple' OR marca = 'Samsung' OR marca = 'Sony'

-- Consulta 2: Buscar productos con precios específicos
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio IN (25.50, 89.99, 199.99, 349.99);

-- Explicación línea por línea:
-- IN (25.50, 89.99, 199.99, 349.99): busca estos precios exactos
-- Útil para productos en oferta o precios especiales

-- Consulta 3: Buscar productos de categorías específicas
SELECT 
    nombre,
    categoria,
    stock
FROM productos 
WHERE categoria IN ('Electrónicos', 'Accesorios');

-- Explicación línea por línea:
-- IN ('Electrónicos', 'Accesorios'): busca en estas dos categorías
-- Más eficiente que usar múltiples OR

-- Consulta 4: Excluir marcas específicas
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca NOT IN ('Apple', 'Samsung');

-- Explicación línea por línea:
-- NOT IN ('Apple', 'Samsung'): excluye estas marcas
-- Útil para filtrar productos de marcas específicas
```

### Ejemplo 4: Filtros con BETWEEN

```sql
-- Consulta 1: Buscar productos con precios en un rango
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio BETWEEN 50 AND 300;

-- Explicación línea por línea:
-- BETWEEN 50 AND 300: incluye precios desde 50 hasta 300 (inclusive)
-- Equivale a: precio >= 50 AND precio <= 300

-- Consulta 2: Buscar productos con stock en un rango
SELECT 
    nombre,
    stock,
    precio
FROM productos 
WHERE stock BETWEEN 10 AND 25;

-- Explicación línea por línea:
-- BETWEEN 10 AND 25: incluye stock desde 10 hasta 25 (inclusive)
-- Útil para productos con stock moderado

-- Consulta 3: Buscar productos creados en un rango de fechas
SELECT 
    nombre,
    fecha_creacion,
    categoria
FROM productos 
WHERE fecha_creacion BETWEEN '2024-01-01' AND '2024-12-31';

-- Explicación línea por línea:
-- BETWEEN '2024-01-01' AND '2024-12-31': incluye fechas en este rango
-- Útil para productos creados en un año específico

-- Consulta 4: Excluir precios en un rango
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio NOT BETWEEN 100 AND 500;

-- Explicación línea por línea:
-- NOT BETWEEN 100 AND 500: excluye precios en este rango
-- Útil para productos muy baratos o muy caros
```

### Ejemplo 5: Manejo de Valores NULL

```sql
-- Consulta 1: Buscar productos sin descripción
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE descripcion IS NULL;

-- Explicación línea por línea:
-- IS NULL: busca registros donde descripcion sea NULL
-- Útil para identificar productos que necesitan descripción

-- Consulta 2: Buscar productos con descripción
SELECT 
    nombre,
    descripcion,
    precio
FROM productos 
WHERE descripcion IS NOT NULL;

-- Explicación línea por línea:
-- IS NOT NULL: busca registros donde descripcion NO sea NULL
-- Útil para productos con información completa

-- Consulta 3: Buscar productos sin marca
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE marca IS NULL;

-- Explicación línea por línea:
-- IS NULL: busca registros donde marca sea NULL
-- Útil para identificar productos sin marca asignada

-- Consulta 4: Buscar productos con marca
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca IS NOT NULL;

-- Explicación línea por línea:
-- IS NOT NULL: busca registros donde marca NO sea NULL
-- Útil para productos con marca conocida
```

### Ejemplo 6: Combinaciones Complejas

```sql
-- Consulta 1: Productos caros de electrónicos con stock alto
SELECT 
    nombre,
    categoria,
    precio,
    stock
FROM productos 
WHERE categoria = 'Electrónicos' 
  AND precio > 500 
  AND stock > 10;

-- Explicación línea por línea:
-- categoria = 'Electrónicos': solo productos de electrónicos
-- AND precio > 500: y precio mayor a 500
-- AND stock > 10: y stock mayor a 10
-- Todas las condiciones deben ser verdaderas

-- Consulta 2: Productos que empiecen con 'L' o 'M' y tengan precio entre 50 y 200
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE (nombre LIKE 'L%' OR nombre LIKE 'M%') 
  AND precio BETWEEN 50 AND 200;

-- Explicación línea por línea:
-- (nombre LIKE 'L%' OR nombre LIKE 'M%'): agrupa condiciones con paréntesis
-- AND precio BETWEEN 50 AND 200: añade condición de precio
-- Paréntesis son importantes para la precedencia

-- Consulta 3: Productos de marcas específicas con stock bajo
SELECT 
    nombre,
    marca,
    stock,
    precio
FROM productos 
WHERE marca IN ('Apple', 'Samsung', 'Sony') 
  AND stock < 10;

-- Explicación línea por línea:
-- marca IN ('Apple', 'Samsung', 'Sony'): marcas específicas
-- AND stock < 10: y stock bajo
-- Combina IN con comparación numérica

-- Consulta 4: Productos con descripción y que NO sean de electrónicos
SELECT 
    nombre,
    categoria,
    descripcion,
    precio
FROM productos 
WHERE descripcion IS NOT NULL 
  AND NOT categoria = 'Electrónicos';

-- Explicación línea por línea:
-- descripcion IS NOT NULL: productos con descripción
-- AND NOT categoria = 'Electrónicos': y que NO sean de electrónicos
-- Combina IS NOT NULL con NOT

-- Consulta 5: Productos caros o con stock muy bajo
SELECT 
    nombre,
    precio,
    stock,
    categoria
FROM productos 
WHERE precio > 800 OR stock < 5;

-- Explicación línea por línea:
-- precio > 800: productos caros
-- OR stock < 5: o productos con stock muy bajo
-- Solo una condición necesita ser verdadera

-- Consulta 6: Productos que empiecen con 'L' y tengan precio entre 50 y 200, o que sean de Apple
SELECT 
    nombre,
    marca,
    precio,
    categoria
FROM productos 
WHERE (nombre LIKE 'L%' AND precio BETWEEN 50 AND 200) 
   OR marca = 'Apple';

-- Explicación línea por línea:
-- (nombre LIKE 'L%' AND precio BETWEEN 50 AND 200): primera condición agrupada
-- OR marca = 'Apple': segunda condición
-- Paréntesis son cruciales para la lógica correcta
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Búsquedas con LIKE
**Objetivo**: Practicar búsquedas por patrones de texto.

**Instrucciones**:
1. Buscar productos que empiecen con 'L'
2. Buscar productos que contengan 'Apple' en el nombre
3. Buscar productos que terminen con 'g'
4. Buscar productos con nombres de exactamente 8 caracteres

**Solución paso a paso:**

```sql
-- Consulta 1: Productos que empiecen con 'L'
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE nombre LIKE 'L%';

-- Explicación:
-- LIKE 'L%': busca nombres que empiecen con 'L'
-- %: comodín para cualquier secuencia de caracteres

-- Consulta 2: Productos que contengan 'Apple'
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE nombre LIKE '%Apple%';

-- Explicación:
-- LIKE '%Apple%': busca 'Apple' en cualquier posición del nombre
-- % al inicio y final: cualquier cosa antes y después

-- Consulta 3: Productos que terminen con 'g'
SELECT 
    nombre,
    categoria
FROM productos 
WHERE nombre LIKE '%g';

-- Explicación:
-- LIKE '%g': busca nombres que terminen con 'g'
-- % al inicio: cualquier cosa antes de 'g'

-- Consulta 4: Productos con nombres de exactamente 8 caracteres
SELECT 
    nombre,
    LENGTH(nombre) AS longitud
FROM productos 
WHERE nombre LIKE '________';

-- Explicación:
-- LIKE '________': 8 guiones bajos = exactamente 8 caracteres
-- LENGTH(nombre): función para verificar la longitud
```

### Ejercicio 2: Filtros con IN
**Objetivo**: Practicar filtros con múltiples valores.

**Instrucciones**:
1. Buscar productos de marcas específicas
2. Buscar productos con precios específicos
3. Buscar productos de categorías específicas
4. Excluir productos de marcas específicas

**Solución paso a paso:**

```sql
-- Consulta 1: Productos de marcas específicas
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca IN ('Apple', 'Samsung', 'Sony');

-- Explicación:
-- IN ('Apple', 'Samsung', 'Sony'): busca en estas tres marcas
-- Más eficiente que usar múltiples OR

-- Consulta 2: Productos con precios específicos
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio IN (25.50, 89.99, 199.99);

-- Explicación:
-- IN (25.50, 89.99, 199.99): busca estos precios exactos
-- Útil para productos en oferta

-- Consulta 3: Productos de categorías específicas
SELECT 
    nombre,
    categoria,
    stock
FROM productos 
WHERE categoria IN ('Electrónicos', 'Accesorios');

-- Explicación:
-- IN ('Electrónicos', 'Accesorios'): busca en estas dos categorías
-- Equivale a: categoria = 'Electrónicos' OR categoria = 'Accesorios'

-- Consulta 4: Excluir productos de marcas específicas
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca NOT IN ('Apple', 'Samsung');

-- Explicación:
-- NOT IN ('Apple', 'Samsung'): excluye estas marcas
-- Útil para filtrar productos de marcas específicas
```

### Ejercicio 3: Filtros con BETWEEN
**Objetivo**: Practicar filtros por rangos de valores.

**Instrucciones**:
1. Buscar productos con precios entre 50 y 300
2. Buscar productos con stock entre 10 y 25
3. Buscar productos creados en un rango de fechas
4. Excluir productos con precios entre 100 y 500

**Solución paso a paso:**

```sql
-- Consulta 1: Productos con precios entre 50 y 300
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio BETWEEN 50 AND 300;

-- Explicación:
-- BETWEEN 50 AND 300: incluye precios desde 50 hasta 300 (inclusive)
-- Equivale a: precio >= 50 AND precio <= 300

-- Consulta 2: Productos con stock entre 10 y 25
SELECT 
    nombre,
    stock,
    precio
FROM productos 
WHERE stock BETWEEN 10 AND 25;

-- Explicación:
-- BETWEEN 10 AND 25: incluye stock desde 10 hasta 25 (inclusive)
-- Útil para productos con stock moderado

-- Consulta 3: Productos creados en un rango de fechas
SELECT 
    nombre,
    fecha_creacion,
    categoria
FROM productos 
WHERE fecha_creacion BETWEEN '2024-01-01' AND '2024-12-31';

-- Explicación:
-- BETWEEN '2024-01-01' AND '2024-12-31': incluye fechas en este rango
-- Útil para productos creados en un año específico

-- Consulta 4: Excluir productos con precios entre 100 y 500
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE precio NOT BETWEEN 100 AND 500;

-- Explicación:
-- NOT BETWEEN 100 AND 500: excluye precios en este rango
-- Útil para productos muy baratos o muy caros
```

### Ejercicio 4: Manejo de Valores NULL
**Objetivo**: Practicar filtros con valores nulos.

**Instrucciones**:
1. Buscar productos sin descripción
2. Buscar productos con descripción
3. Buscar productos sin marca
4. Buscar productos con marca

**Solución paso a paso:**

```sql
-- Consulta 1: Productos sin descripción
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE descripcion IS NULL;

-- Explicación:
-- IS NULL: busca registros donde descripcion sea NULL
-- Útil para identificar productos que necesitan descripción

-- Consulta 2: Productos con descripción
SELECT 
    nombre,
    descripcion,
    precio
FROM productos 
WHERE descripcion IS NOT NULL;

-- Explicación:
-- IS NOT NULL: busca registros donde descripcion NO sea NULL
-- Útil para productos con información completa

-- Consulta 3: Productos sin marca
SELECT 
    nombre,
    categoria,
    precio
FROM productos 
WHERE marca IS NULL;

-- Explicación:
-- IS NULL: busca registros donde marca sea NULL
-- Útil para identificar productos sin marca asignada

-- Consulta 4: Productos con marca
SELECT 
    nombre,
    marca,
    precio
FROM productos 
WHERE marca IS NOT NULL;

-- Explicación:
-- IS NOT NULL: busca registros donde marca NO sea NULL
-- Útil para productos con marca conocida
```

### Ejercicio 5: Combinaciones Complejas
**Objetivo**: Practicar combinaciones de múltiples operadores.

**Instrucciones**:
1. Buscar productos caros de electrónicos con stock alto
2. Buscar productos que empiecen con 'L' o 'M' y tengan precio entre 50 y 200
3. Buscar productos de marcas específicas con stock bajo
4. Buscar productos con descripción y que NO sean de electrónicos

**Solución paso a paso:**

```sql
-- Consulta 1: Productos caros de electrónicos con stock alto
SELECT 
    nombre,
    categoria,
    precio,
    stock
FROM productos 
WHERE categoria = 'Electrónicos' 
  AND precio > 500 
  AND stock > 10;

-- Explicación:
-- categoria = 'Electrónicos': solo productos de electrónicos
-- AND precio > 500: y precio mayor a 500
-- AND stock > 10: y stock mayor a 10
-- Todas las condiciones deben ser verdaderas

-- Consulta 2: Productos que empiecen con 'L' o 'M' y tengan precio entre 50 y 200
SELECT 
    nombre,
    precio,
    categoria
FROM productos 
WHERE (nombre LIKE 'L%' OR nombre LIKE 'M%') 
  AND precio BETWEEN 50 AND 200;

-- Explicación:
-- (nombre LIKE 'L%' OR nombre LIKE 'M%'): agrupa condiciones con paréntesis
-- AND precio BETWEEN 50 AND 200: añade condición de precio
-- Paréntesis son importantes para la precedencia

-- Consulta 3: Productos de marcas específicas con stock bajo
SELECT 
    nombre,
    marca,
    stock,
    precio
FROM productos 
WHERE marca IN ('Apple', 'Samsung', 'Sony') 
  AND stock < 10;

-- Explicación:
-- marca IN ('Apple', 'Samsung', 'Sony'): marcas específicas
-- AND stock < 10: y stock bajo
-- Combina IN con comparación numérica

-- Consulta 4: Productos con descripción y que NO sean de electrónicos
SELECT 
    nombre,
    categoria,
    descripcion,
    precio
FROM productos 
WHERE descripcion IS NOT NULL 
  AND NOT categoria = 'Electrónicos';

-- Explicación:
-- descripcion IS NOT NULL: productos con descripción
-- AND NOT categoria = 'Electrónicos': y que NO sean de electrónicos
-- Combina IS NOT NULL con NOT
```

---

## 📝 Resumen de Conceptos Clave

### Operadores de Filtro Avanzado:

#### LIKE - Búsqueda por Patrones:
- **%**: Cualquier secuencia de caracteres (incluyendo cero)
- **_**: Exactamente un carácter
- **'L%'**: Empieza con 'L'
- **'%g'**: Termina con 'g'
- **'%HP%'**: Contiene 'HP'
- **'_____'**: Exactamente 5 caracteres

#### IN - Múltiples Valores:
- **IN ('valor1', 'valor2')**: Busca en lista específica
- **NOT IN ('valor1', 'valor2')**: Excluye valores específicos
- **Más eficiente que múltiples OR**

#### BETWEEN - Rangos:
- **BETWEEN 50 AND 200**: Incluye valores desde 50 hasta 200
- **NOT BETWEEN 50 AND 200**: Excluye valores en este rango
- **Incluye los valores límite**

#### IS NULL / IS NOT NULL:
- **IS NULL**: Busca valores nulos
- **IS NOT NULL**: Excluye valores nulos
- **No usar = NULL o != NULL**

### Combinaciones:
- **AND**: Todas las condiciones deben ser verdaderas
- **OR**: Al menos una condición debe ser verdadera
- **NOT**: Invierte el resultado de la condición
- **Paréntesis**: Controlan la precedencia de operadores

### Mejores Prácticas:
1. **Usa paréntesis** para agrupar condiciones complejas
2. **Prueba patrones LIKE** con datos de ejemplo
3. **Usa IN** en lugar de múltiples OR
4. **Verifica rangos BETWEEN** para asegurar inclusión correcta
5. **Maneja NULL** con IS NULL/IS NOT NULL
6. **Optimiza consultas** usando índices apropiados

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Ordenamiento con ORDER BY
- Agrupación con GROUP BY
- Funciones agregadas básicas
- Combinación de ordenamiento y agrupación

---

## 💡 Consejos para el Éxito

1. **Practica con patrones**: Experimenta con diferentes comodines LIKE
2. **Usa paréntesis**: Agrupa condiciones complejas correctamente
3. **Prueba con NULL**: Asegúrate de manejar valores nulos
4. **Optimiza consultas**: Usa IN en lugar de múltiples OR
5. **Documenta filtros**: Comenta condiciones complejas

---

## 🧭 Navegación

**← Anterior**: [Clase 6: Funciones Básicas de SQL](clase_6_funciones_basicas.md)  
**Siguiente →**: [Clase 8: Ordenamiento y Agrupación](clase_8_ordenamiento_agrupacion.md)

---

*¡Excelente trabajo! Ahora dominas los filtros avanzados de SQL. 🚀*
