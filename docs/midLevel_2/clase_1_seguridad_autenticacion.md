# Clase 1: Seguridad y Autenticación - Nivel Mid-Level

## Introducción
La seguridad en bases de datos es fundamental para proteger la información sensible. En esta clase aprenderemos sobre autenticación, autorización, encriptación y mejores prácticas de seguridad.

## Conceptos Clave

### Autenticación
**Definición**: Proceso de verificar la identidad de un usuario o sistema.
**Tipos**:
- Autenticación por contraseña
- Autenticación por certificados
- Autenticación por tokens
- Autenticación multifactor

### Autorización
**Definición**: Proceso de determinar qué acciones puede realizar un usuario autenticado.
**Componentes**:
- Roles y permisos
- Privilegios de base de datos
- Privilegios de objeto
- Privilegios de sistema

### Encriptación
**Definición**: Proceso de convertir datos legibles en formato ilegible para proteger la información.
**Tipos**:
- Encriptación en tránsito
- Encriptación en reposo
- Encriptación de columnas
- Encriptación de conexiones

## Ejemplos Prácticos

### 1. Configuración de Autenticación Segura

```sql
-- Crear usuario con autenticación segura
CREATE USER 'admin_seguro'@'localhost' 
IDENTIFIED BY 'Password123!@#';

-- Configurar políticas de contraseña
ALTER USER 'admin_seguro'@'localhost' 
PASSWORD EXPIRE INTERVAL 90 DAY;

-- Habilitar autenticación multifactor
ALTER USER 'admin_seguro'@'localhost' 
ADD FACTOR 2 IDENTIFIED BY '123456';
```

**Explicación línea por línea**:
- `CREATE USER`: Crea un nuevo usuario en el sistema
- `'admin_seguro'@'localhost'`: Define el nombre de usuario y el host permitido
- `IDENTIFIED BY`: Establece la contraseña del usuario
- `PASSWORD EXPIRE`: Configura la expiración de contraseña
- `ADD FACTOR 2`: Agrega autenticación de segundo factor

### 2. Configuración de Roles y Permisos

```sql
-- Crear roles específicos
CREATE ROLE 'lector_datos';
CREATE ROLE 'editor_datos';
CREATE ROLE 'administrador_datos';

-- Asignar permisos a roles
GRANT SELECT ON empresa.* TO 'lector_datos';
GRANT SELECT, INSERT, UPDATE ON empresa.* TO 'editor_datos';
GRANT ALL PRIVILEGES ON empresa.* TO 'administrador_datos';

-- Asignar roles a usuarios
GRANT 'lector_datos' TO 'usuario_consulta'@'localhost';
GRANT 'editor_datos' TO 'usuario_edicion'@'localhost';
```

**Explicación línea por línea**:
- `CREATE ROLE`: Crea un rol que agrupa permisos
- `GRANT SELECT`: Otorga permisos de lectura
- `GRANT ALL PRIVILEGES`: Otorga todos los permisos
- `GRANT 'rol' TO 'usuario'`: Asigna un rol a un usuario

### 3. Encriptación de Datos

```sql
-- Crear tabla con encriptación de columnas
CREATE TABLE usuarios_sensibles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    datos_sensibles VARBINARY(255)
);

-- Insertar datos encriptados
INSERT INTO usuarios_sensibles (nombre, email, telefono, datos_sensibles)
VALUES (
    'Juan Pérez',
    'juan@email.com',
    '1234567890',
    AES_ENCRYPT('Información confidencial', 'clave_secreta')
);

-- Consultar datos desencriptados
SELECT 
    nombre,
    email,
    telefono,
    AES_DECRYPT(datos_sensibles, 'clave_secreta') as datos_desencriptados
FROM usuarios_sensibles;
```

**Explicación línea por línea**:
- `VARBINARY(255)`: Tipo de dato para almacenar datos binarios encriptados
- `AES_ENCRYPT()`: Función para encriptar datos usando AES
- `AES_DECRYPT()`: Función para desencriptar datos
- `'clave_secreta'`: Clave de encriptación

### 4. Configuración de Conexiones Seguras

```sql
-- Configurar SSL para conexiones
SHOW VARIABLES LIKE 'ssl%';

-- Verificar conexiones SSL activas
SELECT 
    user,
    host,
    ssl_cipher,
    ssl_version
FROM information_schema.processlist
WHERE ssl_cipher IS NOT NULL;

-- Configurar conexiones seguras por defecto
SET GLOBAL require_secure_transport = ON;
```

**Explicación línea por línea**:
- `SHOW VARIABLES LIKE 'ssl%'`: Muestra configuraciones SSL
- `information_schema.processlist`: Vista que muestra procesos activos
- `ssl_cipher`: Algoritmo de encriptación SSL usado
- `require_secure_transport`: Requiere conexiones SSL

### 5. Auditoría de Seguridad

```sql
-- Crear tabla de auditoría
CREATE TABLE auditoria_seguridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    accion VARCHAR(50),
    tabla_afectada VARCHAR(100),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    detalles TEXT
);

-- Trigger para auditoría de INSERT
DELIMITER //
CREATE TRIGGER auditoria_insert_usuarios
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_seguridad (
        usuario, accion, tabla_afectada, ip_origen, detalles
    ) VALUES (
        USER(), 'INSERT', 'usuarios', 
        CONNECTION_ID(),
        CONCAT('Nuevo usuario: ', NEW.nombre)
    );
END //
DELIMITER ;
```

**Explicación línea por línea**:
- `auditoria_seguridad`: Tabla para registrar eventos de seguridad
- `TRIGGER`: Disparador que se ejecuta automáticamente
- `AFTER INSERT`: Se ejecuta después de un INSERT
- `USER()`: Función que retorna el usuario actual
- `CONNECTION_ID()`: ID de la conexión actual

## Ejercicios Prácticos

### Ejercicio 1: Crear Usuarios con Diferentes Niveles de Seguridad
```sql
-- Crear usuario con contraseña segura
CREATE USER 'usuario_seguro'@'localhost' 
IDENTIFIED BY 'MiPassword123!@#';

-- Configurar expiración de contraseña
ALTER USER 'usuario_seguro'@'localhost' 
PASSWORD EXPIRE INTERVAL 60 DAY;

-- Verificar configuración
SELECT user, host, password_expired, password_last_changed
FROM mysql.user 
WHERE user = 'usuario_seguro';
```

### Ejercicio 2: Implementar Sistema de Roles
```sql
-- Crear roles para diferentes funciones
CREATE ROLE 'desarrollador';
CREATE ROLE 'analista';
CREATE ROLE 'auditor';

-- Asignar permisos específicos
GRANT SELECT, INSERT, UPDATE ON desarrollo.* TO 'desarrollador';
GRANT SELECT ON produccion.* TO 'analista';
GRANT SELECT ON mysql.* TO 'auditor';

-- Asignar roles a usuarios
GRANT 'desarrollador' TO 'dev1'@'localhost';
GRANT 'analista' TO 'analista1'@'localhost';
```

### Ejercicio 3: Encriptar Datos Sensibles
```sql
-- Crear tabla con datos encriptados
CREATE TABLE clientes_sensibles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    documento VARBINARY(255),
    telefono VARBINARY(255),
    email VARBINARY(255)
);

-- Insertar datos encriptados
INSERT INTO clientes_sensibles (nombre, documento, telefono, email)
VALUES (
    'María García',
    AES_ENCRYPT('12345678', 'clave_documentos'),
    AES_ENCRYPT('987654321', 'clave_telefonos'),
    AES_ENCRYPT('maria@email.com', 'clave_emails')
);
```

### Ejercicio 4: Configurar Auditoría Completa
```sql
-- Crear tabla de auditoría detallada
CREATE TABLE auditoria_completa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    accion VARCHAR(50),
    esquema VARCHAR(100),
    tabla VARCHAR(100),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valores_anteriores JSON,
    valores_nuevos JSON,
    ip_origen VARCHAR(45)
);

-- Trigger para auditoría de UPDATE
DELIMITER //
CREATE TRIGGER auditoria_update_clientes
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_completa (
        usuario, accion, esquema, tabla, 
        valores_anteriores, valores_nuevos, ip_origen
    ) VALUES (
        USER(), 'UPDATE', DATABASE(), 'clientes',
        JSON_OBJECT('nombre', OLD.nombre, 'email', OLD.email),
        JSON_OBJECT('nombre', NEW.nombre, 'email', NEW.email),
        CONNECTION_ID()
    );
END //
DELIMITER ;
```

### Ejercicio 5: Implementar Políticas de Contraseña
```sql
-- Crear función para validar contraseñas
DELIMITER //
CREATE FUNCTION validar_password(password VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE resultado BOOLEAN DEFAULT FALSE;
    
    -- Verificar longitud mínima
    IF LENGTH(password) >= 8 THEN
        -- Verificar que contenga mayúscula
        IF password REGEXP '[A-Z]' THEN
            -- Verificar que contenga minúscula
            IF password REGEXP '[a-z]' THEN
                -- Verificar que contenga número
                IF password REGEXP '[0-9]' THEN
                    -- Verificar que contenga carácter especial
                    IF password REGEXP '[!@#$%^&*(),.?":{}|<>]' THEN
                        SET resultado = TRUE;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    
    RETURN resultado;
END //
DELIMITER ;

-- Usar la función en trigger
DELIMITER //
CREATE TRIGGER validar_password_usuario
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    IF NOT validar_password(NEW.password) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La contraseña no cumple con los requisitos de seguridad';
    END IF;
END //
DELIMITER ;
```

### Ejercicio 6: Configurar Conexiones SSL
```sql
-- Verificar estado SSL
SHOW VARIABLES LIKE 'have_ssl';
SHOW VARIABLES LIKE 'ssl_ca';
SHOW VARIABLES LIKE 'ssl_cert';
SHOW VARIABLES LIKE 'ssl_key';

-- Configurar usuario que requiere SSL
CREATE USER 'usuario_ssl'@'%' 
IDENTIFIED BY 'Password123!'
REQUIRE SSL;

-- Verificar conexiones SSL
SELECT 
    user,
    host,
    ssl_cipher,
    ssl_version,
    ssl_cert
FROM information_schema.processlist
WHERE user = 'usuario_ssl';
```

### Ejercicio 7: Implementar Encriptación de Conexiones
```sql
-- Configurar variables SSL
SET GLOBAL ssl_ca = '/path/to/ca.pem';
SET GLOBAL ssl_cert = '/path/to/server-cert.pem';
SET GLOBAL ssl_key = '/path/to/server-key.pem';

-- Verificar configuración SSL
SHOW VARIABLES LIKE 'ssl%';

-- Crear usuario con certificado específico
CREATE USER 'usuario_certificado'@'%' 
IDENTIFIED BY 'Password123!'
REQUIRE X509;
```

### Ejercicio 8: Sistema de Auditoría Avanzado
```sql
-- Crear tabla de sesiones
CREATE TABLE sesiones_usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(100),
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP NULL,
    ip_origen VARCHAR(45),
    user_agent TEXT,
    estado ENUM('activa', 'cerrada', 'expirada') DEFAULT 'activa'
);

-- Trigger para registrar inicio de sesión
DELIMITER //
CREATE TRIGGER registrar_sesion
AFTER INSERT ON mysql.user
FOR EACH ROW
BEGIN
    INSERT INTO sesiones_usuarios (usuario, ip_origen)
    VALUES (NEW.user, CONNECTION_ID());
END //
DELIMITER ;
```

### Ejercicio 9: Implementar Encriptación de Columnas
```sql
-- Crear tabla con múltiples columnas encriptadas
CREATE TABLE datos_empresa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_empresa VARCHAR(100),
    ruc VARBINARY(255),
    direccion VARBINARY(500),
    telefono VARBINARY(255),
    email VARBINARY(255),
    clave_encriptacion VARCHAR(100)
);

-- Función para encriptar con clave dinámica
DELIMITER //
CREATE FUNCTION encriptar_dato(dato TEXT, clave VARCHAR(100))
RETURNS VARBINARY(255)
DETERMINISTIC
BEGIN
    RETURN AES_ENCRYPT(dato, clave);
END //
DELIMITER ;

-- Insertar datos con encriptación
INSERT INTO datos_empresa (nombre_empresa, ruc, direccion, telefono, email, clave_encriptacion)
VALUES (
    'Mi Empresa S.A.',
    encriptar_dato('12345678901', 'clave_ruc'),
    encriptar_dato('Av. Principal 123', 'clave_direccion'),
    encriptar_dato('987654321', 'clave_telefono'),
    encriptar_dato('empresa@email.com', 'clave_email'),
    'clave_maestra'
);
```

### Ejercicio 10: Sistema de Seguridad Completo
```sql
-- Crear tabla de políticas de seguridad
CREATE TABLE politicas_seguridad (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_politica VARCHAR(100),
    descripcion TEXT,
    configuracion JSON,
    activa BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar políticas
INSERT INTO politicas_seguridad (nombre_politica, descripcion, configuracion)
VALUES 
('Política de Contraseñas', 'Requisitos para contraseñas seguras', 
 JSON_OBJECT('longitud_minima', 8, 'requiere_mayuscula', true, 'requiere_numero', true)),
('Política de Sesiones', 'Configuración de sesiones de usuario',
 JSON_OBJECT('tiempo_expiracion', 3600, 'max_intentos', 3, 'bloqueo_temporal', true));

-- Función para aplicar políticas
DELIMITER //
CREATE FUNCTION aplicar_politica_seguridad(usuario VARCHAR(100), politica VARCHAR(100))
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE resultado BOOLEAN DEFAULT FALSE;
    DECLARE config JSON;
    
    SELECT configuracion INTO config
    FROM politicas_seguridad
    WHERE nombre_politica = politica AND activa = TRUE;
    
    -- Aplicar lógica de política aquí
    SET resultado = TRUE;
    
    RETURN resultado;
END //
DELIMITER ;
```

## Resumen
En esta clase hemos aprendido sobre:
- Configuración de autenticación segura
- Implementación de roles y permisos
- Encriptación de datos y conexiones
- Sistemas de auditoría
- Políticas de seguridad
- Mejores prácticas de seguridad en bases de datos

## Próxima Clase
En la siguiente clase aprenderemos sobre administración avanzada de usuarios y roles, incluyendo gestión de permisos granulares y sistemas de autenticación distribuida.
