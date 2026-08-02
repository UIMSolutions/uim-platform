# NAF v4 Architecture Description — Personal Data Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Personal Data Service — data subject registry, consent management, processing
> purpose catalogue, personal data records, retention rules, and data processing
> logs modelled on SAP Data Privacy Integration.

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
Personal Data
├── C1.1  Data Subject Management
│   ├── C1.1.1  Register data subjects
│   └── C1.1.2  Data subject access requests
│
├── C1.2  Consent Management
│   ├── C1.2.1  Record and revoke consents
│   └── C1.2.2  Consent audit trail
│
├── C1.3  Processing Purpose Catalogue
│   └── C1.3.1  Define purposes with legal grounds
│
├── C1.4  Personal Data Records
│   └── C1.4.1  Register personal data attributes
│
├── C1.5  Retention Rules
│   └── C1.5.1  Retention periods per purpose
│
├── C1.6  Data Processing Logs
│   └── C1.6.1  Audit log of personal data access
│
├── C1.7  Application Registration
│   └── C1.7.1  Register data-processing applications
│
└── C1.8  Cross-Cutting
    ├── C1.8.1  Tenant isolation
    └── C1.8.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide personal data management modelled on SAP Data Privacy Integration. |
| **Vision** | Enable BTP applications to comply with GDPR and equivalent regulations through a centralised personal data registry with consent and processing logs. |
| **Scope** | Data subjects, consent records, processing purposes, personal data records, retention rules, processing logs, and application registrations. |
| **Stakeholders** | Data Protection Officers, Compliance Teams, Application Developers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-DS-CRUD | Data Subject | `/api/v1/data-subjects` | GET, POST, DELETE |
| SVC-CR-CRUD | Consent Record | `/api/v1/consent-records` | GET, POST, DELETE |
| SVC-PP-CRUD | Processing Purpose | `/api/v1/processing-purposes` | GET, POST, DELETE |
| SVC-PDR-CRUD | Personal Data Record | `/api/v1/personal-data-records` | GET, POST, DELETE |
| SVC-RR-CRUD | Retention Rule | `/api/v1/retention-rules` | GET, POST, DELETE |
| SVC-DPL-LIST | Data Processing Log | `/api/v1/data-processing-logs` | GET, POST |
| SVC-RA-CRUD | Registered Application | `/api/v1/registered-applications` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  DPO / Application /│ ─────────────────> │  Personal Data Service       │
│  Data Subject       │                    │  port 8102                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `DataSubject` | Individual whose data is processed |
| `ConsentRecord` | Consent given/revoked for a ProcessingPurpose |
| `ProcessingPurpose` | Defined purpose with legal ground |
| `PersonalDataRecord` | Registered personal data attribute |
| `RetentionRule` | Retention period per ProcessingPurpose |
| `DataProcessingLog` | Audit log entry |
| `RegisteredApplication` | Data-processing BTP application |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: personal-data-config
│   PERSONAL_DATA_HOST: "0.0.0.0"
│   PERSONAL_DATA_PORT: "8102"
├── Deployment: personal-data  port: 8102
└── Service: personal-data (ClusterIP :8102)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Consent-first model | GDPR Article 7 compliant |
| AD-2 | Processing purpose catalogue | Supports purpose limitation |
| AD-3 | Data processing audit log | Evidence for supervisory authority |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8102 | Consistent UIM platform port allocation |
