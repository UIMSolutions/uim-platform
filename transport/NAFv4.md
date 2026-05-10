# NAFv4 – Transport Platform Service

> **NATO Architecture Framework v4 (NAFv4) architectural description**  
> Service: Transport Platform Service (UIM Edition of SAP Cloud Transport Management)

---

## NV-1 Overview

| Attribute | Value |
|---|---|
| System Name | Transport Platform Service |
| Version | 2026.5 |
| Status | Development |
| Owner | UIM Platform Team |
| Port | 8117 |
| Protocol | HTTP/1.1 (REST/JSON) |
| Runtime | D + vibe.d (Hexagonal Architecture) |
| Container | Docker / Podman / Kubernetes |

**Mission Statement:**  
Provide controlled, auditable propagation of software deliverables (MTA archives, integration content, HTML5 applications, ABAP content) across deployment landscapes composed of Cloud Foundry, ABAP, Kyma, and Neo environments.

---

## NV-2 Capability Taxonomy

### C1 – Transport Landscape Management

| Capability | Description |
|---|---|
| C1.1 Node Management | Create, configure, enable, and disable transport nodes |
| C1.2 Route Management | Define directed transport routes between nodes |
| C1.3 Topology Modeling | Model linear, star, and complex pipeline topologies |

### C2 – Transport Request Management

| Capability | Description |
|---|---|
| C2.1 Request Registration | Accept transport requests from CI/CD pipelines and source systems |
| C2.2 Content Type Support | Handle MTA archives, integration content, HTML5 apps, ABAP content |
| C2.3 Lifecycle Management | Track request status (initial → running → success/failed/warning) |
| C2.4 Request Deletion | Remove outdated or erroneous requests |

### C3 – Import Queue Management

| Capability | Description |
|---|---|
| C3.1 Enqueue | Place transport requests into destination node import queues |
| C3.2 Selective Import | Choose which queue entries to import (isSelected flag) |
| C3.3 Scheduled Import | Schedule automatic full imports at defined times |
| C3.4 Reset | Reset failed imports for retry |
| C3.5 Queue Inspection | List and inspect queue entries per node |

### C4 – Audit Trail

| Capability | Description |
|---|---|
| C4.1 Action Recording | Record every transport operation (export, import, forward, reset, delete) |
| C4.2 Action Status | Track action lifecycle (initial → running → success/failed) |
| C4.3 Audit Query | Retrieve audit trail by node, request, action type, or status |
| C4.4 Log Details | Store execution log details per action |

### C5 – Platform Integration

| Capability | Description |
|---|---|
| C5.1 REST API | All capabilities exposed via RESTful HTTP endpoints |
| C5.2 Multi-Tenancy | All data scoped by tenantId |
| C5.3 Health Monitoring | `/health` endpoint for liveness and readiness probes |
| C5.4 Container Support | Docker, Podman, Kubernetes deployment |

---

## NV-3 Node Types (Deployment Environments)

| Node Type | Description |
|---|---|
| `cloudFoundry` | SAP BTP Cloud Foundry space |
| `abap` | SAP ABAP system (ABAP Environment, S/4HANA Cloud) |
| `kyma` | SAP BTP Kyma environment |
| `neo` | SAP BTP Neo environment (legacy) |
| `other` | Custom or external deployment target |

---

## NV-4 System Context Diagram

```
┌───────────────────────────────────────────────────────────────────────┐
│                        External Actors                                │
│                                                                       │
│  ┌──────────────┐   ┌──────────────┐   ┌────────────────────────┐   │
│  │  CI/CD       │   │  Operations  │   │  Source System         │   │
│  │  Pipeline    │   │  Team        │   │  (e.g. SAP Cloud       │   │
│  │  (export)    │   │  (import)    │   │   Integration)         │   │
│  └──────┬───────┘   └──────┬───────┘   └──────────┬─────────────┘   │
│         │                  │                       │                 │
└─────────┼──────────────────┼───────────────────────┼─────────────────┘
          │  POST /requests  │  PUT /queue-entries   │  POST /requests
          │                  │  POST /actions        │
          ▼                  ▼                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 Transport Platform Service                           │
│                        (port 8117)                                  │
│                                                                     │
│   /api/v1/transport/nodes          Transport landscape modeling     │
│   /api/v1/transport/routes         Route definition                 │
│   /api/v1/transport/requests       Transport request lifecycle      │
│   /api/v1/transport/queue-entries  Import queue management          │
│   /api/v1/transport/actions        Audit trail                      │
│   /health                          Health monitoring                │
└─────────────────────────────────────────────────────────────────────┘
          │                  │                       │
          ▼                  ▼                       ▼
┌──────────────┐    ┌──────────────┐    ┌────────────────────────┐
│  Dev Node    │    │  Test Node   │    │  Production Node       │
│  (CF Space)  │───►│  (CF Space)  │───►│  (CF / ABAP / Kyma)   │
└──────────────┘    └──────────────┘    └────────────────────────┘
       source              ↑                      ↑
                     transport route        transport route
```

---

## NV-5 Logical Data Architecture

### Aggregate: Transport Landscape

```
TransportNode (Aggregate Root)
  ├─ TransportNodeId
  ├─ name, description
  ├─ nodeType: NodeType
  ├─ status: NodeStatus
  └─ connection metadata (region, subaccountId, spaceId, serviceKey)

TransportRoute (Aggregate Root)
  ├─ TransportRouteId
  ├─ sourceNodeId → TransportNode
  ├─ destinationNodeId → TransportNode
  └─ status: RouteStatus
```

### Aggregate: Transport Request

```
TransportRequest (Aggregate Root)
  ├─ TransportRequestId
  ├─ contentType: ContentType
  ├─ status: RequestStatus
  ├─ storageUrl, checksum, version_
  └─ sourceNodeId → TransportNode
```

### Aggregate: Import Queue

```
ImportQueueEntry (Aggregate Root)
  ├─ ImportQueueEntryId
  ├─ nodeId → TransportNode
  ├─ requestId → TransportRequest
  ├─ status: ImportStatus
  └─ queuePosition, scheduledAt, importLog
```

### Aggregate: Audit Trail

```
TransportAction (Aggregate Root)
  ├─ TransportActionId
  ├─ actionType: ActionType
  ├─ actionStatus: ActionStatus
  ├─ nodeId → TransportNode
  ├─ requestId → TransportRequest
  ├─ routeId → TransportRoute
  └─ performedBy, logDetails
```

---

## NV-6 Technology Architecture

| Tier | Technology |
|---|---|
| Language | D (dlang) |
| HTTP Framework | vibe.d 0.10.x + vibe-http 1.5.x |
| Serialization | vibe-serialization 1.2.x |
| Persistence | In-memory (MemoryTenantRepository) |
| Build | dub (D package manager) |
| Container Build | Alpine + LDC2 (multi-stage) |
| Container Runtime | Docker, Podman |
| Orchestration | Kubernetes (Deployment, Service, ConfigMap) |
| Health Check | HTTP GET /health |
| Port | 8117 |

### Container Multi-Stage Build

```
Stage 1 (build):  alpine:3.20 + ldc + dub  →  compile binary
Stage 2 (run):    alpine:3.20 + libgcc      →  minimal runtime image
```

---

## NV-7 Security Architecture

| Concern | Mechanism |
|---|---|
| Multi-tenancy | All data scoped by `X-Tenant-Id` header (tenantId) |
| Input validation | Domain service (`TransportValidator`) validates all writes |
| Error information | Internal errors return generic "Internal server error" |
| Container security | Runs as non-root; no unnecessary packages in runtime image |
| Network | ClusterIP service – not exposed directly to internet |

---

## NV-8 Deployment View

### Kubernetes Resources

| Resource | Name | Description |
|---|---|---|
| ConfigMap | `transport-config` | HOST and PORT environment variables |
| Deployment | `transport` | 1 replica, health probes, resource limits |
| Service | `transport` | ClusterIP, port 8117 |

### Resource Limits

| Resource | Request | Limit |
|---|---|---|
| Memory | 64 Mi | 256 Mi |
| CPU | 100m | 500m |

---

## NV-9 Integration Interfaces

| Interface | Direction | Protocol | Description |
|---|---|---|---|
| Transport Request API | Inbound | HTTP POST | CI/CD pipelines register transport requests |
| Import Queue API | Inbound | HTTP POST/PUT | Operations teams manage import queues |
| Audit Action API | Inbound | HTTP POST/PUT | Source systems and operators record actions |
| Health Probe | Inbound | HTTP GET | Kubernetes liveness/readiness probes |
| Node/Route Admin | Inbound | HTTP REST | Landscape administrators configure topology |

---

## NV-10 Quality Attributes

| Quality Attribute | Approach |
|---|---|
| Maintainability | Hexagonal + Clean Architecture, single-responsibility layers |
| Testability | Port interfaces enable mock adapters; use case layer is framework-free |
| Portability | Stateless design; in-memory repo can be swapped for any DB adapter |
| Observability | Structured audit trail, health endpoint, container-ready logging |
| Scalability | Stateless HTTP service; horizontal scaling via Kubernetes replica count |
| Security | Tenant isolation, input validation, minimal container image |
