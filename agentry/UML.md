# UML — Agentry Service

## Component diagram

```mermaid
flowchart LR
  subgraph Clients
    Fiori[SAP Fiori 3 / UI5 app]
    CLI[uim-agentry-cli]
    GUI[uim-agentry-gui · GtkD]
    Ext[REST clients]
  end
  AR[approuter · XSUAA]
  Fiori --> AR
  AR -->|/odata/v4/agentry| OData
  AR -->|/api/v1 · /rest/v1| REST
  Ext --> REST

  subgraph Backend[backend · vibe.d]
    OData[presentation/odata]
    REST[presentation/http · rest]
    CLIA[presentation/cli]
    GUIA[presentation/gui]
    Ports((AgentryPorts))
    UC[application/usecases + statistics]
    Dom[domain · validator · lifecycle]
    Repo[persistence/repositories]
    Store[(JSON snapshots · dataDir)]
    Probe[infrastructure/clients · HttpBackendProbe]
    Pub[infrastructure/logging · LogEventPublisher]
    WD[infrastructure/workers · SyncWatchdog]
  end
  CLI --> CLIA
  GUI --> GUIA
  OData & REST & CLIA & GUIA --> Ports --> UC --> Dom
  UC --> Repo --> Store
  UC --> Probe --> SAP[(SAP backend)]
  UC --> Pub
  WD --> Ports
```

## Class diagram — domain and ports

```mermaid
classDiagram
  class MobileApplication { name; packageName; platform: AppPlatform; status: AppStatus; offlineCapable; pushNotificationsEnabled }
  class AppDefinition { applicationId; name; definitionFormat; definitionContent; status: DefinitionStatus; validationPassed; publishedAt }
  class AppVersion { mobileApplicationId; definitionId; versionNumber; artifactUrl; status: AppVersionStatus; isMandatoryUpdate }
  class MobileDevice { mobileApplicationId; deviceName; platform; osVersion; status: DeviceStatus; groupName; lastSeenAt }
  class SyncSession { deviceId; applicationId; connectionId; status: SyncStatus; direction; bytesSent; bytesReceived }
  class BackendConnection { name; backendType; backendUrl; authMethod; status: ConnectionStatus; lastTestedAt }
  class Deployment { appVersionId; scope_: DeploymentScope; targetGroupName; status: DeploymentStatus; devicesTotal; devicesSucceeded }

  MobileApplication "1" o-- "*" AppDefinition
  MobileApplication "1" o-- "*" AppVersion
  AppDefinition "1" o-- "*" AppVersion
  MobileApplication "1" o-- "*" MobileDevice
  MobileDevice "1" o-- "*" SyncSession
  BackendConnection "1" o-- "*" SyncSession
  AppVersion "1" o-- "*" Deployment

  class AgentryPorts {
    IManageMobileApplicationsUseCase mobileApplications
    IManageAppDefinitionsUseCase appDefinitions
    IManageAppVersionsUseCase appVersions
    IManageDevicesUseCase devices
    IManageSyncSessionsUseCase syncSessions
    IManageBackendConnectionsUseCase backendConnections
    IManageDeploymentsUseCase deployments
    IAgentryStatisticsService statistics
  }
  class ManageDeploymentsUseCase { createDeployment(); startDeployment(); completeDeployment(); rollbackDeployment() }
  ManageDeploymentsUseCase ..|> IManageDeploymentsUseCase
  ManageDeploymentsUseCase --> IDeploymentRepository
  ManageDeploymentsUseCase --> IAppVersionRepository
  ManageDeploymentsUseCase --> IDeviceRepository
  ManageDeploymentsUseCase --> IAgentryEventPublisher
  class ManageBackendConnectionsUseCase { testBackendConnection() }
  ManageBackendConnectionsUseCase --> IBackendProbe
  DeploymentRepository ..|> IDeploymentRepository
  DeploymentRepository --> SnapshotTenantStore
  SnapshotTenantStore --> ISnapshotStorage
  JsonFileSnapshotStorage ..|> ISnapshotStorage
```

## Sequence — release and roll out a version (OData)

```mermaid
sequenceDiagram
  actor Admin as Fiori user
  participant OD as AgentryODataController
  participant DefUC as ManageAppDefinitionsUseCase
  participant VerUC as ManageAppVersionsUseCase
  participant DepUC as ManageDeploymentsUseCase
  Admin->>OD: POST PublishAppDefinition {id}
  OD->>DefUC: publishDefinition()
  DefUC->>DefUC: validateContent() · ensureTransition(draft→published)
  Admin->>OD: POST PublishAppVersion {id}
  OD->>VerUC: publishAppVersion()
  VerUC->>VerUC: definition published? artifactUrl set?
  Admin->>OD: POST Deployments {appVersionId, scope: group}
  OD->>DepUC: createDeployment() — 422 unless version published
  Admin->>OD: POST StartDeployment {id}
  DepUC->>DepUC: resolve target devices → devicesTotal
  Admin->>OD: POST CompleteDeployment {id, devicesSucceeded}
```

## Sequence — data synchronisation

```mermaid
sequenceDiagram
  participant Dev as Device / CLI
  participant UC as ManageSyncSessionsUseCase
  participant DR as IDeviceRepository
  Dev->>UC: createSyncSession(device, app, connection)
  UC->>DR: device suspended / removed? → 422
  Dev->>UC: startSyncSession() (pending → inProgress)
  Dev->>UC: completeSyncSession(metrics)
  UC->>DR: lastSeenAt, appVersionInstalled, enrolled → active
  Note over UC: SyncWatchdogWorker fails sessions in progress longer than syncTimeoutMinutes
```

## State diagrams

```mermaid
stateDiagram-v2
  direction LR
  state "App definition" as D {
    [*] --> draft
    draft --> published: publish (valid metadata)
    draft --> archived
    published --> archived
    archived --> draft
  }
```

```mermaid
stateDiagram-v2
  direction LR
  state "App version" as V {
    [*] --> pending
    pending --> published
    pending --> withdrawn
    published --> deprecated
    deprecated --> published
    published --> withdrawn
    deprecated --> withdrawn
    withdrawn --> [*]
  }
```

```mermaid
stateDiagram-v2
  direction LR
  state "Deployment" as P {
    [*] --> pending
    pending --> deploying: start
    pending --> failed
    deploying --> deployed: complete
    deploying --> failed: complete (0 succeeded)
    failed --> pending: retry
    deployed --> rolledBack
    failed --> rolledBack
    rolledBack --> [*]
  }
```

```mermaid
stateDiagram-v2
  direction LR
  state "Sync session" as S {
    [*] --> pending
    pending --> inProgress
    pending --> cancelled
    inProgress --> completed
    inProgress --> failed
    inProgress --> cancelled
    failed --> pending: retry
  }
```
