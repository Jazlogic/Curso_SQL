# Clase 6: Eventos Programados

## 📋 Descripción

En esta clase aprenderás sobre eventos programados en MySQL. Los eventos son tareas que se ejecutan automáticamente en horarios específicos, similares a los cron jobs en sistemas Unix. Son útiles para mantenimiento automático, limpieza de datos, generación de reportes y otras tareas programadas.

## 🎯 Objetivos de la Clase

- Comprender qué son los eventos programados
- Aprender a crear eventos con diferentes frecuencias
- Entender la sintaxis de programación de eventos
- Implementar eventos para mantenimiento automático
- Crear eventos para limpieza de datos
- Gestionar y monitorear eventos

## 📚 Conceptos Clave

### ¿Qué es un Evento Programado?

Un **evento programado** es una tarea que se ejecuta automáticamente en la base de datos en un momento específico o en intervalos regulares. Es similar a un cron job pero ejecutándose dentro del servidor MySQL.

### Características de los Eventos

- **Ejecución automática**: No requieren intervención manual
- **Programación flexible**: Pueden ejecutarse una vez o repetidamente
- **Integración**: Se ejecutan dentro del servidor MySQL
- **Monitoreo**: Pueden ser monitoreados y gestionados

### Usos Comunes de Eventos

- **Limpieza de datos**: Eliminar registros antiguos
- **Mantenimiento**: Optimización de tablas
- **Reportes**: Generación automática de reportes
- **Backups**: Respaldos programados
- **Estadísticas**: Actualización de métricas
- **Notificaciones**: Envío de alertas

## 🔧 Sintaxis y Comandos

### Crear Evento

```sql
DELIMITER //

CREATE EVENT nombre_evento
ON SCHEDULE
    {AT timestamp | EVERY interval}
    [STARTS timestamp]
    [ENDS timestamp]
DO
BEGIN
    -- código del evento
END //

DELIMITER ;
```

### Gestionar Eventos

```sql
-- Ver eventos existentes
SHOW EVENTS;

-- Ver código de un evento
SHOW CREATE EVENT nombre_evento;

-- Habilitar/deshabilitar evento
ALTER EVENT nombre_evento ENABLE;
ALTER EVENT nombre_evento DISABLE;

-- Eliminar un evento
DROP EVENT nombre_evento;
```

### Configurar Event Scheduler

```sql
-- Verificar si el event scheduler está habilitado
SHOW VARIABLES LIKE 'event_scheduler';

-- Habilitar el event scheduler
SET GLOBAL event_scheduler = ON;

-- Deshabilitar el event scheduler
SET GLOBAL event_scheduler = OFF;
```

## 📖 Ejemplos Prácticos

### Ejemplo 1: Evento de Limpieza Diaria

```sql
-- Crear tabla de logs para limpiar
CREATE TABLE logs_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mensaje TEXT,
    nivel VARCHAR(20),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO logs_sistema (mensaje, nivel) VALUES 
('Sistema iniciado', 'INFO'),
('Error de conexión', 'ERROR'),
('Usuario autenticado', 'INFO'),
('Operación completada', 'INFO');

-- Evento para limpiar logs antiguos diariamente
DELIMITER //

CREATE EVENT evento_limpiar_logs
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Eliminar logs más antiguos de 30 días
    DELETE FROM logs_sistema 
    WHERE fecha_creacion < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    -- Insertar log de limpieza
    INSERT INTO logs_sistema (mensaje, nivel) 
    VALUES ('Limpieza automática de logs ejecutada', 'INFO');
END //

DELIMITER ;

-- Verificar el evento
SHOW EVENTS;
```

**Explicación línea por línea:**

1. `CREATE EVENT evento_limpiar_logs` - Crea el evento con nombre
2. `ON SCHEDULE EVERY 1 DAY` - Programa el evento para ejecutarse cada día
3. `STARTS CURRENT_TIMESTAMP` - Inicia inmediatamente
4. `DELETE FROM logs_sistema WHERE fecha_creacion < DATE_SUB(NOW(), INTERVAL 30 DAY);` - Elimina logs antiguos
5. `INSERT INTO logs_sistema...` - Registra la ejecución del evento

### Ejemplo 2: Evento de Mantenimiento Semanal

```sql
-- Evento para optimizar tablas semanalmente
DELIMITER //

CREATE EVENT evento_mantenimiento_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-01-01 02:00:00'
DO
BEGIN
    -- Optimizar tabla de productos
    OPTIMIZE TABLE productos;
    
    -- Optimizar tabla de ventas
    OPTIMIZE TABLE ventas_detalle;
    
    -- Actualizar estadísticas
    ANALYZE TABLE productos;
    ANALYZE TABLE ventas_detalle;
    
    -- Insertar log de mantenimiento
    INSERT INTO logs_sistema (mensaje, nivel) 
    VALUES ('Mantenimiento semanal ejecutado', 'INFO');
END //

DELIMITER ;
```

### Ejemplo 3: Evento de Generación de Reportes

```sql
-- Crear tabla de reportes
CREATE TABLE reportes_diarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_reporte DATE,
    total_ventas DECIMAL(10,2),
    total_productos INT,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Evento para generar reporte diario
DELIMITER //

CREATE EVENT evento_reporte_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 23:59:00'
DO
BEGIN
    DECLARE total_ventas_dia DECIMAL(10,2) DEFAULT 0;
    DECLARE total_productos_dia INT DEFAULT 0;
    
    -- Calcular total de ventas del día
    SELECT COALESCE(SUM(total), 0) INTO total_ventas_dia
    FROM ventas_detalle
    WHERE DATE(fecha_venta) = CURDATE();
    
    -- Contar productos vendidos
    SELECT COALESCE(SUM(cantidad), 0) INTO total_productos_dia
    FROM ventas_detalle
    WHERE DATE(fecha_venta) = CURDATE();
    
    -- Insertar reporte
    INSERT INTO reportes_diarios (fecha_reporte, total_ventas, total_productos)
    VALUES (CURDATE(), total_ventas_dia, total_productos_dia);
    
    -- Log de generación
    INSERT INTO logs_sistema (mensaje, nivel) 
    VALUES (CONCAT('Reporte diario generado para ', CURDATE()), 'INFO');
END //

DELIMITER ;
```

### Ejemplo 4: Evento de Actualización de Estadísticas

```sql
-- Evento para actualizar estadísticas cada hora
DELIMITER //

CREATE EVENT evento_actualizar_estadisticas
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Actualizar estadísticas de productos
    UPDATE estadisticas_productos s
    JOIN (
        SELECT producto_id, SUM(cantidad) as total_vendido
        FROM ventas_detalle
        WHERE fecha_venta >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
        GROUP BY producto_id
    ) v ON s.producto_id = v.producto_id
    SET s.total_ventas = s.total_ventas + v.total_vendido;
    
    -- Log de actualización
    INSERT INTO logs_sistema (mensaje, nivel) 
    VALUES ('Estadísticas actualizadas', 'INFO');
END //

DELIMITER ;
```

### Ejemplo 5: Evento de Backup de Datos

```sql
-- Crear tabla de respaldos
CREATE TABLE respaldos_datos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_respaldo VARCHAR(50),
    fecha_respaldo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registros_respaldo INT,
    estado VARCHAR(20) DEFAULT 'COMPLETADO'
);

-- Evento para respaldar datos críticos
DELIMITER //

CREATE EVENT evento_respaldo_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 01:00:00'
DO
BEGIN
    DECLARE total_registros INT DEFAULT 0;
    
    -- Contar registros en productos
    SELECT COUNT(*) INTO total_registros FROM productos;
    
    -- Insertar registro de respaldo
    INSERT INTO respaldos_datos (tabla_respaldo, registros_respaldo)
    VALUES ('productos', total_registros);
    
    -- Log de respaldo
    INSERT INTO logs_sistema (mensaje, nivel) 
    VALUES (CONCAT('Respaldo de productos completado: ', total_registros, ' registros'), 'INFO');
END //

DELIMITER ;
```

### Ejemplo 6: Evento de Limpieza de Sesiones

```sql
-- Crear tabla de sesiones
CREATE TABLE sesiones_usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT,
    token VARCHAR(255),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP
);

-- Evento para limpiar sesiones expiradas
DELIMITER //

CREATE EVENT evento_limpiar_sesiones
ON SCHEDULE EVERY 15 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE sesiones_eliminadas INT DEFAULT 0;
    
    -- Eliminar sesiones expiradas
    DELETE FROM sesiones_usuarios 
    WHERE fecha_expiracion < NOW();
    
    -- Contar sesiones eliminadas
    SET sesiones_eliminadas = ROW_COUNT();
    
    -- Log si se eliminaron sesiones
    IF sesiones_eliminadas > 0 THEN
        INSERT INTO logs_sistema (mensaje, nivel) 
        VALUES (CONCAT('Sesiones expiradas eliminadas: ', sesiones_eliminadas), 'INFO');
    END IF;
END //

DELIMITER ;
```

### Ejemplo 7: Evento de Monitoreo de Rendimiento

```sql
-- Crear tabla de métricas de rendimiento
CREATE TABLE metricas_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_metrica TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    conexiones_activas INT,
    consultas_por_segundo DECIMAL(10,2),
    memoria_utilizada BIGINT
);

-- Evento para monitorear rendimiento
DELIMITER //

CREATE EVENT evento_monitoreo_rendimiento
ON SCHEDULE EVERY 5 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE conexiones INT DEFAULT 0;
    DECLARE consultas DECIMAL(10,2) DEFAULT 0;
    
    -- Obtener métricas del sistema
    SELECT COUNT(*) INTO conexiones FROM information_schema.PROCESSLIST;
    
    -- Insertar métricas
    INSERT INTO metricas_rendimiento (conexiones_activas, consultas_por_segundo)
    VALUES (conexiones, consultas);
    
    -- Log de monitoreo
    INSERT INTO logs_sistema (mensaje, nivel) 
    VALUES (CONCAT('Métricas de rendimiento registradas: ', conexiones, ' conexiones'), 'INFO');
END //

DELIMITER ;
```

### Ejemplo 8: Evento de Notificaciones

```sql
-- Crear tabla de notificaciones
CREATE TABLE notificaciones_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(50),
    mensaje TEXT,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leida BOOLEAN DEFAULT FALSE
);

-- Evento para verificar alertas
DELIMITER //

CREATE EVENT evento_verificar_alertas
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE productos_sin_stock INT DEFAULT 0;
    
    -- Contar productos sin stock
    SELECT COUNT(*) INTO productos_sin_stock
    FROM productos
    WHERE stock = 0;
    
    -- Crear notificación si hay productos sin stock
    IF productos_sin_stock > 0 THEN
        INSERT INTO notificaciones_sistema (tipo, mensaje)
        VALUES ('ALERTA', CONCAT('Hay ', productos_sin_stock, ' productos sin stock'));
    END IF;
    
    -- Log de verificación
    INSERT INTO logs_sistema (mensaje, nivel) 
    VALUES ('Verificación de alertas completada', 'INFO');
END //

DELIMITER ;
```

## 🎯 Ejercicios Prácticos

### Ejercicio 1: Evento de Limpieza de Datos
Crea un evento que elimine registros antiguos de una tabla de transacciones.

### Ejercicio 2: Evento de Mantenimiento
Implementa un evento que ejecute mantenimiento de base de datos semanalmente.

### Ejercicio 3: Evento de Generación de Reportes
Crea un evento que genere reportes mensuales automáticamente.

### Ejercicio 4: Evento de Actualización de Contadores
Implementa un evento que actualice contadores de uso cada hora.

### Ejercicio 5: Evento de Verificación de Integridad
Crea un evento que verifique la integridad de los datos diariamente.

### Ejercicio 6: Evento de Limpieza de Archivos Temporales
Implementa un evento que limpie archivos temporales cada 6 horas.

### Ejercicio 7: Evento de Actualización de Estadísticas
Crea un evento que actualice estadísticas de rendimiento cada 15 minutos.

### Ejercicio 8: Evento de Notificaciones de Sistema
Implementa un evento que envíe notificaciones de estado del sistema.

### Ejercicio 9: Evento de Respaldo Incremental
Crea un evento que realice respaldos incrementales cada 4 horas.

### Ejercicio 10: Evento Complejo
Implementa un evento que combine múltiples tareas de mantenimiento.

## 📝 Resumen

En esta clase has aprendido:

- **Eventos programados**: Tareas automáticas que se ejecutan en horarios específicos
- **Sintaxis básica**: CREATE EVENT, ON SCHEDULE, DO
- **Frecuencias**: AT, EVERY, STARTS, ENDS
- **Usos comunes**: Limpieza, mantenimiento, reportes, respaldos
- **Gestión**: Habilitar, deshabilitar, eliminar eventos
- **Monitoreo**: Verificar ejecución y logs

## 🔗 Próximos Pasos

- [Clase 7: Administración de Usuarios y Permisos](clase_7_usuarios_permisos.md)
- [Ejercicios Prácticos del Módulo](ejercicios_practicos.sql)

---

**¡Has completado la Clase 6!** 🎉 Continúa con la siguiente clase para aprender sobre administración de usuarios y permisos.
