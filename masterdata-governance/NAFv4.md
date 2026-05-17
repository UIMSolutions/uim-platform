# NAF v4 Architecture Description — Master Data Governance Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Master Data Governance Service — business partner governance, change request
> workflows, data quality rules, replication management, and quality scoring
> modelled on SAP Master Data Governance on Cloud.

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
Master Data Governance
├── C1.1  Business Partner Management
│   └── C1.1.1  Create and govern business partner records
│
├── C1.2  Change Request Workflow
│   ├── C1.2.1  Submit and approve data change requests
│   └── C1.2.2  Workflow routing and approval
│
├── C1.3  Data Quality Rules
│   └── C1.3.1  Define validation rules for master data
│
├── C1.4  Data Quality Scoring
│   └── C1.4.1  Score master data records against rules
│
├── C1.5  Replication
│   └── C1.5.1  Distribute approved master data to target systems
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide master data governance modelled on SAP Master Data Governance on Cloud. |
| **Vision** | Establish a single source of truth for business partner master data with governed change workflows and quality-scored records. |
| **Scope** | Business partners, change requests, data quality rules, quality scores, and replication. |
| **Stakeholders** | Data Stewards, MDG Administrators, Business Process Owners. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-BP-CRUD | Business Partner | `/api/v1/business-partners` | GET, POST, PUT, DELETE |
| SVC-CR-CRUD | Change Request | `/api/v1/change-requests` | GET, POST, PUT, DELETE |
| SVC-DQR-CRUD | Data Quality Rule | `/api/v1/data-quality-rules` | GET, POST, DELETE |
| SVC-DQS-LIST | Data Quality Score | `/api/v1/data-quality-scores` | GET |
| SVC-REP-CRUD | Replication | `/api/v1/replications` | GET, POST |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Data Steward /     │ ─────────────────> │  Master Data Governance      │
│  MDG Admin          │                    │  port 8108                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `BusinessPartner` | Core master data entity |
| `ChangeRequest` | Governed change submission for BusinessPartner |
| `DataQualityRule` | Validation rule applied to BusinessPartner |
| `DataQualityScore` | Rule evaluation score per BusinessPartner |
| `Replication` | Distribution of approved data to targets |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: masterdata-governance-config
│   MASTERDATA_GOVERNANCE_HOST: "0.0.0.0"
│   MASTERDATA_GOVERNANCE_PORT: "8108"
├── Deployment: masterdata-governance  port: 8108
└── Service: masterdata-governance (ClusterIP :8108)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Change request workflow | Enforces governed data change |
| AD-2 | Quality rule scoring | Quantifies data quality per record |
| AD-3 | Replication model | Distributes golden record downstream |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8108 | Consistent UIM platform port allocation |
