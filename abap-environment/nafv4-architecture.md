# NAF v4 Architecture Description — ABAP Environment Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> ABAP Environment Service — ABAP system lifecycle, software component versioning,
> communication arrangements, and business user/role administration.

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
ABAP Environment
├── C1.1  System Instance Management
│   ├── C1.1.1  Provision ABAP system instances
│   ├── C1.1.2  Lifecycle operations (start / stop / upgrade)
│   └── C1.1.3  Region and service URL tracking
│
├── C1.2  Software Component Lifecycle
│   ├── C1.2.1  Register and version software components
│   ├── C1.2.2  Pull / checkout operations
│   └── C1.2.3  Package management per system instance
│
├── C1.3  Communication Arrangement
│   ├── C1.3.1  Inbound scenario configuration
│   ├── C1.3.2  Outbound scenario configuration
│   └── C1.3.3  Authentication type management (OAuth2, BasicAuth, X.509)
│
├── C1.4  Service Binding
│   ├── C1.4.1  Binding credential issuance
│   └── C1.4.2  Binding lifecycle (create / delete)
│
├── C1.5  Business User Administration
│   ├── C1.5.1  User creation and profile management
│   ├── C1.5.2  Lock / unlock / password reset
│   └── C1.5.3  Role assignment
│
├── C1.6  Business Role Management
│   ├── C1.6.1  Role creation from templates
│   ├── C1.6.2  Catalog assignment to roles
│   └── C1.6.3  Authorization object assignment
│
├── C1.7  Transport Request Workflow
│   ├── C1.7.1  Create transport requests (Workbench / Customizing)
│   ├── C1.7.2  Release workflow
│   └── C1.7.3  Import into target system
│
├── C1.8  Application Job Scheduling
│   ├── C1.8.1  Job template instantiation
│   ├── C1.8.2  Cron / one-time scheduling
│   └── C1.8.3  Execution log retrieval
│
└── C1.9  Cross-Cutting
    ├── C1.9.1  Tenant isolation
    └── C1.9.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide an ABAP Environment lifecycle management API modelled on SAP BTP ABAP Environment. |
| **Vision** | Enable platform operators and development teams to provision ABAP instances, manage transport chains, and administer users/roles without direct ABAP system access. |
| **Scope** | ABAP system provisioning, software component versioning, communication configuration, identity management, and job execution tracking. |
| **Stakeholders** | Platform Operators, ABAP Developers, Basis Administrators, Security Officers. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
ABAP Environment Service Offerings
├── SVC-SYS    System Instance Service
├── SVC-SC     Software Component Service
├── SVC-CA     Communication Arrangement Service
├── SVC-SB     Service Binding Service
├── SVC-BU     Business User Service
├── SVC-BR     Business Role Service
├── SVC-TR     Transport Request Service
├── SVC-ASN    Catalog Assignment Service
├── SVC-JOB    Application Job Service
└── SVC-HLTH   Health Service
```

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-SYS-CRUD | System Instance Management | `/api/v1/systems` | GET, POST, PUT, DELETE |
| SVC-SC-CRUD | Software Component Management | `/api/v1/software-components` | GET, POST, PUT, DELETE |
| SVC-SC-PULL | Software Component Pull | `/api/v1/software-components/pull/{id}` | POST |
| SVC-CA-CRUD | Communication Arrangement | `/api/v1/communication-arrangements` | GET, POST, PUT, DELETE |
| SVC-SB-CRUD | Service Binding | `/api/v1/service-bindings` | GET, POST, DELETE |
| SVC-BU-CRUD | Business User Management | `/api/v1/business-users` | GET, POST, PUT, DELETE |
| SVC-BU-LOCK | User Lock | `/api/v1/business-users/lock/{id}` | POST |
| SVC-BU-UNL | User Unlock | `/api/v1/business-users/unlock/{id}` | POST |
| SVC-BR-CRUD | Business Role Management | `/api/v1/business-roles` | GET, POST, PUT, DELETE |
| SVC-TR-CRUD | Transport Request | `/api/v1/transports` | GET, POST, DELETE |
| SVC-TR-REL | Transport Release | `/api/v1/transports/release/{id}` | POST |
| SVC-TR-IMP | Transport Import | `/api/v1/transports/import/{id}` | POST |
| SVC-ASN-CRUD | Catalog Assignment | `/api/v1/catalog-assignments` | GET, POST, DELETE |
| SVC-JOB-CRUD | Application Job | `/api/v1/application-jobs` | GET, POST, DELETE |
| SVC-JOB-SCH | Job Schedule | `/api/v1/application-jobs/schedule/{id}` | POST |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
┌─────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Platform Admin  │ ─────────────────> │  ABAP Environment Service    │
│  / Developer     │                    │  port 10000                   │
└─────────────────┘                    └──────────────┬───────────────┘
                                                       │
                              ┌────────────────────────▼──────────────────┐
                              │        UIM Platform (In-Memory Store)     │
                              └───────────────────────────────────────────┘
```

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Key Relationships |
|---|---|
| `SystemInstance` | Root aggregate; owns SoftwareComponent, CommunicationArrangement, ServiceBinding, BusinessUser, BusinessRole, TransportRequest, ApplicationJob |
| `SoftwareComponent` | Belongs to SystemInstance; versioned |
| `CommunicationArrangement` | Belongs to SystemInstance; references a communication scenario |
| `ServiceBinding` | Belongs to SystemInstance; carries credentials |
| `BusinessUser` | Belongs to SystemInstance; assigned BusinessRoles |
| `BusinessRole` | Belongs to SystemInstance; has CatalogAssignments |
| `CatalogAssignment` | Links BusinessRole to a catalog entry |
| `TransportRequest` | Belongs to SystemInstance; lifecycle: modifiable → released → imported |
| `ApplicationJob` | Belongs to SystemInstance; produces ExecutionLogs |
| `ExecutionLog` | Immutable record of ApplicationJob execution |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
Kubernetes Cluster — Namespace: uim-platform
│
├── ConfigMap: abap-environment-config
│   ABAP_HOST: "0.0.0.0"
│   ABAP_PORT: "10000"
│
├── Deployment: abap-environment
│   replicas: 1
│   image: uim-platform/abap-environment:latest
│   port: 10000
│   livenessProbe:  GET /api/v1/health :10000
│   readinessProbe: GET /api/v1/health :10000
│   resources: { req: 64Mi/100m, limit: 256Mi/500m }
│   securityContext: runAsNonRoot
│
└── Service: abap-environment (ClusterIP :10000)
```

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

| Information Object | Format | Transport | Notes |
|---|---|---|---|
| System Instance record | JSON | REST over HTTP | Includes region, service URL, status |
| Software Component | JSON | REST over HTTP | Versioned; tied to system instance |
| Communication Arrangement | JSON | REST over HTTP | Auth type + scenario reference |
| Business User | JSON | REST over HTTP | Credential-free; status lifecycle |
| Transport Request | JSON | REST over HTTP | Immutable after release |
| Execution Log | JSON | REST over HTTP | Append-only; correlates to ApplicationJob |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hexagonal architecture | Decouples domain from HTTP and persistence concerns |
| AD-2 | In-memory repositories | Enables fast testing and container portability; swap for RDBMS in production |
| AD-3 | Port 10000 | High-numbered port space separates ABAP Environment from core BTP services (800x) |
| AD-4 | Manual DI via Container struct | Explicit wiring; no reflection overhead; idiomatic D |
| AD-5 | Immutable execution logs | Guarantees job audit trail integrity |
| AD-6 | Multi-stage Dockerfile / Containerfile | Minimal runtime image; OCI-compatible for Docker and Podman |
