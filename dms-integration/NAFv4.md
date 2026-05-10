# NAFv4 — DMS Integration Platform Service

## Architecture Description Reference (ADR)

This document describes the architecture of the **DMS Integration Platform Service** using the NATO Architecture Framework version 4 (NAFv4) viewpoints.

---

## C1 — Concepts View (Capability Taxonomy)

The DMS Integration Platform Service provides the following capabilities aligned with SAP Document Management Service, integration option:

| Capability | Description |
|------------|-------------|
| **Repository Management** | Create, configure, activate, and deactivate document repositories; supports managed, external, Google Workspace, OpenText, SharePoint, and S/4HANA DMS backends |
| **Document Management** | Full document lifecycle: upload, retrieve, update, delete; checkout/checkin for concurrent edit control; publish and archive workflows |
| **Folder Hierarchy** | Hierarchical folder organisation within repositories; path-based navigation; system and virtual folder types |
| **Document Versioning** | Automatic major/minor version creation on checkin; version history retrieval; protect latest version from deletion |
| **Permission Management** | Fine-grained ACL per document or folder; principal types: user, group, everyone; permission types: read, write, delete, readWrite, full |
| **Multi-Tenant Isolation** | All data is scoped to a `tenantId` derived from the HTTP request; no cross-tenant data leakage |
| **Health Monitoring** | Kubernetes liveness and readiness probes via `/health` endpoint |

---

## C2 — Enterprise Vision

The service is a microservice within the **uim-platform**, a cloud-native platform built on SAP BTP patterns. It is intended to be deployed as a stateless containerised workload in Kubernetes, replacing or augmenting the SAP Document Management Service, integration option, with a locally governed and extensible implementation.

---

## L1 — Logical Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  HTTP Client / API Consumer              │
└────────────────────────┬────────────────────────────────┘
                         │  REST/JSON  (port 8109)
┌────────────────────────▼────────────────────────────────┐
│              Presentation Layer (vibe.d HTTP)            │
│  RepositoryController  DocumentController                │
│  FolderController      DocumentVersionController         │
│  PermissionController  HealthController                  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│               Application Layer (Use Cases)              │
│  ManageRepositoriesUseCase   ManageDocumentsUseCase      │
│  ManageFoldersUseCase        ManageDocumentVersionsUseCase│
│  ManagePermissionsUseCase                                │
└────────────────────────┬────────────────────────────────┘
                         │  Domain Ports (Interfaces)
┌────────────────────────▼────────────────────────────────┐
│                   Domain Layer                           │
│  Entities: Repository_, Document, Folder,                │
│            DocumentVersion, Permission                   │
│  Value IDs: RepositoryId, DocumentId, FolderId,          │
│             DocumentVersionId, PermissionId              │
│  Enumerations: RepositoryType, DocumentStatus,           │
│                CheckoutStatus, PermissionType, …         │
│  Domain Services: DmsValidator                           │
│  Repository Interfaces: RepositoryRepository,            │
│    DocumentRepository, FolderRepository,                 │
│    DocumentVersionRepository, PermissionRepository       │
└────────────────────────┬────────────────────────────────┘
                         │  Adapter implementations
┌────────────────────────▼────────────────────────────────┐
│              Infrastructure Layer (Adapters)             │
│  MemoryRepositoryRepository  MemoryDocumentRepository    │
│  MemoryFolderRepository      MemoryDocumentVersionRepository│
│  MemoryPermissionRepository                              │
│  Container (DI wiring)   SrvConfig (env config)          │
└─────────────────────────────────────────────────────────┘
```

---

## L2 — Logical Data Model

```
Repository_  1──* Document
Repository_  1──* Folder
Folder       1──* Folder (parent / children)
Folder       1──* Document
Document     1──* DocumentVersion
Document     1──* Permission
Folder       1──* Permission
Repository_  1──* Permission
```

All entities share a `tenantId` for multi-tenant scoping.

---

## P1 — Physical Architecture

| Component | Technology | Notes |
|-----------|-----------|-------|
| Runtime | D (LDC2 compiler) | Compiled to native binary |
| HTTP Server | vibe.d 0.10.3 | Async event-loop, URLRouter |
| Container Image | Alpine 3.20 + libgcc | Multi-stage Docker / Podman build |
| Orchestration | Kubernetes (uim-platform namespace) | Deployment + Service + ConfigMap |
| Persistence | In-memory (TenantRepository) | Replace with CMIS/DB adapter for production |
| Configuration | Environment variables | DMS_INTEGRATION_HOST, DMS_INTEGRATION_PORT |
| Port | 8109 | HTTP only; TLS terminated at ingress |

---

## P2 — Deployment Architecture

```
┌────────────────────────────────────────────────────────────────┐
│  Kubernetes Cluster (uim-platform namespace)                   │
│                                                                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Deployment: dms-integration  (replicas: 1)             │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │  Container: uim-dms-integration-platform-service  │  │   │
│  │  │  Image:  uim-platform/dms-integration:latest      │  │   │
│  │  │  Port:   8109                                      │  │   │
│  │  │  Env:    DMS_INTEGRATION_HOST, DMS_INTEGRATION_PORT│  │   │
│  │  │  Probes: /health (liveness + readiness)           │  │   │
│  │  │  CPU:    100m req / 500m limit                     │  │   │
│  │  │  Memory: 64Mi req / 256Mi limit                    │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                │
│  Service: dms-integration  (ClusterIP :8109)                   │
│  ConfigMap: dms-integration-config                             │
└────────────────────────────────────────────────────────────────┘
```

---

## S1 — Service-Oriented View

| Service | Consumers | Protocol | Port |
|---------|-----------|----------|------|
| dms-integration | uim-platform internal services, API Gateway | REST/JSON over HTTP | 8109 |

The service exposes five resource endpoints plus a health check:

| Resource | Base Path |
|----------|-----------|
| Repositories | `/api/v1/dms-integration/repositories` |
| Documents | `/api/v1/dms-integration/documents` |
| Folders | `/api/v1/dms-integration/folders` |
| Document Versions | `/api/v1/dms-integration/document-versions` |
| Permissions | `/api/v1/dms-integration/permissions` |
| Health | `/health` |

---

## Ar1 — Architecture Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| AD-01 | Hexagonal (ports & adapters) architecture | Decouples domain logic from HTTP and persistence; allows swapping memory store for CMIS/DB |
| AD-02 | In-memory persistence as default adapter | Enables fast iteration and testing; production deployments replace with CMIS or database adapter |
| AD-03 | vibe.d for HTTP | Idiomatic async D web framework; minimal overhead |
| AD-04 | Multi-stage Alpine/LDC2 Docker build | Minimal runtime image (~20MB); uses ldc2 for performance-optimised native binary |
| AD-05 | TenantId scoping on all data access | Enforces multi-tenant isolation at the repository layer |
| AD-06 | Port 8109 | Unique within uim-platform service port registry |
| AD-07 | Checkout/Checkin document lifecycle | Prevents concurrent edits; mirrors SAP DMS CMIS checkout pattern |
| AD-08 | Major/Minor versioning on checkin | Compatible with CMIS versioning semantics |
