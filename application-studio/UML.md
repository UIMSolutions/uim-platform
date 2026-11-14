# UML — Application Studio Service

Diagrams of the hexagonal backend (`backend/source/uim/platform/application_studio`), the
Fiori frontend and the deployment. All diagrams are Mermaid.

## Class Diagram — Domain Entities

All aggregates mix in `TenantEntity` (`tenantId`, `id`, `createdBy/At`, `updatedBy/At`).
Catalogue entries and dev spaces are tenant-wide; projects and service bindings belong
to a dev space; run and build configurations belong to a project (and carry its
`devSpaceId` for dev-space-wide checks such as port conflicts).

```mermaid
classDiagram
    class DevSpaceType {
        +DevSpaceTypeId id
        +string name
        +DevSpaceTypeCategory category
        +string[] predefinedExtensions
        +ProjectType[] supportedProjectTypes
        +string runtimeStack
    }
    class Extension {
        +ExtensionId id
        +string name
        +string displayName
        +ExtensionScope scope
        +ExtensionStatus status
        +string version
        +string publisher
        +string[] dependencies
        +string[] capabilities
    }
    class ProjectTemplate {
        +ProjectTemplateId id
        +string name
        +string title
        +TemplateCategory category
        +ProjectType targetProjectType
        +string version
        +string[] requiredExtensions
        +string[] scaffoldFiles
        +KeyValue[] parameters
    }
    class DevSpace {
        +DevSpaceId id
        +string name
        +DevSpaceTypeId devSpaceTypeId
        +DevSpacePlan plan
        +DevSpaceStatus status
        +string owner
        +string region
        +string[] extensions
        +int hibernateAfterDays
        +int memoryLimitMb
        +int diskLimitGb
        +string url
        +long lastAccessedAt
        +long startedAt
    }
    class Project {
        +ProjectId id
        +DevSpaceId devSpaceId
        +string name
        +ProjectType projectType
        +ProjectStatus status
        +ProjectTemplateId templateId
        +string rootPath
        +string namespace
        +string gitRepositoryUrl
        +string gitBranch
        +string[] files
    }
    class ServiceBinding {
        +ServiceBindingId id
        +DevSpaceId devSpaceId
        +string name
        +ServiceProviderType providerType
        +BindingStatus status
        +string systemAlias
        +string serviceUrl
        +string servicePath
        +BindingAuthType authType
        +string user
        +string credentials «masked»
        +long connectedAt
    }
    class RunConfiguration {
        +RunConfigurationId id
        +ProjectId projectId
        +DevSpaceId devSpaceId
        +string name
        +RunMode mode
        +RunStatus status
        +string entryPoint
        +string[] arguments
        +KeyValue[] environment
        +int port
        +int debugPort
        +string[] serviceBindings
        +string url
        +int runCount
    }
    class BuildConfiguration {
        +BuildConfigurationId id
        +ProjectId projectId
        +DevSpaceId devSpaceId
        +string name
        +BuildStatus status
        +DeployTarget deployTarget
        +string buildCommand
        +string deployCommand
        +string mtaDescriptor
        +string artifactPath
        +string lastArtifact
        +BuildRun[] history
    }
    class KeyValue {
        +string key
        +string value
    }
    class BuildRun {
        +string runId
        +BuildPhase phase
        +BuildStatus status
        +long startedAt
        +long finishedAt
        +string artifact
        +string message
    }

    DevSpaceType "1" <-- "*" DevSpace : devSpaceTypeId
    DevSpaceType "*" ..> "*" Extension : predefinedExtensions (names)
    DevSpace "*" ..> "*" Extension : extensions (names)
    Extension "*" ..> "*" Extension : dependencies
    ProjectTemplate "*" ..> "*" Extension : requiredExtensions
    DevSpace "1" *-- "*" Project
    DevSpace "1" *-- "*" ServiceBinding
    Project "1" *-- "*" RunConfiguration
    Project "1" *-- "*" BuildConfiguration
    ProjectTemplate "0..1" <-- "*" Project : templateId
    RunConfiguration "*" ..> "*" ServiceBinding : serviceBindings (names)
    ProjectTemplate *-- KeyValue
    RunConfiguration *-- KeyValue
    BuildConfiguration *-- BuildRun
```

## State Diagram — Lifecycles driven by actions and the reconciler

Solid transitions are requested through the use cases (REST/OData/CLI/GUI actions);
transitions marked *(R)* are performed by the reconciler.

```mermaid
stateDiagram-v2
    direction LR
    state "Dev space" as DS {
        [*] --> starting : create
        starting --> running : (R) runtime started
        starting --> error : (R) start failed
        running --> stopping : stop
        stopping --> stopped : (R) runs ended
        stopped --> starting : start
        running --> hibernating : (R) idle ≥ hibernateAfterDays
        hibernating --> hibernated : (R)
        hibernated --> resuming : start / touch
        resuming --> running : (R)
        error --> starting : start
        stopped --> deleting : delete
        hibernated --> deleting : delete
        error --> deleting : delete
        deleting --> [*] : (R) cascade
    }
```

```mermaid
stateDiagram-v2
    direction LR
    state "Service binding" as SB {
        [*] --> disconnected
        disconnected --> connecting : connect
        connecting --> connected : (R) reachable
        connecting --> error : (R) unreachable
        connected --> disconnected : disconnect / settings changed
        error --> connecting : connect
    }
    state "Run configuration" as RC {
        [*] --> idle
        idle --> starting : start
        starting --> running : (R)
        starting --> error : (R) crashed
        running --> stopped : stop / dev space down
        stopped --> starting : start
        error --> starting : start
    }
```

```mermaid
stateDiagram-v2
    direction LR
    state "Build configuration" as BC {
        [*] --> pending
        pending --> building : build
        building --> succeeded : (R)
        building --> failed : (R)
        succeeded --> deploying : deploy
        deployed --> deploying : deploy
        deploying --> deployed : (R)
        deploying --> failed : (R)
        building --> cancelled : cancel
        deploying --> cancelled : cancel
        succeeded --> building : build
        failed --> building : build
        cancelled --> building : build
        deployed --> building : build
    }
```

A project mirrors its build configurations: `deploying` if one deploys, else `building`
if one builds, else `error` if the latest run of one failed, else `active`
(`ProjectStatusSync`). `archived` is set and cleared by the archive/restore actions.

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
    subgraph Driving["Driving adapters (presentation)"]
        REST["http · StudioRestController<br/>/api/v1"]
        OD["odata · StudioODataController<br/>/odata/v4/application-studio + $metadata"]
        CLI["cli · StudioCli"]
        GUI["gui · StudioWindow (GtkD)"]
        WEB["web · FrontendController<br/>Fiori app (local dev)"]
        REG["resources · ResourceRegistry<br/>8 × ResourceAdapter"]
    end
    subgraph Core["Application core"]
        PORTS["ports · StudioPorts<br/>IManageResource&lt;…&gt; × 8<br/>IReconcileUseCase · IStudioStatisticsService<br/>IStudioCatalogService"]
        UC["application · ResourceUseCase&lt;…&gt; × 8<br/>ReconcileUseCase · StudioCatalogService<br/>StudioStatisticsService · CascadeDeleter · ProjectStatusSync"]
        DOM["domain · entities · names · plan policy<br/>dev space lifecycle · extension resolution<br/>run policy · build policy"]
    end
    subgraph Driven["Driven adapters"]
        REPO["persistence · 8 repositories<br/>RecordMapper&lt;T&gt;"]
        STORE["storages · SnapshotTenantStore<br/>JsonFileSnapshotStorage"]
        GW["clients · SimulatedWorkspaceGateway<br/>(IWorkspaceGateway)"]
        PUB["logging · LogEventPublisher<br/>(IStudioEventPublisher)"]
    end
    INFRA["infrastructure · StudioConfig · identity · ReconcileWorker · Container"]

    REST --> REG
    OD --> REG
    CLI --> REG
    GUI --> REG
    REG --> PORTS
    PORTS --> UC
    UC --> DOM
    UC --> REPO
    UC --> GW
    UC --> PUB
    REPO --> STORE
    STORE --> FILES[("data/*.json")]
    INFRA -. wires .-> UC
    INFRA -. wires .-> REPO
    INFRA -. runs .-> PORTS
```

Dependencies point inwards: presentation knows only `StudioPorts`; use cases know only
port interfaces (`StudioRepositories`, `IWorkspaceGateway`, `IStudioEventPublisher`).

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
    class ResourceUseCase~TEntity,TId,TCreate,TUpdate~ {
        <<abstract>>
        #build(TCreate) TEntity*
        #apply(ref TEntity, TSpec)*
        #beforeRemove(TEntity)
        #retire(ref TEntity) bool
        #afterRemove(TEntity)
        #transition(tenant, id, actor, verb, change) UsecaseResult
        #requireDevSpace() / requireProject() / requireType()
        #requireExtensions(names, forNewUse)
    }
    class ManageDevSpacesUseCase {
        +start() +stop() +touch()
        +addExtension() +removeExtension()
    }
    class ManageProjectsUseCase {
        +archive() +restore()
    }
    class ManageServiceBindingsUseCase {
        +connect() +disconnect()
    }
    class ManageRunConfigurationsUseCase {
        +start() +stop()
    }
    class ManageBuildConfigurationsUseCase {
        +build() +deploy() +cancel()
    }
    class ManageExtensionsUseCase {
        +activate() +deactivate() +deprecate()
    }
    class IResourceAdapter {
        <<interface>>
        +path() setName() typeName() parentField()
        +fields() inputFields() recordTypes() columns() actions()
        +list(tenant, filters) Json[]
        +get(tenant, id) Json
        +create(who, Json) Json
        +update(who, id, Json) Json
        +remove(who, id)
        +invoke(who, id, action, Json) Json
    }
    class ResourceAdapter~TEntity,TId,TCreate,TUpdate~ {
        +column(header, field)
        +action(name, label, handler, params)
        +secret(field)
    }
    class ResourceRegistry {
        +adapters() IResourceAdapter[]
        +byPath() bySet() byODataAction()
        +resolve(adapter, tenant, idOrName) string
        +withReferences(tenant, Json) Json
        +statistics() reconcile() seedCatalog()
    }

    IManageResource <|.. ResourceUseCase
    ResourceUseCase <|-- ManageDevSpacesUseCase
    ResourceUseCase <|-- ManageProjectsUseCase
    ResourceUseCase <|-- ManageServiceBindingsUseCase
    ResourceUseCase <|-- ManageRunConfigurationsUseCase
    ResourceUseCase <|-- ManageBuildConfigurationsUseCase
    ResourceUseCase <|-- ManageExtensionsUseCase
    IResourceAdapter <|.. ResourceAdapter
    ResourceAdapter --> IManageResource : port
    ResourceRegistry o-- IResourceAdapter
```

`ManageDevSpaceTypesUseCase` and `ManageProjectTemplatesUseCase` extend `ResourceUseCase`
without extra actions.

## Sequence Diagram — Fiori builds and deploys a project

```mermaid
sequenceDiagram
    actor Dev as Developer
    participant UI as Fiori app (UI5 OData v4 model)
    participant AR as Approuter
    participant OD as StudioODataController
    participant RA as ResourceAdapter (BuildConfigurations)
    participant UC as ManageBuildConfigurationsUseCase
    participant PS as ProjectStatusSync
    participant RE as ReconcileUseCase
    participant GW as IWorkspaceGateway

    Dev->>UI: Build (row "mta")
    UI->>AR: POST /odata/v4/application-studio/BuildBuildConfiguration {"id"}
    AR->>OD: forward (XSUAA token)
    OD->>RA: invoke(who, id, "build", {})
    RA->>UC: build(tenant, id, actor)
    UC->>UC: ensureCanBuild · project not archived · dev space running
    UC-->>RA: status building, BuildRun appended
    UC->>PS: sync(project) → project building
    RA-->>UI: 200 BuildConfiguration
    Note over RE: every 10 s (ReconcileWorker)
    RE->>GW: build(bc, project)
    GW-->>RE: ok, artifact mta_archives/travel-ui_1.0.0.mtar
    RE->>PS: sync(project) → project active
    Dev->>UI: Deploy
    UI->>OD: POST DeployBuildConfiguration {"id"}
    OD->>UC: deploy() → ensureCanDeploy → deploying
    RE->>GW: deploy(bc, project)
    GW-->>RE: ok → status deployed, lastDeployAt
```

## Sequence Diagram — Reconciliation of a dev space

```mermaid
sequenceDiagram
    participant W as ReconcileWorker
    participant RE as ReconcileUseCase
    participant DS as IDevSpaceRepository
    participant RC as IRunConfigurationRepository
    participant CD as CascadeDeleter
    participant GW as IWorkspaceGateway
    participant EV as IStudioEventPublisher

    W->>RE: reconcile(tenant)
    RE->>DS: findByTenant
    alt starting / resuming
        RE->>GW: startDevSpace(ds)
        GW-->>RE: url (or error)
        RE->>DS: update(status running | error)
    else stopping / hibernating
        RE->>GW: stopDevSpace / hibernateDevSpace
        RE->>RC: live runs → stopped
        RE->>DS: update(status stopped | hibernated)
    else running and idle ≥ hibernateAfterDays
        RE->>DS: update(status hibernating)
    else deleting
        RE->>CD: clearDevSpace(tenant, id)
        RE->>GW: deleteDevSpace(ds)
        RE->>DS: remove(ds)
    end
    RE->>EV: publish("studio.dev-space.<state>")
    Note over RE: then bindings (connecting), runs (starting), builds (building / deploying)
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
    actor Admin
    participant CLI as uim-studio-cli
    participant FS as data/dev_spaces.json
    participant SRV as server (SnapshotTenantStore)

    Admin->>CLI: dev-spaces create --name=FioriDev ...
    CLI->>FS: write temp file + rename (atomic)
    SRV->>FS: revision changed? (mtime)
    FS-->>SRV: reload snapshot
    SRV->>SRV: reconciler starts FioriDev
    SRV->>FS: write (status running)
    Admin->>CLI: dev-spaces get FioriDev
    CLI->>FS: read → running, url
```

## Deployment Diagram — SAP BTP (Cloud Foundry) and Kubernetes

```mermaid
flowchart TB
    subgraph User["Browser / desktop"]
        B["Fiori app (sap_horizon)"]
        G["uim-studio-gui (GtkD)"]
        C["uim-studio-cli"]
    end
    subgraph CF["SAP BTP · Cloud Foundry space (mta.yaml)"]
        AR["application-studio-approuter<br/>approuter.nodejs · resources/ = frontend"]
        SRV["application-studio-srv<br/>binary_buildpack · :8080<br/>/api/v1 · /odata/v4/application-studio"]
        XS[("application-studio-xsuaa<br/>xsuaa / application")]
        CFG[("application-studio-config<br/>user-provided")]
    end
    subgraph K8S["Kubernetes · namespace uim-platform (k8s/)"]
        POD["Deployment application-studio<br/>:8111 · /data volume"]
        SVC["Service application-studio (ClusterIP)"]
    end

    B -->|HTTPS| AR
    AR -->|destination application-studio-srv<br/>forwardAuthToken| SRV
    AR --- XS
    SRV --- XS
    SRV --- CFG
    SVC --> POD
    G -->|same data dir| FS[("backend/data/*.json")]
    C -->|same data dir| FS
```
