# 🎯 Senior 3: Triggers y Eventos

## 📖 Teoría

### ¿Qué son los Triggers?
Los triggers son objetos de base de datos que se ejecutan automáticamente cuando ocurren eventos específicos en las tablas. Permiten automatizar acciones y mantener la integridad de los datos.

### Tipos de Triggers
1. **BEFORE INSERT**: Antes de insertar datos
2. **AFTER INSERT**: Después de insertar datos
3. **BEFORE UPDATE**: Antes de actualizar datos
4. **AFTER UPDATE**: Después de actualizar datos
5. **BEFORE DELETE**: Antes de eliminar datos
6. **AFTER DELETE**: Después de eliminar datos

### ¿Qué son los Eventos?
Los eventos son tareas programadas que se ejecutan automáticamente en momentos específicos. Son útiles para mantenimiento, limpieza y reportes automáticos.

### Casos de Uso Comunes
- **Auditoría**: Registrar cambios automáticamente
- **Validación**: Verificar datos antes de insertar/actualizar
- **Mantenimiento**: Limpiar datos obsoletos
- **Sincronización**: Mantener tablas relacionadas actualizadas

## 💡 Ejemplos Prácticos

### Ejemplo 1: Trigger de Auditoría
```sql
DELIMITER //
CREATE TRIGGER audit_productos_changes
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
```

### Ejemplo 2: Trigger de Validación
```sql
DELIMITER //
CREATE TRIGGER validar_stock_producto
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';
    END IF;
END //
DELIMITER ;
```

### Ejemplo 3: Evento de Limpieza
```sql
-- Habilitar eventos
SET GLOBAL event_scheduler = ON;

-- Crear evento de limpieza diaria
CREATE EVENT limpiar_logs_antiguos
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
    DELETE FROM logs_sistema 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Auditoría Automática
Implementa triggers para:

1. Registrar cambios en productos
2. Auditar modificaciones de precios
3. Rastrear cambios de stock
4. Registrar eliminaciones
5. Mantener historial de usuarios

**Solución:**
```sql
-- 1. Trigger para auditar cambios en productos
DELIMITER //
CREATE TRIGGER audit_productos_completa
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Auditar cambios en nombre
    IF OLD.nombre != NEW.nombre THEN
        INSERT INTO auditoria_productos (
            producto_id, campo_modificado, valor_anterior, 
            valor_nuevo, usuario, fecha_modificacion, tipo_cambio
        ) VALUES (
            NEW.id, 'nombre', OLD.nombre, NEW.nombre, 
            USER(), NOW(), 'MODIFICACION'
        );
    END IF;
    
    -- Auditar cambios en precio
    IF OLD.precio != NEW.precio THEN
        INSERT INTO auditoria_productos (
            producto_id, campo_modificado, valor_anterior, 
            valor_nuevo, usuario, fecha_modificacion, tipo_cambio
        ) VALUES (
            NEW.id, 'precio', OLD.precio, NEW.precio, 
            USER(), NOW(), 'MODIFICACION'
        );
        
        -- Registrar cambio de precio en tabla específica
        INSERT INTO historial_precios (
            producto_id, precio_anterior, precio_nuevo, 
            porcentaje_cambio, usuario, fecha_cambio
        ) VALUES (
            NEW.id, OLD.precio, NEW.precio,
            ROUND(((NEW.precio - OLD.precio) / OLD.precio) * 100, 2),
            USER(), NOW()
        );
    END IF;
    
    -- Auditar cambios en stock
    IF OLD.stock != NEW.stock THEN
        INSERT INTO auditoria_productos (
            producto_id, campo_modificado, valor_anterior, 
            valor_nuevo, usuario, fecha_modificacion, tipo_cambio
        ) VALUES (
            NEW.id, 'stock', OLD.stock, NEW.stock, 
            USER(), NOW(), 'MODIFICACION'
        );
        
        -- Registrar movimiento de stock
        INSERT INTO movimientos_stock (
            producto_id, stock_anterior, stock_nuevo, 
            diferencia, tipo_movimiento, usuario, fecha
        ) VALUES (
            NEW.id, OLD.stock, NEW.stock,
            NEW.stock - OLD.stock,
            CASE 
                WHEN NEW.stock > OLD.stock THEN 'INCREMENTO'
                ELSE 'DECREMENTO'
            END,
            USER(), NOW()
        );
    END IF;
END //
DELIMITER ;

-- 2. Trigger para auditar eliminaciones
DELIMITER //
CREATE TRIGGER audit_productos_delete
BEFORE DELETE ON productos
FOR EACH ROW
BEGIN
    -- Registrar eliminación en auditoría
    INSERT INTO auditoria_productos (
        producto_id, campo_modificado, valor_anterior, 
        valor_nuevo, usuario, fecha_modificacion, tipo_cambio
    ) VALUES (
        OLD.id, 'ELIMINACION', 
        CONCAT('Producto: ', OLD.nombre, ' - Precio: ', OLD.precio, ' - Stock: ', OLD.stock),
        'ELIMINADO', USER(), NOW(), 'ELIMINACION'
    );
    
    -- Mover a tabla de productos eliminados
    INSERT INTO productos_eliminados (
        id, nombre, precio, stock, categoria_id, 
        fecha_eliminacion, usuario_eliminacion, motivo
    ) VALUES (
        OLD.id, OLD.nombre, OLD.precio, OLD.stock, OLD.categoria_id,
        NOW(), USER(), 'Eliminación por trigger'
    );
END //
DELIMITER ;
```

### Ejercicio 2: Sistema de Validación Automática
Implementa triggers para:

1. Validar datos antes de insertar
2. Verificar restricciones de negocio
3. Prevenir operaciones inválidas
4. Validar referencias entre tablas
5. Aplicar reglas de negocio

**Solución:**
```sql
-- 1. Trigger para validar inserción de productos
DELIMITER //
CREATE TRIGGER validar_producto_insert
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    DECLARE categoria_existe INT;
    
    -- Validar que la categoría existe
    SELECT COUNT(*) INTO categoria_existe
    FROM categorias WHERE id = NEW.categoria_id;
    
    IF categoria_existe = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La categoría especificada no existe';
    END IF;
    
    -- Validar nombre no vacío
    IF NEW.nombre IS NULL OR TRIM(NEW.nombre) = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del producto no puede estar vacío';
    END IF;
    
    -- Validar precio positivo
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';
    END IF;
    
    -- Validar stock no negativo
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    -- Validar longitud del nombre
    IF LENGTH(NEW.nombre) > 200 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del producto es demasiado largo';
    END IF;
END //
DELIMITER ;

-- 2. Trigger para validar actualización de productos
DELIMITER //
CREATE TRIGGER validar_producto_update
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    DECLARE categoria_existe INT;
    
    -- Validar que la categoría existe (si cambió)
    IF NEW.categoria_id != OLD.categoria_id THEN
        SELECT COUNT(*) INTO categoria_existe
        FROM categorias WHERE id = NEW.categoria_id;
        
        IF categoria_existe = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'La nueva categoría no existe';
        END IF;
    END IF;
    
    -- Validar que no se reduzca el stock por debajo de 0
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se puede reducir el stock por debajo de 0';
    END IF;
    
    -- Validar que el precio no se reduzca más del 50%
    IF NEW.precio < OLD.precio * 0.5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se puede reducir el precio más del 50%';
    END IF;
    
    -- Validar que el nombre no se haga vacío
    IF NEW.nombre IS NULL OR TRIM(NEW.nombre) = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del producto no puede estar vacío';
    END IF;
END //
DELIMITER ;
```

### Ejercicio 3: Sistema de Sincronización Automática
Implementa triggers para:

1. Mantener contadores actualizados
2. Sincronizar tablas relacionadas
3. Actualizar estadísticas en tiempo real
4. Mantener integridad referencial
5. Sincronizar cache de datos

**Solución:**
```sql
-- 1. Trigger para mantener contador de productos por categoría
DELIMITER //
CREATE TRIGGER sync_contador_productos_categoria
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    -- Incrementar contador de productos en la categoría
    UPDATE categorias 
    SET total_productos = total_productos + 1
    WHERE id = NEW.categoria_id;
    
    -- Actualizar estadísticas de la categoría
    UPDATE estadisticas_categorias 
    SET total_productos = total_productos + 1,
        valor_total_inventario = valor_total_inventario + (NEW.precio * NEW.stock),
        fecha_ultima_actualizacion = NOW()
    WHERE categoria_id = NEW.categoria_id;
END //
DELIMITER ;

-- 2. Trigger para sincronizar cuando se elimina un producto
DELIMITER //
CREATE TRIGGER sync_contador_productos_categoria_delete
AFTER DELETE ON productos
FOR EACH ROW
BEGIN
    -- Decrementar contador de productos en la categoría
    UPDATE categorias 
    SET total_productos = total_productos - 1
    WHERE id = OLD.categoria_id;
    
    -- Actualizar estadísticas de la categoría
    UPDATE estadisticas_categorias 
    SET total_productos = total_productos - 1,
        valor_total_inventario = valor_total_inventario - (OLD.precio * OLD.stock),
        fecha_ultima_actualizacion = NOW()
    WHERE categoria_id = OLD.categoria_id;
END //
DELIMITER ;

-- 3. Trigger para sincronizar cuando se actualiza un producto
DELIMITER //
CREATE TRIGGER sync_estadisticas_categoria_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Si cambió la categoría, actualizar ambas categorías
    IF NEW.categoria_id != OLD.categoria_id THEN
        -- Decrementar en categoría anterior
        UPDATE categorias 
        SET total_productos = total_productos - 1
        WHERE id = OLD.categoria_id;
        
        UPDATE estadisticas_categorias 
        SET total_productos = total_productos - 1,
            valor_total_inventario = valor_total_inventario - (OLD.precio * OLD.stock),
            fecha_ultima_actualizacion = NOW()
        WHERE categoria_id = OLD.categoria_id;
        
        -- Incrementar en nueva categoría
        UPDATE categorias 
        SET total_productos = total_productos + 1
        WHERE id = NEW.categoria_id;
        
        UPDATE estadisticas_categorias 
        SET total_productos = total_productos + 1,
            valor_total_inventario = valor_total_inventario + (NEW.precio * NEW.stock),
            fecha_ultima_actualizacion = NOW()
        WHERE categoria_id = NEW.categoria_id;
    ELSE
        -- Solo actualizar valor del inventario si cambió precio o stock
        IF NEW.precio != OLD.precio OR NEW.stock != OLD.stock THEN
            UPDATE estadisticas_categorias 
            SET valor_total_inventario = valor_total_inventario - (OLD.precio * OLD.stock) + (NEW.precio * NEW.stock),
                fecha_ultima_actualizacion = NOW()
            WHERE categoria_id = NEW.categoria_id;
        END IF;
    END IF;
END //
DELIMITER ;
```

### Ejercicio 4: Sistema de Eventos Automáticos
Implementa eventos para:

1. Limpiar datos obsoletos
2. Generar reportes automáticos
3. Mantener estadísticas actualizadas
4. Ejecutar mantenimiento programado
5. Sincronizar datos entre sistemas

**Solución:**
```sql
-- 1. Evento para limpiar logs antiguos
CREATE EVENT limpiar_logs_sistema
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Limpiar logs de auditoría más antiguos de 1 año
    DELETE FROM auditoria_productos 
    WHERE fecha_modificacion < DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    -- Limpiar logs de sistema más antiguos de 6 meses
    DELETE FROM logs_sistema 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 6 MONTH);
    
    -- Limpiar historial de precios más antiguo de 2 años
    DELETE FROM historial_precios 
    WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 2 YEAR);
    
    -- Limpiar movimientos de stock más antiguos de 1 año
    DELETE FROM movimientos_stock 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 1 YEAR);
END;

-- 2. Evento para actualizar estadísticas diarias
CREATE EVENT actualizar_estadisticas_diarias
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
BEGIN
    -- Actualizar estadísticas de ventas del día anterior
    INSERT INTO estadisticas_ventas_diarias (
        fecha, total_ventas, total_pedidos, 
        clientes_activos, productos_vendidos
    )
    SELECT 
        DATE_SUB(CURDATE(), INTERVAL 1 DAY) as fecha,
        COALESCE(SUM(total), 0) as total_ventas,
        COUNT(*) as total_pedidos,
        COUNT(DISTINCT cliente_id) as clientes_activos,
        COUNT(DISTINCT pp.producto_id) as productos_vendidos
    FROM pedidos p
    LEFT JOIN productos_pedido pp ON p.id = pp.pedido_id
    WHERE DATE(p.fecha_pedido) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
    AND p.estado = 'Completado';
    
    -- Actualizar métricas de productos
    UPDATE productos p
    SET 
        rotacion_30_dias = (
            SELECT COALESCE(SUM(pp.cantidad), 0) / GREATEST(p.stock, 1)
            FROM productos_pedido pp
            INNER JOIN pedidos ped ON pp.pedido_id = ped.id
            WHERE pp.producto_id = p.id
            AND ped.fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            AND ped.estado = 'Completado'
        ),
        ultima_actualizacion_metricas = NOW();
END;

-- 3. Evento para mantenimiento semanal
CREATE EVENT mantenimiento_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    -- Optimizar tablas
    OPTIMIZE TABLE productos, categorias, pedidos, clientes;
    
    -- Analizar tablas para estadísticas
    ANALYZE TABLE productos, categorias, pedidos, clientes;
    
    -- Limpiar tablas temporales
    DROP TEMPORARY TABLE IF EXISTS temp_estadisticas;
    DROP TEMPORARY TABLE IF EXISTS temp_reportes;
    
    -- Registrar mantenimiento
    INSERT INTO log_mantenimiento (
        tipo, descripcion, fecha_ejecucion, duracion_segundos
    ) VALUES (
        'SEMANAL', 'Optimización y análisis de tablas', NOW(), 0
    );
END;

-- 4. Evento para backup de auditoría mensual
CREATE EVENT backup_auditoria_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    -- Crear backup de auditoría del mes anterior
    INSERT INTO backup_auditoria_productos (
        producto_id, campo_modificado, valor_anterior, 
        valor_nuevo, usuario, fecha_modificacion, tipo_cambio,
        fecha_backup
    )
    SELECT 
        producto_id, campo_modificado, valor_anterior, 
        valor_nuevo, usuario, fecha_modificacion, tipo_cambio,
        NOW() as fecha_backup
    FROM auditoria_productos
    WHERE fecha_modificacion >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND fecha_modificacion < DATE_SUB(CURDATE(), INTERVAL 1 DAY);
    
    -- Limpiar auditoría del mes anterior
    DELETE FROM auditoria_productos 
    WHERE fecha_modificacion < DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
END;
```

### Ejercicio 5: Sistema de Triggers Avanzados
Implementa triggers complejos para:

1. Manejar soft deletes
2. Implementar versionado de datos
3. Gestionar colas de trabajo
4. Implementar cache inteligente
5. Manejar archivos adjuntos

**Solución:**
```sql
-- 1. Trigger para soft delete con versionado
DELIMITER //
CREATE TRIGGER soft_delete_producto_versionado
BEFORE DELETE ON productos
FOR EACH ROW
BEGIN
    -- Crear versión final antes de eliminar
    INSERT INTO versiones_productos (
        producto_id, nombre, precio, stock, categoria_id,
        fecha_version, tipo_version, usuario_version
    ) VALUES (
        OLD.id, OLD.nombre, OLD.precio, OLD.stock, OLD.categoria_id,
        NOW(), 'ELIMINACION', USER()
    );
    
    -- Marcar como eliminado en lugar de eliminar físicamente
    UPDATE productos 
    SET 
        eliminado = 1,
        fecha_eliminacion = NOW(),
        usuario_eliminacion = USER(),
        motivo_eliminacion = 'Soft delete por trigger'
    WHERE id = OLD.id;
    
    -- Prevenir la eliminación física
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Use soft_delete_producto() en lugar de DELETE';
END //
DELIMITER ;

-- 2. Trigger para gestionar colas de trabajo
DELIMITER //
CREATE TRIGGER gestionar_cola_trabajo
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    -- Si el stock es bajo, agregar a cola de reposición
    IF NEW.stock <= NEW.stock_minimo THEN
        INSERT INTO cola_reposicion (
            producto_id, prioridad, fecha_solicitud, 
            estado, cantidad_solicitada
        ) VALUES (
            NEW.id, 
            CASE 
                WHEN NEW.stock = 0 THEN 'ALTA'
                WHEN NEW.stock <= NEW.stock_minimo * 0.5 THEN 'MEDIA'
                ELSE 'BAJA'
            END,
            NOW(),
            'PENDIENTE',
            NEW.stock_maximo - NEW.stock
        );
    END IF;
    
    -- Si es un producto nuevo, agregar a cola de revisión
    IF NEW.fecha_creacion = CURDATE() THEN
        INSERT INTO cola_revision_productos (
            producto_id, tipo_revision, prioridad, 
            fecha_solicitud, estado
        ) VALUES (
            NEW.id, 'REVISION_INICIAL', 'MEDIA', NOW(), 'PENDIENTE'
        );
    END IF;
END //
DELIMITER ;

-- 3. Trigger para cache inteligente
DELIMITER //
CREATE TRIGGER invalidar_cache_productos
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Invalidar cache de productos por categoría
    IF OLD.categoria_id != NEW.categoria_id THEN
        INSERT INTO cache_invalidaciones (
            tipo_cache, identificador, fecha_invalidacion, 
            motivo, usuario
        ) VALUES 
        ('PRODUCTOS_CATEGORIA', OLD.categoria_id, NOW(), 'Cambio de categoría', USER()),
        ('PRODUCTOS_CATEGORIA', NEW.categoria_id, NOW(), 'Cambio de categoría', USER());
    END IF;
    
    -- Invalidar cache de productos individuales
    INSERT INTO cache_invalidaciones (
        tipo_cache, identificador, fecha_invalidacion, 
        motivo, usuario
    ) VALUES (
        'PRODUCTO_INDIVIDUAL', NEW.id, NOW(), 'Modificación de producto', USER()
    );
    
    -- Invalidar cache de estadísticas si cambió precio o stock
    IF OLD.precio != NEW.precio OR OLD.stock != NEW.stock THEN
        INSERT INTO cache_invalidaciones (
            tipo_cache, identificador, fecha_invalidacion, 
            motivo, usuario
        ) VALUES (
            'ESTADISTICAS_PRODUCTOS', 'GENERAL', NOW(), 'Cambio en métricas', USER()
        );
    END IF;
END //
DELIMITER ;
```

## 📝 Resumen de Conceptos Clave
- ✅ Los triggers se ejecutan automáticamente ante eventos de tabla
- ✅ Los eventos permiten programar tareas automáticas
- ✅ Los triggers BEFORE permiten validación y prevención
- ✅ Los triggers AFTER permiten auditoría y sincronización
- ✅ Los eventos son útiles para mantenimiento programado
- ✅ Los triggers complejos pueden implementar lógica de negocio avanzada

## 🔗 Próximo Nivel
Continúa con `docs/senior_4` para aprender sobre optimización avanzada y análisis de consultas.

---

**💡 Consejo: Practica implementando triggers para casos de uso reales como auditoría, validación y sincronización. Son herramientas poderosas para automatización.**
