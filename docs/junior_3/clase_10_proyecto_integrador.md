# Clase 10: Proyecto Integrador - Sistema de Gestión de Biblioteca

## 📋 Descripción

En esta clase final del módulo, implementarás un proyecto integrador completo que combine todos los conceptos aprendidos: transacciones, procedimientos almacenados, funciones, triggers, eventos, administración de usuarios, backup y monitoreo. Crearás un sistema completo de gestión de biblioteca con todas las funcionalidades avanzadas.

## 🎯 Objetivos del Proyecto

- Integrar todos los conceptos del módulo en un proyecto real
- Implementar un sistema completo de gestión de biblioteca
- Aplicar transacciones para mantener integridad de datos
- Crear procedimientos almacenados para lógica de negocio
- Implementar triggers para automatización
- Configurar eventos para mantenimiento automático
- Establecer políticas de seguridad y usuarios
- Implementar sistema de backup y monitoreo

## 🏗️ Arquitectura del Sistema

### Estructura de la Base de Datos

```sql
-- Base de datos principal
CREATE DATABASE biblioteca_avanzada;
USE biblioteca_avanzada;

-- Tabla de usuarios del sistema
CREATE TABLE usuarios_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    rol ENUM('ADMIN', 'BIBLIOTECARIO', 'LECTOR') NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de libros
CREATE TABLE libros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    editorial VARCHAR(100),
    año_publicacion YEAR,
    categoria VARCHAR(50),
    stock_total INT NOT NULL DEFAULT 0,
    stock_disponible INT NOT NULL DEFAULT 0,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de lectores
CREATE TABLE lectores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    numero_carnet VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lector_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_prestamo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_devolucion_esperada DATE NOT NULL,
    fecha_devolucion_real DATE NULL,
    estado ENUM('ACTIVO', 'DEVUELTO', 'VENCIDO') DEFAULT 'ACTIVO',
    multa DECIMAL(10,2) DEFAULT 0.00,
    observaciones TEXT,
    FOREIGN KEY (lector_id) REFERENCES lectores(id),
    FOREIGN KEY (libro_id) REFERENCES libros(id)
);

-- Tabla de reservas
CREATE TABLE reservas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lector_id INT NOT NULL,
    libro_id INT NOT NULL,
    fecha_reserva TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento DATE NOT NULL,
    estado ENUM('ACTIVA', 'CANCELADA', 'COMPLETADA') DEFAULT 'ACTIVA',
    FOREIGN KEY (lector_id) REFERENCES lectores(id),
    FOREIGN KEY (libro_id) REFERENCES libros(id)
);

-- Tabla de auditoría
CREATE TABLE auditoria_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_afectada VARCHAR(50),
    accion VARCHAR(20),
    registro_id INT,
    valores_anteriores TEXT,
    valores_nuevos TEXT,
    usuario VARCHAR(50),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de logs del sistema
CREATE TABLE logs_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nivel VARCHAR(20),
    mensaje TEXT,
    usuario VARCHAR(50),
    fecha_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔧 Implementación del Sistema

### 1. Procedimientos Almacenados

```sql
-- Procedimiento para registrar un nuevo libro
DELIMITER //
CREATE PROCEDURE RegistrarLibro(
    IN p_isbn VARCHAR(20),
    IN p_titulo VARCHAR(200),
    IN p_autor VARCHAR(100),
    IN p_editorial VARCHAR(100),
    IN p_año YEAR,
    IN p_categoria VARCHAR(50),
    IN p_stock INT,
    OUT p_resultado VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_resultado = 'Error al registrar el libro';
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validar datos
    IF p_isbn IS NULL OR p_isbn = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ISBN es requerido';
    END IF;
    
    IF p_titulo IS NULL OR p_titulo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El título es requerido';
    END IF;
    
    IF p_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    -- Insertar libro
    INSERT INTO libros (isbn, titulo, autor, editorial, año_publicacion, categoria, stock_total, stock_disponible)
    VALUES (p_isbn, p_titulo, p_autor, p_editorial, p_año, p_categoria, p_stock, p_stock);
    
    COMMIT;
    SET p_resultado = 'Libro registrado correctamente';
END //
DELIMITER ;

-- Procedimiento para realizar un préstamo
DELIMITER //
CREATE PROCEDURE RealizarPrestamo(
    IN p_lector_id INT,
    IN p_libro_id INT,
    IN p_dias_prestamo INT,
    OUT p_resultado VARCHAR(255)
)
BEGIN
    DECLARE stock_disponible INT DEFAULT 0;
    DECLARE prestamos_activos INT DEFAULT 0;
    DECLARE fecha_devolucion DATE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_resultado = 'Error al realizar el préstamo';
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Verificar stock disponible
    SELECT stock_disponible INTO stock_disponible
    FROM libros WHERE id = p_libro_id;
    
    IF stock_disponible <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay ejemplares disponibles';
    END IF;
    
    -- Verificar préstamos activos del lector
    SELECT COUNT(*) INTO prestamos_activos
    FROM prestamos
    WHERE lector_id = p_lector_id AND estado = 'ACTIVO';
    
    IF prestamos_activos >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lector ha alcanzado el límite de préstamos';
    END IF;
    
    -- Calcular fecha de devolución
    SET fecha_devolucion = DATE_ADD(CURDATE(), INTERVAL p_dias_prestamo DAY);
    
    -- Realizar préstamo
    INSERT INTO prestamos (lector_id, libro_id, fecha_devolucion_esperada)
    VALUES (p_lector_id, p_libro_id, fecha_devolucion);
    
    -- Actualizar stock
    UPDATE libros SET stock_disponible = stock_disponible - 1 WHERE id = p_libro_id;
    
    COMMIT;
    SET p_resultado = 'Préstamo realizado correctamente';
END //
DELIMITER ;

-- Procedimiento para devolver un libro
DELIMITER //
CREATE PROCEDURE DevolverLibro(
    IN p_prestamo_id INT,
    OUT p_resultado VARCHAR(255)
)
BEGIN
    DECLARE libro_id INT;
    DECLARE fecha_esperada DATE;
    DECLARE dias_retraso INT DEFAULT 0;
    DECLARE multa_calculada DECIMAL(10,2) DEFAULT 0.00;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_resultado = 'Error al devolver el libro';
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Obtener información del préstamo
    SELECT libro_id, fecha_devolucion_esperada INTO libro_id, fecha_esperada
    FROM prestamos WHERE id = p_prestamo_id AND estado = 'ACTIVO';
    
    IF libro_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Préstamo no encontrado o ya devuelto';
    END IF;
    
    -- Calcular multa si hay retraso
    SET dias_retraso = DATEDIFF(CURDATE(), fecha_esperada);
    IF dias_retraso > 0 THEN
        SET multa_calculada = dias_retraso * 1.00; -- $1 por día de retraso
    END IF;
    
    -- Actualizar préstamo
    UPDATE prestamos 
    SET estado = 'DEVUELTO', 
        fecha_devolucion_real = CURDATE(),
        multa = multa_calculada
    WHERE id = p_prestamo_id;
    
    -- Actualizar stock
    UPDATE libros SET stock_disponible = stock_disponible + 1 WHERE id = libro_id;
    
    COMMIT;
    SET p_resultado = CONCAT('Libro devuelto correctamente. Multa: $', multa_calculada);
END //
DELIMITER ;
```

### 2. Funciones Personalizadas

```sql
-- Función para calcular multa por retraso
DELIMITER //
CREATE FUNCTION CalcularMulta(fecha_esperada DATE, fecha_real DATE)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE dias_retraso INT;
    DECLARE multa DECIMAL(10,2) DEFAULT 0.00;
    
    SET dias_retraso = DATEDIFF(fecha_real, fecha_esperada);
    
    IF dias_retraso > 0 THEN
        SET multa = dias_retraso * 1.00;
    END IF;
    
    RETURN multa;
END //
DELIMITER ;

-- Función para verificar disponibilidad de libro
DELIMITER //
CREATE FUNCTION VerificarDisponibilidad(libro_id INT)
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE stock_disponible INT DEFAULT 0;
    
    SELECT stock_disponible INTO stock_disponible
    FROM libros WHERE id = libro_id;
    
    RETURN stock_disponible > 0;
END //
DELIMITER ;

-- Función para obtener estadísticas de préstamos
DELIMITER //
CREATE FUNCTION ObtenerEstadisticasPrestamos(lector_id INT)
RETURNS VARCHAR(255)
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE prestamos_activos INT DEFAULT 0;
    DECLARE prestamos_totales INT DEFAULT 0;
    DECLARE multas_pendientes DECIMAL(10,2) DEFAULT 0.00;
    DECLARE resultado VARCHAR(255);
    
    SELECT COUNT(*) INTO prestamos_activos
    FROM prestamos WHERE lector_id = lector_id AND estado = 'ACTIVO';
    
    SELECT COUNT(*) INTO prestamos_totales
    FROM prestamos WHERE lector_id = lector_id;
    
    SELECT COALESCE(SUM(multa), 0) INTO multas_pendientes
    FROM prestamos WHERE lector_id = lector_id AND multa > 0;
    
    SET resultado = CONCAT('Activos: ', prestamos_activos, ', Total: ', prestamos_totales, ', Multas: $', multas_pendientes);
    
    RETURN resultado;
END //
DELIMITER ;
```

### 3. Triggers de Auditoría

```sql
-- Trigger para auditar cambios en libros
DELIMITER //
CREATE TRIGGER trigger_auditoria_libros
    AFTER UPDATE ON libros
    FOR EACH ROW
BEGIN
    INSERT INTO auditoria_sistema (
        tabla_afectada, 
        accion, 
        registro_id, 
        valores_anteriores, 
        valores_nuevos, 
        usuario
    ) VALUES (
        'libros',
        'UPDATE',
        NEW.id,
        CONCAT('Stock: ', OLD.stock_disponible, ', Título: ', OLD.titulo),
        CONCAT('Stock: ', NEW.stock_disponible, ', Título: ', NEW.titulo),
        USER()
    );
END //
DELIMITER ;

-- Trigger para auditar préstamos
DELIMITER //
CREATE TRIGGER trigger_auditoria_prestamos
    AFTER INSERT ON prestamos
    FOR EACH ROW
BEGIN
    INSERT INTO auditoria_sistema (
        tabla_afectada, 
        accion, 
        registro_id, 
        valores_anteriores, 
        valores_nuevos, 
        usuario
    ) VALUES (
        'prestamos',
        'INSERT',
        NEW.id,
        NULL,
        CONCAT('Lector: ', NEW.lector_id, ', Libro: ', NEW.libro_id, ', Fecha: ', NEW.fecha_devolucion_esperada),
        USER()
    );
END //
DELIMITER ;

-- Trigger para actualizar stock automáticamente
DELIMITER //
CREATE TRIGGER trigger_actualizar_stock_prestamo
    AFTER INSERT ON prestamos
    FOR EACH ROW
BEGIN
    UPDATE libros 
    SET stock_disponible = stock_disponible - 1 
    WHERE id = NEW.libro_id;
END //
DELIMITER ;

-- Trigger para restaurar stock en devolución
DELIMITER //
CREATE TRIGGER trigger_restaurar_stock_devolucion
    AFTER UPDATE ON prestamos
    FOR EACH ROW
BEGIN
    IF OLD.estado = 'ACTIVO' AND NEW.estado = 'DEVUELTO' THEN
        UPDATE libros 
        SET stock_disponible = stock_disponible + 1 
        WHERE id = NEW.libro_id;
    END IF;
END //
DELIMITER ;
```

### 4. Eventos Programados

```sql
-- Evento para actualizar préstamos vencidos
DELIMITER //
CREATE EVENT evento_actualizar_prestamos_vencidos
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE prestamos 
    SET estado = 'VENCIDO' 
    WHERE estado = 'ACTIVO' 
      AND fecha_devolucion_esperada < CURDATE();
    
    INSERT INTO logs_sistema (nivel, mensaje)
    VALUES ('INFO', 'Préstamos vencidos actualizados');
END //
DELIMITER ;

-- Evento para limpiar logs antiguos
DELIMITER //
CREATE EVENT evento_limpiar_logs_antiguos
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM logs_sistema 
    WHERE fecha_log < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    DELETE FROM auditoria_sistema 
    WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 90 DAY);
    
    INSERT INTO logs_sistema (nivel, mensaje)
    VALUES ('INFO', 'Limpieza de logs antiguos completada');
END //
DELIMITER ;

-- Evento para generar reporte diario
DELIMITER //
CREATE EVENT evento_reporte_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 23:59:00'
DO
BEGIN
    DECLARE prestamos_hoy INT DEFAULT 0;
    DECLARE devoluciones_hoy INT DEFAULT 0;
    DECLARE multas_hoy DECIMAL(10,2) DEFAULT 0.00;
    
    SELECT COUNT(*) INTO prestamos_hoy
    FROM prestamos WHERE DATE(fecha_prestamo) = CURDATE();
    
    SELECT COUNT(*) INTO devoluciones_hoy
    FROM prestamos WHERE DATE(fecha_devolucion_real) = CURDATE();
    
    SELECT COALESCE(SUM(multa), 0) INTO multas_hoy
    FROM prestamos WHERE DATE(fecha_devolucion_real) = CURDATE();
    
    INSERT INTO logs_sistema (nivel, mensaje)
    VALUES ('INFO', CONCAT('Reporte diario - Préstamos: ', prestamos_hoy, ', Devoluciones: ', devoluciones_hoy, ', Multas: $', multas_hoy));
END //
DELIMITER ;
```

### 5. Sistema de Usuarios y Permisos

```sql
-- Crear usuarios del sistema
CREATE USER 'admin_biblioteca'@'localhost' IDENTIFIED BY 'admin_2024';
CREATE USER 'bibliotecario'@'localhost' IDENTIFIED BY 'biblio_2024';
CREATE USER 'lector'@'localhost' IDENTIFIED BY 'lector_2024';

-- Asignar permisos de administrador
GRANT ALL PRIVILEGES ON biblioteca_avanzada.* TO 'admin_biblioteca'@'localhost';

-- Asignar permisos de bibliotecario
GRANT SELECT, INSERT, UPDATE ON biblioteca_avanzada.* TO 'bibliotecario'@'localhost';
GRANT EXECUTE ON biblioteca_avanzada.* TO 'bibliotecario'@'localhost';

-- Asignar permisos de lector
GRANT SELECT ON biblioteca_avanzada.libros TO 'lector'@'localhost';
GRANT SELECT ON biblioteca_avanzada.prestamos TO 'lector'@'localhost';
GRANT EXECUTE ON PROCEDURE biblioteca_avanzada.ObtenerEstadisticasPrestamos TO 'lector'@'localhost';
```

### 6. Sistema de Backup

```sql
-- Crear tabla de control de backups
CREATE TABLE control_backups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_backup VARCHAR(50),
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo_backup VARCHAR(255),
    tamaño_archivo BIGINT,
    estado VARCHAR(20) DEFAULT 'COMPLETADO'
);

-- Procedimiento para realizar backup
DELIMITER //
CREATE PROCEDURE RealizarBackupCompleto()
BEGIN
    DECLARE fecha_backup VARCHAR(20);
    SET fecha_backup = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');
    
    -- Insertar registro de backup
    INSERT INTO control_backups (tipo_backup, archivo_backup)
    VALUES ('COMPLETO', CONCAT('backup_biblioteca_', fecha_backup, '.sql'));
    
    INSERT INTO logs_sistema (nivel, mensaje)
    VALUES ('INFO', CONCAT('Backup completo iniciado: backup_biblioteca_', fecha_backup, '.sql'));
END //
DELIMITER ;
```

### 7. Sistema de Monitoreo

```sql
-- Crear tabla de métricas
CREATE TABLE metricas_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_metrica TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prestamos_activos INT,
    libros_disponibles INT,
    lectores_activos INT,
    multas_pendientes DECIMAL(10,2)
);

-- Procedimiento para recopilar métricas
DELIMITER //
CREATE PROCEDURE RecopilarMetricas()
BEGIN
    DECLARE prestamos_activos INT DEFAULT 0;
    DECLARE libros_disponibles INT DEFAULT 0;
    DECLARE lectores_activos INT DEFAULT 0;
    DECLARE multas_pendientes DECIMAL(10,2) DEFAULT 0.00;
    
    SELECT COUNT(*) INTO prestamos_activos
    FROM prestamos WHERE estado = 'ACTIVO';
    
    SELECT SUM(stock_disponible) INTO libros_disponibles
    FROM libros WHERE activo = TRUE;
    
    SELECT COUNT(*) INTO lectores_activos
    FROM lectores WHERE activo = TRUE;
    
    SELECT COALESCE(SUM(multa), 0) INTO multas_pendientes
    FROM prestamos WHERE multa > 0;
    
    INSERT INTO metricas_sistema (prestamos_activos, libros_disponibles, lectores_activos, multas_pendientes)
    VALUES (prestamos_activos, libros_disponibles, lectores_activos, multas_pendientes);
    
    INSERT INTO logs_sistema (nivel, mensaje)
    VALUES ('INFO', 'Métricas del sistema recopiladas');
END //
DELIMITER ;

-- Evento para recopilar métricas cada hora
DELIMITER //
CREATE EVENT evento_recopilar_metricas
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL RecopilarMetricas();
END //
DELIMITER ;
```

## 🎯 Ejercicios del Proyecto

### Ejercicio 1: Configuración Inicial
Implementa la estructura completa de la base de datos y configura los usuarios.

### Ejercicio 2: Procedimientos de Gestión
Crea procedimientos para todas las operaciones de la biblioteca.

### Ejercicio 3: Sistema de Auditoría
Implementa triggers para auditar todos los cambios importantes.

### Ejercicio 4: Automatización
Configura eventos para mantenimiento automático del sistema.

### Ejercicio 5: Seguridad
Establece políticas de seguridad y permisos de usuarios.

### Ejercicio 6: Backup y Recuperación
Implementa sistema de backup automático y recuperación.

### Ejercicio 7: Monitoreo
Crea sistema de monitoreo y alertas del sistema.

### Ejercicio 8: Reportes
Implementa procedimientos para generar reportes del sistema.

### Ejercicio 9: Optimización
Aplica técnicas de optimización y análisis de rendimiento.

### Ejercicio 10: Pruebas Integrales
Realiza pruebas completas del sistema implementado.

## 📝 Resumen del Proyecto

En este proyecto integrador has implementado:

- **Sistema completo de gestión de biblioteca** con todas las funcionalidades
- **Transacciones** para mantener integridad de datos
- **Procedimientos almacenados** para lógica de negocio
- **Funciones personalizadas** para cálculos y validaciones
- **Triggers** para auditoría y automatización
- **Eventos programados** para mantenimiento automático
- **Sistema de usuarios** con permisos granulares
- **Backup y recuperación** automatizados
- **Monitoreo** y métricas del sistema

## 🔗 Próximos Pasos

- [Módulo 4: Diseño de Bases de Datos](../junior_4/README.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado el Módulo 3: Bases de Datos Avanzadas!** 🎉 

Has dominado conceptos avanzados de bases de datos y estás listo para continuar con el siguiente módulo del curso.
