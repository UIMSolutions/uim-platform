# UML — AI Core Service

Diagrams of the AI Core service (`ai-core/backend`, module
`uim.platform.ai_core`). They match the code: entity fields, port names,
state transitions and adapters are taken from the sources. Rendered with
Mermaid.

Contents

1. [Domain model](#1-domain-model)
2. [Value types and building blocks](#2-value-types-and-building-blocks)
3. [Ports and interactors](#3-ports-and-interactors)
4. [Component diagram (hexagonal layers)](#4-component-diagram-hexagonal-layers)
5. [Persistence](#5-persistence)
6. [State machines](#6-state-machines)
7. [Sequence diagrams](#7-sequence-diagrams)
8. [Deployment diagram](#8-deployment-diagram)
9. [Frontend](#9-frontend)

---

## 1. Domain model

Every entity mixes in `TenantEntity!(TId)`: `tenantId`, `id`, `createdAt`,
`createdBy`, `updatedAt`, `updatedBy`. Everything except `ResourceGroup` and
`DockerRegistrySecret` lives inside a resource group and is identified by
(resource group, id).

```mermaid
classDiagram
    direction LR
    class ResourceGroup {
        ResourceGroupId id
        ResourceGroupStatus status
        string statusMessage
        Label[] labels
        isProvisioned() bool
        validate()
    }
    class Scenario {
        ScenarioId id
        ResourceGroupId resourceGroupId
        string name
        string description
        Label[] labels
        validate()
    }
    class Executable {
        ExecutableId id
        ScenarioId scenarioId
        string name
        ExecutableType type
        string versionId
        ParameterDef[] parameters
        ArtifactSlot[] inputArtifacts
        ArtifactSlot[] outputArtifacts
        Label[] labels
        deployable() bool
        validate()
    }
    class Configuration {
        ConfigurationId id
        ScenarioId scenarioId
        ExecutableId executableId
        string name
        Label[] parameterBindings
        ArtifactRef[] inputArtifactBindings
        validate()
    }
    class Execution {
        ExecutionId id
        ConfigurationId configurationId
        ScenarioId scenarioId
        ExecutableId executableId
        ScheduleId scheduleId
        ExecutionStatus status
        TargetStatus targetStatus
        string statusMessage
        long submissionTime
        long startTime
        long completionTime
        ArtifactRef[] outputArtifacts
        Label[] tags
        durationSeconds(now) long
    }
    class Deployment {
        DeploymentId id
        ConfigurationId configurationId
        ConfigurationId latestRunningConfigurationId
        DeploymentStatus status
        TargetStatus targetStatus
        DeploymentOperation lastOperation
        string deploymentUrl
        long ttlSeconds
        long submissionTime
        long startTime
        long completionTime
        expiresAt() long
    }
    class Artifact {
        ArtifactId id
        ScenarioId scenarioId
        ExecutionId executionId
        string name
        ArtifactKind kind
        string url
        string description
        Label[] labels
        validate()
    }
    class ExecutionSchedule {
        ScheduleId id
        ConfigurationId configurationId
        string name
        string cron
        ScheduleStatus status
        long startTime
        long endTime
        long lastRunAt
        long nextRunAt
        ExecutionId lastExecutionId
        inWindow(at) bool
        validate()
    }
    class Metric {
        MetricId id
        ExecutionId executionId
        string name
        double value
        long step
        long timestamp
        Label[] labels
        idFor(executionId, name, step)$ string
    }
    class DockerRegistrySecret {
        DockerRegistrySecretId id
        string server
        string username
        string credentialFingerprint
    }
    class ObjectStoreSecret {
        ObjectStoreSecretId id
        ObjectStoreType type
        string bucket
        string endpoint
        string region
        string pathPrefix
        string credentialFingerprint
    }

    ResourceGroup "1" o-- "*" Scenario
    ResourceGroup "1" o-- "*" ObjectStoreSecret
    Scenario "1" o-- "*" Executable
    Scenario "1" o-- "*" Configuration
    Scenario "1" o-- "*" Artifact
    Executable "1" <-- "*" Configuration : binds
    Configuration "1" <-- "*" Execution : runs
    Configuration "1" <-- "*" Deployment : serves
    Configuration "1" <-- "*" ExecutionSchedule : schedules
    Configuration "*" --> "*" Artifact : inputArtifactBindings
    ExecutionSchedule "1" <.. "*" Execution : scheduleId
    Execution "1" o-- "*" Metric
    Execution "1" --> "*" Artifact : outputArtifacts
```

Enumerations (wire values of the AI API):

```mermaid
classDiagram
    class ExecutionStatus {
        <<enumeration>>
        UNKNOWN
        PENDING
        RUNNING
        COMPLETED
        DEAD
        STOPPING
        STOPPED
    }
    class DeploymentStatus {
        <<enumeration>>
        UNKNOWN
        PENDING
        RUNNING
        COMPLETED
        DEAD
        STOPPING
        STOPPED
    }
    class TargetStatus {
        <<enumeration>>
        RUNNING
        COMPLETED
        STOPPED
        DELETED
    }
    class ResourceGroupStatus {
        <<enumeration>>
        PROVISIONING
        PROVISIONED
        ERROR
    }
    class ScheduleStatus {
        <<enumeration>>
        ACTIVE
        INACTIVE
    }
    class DeploymentOperation {
        <<enumeration>>
        CREATE
        UPDATE
        DELETE
        CASCADE-UPDATE
    }
    class ArtifactKind {
        <<enumeration>>
        model
        dataset
        resultset
        other
    }
    class ExecutableType {
        <<enumeration>>
        workflow
        serving
    }
    class ObjectStoreType {
        <<enumeration>>
        S3
        GCS
        AZURE
        WEBHDFS
    }
```

## 2. Value types and building blocks

```mermaid
classDiagram
    class Label {
        string key
        string value
        toText() string
    }
    class ParameterDef {
        string key
        string type
        string defaultValue
        string description
        required() bool
    }
    class ArtifactSlot {
        string key
        ArtifactKind kind
        string description
    }
    class ArtifactRef {
        string key
        ArtifactId artifactId
    }
    class CronExpression {
        string text
        parse(text)$ CronExpression
        isValid(text)$ bool
        matches(DateTime) bool
        next(afterStdTime) long
    }
    class LifecyclePolicy {
        long provisionSeconds
        long executionStartSeconds
        long executionRunSeconds
        long deploymentStartSeconds
        string inferenceBaseUrl
    }
    class AiCoreException {
        AiCoreErrorKind kind
    }
    class AiCoreErrorKind {
        <<enumeration>>
        invalid
        notFound
        conflict
        ruleViolation
    }
    AiCoreException --> AiCoreErrorKind
```

Domain services are pure functions:

| Module | Functions |
| --- | --- |
| `domain/services/identifiers.d` | `isValidResourceGroupId`, `isValidResourceId`, `requireResourceGroupId`, `requireResourceId` |
| `domain/services/cron.d` | `CronExpression` (lists, ranges, steps, `7` = Sunday, Vixie day-of-month / day-of-week OR) |
| `domain/services/lifecycle.d` | `advanceResourceGroup`, `submitExecution`, `requestExecutionStop`, `advanceExecution`, `submitDeployment`, `requestDeploymentTarget`, `changeDeploymentConfiguration`, `advanceDeployment`, `planSchedule`, `isScheduleDue`, `recordScheduleRun` |
| `domain/services/bindings.d` | `checkParameterBindings`, `checkArtifactBindings`, `effectiveParameters` |
| `domain/types/keys.d` | `resourceKey(group, id)` → `"group~id"`, `splitResourceKey` |

## 3. Ports and interactors

```mermaid
classDiagram
    direction TB
    class AiCorePorts {
        IManageResourceGroups resourceGroups
        IManageScenarios scenarios
        IManageExecutables executables
        IManageConfigurations configurations
        IManageExecutions executions
        IManageDeployments deployments
        IManageArtifacts artifacts
        IManageSchedules schedules
        IManageMetrics metrics
        IManageSecrets secrets
        IReconcileLifecycle reconciler
        IAiCoreStatisticsService statistics
    }
    class AiCoreInteractor {
        <<abstract>>
        #AiCoreRepositories repos
        #IClock clock
        #IAiCoreEventPublisher events
        #LifecyclePolicy policy
        +string defaultGroup
        #groupOf(t, rg) ResourceGroup
        #provisionedGroupOf(t, rg) ResourceGroup
        #emit(type, t, subject, data)
    }
    class ManageExecutionsUseCase {
        createExecution(r) Execution
        submit(t, rg, configuration, actor, schedule) Execution
        patchExecution(r) Execution
        patchExecutions(t, rg, actor, ids, target) BulkResult[]
        deleteExecution(t, rg, id)
    }
    class ManageDeploymentsUseCase {
        createDeployment(r) Deployment
        patchDeployment(r) Deployment
        patchDeployments(...) BulkResult[]
        deleteDeployment(t, rg, id)
    }
    class ManageSchedulesUseCase {
        createSchedule(r)
        updateSchedule(r)
        triggerSchedule(t, rg, id, actor) Execution
        fire(ref schedule, actor) Execution
    }
    class ReconcileLifecycleUseCase {
        reconcile(t) ReconcileResult
        #registerOutputs(ref execution, at) size_t
    }
    AiCoreInteractor <|-- ManageResourceGroupsUseCase
    AiCoreInteractor <|-- ManageSecretsUseCase
    AiCoreInteractor <|-- ManageScenariosUseCase
    AiCoreInteractor <|-- ManageExecutablesUseCase
    AiCoreInteractor <|-- ManageConfigurationsUseCase
    AiCoreInteractor <|-- ManageArtifactsUseCase
    AiCoreInteractor <|-- ManageExecutionsUseCase
    AiCoreInteractor <|-- ManageDeploymentsUseCase
    AiCoreInteractor <|-- ManageSchedulesUseCase
    AiCoreInteractor <|-- ManageMetricsUseCase
    AiCoreInteractor <|-- ReconcileLifecycleUseCase
    ManageSchedulesUseCase --> ManageExecutionsUseCase : submit
    ReconcileLifecycleUseCase --> ManageSchedulesUseCase : fire
    AiCoreStatisticsService ..|> IAiCoreStatisticsService
```

Driven ports:

```mermaid
classDiagram
    class ITenantWideRepository~TEntity,TId~ {
        <<interface>>
        findAll(t) TEntity[]
        findById(t, id) TEntity
        existsById(t, id) bool
        countAll(t) size_t
        save(entity)
        removeById(t, id) bool
    }
    class IGroupRepository~TEntity,TId~ {
        <<interface>>
        findAll(t) TEntity[]
        findByGroup(t, rg) TEntity[]
        findById(t, rg, id) TEntity
        existsById(t, rg, id) bool
        countAll(t) size_t
        save(entity)
        removeById(t, rg, id) bool
        removeByGroup(t, rg) size_t
    }
    class IClock {
        <<interface>>
        now() long
    }
    class IAiCoreEventPublisher {
        <<interface>>
        publish(type, t, subject, data)
    }
    class IDocumentStore {
        <<interface>>
        all()
        get()
        put()
        remove()
        count()
    }
    ITenantWideRepository <|-- IResourceGroupRepository
    ITenantWideRepository <|-- IDockerRegistrySecretRepository
    IGroupRepository <|-- IScenarioRepository
    IGroupRepository <|-- IExecutableRepository
    IGroupRepository <|-- IConfigurationRepository
    IGroupRepository <|-- IExecutionRepository
    IGroupRepository <|-- IDeploymentRepository
    IGroupRepository <|-- IArtifactRepository
    IGroupRepository <|-- IScheduleRepository
    IGroupRepository <|-- IMetricRepository
    IGroupRepository <|-- IObjectStoreSecretRepository
```

## 4. Component diagram (hexagonal layers)

```mermaid
flowchart LR
    subgraph Clients
        SDK[AI API clients<br/>SAP AI SDK / curl]
        Fiori[Fiori 3 app]
        Admin[CLI / GtkD GUI]
    end
    subgraph Presentation
        AIAPI[AiApiController<br/>/api/v2]
        OData[ODataController<br/>/odata/v4/ai-core]
        Engine[ODataEngine<br/>aiCoreModel + PortProviders]
        CLI[buildAiCoreCli]
        GUI[runAiCoreGui]
        Health[AiCoreHealthController]
        Web[FrontendController /app]
    end
    subgraph Application
        UC[Manage*UseCase ×10]
        REC[ReconcileLifecycleUseCase]
        STAT[AiCoreStatisticsService]
        SEED[seedDemoData]
    end
    subgraph Domain
        ENT[Entities]
        SRV[lifecycle · cron · bindings · identifiers]
    end
    subgraph Infrastructure
        CFG[loadAiCoreConfig]
        SEC[SecuritySetup<br/>XSUAA / HS256 / open]
        LOG[LoggingEventPublisher]
        CLK[SystemClock / ManualClock]
        WRK[ReconcilerWorker]
        CTR[AiCoreContainer]
    end
    subgraph Persistence
        REPO[Tenant/GroupDocumentRepository]
        MAP[mappers]
        STORE[(Memory / File<br/>DocumentStore)]
    end
    SDK --> AIAPI
    Fiori --> OData
    Admin --> CLI & GUI
    OData --> Engine
    CLI --> Engine
    GUI --> Engine
    AIAPI --> UC
    Engine --> UC & REC & STAT & SEED
    WRK --> REC
    UC & REC --> SRV --> ENT
    UC --> REPO
    REPO --> MAP --> STORE
    UC -.-> LOG
    UC -.-> CLK
    AIAPI & OData -.-> SEC
    CTR -.wires.-> UC & REPO & Engine
    CFG -.-> CTR
```

## 5. Persistence

```mermaid
classDiagram
    class TenantDocumentRepository~TEntity,TId,toRecord,fromRecord~ {
        #IDocumentStore store
        #string collection
    }
    class GroupDocumentRepository~TEntity,TId,toRecord,fromRecord~ {
        #IDocumentStore store
        #string collection
        #where(t, rg, predicate) TEntity[]
    }
    class MemoryDocumentStore
    class FileDocumentStore
    TenantDocumentRepository ..|> ITenantWideRepository
    GroupDocumentRepository ..|> IGroupRepository
    MemoryDocumentStore ..|> IDocumentStore
    FileDocumentStore --|> MemoryDocumentStore
    TenantDocumentRepository --> IDocumentStore
    GroupDocumentRepository --> IDocumentStore
```

| Collection | Key | Mapper |
| --- | --- | --- |
| `aicore.resourceGroups` | `id` | `resourceGroupToRecord` / `recordToResourceGroup` |
| `aicore.dockerRegistrySecrets` | `id` | `dockerSecretToRecord` / `recordToDockerSecret` |
| `aicore.scenarios`, `.executables`, `.configurations`, `.executions`, `.deployments`, `.artifacts`, `.executionSchedules`, `.metrics`, `.objectStoreSecrets` | `<resourceGroupId>~<id>` | `*ToRecord` / `recordTo*` |

Records store times as std time (hnsecs, UTC). Unknown enum values fall back
to safe defaults so older snapshots stay readable.

## 6. State machines

Execution (`domain/services/lifecycle.d`):

```mermaid
stateDiagram-v2
    [*] --> PENDING : submitExecution
    PENDING --> RUNNING : advance (after executionStartSeconds)
    PENDING --> STOPPED : PATCH targetStatus=STOPPED
    RUNNING --> COMPLETED : advance (after executionRunSeconds)<br/>registers output artifacts
    RUNNING --> STOPPING : PATCH targetStatus=STOPPED
    STOPPING --> STOPPED : advance
    COMPLETED --> [*] : DELETE
    STOPPED --> [*] : DELETE
    DEAD --> [*] : DELETE
```

Deployment:

```mermaid
stateDiagram-v2
    [*] --> PENDING : submitDeployment
    PENDING --> RUNNING : advance (after deploymentStartSeconds)<br/>sets deploymentUrl
    PENDING --> STOPPED : targetStatus=STOPPED
    RUNNING --> STOPPING : targetStatus=STOPPED
    RUNNING --> STOPPED : TTL elapsed
    RUNNING --> PENDING : PATCH configurationId (rollout)
    STOPPING --> STOPPED : advance
    STOPPED --> PENDING : targetStatus=RUNNING (restart)
    DEAD --> PENDING : targetStatus=RUNNING
    STOPPED --> [*] : DELETE
```

Resource group and schedule:

```mermaid
stateDiagram-v2
    state "Resource group" as RG {
        [*] --> PROVISIONING : provisionSeconds > 0
        [*] --> PROVISIONED : provisionSeconds = 0
        PROVISIONING --> PROVISIONED : advance
    }
    state "Schedule" as S {
        [*] --> ACTIVE
        ACTIVE --> INACTIVE : PATCH status
        INACTIVE --> ACTIVE : PATCH status (replans nextRunAt)
        ACTIVE --> ACTIVE : due → fire execution,<br/>nextRunAt = cron.next(now)
    }
```

## 7. Sequence diagrams

### Training run through the AI API

```mermaid
sequenceDiagram
    autonumber
    participant C as AI API client
    participant A as AiApiController
    participant S as SecuritySetup
    participant E as ManageExecutionsUseCase
    participant R as IExecutionRepository
    participant W as ReconcilerWorker
    participant L as ReconcileLifecycleUseCase
    participant AR as IArtifactRepository

    C->>A: POST /api/v2/lm/executions {configurationId}<br/>AI-Resource-Group: default
    A->>S: resolve(req) → RequestContext, check scope Manage
    A->>E: createExecution(request)
    E->>E: provisionedGroupOf, configurationOf, executable is workflow
    E->>R: save(Execution PENDING)
    E-->>A: Execution
    A-->>C: 202 {id, status: PENDING}
    loop every reconcileIntervalSeconds
        W->>L: reconcile(tenant)
        L->>L: advanceExecution(e, now, policy)
        alt started
            L->>R: save(RUNNING)
        else completed
            L->>AR: save(Artifact per output slot)
            L->>R: save(COMPLETED, outputArtifacts)
        end
    end
    C->>A: PATCH /api/v2/lm/metrics {executionId, metrics, tags}
    A-->>C: 204
    C->>A: GET /api/v2/lm/executions/{id}
    A-->>C: 200 {status: COMPLETED, outputArtifacts: [...]}
```

### Deployment rollout from the Fiori app

```mermaid
sequenceDiagram
    autonumber
    participant U as Fiori DeploymentDetail
    participant O as ODataController
    participant G as ODataEngine
    participant D as ManageDeploymentsUseCase
    participant L as Reconciler

    U->>O: PATCH /Deployments('default~d1') {configurationId: serve-v2}
    O->>G: update(ctx, "Deployments", key, payload)
    G->>G: validatePayload (computed / immutable dropped)
    G->>D: patchDeployment(request)
    D->>D: same scenario, executable is serving
    D->>D: changeDeploymentConfiguration → PENDING, lastOperation=UPDATE
    D-->>U: 200 row
    L->>L: advanceDeployment → RUNNING, latestRunningConfigurationId = serve-v2
```

### Schedule firing

```mermaid
sequenceDiagram
    participant W as ReconcilerWorker
    participant L as ReconcileLifecycleUseCase
    participant S as ManageSchedulesUseCase
    participant E as ManageExecutionsUseCase
    W->>L: reconcile(t)
    L->>L: isScheduleDue(s, now)
    L->>S: fire(s, "scheduler")
    S->>E: submit(t, rg, configuration, actor, s.id)
    E-->>S: Execution (scheduleId = s.id)
    S->>S: recordScheduleRun → lastRunAt, nextRunAt = cron.next(now)
    Note over L,S: on AiCoreException the schedule moves to its next slot<br/>and "schedule.failed" is published
```

## 8. Deployment diagram

```mermaid
flowchart TB
    subgraph BTP["SAP BTP Cloud Foundry (mta.yaml)"]
        AR["ai-core-approuter<br/>@sap/approuter + Fiori resources"]
        SRV["ai-core-srv<br/>binary_buildpack<br/>uim-ai-core-platform-service"]
        XSUAA[("ai-core-xsuaa<br/>xsuaa / application")]
        UPS[("ai-core-config<br/>user-provided")]
        AR -- "destination ai-core-srv<br/>forwardAuthToken" --> SRV
        AR -.-> XSUAA
        SRV -.-> XSUAA
        SRV -.-> UPS
    end
    Browser --> AR
    SDKClient[AI API client] --> AR

    subgraph K8s["Kubernetes (k8s/)"]
        POD["Deployment ai-core (1 replica, Recreate)<br/>readOnlyRootFilesystem, /data emptyDir"]
        SVC["Service ai-core :8090"]
        CM["ConfigMap ai-core-config"]
        SVC --> POD
        CM -.-> POD
    end
```

## 9. Frontend

```mermaid
flowchart LR
    Component --> App[App.view]
    App -->|"route main (:tab:)"| Main[Main.view<br/>KPI header · group filter · 9 tabs]
    App -->|"executions/(key)"| ED[ExecutionDetail<br/>outputs · metrics]
    App -->|"deployments/(key)"| DD[DeploymentDetail<br/>stop · restart · roll out]
    App -->|"scenarios/(key)"| SD[ScenarioDetail<br/>executables · configurations · artifacts]
    Main --> Dialogs[10 create dialogs<br/>fragment/*.fragment.xml]
    Main & ED & DD & SD --> Base[BaseController<br/>invokeAction · filterTable · bindTo]
    Base --> M[(OData V4 model<br/>/odata/v4/ai-core)]
    Base --> F[formatter.js · models.js]
```
