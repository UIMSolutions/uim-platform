# NAF v4 Architecture Description — Master Data Integration Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Master Data Integration Service — master data object distribution, data model
> governance, replication jobs, filter rules, key mapping, and change audit.

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
Master Data Integration
├── C1.1  Data Model Management
│   ├── C1.1.1  Define and version master data models
│   └── C1.1.2  JSON schema governance
│
├── C1.2  Client Registry
│   ├── C1.2.1  Register source and target clients
│   └── C1.2.2  Client endpoint configuration
│
├── C1.3  Master Data Objects
│   ├── C1.3.1  CRUD for master data records
│   └── C1.3.2  External ID management
│
├── C1.4  Distribution Models
│   ├── C1.4.1  Define distribution targets and modes
│   └── C1.4.2  Filter rule configuration
│
├── C1.5  Replication Jobs
│   ├── C1.5.1  Full and delta replication
│   └── C1.5.2  Job lifecycle management
│
├── C1.6  Key Mapping
│   └── C1.6.1  Cross-system ID mapping per client
│
├── C1.7  Change Log
│   └── C1.7.1  Object-level change audit trail
│
└── C1.8  Cross-Cutting
    ├── C1.8.1  Tenant isolation
    └── C1.8.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide master data integration modelled on SAP Master Data Integration (MDI) for BTP. |
| **Vision** | Enable enterprises to maintain a single source of truth for master data and replicate consistent records to all connected target systems with full change history. |
| **Scope** | Data model management, client registry, MDO CRUD, distribution, replication, key mapping, and change log. |
| **Stakeholders** | Master Data Stewards, Integration Architects, IT Operations. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-DM-CRUD | Data Model | `/api/v1/data-models` | GET, POST, PUT, DELETE |
| SVC-CLI-CRUD | Client | `/api/v1/clients` | GET, POST, DELETE |
| SVC-MDO-CRUD | Master Data Object | `/api/v1/master-data-objects` | GET, POST, PUT, DELETE |
| SVC-DIST-CRUD | Distribution Model | `/api/v1/distribution-models` | GET, POST, DELETE |
| SVC-RJ-CRUD | Replication Job | `/api/v1/replication-jobs` | GET, POST, DELETE |
| SVC-RJ-START | Start Replication | `/api/v1/replication-jobs/{id}/start` | POST |
| SVC-FR-CRUD | Filter Rule | `/api/v1/filter-rules` | GET, POST, DELETE |
| SVC-KM-CRUD | Key Mapping | `/api/v1/key-mappings` | GET, POST, DELETE |
| SVC-CL-LIST | Change Log | `/api/v1/change-log` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Master Data        │ ─────────────────> │  Master Data Integration     │
│  Steward / Ops      │                    │  Service — port 8096          │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `DataModel` | Schema definition; parent of MasterDataObjects and DistributionModels |
| `Client` | Source or target system; referenced by DistributionModels and KeyMappings |
| `MasterDataObject` | Individual master data record; audited by ChangeLogEntries |
| `DistributionModel` | Replication target set; parent of ReplicationJobs and FilterRules |
| `ReplicationJob` | Execution of a distribution; full or delta |
| `FilterRule` | Condition limiting which objects are replicated |
| `KeyMapping` | Cross-system external ID registry per client |
| `ChangeLogEntry` | Immutable diff record per MDO operation |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: masterdata-integration-config
│   MASTERDATA_INTEGRATION_HOST: "0.0.0.0"
│   MASTERDATA_INTEGRATION_PORT: "8096"
├── Deployment: masterdata-integration  port: 8096
└── Service: masterdata-integration (ClusterIP :8096)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Distribution model abstraction | Mirrors SAP MDI's replication topology concept |
| AD-2 | Key mapping registry | Supports cross-system ID harmonisation |
| AD-3 | Immutable change log | Full audit trail for master data governance |
| AD-4 | In-memory repositories | Fast testing; swap for persistent store in production |
| AD-5 | Port 8096 | Consistent UIM platform port allocation |
