# 🎯 Senior Level 2: Procedimientos Almacenados y Funciones

## 🧭 Navegación del Curso

**← Anterior**: [Senior Level 1: Transacciones](../senior_1/README.md)  
**Siguiente →**: [Senior Level 3: Triggers y Eventos](../senior_3/README.md)

---

## 📖 Teoría

### ¿Qué son los Procedimientos Almacenados?
Los procedimientos almacenados son bloques de código SQL reutilizables que se ejecutan en el servidor de base de datos. Permiten encapsular lógica de negocio compleja y mejorar el rendimiento.

### ¿Qué son las Funciones?
Las funciones son objetos de base de datos que retornan un valor y pueden ser usadas en consultas SQL. Son útiles para cálculos complejos y validaciones.

### Ventajas de Procedimientos y Funciones
- **Rendimiento**: Ejecución en el servidor
- **Seguridad**: Control de acceso granular
- **Mantenibilidad**: Lógica centralizada
- **Reutilización**: Código compartido
- **Transacciones**: Manejo de operaciones complejas

### Tipos de Parámetros
- **IN**: Parámetros de entrada
- **OUT**: Parámetros de salida
- **INOUT**: Parámetros de entrada/salida

## 💡 Ejemplos Prácticos

### Ejemplo 1: Procedimiento Básico
```sql
DELIMITER //
CREATE PROCEDURE obtener_productos_por_categoria(
    IN categoria_nombre VARCHAR(100)
)
BEGIN
    SELECT p.nombre, p.precio, p.stock
    FROM productos p
    INNER JOIN categorias c ON p.categoria_id = c.id
    WHERE c.nombre = categoria_nombre
    ORDER BY p.precio DESC;
END //
DELIMITER ;

-- Usar el procedimiento
CALL obtener_productos_por_categoria('Electrónica');
```

### Ejemplo 2: Función de Cálculo
```sql
DELIMITER //
CREATE FUNCTION calcular_descuento(
    precio DECIMAL(10,2),
    porcentaje_descuento INT
) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio_final DECIMAL(10,2);
    SET precio_final = precio * (1 - porcentaje_descuento / 100);
    RETURN ROUND(precio_final, 2);
END //
DELIMITER ;

-- Usar la función
SELECT nombre, precio, calcular_descuento(precio, 15) AS precio_con_descuento
FROM productos;
```

### Ejemplo 3: Procedimiento con Transacciones
```sql
DELIMITER //
CREATE PROCEDURE procesar_venta(
    IN cliente_id INT,
    IN producto_id INT,
    IN cantidad INT,
    OUT mensaje VARCHAR(200)
)
BEGIN
    DECLARE stock_disponible INT;
    DECLARE precio_unitario DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET mensaje = 'Error en la transacción';
    END;
    
    START TRANSACTION;
        -- Verificar stock
        SELECT stock, precio INTO stock_disponible, precio_unitario
        FROM productos WHERE id = producto_id;
        
        IF stock_disponible < cantidad THEN
            SET mensaje = 'Stock insuficiente';
            ROLLBACK;
        ELSE
            -- Actualizar stock
            UPDATE productos SET stock = stock - cantidad WHERE id = producto_id;
            
            -- Crear venta
            INSERT INTO ventas (cliente_id, producto_id, cantidad, precio_total, fecha)
            VALUES (cliente_id, producto_id, cantidad, cantidad * precio_unitario, NOW());
            
            SET mensaje = 'Venta procesada exitosamente';
            COMMIT;
        END IF;
    END //
DELIMITER ;
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Gestión de Empleados
Crea procedimientos y funciones para:

1. Calcular salarios con bonificaciones
2. Gestionar promociones de empleados
3. Generar reportes de rendimiento
4. Calcular antigüedad y beneficios
5. Manejar licencias y ausencias

**Solución:**
```sql
-- 1. Función para calcular salario total
DELIMITER //
CREATE FUNCTION calcular_salario_total(
    salario_base DECIMAL(10,2),
    años_antigüedad INT,
    rendimiento DECIMAL(3,2)
) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE bono_antigüedad DECIMAL(10,2);
    DECLARE bono_rendimiento DECIMAL(10,2);
    DECLARE salario_total DECIMAL(10,2);
    
    -- Bono por antigüedad (5% por año, máximo 25%)
    SET bono_antigüedad = salario_base * (LEAST(años_antigüedad * 0.05, 0.25));
    
    -- Bono por rendimiento (0-20% del salario base)
    SET bono_rendimiento = salario_base * (rendimiento * 0.20);
    
    SET salario_total = salario_base + bono_antigüedad + bono_rendimiento;
    RETURN ROUND(salario_total, 2);
END //
DELIMITER ;

-- 2. Procedimiento para gestionar promociones
DELIMITER //
CREATE PROCEDURE promover_empleado(
    IN empleado_id INT,
    IN nuevo_cargo VARCHAR(100),
    IN nuevo_salario DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Registrar cambio de cargo
        INSERT INTO historial_cargos (
            empleado_id, cargo_anterior, cargo_nuevo, 
            salario_anterior, salario_nuevo, fecha_cambio
        ) SELECT 
            id, cargo, nuevo_cargo, salario, nuevo_salario, NOW()
        FROM empleados 
        WHERE id = empleado_id;
        
        -- Actualizar empleado
        UPDATE empleados 
        SET cargo = nuevo_cargo, 
            salario = nuevo_salario,
            fecha_promocion = NOW()
        WHERE id = empleado_id;
        
        -- Registrar en auditoría
        INSERT INTO auditoria_empleados (
            empleado_id, accion, detalles, fecha
        ) VALUES (
            empleado_id, 'PROMOCION', 
            CONCAT('Promovido a ', nuevo_cargo), NOW()
        );
        
    COMMIT;
END //
DELIMITER ;
```

### Ejercicio 2: Sistema de Gestión de Inventario
Crea procedimientos y funciones para:

1. Gestionar stock mínimo y máximo
2. Calcular rotación de inventario
3. Generar alertas de stock
4. Manejar transferencias entre almacenes
5. Calcular costos de inventario

**Solución:**
```sql
-- 1. Función para calcular rotación de inventario
DELIMITER //
CREATE FUNCTION calcular_rotacion_inventario(
    producto_id INT,
    período_días INT
) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE stock_promedio DECIMAL(10,2);
    DECLARE ventas_período INT;
    DECLARE rotacion DECIMAL(10,2);
    
    -- Calcular stock promedio del período
    SELECT AVG(stock) INTO stock_promedio
    FROM historial_stock
    WHERE producto_id = producto_id
    AND fecha >= DATE_SUB(CURDATE(), INTERVAL período_días DAY);
    
    -- Calcular ventas del período
    SELECT COALESCE(SUM(cantidad), 0) INTO ventas_período
    FROM ventas
    WHERE producto_id = producto_id
    AND fecha >= DATE_SUB(CURDATE(), INTERVAL período_días DAY);
    
    -- Calcular rotación
    IF stock_promedio > 0 THEN
        SET rotacion = ventas_período / stock_promedio;
    ELSE
        SET rotacion = 0;
    END IF;
    
    RETURN ROUND(rotacion, 2);
END //
DELIMITER ;

-- 2. Procedimiento para generar alertas de stock
DELIMITER //
CREATE PROCEDURE generar_alertas_stock()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE producto_id INT;
    DECLARE nombre_producto VARCHAR(200);
    DECLARE stock_actual INT;
    DECLARE stock_minimo INT;
    DECLARE rotacion DECIMAL(10,2);
    
    DECLARE cur CURSOR FOR
        SELECT p.id, p.nombre, p.stock, p.stock_minimo
        FROM productos p
        WHERE p.activo = 1;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO producto_id, nombre_producto, stock_actual, stock_minimo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Calcular rotación
        SET rotacion = calcular_rotacion_inventario(producto_id, 30);
        
        -- Generar alertas según criterios
        IF stock_actual <= stock_minimo THEN
            INSERT INTO alertas_stock (
                producto_id, tipo_alerta, descripcion, 
                stock_actual, stock_minimo, fecha
            ) VALUES (
                producto_id, 'STOCK_CRITICO', 
                CONCAT('Stock crítico: ', stock_actual, ' unidades'),
                stock_actual, stock_minimo, NOW()
            );
        ELSEIF stock_actual <= stock_minimo * 1.5 AND rotacion > 2 THEN
            INSERT INTO alertas_stock (
                producto_id, tipo_alerta, descripcion, 
                stock_actual, stock_minimo, fecha
            ) VALUES (
                producto_id, 'STOCK_BAJO_ALTA_DEMANDA', 
                CONCAT('Stock bajo con alta rotación: ', rotacion),
                stock_actual, stock_minimo, NOW()
            );
        END IF;
        
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 3: Sistema de Gestión de Clientes
Crea procedimientos y funciones para:

1. Calcular valor del cliente (CLV)
2. Segmentar clientes por comportamiento
3. Gestionar programas de fidelización
4. Generar recomendaciones personalizadas
5. Manejar quejas y reclamaciones

**Solución:**
```sql
-- 1. Función para calcular CLV (Customer Lifetime Value)
DELIMITER //
CREATE FUNCTION calcular_clv(
    cliente_id INT
) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE compras_totales DECIMAL(10,2);
    DECLARE frecuencia_compra DECIMAL(5,2);
    DECLARE tasa_retencion DECIMAL(3,2);
    DECLARE clv DECIMAL(10,2);
    
    -- Calcular compras totales
    SELECT COALESCE(SUM(total), 0) INTO compras_totales
    FROM pedidos
    WHERE cliente_id = cliente_id AND estado = 'Completado';
    
    -- Calcular frecuencia de compra (compras por mes)
    SELECT COALESCE(COUNT(*) / GREATEST(DATEDIFF(MAX(fecha), MIN(fecha)) / 30, 1), 0)
    INTO frecuencia_compra
    FROM pedidos
    WHERE cliente_id = cliente_id AND estado = 'Completado';
    
    -- Calcular tasa de retención (porcentaje de clientes que repiten)
    SELECT COALESCE(
        (COUNT(DISTINCT cliente_id) / COUNT(*)) * 100, 0
    ) INTO tasa_retencion
    FROM (
        SELECT cliente_id, COUNT(*) as compras
        FROM pedidos
        WHERE estado = 'Completado'
        GROUP BY cliente_id
        HAVING COUNT(*) > 1
    ) clientes_recurrentes;
    
    -- Calcular CLV
    SET clv = compras_totales * frecuencia_compra * (tasa_retencion / 100);
    RETURN ROUND(clv, 2);
END //
DELIMITER ;

-- 2. Procedimiento para segmentar clientes
DELIMITER //
CREATE PROCEDURE segmentar_clientes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cliente_id INT;
    DECLARE clv DECIMAL(10,2);
    DECLARE segmento VARCHAR(50);
    
    DECLARE cur CURSOR FOR
        SELECT c.id, calcular_clv(c.id) as clv
        FROM clientes c;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Limpiar segmentaciones anteriores
    UPDATE clientes SET segmento = NULL;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO cliente_id, clv;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Determinar segmento
        IF clv > 10000 THEN
            SET segmento = 'PREMIUM';
        ELSEIF clv > 5000 THEN
            SET segmento = 'GOLD';
        ELSEIF clv > 2000 THEN
            SET segmento = 'SILVER';
        ELSEIF clv > 500 THEN
            SET segmento = 'BRONZE';
        ELSE
            SET segmento = 'BASIC';
        END IF;
        
        -- Actualizar segmento
        UPDATE clientes 
        SET segmento = segmento, 
            fecha_segmentacion = NOW()
        WHERE id = cliente_id;
        
    END LOOP;
    
    CLOSE cur;
END //
DELIMITER ;
```

### Ejercicio 4: Sistema de Gestión de Proyectos
Crea procedimientos y funciones para:

1. Calcular progreso de proyectos
2. Gestionar asignación de recursos
3. Calcular costos y presupuestos
4. Generar reportes de estado
5. Manejar dependencias entre tareas

**Solución:**
```sql
-- 1. Función para calcular progreso del proyecto
DELIMITER //
CREATE FUNCTION calcular_progreso_proyecto(
    proyecto_id INT
) 
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE total_tareas INT;
    DECLARE tareas_completadas INT;
    DECLARE progreso DECIMAL(5,2);
    
    -- Contar total de tareas
    SELECT COUNT(*) INTO total_tareas
    FROM tareas
    WHERE proyecto_id = proyecto_id;
    
    -- Contar tareas completadas
    SELECT COUNT(*) INTO tareas_completadas
    FROM tareas
    WHERE proyecto_id = proyecto_id AND estado = 'COMPLETADA';
    
    -- Calcular progreso
    IF total_tareas > 0 THEN
        SET progreso = (tareas_completadas / total_tareas) * 100;
    ELSE
        SET progreso = 0;
    END IF;
    
    RETURN ROUND(progreso, 2);
END //
DELIMITER ;

-- 2. Procedimiento para asignar recursos
DELIMITER //
CREATE PROCEDURE asignar_recurso_tarea(
    IN tarea_id INT,
    IN recurso_id INT,
    IN horas_asignadas INT
)
BEGIN
    DECLARE horas_disponibles INT;
    DECLARE proyecto_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Obtener proyecto de la tarea
        SELECT proyecto_id INTO proyecto_id
        FROM tareas WHERE id = tarea_id;
        
        -- Verificar disponibilidad del recurso
        SELECT horas_disponibles INTO horas_disponibles
        FROM recursos
        WHERE id = recurso_id;
        
        IF horas_disponibles < horas_asignadas THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recurso no disponible';
        END IF;
        
        -- Asignar recurso a la tarea
        INSERT INTO asignaciones_recursos (
            tarea_id, recurso_id, horas_asignadas, 
            fecha_asignacion, estado
        ) VALUES (
            tarea_id, recurso_id, horas_asignadas, 
            NOW(), 'ACTIVA'
        );
        
        -- Actualizar disponibilidad del recurso
        UPDATE recursos 
        SET horas_disponibles = horas_disponibles - horas_asignadas
        WHERE id = recurso_id;
        
        -- Actualizar estado de la tarea
        UPDATE tareas 
        SET estado = 'EN_PROGRESO',
            fecha_inicio = COALESCE(fecha_inicio, NOW())
        WHERE id = tarea_id;
        
    COMMIT;
END //
DELIMITER ;
```

### Ejercicio 5: Sistema de Gestión de Calidad
Crea procedimientos y funciones para:

1. Calcular métricas de calidad
2. Gestionar no conformidades
3. Generar reportes de auditoría
4. Calcular costos de calidad
5. Manejar acciones correctivas

**Solución:**
```sql
-- 1. Función para calcular métricas de calidad
DELIMITER //
CREATE FUNCTION calcular_metricas_calidad(
    producto_id INT,
    período_días INT
) 
RETURNS JSON
READS SQL DATA
BEGIN
    DECLARE total_producido INT;
    DECLARE total_defectuoso INT;
    DECLARE defectos_por_millón DECIMAL(10,2);
    DECLARE tasa_defectos DECIMAL(5,2);
    DECLARE resultado JSON;
    
    -- Calcular total producido
    SELECT COALESCE(SUM(cantidad), 0) INTO total_producido
    FROM produccion
    WHERE producto_id = producto_id
    AND fecha >= DATE_SUB(CURDATE(), INTERVAL período_días DAY);
    
    -- Calcular total defectuoso
    SELECT COALESCE(SUM(cantidad), 0) INTO total_defectuoso
    FROM no_conformidades
    WHERE producto_id = producto_id
    AND fecha >= DATE_SUB(CURDATE(), INTERVAL período_días DAY);
    
    -- Calcular métricas
    IF total_producido > 0 THEN
        SET tasa_defectos = (total_defectuoso / total_producido) * 100;
        SET defectos_por_millón = (total_defectuoso / total_producido) * 1000000;
    ELSE
        SET tasa_defectos = 0;
        SET defectos_por_millón = 0;
    END IF;
    
    -- Crear resultado JSON
    SET resultado = JSON_OBJECT(
        'total_producido', total_producido,
        'total_defectuoso', total_defectuoso,
        'tasa_defectos', ROUND(tasa_defectos, 2),
        'defectos_por_millon', ROUND(defectos_por_millón, 2),
        'periodo_dias', período_días
    );
    
    RETURN resultado;
END //
DELIMITER ;

-- 2. Procedimiento para gestionar no conformidades
DELIMITER //
CREATE PROCEDURE registrar_no_conformidad(
    IN producto_id INT,
    IN lote_id INT,
    IN cantidad INT,
    IN tipo_defecto VARCHAR(100),
    IN descripcion TEXT,
    IN responsable_id INT
)
BEGIN
    DECLARE no_conformidad_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
        -- Registrar no conformidad
        INSERT INTO no_conformidades (
            producto_id, lote_id, cantidad, tipo_defecto, 
            descripcion, responsable_id, fecha_registro, estado
        ) VALUES (
            producto_id, lote_id, cantidad, tipo_defecto, 
            descripcion, responsable_id, NOW(), 'REGISTRADA'
        );
        
        SET no_conformidad_id = LAST_INSERT_ID();
        
        -- Crear acción correctiva automática
        INSERT INTO acciones_correctivas (
            no_conformidad_id, tipo_accion, descripcion, 
            responsable_id, fecha_limite, estado
        ) VALUES (
            no_conformidad_id, 'INVESTIGACION', 
            'Investigar causa raíz del defecto', 
            responsable_id, DATE_ADD(NOW(), INTERVAL 7 DAY), 'PENDIENTE'
        );
        
        -- Actualizar inventario
        UPDATE inventario 
        SET stock_defectuoso = stock_defectuoso + cantidad
        WHERE producto_id = producto_id;
        
        -- Registrar en auditoría
        INSERT INTO auditoria_calidad (
            accion, producto_id, lote_id, cantidad, 
            usuario, fecha, detalles
        ) VALUES (
            'NO_CONFORMIDAD_REGISTRADA', producto_id, lote_id, 
            cantidad, USER(), NOW(), descripcion
        );
        
    COMMIT;
END //
DELIMITER ;
```

## 📝 Resumen de Conceptos Clave
- ✅ Los procedimientos almacenados encapsulan lógica de negocio compleja
- ✅ Las funciones retornan valores y pueden usarse en consultas SQL
- ✅ Los parámetros IN, OUT e INOUT permiten comunicación bidireccional
- ✅ El manejo de errores con handlers es esencial para robustez
- ✅ Los cursores permiten procesar resultados fila por fila
- ✅ Las transacciones en procedimientos garantizan consistencia

## 🔗 Próximo Nivel
Continúa con `docs/senior_3` para aprender sobre triggers y eventos.

---

**💡 Consejo: Practica creando procedimientos y funciones que resuelvan problemas reales de negocio. Son herramientas poderosas para la lógica de aplicación.**


