# Automation Pilot — UML Diagrams

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class Catalog {
        +CatalogId id
        +string tenantId
        +string name
        +string description
        +CatalogStatus status
        +CatalogType catalogType
        +string tags
        +string version_
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +catalogToJson() Json
    }

    class Command {
        +CommandId id
        +string tenantId
        +string catalogId
        +string name
        +string description
        +CommandStatus status
        +CommandType commandType
        +string version_
        +string inputSchema
        +string outputSchema
        +string steps
        +string timeout
        +string retryCount
        +string tags
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +commandToJson() Json
    }

    class CommandInput {
        +CommandInputId id
        +string tenantId
        +string name
        +string description
        +InputType inputType
        +InputSensitivity sensitivity
        +string keys
        +string values
        +string version_
        +string commandId
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +commandInputToJson() Json
    }

    class Execution {
        +ExecutionId id
        +string tenantId
        +string commandId
        +ExecutionStatus status
        +ExecutionPriority priority
        +string inputValues
        +string outputValues
        +string errorLog
        +string triggeredBy
        +string startedAt
        +string completedAt
        +string durationMs
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +executionToJson() Json
    }

    class ScheduledExecution {
        +ScheduledExecutionId id
        +string tenantId
        +string commandId
        +ScheduleType scheduleType
        +ScheduleStatus status
        +string cronExpression
        +string scheduledAt
        +string lastRunAt
        +string nextRunAt
        +string inputValues
        +string description
        +string maxRetries
        +string retryDelay
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +scheduledExecutionToJson() Json
    }

    class Trigger {
        +TriggerId id
        +string tenantId
        +string commandId
        +TriggerType triggerType
        +TriggerStatus status
        +string name
        +string description
        +string eventType
        +string eventSource
        +string filterExpression
        +string inputMapping
        +string lastTriggeredAt
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +triggerToJson() Json
    }

    class ServiceAccount {
        +ServiceAccountId id
        +string tenantId
        +string name
        +string description
        +ServiceAccountStatus status
        +string clientId
        +string permissions
        +string expiresAt
        +string lastUsedAt
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +serviceAccountToJson() Json
    }

    class ContentConnector {
        +ContentConnectorId id
        +string tenantId
        +string name
        +string description
        +ConnectorType connectorType
        +ConnectorStatus status
        +string repositoryUrl
        +string branch
        +string path
        +BackupStatus lastBackupStatus
        +string lastBackupAt
        +string lastRestoreAt
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId updatedBy
        +contentConnectorToJson() Json
    }

    Catalog "1" --> "*" Command : contains
    Command "1" --> "*" CommandInput : has inputs
    Command "1" --> "*" Execution : executed as
    Command "1" --> "*" ScheduledExecution : scheduled as
    Command "1" --> "*" Trigger : triggered by
    ServiceAccount "1" --> "*" Execution : authenticates
    ContentConnector "1" --> "*" Catalog : backs up
```

## Class Diagram — Repository Interfaces

```mermaid
classDiagram
    class ICatalogRepository {
        <<interface>>
        +findAll() Catalog[]
        +findByTenant(tenantId) Catalog[]
        +findById(id) Catalog
        +existsById(id) bool
        +findByName(name) Catalog
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }

    class ICommandRepository {
        <<interface>>
        +findAll() Command[]
        +findByTenant(tenantId) Command[]
        +findById(id) Command
        +existsById(id) bool
        +findByCatalogId(id) Command[]
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }

    class ICommandInputRepository {
        <<interface>>
        +findAll() CommandInput[]
        +findByTenant(tenantId) CommandInput[]
        +findById(id) CommandInput
        +existsById(id) bool
        +findByCommandId(id) CommandInput[]
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }

    class IExecutionRepository {
        <<interface>>
        +findAll() Execution[]
        +findByTenant(tenantId) Execution[]
        +findById(id) Execution
        +existsById(id) bool
        +findByCommandId(id) Execution[]
        +findByStatus(status) Execution[]
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }

    class IScheduledExecutionRepository {
        <<interface>>
        +findAll() ScheduledExecution[]
        +findByTenant(tenantId) ScheduledExecution[]
        +findById(id) ScheduledExecution
        +existsById(id) bool
        +findByCommandId(id) ScheduledExecution[]
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }

    class ITriggerRepository {
        <<interface>>
        +findAll() Trigger[]
        +findByTenant(tenantId) Trigger[]
        +findById(id) Trigger
        +existsById(id) bool
        +findByCommandId(id) Trigger[]
        +findByEventType(type) Trigger[]
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }

    class IServiceAccountRepository {
        <<interface>>
        +findAll() ServiceAccount[]
        +findByTenant(tenantId) ServiceAccount[]
        +findById(id) ServiceAccount
        +existsById(id) bool
        +findByClientId(clientId) ServiceAccount
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }

    class IContentConnectorRepository {
        <<interface>>
        +findAll() ContentConnector[]
        +findByTenant(tenantId) ContentConnector[]
        +findById(id) ContentConnector
        +existsById(id) bool
        +save(entity) void
        +update(entity) void
        +remove(id) void
    }
```

## Use Case Diagram

```mermaid
graph LR
    subgraph Actors
        A[API Client]
    end

    subgraph "Automation Pilot Service"
        UC1[Manage Catalogs]
        UC2[Manage Commands]
        UC3[Manage Command Inputs]
        UC4[Manage Executions]
        UC5[Manage Scheduled Executions]
        UC6[Manage Triggers]
        UC7[Manage Service Accounts]
        UC8[Manage Content Connectors]
        UC9[Health Check]
    end

    A --> UC1
    A --> UC2
    A --> UC3
    A --> UC4
    A --> UC5
    A --> UC6
    A --> UC7
    A --> UC8
    A --> UC9
```

## Component Diagram

```mermaid
graph TB
    subgraph Presentation
        C1[CatalogController]
        C2[CommandController]
        C3[CommandInputController]
        C4[ExecutionController]
        C5[ScheduledExecutionController]
        C6[TriggerController]
        C7[ServiceAccountController]
        C8[ContentConnectorController]
    end

    subgraph Application
        U1[ManageCatalogsUseCase]
        U2[ManageCommandsUseCase]
        U3[ManageCommandInputsUseCase]
        U4[ManageExecutionsUseCase]
        U5[ManageScheduledExecutionsUseCase]
        U6[ManageTriggersUseCase]
        U7[ManageServiceAccountsUseCase]
        U8[ManageContentConnectorsUseCase]
    end

    subgraph Domain
        E[Entities]
        R[Repository Interfaces]
        V[AutomationValidator]
    end

    subgraph Infrastructure
        MR[Memory Repositories]
        CFG[AppConfig]
        DI[Container]
    end

    C1 --> U1
    C2 --> U2
    C3 --> U3
    C4 --> U4
    C5 --> U5
    C6 --> U6
    C7 --> U7
    C8 --> U8

    U1 --> R
    U2 --> R
    U3 --> R
    U4 --> R
    U5 --> R
    U6 --> R
    U7 --> R
    U8 --> R

    R --> E
    U1 --> V
    U2 --> V
    U3 --> V
    U4 --> V
    U5 --> V
    U6 --> V
    U7 --> V
    U8 --> V
    MR -.-> R
    DI --> MR
    DI --> CFG
```

## Sequence Diagram — Command Execution Workflow

```mermaid
sequenceDiagram
    participant OPS as Ops Engineer
    participant API as Automation Pilot API :8110
    participant DB as Data Store

    OPS->>API: POST /catalogs (create catalog)
    API->>DB: Save catalog
    API-->>OPS: 201 Created

    OPS->>API: POST /commands (define command in catalog)
    API->>DB: Save command
    API-->>OPS: 201 Created

    OPS->>API: POST /inputs (create reusable inputs)
    API->>DB: Save command input
    API-->>OPS: 201 Created

    OPS->>API: POST /executions (execute command)
    API->>DB: Save execution (status: pending)
    API-->>OPS: 201 Created

    Note over API,DB: Command steps execute

    API->>DB: Update execution (status: running)
    API->>DB: Update execution (status: completed, output captured)

    OPS->>API: GET /executions/{id}
    API->>DB: Query execution
    API-->>OPS: Execution with status, output, duration
```

## Sequence Diagram — Scheduled Execution Workflow

```mermaid
sequenceDiagram
    participant OPS as Ops Engineer
    participant API as Automation Pilot API :8110
    participant DB as Data Store

    OPS->>API: POST /scheduled-executions (schedule recurring run)
    API->>DB: Save scheduled execution (cron, enabled)
    API-->>OPS: 201 Created

    Note over API,DB: Cron trigger fires at scheduled time

    API->>DB: Create execution from scheduled config
    API->>DB: Update lastRunAt, nextRunAt

    OPS->>API: GET /scheduled-executions/{id}
    API->>DB: Query scheduled execution
    API-->>OPS: Schedule with last/next run info

    OPS->>API: PUT /scheduled-executions/{id} (disable)
    API->>DB: Update status to disabled
    API-->>OPS: 200 Updated
```

## Sequence Diagram — Trigger-Based Execution

```mermaid
sequenceDiagram
    participant SRC as Event Source
    participant API as Automation Pilot API :8110
    participant DB as Data Store
    participant OPS as Ops Engineer

    OPS->>API: POST /triggers (configure event trigger)
    API->>DB: Save trigger
    API-->>OPS: 201 Created

    SRC->>API: Event received (matches trigger filter)
    API->>DB: Map event to command input via inputMapping
    API->>DB: Create execution from trigger
    API->>DB: Update trigger lastTriggeredAt

    OPS->>API: GET /executions (review triggered executions)
    API->>DB: Query executions
    API-->>OPS: Execution list with trigger attribution
```
