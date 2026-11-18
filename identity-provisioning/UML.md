# UML — Identity Provisioning Service

Diagrams of the backend (`backend/source/uim/platform/identity_provisioning`), the
Fiori app and the deployment. Mermaid source; renders on GitHub and in most IDEs.

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class ConnectedSystem {
        <<mixin>>
        +string name
        +string description
        +SystemType systemType
        +SystemStatus status
        +string url
        +AuthenticationType authenticationType
        +string user
        +string password «secret»
        +Attribute[] properties
        +string statusMessage
        +long lastTestedAt
        +long lastSyncAt
        +int entityCount
        +connection() ConnectionSettings
    }
    class TenantEntity {
        <<mixin>>
        +TenantId tenantId
        +TId id
        +UserId createdBy / updatedBy
        +long createdAt / updatedAt
    }
    class SourceSystem
    class TargetSystem
    class ProxySystem
    class Transformation {
        +string name
        +SystemRole systemRole
        +string systemId
        +string systemName
        +EntityScope scope
        +int sequence
        +bool active
        +AttributeMapping[] mappings
        +EntityCondition[] conditions
    }
    class ProvisioningJob {
        +string name
        +SourceSystemId sourceSystemId
        +TargetSystemId targetSystemId
        +JobType jobType
        +JobStatus status
        +int intervalMinutes
        +long nextRunAt
        +int runCount
        +int readCount … failedCount
        +string statusMessage
    }
    class ProvisionedEntity {
        +string name
        +EntityType entityType
        +string externalId
        +string targetId
        +Attribute[] attributes
        +string checksum
        +EntityStatus status
        +OperationType lastOperation
    }
    class ProvisioningLog {
        +string name
        +ProvisioningJobId jobId
        +int runNumber
        +EntityType entityType
        +string entityName
        +OperationType operation
        +LogStatus status
        +string message
    }
    class Attribute {
        <<value>>
        +string key
        +string value
    }
    class AttributeMapping {
        <<value>>
        +string sourcePath
        +string targetPath
        +MappingFunction function
        +string defaultValue
        +bool mandatory
    }
    class EntityCondition {
        <<value>>
        +string attribute
        +ConditionOperator operator
        +string value
    }

    TenantEntity <|.. SourceSystem
    TenantEntity <|.. TargetSystem
    TenantEntity <|.. ProxySystem
    ConnectedSystem <|.. SourceSystem
    ConnectedSystem <|.. TargetSystem
    ConnectedSystem <|.. ProxySystem
    SourceSystem "1" <-- "0..*" ProvisioningJob : reads from
    TargetSystem "1" <-- "0..*" ProvisioningJob : writes to
    SourceSystem "1" <-- "0..*" Transformation : read rules
    TargetSystem "1" <-- "0..*" Transformation : write rules
    ProxySystem "1" <-- "0..*" Transformation : proxy rules
    ProvisioningJob "1" --> "0..*" ProvisioningLog : produces
    ProvisioningJob "1" --> "0..*" ProvisionedEntity : delta state of (source, target)
    Transformation *-- AttributeMapping
    Transformation *-- EntityCondition
    ProvisionedEntity *-- Attribute
    ConnectedSystem *-- Attribute : properties
```

## Class Diagram — Enumerations

```mermaid
classDiagram
    class SystemType {
        <<enumeration>>
        ias
        ldap
        sapHr
        successFactors
        scim
        csv
        azureAd
        custom
    }
    class SystemStatus {
        <<enumeration>>
        configuring
        active
        inactive
        error
    }
    class SystemRole {
        <<enumeration>>
        source
        target
        proxy
    }
    class AuthenticationType {
        <<enumeration>>
        none
        basic
        oauth2ClientCredentials
        certificate
    }
    class JobType {
        <<enumeration>>
        full
        delta
        simulate
    }
    class JobStatus {
        <<enumeration>>
        scheduled
        running
        completed
        failed
        cancelled
    }
    class OperationType {
        <<enumeration>>
        create
        update
        delete
        skip
    }
    class LogStatus {
        <<enumeration>>
        success
        failed
        skipped
        simulated
    }
    class EntityType {
        <<enumeration>>
        user
        group
    }
    class EntityStatus {
        <<enumeration>>
        active
        inactive
        pending
        error
    }
    class EntityScope {
        <<enumeration>>
        all
        user
        group
    }
    class MappingFunction {
        <<enumeration>>
        none
        lowerCase
        upperCase
        trim
        constant
    }
    class ConditionOperator {
        <<enumeration>>
        equals
        notEquals
        contains
        startsWith
        endsWith
        present
        absent
    }
```

## Class Diagram — Domain and Application Services

```mermaid
classDiagram
    class transformer {
        <<domain service, pure>>
        +transform(Transformation, EntityType, Attribute[]) TransformationResult
        +transformAll(Transformation[], EntityType, Attribute[]) TransformationResult
        +conditionHolds(EntityCondition, Attribute[]) bool
        +validateRules(AttributeMapping[], EntityCondition[])
    }
    class planner {
        <<domain service, pure>>
        +attributeChecksum(Attribute[]) string
        +planOperations(JobType, SourceIdentity[], ProvisionedEntity[]) PlannedOperation[]
    }
    class systems_catalog_lifecycle {
        <<domain services>>
        +validateConnection(ConnectionSettings, SystemRole) ConnectionSettings
        +supportsRole(SystemType, SystemRole) bool
        +ensureRunnable / ensureIdle / ensureResumable(job)
        +statusAfterRun(failed, connectorFailed) JobStatus
        +nextRunAfter(now, minutes) long
        +isDue(job, now) bool
    }
    class ProvisioningRunner {
        <<application service>>
        +execute(ProvisioningJob, UserId) ProvisioningJob
    }
    class ProvisioningStatisticsService
    class SystemCatalogService
    class DemoDataSeeder {
        +seed(TenantId, UserId) bool
    }
    class IIdentityConnector {
        <<gateway port>>
        +test(ConnectionSettings) ConnectionTestResult
        +read(ConnectionSettings) SourceIdentity[]
        +write(ConnectionSettings, PlannedOperation) string
        +remove(ConnectionSettings, PlannedOperation)
    }
    class SimulatedIdentityConnector

    ProvisioningRunner ..> transformer
    ProvisioningRunner ..> planner
    ProvisioningRunner ..> systems_catalog_lifecycle
    ProvisioningRunner --> IIdentityConnector
    ProvisioningRunner --> ProvisioningRepositories
    IIdentityConnector <|.. SimulatedIdentityConnector
    DemoDataSeeder --> ProvisioningPorts
```

## State Diagram — System lifecycle

```mermaid
stateDiagram-v2
    [*] --> configuring : create
    configuring --> active : activate (test OK)
    configuring --> error : activate / test-connection (test failed)
    error --> active : test-connection OK / activate OK
    active --> configuring : URL, type or credentials changed
    active --> inactive : deactivate
    error --> inactive : deactivate
    inactive --> active : activate (test OK)
    inactive --> error : activate (test failed)
```

## State Diagram — Job lifecycle

```mermaid
stateDiagram-v2
    [*] --> scheduled : create
    scheduled --> running : run / scheduler (due)
    completed --> running : run / scheduler
    failed --> running : run / scheduler
    running --> completed : no failed entities
    running --> failed : failed entities or connector error
    scheduled --> cancelled : cancel
    completed --> cancelled : cancel
    failed --> cancelled : cancel
    cancelled --> scheduled : resume
    note right of running : synchronous in this version — never persisted between requests
```

## Activity Diagram — Provisioning run (`ProvisioningRunner.execute`)

```mermaid
flowchart TD
    A[run / scheduler] --> B{source and target active?}
    B -- no --> X[409 Conflict, job unchanged]
    B -- yes --> C[job → running, runCount++]
    C --> D[connector.read source]
    D -- ConnectorException --> F[job failed: connector error]
    D --> E[for each identity: read rules → write rules]
    E -- condition false --> S1[log skipped]
    E -- mandatory empty --> S2[log failed]
    E -- accepted --> P[planOperations vs delta state]
    P --> T{jobType simulate?}
    T -- yes --> L1[log simulated]
    T -- no --> W[connector.write / remove per operation]
    W -- ConnectorException --> L2[entity error, log failed]
    W --> L3[upsert / delete ProvisionedEntity, log success]
    L1 --> Z
    L2 --> Z
    L3 --> Z
    S1 --> Z
    S2 --> Z
    F --> Z[batch save entities + logs]
    Z --> Y[job completed / failed, figures, nextRunAt; target entityCount; publish event]
```

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
    subgraph Presentation["presentation (driving adapters)"]
        REST[ProvisioningRestController<br/>/api/v1]
        OD[ProvisioningODataController<br/>/odata/v4/identity-provisioning]
        CLI[ProvisioningCli]
        GUI[ProvisioningWindow · GtkD]
        WEB[FrontendController]
        REG[ResourceRegistry<br/>ResourceAdapter · QueryAdapter · CatalogAdapter]
    end
    subgraph Ports["ports"]
        DP[ProvisioningPorts<br/>use cases · queries · services]
        RP[repositories]
        GW[gateways: IIdentityConnector]
        ST[storages: ISnapshotStorage]
        MSG[messaging: IProvisioningEventPublisher]
    end
    subgraph Application["application"]
        UC[ManageSystemsUseCase×3<br/>ManageTransformationsUseCase<br/>ManageProvisioningJobsUseCase<br/>ProvisioningLogsQuery · ProvisionedEntitiesQuery]
        SV[ProvisioningRunner · Statistics · Catalog · DemoDataSeeder · EventRecorder]
    end
    subgraph Domain["domain"]
        ENT[entities · types · enumerations · exceptions]
        DS[transformer · planner · systems · catalog · lifecycle · names]
    end
    subgraph Driven["persistence / infrastructure"]
        REPO[SystemRepository · TransformationRepository · …]
        SNAP[SnapshotTenantStore · JsonFileSnapshotStorage · MemorySnapshotStorage]
        CON[SimulatedIdentityConnector]
        LOG[LogEventPublisher]
        SCH[JobScheduler]
        CFG[ProvisioningConfig · Container]
    end

    REST & OD & CLI & GUI --> REG --> DP
    DP -.implemented by.-> UC
    UC --> SV --> DS --> ENT
    UC --> RP
    SV --> GW
    RP -.implemented by.-> REPO --> SNAP
    ST -.implemented by.-> SNAP
    GW -.implemented by.-> CON
    MSG -.implemented by.-> LOG
    SCH --> DP
    CFG --> REPO & UC & CON
```

## Class Diagram — Generic use cases and adapters

```mermaid
classDiagram
    class IManageResource~TEntity,TId,TCreate,TUpdate~ {
        <<interface>>
        +create(TCreate) UsecaseResult
        +update(TUpdate) UsecaseResult
        +remove(TenantId, TId, UserId) UsecaseResult
        +get(TenantId, TId) TEntity
        +list(TenantId) TEntity[]
    }
    class IManageSystemsUseCase~TEntity,TId~ {
        <<interface>>
        +activate / deactivate / testConnection
        +findByName
    }
    class ResourceUseCase~TEntity,TId,TCreate,TUpdate~ {
        <<abstract>>
        #build(TCreate) TEntity
        #apply(ref TEntity, TSpec)
        #beforeRemove / afterUpdate
        #transition(…)
    }
    class ManageSystemsUseCase~TEntity,TId~
    class ManageTransformationsUseCase
    class ManageProvisioningJobsUseCase
    class IResourceAdapter {
        <<interface>>
        +path / setName / typeName
        +fields() FieldInfo[]
        +list / get / create / update / remove / invoke
    }
    class ResourceAdapter~TEntity,TId,TCreate,TUpdate~ {
        +column() +action() +secret()
    }
    class QueryAdapter~TEntity,TId~
    class CatalogAdapter~T~

    IManageResource <|-- IManageSystemsUseCase
    IManageResource <|.. ResourceUseCase
    ResourceUseCase <|-- ManageSystemsUseCase
    ResourceUseCase <|-- ManageTransformationsUseCase
    ResourceUseCase <|-- ManageProvisioningJobsUseCase
    IManageSystemsUseCase <|.. ManageSystemsUseCase
    IResourceAdapter <|.. ResourceAdapter
    IResourceAdapter <|.. QueryAdapter
    IResourceAdapter <|.. CatalogAdapter
    ResourceAdapter --> IManageResource
```

## Sequence Diagram — Fiori runs a job

```mermaid
sequenceDiagram
    actor Admin
    participant UI as Fiori app (JobDetail)
    participant AR as Approuter
    participant OD as ODataController
    participant REG as ResourceRegistry
    participant UC as ManageProvisioningJobsUseCase
    participant RUN as ProvisioningRunner
    participant CON as IIdentityConnector
    participant REPO as Repositories

    Admin->>UI: Run Now
    UI->>AR: POST /odata/v4/identity-provisioning/RunProvisioningJob {id}
    AR->>OD: + JWT (XSUAA), CSRF checked
    OD->>REG: byODataAction → adapter.invoke(who, id, "run")
    REG->>UC: run(tenant, id, user)
    UC->>RUN: execute(job)
    RUN->>CON: read(source)
    CON-->>RUN: SourceIdentity[]
    RUN->>RUN: transformAll · planOperations
    loop each planned operation
        RUN->>CON: write / remove
    end
    RUN->>REPO: save entities + logs (batch), update job
    RUN-->>UC: job (completed / failed)
    UC-->>REG: UsecaseResult
    REG-->>OD: job payload
    OD-->>UI: 200 $metadata#ProvisioningJobs/$entity
    UI->>OD: refresh job, GET ProvisioningLogs?$filter=jobId eq … and runNumber eq …
```

## Sequence Diagram — Scheduled delta run

```mermaid
sequenceDiagram
    participant T as vibe.d timer
    participant S as JobScheduler
    participant UC as ManageProvisioningJobsUseCase
    participant RUN as ProvisioningRunner
    participant L as ProvisioningLogsQuery

    T->>S: every schedulerIntervalSeconds
    S->>UC: runDue(tenant, now, 10)
    UC->>UC: isDue(job, now)?
    UC->>RUN: execute(job, "scheduler")
    RUN-->>UC: job, nextRunAt = completedAt + interval
    UC-->>S: JobRunReport
    S->>L: purge(tenant, logRetentionDays)
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
    actor Op as Operator
    participant CLI as uim-ips-cli
    participant FS as data/*.json
    participant SRV as server (SnapshotTenantStore)
    Op->>CLI: run "HR → IAS (delta)"
    CLI->>FS: write ips_jobs.json, ips_logs.json, … (atomic rename)
    SRV->>FS: revision changed? → reload before next read
    SRV-->>Op: Fiori app shows the new run
```

## Deployment Diagram — SAP BTP (Cloud Foundry)

```mermaid
flowchart TB
    U[Browser] -->|HTTPS| AR
    subgraph CF["Cloud Foundry space (mta.yaml)"]
        AR[identity-provisioning-approuter<br/>@sap/approuter · Fiori app in resources/]
        SRV[identity-provisioning-srv<br/>binary_buildpack · D/vibe.d]
        XS[(identity-provisioning-xsuaa)]
        CFG[(identity-provisioning-config<br/>user-provided)]
    end
    AR -->|destination identity-provisioning-srv<br/>forwardAuthToken| SRV
    AR --- XS
    SRV --- XS
    SRV --- CFG
    SRV -.connectors.-> EXT[(SuccessFactors · LDAP · IAS · SCIM · Entra ID)]
```
