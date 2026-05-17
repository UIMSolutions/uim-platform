# NAF v4 Architecture Description — Workzone Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Workzone Service — digital workplace portal combining site management, content
> publishing, UI card catalogue, app registration, knowledge base, tasks, and
> personalised notifications modelled on SAP Build Work Zone (formerly SAP Launchpad Service).

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
Workzone
├── C1.1  Site Management
│   ├── C1.1.1  Create and configure digital workplace sites
│   └── C1.1.2  Page template management
│
├── C1.2  Page and Widget Authoring
│   ├── C1.2.1  Page CRUD with slug routing
│   └── C1.2.2  Configurable widget embedding
│
├── C1.3  App Registration
│   └── C1.3.1  Register and publish BTP applications
│
├── C1.4  UI Cards
│   └── C1.4.1  Card manifest management and publishing
│
├── C1.5  Content Channels
│   ├── C1.5.1  Channel creation and management
│   └── C1.5.2  Content item authoring and publishing
│
├── C1.6  Knowledge Base
│   └── C1.6.1  Article authoring, tagging, and search
│
├── C1.7  User Profiles
│   └── C1.7.1  User preferences and personalisation
│
├── C1.8  Tasks
│   └── C1.8.1  Personal task list management
│
├── C1.9  Notifications
│   └── C1.9.1  In-app notification delivery
│
└── C1.10  Cross-Cutting
    ├── C1.10.1  Tenant isolation
    └── C1.10.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a unified digital workplace portal modelled on SAP Build Work Zone Standard/Advanced Edition. |
| **Vision** | Give business users a personalised, content-rich workplace combining app launching, content consumption, task tracking, and knowledge access in a single platform. |
| **Scope** | Sites, pages, widgets, app registrations, UI cards, content channels, knowledge base articles, user profiles, tasks, and notifications. |
| **Stakeholders** | End Users, IT Administrators, Content Editors, App Developers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-SITE-CRUD | Site | `/api/v1/sites` | GET, POST, PUT, DELETE |
| SVC-PAGE-CRUD | Page | `/api/v1/pages` | GET, POST, PUT, DELETE |
| SVC-PT-CRUD | Page Template | `/api/v1/page-templates` | GET, POST, DELETE |
| SVC-WGT-CRUD | Widget | `/api/v1/widgets` | GET, POST, PUT, DELETE |
| SVC-CARD-CRUD | Card | `/api/v1/cards` | GET, POST, PUT, DELETE |
| SVC-APP-CRUD | App Registration | `/api/v1/app-registrations` | GET, POST, DELETE |
| SVC-CH-CRUD | Channel | `/api/v1/channels` | GET, POST, DELETE |
| SVC-CI-CRUD | Content Item | `/api/v1/content-items` | GET, POST, DELETE |
| SVC-KB-CRUD | Knowledge Base Article | `/api/v1/knowledge-base-articles` | GET, POST, PUT, DELETE |
| SVC-UP-CRUD | User Profile | `/api/v1/user-profiles` | GET, POST, PUT |
| SVC-TSK-CRUD | Task | `/api/v1/tasks` | GET, POST, PUT, DELETE |
| SVC-NOT-LIST | Notification | `/api/v1/notifications` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  End User /         │ ─────────────────> │  Workzone Service            │
│  Content Editor /   │                    │  port 8084                    │
│  Admin              │                    └──────────────────────────────┘
└────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Site` | Root workplace; parent of Pages; references PageTemplate |
| `Page` | Site page with URL slug; parent of Widgets |
| `PageTemplate` | Reusable layout for Pages |
| `Widget` | Embedded content block within a Page |
| `Card` | UI card registered in the card catalogue |
| `AppRegistration` | BTP application entry point |
| `Channel` | Content publishing stream; parent of ContentItems |
| `ContentItem` | Published piece of content |
| `KnowledgeBaseArticle` | Searchable help article |
| `UserProfile` | Personalization and preferences per user |
| `Task` | Personal to-do item |
| `Notification` | In-app push message to user |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: workzone-config
│   WORKZONE_HOST: "0.0.0.0"
│   WORKZONE_PORT: "8084"
├── Deployment: workzone  port: 8084
└── Service: workzone (ClusterIP :8084)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Site + Page + Widget hierarchy | Mirrors SAP Build Work Zone site structure |
| AD-2 | Card manifest model | Enables SAPUI5 / OpenUI5 integration card support |
| AD-3 | Channel-based content | Supports target-audience content distribution |
| AD-4 | In-memory repositories | Fast testing; swap for persistent CMS store in production |
| AD-5 | Port 8084 | Consistent UIM platform port allocation |
