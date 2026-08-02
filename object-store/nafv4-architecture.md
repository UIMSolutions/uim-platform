# NAF v4 Architecture Description — Object Store Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Object Store Service — S3-compatible object storage, bucket management,
> object versioning, lifecycle policies, access controls, and CORS configuration.

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
Object Store
├── C1.1  Bucket Management
│   ├── C1.1.1  Create / delete buckets
│   ├── C1.1.2  Versioning configuration
│   └── C1.1.3  Storage class selection
│
├── C1.2  Object Operations
│   ├── C1.2.1  Put, get, delete objects
│   └── C1.2.2  ETag-based cache control
│
├── C1.3  Object Versioning
│   ├── C1.3.1  Version listing and retrieval
│   └── C1.3.2  Restore from previous version
│
├── C1.4  Access Control
│   ├── C1.4.1  Bucket access policies (allow / deny)
│   └── C1.4.2  Service binding for application access
│
├── C1.5  CORS Configuration
│   └── C1.5.1  Origin and method allow-list management
│
├── C1.6  Lifecycle Management
│   └── C1.6.1  Expiration rules by prefix
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide S3-compatible object storage modelled on SAP Object Store Service for BTP. |
| **Vision** | Enable BTP applications to persist unstructured data (documents, binaries, backups) in tenant-isolated buckets with full lifecycle governance. |
| **Scope** | Bucket CRUD, object operations, versioning, access policies, CORS rules, lifecycle rules, and service bindings. |
| **Stakeholders** | Application Developers, Platform Operators, Data Engineers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-BKT-CRUD | Bucket | `/api/v1/buckets` | GET, POST, DELETE |
| SVC-OBJ-CRUD | Storage Object | `/api/v1/storage-objects` | GET, POST, DELETE |
| SVC-VER-LIST | Object Version | `/api/v1/object-versions` | GET |
| SVC-SB-CRUD | Service Binding | `/api/v1/service-bindings` | GET, POST, DELETE |
| SVC-AP-CRUD | Access Policy | `/api/v1/access-policies` | GET, POST, DELETE |
| SVC-CORS-CRUD | CORS Rule | `/api/v1/cors-rules` | GET, POST, DELETE |
| SVC-LC-CRUD | Lifecycle Rule | `/api/v1/lifecycle-rules` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Application /      │ ─────────────────> │  Object Store Service        │
│  Data Pipeline      │                    │  port 8092                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Bucket` | Root; contains StorageObjects, AccessPolicies, CorsRules, LifecycleRules |
| `StorageObject` | Keyed binary object; ETag-indexed; parent of ObjectVersions |
| `ObjectVersion` | Point-in-time snapshot of a StorageObject |
| `ServiceBinding` | Application access key linked to Bucket |
| `AccessPolicy` | Principal-scoped allow/deny for Bucket operations |
| `CorsRule` | Origin and method CORS configuration |
| `LifecycleRule` | Prefix-scoped expiration and noncurrent version management |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: object-store-config
│   OBJECT_STORE_HOST: "0.0.0.0"
│   OBJECT_STORE_PORT: "8092"
├── Deployment: object-store  port: 8092
└── Service: object-store (ClusterIP :8092)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | S3-compatible API model | Mirrors SAP Object Store Service S3 compatibility |
| AD-2 | Object versioning | Enables rollback and audit of stored objects |
| AD-3 | Lifecycle rules | Automates storage cost management via expiration |
| AD-4 | In-memory repositories | Fast testing; swap for S3/MinIO in production |
| AD-5 | Port 8092 | Consistent UIM platform port allocation |
