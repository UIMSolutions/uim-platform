# NAFv4 Architecture Description — Feature Flags Service

## 1. Overview

| Attribute | Value |
|---|---|
| **Service Name** | UIM Platform Feature Flags Service |
| **Version** | 1.0.0 |
| **NAF Version** | NATO Architecture Framework v4 (NAFv4) |
| **SAP BTP Equivalent** | SAP Feature Flags Service |
| **Technology** | D Language, vibe.d, Hexagonal Architecture |
| **Port** | 8097 |
| **License** | Apache-2.0 |

---

## 2. C1 — Capability View

### Strategic Capability: Feature Toggle Management

This service provides the capability to **decouple feature delivery from code deployment** by managing feature flags across applications bound to SAP BTP-compatible service instances.

| Capability | Description |
|---|---|
| Flag Lifecycle Management | Create, update, enable, disable, archive and delete flags |
| Variant Management | Define multiple named variants per flag with weighted values |
| Targeted Delivery | Apply targeting rules (user, tenant, rollout %, attributes) to serve variants |
| SDK Evaluation | REST API for real-time flag evaluation with context (userId, tenantId, custom attributes) |
| Audit Logging | Immutable, append-only audit trail for all management operations |
| Multi-tenant Isolation | All data is scoped by tenantId |
| Multi-backend Storage | In-memory, file-based, and MongoDB persistence adapters |

---

## 3. C2 — Service / Node View

```
┌─────────────────────────────────────────────────────────────────────┐
│  UIM Platform Kubernetes Cluster                                      │
│                                                                       │
│  ┌──────────────────────────────────┐                                 │
│  │  cloud-feature-flags (Pod)        │                                 │
│  │  image: uim-feature-flags-        │   ◄── ClusterIP :8097           │
│  │         platform-service:latest   │                                 │
│  │                                   │                                 │
│  │  ConfigMap: feature-flags-config  │                                 │
│  │  Volume: /data/feature-flags      │                                 │
│  └──────────────┬────────────────────┘                                 │
│                 │                                                       │
│        ┌────────▼────────┐                                             │
│        │  Storage Backend │                                             │
│        │  MEMORY / FILE / │                                             │
│        │  MONGODB         │                                             │
│        └──────────────────┘                                             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 4. C3 — System / Data View

### Data Entities

| Entity | Key Fields | Cardinality |
|---|---|---|
| `ServiceInstance` | id, tenantId, name, bindingGuid | 1..n per tenant |
| `FeatureFlag` | id, tenantId, instanceId, name, type, state, variants, rules | 1..n per instance |
| `FlagVariant` | id, key, value, weight | 1..n per flag |
| `TargetingRule` | id, type, priority, variantKey | 0..n per flag |
| `AuditEntry` | id, tenantId, action, entityId, performedBy, performedAt | append-only |

### Data Flow

```
Client SDK
    │
    ▼
REST API (vibe.d HTTPServerRequest)
    │
    ├── Management flow ──► ManageFeatureFlagsUseCase ──► FeatureFlagRepository
    │                                                          ├── MemoryRepo
    │                                                          ├── FileRepo
    │                                                          └── MongoRepo
    │
    └── Evaluation flow ──► EvaluateFlagsUseCase ──► FlagEvaluator (pure domain)
                                │                         │
                                │                         ▼
                                │                  EvaluationResult
                                │
                                └── FeatureFlagRepository (read-only)
```

---

## 5. C4 — Operational Architecture

### Deployment Topology

| Component | Runtime | Port | Health |
|---|---|---|---|
| Feature Flags Service | Docker / Podman / Kubernetes | 8097 | `GET /api/v1/health` |
| MongoDB (optional) | External or sidecar | 27017 | — |

### Container Image Build

| Stage | Base Image | Action |
|---|---|---|
| builder | `dlang2/ldc-ubuntu:1.40.1` | `dub build --build=release --config=defaultRun` |
| runtime | `ubuntu:24.04` | Copy binary, run as non-root `appuser` |

### Resource Limits (Kubernetes)

| Resource | Request | Limit |
|---|---|---|
| Memory | 64 Mi | 256 Mi |
| CPU | 50 m | 500 m |

### Security Controls

- Runs as non-root user (`appuser`, UID 1000)
- `allowPrivilegeEscalation: false`
- `readOnlyRootFilesystem: true`
- All Linux capabilities dropped
- No secrets in images or ConfigMaps (connection strings via env vars)
- Input validated at controller boundary before reaching domain

---

## 6. C5 — Information Assurance View

| Control | Implementation |
|---|---|
| Input validation | All JSON fields validated before use-case invocation |
| Tenant isolation | All repository queries require `tenantId` scope |
| Audit trail | Every create/update/delete writes an immutable `AuditEntry` |
| No credential storage | MongoDB URI via env var only, not in code |
| Non-destructive archive | `ARCHIVED` state prevents modification without deletion |
| CRC-32 percentage hashing | Stable, deterministic rollout hashing (no random drift) |

---

## 7. L1 — Lines of Development

| Layer | Module | Responsibility |
|---|---|---|
| Domain | `domain/entities/` | Pure business types — no framework dependencies |
| Domain | `domain/ports/repositories/` | Outbound port interfaces |
| Domain | `domain/services/flag_evaluator.d` | Pure evaluation algorithm |
| Application | `application/dto.d` | Input data transfer objects |
| Application | `application/usecases/manage/` | Orchestration use cases |
| Presentation | `presentation/http/controllers/` | HTTP MVC controllers |
| Presentation | `presentation/web/views/` | Web MVC view models |
| Presentation | `presentation/cli/commands/` | CLI MVC commands |
| Presentation | `presentation/gui/widgets/` | GUI MVC widget view models |
| Infrastructure | `infrastructure/config.d` | Environment variable loading |
| Infrastructure | `infrastructure/container.d` | Dependency injection wiring |
| Infrastructure | `infrastructure/persistence/memory/` | In-memory adapters |
| Infrastructure | `infrastructure/persistence/file_/` | File-based adapters |
| Infrastructure | `infrastructure/persistence/mongodb_/` | MongoDB adapters (stub + fallback) |

---

## 8. Alignment with SAP BTP Feature Flags Service

| SAP Concept | This Service |
|---|---|
| Service Instance | `ServiceInstance` entity |
| Feature Flag | `FeatureFlag` entity with `FlagType`, `FlagState` |
| Variant / Strategy | `FlagVariant` |
| Evaluation Rules | `TargetingRule` (user, tenant, rollout, attribute) |
| Evaluation API | `GET /api/v1/feature-flags/evaluate/:flagName` |
| Bulk Evaluation | `GET /api/v1/feature-flags/evaluate` |
| Management API | CRUD on `/api/v1/feature-flags/flags` |
| Service Binding | `ServiceInstance.bindingGuid` |
| Audit Log | `AuditEntry` repository |
| Flag States | `ENABLED`, `DISABLED`, `ARCHIVED` |
| Flag Types | `BOOLEAN`, `STRING`, `JSON`, `NUMBER` |
