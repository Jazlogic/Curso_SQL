# 🎯 Senior Level 5: Administración de Bases de Datos y Seguridad

## 🧭 Navegación del Curso

**← Anterior**: [Senior Level 4: Optimización Avanzada](../senior_4/README.md)  
**Siguiente →**: [Senior Level 6: Plataformas Musicales](../senior_6/README.md)

---

## 📖 Teoría

### ¿Qué es la Administración de Bases de Datos?
La administración de bases de datos (DBA) es el conjunto de actividades necesarias para mantener una base de datos funcionando de manera eficiente, segura y confiable.

### Responsabilidades del DBA
1. **Instalación y Configuración**: Configurar el servidor de base de datos
2. **Monitoreo**: Supervisar el rendimiento y la salud del sistema
3. **Backup y Recuperación**: Proteger los datos contra pérdidas
4. **Seguridad**: Implementar controles de acceso y protección
5. **Mantenimiento**: Optimizar y actualizar el sistema

### Aspectos de Seguridad
- **Autenticación**: Verificar la identidad de usuarios
- **Autorización**: Controlar qué puede hacer cada usuario
- **Encriptación**: Proteger datos sensibles
- **Auditoría**: Rastrear actividades del sistema
- **Cumplimiento**: Adherir a regulaciones y estándares

## 💡 Ejemplos Prácticos

### Ejemplo 1: Crear Usuario y Asignar Permisos
```sql
-- Crear usuario
CREATE USER 'usuario_app'@'localhost' IDENTIFIED BY 'Password123!';

-- Asignar permisos específicos
GRANT SELECT, INSERT, UPDATE, DELETE ON tienda_online.* TO 'usuario_app'@'localhost';

-- Verificar permisos
SHOW GRANTS FOR 'usuario_app'@'localhost';
```

### Ejemplo 2: Configurar Backup Automático
```sql
-- Crear evento para backup diario
CREATE EVENT backup_diario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Lógica de backup (ejecutar desde línea de comandos)
    -- mysqldump -u root -p tienda_online > backup_$(date +%Y%m%d).sql
END;
```

### Ejemplo 3: Configurar Auditoría
```sql
-- Habilitar auditoría general
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';

-- Crear tabla de auditoría personalizada
CREATE TABLE auditoria_general (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    host VARCHAR(100),
    comando TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🎯 Ejercicios

### Ejercicio 1: Gestión de Usuarios y Permisos
Implementa un sistema completo de gestión de usuarios:

1. Crear roles de usuario con permisos específicos
2. Implementar sistema de contraseñas seguras
3. Gestionar acceso por IP y horarios
4. Crear usuarios temporales con expiración
5. Implementar auditoría de acceso

**Solución:**
```sql
-- 1. Crear roles de usuario
-- Rol de administrador
CREATE USER 'admin_db'@'localhost' IDENTIFIED BY 'AdminSecure123!';
GRANT ALL PRIVILEGES ON *.* TO 'admin_db'@'localhost' WITH GRANT OPTION;

-- Rol de desarrollador
CREATE USER 'dev_user'@'%' IDENTIFIED BY 'DevSecure456!';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON tienda_online.* TO 'dev_user'@'%';

-- Rol de reportes
CREATE USER 'reportes_user'@'192.168.1.%' IDENTIFIED BY 'Reports789!';
GRANT SELECT ON tienda_online.* TO 'reportes_user'@'192.168.1.%';

-- Rol de aplicación
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'AppSecure000!';
GRANT SELECT, INSERT, UPDATE, DELETE ON tienda_online.* TO 'app_user'@'localhost';

-- 2. Sistema de contraseñas seguras
-- Crear función para validar contraseñas
DELIMITER //
CREATE FUNCTION validar_password_seguro(password VARCHAR(255)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE es_seguro BOOLEAN DEFAULT FALSE;
    
    -- Verificar longitud mínima (8 caracteres)
    IF LENGTH(password) >= 8 THEN
        -- Verificar que contenga mayúsculas, minúsculas, números y símbolos
        IF password REGEXP '[A-Z]' AND 
           password REGEXP '[a-z]' AND 
           password REGEXP '[0-9]' AND 
           password REGEXP '[^A-Za-z0-9]' THEN
            SET es_seguro = TRUE;
        END IF;
    END IF;
    
    RETURN es_seguro;
END //
DELIMITER ;

-- 3. Usuarios temporales con expiración
-- Crear usuario temporal
CREATE USER 'temp_user'@'localhost' IDENTIFIED BY 'TempPass123!';
GRANT SELECT ON tienda_online.productos TO 'temp_user'@'localhost';

-- Configurar expiración (MySQL 8.0+)
ALTER USER 'temp_user'@'localhost' PASSWORD EXPIRE INTERVAL 7 DAY;

-- 4. Auditoría de acceso
CREATE TABLE auditoria_acceso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    host VARCHAR(100),
    fecha_acceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_acceso ENUM('LOGIN', 'LOGOUT', 'FAILED_LOGIN'),
    ip_address VARCHAR(45),
    user_agent TEXT
);

-- Trigger para registrar accesos exitosos
DELIMITER //
CREATE TRIGGER log_acceso_exitoso
AFTER INSERT ON mysql.general_log
FOR EACH ROW
BEGIN
    IF NEW.argument LIKE '%Connect%' AND NEW.command_type = 'Connect' THEN
        INSERT INTO auditoria_acceso (
            usuario, host, tipo_acceso, ip_address, user_agent
        ) VALUES (
            SUBSTRING_INDEX(NEW.argument, '@', 1),
            SUBSTRING_INDEX(NEW.argument, '@', -1),
            'LOGIN',
            NEW.thread_id,
            'N/A'
        );
    END IF;
END //
DELIMITER ;
```

### Ejercicio 2: Sistema de Backup y Recuperación
Implementa un sistema completo de backup:

1. Backup automático diario
2. Backup incremental
3. Verificación de integridad
4. Recuperación de datos
5. Retención de backups

**Solución:**
```sql
-- 1. Crear tabla de control de backups
CREATE TABLE control_backups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo_backup VARCHAR(255),
    tamaño_bytes BIGINT,
    estado ENUM('EN_PROGRESO', 'COMPLETADO', 'FALLIDO'),
    checksum VARCHAR(64),
    duracion_segundos INT,
    observaciones TEXT
);

-- 2. Procedimiento para backup completo
DELIMITER //
CREATE PROCEDURE realizar_backup_completo()
BEGIN
    DECLARE nombre_archivo VARCHAR(255);
    DECLARE fecha_actual VARCHAR(8);
    DECLARE backup_id INT;
    
    -- Generar nombre de archivo
    SET fecha_actual = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');
    SET nombre_archivo = CONCAT('backup_completo_', fecha_actual, '.sql');
    
    -- Registrar inicio de backup
    INSERT INTO control_backups (
        tipo_backup, archivo_backup, estado, fecha_backup
    ) VALUES (
        'COMPLETO', nombre_archivo, 'EN_PROGRESO', NOW()
    );
    
    SET backup_id = LAST_INSERT_ID();
    
    -- Aquí se ejecutaría el comando mysqldump
    -- mysqldump -u root -p --single-transaction --routines --triggers tienda_online > /backups/nombre_archivo
    
    -- Actualizar estado (esto se haría después de verificar el archivo)
    UPDATE control_backups 
    SET estado = 'COMPLETADO',
        fecha_backup = NOW()
    WHERE id = backup_id;
    
    SELECT CONCAT('Backup completado: ', nombre_archivo) AS mensaje;
END //
DELIMITER ;

-- 3. Procedimiento para verificar integridad
DELIMITER //
CREATE PROCEDURE verificar_integridad_backup(IN backup_id INT)
BEGIN
    DECLARE archivo_backup VARCHAR(255);
    DECLARE checksum_calculado VARCHAR(64);
    
    -- Obtener archivo del backup
    SELECT archivo_backup INTO archivo_backup
    FROM control_backups WHERE id = backup_id;
    
    -- Aquí se calcularía el checksum del archivo
    -- SET checksum_calculado = SHA2(LOAD_FILE(CONCAT('/backups/', archivo_backup)), 256);
    
    -- Verificar integridad
    IF checksum_calculado IS NOT NULL THEN
        UPDATE control_backups 
        SET checksum = checksum_calculado,
            observaciones = 'Verificación de integridad exitosa'
        WHERE id = backup_id;
        
        SELECT 'Backup verificado correctamente' AS resultado;
    ELSE
        UPDATE control_backups 
        SET estado = 'FALLIDO',
            observaciones = 'Error en verificación de integridad'
        WHERE id = backup_id;
        
        SELECT 'Error en verificación de integridad' AS resultado;
    END IF;
END //
DELIMITER ;

-- 4. Procedimiento para limpiar backups antiguos
DELIMITER //
CREATE PROCEDURE limpiar_backups_antiguos(IN dias_retener INT)
BEGIN
    DECLARE fecha_limite DATE;
    
    SET fecha_limite = DATE_SUB(CURDATE(), INTERVAL dias_retener DAY);
    
    -- Marcar backups antiguos para eliminación
    UPDATE control_backups 
    SET observaciones = CONCAT('Marcado para eliminación - Backup antiguo (', dias_retener, ' días)')
    WHERE fecha_backup < fecha_limite
    AND estado = 'COMPLETADO';
    
    -- Aquí se eliminarían los archivos físicos
    -- DELETE FROM control_backups WHERE fecha_backup < fecha_limite;
    
    SELECT CONCAT('Backups anteriores a ', fecha_limite, ' marcados para eliminación') AS mensaje;
END //
DELIMITER ;
```

### Ejercicio 3: Monitoreo y Alertas del Sistema
Implementa un sistema de monitoreo:

1. Monitoreo de recursos del sistema
2. Alertas automáticas por email
3. Dashboard de métricas en tiempo real
4. Detección de anomalías
5. Reportes de rendimiento

**Solución:**
```sql
-- 1. Tabla de métricas del sistema
CREATE TABLE metricas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_uso DECIMAL(5,2),
    memoria_uso DECIMAL(5,2),
    espacio_disco DECIMAL(5,2),
    conexiones_activas INT,
    consultas_por_segundo DECIMAL(10,2),
    tiempo_respuesta_promedio DECIMAL(10,6),
    tablas_locked INT,
    slow_queries INT
);

-- 2. Tabla de alertas
CREATE TABLE alertas_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_alerta ENUM('CRITICA', 'ADVERTENCIA', 'INFO'),
    categoria ENUM('RECURSOS', 'RENDIMIENTO', 'SEGURIDAD', 'BACKUP'),
    titulo VARCHAR(200),
    descripcion TEXT,
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_resuelta TIMESTAMP NULL,
    estado ENUM('ACTIVA', 'RESUELTA', 'IGNORADA'),
    usuario_resolucion VARCHAR(100),
    accion_tomada TEXT
);

-- 3. Procedimiento para monitoreo automático
DELIMITER //
CREATE PROCEDURE monitoreo_automatico()
BEGIN
    DECLARE cpu_actual DECIMAL(5,2);
    DECLARE memoria_actual DECIMAL(5,2);
    DECLARE disco_actual DECIMAL(5,2);
    DECLARE conexiones_actuales INT;
    
    -- Simular obtención de métricas (en producción se usarían comandos del sistema)
    SET cpu_actual = 45.5;
    SET memoria_actual = 78.2;
    SET disco_actual = 65.8;
    SET conexiones_actuales = 125;
    
    -- Registrar métricas
    INSERT INTO metricas_sistema (
        cpu_uso, memoria_uso, espacio_disco, conexiones_activas
    ) VALUES (
        cpu_actual, memoria_actual, disco_actual, conexiones_actuales
    );
    
    -- Verificar alertas
    -- CPU alto
    IF cpu_actual > 80 THEN
        INSERT INTO alertas_sistema (
            tipo_alerta, categoria, titulo, descripcion
        ) VALUES (
            'CRITICA', 'RECURSOS', 
            'Uso de CPU crítico', 
            CONCAT('El uso de CPU es del ', cpu_actual, '%')
        );
    END IF;
    
    -- Memoria alta
    IF memoria_actual > 85 THEN
        INSERT INTO alertas_sistema (
            tipo_alerta, categoria, titulo, descripcion
        ) VALUES (
            'ADVERTENCIA', 'RECURSOS', 
            'Uso de memoria alto', 
            CONCAT('El uso de memoria es del ', memoria_actual, '%')
        );
    END IF;
    
    -- Disco alto
    IF disco_actual > 90 THEN
        INSERT INTO alertas_sistema (
            tipo_alerta, categoria, titulo, descripcion
        ) VALUES (
            'CRITICA', 'RECURSOS', 
            'Espacio en disco crítico', 
            CONCAT('El uso de disco es del ', disco_actual, '%')
        );
    END IF;
    
    -- Conexiones altas
    IF conexiones_actuales > 200 THEN
        INSERT INTO alertas_sistema (
            tipo_alerta, categoria, titulo, descripcion
        ) VALUES (
            'ADVERTENCIA', 'RENDIMIENTO', 
            'Muchas conexiones activas', 
            CONCAT('Hay ', conexiones_actuales, ' conexiones activas')
        );
    END IF;
END //
DELIMITER ;

-- 4. Procedimiento para generar reportes
DELIMITER //
CREATE PROCEDURE generar_reporte_rendimiento(IN dias INT)
BEGIN
    SELECT 
        DATE(fecha_medicion) AS fecha,
        ROUND(AVG(cpu_uso), 2) AS cpu_promedio,
        ROUND(AVG(memoria_uso), 2) AS memoria_promedio,
        ROUND(AVG(espacio_disco), 2) AS disco_promedio,
        ROUND(AVG(conexiones_activas), 0) AS conexiones_promedio,
        ROUND(MAX(cpu_uso), 2) AS cpu_maximo,
        ROUND(MAX(memoria_uso), 2) AS memoria_maxima,
        COUNT(*) AS mediciones
    FROM metricas_sistema
    WHERE fecha_medicion >= DATE_SUB(CURDATE(), INTERVAL dias DAY)
    GROUP BY DATE(fecha_medicion)
    ORDER BY fecha DESC;
END //
DELIMITER ;
```

### Ejercicio 4: Seguridad y Cumplimiento
Implementa medidas de seguridad avanzadas:

1. Encriptación de datos sensibles
2. Auditoría completa de cambios
3. Detección de intrusiones
4. Cumplimiento de regulaciones
5. Respuesta a incidentes

**Solución:**
```sql
-- 1. Tabla para datos encriptados
CREATE TABLE datos_sensibles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    numero_tarjeta VARBINARY(255), -- Encriptado
    cvv VARBINARY(255), -- Encriptado
    fecha_expiracion VARBINARY(255), -- Encriptado
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Procedimiento para encriptar datos
DELIMITER //
CREATE PROCEDURE insertar_datos_encriptados(
    IN cliente_id INT,
    IN numero_tarjeta VARCHAR(16),
    IN cvv VARCHAR(4),
    IN fecha_expiracion VARCHAR(5)
)
BEGIN
    -- Encriptar datos sensibles (ejemplo simplificado)
    INSERT INTO datos_sensibles (
        cliente_id, numero_tarjeta, cvv, fecha_expiracion
    ) VALUES (
        cliente_id,
        AES_ENCRYPT(numero_tarjeta, 'clave_secreta_32_caracteres'),
        AES_ENCRYPT(cvv, 'clave_secreta_32_caracteres'),
        AES_ENCRYPT(fecha_expiracion, 'clave_secreta_32_caracteres')
    );
END //
DELIMITER ;

-- 3. Auditoría completa de cambios
CREATE TABLE auditoria_completa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla_modificada VARCHAR(100),
    tipo_operacion ENUM('INSERT', 'UPDATE', 'DELETE'),
    registro_id INT,
    datos_anteriores JSON,
    datos_nuevos JSON,
    usuario_modificacion VARCHAR(100),
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);

-- Trigger para auditoría completa de productos
DELIMITER //
CREATE TRIGGER audit_productos_completa_avanzada
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_completa (
        tabla_modificada, tipo_operacion, registro_id,
        datos_anteriores, datos_nuevos, usuario_modificacion
    ) VALUES (
        'productos', 'UPDATE', NEW.id,
        JSON_OBJECT(
            'nombre', OLD.nombre,
            'precio', OLD.precio,
            'stock', OLD.stock,
            'categoria_id', OLD.categoria_id
        ),
        JSON_OBJECT(
            'nombre', NEW.nombre,
            'precio', NEW.precio,
            'stock', NEW.stock,
            'categoria_id', NEW.categoria_id
        ),
        USER()
    );
END //
DELIMITER ;

-- 4. Detección de intrusiones
CREATE TABLE intentos_acceso (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    host VARCHAR(100),
    fecha_intento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resultado ENUM('EXITOSO', 'FALLIDO'),
    ip_address VARCHAR(45),
    user_agent TEXT
);

-- Procedimiento para detectar ataques de fuerza bruta
DELIMITER //
CREATE PROCEDURE detectar_ataques_fuerza_bruta()
BEGIN
    DECLARE usuario_sospechoso VARCHAR(100);
    DECLARE intentos_fallidos INT;
    
    -- Buscar usuarios con muchos intentos fallidos
    SELECT 
        usuario,
        COUNT(*) as intentos_fallidos
    FROM intentos_acceso
    WHERE resultado = 'FALLIDO'
    AND fecha_intento >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
    GROUP BY usuario
    HAVING COUNT(*) > 5
    INTO usuario_sospechoso, intentos_fallidos;
    
    -- Si se detecta un ataque, crear alerta
    IF usuario_sospechoso IS NOT NULL THEN
        INSERT INTO alertas_sistema (
            tipo_alerta, categoria, titulo, descripcion
        ) VALUES (
            'CRITICA', 'SEGURIDAD',
            'Posible ataque de fuerza bruta',
            CONCAT('Usuario: ', usuario_sospechoso, ' - Intentos fallidos: ', intentos_fallidos)
        );
        
        -- Bloquear usuario temporalmente
        -- ALTER USER usuario_sospechoso@'%' ACCOUNT LOCK;
    END IF;
END //
DELIMITER ;
```

### Ejercicio 5: Automatización y Mantenimiento
Implementa tareas automatizadas:

1. Mantenimiento automático de índices
2. Limpieza de logs y datos obsoletos
3. Optimización automática de tablas
4. Rotación de archivos de log
5. Sincronización de réplicas

**Solución:**
```sql
-- 1. Tabla de tareas de mantenimiento
CREATE TABLE tareas_mantenimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tarea VARCHAR(100),
    descripcion TEXT,
    frecuencia ENUM('DIARIA', 'SEMANAL', 'MENSUAL'),
    ultima_ejecucion TIMESTAMP NULL,
    proxima_ejecucion TIMESTAMP,
    estado ENUM('ACTIVA', 'PAUSADA', 'ELIMINADA'),
    comando_ejecutar TEXT,
    timeout_segundos INT DEFAULT 3600
);

-- 2. Procedimiento para mantenimiento de índices
DELIMITER //
CREATE PROCEDURE mantenimiento_indices()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nombre_tabla VARCHAR(100);
    DECLARE nombre_indice VARCHAR(100);
    
    DECLARE cur CURSOR FOR
        SELECT DISTINCT TABLE_NAME
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE();
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO nombre_tabla;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Analizar tabla para actualizar estadísticas
        SET @sql = CONCAT('ANALYZE TABLE ', nombre_tabla);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Optimizar tabla si es necesario
        SET @sql = CONCAT('OPTIMIZE TABLE ', nombre_tabla);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
    END LOOP;
    
    CLOSE cur;
    
    -- Registrar mantenimiento
    INSERT INTO log_mantenimiento (
        tipo, descripcion, fecha_ejecucion
    ) VALUES (
        'INDICES', 'Mantenimiento de índices completado', NOW()
    );
END //
DELIMITER ;

-- 3. Procedimiento para limpieza automática
DELIMITER //
CREATE PROCEDURE limpieza_automatica()
BEGIN
    DECLARE registros_eliminados INT DEFAULT 0;
    
    -- Limpiar logs antiguos
    DELETE FROM mysql.general_log 
    WHERE event_time < DATE_SUB(NOW(), INTERVAL 30 DAY);
    
    SET registros_eliminados = ROW_COUNT();
    
    -- Limpiar auditoría antigua
    DELETE FROM auditoria_completa 
    WHERE fecha_modificacion < DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    SET registros_eliminados = registros_eliminados + ROW_COUNT();
    
    -- Limpiar métricas antiguas
    DELETE FROM metricas_sistema 
    WHERE fecha_medicion < DATE_SUB(NOW(), INTERVAL 6 MONTH);
    
    SET registros_eliminados = registros_eliminados + ROW_COUNT();
    
    -- Registrar limpieza
    INSERT INTO log_mantenimiento (
        tipo, descripcion, fecha_ejecucion, observaciones
    ) VALUES (
        'LIMPIEZA', 'Limpieza automática completada', NOW(),
        CONCAT('Registros eliminados: ', registros_eliminados)
    );
END //
DELIMITER ;

-- 4. Evento para mantenimiento automático
CREATE EVENT mantenimiento_automatico_diario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 2 HOUR
DO
BEGIN
    -- Ejecutar mantenimiento de índices
    CALL mantenimiento_indices();
    
    -- Ejecutar limpieza automática
    CALL limpieza_automatica();
    
    -- Verificar estado del sistema
    CALL monitoreo_automatico();
    
    -- Generar reporte diario
    INSERT INTO reporte_mantenimiento (
        fecha, tipo_mantenimiento, estado, observaciones
    ) VALUES (
        CURDATE(), 'AUTOMATICO', 'COMPLETADO', 'Mantenimiento diario ejecutado correctamente'
    );
END;

-- 5. Procedimiento para sincronización de réplicas
DELIMITER //
CREATE PROCEDURE verificar_sincronizacion_replica()
BEGIN
    DECLARE replica_lag INT;
    DECLARE replica_status VARCHAR(50);
    
    -- Verificar estado de la réplica (ejemplo simplificado)
    -- En producción se usaría SHOW SLAVE STATUS
    
    -- Simular verificación
    SET replica_lag = 0;
    SET replica_status = 'RUNNING';
    
    -- Si hay retraso, crear alerta
    IF replica_lag > 300 THEN -- Más de 5 minutos
        INSERT INTO alertas_sistema (
            tipo_alerta, categoria, titulo, descripcion
        ) VALUES (
            'ADVERTENCIA', 'RENDIMIENTO',
            'Réplica con retraso',
            CONCAT('La réplica tiene un retraso de ', replica_lag, ' segundos')
        );
    END IF;
    
    -- Si la réplica no está funcionando
    IF replica_status != 'RUNNING' THEN
        INSERT INTO alertas_sistema (
            tipo_alerta, categoria, titulo, descripcion
        ) VALUES (
            'CRITICA', 'RENDIMIENTO',
            'Réplica no funcionando',
            CONCAT('Estado de la réplica: ', replica_status)
        );
    END IF;
END //
DELIMITER ;
```

## 📝 Resumen de Conceptos Clave
- ✅ La administración de bases de datos requiere planificación y automatización
- ✅ La seguridad debe implementarse en múltiples niveles
- ✅ El monitoreo continuo es esencial para detectar problemas temprano
- ✅ Los backups regulares son fundamentales para la recuperación
- ✅ La automatización reduce errores humanos y mejora la eficiencia
- ✅ El cumplimiento de regulaciones es obligatorio en entornos empresariales

## 🎉 ¡Felicidades! Has Completado el Nivel Senior

Has alcanzado el nivel de **Senior Database Professional**. Ahora tienes:

- ✅ Conocimientos avanzados de SQL y bases de datos
- ✅ Habilidades de administración y optimización
- ✅ Experiencia en seguridad y cumplimiento
- ✅ Capacidad para diseñar sistemas complejos
- ✅ Preparación para roles de liderazgo técnico

## 🔗 Recursos Adicionales
- **Proyectos Prácticos**: Implementa sistemas completos
- **Certificaciones**: Considera obtener certificaciones oficiales
- **Comunidad**: Participa en foros y conferencias
- **Mentoría**: Comparte tu conocimiento con otros

---

**💡 Consejo Final: La excelencia en bases de datos se logra con práctica continua, aprendizaje constante y pasión por resolver problemas complejos. ¡Sigue creciendo!**


