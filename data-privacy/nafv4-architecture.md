# NAF v4 Architecture Description — Data Privacy Integration Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Data Privacy Integration Service — GDPR/data privacy management, data subject
> rights handling, consent management, and personal data inventory.

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
Data Privacy Integration
├── C1.1  Data Subject Management
│   ├── C1.1.1  Register data subjects
│   └── C1.1.2  Data subject lifecycle (active / deleted)
│
├── C1.2  Personal Data Inventory
│   ├── C1.2.1  Register personal data records per data subject
│   └── C1.2.2  Data category and storage location tracking
│
├── C1.3  Consent Management
│   ├── C1.3.1  Record and withdraw consent
│   ├── C1.3.2  Consent validity periods
│   └── C1.3.3  Legal ground linking
│
├── C1.4  Legal Ground Management
│   ├── C1.4.1  Define legal grounds (consent, contract, legitimate interest)
│   └── C1.4.2  Link purposes to legal grounds
│
├── C1.5  Business Context
│   └── C1.5.1  Application-level data category registration
│
├── C1.6  Data Subject Rights
│   ├── C1.6.1  Information report generation (right of access)
│   └── C1.6.2  Erasure and portability support
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide GDPR data privacy management modelled on SAP Data Privacy Integration for BTP. |
| **Vision** | Enable compliance officers to maintain a personal data inventory, manage consent records, and respond to data subject rights requests across all connected applications. |
| **Scope** | Data subject registration, personal data inventory, consent and purpose management, information reports. |
| **Stakeholders** | Data Protection Officers, Compliance Officers, Application Owners. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-DS-CRUD | Data Subject | `/api/v1/data-subjects` | GET, POST, PUT, DELETE |
| SVC-PDR-CRUD | Personal Data Record | `/api/v1/personal-data-records` | GET, POST, DELETE |
| SVC-CON-CRUD | Consent Record | `/api/v1/consent-records` | GET, POST, PUT, DELETE |
| SVC-LG-CRUD | Legal Ground | `/api/v1/legal-grounds` | GET, POST, DELETE |
| SVC-BC-CRUD | Business Context | `/api/v1/business-contexts` | GET, POST, DELETE |
| SVC-PR-CRUD | Purpose Record | `/api/v1/purpose-records` | GET, POST, DELETE |
| SVC-IR-CRUD | Information Report | `/api/v1/information-reports` | GET, POST |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Compliance Officer │ ─────────────────> │  Data Privacy Integration    │
│  / Application      │                    │  Service — port 8089          │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `DataSubject` | Root; parent of PersonalDataRecords, ConsentRecords, InformationReports |
| `PersonalDataRecord` | Linked to DataSubject and a source application |
| `ConsentRecord` | Linked to DataSubject and LegalGround; time-bounded |
| `LegalGround` | Referenced by ConsentRecords and PurposeRecords |
| `BusinessContext` | Application-level container of PurposeRecords |
| `PurposeRecord` | Linked to BusinessContext and LegalGround |
| `InformationReport` | Generated on demand per DataSubject; downloadable |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: data-privacy-config
│   DATA_PRIVACY_HOST: "0.0.0.0"
│   DATA_PRIVACY_PORT: "8089"
├── Deployment: data-privacy  port: 8089
└── Service: data-privacy (ClusterIP :8089)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | GDPR data model | Mirrors SAP Data Privacy Integration entity model |
| AD-2 | Consent validity periods | Supports time-bounded consent as required by GDPR |
| AD-3 | InformationReport as on-demand artifact | Enables right-of-access fulfillment |
| AD-4 | In-memory repositories | Fast testing; swap for RDBMS in production |
| AD-5 | Port 8089 | Consistent UIM platform port allocation |
