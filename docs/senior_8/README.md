# 🚀 Senior Level 8: Bases de Datos NoSQL y Alto Rendimiento

## 🧭 Navegación del Curso

**← Anterior**: [Senior Level 7: Microservicios](../senior_7/README.md)  
**Siguiente →**: [Senior Level 9: Machine Learning](../senior_9/README.md)

---

## 📖 Teoría

### Bases de Datos NoSQL para Plataformas Musicales
Las plataformas como **MussikOn** requieren bases de datos NoSQL para manejar:
- **Datos no estructurados**: Portfolios, reviews, mensajes de chat
- **Escalabilidad horizontal**: Millones de usuarios y solicitudes
- **Consultas complejas**: Búsquedas geoespaciales, full-text, agregaciones
- **Tiempo real**: Notificaciones, chat, matching en vivo
- **Flexibilidad de esquema**: Diferentes tipos de perfiles y eventos

### Tipos de Bases de Datos NoSQL para Música
- **Document Stores**: MongoDB para perfiles y solicitudes
- **Key-Value Stores**: Redis para caching y sesiones
- **Graph Databases**: Neo4j para relaciones sociales y recomendaciones
- **Search Engines**: Elasticsearch para búsquedas avanzadas
- **Time Series**: InfluxDB para métricas y analytics

### Arquitectura de Alto Rendimiento
- **Polyglot Persistence**: Usar la base de datos correcta para cada caso
- **Caching en Múltiples Niveles**: L1, L2, L3 caching
- **Read Replicas**: Distribuir carga de lectura
- **Sharding Inteligente**: Particionamiento por dominio
- **CDN y Edge Computing**: Acercar datos a los usuarios

## 💡 Ejemplos Prácticos

### Ejemplo 1: Arquitectura Híbrida SQL + NoSQL para MussikOn
```sql
-- Base de datos SQL principal para transacciones críticas
CREATE DATABASE mussikon_core;
USE mussikon_core;

-- Tabla de usuarios (datos críticos)
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

-- Tabla de perfiles básicos (referencias a NoSQL)
CREATE TABLE user_profiles (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    profile_document_id VARCHAR(100), -- ID del documento en MongoDB
    search_index_id VARCHAR(100), -- ID del índice en Elasticsearch
    cache_key VARCHAR(100), -- Clave para Redis
    last_sync_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabla de solicitudes básicas (referencias a NoSQL)
CREATE TABLE musician_requests (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    client_id UNIQUEIDENTIFIER NOT NULL,
    request_document_id VARCHAR(100), -- ID del documento en MongoDB
    search_index_id VARCHAR(100), -- ID del índice en Elasticsearch
    status ENUM('open', 'in_progress', 'assigned', 'completed', 'cancelled') DEFAULT 'open',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (client_id) REFERENCES users(id)
);

-- Tabla de relaciones sociales (referencias a Neo4j)
CREATE TABLE social_connections (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    user_id UNIQUEIDENTIFIER NOT NULL,
    connection_id UNIQUEIDENTIFIER NOT NULL,
    connection_type ENUM('follow', 'friend', 'collaborator') NOT NULL,
    graph_node_id VARCHAR(100), -- ID del nodo en Neo4j
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (connection_id) REFERENCES users(id)
);

-- Tabla de métricas de tiempo real (referencias a InfluxDB)
CREATE TABLE real_time_metrics (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10,4) NOT NULL,
    metric_unit VARCHAR(20),
    tags JSON, -- Metadatos adicionales
    time_series_id VARCHAR(100), -- ID de la serie en InfluxDB
    recorded_at DATETIME2 DEFAULT GETDATE()
);

-- Tabla de configuración de bases de datos
CREATE TABLE database_config (
    id INT PRIMARY KEY IDENTITY(1,1),
    database_type ENUM('mongodb', 'redis', 'neo4j', 'elasticsearch', 'influxdb') NOT NULL,
    connection_string NVARCHAR(500) NOT NULL,
    database_name VARCHAR(100),
    collection_name VARCHAR(100),
    is_active BIT DEFAULT 1,
    priority INT DEFAULT 1, -- Prioridad para fallback
    health_check_url NVARCHAR(500),
    last_health_check DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- Insertar configuración de bases de datos NoSQL
INSERT INTO database_config (database_type, connection_string, database_name, collection_name, priority) VALUES
('mongodb', 'mongodb://localhost:27017', 'mussikon', 'users', 1),
('mongodb', 'mongodb://localhost:27017', 'mussikon', 'musician_profiles', 1),
('mongodb', 'mongodb://localhost:27017', 'mussikon', 'requests', 1),
('redis', 'redis://localhost:6379', 'mussikon_cache', 'sessions', 2),
('elasticsearch', 'http://localhost:9200', 'mussikon_search', 'users', 3),
('neo4j', 'bolt://localhost:7687', 'mussikon_graph', 'relationships', 4),
('influxdb', 'http://localhost:8086', 'mussikon_metrics', 'performance', 5);
```

### Ejemplo 2: Integración con MongoDB para Datos Flexibles
```sql
-- Procedimiento para sincronizar usuarios con MongoDB
CREATE PROCEDURE SyncUserToMongoDB
    @UserId UNIQUEIDENTIFIER,
    @Operation ENUM('create', 'update', 'delete')
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MongoConnectionString NVARCHAR(500);
    DECLARE @MongoDatabase VARCHAR(100);
    DECLARE @MongoCollection VARCHAR(100);
    DECLARE @DocumentId VARCHAR(100);
    DECLARE @Success BIT = 0;
    
    -- Obtener configuración de MongoDB
    SELECT 
        @MongoConnectionString = connection_string,
        @MongoDatabase = database_name,
        @MongoCollection = collection_name
    FROM database_config 
    WHERE database_type = 'mongodb' 
    AND collection_name = 'users'
    AND is_active = 1;
    
    IF @MongoConnectionString IS NULL
    BEGIN
        RAISERROR('MongoDB configuration not found', 16, 1);
        RETURN;
    END
    
    IF @Operation = 'create' OR @Operation = 'update'
    BEGIN
        -- Obtener datos del usuario
        DECLARE @UserData TABLE (
            id UNIQUEIDENTIFIER,
            username VARCHAR(50),
            email VARCHAR(255),
            user_type VARCHAR(20),
            created_at DATETIME2,
            updated_at DATETIME2
        );
        
        INSERT INTO @UserData
        SELECT id, username, email, user_type, created_at, updated_at
        FROM users 
        WHERE id = @UserId;
        
        -- Aquí se haría la llamada a MongoDB usando CLR o servicios externos
        -- Por simplicidad, simulamos la operación
        
        IF @Operation = 'create'
        BEGIN
            SET @DocumentId = NEWID();
            PRINT 'Creating user document in MongoDB with ID: ' + @DocumentId;
        END
        ELSE
        BEGIN
            SELECT @DocumentId = profile_document_id 
            FROM user_profiles 
            WHERE user_id = @UserId;
            
            IF @DocumentId IS NULL
            BEGIN
                SET @DocumentId = NEWID();
            END
            
            PRINT 'Updating user document in MongoDB with ID: ' + @DocumentId;
        END
        
        -- Actualizar referencia en SQL
        IF NOT EXISTS (SELECT 1 FROM user_profiles WHERE user_id = @UserId)
        BEGIN
            INSERT INTO user_profiles (user_id, profile_document_id, last_sync_at)
            VALUES (@UserId, @DocumentId, GETDATE());
        END
        ELSE
        BEGIN
            UPDATE user_profiles 
            SET profile_document_id = @DocumentId, last_sync_at = GETDATE()
            WHERE user_id = @UserId;
        END
        
        SET @Success = 1;
    END
    ELSE IF @Operation = 'delete'
    BEGIN
        -- Eliminar documento de MongoDB
        SELECT @DocumentId = profile_document_id 
        FROM user_profiles 
        WHERE user_id = @UserId;
        
        IF @DocumentId IS NOT NULL
        BEGIN
            PRINT 'Deleting user document from MongoDB with ID: ' + @DocumentId;
            
            -- Eliminar referencia
            DELETE FROM user_profiles WHERE user_id = @UserId;
            SET @Success = 1;
        END
    END
    
    -- Registrar resultado de sincronización
    INSERT INTO sync_logs (
        source_service, target_service, entity_type, entity_id, 
        operation, status, created_at
    )
    VALUES (
        'sql_server', 'mongodb', 'user', @UserId, 
        @Operation, CASE WHEN @Success = 1 THEN 'completed' ELSE 'failed' END, 
        GETDATE()
    );
    
    SELECT @Success AS success, @DocumentId AS document_id;
END;
```

### Ejemplo 3: Integración con Redis para Caching Avanzado
```sql
-- Procedimiento para gestionar cache en Redis
CREATE PROCEDURE ManageRedisCache
    @Operation ENUM('get', 'set', 'delete', 'expire'),
    @CacheKey VARCHAR(255),
    @CacheValue NVARCHAR(MAX) = NULL,
    @ExpirationSeconds INT = 3600
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RedisConnectionString NVARCHAR(500);
    DECLARE @RedisDatabase VARCHAR(100);
    DECLARE @Success BIT = 0;
    DECLARE @CachedValue NVARCHAR(MAX);
    
    -- Obtener configuración de Redis
    SELECT 
        @RedisConnectionString = connection_string,
        @RedisDatabase = database_name
    FROM database_config 
    WHERE database_type = 'redis' 
    AND is_active = 1;
    
    IF @RedisConnectionString IS NULL
    BEGIN
        RAISERROR('Redis configuration not found', 16, 1);
        RETURN;
    END
    
    -- Simular operaciones de Redis
    IF @Operation = 'get'
    BEGIN
        -- Simular obtención de valor del cache
        IF @CacheKey LIKE 'user:%'
        BEGIN
            -- Buscar en cache local como fallback
            SELECT @CachedValue = profile_document_id
            FROM user_profiles 
            WHERE user_id = CAST(SUBSTRING(@CacheKey, 6, 36) AS UNIQUEIDENTIFIER);
            
            IF @CachedValue IS NOT NULL
            BEGIN
                SET @CachedValue = '{"cached": true, "value": "' + @CachedValue + '"}';
                SET @Success = 1;
            END
        END
        
        PRINT 'Getting from Redis cache: ' + @CacheKey;
        SELECT @Success AS success, @CachedValue AS cached_value;
    END
    ELSE IF @Operation = 'set'
    BEGIN
        -- Simular almacenamiento en cache
        PRINT 'Setting in Redis cache: ' + @CacheKey + ' = ' + @CacheValue;
        
        -- Actualizar referencia local si es un usuario
        IF @CacheKey LIKE 'user:%' AND @CacheValue IS NOT NULL
        BEGIN
            DECLARE @UserId UNIQUEIDENTIFIER = CAST(SUBSTRING(@CacheKey, 6, 36) AS UNIQUEIDENTIFIER);
            
            UPDATE user_profiles 
            SET cache_key = @CacheKey, last_sync_at = GETDATE()
            WHERE user_id = @UserId;
        END
        
        SET @Success = 1;
        SELECT @Success AS success;
    END
    ELSE IF @Operation = 'delete'
    BEGIN
        -- Simular eliminación del cache
        PRINT 'Deleting from Redis cache: ' + @CacheKey;
        
        -- Limpiar referencia local
        UPDATE user_profiles 
        SET cache_key = NULL
        WHERE cache_key = @CacheKey;
        
        SET @Success = 1;
        SELECT @Success AS success;
    END
    ELSE IF @Operation = 'expire'
    BEGIN
        -- Simular expiración del cache
        PRINT 'Setting expiration for Redis cache: ' + @CacheKey + ' = ' + CAST(@ExpirationSeconds AS VARCHAR) + ' seconds';
        SET @Success = 1;
        SELECT @Success AS success;
    END
END;

-- Procedimiento para cache inteligente de perfiles de músicos
CREATE PROCEDURE GetMusicianProfileCached
    @MusicianId UNIQUEIDENTIFIER,
    @ForceRefresh BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CacheKey VARCHAR(255) = 'musician_profile:' + CAST(@MusicianId AS VARCHAR(36));
    DECLARE @CachedProfile NVARCHAR(MAX);
    DECLARE @ProfileFromDB NVARCHAR(MAX);
    DECLARE @Success BIT = 0;
    
    -- Intentar obtener del cache si no se fuerza refresh
    IF @ForceRefresh = 0
    BEGIN
        EXEC ManageRedisCache 'get', @CacheKey;
        
        -- Si hay datos en cache, retornarlos
        IF @@ROWCOUNT > 0
        BEGIN
            PRINT 'Profile retrieved from cache';
            RETURN;
        END
    END
    
    -- Si no hay cache o se fuerza refresh, obtener de la base de datos
    SELECT @ProfileFromDB = profile_document_id
    FROM user_profiles 
    WHERE user_id = @MusicianId;
    
    IF @ProfileFromDB IS NOT NULL
    BEGIN
        -- Simular obtención del documento completo de MongoDB
        SET @ProfileFromDB = '{"id": "' + CAST(@MusicianId AS VARCHAR(36)) + '", "profile": "full_profile_data"}';
        
        -- Almacenar en cache por 1 hora
        EXEC ManageRedisCache 'set', @CacheKey, @ProfileFromDB, 3600;
        
        SET @Success = 1;
        PRINT 'Profile retrieved from database and cached';
    END
    
    SELECT @Success AS success, @ProfileFromDB AS profile_data;
END;
```

### Ejemplo 4: Integración con Elasticsearch para Búsquedas Avanzadas
```sql
-- Procedimiento para indexar usuarios en Elasticsearch
CREATE PROCEDURE IndexUserInElasticsearch
    @UserId UNIQUEIDENTIFIER,
    @Operation ENUM('index', 'update', 'delete')
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ElasticsearchUrl NVARCHAR(500);
    DECLARE @ElasticsearchIndex VARCHAR(100);
    DECLARE @UserData NVARCHAR(MAX);
    DECLARE @Success BIT = 0;
    
    -- Obtener configuración de Elasticsearch
    SELECT 
        @ElasticsearchUrl = connection_string,
        @ElasticsearchIndex = database_name
    FROM database_config 
    WHERE database_type = 'elasticsearch' 
    AND is_active = 1;
    
    IF @ElasticsearchUrl IS NULL
    BEGIN
        RAISERROR('Elasticsearch configuration not found', 16, 1);
        RETURN;
    END
    
    IF @Operation = 'index' OR @Operation = 'update'
    BEGIN
        -- Obtener datos del usuario para indexación
        SELECT @UserData = (
            SELECT 
                u.id,
                u.username,
                u.email,
                u.user_type,
                u.created_at,
                u.updated_at,
                up.profile_document_id,
                up.search_index_id
            FROM users u
            LEFT JOIN user_profiles up ON u.id = up.user_id
            WHERE u.id = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        
        IF @UserData IS NOT NULL
        BEGIN
            -- Simular indexación en Elasticsearch
            PRINT 'Indexing user in Elasticsearch: ' + @UserId;
            
            -- Generar ID de índice
            DECLARE @IndexId VARCHAR(100) = NEWID();
            
            -- Actualizar referencia en SQL
            UPDATE user_profiles 
            SET search_index_id = @IndexId
            WHERE user_id = @UserId;
            
            SET @Success = 1;
        END
    END
    ELSE IF @Operation = 'delete'
    BEGIN
        -- Simular eliminación del índice
        PRINT 'Deleting user from Elasticsearch: ' + @UserId;
        
        -- Limpiar referencia
        UPDATE user_profiles 
        SET search_index_id = NULL
        WHERE user_id = @UserId;
        
        SET @Success = 1;
    END
    
    -- Registrar operación de indexación
    INSERT INTO sync_logs (
        source_service, target_service, entity_type, entity_id, 
        operation, status, created_at
    )
    VALUES (
        'sql_server', 'elasticsearch', 'user', @UserId, 
        @Operation, CASE WHEN @Success = 1 THEN 'completed' ELSE 'failed' END, 
        GETDATE()
    );
    
    SELECT @Success AS success;
END;

-- Procedimiento para búsqueda avanzada de músicos
CREATE PROCEDURE SearchMusiciansAdvanced
    @Query NVARCHAR(500),
    @LocationLat DECIMAL(10,8) = NULL,
    @LocationLng DECIMAL(11,8) = NULL,
    @MaxDistance DECIMAL(10,2) = 50.0,
    @Skills NVARCHAR(MAX) = NULL,
    @MinRating DECIMAL(3,2) = NULL,
    @MaxHourlyRate DECIMAL(10,2) = NULL,
    @Page INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ElasticsearchUrl NVARCHAR(500);
    DECLARE @ElasticsearchIndex VARCHAR(100);
    DECLARE @SearchQuery NVARCHAR(MAX);
    DECLARE @Offset INT = (@Page - 1) * @PageSize;
    
    -- Obtener configuración de Elasticsearch
    SELECT 
        @ElasticsearchUrl = connection_string,
        @ElasticsearchIndex = database_name
    FROM database_config 
    WHERE database_type = 'elasticsearch' 
    AND is_active = 1;
    
    IF @ElasticsearchUrl IS NULL
    BEGIN
        RAISERROR('Elasticsearch configuration not found', 16, 1);
        RETURN;
    END
    
    -- Construir query de Elasticsearch
    SET @SearchQuery = '{
        "query": {
            "bool": {
                "must": [
                    {"match": {"user_type": "musician"}},
                    {"multi_match": {"query": "' + @Query + '", "fields": ["username", "bio", "skills"]}}
                ]';
    
    -- Agregar filtros de ubicación si se especifican
    IF @LocationLat IS NOT NULL AND @LocationLng IS NOT NULL
    BEGIN
        SET @SearchQuery = @SearchQuery + ',
                "filter": [
                    {"geo_distance": {"distance": "' + CAST(@MaxDistance AS VARCHAR) + 'km", "location": {"lat": ' + CAST(@LocationLat AS VARCHAR) + ', "lon": ' + CAST(@LocationLng AS VARCHAR) + '}}}
                ]';
    END
    
    -- Agregar filtros adicionales
    IF @Skills IS NOT NULL
    BEGIN
        SET @SearchQuery = @SearchQuery + ',
                "must": [
                    {"terms": {"skills": [' + @Skills + ']}}
                ]';
    END
    
    IF @MinRating IS NOT NULL
    BEGIN
        SET @SearchQuery = @SearchQuery + ',
                "filter": [
                    {"range": {"rating": {"gte": ' + CAST(@MinRating AS VARCHAR) + '}}}
                ]';
    END
    
    IF @MaxHourlyRate IS NOT NULL
    BEGIN
        SET @SearchQuery = @SearchQuery + ',
                "filter": [
                    {"range": {"hourly_rate": {"lte": ' + CAST(@MaxHourlyRate AS VARCHAR) + '}}}
                ]';
    END
    
    SET @SearchQuery = @SearchQuery + '
            }
        },
        "sort": [
            {"_score": {"order": "desc"}},
            {"rating": {"order": "desc"}}
        ],
        "from": ' + CAST(@Offset AS VARCHAR) + ',
        "size": ' + CAST(@PageSize AS VARCHAR) + '
    }';
    
    -- Simular búsqueda en Elasticsearch
    PRINT 'Searching in Elasticsearch with query: ' + @SearchQuery;
    
    -- Retornar resultados simulados
    SELECT 
        NEWID() AS id,
        'Musician ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR) AS stage_name,
        'Bio for musician ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR) AS bio,
        CAST(RAND(CHECKSUM(NEWID())) * 100 + 50 AS DECIMAL(10,2)) AS hourly_rate,
        CAST(RAND(CHECKSUM(NEWID())) * 10 + 1 AS INT) AS experience_years,
        CAST(RAND(CHECKSUM(NEWID())) * 0.1 + 40.0 AS DECIMAL(10,8)) AS location_lat,
        CAST(RAND(CHECKSUM(NEWID())) * 0.1 - 74.0 AS DECIMAL(11,8)) AS location_lng,
        'Address ' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR) AS location_address,
        CAST(RAND(CHECKSUM(NEWID())) * 2 + 3 AS DECIMAL(3,2)) AS rating,
        CAST(RAND(CHECKSUM(NEWID())) * 50 + 10 AS INT) AS total_reviews,
        CAST(RAND(CHECKSUM(NEWID())) * 0.5 + 0.5 AS DECIMAL(5,2)) AS relevance_score
    FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20)) AS Numbers(n)
    WHERE n <= @PageSize;
END;
```

### Ejemplo 5: Integración con Neo4j para Relaciones Sociales
```sql
-- Procedimiento para gestionar relaciones sociales en Neo4j
CREATE PROCEDURE ManageSocialRelationships
    @Operation ENUM('create', 'delete', 'query'),
    @UserId UNIQUEIDENTIFIER,
    @ConnectionId UNIQUEIDENTIFIER = NULL,
    @ConnectionType VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Neo4jUrl NVARCHAR(500);
    DECLARE @Neo4jDatabase VARCHAR(100);
    DECLARE @Success BIT = 0;
    DECLARE @GraphNodeId VARCHAR(100);
    
    -- Obtener configuración de Neo4j
    SELECT 
        @Neo4jUrl = connection_string,
        @Neo4jDatabase = database_name
    FROM database_config 
    WHERE database_type = 'neo4j' 
    AND is_active = 1;
    
    IF @Neo4jUrl IS NULL
    BEGIN
        RAISERROR('Neo4j configuration not found', 16, 1);
        RETURN;
    END
    
    IF @Operation = 'create'
    BEGIN
        -- Crear relación social
        IF @ConnectionId IS NOT NULL AND @ConnectionType IS NOT NULL
        BEGIN
            -- Verificar que ambos usuarios existen
            IF EXISTS (SELECT 1 FROM users WHERE id = @UserId) 
            AND EXISTS (SELECT 1 FROM users WHERE id = @ConnectionId)
            BEGIN
                -- Simular creación de nodos y relación en Neo4j
                SET @GraphNodeId = NEWID();
                
                -- Insertar en tabla de relaciones sociales
                INSERT INTO social_connections (
                    user_id, connection_id, connection_type, graph_node_id
                )
                VALUES (
                    @UserId, @ConnectionId, @ConnectionType, @GraphNodeId
                );
                
                PRINT 'Created social relationship in Neo4j: ' + @UserId + ' -> ' + @ConnectionId + ' (' + @ConnectionType + ')';
                SET @Success = 1;
            END
        END
    END
    ELSE IF @Operation = 'delete'
    BEGIN
        -- Eliminar relación social
        IF @ConnectionId IS NOT NULL
        BEGIN
            DELETE FROM social_connections 
            WHERE user_id = @UserId AND connection_id = @ConnectionId;
            
            PRINT 'Deleted social relationship from Neo4j: ' + @UserId + ' -> ' + @ConnectionId;
            SET @Success = 1;
        END
    END
    ELSE IF @Operation = 'query'
    BEGIN
        -- Consultar relaciones sociales
        SELECT 
            sc.connection_id,
            u.username,
            sc.connection_type,
            sc.created_at,
            sc.graph_node_id
        FROM social_connections sc
        INNER JOIN users u ON sc.connection_id = u.id
        WHERE sc.user_id = @UserId
        ORDER BY sc.created_at DESC;
        
        SET @Success = 1;
    END
    
    SELECT @Success AS success;
END;

-- Procedimiento para recomendaciones basadas en relaciones sociales
CREATE PROCEDURE GetSocialRecommendations
    @UserId UNIQUEIDENTIFIER,
    @MaxRecommendations INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Obtener músicos conectados socialmente
    WITH SocialConnections AS (
        SELECT 
            sc.connection_id,
            sc.connection_type,
            sc.created_at,
            -- Calcular score de conexión social
            CASE 
                WHEN sc.connection_type = 'friend' THEN 100
                WHEN sc.connection_type = 'collaborator' THEN 80
                WHEN sc.connection_type = 'follow' THEN 60
                ELSE 40
            END AS social_score
        FROM social_connections sc
        WHERE sc.user_id = @UserId
    ),
    MusicianProfiles AS (
        SELECT 
            mp.id,
            mp.stage_name,
            mp.hourly_rate,
            mp.experience_years,
            mp.location_address,
            sc.social_score,
            -- Calcular score de recomendación
            sc.social_score * 0.6 + 
            CASE 
                WHEN mp.experience_years >= 10 THEN 100
                WHEN mp.experience_years >= 5 THEN 80
                WHEN mp.experience_years >= 2 THEN 60
                ELSE 40
            END * 0.4 AS recommendation_score
        FROM musician_profiles mp
        INNER JOIN SocialConnections sc ON mp.id = sc.connection_id
        WHERE mp.id IN (SELECT connection_id FROM SocialConnections)
    )
    SELECT TOP(@MaxRecommendations)
        id,
        stage_name,
        hourly_rate,
        experience_years,
        location_address,
        social_score,
        recommendation_score
    FROM MusicianProfiles
    ORDER BY recommendation_score DESC, social_score DESC;
END;
```

## 🎯 Ejercicios

### Ejercicio 1: Diseño de Arquitectura Híbrida SQL + NoSQL
Diseña una arquitectura completa que combine:
- **SQL Server** para transacciones críticas
- **MongoDB** para datos flexibles y perfiles
- **Redis** para caching y sesiones
- **Elasticsearch** para búsquedas avanzadas
- **Neo4j** para relaciones sociales

**Requisitos:**
- Definir qué datos van en cada base de datos
- Estrategia de sincronización entre sistemas
- Fallback y recuperación ante fallos
- Monitoreo de consistencia

### Ejercicio 2: Implementación de Caching Multinivel
Implementa un sistema de caching que incluya:
- **L1 Cache**: Memoria local de la aplicación
- **L2 Cache**: Redis compartido
- **L3 Cache**: Base de datos SQL como fallback
- **Cache Invalidation**: Estrategias de invalidación inteligente

**Puntos extra:**
- Cache warming automático
- Compresión de datos en cache
- Métricas de hit ratio
- Cache distribuido

### Ejercicio 3: Búsquedas Avanzadas con Elasticsearch
Implementa búsquedas que incluyan:
- **Búsqueda full-text** en perfiles y solicitudes
- **Filtros geoespaciales** por ubicación
- **Agregaciones** por habilidades y precios
- **Búsqueda semántica** y sugerencias

**Consideraciones:**
- Indexación en tiempo real
- Optimización de queries
- Búsqueda fuzzy y corrección ortográfica
- Personalización de resultados

### Ejercicio 4: Grafo de Relaciones Sociales con Neo4j
Crea un sistema de relaciones que maneje:
- **Conexiones entre usuarios** (follow, friend, collaborator)
- **Recomendaciones** basadas en relaciones
- **Análisis de redes** y influencia
- **Detección de comunidades** musicales

**Requerimientos:**
- Modelado de relaciones complejas
- Algoritmos de recomendación
- Análisis de patrones sociales
- Escalabilidad del grafo

### Ejercicio 5: Métricas en Tiempo Real con InfluxDB
Implementa un sistema de métricas que capture:
- **Performance** de la aplicación
- **Uso de recursos** del sistema
- **Métricas de negocio** (matching, conversiones)
- **Alertas** automáticas

**Técnicas a usar:**
- Series de tiempo optimizadas
- Agregaciones en tiempo real
- Retención de datos históricos
- Dashboards interactivos

### Ejercicio 6: Optimización de Performance para Alto Tráfico
Optimiza el rendimiento para:
- **100,000+ usuarios concurrentes**
- **1,000+ solicitudes por minuto**
- **Matching en <50ms**
- **Búsquedas en <100ms**

**Requerimientos:**
- Load balancing inteligente
- Connection pooling
- Query optimization
- Resource monitoring

### Ejercicio 7: Escalabilidad Horizontal y Sharding
Implementa estrategias de escalabilidad:
- **Sharding por región geográfica**
- **Replicación** entre centros de datos
- **Balanceo de carga** automático
- **Migración** de datos en caliente

**Consideraciones:**
- Consistencia eventual
- Latencia de red
- Costos de infraestructura
- Plan de disaster recovery

### Ejercicio 8: Integración con CDN y Edge Computing
Optimiza la distribución de datos:
- **CDN** para contenido estático
- **Edge computing** para lógica de negocio
- **Caching** en múltiples ubicaciones
- **Optimización** de latencia global

**Requerimientos:**
- Estrategia de invalidación de cache
- Fallback a origen
- Métricas de performance global
- Optimización por región

### Ejercicio 9: Machine Learning en Bases de Datos Musicales
Implementa algoritmos de ML para:
- **Recomendaciones** personalizadas
- **Predicción** de precios
- **Detección** de patrones musicales
- **Optimización** de matching

**Consideraciones:**
- Feature engineering
- Model training y deployment
- A/B testing
- Continuous learning

### Ejercicio 10: Proyecto Integrador: Plataforma Musical de Alto Rendimiento
Construye una plataforma completa que incluya:
- Arquitectura híbrida SQL + NoSQL
- Sistema de caching multinivel
- Búsquedas avanzadas
- Relaciones sociales
- Métricas en tiempo real
- Escalabilidad horizontal

**Entregables:**
- Arquitectura completa documentada
- Scripts SQL y NoSQL
- Estrategia de deployment
- Plan de escalabilidad y monitoreo

## 🧠 Autoevaluación

### Preguntas de Comprensión
1. **¿Por qué es importante usar bases de datos híbridas en plataformas musicales?**
2. **¿Cómo funciona el caching multinivel para mejorar el rendimiento?**
3. **¿Qué ventajas ofrece Elasticsearch para búsquedas musicales?**
4. **¿Cómo se modelan las relaciones sociales en Neo4j?**

### Preguntas de Aplicación
1. **Diseña una estrategia de caching para perfiles de músicos**
2. **Implementa búsquedas geoespaciales en Elasticsearch**
3. **Crea un grafo de relaciones musicales en Neo4j**
4. **Implementa métricas en tiempo real para performance**

### Preguntas de Análisis
1. **Analiza el impacto de la latencia en arquitecturas distribuidas**
2. **Evalúa diferentes estrategias de sharding para escalabilidad**
3. **Compara patrones de caching para diferentes tipos de datos**
4. **Analiza la optimización de queries en bases de datos NoSQL**

---

## 🚀 Próximos Pasos

**En el siguiente nivel (Senior Level 9) aprenderás:**
- **Machine Learning Avanzado en Bases de Datos Musicales**
- **Optimización para Escala Global**
- **Arquitectura de Event-Driven Systems**
- **Implementación de Plataformas Musicales Enterprise**

**¡Continúa tu viaje hacia la maestría en bases de datos NoSQL y alto rendimiento para plataformas musicales! 🚀**
