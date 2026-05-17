# NAF v4 Architecture Description — Application Studio Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Application Studio Service — cloud-based IDE with dev space management,
> project scaffolding, run/build configurations, and service bindings modelled
> on SAP Business Application Studio.

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
Application Studio
├── C1.1  Dev Space Management
│   ├── C1.1.1  Create / stop / delete dev spaces
│   └── C1.1.2  Extension installation
│
├── C1.2  Project Management
│   ├── C1.2.1  Scaffold from templates
│   └── C1.2.2  Project lifecycle
│
├── C1.3  Build and Run
│   ├── C1.3.1  Build configuration management
│   └── C1.3.2  Run configuration management
│
├── C1.4  Service Bindings
│   └── C1.4.1  Bind BTP services to projects
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Tenant isolation
    └── C1.5.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a cloud-based IDE modelled on SAP Business Application Studio. |
| **Vision** | Give developers a full-featured browser-based development environment with SAP-specific tooling. |
| **Scope** | Dev spaces, projects, extensions, run/build configurations, service bindings, and templates. |
| **Stakeholders** | Application Developers, Full-Stack Developers, Platform Architects. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-DS-CRUD | Dev Space | `/api/v1/dev-spaces` | GET, POST, PUT, DELETE |
| SVC-PRJ-CRUD | Project | `/api/v1/projects` | GET, POST, PUT, DELETE |
| SVC-EXT-CRUD | Extension | `/api/v1/extensions` | GET, POST, DELETE |
| SVC-DST-CRUD | Dev Space Type | `/api/v1/dev-space-types` | GET, POST, DELETE |
| SVC-PT-CRUD | Project Template | `/api/v1/project-templates` | GET, POST |
| SVC-SB-CRUD | Service Binding | `/api/v1/service-bindings` | GET, POST, DELETE |
| SVC-RC-CRUD | Run Configuration | `/api/v1/run-configurations` | GET, POST, DELETE |
| SVC-BC-CRUD | Build Configuration | `/api/v1/build-configurations` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Developer /        │ ─────────────────> │  Application Studio Service  │
│  IDE Client         │                    │  port 8111                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `DevSpace` | Root IDE environment; has Extensions and ServiceBindings |
| `Project` | Code project within a DevSpace |
| `Extension` | Plugin installed into a DevSpace |
| `DevSpaceType` | DevSpace template type |
| `ProjectTemplate` | Scaffold template for new projects |
| `ServiceBinding` | BTP service bound to a Project |
| `RunConfiguration` | Run target for a Project |
| `BuildConfiguration` | Build pipeline for a Project |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: application-studio-config
│   APPLICATION_STUDIO_HOST: "0.0.0.0"
│   APPLICATION_STUDIO_PORT: "8111"
├── Deployment: application-studio  port: 8111
└── Service: application-studio (ClusterIP :8111)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Dev-space-centric model | Mirrors SAP BAS dev space isolation |
| AD-2 | Extension catalogue | Supports modular tooling installation |
| AD-3 | Template-based scaffolding | Accelerates project creation |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8111 | Consistent UIM platform port allocation |
