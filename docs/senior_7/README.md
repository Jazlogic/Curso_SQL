# 🚀 Senior Level 7: Microservicios y Bases de Datos Distribuidas

## 🧭 Navegación del Curso

**← Anterior**: [Senior Level 6: Plataformas Musicales](../senior_6/README.md)  
**Siguiente →**: [Senior Level 8: NoSQL y Alto Rendimiento](../senior_8/README.md)

---

## 📖 Teoría

### Arquitectura de Microservicios para Plataformas Musicales
Las plataformas como **MussikOn** requieren arquitecturas distribuidas que manejen:
- **Servicios independientes** para diferentes funcionalidades
- **Bases de datos separadas** por dominio de negocio
- **Comunicación asíncrona** entre servicios
- **Escalabilidad independiente** de cada componente
- **Resiliencia** ante fallos de servicios individuales

### Patrones de Base de Datos Distribuidas
- **Database per Service**: Cada microservicio tiene su propia base de datos
- **Shared Database**: Múltiples servicios comparten una base de datos
- **Saga Pattern**: Transacciones distribuidas a través de múltiples servicios
- **Event Sourcing**: Rastrear cambios como secuencia de eventos
- **CQRS**: Separar comandos y consultas en bases de datos diferentes

### Desafíos de Consistencia en Sistemas Distribuidos
- **Consistencia Eventual**: Los datos se sincronizan con el tiempo
- **Transacciones Distribuidas**: Mantener ACID a través de múltiples bases de datos
- **Sincronización de Datos**: Mantener coherencia entre servicios
- **Latencia de Red**: Impacto en el rendimiento de consultas distribuidas

## 💡 Ejemplos Prácticos

### Ejemplo 1: Arquitectura de Microservicios para MussikOn
```sql
-- Base de datos del servicio de usuarios
CREATE DATABASE user_service_db;
USE user_service_db;

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

-- Tabla de perfiles extendidos
CREATE TABLE user_profiles (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    profile_picture_url NVARCHAR(500),
    preferences JSON,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Base de datos del servicio de perfiles musicales
CREATE DATABASE musician_service_db;
USE musician_service_db;

-- Tabla de perfiles de músicos
CREATE TABLE musician_profiles (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL, -- Referencia al servicio de usuarios
    stage_name VARCHAR(100),
    bio TEXT,
    hourly_rate DECIMAL(10,2),
    experience_years INT,
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address NVARCHAR(500),
    availability_schedule JSON, -- Horarios disponibles
    portfolio_urls JSON, -- Enlaces a portfolio
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Tabla de habilidades musicales
CREATE TABLE musical_skills (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    category ENUM('instrument', 'genre', 'style') NOT NULL,
    description TEXT,
    icon_url NVARCHAR(500)
);

-- Base de datos del servicio de solicitudes
CREATE DATABASE request_service_db;
USE request_service_db;

-- Tabla de solicitudes de eventos
CREATE TABLE musician_requests (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    client_id UNIQUEIDENTIFIER NOT NULL, -- Referencia al servicio de usuarios
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
    urgency_level ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Base de datos del servicio de matching
CREATE DATABASE matching_service_db;
USE matching_service_db;

-- Tabla de algoritmos de matching
CREATE TABLE matching_algorithms (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parameters JSON, -- Parámetros configurables del algoritmo
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- Tabla de resultados de matching
CREATE TABLE matching_results (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    request_id UNIQUEIDENTIFIER NOT NULL, -- Referencia al servicio de solicitudes
    algorithm_id INT NOT NULL,
    musician_scores JSON, -- Resultados del algoritmo con scores
    execution_time_ms INT, -- Tiempo de ejecución del algoritmo
    cache_hit BIT DEFAULT 0, -- Si el resultado vino del cache
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (algorithm_id) REFERENCES matching_algorithms(id)
);

-- Base de datos del servicio de notificaciones
CREATE DATABASE notification_service_db;
USE notification_service_db;

-- Tabla de notificaciones
CREATE TABLE notifications (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL, -- Referencia al servicio de usuarios
    type ENUM('request_update', 'new_application', 'message', 'reminder', 'system') NOT NULL,
    title NVARCHAR(200) NOT NULL,
    message TEXT,
    data JSON, -- Datos adicionales de la notificación
    is_read BIT DEFAULT 0,
    read_at DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- Tabla de configuración de notificaciones por usuario
CREATE TABLE user_notification_settings (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    email_notifications BIT DEFAULT 1,
    push_notifications BIT DEFAULT 1,
    sms_notifications BIT DEFAULT 0,
    notification_types JSON, -- Tipos específicos que quiere recibir
    quiet_hours_start TIME DEFAULT '22:00:00',
    quiet_hours_end TIME DEFAULT '08:00:00'
);
```

### Ejemplo 2: Implementación del Patrón Saga para Transacciones Distribuidas
```sql
-- Base de datos del servicio de orquestación
CREATE DATABASE orchestration_service_db;
USE orchestration_service_db;

-- Tabla de sagas (transacciones distribuidas)
CREATE TABLE sagas (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    saga_type VARCHAR(100) NOT NULL,
    status ENUM('started', 'in_progress', 'completed', 'failed', 'compensated') NOT NULL,
    current_step INT DEFAULT 1,
    total_steps INT NOT NULL,
    data JSON, -- Datos de la saga
    started_at DATETIME2 DEFAULT GETDATE(),
    completed_at DATETIME2,
    error_message TEXT
);

-- Tabla de pasos de la saga
CREATE TABLE saga_steps (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    saga_id UNIQUEIDENTIFIER NOT NULL,
    step_number INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    operation VARCHAR(100) NOT NULL,
    status ENUM('pending', 'in_progress', 'completed', 'failed', 'compensated') NOT NULL,
    request_data JSON,
    response_data JSON,
    error_message TEXT,
    started_at DATETIME2,
    completed_at DATETIME2,
    compensation_data JSON, -- Datos para compensación
    FOREIGN KEY (saga_id) REFERENCES sagas(id) ON DELETE CASCADE
);

-- Procedimiento para crear una saga de solicitud musical
CREATE PROCEDURE CreateMusicianRequestSaga
    @RequestId UNIQUEIDENTIFIER,
    @ClientId UNIQUEIDENTIFIER,
    @MusicianId UNIQUEIDENTIFIER,
    @EventDate DATE,
    @StartTime TIME,
    @EndTime TIME
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SagaId UNIQUEIDENTIFIER = NEWID();
    DECLARE @TotalSteps INT = 5;
    
    -- Crear la saga principal
    INSERT INTO sagas (id, saga_type, status, total_steps, data)
    VALUES (
        @SagaId,
        'musician_request_assignment',
        'started',
        @TotalSteps,
        JSON_OBJECT(
            'request_id', @RequestId,
            'client_id', @ClientId,
            'musician_id', @MusicianId,
            'event_date', @EventDate,
            'start_time', @StartTime,
            'end_time', @EndTime
        )
    );
    
    -- Crear los pasos de la saga
    INSERT INTO saga_steps (id, saga_id, step_number, service_name, operation, status)
    VALUES 
        (NEWID(), @SagaId, 1, 'matching_service', 'validate_availability', 'pending'),
        (NEWID(), @SagaId, 2, 'request_service', 'update_status', 'pending'),
        (NEWID(), @SagaId, 3, 'notification_service', 'notify_musician', 'pending'),
        (NEWID(), @SagaId, 4, 'payment_service', 'create_escrow', 'pending'),
        (NEWID(), @SagaId, 5, 'calendar_service', 'block_availability', 'pending');
    
    -- Ejecutar el primer paso
    EXEC ExecuteSagaStep @SagaId, 1;
    
    SELECT @SagaId AS saga_id;
END;

-- Procedimiento para ejecutar un paso de la saga
CREATE PROCEDURE ExecuteSagaStep
    @SagaId UNIQUEIDENTIFIER,
    @StepNumber INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ServiceName VARCHAR(100), @Operation VARCHAR(100);
    DECLARE @RequestData JSON, @ResponseData JSON;
    DECLARE @Success BIT = 1;
    DECLARE @ErrorMessage TEXT = '';
    
    -- Obtener información del paso
    SELECT 
        @ServiceName = service_name,
        @Operation = operation,
        @RequestData = request_data
    FROM saga_steps 
    WHERE saga_id = @SagaId AND step_number = @StepNumber;
    
    -- Marcar paso como en progreso
    UPDATE saga_steps 
    SET status = 'in_progress', started_at = GETDATE()
    WHERE saga_id = @SagaId AND step_number = @StepNumber;
    
    BEGIN TRY
        -- Ejecutar la operación según el servicio
        IF @ServiceName = 'matching_service' AND @Operation = 'validate_availability'
        BEGIN
            -- Validar disponibilidad del músico
            SET @ResponseData = JSON_OBJECT('available', 1, 'message', 'Musician is available');
        END
        ELSE IF @ServiceName = 'request_service' AND @Operation = 'update_status'
        BEGIN
            -- Actualizar estado de la solicitud
            SET @ResponseData = JSON_OBJECT('status_updated', 1, 'new_status', 'assigned');
        END
        -- ... más operaciones
        
        -- Marcar paso como completado
        UPDATE saga_steps 
        SET status = 'completed', response_data = @ResponseData, completed_at = GETDATE()
        WHERE saga_id = @SagaId AND step_number = @StepNumber;
        
        -- Si hay más pasos, ejecutar el siguiente
        IF @StepNumber < (SELECT total_steps FROM sagas WHERE id = @SagaId)
        BEGIN
            EXEC ExecuteSagaStep @SagaId, @StepNumber + 1;
        END
        ELSE
        BEGIN
            -- Saga completada
            UPDATE sagas SET status = 'completed', completed_at = GETDATE() WHERE id = @SagaId;
        END
    END TRY
    BEGIN CATCH
        SET @Success = 0;
        SET @ErrorMessage = ERROR_MESSAGE();
        
        -- Marcar paso como fallido
        UPDATE saga_steps 
        SET status = 'failed', error_message = @ErrorMessage, completed_at = GETDATE()
        WHERE saga_id = @SagaId AND step_number = @StepNumber;
        
        -- Marcar saga como fallida
        UPDATE sagas SET status = 'failed', error_message = @ErrorMessage WHERE id = @SagaId;
        
        -- Iniciar compensación
        EXEC CompensateSaga @SagaId, @StepNumber;
    END CATCH
END;
```

### Ejemplo 3: Event Sourcing para Auditoría Completa
```sql
-- Base de datos del servicio de eventos
CREATE DATABASE event_store_db;
USE event_store_db;

-- Tabla de eventos
CREATE TABLE events (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    aggregate_id UNIQUEIDENTIFIER NOT NULL, -- ID de la entidad
    aggregate_type VARCHAR(100) NOT NULL, -- Tipo de entidad
    event_type VARCHAR(100) NOT NULL, -- Tipo de evento
    event_data JSON NOT NULL, -- Datos del evento
    metadata JSON, -- Metadatos adicionales
    version INT NOT NULL, -- Versión del evento
    occurred_at DATETIME2 DEFAULT GETDATE(),
    created_by UNIQUEIDENTIFIER, -- Usuario que creó el evento
    correlation_id UNIQUEIDENTIFIER, -- Para rastrear operaciones
    causation_id UNIQUEIDENTIFIER -- Evento que causó este evento
);

-- Tabla de snapshots (estados guardados)
CREATE TABLE snapshots (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    aggregate_id UNIQUEIDENTIFIER NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    state_data JSON NOT NULL, -- Estado completo de la entidad
    version INT NOT NULL, -- Versión del snapshot
    created_at DATETIME2 DEFAULT GETDATE()
);

-- Tabla de streams de eventos
CREATE TABLE event_streams (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    aggregate_id UNIQUEIDENTIFIER NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    current_version INT DEFAULT 0,
    last_snapshot_version INT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Procedimiento para agregar un evento
CREATE PROCEDURE AddEvent
    @AggregateId UNIQUEIDENTIFIER,
    @AggregateType VARCHAR(100),
    @EventType VARCHAR(100),
    @EventData JSON,
    @Metadata JSON = NULL,
    @CreatedBy UNIQUEIDENTIFIER = NULL,
    @CorrelationId UNIQUEIDENTIFIER = NULL,
    @CausationId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NextVersion INT;
    DECLARE @StreamId UNIQUEIDENTIFIER;
    
    -- Obtener o crear el stream
    SELECT @StreamId = id, @NextVersion = current_version + 1
    FROM event_streams 
    WHERE aggregate_id = @AggregateId AND aggregate_type = @AggregateType;
    
    IF @StreamId IS NULL
    BEGIN
        SET @StreamId = NEWID();
        SET @NextVersion = 1;
        
        INSERT INTO event_streams (id, aggregate_id, aggregate_type, current_version)
        VALUES (@StreamId, @AggregateId, @AggregateType, 0);
    END
    
    -- Insertar el evento
    INSERT INTO events (
        aggregate_id, aggregate_type, event_type, event_data, 
        metadata, version, created_by, correlation_id, causation_id
    )
    VALUES (
        @AggregateId, @AggregateType, @EventType, @EventData,
        @Metadata, @NextVersion, @CreatedBy, @CorrelationId, @CausationId
    );
    
    -- Actualizar la versión del stream
    UPDATE event_streams 
    SET current_version = @NextVersion, updated_at = GETDATE()
    WHERE id = @StreamId;
    
    -- Crear snapshot cada 10 eventos
    IF @NextVersion % 10 = 0
    BEGIN
        EXEC CreateSnapshot @AggregateId, @AggregateType, @NextVersion;
    END
END;

-- Procedimiento para crear un snapshot
CREATE PROCEDURE CreateSnapshot
    @AggregateId UNIQUEIDENTIFIER,
    @AggregateType VARCHAR(100),
    @Version INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Aquí se reconstruiría el estado de la entidad
    -- basándose en todos los eventos hasta la versión especificada
    -- Por simplicidad, solo insertamos un placeholder
    
    INSERT INTO snapshots (aggregate_id, aggregate_type, state_data, version)
    VALUES (
        @AggregateId, 
        @AggregateType, 
        JSON_OBJECT('snapshot_version', @Version, 'created_at', GETDATE()),
        @Version
    );
    
    -- Actualizar la versión del último snapshot
    UPDATE event_streams 
    SET last_snapshot_version = @Version
    WHERE aggregate_id = @AggregateId AND aggregate_type = @AggregateType;
END;

-- Procedimiento para reconstruir una entidad
CREATE PROCEDURE RebuildAggregate
    @AggregateId UNIQUEIDENTIFIER,
    @AggregateType VARCHAR(100),
    @Version INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @LastSnapshotVersion INT = 0;
    DECLARE @StartVersion INT = 1;
    
    -- Si no se especifica versión, usar la última
    IF @Version IS NULL
    BEGIN
        SELECT @Version = current_version 
        FROM event_streams 
        WHERE aggregate_id = @AggregateId AND aggregate_type = @AggregateType;
    END
    
    -- Buscar el snapshot más reciente
    SELECT @LastSnapshotVersion = MAX(version)
    FROM snapshots 
    WHERE aggregate_id = @AggregateId AND aggregate_type = @AggregateType
    AND version <= @Version;
    
    IF @LastSnapshotVersion > 0
    BEGIN
        SET @StartVersion = @LastSnapshotVersion + 1;
        
        -- Aquí se cargaría el estado del snapshot
        PRINT 'Loading snapshot from version ' + CAST(@LastSnapshotVersion AS VARCHAR);
    END
    
    -- Obtener todos los eventos desde la versión de inicio
    SELECT 
        event_type,
        event_data,
        version,
        occurred_at
    FROM events 
    WHERE aggregate_id = @AggregateId 
    AND aggregate_type = @AggregateType
    AND version BETWEEN @StartVersion AND @Version
    ORDER BY version;
    
    PRINT 'Rebuilding aggregate from version ' + CAST(@StartVersion AS VARCHAR) + ' to ' + CAST(@Version AS VARCHAR);
END;
```

### Ejemplo 4: CQRS con Bases de Datos Separadas
```sql
-- Base de datos de comandos (write model)
CREATE DATABASE command_db;
USE command_db;

-- Tabla de comandos pendientes
CREATE TABLE pending_commands (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    command_type VARCHAR(100) NOT NULL,
    aggregate_id UNIQUEIDENTIFIER NOT NULL,
    command_data JSON NOT NULL,
    status ENUM('pending', 'processing', 'completed', 'failed') DEFAULT 'pending',
    created_at DATETIME2 DEFAULT GETDATE(),
    processed_at DATETIME2,
    error_message TEXT
);

-- Tabla de comandos procesados
CREATE TABLE processed_commands (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    command_type VARCHAR(100) NOT NULL,
    aggregate_id UNIQUEIDENTIFIER NOT NULL,
    command_data JSON NOT NULL,
    result_data JSON,
    processing_time_ms INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    processed_at DATETIME2 DEFAULT GETDATE()
);

-- Base de datos de consultas (read model)
CREATE DATABASE query_db;
USE query_db;

-- Tabla de músicos para consultas rápidas
CREATE TABLE musician_read_model (
    id UNIQUEIDENTIFIER PRIMARY KEY,
    stage_name VARCHAR(100),
    bio TEXT,
    hourly_rate DECIMAL(10,2),
    experience_years INT,
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address NVARCHAR(500),
    skills JSON, -- Habilidades como JSON para consultas rápidas
    rating DECIMAL(3,2),
    total_reviews INT,
    last_active DATETIME2,
    is_available BIT DEFAULT 1,
    search_vector AS CONCAT(stage_name, ' ', bio) PERSISTED -- Para búsquedas full-text
);

-- Tabla de solicitudes para consultas rápidas
CREATE TABLE request_read_model (
    id UNIQUEIDENTIFIER PRIMARY KEY,
    title NVARCHAR(200),
    description TEXT,
    event_date DATE,
    start_time TIME,
    end_time TIME,
    budget_min DECIMAL(10,2),
    budget_max DECIMAL(10,2),
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_address NVARCHAR(500),
    status VARCHAR(50),
    required_skills JSON,
    client_name VARCHAR(100),
    total_applications INT,
    created_at DATETIME2,
    search_vector AS CONCAT(title, ' ', description) PERSISTED
);

-- Tabla de resultados de matching para consultas rápidas
CREATE TABLE matching_read_model (
    id UNIQUEIDENTIFIER PRIMARY KEY,
    request_id UNIQUEIDENTIFIER NOT NULL,
    musician_id UNIQUEIDENTIFIER NOT NULL,
    total_score DECIMAL(5,2),
    skill_score DECIMAL(5,2),
    experience_score DECIMAL(5,2),
    price_score DECIMAL(5,2),
    distance_score DECIMAL(5,2),
    distance_km DECIMAL(10,2),
    is_recommended BIT DEFAULT 0,
    ranking_position INT,
    last_updated DATETIME2 DEFAULT GETDATE()
);

-- Índices optimizados para consultas
CREATE INDEX idx_musician_location ON musician_read_model(location_lat, location_lng);
CREATE INDEX idx_musician_skills ON musician_read_model(skills) USING GIN;
CREATE INDEX idx_musician_rating ON musician_read_model(rating DESC, total_reviews DESC);
CREATE INDEX idx_request_location ON request_read_model(location_lat, location_lng);
CREATE INDEX idx_request_date_status ON request_read_model(event_date, status);
CREATE INDEX idx_matching_score ON matching_read_model(total_score DESC, ranking_position);
CREATE INDEX idx_matching_request ON matching_read_model(request_id, total_score DESC);

-- Vistas materializadas para consultas complejas
CREATE VIEW v_top_musicians AS
SELECT 
    id,
    stage_name,
    hourly_rate,
    experience_years,
    rating,
    total_reviews,
    skills,
    location_address
FROM musician_read_model
WHERE is_available = 1
AND rating >= 4.5
AND total_reviews >= 10
ORDER BY rating DESC, total_reviews DESC;

CREATE VIEW v_active_requests_summary AS
SELECT 
    status,
    COUNT(*) AS total_requests,
    AVG(DATEDIFF(day, created_at, GETDATE())) AS avg_age_days,
    AVG(budget_max - budget_min) AS avg_budget_range
FROM request_read_model
WHERE status IN ('open', 'in_progress')
GROUP BY status;
```

### Ejemplo 5: Sincronización de Datos entre Microservicios
```sql
-- Base de datos del servicio de sincronización
CREATE DATABASE sync_service_db;
USE sync_service_db;

-- Tabla de cambios pendientes de sincronización
CREATE TABLE pending_syncs (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    source_service VARCHAR(100) NOT NULL,
    target_service VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UNIQUEIDENTIFIER NOT NULL,
    operation ENUM('create', 'update', 'delete') NOT NULL,
    data JSON,
    status ENUM('pending', 'processing', 'completed', 'failed', 'retry') DEFAULT 'pending',
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    created_at DATETIME2 DEFAULT GETDATE(),
    processed_at DATETIME2,
    error_message TEXT
);

-- Tabla de logs de sincronización
CREATE TABLE sync_logs (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    sync_id UNIQUEIDENTIFIER NOT NULL,
    source_service VARCHAR(100) NOT NULL,
    target_service VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UNIQUEIDENTIFIER NOT NULL,
    operation VARCHAR(100) NOT NULL,
    status VARCHAR(100) NOT NULL,
    processing_time_ms INT,
    data_size_bytes INT,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- Procedimiento para sincronizar cambios
CREATE PROCEDURE SyncChanges
    @SourceService VARCHAR(100),
    @TargetService VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SyncId UNIQUEIDENTIFIER;
    DECLARE @EntityType VARCHAR(100);
    DECLARE @EntityId UNIQUEIDENTIFIER;
    DECLARE @Operation VARCHAR(100);
    DECLARE @Data JSON;
    DECLARE @Success BIT = 1;
    DECLARE @ErrorMessage TEXT = '';
    
    -- Procesar cambios pendientes
    WHILE EXISTS (
        SELECT 1 FROM pending_syncs 
        WHERE source_service = @SourceService 
        AND target_service = @TargetService
        AND status = 'pending'
        AND retry_count < max_retries
    )
    BEGIN
        -- Obtener el siguiente cambio pendiente
        SELECT TOP 1
            @SyncId = id,
            @EntityType = entity_type,
            @EntityId = entity_id,
            @Operation = operation,
            @Data = data
        FROM pending_syncs 
        WHERE source_service = @SourceService 
        AND target_service = @TargetService
        AND status = 'pending'
        AND retry_count < max_retries
        ORDER BY created_at;
        
        -- Marcar como en procesamiento
        UPDATE pending_syncs 
        SET status = 'processing'
        WHERE id = @SyncId;
        
        BEGIN TRY
            -- Ejecutar la sincronización según el tipo de entidad
            IF @EntityType = 'user'
            BEGIN
                EXEC SyncUser @EntityId, @Operation, @Data;
            END
            ELSE IF @EntityType = 'musician_profile'
            BEGIN
                EXEC SyncMusicianProfile @EntityId, @Operation, @Data;
            END
            ELSE IF @EntityType = 'musician_request'
            BEGIN
                EXEC SyncMusicianRequest @EntityId, @Operation, @Data;
            END
            
            -- Marcar como completado
            UPDATE pending_syncs 
            SET status = 'completed', processed_at = GETDATE()
            WHERE id = @SyncId;
            
            -- Registrar en el log
            INSERT INTO sync_logs (
                sync_id, source_service, target_service, entity_type, 
                entity_id, operation, status, data_size_bytes
            )
            VALUES (
                @SyncId, @SourceService, @TargetService, @EntityType,
                @EntityId, @Operation, 'completed', 
                JSON_LENGTH(@Data)
            );
            
        END TRY
        BEGIN CATCH
            SET @Success = 0;
            SET @ErrorMessage = ERROR_MESSAGE();
            
            -- Incrementar contador de reintentos
            UPDATE pending_syncs 
            SET 
                status = CASE 
                    WHEN retry_count + 1 >= max_retries THEN 'failed'
                    ELSE 'retry'
                END,
                retry_count = retry_count + 1,
                error_message = @ErrorMessage
            WHERE id = @SyncId;
            
            -- Registrar error en el log
            INSERT INTO sync_logs (
                sync_id, source_service, target_service, entity_type,
                entity_id, operation, status, error_message
            )
            VALUES (
                @SyncId, @SourceService, @TargetService, @EntityType,
                @EntityId, @Operation, 'failed', @ErrorMessage
            );
        END CATCH
    END
END;

-- Procedimiento para sincronizar usuarios
CREATE PROCEDURE SyncUser
    @EntityId UNIQUEIDENTIFIER,
    @Operation VARCHAR(100),
    @Data JSON
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Operation = 'create' OR @Operation = 'update'
    BEGIN
        -- Sincronizar con el servicio de usuarios
        -- Aquí se haría la llamada HTTP al servicio correspondiente
        PRINT 'Syncing user ' + CAST(@EntityId AS VARCHAR(50)) + ' with operation ' + @Operation;
    END
    ELSE IF @Operation = 'delete'
    BEGIN
        -- Marcar como eliminado en el servicio de usuarios
        PRINT 'Deleting user ' + CAST(@EntityId AS VARCHAR(50));
    END
END;
```

## 🎯 Ejercicios

### Ejercicio 1: Diseño de Arquitectura de Microservicios
Diseña una arquitectura completa de microservicios para MussikOn que incluya:
- **Servicios principales**: Usuarios, Perfiles, Solicitudes, Matching, Notificaciones
- **Bases de datos separadas** por dominio
- **Patrones de comunicación** entre servicios
- **Estrategia de escalabilidad** para cada servicio

**Requisitos:**
- Usar Database per Service
- Implementar comunicación asíncrona
- Diseñar para alta disponibilidad
- Considerar latencia de red

### Ejercicio 2: Implementación del Patrón Saga
Implementa un sistema de sagas para:
- Asignación de músicos a solicitudes
- Proceso de pago y confirmación
- Cancelación y reembolso
- Compensación automática en caso de fallos

**Puntos extra:**
- Manejo de timeouts
- Retry automático con backoff exponencial
- Logging detallado de cada paso
- Dashboard de monitoreo

### Ejercicio 3: Event Sourcing Completo
Implementa un sistema de Event Sourcing para:
- Auditoría completa de cambios
- Reconstrucción de entidades
- Snapshots automáticos
- Proyecciones para consultas

**Consideraciones:**
- Optimización de consultas de eventos
- Estrategia de limpieza de eventos antiguos
- Versionado de esquemas de eventos
- Migración de eventos

### Ejercicio 4: CQRS con Bases de Datos Separadas
Implementa CQRS para:
- Separar comandos y consultas
- Optimizar modelos de lectura
- Mantener consistencia eventual
- Sincronización automática

**Requerimientos:**
- Modelos de comando optimizados para escritura
- Modelos de consulta optimizados para lectura
- Sincronización en tiempo real
- Fallback a datos de comando

### Ejercicio 5: Sincronización de Datos entre Servicios
Crea un sistema de sincronización que:
- Detecte cambios automáticamente
- Sincronice en tiempo real
- Maneje conflictos de datos
- Proporcione logs detallados

**Técnicas a usar:**
- Triggers de base de datos
- Colas de mensajes
- Retry automático
- Monitoreo de latencia

### Ejercicio 6: Optimización de Performance para Microservicios
Optimiza el rendimiento para:
- Consultas distribuidas
- Caching entre servicios
- Balanceo de carga
- Monitoreo de performance

**Requerimientos:**
- Response time < 200ms para consultas
- Throughput > 1000 req/s por servicio
- Cache hit ratio > 90%
- Métricas en tiempo real

### Ejercicio 7: Resiliencia y Circuit Breaker
Implementa patrones de resiliencia:
- Circuit breaker para servicios externos
- Retry con backoff exponencial
- Fallback a servicios alternativos
- Timeout y cancelación

**Consideraciones:**
- Configuración de thresholds
- Monitoreo de estado del circuito
- Notificaciones de fallos
- Recuperación automática

### Ejercicio 8: Monitoreo y Observabilidad
Crea un sistema de monitoreo que incluya:
- Métricas de performance
- Trazabilidad distribuida
- Logs estructurados
- Alertas automáticas

**Requerimientos:**
- Dashboard en tiempo real
- Alertas proactivas
- Análisis de tendencias
- Integración con herramientas de monitoreo

### Ejercicio 9: Testing de Microservicios
Implementa estrategias de testing para:
- Testing unitario de cada servicio
- Testing de integración entre servicios
- Testing de contratos (Contract Testing)
- Testing de performance

**Consideraciones:**
- Mocks de servicios externos
- Testing de escenarios de fallo
- Testing de latencia de red
- Testing de concurrencia

### Ejercicio 10: Proyecto Integrador: Sistema de Microservicios Completo
Construye un sistema completo de microservicios para MussikOn que incluya:
- Todos los servicios principales
- Bases de datos separadas
- Comunicación asíncrona
- Patrones de resiliencia
- Monitoreo y observabilidad

**Entregables:**
- Arquitectura completa documentada
- Scripts SQL para todas las bases de datos
- Código de ejemplo para cada servicio
- Plan de deployment y escalabilidad

## 🧠 Autoevaluación

### Preguntas de Comprensión
1. **¿Por qué es importante separar las bases de datos por servicio en microservicios?**
2. **¿Cómo funciona el patrón Saga para transacciones distribuidas?**
3. **¿Qué ventajas ofrece Event Sourcing para auditoría?**
4. **¿Cómo se mantiene la consistencia en CQRS?**

### Preguntas de Aplicación
1. **Diseña una saga para el proceso de reserva de músicos**
2. **Implementa un sistema de Event Sourcing para perfiles de músicos**
3. **Crea un modelo de consulta optimizado para búsquedas de músicos**
4. **Implementa sincronización de datos entre servicios de usuarios y perfiles**

### Preguntas de Análisis
1. **Analiza el impacto de la latencia de red en arquitecturas de microservicios**
2. **Evalúa diferentes estrategias de sincronización de datos**
3. **Compara patrones de resiliencia para servicios distribuidos**
4. **Analiza la escalabilidad de diferentes patrones de base de datos**

---

## 🚀 Próximos Pasos

**En el siguiente nivel (Senior Level 8) aprenderás:**
- **Bases de Datos NoSQL para Plataformas Musicales**
- **Arquitectura de Alto Rendimiento para Matching**
- **Machine Learning en Bases de Datos Musicales**
- **Optimización para Escala Global**

**¡Continúa tu viaje hacia la maestría en bases de datos distribuidas para plataformas musicales! 🚀**
