-- =====================================================
-- EJERCICIOS PRÁCTICOS - MÓDULO 2 MID-LEVEL
-- ADMINISTRACIÓN AVANZADA DE BASES DE DATOS
-- =====================================================

-- =====================================================
-- EJERCICIOS DE LA CLASE 1: SEGURIDAD Y AUTENTICACIÓN
-- =====================================================

-- Ejercicio 1: Crear usuarios con diferentes niveles de seguridad
CREATE USER 'admin_seguro'@'localhost' IDENTIFIED BY 'AdminPass123!@#';
ALTER USER 'admin_seguro'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;
SELECT user, host, password_expired FROM mysql.user WHERE user = 'admin_seguro';

-- Ejercicio 2: Implementar sistema de roles
CREATE ROLE 'desarrollador', 'analista', 'auditor';
GRANT SELECT, INSERT, UPDATE ON desarrollo.* TO 'desarrollador';
GRANT SELECT ON produccion.* TO 'analista';
GRANT SELECT ON mysql.* TO 'auditor';

-- Ejercicio 3: Encriptar datos sensibles
CREATE TABLE clientes_sensibles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    documento VARBINARY(255),
    telefono VARBINARY(255)
);
INSERT INTO clientes_sensibles (nombre, documento, telefono)
VALUES ('María García', AES_ENCRYPT('12345678', 'clave_docs'), AES_ENCRYPT('987654321', 'clave_tel'));

-- Ejercicio 4: Configurar auditoría completa
CREATE TABLE auditoria_completa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    accion VARCHAR(50),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detalles JSON
);

-- Ejercicio 5: Implementar políticas de contraseña
DELIMITER //
CREATE FUNCTION validar_password(password VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE resultado BOOLEAN DEFAULT FALSE;
    IF LENGTH(password) >= 8 AND password REGEXP '[A-Z]' AND 
       password REGEXP '[a-z]' AND password REGEXP '[0-9]' AND 
       password REGEXP '[!@#$%^&*(),.?":{}|<>]' THEN
        SET resultado = TRUE;
    END IF;
    RETURN resultado;
END //
DELIMITER ;

-- Ejercicio 6: Configurar conexiones SSL
SHOW VARIABLES LIKE 'ssl%';
CREATE USER 'usuario_ssl'@'%' IDENTIFIED BY 'Password123!' REQUIRE SSL;

-- Ejercicio 7: Implementar encriptación de conexiones
SET GLOBAL ssl_ca = '/path/to/ca.pem';
SET GLOBAL ssl_cert = '/path/to/server-cert.pem';
SET GLOBAL ssl_key = '/path/to/server-key.pem';

-- Ejercicio 8: Sistema de auditoría avanzado
CREATE TABLE sesiones_usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    estado ENUM('activa', 'cerrada', 'expirada') DEFAULT 'activa'
);

-- Ejercicio 9: Implementar encriptación de columnas
CREATE TABLE datos_empresa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_empresa VARCHAR(100),
    ruc VARBINARY(255),
    direccion VARBINARY(500)
);

-- Ejercicio 10: Sistema de seguridad completo
CREATE TABLE politicas_seguridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_politica VARCHAR(100),
    configuracion JSON,
    activa BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 2: USUARIOS Y ROLES
-- =====================================================

-- Ejercicio 1: Crear sistema de usuarios por departamento
CREATE USER 'hr_manager'@'localhost' IDENTIFIED BY 'HRManager123!';
CREATE USER 'finance_manager'@'localhost' IDENTIFIED BY 'FinanceManager123!';
CREATE ROLE 'hr_role', 'finance_role';
GRANT SELECT, INSERT, UPDATE ON empresa.empleados TO 'hr_role';
GRANT SELECT, INSERT, UPDATE ON empresa.nominas TO 'finance_role';

-- Ejercicio 2: Implementar roles con herencia
CREATE ROLE 'usuario_base', 'usuario_avanzado', 'usuario_experto';
GRANT SELECT ON empresa.* TO 'usuario_base';
GRANT 'usuario_base' TO 'usuario_avanzado';
GRANT SELECT, INSERT, UPDATE ON empresa.* TO 'usuario_avanzado';

-- Ejercicio 3: Sistema de permisos temporales
CREATE TABLE permisos_temporales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    permiso VARCHAR(100),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 4: Gestión de contraseñas con historial
CREATE TABLE historial_passwords (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    password_hash VARCHAR(255),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 5: Sistema de bloqueo de cuentas
CREATE TABLE intentos_login (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    ip_origen VARCHAR(45),
    fecha_intento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    exitoso BOOLEAN DEFAULT FALSE
);

-- Ejercicio 6: Permisos por horario
CREATE TABLE horarios_acceso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    dia_semana ENUM('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'),
    hora_inicio TIME,
    hora_fin TIME,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 7: Sistema de delegación de permisos
CREATE TABLE delegacion_permisos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_delegador VARCHAR(100),
    usuario_delegado VARCHAR(100),
    permiso VARCHAR(100),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 8: Auditoría de cambios de permisos
CREATE TABLE auditoria_permisos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    accion VARCHAR(50),
    permiso VARCHAR(100),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detalles JSON
);

-- Ejercicio 9: Sistema de roles dinámicos
CREATE TABLE roles_dinamicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_rol VARCHAR(100),
    condiciones JSON,
    permisos JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 10: Sistema completo de gestión de usuarios
CREATE TABLE perfiles_usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    perfil ENUM('basico', 'intermedio', 'avanzado', 'administrador'),
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 3: BACKUP Y RECUPERACIÓN
-- =====================================================

-- Ejercicio 1: Sistema de backup completo
CREATE TABLE backup_completo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    duracion_minutos INT,
    estado ENUM('INICIADO', 'COMPLETADO', 'ERROR') DEFAULT 'INICIADO'
);

-- Ejercicio 2: Backup incremental con control
CREATE TABLE backup_incremental (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo VARCHAR(255),
    posicion_binlog_inicio VARCHAR(50),
    posicion_binlog_fin VARCHAR(50),
    estado ENUM('INICIADO', 'COMPLETADO', 'ERROR') DEFAULT 'INICIADO'
);

-- Ejercicio 3: Sistema de retención de backups
CREATE TABLE politicas_retencion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    retencion_dias INT,
    comprimir BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 4: Recuperación punto en tiempo
CREATE TABLE recuperaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_objetivo DATETIME,
    tipo_recuperacion ENUM('COMPLETA', 'PUNTO_TIEMPO', 'TABLA_ESPECIFICA'),
    estado ENUM('SOLICITADA', 'EN_PROCESO', 'COMPLETADA', 'ERROR'),
    observaciones TEXT
);

-- Ejercicio 5: Monitoreo y alertas de backup
CREATE TABLE alertas_backup (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta ENUM('BACKUP_FALLIDO', 'BACKUP_TARDIO', 'ESPACIO_INSUFICIENTE'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    resuelto BOOLEAN DEFAULT FALSE
);

-- Ejercicio 6: Backup de tablas específicas
CREATE TABLE configuracion_tablas_backup (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tabla VARCHAR(100),
    frecuencia_backup ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_backup TIME,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 7: Sistema de compresión de backups
CREATE TABLE backups_comprimidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    archivo_original VARCHAR(255),
    archivo_comprimido VARCHAR(255),
    fecha_compresion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tamaño_original_mb DECIMAL(10,2),
    tamaño_comprimido_mb DECIMAL(10,2),
    ratio_compresion DECIMAL(5,2)
);

-- Ejercicio 8: Backup en la nube
CREATE TABLE configuracion_nube (
    id INT PRIMARY KEY AUTO_INCREMENT,
    proveedor ENUM('AWS_S3', 'GOOGLE_CLOUD', 'AZURE_BLOB'),
    bucket_nombre VARCHAR(100),
    region VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 9: Sistema de pruebas de recuperación
CREATE TABLE pruebas_recuperacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_prueba TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_prueba ENUM('COMPLETA', 'PUNTO_TIEMPO', 'TABLA_ESPECIFICA'),
    backup_utilizado VARCHAR(255),
    tiempo_recuperacion_minutos INT,
    resultado ENUM('EXITOSA', 'FALLIDA', 'PARCIAL')
);

-- Ejercicio 10: Sistema completo de gestión de backups
CREATE TABLE dashboard_backups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_backups_hoy INT,
    backups_exitosos_hoy INT,
    backups_fallidos_hoy INT,
    espacio_utilizado_gb DECIMAL(10,2),
    estado_sistema ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 4: REPLICACIÓN
-- =====================================================

-- Ejercicio 1: Configuración básica de replicación
CREATE TABLE configuracion_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    tipo_replicacion ENUM('MAESTRO_ESCLAVO', 'MAESTRO_MAESTRO', 'CIRCULAR'),
    servidor_maestro VARCHAR(100),
    usuario_replicacion VARCHAR(100),
    estado ENUM('ACTIVO', 'INACTIVO', 'ERROR') DEFAULT 'INACTIVO'
);

-- Ejercicio 2: Monitoreo avanzado de replicación
CREATE TABLE metricas_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    retraso_segundos INT,
    bytes_recibidos BIGINT,
    eventos_procesados INT,
    errores_io INT,
    errores_sql INT
);

-- Ejercicio 3: Sistema de failover automático
CREATE TABLE configuracion_failover (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_primario INT,
    servidor_secundario INT,
    tiempo_espera_segundos INT DEFAULT 30,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 4: Replicación selectiva por tabla
CREATE TABLE replicacion_selectiva (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tabla VARCHAR(100),
    replicar BOOLEAN DEFAULT TRUE,
    filtro_where TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 5: Replicación con compresión
CREATE TABLE estadisticas_compresion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bytes_sin_comprimir BIGINT,
    bytes_comprimidos BIGINT,
    ratio_compresion DECIMAL(5,2),
    tiempo_compresion_ms INT
);

-- Ejercicio 6: Replicación multi-maestro con resolución de conflictos
CREATE TABLE configuracion_multi_maestro (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    servidor_maestro VARCHAR(100),
    prioridad INT DEFAULT 1,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 7: Replicación con encriptación
CREATE TABLE configuracion_ssl_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    ssl_habilitado BOOLEAN DEFAULT TRUE,
    certificado_ca VARCHAR(255),
    certificado_cliente VARCHAR(255),
    clave_privada VARCHAR(255)
);

-- Ejercicio 8: Replicación con filtros de datos
CREATE TABLE filtros_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_filtro VARCHAR(100),
    tabla_origen VARCHAR(100),
    tabla_destino VARCHAR(100),
    condicion_where TEXT,
    transformacion JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 9: Sistema de balanceo de carga con replicación
CREATE TABLE configuracion_balanceo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    peso_balanceo INT DEFAULT 1,
    conexiones_activas INT DEFAULT 0,
    capacidad_maxima INT DEFAULT 100,
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO'
);

-- Ejercicio 10: Sistema completo de gestión de replicación
CREATE TABLE dashboard_replicacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidores_activos INT,
    servidores_con_error INT,
    retraso_promedio_segundos INT,
    throughput_total_mb_por_segundo DECIMAL(10,2),
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 5: CLUSTERING
-- =====================================================

-- Ejercicio 1: Configuración de cluster básico
CREATE TABLE configuracion_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    rol ENUM('PRIMARIO', 'SECUNDARIO', 'TERCIARIO'),
    ip_servidor VARCHAR(15),
    puerto INT DEFAULT 3306,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 2: Balanceo de carga
CREATE TABLE balanceo_carga (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    peso INT DEFAULT 1,
    conexiones_activas INT DEFAULT 0,
    capacidad_maxima INT DEFAULT 100,
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO'
);

-- Ejercicio 3: Monitoreo de alta disponibilidad
CREATE TABLE metricas_disponibilidad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uptime_porcentaje DECIMAL(5,2),
    tiempo_respuesta_promedio_ms INT,
    errores_por_hora INT,
    disponibilidad_objetivo DECIMAL(5,2) DEFAULT 99.9
);

-- Ejercicio 4: Sistema de health check
CREATE TABLE health_checks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('OK', 'WARNING', 'ERROR'),
    tiempo_respuesta_ms INT,
    detalles JSON
);

-- Ejercicio 5: Sistema de recuperación automática
CREATE TABLE recuperacion_automatica (
    id INT PRIMARY KEY AUTO_INCREMENT,
    servidor_id INT,
    fecha_recuperacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_recuperacion ENUM('REINICIO', 'REPARACION', 'RESTAURACION'),
    estado ENUM('INICIADA', 'COMPLETADA', 'FALLIDA'),
    tiempo_recuperacion_minutos INT
);

-- Ejercicio 6: Dashboard de cluster
CREATE TABLE dashboard_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidores_activos INT,
    servidores_inactivos INT,
    disponibilidad_promedio DECIMAL(5,2),
    carga_promedio DECIMAL(5,2),
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Ejercicio 7: Sistema de alertas inteligentes
CREATE TABLE alertas_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta VARCHAR(50),
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelto BOOLEAN DEFAULT FALSE
);

-- Ejercicio 8: Sistema de escalado automático
CREATE TABLE escalado_automatico (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_escalado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_escalado ENUM('ESCALAR_ARRIBA', 'ESCALAR_ABAJO'),
    servidores_afectados INT,
    razon TEXT,
    estado ENUM('INICIADO', 'COMPLETADO', 'FALLIDO') DEFAULT 'INICIADO'
);

-- Ejercicio 9: Sistema de backup en cluster
CREATE TABLE backup_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    servidor_origen INT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL'),
    archivo_backup VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    estado ENUM('INICIADO', 'COMPLETADO', 'ERROR') DEFAULT 'INICIADO'
);

-- Ejercicio 10: Sistema completo de gestión de cluster
CREATE TABLE configuracion_completa_cluster (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_cluster VARCHAR(100),
    version_configuracion VARCHAR(20),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 6: MONITOREO Y ALERTAS
-- =====================================================

-- Ejercicio 1: Sistema de monitoreo básico
CREATE TABLE metricas_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_porcentaje DECIMAL(5,2),
    memoria_porcentaje DECIMAL(5,2),
    disco_porcentaje DECIMAL(5,2),
    conexiones_activas INT,
    consultas_por_segundo DECIMAL(10,2)
);

-- Ejercicio 2: Sistema de alertas
CREATE TABLE alertas_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_alerta VARCHAR(50),
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelto BOOLEAN DEFAULT FALSE
);

-- Ejercicio 3: Dashboard de rendimiento
CREATE TABLE dashboard_rendimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_promedio DECIMAL(5,2),
    memoria_promedio DECIMAL(5,2),
    disco_promedio DECIMAL(5,2),
    conexiones_promedio INT,
    qps_promedio DECIMAL(10,2),
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Ejercicio 4: Monitoreo de consultas
CREATE TABLE monitoreo_consultas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_consulta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_consulta ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE'),
    tiempo_ejecucion_ms INT,
    filas_afectadas INT,
    usuario VARCHAR(100)
);

-- Ejercicio 5: Alertas por tendencia
CREATE TABLE tendencias_metricas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metrica VARCHAR(50),
    valor_actual DECIMAL(10,2),
    valor_anterior DECIMAL(10,2),
    cambio_porcentual DECIMAL(5,2),
    tendencia ENUM('CRECIENTE', 'DECRECIENTE', 'ESTABLE')
);

-- Ejercicio 6: Sistema de notificaciones
CREATE TABLE notificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_notificacion VARCHAR(50),
    mensaje TEXT,
    destinatario VARCHAR(100),
    metodo ENUM('EMAIL', 'SMS', 'WEBHOOK'),
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'ENVIADO', 'FALLIDO') DEFAULT 'PENDIENTE'
);

-- Ejercicio 7: Monitoreo de recursos
CREATE TABLE recursos_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cpu_cores INT,
    memoria_total_gb DECIMAL(10,2),
    disco_total_gb DECIMAL(10,2),
    red_entrada_mbps DECIMAL(10,2),
    red_salida_mbps DECIMAL(10,2)
);

-- Ejercicio 8: Dashboard en tiempo real
CREATE VIEW dashboard_tiempo_real AS
SELECT 
    'CPU' as metrica,
    cpu_porcentaje as valor,
    CASE 
        WHEN cpu_porcentaje > 90 THEN 'CRITICO'
        WHEN cpu_porcentaje > 70 THEN 'ADVERTENCIA'
        ELSE 'NORMAL'
    END as estado
FROM metricas_sistema
WHERE fecha_medicion = (SELECT MAX(fecha_medicion) FROM metricas_sistema);

-- Ejercicio 9: Sistema de umbrales dinámicos
CREATE TABLE umbrales_alertas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metrica VARCHAR(50),
    umbral_warning DECIMAL(10,2),
    umbral_critical DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 10: Sistema completo de monitoreo
CREATE TABLE configuracion_monitoreo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    metrica VARCHAR(100),
    intervalo_segundos INT,
    umbral_warning DECIMAL(10,2),
    umbral_critical DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 7: MANTENIMIENTO Y TUNING
-- =====================================================

-- Ejercicio 1: Sistema de mantenimiento automático
CREATE TABLE tareas_mantenimiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tarea VARCHAR(100),
    descripcion TEXT,
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    activo BOOLEAN DEFAULT TRUE,
    ultima_ejecucion TIMESTAMP NULL,
    proxima_ejecucion TIMESTAMP NULL
);

-- Ejercicio 2: Optimización de consultas
CREATE TABLE consultas_lentas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    consulta_sql TEXT,
    tiempo_ejecucion_ms INT,
    filas_examinadas INT,
    filas_enviadas INT,
    usuario VARCHAR(100),
    base_datos VARCHAR(100)
);

-- Ejercicio 3: Mantenimiento de índices
CREATE TABLE analisis_indices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    indice VARCHAR(100),
    cardinalidad INT,
    fragmentacion DECIMAL(5,2),
    uso_porcentaje DECIMAL(5,2),
    recomendacion TEXT,
    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 4: Limpieza de datos antiguos
CREATE TABLE configuracion_limpieza (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    columna_fecha VARCHAR(100),
    retencion_dias INT,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 5: Optimización de parámetros
CREATE TABLE configuracion_parametros (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parametro VARCHAR(100),
    valor_actual VARCHAR(100),
    valor_recomendado VARCHAR(100),
    descripcion TEXT,
    impacto ENUM('BAJO', 'MEDIO', 'ALTO') DEFAULT 'MEDIO'
);

-- Ejercicio 6: Compresión de datos
CREATE TABLE configuracion_compresion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    comprimir BOOLEAN DEFAULT FALSE,
    algoritmo ENUM('ROW', 'PAGE', 'NONE') DEFAULT 'ROW',
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 7: Actualización de estadísticas
CREATE TABLE estadisticas_tablas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    filas_estimadas BIGINT,
    tamaño_mb DECIMAL(10,2),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 8: Sistema de tuning automático
CREATE TABLE tuning_automatico (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_analisis TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metrica VARCHAR(100),
    valor_actual DECIMAL(10,2),
    valor_objetivo DECIMAL(10,2),
    accion_recomendada TEXT,
    ejecutado BOOLEAN DEFAULT FALSE
);

-- Ejercicio 9: Mantenimiento de logs
CREATE TABLE configuracion_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_log VARCHAR(100),
    ubicacion VARCHAR(255),
    retencion_dias INT,
    comprimir BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 10: Sistema completo de mantenimiento
CREATE TABLE configuracion_mantenimiento_completo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    tarea VARCHAR(100),
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    activo BOOLEAN DEFAULT TRUE,
    configuracion JSON
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 8: MIGRACIÓN DE DATOS
-- =====================================================

-- Ejercicio 1: Sistema de migración básico
CREATE TABLE configuracion_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_migracion VARCHAR(100),
    tabla_origen VARCHAR(100),
    tabla_destino VARCHAR(100),
    estado ENUM('PENDIENTE', 'EN_PROCESO', 'COMPLETADA', 'ERROR') DEFAULT 'PENDIENTE',
    fecha_inicio TIMESTAMP NULL,
    fecha_fin TIMESTAMP NULL,
    registros_migrados INT DEFAULT 0,
    registros_totales INT DEFAULT 0
);

-- Ejercicio 2: Migración con validación
CREATE TABLE validacion_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    tipo_validacion ENUM('CONTEO', 'INTEGRIDAD', 'FORMATO', 'REFERENCIAL'),
    resultado ENUM('EXITOSO', 'FALLIDO', 'ADVERTENCIA'),
    detalles TEXT,
    fecha_validacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 3: Migración incremental
CREATE TABLE migracion_incremental (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla VARCHAR(100),
    ultima_migracion TIMESTAMP,
    registros_migrados INT,
    estado ENUM('ACTIVO', 'PAUSADO', 'COMPLETADO') DEFAULT 'ACTIVO'
);

-- Ejercicio 4: Migración por lotes
CREATE TABLE control_lotes_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    numero_lote INT,
    registros_lote INT,
    fecha_procesamiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'PROCESANDO', 'COMPLETADO', 'ERROR') DEFAULT 'PENDIENTE'
);

-- Ejercicio 5: Migración con mapeo de campos
CREATE TABLE mapeo_campos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    campo_origen VARCHAR(100),
    campo_destino VARCHAR(100),
    transformacion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 6: Migración con rollback
CREATE TABLE rollback_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    fecha_rollback TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    estado ENUM('INICIADO', 'COMPLETADO', 'FALLIDO') DEFAULT 'INICIADO'
);

-- Ejercicio 7: Migración con verificación de integridad
CREATE TABLE verificacion_integridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    tabla VARCHAR(100),
    tipo_verificacion VARCHAR(100),
    resultado ENUM('EXITOSO', 'FALLIDO'),
    detalles TEXT,
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 8: Migración con logging detallado
CREATE TABLE log_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    nivel_log ENUM('INFO', 'WARNING', 'ERROR'),
    mensaje TEXT,
    fecha_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 9: Migración con resolución de conflictos
CREATE TABLE conflictos_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    migracion_id INT,
    registro_id VARCHAR(100),
    tipo_conflicto ENUM('DUPLICADO', 'FORMATO', 'REFERENCIAL'),
    descripcion TEXT,
    resolucion ENUM('AUTOMATICA', 'MANUAL', 'PENDIENTE') DEFAULT 'PENDIENTE',
    fecha_conflicto TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 10: Sistema completo de migración
CREATE TABLE configuracion_migracion_completa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proyecto VARCHAR(100),
    descripcion TEXT,
    configuracion JSON,
    estado ENUM('PLANIFICADO', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO') DEFAULT 'PLANIFICADO',
    fecha_inicio TIMESTAMP NULL,
    fecha_fin TIMESTAMP NULL
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 9: DISASTER RECOVERY
-- =====================================================

-- Ejercicio 1: Plan de disaster recovery
CREATE TABLE planes_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_plan VARCHAR(100),
    descripcion TEXT,
    rto_minutos INT,
    rpo_minutos INT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 2: Procedimientos de recuperación
CREATE TABLE procedimientos_recuperacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    nombre_procedimiento VARCHAR(100),
    descripcion TEXT,
    orden_ejecucion INT,
    tiempo_estimado_minutos INT,
    dependencias JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 3: Sistema de monitoreo de disaster recovery
CREATE TABLE monitoreo_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_sistema ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO', 'FALLO'),
    tiempo_respuesta_ms INT,
    disponibilidad_porcentaje DECIMAL(5,2),
    observaciones TEXT
);

-- Ejercicio 4: Plan de recuperación automático
CREATE TABLE configuracion_recuperacion_automatica (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    umbral_disponibilidad DECIMAL(5,2),
    tiempo_espera_minutos INT,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 5: Sistema de alertas de disaster recovery
CREATE TABLE alertas_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_alerta VARCHAR(100),
    descripcion TEXT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resuelto BOOLEAN DEFAULT FALSE
);

-- Ejercicio 6: Pruebas de disaster recovery
CREATE TABLE pruebas_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_prueba ENUM('COMPLETA', 'PARCIAL', 'SIMULADA'),
    fecha_prueba TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duracion_minutos INT,
    resultado ENUM('EXITOSA', 'FALLIDA', 'PARCIAL'),
    observaciones TEXT
);

-- Ejercicio 7: Sistema de notificaciones de emergencia
CREATE TABLE notificaciones_emergencia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_notificacion ENUM('EMAIL', 'SMS', 'WEBHOOK', 'TELEFONO'),
    destinatario VARCHAR(100),
    mensaje TEXT,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'ENVIADO', 'FALLIDO') DEFAULT 'PENDIENTE'
);

-- Ejercicio 8: Dashboard de disaster recovery
CREATE TABLE dashboard_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    planes_activos INT,
    planes_criticos INT,
    planes_fallo INT,
    disponibilidad_promedio DECIMAL(5,2),
    tiempo_respuesta_promedio_ms INT,
    estado_general ENUM('NORMAL', 'ADVERTENCIA', 'CRITICO') DEFAULT 'NORMAL'
);

-- Ejercicio 9: Sistema de backup para disaster recovery
CREATE TABLE backups_disaster_recovery (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT,
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    ubicacion_backup VARCHAR(255),
    tamaño_mb DECIMAL(10,2),
    fecha_backup TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('CREANDO', 'COMPLETADO', 'ERROR') DEFAULT 'CREANDO'
);

-- Ejercicio 10: Sistema completo de disaster recovery
CREATE TABLE configuracion_disaster_recovery_completa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_sistema VARCHAR(100),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_configuracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- EJERCICIOS DE LA CLASE 10: PROYECTO INTEGRADOR
-- =====================================================

-- Ejercicio 1: Estructura base del sistema
CREATE DATABASE sistema_administracion_db;
USE sistema_administracion_db;

CREATE TABLE configuracion_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 2: Sistema de seguridad integrado
CREATE TABLE politicas_seguridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_politica VARCHAR(100),
    descripcion TEXT,
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 3: Sistema de gestión de usuarios avanzado
CREATE TABLE usuarios_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100) UNIQUE,
    email VARCHAR(100),
    perfil ENUM('ADMINISTRADOR', 'OPERADOR', 'AUDITOR', 'DESARROLLADOR'),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP NULL
);

-- Ejercicio 4: Sistema de backup y recuperación integrado
CREATE TABLE configuracion_backup_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_backup VARCHAR(100),
    tipo_backup ENUM('COMPLETO', 'INCREMENTAL', 'DIFERENCIAL'),
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    retencion_dias INT,
    compresion BOOLEAN DEFAULT TRUE,
    encriptacion BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 5: Sistema de replicación y clustering
CREATE TABLE configuracion_replicacion_integrada (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_cluster VARCHAR(100),
    tipo_replicacion ENUM('MAESTRO_ESCLAVO', 'MAESTRO_MAESTRO', 'CIRCULAR'),
    servidores JSON,
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 6: Sistema de monitoreo integral
CREATE TABLE metricas_sistema_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    metrica VARCHAR(100),
    valor DECIMAL(10,2),
    umbral_warning DECIMAL(10,2),
    umbral_critical DECIMAL(10,2),
    fecha_medicion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ejercicio 7: Sistema de mantenimiento automático
CREATE TABLE tareas_mantenimiento_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_tarea VARCHAR(100),
    componente VARCHAR(100),
    frecuencia ENUM('DIARIO', 'SEMANAL', 'MENSUAL'),
    hora_ejecucion TIME,
    procedimiento VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 8: Sistema de migración integrado
CREATE TABLE proyectos_migracion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proyecto VARCHAR(100),
    descripcion TEXT,
    estado ENUM('PLANIFICADO', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO'),
    fecha_inicio TIMESTAMP NULL,
    fecha_fin TIMESTAMP NULL,
    configuracion JSON
);

-- Ejercicio 9: Sistema de disaster recovery integrado
CREATE TABLE planes_disaster_recovery_integrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_plan VARCHAR(100),
    descripcion TEXT,
    rto_minutos INT,
    rpo_minutos INT,
    nivel_critico ENUM('BAJO', 'MEDIO', 'ALTO', 'CRITICO'),
    procedimientos JSON,
    activo BOOLEAN DEFAULT TRUE
);

-- Ejercicio 10: Sistema de gestión integral
CREATE TABLE configuracion_integral (
    id INT PRIMARY KEY AUTO_INCREMENT,
    componente VARCHAR(100),
    configuracion JSON,
    activo BOOLEAN DEFAULT TRUE,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN
-- =====================================================

-- Verificar todas las tablas creadas
SHOW TABLES;

-- Verificar estructura de tablas principales
DESCRIBE politicas_seguridad;
DESCRIBE usuarios_sistema;
DESCRIBE configuracion_backup_integrado;
DESCRIBE configuracion_replicacion_integrada;
DESCRIBE metricas_sistema_integrado;

-- Verificar configuraciones
SELECT * FROM configuracion_sistema WHERE activo = TRUE;
SELECT * FROM politicas_seguridad WHERE activo = TRUE;
SELECT * FROM configuracion_backup_integrado WHERE activo = TRUE;

-- =====================================================
-- PROCEDIMIENTOS DE PRUEBA
-- =====================================================

-- Procedimiento para probar el sistema completo
DELIMITER //
CREATE PROCEDURE probar_sistema_completo()
BEGIN
    DECLARE v_tablas_creadas INT;
    DECLARE v_configuraciones_activas INT;
    
    -- Contar tablas creadas
    SELECT COUNT(*) INTO v_tablas_creadas
    FROM information_schema.tables
    WHERE table_schema = DATABASE();
    
    -- Contar configuraciones activas
    SELECT COUNT(*) INTO v_configuraciones_activas
    FROM configuracion_sistema
    WHERE activo = TRUE;
    
    -- Mostrar resumen
    SELECT 
        'Sistema de Administración de Bases de Datos' as sistema,
        v_tablas_creadas as tablas_creadas,
        v_configuraciones_activas as configuraciones_activas,
        'SISTEMA LISTO' as estado,
        NOW() as fecha_verificacion;
END //
DELIMITER ;

-- Ejecutar prueba del sistema
CALL probar_sistema_completo();

-- =====================================================
-- FIN DE EJERCICIOS PRÁCTICOS
-- =====================================================
