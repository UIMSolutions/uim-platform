# UML Diagrams — Agentry Service

## Class Diagram

```mermaid
classDiagram
    class MobileApplication {
        +string id
        +string name
        +AppPlatform platform
        +AppStatus status
        +string packageName
        +bool offlineCapable
        +bool pushNotificationsEnabled
    }
    class AppDefinition {
        +string id
        +string mobileApplicationId
        +string name
        +string definitionContent
        +string definitionFormat
        +DefinitionStatus status
        +bool validationPassed
    }
    class AppVersion {
        +string id
        +string mobileApplicationId
        +string definitionId
        +string versionNumber
        +AppVersionStatus status
        +bool isMandatoryUpdate
    }
    class Device {
        +string id
        +string mobileApplicationId
        +string deviceName
        +AppPlatform platform
        +string osVersion
        +DeviceStatus status
        +string groupName
    }
    class SyncSession {
        +string id
        +string deviceId
        +string mobileApplicationId
        +string backendConnectionId
        +SyncStatus status
        +SyncDirection direction
        +long bytesSent
        +long bytesReceived
    }
    class BackendConnection {
        +string id
        +string name
        +BackendType backendType
        +ConnectionStatus status
        +string backendUrl
        +string authMethod
        +bool sslEnabled
    }
    class Deployment {
        +string id
        +string mobileApplicationId
        +string appVersionId
        +DeploymentStatus status
        +DeploymentScope scope
        +long devicesTotal
        +long devicesSucceeded
    }

    AppDefinition --> MobileApplication : defines
    AppVersion --> MobileApplication : version of
    AppVersion --> AppDefinition : built from
    Device --> MobileApplication : enrolled in
    SyncSession --> Device : initiated by
    SyncSession --> MobileApplication : syncs
    SyncSession --> BackendConnection : connects to
    Deployment --> MobileApplication : deploys
    Deployment --> AppVersion : targets
```

## Component Diagram

```mermaid
flowchart TB
    subgraph Presentation["Presentation Layer"]
        REST["REST API\n/api/v1/agentry/..."]
    end

    subgraph Application["Application Layer"]
        UC1["ManageMobileApplicationsUseCase"]
        UC2["ManageAppDefinitionsUseCase"]
        UC3["ManageAppVersionsUseCase"]
        UC4["ManageDevicesUseCase"]
        UC5["ManageSyncSessionsUseCase"]
        UC6["ManageBackendConnectionsUseCase"]
        UC7["ManageDeploymentsUseCase"]
    end

    subgraph Domain["Domain Layer"]
        Entities["Entities\nMobileApplication · AppDefinition\nAppVersion · Device\nSyncSession · BackendConnection\nDeployment"]
        Ports["Repository Interfaces\n(Ports)"]
        Validator["AgentryValidator"]
    end

    subgraph Infrastructure["Infrastructure Layer"]
        Repos["Memory Repositories\n(Adapters)"]
        Config["SrvConfig\n(AGENTRY_HOST/PORT)"]
        Container["DI Container"]
    end

    REST --> UC1 & UC2 & UC3 & UC4 & UC5 & UC6 & UC7
    UC1 & UC2 & UC3 & UC4 & UC5 & UC6 & UC7 --> Entities
    UC1 & UC2 & UC3 & UC4 & UC5 & UC6 & UC7 --> Ports
    UC1 & UC2 & UC3 --> Validator
    Ports --> Repos
    Config --> Container
    Container --> Repos
```

## Sequence Diagram — Device Enrollment

```mermaid
sequenceDiagram
    actor Client
    participant DC as DeviceController
    participant UC as ManageDevicesUseCase
    participant V as AgentryValidator
    participant R as DeviceRepository

    Client->>DC: POST /api/v1/agentry/devices
    DC->>UC: enrollDevice(DeviceDTO)
    UC->>V: isValidDevice(device)
    V-->>UC: true
    UC->>R: save(device)
    R-->>UC: ok
    UC-->>DC: CommandResult(success, id)
    DC-->>Client: 201 Created { id }
```

## Sequence Diagram — Data Synchronisation

```mermaid
sequenceDiagram
    actor MobileApp
    participant SC as SyncSessionController
    participant UC as ManageSyncSessionsUseCase
    participant R as SyncSessionRepository
    participant BC as BackendConnection

    MobileApp->>SC: POST /api/v1/agentry/sync-sessions
    SC->>UC: createSyncSession(SyncSessionDTO)
    UC->>R: save(session)
    R-->>UC: ok
    UC-->>SC: CommandResult(success, id)
    SC-->>MobileApp: 201 Created { id }

    MobileApp->>SC: PUT /api/v1/agentry/sync-sessions/{id}
    note over MobileApp,SC: Update status to completed
    SC->>UC: updateSyncSession(dto)
    UC->>R: update(session)
    R-->>UC: ok
    UC-->>SC: CommandResult(success, id)
    SC-->>MobileApp: 200 OK
```

## State Diagram — Mobile Application Lifecycle

```mermaid
stateDiagram-v2
    [*] --> draft : create
    draft --> active : publish
    active --> deprecated_ : deprecate
    deprecated_ --> archived : archive
    draft --> archived : discard
```

## State Diagram — Deployment Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending : create deployment
    pending --> deploying : start rollout
    deploying --> deployed : all devices updated
    deploying --> failed : error during rollout
    failed --> rolledBack : rollback triggered
    deployed --> [*]
    rolledBack --> [*]
```
