# Clase 10: Proyecto Integrador - Sistema de Análisis de Rendimiento

## Objetivos de la Clase
- Integrar todas las técnicas aprendidas en el módulo
- Implementar un sistema completo de análisis de rendimiento
- Aplicar optimizaciones avanzadas en un proyecto real
- Crear un sistema de monitoreo y automatización completo

## 1. Descripción del Proyecto

### Sistema de Análisis de Rendimiento Empresarial
Vamos a crear un sistema completo que integre todas las técnicas aprendidas en el módulo para analizar el rendimiento de una empresa de e-commerce, incluyendo:

- **Análisis de Ventas**: Tendencias, estacionalidad, crecimiento
- **Análisis de Clientes**: Segmentación RFM, cohortes, retención
- **Análisis de Productos**: Rendimiento, correlaciones, predicciones
- **Monitoreo de Rendimiento**: Métricas en tiempo real
- **Automatización**: Tareas de mantenimiento y reportes

## 2. Estructura de la Base de Datos

### Tablas Principales
```sql
-- Crear base de datos del proyecto
CREATE DATABASE sistema_analisis_rendimiento;
USE sistema_analisis_rendimiento;

-- Tabla de clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    fecha_registro DATE NOT NULL,
    ciudad VARCHAR(50),
    pais VARCHAR(50),
    segmento ENUM('Bronce', 'Plata', 'Oro', 'Platino') DEFAULT 'Bronce',
    INDEX idx_fecha_registro (fecha_registro),
    INDEX idx_segmento (segmento)
);

-- Tabla de categorías
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    INDEX idx_nombre (nombre)
);

-- Tabla de productos
CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria_id INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    fecha_creacion DATE NOT NULL,
    estado ENUM('activo', 'inactivo', 'descontinuado') DEFAULT 'activo',
    FOREIGN KEY (categoria_id) REFERENCES categorias(id),
    INDEX idx_categoria (categoria_id),
    INDEX idx_precio (precio),
    INDEX idx_estado (estado),
    INDEX idx_fecha_creacion (fecha_creacion)
);

-- Tabla de ventas (particionada por fecha)
CREATE TABLE ventas (
    id INT AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    monto_total DECIMAL(10,2) NOT NULL,
    canal_venta ENUM('online', 'tienda', 'telefono') DEFAULT 'online',
    PRIMARY KEY (id, fecha),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    INDEX idx_cliente_fecha (cliente_id, fecha),
    INDEX idx_producto_fecha (producto_id, fecha),
    INDEX idx_fecha (fecha),
    INDEX idx_canal (canal_venta)
) PARTITION BY RANGE (YEAR(fecha)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);
```

### Tablas de Análisis y Monitoreo
```sql
-- Tabla de métricas de rendimiento
CREATE TABLE metricas_rendimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha TIMESTAMP NOT NULL,
    total_ventas INT NOT NULL,
    monto_total DECIMAL(15,2) NOT NULL,
    clientes_activos INT NOT NULL,
    productos_vendidos INT NOT NULL,
    ticket_promedio DECIMAL(10,2) NOT NULL,
    conversion_rate DECIMAL(5,2) NOT NULL,
    INDEX idx_fecha (fecha)
);

-- Tabla de análisis de cohortes
CREATE TABLE analisis_cohortes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cohorte VARCHAR(7) NOT NULL, -- YYYY-MM
    mes_desde_registro INT NOT NULL,
    clientes_activos INT NOT NULL,
    tasa_retencion DECIMAL(5,2) NOT NULL,
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_cohorte (cohorte),
    INDEX idx_mes (mes_desde_registro)
);

-- Tabla de análisis RFM
CREATE TABLE analisis_rfm (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    recency INT NOT NULL,
    frequency INT NOT NULL,
    monetary DECIMAL(10,2) NOT NULL,
    r_score INT NOT NULL,
    f_score INT NOT NULL,
    m_score INT NOT NULL,
    rfm_score VARCHAR(3) NOT NULL,
    segmento VARCHAR(50) NOT NULL,
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    INDEX idx_cliente (cliente_id),
    INDEX idx_segmento (segmento),
    INDEX idx_fecha_calculo (fecha_calculo)
);

-- Tabla de alertas del sistema
CREATE TABLE alertas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('RENDIMIENTO', 'ERROR', 'ADVERTENCIA', 'INFO') NOT NULL,
    severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA') NOT NULL,
    mensaje TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelta BOOLEAN DEFAULT FALSE,
    INDEX idx_tipo (tipo),
    INDEX idx_severidad (severidad),
    INDEX idx_fecha (fecha),
    INDEX idx_resuelta (resuelta)
);

-- Tabla de logs de automatización
CREATE TABLE log_automatizacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    procedimiento VARCHAR(100) NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    estado ENUM('EXITOSO', 'ERROR', 'EN_PROGRESO') NOT NULL,
    mensaje TEXT,
    duracion_segundos INT,
    INDEX idx_procedimiento (procedimiento),
    INDEX idx_fecha_inicio (fecha_inicio),
    INDEX idx_estado (estado)
);
```

## 3. Procedimientos de Análisis Avanzado

### Análisis de Tendencias de Ventas
```sql
DELIMITER //
CREATE PROCEDURE AnalizarTendenciasVentas()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('ERROR', 'ALTA', 'Error en análisis de tendencias de ventas');
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Análisis de tendencias mensuales
    INSERT INTO metricas_rendimiento (
        fecha,
        total_ventas,
        monto_total,
        clientes_activos,
        productos_vendidos,
        ticket_promedio,
        conversion_rate
    )
    SELECT 
        DATE_FORMAT(fecha, '%Y-%m-01') AS fecha,
        COUNT(*) AS total_ventas,
        SUM(monto_total) AS monto_total,
        COUNT(DISTINCT cliente_id) AS clientes_activos,
        COUNT(DISTINCT producto_id) AS productos_vendidos,
        AVG(monto_total) AS ticket_promedio,
        (COUNT(DISTINCT cliente_id) * 100.0 / 
         (SELECT COUNT(*) FROM clientes WHERE DATE_FORMAT(fecha_registro, '%Y-%m') = DATE_FORMAT(v.fecha, '%Y-%m'))) AS conversion_rate
    FROM ventas v
    WHERE fecha >= DATE_SUB(CURRENT_DATE, INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(fecha, '%Y-%m')
    ON DUPLICATE KEY UPDATE
        total_ventas = VALUES(total_ventas),
        monto_total = VALUES(monto_total),
        clientes_activos = VALUES(clientes_activos),
        productos_vendidos = VALUES(productos_vendidos),
        ticket_promedio = VALUES(ticket_promedio),
        conversion_rate = VALUES(conversion_rate);
    
    COMMIT;
END //
DELIMITER ;
```

### Análisis de Cohortes de Clientes
```sql
DELIMITER //
CREATE PROCEDURE AnalizarCohortesClientes()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('ERROR', 'ALTA', 'Error en análisis de cohortes');
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Limpiar análisis anterior
    DELETE FROM analisis_cohortes 
    WHERE fecha_calculo < DATE_SUB(NOW(), INTERVAL 1 DAY);
    
    -- Análisis de cohortes
    INSERT INTO analisis_cohortes (cohorte, mes_desde_registro, clientes_activos, tasa_retencion)
    WITH primera_compra AS (
        SELECT 
            cliente_id,
            MIN(DATE(fecha)) AS primera_fecha
        FROM ventas
        GROUP BY cliente_id
    ),
    cohortes AS (
        SELECT 
            cliente_id,
            primera_fecha,
            DATE_FORMAT(primera_fecha, '%Y-%m') AS cohorte
        FROM primera_compra
    ),
    compras_cohorte AS (
        SELECT 
            c.cohorte,
            v.fecha,
            c.cliente_id,
            TIMESTAMPDIFF(MONTH, c.primera_fecha, v.fecha) AS mes_desde_registro
        FROM cohortes c
        JOIN ventas v ON c.cliente_id = v.cliente_id
    )
    SELECT 
        cohorte,
        mes_desde_registro,
        COUNT(DISTINCT cliente_id) AS clientes_activos,
        ROUND(
            COUNT(DISTINCT cliente_id) * 100.0 / 
            (SELECT COUNT(DISTINCT cliente_id) FROM cohortes WHERE cohorte = cc.cohorte), 2
        ) AS tasa_retencion
    FROM compras_cohorte cc
    GROUP BY cohorte, mes_desde_registro
    ORDER BY cohorte, mes_desde_registro;
    
    COMMIT;
END //
DELIMITER ;
```

### Análisis RFM de Clientes
```sql
DELIMITER //
CREATE PROCEDURE AnalizarRFMClientes()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('ERROR', 'ALTA', 'Error en análisis RFM');
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Limpiar análisis anterior
    DELETE FROM analisis_rfm 
    WHERE fecha_calculo < DATE_SUB(NOW(), INTERVAL 1 DAY);
    
    -- Análisis RFM
    INSERT INTO analisis_rfm (
        cliente_id, recency, frequency, monetary, 
        r_score, f_score, m_score, rfm_score, segmento
    )
    WITH metricas_rfm AS (
        SELECT 
            cliente_id,
            DATEDIFF(CURRENT_DATE, MAX(DATE(fecha))) AS recency,
            COUNT(*) AS frequency,
            SUM(monto_total) AS monetary
        FROM ventas
        GROUP BY cliente_id
    ),
    percentiles_rfm AS (
        SELECT 
            cliente_id,
            recency,
            frequency,
            monetary,
            NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
            NTILE(5) OVER (ORDER BY frequency) AS f_score,
            NTILE(5) OVER (ORDER BY monetary) AS m_score
        FROM metricas_rfm
    )
    SELECT 
        cliente_id,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CONCAT(r_score, f_score, m_score) AS rfm_score,
        CASE 
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Campeones'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Leales'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'Nuevos'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'En Riesgo'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Perdidos'
            ELSE 'Otros'
        END AS segmento
    FROM percentiles_rfm;
    
    COMMIT;
END //
DELIMITER ;
```

## 4. Sistema de Monitoreo Automatizado

### Procedimiento de Monitoreo Completo
```sql
DELIMITER //
CREATE PROCEDURE MonitoreoCompleto()
BEGIN
    DECLARE total_consultas INT DEFAULT 0;
    DECLARE consultas_lentas INT DEFAULT 0;
    DECLARE hit_ratio_buffer DECIMAL(5,2) DEFAULT 0;
    DECLARE conexiones_activas INT DEFAULT 0;
    DECLARE espacio_libre DECIMAL(10,2) DEFAULT 0;
    
    -- Obtener métricas del sistema
    SELECT VARIABLE_VALUE INTO total_consultas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Questions';
    
    SELECT VARIABLE_VALUE INTO consultas_lentas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Slow_queries';
    
    SELECT VARIABLE_VALUE INTO conexiones_activas
    FROM information_schema.GLOBAL_STATUS
    WHERE VARIABLE_NAME = 'Threads_connected';
    
    -- Calcular hit ratio del buffer pool
    SELECT 
        (1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)) * 100 
        INTO hit_ratio_buffer
    FROM (
        SELECT 
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') AS Innodb_buffer_pool_reads,
            (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests') AS Innodb_buffer_pool_read_requests
    ) AS stats;
    
    -- Generar alertas basadas en métricas
    IF hit_ratio_buffer < 95 THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('RENDIMIENTO', 'ALTA', 'Buffer pool hit ratio bajo: ' || hit_ratio_buffer);
    END IF;
    
    IF consultas_lentas > 100 THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('RENDIMIENTO', 'ALTA', 'Muchas consultas lentas: ' || consultas_lentas);
    END IF;
    
    IF conexiones_activas > 150 THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('RENDIMIENTO', 'MEDIA', 'Muchas conexiones activas: ' || conexiones_activas);
    END IF;
    
    -- Log de monitoreo
    INSERT INTO log_automatizacion (procedimiento, fecha_inicio, estado, mensaje)
    VALUES ('MonitoreoCompleto', NOW(), 'EXITOSO', 
            CONCAT('Consultas: ', total_consultas, ', Lentas: ', consultas_lentas, ', Hit Ratio: ', hit_ratio_buffer));
END //
DELIMITER ;
```

### Procedimiento de Mantenimiento Automático
```sql
DELIMITER //
CREATE PROCEDURE MantenimientoAutomatico()
BEGIN
    DECLARE fecha_inicio TIMESTAMP DEFAULT NOW();
    DECLARE fecha_fin TIMESTAMP;
    DECLARE duracion INT;
    
    -- Log de inicio
    INSERT INTO log_automatizacion (procedimiento, fecha_inicio, estado)
    VALUES ('MantenimientoAutomatico', fecha_inicio, 'EN_PROGRESO');
    
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            SET fecha_fin = NOW();
            SET duracion = TIMESTAMPDIFF(SECOND, fecha_inicio, fecha_fin);
            
            UPDATE log_automatizacion 
            SET fecha_fin = fecha_fin,
                estado = 'ERROR',
                duracion_segundos = duracion,
                mensaje = 'Error en mantenimiento automático'
            WHERE procedimiento = 'MantenimientoAutomatico' 
                AND fecha_inicio = fecha_inicio;
            
            INSERT INTO alertas_sistema (tipo, severidad, mensaje)
            VALUES ('ERROR', 'ALTA', 'Error en mantenimiento automático');
        END;
        
        -- 1. Analizar tablas
        ANALYZE TABLE clientes, productos, ventas, categorias;
        
        -- 2. Optimizar tablas grandes
        OPTIMIZE TABLE ventas;
        
        -- 3. Limpiar cache
        FLUSH QUERY CACHE;
        
        -- 4. Ejecutar análisis
        CALL AnalizarTendenciasVentas();
        CALL AnalizarCohortesClientes();
        CALL AnalizarRFMClientes();
        
        -- 5. Limpiar datos antiguos
        DELETE FROM log_automatizacion 
        WHERE fecha_inicio < DATE_SUB(NOW(), INTERVAL 30 DAY);
        
        DELETE FROM alertas_sistema 
        WHERE fecha < DATE_SUB(NOW(), INTERVAL 7 DAY) 
            AND resuelta = TRUE;
        
        -- Log de éxito
        SET fecha_fin = NOW();
        SET duracion = TIMESTAMPDIFF(SECOND, fecha_inicio, fecha_fin);
        
        UPDATE log_automatizacion 
        SET fecha_fin = fecha_fin,
            estado = 'EXITOSO',
            duracion_segundos = duracion,
            mensaje = 'Mantenimiento completado exitosamente'
        WHERE procedimiento = 'MantenimientoAutomatico' 
            AND fecha_inicio = fecha_inicio;
    END;
END //
DELIMITER ;
```

## 5. Vistas Materializadas para Reportes

### Vista de Resumen de Ventas
```sql
-- Crear vista materializada para resumen de ventas
CREATE TABLE resumen_ventas_mensual AS
SELECT 
    DATE_FORMAT(fecha, '%Y-%m') AS mes,
    COUNT(*) AS total_ventas,
    SUM(monto_total) AS monto_total,
    AVG(monto_total) AS ticket_promedio,
    COUNT(DISTINCT cliente_id) AS clientes_unicos,
    COUNT(DISTINCT producto_id) AS productos_vendidos,
    SUM(cantidad) AS unidades_vendidas
FROM ventas
GROUP BY DATE_FORMAT(fecha, '%Y-%m');

-- Crear índice en la vista materializada
CREATE INDEX idx_resumen_mes ON resumen_ventas_mensual(mes);
```

### Vista de Análisis de Productos
```sql
-- Crear vista materializada para análisis de productos
CREATE TABLE analisis_productos AS
SELECT 
    p.id,
    p.nombre,
    c.nombre AS categoria,
    p.precio,
    COUNT(v.id) AS total_ventas,
    SUM(v.monto_total) AS monto_total,
    AVG(v.monto_total) AS ticket_promedio,
    SUM(v.cantidad) AS unidades_vendidas,
    COUNT(DISTINCT v.cliente_id) AS clientes_unicos
FROM productos p
LEFT JOIN ventas v ON p.id = v.producto_id
LEFT JOIN categorias c ON p.categoria_id = c.id
GROUP BY p.id, p.nombre, c.nombre, p.precio;

-- Crear índices
CREATE INDEX idx_analisis_categoria ON analisis_productos(categoria);
CREATE INDEX idx_analisis_ventas ON analisis_productos(total_ventas);
CREATE INDEX idx_analisis_monto ON analisis_productos(monto_total);
```

## 6. Eventos Automatizados

### Eventos de Mantenimiento
```sql
-- Evento para mantenimiento diario
CREATE EVENT mantenimiento_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 02:00:00'
DO
BEGIN
    CALL MantenimientoAutomatico();
END;

-- Evento para monitoreo cada 5 minutos
CREATE EVENT monitoreo_continuo
ON SCHEDULE EVERY 5 MINUTE
STARTS '2024-01-01 00:00:00'
DO
BEGIN
    CALL MonitoreoCompleto();
END;

-- Evento para análisis semanal
CREATE EVENT analisis_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2024-01-01 03:00:00'
DO
BEGIN
    CALL AnalizarTendenciasVentas();
    CALL AnalizarCohortesClientes();
    CALL AnalizarRFMClientes();
END;
```

## 7. Consultas de Análisis Avanzado

### Dashboard de Rendimiento
```sql
-- Consulta para dashboard de rendimiento
SELECT 
    'Ventas del Mes' AS metrica,
    COUNT(*) AS valor,
    'ventas' AS unidad
FROM ventas
WHERE DATE_FORMAT(fecha, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m')

UNION ALL

SELECT 
    'Monto Total del Mes' AS metrica,
    SUM(monto_total) AS valor,
    'USD' AS unidad
FROM ventas
WHERE DATE_FORMAT(fecha, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m')

UNION ALL

SELECT 
    'Clientes Activos' AS metrica,
    COUNT(DISTINCT cliente_id) AS valor,
    'clientes' AS unidad
FROM ventas
WHERE DATE_FORMAT(fecha, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m')

UNION ALL

SELECT 
    'Ticket Promedio' AS metrica,
    AVG(monto_total) AS valor,
    'USD' AS unidad
FROM ventas
WHERE DATE_FORMAT(fecha, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m');
```

### Análisis de Tendencias
```sql
-- Análisis de tendencias con crecimiento
WITH ventas_mensuales AS (
    SELECT 
        DATE_FORMAT(fecha, '%Y-%m') AS mes,
        COUNT(*) AS total_ventas,
        SUM(monto_total) AS monto_total
    FROM ventas
    WHERE fecha >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(fecha, '%Y-%m')
)
SELECT 
    mes,
    total_ventas,
    monto_total,
    LAG(total_ventas, 1) OVER (ORDER BY mes) AS ventas_mes_anterior,
    LAG(monto_total, 1) OVER (ORDER BY mes) AS monto_mes_anterior,
    ROUND(
        (total_ventas - LAG(total_ventas, 1) OVER (ORDER BY mes)) 
        / LAG(total_ventas, 1) OVER (ORDER BY mes) * 100, 2
    ) AS crecimiento_ventas_porcentual,
    ROUND(
        (monto_total - LAG(monto_total, 1) OVER (ORDER BY mes)) 
        / LAG(monto_total, 1) OVER (ORDER BY mes) * 100, 2
    ) AS crecimiento_monto_porcentual
FROM ventas_mensuales
ORDER BY mes;
```

## 8. Sistema de Alertas Inteligentes

### Procedimiento de Alertas Inteligentes
```sql
DELIMITER //
CREATE PROCEDURE VerificarAlertasInteligentes()
BEGIN
    DECLARE ventas_hoy INT DEFAULT 0;
    DECLARE ventas_ayer INT DEFAULT 0;
    DECLARE clientes_nuevos_hoy INT DEFAULT 0;
    DECLARE clientes_nuevos_ayer INT DEFAULT 0;
    
    -- Obtener métricas del día
    SELECT COUNT(*) INTO ventas_hoy
    FROM ventas
    WHERE DATE(fecha) = CURDATE();
    
    SELECT COUNT(*) INTO ventas_ayer
    FROM ventas
    WHERE DATE(fecha) = DATE_SUB(CURDATE(), INTERVAL 1 DAY);
    
    SELECT COUNT(*) INTO clientes_nuevos_hoy
    FROM clientes
    WHERE DATE(fecha_registro) = CURDATE();
    
    SELECT COUNT(*) INTO clientes_nuevos_ayer
    FROM clientes
    WHERE DATE(fecha_registro) = DATE_SUB(CURDATE(), INTERVAL 1 DAY);
    
    -- Alertas de rendimiento
    IF ventas_hoy < (ventas_ayer * 0.8) THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('RENDIMIENTO', 'ALTA', 
                CONCAT('Ventas del día bajaron significativamente: ', ventas_hoy, ' vs ', ventas_ayer));
    END IF;
    
    IF clientes_nuevos_hoy < (clientes_nuevos_ayer * 0.5) THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('RENDIMIENTO', 'MEDIA', 
                CONCAT('Registro de clientes bajó: ', clientes_nuevos_hoy, ' vs ', clientes_nuevos_ayer));
    END IF;
    
    -- Alertas de productos
    IF EXISTS (
        SELECT 1 FROM productos 
        WHERE stock < 10 AND estado = 'activo'
    ) THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('INVENTARIO', 'MEDIA', 'Algunos productos tienen stock bajo');
    END IF;
END //
DELIMITER ;
```

## 9. Reportes Automatizados

### Procedimiento de Generación de Reportes
```sql
DELIMITER //
CREATE PROCEDURE GenerarReportesDiarios()
BEGIN
    DECLARE fecha_reporte DATE DEFAULT CURDATE();
    
    -- Reporte de ventas del día
    INSERT INTO reportes_diarios (
        fecha,
        total_ventas,
        monto_total,
        clientes_activos,
        productos_vendidos,
        ticket_promedio
    )
    SELECT 
        fecha_reporte,
        COUNT(*) AS total_ventas,
        SUM(monto_total) AS monto_total,
        COUNT(DISTINCT cliente_id) AS clientes_activos,
        COUNT(DISTINCT producto_id) AS productos_vendidos,
        AVG(monto_total) AS ticket_promedio
    FROM ventas
    WHERE DATE(fecha) = fecha_reporte;
    
    -- Reporte por categoría
    INSERT INTO reportes_categorias_diarios (
        fecha,
        categoria,
        total_ventas,
        monto_total
    )
    SELECT 
        fecha_reporte,
        c.nombre AS categoria,
        COUNT(*) AS total_ventas,
        SUM(v.monto_total) AS monto_total
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    JOIN categorias c ON p.categoria_id = c.id
    WHERE DATE(v.fecha) = fecha_reporte
    GROUP BY c.nombre;
    
    -- Log de generación de reportes
    INSERT INTO log_automatizacion (procedimiento, fecha_inicio, estado, mensaje)
    VALUES ('GenerarReportesDiarios', NOW(), 'EXITOSO', 'Reportes diarios generados');
END //
DELIMITER ;
```

## 10. Monitoreo y Mantenimiento del Sistema

### Procedimiento de Salud del Sistema
```sql
DELIMITER //
CREATE PROCEDURE VerificarSaludSistema()
BEGIN
    DECLARE total_alertas INT DEFAULT 0;
    DECLARE alertas_criticas INT DEFAULT 0;
    DECLARE ultimo_mantenimiento TIMESTAMP;
    DECLARE dias_sin_mantenimiento INT DEFAULT 0;
    
    -- Contar alertas
    SELECT COUNT(*) INTO total_alertas
    FROM alertas_sistema
    WHERE fecha >= DATE_SUB(NOW(), INTERVAL 24 HOUR);
    
    SELECT COUNT(*) INTO alertas_criticas
    FROM alertas_sistema
    WHERE fecha >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
        AND severidad = 'CRITICA';
    
    -- Verificar último mantenimiento
    SELECT MAX(fecha_inicio) INTO ultimo_mantenimiento
    FROM log_automatizacion
    WHERE procedimiento = 'MantenimientoAutomatico'
        AND estado = 'EXITOSO';
    
    SET dias_sin_mantenimiento = DATEDIFF(NOW(), ultimo_mantenimiento);
    
    -- Generar alertas de salud del sistema
    IF alertas_criticas > 0 THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('SISTEMA', 'CRITICA', 
                CONCAT('Sistema con ', alertas_criticas, ' alertas críticas en las últimas 24 horas'));
    END IF;
    
    IF dias_sin_mantenimiento > 2 THEN
        INSERT INTO alertas_sistema (tipo, severidad, mensaje)
        VALUES ('SISTEMA', 'ALTA', 
                CONCAT('Sistema sin mantenimiento por ', dias_sin_mantenimiento, ' días'));
    END IF;
    
    -- Log de verificación de salud
    INSERT INTO log_automatizacion (procedimiento, fecha_inicio, estado, mensaje)
    VALUES ('VerificarSaludSistema', NOW(), 'EXITOSO', 
            CONCAT('Alertas: ', total_alertas, ', Críticas: ', alertas_criticas));
END //
DELIMITER ;
```

## Ejercicios Prácticos del Proyecto

### Ejercicio 1: Implementar el Sistema Completo
```sql
-- 1. Crear la base de datos y tablas
CREATE DATABASE sistema_analisis_rendimiento;
USE sistema_analisis_rendimiento;

-- Crear todas las tablas del sistema
-- (Ejecutar todos los CREATE TABLE del proyecto)

-- 2. Insertar datos de prueba
INSERT INTO categorias (nombre, descripcion) VALUES
('Electrónicos', 'Dispositivos electrónicos y tecnología'),
('Ropa', 'Vestimenta y accesorios'),
('Hogar', 'Artículos para el hogar'),
('Deportes', 'Equipos y accesorios deportivos');

INSERT INTO clientes (nombre, email, fecha_registro, ciudad, pais) VALUES
('Juan Pérez', 'juan@email.com', '2023-01-15', 'Madrid', 'España'),
('María García', 'maria@email.com', '2023-02-20', 'Barcelona', 'España'),
('Carlos López', 'carlos@email.com', '2023-03-10', 'Valencia', 'España');

INSERT INTO productos (nombre, categoria_id, precio, costo, stock, fecha_creacion) VALUES
('Smartphone', 1, 500.00, 300.00, 50, '2023-01-01'),
('Laptop', 1, 1200.00, 800.00, 25, '2023-01-01'),
('Camiseta', 2, 25.00, 15.00, 100, '2023-01-01');
```

### Ejercicio 2: Ejecutar Análisis Inicial
```sql
-- Ejecutar análisis inicial del sistema
CALL AnalizarTendenciasVentas();
CALL AnalizarCohortesClientes();
CALL AnalizarRFMClientes();
CALL MonitoreoCompleto();
```

### Ejercicio 3: Configurar Automatización
```sql
-- Habilitar event scheduler
SET GLOBAL event_scheduler = ON;

-- Crear eventos de automatización
CREATE EVENT mantenimiento_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2024-01-01 02:00:00'
DO
BEGIN
    CALL MantenimientoAutomatico();
END;

CREATE EVENT monitoreo_continuo
ON SCHEDULE EVERY 5 MINUTE
STARTS '2024-01-01 00:00:00'
DO
BEGIN
    CALL MonitoreoCompleto();
END;
```

### Ejercicio 4: Generar Reportes
```sql
-- Generar reportes del sistema
CALL GenerarReportesDiarios();

-- Ver reportes generados
SELECT * FROM reportes_diarios ORDER BY fecha DESC LIMIT 10;
SELECT * FROM reportes_categorias_diarios ORDER BY fecha DESC LIMIT 10;
```

### Ejercicio 5: Monitorear Alertas
```sql
-- Verificar alertas del sistema
SELECT * FROM alertas_sistema 
WHERE fecha >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY fecha DESC;

-- Verificar salud del sistema
CALL VerificarSaludSistema();
```

### Ejercicio 6: Análisis de Rendimiento
```sql
-- Dashboard de rendimiento
SELECT 
    'Ventas del Mes' AS metrica,
    COUNT(*) AS valor,
    'ventas' AS unidad
FROM ventas
WHERE DATE_FORMAT(fecha, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m')

UNION ALL

SELECT 
    'Monto Total del Mes' AS metrica,
    SUM(monto_total) AS valor,
    'USD' AS unidad
FROM ventas
WHERE DATE_FORMAT(fecha, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m');
```

### Ejercicio 7: Análisis de Tendencias
```sql
-- Análisis de tendencias con crecimiento
WITH ventas_mensuales AS (
    SELECT 
        DATE_FORMAT(fecha, '%Y-%m') AS mes,
        COUNT(*) AS total_ventas,
        SUM(monto_total) AS monto_total
    FROM ventas
    WHERE fecha >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(fecha, '%Y-%m')
)
SELECT 
    mes,
    total_ventas,
    monto_total,
    ROUND(
        (total_ventas - LAG(total_ventas, 1) OVER (ORDER BY mes)) 
        / LAG(total_ventas, 1) OVER (ORDER BY mes) * 100, 2
    ) AS crecimiento_ventas_porcentual
FROM ventas_mensuales
ORDER BY mes;
```

### Ejercicio 8: Análisis de Clientes
```sql
-- Análisis de segmentación RFM
SELECT 
    segmento,
    COUNT(*) AS total_clientes,
    AVG(monetary) AS monto_promedio,
    AVG(frequency) AS frecuencia_promedio,
    AVG(recency) AS recencia_promedio
FROM analisis_rfm
GROUP BY segmento
ORDER BY total_clientes DESC;
```

### Ejercicio 9: Análisis de Productos
```sql
-- Top productos por rendimiento
SELECT 
    nombre,
    categoria,
    total_ventas,
    monto_total,
    unidades_vendidas,
    clientes_unicos
FROM analisis_productos
ORDER BY monto_total DESC
LIMIT 10;
```

### Ejercicio 10: Monitoreo del Sistema
```sql
-- Verificar logs de automatización
SELECT 
    procedimiento,
    fecha_inicio,
    estado,
    duracion_segundos,
    mensaje
FROM log_automatizacion
ORDER BY fecha_inicio DESC
LIMIT 20;

-- Verificar métricas de rendimiento
SELECT 
    fecha,
    total_ventas,
    monto_total,
    clientes_activos,
    ticket_promedio
FROM metricas_rendimiento
ORDER BY fecha DESC
LIMIT 10;
```

## Resumen del Proyecto

En este proyecto integrador hemos implementado:

1. **Sistema de Base de Datos**: Estructura completa con particionamiento
2. **Análisis Avanzado**: Tendencias, cohortes, RFM, correlaciones
3. **Monitoreo Automatizado**: Métricas en tiempo real y alertas
4. **Automatización**: Eventos, procedimientos y mantenimiento automático
5. **Reportes**: Generación automática de reportes y dashboards
6. **Optimización**: Índices, vistas materializadas, consultas optimizadas
7. **Alertas Inteligentes**: Sistema de alertas basado en métricas
8. **Mantenimiento**: Procedimientos de limpieza y optimización
9. **Escalabilidad**: Diseño para manejar grandes volúmenes de datos
10. **Monitoreo de Salud**: Verificación continua del estado del sistema

## Conclusiones del Módulo

Este módulo ha cubierto técnicas avanzadas de SQL y optimización:

- **Consultas Avanzadas**: Funciones analíticas, CTEs, subconsultas complejas
- **Optimización**: Índices, particionamiento, análisis de rendimiento
- **Monitoreo**: Profiling, métricas, alertas automáticas
- **Automatización**: Eventos, procedimientos, mantenimiento automático
- **Escalabilidad**: Consultas distribuidas, sharding, replicación

## Próximo Módulo
En el siguiente módulo exploraremos bases de datos NoSQL y técnicas avanzadas de almacenamiento de datos.

## Recursos Adicionales
- Documentación completa del proyecto
- Scripts de implementación
- Guías de mantenimiento
- Herramientas de monitoreo
