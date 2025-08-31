# 🚀 Senior Level 6: Bases de Datos para Plataformas de Matching Musical

## 🧭 Navegación del Curso

**← Anterior**: [Senior Level 5: Administración y Seguridad](../senior_5/README.md)  
**Siguiente →**: [Senior Level 7: Microservicios](../senior_7/README.md)

---

# 🎵 Senior Level 6: Bases de Datos para Plataformas de Matching Musical

## 📖 Teoría

### Plataformas de Matching Musical
Las plataformas de matching musical como **MussikOn** requieren bases de datos especializadas que manejen:
- **Perfiles de músicos** con habilidades, instrumentos y disponibilidad
- **Solicitudes de eventos** con requisitos específicos
- **Algoritmos de matching** basados en múltiples criterios
- **Sistema de calificaciones** y reputación
- **Gestión de pagos** y transacciones
- **Notificaciones en tiempo real** y chat

### Arquitectura de Base de Datos para Matching
- **Normalización avanzada** para evitar redundancia
- **Índices compuestos** para consultas de matching
- **Particionamiento** para grandes volúmenes de datos
- **Caching** para algoritmos de matching frecuentes
- **Sharding** para escalabilidad horizontal

### Patrones de Diseño para Matching
- **Entity-Aggregate Pattern**: Agrupar entidades relacionadas
- **Event Sourcing**: Rastrear cambios de estado
- **CQRS**: Separar consultas de comandos
- **Materialized Views**: Vistas pre-calculadas para matching

## 💡 Ejemplos Prácticos

### Ejemplo 1: Estructura de Base de Datos para MussikOn
```sql
-- Base de datos principal
CREATE DATABASE mussikon;
USE mussikon;

-- Tabla de usuarios
CREATE TABLE users (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type ENUM('client', 'musician', 'admin') NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    is_active BIT DEFAULT 1
);

-- Tabla de perfiles de músicos
CREATE TABLE musician_profiles (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    stage_name VARCHAR(100),
    bio TEXT,
    hourly_rate DECIMAL(10,2),
    experience_years INT,
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address NVARCHAR(500),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabla de habilidades musicales
CREATE TABLE musical_skills (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    category ENUM('instrument', 'genre', 'style') NOT NULL,
    description TEXT
);

-- Tabla de habilidades por músico
CREATE TABLE musician_skills (
    id INT PRIMARY KEY IDENTITY(1,1),
    musician_profile_id UNIQUEIDENTIFIER NOT NULL,
    skill_id INT NOT NULL,
    proficiency_level ENUM('beginner', 'intermediate', 'advanced', 'expert') NOT NULL,
    years_experience INT,
    FOREIGN KEY (musician_profile_id) REFERENCES musician_profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES musical_skills(id)
);

-- Tabla de solicitudes de eventos
CREATE TABLE musician_requests (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    client_id UNIQUEIDENTIFIER NOT NULL,
    title NVARCHAR(200) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    budget_min DECIMAL(10,2),
    budget_max DECIMAL(10,2),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address NVARCHAR(500),
    status ENUM('open', 'in_progress', 'assigned', 'completed', 'cancelled') DEFAULT 'open',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (client_id) REFERENCES users(id)
);

-- Tabla de requisitos de habilidades por solicitud
CREATE TABLE request_skill_requirements (
    id INT PRIMARY KEY IDENTITY(1,1),
    request_id UNIQUEIDENTIFIER NOT NULL,
    skill_id INT NOT NULL,
    required_level ENUM('beginner', 'intermediate', 'advanced', 'expert'),
    is_required BIT DEFAULT 1,
    FOREIGN KEY (request_id) REFERENCES musician_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES musical_skills(id)
);

-- Tabla de aplicaciones de músicos
CREATE TABLE musician_applications (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    request_id UNIQUEIDENTIFIER NOT NULL,
    musician_profile_id UNIQUEIDENTIFIER NOT NULL,
    proposed_rate DECIMAL(10,2),
    message TEXT,
    status ENUM('pending', 'accepted', 'rejected', 'withdrawn') DEFAULT 'pending',
    applied_at DATETIME2 DEFAULT GETDATE(),
    responded_at DATETIME2,
    FOREIGN KEY (request_id) REFERENCES musician_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (musician_profile_id) REFERENCES musician_profiles(id)
);
```

### Ejemplo 2: Índices Optimizados para Matching
```sql
-- Índices para consultas de matching frecuentes
CREATE INDEX idx_musician_location ON musician_profiles(location_lat, location_lng);
CREATE INDEX idx_musician_skills ON musician_skills(musician_profile_id, skill_id, proficiency_level);
CREATE INDEX idx_request_location ON musician_requests(location_lat, location_lng);
CREATE INDEX idx_request_date_status ON musician_requests(event_date, status);
CREATE INDEX idx_request_skills ON request_skill_requirements(request_id, skill_id, required_level);

-- Índices compuestos para algoritmos de matching
CREATE INDEX idx_musician_matching ON musician_profiles(
    location_lat, 
    location_lng, 
    hourly_rate, 
    experience_years
);

-- Índices para consultas de búsqueda
CREATE FULLTEXT INDEX idx_musician_search ON musician_profiles(stage_name, bio);
CREATE FULLTEXT INDEX idx_request_search ON musician_requests(title, description);
```

### Ejemplo 3: Algoritmo de Matching Avanzado
```sql
-- Procedimiento almacenado para matching de músicos
CREATE PROCEDURE FindMatchingMusicians
    @RequestId UNIQUEIDENTIFIER,
    @MaxDistance DECIMAL(10,2) = 50.0, -- km
    @MaxResults INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RequestLat DECIMAL(10,8), @RequestLng DECIMAL(11,8);
    DECLARE @RequestDate DATE, @StartTime TIME, @EndTime TIME;
    DECLARE @BudgetMin DECIMAL(10,2), @BudgetMax DECIMAL(10,2);
    
    -- Obtener detalles de la solicitud
    SELECT 
        @RequestLat = location_lat,
        @RequestLng = location_lng,
        @RequestDate = event_date,
        @StartTime = start_time,
        @EndTime = end_time,
        @BudgetMin = budget_min,
        @BudgetMax = budget_max
    FROM musician_requests 
    WHERE id = @RequestId;
    
    -- Buscar músicos disponibles con scoring
    WITH MusicianScores AS (
        SELECT 
            mp.id,
            mp.user_id,
            mp.stage_name,
            mp.hourly_rate,
            mp.experience_years,
            mp.location_lat,
            mp.location_lng,
            mp.location_address,
            -- Calcular distancia (fórmula de Haversine simplificada)
            (6371 * ACOS(
                COS(RADIANS(@RequestLat)) * 
                COS(RADIANS(mp.location_lat)) * 
                COS(RADIANS(mp.location_lng) - RADIANS(@RequestLng)) + 
                SIN(RADIANS(@RequestLat)) * 
                SIN(RADIANS(mp.location_lat))
            )) AS distance_km,
            -- Calcular score de habilidades
            ISNULL((
                SELECT COUNT(*) * 10
                FROM musician_skills ms
                INNER JOIN request_skill_requirements rsr ON ms.skill_id = rsr.skill_id
                WHERE ms.musician_profile_id = mp.id 
                AND rsr.request_id = @RequestId
                AND ms.proficiency_level >= rsr.required_level
            ), 0) AS skill_score,
            -- Calcular score de experiencia
            CASE 
                WHEN mp.experience_years >= 10 THEN 100
                WHEN mp.experience_years >= 5 THEN 80
                WHEN mp.experience_years >= 2 THEN 60
                WHEN mp.experience_years >= 1 THEN 40
                ELSE 20
            END AS experience_score,
            -- Calcular score de precio
            CASE 
                WHEN mp.hourly_rate BETWEEN @BudgetMin AND @BudgetMax THEN 100
                WHEN mp.hourly_rate <= @BudgetMax * 1.2 THEN 80
                WHEN mp.hourly_rate <= @BudgetMax * 1.5 THEN 60
                ELSE 40
            END AS price_score
        FROM musician_profiles mp
        WHERE mp.id NOT IN (
            -- Excluir músicos ya aplicados
            SELECT DISTINCT musician_profile_id 
            FROM musician_applications 
            WHERE request_id = @RequestId
        )
        AND mp.id NOT IN (
            -- Excluir músicos con conflictos de horario
            SELECT DISTINCT ma.musician_profile_id
            FROM musician_applications ma
            INNER JOIN musician_requests mr ON ma.request_id = mr.id
            WHERE ma.status IN ('accepted', 'pending')
            AND mr.event_date = @RequestDate
            AND (
                (mr.start_time < @EndTime AND mr.end_time > @StartTime)
            )
        )
    )
    SELECT TOP(@MaxResults)
        id,
        user_id,
        stage_name,
        hourly_rate,
        experience_years,
        location_address,
        distance_km,
        skill_score,
        experience_score,
        price_score,
        -- Score total ponderado
        (skill_score * 0.4 + experience_score * 0.3 + price_score * 0.2 + 
         CASE WHEN distance_km <= 10 THEN 100 
              WHEN distance_km <= 25 THEN 80 
              WHEN distance_km <= 50 THEN 60 
              ELSE 40 END * 0.1) AS total_score
    FROM MusicianScores
    WHERE distance_km <= @MaxDistance
    ORDER BY total_score DESC, distance_km ASC;
END;
```

### Ejemplo 4: Vistas Materializadas para Performance
```sql
-- Vista materializada para estadísticas de músicos
CREATE VIEW v_musician_statistics AS
SELECT 
    mp.id,
    mp.stage_name,
    mp.hourly_rate,
    mp.experience_years,
    mp.location_address,
    COUNT(DISTINCT ma.id) AS total_applications,
    COUNT(DISTINCT CASE WHEN ma.status = 'accepted' THEN ma.id END) AS accepted_applications,
    COUNT(DISTINCT CASE WHEN ma.status = 'rejected' THEN ma.id END) AS rejected_applications,
    AVG(CASE WHEN ma.status = 'accepted' THEN ma.proposed_rate END) AS avg_accepted_rate,
    COUNT(DISTINCT ms.skill_id) AS total_skills,
    STRING_AGG(msk.name, ', ') AS skill_names
FROM musician_profiles mp
LEFT JOIN musician_applications ma ON mp.id = ma.musician_profile_id
LEFT JOIN musician_skills ms ON mp.id = ms.musician_profile_id
LEFT JOIN musical_skills msk ON ms.skill_id = msk.id
GROUP BY mp.id, mp.stage_name, mp.hourly_rate, mp.experience_years, mp.location_address;

-- Vista materializada para solicitudes activas
CREATE VIEW v_active_requests AS
SELECT 
    mr.id,
    mr.title,
    mr.description,
    mr.event_date,
    mr.start_time,
    mr.end_time,
    mr.budget_min,
    mr.budget_max,
    mr.location_address,
    mr.status,
    u.username AS client_name,
    COUNT(DISTINCT ma.id) AS total_applications,
    COUNT(DISTINCT CASE WHEN ma.status = 'accepted' THEN ma.id END) AS accepted_applications,
    STRING_AGG(DISTINCT msk.name, ', ') AS required_skills
FROM musician_requests mr
INNER JOIN users u ON mr.client_id = u.id
LEFT JOIN request_skill_requirements rsr ON mr.id = rsr.request_id
LEFT JOIN musical_skills msk ON rsr.skill_id = msk.id
LEFT JOIN musician_applications ma ON mr.id = ma.request_id
WHERE mr.status IN ('open', 'in_progress')
GROUP BY mr.id, mr.title, mr.description, mr.event_date, mr.start_time, 
         mr.end_time, mr.budget_min, mr.budget_max, mr.location_address, 
         mr.status, u.username;
```

### Ejemplo 5: Triggers para Auditoría y Validación
```sql
-- Trigger para auditoría de cambios en solicitudes
CREATE TRIGGER tr_musician_requests_audit
ON musician_requests
AFTER UPDATE
AS
BEGIN
    INSERT INTO request_audit_log (
        request_id,
        field_name,
        old_value,
        new_value,
        changed_by,
        changed_at
    )
    SELECT 
        i.id,
        'status',
        d.status,
        i.status,
        SYSTEM_USER,
        GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.id = d.id
    WHERE i.status != d.status;
    
    -- Notificar cambios de estado
    IF EXISTS (
        SELECT 1 FROM inserted i 
        INNER JOIN deleted d ON i.id = d.id 
        WHERE i.status != d.status
    )
    BEGIN
        -- Aquí se enviarían notificaciones en tiempo real
        -- usando SignalR o similar
        PRINT 'Estado de solicitud cambiado - notificación enviada';
    END
END;

-- Trigger para validar disponibilidad de músicos
CREATE TRIGGER tr_validate_musician_availability
ON musician_applications
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @RequestId UNIQUEIDENTIFIER, @MusicianId UNIQUEIDENTIFIER;
    DECLARE @EventDate DATE, @StartTime TIME, @EndTime TIME;
    
    SELECT 
        @RequestId = request_id,
        @MusicianId = musician_profile_id
    FROM inserted;
    
    SELECT 
        @EventDate = event_date,
        @StartTime = start_time,
        @EndTime = end_time
    FROM musician_requests 
    WHERE id = @RequestId;
    
    -- Verificar conflictos de horario
    IF EXISTS (
        SELECT 1
        FROM musician_applications ma
        INNER JOIN musician_requests mr ON ma.request_id = mr.id
        WHERE ma.musician_profile_id = @MusicianId
        AND ma.status IN ('accepted', 'pending')
        AND mr.event_date = @EventDate
        AND (
            (mr.start_time < @EndTime AND mr.end_time > @StartTime)
        )
    )
    BEGIN
        RAISERROR('El músico no está disponible en este horario', 16, 1);
        RETURN;
    END
    
    -- Si no hay conflictos, insertar la aplicación
    INSERT INTO musician_applications (
        request_id, musician_profile_id, proposed_rate, message, status
    )
    SELECT request_id, musician_profile_id, proposed_rate, message, status
    FROM inserted;
END;
```

## 🎯 Ejercicios

### Ejercicio 1: Diseño de Base de Datos para Plataforma Musical
Crea una base de datos completa para una plataforma de matching musical que incluya:
- Usuarios (clientes y músicos)
- Perfiles de músicos con habilidades
- Solicitudes de eventos
- Sistema de aplicaciones y matching
- Calificaciones y reseñas
- Sistema de pagos

**Requisitos:**
- Usar UUIDs como claves primarias
- Implementar normalización avanzada
- Crear índices optimizados para matching
- Incluir triggers de auditoría

### Ejercicio 2: Algoritmo de Matching con Scoring
Implementa un algoritmo de matching que considere:
- Distancia geográfica (usando fórmula de Haversine)
- Habilidades requeridas vs. disponibles
- Experiencia del músico
- Precio vs. presupuesto
- Disponibilidad de horario
- Calificaciones previas

**Puntos extra:**
- Implementar caching de resultados
- Usar vistas materializadas
- Optimizar consultas con índices compuestos

### Ejercicio 3: Sistema de Notificaciones en Tiempo Real
Crea un sistema de base de datos que soporte:
- Notificaciones push
- Chat en tiempo real
- Estados de solicitudes
- Historial de mensajes

**Consideraciones:**
- Usar tablas de eventos
- Implementar soft deletes
- Crear índices para consultas de chat

### Ejercicio 4: Optimización de Performance para Alto Tráfico
Optimiza la base de datos para:
- 100,000+ usuarios
- 50,000+ solicitudes activas
- Consultas de matching en <100ms
- Escalabilidad horizontal

**Técnicas a usar:**
- Particionamiento de tablas
- Sharding por región geográfica
- Caching con Redis
- Índices compuestos optimizados

### Ejercicio 5: Sistema de Analytics y Reportes
Implementa un sistema de analytics que genere:
- Reportes de matching exitoso
- Análisis de tendencias de precios
- Métricas de performance de músicos
- KPIs de la plataforma

**Requerimientos:**
- Usar vistas materializadas
- Implementar agregaciones pre-calculadas
- Crear índices para consultas de reportes

### Ejercicio 6: Backup y Recuperación para Producción
Diseña una estrategia de backup que incluya:
- Backup completo diario
- Backup incremental cada hora
- Backup de transacciones cada 15 minutos
- Plan de recuperación ante desastres

**Consideraciones:**
- RTO < 4 horas
- RPO < 15 minutos
- Backup en múltiples ubicaciones
- Testing de recuperación

### Ejercicio 7: Seguridad y Auditoría
Implementa medidas de seguridad:
- Encriptación de datos sensibles
- Auditoría completa de cambios
- Control de acceso granular
- Logs de seguridad

**Requerimientos:**
- Encriptar información personal
- Registrar todos los cambios
- Implementar roles y permisos
- Monitoreo de accesos sospechosos

### Ejercicio 8: Escalabilidad y Sharding
Diseña una estrategia de sharding para:
- Distribuir datos por región geográfica
- Balancear carga entre servidores
- Mantener consistencia de datos
- Facilitar mantenimiento

**Consideraciones:**
- Sharding por ubicación
- Replicación entre shards
- Routing inteligente de consultas
- Migración de datos

### Ejercicio 9: Integración con Sistemas Externos
Crea interfaces para integración con:
- Sistemas de pago (Stripe, PayPal)
- Servicios de geolocalización
- APIs de redes sociales
- Sistemas de email/SMS

**Requerimientos:**
- Tablas de configuración
- Logs de integración
- Manejo de errores
- Retry automático

### Ejercicio 10: Proyecto Integrador: Plataforma Musical Completa
Construye una base de datos completa para una plataforma de matching musical que incluya:
- Todas las entidades del sistema
- Algoritmos de matching optimizados
- Sistema de notificaciones
- Analytics y reportes
- Estrategia de backup
- Plan de escalabilidad

**Entregables:**
- Scripts SQL completos
- Documentación de arquitectura
- Plan de implementación
- Estrategia de testing

## 🧠 Autoevaluación

### Preguntas de Comprensión
1. **¿Por qué es importante la normalización avanzada en plataformas de matching?**
2. **¿Cómo afecta la geolocalización al diseño de índices?**
3. **¿Qué ventajas ofrece el patrón CQRS para sistemas de matching?**
4. **¿Cómo se optimiza una consulta de matching compleja?**

### Preguntas de Aplicación
1. **Diseña un índice compuesto para consultas de matching por ubicación y habilidades**
2. **Implementa un trigger que valide la disponibilidad de músicos**
3. **Crea una vista materializada para estadísticas de matching**
4. **Optimiza una consulta de búsqueda de músicos disponibles**

### Preguntas de Análisis
1. **Analiza el impacto de diferentes estrategias de sharding en el rendimiento**
2. **Evalúa las ventajas y desventajas de usar UUIDs vs. IDs auto-incrementales**
3. **Compara diferentes algoritmos de scoring para matching**
4. **Analiza la escalabilidad de diferentes patrones de base de datos**

---

## 🚀 Próximos Pasos

**En el siguiente nivel (Senior Level 7) aprenderás:**
- **Microservicios y Bases de Datos Distribuidas**
- **Event Sourcing y CQRS Avanzado**
- **Bases de Datos NoSQL para Plataformas Musicales**
- **Arquitectura de Alto Rendimiento para Matching**

**¡Continúa tu viaje hacia la maestría en bases de datos para plataformas musicales! 🎵**
