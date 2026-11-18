# NAF v4 Architecture Description — Object Store Service

> NATO Architecture Framework v4 (NAF v4) description of the UIM Platform Object Store
> service. It covers S3-like buckets and objects with versioning, data plane
> authorization (access policies, service bindings), lifecycle management and CORS,
> exposed through REST, an S3-like content API, OData v4 (SAP Fiori), a CLI and a
> desktop GUI.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – Capability View | C1 Capability Taxonomy, C2 Enterprise Vision, C3 Capability Dependencies | §2 |
| **NSV** – Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions, NSOV-3 Service Interfaces | §3 |
| **NOV** – Operational View | NOV-1 Concept, NOV-2 Node Connectivity, NOV-5 Operational Activities | §4 |
| **NLV** – Logical View | NLV-1 Logical Data Model, NLV-2 Logical Components, NLV-6 State Transitions | §5 |
| **NPV** – Physical View | NPV-1 Physical Deployment, NPV-2 Configuration | §6 |
| **NIV** – Information View | NIV-1 Information Structure, NIV-2 Business Rules | §7 |
| **Architecture decisions** | — | §8 |
| **Traceability** | capabilities → services → components | §9 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
C1  Object Storage
├── C1.1  Bucket Management
│   ├── C1.1.1  Provisioning on a hyperscaler region (AWS, Azure, GCP, Alibaba)
│   ├── C1.1.2  Encryption (SSE-S3, SSE-KMS with key validation, SSE-C)
│   ├── C1.1.3  Quotas and usage accounting
│   └── C1.1.4  Suspend / resume / empty / delete
├── C1.2  Object Management
│   ├── C1.2.1  Upload, download, head, delete (data plane)
│   ├── C1.2.2  Metadata, content types, ETags
│   ├── C1.2.3  Listing with prefixes and folders
│   ├── C1.2.4  Copy (content addressed, no duplication)
│   └── C1.2.5  Storage classes, archive / restore
├── C1.3  Versioning & Retention
│   ├── C1.3.1  Versions and delete markers
│   ├── C1.3.2  Promote / permanently delete versions
│   └── C1.3.3  Legal hold
├── C1.4  Access Control
│   ├── C1.4.1  Access policies (allow / deny, principals, actions, key patterns)
│   ├── C1.4.2  Service bindings (access keys, permissions, expiry, rotation, revocation)
│   ├── C1.4.3  Public access block
│   └── C1.4.4  CORS for browser clients
├── C1.5  Lifecycle Management
│   ├── C1.5.1  Transition to colder storage classes
│   ├── C1.5.2  Expiration
│   └── C1.5.3  Noncurrent version cleanup
└── C1.6  Operations
    ├── C1.6.1  Statistics / KPIs (usage per storage class)
    ├── C1.6.2  Background lifecycle processing
    ├── C1.6.3  Domain events
    └── C1.6.4  Multi-tenancy & role-based access (XSUAA)
```

### C2 – Enterprise Vision

| Goal | Outcome |
|---|---|
| One object store for all UIM applications | Applications get buckets on the hyperscaler region they need and access them with scoped, rotatable access keys. |
| Protect data against loss and tampering | Versioning, delete markers and legal hold; lifecycle rules never remove held objects. |
| Least privilege on the data plane | Binding permissions and IAM-style policies with explicit deny decide every content operation. |
| Control storage cost | Lifecycle rules move cold data to cheaper classes and remove expired data and old versions automatically. |
| Self-service administration | Fiori app, CLI and desktop GUI on the same ports; scripts and humans see the same data. |

### C3 – Capability Dependencies

| Capability | Depends on |
|---|---|
| C1.2 Object Management | C1.1 (bucket active, quota), C1.4.1/C1.4.2 (authorization) |
| C1.3 Versioning | C1.2 (every write creates a version) |
| C1.4.2 Service Bindings | C1.1 (binding belongs to a bucket) |
| C1.4.4 CORS | C1.1 |
| C1.5 Lifecycle | C1.2, C1.3 (legal hold, versions) |
| C1.6.1 Statistics | all aggregates |
| C1.1.2 SSE-KMS | external key management service (gateway) |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Object Store Service
├── Management services (management plane)
│   ├── Bucket service             buckets, suspend/resume/empty
│   ├── Object service             metadata, storage class, archive/restore, legal hold, copy
│   ├── Version service            list, promote, delete
│   ├── Policy service             access policies, EvaluateAccess
│   ├── Lifecycle service          lifecycle rules, ApplyLifecycle
│   ├── CORS service               CORS rules, CheckCors
│   ├── Binding service            bindings, rotate/revoke, VerifyCredentials
│   └── Reference data service     regions, storage classes, statistics
└── Content service (data plane)   put / get / head / delete / list / preflight
```

### NSOV-2 – Service Definitions

| Service | Driving port | Provided operations |
|---|---|---|
| Bucket | `IManageBucketsUseCase` | create, update, remove, get, list, suspend, resume, empty, findByName |
| Object | `IManageObjectsUseCase` | create, update (metadata / new content), remove, put, read, listing, archive, restore, hold, copy |
| Version | `IManageVersionsUseCase` | get, list, listByObject, remove, promote (create/update → 405) |
| Policy | `IManageAccessPoliciesUseCase` | CRUD, evaluate |
| Lifecycle | `IManageLifecycleRulesUseCase` | CRUD, run, apply |
| CORS | `IManageCorsRulesUseCase` | CRUD, check |
| Binding | `IManageServiceBindingsUseCase` | CRUD, revoke, rotate, verify, takeIssuedSecret |
| Reference data | `IObjectStoreCatalogService`, `IObjectStoreStatisticsService` | regions, storageClasses, statistics |

### NSOV-3 – Service Interfaces

| Interface | Protocol | Consumers |
|---|---|---|
| `/api/v1/object-store/<resource>` | REST / JSON | scripts, integrations |
| `/api/v1/object-store/content/<bucket>/<key>` | HTTP (S3-like), CORS | applications, browsers, service bindings |
| `/odata/v4/object-store` | OData v4 (JSON, CSDL `$metadata`) | SAP Fiori app, other OData clients |
| `uim-object-store-cli` | command line | administrators, CI pipelines |
| `uim-object-store-gui` | GtkD 3 desktop | administrators |
| `/api/v1/health` | HTTP | Cloud Foundry / Kubernetes probes |
| Events `objectstore.<aggregate>.<verb>` | `IObjectStoreEventPublisher` | log today; Event Mesh adapter possible |

---

## 4. Operational View (NOV)

### NOV-1 – Concept

Administrators create buckets on a provider region, configure versioning,
encryption, quotas, policies, lifecycle and CORS rules, and issue service bindings
to applications. Applications use the binding credentials on the content API;
browser applications are admitted by CORS rules; business users browse, upload
and download objects in the Fiori app. A background worker applies lifecycle
rules; administrators monitor usage through the KPI header.

### NOV-2 – Operational Node Connectivity

| From | To | Exchange |
|---|---|---|
| Business user (browser) | Approuter | Fiori app, OData, content downloads (XSUAA session) |
| Approuter | Object Store backend | OData / REST / content with forwarded JWT |
| Client application | Approuter or backend | content API with binding credentials |
| Administrator (CLI / GUI) | data directory | direct use of the ports on the shared storage |
| Backend | Key management service | key validation (simulated gateway) |
| Backend | Event broker | domain events (log publisher today) |

### NOV-5 – Operational Activities

| # | Activity | Actor | Result |
|---|---|---|---|
| A1 | Create bucket (provider, region, versioning, encryption, quota) | Admin | active bucket |
| A2 | Define access policies, CORS and lifecycle rules | Admin | bucket configuration |
| A3 | Issue / rotate / revoke service binding | Admin | one-time secret, revoked key |
| A4 | Upload / download / list / delete content | User, application | versions, ETags |
| A5 | Restore an older version, remove a delete marker | User | promoted version |
| A6 | Place / release legal hold, archive / restore | User | protected or cold object |
| A7 | Apply lifecycle (scheduled or on demand) | Worker, admin | transitions, expirations, purged versions |
| A8 | Evaluate access, check CORS, verify credentials | Admin | decision with reason |
| A9 | Monitor usage | Admin | KPIs per tenant and storage class |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Identity | Main attributes | Relations |
|---|---|---|---|
| Bucket | `BucketId`, unique `name` per tenant | provider, region, storageClass, versioningEnabled, encryption, quota, status, labels, usage | 1 → n objects, policies, rules, bindings |
| StorageObject | `StorageObjectId`, unique `name` (key) per bucket | contentType, size, etag, metadata, storageClass, status, legalHold, currentVersion | n → 1 bucket, 1 → n versions |
| ObjectVersion | `ObjectVersionId`, (`objectId`, `versionNumber`) | size, etag, contentType, blobId, isLatest, isDeleteMarker | n → 1 object, n → 1 blob |
| AccessPolicy | `AccessPolicyId`, name per bucket | effect, principals, actions, resources, enabled | n → 1 bucket |
| LifecycleRule | `LifecycleRuleId`, name per bucket | prefix, status, transition/expiration/noncurrent days, last run results | n → 1 bucket |
| CorsRule | `CorsRuleId`, name per bucket | origins, methods, headers, exposed headers, max age | n → 1 bucket |
| ServiceBinding | `ServiceBindingId`, name per bucket, `accessKeyId` | permission, status, expiresAt, secretHash, secretSalt, lastRotatedAt, lastUsedAt | n → 1 bucket |
| Blob | SHA-256 of the content (per tenant) | bytes | referenced by n versions |

All aggregates carry `tenantId`, `createdBy/At`, `updatedBy/At`.

### NLV-2 – Logical Components

| Layer | Components |
|---|---|
| Domain | entities, values, enumerations, exceptions; services `naming`, `checksums`, `bucket_rules`, `access_evaluator`, `cors_matcher`, `lifecycle_planner`, `catalogs` |
| Ports | driving use case ports, service ports; driven repository, snapshot, blob, key management and event ports |
| Application | interactors (`ResourceUseCase`, `BucketChildUseCase` and seven concrete use cases), `ObjectStorageService`, statistics, catalog, event recorder, DTOs |
| Persistence | repositories, `SnapshotTenantStore` (JSON files / memory), `FileBlobStorage` / `MemoryBlobStorage`, reflection mappers |
| Infrastructure | configuration (defaults → file → env → VCAP), XSUAA identity, KMS client, logging, lifecycle worker, container |
| Presentation | resource registry, REST, content API, OData v4 (`$metadata` generated), CLI, GtkD GUI, Fiori static files |

### NLV-6 – State Transitions

| Entity | States | Transitions |
|---|---|---|
| Bucket | active, suspended | suspend, resume; delete only when empty |
| StorageObject | active, archived, deleted | archive/restore; delete → delete marker (versioned); delete marker removed or version promoted → active; second delete → removed |
| ServiceBinding | active, expired, revoked | expiry by time; rotate keeps active; revoke is final |
| LifecycleRule | enabled, disabled | update |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

| Target | Units |
|---|---|
| SAP BTP Cloud Foundry (`mta.yaml`) | `object-store-srv` (binary buildpack, 512 MB, health check `/api/v1/health`), `object-store-approuter` (Node.js, Fiori app in `resources/`), XSUAA `object-store-xsuaa`, user-provided `object-store-config` |
| Kubernetes (`k8s/`) | Deployment `cloud-object-store` (non-root, read-only root FS, `/app/data` volume), Service (8092), ConfigMap |
| Container image | multi-stage `Dockerfile` / `Containerfile` (LDC build, Ubuntu runtime with server and CLI) |
| Workstation | server, CLI and GUI binaries sharing one `dataDir` |

### NPV-2 – Configuration

| Item | Source | Notes |
|---|---|---|
| Listener, log level | `config/default.json`, `OBJSTORE_*`, `PORT` | |
| Storage mode and data directory | `OBJSTORE_STORAGE`, `OBJSTORE_DATA_DIR` | `file` shares data across processes |
| Limits | `maxObjectSize`, `maxBucketsPerTenant` | 413 / 422 when exceeded |
| Providers, default region | `providers`, `defaultRegion` | region value help and defaults |
| Lifecycle worker | `lifecycleIntervalSeconds`, `lifecycleTenants` | 0 = off |
| Overrides on BTP | `VCAP_SERVICES` → `object-store-config` | highest precedence |
| Roles | `approuter/xs-security.json` | Viewer, User, Admin role templates and collections |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

* Snapshot collections (`object_store_buckets`, `…_objects`, `…_versions`,
  `…_access_policies`, `…_lifecycle_rules`, `…_cors_rules`, `…_service_bindings`):
  `{ "schemaVersion": 1, "collection": "...", "records": [...] }`, timestamps as std time,
  enums by name, missing fields default (forward compatible).
* Blobs: `dataDir/blobs/<tenant>/<id[0..2]>/<id>` with `id` = SHA-256 of the content.
* Payloads (REST / OData / CLI `--json`): entity fields, ISO 8601 timestamps,
  `Edm.Int64` byte sizes (strings for IEEE754Compatible clients), secrets masked.

### NIV-2 – Business Rules

| # | Rule | Enforced in |
|---|---|---|
| R1 | Bucket names follow the S3 rules and are unique per tenant | `naming`, `ManageBucketsUseCase` |
| R2 | Region must be offered by the provider; provider and region are fixed | `catalogs`, `ManageBucketsUseCase.apply` |
| R3 | SSE-KMS / SSE-C need a key id; SSE-KMS keys must match the provider's key format | `bucket_rules`, `IKeyManagementGateway` |
| R4 | Usage must stay within the quota; a quota below the usage is rejected | `bucket_rules` |
| R5 | Suspended buckets reject writes and deletes | `bucket_rules.ensureWritable` |
| R6 | Object keys: 1–1024 bytes, no leading `/`, no control characters, no `.`/`..` segments | `naming.validateObjectKey` |
| R7 | Objects under legal hold cannot be overwritten, deleted or expired | `bucket_rules`, `lifecycle_planner` |
| R8 | Archived objects must be restored before their content is read | `bucket_rules.ensureReadable` |
| R9 | Versioned buckets write delete markers; unversioned buckets keep one version | `ObjectStorageService` |
| R10 | Blobs are removed when no version references them | `ObjectStorageService.purge` |
| R11 | An explicit deny wins; without an allow access is denied (when policies exist) | `access_evaluator` |
| R12 | With public access blocked, wildcard statements never apply to `anonymous` | `access_evaluator` |
| R13 | Binding secrets are stored as salted SHA-256, compared in constant time and shown once | `checksums`, `ManageServiceBindingsUseCase` |
| R14 | Revoked or expired bindings are rejected; a binding only works on its bucket and within its permission | `ResourceRegistry.authorize` |
| R15 | Lifecycle transitions only move to colder classes; transitionDays < expirationDays | `lifecycle_planner` |
| R16 | CORS origins must be `*` or http(s) URLs; at least one method; max age ≤ 1 day | `cors_matcher` |
| R17 | A bucket must be empty before it is deleted; deleting it removes its configuration | `ManageBucketsUseCase` |

---

## 8. Architecture Decisions

| # | Decision | Rationale | Consequence |
|---|---|---|---|
| AD1 | Hexagonal architecture with a port bundle (`ObjectStorePorts`) | Five driving adapters must share identical behaviour | Adapters cannot bypass business rules |
| AD2 | Protocol-neutral resource registry with reflection codec | One definition for REST, OData `$metadata`, CLI and GUI | New fields appear in every adapter automatically |
| AD3 | Content-addressed blob storage behind `IBlobStorage` | Deduplicated copies and promotions; hyperscaler adapters can replace files | Blob GC by reference count |
| AD4 | Separate management plane and data plane | Admin scopes vs. per-bucket policies and access keys | Policies govern content operations only |
| AD5 | JSON snapshot storage with revision check | Server, CLI and GUI share data without a database | Suited to moderate volumes; repository ports allow a database later |
| AD6 | One-time secrets with salted hashes | Credentials cannot be read back from storage or APIs | Lost secrets require rotation |
| AD7 | Pure lifecycle planner + executing use case | Deterministic, testable planning with an injected `now` | Worker and on-demand runs share code |
| AD8 | Int64 byte sizes, strings for IEEE754Compatible clients | Sizes beyond 2^53 / UI5 type requirements | Clients convert strings to numbers |
| AD9 | Backend depends on `service` by path | Builds independently of the monorepo root recipe | Version alignment through the repository |
| AD10 | XSUAA claims decoded, signature checked by the approuter | Keeps the backend simple behind the approuter | Backend must not be exposed directly without JWKS validation |

---

## 9. Traceability Matrix

| Capability | Service (port) | Components | Interfaces |
|---|---|---|---|
| C1.1 Bucket management | `IManageBucketsUseCase` | `ManageBucketsUseCase`, `bucket_rules`, `catalogs`, `naming`, KMS client | REST `buckets`, OData `Buckets` + actions, CLI, GUI, Fiori |
| C1.2 Object management | `IManageObjectsUseCase` | `ManageObjectsUseCase`, `ObjectStorageService`, blob storages | content API, REST `objects`, OData `StorageObjects`, `PutObjectContent`, CLI `put/get/ls/rm`, GUI browser |
| C1.3 Versioning & retention | `IManageVersionsUseCase`, `IManageObjectsUseCase.hold` | `ManageVersionsUseCase`, `ObjectStorageService` | REST `versions`, OData `ObjectVersions`, `PromoteObjectVersion`, Fiori versions dialog |
| C1.4.1 Access policies | `IManageAccessPoliciesUseCase` | `access_evaluator`, `ResourceRegistry.authorize` | REST `policies`, `access/evaluate`, OData `EvaluateAccess`, CLI `evaluate` |
| C1.4.2 Service bindings | `IManageServiceBindingsUseCase` | `checksums`, `ManageServiceBindingsUseCase` | REST `bindings`, `credentials/verify`, OData `ServiceBindings`, `VerifyCredentials`, content API headers |
| C1.4.4 CORS | `IManageCorsRulesUseCase` | `cors_matcher`, content controller | REST `cors-rules`, `cors/check`, OData `CheckCors`, `OPTIONS` |
| C1.5 Lifecycle | `IManageLifecycleRulesUseCase` | `lifecycle_planner`, `LifecycleWorker` | REST `lifecycle-rules`, `lifecycle/apply`, OData `ApplyLifecycle`, CLI `lifecycle` |
| C1.6 Operations | `IObjectStoreStatisticsService`, `IObjectStoreCatalogService` | statistics, catalog, logging, configuration, security | `Statistics`, `Regions`, `StorageClasses`, `/api/v1/health` |
