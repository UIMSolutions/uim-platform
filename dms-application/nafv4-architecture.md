# NAF v4 Architecture Description — DMS Application Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> DMS Application Service — document management, repository and folder hierarchies,
> versioned documents, permissions, favourites, and sharing.

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
DMS Application
├── C1.1  DmsRepository Management
│   ├── C1.1.1  Create / update / delete repositories
│   └── C1.1.2  DmsRepository type and status lifecycle
│
├── C1.2  DmsFolder Hierarchy
│   ├── C1.2.1  Create / rename / delete folders
│   └── C1.2.2  Nested folder paths
│
├── C1.3  Document Lifecycle
│   ├── C1.3.1  Upload and update documents
│   ├── C1.3.2  Version management
│   └── C1.3.3  Content checksum integrity
│
├── C1.4  Access Control
│   ├── C1.4.1  Resource-level permissions (read / write / admin)
│   └── C1.4.2  Principal-based access (user / group)
│
├── C1.5  Personalisation
│   └── C1.5.1  User favourites management
│
├── C1.6  Collaboration
│   └── C1.6.1  Document and folder sharing with expiry
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide enterprise document management modelled on SAP Document Management Service (DMS). |
| **Vision** | Enable teams to store, version, and collaborate on documents within governed repository hierarchies. |
| **Scope** | DmsRepository and folder CRUD, document upload and versioning, permissions, favourites, and sharing. |
| **Stakeholders** | Business Users, Content Managers, Application Developers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-REPO-CRUD | DmsRepository | `/api/v1/repositories` | GET, POST, PUT, DELETE |
| SVC-FLD-CRUD | DmsFolder | `/api/v1/folders` | GET, POST, PUT, DELETE |
| SVC-DOC-CRUD | Document | `/api/v1/documents` | GET, POST, PUT, DELETE |
| SVC-DVER-CRUD | Document Version | `/api/v1/document-versions` | GET, POST |
| SVC-PERM-CRUD | Permission | `/api/v1/permissions` | GET, POST, DELETE |
| SVC-FAV-CRUD | Favorite | `/api/v1/favorites` | GET, POST, DELETE |
| SVC-SHR-CRUD | Share | `/api/v1/shares` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Business User /    │ ─────────────────> │  DMS Application Service     │
│  Content Manager    │                    │  port 8094                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `DmsRepository` | Root aggregate; contains Folders and Documents |
| `DmsFolder` | Belongs to DmsRepository; self-referential parent/child nesting |
| `Document` | Belongs to DmsRepository and DmsFolder; parent of DocumentVersions |
| `DocumentVersion` | Belongs to Document; sequential version numbers |
| `Permission` | Polymorphic ACL entry for DmsRepository, DmsFolder, or Document |
| `Favorite` | User bookmark to any resource |
| `Share` | Owner-to-recipient grant with optional expiry |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: dms-application-config
│   DMS_APPLICATION_HOST: "0.0.0.0"
│   DMS_APPLICATION_PORT: "8094"
├── Deployment: dms-application  port: 8094
└── Service: dms-application (ClusterIP :8094)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Document versioning | Mirrors SAP DMS versioned content objects |
| AD-2 | Polymorphic permissions | Single ACL model for repos, folders, and documents |
| AD-3 | Share expiry | Time-bounded sharing for compliance |
| AD-4 | In-memory repositories | Fast testing; swap for object store in production |
| AD-5 | Port 8094 | Consistent UIM platform port allocation |
