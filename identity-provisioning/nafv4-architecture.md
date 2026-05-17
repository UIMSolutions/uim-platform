# NAF v4 Architecture Description — Identity Provisioning Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Identity Provisioning Service — identity synchronisation, source/target system
> configuration, transformation scripting, and provisioning job management.

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
Identity Provisioning
├── C1.1  System Configuration
│   ├── C1.1.1  Source system registration (LDAP, AAD, IAS, HR systems)
│   ├── C1.1.2  Target system registration (IAS, XSUAA, AS ABAP, etc.)
│   └── C1.1.3  Proxy system (read/write bridge)
│
├── C1.2  Transformation
│   ├── C1.2.1  Read and write transformation scripts
│   └── C1.2.2  Attribute mapping and filtering
│
├── C1.3  Provisioning Jobs
│   ├── C1.3.1  Full and delta provisioning jobs
│   ├── C1.3.2  Job lifecycle (created → running → completed)
│   └── C1.3.3  Simulate and validate job runs
│
├── C1.4  Provisioning Logs
│   └── C1.4.1  Detailed entity-level provisioning logs
│
├── C1.5  Provisioned Entities
│   └── C1.5.1  Track individual user/group sync results
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide identity provisioning modelled on SAP Identity Provisioning Service (IPS) for BTP. |
| **Vision** | Enable IT administrators to synchronise users and groups from HR and directory systems to all BTP and on-premise target systems with configurable transformations. |
| **Scope** | Source/target system lifecycle, transformation management, provisioning job execution, and logging. |
| **Stakeholders** | Identity Administrators, IT Operations, Security Officers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-SS-CRUD | Source System | `/api/v1/source-systems` | GET, POST, PUT, DELETE |
| SVC-TS-CRUD | Target System | `/api/v1/target-systems` | GET, POST, PUT, DELETE |
| SVC-PS-CRUD | Proxy System | `/api/v1/proxy-systems` | GET, POST, DELETE |
| SVC-TR-CRUD | Transformation | `/api/v1/transformations` | GET, POST, PUT, DELETE |
| SVC-JOB-CRUD | Provisioning Job | `/api/v1/provisioning-jobs` | GET, POST, DELETE |
| SVC-JOB-START | Start Job | `/api/v1/provisioning-jobs/{id}/start` | POST |
| SVC-LOG-LIST | Provisioning Log | `/api/v1/provisioning-logs` | GET |
| SVC-ENT-LIST | Provisioned Entity | `/api/v1/provisioned-entities` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Identity Admin /   │ ─────────────────> │  Identity Provisioning       │
│  Scheduler          │                    │  Service — port 8093          │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `SourceSystem` | Identity source; triggers ProvisioningJobs |
| `TargetSystem` | Identity target; receives ProvisioningJobs |
| `ProxySystem` | Bridge; wraps both SourceSystem and TargetSystem |
| `Transformation` | Script linked to a system's read or write role |
| `ProvisioningJob` | Connects SourceSystem to TargetSystem; produces logs and entities |
| `ProvisioningLog` | Timestamped log entry per job |
| `ProvisionedEntity` | Individual user/group sync result |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: identity-provisioning-config
│   IDENTITY_PROVISIONING_HOST: "0.0.0.0"
│   IDENTITY_PROVISIONING_PORT: "8093"
├── Deployment: identity-provisioning  port: 8093
└── Service: identity-provisioning (ClusterIP :8093)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Source/target abstraction | Mirrors SAP IPS connector model |
| AD-2 | Scriptable transformations | Reflects SAP IPS JSONATA/Groovy transformation approach |
| AD-3 | Immutable provisioning logs | Audit trail for identity synchronisation compliance |
| AD-4 | In-memory repositories | Fast testing; swap for persistent store in production |
| AD-5 | Port 8093 | Consistent UIM platform port allocation |
