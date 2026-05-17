# NAF v4 Architecture Description — Content Agent Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Content Agent Service — content export/import, transport request management,
> transport queue orchestration, and content provider integration.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Content Agent
├── C1.1  Content Provider Management
│   ├── C1.1.1  Register content providers (BTP, S/4HANA, etc.)
│   ├── C1.1.2  Endpoint and authentication configuration
│   └── C1.1.3  Provider status lifecycle
│
├── C1.2  Content Export
│   ├── C1.2.1  Trigger content package export
│   ├── C1.2.2  Export status tracking
│   └── C1.2.3  Download URL generation
│
├── C1.3  Content Import
│   ├── C1.3.1  Import package into target system
│   ├── C1.3.2  Import mode selection (create / update / replace)
│   └── C1.3.3  Import job status tracking
│
├── C1.4  Transport Management
│   ├── C1.4.1  Transport request creation and lifecycle
│   ├── C1.4.2  Transport queue management
│   └── C1.4.3  Queue-to-request assignment
│
├── C1.5  Activity Audit
│   └── C1.5.1  Content activity logging
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a content lifecycle management API modelled on SAP Content Agent Service. |
| **Vision** | Enable platform operators to export integration content from source systems, manage transport queues, and import content into target landscapes with full audit trail. |
| **Scope** | Content export/import lifecycle, transport orchestration, and provider integration. |
| **Stakeholders** | Integration Consultants, Platform Operators, DevOps Engineers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-CP-CRUD | Content Provider | `/api/v1/content-providers` | GET, POST, PUT, DELETE |
| SVC-EJ-CRUD | Export Job | `/api/v1/export-jobs` | GET, POST, DELETE |
| SVC-IJ-CRUD | Import Job | `/api/v1/import-jobs` | GET, POST, DELETE |
| SVC-TR-CRUD | Transport Request | `/api/v1/transport-requests` | GET, POST, DELETE |
| SVC-TQ-CRUD | Transport Queue | `/api/v1/transport-queues` | GET, POST, DELETE |
| SVC-CA-CRUD | Content Activity | `/api/v1/activities` | GET, POST |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Integration        │ ─────────────────> │  Content Agent Service       │
│  Consultant / Ops   │                    │  port 8092                    │
└────────────────────┘                    └──────────────┬───────────────┘
                                                          │
                              ┌───────────────────────────▼──────────────────┐
                              │         UIM Platform (In-Memory Store)       │
                              └──────────────────────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `ContentProvider` | Root; triggers ContentExportJobs |
| `ContentExportJob` | Belongs to ContentProvider; produces downloadable packages |
| `ImportJob` | Consumes export packages; targets a system; produces ContentActivities |
| `TransportRequest` | Groups content IDs; assigned to TransportQueues |
| `TransportQueue` | Named queue pointing to a target system |
| `ContentActivity` | Append-only audit record of content operations |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: content-agent-config
│   CONTENT_AGENT_HOST: "0.0.0.0"
│   CONTENT_AGENT_PORT: "8092"
├── Deployment: content-agent  port: 8092
└── Service: content-agent (ClusterIP :8092)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | SAP Content Agent API alignment | Mirrors SAP BTP Content Agent patterns |
| AD-2 | In-memory repositories | Fast testing and portability |
| AD-3 | Port 8092 | Consistent UIM platform port allocation |
| AD-4 | Immutable ContentActivity | Audit trail integrity |
