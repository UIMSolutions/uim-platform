# UML Diagrams — Cloud Transport Management

Diagrams of the redesigned transport service (backend `backend/source/uim/platform/transport`,
Fiori app `frontend/`, approuter `approuter/`). See [README.md](README.md) for the
overview and [NAFv4.md](NAFv4.md) for the architecture description.

## 1. Domain model (class diagram)

```mermaid
classDiagram
    direction LR
    class TenantEntity {
        <<mixin>>
        +TenantId tenantId
        +TId id
        +UserId createdBy
        +long createdAt
        +UserId updatedBy
        +long updatedAt
        +isNull() bool
    }
    class TransportNode {
        +string name
        +string description
        +NodeType nodeType
        +NodeStatus status
        +string environment
        +string region
        +string globalAccount
        +SubaccountId subaccountId
        +SpaceId spaceId
        -string serviceKey
        +bool isForwardEnabled
        +bool autoImport
        +string autoImportSchedule
        +long lastCheckedAt
        +string connectionStatus
        +isEnabled() bool
        +enable()
        +disable()
    }
    class TransportRoute {
        +string name
        +string description
        +TransportNodeId sourceNodeId
        +TransportNodeId destinationNodeId
        +RouteStatus status
        +bool isSequential
        +int sequence
        +isEnabled() bool
        +connects(src, dst) bool
    }
    class TransportRequest {
        +string name
        +string description
        +string externalId
        +ContentType contentType
        +RequestStatus status
        +string version_
        +string storageUrl
        +string checksum
        +TransportNodeId sourceNodeId
        +string namedUser
        +long queuedAt
        +long importedAt
        +string errorMessage
        +hasContent() bool
    }
    class ImportQueueEntry {
        +TransportNodeId nodeId
        +TransportRequestId requestId
        +ImportStatus status
        +int queuePosition
        +bool isSelected
        +long queuedAt
        +long startedAt
        +long completedAt
        +string importLog
        +string errorMessage
        +isPending() bool
        +isImportable() bool
        +start(now)
        +finish(status, now, log, error)
        +reset(now)
    }
    class TransportAction {
        +ActionType actionType
        +ActionStatus actionStatus
        +TransportNodeId nodeId
        +TransportRequestId requestId
        +TransportRouteId routeId
        +string performedBy
        +long performedAt
        +string description
        +string logDetails
        +complete(status, now, error)
    }

    TenantEntity <|.. TransportNode
    TenantEntity <|.. TransportRoute
    TenantEntity <|.. TransportRequest
    TenantEntity <|.. ImportQueueEntry
    TenantEntity <|.. TransportAction

    TransportRoute "*" --> "1" TransportNode : source
    TransportRoute "*" --> "1" TransportNode : destination
    TransportRequest "*" --> "0..1" TransportNode : source node
    ImportQueueEntry "*" --> "1" TransportNode : queue of
    ImportQueueEntry "*" --> "1" TransportRequest : carries
    TransportAction "*" --> "0..1" TransportRequest : about
    TransportAction "*" --> "0..1" TransportNode : at
    TransportAction "*" --> "0..1" TransportRoute : via
```

### Enumerations

```mermaid
classDiagram
    direction LR
    class NodeType {
        <<enumeration>>
        cloudFoundry
        abap
        neo
        kyma
        other
    }
    class NodeStatus {
        <<enumeration>>
        enabled
        disabled
    }
    class RouteStatus {
        <<enumeration>>
        enabled
        disabled
    }
    class ContentType {
        <<enumeration>>
        mtaArchive
        integrationContent
        htmlApp
        abapCorContent
        other
    }
    class RequestStatus {
        <<enumeration>>
        initial
        running
        success
        failed
        warning
        outdated
        repeating
    }
    class ImportStatus {
        <<enumeration>>
        initial
        running
        success
        failed
        warning
        repeating
    }
    class ActionType {
        <<enumeration>>
        export
        import
        forward
        reset
        delete
        schedule
    }
    class ActionStatus {
        <<enumeration>>
        initial
        running
        success
        failed
        warning
    }
```

External names drop D's trailing underscore (`ActionType.export_` ⇄ `"export"`), see
`domain/enumerations/names.d`.

### Domain services

```mermaid
classDiagram
    class TransportValidator {
        <<static>>
        +validateNode(node) string
        +validateRoute(route) string
        +validateRequest(request) string
        +validateQueueEntry(entry) string
        +validateAction(action) string
    }
    class TransportLandscape {
        +TransportNode[] nodes
        +TransportRoute[] routes
        +outgoing(nodeId) TransportRoute[]
        +destinations(nodeId) TransportNodeId[]
        +entryNodes() TransportNode[]
        +hasRoute(src, dst) bool
        +wouldCreateCycle(src, dst) bool
        +reachableFrom(nodeId) TransportNodeId[]
        +render() string
    }
    class aggregateRequestStatus {
        <<function>>
        +(entries) RequestStatus
    }
```

## 2. Hexagonal architecture (component diagram)

```mermaid
flowchart LR
    subgraph Driving["Driving adapters (presentation)"]
        REST["REST controllers<br/>/api/v1/transport"]
        ODATA["OData v4 controller<br/>/odata/v4/transport"]
        CLI["TransportCli<br/>uim-transport-cli"]
        GUI["TransportWindow (GtkD)<br/>uim-transport-gui"]
        WORKER["AutoImportWorker"]
        WEB["FrontendController<br/>(static Fiori app)"]
    end

    subgraph Ports["Driving ports — TransportPorts"]
        PN["IManageTransportNodesUseCase"]
        PR["IManageTransportRoutesUseCase"]
        PQ["IManageTransportRequestsUseCase"]
        PI["IManageImportQueueUseCase"]
        PA["IManageTransportActionsUseCase"]
        PO["ITransportOperationsUseCase"]
        PS["ITransportStatisticsService<br/>ITransportLandscapeService"]
    end

    subgraph App["Application"]
        UC["Manage* use cases"]
        OPS["TransportOperationsUseCase"]
        STAT["TransportStatisticsService"]
        REC["TransportActionRecorder<br/>syncRequestStatus"]
    end

    subgraph Domain["Domain"]
        ENT["Entities"]
        DS["TransportValidator<br/>TransportLandscape<br/>aggregateRequestStatus"]
    end

    subgraph Driven["Driven ports"]
        RP["I*Repository"]
        GW["IDeploymentGateway"]
        MSG["ITransportEventPublisher"]
        ST["ISnapshotStorage"]
    end

    subgraph Adapters["Driven adapters"]
        REPO["*Repository + SnapshotTenantStore"]
        JSON["JsonFileSnapshotStorage<br/>MemorySnapshotStorage"]
        SIM["SimulatedDeploymentGateway"]
        LOG["LogEventPublisher"]
    end

    REST & ODATA & CLI & GUI & WORKER --> Ports
    Ports --> App
    App --> Domain
    App --> Driven
    REPO -.implements.-> RP
    REPO --> ST
    JSON -.implements.-> ST
    SIM -.implements.-> GW
    LOG -.implements.-> MSG
```

`infrastructure/container.d` wires everything; the entry points `app.d`, `cli.d` and
`gui.d` build the adapters on `container.ports`.

## 3. Deployment view (SAP BTP)

```mermaid
flowchart LR
    U["Browser<br/>(Fiori app)"] -->|HTTPS| AR["transport-approuter<br/>@sap/approuter"]
    AR -->|login| XSUAA[("transport-xsuaa")]
    AR -->|"/odata/v4/transport, /api/v1<br/>+ JWT"| SRV["transport-srv<br/>D / vibe.d"]
    SRV --> DATA[("data/*.json snapshots")]
    SRV -.->|VCAP_SERVICES| CFG[("transport-config<br/>user-provided")]
    CLIU["Admin: CLI / GtkD GUI"] --> DATA
```

## 4. Sequence — export, import and forward

```mermaid
sequenceDiagram
    actor Op as Operator (Fiori / CLI / GUI)
    participant AD as Adapter (OData / CLI / GUI)
    participant OPS as TransportOperationsUseCase
    participant L as TransportLandscape
    participant Q as IImportQueueEntryRepository
    participant GW as IDeploymentGateway
    participant REC as TransportActionRecorder
    participant R as ITransportRequestRepository

    Op->>AD: Export request "my-app"
    AD->>OPS: exportRequest(ExportInput)
    OPS->>L: outgoing(DEV)
    L-->>OPS: [route DEV→QA]
    OPS->>Q: save(entry @ QA)
    OPS->>REC: record(export, success)
    OPS->>R: syncRequestStatus → initial
    OPS-->>AD: ok "exported to 1 node(s): QA"

    Op->>AD: Import queue of QA
    AD->>OPS: importNode(ImportInput{QA})
    loop each selected pending entry (queue order)
        OPS->>Q: entry.start() / update
        OPS->>GW: deploy(QA, request)
        GW-->>OPS: DeploymentResult(success, log)
        OPS->>Q: entry.finish(success) / update
        OPS->>REC: record(import, success, log)
        alt success / warning and QA.isForwardEnabled
            OPS->>L: outgoing(QA)
            OPS->>Q: save(entry @ PROD)
            OPS->>REC: record(forward, success)
        end
        OPS->>R: syncRequestStatus → running (still queued in PROD)
    end
    OPS-->>AD: ok + ImportRunSummary{succeeded, failed, forwarded}
```

## 5. Sequence — creating a route (cycle protection)

```mermaid
sequenceDiagram
    participant AD as Adapter
    participant UC as ManageTransportRoutesUseCase
    participant V as TransportValidator
    participant N as ITransportNodeRepository
    participant RR as ITransportRouteRepository
    participant L as TransportLandscape

    AD->>UC: createRoute(CreateRouteInput)
    UC->>V: validateRoute
    UC->>N: findById(source), findById(destination)
    UC->>RR: findByTenant
    UC->>L: hasRoute(src, dst)?  wouldCreateCycle(src, dst)?
    alt duplicate
        UC-->>AD: 409 Conflict
    else cycle
        UC-->>AD: 422 would create a cycle
    else ok
        UC->>RR: save(route)
        UC-->>AD: ok(routeId)
    end
```

## 6. State machine — import queue entry

```mermaid
stateDiagram-v2
    [*] --> initial : export / forward / enqueue
    initial --> running : import
    repeating --> running : import
    running --> success : deploy ok
    running --> warning : deploy with warnings
    running --> failed : deploy error
    success --> repeating : reset
    warning --> repeating : reset
    failed --> repeating : reset
    initial --> [*] : delete
    repeating --> [*] : delete
    success --> [*] : delete
    warning --> [*] : delete
    failed --> [*] : delete
```

The aggregated request status follows: any `failed` → failed; any `running` → running;
any `repeating` → repeating; some `initial` and some finished → running (in transit);
all `initial` → initial; any `warning` → warning; otherwise success.

## 7. Presentation — Fiori app structure

```mermaid
flowchart TB
    C["Component.js<br/>manifest.json (OData V4, $direct)"] --> APP["App.view"]
    APP --> MAIN["Main.view<br/>DynamicPage + KPI header (/Statistics)"]
    APP --> DET["RequestDetail.view<br/>ObjectHeader + queue entries + history"]
    MAIN --> T1["Overview: status tiles, routes"]
    MAIN --> T2["Nodes"]
    MAIN --> T3["Routes"]
    MAIN --> T4["Requests"]
    MAIN --> T5["Import Queues"]
    MAIN --> T6["Audit Trail"]
    MAIN -.-> FR["fragments: CreateNode / CreateRoute / CreateRequest"]
    MAIN & DET -.->|"BaseController.callAction"| ACT["OData actions<br/>ExportRequest, ImportNode, ResetQueueEntry, …"]
```
