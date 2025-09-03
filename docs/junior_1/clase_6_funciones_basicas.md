# Clase 6: Funciones Básicas de SQL - Manipulación de Datos

## 📚 Descripción de la Clase
En esta clase aprenderás las funciones básicas de SQL que te permitirán manipular, transformar y calcular datos de manera más eficiente. Cubriremos funciones de texto, numéricas, de fecha y de conversión, que son fundamentales para crear consultas más potentes y útiles.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Usar funciones de texto para manipular cadenas
- Aplicar funciones numéricas para cálculos
- Trabajar con funciones de fecha y hora
- Convertir tipos de datos con funciones de conversión
- Combinar funciones para crear consultas complejas
- Optimizar consultas usando funciones apropiadas

## ⏱️ Duración Estimada
**3-4 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son las Funciones en SQL?

Las **funciones** en SQL son operaciones predefinidas que toman uno o más valores como entrada y devuelven un resultado. Son herramientas poderosas que permiten:
- **Transformar datos**: Cambiar el formato o contenido de los datos
- **Calcular valores**: Realizar operaciones matemáticas
- **Manipular texto**: Procesar cadenas de caracteres
- **Trabajar con fechas**: Manejar fechas y horas
- **Convertir tipos**: Cambiar el tipo de dato

### Sintaxis General de Funciones

```sql
SELECT FUNCION(argumento1, argumento2, ...) AS alias
FROM tabla
WHERE condicion;
```

**Explicación línea por línea:**
- `FUNCION`: nombre de la función a usar
- `(argumento1, argumento2, ...)`: valores de entrada para la función
- `AS alias`: nombre alternativo para el resultado (opcional)
- `FROM tabla`: tabla de donde obtener los datos
- `WHERE condicion`: condición para filtrar (opcional)

### 1. Funciones de Texto (String Functions)

Las funciones de texto permiten manipular cadenas de caracteres de diversas maneras.

#### 1.1 CONCAT - Concatenar Texto
```sql
-- Unir múltiples cadenas de texto
SELECT CONCAT(nombre, ' - ', categoria) AS producto_completo
FROM productos;
```

**Explicación línea por línea:**
- `CONCAT`: función que une múltiples cadenas de texto
- `nombre`: primera cadena a unir
- `' - '`: cadena literal (espacio, guión, espacio)
- `categoria`: segunda cadena a unir
- `AS producto_completo`: alias para el resultado

#### 1.2 UPPER y LOWER - Cambiar Mayúsculas/Minúsculas
```sql
-- Convertir a mayúsculas
SELECT UPPER(nombre) AS nombre_mayusculas
FROM productos;

-- Convertir a minúsculas
SELECT LOWER(nombre) AS nombre_minusculas
FROM productos;
```

**Explicación línea por línea:**
- `UPPER(nombre)`: convierte el texto a mayúsculas
- `LOWER(nombre)`: convierte el texto a minúsculas
- `AS nombre_mayusculas`: alias para el resultado

#### 1.3 LENGTH - Longitud de Texto
```sql
-- Obtener la longitud de una cadena
SELECT nombre, LENGTH(nombre) AS longitud_nombre
FROM productos;
```

**Explicación línea por línea:**
- `LENGTH(nombre)`: cuenta el número de caracteres en el nombre
- `AS longitud_nombre`: alias para el resultado

#### 1.4 SUBSTRING - Extraer Parte del Texto
```sql
-- Extraer parte de una cadena
SELECT nombre, SUBSTRING(nombre, 1, 10) AS primeras_10_letras
FROM productos;
```

**Explicación línea por línea:**
- `SUBSTRING(nombre, 1, 10)`: extrae 10 caracteres empezando desde la posición 1
- `1`: posición inicial (1 = primer carácter)
- `10`: número de caracteres a extraer
- `AS primeras_10_letras`: alias para el resultado

#### 1.5 TRIM - Eliminar Espacios
```sql
-- Eliminar espacios al inicio y final
SELECT TRIM('   Texto con espacios   ') AS texto_limpio;
```

**Explicación línea por línea:**
- `TRIM('   Texto con espacios   ')`: elimina espacios al inicio y final
- `AS texto_limpio`: alias para el resultado

#### 1.6 REPLACE - Reemplazar Texto
```sql
-- Reemplazar parte de una cadena
SELECT nombre, REPLACE(nombre, 'HP', 'Hewlett-Packard') AS nombre_completo
FROM productos;
```

**Explicación línea por línea:**
- `REPLACE(nombre, 'HP', 'Hewlett-Packard')`: reemplaza 'HP' con 'Hewlett-Packard'
- `'HP'`: texto a buscar
- `'Hewlett-Packard'`: texto de reemplazo
- `AS nombre_completo`: alias para el resultado

### 2. Funciones Numéricas (Numeric Functions)

Las funciones numéricas permiten realizar cálculos matemáticos y operaciones con números.

#### 2.1 ROUND - Redondear Números
```sql
-- Redondear a 2 decimales
SELECT precio, ROUND(precio, 2) AS precio_redondeado
FROM productos;

-- Redondear a entero
SELECT precio, ROUND(precio) AS precio_entero
FROM productos;
```

**Explicación línea por línea:**
- `ROUND(precio, 2)`: redondea a 2 decimales
- `ROUND(precio)`: redondea a entero (sin decimales)
- `AS precio_redondeado`: alias para el resultado

#### 2.2 CEIL y FLOOR - Redondear Hacia Arriba/Abajo
```sql
-- Redondear hacia arriba
SELECT precio, CEIL(precio) AS precio_arriba
FROM productos;

-- Redondear hacia abajo
SELECT precio, FLOOR(precio) AS precio_abajo
FROM productos;
```

**Explicación línea por línea:**
- `CEIL(precio)`: redondea hacia arriba al entero más cercano
- `FLOOR(precio)`: redondea hacia abajo al entero más cercano
- `AS precio_arriba`: alias para el resultado

#### 2.3 ABS - Valor Absoluto
```sql
-- Obtener valor absoluto
SELECT precio, ABS(precio) AS valor_absoluto
FROM productos;
```

**Explicación línea por línea:**
- `ABS(precio)`: devuelve el valor absoluto (sin signo negativo)
- `AS valor_absoluto`: alias para el resultado

#### 2.4 MOD - Módulo (Resto de División)
```sql
-- Obtener resto de división
SELECT stock, MOD(stock, 5) AS resto_division_5
FROM productos;
```

**Explicación línea por línea:**
- `MOD(stock, 5)`: devuelve el resto de dividir stock entre 5
- `AS resto_division_5`: alias para el resultado

#### 2.5 POWER - Potencia
```sql
-- Elevar a una potencia
SELECT precio, POWER(precio, 2) AS precio_al_cuadrado
FROM productos;
```

**Explicación línea por línea:**
- `POWER(precio, 2)`: eleva el precio a la potencia 2 (al cuadrado)
- `AS precio_al_cuadrado`: alias para el resultado

### 3. Funciones de Fecha y Hora (Date Functions)

Las funciones de fecha permiten trabajar con fechas y horas de manera eficiente.

#### 3.1 NOW - Fecha y Hora Actual
```sql
-- Obtener fecha y hora actual
SELECT NOW() AS fecha_actual;
```

**Explicación línea por línea:**
- `NOW()`: devuelve la fecha y hora actual del sistema
- `AS fecha_actual`: alias para el resultado

#### 3.2 CURDATE - Fecha Actual
```sql
-- Obtener solo la fecha actual
SELECT CURDATE() AS fecha_hoy;
```

**Explicación línea por línea:**
- `CURDATE()`: devuelve solo la fecha actual (sin hora)
- `AS fecha_hoy`: alias para el resultado

#### 3.3 CURTIME - Hora Actual
```sql
-- Obtener solo la hora actual
SELECT CURTIME() AS hora_actual;
```

**Explicación línea por línea:**
- `CURTIME()`: devuelve solo la hora actual (sin fecha)
- `AS hora_actual`: alias para el resultado

#### 3.4 YEAR, MONTH, DAY - Extraer Partes de Fecha
```sql
-- Extraer año, mes y día de una fecha
SELECT 
    fecha_creacion,
    YEAR(fecha_creacion) AS año,
    MONTH(fecha_creacion) AS mes,
    DAY(fecha_creacion) AS dia
FROM productos;
```

**Explicación línea por línea:**
- `YEAR(fecha_creacion)`: extrae el año de la fecha
- `MONTH(fecha_creacion)`: extrae el mes de la fecha
- `DAY(fecha_creacion)`: extrae el día de la fecha
- `AS año`: alias para el resultado

#### 3.5 DATE_ADD y DATE_SUB - Sumar/Restar Fechas
```sql
-- Sumar días a una fecha
SELECT fecha_creacion, DATE_ADD(fecha_creacion, INTERVAL 30 DAY) AS fecha_mas_30_dias
FROM productos;

-- Restar días de una fecha
SELECT fecha_creacion, DATE_SUB(fecha_creacion, INTERVAL 7 DAY) AS fecha_menos_7_dias
FROM productos;
```

**Explicación línea por línea:**
- `DATE_ADD(fecha_creacion, INTERVAL 30 DAY)`: suma 30 días a la fecha
- `DATE_SUB(fecha_creacion, INTERVAL 7 DAY)`: resta 7 días de la fecha
- `INTERVAL 30 DAY`: especifica el intervalo (30 días)
- `AS fecha_mas_30_dias`: alias para el resultado

#### 3.6 DATEDIFF - Diferencia Entre Fechas
```sql
-- Calcular diferencia en días entre fechas
SELECT 
    fecha_creacion,
    DATEDIFF(NOW(), fecha_creacion) AS dias_desde_creacion
FROM productos;
```

**Explicación línea por línea:**
- `DATEDIFF(NOW(), fecha_creacion)`: calcula la diferencia en días
- `NOW()`: fecha actual
- `fecha_creacion`: fecha de creación del producto
- `AS dias_desde_creacion`: alias para el resultado

### 4. Funciones de Conversión (Conversion Functions)

Las funciones de conversión permiten cambiar el tipo de dato de un valor.

#### 4.1 CAST - Convertir Tipos
```sql
-- Convertir número a texto
SELECT precio, CAST(precio AS CHAR) AS precio_texto
FROM productos;

-- Convertir texto a número
SELECT stock, CAST(stock AS DECIMAL(10,2)) AS stock_decimal
FROM productos;
```

**Explicación línea por línea:**
- `CAST(precio AS CHAR)`: convierte el precio a texto
- `CAST(stock AS DECIMAL(10,2))`: convierte el stock a decimal
- `AS precio_texto`: alias para el resultado

#### 4.2 CONVERT - Convertir Tipos (Alternativa)
```sql
-- Convertir usando CONVERT
SELECT precio, CONVERT(precio, CHAR) AS precio_texto
FROM productos;
```

**Explicación línea por línea:**
- `CONVERT(precio, CHAR)`: convierte el precio a texto
- `AS precio_texto`: alias para el resultado

### 5. Funciones de Condición

Las funciones de condición permiten crear lógica condicional en las consultas.

#### 5.1 IF - Condición Simple
```sql
-- Usar IF para condiciones
SELECT 
    nombre,
    precio,
    IF(precio > 100, 'Caro', 'Barato') AS categoria_precio
FROM productos;
```

**Explicación línea por línea:**
- `IF(precio > 100, 'Caro', 'Barato')`: si precio > 100, devuelve 'Caro', sino 'Barato'
- `precio > 100`: condición a evaluar
- `'Caro'`: valor si la condición es verdadera
- `'Barato'`: valor si la condición es falsa
- `AS categoria_precio`: alias para el resultado

#### 5.2 CASE - Condiciones Múltiples
```sql
-- Usar CASE para múltiples condiciones
SELECT 
    nombre,
    precio,
    CASE 
        WHEN precio > 500 THEN 'Muy Caro'
        WHEN precio > 200 THEN 'Caro'
        WHEN precio > 50 THEN 'Moderado'
        ELSE 'Barato'
    END AS categoria_precio
FROM productos;
```

**Explicación línea por línea:**
- `CASE`: inicia la estructura condicional
- `WHEN precio > 500 THEN 'Muy Caro'`: si precio > 500, devuelve 'Muy Caro'
- `WHEN precio > 200 THEN 'Caro'`: si precio > 200, devuelve 'Caro'
- `WHEN precio > 50 THEN 'Moderado'`: si precio > 50, devuelve 'Moderado'
- `ELSE 'Barato'`: en cualquier otro caso, devuelve 'Barato'
- `END`: termina la estructura CASE
- `AS categoria_precio`: alias para el resultado

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Sistema de Gestión con Funciones

```sql
-- Crear base de datos para el ejemplo
CREATE DATABASE funciones_sql;
USE funciones_sql;

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
('Smartphone iPhone 14', 'Smartphone Apple con cámara de 48MP', 999.99, 5, 'Electrónicos');
```

### Ejemplo 2: Funciones de Texto en Acción

```sql
-- Consulta 1: Concatenar información del producto
SELECT 
    CONCAT(nombre, ' - ', categoria) AS producto_categoria,
    CONCAT('$', precio) AS precio_formateado
FROM productos;

-- Explicación línea por línea:
-- CONCAT(nombre, ' - ', categoria): une nombre, guión y categoría
-- CONCAT('$', precio): une símbolo de dólar con el precio
-- AS producto_categoria: alias para el resultado

-- Consulta 2: Manipular texto
SELECT 
    nombre,
    UPPER(nombre) AS nombre_mayusculas,
    LOWER(nombre) AS nombre_minusculas,
    LENGTH(nombre) AS longitud_nombre,
    SUBSTRING(nombre, 1, 15) AS primeras_15_letras
FROM productos;

-- Explicación línea por línea:
-- UPPER(nombre): convierte a mayúsculas
-- LOWER(nombre): convierte a minúsculas
-- LENGTH(nombre): cuenta caracteres
-- SUBSTRING(nombre, 1, 15): extrae primeros 15 caracteres

-- Consulta 3: Reemplazar texto
SELECT 
    nombre,
    REPLACE(nombre, 'HP', 'Hewlett-Packard') AS nombre_completo,
    REPLACE(nombre, ' ', '_') AS nombre_con_guiones
FROM productos;

-- Explicación línea por línea:
-- REPLACE(nombre, 'HP', 'Hewlett-Packard'): reemplaza 'HP' con 'Hewlett-Packard'
-- REPLACE(nombre, ' ', '_'): reemplaza espacios con guiones bajos
```

### Ejemplo 3: Funciones Numéricas en Acción

```sql
-- Consulta 1: Operaciones matemáticas con precios
SELECT 
    nombre,
    precio,
    ROUND(precio, 1) AS precio_redondeado_1_decimal,
    CEIL(precio) AS precio_redondeado_arriba,
    FLOOR(precio) AS precio_redondeado_abajo,
    ABS(precio) AS valor_absoluto
FROM productos;

-- Explicación línea por línea:
-- ROUND(precio, 1): redondea a 1 decimal
-- CEIL(precio): redondea hacia arriba
-- FLOOR(precio): redondea hacia abajo
-- ABS(precio): valor absoluto

-- Consulta 2: Cálculos con stock
SELECT 
    nombre,
    stock,
    MOD(stock, 5) AS resto_division_5,
    POWER(stock, 2) AS stock_al_cuadrado,
    (precio * stock) AS valor_total_inventario
FROM productos;

-- Explicación línea por línea:
-- MOD(stock, 5): resto de dividir stock entre 5
-- POWER(stock, 2): stock elevado al cuadrado
-- (precio * stock): cálculo del valor total del inventario

-- Consulta 3: Aplicar descuentos
SELECT 
    nombre,
    precio AS precio_original,
    ROUND(precio * 0.9, 2) AS precio_con_10_descuento,
    ROUND(precio * 0.8, 2) AS precio_con_20_descuento,
    ROUND(precio - (precio * 0.1), 2) AS ahorro_10_porciento
FROM productos;

-- Explicación línea por línea:
-- precio * 0.9: precio con 10% de descuento
-- precio * 0.8: precio con 20% de descuento
-- precio - (precio * 0.1): cantidad ahorrada con 10% de descuento
```

### Ejemplo 4: Funciones de Fecha en Acción

```sql
-- Consulta 1: Información de fechas
SELECT 
    nombre,
    fecha_creacion,
    YEAR(fecha_creacion) AS año_creacion,
    MONTH(fecha_creacion) AS mes_creacion,
    DAY(fecha_creacion) AS dia_creacion,
    DATEDIFF(NOW(), fecha_creacion) AS dias_desde_creacion
FROM productos;

-- Explicación línea por línea:
-- YEAR(fecha_creacion): extrae el año
-- MONTH(fecha_creacion): extrae el mes
-- DAY(fecha_creacion): extrae el día
-- DATEDIFF(NOW(), fecha_creacion): días transcurridos desde la creación

-- Consulta 2: Fechas futuras
SELECT 
    nombre,
    fecha_creacion,
    DATE_ADD(fecha_creacion, INTERVAL 30 DAY) AS fecha_mas_30_dias,
    DATE_ADD(fecha_creacion, INTERVAL 1 YEAR) AS fecha_mas_1_año,
    DATE_SUB(fecha_creacion, INTERVAL 7 DAY) AS fecha_menos_7_dias
FROM productos;

-- Explicación línea por línea:
-- DATE_ADD(fecha_creacion, INTERVAL 30 DAY): suma 30 días
-- DATE_ADD(fecha_creacion, INTERVAL 1 YEAR): suma 1 año
-- DATE_SUB(fecha_creacion, INTERVAL 7 DAY): resta 7 días

-- Consulta 3: Productos por antigüedad
SELECT 
    nombre,
    fecha_creacion,
    DATEDIFF(NOW(), fecha_creacion) AS dias_antiguedad,
    CASE 
        WHEN DATEDIFF(NOW(), fecha_creacion) > 30 THEN 'Antiguo'
        WHEN DATEDIFF(NOW(), fecha_creacion) > 7 THEN 'Reciente'
        ELSE 'Nuevo'
    END AS categoria_antiguedad
FROM productos;

-- Explicación línea por línea:
-- DATEDIFF(NOW(), fecha_creacion): días de antigüedad
-- CASE: estructura condicional para categorizar por antigüedad
-- WHEN ... THEN: condiciones para cada categoría
-- ELSE: categoría por defecto
```

### Ejemplo 5: Funciones de Conversión y Condición

```sql
-- Consulta 1: Conversión de tipos
SELECT 
    nombre,
    precio,
    CAST(precio AS CHAR) AS precio_texto,
    CAST(stock AS DECIMAL(10,2)) AS stock_decimal,
    CONCAT('Producto: ', nombre, ' - Precio: $', CAST(precio AS CHAR)) AS descripcion_completa
FROM productos;

-- Explicación línea por línea:
-- CAST(precio AS CHAR): convierte precio a texto
-- CAST(stock AS DECIMAL(10,2)): convierte stock a decimal
-- CONCAT(...): une texto con valores convertidos

-- Consulta 2: Condiciones con IF
SELECT 
    nombre,
    precio,
    stock,
    IF(precio > 100, 'Caro', 'Barato') AS categoria_precio,
    IF(stock > 10, 'Bien Stock', 'Stock Bajo') AS estado_stock,
    IF(precio > 100 AND stock > 10, 'Producto Premium', 'Producto Regular') AS tipo_producto
FROM productos;

-- Explicación línea por línea:
-- IF(precio > 100, 'Caro', 'Barato'): categoriza por precio
-- IF(stock > 10, 'Bien Stock', 'Stock Bajo'): categoriza por stock
-- IF(precio > 100 AND stock > 10, ...): categoriza por precio Y stock

-- Consulta 3: Condiciones múltiples con CASE
SELECT 
    nombre,
    precio,
    stock,
    CASE 
        WHEN precio > 500 THEN 'Muy Caro'
        WHEN precio > 200 THEN 'Caro'
        WHEN precio > 50 THEN 'Moderado'
        ELSE 'Barato'
    END AS categoria_precio,
    CASE 
        WHEN stock > 20 THEN 'Excelente Stock'
        WHEN stock > 10 THEN 'Buen Stock'
        WHEN stock > 5 THEN 'Stock Regular'
        ELSE 'Stock Bajo'
    END AS estado_stock,
    CASE 
        WHEN precio > 500 AND stock > 20 THEN 'Producto Premium'
        WHEN precio > 200 AND stock > 10 THEN 'Producto Estándar'
        ELSE 'Producto Básico'
    END AS tipo_producto
FROM productos;

-- Explicación línea por línea:
-- CASE: estructura condicional múltiple
-- WHEN ... THEN: condiciones para cada categoría
-- ELSE: categoría por defecto
-- Múltiples CASE para diferentes aspectos del producto
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Funciones de Texto
**Objetivo**: Practicar funciones de manipulación de texto.

**Instrucciones**:
Usando la tabla `productos`, crea consultas que:
1. Concatenen nombre y categoría con un separador
2. Muestren nombres en mayúsculas y minúsculas
3. Extraigan las primeras 10 letras del nombre
4. Reemplacen espacios con guiones bajos

**Solución paso a paso:**

```sql
-- Consulta 1: Concatenar nombre y categoría
SELECT 
    CONCAT(nombre, ' | ', categoria) AS producto_categoria
FROM productos;

-- Explicación:
-- CONCAT(nombre, ' | ', categoria): une nombre, separador y categoría
-- AS producto_categoria: alias para el resultado

-- Consulta 2: Nombres en mayúsculas y minúsculas
SELECT 
    nombre,
    UPPER(nombre) AS nombre_mayusculas,
    LOWER(nombre) AS nombre_minusculas
FROM productos;

-- Explicación:
-- UPPER(nombre): convierte a mayúsculas
-- LOWER(nombre): convierte a minúsculas

-- Consulta 3: Primeras 10 letras del nombre
SELECT 
    nombre,
    SUBSTRING(nombre, 1, 10) AS primeras_10_letras
FROM productos;

-- Explicación:
-- SUBSTRING(nombre, 1, 10): extrae 10 caracteres desde la posición 1

-- Consulta 4: Reemplazar espacios con guiones bajos
SELECT 
    nombre,
    REPLACE(nombre, ' ', '_') AS nombre_con_guiones
FROM productos;

-- Explicación:
-- REPLACE(nombre, ' ', '_'): reemplaza espacios con guiones bajos
```

### Ejercicio 2: Funciones Numéricas
**Objetivo**: Practicar funciones matemáticas y cálculos.

**Instrucciones**:
1. Redondear precios a 1 decimal
2. Calcular el valor total del inventario
3. Aplicar un descuento del 15% a productos caros
4. Mostrar el resto de dividir stock entre 3

**Solución paso a paso:**

```sql
-- Consulta 1: Redondear precios
SELECT 
    nombre,
    precio,
    ROUND(precio, 1) AS precio_redondeado
FROM productos;

-- Explicación:
-- ROUND(precio, 1): redondea a 1 decimal

-- Consulta 2: Valor total del inventario
SELECT 
    nombre,
    precio,
    stock,
    (precio * stock) AS valor_total_inventario
FROM productos;

-- Explicación:
-- (precio * stock): multiplica precio por stock para obtener valor total

-- Consulta 3: Descuento del 15% a productos caros
SELECT 
    nombre,
    precio AS precio_original,
    CASE 
        WHEN precio > 100 THEN ROUND(precio * 0.85, 2)
        ELSE precio
    END AS precio_con_descuento
FROM productos;

-- Explicación:
-- CASE: estructura condicional
-- WHEN precio > 100: solo productos caros
-- precio * 0.85: aplicar 15% de descuento
-- ELSE precio: mantener precio original

-- Consulta 4: Resto de división
SELECT 
    nombre,
    stock,
    MOD(stock, 3) AS resto_division_3
FROM productos;

-- Explicación:
-- MOD(stock, 3): resto de dividir stock entre 3
```

### Ejercicio 3: Funciones de Fecha
**Objetivo**: Practicar funciones de fecha y tiempo.

**Instrucciones**:
1. Mostrar año, mes y día de creación
2. Calcular días transcurridos desde la creación
3. Mostrar fecha de creación más 45 días
4. Categorizar productos por antigüedad

**Solución paso a paso:**

```sql
-- Consulta 1: Partes de la fecha
SELECT 
    nombre,
    fecha_creacion,
    YEAR(fecha_creacion) AS año,
    MONTH(fecha_creacion) AS mes,
    DAY(fecha_creacion) AS dia
FROM productos;

-- Explicación:
-- YEAR(fecha_creacion): extrae el año
-- MONTH(fecha_creacion): extrae el mes
-- DAY(fecha_creacion): extrae el día

-- Consulta 2: Días transcurridos
SELECT 
    nombre,
    fecha_creacion,
    DATEDIFF(NOW(), fecha_creacion) AS dias_transcurridos
FROM productos;

-- Explicación:
-- DATEDIFF(NOW(), fecha_creacion): diferencia en días entre fecha actual y creación

-- Consulta 3: Fecha más 45 días
SELECT 
    nombre,
    fecha_creacion,
    DATE_ADD(fecha_creacion, INTERVAL 45 DAY) AS fecha_mas_45_dias
FROM productos;

-- Explicación:
-- DATE_ADD(fecha_creacion, INTERVAL 45 DAY): suma 45 días a la fecha de creación

-- Consulta 4: Categorizar por antigüedad
SELECT 
    nombre,
    fecha_creacion,
    DATEDIFF(NOW(), fecha_creacion) AS dias_antiguedad,
    CASE 
        WHEN DATEDIFF(NOW(), fecha_creacion) > 30 THEN 'Antiguo'
        WHEN DATEDIFF(NOW(), fecha_creacion) > 7 THEN 'Reciente'
        ELSE 'Nuevo'
    END AS categoria_antiguedad
FROM productos;

-- Explicación:
-- CASE: estructura condicional
-- WHEN ... THEN: condiciones para cada categoría
-- ELSE: categoría por defecto
```

---

## 📝 Resumen de Conceptos Clave

### Funciones de Texto:
- **CONCAT**: Unir cadenas de texto
- **UPPER/LOWER**: Cambiar mayúsculas/minúsculas
- **LENGTH**: Longitud de una cadena
- **SUBSTRING**: Extraer parte del texto
- **TRIM**: Eliminar espacios
- **REPLACE**: Reemplazar texto

### Funciones Numéricas:
- **ROUND**: Redondear números
- **CEIL/FLOOR**: Redondear hacia arriba/abajo
- **ABS**: Valor absoluto
- **MOD**: Resto de división
- **POWER**: Potencia

### Funciones de Fecha:
- **NOW**: Fecha y hora actual
- **CURDATE**: Fecha actual
- **CURTIME**: Hora actual
- **YEAR/MONTH/DAY**: Extraer partes de fecha
- **DATE_ADD/DATE_SUB**: Sumar/restar fechas
- **DATEDIFF**: Diferencia entre fechas

### Funciones de Conversión:
- **CAST**: Convertir tipos de datos
- **CONVERT**: Convertir tipos (alternativa)

### Funciones de Condición:
- **IF**: Condición simple
- **CASE**: Condiciones múltiples

### Mejores Prácticas:
1. **Usa alias descriptivos** para los resultados de funciones
2. **Combina funciones** para crear consultas más potentes
3. **Prueba funciones** con datos de ejemplo
4. **Documenta cálculos complejos** con comentarios
5. **Optimiza consultas** usando funciones apropiadas

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Filtros avanzados con WHERE
- Operadores LIKE con patrones complejos
- Operadores IN y BETWEEN
- Condiciones con IS NULL e IS NOT NULL

---

## 💡 Consejos para el Éxito

1. **Practica con datos reales**: Usa ejemplos que te interesen
2. **Combina funciones**: Experimenta con múltiples funciones
3. **Usa alias descriptivos**: Hace las consultas más legibles
4. **Prueba diferentes tipos**: Experimenta con texto, números y fechas
5. **Documenta tus cálculos**: Comenta qué hace cada función

---

## 🧭 Navegación

**← Anterior**: [Clase 5: Consultas SELECT Avanzadas](clase_5_consultas_select.md)  
**Siguiente →**: [Clase 7: Filtros Avanzados](clase_7_filtros_avanzados.md)

---

*¡Excelente trabajo! Ahora dominas las funciones básicas de SQL. 🚀*
