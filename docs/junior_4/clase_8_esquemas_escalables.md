# Clase 8: Diseño de Esquemas Escalables

## Objetivos de la Clase
- Comprender los principios de escalabilidad en bases de datos
- Diseñar esquemas que soporten crecimiento
- Implementar estrategias de particionamiento
- Aplicar técnicas de optimización para grandes volúmenes

## Contenido Teórico

### 1. ¿Qué es la Escalabilidad?

**Escalabilidad** es la capacidad de un sistema de bases de datos para manejar un crecimiento en la cantidad de datos, usuarios y transacciones sin degradar significativamente el rendimiento.

#### Tipos de Escalabilidad:

##### Escalabilidad Vertical (Scale Up)
```sql
-- Aumentar recursos del servidor existente
-- Más CPU, RAM, almacenamiento
-- Limitado por la capacidad máxima del hardware
```

##### Escalabilidad Horizontal (Scale Out)
```sql
-- Agregar más servidores
-- Distribuir carga entre múltiples nodos
-- Requiere diseño específico de la base de datos
```

### 2. Principios de Diseño Escalable

#### Principio 1: Normalización vs Desnormalización
```sql
-- NORMALIZACIÓN: Para consistencia y mantenibilidad
-- DESNORMALIZACIÓN: Para rendimiento en consultas específicas

-- Ejemplo de desnormalización controlada
CREATE TABLE reportes_ventas_desnormalizado (
    id INT PRIMARY KEY,
    fecha_reporte DATE,
    total_ventas DECIMAL(12,2),
    numero_ventas INT,
    cliente_mas_frecuente VARCHAR(100),  -- Desnormalizado
    producto_mas_vendido VARCHAR(200),   -- Desnormalizado
    vendedor_top VARCHAR(100)            -- Desnormalizado
);
```

#### Principio 2: Separación de Lectura y Escritura
```sql
-- MASTER-SLAVE: Una base para escritura, múltiples para lectura
-- READ REPLICAS: Copias de solo lectura para consultas

-- Ejemplo de configuración
-- MASTER: Para INSERT, UPDATE, DELETE
-- SLAVE: Para SELECT, reportes, análisis
```

#### Principio 3: Caching Estratégico
```sql
-- Caché de consultas frecuentes
-- Caché de resultados de agregaciones
-- Caché de datos de referencia

-- Ejemplo de datos para caché
CREATE TABLE cache_consultas (
    consulta_hash VARCHAR(64) PRIMARY KEY,
    resultado JSON,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP
);
```

### 3. Estrategias de Particionamiento

#### Particionamiento Horizontal (Sharding)
```sql
-- Dividir datos por rangos, hash o directorio
-- Ejemplo: Usuarios por región geográfica

-- Tabla particionada por rango de fechas
CREATE TABLE ventas_particionada (
    id INT,
    fecha_venta DATE,
    cliente_id INT,
    total DECIMAL(10,2)
) PARTITION BY RANGE (YEAR(fecha_venta)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);
```

#### Particionamiento Vertical
```sql
-- Dividir columnas en tablas separadas
-- Ejemplo: Datos frecuentes vs datos históricos

-- Tabla principal (datos frecuentes)
CREATE TABLE usuarios_principal (
    id INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE
);

-- Tabla de perfil (datos menos frecuentes)
CREATE TABLE usuarios_perfil (
    usuario_id INT PRIMARY KEY,
    direccion TEXT,
    fecha_nacimiento DATE,
    biografia TEXT,
    preferencias JSON,
    FOREIGN KEY (usuario_id) REFERENCES usuarios_principal(id)
);
```

### 4. Técnicas de Optimización para Escalabilidad

#### Índices Estratégicos
```sql
-- Índices para consultas frecuentes
-- Índices compuestos para consultas complejas
-- Índices parciales para datos específicos

-- Ejemplo de índice parcial
CREATE INDEX idx_usuarios_activos ON usuarios(nombre) WHERE activo = TRUE;
```

#### Agregaciones Precalculadas
```sql
-- Tablas de resumen para reportes
CREATE TABLE resumen_ventas_diario (
    fecha DATE,
    total_ventas DECIMAL(12,2),
    numero_ventas INT,
    promedio_venta DECIMAL(10,2),
    PRIMARY KEY (fecha)
);

-- Actualizar con triggers o procesos ETL
```

#### Archivo de Datos Históricos
```sql
-- Mover datos antiguos a tablas de archivo
CREATE TABLE ventas_archivo (
    id INT,
    fecha_venta DATE,
    cliente_id INT,
    total DECIMAL(10,2),
    fecha_archivo TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Proceso para archivar datos antiguos
```

## Ejemplos Prácticos

### Ejemplo 1: Sistema de E-commerce Escalable

#### Estructura Base:
```sql
-- Crear base de datos escalable
CREATE DATABASE ecommerce_escalable;
USE ecommerce_escalable;

-- Tabla de clientes (datos principales)
CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro DATE DEFAULT (CURRENT_DATE),
    
    -- Índices para escalabilidad
    INDEX idx_clientes_email (email),
    INDEX idx_clientes_activo (activo),
    INDEX idx_clientes_fecha_registro (fecha_registro)
);

-- Tabla de perfiles de clientes (datos secundarios)
CREATE TABLE clientes_perfil (
    cliente_id INT PRIMARY KEY,
    direccion TEXT,
    ciudad VARCHAR(50),
    estado VARCHAR(50),
    codigo_postal VARCHAR(10),
    fecha_nacimiento DATE,
    preferencias JSON,
    
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- Tabla de productos (con particionamiento)
CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria_id INT,
    stock INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (categoria_id) (
    PARTITION p_electronicos VALUES LESS THAN (100),
    PARTITION p_hogar VALUES LESS THAN (200),
    PARTITION p_deportes VALUES LESS THAN (300),
    PARTITION p_otros VALUES LESS THAN MAXVALUE
);
```

### Ejemplo 2: Sistema de Logs Escalable

#### Estructura para Alto Volumen:
```sql
-- Crear sistema de logs escalable
CREATE DATABASE logs_escalable;
USE logs_escalable;

-- Tabla de logs particionada por fecha
CREATE TABLE logs_aplicacion (
    id BIGINT AUTO_INCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nivel ENUM('DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'),
    mensaje TEXT,
    usuario_id INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    PRIMARY KEY (id, timestamp)
) PARTITION BY RANGE (UNIX_TIMESTAMP(timestamp)) (
    PARTITION p_2024_01 VALUES LESS THAN (UNIX_TIMESTAMP('2024-02-01')),
    PARTITION p_2024_02 VALUES LESS THAN (UNIX_TIMESTAMP('2024-03-01')),
    PARTITION p_2024_03 VALUES LESS THAN (UNIX_TIMESTAMP('2024-04-01')),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- Tabla de resumen de logs
CREATE TABLE resumen_logs_diario (
    fecha DATE,
    nivel VARCHAR(10),
    total_logs INT,
    usuarios_unicos INT,
    PRIMARY KEY (fecha, nivel)
);
```

## Ejercicios Prácticos

### Ejercicio 1: Diseñar Esquema Escalable para Red Social
**Objetivo**: Crear esquema que soporte millones de usuarios.

```sql
-- Crear base de datos de red social escalable
CREATE DATABASE red_social_escalable;
USE red_social_escalable;

-- Tabla de usuarios (datos principales)
CREATE TABLE usuarios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Índices para escalabilidad
    INDEX idx_usuarios_username (username),
    INDEX idx_usuarios_email (email),
    INDEX idx_usuarios_activo (activo),
    INDEX idx_usuarios_ultima_actividad (ultima_actividad)
);

-- Tabla de perfiles (datos secundarios)
CREATE TABLE usuarios_perfil (
    usuario_id BIGINT PRIMARY KEY,
    biografia TEXT,
    ubicacion VARCHAR(100),
    fecha_nacimiento DATE,
    genero ENUM('M', 'F', 'Otro'),
    sitio_web VARCHAR(200),
    avatar_url VARCHAR(500),
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla de publicaciones (particionada por fecha)
CREATE TABLE publicaciones (
    id BIGINT AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    contenido TEXT NOT NULL,
    tipo ENUM('texto', 'imagen', 'video', 'enlace') DEFAULT 'texto',
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    likes_count INT DEFAULT 0,
    comentarios_count INT DEFAULT 0,
    compartidos_count INT DEFAULT 0,
    
    PRIMARY KEY (id, fecha_publicacion),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    -- Índices para consultas frecuentes
    INDEX idx_publicaciones_usuario (usuario_id),
    INDEX idx_publicaciones_fecha (fecha_publicacion),
    INDEX idx_publicaciones_likes (likes_count)
) PARTITION BY RANGE (UNIX_TIMESTAMP(fecha_publicacion)) (
    PARTITION p_2024_01 VALUES LESS THAN (UNIX_TIMESTAMP('2024-02-01')),
    PARTITION p_2024_02 VALUES LESS THAN (UNIX_TIMESTAMP('2024-03-01')),
    PARTITION p_2024_03 VALUES LESS THAN (UNIX_TIMESTAMP('2024-04-01')),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- Tabla de seguidores (optimizada para consultas)
CREATE TABLE seguidores (
    seguidor_id BIGINT,
    seguido_id BIGINT,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (seguidor_id, seguido_id),
    FOREIGN KEY (seguidor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (seguido_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    -- Índices para consultas bidireccionales
    INDEX idx_seguidores_seguido (seguido_id),
    INDEX idx_seguidores_fecha (fecha_seguimiento)
);

-- Tabla de likes (optimizada para alto volumen)
CREATE TABLE likes (
    id BIGINT AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    publicacion_id BIGINT NOT NULL,
    fecha_like TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    UNIQUE KEY uk_like_usuario_publicacion (usuario_id, publicacion_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    -- Índices para consultas frecuentes
    INDEX idx_likes_publicacion (publicacion_id),
    INDEX idx_likes_fecha (fecha_like)
);
```

### Ejercicio 2: Implementar Caching Estratégico
**Objetivo**: Crear sistema de caché para consultas frecuentes.

```sql
-- Crear sistema de caché
CREATE TABLE cache_consultas (
    consulta_hash VARCHAR(64) PRIMARY KEY,
    consulta_sql TEXT NOT NULL,
    resultado JSON NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    hits INT DEFAULT 0,
    
    INDEX idx_cache_expiracion (fecha_expiracion),
    INDEX idx_cache_hits (hits)
);

-- Tabla de estadísticas de caché
CREATE TABLE cache_estadisticas (
    fecha DATE,
    consultas_totales INT,
    hits_cache INT,
    misses_cache INT,
    porcentaje_hit DECIMAL(5,2),
    
    PRIMARY KEY (fecha)
);

-- Procedimiento para limpiar caché expirado
DELIMITER //
CREATE PROCEDURE limpiar_cache_expirado()
BEGIN
    DELETE FROM cache_consultas 
    WHERE fecha_expiracion < NOW();
    
    SELECT ROW_COUNT() AS registros_eliminados;
END//
DELIMITER ;

-- Procedimiento para obtener datos del caché
DELIMITER //
CREATE PROCEDURE obtener_datos_cache(
    IN consulta_sql TEXT,
    IN tiempo_expiracion_minutos INT
)
BEGIN
    DECLARE consulta_hash VARCHAR(64);
    DECLARE resultado_cache JSON;
    DECLARE fecha_expiracion TIMESTAMP;
    
    -- Generar hash de la consulta
    SET consulta_hash = SHA2(consulta_sql, 256);
    
    -- Buscar en caché
    SELECT resultado, fecha_expiracion INTO resultado_cache, fecha_expiracion
    FROM cache_consultas
    WHERE consulta_hash = consulta_hash
    AND fecha_expiracion > NOW();
    
    IF resultado_cache IS NOT NULL THEN
        -- Incrementar hits
        UPDATE cache_consultas 
        SET hits = hits + 1 
        WHERE consulta_hash = consulta_hash;
        
        -- Devolver resultado del caché
        SELECT resultado_cache AS resultado, 'CACHE_HIT' AS fuente;
    ELSE
        -- Devolver indicador de miss
        SELECT NULL AS resultado, 'CACHE_MISS' AS fuente;
    END IF;
END//
DELIMITER ;
```

### Ejercicio 3: Crear Agregaciones Precalculadas
**Objetivo**: Implementar sistema de resúmenes para reportes.

```sql
-- Crear tablas de resumen
CREATE TABLE resumen_usuarios_diario (
    fecha DATE,
    usuarios_nuevos INT,
    usuarios_activos INT,
    usuarios_totales INT,
    publicaciones_totales INT,
    likes_totales INT,
    
    PRIMARY KEY (fecha)
);

CREATE TABLE resumen_publicaciones_diario (
    fecha DATE,
    publicaciones_texto INT,
    publicaciones_imagen INT,
    publicaciones_video INT,
    publicaciones_enlace INT,
    promedio_likes DECIMAL(10,2),
    promedio_comentarios DECIMAL(10,2),
    
    PRIMARY KEY (fecha)
);

CREATE TABLE resumen_usuarios_populares (
    usuario_id BIGINT,
    total_seguidores INT,
    total_publicaciones INT,
    total_likes_recibidos INT,
    promedio_likes_por_publicacion DECIMAL(10,2),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (usuario_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_populares_seguidores (total_seguidores),
    INDEX idx_populares_likes (total_likes_recibidos)
);

-- Procedimiento para actualizar resúmenes
DELIMITER //
CREATE PROCEDURE actualizar_resumenes_diarios(IN fecha_resumen DATE)
BEGIN
    -- Actualizar resumen de usuarios
    INSERT INTO resumen_usuarios_diario (
        fecha, usuarios_nuevos, usuarios_activos, usuarios_totales, 
        publicaciones_totales, likes_totales
    )
    SELECT 
        fecha_resumen,
        COUNT(CASE WHEN DATE(fecha_registro) = fecha_resumen THEN 1 END) as usuarios_nuevos,
        COUNT(CASE WHEN DATE(ultima_actividad) = fecha_resumen THEN 1 END) as usuarios_activos,
        COUNT(*) as usuarios_totales,
        (SELECT COUNT(*) FROM publicaciones WHERE DATE(fecha_publicacion) = fecha_resumen) as publicaciones_totales,
        (SELECT COUNT(*) FROM likes WHERE DATE(fecha_like) = fecha_resumen) as likes_totales
    FROM usuarios
    WHERE fecha_registro <= fecha_resumen
    ON DUPLICATE KEY UPDATE
        usuarios_nuevos = VALUES(usuarios_nuevos),
        usuarios_activos = VALUES(usuarios_activos),
        usuarios_totales = VALUES(usuarios_totales),
        publicaciones_totales = VALUES(publicaciones_totales),
        likes_totales = VALUES(likes_totales);
    
    -- Actualizar resumen de publicaciones
    INSERT INTO resumen_publicaciones_diario (
        fecha, publicaciones_texto, publicaciones_imagen, publicaciones_video, 
        publicaciones_enlace, promedio_likes, promedio_comentarios
    )
    SELECT 
        fecha_resumen,
        COUNT(CASE WHEN tipo = 'texto' THEN 1 END) as publicaciones_texto,
        COUNT(CASE WHEN tipo = 'imagen' THEN 1 END) as publicaciones_imagen,
        COUNT(CASE WHEN tipo = 'video' THEN 1 END) as publicaciones_video,
        COUNT(CASE WHEN tipo = 'enlace' THEN 1 END) as publicaciones_enlace,
        AVG(likes_count) as promedio_likes,
        AVG(comentarios_count) as promedio_comentarios
    FROM publicaciones
    WHERE DATE(fecha_publicacion) = fecha_resumen
    ON DUPLICATE KEY UPDATE
        publicaciones_texto = VALUES(publicaciones_texto),
        publicaciones_imagen = VALUES(publicaciones_imagen),
        publicaciones_video = VALUES(publicaciones_video),
        publicaciones_enlace = VALUES(publicaciones_enlace),
        promedio_likes = VALUES(promedio_likes),
        promedio_comentarios = VALUES(promedio_comentarios);
    
    SELECT 'Resúmenes actualizados' AS resultado;
END//
DELIMITER ;
```

### Ejercicio 4: Implementar Archivo de Datos Históricos
**Objetivo**: Crear sistema para archivar datos antiguos.

```sql
-- Crear tabla de archivo para publicaciones antiguas
CREATE TABLE publicaciones_archivo (
    id BIGINT,
    usuario_id BIGINT,
    contenido TEXT,
    tipo ENUM('texto', 'imagen', 'video', 'enlace'),
    fecha_publicacion TIMESTAMP,
    likes_count INT,
    comentarios_count INT,
    compartidos_count INT,
    fecha_archivo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id),
    INDEX idx_archivo_usuario (usuario_id),
    INDEX idx_archivo_fecha (fecha_publicacion)
);

-- Procedimiento para archivar datos antiguos
DELIMITER //
CREATE PROCEDURE archivar_publicaciones_antiguas(IN dias_antiguedad INT)
BEGIN
    DECLARE fecha_limite DATE;
    SET fecha_limite = DATE_SUB(CURDATE(), INTERVAL dias_antiguedad DAY);
    
    -- Mover publicaciones antiguas al archivo
    INSERT INTO publicaciones_archivo (
        id, usuario_id, contenido, tipo, fecha_publicacion, 
        likes_count, comentarios_count, compartidos_count
    )
    SELECT 
        id, usuario_id, contenido, tipo, fecha_publicacion,
        likes_count, comentarios_count, compartidos_count
    FROM publicaciones
    WHERE DATE(fecha_publicacion) < fecha_limite;
    
    -- Eliminar publicaciones antiguas de la tabla principal
    DELETE FROM publicaciones 
    WHERE DATE(fecha_publicacion) < fecha_limite;
    
    SELECT ROW_COUNT() AS publicaciones_archivadas;
END//
DELIMITER ;

-- Crear evento para archivo automático
CREATE EVENT archivo_automatico_publicaciones
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
  CALL archivar_publicaciones_antiguas(365); -- Archivar publicaciones de más de 1 año
```

### Ejercicio 5: Optimizar Consultas para Escalabilidad
**Objetivo**: Crear consultas optimizadas para grandes volúmenes.

```sql
-- Consulta 1: Timeline de usuario (optimizada)
SELECT 
    p.id,
    p.contenido,
    p.tipo,
    p.fecha_publicacion,
    p.likes_count,
    p.comentarios_count,
    u.username,
    u.nombre,
    u.apellido
FROM publicaciones p
JOIN usuarios u ON p.usuario_id = u.id
WHERE p.usuario_id IN (
    SELECT seguido_id 
    FROM seguidores 
    WHERE seguidor_id = ? -- ID del usuario actual
)
ORDER BY p.fecha_publicacion DESC
LIMIT 20;

-- Consulta 2: Usuarios populares (optimizada)
SELECT 
    u.id,
    u.username,
    u.nombre,
    u.apellido,
    COUNT(s.seguidor_id) as total_seguidores,
    COUNT(p.id) as total_publicaciones,
    SUM(p.likes_count) as total_likes
FROM usuarios u
LEFT JOIN seguidores s ON u.id = s.seguido_id
LEFT JOIN publicaciones p ON u.id = p.usuario_id
WHERE u.activo = TRUE
GROUP BY u.id, u.username, u.nombre, u.apellido
ORDER BY total_seguidores DESC, total_likes DESC
LIMIT 50;

-- Consulta 3: Estadísticas de usuario (optimizada)
SELECT 
    u.username,
    u.nombre,
    u.apellido,
    COUNT(DISTINCT s.seguidor_id) as seguidores,
    COUNT(DISTINCT s2.seguido_id) as siguiendo,
    COUNT(DISTINCT p.id) as publicaciones,
    SUM(p.likes_count) as likes_recibidos,
    COUNT(DISTINCT l.id) as likes_dados
FROM usuarios u
LEFT JOIN seguidores s ON u.id = s.seguido_id
LEFT JOIN seguidores s2 ON u.id = s2.seguidor_id
LEFT JOIN publicaciones p ON u.id = p.usuario_id
LEFT JOIN likes l ON u.id = l.usuario_id
WHERE u.id = ? -- ID del usuario
GROUP BY u.id, u.username, u.nombre, u.apellido;
```

### Ejercicio 6: Crear Sistema de Monitoreo de Escalabilidad
**Objetivo**: Implementar monitoreo para detectar problemas de escalabilidad.

```sql
-- Crear tabla de métricas de rendimiento
CREATE TABLE metricas_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    consulta_hash VARCHAR(64),
    tiempo_ejecucion DECIMAL(10,6),
    filas_examinadas INT,
    filas_devueltas INT,
    uso_memoria INT,
    tipo_consulta VARCHAR(50)
);

-- Crear tabla de alertas de rendimiento
CREATE TABLE alertas_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_alerta ENUM('CONSULTA_LENTA', 'ALTO_VOLUMEN', 'MEMORIA_ALTA', 'DISCO_LLENO'),
    mensaje TEXT,
    severidad ENUM('BAJA', 'MEDIA', 'ALTA', 'CRITICA'),
    resuelta BOOLEAN DEFAULT FALSE
);

-- Procedimiento para monitorear consultas lentas
DELIMITER //
CREATE PROCEDURE monitorear_consultas_lentas()
BEGIN
    DECLARE consultas_lentas INT DEFAULT 0;
    
    -- Contar consultas que tardan más de 1 segundo
    SELECT COUNT(*) INTO consultas_lentas
    FROM metricas_rendimiento
    WHERE fecha_medicion >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
    AND tiempo_ejecucion > 1.0;
    
    -- Crear alerta si hay muchas consultas lentas
    IF consultas_lentas > 10 THEN
        INSERT INTO alertas_rendimiento (tipo_alerta, mensaje, severidad)
        VALUES (
            'CONSULTA_LENTA',
            CONCAT('Se detectaron ', consultas_lentas, ' consultas lentas en la última hora'),
            'ALTA'
        );
    END IF;
    
    SELECT consultas_lentas AS consultas_lentas_detectadas;
END//
DELIMITER ;

-- Procedimiento para analizar tendencias de crecimiento
DELIMITER //
CREATE PROCEDURE analizar_tendencias_crecimiento()
BEGIN
    -- Análisis de crecimiento de usuarios
    SELECT 
        DATE(fecha_registro) as fecha,
        COUNT(*) as usuarios_nuevos,
        SUM(COUNT(*)) OVER (ORDER BY DATE(fecha_registro)) as usuarios_acumulados
    FROM usuarios
    WHERE fecha_registro >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(fecha_registro)
    ORDER BY fecha;
    
    -- Análisis de crecimiento de publicaciones
    SELECT 
        DATE(fecha_publicacion) as fecha,
        COUNT(*) as publicaciones_nuevas,
        SUM(COUNT(*)) OVER (ORDER BY DATE(fecha_publicacion)) as publicaciones_acumuladas
    FROM publicaciones
    WHERE fecha_publicacion >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY DATE(fecha_publicacion)
    ORDER BY fecha;
END//
DELIMITER ;
```

### Ejercicio 7: Implementar Estrategias de Particionamiento
**Objetivo**: Crear tablas particionadas para optimizar consultas.

```sql
-- Crear tabla de mensajes particionada por fecha
CREATE TABLE mensajes (
    id BIGINT AUTO_INCREMENT,
    remitente_id BIGINT NOT NULL,
    destinatario_id BIGINT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE,
    
    PRIMARY KEY (id, fecha_envio),
    FOREIGN KEY (remitente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (destinatario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_mensajes_remitente (remitente_id),
    INDEX idx_mensajes_destinatario (destinatario_id)
) PARTITION BY RANGE (UNIX_TIMESTAMP(fecha_envio)) (
    PARTITION p_2024_01 VALUES LESS THAN (UNIX_TIMESTAMP('2024-02-01')),
    PARTITION p_2024_02 VALUES LESS THAN (UNIX_TIMESTAMP('2024-03-01')),
    PARTITION p_2024_03 VALUES LESS THAN (UNIX_TIMESTAMP('2024-04-01')),
    PARTITION p_2024_04 VALUES LESS THAN (UNIX_TIMESTAMP('2024-05-01')),
    PARTITION p_2024_05 VALUES LESS THAN (UNIX_TIMESTAMP('2024-06-01')),
    PARTITION p_2024_06 VALUES LESS THAN (UNIX_TIMESTAMP('2024-07-01')),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- Crear tabla de notificaciones particionada por usuario
CREATE TABLE notificaciones (
    id BIGINT AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    tipo ENUM('like', 'comentario', 'seguimiento', 'mensaje') NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leida BOOLEAN DEFAULT FALSE,
    
    PRIMARY KEY (id, usuario_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_notificaciones_fecha (fecha_creacion),
    INDEX idx_notificaciones_tipo (tipo)
) PARTITION BY HASH(usuario_id) PARTITIONS 10;

-- Consulta optimizada para mensajes recientes
SELECT 
    m.id,
    m.contenido,
    m.fecha_envio,
    m.leido,
    u.username as remitente_username,
    u.nombre as remitente_nombre
FROM mensajes m
JOIN usuarios u ON m.remitente_id = u.id
WHERE m.destinatario_id = ? -- ID del usuario
AND m.fecha_envio >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY m.fecha_envio DESC
LIMIT 50;
```

### Ejercicio 8: Crear Sistema de Backup Escalable
**Objetivo**: Implementar estrategias de backup para grandes volúmenes.

```sql
-- Crear tabla de configuración de backups
CREATE TABLE configuracion_backup (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_nombre VARCHAR(100) NOT NULL,
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL') NOT NULL,
    retencion_dias INT NOT NULL,
    comprimir BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE
);

-- Crear tabla de historial de backups
CREATE TABLE historial_backup (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_nombre VARCHAR(100) NOT NULL,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tamaño_bytes BIGINT,
    registros_backup INT,
    estado ENUM('EXITOSO', 'FALLIDO', 'EN_PROGRESO') NOT NULL,
    ruta_archivo VARCHAR(500),
    duracion_segundos INT
);

-- Procedimiento para backup incremental
DELIMITER //
CREATE PROCEDURE backup_incremental(IN tabla_nombre VARCHAR(100))
BEGIN
    DECLARE fecha_ultimo_backup TIMESTAMP;
    DECLARE registros_backup INT DEFAULT 0;
    DECLARE inicio_backup TIMESTAMP;
    DECLARE fin_backup TIMESTAMP;
    
    SET inicio_backup = NOW();
    
    -- Obtener fecha del último backup exitoso
    SELECT MAX(fecha_backup) INTO fecha_ultimo_backup
    FROM historial_backup
    WHERE tabla_nombre = tabla_nombre
    AND estado = 'EXITOSO';
    
    -- Crear backup incremental (simplificado)
    -- En un entorno real, esto sería más complejo
    
    SET fin_backup = NOW();
    
    -- Registrar en historial
    INSERT INTO historial_backup (
        tabla_nombre, fecha_backup, registros_backup, 
        estado, duracion_segundos
    )
    VALUES (
        tabla_nombre, NOW(), registros_backup,
        'EXITOSO', TIMESTAMPDIFF(SECOND, inicio_backup, fin_backup)
    );
    
    SELECT 'Backup incremental completado' AS resultado;
END//
DELIMITER ;

-- Crear evento para backup automático
CREATE EVENT backup_automatico_diario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL backup_incremental('usuarios');
    CALL backup_incremental('publicaciones');
    CALL backup_incremental('seguidores');
END;
```

### Ejercicio 9: Implementar Estrategias de Carga
**Objetivo**: Crear sistema para manejar picos de carga.

```sql
-- Crear tabla de configuración de carga
CREATE TABLE configuracion_carga (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_configuracion VARCHAR(100) NOT NULL,
    max_conexiones INT DEFAULT 100,
    timeout_consulta INT DEFAULT 30,
    cache_size_mb INT DEFAULT 256,
    activo BOOLEAN DEFAULT TRUE
);

-- Crear tabla de métricas de carga
CREATE TABLE metricas_carga (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    conexiones_activas INT,
    consultas_por_segundo DECIMAL(10,2),
    uso_cpu DECIMAL(5,2),
    uso_memoria DECIMAL(5,2),
    uso_disco DECIMAL(5,2)
);

-- Procedimiento para ajustar configuración según carga
DELIMITER //
CREATE PROCEDURE ajustar_configuracion_carga()
BEGIN
    DECLARE carga_actual DECIMAL(5,2);
    DECLARE conexiones_actuales INT;
    
    -- Obtener métricas actuales
    SELECT 
        uso_cpu, 
        conexiones_activas 
    INTO carga_actual, conexiones_actuales
    FROM metricas_carga
    ORDER BY fecha_medicion DESC
    LIMIT 1;
    
    -- Ajustar configuración según la carga
    IF carga_actual > 80 THEN
        -- Alta carga: reducir conexiones máximas
        UPDATE configuracion_carga 
        SET max_conexiones = 50, timeout_consulta = 15
        WHERE activo = TRUE;
        
        INSERT INTO alertas_rendimiento (tipo_alerta, mensaje, severidad)
        VALUES ('ALTO_VOLUMEN', 'Alta carga detectada, reduciendo conexiones', 'ALTA');
        
    ELSEIF carga_actual < 30 THEN
        -- Baja carga: aumentar conexiones máximas
        UPDATE configuracion_carga 
        SET max_conexiones = 200, timeout_consulta = 60
        WHERE activo = TRUE;
    END IF;
    
    SELECT 'Configuración ajustada según carga' AS resultado;
END//
DELIMITER ;
```

### Ejercicio 10: Caso de Estudio Completo
**Objetivo**: Crear sistema completo escalable para streaming de video.

```sql
-- Crear sistema de streaming escalable
CREATE DATABASE streaming_escalable;
USE streaming_escalable;

-- Tabla de usuarios (optimizada para escalabilidad)
CREATE TABLE usuarios (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    premium BOOLEAN DEFAULT FALSE,
    
    INDEX idx_usuarios_username (username),
    INDEX idx_usuarios_email (email),
    INDEX idx_usuarios_activo (activo),
    INDEX idx_usuarios_premium (premium)
);

-- Tabla de videos (particionada por fecha)
CREATE TABLE videos (
    id BIGINT AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    duracion_segundos INT NOT NULL,
    categoria_id INT,
    usuario_id BIGINT NOT NULL,
    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vistas_count BIGINT DEFAULT 0,
    likes_count INT DEFAULT 0,
    dislikes_count INT DEFAULT 0,
    comentarios_count INT DEFAULT 0,
    estado ENUM('procesando', 'publicado', 'privado', 'eliminado') DEFAULT 'procesando',
    
    PRIMARY KEY (id, fecha_subida),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_videos_usuario (usuario_id),
    INDEX idx_videos_categoria (categoria_id),
    INDEX idx_videos_estado (estado),
    INDEX idx_videos_vistas (vistas_count)
) PARTITION BY RANGE (UNIX_TIMESTAMP(fecha_subida)) (
    PARTITION p_2024_01 VALUES LESS THAN (UNIX_TIMESTAMP('2024-02-01')),
    PARTITION p_2024_02 VALUES LESS THAN (UNIX_TIMESTAMP('2024-03-01')),
    PARTITION p_2024_03 VALUES LESS THAN (UNIX_TIMESTAMP('2024-04-01')),
    PARTITION p_futuro VALUES LESS THAN MAXVALUE
);

-- Tabla de vistas (optimizada para alto volumen)
CREATE TABLE vistas_videos (
    id BIGINT AUTO_INCREMENT,
    video_id BIGINT NOT NULL,
    usuario_id BIGINT,
    fecha_vista TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duracion_vista_segundos INT,
    porcentaje_visto DECIMAL(5,2),
    
    PRIMARY KEY (id),
    FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    
    INDEX idx_vistas_video (video_id),
    INDEX idx_vistas_usuario (usuario_id),
    INDEX idx_vistas_fecha (fecha_vista)
);

-- Tabla de suscripciones (optimizada para consultas)
CREATE TABLE suscripciones (
    suscriptor_id BIGINT,
    canal_id BIGINT,
    fecha_suscripcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notificaciones BOOLEAN DEFAULT TRUE,
    
    PRIMARY KEY (suscriptor_id, canal_id),
    FOREIGN KEY (suscriptor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (canal_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_suscripciones_canal (canal_id),
    INDEX idx_suscripciones_fecha (fecha_suscripcion)
);

-- Tabla de resumen de canales (desnormalizada para rendimiento)
CREATE TABLE resumen_canales (
    canal_id BIGINT PRIMARY KEY,
    total_suscriptores INT DEFAULT 0,
    total_videos INT DEFAULT 0,
    total_vistas BIGINT DEFAULT 0,
    total_likes INT DEFAULT 0,
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (canal_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_resumen_suscriptores (total_suscriptores),
    INDEX idx_resumen_vistas (total_vistas)
);

-- Procedimiento para actualizar resúmenes de canales
DELIMITER //
CREATE PROCEDURE actualizar_resumen_canal(IN canal_id_param BIGINT)
BEGIN
    UPDATE resumen_canales SET
        total_suscriptores = (
            SELECT COUNT(*) FROM suscripciones WHERE canal_id = canal_id_param
        ),
        total_videos = (
            SELECT COUNT(*) FROM videos WHERE usuario_id = canal_id_param AND estado = 'publicado'
        ),
        total_vistas = (
            SELECT COALESCE(SUM(vistas_count), 0) FROM videos WHERE usuario_id = canal_id_param
        ),
        total_likes = (
            SELECT COALESCE(SUM(likes_count), 0) FROM videos WHERE usuario_id = canal_id_param
        ),
        fecha_ultima_actualizacion = NOW()
    WHERE canal_id = canal_id_param;
END//
DELIMITER ;

-- Consultas optimizadas para el sistema de streaming
-- 1. Videos populares
SELECT 
    v.id,
    v.titulo,
    v.vistas_count,
    v.likes_count,
    u.username as canal_username,
    rc.total_suscriptores
FROM videos v
JOIN usuarios u ON v.usuario_id = u.id
JOIN resumen_canales rc ON u.id = rc.canal_id
WHERE v.estado = 'publicado'
ORDER BY v.vistas_count DESC
LIMIT 50;

-- 2. Timeline de suscripciones
SELECT 
    v.id,
    v.titulo,
    v.fecha_subida,
    v.vistas_count,
    u.username as canal_username
FROM videos v
JOIN usuarios u ON v.usuario_id = u.id
WHERE v.usuario_id IN (
    SELECT canal_id FROM suscripciones WHERE suscriptor_id = ? -- ID del usuario
)
AND v.estado = 'publicado'
ORDER BY v.fecha_subida DESC
LIMIT 20;
```

## Resumen de la Clase

### Conceptos Clave Aprendidos:
1. **Escalabilidad**: Capacidad de crecer sin degradar rendimiento
2. **Particionamiento**: División de datos para optimizar consultas
3. **Caching**: Almacenamiento temporal de datos frecuentes
4. **Agregaciones**: Precalculación de resúmenes
5. **Monitoreo**: Seguimiento de métricas de rendimiento

### Próximos Pasos:
- Aprender optimización avanzada de consultas
- Estudiar técnicas de replicación
- Practicar con casos complejos de escalabilidad

### Recursos Adicionales:
- Documentación sobre escalabilidad en MySQL
- Herramientas de monitoreo de rendimiento
- Casos de estudio de empresas tecnológicas
