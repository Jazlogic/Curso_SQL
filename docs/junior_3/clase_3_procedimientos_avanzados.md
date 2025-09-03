# Clase 3: Procedimientos Almacenados Avanzados

## 📋 Descripción

En esta clase profundizarás en técnicas avanzadas de procedimientos almacenados, incluyendo cursores, loops, manejo de errores, transacciones dentro de procedimientos, y optimización de rendimiento. Aprenderás a crear procedimientos más complejos y robustos.

## 🎯 Objetivos de la Clase

- Dominar el uso de cursores para procesar resultados
- Implementar loops y estructuras de repetición
- Manejar errores y excepciones
- Integrar transacciones en procedimientos
- Optimizar el rendimiento de procedimientos
- Crear procedimientos modulares y reutilizables

## 📚 Conceptos Clave

### Cursores

Un **cursor** es un mecanismo que permite procesar fila por fila los resultados de una consulta. Es útil cuando necesitas realizar operaciones complejas sobre cada registro.

### Loops

Los **loops** permiten repetir bloques de código múltiples veces, útil para procesar datos en lotes o realizar operaciones iterativas.

### Manejo de Errores

El **manejo de errores** permite capturar y gestionar excepciones que pueden ocurrir durante la ejecución del procedimiento.

## 🔧 Sintaxis y Comandos

### Declarar y Usar Cursores

```sql
-- Declarar cursor
DECLARE nombre_cursor CURSOR FOR consulta_sql;

-- Declarar variables para el cursor
DECLARE variable1 TIPO;
DECLARE variable2 TIPO;

-- Declarar handler para fin de cursor
DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin_cursor = TRUE;

-- Abrir cursor
OPEN nombre_cursor;

-- Leer datos del cursor
FETCH nombre_cursor INTO variable1, variable2;

-- Cerrar cursor
CLOSE nombre_cursor;
```

### Loops

```sql
-- Loop WHILE
WHILE condicion DO
    -- código
END WHILE;

-- Loop REPEAT
REPEAT
    -- código
UNTIL condicion END REPEAT;

-- Loop LOOP
loop_label: LOOP
    -- código
    IF condicion THEN
        LEAVE loop_label;
    END IF;
END LOOP;
```

### Manejo de Errores

```sql
-- Declarar handler para errores
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
BEGIN
    -- código de manejo de error
    ROLLBACK;
    RESIGNAL;
END;
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Procedimiento con Cursor

```sql
-- Crear tabla de ejemplo
CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    fecha_venta DATE
);

-- Insertar datos de ejemplo
INSERT INTO ventas (producto_id, cantidad, precio_unitario, fecha_venta) VALUES 
(1, 2, 999.99, '2024-01-15'),
(2, 5, 25.50, '2024-01-16'),
(1, 1, 999.99, '2024-01-17'),
(3, 3, 75.00, '2024-01-18');

-- Procedimiento para procesar ventas con cursor
DELIMITER //

CREATE PROCEDURE ProcesarVentas()
BEGIN
    DECLARE v_id INT;
    DECLARE v_producto_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_fecha DATE;
    DECLARE v_total DECIMAL(10,2);
    DECLARE fin_cursor BOOLEAN DEFAULT FALSE;
    
    -- Declarar cursor
    DECLARE cursor_ventas CURSOR FOR 
        SELECT id, producto_id, cantidad, precio_unitario, fecha_venta 
        FROM ventas 
        ORDER BY fecha_venta;
    
    -- Declarar handler para fin de cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin_cursor = TRUE;
    
    -- Crear tabla temporal para resultados
    CREATE TEMPORARY TABLE IF NOT EXISTS resumen_ventas (
        venta_id INT,
        total_venta DECIMAL(10,2),
        procesado BOOLEAN DEFAULT FALSE
    );
    
    -- Abrir cursor
    OPEN cursor_ventas;
    
    -- Procesar cada venta
    loop_ventas: LOOP
        FETCH cursor_ventas INTO v_id, v_producto_id, v_cantidad, v_precio, v_fecha;
        
        IF fin_cursor THEN
            LEAVE loop_ventas;
        END IF;
        
        -- Calcular total de la venta
        SET v_total = v_cantidad * v_precio;
        
        -- Insertar en tabla temporal
        INSERT INTO resumen_ventas (venta_id, total_venta, procesado) 
        VALUES (v_id, v_total, TRUE);
        
    END LOOP;
    
    -- Cerrar cursor
    CLOSE cursor_ventas;
    
    -- Mostrar resultados
    SELECT * FROM resumen_ventas;
    
    -- Limpiar tabla temporal
    DROP TEMPORARY TABLE resumen_ventas;
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL ProcesarVentas();
```

**Explicación línea por línea:**

1. `DECLARE v_id INT;` - Declara variables para almacenar datos del cursor
2. `DECLARE cursor_ventas CURSOR FOR SELECT...` - Crea cursor para la consulta
3. `DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin_cursor = TRUE;` - Maneja fin de cursor
4. `OPEN cursor_ventas;` - Abre el cursor
5. `FETCH cursor_ventas INTO v_id, v_producto_id...` - Lee una fila del cursor
6. `IF fin_cursor THEN LEAVE loop_ventas; END IF;` - Verifica si terminó el cursor
7. `CLOSE cursor_ventas;` - Cierra el cursor

### Ejemplo 2: Procedimiento con Loop WHILE

```sql
-- Procedimiento para generar números secuenciales
DELIMITER //

CREATE PROCEDURE GenerarNumeros(IN cantidad INT)
BEGIN
    DECLARE contador INT DEFAULT 1;
    DECLARE numero_actual INT DEFAULT 1;
    
    -- Crear tabla temporal
    CREATE TEMPORARY TABLE IF NOT EXISTS numeros_generados (
        id INT,
        numero INT
    );
    
    -- Loop WHILE
    WHILE contador <= cantidad DO
        INSERT INTO numeros_generados (id, numero) 
        VALUES (contador, numero_actual);
        
        SET contador = contador + 1;
        SET numero_actual = numero_actual * 2; -- Generar números exponenciales
    END WHILE;
    
    -- Mostrar resultados
    SELECT * FROM numeros_generados ORDER BY id;
    
    -- Limpiar
    DROP TEMPORARY TABLE numeros_generados;
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL GenerarNumeros(5);
```

### Ejemplo 3: Procedimiento con Manejo de Errores

```sql
-- Procedimiento con manejo de errores
DELIMITER //

CREATE PROCEDURE InsertarProductoSeguro(
    IN p_nombre VARCHAR(100),
    IN p_precio DECIMAL(10,2),
    IN p_stock INT,
    OUT p_resultado VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_resultado = 'Error al insertar producto';
        RESIGNAL;
    END;
    
    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        ROLLBACK;
        SET p_resultado = 'Advertencia al insertar producto';
    END;
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Validar datos
    IF p_nombre IS NULL OR p_nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del producto es requerido';
    END IF;
    
    IF p_precio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';
    END IF;
    
    IF p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    -- Insertar producto
    INSERT INTO productos (nombre, precio, stock) 
    VALUES (p_nombre, p_precio, p_stock);
    
    -- Confirmar transacción
    COMMIT;
    SET p_resultado = 'Producto insertado correctamente';
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL InsertarProductoSeguro('Nuevo Producto', 99.99, 10, @resultado);
SELECT @resultado AS mensaje;
```

### Ejemplo 4: Procedimiento con Transacciones

```sql
-- Procedimiento para transferir stock entre productos
DELIMITER //

CREATE PROCEDURE TransferirStock(
    IN producto_origen INT,
    IN producto_destino INT,
    IN cantidad_transferir INT,
    OUT resultado VARCHAR(255)
)
BEGIN
    DECLARE stock_origen INT DEFAULT 0;
    DECLARE stock_destino INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET resultado = 'Error en la transferencia';
        RESIGNAL;
    END;
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Verificar que los productos existen
    IF NOT EXISTS (SELECT 1 FROM productos WHERE id = producto_origen) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto origen no existe';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM productos WHERE id = producto_destino) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto destino no existe';
    END IF;
    
    -- Obtener stock actual
    SELECT stock INTO stock_origen FROM productos WHERE id = producto_origen;
    SELECT stock INTO stock_destino FROM productos WHERE id = producto_destino;
    
    -- Verificar stock suficiente
    IF stock_origen < cantidad_transferir THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente en producto origen';
    END IF;
    
    -- Realizar transferencia
    UPDATE productos SET stock = stock - cantidad_transferir WHERE id = producto_origen;
    UPDATE productos SET stock = stock + cantidad_transferir WHERE id = producto_destino;
    
    -- Confirmar transacción
    COMMIT;
    SET resultado = CONCAT('Transferencia exitosa: ', cantidad_transferir, ' unidades');
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL TransferirStock(1, 2, 3, @resultado);
SELECT @resultado AS mensaje;
```

### Ejemplo 5: Procedimiento con Loop REPEAT

```sql
-- Procedimiento para calcular factorial
DELIMITER //

CREATE PROCEDURE CalcularFactorial(IN numero INT, OUT factorial BIGINT)
BEGIN
    DECLARE contador INT DEFAULT 1;
    SET factorial = 1;
    
    -- Loop REPEAT
    REPEAT
        SET factorial = factorial * contador;
        SET contador = contador + 1;
    UNTIL contador > numero END REPEAT;
END //

DELIMITER ;

-- Ejecutar el procedimiento
CALL CalcularFactorial(5, @factorial);
SELECT @factorial AS factorial_5;
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Cursor con Procesamiento
Crea un procedimiento que use un cursor para procesar todas las ventas y calcular comisiones.

### Ejercicio 2: Loop con Validación
Implementa un procedimiento que use un loop para validar múltiples productos.

### Ejercicio 3: Manejo de Errores Complejo
Crea un procedimiento con manejo de errores para operaciones de inventario.

### Ejercicio 4: Transacción con Rollback
Implementa un procedimiento que use transacciones para operaciones de compra.

### Ejercicio 5: Cursor con Agregaciones
Crea un procedimiento que use cursor para calcular estadísticas por producto.

### Ejercicio 6: Loop con Condiciones
Implementa un procedimiento que use loop para generar reportes por período.

### Ejercicio 7: Manejo de Excepciones
Crea un procedimiento que maneje diferentes tipos de errores.

### Ejercicio 8: Transacción Compleja
Implementa un procedimiento con transacción para operaciones de devolución.

### Ejercicio 9: Cursor con Actualizaciones
Crea un procedimiento que use cursor para actualizar precios masivamente.

### Ejercicio 10: Procedimiento Modular
Implementa un procedimiento complejo que combine todas las técnicas aprendidas.

## 📝 Resumen

En esta clase has aprendido:

- **Cursores**: Procesamiento fila por fila de resultados
- **Loops**: WHILE, REPEAT y LOOP para repetición
- **Manejo de errores**: Handlers y excepciones
- **Transacciones**: Integración en procedimientos
- **Optimización**: Mejores prácticas de rendimiento
- **Modularidad**: Creación de procedimientos reutilizables

## 🔗 Próximos Pasos

- [Clase 4: Funciones Personalizadas](clase_4_funciones_personalizadas.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 3!** 🎉 Continúa con la siguiente clase para aprender sobre funciones personalizadas.
