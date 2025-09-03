# 🔶 Mid Level 2: Administración y Mantenimiento de Bases de Datos

## 🧭 Navegación del Curso

**← Anterior**: [Mid Level 1: Consultas Avanzadas y Optimización](../midLevel_1/README.md)  
**Siguiente →**: [Mid Level 3: Funciones Agregadas](../midLevel_3/README.md)

---

## 📖 Teoría

### ¿Qué es la Administración de Bases de Datos?
La administración de bases de datos es el proceso de gestionar, mantener y optimizar sistemas de bases de datos para garantizar su disponibilidad, rendimiento y seguridad. Incluye tareas como backup, recuperación, monitoreo, mantenimiento y gestión de usuarios.

### Áreas de Administración
1. **Seguridad**: Autenticación, autorización, encriptación
2. **Backup y Recuperación**: Estrategias de respaldo y restauración
3. **Replicación**: Sincronización de datos entre servidores
4. **Clustering**: Agrupación de servidores para alta disponibilidad
5. **Monitoreo**: Supervisión de rendimiento y alertas
6. **Mantenimiento**: Optimización y limpieza de bases de datos
7. **Migración**: Transferencia de datos entre sistemas
8. **Disaster Recovery**: Planes de recuperación ante desastres

### Herramientas de Administración
- **MySQL**: MySQL Workbench, mysqladmin, mysqldump
- **PostgreSQL**: pgAdmin, pg_dump, pg_restore
- **SQL Server**: SQL Server Management Studio, SQL Server Agent
- **Oracle**: Oracle Enterprise Manager, RMAN

## 💡 Ejemplos Prácticos

### Ejemplo 1: Gestión de Usuarios
```sql
-- Crear usuario con permisos específicos
CREATE USER 'analista'@'localhost' IDENTIFIED BY 'password123';
GRANT SELECT, INSERT ON tienda_online.* TO 'analista'@'localhost';
GRANT UPDATE ON tienda_online.productos TO 'analista'@'localhost';
FLUSH PRIVILEGES;
```

### Ejemplo 2: Backup de Base de Datos
```sql
-- Backup completo de base de datos
mysqldump -u root -p --single-transaction --routines --triggers tienda_online > backup_tienda_$(date +%Y%m%d).sql

-- Backup de tablas específicas
mysqldump -u root -p tienda_online productos categorias > backup_productos.sql
```

### Ejemplo 3: Monitoreo de Rendimiento
```sql
-- Verificar procesos activos
SHOW PROCESSLIST;

-- Analizar consultas lentas
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';

-- Verificar uso de índices
SHOW INDEX FROM productos;
EXPLAIN SELECT * FROM productos WHERE categoria_id = 1;
```

### Ejemplo 4: Mantenimiento de Tablas
```sql
-- Optimizar tabla
OPTIMIZE TABLE productos;

-- Analizar tabla para estadísticas
ANALYZE TABLE productos;

-- Verificar integridad de tabla
CHECK TABLE productos;
REPAIR TABLE productos;
```

### Ejemplo 5: Configuración de Replicación
```sql
-- Configurar servidor maestro
CHANGE MASTER TO
    MASTER_HOST='192.168.1.100',
    MASTER_USER='replicador',
    MASTER_PASSWORD='replica123',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=154;

-- Iniciar replicación
START SLAVE;

-- Verificar estado de replicación
SHOW SLAVE STATUS\G
```

## 🎯 Ejercicios

### Ejercicio 1: Sistema de Seguridad
Implementa un sistema de seguridad completo para la base de datos `tienda_online`:

1. Crear usuarios con diferentes niveles de acceso
2. Configurar roles y permisos granulares
3. Implementar auditoría de accesos
4. Configurar encriptación de datos sensibles
5. Establecer políticas de contraseñas

**Solución:**
```sql
-- 1. Crear usuarios con diferentes niveles
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'AdminPass123!';
CREATE USER 'vendedor'@'localhost' IDENTIFIED BY 'VendedorPass123!';
CREATE USER 'cliente'@'localhost' IDENTIFIED BY 'ClientePass123!';

-- 2. Configurar roles
CREATE ROLE 'administrador';
CREATE ROLE 'vendedor_role';
CREATE ROLE 'cliente_role';

-- Asignar permisos a roles
GRANT ALL PRIVILEGES ON tienda_online.* TO 'administrador';
GRANT SELECT, INSERT, UPDATE ON tienda_online.productos TO 'vendedor_role';
GRANT SELECT ON tienda_online.productos TO 'cliente_role';

-- Asignar roles a usuarios
GRANT 'administrador' TO 'admin'@'localhost';
GRANT 'vendedor_role' TO 'vendedor'@'localhost';
GRANT 'cliente_role' TO 'cliente'@'localhost';

-- 3. Configurar auditoría
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50),
    accion VARCHAR(100),
    tabla VARCHAR(50),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Encriptar datos sensibles
ALTER TABLE clientes MODIFY COLUMN telefono VARBINARY(255);
UPDATE clientes SET telefono = AES_ENCRYPT(telefono, 'clave_secreta');

-- 5. Políticas de contraseñas
SET GLOBAL validate_password.policy = STRONG;
SET GLOBAL validate_password.length = 12;
```

### Ejercicio 2: Sistema de Backup
Implementa un sistema de backup automatizado para la base de datos `biblioteca_completa`:

1. Crear script de backup completo
2. Implementar backup incremental
3. Configurar rotación de backups
4. Crear script de restauración
5. Implementar verificación de integridad

**Solución:**
```sql
-- 1. Script de backup completo
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/biblioteca"
DB_NAME="biblioteca_completa"

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

# Backup completo
mysqldump -u root -p --single-transaction --routines --triggers \
    --master-data=2 $DB_NAME > $BACKUP_DIR/backup_completo_$DATE.sql

# 2. Backup incremental
mysqlbinlog --start-datetime="2024-01-01 00:00:00" \
    --stop-datetime="2024-01-02 00:00:00" \
    mysql-bin.000001 > $BACKUP_DIR/incremental_$DATE.sql

# 3. Rotación de backups (mantener últimos 30 días)
find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete

# 4. Script de restauración
mysql -u root -p $DB_NAME < $BACKUP_DIR/backup_completo_$DATE.sql

# 5. Verificación de integridad
mysqlcheck -u root -p --check --all-databases
```

### Ejercicio 3: Sistema de Monitoreo
Implementa un sistema de monitoreo para la base de datos `escuela_completa`:

1. Configurar logs de consultas lentas
2. Implementar monitoreo de conexiones
3. Crear alertas de espacio en disco
4. Configurar monitoreo de rendimiento
5. Implementar dashboard de métricas

**Solución:**
```sql
-- 1. Configurar logs de consultas lentas
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';

-- 2. Monitoreo de conexiones
CREATE TABLE connection_monitor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50),
    host VARCHAR(100),
    comando VARCHAR(20),
    tiempo TIME,
    estado VARCHAR(20),
    info TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Alertas de espacio en disco
SELECT 
    table_schema AS 'Base de Datos',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Tamaño (MB)'
FROM information_schema.tables
WHERE table_schema = 'escuela_completa'
GROUP BY table_schema;

-- 4. Monitoreo de rendimiento
SHOW GLOBAL STATUS LIKE 'Questions';
SHOW GLOBAL STATUS LIKE 'Uptime';
SHOW GLOBAL STATUS LIKE 'Threads_connected';

-- 5. Dashboard de métricas
CREATE VIEW performance_dashboard AS
SELECT 
    'Conexiones Activas' AS metric,
    VARIABLE_VALUE AS value
FROM information_schema.GLOBAL_STATUS 
WHERE VARIABLE_NAME = 'Threads_connected'
UNION ALL
SELECT 
    'Consultas por Segundo' AS metric,
    ROUND(VARIABLE_VALUE / (SELECT VARIABLE_VALUE FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME = 'Uptime'), 2) AS value
FROM information_schema.GLOBAL_STATUS 
WHERE VARIABLE_NAME = 'Questions';
```

### Ejercicio 4: Sistema de Mantenimiento
Implementa un sistema de mantenimiento automatizado para la base de datos `restaurante_completo`:

1. Crear script de limpieza de logs
2. Implementar optimización de tablas
3. Configurar limpieza de datos obsoletos
4. Crear script de actualización de estadísticas
5. Implementar verificación de integridad

**Solución:**
```sql
-- 1. Limpieza de logs
DELETE FROM audit_log WHERE fecha < DATE_SUB(NOW(), INTERVAL 90 DAY);
DELETE FROM error_log WHERE fecha < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- 2. Optimización de tablas
OPTIMIZE TABLE mesas, platos, pedidos, categorias_platos;

-- 3. Limpieza de datos obsoletos
DELETE FROM pedidos WHERE fecha_pedido < DATE_SUB(NOW(), INTERVAL 2 YEAR) AND estado = 'Cancelado';
DELETE FROM productos_pedido WHERE pedido_id NOT IN (SELECT id FROM pedidos);

-- 4. Actualización de estadísticas
ANALYZE TABLE mesas, platos, pedidos, categorias_platos;

-- 5. Verificación de integridad
CHECK TABLE mesas, platos, pedidos, categorias_platos;
REPAIR TABLE mesas, platos, pedidos, categorias_platos;
```

### Ejercicio 5: Sistema de Disaster Recovery
Implementa un sistema de disaster recovery para la base de datos `hospital_completo`:

1. Crear plan de recuperación ante desastres
2. Implementar replicación en tiempo real
3. Configurar failover automático
4. Crear script de recuperación de emergencia
5. Implementar verificación de consistencia

**Solución:**
```sql
-- 1. Plan de recuperación ante desastres
-- Configurar replicación maestro-esclavo
CHANGE MASTER TO
    MASTER_HOST='192.168.1.100',
    MASTER_USER='replicador',
    MASTER_PASSWORD='replica123',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=154;

-- 2. Replicación en tiempo real
START SLAVE;
SHOW SLAVE STATUS\G

-- 3. Failover automático
-- Script de monitoreo del maestro
#!/bin/bash
if ! mysqladmin ping -h 192.168.1.100 -u root -p --silent; then
    # Promover esclavo a maestro
    STOP SLAVE;
    RESET MASTER;
    # Notificar a aplicaciones
fi

-- 4. Recuperación de emergencia
-- Restaurar desde backup más reciente
mysql -u root -p hospital_completo < backup_emergencia.sql

-- 5. Verificación de consistencia
CHECKSUM TABLE doctores, pacientes, citas, tratamientos;
```

## 📝 Resumen de Conceptos Clave
- ✅ La administración de bases de datos es fundamental para la operación
- ✅ La seguridad incluye autenticación, autorización y encriptación
- ✅ Los backups son esenciales para la protección de datos
- ✅ El monitoreo permite detectar problemas proactivamente
- ✅ El mantenimiento mantiene el rendimiento óptimo
- ✅ La replicación proporciona alta disponibilidad
- ✅ El disaster recovery garantiza la continuidad del negocio

## 🔗 Próximo Nivel
Una vez que hayas completado todos los ejercicios de esta sección, continúa con `docs/midLevel_3` para aprender sobre funciones agregadas y GROUP BY.

---

**💡 Consejo: La administración de bases de datos es una habilidad crítica. Practica con diferentes escenarios y herramientas para desarrollar experiencia real.**