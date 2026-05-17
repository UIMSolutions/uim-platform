# NAF v4 Architecture Description — Service Library (uim-platform-service)

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Service Library — the shared hexagonal-architecture scaffolding, interfaces,
> mixins, and base entities used by every UIM Platform HTTP service.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Reusable Libraries | §3 |
| **NOV** – NATO Operational View | NOV-2 Dependency Graph | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Build Artefact | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Service Library
├── C1.1  Entity Scaffolding
│   ├── C1.1.1  Strong-typed Id wrappers
│   ├── C1.1.2  Tenant-aware base entities
│   └── C1.1.3  Resource base entity
│
├── C1.2  Repository Scaffolding
│   ├── C1.2.1  IRepository generic interface
│   └── C1.2.2  In-memory CRUD mixin (RepositoryMixin)
│
├── C1.3  Application Layer Helpers
│   ├── C1.3.1  CommandResult / QueryResult DTOs
│   ├── C1.3.2  IdUseCase base
│   └── C1.3.3  TenantUseCase base
│
├── C1.4  Presentation Layer Bootstrap
│   ├── C1.4.1  vibe.d server lifecycle (ServiceMixin)
│   └── C1.4.2  Env-based configuration (ConfigMixin)
│
└── C1.5  Cross-Cutting Interfaces
    ├── C1.5.1  IEntity / ITenantEntity
    ├── C1.5.2  IService / IConfig / IStore
    └── C1.5.3  Domain / validation / auth exceptions
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a reusable D-language library that enforces consistent hexagonal architecture across all 54 UIM Platform services. |
| **Vision** | Eliminate boilerplate in individual services by centralising interfaces, mixins, and base types so each service focuses only on its domain logic. |
| **Scope** | Interfaces (IEntity, IRepository, IService, IConfig, IStore), entity mixins, application DTOs, use-case bases, and vibe.d server bootstrap. |
| **Stakeholders** | Platform Architects, Service Developers. |

---

## 3. Service View (NSV)

> This is a **library** — it exposes no HTTP endpoints.

| Module | Path | Purpose |
|---|---|---|
| Interfaces | `interfaces/` | IEntity, IRepository, IService, IConfig, IStore, ITenantEntity |
| Mixins | `mixins/` | ObjMixin, DomainMixin, RepositoryMixin, StoreMixin, ServiceMixin, ConfigMixin |
| Entity bases | `mixins/entities/` | GlobalEntity, IdEntity, ResourceEntity |
| Application | `application/` | CommandResult, QueryResult, IdUseCase, TenantUseCase |
| Exceptions | `exceptions/` | UIMException, ValidationException, AuthorizationException, ConfigException |
| Tests | `tests/` | Shared test helpers |

---

## 4. Operational View (NOV)

```
┌──────────────────────────────────────┐
│  Any UIM Platform Service (×54)      │
│  dub.sdl dependency: uim-service     │
└──────────┬───────────────────────────┘
           │ static link / import
           ▼
┌──────────────────────────────────────┐
│  uim-platform-service library        │
│  libuim-platform-service.a           │
└──────────────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Concept | Description |
|---|---|
| `IEntity` | Base interface: id + toJson() |
| `ITenantEntity` | Extends IEntity with tenantId |
| `IRepository~T~` | Generic CRUD interface |
| `IService` | Server start/stop lifecycle |
| `IConfig` | host / port configuration contract |
| `CommandResult` | success flag + id + errorMessage |
| `TenantUseCase` | Filter operations by tenantId |

---

## 6. Physical View (NPV)

```
Build artefact
├── libuim-platform-service.a   (D static library)
├── libuim-sap-service.a        (SAP-extended static library)
└── libuim-service.a            (alias entry)

dub.sdl consumers add:
  dependency "uim-service" version="*"
  subPackage "../service"
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Static D library | Zero runtime overhead; compile-time mixin expansion |
| AD-2 | Mixin-based scaffolding | Single source of truth for CRUD boilerplate |
| AD-3 | In-memory repository mixin | Enables test-first development per service |
| AD-4 | Strong-typed Id wrappers | Prevents id confusion across aggregate roots |
| AD-5 | Shared CommandResult / QueryResult DTOs | Uniform application layer API surface |
