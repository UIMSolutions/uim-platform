# NAFv4 Architecture Description — UIM RFC Interface Service

## 1. Architecture Overview

This document describes the UIM RFC Interface Service in terms of the **NATO Architecture Framework version 4 (NAFv4)** viewpoints. The service acts as a platform-managed RFC gateway, exposing all SAP RFC variant protocols (sRFC, aRFC, tRFC, qRFC, bgRFC, LDQ) via a RESTful HTTP API and an interactive CLI.

---

## 2. NAFv4 Viewpoints

### 2.1 Concepts View (C1 — Capability Taxonomy)

| Capability | Description |
|------------|-------------|
| RFC Gateway | Ability to dispatch RFC calls to registered remote destinations |
| Destination Management | Register, update, and deactivate RFC destination profiles (SM59 equivalent) |
| Function Module Registry | Maintain metadata for RFC-enabled ABAP function modules |
| Synchronous RFC (sRFC) | Invoke and await a remote function module result |
| Asynchronous RFC (aRFC) | Dispatch a function module call without blocking |
| Transactional RFC (tRFC) | Exactly-once execution via Transaction ID (TID) |
| Queued RFC (qRFC) | Ordered LUW execution via named inbound/outbound queues |
| Background RFC (bgRFC) | Improved-performance successor to tRFC/qRFC |
| Local Data Queue (LDQ) | Pull-based data transfer stored locally until retrieved |
| TID Lifecycle Management | Create, track, commit, and roll back TIDs |
| Queue Processing | Sequential processing of qRFC/bgRFC queue entries |
| Health Monitoring | Kubernetes-compatible liveness and readiness probes |

---

### 2.2 Service View (S1 — Service Taxonomy)

```
UIM Platform
└── RFC Interface Service  (port 8092)
    ├── RFC Invocation Service
    │   ├── sRFC Invocation
    │   ├── aRFC Invocation
    │   ├── tRFC Invocation (with TID)
    │   ├── qRFC Invocation (with TID + Queue)
    │   ├── bgRFC Invocation
    │   └── LDQ Storage
    ├── Destination Management Service
    ├── Function Module Registry Service
    ├── Call History Service
    ├── Queue Management Service
    └── Health Service
```

---

### 2.3 Logical Architecture View (L1 — Logical Architecture)

The service follows a hexagonal (ports and adapters) architecture with four concentric layers:

```
┌──────────────────────────────────────────────────────────────┐
│  Presentation Layer                                           │
│  ┌──────────────────────────┐  ┌──────────────────────────┐  │
│  │  HTTP Controllers         │  │  CLI (RfcCliRunner)      │  │
│  │  - DestinationController  │  │  - call <dest> <fm>      │  │
│  │  - FunctionModuleCtrl     │  │  - destinations          │  │
│  │  - CallController         │  │  - functions             │  │
│  │  - QueueController        │  │  - status <id>           │  │
│  │  - HealthController       │  │  - add-destination       │  │
│  └──────────────────────────┘  └──────────────────────────┘  │
├──────────────────────────────────────────────────────────────┤
│  Application Layer                                            │
│  - InvokeRfcUseCase           (all RFC type dispatch)         │
│  - ManageDestinationsUseCase  (SM59 lifecycle)                │
│  - ManageFunctionModulesUseCase (SE37 metadata)               │
│  - ManageCallsUseCase         (call history)                  │
│  - ManageQueuesUseCase        (qRFC queue orchestration)      │
├──────────────────────────────────────────────────────────────┤
│  Domain Layer                                                 │
│  Entities: Destination, FunctionModule, RfcCall, Tid,         │
│            RfcQueueEntry, RfcParameter, ParameterValue        │
│  Services: RfcExecutor, TidManager, QueueProcessor            │
│  Ports:    DestinationRepository, FunctionModuleRepository,   │
│            RfcCallRepository, TidRepository,                  │
│            RfcQueueRepository                                 │
├──────────────────────────────────────────────────────────────┤
│  Infrastructure Layer                                         │
│  - MemoryDestinationRepository                                │
│  - MemoryFunctionModuleRepository                             │
│  - MemoryRfcCallRepository                                    │
│  - MemoryTidRepository                                        │
│  - MemoryRfcQueueRepository                                   │
│  - SrvConfig (RFC_HOST / RFC_PORT env vars)                   │
│  - Container (DI composition root)                            │
└──────────────────────────────────────────────────────────────┘
```

---

### 2.4 Physical Architecture View (P1 — Resource Structure)

```
Kubernetes Cluster
└── Namespace: uim-platform
    ├── Deployment: uim-rfc
    │   └── Pod: uim-rfc-xxxxxxxx
    │       └── Container: uim-rfc-platform-service
    │           Image:  uim-rfc-platform-service:latest
    │           Port:   8092/TCP
    │           Memory: 64Mi request / 256Mi limit
    │           CPU:    50m request / 500m limit
    │           User:   appuser (non-root, UID system)
    ├── Service: uim-rfc  (ClusterIP: port 8092)
    └── ConfigMap: rfc-config
            RFC_HOST = 0.0.0.0
            RFC_PORT = 8092
```

**Container image stages (multi-stage build):**

| Stage | Base Image | Purpose |
|-------|-----------|---------|
| builder | `dlang2/ldc-ubuntu:1.40.1` | Compile D source to native binary |
| runtime | `ubuntu:24.04` | Minimal runtime with curl for health checks |

---

### 2.5 Operational View (O1 — Operational Activity)

#### RFC Call Flow (sRFC)

```
1. Client sends POST /api/v1/rfc/calls  {rfcType:"sRFC", destinationId:"S4H", ...}
2. CallController validates request and calls InvokeRfcUseCase
3. Use case fetches Destination + FunctionModule from repositories
4. Creates RfcCall record (status=executing) and persists it
5. RfcExecutor dispatches synchronous call, waits for result
6. RfcCall updated: status=succeeded, exportParams filled
7. Response returned to client with result parameters
```

#### tRFC Call Flow

```
1. Client sends POST /api/v1/rfc/calls  {rfcType:"tRFC", destinationId:"S4H", ...}
2. TidManager creates and persists new TID (status=open)
3. RfcCall created with TID assigned (status=executing)
4. RfcExecutor executes transactionally; verifies TID uniqueness
5. On success: TidManager.commit → TID status=committed
6. On failure: TidManager.rollback → TID status=rolledBack
7. Client receives callId + TID for tracking
```

#### qRFC Enqueue Flow

```
1. Client sends POST /api/v1/rfc/calls  {rfcType:"qRFC", queueName:"ZQUEUE01", ...}
2. TID allocated; RfcQueueEntry created (sequenceNr=N, status=queued)
3. Client immediately receives {status:"queued", tid:..., callId:...}
4. Later: POST /api/v1/rfc/queues/ZQUEUE01/process
5. QueueProcessor loads pending entries sorted by sequenceNr
6. Entries processed in order; queue stops on first failure (ordering guarantee)
```

---

### 2.6 Technology View

| Component | Technology |
|-----------|-----------|
| Runtime Language | D (LDC 1.40.1) |
| HTTP Framework | vibe.d 0.10.x / vibe-http 1.4.0 |
| JSON Serialisation | vibe-data (vibe.data.json) |
| Dependency Management | DUB (dub.sdl format) |
| Container Build | Docker / Podman (multi-stage) |
| Container Runtime | Docker Engine / Podman |
| Orchestration | Kubernetes (deployment + service + configmap) |
| Architecture Style | Hexagonal (Ports & Adapters) + Clean Architecture |
| Persistence (default) | In-memory (production: swap adapter for PostgreSQL/Redis) |
| Security | Non-root container user; ReadOnlyRootFilesystem |
| Health Probes | HTTP liveness + readiness on `/api/v1/health` |

---

### 2.7 Security Considerations

- Service runs as a **non-root system user** (`appuser`) inside the container.
- `ReadOnlyRootFilesystem: true` prevents runtime filesystem modifications.
- `AllowPrivilegeEscalation: false` in the Kubernetes security context.
- No credentials (passwords, certificates) are stored in the service — RFC `logonUser` is stored as a reference only; password management is delegated to SAP Credential Store or Kubernetes Secrets.
- All input validated at the HTTP boundary (presentation layer); domain layer receives clean DTOs.
- TID-based exactly-once guarantee prevents replay attacks on tRFC/qRFC calls.

---

### 2.8 Standards and Compliance

| Standard | Reference |
|----------|-----------|
| SAP RFC Programming Guide | SAP Note 2018682 |
| SAP tRFC / qRFC / bgRFC | SAP S/4HANA connectivity documentation |
| NATO Architecture Framework v4 | NATO STANAG 5524 Ed. A |
| Container best practices | OCI Image Specification |
| API design | REST / JSON:API |
| D Language | ISO/IEC JTC 1/SC 22 (D specification) |
