# NAF v4 Architecture Description — Cloud Transport Management

> NATO Architecture Framework v4 (NAF v4) description of the UIM Platform
> **Cloud Transport Management** service: governed propagation of software
> deliverables (MTA archives, integration content, HTML5 apps, ABAP content)
> through a landscape of transport nodes, modelled on SAP Cloud Transport
> Management. Implementation: D/vibe.d backend (REST, OData v4, CLI, GtkD GUI),
> SAP Fiori 3 frontend and SAP approuter — see [README.md](README.md) and
> [UML.md](UML.md).

---

## 1. NAF v4 grid mapping

| NAF view | Viewpoint | Section |
|---|---|---|
| **C1** Capability Taxonomy | Capabilities and sub-capabilities | §2.1 |
| **C2** Enterprise Vision | Mission, vision, scope, stakeholders | §2.2 |
| **C4** Standard Processes | Transport workflow | §2.3 |
| **S1** Service Taxonomy | Services offered | §3.1 |
| **S2** Service Structure / Interfaces | REST, OData, CLI, GUI | §3.2 |
| **S4** Service Functions | Service → use case mapping | §3.3 |
| **L2** Logical Scenario | Logical nodes and flows | §4.1 |
| **L4** Logical Activities | Activities per role | §4.2 |
| **L6** Logical Sequence | Export / import / forward | §4.3 |
| **L7** Logical Data Model | Entities and relationships | §5 |
| **P1** Resource Types | Software components | §6.1 |
| **P2** Resource Structure | Hexagonal layers | §6.2 |
| **P3** Resource Connectivity | Physical deployment (BTP, Kubernetes) | §6.3 |
| **A2** Architecture Meta-data / Decisions | Architecture decisions | §7 |
| **A3** Standards | Standards and protocols | §8 |
| **Security** | Authentication, authorization, data protection | §9 |

---

## 2. Capability views

### 2.1 C1 — Capability taxonomy

```text
Cloud Transport Management
├── C1  Transport Landscape
│   ├── C1.1  Maintain transport nodes (Cloud Foundry, ABAP, Neo, Kyma, other)
│   ├── C1.2  Maintain transport routes (directed, acyclic, enable/disable)
│   ├── C1.3  Visualize the landscape topology
│   └── C1.4  Check node connectivity
├── C2  Transport Requests
│   ├── C2.1  Register transport requests (content type, version, archive, checksum)
│   ├── C2.2  Export from the source node into follow-on import queues
│   ├── C2.3  Forward along the routes
│   └── C2.4  Track aggregated request status
├── C3  Import Queues
│   ├── C3.1  Queue ordering and selection
│   ├── C3.2  Import (deploy) selected entries or the whole queue
│   ├── C3.3  Automatic import (auto-import worker)
│   └── C3.4  Reset and repeat imports
├── C4  Audit & Monitoring
│   ├── C4.1  Audit trail of every operation (who, when, what, log)
│   ├── C4.2  Key figures (KPIs) per tenant
│   └── C4.3  Domain events (export, forward, import finished, reset)
└── C5  Cross-cutting
    ├── C5.1  Multi-tenancy (XSUAA zone / X-Tenant-Id)
    ├── C5.2  Role based access (Viewer / Operator / Admin)
    ├── C5.3  Configurable runtime (file, env, VCAP_SERVICES)
    └── C5.4  Health monitoring
```

### 2.2 C2 — Enterprise vision

| Aspect | Description |
|---|---|
| **Mission** | Move software deliverables reliably and traceably from development to production. |
| **Vision** | One governed transport pipeline per tenant, usable from Fiori, the command line, a desktop client and CI/CD. |
| **Scope** | Nodes, routes, transport requests, import queues, deployment, forwarding, audit trail, statistics. |
| **Out of scope** | Building the content (CI/CD), content repository storage, real runtime deployers (pluggable via `IDeploymentGateway`). |
| **Stakeholders** | Release managers, landscape administrators, DevOps engineers, auditors, CI/CD pipelines. |

### 2.3 C4 — Standard process: transport workflow

```text
 Register ──► Export ──► [Import queue of follow-on node] ──► Import (deploy)
                                     ▲                          │ success/warning
                                     └────── Forward ◄──────────┘ (node forwards)
 failed / finished ──► Reset ──► repeating ──► Import again
```

---

## 3. Service views

### 3.1 S1 — Service taxonomy

| Service ID | Service | Capability |
|---|---|---|
| SVC-TM-NODE | Transport node management | C1.1, C1.4 |
| SVC-TM-ROUTE | Transport route management | C1.2 |
| SVC-TM-LAND | Landscape read model | C1.3 |
| SVC-TM-REQ | Transport request management | C2.1, C2.4 |
| SVC-TM-OPS | Transport operations (export, import, forward, check) | C2.2, C2.3, C3.2 |
| SVC-TM-QUEUE | Import queue management | C3.1, C3.4 |
| SVC-TM-AUTO | Auto-import | C3.3 |
| SVC-TM-AUDIT | Audit trail | C4.1 |
| SVC-TM-STAT | Statistics | C4.2 |
| SVC-TM-HLTH | Health check | C5.4 |

### 3.2 S2 — Service interfaces

| Interface | Protocol / technology | Endpoint | Consumers |
|---|---|---|---|
| REST API | HTTP/JSON (vibe.d) | `/api/v1/transport/{nodes, routes, requests, queue-entries, actions, nodes-import, statistics, landscape}` | CI/CD, scripts, other services |
| OData v4 | OASIS OData 4.0, CSDL `$metadata` | `/odata/v4/transport/` (5 entity sets, `Statistics` singleton, 9 unbound actions) | SAP Fiori / UI5 app |
| Health | HTTP/JSON | `/api/v1/health` | CF / Kubernetes probes |
| CLI | Process, stdout text or `--json` | `uim-transport-cli <command>` | Administrators, scripts |
| Desktop GUI | GTK 3 (GtkD) | `uim-transport-gui` | Administrators |
| Fiori app | HTML5 / UI5 1.120, SAP Fiori 3 theme | approuter `/index.html` | Release managers, operators |
| Events | `ITransportEventPublisher` (log adapter; Event Mesh ready) | topics `transport/request/*`, `transport/import/finished`, `transport/queue/reset` | Monitoring, integrations |

### 3.3 S4 — Service functions

| Service | Driving port | Functions |
|---|---|---|
| SVC-TM-NODE | `IManageTransportNodesUseCase` | create, update, enable, disable, delete, get, find by name, list |
| SVC-TM-ROUTE | `IManageTransportRoutesUseCase` | create (unique, acyclic), update, enable, disable, delete, list |
| SVC-TM-REQ | `IManageTransportRequestsUseCase` | create, update, set status, delete (cascades queue entries), list |
| SVC-TM-QUEUE | `IManageImportQueueUseCase` | enqueue, select/deselect, set status, reset, delete, list by node/request |
| SVC-TM-OPS | `ITransportOperationsUseCase` | exportRequest, importNode, forwardRequest, checkConnection |
| SVC-TM-AUDIT | `IManageTransportActionsUseCase` | record, set status, list by node/request/status |
| SVC-TM-STAT / LAND | `ITransportStatisticsService`, `ITransportLandscapeService` | statistics, landscape |
| SVC-TM-AUTO | `AutoImportWorker` → `ITransportOperationsUseCase` | periodic importNode for auto-import nodes |

---

## 4. Logical views

### 4.1 L2 — Logical scenario

```text
┌──────────────┐  OData v4   ┌─────────────┐  HTTP + JWT  ┌──────────────────────────────┐
│ Fiori app    │────────────►│ Approuter   │─────────────►│ Transport service (backend)  │
│ (browser)    │◄────────────│ + XSUAA     │◄─────────────│  REST · OData · worker       │
└──────────────┘             └─────────────┘              │                              │
┌──────────────┐  REST/JSON                               │  ┌────────────────────────┐  │
│ CI/CD        │─────────────────────────────────────────►│  │ application core       │  │
└──────────────┘                                          │  └──────────┬─────────────┘  │
┌──────────────┐  process (same storage)                  │             │ IDeployment-   │
│ CLI / GtkD   │─────────────┐                            │             ▼ Gateway        │
└──────────────┘             ▼                            │      target runtimes        │
                      ┌─────────────┐◄────────────────────│  (CF / ABAP / Neo / Kyma)   │
                      │ data/*.json │   ISnapshotStorage  └──────────────────────────────┘
                      └─────────────┘
```

### 4.2 L4 — Logical activities per role

| Role (XSUAA) | Activities |
|---|---|
| TransportViewer | View nodes, routes, requests, queues, audit trail, KPIs, landscape |
| TransportOperator | + register and export requests, import queues, forward, reset queue entries |
| TransportAdmin | + create/update/delete nodes and routes, enable/disable, delete requests and entries |
| System (worker) | Auto-import of nodes with `autoImport = true` |

### 4.3 L6 — Logical sequence (export → import → forward)

1. Operator registers request *R* with source node *DEV* (`createRequest`).
2. `exportRequest(R)`: the landscape returns the enabled routes leaving *DEV*; *R* is
   enqueued at *QA*; action `export` recorded; request status `initial`.
3. `importNode(QA)`: each selected pending entry is set `running`, deployed through
   `IDeploymentGateway`, finished `success | warning | failed`; action `import`
   recorded with the deployment log.
4. If the import did not fail and *QA* forwards, *R* is enqueued at *PROD*
   (action `forward`); request status becomes `running` (in transit).
5. `importNode(PROD)` → all entries finished → request status `success`.
6. A failed entry can be reset (`repeating`) and imported again.

Detailed sequence diagrams: [UML.md §4–5](UML.md).

---

## 5. L7 — Logical data model

| Entity | Key attributes | Relationships |
|---|---|---|
| `TransportNode` | name (unique per tenant), nodeType, status, region, subaccount, space, isForwardEnabled, autoImport, connectionStatus | source/destination of routes; owns an import queue |
| `TransportRoute` | name (unique), sourceNodeId, destinationNodeId, status, sequence | 2 × → TransportNode; landscape is a DAG |
| `TransportRequest` | name, contentType, version, storageUrl, checksum, status (aggregated), queuedAt, importedAt | → source TransportNode; 0..* queue entries |
| `ImportQueueEntry` | nodeId, requestId, status, queuePosition, isSelected, importLog | → TransportNode, → TransportRequest; at most one pending entry per node/request |
| `TransportAction` | actionType, actionStatus, performedBy, performedAt, description, logDetails | → request, node, route (optional) |
| `TransportStatistics` (read model) | counts per entity and status | derived |

All entities carry `tenantId`, `id`, `createdBy/At`, `updatedBy/At` (`TenantEntity`).
Persistence: one JSON snapshot per collection (`transport_nodes`, `transport_routes`,
`transport_requests`, `import_queue_entries`, `transport_actions`) with
`schemaVersion` envelope; the node `serviceKey` is stored but never returned by
any interface.

---

## 6. Physical (resource) views

### 6.1 P1 — Resource types

| Resource | Type | Artefact |
|---|---|---|
| transport-srv | D executable (vibe.d 0.10.3) | `uim-transport-platform-service` |
| transport-cli | D executable | `uim-transport-cli` |
| transport-gui | D executable (GtkD 3.11, GTK 3.24) | `uim-transport-gui` |
| transport-ui | SAP Fiori 3 / UI5 1.120 app `uim.transport` | `frontend/` |
| transport-approuter | Node.js `@sap/approuter` | `approuter/` |
| transport-xsuaa | SAP BTP XSUAA (plan application) | `approuter/xs-security.json` |
| transport-config | user-provided service | `mta.yaml` |
| snapshot storage | JSON files | `data/*.json` |

### 6.2 P2 — Resource structure (hexagonal)

| Layer | Package | Content |
|---|---|---|
| Domain | `domain` | entities, IDs, enumerations, validator, landscape graph, status aggregation, exceptions |
| Ports | `ports` | driving use-case/service interfaces, `TransportPorts`; driven repository, storage, gateway, messaging ports |
| Application | `application` | DTOs, manage use cases, operations use case, statistics/landscape, action recorder |
| Persistence | `persistence` | repositories, snapshot stores, mappers, records |
| Infrastructure | `infrastructure` | configuration, XSUAA identity, logging/events, deployment gateway, auto-import worker, DI container |
| Presentation | `presentation` | REST, OData v4, CLI, GtkD GUI, static web delivery, tabular projections |

### 6.3 P3 — Resource connectivity

**SAP BTP Cloud Foundry (`mta.yaml`)**

```text
Space
├── transport-approuter (approuter.nodejs, 256M)  ──destination transport-srv──►
├── transport-srv (binary_buildpack, 256M, health /api/v1/health, TM_AUTO_IMPORT_INTERVAL=15)
├── transport-xsuaa (xsuaa/application)  bound to approuter + srv
└── transport-config (user-provided)     bound to srv → VCAP_SERVICES overrides
```

**Kubernetes (`k8s/`)**

```text
Namespace uim-platform
├── ConfigMap transport-config  (TM_HOST, TM_PORT=8117, TM_STORAGE=file, TM_DATA_DIR=/data, …)
├── Deployment transport        (image uim-platform/transport, :8117, probes /api/v1/health,
│                                volume /data — emptyDir, replace with a PVC)
└── Service transport           (ClusterIP :8117)
```

---

## 7. A2 — Architecture decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hexagonal / Clean Architecture with a `TransportPorts` bundle | One application core for REST, OData, CLI, GUI and the worker; adapters are replaceable and testable. |
| AD-2 | Node/route topology as an **acyclic** graph (`TransportLandscape`) | Mirrors CTM landscapes; cycles would forward requests forever. |
| AD-3 | One import queue per node, ordered by position, with selection | Explicit, auditable import ordering as in CTM. |
| AD-4 | Request status **derived** from queue entries | No contradictory states; one source of truth. |
| AD-5 | Automatic forwarding after successful import (per node switch) | Implements DEV → QA → PROD propagation without manual steps. |
| AD-6 | Deployment behind `IDeploymentGateway`; simulated adapter by default | Runtime specific deployers can be plugged in without touching use cases. |
| AD-7 | Every operation writes a `TransportAction` | Full audit trail for compliance. |
| AD-8 | JSON snapshot storage shared by all processes (revision check before each read) | Server, CLI and GUI work on the same data without a database; atomic rename prevents torn reads. |
| AD-9 | OData v4 served directly by the D backend, `$batch` not supported | Native Fiori integration (`$metadata`, annotations, actions); the UI uses `$direct`. |
| AD-10 | Configuration precedence defaults → file → env → `VCAP_SERVICES` | Same binary locally, in containers and on Cloud Foundry; legacy `TRANSPORT_HOST/PORT` kept. |
| AD-11 | Approuter + XSUAA as the single entry point | Authentication, CSRF and role checks outside the service. |
| AD-12 | Port 8117 | Consistent UIM platform port allocation. |

---

## 8. A3 — Standards

| Area | Standard |
|---|---|
| API | OData 4.0 (OASIS), CSDL XML, `Org.OData.Capabilities.V1`, `com.sap.vocabularies.Common.v1` |
| Data exchange | JSON (RFC 8259), ISO 8601 / `Edm.DateTimeOffset` |
| Security | OAuth 2.0 / JWT (XSUAA), CSRF tokens (approuter) |
| UI | SAP Fiori 3 design guidelines, UI5 1.120 |
| Deployment | MTA 3.3, Cloud Foundry, OCI images, Kubernetes |
| Language | D (dmd / ldc2), vibe.d 0.10.3, GtkD 3.11 |

---

## 9. Security view

| Concern | Measure |
|---|---|
| Authentication | XSUAA login at the approuter; JWT forwarded to the backend (`forwardAuthToken`). |
| Authorization | Role templates `TransportViewer`, `TransportOperator`, `TransportAdmin`; route scopes in `xs-app.json` (GET: viewer, POST: operator, other methods: admin). |
| Tenant isolation | Tenant taken from the token (`zid`), else `X-Tenant-Id`, else the default; all repository access is tenant scoped. |
| Token validation | The backend decodes claims but **does not verify JWT signatures**; it must only be reachable through the approuter (or signature verification must be added). |
| Secrets | Node `serviceKey` never serialized to clients; `approuter/default-env.json` is git-ignored. |
| Audit | Every export, import, forward, reset and delete is recorded with user and timestamp. |
| Container | Non-root user, read-only binaries, data volume `/data`, HTTP health check. |
