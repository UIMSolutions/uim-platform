# NAF v4 Architecture Description — Cloud Foundry Runtime Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Cloud Foundry Runtime Service — organisation, space, application, service,
> route, buildpack, and domain lifecycle management.

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
Cloud Foundry Runtime
├── C1.1  Organisation Management
│   ├── C1.1.1  Create / update / delete organisations
│   ├── C1.1.2  Suspend / activate lifecycle
│   └── C1.1.3  Quota plan assignment
│
├── C1.2  Space Management
│   ├── C1.2.1  Create / update / delete spaces
│   └── C1.2.2  Space-level resource scoping
│
├── C1.3  Application Lifecycle
│   ├── C1.3.1  Deploy and manage CF applications
│   ├── C1.3.2  Start / stop / restart / scale
│   └── C1.3.3  Environment variable management
│
├── C1.4  Service Management
│   ├── C1.4.1  Service instance provisioning
│   └── C1.4.2  Service binding to applications
│
├── C1.5  Network Management
│   ├── C1.5.1  Route creation and mapping
│   └── C1.5.2  Domain registration (shared / private)
│
├── C1.6  Buildpack Management
│   ├── C1.6.1  Register and position buildpacks
│   └── C1.6.2  Enable / lock / unlock buildpacks
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a Cloud Foundry runtime management API modelled on SAP BTP Cloud Foundry Environment. |
| **Vision** | Enable platform operators to provision organisations and spaces, deploy applications, manage service bindings, and configure network routes through a unified REST API. |
| **Scope** | Full CF runtime lifecycle from org provisioning through application deployment to route mapping. |
| **Stakeholders** | Platform Operators, Application Developers, DevOps Engineers. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Cloud Foundry Service Offerings
├── SVC-ORG    Organisation Service
├── SVC-SP     Space Service
├── SVC-APP    Application Service
├── SVC-SI     Service Instance Service
├── SVC-SB     Service Binding Service
├── SVC-RT     Route Service
├── SVC-DOM    Domain Service
├── SVC-BP     Buildpack Service
└── SVC-HLTH   Health Service
```

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-ORG-CRUD | Organisation | `/api/v1/orgs` | GET, POST, PUT, DELETE |
| SVC-ORG-SUSP | Suspend Org | `/api/v1/orgs/suspend/{id}` | POST |
| SVC-ORG-ACT | Activate Org | `/api/v1/orgs/activate/{id}` | POST |
| SVC-SP-CRUD | Space | `/api/v1/spaces` | GET, POST, PUT, DELETE |
| SVC-APP-CRUD | Application | `/api/v1/apps` | GET, POST, PUT, DELETE |
| SVC-APP-START | Start App | `/api/v1/apps/start/{id}` | POST |
| SVC-APP-STOP | Stop App | `/api/v1/apps/stop/{id}` | POST |
| SVC-APP-SCALE | Scale App | `/api/v1/apps/scale/{id}` | POST |
| SVC-SI-CRUD | Service Instance | `/api/v1/service-instances` | GET, POST, DELETE |
| SVC-SB-CRUD | Service Binding | `/api/v1/service-bindings` | GET, POST, DELETE |
| SVC-RT-CRUD | Route | `/api/v1/routes` | GET, POST, DELETE |
| SVC-RT-MAP | Map Route | `/api/v1/routes/map/{id}` | POST |
| SVC-DOM-CRUD | Domain | `/api/v1/domains` | GET, POST, DELETE |
| SVC-BP-CRUD | Buildpack | `/api/v1/buildpacks` | GET, POST, PUT, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
┌─────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Platform        │ ─────────────────> │  Cloud Foundry Runtime       │
│  Operator / CLI  │                    │  Service — port 8091         │
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
| `Organization` | Root aggregate; contains Spaces and CfDomains |
| `Space` | Belongs to Organization; scopes Applications, ServiceInstances, Routes |
| `Application` | Belongs to Space; bound to ServiceInstances via ServiceBindings |
| `ServiceInstance` | Belongs to Space; bound to Applications via ServiceBindings |
| `ServiceBinding` | Links Application ↔ ServiceInstance; carries credentials |
| `Route` | Belongs to Space; maps to Application; references CfDomain |
| `CfDomain` | Belongs to Organization; shared or private |
| `Buildpack` | Global; referenced by Application during staging |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
Kubernetes Cluster — Namespace: uim-platform
│
├── ConfigMap: cloud-foundry-config
│   CF_HOST: "0.0.0.0"
│   CF_PORT: "8091"
│
├── Deployment: cloud-foundry
│   replicas: 1
│   image: uim-platform/cloud-foundry:latest
│   port: 8091
│   livenessProbe:  GET /api/v1/health :8091
│   resources: { req: 64Mi/100m, limit: 256Mi/500m }
│   securityContext: runAsNonRoot
│
└── Service: cloud-foundry (ClusterIP :8091)
```

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

| Information Object | Format | Transport | Notes |
|---|---|---|---|
| Organization | JSON | REST over HTTP | Root aggregate; quota plan reference |
| Application | JSON | REST over HTTP | state: stopped/started/crashed |
| ServiceBinding | JSON | REST over HTTP | Credential payload included |
| Route | JSON | REST over HTTP | host + domain + path combination |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | CF API v3-inspired design | Mirrors SAP BTP Cloud Foundry API patterns |
| AD-2 | Separate suspend/activate endpoints | Mirrors CF's lifecycle action pattern |
| AD-3 | In-memory repositories | Fast testing; swap for RDBMS in production |
| AD-4 | Port 8091 | Consistent port in UIM platform namespace |
| AD-5 | Multi-stage Dockerfile / Containerfile | Minimal OCI runtime image |
