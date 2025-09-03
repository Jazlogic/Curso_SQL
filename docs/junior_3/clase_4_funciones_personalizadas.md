# Clase 4: Funciones Personalizadas

## 📋 Descripción

En esta clase aprenderás a crear funciones personalizadas en MySQL. Las funciones son similares a los procedimientos almacenados, pero siempre devuelven un valor y pueden ser utilizadas en expresiones SQL. Aprenderás a crear funciones escalares, de tabla y agregadas.

## 🎯 Objetivos de la Clase

- Comprender la diferencia entre procedimientos y funciones
- Aprender a crear funciones escalares
- Implementar funciones de tabla
- Crear funciones agregadas personalizadas
- Manejar parámetros y valores de retorno
- Optimizar el rendimiento de funciones

## 📚 Conceptos Clave

### ¿Qué es una Función Personalizada?

Una **función personalizada** es un bloque de código SQL que siempre devuelve un valor y puede ser utilizada en expresiones SQL, consultas SELECT, WHERE, ORDER BY, etc.

### Tipos de Funciones

1. **Funciones Escalares**: Devuelven un solo valor
2. **Funciones de Tabla**: Devuelven un conjunto de filas
3. **Funciones Agregadas**: Operan sobre conjuntos de datos

### Diferencias con Procedimientos

| Característica | Procedimiento | Función |
|----------------|---------------|---------|
| Valor de retorno | Opcional | Obligatorio |
| Uso en expresiones | No | Sí |
| Transacciones | Sí | No |
| Parámetros OUT | Sí | No |

## 🔧 Sintaxis y Comandos

### Crear Función Escalar

```sql
DELIMITER //

CREATE FUNCTION nombre_funcion(
    parametro1 TIPO,
    parametro2 TIPO
)
RETURNS TIPO
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE variable TIPO;
    -- lógica de la función
    RETURN valor;
END //

DELIMITER ;
```

### Crear Función de Tabla

```sql
DELIMITER //

CREATE FUNCTION nombre_funcion_tabla(parametro TIPO)
RETURNS TABLE (
    columna1 TIPO,
    columna2 TIPO
)
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN (
        SELECT columna1, columna2 
        FROM tabla 
        WHERE condicion
    );
END //

DELIMITER ;
```

### Gestionar Funciones

```sql
-- Ver funciones existentes
SHOW FUNCTION STATUS;

-- Ver código de una función
SHOW CREATE FUNCTION nombre_funcion;

-- Eliminar una función
DROP FUNCTION nombre_funcion;
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Función Escalar Básica

```sql
-- Función para calcular el precio con IVA
DELIMITER //

CREATE FUNCTION CalcularPrecioConIVA(
    precio_base DECIMAL(10,2),
    porcentaje_iva DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE precio_final DECIMAL(10,2);
    SET precio_final = precio_base * (1 + porcentaje_iva / 100);
    RETURN precio_final;
END //

DELIMITER ;

-- Usar la función en una consulta
SELECT 
    nombre,
    precio,
    CalcularPrecioConIVA(precio, 21.00) AS precio_con_iva
FROM productos;
```

**Explicación línea por línea:**

1. `CREATE FUNCTION CalcularPrecioConIVA(...)` - Crea la función con parámetros
2. `RETURNS DECIMAL(10,2)` - Especifica el tipo de retorno
3. `READS SQL DATA` - Indica que la función lee datos de la base
4. `DETERMINISTIC` - Indica que siempre devuelve el mismo resultado para los mismos parámetros
5. `DECLARE precio_final DECIMAL(10,2);` - Declara variable local
6. `SET precio_final = precio_base * (1 + porcentaje_iva / 100);` - Calcula el precio
7. `RETURN precio_final;` - Devuelve el resultado

### Ejemplo 2: Función con Lógica Condicional

```sql
-- Función para determinar el estado del stock
DELIMITER //

CREATE FUNCTION EstadoStock(stock_actual INT)
RETURNS VARCHAR(20)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE estado VARCHAR(20);
    
    IF stock_actual = 0 THEN
        SET estado = 'Sin Stock';
    ELSEIF stock_actual < 5 THEN
        SET estado = 'Stock Bajo';
    ELSEIF stock_actual < 20 THEN
        SET estado = 'Stock Medio';
    ELSE
        SET estado = 'Stock Alto';
    END IF;
    
    RETURN estado;
END //

DELIMITER ;

-- Usar la función
SELECT 
    nombre,
    stock,
    EstadoStock(stock) AS estado_actual
FROM productos;
```

### Ejemplo 3: Función con Consulta a Base de Datos

```sql
-- Función para obtener el nombre del producto por ID
DELIMITER //

CREATE FUNCTION ObtenerNombreProducto(producto_id INT)
RETURNS VARCHAR(100)
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE nombre_producto VARCHAR(100);
    
    SELECT nombre INTO nombre_producto 
    FROM productos 
    WHERE id = producto_id;
    
    RETURN COALESCE(nombre_producto, 'Producto no encontrado');
END //

DELIMITER ;

-- Usar la función
SELECT 
    id,
    ObtenerNombreProducto(id) AS nombre,
    precio
FROM productos;
```

### Ejemplo 4: Función de Tabla

```sql
-- Función para obtener productos por rango de precio
DELIMITER //

CREATE FUNCTION ProductosPorPrecio(
    precio_minimo DECIMAL(10,2),
    precio_maximo DECIMAL(10,2)
)
RETURNS TABLE (
    id INT,
    nombre VARCHAR(100),
    precio DECIMAL(10,2),
    stock INT
)
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN (
        SELECT id, nombre, precio, stock
        FROM productos
        WHERE precio BETWEEN precio_minimo AND precio_maximo
        ORDER BY precio
    );
END //

DELIMITER ;

-- Usar la función de tabla
SELECT * FROM ProductosPorPrecio(50.00, 200.00);
```

### Ejemplo 5: Función con Manejo de Errores

```sql
-- Función para dividir con manejo de errores
DELIMITER //

CREATE FUNCTION DividirSeguro(
    dividendo DECIMAL(10,2),
    divisor DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE resultado DECIMAL(10,2);
    
    -- Verificar división por cero
    IF divisor = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'División por cero no permitida';
    END IF;
    
    SET resultado = dividendo / divisor;
    RETURN resultado;
END //

DELIMITER ;

-- Usar la función
SELECT 
    nombre,
    precio,
    stock,
    DividirSeguro(precio, stock) AS precio_por_unidad
FROM productos;
```

### Ejemplo 6: Función con Cálculos Complejos

```sql
-- Función para calcular descuento por volumen
DELIMITER //

CREATE FUNCTION CalcularDescuentoVolumen(
    cantidad INT,
    precio_unitario DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE descuento DECIMAL(10,2) DEFAULT 0;
    DECLARE total DECIMAL(10,2);
    
    SET total = cantidad * precio_unitario;
    
    -- Aplicar descuentos por volumen
    IF cantidad >= 100 THEN
        SET descuento = total * 0.15; -- 15% de descuento
    ELSEIF cantidad >= 50 THEN
        SET descuento = total * 0.10; -- 10% de descuento
    ELSEIF cantidad >= 20 THEN
        SET descuento = total * 0.05; -- 5% de descuento
    END IF;
    
    RETURN descuento;
END //

DELIMITER ;

-- Usar la función
SELECT 
    nombre,
    precio,
    CalcularDescuentoVolumen(75, precio) AS descuento_aplicado
FROM productos;
```

### Ejemplo 7: Función con Fechas

```sql
-- Función para calcular días entre fechas
DELIMITER //

CREATE FUNCTION DiasEntreFechas(
    fecha_inicio DATE,
    fecha_fin DATE
)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE dias INT;
    
    -- Verificar que las fechas sean válidas
    IF fecha_inicio IS NULL OR fecha_fin IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Calcular diferencia en días
    SET dias = DATEDIFF(fecha_fin, fecha_inicio);
    
    -- Asegurar que el resultado sea positivo
    IF dias < 0 THEN
        SET dias = ABS(dias);
    END IF;
    
    RETURN dias;
END //

DELIMITER ;

-- Usar la función
SELECT 
    id,
    fecha_venta,
    DiasEntreFechas(fecha_venta, CURDATE()) AS dias_desde_venta
FROM ventas;
```

### Ejemplo 8: Función con Validación de Datos

```sql
-- Función para validar email
DELIMITER //

CREATE FUNCTION ValidarEmail(email VARCHAR(255))
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE es_valido BOOLEAN DEFAULT FALSE;
    
    -- Verificar formato básico de email
    IF email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$' THEN
        SET es_valido = TRUE;
    END IF;
    
    RETURN es_valido;
END //

DELIMITER ;

-- Usar la función
SELECT 
    'usuario@ejemplo.com' AS email,
    ValidarEmail('usuario@ejemplo.com') AS es_valido;
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Función de Cálculo
Crea una función que calcule el área de un rectángulo dados su base y altura.

### Ejercicio 2: Función de Validación
Implementa una función que valide si un número es primo.

### Ejercicio 3: Función de Formato
Crea una función que formatee un número como moneda con símbolo de peso.

### Ejercicio 4: Función de Conversión
Implementa una función que convierta grados Celsius a Fahrenheit.

### Ejercicio 5: Función de Búsqueda
Crea una función que busque productos por nombre y devuelva el ID.

### Ejercicio 6: Función de Cálculo de Edad
Implementa una función que calcule la edad en años dados la fecha de nacimiento.

### Ejercicio 7: Función de Validación de Teléfono
Crea una función que valide el formato de un número de teléfono.

### Ejercicio 8: Función de Generación de Código
Implementa una función que genere un código único para productos.

### Ejercicio 9: Función de Cálculo de Interés
Crea una función que calcule interés compuesto.

### Ejercicio 10: Función de Tabla Compleja
Implementa una función de tabla que devuelva estadísticas de ventas por período.

## 📝 Resumen

En esta clase has aprendido:

- **Funciones personalizadas**: Bloques de código que siempre devuelven un valor
- **Tipos de funciones**: Escalares, de tabla y agregadas
- **Sintaxis básica**: CREATE FUNCTION, parámetros y RETURNS
- **Características**: DETERMINISTIC, READS SQL DATA
- **Uso en consultas**: Integración en expresiones SQL
- **Manejo de errores**: Validación y excepciones en funciones

## 🔗 Próximos Pasos

- [Clase 5: Triggers y Automatización](clase_5_triggers_automatizacion.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 4!** 🎉 Continúa con la siguiente clase para aprender sobre triggers y automatización.
