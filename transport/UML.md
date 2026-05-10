# UML – Transport Platform Service

## Class Diagram (Domain Layer)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DOMAIN ENTITIES                                │
├────────────────────┬────────────────────────────────────────────────────┤
│  TransportNode     │  TransportRoute                                    │
│  ────────────────  │  ────────────────────────────────────────────────  │
│  id: NodeId        │  id: RouteId                                       │
│  tenantId          │  tenantId                                          │
│  name              │  name                                              │
│  description       │  description                                       │
│  nodeType          │  sourceNodeId ──────────────────────────►NodeId    │
│  status            │  destinationNodeId ─────────────────────►NodeId    │
│  environment       │  status: RouteStatus                               │
│  region            │  isSequential: bool                                │
│  globalAccount     │  sequence: int                                     │
│  subaccountId      ├────────────────────────────────────────────────────┤
│  spaceId           │  TransportRequest                                  │
│  isForwardEnabled  │  ────────────────────────────────────────────────  │
│  autoImport        │  id: RequestId                                     │
│  toJson()          │  tenantId                                          │
├────────────────────┤  name                                              │
│  ImportQueueEntry  │  contentType: ContentType                          │
│  ────────────────  │  status: RequestStatus                             │
│  id: EntryId       │  version_                                          │
│  tenantId          │  storageUrl                                        │
│  nodeId ──────────►NodeId                                               │
│  requestId ───────►RequestId                                            │
│  status: ImportStatus                                                   │
│  queuePosition     ├────────────────────────────────────────────────────┤
│  isSelected        │  TransportAction                                   │
│  scheduledAt       │  ────────────────────────────────────────────────  │
│  importLog         │  id: ActionId                                      │
│  toJson()          │  tenantId                                          │
│                    │  actionType: ActionType                             │
│                    │  actionStatus: ActionStatus                         │
│                    │  nodeId ────────────────────────────────────►NodeId │
│                    │  requestId ────────────────────────────►RequestId  │
│                    │  routeId ────────────────────────────────►RouteId  │
│                    │  performedBy                                        │
│                    │  logDetails                                         │
│                    │  toJson()                                           │
└────────────────────┴────────────────────────────────────────────────────┘
```

---

## Interface (Port) Diagram

```
ITenantRepository<E, ID>
        │
        ├── TransportNodeRepository
        │       findByStatus(), findByType()
        │
        ├── TransportRouteRepository
        │       findBySourceNode(), findByDestinationNode(), findByStatus()
        │
        ├── TransportRequestRepository
        │       findByStatus(), findBySourceNode(), findByContentType()
        │
        ├── ImportQueueEntryRepository
        │       findByNode(), findByRequest(), findByStatus(),
        │       findByNodeAndStatus()
        │
        └── TransportActionRepository
                findByNode(), findByRequest(), findByType(), findByStatus()
```

---

## Component Diagram (Hexagonal Architecture)

```
┌────────────────────────────────────────────────────────────────────────┐
│                     Transport Platform Service                         │
│                                                                        │
│  ┌─────────────────────────────┐    ┌──────────────────────────────┐  │
│  │    PRESENTATION (HTTP)       │    │      APPLICATION             │  │
│  │  ─────────────────────────  │    │  ──────────────────────────  │  │
│  │  TransportNodeController    │───►│  ManageTransportNodesUseCase │  │
│  │  TransportRouteController   │───►│  ManageTransportRoutes...    │  │
│  │  TransportRequestController │───►│  ManageTransportRequests...  │  │
│  │  ImportQueueEntryController │───►│  ManageImportQueueEntries... │  │
│  │  TransportActionController  │───►│  ManageTransportActions...   │  │
│  │  HealthController           │    │                              │  │
│  └─────────────────────────────┘    └──────────┬───────────────────┘  │
│                                                │ calls                 │
│                                     ┌──────────▼───────────────────┐  │
│                                     │         DOMAIN               │  │
│                                     │  ─────────────────────────   │  │
│                                     │  TransportNode               │  │
│                                     │  TransportRoute              │  │
│                                     │  TransportRequest            │  │
│                                     │  ImportQueueEntry            │  │
│                                     │  TransportAction             │  │
│                                     │  TransportValidator          │  │
│                                     │  <<ports>>                   │  │
│                                     │  TransportNodeRepository     │  │
│                                     │  TransportRouteRepository    │  │
│                                     │  ...                         │  │
│                                     └──────────▲───────────────────┘  │
│                                                │ implements            │
│                                     ┌──────────┴───────────────────┐  │
│                                     │     INFRASTRUCTURE           │  │
│                                     │  ─────────────────────────   │  │
│                                     │  MemoryTransportNodeRepo     │  │
│                                     │  MemoryTransportRouteRepo    │  │
│                                     │  MemoryTransportRequestRepo  │  │
│                                     │  MemoryImportQueueEntryRepo  │  │
│                                     │  MemoryTransportActionRepo   │  │
│                                     │  Container / loadConfig()    │  │
│                                     └──────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Sequence Diagram – Export Transport Request

```
CI/CD Pipeline          HTTP API          TransportRequestController
      │                    │                         │
      │  POST /requests    │                         │
      │───────────────────►│  handleCreate()         │
      │                    │────────────────────────►│
      │                    │                    ManageTransportRequestsUseCase
      │                    │                         │──────────────────────►│
      │                    │                         │  createRequest(dto)   │
      │                    │                         │◄──────────────────────│
      │                    │  201 {id, message}      │
      │◄───────────────────│◄────────────────────────│
      │                    │                         │
```

---

## Sequence Diagram – Import Queue Flow

```
Operator    ImportQueueEntryController    ManageImportQueueEntriesUseCase
    │                  │                              │
    │  POST /queue-entries (enqueue)                  │
    │─────────────────►│  enqueue(dto)               │
    │                  │────────────────────────────►│
    │                  │                   save to repo
    │◄─────────────────│  201 {id}                   │
    │                  │                             │
    │  PUT /queue-entries/:id {status:"running"}      │
    │─────────────────►│  updateEntryStatus()        │
    │                  │────────────────────────────►│
    │                  │◄────────────────────────────│
    │◄─────────────────│  200 {message:"Status updated"}
    │                  │                             │
    │  PUT /queue-entries/:id {status:"success"}      │
    │─────────────────►│  updateEntryStatus()        │
    │                  │────────────────────────────►│
    │◄─────────────────│  200                        │
```

---

## State Machine – Transport Request Lifecycle

```
       ┌──────────┐
  ──►  │ initial  │
       └────┬─────┘
            │ start import
            ▼
       ┌──────────┐
       │ running  │
       └──┬───┬───┘
     ok   │   │ error
          │   ▼
          │ ┌─────────┐
          │ │ failed  │◄─── retry ───┐
          │ └─────────┘              │
          │                          │
          ▼                          │
       ┌──────────┐    reset    ┌────┴──────┐
       │ success  │◄────────────│ repeating │
       └──────────┘             └───────────┘
            │
            │ newer version available
            ▼
       ┌──────────┐
       │ outdated │
       └──────────┘
```
