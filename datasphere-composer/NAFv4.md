# NAFv4 Architecture — Datasphere Data Composer

## 1. Service Overview

| Attribute | Value |
|-----------|-------|
| **Service Name** | Datasphere Data Composer |
| **Binary** | `uim-datasphere-composer-platform-service` |
| **Port** | 8099 |
| **Language** | D (dlang) |
| **Framework** | vibe.d 0.10.x |
| **Architecture Style** | Hexagonal + Clean Architecture |
| **SAP Reference** | SAP BDC — Datasphere Data Composer |
| **Version** | 1.0.0 |

---

## 2. NAFv4 Architecture Views

### 2.1 Capability Architecture View (NCV)

The service exposes the following operational capabilities:

| Capability | Description |
|------------|-------------|
| Data Provider Management | Register and manage data systems (e.g. S/4 HANA Cloud) |
| Data Product Catalog | Manage datasets exposed by each provider |
| Unification Rule Engine | Define deterministic/probabilistic merge rules |
| Data Source Configuration | Per-product quality rank, timestamp, identifier config |
| Attribute Mapping | Source-to-target field transformation pipeline |
| Customer Profile Store | Unified, harmonized profile output |
| Composition Run Orchestration | Pipeline execution tracking (pending/running/done/cancelled) |
| Tenant User Management | Administrator role management per tenant |

---

### 2.2 Service Architecture View (NSoV)

```
┌──────────────────────────────────────────────────┐
│                   UIM Platform                   │
│  ┌────────────────────────────────────────────┐  │
│  │      Datasphere Data Composer Service      │  │
│  │  Port: 8099                                │  │
│  │                                            │  │
│  │  Presentation (HTTP, CLI, Web, GUI)        │  │
│  │  ─────────────────────────────────────     │  │
│  │  Application (Use Cases, DTOs)             │  │
│  │  ─────────────────────────────────────     │  │
│  │  Domain (Entities, Ports, Validators)      │  │
│  │  ─────────────────────────────────────     │  │
│  │  Infrastructure (Repos, DI, Config)        │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

### 2.3 Logical Architecture View (NLV)

#### Domain Layer
- **Entities**: DataProvider, DataProduct, UnificationRule, DataSourceConfig, AttributeMapping, CustomerProfile, CompositionRun, TenantUser
- **Ports**: 8 repository interfaces extending `ITenantRepository`
- **Value Types**: AttributeSchema, TimestampConfig, IdentifierMapping, MappingTransformation
- **Validators**: `ComposerValidator` — static validation per entity

#### Application Layer
- **Use Cases**: `ManageXxxUseCase` — one per aggregate, injected with repository
- **DTOs**: create/update requests per entity

#### Infrastructure Layer
- **Memory Repositories**: `MemoryXxxRepository` extending `TenantRepository!(E, Id)` and implementing domain port
- **Container**: `buildContainer(SrvConfig)` — wires all dependencies
- **Config**: `loadConfig()` reading env vars `DATASPHERE_COMPOSER_HOST`, `DATASPHERE_COMPOSER_PORT`

#### Presentation Layer
- **HTTP**: 9 REST controllers registered on `URLRouter`
- **CLI/Web/GUI**: MVC stubs (controllers, models, views sub-packages)

---

### 2.4 Physical Architecture View (NPV)

#### Container Runtime

| Artifact | Detail |
|----------|--------|
| Dockerfile | Multi-stage: `ldc2:latest` → `ubuntu:24.04` |
| Containerfile | Podman-compatible, identical to Dockerfile |
| Base Image | `ubuntu:24.04` |
| Exposed Port | 8099 |
| Healthcheck | `GET /api/v1/health` |

#### Kubernetes

| Resource | Name |
|----------|------|
| Deployment | `cloud-datasphere-composer` |
| Service | `cloud-datasphere-composer` (ClusterIP, port 8099) |
| ConfigMap | `cloud-datasphere-composer-config` |

---

### 2.5 Data Architecture View (NDAV)

All entities are multi-tenant. Every entity has:
- A typed ID struct (`mixin DomainId`)
- `TenantId tenantId` field
- `string createdAt`, `string updatedAt` timestamps (via `initEntity`)
- `bool deleted` soft-delete flag

Storage backends (configurable via infrastructure):
- **In-memory** (default): All 8 `MemoryXxxRepository` classes
- **File-based**: Planned extension (not implemented)
- **MongoDB**: Planned extension (not implemented)

---

### 2.6 Security View (NSV)

| Concern | Implementation |
|---------|----------------|
| Tenant isolation | `X-Tenant-ID` header mandatory, enforced via `req.getTenantId` |
| Input validation | `ComposerValidator` per entity at use case boundary |
| OWASP alignment | No SQL/NoSQL injection risk (in-memory); no dynamic eval; structured JSON only |
| Auth | External (API Gateway / Identity Authentication Service) |

---

## 3. Interfaces

### External REST API

Base URL: `http://<host>:8099`

All requests: `Content-Type: application/json`, `X-Tenant-ID: <tenantId>`

See [README.md](README.md#api-endpoints) for full endpoint list.

---

## 4. Constraints and Assumptions

- Maximum 10 unification rules per tenant (SAP BDC constraint)
- Customer profiles are read-only from the API; created by composition runs
- In-memory storage does not persist across restarts
- MongoDB and file adapters are planned future extensions
