# NAF v4 Architecture Description — HTML5 Repository Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> HTML5 Repository Service — HTML5 application hosting, version deployment,
> file management, routing, and content caching for BTP launchpads.

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
HTML5 Repository
├── C1.1  Application Management
│   ├── C1.1.1  Register HTML5 applications with namespace
│   └── C1.1.2  Application status lifecycle
│
├── C1.2  Version Deployment
│   ├── C1.2.1  Deploy versioned app packages
│   ├── C1.2.2  Deployment status and history
│   └── C1.2.3  Rollback to previous versions
│
├── C1.3  File Serving
│   ├── C1.3.1  Upload and store application files
│   ├── C1.3.2  ETag-based cache control
│   └── C1.3.3  MIME type handling
│
├── C1.4  Routing
│   └── C1.4.1  URL-to-app routing configuration
│
├── C1.5  Content Caching
│   └── C1.5.1  TTL-based content cache management
│
├── C1.6  Service Binding
│   └── C1.6.1  Service instance and plan lifecycle
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide HTML5 application hosting modelled on SAP HTML5 Application Repository for BTP. |
| **Vision** | Enable developers to upload, version, and serve frontend applications from a central repository used by SAP Launchpad and other BTP services. |
| **Scope** | App registration, versioned package deployment, file serving, routing, and caching. |
| **Stakeholders** | Frontend Developers, Platform Operators, SAP Launchpad Admins. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-APP-CRUD | HTML5 App | `/api/v1/html5-apps` | GET, POST, PUT, DELETE |
| SVC-VER-CRUD | App Version | `/api/v1/app-versions` | GET, POST, DELETE |
| SVC-VER-DEPLOY | Deploy Version | `/api/v1/app-versions/{id}/deploy` | POST |
| SVC-FILE-CRUD | App File | `/api/v1/app-files` | GET, POST, DELETE |
| SVC-ROUTE-CRUD | App Route | `/api/v1/app-routes` | GET, POST, DELETE |
| SVC-DEPLOY-LIST | Deployment Record | `/api/v1/deployment-records` | GET |
| SVC-SVC-CRUD | Service Instance | `/api/v1/service-instances` | GET, POST, DELETE |
| SVC-CACHE-CRUD | Content Cache | `/api/v1/content-cache` | GET, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Frontend Dev /     │ ─────────────────> │  HTML5 Repository Service    │
│  CI/CD Pipeline     │                    │  port 8097                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `HtmlApp` | Root; named by namespace; parent of AppVersions and AppRoutes |
| `AppVersion` | Belongs to HtmlApp; contains AppFiles; tracked by DeploymentRecords |
| `AppFile` | Belongs to AppVersion; path-addressed, ETag-indexed |
| `AppRoute` | Maps URL pattern to HtmlApp target |
| `DeploymentRecord` | Append-only history per AppVersion |
| `ServiceInstance` | SAP BTP service instance binding for the repository |
| `ContentCache` | TTL-cached file content keyed by AppVersion |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: html-repository-config
│   HTML_REPOSITORY_HOST: "0.0.0.0"
│   HTML_REPOSITORY_PORT: "8097"
├── Deployment: html-repository  port: 8097
└── Service: html-repository (ClusterIP :8097)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Namespace-scoped apps | Mirrors SAP HTML5 Repository namespace isolation |
| AD-2 | ETag-based caching | Enables efficient browser and CDN cache revalidation |
| AD-3 | Immutable deployment records | Provides full deployment history for auditing |
| AD-4 | In-memory repositories | Fast testing; swap for object store in production |
| AD-5 | Port 8097 | Consistent UIM platform port allocation |
