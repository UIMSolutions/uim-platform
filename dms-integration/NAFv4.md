# NAF v4 Architecture Description — DMS Integration Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> DMS Integration Service — document management integration with repository
> federation, folder management, and permission control modelled on
> SAP Document Management Service, Integration Option.

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
DMS Integration
├── C1.1  Repository Management
│   └── C1.1.1  Register and manage federated repositories
│
├── C1.2  Folder Management
│   ├── C1.2.1  Create folder hierarchies
│   └── C1.2.2  Folder navigation
│
├── C1.3  Document Management
│   ├── C1.3.1  Store and retrieve documents
│   └── C1.3.2  Document versioning
│
├── C1.4  Permission Management
│   └── C1.4.1  Role-based access to repositories and folders
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Tenant isolation
    └── C1.5.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide DMS integration capabilities modelled on SAP DMS Integration Option (CMIS-based). |
| **Vision** | Enable S/4HANA and LoB applications to store and retrieve attachments in federated content repositories. |
| **Scope** | Repositories, folders, documents, document versions, and permissions. |
| **Stakeholders** | Application Developers, Content Architects, Enterprise Architects. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-REPO-CRUD | Repository | `/api/v1/repositories` | GET, POST, DELETE |
| SVC-FOLD-CRUD | Folder | `/api/v1/folders` | GET, POST, DELETE |
| SVC-DOC-CRUD | Document | `/api/v1/documents` | GET, POST, DELETE |
| SVC-VER-LIST | Document Version | `/api/v1/document-versions` | GET |
| SVC-PERM-CRUD | Permission | `/api/v1/permissions` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  LoB Application /  │ ─────────────────> │  DMS Integration Service     │
│  S/4HANA            │                    │  port 8109                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Repository` | Root content store; parent of Folders |
| `Folder` | Hierarchical container; parent of Documents |
| `Document` | File with metadata; parent of DocumentVersions |
| `DocumentVersion` | Point-in-time document snapshot |
| `Permission` | ACL entry for Repository or Folder |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: dms-integration-config
│   DMS_INTEGRATION_HOST: "0.0.0.0"
│   DMS_INTEGRATION_PORT: "8109"
├── Deployment: dms-integration  port: 8109
└── Service: dms-integration (ClusterIP :8109)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | CMIS-aligned model | Mirrors SAP DMS CMIS interface |
| AD-2 | Repository federation | Supports multiple backend content stores |
| AD-3 | Document versioning | Enables audit trail |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8109 | Consistent UIM platform port allocation |
