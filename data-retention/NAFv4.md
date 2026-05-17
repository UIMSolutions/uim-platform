# NAF v4 Architecture Description — Data Retention Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Data Retention Service — GDPR-aligned data lifecycle management with retention
> rules, legal grounds, business purposes, archiving jobs, and data subject roles.

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
Data Retention
├── C1.1  Retention Rule Management
│   ├── C1.1.1  Define retention durations by business purpose
│   └── C1.1.2  Legal-ground based rules
│
├── C1.2  Legal Ground Management
│   └── C1.2.1  GDPR / LGPD legal basis catalogue
│
├── C1.3  Business Purpose Management
│   └── C1.3.1  Purpose definitions linked to legal grounds
│
├── C1.4  Data Subject Management
│   ├── C1.4.1  Data subject registration
│   └── C1.4.2  Role assignments
│
├── C1.5  Archiving
│   └── C1.5.1  Triggered and scheduled archiving jobs
│
├── C1.6  Legal Entity
│   └── C1.6.1  Legal entity reference data
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide data retention management modelled on SAP Data Retention Manager for BTP. |
| **Vision** | Enable compliant data lifecycle management by enforcing retention periods, automating archiving, and managing data subject rights. |
| **Scope** | Retention rules, legal grounds, business purposes, data subjects, data subject roles, archiving jobs, and legal entities. |
| **Stakeholders** | Data Protection Officers, Compliance Teams, Application Developers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-RR-CRUD | Retention Rule | `/api/v1/retention-rules` | GET, POST, PUT, DELETE |
| SVC-LG-CRUD | Legal Ground | `/api/v1/legal-grounds` | GET, POST, DELETE |
| SVC-BP-CRUD | Business Purpose | `/api/v1/business-purposes` | GET, POST, DELETE |
| SVC-DS-CRUD | Data Subject | `/api/v1/data-subjects` | GET, POST, DELETE |
| SVC-DSR-CRUD | Data Subject Role | `/api/v1/data-subject-roles` | GET, POST, DELETE |
| SVC-AJ-CRUD | Archiving Job | `/api/v1/archiving-jobs` | GET, POST |
| SVC-LE-CRUD | Legal Entity | `/api/v1/legal-entities` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Compliance Team /  │ ─────────────────> │  Data Retention Service      │
│  DPO / Application  │                    │  port 8112                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `RetentionRule` | Duration rule linked to BusinessPurpose |
| `LegalGround` | GDPR/LGPD legal basis |
| `BusinessPurpose` | Processing purpose linked to LegalGround |
| `DataSubject` | Individual data subject |
| `DataSubjectRole` | Role of a data subject (employee, customer) |
| `ArchivingJob` | Batch deletion/anonymisation run |
| `LegalEntity` | Organisational legal entity |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: data-retention-config
│   DATA_RETENTION_HOST: "0.0.0.0"
│   DATA_RETENTION_PORT: "8112"
├── Deployment: data-retention  port: 8112
└── Service: data-retention (ClusterIP :8112)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Legal-ground-centric model | GDPR-compliant foundation |
| AD-2 | Business purpose separation | Enables purpose limitation principle |
| AD-3 | Archiving job execution | Automates compliant data disposal |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8112 | Consistent UIM platform port allocation |
