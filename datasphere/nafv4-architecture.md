# NAF v4 Architecture Description — Datasphere Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Datasphere Service — data warehouse, integration space management, analytical
> views, remote table replication, data flows, and task orchestration.

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
Datasphere
├── C1.1  Space Management
│   ├── C1.1.1  Create / update / delete spaces
│   └── C1.1.2  Resource quota management
│
├── C1.2  Connectivity
│   ├── C1.2.1  Create external system connections (HANA, S/4HANA, etc.)
│   └── C1.2.2  Connection lifecycle
│
├── C1.3  Data Virtualisation
│   ├── C1.3.1  Remote table replication
│   └── C1.3.2  View definition and SQL management
│
├── C1.4  Data Integration
│   ├── C1.4.1  Data flow design and execution
│   ├── C1.4.2  Task scheduling
│   └── C1.4.3  Task chain orchestration
│
├── C1.5  Access Control
│   └── C1.5.1  Data access control for spaces
│
├── C1.6  Catalog
│   └── C1.6.1  Asset tagging and discovery
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a data warehouse and integration platform modelled on SAP Datasphere. |
| **Vision** | Enable data engineers to model, virtualise, integrate, and orchestrate data across enterprise landscapes within governed spaces. |
| **Scope** | Space lifecycle, connectivity, remote tables, views, data flows, tasks, task chains, access controls, and catalog assets. |
| **Stakeholders** | Data Engineers, Business Analysts, Data Architects. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-SP-CRUD | Space | `/api/v1/spaces` | GET, POST, PUT, DELETE |
| SVC-CN-CRUD | Connection | `/api/v1/connections` | GET, POST, DELETE |
| SVC-RT-CRUD | Remote Table | `/api/v1/remote-tables` | GET, POST, DELETE |
| SVC-VW-CRUD | View | `/api/v1/views` | GET, POST, DELETE |
| SVC-DF-CRUD | Data Flow | `/api/v1/data-flows` | GET, POST, DELETE |
| SVC-TK-CRUD | Task | `/api/v1/tasks` | GET, POST, DELETE |
| SVC-TC-CRUD | Task Chain | `/api/v1/task-chains` | GET, POST, DELETE |
| SVC-AC-CRUD | Data Access Control | `/api/v1/data-access-controls` | GET, POST, DELETE |
| SVC-CA-CRUD | Catalog Asset | `/api/v1/catalog-assets` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Data Engineer /    │ ─────────────────> │  Datasphere Service          │
│  Business Analyst   │                    │  port 8095                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Space` | Root aggregate; scopes all data resources |
| `Connection` | Belongs to Space; parent of RemoteTables |
| `RemoteTable` | Belongs to Space and Connection; replicates external tables |
| `View_` | Belongs to Space; SQL-defined analytical view |
| `DataFlow` | Belongs to Space; source-to-target data movement pipeline |
| `Task` | Belongs to Space; schedulable unit of work |
| `TaskChain` | Belongs to Space; ordered sequence of Tasks |
| `DataAccessControl` | Belongs to Space; row-level access restriction |
| `CatalogAsset` | Cross-space discoverable data asset |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: datasphere-config
│   DATASPHERE_HOST: "0.0.0.0"
│   DATASPHERE_PORT: "8095"
├── Deployment: datasphere  port: 8095
└── Service: datasphere (ClusterIP :8095)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Space-centric model | Mirrors SAP Datasphere's space isolation paradigm |
| AD-2 | Remote table replication | Aligns with SAP Datasphere's data virtualisation approach |
| AD-3 | Task chain orchestration | Reflects SAP Datasphere's scheduling capabilities |
| AD-4 | In-memory repositories | Fast testing; swap for real DW engine in production |
| AD-5 | Port 8095 | Consistent UIM platform port allocation |
