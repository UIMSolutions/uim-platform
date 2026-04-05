# HANA Cloud Service — UML Diagrams

## 1. Component Diagram — Hexagonal Architecture

```mermaid
graph TB
    subgraph Clients["External Clients"]
        REST["REST API Consumer"]
        K8S["Kubernetes Probes"]
    end

    subgraph Presentation["Presentation Layer (Driving Adapters)"]
        IC["InstanceController"]
        DLC["DataLakeController"]
        SC["SchemaController"]
        DUC["DatabaseUserController"]
        BC["BackupController"]
        AC["AlertController"]
        HC["HDIContainerController"]
        RTC["ReplicationTaskController"]
        CFC["ConfigurationController"]
        DCC["DatabaseConnectionController"]
        HLC["HealthController"]
        JU["json_utils"]
    end

    subgraph Application["Application Layer (Use Cases)"]
        MIU["ManageInstancesUseCase"]
        MDLU["ManageDataLakesUseCase"]
        MSU["ManageSchemasUseCase"]
        MDUU["ManageDatabaseUsersUseCase"]
        MBU["ManageBackupsUseCase"]
        MAU["ManageAlertsUseCase"]
        MHCU["ManageHDIContainersUseCase"]
        MRTU["ManageReplicationTasksUseCase"]
        MCU["ManageConfigurationsUseCase"]
        MDCU["ManageDatabaseConnectionsUseCase"]
        DTO["DTOs"]
    end

    subgraph Domain["Domain Layer (Core)"]
        subgraph Entities
            DBI["DatabaseInstance"]
            DL["DataLake"]
            SCH["Schema"]
            DBU["DatabaseUser"]
            BK["Backup"]
            AL["Alert"]
            HDI["HDIContainer"]
            RT["ReplicationTask"]
            CFG["Configuration"]
            DBC["DatabaseConnection"]
        end
        subgraph Ports["Ports (Interfaces)"]
            IRI["InstanceRepository"]
            DLRI["DataLakeRepository"]
            SRI["SchemaRepository"]
            DURI["DatabaseUserRepository"]
            BRI["BackupRepository"]
            ARI["AlertRepository"]
            HRI["HDIContainerRepository"]
            RTRI["ReplicationTaskRepository"]
            CRI["ConfigurationRepository"]
            DCRI["DatabaseConnectionRepository"]
        end
        subgraph Services["Domain Services"]
            IV["InstanceValidator"]
        end
        TYP["Types & Enums"]
    end

    subgraph Infrastructure["Infrastructure Layer (Driven Adapters)"]
        subgraph Memory["In-Memory Repositories"]
            MIR["MemoryInstanceRepo"]
            MDLR["MemoryDataLakeRepo"]
            MSR["MemorySchemaRepo"]
            MDUR["MemoryDatabaseUserRepo"]
            MBR["MemoryBackupRepo"]
            MAR["MemoryAlertRepo"]
            MHCR["MemoryHDIContainerRepo"]
            MRTR["MemoryReplicationTaskRepo"]
            MCR["MemoryConfigurationRepo"]
            MDCR["MemoryDatabaseConnectionRepo"]
        end
        ACFG["AppConfig + loadConfig()"]
        CONT["Container + buildContainer()"]
    end

    REST --> IC & DLC & SC & DUC & BC & AC & HC & RTC & CFC & DCC
    K8S --> HLC
    IC --> MIU
    DLC --> MDLU
    SC --> MSU
    DUC --> MDUU
    BC --> MBU
    AC --> MAU
    HC --> MHCU
    RTC --> MRTU
    CFC --> MCU
    DCC --> MDCU
    MIU --> IRI
    MDLU --> DLRI
    MSU --> SRI
    MDUU --> DURI
    MBU --> BRI
    MAU --> ARI
    MHCU --> HRI
    MRTU --> RTRI
    MCU --> CRI
    MDCU --> DCRI
    IRI -.->|implements| MIR
    DLRI -.->|implements| MDLR
    SRI -.->|implements| MSR
    DURI -.->|implements| MDUR
    BRI -.->|implements| MBR
    ARI -.->|implements| MAR
    HRI -.->|implements| MHCR
    RTRI -.->|implements| MRTR
    CRI -.->|implements| MCR
    DCRI -.->|implements| MDCR
```

## 2. Class Diagram — Domain Model

```mermaid
classDiagram
    class DatabaseInstance {
        +InstanceId id
        +TenantId tenantId
        +string name
        +string description
        +InstanceType type
        +InstanceStatus status
        +InstanceSize size
        +string version_
        +string region
        +string availabilityZone
        +InstanceEndpoint endpoint
        +InstanceResource resources
        +InstanceLabel[] labels
        +bool enableScriptServer
        +bool enableDocStore
        +bool enableDataLake
        +bool allowAllIpAccess
        +string[] whitelistedIps
        +long createdAt
        +long modifiedAt
    }

    class InstanceEndpoint {
        +string host
        +int port
        +string protocol
    }

    class InstanceResource {
        +long memoryGB
        +int vcpus
        +long storageGB
        +long usedStorageGB
    }

    class DataLake {
        +DataLakeId id
        +TenantId tenantId
        +InstanceId instanceId
        +string name
        +string description
        +DataLakeStatus status
        +DataLakeEndpoint endpoint
        +DataLakeStorage[] storage
        +FileFormat[] supportedFormats
        +int computeNodes
        +long createdAt
        +long modifiedAt
    }

    class DataLakeStorage {
        +StorageTier tier
        +long capacityGB
        +long usedGB
    }

    class Schema {
        +SchemaId id
        +TenantId tenantId
        +InstanceId instanceId
        +string name
        +string owner
        +SchemaType type
        +bool hasPrivileges
        +long tableCount
        +long viewCount
        +long procedureCount
        +long sizeBytes
        +long createdAt
        +long modifiedAt
    }

    class DatabaseUser {
        +DatabaseUserId id
        +TenantId tenantId
        +InstanceId instanceId
        +string userName
        +AuthType authType
        +UserStatus status
        +UserRole[] roles
        +UserPrivilege[] privileges
        +string defaultSchema
        +bool isRestricted
        +bool forcePasswordChange
        +int failedLoginAttempts
        +long passwordExpiresAt
        +long lastLoginAt
        +long createdAt
        +long modifiedAt
    }

    class UserPrivilege {
        +PrivilegeType type
        +string name
        +string schemaName
        +bool grantable
    }

    class Backup {
        +BackupId id
        +TenantId tenantId
        +InstanceId instanceId
        +string name
        +BackupType type
        +BackupStatus status
        +long sizeBytes
        +string destination
        +string encryptionKey
        +bool encrypted
        +BackupSchedule schedule
        +long startedAt
        +long completedAt
        +long expiresAt
        +long createdAt
    }

    class BackupSchedule {
        +string cronExpression
        +int retentionDays
        +bool enabled
    }

    class Alert {
        +AlertId id
        +TenantId tenantId
        +InstanceId instanceId
        +string name
        +string description
        +AlertSeverity severity
        +AlertStatus status
        +AlertCategory category
        +string source
        +string metricName
        +double metricValue
        +AlertThreshold threshold
        +string acknowledgedBy
        +long triggeredAt
        +long acknowledgedAt
        +long resolvedAt
        +long createdAt
    }

    class AlertThreshold {
        +string metric
        +double warningValue
        +double criticalValue
        +string unit
    }

    class HDIContainer {
        +HDIContainerId id
        +TenantId tenantId
        +InstanceId instanceId
        +string name
        +string description
        +HDIContainerStatus status
        +string schemaName
        +string appUser
        +string appUserSchema
        +int artifactCount
        +long sizeBytes
        +string[] grantedSchemas
        +long createdAt
        +long modifiedAt
    }

    class ReplicationTask {
        +ReplicationTaskId id
        +TenantId tenantId
        +InstanceId instanceId
        +string name
        +string description
        +ReplicationMode mode
        +ReplicationTaskStatus status
        +string sourceConnectionId
        +string targetConnectionId
        +ReplicationMapping[] mappings
        +string scheduleExpression
        +long lastRunAt
        +long nextRunAt
        +long rowsReplicated
        +long errorCount
        +long createdAt
        +long modifiedAt
    }

    class ReplicationMapping {
        +string sourceSchema
        +string sourceTable
        +string targetSchema
        +string targetTable
    }

    class Configuration {
        +ConfigurationId id
        +TenantId tenantId
        +InstanceId instanceId
        +string section
        +string key
        +string value
        +string defaultValue
        +ConfigScope scope_
        +ConfigDataType dataType
        +string description
        +bool isReadOnly
        +bool requiresRestart
        +long modifiedAt
        +string modifiedBy
    }

    class DatabaseConnection {
        +DatabaseConnectionId id
        +TenantId tenantId
        +InstanceId instanceId
        +string name
        +string description
        +ConnectionType type
        +ConnectionStatus status
        +string host
        +int port
        +string database
        +string user
        +bool useTls
        +string tlsCertificate
        +ConnectionPoolConfig poolConfig
        +string[][] properties
        +long createdAt
        +long modifiedAt
    }

    class ConnectionPoolConfig {
        +int minConnections
        +int maxConnections
        +long idleTimeoutMs
        +long connectionTimeoutMs
    }

    DatabaseInstance "1" --> "0..*" DataLake : hosts
    DatabaseInstance "1" --> "0..*" Schema : contains
    DatabaseInstance "1" --> "0..*" DatabaseUser : manages
    DatabaseInstance "1" --> "0..*" Backup : has
    DatabaseInstance "1" --> "0..*" Alert : monitors
    DatabaseInstance "1" --> "0..*" HDIContainer : runs
    DatabaseInstance "1" --> "0..*" ReplicationTask : executes
    DatabaseInstance "1" --> "0..*" Configuration : configures
    DatabaseInstance "1" --> "0..*" DatabaseConnection : connects via
    DatabaseInstance *-- InstanceEndpoint
    DatabaseInstance *-- InstanceResource
    DataLake *-- DataLakeStorage
    DatabaseUser *-- UserPrivilege
    Backup *-- BackupSchedule
    Alert *-- AlertThreshold
    ReplicationTask *-- ReplicationMapping
    DatabaseConnection *-- ConnectionPoolConfig
```

## 3. Enumeration Diagram

```mermaid
classDiagram
    class InstanceType {
        <<enumeration>>
        hana
        hanaExpress
        hanaCloud
        trial
        free
    }

    class InstanceStatus {
        <<enumeration>>
        creating
        running
        stopped
        starting
        stopping
        updating
        deleting
        error
        suspended
    }

    class InstanceSize {
        <<enumeration>>
        xs
        s
        m
        l
        xl
        xxl
        custom
    }

    class StorageTier {
        <<enumeration>>
        hot
        warm
        cold
    }

    class DataLakeStatus {
        <<enumeration>>
        creating
        running
        stopped
        error
        deleting
    }

    class FileFormat {
        <<enumeration>>
        parquet
        csv
        orc
        json
        avro
    }

    class SchemaType {
        <<enumeration>>
        standard
        hdi
        virtual
        system
        temporary
    }

    class AuthType {
        <<enumeration>>
        password
        kerberos
        saml
        x509
        jwt
        ldap
    }

    class UserStatus {
        <<enumeration>>
        active
        deactivated
        locked
        expired
    }

    class BackupType {
        <<enumeration>>
        full
        incremental
        differential
        log
        snapshot
    }

    class BackupStatus {
        <<enumeration>>
        scheduled
        running
        completed
        failed
        cancelled
    }

    class AlertSeverity {
        <<enumeration>>
        info
        warning
        error
        critical
    }

    class AlertStatus {
        <<enumeration>>
        active
        acknowledged
        resolved
        suppressed
    }

    class AlertCategory {
        <<enumeration>>
        performance
        availability
        storage
        memory
        cpu
        replication
        backup
        security
        configuration
    }

    class HDIContainerStatus {
        <<enumeration>>
        creating
        active
        inactive
        error
        deleting
    }

    class ReplicationMode {
        <<enumeration>>
        none
        realtime
        scheduled
        snapshot
        logBased
    }

    class ReplicationTaskStatus {
        <<enumeration>>
        active
        inactive
        running
        completed
        failed
        paused
    }

    class ConfigScope {
        <<enumeration>>
        system
        database
        tenant
        session
    }

    class ConnectionType {
        <<enumeration>>
        jdbc
        odbc
        hdbsql
        nodeJs
        python
        java
        go
        dotnet
    }

    class ConnectionStatus {
        <<enumeration>>
        active
        inactive
        error
        pooled
    }
```

## 4. Sequence Diagram — Create Instance

```mermaid
sequenceDiagram
    actor Client
    participant IC as InstanceController
    participant MIU as ManageInstancesUseCase
    participant IV as InstanceValidator
    participant IR as MemoryInstanceRepo

    Client->>IC: POST /api/v1/hana/instances<br/>{name, type, size, region, ...}
    IC->>IC: Parse JSON, extract X-Tenant-Id
    IC->>MIU: create(CreateInstanceRequest)
    MIU->>MIU: Validate (name required)
    MIU->>MIU: Generate UUID
    MIU->>MIU: Build DatabaseInstance entity
    MIU->>MIU: Set status = creating
    MIU->>IR: save(DatabaseInstance)
    IR-->>MIU: void
    MIU-->>IC: CommandResult(success, instanceId)
    IC-->>Client: 201 Created {id, message}
```

## 5. Sequence Diagram — Instance Action (Start/Stop/Restart)

```mermaid
sequenceDiagram
    actor Client
    participant IC as InstanceController
    participant MIU as ManageInstancesUseCase
    participant IR as MemoryInstanceRepo

    Client->>IC: POST /api/v1/hana/instances/{id}/actions<br/>{action: "start"}
    IC->>IC: Parse JSON, extract tenant and action
    IC->>MIU: performAction(InstanceActionRequest)
    MIU->>IR: findById(tenantId, id)
    IR-->>MIU: DatabaseInstance
    alt action = "start"
        MIU->>MIU: Set status = starting
    else action = "stop"
        MIU->>MIU: Set status = stopping
    else action = "restart"
        MIU->>MIU: Set status = stopping → starting
    end
    MIU->>IR: update(instance)
    IR-->>MIU: void
    MIU-->>IC: CommandResult(success)
    IC-->>Client: 200 OK {id, message}
```

## 6. Sequence Diagram — Alert Acknowledgment

```mermaid
sequenceDiagram
    actor Client
    participant AC as AlertController
    participant MAU as ManageAlertsUseCase
    participant AR as MemoryAlertRepo

    Client->>AC: PUT /api/v1/hana/alerts/{id}/acknowledge<br/>{acknowledgedBy: "admin"}
    AC->>AC: Parse JSON, extract tenant
    AC->>MAU: acknowledge(AcknowledgeAlertRequest)
    MAU->>AR: findById(tenantId, id)
    AR-->>MAU: Alert
    MAU->>MAU: Set status = acknowledged
    MAU->>MAU: Set acknowledgedBy, acknowledgedAt
    MAU->>AR: update(alert)
    AR-->>MAU: void
    MAU-->>AC: CommandResult(success)
    AC-->>Client: 200 OK {id, message}
```

## 7. State Diagram — Instance Lifecycle

```mermaid
stateDiagram-v2
    [*] --> creating : Create Instance
    creating --> running : Provisioning Complete
    creating --> error : Provisioning Failed
    running --> stopping : Stop Action
    running --> updating : Update Request
    running --> deleting : Delete Request
    stopping --> stopped : Stop Complete
    stopped --> starting : Start Action
    stopped --> deleting : Delete Request
    starting --> running : Start Complete
    starting --> error : Start Failed
    updating --> running : Update Complete
    updating --> error : Update Failed
    error --> deleting : Delete Request
    error --> starting : Retry Start
    running --> suspended : Suspend
    suspended --> starting : Resume
    deleting --> [*] : Deleted
```

## 8. State Diagram — Alert Lifecycle

```mermaid
stateDiagram-v2
    [*] --> active : Threshold Breached
    active --> acknowledged : Acknowledge
    active --> resolved : Metric Recovered
    active --> suppressed : Suppress
    acknowledged --> resolved : Metric Recovered
    suppressed --> active : Unsuppress
    resolved --> [*]
```

## 9. State Diagram — Backup Lifecycle

```mermaid
stateDiagram-v2
    [*] --> scheduled : Backup Created
    scheduled --> running : Execution Start
    scheduled --> cancelled : Cancel
    running --> completed : Success
    running --> failed : Error
    completed --> [*]
    failed --> [*]
    cancelled --> [*]
```

## 10. Deployment Diagram

```mermaid
graph TB
    subgraph K8S["Kubernetes Cluster"]
        subgraph Pod["Pod: cloud-hana"]
            SVC["uim-hana-platform-service<br/>Port 8097"]
            MEM["In-Memory Store"]
            SVC --> MEM
        end
        CM["ConfigMap<br/>cloud-hana-config<br/>HANA_HOST=0.0.0.0<br/>HANA_PORT=8097"]
        KSVC["Service<br/>cloud-hana<br/>ClusterIP:8097"]
        CM -.->|envFrom| Pod
        KSVC -->|routes to| Pod
    end

    subgraph Build["Container Build (Multi-Stage)"]
        B1["Stage 1: dlang2/ldc-ubuntu:1.40.1<br/>Build binary"]
        B2["Stage 2: ubuntu:24.04<br/>Runtime image"]
        B1 -->|COPY binary| B2
    end

    CLIENT["API Consumer"] -->|HTTP :8097| KSVC
```

## 11. Package Dependency Diagram

```mermaid
graph TD
    APP["app.d"] --> CONT["infrastructure.container"]
    CONT --> MEM_REPOS["infrastructure.persistence.memory.*"]
    CONT --> USECASES["application.usecases.manage.*"]
    CONT --> CONTROLLERS["presentation.http.controllers.*"]
    CONT --> CONFIG["infrastructure.config"]

    CONTROLLERS --> USECASES
    CONTROLLERS --> DTO["application.dto"]
    CONTROLLERS --> JSON["presentation.http.json_utils"]

    USECASES --> PORTS["domain.ports.repositories.*"]
    USECASES --> DTO
    USECASES --> DOMAIN_SVC["domain.services"]

    MEM_REPOS -.->|implements| PORTS
    PORTS --> ENTITIES["domain.entities.*"]
    ENTITIES --> TYPES["domain.types"]
    DOMAIN_SVC --> TYPES
```
