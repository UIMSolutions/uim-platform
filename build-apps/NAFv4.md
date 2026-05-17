# NAF v4 Architecture Description — Build Apps Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Build Apps Service — low-code application builder with UI components,
> logic flows, data connections, and build pipeline management modelled on
> SAP Build Apps (AppGyver).

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
Build Apps
├── C1.1  Application Management
│   ├── C1.1.1  Create and publish apps
│   └── C1.1.2  App build pipeline
│
├── C1.2  UI Design
│   ├── C1.2.1  UI component library
│   └── C1.2.2  Page layout management
│
├── C1.3  Logic Flows
│   └── C1.3.1  Visual event-action logic design
│
├── C1.4  Data Connections
│   └── C1.4.1  REST / OData connector management
│
├── C1.5  Data Entities
│   └── C1.5.1  Client-side data model definitions
│
├── C1.6  Collaboration
│   └── C1.6.1  Project member management
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a low-code app builder modelled on SAP Build Apps (AppGyver). |
| **Vision** | Enable citizen developers to create mobile and web applications visually without deep coding expertise. |
| **Scope** | Applications, pages, UI components, logic flows, data entities, data connections, builds, and project members. |
| **Stakeholders** | Citizen Developers, Business Analysts, IT Administrators. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-APP-CRUD | Application | `/api/v1/applications` | GET, POST, PUT, DELETE |
| SVC-PAGE-CRUD | Page | `/api/v1/pages` | GET, POST, PUT, DELETE |
| SVC-UI-CRUD | UI Component | `/api/v1/ui-components` | GET, POST, DELETE |
| SVC-LF-CRUD | Logic Flow | `/api/v1/logic-flows` | GET, POST, PUT, DELETE |
| SVC-DE-CRUD | Data Entity | `/api/v1/data-entities` | GET, POST, DELETE |
| SVC-DC-CRUD | Data Connection | `/api/v1/data-connections` | GET, POST, DELETE |
| SVC-BLD-CRUD | App Build | `/api/v1/app-builds` | GET, POST |
| SVC-MBR-CRUD | Project Member | `/api/v1/project-members` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Citizen Developer /│ ─────────────────> │  Build Apps Service          │
│  Designer UI        │                    │  port 8112                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Application` | Root; parent of Pages, LogicFlows, DataConnections |
| `Page` | UI page within an Application |
| `UIComponent` | Widget placed on a Page |
| `LogicFlow` | Event-action workflow within an Application |
| `DataEntity` | Client-side data model |
| `DataConnection` | Backend service connector |
| `AppBuild` | Compiled deployable artefact |
| `ProjectMember` | Collaborator with role |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: build-apps-config
│   BUILD_APPS_HOST: "0.0.0.0"
│   BUILD_APPS_PORT: "8112"
├── Deployment: build-apps  port: 8112
└── Service: build-apps (ClusterIP :8112)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | App-centric model | Mirrors SAP Build Apps application concept |
| AD-2 | Visual logic flows | No-code event-action design |
| AD-3 | Data connection abstraction | Decouples UI from backend |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8112 | Consistent UIM platform port allocation |
