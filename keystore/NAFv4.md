# NAFv4 — Keystore Service

NATO Architecture Framework v4 — Architectural Viewpoints

---

## 1. Capability View (CV-1) — Capability Overview

| Capability | Description |
|------------|-------------|
| Keystore Management | Upload, list, download, update, and delete keystores in JKS, JCEKS, P12, or PEM format |
| Scope-Aware Resolution | Resolve keystores by name using a three-level hierarchy: subscription → application → account |
| Key Entry Management | Import, list, retrieve, and remove individual key and certificate entries within a keystore |
| Password Storage | Securely store, retrieve, and delete passwords/key-phrases scoped to an application |
| Health Monitoring | Expose a `/api/v1/health` endpoint for liveness and readiness probes |

---

## 2. Architecture Viewpoints

### 2.1 Logical Architecture View

The service is structured using **Hexagonal (Ports & Adapters) Architecture** with **Clean Architecture** layering:

```
┌────────────────────────────────────────────────────────────────┐
│  Driving Adapters (Presentation)                               │
│  HTTP REST Controllers (vibe.d URLRouter)                      │
│    KeystoreController, KeyEntryController, KeyPasswordController│
└──────────────────────────┬─────────────────────────────────────┘
                           │ calls use cases
┌──────────────────────────▼─────────────────────────────────────┐
│  Application Layer                                             │
│  Use Cases: ManageKeystoresUseCase, ManageKeyEntriesUseCase,   │
│             ManageKeyPasswordsUseCase                          │
│  DTOs: UploadKeystoreRequest, CommandResult, …                 │
└──────────────────────────┬─────────────────────────────────────┘
                           │ uses domain ports
┌──────────────────────────▼─────────────────────────────────────┐
│  Domain Layer                                                  │
│  Entities: KeystoreEntity, KeyEntry, KeyPassword               │
│  Value Types / Enums: KeystoreFormat, KeystoreLevel,           │
│                        KeyEntryType                            │
│  Repository Interfaces (Ports): KeystoreRepository,           │
│    KeyEntryRepository, KeyPasswordRepository                   │
│  Domain Service: KeystoreSearchService                         │
└──────────────────────────┬─────────────────────────────────────┘
                           │ implements ports
┌──────────────────────────▼─────────────────────────────────────┐
│  Driven Adapters (Infrastructure)                              │
│  In-Memory Repositories: MemoryKeystoreRepository,            │
│    MemoryKeyEntryRepository, MemoryKeyPasswordRepository       │
│  Config: AppConfig (env-var based)                             │
│  DI Container: buildContainer(AppConfig)                       │
└────────────────────────────────────────────────────────────────┘
```

**Dependency Rule**: dependencies point strictly inward (presentation → application → domain ← infrastructure).

---

### 2.2 System Context View (AV-2)

```
┌─────────────┐      REST / HTTP        ┌────────────────────────┐
│  Client App │ ──────────────────────► │  Keystore Service      │
│  (consumer) │                         │  :8115                 │
└─────────────┘                         └────────────┬───────────┘
                                                      │ in-memory store
                                              ┌───────▼───────┐
                                              │  MemoryRepo   │
                                              │  (volatile)   │
                                              └───────────────┘

External Orchestrators:
┌────────────────┐          ┌─────────────────┐
│  Docker /      │          │  Kubernetes     │
│  Podman        │          │  (k8s manifests)│
└────────────────┘          └─────────────────┘
```

---

### 2.3 Service Interaction View

| Endpoint | HTTP Method | Use Case | Repository |
|----------|-------------|----------|------------|
| `/api/v1/keystores` | POST | `ManageKeystoresUseCase.upload()` | `KeystoreRepository.save()` |
| `/api/v1/keystores` | GET | `ManageKeystoresUseCase.listByAccount()` | `KeystoreRepository.findByAccount()` |
| `/api/v1/keystores/{id}` | GET | `ManageKeystoresUseCase.getById()` | `KeystoreRepository.findById()` |
| `/api/v1/keystores/{id}` | PUT | `ManageKeystoresUseCase.update()` | `KeystoreRepository.update()` |
| `/api/v1/keystores/{id}` | DELETE | `ManageKeystoresUseCase.remove()` | `KeystoreRepository.remove()` |
| `/api/v1/keystores/resolve` | GET | `KeystoreSearchService.findByName()` | multi-level lookup |
| `/api/v1/keystores/{id}/entries` | POST | `ManageKeyEntriesUseCase.importEntry()` | `KeyEntryRepository.save()` |
| `/api/v1/keystores/{id}/entries` | GET | `ManageKeyEntriesUseCase.listByKeystore()` | `KeyEntryRepository.findByKeystore()` |
| `/api/v1/passwords/{alias}` | PUT | `ManageKeyPasswordsUseCase.setPassword()` | `KeyPasswordRepository.save()` |
| `/api/v1/passwords/{alias}` | GET | `ManageKeyPasswordsUseCase.getPassword()` | `KeyPasswordRepository.findByAlias()` |
| `/api/v1/passwords/{alias}` | DELETE | `ManageKeyPasswordsUseCase.deletePassword()` | `KeyPasswordRepository.removeByAlias()` |
| `/api/v1/health` | GET | — | — |

---

### 2.4 Deployment View (NSV-1)

| Component | Technology | Port | Container |
|-----------|-----------|------|-----------|
| Keystore Service | D / vibe.d | 8115 | Docker / Podman / Kubernetes Pod |
| Container runtime | Docker or Podman | — | linux/amd64 |
| Build environment | dlang2/ldc-ubuntu:1.40.1 | — | Multi-stage Dockerfile |
| Base runtime image | ubuntu:24.04 | — | Non-root, read-only filesystem |

---

### 2.5 Security View

| Concern | Implementation |
|---------|----------------|
| Non-root execution | `USER appuser` in container |
| Read-only root FS | `readOnlyRootFilesystem: true` in k8s securityContext |
| Password exposure | Password values are **never returned** via the API — only metadata |
| Input validation | Use cases validate required fields before persisting |
| No SQL injection | In-memory repositories, no raw query strings |
| Transport security | TLS termination handled at ingress/load-balancer level |

---

### 2.6 Keystore Format Standards

| Format | Standard | Integrity | Key Protection |
|--------|----------|-----------|----------------|
| JKS    | Proprietary Java | Password-based | Password-based encryption |
| JCEKS  | Proprietary Java | Password-based | Stronger private-key encryption |
| P12    | PKCS#12 (RFC 7292) | Password-based | Symmetric encryption |
| PEM    | RFC 7468 | None | None (plain entries) |

---

### 2.7 Scope Hierarchy Decision Flow (CV-2)

```
Resolve keystore by name
        │
        ├─► Is subscriptionId provided?
        │         │
        │    YES  ├─► Search at subscription level
        │         │     Found? → return ✓
        │         │     Not found → continue
        │    NO   └─► skip
        │
        ├─► Is applicationId provided?
        │         │
        │    YES  ├─► Search at application level
        │         │     Found? → return ✓
        │         │     Not found → continue
        │    NO   └─► skip
        │
        └─► Search at account level
              Found? → return ✓
              Not found → 404 Not Found
```

---

## 3. Quality Attributes (NFR)

| Attribute | Value / Approach |
|-----------|-----------------|
| Availability | Health probe on `/api/v1/health`; K8s liveness + readiness |
| Scalability | Stateless service; horizontal scaling via K8s replicas |
| Performance | Lightweight vibe.d async runtime; in-memory O(n) operations |
| Portability | Docker, Podman, and Kubernetes manifests included |
| Maintainability | Strict layering (hexagonal); no cross-layer imports |
| Testability | Repository interfaces allow mock substitution |
| Security | Non-root container, read-only FS, no secret leakage via API |
