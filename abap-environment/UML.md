# UML — ABAP Environment Service

Diagrams of the hexagonal backend (`backend/source/uim/platform/abap_environment`), the
Fiori frontend and the BTP deployment. All diagrams are Mermaid.

## Class Diagram — Domain Entities

All aggregates mix in `TenantEntity` (`tenantId`, `id`, `createdBy/At`, `updatedBy/At`).
Every aggregate except `SystemInstance` belongs to one system; transports belong to their
source system and reference a target system.

```mermaid
classDiagram
    class SystemInstance {
        +SystemInstanceId id
        +SubaccountId subaccountId
        +string name
        +SystemPlan plan
        +SystemStatus status
        +string region
        +string sapSystemId
        +string adminEmail
        +int abapRuntimeSize
        +int hanaMemorySize
        +string serviceUrl
        +string webSocketUrl
        +string sapClient
        +string softwareVersion
        +long activatedAt
    }
    class SoftwareComponent {
        +SoftwareComponentId id
        +string name
        +ComponentType componentType
        +ComponentStatus status
        +string repositoryUrl
        +string branch
        +BranchStrategy branchStrategy
        +string currentCommitId
        +ComponentCommit[] commitHistory
        +string namespace
        +long clonedAt
        +long lastPulledAt
    }
    class CommunicationArrangement {
        +CommunicationArrangementId id
        +string name
        +CommunicationScenarioId scenarioId
        +CommunicationDirection direction
        +ArrangementStatus status
        +string communicationSystem
        +CommunicationAuthMethod authMethod
        +string communicationUser
        +string communicationPassword «secret»
        +string clientId
        +string clientSecret «secret»
        +string tokenEndpoint
        +string certificateId
        +CommunicationEndpoint[] inboundServices
        +CommunicationEndpoint[] outboundServices
    }
    class ServiceBinding {
        +ServiceBindingId id
        +string name
        +string serviceDefinition
        +BindingType bindingType
        +string serviceVersion
        +BindingStatus status
        +ExposedEndpoint[] endpoints
        +string serviceUrl
        +string metadataUrl
        +long publishedAt
    }
    class BusinessRole {
        +BusinessRoleId id
        +string name
        +RoleType roleType
        +string[] businessCatalogs
        +string[] restrictionTypes
    }
    class BusinessUser {
        +BusinessUserId id
        +string name
        +string firstName
        +string lastName
        +string email
        +UserStatus status
        +string[] roles
        +RoleAssignment[] roleAssignments
        +bool passwordChangeRequired
        +int failedLoginAttempts
        +long lockedAt
    }
    class TransportRequest {
        +TransportRequestId id
        +string name «SIDK9nnnnn»
        +string description
        +string owner
        +TransportType transportType
        +TransportStatus status
        +TransportTask[] tasks
        +long releasedAt
        +long importedAt
    }
    class ApplicationJob {
        +ApplicationJobId id
        +string name
        +string jobTemplateName
        +JobFrequency frequency
        +long scheduledAt
        +string cronExpression
        +bool active
        +JobStatus status
        +KeyValue[] parameters
        +JobExecutionLog[] executionHistory
        +int runCount
    }
    class TransportTask {
        +string taskId
        +string owner
        +TransportStatus status
        +string[] objects
        +long releasedAt
    }
    class RoleAssignment {
        +BusinessRoleId roleId
        +string roleName
        +long assignedAt
    }
    class JobExecutionLog {
        +string runId
        +JobStatus status
        +long startedAt
        +long finishedAt
        +int returnCode
        +string message
    }
    class ComponentCommit {
        +string commitId
        +string branch
        +string message
        +string author
        +long committedAt
    }

    SystemInstance "1" o-- "*" SoftwareComponent : systemInstanceId
    SystemInstance "1" o-- "*" CommunicationArrangement : systemInstanceId
    SystemInstance "1" o-- "*" ServiceBinding : systemInstanceId
    SystemInstance "1" o-- "*" BusinessRole : systemInstanceId
    SystemInstance "1" o-- "*" BusinessUser : systemInstanceId
    SystemInstance "1" o-- "*" ApplicationJob : systemInstanceId
    SystemInstance "1" o-- "*" TransportRequest : sourceSystemId
    TransportRequest "*" --> "0..1" SystemInstance : targetSystemId
    TransportRequest *-- "*" TransportTask
    BusinessUser *-- "*" RoleAssignment
    RoleAssignment --> BusinessRole : roleId
    ApplicationJob *-- "*" JobExecutionLog
    SoftwareComponent *-- "*" ComponentCommit
```

Deleting a system deletes all objects of the system; transports from other systems that
wait for an import into it fail. A business role that is assigned to users cannot be deleted.

## State Diagram — Lifecycles driven by actions and the reconciler

```mermaid
stateDiagram-v2
    state "SystemInstance" as Sys {
        [*] --> provisioning : create
        provisioning --> active : reconcile
        active --> updating : upgrade / resize
        updating --> active : reconcile
        active --> suspended : suspend
        suspended --> active : resume
        active --> deleting : delete
        suspended --> deleting : delete
        error --> deleting : delete
        deleting --> [*] : reconcile (cascade)
    }
    state "SoftwareComponent" as Sc {
        [*] --> notCloned : create
        notCloned --> cloning : clone
        cloning --> cloned : reconcile
        cloning --> scError : branch unreadable
        cloned --> pulling : pull / checkout
        pulling --> cloned : reconcile
        scError --> cloning : clone
    }
    state "TransportRequest" as Tr {
        [*] --> modifiable : create
        modifiable --> released : release (all tasks released)
        released --> importing : import
        importing --> imported : reconcile
        importing --> trError : import fails
        trError --> importing : import
    }
    state "ApplicationJob" as Job {
        [*] --> scheduled : create
        scheduled --> running : due (reconcile) / run
        running --> scheduled : reconcile (recurring)
        running --> completed : reconcile (rc = 0)
        running --> failed : reconcile (rc ≠ 0)
        scheduled --> canceled : cancel
        running --> canceled : cancel
        canceled --> scheduled : reactivate
        completed --> scheduled : reactivate
        failed --> scheduled : reactivate
    }
```

Action-only transitions: service binding `unpublished → published → deprecated`
(and back to `unpublished`), communication arrangement `active ⇄ inactive`, business
user `active → locked → active`. Components, imports and jobs only progress while their
system (for imports: the target system) is active.

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
    subgraph Driving["Driving adapters (presentation)"]
        REST["http · AbapRestController<br/>/api/v1"]
        OD["odata · AbapODataController<br/>/odata/v4/abap-environment + $metadata"]
        CLI["cli · AbapCli"]
        GUI["gui · AbapWindow (GtkD)"]
        WEB["web · FrontendController<br/>Fiori app (local dev)"]
        REG["resources · ResourceRegistry<br/>8 × ResourceAdapter"]
    end
    subgraph Core["Application core"]
        PORTS["ports · AbapPorts<br/>IManageResource&lt;…&gt; × 8<br/>IReconcileUseCase · IAbapStatisticsService"]
        UC["application · ResourceUseCase&lt;…&gt; × 8<br/>ReconcileUseCase · AbapStatisticsService<br/>CascadeDeleter"]
        DOM["domain · entities · names & SIDs<br/>system lifecycle · communication policy<br/>transport policy · job schedule · service URLs"]
    end
    subgraph Driven["Driven adapters"]
        REPO["persistence · 8 repositories<br/>RecordMapper&lt;T&gt;"]
        STORE["storages · SnapshotTenantStore<br/>JsonFileSnapshotStorage"]
        GW["clients · SimulatedLandscapeGateway<br/>(IAbapLandscapeGateway)"]
        PUB["logging · LogEventPublisher<br/>(IAbapEventPublisher)"]
    end
    INFRA["infrastructure · AbapConfig · identity · ReconcileWorker · Container"]

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

Dependencies point inwards: presentation knows only `AbapPorts`; use cases know only
port interfaces (`AbapRepositories`, `IAbapLandscapeGateway`, `IAbapEventPublisher`).

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
        #AbapRepositories repos
        #IAbapEventPublisher publisher
        #build(TCreate) TEntity*
        #apply(ref TEntity, TSpec)*
        #beforeRemove(TEntity)
        #retire(ref TEntity) bool
        #transition(tenant, id, actor, verb, change) UsecaseResult
        #requireActiveSystem(tenant, id, forWhat) SystemInstance
        #ensureUnique(existing, candidate, scope)
    }
    class ManageSystemsUseCase {
        +suspend()
        +resume()
        +upgrade(softwareVersion)
        #retire() bool
    }
    class ManageTransportRequestsUseCase {
        +addTask(owner, description, objects)
        +releaseTask(taskId)
        +release()
        +import_()
    }
    class IResourceAdapter {
        <<interface>>
        +path() / setName() / typeName()
        +fields() / inputFields() / recordTypes()
        +columns() / actions()
        +list() / get() / create() / update() / remove() / invoke()
    }
    class ResourceAdapter~TEntity,TId,TCreate,TUpdate~ {
        +column(header, field)
        +action(name, label, handler, parameters)
        +secret(field)
        #payload(TEntity) Json
        #unmask(Json) Json
    }
    class ResourceRegistry {
        +adapters() IResourceAdapter[]
        +byPath(path) / bySet(set) / byODataAction(name)
        +resolve(adapter, tenant, idOrName) string
        +withReferences(tenant, body) Json
        +statistics(tenant) / reconcile(tenant) Json
    }
    IManageResource <|.. ResourceUseCase
    ResourceUseCase <|-- ManageSystemsUseCase
    ResourceUseCase <|-- ManageTransportRequestsUseCase
    IResourceAdapter <|.. ResourceAdapter
    ResourceAdapter --> IManageResource : port
    ResourceRegistry o-- "8" IResourceAdapter
```

The other six interactors (`ManageSoftwareComponentsUseCase`, `ManageCommunicationArrangementsUseCase`,
`ManageServiceBindingsUseCase`, `ManageBusinessRolesUseCase`, `ManageBusinessUsersUseCase`,
`ManageApplicationJobsUseCase`) follow the same pattern. Persistence mirrors it:
`SystemScopedRepository<TEntity, TId>` provides `findByName` / `findBySystem` for all
system-scoped aggregates.

## Sequence Diagram — Fiori releases and imports a transport

```mermaid
sequenceDiagram
    actor Dev as Developer
    participant UI as Fiori app (Main.controller)
    participant AR as Approuter (XSUAA)
    participant OD as AbapODataController
    participant REG as ResourceRegistry
    participant UC as ManageTransportRequestsUseCase
    participant POL as transport policy
    participant REPO as TransportRequestRepository

    Dev->>UI: select DEVK900001, press "Release"
    UI->>AR: POST /odata/v4/abap-environment/ReleaseTransportRequest {"id": "…"}
    AR->>OD: forward + JWT (AbapDeveloper scope checked)
    OD->>REG: byODataAction("ReleaseTransportRequest")
    REG->>UC: release(tenant, id, user)
    UC->>REPO: findById
    UC->>POL: ensureReleasable(request)
    alt a task is still modifiable
        POL-->>UC: AbapConflictException
        UC-->>OD: UsecaseResult(code 409)
        OD-->>UI: 409 {"error": {"code": "Conflict", …}}
    else releasable
        UC->>REPO: update(status = released)
        UC-->>OD: success
        OD-->>UI: 200 TransportRequest
        Dev->>UI: press "Import"
        UI->>OD: POST ImportTransportRequest → status importing
    end
```

## Sequence Diagram — Reconciliation

```mermaid
sequenceDiagram
    participant W as ReconcileWorker (timer)
    participant R as ReconcileUseCase
    participant REPOS as AbapRepositories
    participant GW as IAbapLandscapeGateway
    participant C as CascadeDeleter
    participant P as IAbapEventPublisher

    W->>R: reconcile(tenant)
    loop systems
        alt provisioning
            R->>GW: provision(system)
            GW-->>R: serviceUrl, webSocketUrl, stack
            R->>REPOS: update(active)
        else deleting
            R->>C: clearSystem(tenant, id)
            R->>GW: deprovision(system)
            R->>REPOS: remove(system)
        end
        R->>P: abap.system.*
    end
    loop components cloning / pulling (active system)
        R->>GW: headCommit(repositoryUrl, branch)
        R->>REPOS: update(cloned + commit) or error
    end
    loop transports importing (active target)
        R->>GW: importTransport(request, target)
        R->>REPOS: update(imported | error)
    end
    loop jobs due or running
        R->>GW: runJob(job)
        R->>REPOS: update(completed | failed | rescheduled)
    end
    R-->>W: ReconcileReport(examined, advanced, changes)
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
    actor Admin
    participant CLI as uim-abap-cli
    participant FS as data/*.json
    participant SRV as server (SnapshotTenantStore)

    Admin->>CLI: systems create --name=dev …
    CLI->>FS: write systems.json (temp file + rename)
    SRV->>FS: revision changed? → reload before next read
    SRV-->>SRV: reconciler provisions "dev"
    SRV->>FS: write systems.json
    Admin->>CLI: systems get dev
    CLI->>FS: reload → status active
```

## Deployment Diagram — SAP BTP (Cloud Foundry)

```mermaid
flowchart TB
    User(["Browser"]) -->|HTTPS| AR
    subgraph CF["Cloud Foundry space (mta.yaml)"]
        AR["abap-environment-approuter<br/>@sap/approuter · Fiori app in resources/"]
        SRV["abap-environment-srv<br/>binary buildpack · uim-abap-environment-platform-service"]
        XSUAA[("abap-environment-xsuaa<br/>xsuaa / application")]
        CFG[("abap-config<br/>user-provided")]
    end
    AR -->|"destination abap-environment-srv<br/>/odata/v4/abap-environment · /api/v1"| SRV
    AR -. login / token .-> XSUAA
    SRV -. VCAP_SERVICES .-> XSUAA
    SRV -. VCAP_SERVICES .-> CFG
    Desk(["Desktop: uim-abap-gui / uim-abap-cli"]) -->|"same data dir (local)"| Local[("backend/data/*.json")]
```
