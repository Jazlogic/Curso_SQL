# Clase 2: Procedimientos Almacenados Básicos

## 📋 Descripción

En esta clase aprenderás a crear y usar procedimientos almacenados en MySQL. Los procedimientos almacenados son bloques de código SQL que se almacenan en la base de datos y pueden ser ejecutados múltiples veces, mejorando el rendimiento y la seguridad.

## 🎯 Objetivos de la Clase

- Comprender qué son los procedimientos almacenados
- Aprender la sintaxis básica para crear procedimientos
- Entender los parámetros de entrada y salida
- Implementar lógica de control básica
- Gestionar procedimientos almacenados

## 📚 Conceptos Clave

### ¿Qué es un Procedimiento Almacenado?

Un **procedimiento almacenado** es un conjunto de instrucciones SQL precompiladas que se almacenan en la base de datos. Pueden recibir parámetros, ejecutar lógica compleja y devolver resultados.

### Ventajas de los Procedimientos Almacenados

1. **Rendimiento**: Se compilan una vez y se ejecutan múltiples veces
2. **Seguridad**: Control de acceso granular
3. **Reutilización**: Código reutilizable en múltiples aplicaciones
4. **Mantenimiento**: Centralización de lógica de negocio
5. **Reducción de tráfico**: Menos datos transferidos entre cliente y servidor

## 🔧 Sintaxis y Comandos

### Crear un Procedimiento Almacenado

```sql
DELIMITER //

CREATE PROCEDURE nombre_procedimiento(
    IN parametro_entrada TIPO,
    OUT parametro_salida TIPO,
    INOUT parametro_entrada_salida TIPO
)
BEGIN
    -- Código del procedimiento
END //

DELIMITER ;
```

### Ejecutar un Procedimiento

```sql
-- Llamar procedimiento sin parámetros
CALL nombre_procedimiento();

-- Llamar procedimiento con parámetros
CALL nombre_procedimiento(valor1, @variable_salida, @variable_inout);
```

### Gestionar Procedimientos

```sql
-- Ver procedimientos existentes
SHOW PROCEDURE STATUS;

-- Ver código de un procedimiento
SHOW CREATE PROCEDURE nombre_procedimiento;

-- Eliminar un procedimiento
DROP PROCEDURE nombre_procedimiento;
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Procedimiento Básico

```sql
-- Crear tabla de ejemplo
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- Insertar datos de ejemplo
INSERT INTO productos (nombre, precio, stock) VALUES 
('Laptop', 999.99, 10),
('Mouse', 25.50, 50),
('Teclado', 75.00, 30);

-- Procedimiento para obtener todos los productos
DELIMITER //

CREATE PROCEDURE ObtenerProductos()
BEGIN
    SELECT id, nombre, precio, stock 
    FROM productos 
    ORDER BY nombre;
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL ObtenerProductos();
```

**Explicación línea por línea:**

1. `DELIMITER //` - Cambia el delimitador para permitir múltiples declaraciones
2. `CREATE PROCEDURE ObtenerProductos()` - Crea un procedimiento sin parámetros
3. `BEGIN` - Inicia el bloque de código del procedimiento
4. `SELECT id, nombre, precio, stock FROM productos ORDER BY nombre;` - Consulta que se ejecutará
5. `END //` - Termina el bloque de código
6. `DELIMITER ;` - Restaura el delimitador original

### Ejemplo 2: Procedimiento con Parámetro de Entrada

```sql
-- Procedimiento para buscar productos por nombre
DELIMITER //

CREATE PROCEDURE BuscarProducto(IN nombre_producto VARCHAR(100))
BEGIN
    SELECT id, nombre, precio, stock 
    FROM productos 
    WHERE nombre LIKE CONCAT('%', nombre_producto, '%');
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL BuscarProducto('Laptop');
```

### Ejemplo 3: Procedimiento con Parámetro de Salida

```sql
-- Procedimiento para contar productos
DELIMITER //

CREATE PROCEDURE ContarProductos(OUT total_productos INT)
BEGIN
    SELECT COUNT(*) INTO total_productos 
    FROM productos;
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL ContarProductos(@total);
SELECT @total AS total_productos;
```

### Ejemplo 4: Procedimiento con Parámetro INOUT

```sql
-- Procedimiento para incrementar stock
DELIMITER //

CREATE PROCEDURE IncrementarStock(
    IN producto_id INT,
    INOUT cantidad_incremento INT
)
BEGIN
    UPDATE productos 
    SET stock = stock + cantidad_incremento 
    WHERE id = producto_id;
    
    SELECT stock INTO cantidad_incremento 
    FROM productos 
    WHERE id = producto_id;
END //

DELIMITER ;

-- Ejecutar el procedimiento
SET @cantidad = 5;
CALL IncrementarStock(1, @cantidad);
SELECT @cantidad AS nuevo_stock;
```

### Ejemplo 5: Procedimiento con Lógica de Control

```sql
-- Procedimiento para verificar stock
DELIMITER //

CREATE PROCEDURE VerificarStock(
    IN producto_id INT,
    OUT mensaje VARCHAR(255)
)
BEGIN
    DECLARE stock_actual INT DEFAULT 0;
    
    SELECT stock INTO stock_actual 
    FROM productos 
    WHERE id = producto_id;
    
    IF stock_actual > 10 THEN
        SET mensaje = 'Stock suficiente';
    ELSEIF stock_actual > 0 THEN
        SET mensaje = 'Stock bajo';
    ELSE
        SET mensaje = 'Sin stock';
    END IF;
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL VerificarStock(1, @mensaje);
SELECT @mensaje AS estado_stock;
```

## 🔄 Variables y Control de Flujo

### Declarar Variables

```sql
-- Declarar variables locales
DECLARE variable_nombre TIPO DEFAULT valor_inicial;
```

### Estructuras de Control

```sql
-- Estructura IF-THEN-ELSE
IF condicion THEN
    -- código
ELSEIF otra_condicion THEN
    -- código
ELSE
    -- código
END IF;

-- Estructura CASE
CASE variable
    WHEN valor1 THEN
        -- código
    WHEN valor2 THEN
        -- código
    ELSE
        -- código
END CASE;
```

### Ejemplo con Variables y Control de Flujo

```sql
-- Procedimiento para calcular descuento
DELIMITER //

CREATE PROCEDURE CalcularDescuento(
    IN producto_id INT,
    IN cantidad INT,
    OUT precio_final DECIMAL(10,2),
    OUT descuento_aplicado DECIMAL(5,2)
)
BEGIN
    DECLARE precio_base DECIMAL(10,2) DEFAULT 0;
    DECLARE descuento DECIMAL(5,2) DEFAULT 0;
    
    -- Obtener precio base
    SELECT precio INTO precio_base 
    FROM productos 
    WHERE id = producto_id;
    
    -- Calcular descuento basado en cantidad
    IF cantidad >= 10 THEN
        SET descuento = 15.00;
    ELSEIF cantidad >= 5 THEN
        SET descuento = 10.00;
    ELSEIF cantidad >= 3 THEN
        SET descuento = 5.00;
    ELSE
        SET descuento = 0.00;
    END IF;
    
    -- Calcular precio final
    SET precio_final = precio_base * (1 - descuento/100);
    SET descuento_aplicado = descuento;
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL CalcularDescuento(1, 8, @precio_final, @descuento);
SELECT @precio_final AS precio_final, @descuento AS descuento_porcentaje;
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Procedimiento de Inserción
Crea un procedimiento que inserte un nuevo producto con validación de datos.

### Ejercicio 2: Procedimiento de Actualización
Implementa un procedimiento que actualice el precio de un producto específico.

### Ejercicio 3: Procedimiento de Eliminación
Crea un procedimiento que elimine un producto solo si no tiene stock.

### Ejercicio 4: Procedimiento de Consulta
Implementa un procedimiento que devuelva productos con stock bajo (menos de 5 unidades).

### Ejercicio 5: Procedimiento con Múltiples Parámetros
Crea un procedimiento que busque productos por rango de precios.

### Ejercicio 6: Procedimiento de Cálculo
Implementa un procedimiento que calcule el valor total del inventario.

### Ejercicio 7: Procedimiento de Validación
Crea un procedimiento que valide si un producto existe antes de realizar operaciones.

### Ejercicio 8: Procedimiento con Lógica Condicional
Implementa un procedimiento que aplique diferentes descuentos según el tipo de producto.

### Ejercicio 9: Procedimiento de Resumen
Crea un procedimiento que genere un resumen de productos por categoría.

### Ejercicio 10: Procedimiento Complejo
Implementa un procedimiento que combine inserción, actualización y consulta en una sola operación.

## 📝 Resumen

En esta clase has aprendido:

- **Procedimientos almacenados**: Bloques de código SQL precompilados
- **Sintaxis básica**: CREATE PROCEDURE, parámetros IN/OUT/INOUT
- **Parámetros**: Entrada, salida y entrada/salida
- **Variables**: Declaración y uso de variables locales
- **Control de flujo**: IF-THEN-ELSE y CASE
- **Gestión**: Crear, ejecutar y eliminar procedimientos

## 🔗 Próximos Pasos

- [Clase 3: Procedimientos Almacenados Avanzados](clase_3_procedimientos_avanzados.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 2!** 🎉 Continúa con la siguiente clase para aprender técnicas avanzadas de procedimientos almacenados.
