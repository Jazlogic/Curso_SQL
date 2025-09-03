-- =====================================================
-- EJERCICIOS PRÁCTICOS - MÓDULO 3: BASES DE DATOS AVANZADAS
-- =====================================================

-- =====================================================
-- EJERCICIOS DE LA CLASE 1: TRANSACCIONES Y CONCURRENCIA
-- =====================================================

-- Ejercicio 1: Transacción de Transferencia
-- Crear una transacción que transfiera $150 de la cuenta 'ACC001' a 'ACC002'
START TRANSACTION;
UPDATE cuentas SET saldo = saldo - 150 WHERE numero_cuenta = 'ACC001';
UPDATE cuentas SET saldo = saldo + 150 WHERE numero_cuenta = 'ACC002';
COMMIT;

-- Ejercicio 2: Transacción con Validación
-- Implementar una transacción que inserte una nueva cuenta solo si el número no existe
START TRANSACTION;
INSERT INTO cuentas (numero_cuenta, saldo) 
SELECT 'ACC003', 500.00 
WHERE NOT EXISTS (SELECT 1 FROM cuentas WHERE numero_cuenta = 'ACC003');
COMMIT;

-- Ejercicio 3: Transacción con Savepoints
-- Crear una transacción que inserte 3 cuentas, pero permite revertir solo las dos últimas
START TRANSACTION;
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC004', 1000.00);
SAVEPOINT punto1;
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC005', 2000.00);
SAVEPOINT punto2;
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC006', 3000.00);
ROLLBACK TO SAVEPOINT punto1;
COMMIT;

-- Ejercicio 4: Manejo de Errores
-- Implementar una transacción que maneje errores y haga rollback automático
START TRANSACTION;
INSERT INTO cuentas (numero_cuenta, saldo) VALUES ('ACC007', 750.00);
-- Simular error
SELECT COUNT(*) FROM cuentas WHERE saldo < 0;
ROLLBACK;

-- Ejercicio 5: Transacción de Actualización Masiva
-- Crear una transacción que actualice el saldo de múltiples cuentas
START TRANSACTION;
UPDATE cuentas SET saldo = saldo * 1.05 WHERE numero_cuenta IN ('ACC001', 'ACC002');
COMMIT;

-- =====================================================
-- EJERCICIOS DE LA CLASE 2: PROCEDIMIENTOS ALMACENADOS BÁSICOS
-- =====================================================

-- Ejercicio 1: Procedimiento de Inserción
DELIMITER //
CREATE PROCEDURE InsertarProducto(
    IN p_nombre VARCHAR(100),
    IN p_precio DECIMAL(10,2),
    IN p_stock INT
)
BEGIN
    INSERT INTO productos (nombre, precio, stock) VALUES (p_nombre, p_precio, p_stock);
END //
DELIMITER ;

-- Ejercicio 2: Procedimiento de Actualización
DELIMITER //
CREATE PROCEDURE ActualizarPrecio(
    IN p_id INT,
    IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
    UPDATE productos SET precio = p_nuevo_precio WHERE id = p_id;
END //
DELIMITER ;

-- Ejercicio 3: Procedimiento de Eliminación
DELIMITER //
CREATE PROCEDURE EliminarProducto(
    IN p_id INT
)
BEGIN
    DELETE FROM productos WHERE id = p_id AND stock = 0;
END //
DELIMITER ;

-- Ejercicio 4: Procedimiento de Consulta
DELIMITER //
CREATE PROCEDURE ProductosStockBajo()
BEGIN
    SELECT * FROM productos WHERE stock < 5;
END //
DELIMITER ;

-- Ejercicio 5: Procedimiento con Múltiples Parámetros
DELIMITER //
CREATE PROCEDURE BuscarProductosPorPrecio(
    IN p_precio_min DECIMAL(10,2),
    IN p_precio_max DECIMAL(10,2)
)
BEGIN
    SELECT * FROM productos WHERE precio BETWEEN p_precio_min AND p_precio_max;
END //
DELIMITER ;

-- =====================================================
-- EJERCICIOS DE LA CLASE 3: PROCEDIMIENTOS ALMACENADOS AVANZADOS
-- =====================================================

-- Ejercicio 1: Cursor con Procesamiento
DELIMITER //
CREATE PROCEDURE ProcesarVentasConCursor()
BEGIN
    DECLARE v_id INT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE fin_cursor BOOLEAN DEFAULT FALSE;
    
    DECLARE cursor_ventas CURSOR FOR 
        SELECT id, cantidad * precio_unitario FROM ventas_detalle;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin_cursor = TRUE;
    
    OPEN cursor_ventas;
    
    loop_ventas: LOOP
        FETCH cursor_ventas INTO v_id, v_total;
        IF fin_cursor THEN
            LEAVE loop_ventas;
        END IF;
        
        UPDATE ventas_detalle SET total = v_total WHERE id = v_id;
    END LOOP;
    
    CLOSE cursor_ventas;
END //
DELIMITER ;

-- Ejercicio 2: Loop con Validación
DELIMITER //
CREATE PROCEDURE ValidarProductos()
BEGIN
    DECLARE contador INT DEFAULT 1;
    DECLARE total_productos INT;
    
    SELECT COUNT(*) INTO total_productos FROM productos;
    
    WHILE contador <= total_productos DO
        UPDATE productos SET nombre = UPPER(nombre) WHERE id = contador;
        SET contador = contador + 1;
    END WHILE;
END //
DELIMITER ;

-- Ejercicio 3: Manejo de Errores Complejo
DELIMITER //
CREATE PROCEDURE OperacionInventario(
    IN p_producto_id INT,
    IN p_cantidad INT,
    OUT p_resultado VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_resultado = 'Error en operación de inventario';
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    IF p_cantidad < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad no puede ser negativa';
    END IF;
    
    UPDATE productos SET stock = stock + p_cantidad WHERE id = p_producto_id;
    
    COMMIT;
    SET p_resultado = 'Operación completada';
END //
DELIMITER ;

-- =====================================================
-- EJERCICIOS DE LA CLASE 4: FUNCIONES PERSONALIZADAS
-- =====================================================

-- Ejercicio 1: Función de Cálculo
DELIMITER //
CREATE FUNCTION CalcularAreaRectangulo(base DECIMAL(10,2), altura DECIMAL(10,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN base * altura;
END //
DELIMITER ;

-- Ejercicio 2: Función de Validación
DELIMITER //
CREATE FUNCTION EsNumeroPrimo(numero INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE i INT DEFAULT 2;
    
    IF numero < 2 THEN
        RETURN FALSE;
    END IF;
    
    WHILE i * i <= numero DO
        IF numero % i = 0 THEN
            RETURN FALSE;
        END IF;
        SET i = i + 1;
    END WHILE;
    
    RETURN TRUE;
END //
DELIMITER ;

-- Ejercicio 3: Función de Formato
DELIMITER //
CREATE FUNCTION FormatearMoneda(cantidad DECIMAL(10,2))
RETURNS VARCHAR(50)
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN CONCAT('$', FORMAT(cantidad, 2));
END //
DELIMITER ;

-- Ejercicio 4: Función de Conversión
DELIMITER //
CREATE FUNCTION CelsiusAFahrenheit(celsius DECIMAL(5,2))
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN (celsius * 9/5) + 32;
END //
DELIMITER ;

-- Ejercicio 5: Función de Búsqueda
DELIMITER //
CREATE FUNCTION BuscarProductoPorNombre(nombre_producto VARCHAR(100))
RETURNS INT
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE producto_id INT;
    
    SELECT id INTO producto_id 
    FROM productos 
    WHERE nombre LIKE CONCAT('%', nombre_producto, '%') 
    LIMIT 1;
    
    RETURN COALESCE(producto_id, 0);
END //
DELIMITER ;

-- =====================================================
-- EJERCICIOS DE LA CLASE 5: TRIGGERS Y AUTOMATIZACIÓN
-- =====================================================

-- Ejercicio 1: Trigger de Auditoría Completa
DELIMITER //
CREATE TRIGGER trigger_auditoria_productos_completa
    AFTER UPDATE ON productos
    FOR EACH ROW
BEGIN
    INSERT INTO auditoria_sistema (
        tabla_afectada, accion, registro_id, 
        valores_anteriores, valores_nuevos, usuario
    ) VALUES (
        'productos', 'UPDATE', NEW.id,
        CONCAT('Nombre: ', OLD.nombre, ', Precio: ', OLD.precio, ', Stock: ', OLD.stock),
        CONCAT('Nombre: ', NEW.nombre, ', Precio: ', NEW.precio, ', Stock: ', NEW.stock),
        USER()
    );
END //
DELIMITER ;

-- Ejercicio 2: Trigger de Validación de Datos
DELIMITER //
CREATE TRIGGER trigger_validar_producto_completo
    BEFORE INSERT ON productos
    FOR EACH ROW
BEGIN
    IF NEW.nombre IS NULL OR NEW.nombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre requerido';
    END IF;
    
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio debe ser positivo';
    END IF;
    
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock no puede ser negativo';
    END IF;
    
    SET NEW.nombre = UPPER(NEW.nombre);
END //
DELIMITER ;

-- Ejercicio 3: Trigger de Cálculo de Totales
DELIMITER //
CREATE TRIGGER trigger_calcular_total_venta
    BEFORE INSERT ON ventas_detalle
    FOR EACH ROW
BEGIN
    SET NEW.total = NEW.cantidad * NEW.precio_unitario;
END //
DELIMITER ;

-- Ejercicio 4: Trigger de Actualización de Contadores
DELIMITER //
CREATE TRIGGER trigger_actualizar_contador_ventas
    AFTER INSERT ON ventas_detalle
    FOR EACH ROW
BEGIN
    UPDATE productos 
    SET stock = stock - NEW.cantidad 
    WHERE id = NEW.producto_id;
END //
DELIMITER ;

-- Ejercicio 5: Trigger de Validación de Negocio
DELIMITER //
CREATE TRIGGER trigger_validar_negocio_venta
    BEFORE INSERT ON ventas_detalle
    FOR EACH ROW
BEGIN
    DECLARE stock_disponible INT;
    
    SELECT stock INTO stock_disponible 
    FROM productos 
    WHERE id = NEW.producto_id;
    
    IF stock_disponible < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
END //
DELIMITER ;

-- =====================================================
-- EJERCICIOS DE LA CLASE 6: EVENTOS PROGRAMADOS
-- =====================================================

-- Ejercicio 1: Evento de Limpieza de Datos
DELIMITER //
CREATE EVENT evento_limpiar_datos_antiguos
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM logs_sistema 
    WHERE fecha_log < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    INSERT INTO logs_sistema (nivel, mensaje) 
    VALUES ('INFO', 'Limpieza de datos antiguos completada');
END //
DELIMITER ;

-- Ejercicio 2: Evento de Mantenimiento
DELIMITER //
CREATE EVENT evento_mantenimiento_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-01-01 02:00:00'
DO
BEGIN
    OPTIMIZE TABLE productos;
    OPTIMIZE TABLE ventas_detalle;
    
    INSERT INTO logs_sistema (nivel, mensaje) 
    VALUES ('INFO', 'Mantenimiento semanal ejecutado');
END //
DELIMITER ;

-- Ejercicio 3: Evento de Generación de Reportes
DELIMITER //
CREATE EVENT evento_reporte_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 23:59:00'
DO
BEGIN
    DECLARE total_ventas DECIMAL(10,2);
    DECLARE total_productos INT;
    
    SELECT COALESCE(SUM(total), 0) INTO total_ventas
    FROM ventas_detalle
    WHERE DATE(fecha_venta) = CURDATE();
    
    SELECT COUNT(*) INTO total_productos
    FROM productos;
    
    INSERT INTO logs_sistema (nivel, mensaje) 
    VALUES ('INFO', CONCAT('Reporte diario - Ventas: $', total_ventas, ', Productos: ', total_productos));
END //
DELIMITER ;

-- Ejercicio 4: Evento de Actualización de Contadores
DELIMITER //
CREATE EVENT evento_actualizar_contadores
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE estadisticas_productos s
    JOIN (
        SELECT producto_id, SUM(cantidad) as total_vendido
        FROM ventas_detalle
        WHERE fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
        GROUP BY producto_id
    ) v ON s.producto_id = v.producto_id
    SET s.total_ventas = s.total_ventas + v.total_vendido;
    
    INSERT INTO logs_sistema (nivel, mensaje) 
    VALUES ('INFO', 'Contadores actualizados');
END //
DELIMITER ;

-- Ejercicio 5: Evento de Verificación de Integridad
DELIMITER //
CREATE EVENT evento_verificar_integridad
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 01:00:00'
DO
BEGIN
    DECLARE productos_sin_stock INT;
    
    SELECT COUNT(*) INTO productos_sin_stock
    FROM productos
    WHERE stock = 0;
    
    IF productos_sin_stock > 0 THEN
        INSERT INTO logs_sistema (nivel, mensaje) 
        VALUES ('ALERTA', CONCAT('Hay ', productos_sin_stock, ' productos sin stock'));
    END IF;
END //
DELIMITER ;

-- =====================================================
-- EJERCICIOS DE LA CLASE 7: ADMINISTRACIÓN DE USUARIOS Y PERMISOS
-- =====================================================

-- Ejercicio 1: Usuario de Aplicación
CREATE USER 'app_web'@'localhost' IDENTIFIED BY 'app_2024';
GRANT SELECT, INSERT, UPDATE, DELETE ON tienda.* TO 'app_web'@'localhost';

-- Ejercicio 2: Usuario de Reportes
CREATE USER 'reportes'@'%' IDENTIFIED BY 'reportes_2024';
GRANT SELECT ON tienda.productos TO 'reportes'@'%';
GRANT SELECT ON tienda.ventas_detalle TO 'reportes'@'%';

-- Ejercicio 3: Usuario de Administración
CREATE USER 'admin_tienda'@'localhost' IDENTIFIED BY 'admin_2024';
GRANT ALL PRIVILEGES ON tienda.* TO 'admin_tienda'@'localhost';
GRANT CREATE USER ON *.* TO 'admin_tienda'@'localhost';

-- Ejercicio 4: Usuario con Restricciones
CREATE USER 'usuario_restricto'@'localhost' 
IDENTIFIED BY 'restricto_2024'
PASSWORD EXPIRE INTERVAL 30 DAY
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 1;
GRANT SELECT ON tienda.productos TO 'usuario_restricto'@'localhost';

-- Ejercicio 5: Sistema de Roles
CREATE ROLE 'rol_empleado';
GRANT SELECT, INSERT, UPDATE ON tienda.productos TO 'rol_empleado';
GRANT SELECT ON tienda.categorias TO 'rol_empleado';

CREATE USER 'empleado1'@'localhost' IDENTIFIED BY 'empleado_2024';
GRANT 'rol_empleado' TO 'empleado1'@'localhost';
SET DEFAULT ROLE 'rol_empleado' FOR 'empleado1'@'localhost';

-- =====================================================
-- EJERCICIOS DE LA CLASE 8: BACKUP Y RECUPERACIÓN
-- =====================================================

-- Ejercicio 1: Backup Básico
-- Comando: mysqldump -u root -p tienda > backup_tienda.sql

-- Ejercicio 2: Backup con Opciones
-- Comando: mysqldump -u root -p --single-transaction --routines --triggers tienda > backup_completo.sql

-- Ejercicio 3: Backup de Estructura
-- Comando: mysqldump -u root -p --no-data tienda > estructura_tienda.sql

-- Ejercicio 4: Backup de Datos
-- Comando: mysqldump -u root -p --no-create-info tienda > datos_tienda.sql

-- Ejercicio 5: Backup con Compresión
-- Comando: mysqldump -u root -p tienda | gzip > backup_tienda.sql.gz

-- =====================================================
-- EJERCICIOS DE LA CLASE 9: MONITOREO Y OPTIMIZACIÓN
-- =====================================================

-- Ejercicio 1: Monitoreo Básico
SHOW STATUS LIKE 'Questions';
SHOW STATUS LIKE 'Uptime';
SHOW STATUS LIKE 'Connections';

-- Ejercicio 2: Análisis de Consultas
SELECT 
    DIGEST_TEXT,
    COUNT_STAR,
    AVG_TIMER_WAIT/1000000000 as avg_time_seconds
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT IS NOT NULL
ORDER BY AVG_TIMER_WAIT DESC;

-- Ejercicio 3: Monitoreo de Conexiones
SELECT 
    ID, USER, HOST, DB, COMMAND, TIME, STATE
FROM information_schema.PROCESSLIST
WHERE COMMAND != 'Sleep';

-- Ejercicio 4: Análisis de Memoria
SELECT 
    EVENT_NAME,
    CURRENT_NUMBER_OF_BYTES_USED/1024/1024 as MB_USED
FROM performance_schema.memory_summary_global_by_event_name
WHERE CURRENT_NUMBER_OF_BYTES_USED > 0
ORDER BY CURRENT_NUMBER_OF_BYTES_USED DESC;

-- Ejercicio 5: Optimización de Consultas
EXPLAIN SELECT * FROM productos WHERE precio > 100;
CREATE INDEX idx_precio ON productos(precio);
EXPLAIN SELECT * FROM productos WHERE precio > 100;

-- =====================================================
-- EJERCICIOS DE LA CLASE 10: PROYECTO INTEGRADOR
-- =====================================================

-- Ejercicio 1: Configuración Inicial
-- Implementar la estructura completa de la base de datos del proyecto

-- Ejercicio 2: Procedimientos de Gestión
-- Crear todos los procedimientos necesarios para el sistema de biblioteca

-- Ejercicio 3: Sistema de Auditoría
-- Implementar triggers para auditar todos los cambios importantes

-- Ejercicio 4: Automatización
-- Configurar eventos para mantenimiento automático del sistema

-- Ejercicio 5: Seguridad
-- Establecer políticas de seguridad y permisos de usuarios

-- Ejercicio 6: Backup y Recuperación
-- Implementar sistema de backup automático y recuperación

-- Ejercicio 7: Monitoreo
-- Crear sistema de monitoreo y alertas del sistema

-- Ejercicio 8: Reportes
-- Implementar procedimientos para generar reportes del sistema

-- Ejercicio 9: Optimización
-- Aplicar técnicas de optimización y análisis de rendimiento

-- Ejercicio 10: Pruebas Integrales
-- Realizar pruebas completas del sistema implementado

-- =====================================================
-- FIN DE EJERCICIOS PRÁCTICOS - MÓDULO 3
-- =====================================================
