# NAF v4 Architecture Description — Transport Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Transport Service — transport request lifecycle management, import queues,
> transport routes, transport nodes, and transport actions modelled on SAP
> Transport Management Service.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** | NSOV-2 Service Definitions | §3 |
| **NOV** | NOV-2 Operational Node Connectivity | §4 |
| **NLV** | NLV-1 Logical Data Model | §5 |
| **NPV** | NPV-1 Physical Deployment | §6 |
| **NIV** | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Transport
├── C1.1  Transport Topology
│   ├── C1.1.1  Define transport nodes
│   └── C1.1.2  Define routes between nodes
│
├── C1.2  Transport Requests
│   ├── C1.2.1  Create and manage transport requests
│   └── C1.2.2  Track request status
│
├── C1.3  Import Queue
│   ├── C1.3.1  Queue entries for node import
│   └── C1.3.2  Trigger and schedule imports
│
├── C1.4  Transport Actions
│   └── C1.4.1  Record forward/backward/reset actions
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Tenant isolation
    └── C1.5.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide transport management modelled on SAP Transport Management Service. |
| **Vision** | Give development teams a governed pipeline for promoting content through landscape nodes from DEV to PROD. |
| **Scope** | Transport nodes, routes, requests, import queue entries, and transport actions. |
| **Stakeholders** | Release Managers, Basis Administrators, DevOps Engineers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-TN-CRUD | Transport Node | `/api/v1/transport-nodes` | GET, POST, PUT, DELETE |
| SVC-TR-CRUD | Transport Route | `/api/v1/transport-routes` | GET, POST, DELETE |
| SVC-TREQ-CRUD | Transport Request | `/api/v1/transport-requests` | GET, POST, PUT, DELETE |
| SVC-IQ-CRUD | Import Queue Entry | `/api/v1/import-queue-entries` | GET, POST, DELETE |
| SVC-TA-CRUD | Transport Action | `/api/v1/transport-actions` | GET, POST |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Release Manager /  │ ─────────────────> │  Transport Service           │
│  CI/CD Pipeline     │                    │  port 8117                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `TransportNode` | Landscape node (DEV/QA/PROD) |
| `TransportRoute` | Directed path between two TransportNodes |
| `TransportRequest` | Deployable changeset |
| `ImportQueueEntry` | TransportRequest queued at a node |
| `TransportAction` | Forward/backward/reset action on a request |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: transport-config
│   TRANSPORT_HOST: "0.0.0.0"
│   TRANSPORT_PORT: "8117"
├── Deployment: transport  port: 8117
└── Service: transport (ClusterIP :8117)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Node-route topology | Mirrors CTS+ landscape modelling |
| AD-2 | Import queue per node | Explicit import ordering |
| AD-3 | Transport action log | Full audit trail of promotions |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8117 | Consistent UIM platform port allocation |
