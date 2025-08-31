# 🎯 Senior Level 1: Transacciones y Control de Concurrencia

## 🧭 Navegación del Curso

**← Anterior**: [Mid Level 5: Vistas e Índices](../midLevel_5/README.md)  
**Siguiente →**: [Senior Level 2: Procedimientos Almacenados](../senior_2/README.md)

---

## 📖 Teoría

### ¿Qué son las Transacciones?
Las transacciones son grupos de operaciones SQL que se ejecutan como una unidad atómica. Garantizan la integridad de los datos mediante las propiedades ACID.

### Propiedades ACID
1. **Atomicity**: Todas las operaciones se ejecutan o ninguna
2. **Consistency**: La base de datos mantiene su integridad
3. **Isolation**: Las transacciones no interfieren entre sí
4. **Durability**: Los cambios son permanentes

### Niveles de Aislamiento
- **READ UNCOMMITTED**: Permite lecturas sucias
- **READ COMMITTED**: Solo lee datos confirmados
- **REPEATABLE READ**: Lecturas consistentes
- **SERIALIZABLE**: Aislamiento total

### Control de Concurrencia
- **Bloqueos**: Evitan conflictos entre transacciones
- **Deadlocks**: Situaciones de bloqueo mutuo
- **Timeouts**: Límites de tiempo para operaciones

## 💡 Ejemplos Prácticos

### Ejemplo 1: Transacción Básica
```sql
START TRANSACTION;
    INSERT INTO productos (nombre, precio, stock) VALUES ('Nuevo Producto', 99.99, 50);
    UPDATE inventario SET total_productos = total_productos + 1;
    INSERT INTO log_cambios (accion, tabla, fecha) VALUES ('INSERT', 'productos', NOW());
COMMIT;
```

### Ejemplo 2: Transacción con Rollback
```sql
START TRANSACTION;
    UPDATE productos SET stock = stock - 5 WHERE id = 1;
    UPDATE inventario SET total_stock = total_stock - 5;
    
    -- Verificar si hay stock suficiente
    IF (SELECT stock FROM productos WHERE id = 1) < 0 THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
```

### Ejemplo 3: Niveles de Aislamiento
```sql
-- Transacción con aislamiento alto
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
    SELECT * FROM productos WHERE stock < 10;
    -- Otras operaciones...
COMMIT;
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Inventario
Implementa transacciones para:

1. Transferir productos entre almacenes
2. Actualizar stock con validaciones
3. Registrar movimientos de inventario
4. Manejar errores con rollback
5. Implementar bloqueos optimistas

**Solución:**
```sql
-- 1. Transferir productos entre almacenes
DELIMITER //
CREATE PROCEDURE transferir_producto(
    IN producto_id INT,
    IN almacen_origen INT,
    IN almacen_destino INT,
    IN cantidad INT
)
BEGIN
    DECLARE stock_disponible INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Verificar stock disponible
        SELECT stock INTO stock_disponible 
        FROM inventario_almacen 
        WHERE producto_id = producto_id AND almacen_id = almacen_origen;
        
        IF stock_disponible < cantidad THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
        END IF;
        
        -- Reducir stock del almacén origen
        UPDATE inventario_almacen 
        SET stock = stock - cantidad 
        WHERE producto_id = producto_id AND almacen_id = almacen_origen;
        
        -- Aumentar stock del almacén destino
        UPDATE inventario_almacen 
        SET stock = stock + cantidad 
        WHERE producto_id = producto_id AND almacen_id = almacen_destino;
        
        -- Registrar movimiento
        INSERT INTO movimientos_inventario (
            producto_id, almacen_origen, almacen_destino, 
            cantidad, fecha, tipo
        ) VALUES (
            producto_id, almacen_origen, almacen_destino, 
            cantidad, NOW(), 'TRANSFERENCIA'
        );
        
    COMMIT;
END //
DELIMITER ;
```

### Ejercicio 2: Sistema de Reservas
Implementa transacciones para:

1. Crear reservas con validación de disponibilidad
2. Cancelar reservas con liberación de recursos
3. Modificar reservas existentes
4. Manejar conflictos de concurrencia
5. Implementar timeouts automáticos

**Solución:**
```sql
-- 1. Crear reserva con validación
DELIMITER //
CREATE PROCEDURE crear_reserva(
    IN cliente_id INT,
    IN recurso_id INT,
    IN fecha_inicio DATETIME,
    IN fecha_fin DATETIME
)
BEGIN
    DECLARE conflicto INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Verificar disponibilidad
        SELECT COUNT(*) INTO conflicto
        FROM reservas
        WHERE recurso_id = recurso_id
        AND estado = 'ACTIVA'
        AND (
            (fecha_inicio BETWEEN fecha_inicio AND fecha_fin)
            OR (fecha_fin BETWEEN fecha_inicio AND fecha_fin)
            OR (fecha_inicio <= fecha_inicio AND fecha_fin >= fecha_fin)
        );
        
        IF conflicto > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recurso no disponible';
        END IF;
        
        -- Crear reserva
        INSERT INTO reservas (
            cliente_id, recurso_id, fecha_inicio, 
            fecha_fin, estado, fecha_creacion
        ) VALUES (
            cliente_id, recurso_id, fecha_inicio, 
            fecha_fin, 'ACTIVA', NOW()
        );
        
        -- Actualizar estado del recurso
        UPDATE recursos 
        SET estado = 'RESERVADO' 
        WHERE id = recurso_id;
        
    COMMIT;
END //
DELIMITER ;
```

### Ejercicio 3: Sistema de Pagos
Implementa transacciones para:

1. Procesar pagos con validación de saldo
2. Revertir transacciones fallidas
3. Manejar pagos parciales
4. Implementar auditoría de transacciones
5. Manejar timeouts de conexión

**Solución:**
```sql
-- 1. Procesar pago con validación
DELIMITER //
CREATE PROCEDURE procesar_pago(
    IN cuenta_origen INT,
    IN cuenta_destino INT,
    IN monto DECIMAL(10,2)
)
BEGIN
    DECLARE saldo_disponible DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO log_errores (error, fecha) VALUES (ERROR_MESSAGE(), NOW());
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Verificar saldo
        SELECT saldo INTO saldo_disponible 
        FROM cuentas 
        WHERE id = cuenta_origen;
        
        IF saldo_disponible < monto THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
        END IF;
        
        -- Debitar cuenta origen
        UPDATE cuentas 
        SET saldo = saldo - monto 
        WHERE id = cuenta_origen;
        
        -- Acreditar cuenta destino
        UPDATE cuentas 
        SET saldo = saldo + monto 
        WHERE id = cuenta_destino;
        
        -- Registrar transacción
        INSERT INTO transacciones (
            cuenta_origen, cuenta_destino, monto, 
            fecha, estado, tipo
        ) VALUES (
            cuenta_origen, cuenta_destino, monto, 
            NOW(), 'COMPLETADA', 'TRANSFERENCIA'
        );
        
    COMMIT;
END //
DELIMITER ;
```

### Ejercicio 4: Sistema de Pedidos
Implementa transacciones para:

1. Crear pedidos con validación de stock
2. Procesar pagos y actualizar inventario
3. Cancelar pedidos con restauración
4. Manejar múltiples productos
5. Implementar colas de procesamiento

**Solución:**
```sql
-- 1. Crear pedido completo
DELIMITER //
CREATE PROCEDURE crear_pedido_completo(
    IN cliente_id INT,
    IN productos_json JSON
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE producto_id INT;
    DECLARE cantidad INT;
    DECLARE precio_unitario DECIMAL(10,2);
    DECLARE stock_disponible INT;
    DECLARE total_pedido DECIMAL(10,2) DEFAULT 0;
    DECLARE pedido_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Crear pedido
        INSERT INTO pedidos (cliente_id, fecha, estado, total) 
        VALUES (cliente_id, NOW(), 'PENDIENTE', 0);
        
        SET pedido_id = LAST_INSERT_ID();
        
        -- Procesar cada producto
        WHILE i < JSON_LENGTH(productos_json) DO
            SET producto_id = JSON_EXTRACT(productos_json, CONCAT('$[', i, '].producto_id'));
            SET cantidad = JSON_EXTRACT(productos_json, CONCAT('$[', i, '].cantidad'));
            SET precio_unitario = JSON_EXTRACT(productos_json, CONCAT('$[', i, '].precio'));
            
            -- Verificar stock
            SELECT stock INTO stock_disponible 
            FROM productos 
            WHERE id = producto_id;
            
            IF stock_disponible < cantidad THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
            END IF;
            
            -- Agregar producto al pedido
            INSERT INTO productos_pedido (
                pedido_id, producto_id, cantidad, precio_unitario
            ) VALUES (
                pedido_id, producto_id, cantidad, precio_unitario
            );
            
            -- Actualizar stock
            UPDATE productos 
            SET stock = stock - cantidad 
            WHERE id = producto_id;
            
            SET total_pedido = total_pedido + (cantidad * precio_unitario);
            SET i = i + 1;
        END WHILE;
        
        -- Actualizar total del pedido
        UPDATE pedidos 
        SET total = total_pedido 
        WHERE id = pedido_id;
        
    COMMIT;
END //
DELIMITER ;
```

### Ejercicio 5: Sistema de Auditoría
Implementa transacciones para:

1. Registrar cambios en tablas críticas
2. Mantener historial de modificaciones
3. Implementar soft deletes
4. Manejar versionado de datos
5. Crear reportes de auditoría

**Solución:**
```sql
-- 1. Trigger para auditoría de cambios
DELIMITER //
CREATE TRIGGER audit_productos_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_productos (
        producto_id, campo_modificado, valor_anterior, 
        valor_nuevo, usuario, fecha_modificacion
    ) VALUES 
    (NEW.id, 'nombre', OLD.nombre, NEW.nombre, USER(), NOW()),
    (NEW.id, 'precio', OLD.precio, NEW.precio, USER(), NOW()),
    (NEW.id, 'stock', OLD.stock, NEW.stock, USER(), NOW());
END //
DELIMITER ;

-- 2. Procedimiento para soft delete
DELIMITER //
CREATE PROCEDURE soft_delete_producto(IN producto_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Marcar como eliminado
        UPDATE productos 
        SET eliminado = 1, fecha_eliminacion = NOW() 
        WHERE id = producto_id;
        
        -- Registrar en auditoría
        INSERT INTO auditoria_productos (
            producto_id, campo_modificado, valor_anterior, 
            valor_nuevo, usuario, fecha_modificacion
        ) VALUES (
            producto_id, 'eliminado', 0, 1, USER(), NOW()
        );
        
        -- Mover a tabla de productos eliminados
        INSERT INTO productos_eliminados (
            id, nombre, precio, stock, fecha_eliminacion, usuario_eliminacion
        ) SELECT 
            id, nombre, precio, stock, fecha_eliminacion, USER()
        FROM productos 
        WHERE id = producto_id;
        
    COMMIT;
END //
DELIMITER ;
```

## 📝 Resumen de Conceptos Clave
- ✅ Las transacciones garantizan la integridad de los datos
- ✅ Las propiedades ACID son fundamentales para bases de datos confiables
- ✅ Los niveles de aislamiento controlan la concurrencia
- ✅ El manejo de errores con rollback es esencial
- ✅ Los bloqueos y timeouts previenen deadlocks
- ✅ La auditoría mantiene trazabilidad de cambios

## 🔗 Próximo Nivel
Continúa con `docs/senior_2` para aprender sobre procedimientos almacenados y funciones.

---

**💡 Consejo: Practica implementando transacciones complejas y manejando casos de error. Son fundamentales para sistemas de producción robustos.**
