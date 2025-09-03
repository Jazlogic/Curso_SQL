# Clase 4: Operaciones Básicas CRUD - Manipulación de Datos

## 📚 Descripción de la Clase
En esta clase aprenderás las operaciones fundamentales para manipular datos en una base de datos: CREATE (Crear), READ (Leer), UPDATE (Actualizar) y DELETE (Eliminar). Estas operaciones, conocidas como CRUD, son la base de cualquier aplicación que trabaje con bases de datos.

## 🎯 Objetivos de la Clase
Al finalizar esta clase, serás capaz de:
- Entender qué son las operaciones CRUD
- Insertar datos de diferentes formas
- Consultar datos con SELECT básico
- Actualizar registros existentes
- Eliminar registros de manera segura
- Aplicar mejores prácticas en operaciones de datos

## ⏱️ Duración Estimada
**3-4 horas** (dependiendo de tu ritmo de aprendizaje)

---

## 📖 Contenido Teórico

### ¿Qué son las Operaciones CRUD?

**CRUD** es un acrónimo que representa las cuatro operaciones básicas que se pueden realizar en una base de datos:

- **C**reate (Crear): INSERT - Agregar nuevos registros
- **R**ead (Leer): SELECT - Consultar y leer datos
- **U**pdate (Actualizar): UPDATE - Modificar registros existentes
- **D**elete (Eliminar): DELETE - Eliminar registros

Estas operaciones son fundamentales porque cubren todas las necesidades básicas de manipulación de datos en cualquier aplicación.

### 1. CREATE - Insertar Datos (INSERT)

El comando **INSERT** se utiliza para agregar nuevos registros a una tabla. Es la operación que permite "crear" datos en la base de datos.

#### Sintaxis Básica de INSERT

```sql
INSERT INTO nombre_tabla (columna1, columna2, columna3, ...)
VALUES (valor1, valor2, valor3, ...);
```

**Explicación línea por línea:**
- `INSERT INTO`: comando para insertar datos
- `nombre_tabla`: nombre de la tabla donde insertaremos
- `(columna1, columna2, columna3, ...)`: lista de columnas donde insertaremos
- `VALUES`: palabra clave que indica que vienen los valores
- `(valor1, valor2, valor3, ...)`: valores correspondientes a cada columna

#### Diferentes Formas de INSERT

##### 1. INSERT con Todas las Columnas
```sql
-- Insertar en todas las columnas (excepto auto-incremento)
INSERT INTO productos (nombre, precio, stock, categoria) 
VALUES ('Laptop HP', 899.99, 10, 'Electrónicos');
```

**Explicación línea por línea:**
- `INSERT INTO productos`: insertar en la tabla productos
- `(nombre, precio, stock, categoria)`: especifica las columnas
- `VALUES ('Laptop HP', 899.99, 10, 'Electrónicos')`: valores correspondientes
- `'Laptop HP'`: valor para nombre (texto)
- `899.99`: valor para precio (decimal)
- `10`: valor para stock (entero)
- `'Electrónicos'`: valor para categoria (texto)

##### 2. INSERT con Columnas Específicas
```sql
-- Insertar solo en algunas columnas
INSERT INTO productos (nombre, precio) 
VALUES ('Mouse Inalámbrico', 25.50);
```

**Explicación línea por línea:**
- `INSERT INTO productos`: insertar en la tabla productos
- `(nombre, precio)`: solo especifica estas dos columnas
- `VALUES ('Mouse Inalámbrico', 25.50)`: valores solo para estas columnas
- Las columnas no especificadas tomarán sus valores por defecto o NULL

##### 3. INSERT Múltiple
```sql
-- Insertar múltiples registros en una sola operación
INSERT INTO productos (nombre, precio, stock, categoria) VALUES
('Teclado Mecánico', 89.99, 15, 'Accesorios'),
('Monitor 24"', 199.99, 8, 'Electrónicos'),
('Auriculares', 49.99, 25, 'Accesorios');
```

**Explicación línea por línea:**
- `INSERT INTO productos`: insertar en la tabla productos
- `(nombre, precio, stock, categoria)`: columnas donde insertaremos
- `VALUES`: palabra clave para los valores
- `('Teclado Mecánico', 89.99, 15, 'Accesorios'),`: primera fila
- `('Monitor 24"', 199.99, 8, 'Electrónicos'),`: segunda fila
- `('Auriculares', 49.99, 25, 'Accesorios');`: tercera fila (sin coma al final)

### 2. READ - Consultar Datos (SELECT)

El comando **SELECT** se utiliza para leer y consultar datos de una tabla. Es la operación más utilizada en bases de datos.

#### Sintaxis Básica de SELECT

```sql
SELECT columna1, columna2, columna3, ...
FROM nombre_tabla
WHERE condicion;
```

**Explicación línea por línea:**
- `SELECT`: comando para consultar datos
- `columna1, columna2, columna3, ...`: columnas que queremos ver
- `FROM nombre_tabla`: tabla de donde obtenemos los datos
- `WHERE condicion`: condición para filtrar los datos (opcional)

#### Diferentes Formas de SELECT

##### 1. SELECT Todas las Columnas
```sql
-- Ver todos los datos de la tabla
SELECT * FROM productos;
```

**Explicación línea por línea:**
- `SELECT *`: el asterisco (*) significa "todas las columnas"
- `FROM productos`: de la tabla productos
- `;`: final de la instrucción

##### 2. SELECT Columnas Específicas
```sql
-- Ver solo algunas columnas
SELECT nombre, precio FROM productos;
```

**Explicación línea por línea:**
- `SELECT nombre, precio`: solo queremos ver estas dos columnas
- `FROM productos`: de la tabla productos

##### 3. SELECT con Alias
```sql
-- Usar alias para cambiar nombres de columnas
SELECT 
    nombre AS producto,
    precio AS precio_unitario,
    stock AS cantidad_disponible
FROM productos;
```

**Explicación línea por línea:**
- `SELECT`: comando para consultar
- `nombre AS producto`: columna nombre con alias "producto"
- `precio AS precio_unitario`: columna precio con alias "precio_unitario"
- `stock AS cantidad_disponible`: columna stock con alias "cantidad_disponible"
- `FROM productos`: de la tabla productos

### 3. UPDATE - Actualizar Datos

El comando **UPDATE** se utiliza para modificar registros existentes en una tabla.

#### Sintaxis Básica de UPDATE

```sql
UPDATE nombre_tabla
SET columna1 = valor1, columna2 = valor2, ...
WHERE condicion;
```

**Explicación línea por línea:**
- `UPDATE nombre_tabla`: actualizar en la tabla especificada
- `SET`: palabra clave que indica qué columnas actualizar
- `columna1 = valor1, columna2 = valor2, ...`: columnas y sus nuevos valores
- `WHERE condicion`: condición para especificar qué registros actualizar

#### Diferentes Formas de UPDATE

##### 1. UPDATE un Solo Registro
```sql
-- Actualizar un producto específico
UPDATE productos 
SET precio = 799.99, stock = 5 
WHERE id = 1;
```

**Explicación línea por línea:**
- `UPDATE productos`: actualizar en la tabla productos
- `SET precio = 799.99, stock = 5`: cambiar precio a 799.99 y stock a 5
- `WHERE id = 1`: solo el registro con id = 1

##### 2. UPDATE Múltiples Registros
```sql
-- Actualizar múltiples registros que cumplan una condición
UPDATE productos 
SET stock = stock + 10 
WHERE categoria = 'Electrónicos';
```

**Explicación línea por línea:**
- `UPDATE productos`: actualizar en la tabla productos
- `SET stock = stock + 10`: aumentar el stock en 10 unidades
- `WHERE categoria = 'Electrónicos'`: solo productos de la categoría Electrónicos

##### 3. UPDATE con Cálculos
```sql
-- Actualizar con cálculos
UPDATE productos 
SET precio = precio * 1.1 
WHERE precio < 100;
```

**Explicación línea por línea:**
- `UPDATE productos`: actualizar en la tabla productos
- `SET precio = precio * 1.1`: aumentar el precio en 10% (multiplicar por 1.1)
- `WHERE precio < 100`: solo productos con precio menor a 100

### 4. DELETE - Eliminar Datos

El comando **DELETE** se utiliza para eliminar registros de una tabla.

#### Sintaxis Básica de DELETE

```sql
DELETE FROM nombre_tabla
WHERE condicion;
```

**Explicación línea por línea:**
- `DELETE FROM nombre_tabla`: eliminar de la tabla especificada
- `WHERE condicion`: condición para especificar qué registros eliminar

#### Diferentes Formas de DELETE

##### 1. DELETE un Solo Registro
```sql
-- Eliminar un producto específico
DELETE FROM productos 
WHERE id = 5;
```

**Explicación línea por línea:**
- `DELETE FROM productos`: eliminar de la tabla productos
- `WHERE id = 5`: solo el registro con id = 5

##### 2. DELETE Múltiples Registros
```sql
-- Eliminar productos sin stock
DELETE FROM productos 
WHERE stock = 0;
```

**Explicación línea por línea:**
- `DELETE FROM productos`: eliminar de la tabla productos
- `WHERE stock = 0`: solo productos con stock igual a 0

##### 3. DELETE con Condiciones Complejas
```sql
-- Eliminar productos antiguos y sin stock
DELETE FROM productos 
WHERE stock = 0 AND precio < 50;
```

**Explicación línea por línea:**
- `DELETE FROM productos`: eliminar de la tabla productos
- `WHERE stock = 0 AND precio < 50`: productos que no tengan stock Y precio menor a 50

### ⚠️ Importante: DELETE sin WHERE

**NUNCA** ejecutes DELETE sin WHERE, ya que eliminará TODOS los registros de la tabla:

```sql
-- ¡PELIGROSO! Elimina TODOS los productos
DELETE FROM productos;
```

### Mejores Prácticas para Operaciones CRUD

#### 1. Siempre Usar WHERE en UPDATE y DELETE
```sql
-- ✅ CORRECTO: Especifica qué actualizar
UPDATE productos SET precio = 100 WHERE id = 1;

-- ❌ PELIGROSO: Actualiza TODOS los registros
UPDATE productos SET precio = 100;
```

#### 2. Verificar Antes de Eliminar
```sql
-- Primero consultar qué se va a eliminar
SELECT * FROM productos WHERE stock = 0;

-- Luego eliminar si es correcto
DELETE FROM productos WHERE stock = 0;
```

#### 3. Usar Transacciones para Operaciones Críticas
```sql
-- Iniciar transacción
START TRANSACTION;

-- Realizar operaciones
UPDATE productos SET stock = stock - 1 WHERE id = 1;
INSERT INTO ventas (producto_id, cantidad, fecha) VALUES (1, 1, NOW());

-- Confirmar cambios
COMMIT;

-- O cancelar si hay error
-- ROLLBACK;
```

---

## 💻 Ejemplos Prácticos

### Ejemplo 1: Sistema de Gestión de Productos

```sql
-- Crear base de datos para el ejemplo
CREATE DATABASE gestion_productos;
USE gestion_productos;

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

-- Insertar productos iniciales
INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
('Laptop HP Pavilion', 'Laptop de 15 pulgadas con procesador Intel i5', 899.99, 10, 'Electrónicos'),
('Mouse Logitech', 'Mouse óptico inalámbrico', 25.50, 50, 'Accesorios'),
('Teclado Mecánico', 'Teclado mecánico RGB', 89.99, 15, 'Accesorios'),
('Monitor Samsung', 'Monitor LED de 24 pulgadas', 199.99, 8, 'Electrónicos'),
('Auriculares Sony', 'Auriculares inalámbricos con cancelación de ruido', 149.99, 20, 'Accesorios');
```

**Explicación línea por línea:**

```sql
-- CREATE DATABASE gestion_productos;
--   CREATE DATABASE: comando para crear una nueva base de datos
--   gestion_productos: nombre de la base de datos

-- USE gestion_productos;
--   USE: comando para seleccionar la base de datos
--   gestion_productos: nombre de la base de datos a usar

-- CREATE TABLE productos (
--   CREATE TABLE: comando para crear una nueva tabla
--   productos: nombre de la tabla

-- id INT PRIMARY KEY AUTO_INCREMENT,
--   id: nombre de la columna
--   INT: tipo de dato entero
--   PRIMARY KEY: clave primaria
--   AUTO_INCREMENT: se incrementa automáticamente

-- nombre VARCHAR(200) NOT NULL,
--   nombre: nombre de la columna
--   VARCHAR(200): texto de máximo 200 caracteres
--   NOT NULL: no puede estar vacía

-- descripcion TEXT,
--   descripcion: nombre de la columna
--   TEXT: tipo de dato para textos largos

-- precio DECIMAL(10,2) NOT NULL,
--   precio: nombre de la columna
--   DECIMAL(10,2): número decimal con 10 dígitos totales y 2 decimales
--   NOT NULL: no puede estar vacía

-- stock INT DEFAULT 0,
--   stock: nombre de la columna
--   INT: tipo de dato entero
--   DEFAULT 0: valor por defecto es 0

-- categoria VARCHAR(50),
--   categoria: nombre de la columna
--   VARCHAR(50): texto de máximo 50 caracteres

-- fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
--   fecha_creacion: nombre de la columna
--   TIMESTAMP: tipo de dato marca de tiempo
--   DEFAULT CURRENT_TIMESTAMP: fecha y hora actual por defecto

-- );
--   ): cierre de la definición de la tabla
--   ;: final de la instrucción
```

### Ejemplo 2: Operaciones CRUD Completas

```sql
-- 1. CREATE - Insertar nuevos productos
INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
('Tablet iPad', 'Tablet Apple de 10.9 pulgadas', 499.99, 12, 'Electrónicos'),
('Cargador USB-C', 'Cargador rápido de 65W', 29.99, 30, 'Accesorios');

-- 2. READ - Consultar productos
-- Ver todos los productos
SELECT * FROM productos;

-- Ver solo productos de electrónicos
SELECT nombre, precio, stock FROM productos WHERE categoria = 'Electrónicos';

-- Ver productos con stock bajo
SELECT nombre, stock FROM productos WHERE stock < 10;

-- 3. UPDATE - Actualizar productos
-- Actualizar precio de un producto específico
UPDATE productos SET precio = 849.99 WHERE nombre = 'Laptop HP Pavilion';

-- Aumentar stock de todos los accesorios
UPDATE productos SET stock = stock + 5 WHERE categoria = 'Accesorios';

-- Actualizar descripción de un producto
UPDATE productos SET descripcion = 'Mouse óptico inalámbrico con batería de larga duración' 
WHERE nombre = 'Mouse Logitech';

-- 4. DELETE - Eliminar productos
-- Eliminar productos sin stock
DELETE FROM productos WHERE stock = 0;

-- Eliminar un producto específico (ejemplo: si ya no se vende)
DELETE FROM productos WHERE nombre = 'Auriculares Sony';
```

**Explicación línea por línea:**

```sql
-- INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
--   INSERT INTO: comando para insertar datos
--   productos: nombre de la tabla
--   (nombre, descripcion, precio, stock, categoria): columnas donde insertaremos
--   VALUES: palabra clave para los valores

-- ('Tablet iPad', 'Tablet Apple de 10.9 pulgadas', 499.99, 12, 'Electrónicos'),
--   'Tablet iPad': valor para nombre
--   'Tablet Apple de 10.9 pulgadas': valor para descripcion
--   499.99: valor para precio
--   12: valor para stock
--   'Electrónicos': valor para categoria
--   ,: separador entre filas

-- SELECT * FROM productos;
--   SELECT *: consultar todas las columnas
--   FROM productos: de la tabla productos

-- SELECT nombre, precio, stock FROM productos WHERE categoria = 'Electrónicos';
--   SELECT nombre, precio, stock: solo estas columnas
--   FROM productos: de la tabla productos
--   WHERE categoria = 'Electrónicos': solo registros donde categoria sea 'Electrónicos'

-- UPDATE productos SET precio = 849.99 WHERE nombre = 'Laptop HP Pavilion';
--   UPDATE productos: actualizar en la tabla productos
--   SET precio = 849.99: cambiar precio a 849.99
--   WHERE nombre = 'Laptop HP Pavilion': solo el producto con este nombre

-- DELETE FROM productos WHERE stock = 0;
--   DELETE FROM productos: eliminar de la tabla productos
--   WHERE stock = 0: solo productos con stock igual a 0
```

### Ejemplo 3: Operaciones con Condiciones Avanzadas

```sql
-- Consultas con múltiples condiciones
SELECT nombre, precio, stock 
FROM productos 
WHERE categoria = 'Electrónicos' AND precio > 200;

-- Actualizar con condiciones complejas
UPDATE productos 
SET precio = precio * 0.9 
WHERE categoria = 'Accesorios' AND stock > 20;

-- Eliminar con condiciones múltiples
DELETE FROM productos 
WHERE stock = 0 AND precio < 50;

-- Consultas con ordenamiento
SELECT nombre, precio 
FROM productos 
ORDER BY precio DESC;

-- Consultas con límite
SELECT nombre, precio 
FROM productos 
ORDER BY precio ASC 
LIMIT 3;
```

**Explicación línea por línea:**

```sql
-- SELECT nombre, precio, stock FROM productos WHERE categoria = 'Electrónicos' AND precio > 200;
--   SELECT nombre, precio, stock: solo estas columnas
--   FROM productos: de la tabla productos
--   WHERE categoria = 'Electrónicos' AND precio > 200: productos de electrónicos Y precio mayor a 200
--   AND: operador lógico que significa "y también"

-- UPDATE productos SET precio = precio * 0.9 WHERE categoria = 'Accesorios' AND stock > 20;
--   UPDATE productos: actualizar en la tabla productos
--   SET precio = precio * 0.9: reducir precio en 10% (multiplicar por 0.9)
--   WHERE categoria = 'Accesorios' AND stock > 20: solo accesorios con stock mayor a 20

-- SELECT nombre, precio FROM productos ORDER BY precio DESC;
--   SELECT nombre, precio: solo estas columnas
--   FROM productos: de la tabla productos
--   ORDER BY precio DESC: ordenar por precio de mayor a menor
--   DESC: descendente (de mayor a menor)

-- SELECT nombre, precio FROM productos ORDER BY precio ASC LIMIT 3;
--   SELECT nombre, precio: solo estas columnas
--   FROM productos: de la tabla productos
--   ORDER BY precio ASC: ordenar por precio de menor a mayor
--   ASC: ascendente (de menor a mayor)
--   LIMIT 3: solo mostrar los primeros 3 resultados
```

---

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Gestión de Empleados
**Objetivo**: Practicar operaciones CRUD básicas con una tabla de empleados.

**Instrucciones**:
1. Crea una tabla `empleados` con: id, nombre, apellido, email, salario, departamento
2. Inserta 5 empleados de ejemplo
3. Consulta todos los empleados
4. Actualiza el salario de un empleado específico
5. Elimina un empleado

**Solución paso a paso:**

```sql
-- Paso 1: Crear tabla de empleados
CREATE TABLE empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    departamento VARCHAR(50) NOT NULL
);

-- Explicación:
-- CREATE TABLE empleados: crear tabla llamada empleados
-- id INT PRIMARY KEY AUTO_INCREMENT: clave primaria auto-incremento
-- nombre VARCHAR(100) NOT NULL: nombre del empleado, obligatorio
-- apellido VARCHAR(100) NOT NULL: apellido del empleado, obligatorio
-- email VARCHAR(255) UNIQUE NOT NULL: email único y obligatorio
-- salario DECIMAL(10,2) NOT NULL: salario con 2 decimales, obligatorio
-- departamento VARCHAR(50) NOT NULL: departamento del empleado, obligatorio

-- Paso 2: Insertar empleados de ejemplo
INSERT INTO empleados (nombre, apellido, email, salario, departamento) VALUES
('Juan', 'Pérez', 'juan.perez@empresa.com', 35000.00, 'Ventas'),
('María', 'García', 'maria.garcia@empresa.com', 42000.00, 'IT'),
('Carlos', 'López', 'carlos.lopez@empresa.com', 38000.00, 'Marketing'),
('Ana', 'Martín', 'ana.martin@empresa.com', 45000.00, 'IT'),
('Pedro', 'Sánchez', 'pedro.sanchez@empresa.com', 32000.00, 'Ventas');

-- Explicación:
-- INSERT INTO empleados: insertar en la tabla empleados
-- (nombre, apellido, email, salario, departamento): columnas donde insertaremos
-- VALUES: palabra clave para los valores
-- Cada fila contiene: nombre, apellido, email, salario, departamento

-- Paso 3: Consultar todos los empleados
SELECT * FROM empleados;

-- Explicación:
-- SELECT *: consultar todas las columnas
-- FROM empleados: de la tabla empleados

-- Paso 4: Actualizar salario de un empleado específico
UPDATE empleados 
SET salario = 40000.00 
WHERE email = 'juan.perez@empresa.com';

-- Explicación:
-- UPDATE empleados: actualizar en la tabla empleados
-- SET salario = 40000.00: cambiar salario a 40000.00
-- WHERE email = 'juan.perez@empresa.com': solo el empleado con este email

-- Paso 5: Eliminar un empleado
DELETE FROM empleados 
WHERE email = 'pedro.sanchez@empresa.com';

-- Explicación:
-- DELETE FROM empleados: eliminar de la tabla empleados
-- WHERE email = 'pedro.sanchez@empresa.com': solo el empleado con este email
```

### Ejercicio 2: Gestión de Inventario
**Objetivo**: Practicar operaciones CRUD con condiciones complejas.

**Instrucciones**:
1. Usa la tabla `productos` del ejemplo anterior
2. Consulta productos con precio entre 50 y 200
3. Actualiza el stock de todos los productos de una categoría
4. Elimina productos con stock 0 y precio menor a 30

**Solución paso a paso:**

```sql
-- Consulta 1: Productos con precio entre 50 y 200
SELECT nombre, precio, stock 
FROM productos 
WHERE precio BETWEEN 50 AND 200;

-- Explicación:
-- SELECT nombre, precio, stock: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE precio BETWEEN 50 AND 200: productos con precio entre 50 y 200
-- BETWEEN: operador que significa "entre" (incluye los valores límite)

-- Consulta 2: Actualizar stock de todos los productos de una categoría
UPDATE productos 
SET stock = stock + 10 
WHERE categoria = 'Accesorios';

-- Explicación:
-- UPDATE productos: actualizar en la tabla productos
-- SET stock = stock + 10: aumentar stock en 10 unidades
-- WHERE categoria = 'Accesorios': solo productos de la categoría Accesorios

-- Consulta 3: Eliminar productos con stock 0 y precio menor a 30
DELETE FROM productos 
WHERE stock = 0 AND precio < 30;

-- Explicación:
-- DELETE FROM productos: eliminar de la tabla productos
-- WHERE stock = 0 AND precio < 30: productos que no tengan stock Y precio menor a 30
-- AND: operador lógico que significa "y también"
```

### Ejercicio 3: Reportes y Consultas Avanzadas
**Objetivo**: Practicar consultas complejas con múltiples condiciones.

**Instrucciones**:
1. Consulta el producto más caro
2. Consulta productos ordenados por stock (menor a mayor)
3. Actualiza precios aplicando un descuento del 15% a productos con stock alto
4. Consulta productos que empiecen con "L"

**Solución paso a paso:**

```sql
-- Consulta 1: Producto más caro
SELECT nombre, precio 
FROM productos 
ORDER BY precio DESC 
LIMIT 1;

-- Explicación:
-- SELECT nombre, precio: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY precio DESC: ordenar por precio de mayor a menor
-- LIMIT 1: solo mostrar el primer resultado (el más caro)

-- Consulta 2: Productos ordenados por stock (menor a mayor)
SELECT nombre, stock, categoria 
FROM productos 
ORDER BY stock ASC;

-- Explicación:
-- SELECT nombre, stock, categoria: solo estas columnas
-- FROM productos: de la tabla productos
-- ORDER BY stock ASC: ordenar por stock de menor a mayor
-- ASC: ascendente (de menor a mayor)

-- Consulta 3: Aplicar descuento del 15% a productos con stock alto
UPDATE productos 
SET precio = precio * 0.85 
WHERE stock > 20;

-- Explicación:
-- UPDATE productos: actualizar en la tabla productos
-- SET precio = precio * 0.85: reducir precio en 15% (multiplicar por 0.85)
-- WHERE stock > 20: solo productos con stock mayor a 20

-- Consulta 4: Productos que empiecen con "L"
SELECT nombre, precio, stock 
FROM productos 
WHERE nombre LIKE 'L%';

-- Explicación:
-- SELECT nombre, precio, stock: solo estas columnas
-- FROM productos: de la tabla productos
-- WHERE nombre LIKE 'L%': productos cuyo nombre empiece con "L"
-- LIKE: operador para búsquedas de texto
-- 'L%': patrón que significa "empieza con L seguido de cualquier cosa"
-- %: comodín que representa cualquier cantidad de caracteres
```

---

## 📝 Resumen de Conceptos Clave

### Operaciones CRUD:
- **CREATE (INSERT)**: Agregar nuevos registros
- **READ (SELECT)**: Consultar y leer datos
- **UPDATE**: Modificar registros existentes
- **DELETE**: Eliminar registros

### Comandos Aprendidos:

#### INSERT:
- `INSERT INTO tabla (columnas) VALUES (valores)`
- Insertar múltiples registros en una operación
- Usar valores por defecto para columnas no especificadas

#### SELECT:
- `SELECT columnas FROM tabla WHERE condicion`
- Usar `*` para todas las columnas
- Usar alias con `AS`
- Filtrar con `WHERE`

#### UPDATE:
- `UPDATE tabla SET columna = valor WHERE condicion`
- Actualizar múltiples columnas
- Usar cálculos en las actualizaciones
- **SIEMPRE usar WHERE**

#### DELETE:
- `DELETE FROM tabla WHERE condicion`
- **SIEMPRE usar WHERE**
- Verificar antes de eliminar

### Operadores Útiles:
- `AND`: Condición "y también"
- `OR`: Condición "o"
- `BETWEEN`: Entre dos valores
- `LIKE`: Búsqueda de texto con patrones
- `%`: Comodín para cualquier cantidad de caracteres

### Mejores Prácticas:
1. **Siempre usar WHERE** en UPDATE y DELETE
2. **Verificar antes de eliminar** con SELECT
3. **Usar transacciones** para operaciones críticas
4. **Hacer respaldos** antes de operaciones masivas
5. **Probar en desarrollo** antes de producción

---

## 🚀 Próximos Pasos

En la siguiente clase aprenderás:
- Consultas SELECT más avanzadas
- Filtros con WHERE y operadores
- Ordenamiento con ORDER BY
- Límites con LIMIT y OFFSET

---

## 💡 Consejos para el Éxito

1. **Practica cada operación**: No solo leas, ejecuta cada ejemplo
2. **Usa WHERE siempre**: En UPDATE y DELETE para evitar errores
3. **Verifica antes de eliminar**: Usa SELECT para ver qué se eliminará
4. **Haz respaldos**: Antes de operaciones importantes
5. **Documenta tus cambios**: Comenta qué hace cada operación

---

## 🧭 Navegación

**← Anterior**: [Clase 3: Relaciones entre Tablas](clase_3_relaciones_tablas.md)  
**Siguiente →**: [Clase 5: Consultas SELECT Avanzadas](clase_5_consultas_select.md)

---

*¡Excelente trabajo! Ahora dominas las operaciones CRUD básicas. 🚀*
