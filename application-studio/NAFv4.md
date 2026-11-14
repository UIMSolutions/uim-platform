# NAF v4 Architecture Description — Application Studio Service

> NATO Architecture Framework v4 (NAF v4) description of the UIM Platform
> Application Studio service: a cloud development environment modelled on SAP
> Business Application Studio — catalogue of dev space types, extensions and project
> templates; dev spaces with projects, service bindings, run configurations and
> build-and-deploy configurations — exposed through REST, OData v4 (SAP Fiori), a CLI
> and a desktop GUI.

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

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Application Studio
├── C1.1  Catalogue
│   ├── C1.1.1  Dev space types (predefined SAP types, custom types)
│   ├── C1.1.2  Extensions (versions, dependencies, activate / deactivate / deprecate)
│   ├── C1.1.3  Project templates (generators, required extensions, scaffold files)
│   └── C1.1.4  Install the predefined SAP catalogue (idempotent)
├── C1.2  Dev Space Management
│   ├── C1.2.1  Create with type, plan, sizes and additional extensions
│   ├── C1.2.2  Start / stop / resume on access
│   ├── C1.2.3  Hibernation after inactivity
│   ├── C1.2.4  Change extensions and sizes (stopped)
│   └── C1.2.5  Asynchronous deletion with cascade
├── C1.3  Project Management
│   ├── C1.3.1  Generate from templates (type and extension checks)
│   ├── C1.3.2  Git repository, branch, namespace
│   └── C1.3.3  Archive / restore, deletion with cascade
├── C1.4  Service Bindings
│   ├── C1.4.1  BTP destinations, S/4HANA, SuccessFactors, OData, REST
│   └── C1.4.2  Connection test (connect / disconnect)
├── C1.5  Run & Debug
│   ├── C1.5.1  Run, debug, test, preview configurations
│   └── C1.5.2  Start / stop with port and binding checks, preview URLs
├── C1.6  Build & Deploy
│   ├── C1.6.1  Build (mbt, npm, maven, …) with artifact derivation
│   ├── C1.6.2  Deploy to Cloud Foundry, Kyma, ABAP, HTML5 repository, Docker
│   └── C1.6.3  Run history, cancel, project status
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation (XSUAA zone / X-Tenant-Id)
    ├── C1.7.2  Reconciliation (background worker)
    ├── C1.7.3  Statistics
    └── C1.7.4  Domain events, health
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a development-environment management service modelled on SAP Business Application Studio for the UIM platform. |
| **Vision** | Developers and administrators run SAP-style dev spaces — tools, projects, connections, launches, builds and deployments — from the browser (Fiori), the terminal (CLI) or the desktop (GtkD). |
| **Scope** | Catalogue, dev space, project, binding, run and build lifecycle; plan limits; reconciliation; statistics. Not in scope: hosting a real IDE or containers, executing builds (pluggable via the workspace gateway). |
| **Stakeholders** | Application developers, catalogue / platform administrators, operators, CI/CD pipelines. |

### C3 – Capability Dependencies

| Capability | Depends on |
|---|---|
| C1.2.1 create dev space | C1.1.1 an existing type; C1.1.2 active extensions (+ dependencies); plan capacity |
| C1.3.1 generate project | C1.2 a **running** dev space; C1.1.3 template whose extensions the dev space has; type supports the project type |
| C1.4.2 connect | C1.2 a running dev space |
| C1.5.2 start run | C1.3 a non-archived project; C1.2 running dev space; C1.4 connected bindings; free ports |
| C1.6.1 build / C1.6.2 deploy | C1.3 a non-archived project; C1.2 running dev space; deploy needs a successful build |
| C1.2.5 delete dev space | removes everything of C1.3 – C1.6 in the dev space |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Application Studio Services
├── Resource Management (REST /api/v1 · OData v4 entity sets)
│   ├── DevSpaceTypes · Extensions · ProjectTemplates      (catalogue)
│   ├── DevSpaces
│   ├── Projects · ServiceBindings                          (per dev space)
│   └── RunConfigurations · BuildConfigurations             (per project)
├── Lifecycle Operations (REST actions · OData unbound actions)
├── Catalogue Seeding (POST /catalog/seed · SeedCatalog action · on server start)
├── Reconciliation (POST /reconcile · Reconcile action · background worker)
├── Statistics (GET /statistics · Statistics singleton)
└── Catalogue & Health (GET /resources · GET /health · $metadata)
```

### NSOV-2 – Service Definitions

| Service ID | Name | REST | OData v4 | Operations |
|---|---|---|---|---|
| SVC-DST | Dev Space Type | `/api/v1/dev-space-types` | `DevSpaceTypes` | CRUD (predefined read-only) |
| SVC-EXT | Extension | `/api/v1/extensions` | `Extensions` | CRUD, activate, deactivate, deprecate |
| SVC-TPL | Project Template | `/api/v1/project-templates` | `ProjectTemplates` | CRUD |
| SVC-DS | Dev Space | `/api/v1/dev-spaces` | `DevSpaces` | CRUD (delete = asynchronous), start, stop, touch, add-extension, remove-extension |
| SVC-PRJ | Project | `/api/v1/projects` | `Projects` | CRUD (cascade), archive, restore |
| SVC-SB | Service Binding | `/api/v1/service-bindings` | `ServiceBindings` | CRUD, connect, disconnect |
| SVC-RUN | Run Configuration | `/api/v1/run-configurations` | `RunConfigurations` | CRUD, start, stop |
| SVC-BLD | Build Configuration | `/api/v1/build-configurations` | `BuildConfigurations` | CRUD, build, deploy, cancel |
| SVC-SEED | Catalogue Seeding | `POST /api/v1/catalog/seed` | `SeedCatalog` | install predefined catalogue |
| SVC-REC | Reconciliation | `POST /api/v1/reconcile` | `Reconcile` | one pass per tenant |
| SVC-STAT | Statistics | `GET /api/v1/statistics` | `Statistics` | read |
| SVC-CAT | Resource catalogue | `GET /api/v1/resources` | `$metadata` | read |
| SVC-HLTH | Health | `GET /api/v1/health` | — | read |

### NSOV-3 – Service Interfaces

| Interface | Protocol | Consumer | Notes |
|---|---|---|---|
| REST | HTTP/JSON | scripts, services, CI | `{items, count}` lists, field filters, PATCH semantics, ids or unique names in paths and references, `{error:{code,message}}`; legacy prefix `/api/v1/application-studio` |
| OData v4 | HTTP/JSON + CSDL | SAP Fiori / UI5 | `$filter $orderby $select $top $skip $count $search`, no `$batch` (`$direct`) |
| CLI | process | developers, administrators, CI | same verbs for all resources, `--json`, exit codes 0/1/2 |
| GUI | GtkD 3 | developers, administrators | tabs per resource, forms derived from the specs, masked secrets, auto refresh |
| Workspace gateway | port `IWorkspaceGateway` | — | dev space runtime, process runner, build service, deployers, connectivity check; default adapter simulates |
| Event publisher | port `IStudioEventPublisher` | event broker | `studio.<kind>.<verb>`; default adapter logs |

---

## 4. Operational View (NOV)

### NOV-1 – Concept

```
 Developer ─────────────Fiori (browser)──┐
 Platform admin ────────CLI / GUI ───────┤      ┌──────────────────────────────┐
 CI / CD pipeline ──────REST ────────────┼────▶ │  Application Studio Service  │ ──▶ Workspace runtime
 Other UIM services ────REST / OData ────┘      │  (reconciler, rules, store)  │     (containers, builds,
                                                └──────────────────────────────┘      deployers — pluggable)
```

### NOV-2 – Operational Node Connectivity

| From | To | Information exchanged | Channel |
|---|---|---|---|
| Browser | Approuter | UI, user session | HTTPS, XSUAA login |
| Approuter | Application Studio service | OData / REST requests + JWT | HTTPS (destination `application-studio-srv`) |
| CLI / GUI | Snapshot files | object state | local file system |
| Application Studio service | Snapshot files | object state | local file system |
| Application Studio service | Workspace gateway | start/stop/hibernate/delete, connection tests, runs, builds, deployments | port `IWorkspaceGateway` |
| Application Studio service | Event publisher | domain events `studio.<kind>.<verb>` | port `IStudioEventPublisher` |

### NOV-5 – Operational Activities

1. **Prepare the catalogue**: install the SAP catalogue; add custom extensions, types and templates.
2. **Create a dev space** of a type and plan → reconcile → running.
3. **Generate projects** from templates; set git repository and namespace.
4. **Connect services**: create bindings to destinations or systems and connect them.
5. **Run & debug**: create run configurations and start them; open preview URLs.
6. **Build & deploy**: create build configurations, build, deploy; watch history and statistics.
7. **Operate**: stop dev spaces, let idle ones hibernate, resume on access, change extensions while stopped.
8. **Decommission**: archive or delete projects; delete dev spaces (asynchronous, cascading).

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Parent | Key relationships |
|---|---|---|
| DevSpaceType | tenant | `predefinedExtensions` → Extension names; `supportedProjectTypes` |
| Extension | tenant | `dependencies` → Extension names |
| ProjectTemplate | tenant | `requiredExtensions` → Extension names; `parameters` (KeyValue) |
| DevSpace | tenant | `devSpaceTypeId` → DevSpaceType; `extensions` → Extension names |
| Project | DevSpace | `devSpaceId`; `templateId` → ProjectTemplate |
| ServiceBinding | DevSpace | `devSpaceId` |
| RunConfiguration | Project | `projectId`, `devSpaceId`; `serviceBindings` → ServiceBinding names; `environment` (KeyValue) |
| BuildConfiguration | Project | `projectId`, `devSpaceId`; `history` (BuildRun) |

### NLV-2 – Logical Components

| Component | Layer | Responsibility |
|---|---|---|
| Entities, enumerations, value objects | domain | state of the eight aggregates |
| Names, plan policy, dev space lifecycle, extension resolution, run policy, build policy | domain services | business rules without I/O |
| `ResourceUseCase` + 8 interactors | application | validation, uniqueness, references, actions |
| `ReconcileUseCase` | application | asynchronous transitions |
| `StudioCatalogService` · `StudioStatisticsService` · `CascadeDeleter` · `ProjectStatusSync` | application services | catalogue, figures, cascades, project status |
| Repositories, `RecordMapper`, `SnapshotTenantStore`, `JsonFileSnapshotStorage` | persistence | tenant-scoped storage, JSON snapshots |
| `StudioConfig`, identity, `ReconcileWorker`, `SimulatedWorkspaceGateway`, `LogEventPublisher`, `Container` | infrastructure | configuration, security, background work, wiring |
| `ResourceRegistry` + REST, OData, CLI, GUI, web | presentation | protocol adapters |

### NLV-6 – State Transitions

| Entity | Transitions (→ by reconciler, ⇒ by user action) |
|---|---|
| Dev space | ⇒ starting (create/start) → running \| error; running ⇒ stopping → stopped; running → hibernating (idle) → hibernated ⇒ resuming (start/touch) → running; stopped/hibernated/error ⇒ deleting → removed |
| Project | active ⇒ archived ⇒ active; active → building / deploying / error (mirrors build configurations) |
| Service binding | disconnected ⇒ connecting → connected \| error; connected/error ⇒ disconnected (also on changed settings) |
| Run configuration | idle/stopped/error ⇒ starting → running \| error; running ⇒ stopped (also when the dev space stops or hibernates) |
| Build configuration | ⇒ building → succeeded \| failed; succeeded/deployed ⇒ deploying → deployed \| failed; building/deploying ⇒ cancelled |
| Extension | active ⇒ inactive ⇒ active; active/inactive ⇒ deprecated ⇒ active |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
SAP BTP subaccount — Cloud Foundry space                     (mta.yaml: uim-application-studio)
├── application-studio-approuter  approuter.nodejs, 256M    Fiori app + routes /odata/v4/application-studio, /api/v1
├── application-studio-srv        binary_buildpack, 256M    uim-application-studio-platform-service, health /api/v1/health
├── application-studio-xsuaa      xsuaa / application       roles StudioViewer, StudioDeveloper, StudioAdmin
└── application-studio-config     user-provided             runtime overrides via VCAP_SERVICES

Kubernetes — namespace uim-platform                          (k8s/)
├── ConfigMap application-studio-config                      APPLICATION_STUDIO_* settings
├── Deployment application-studio                            image uim-platform/application-studio, :8111, /data volume
└── Service application-studio                               ClusterIP :8111

Workstation
├── uim-studio-cli     dub --config=cli
├── uim-studio-gui     dub --config=gui (GTK 3.24)
└── backend/data/*.json   shared snapshot storage
```

### NPV-2 – Configuration

| Setting | Source (lowest → highest) | Default |
|---|---|---|
| host / port | defaults → `config/default.json` → `APPLICATION_STUDIO_HOST` / `APPLICATION_STUDIO_PORT`, `PORT` → `VCAP_SERVICES` | 0.0.0.0 / 8111 |
| storage / dataDir | … `APPLICATION_STUDIO_STORAGE` / `APPLICATION_STUDIO_DATA_DIR` | file / data |
| reconcile | … `APPLICATION_STUDIO_RECONCILE_INTERVAL`, `APPLICATION_STUDIO_RECONCILE_TENANTS` | 10 s / default |
| catalogue | … `APPLICATION_STUDIO_SEED_CATALOG` | true |
| OData root | … `APPLICATION_STUDIO_ODATA_PATH` | /odata/v4/application-studio |
| frontend | … `APPLICATION_STUDIO_FRONTEND_DIR` | ../frontend |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

- **Payloads** (REST, OData): entity fields, timestamps ISO 8601 (`Edm.DateTimeOffset`),
  enums by name, lists as arrays (comma separated strings accepted on input), key/value
  lists as `[{key, value}]` (maps and `k=v` accepted), build history as an array of
  `BuildRun` complex types.
- **Records** (snapshot files): `{ "schemaVersion": 1, "collection": "...", "records": [...] }`,
  timestamps as std time numbers; unknown or missing fields fall back to defaults.
- **Identifiers**: UUIDs; catalogue entries, dev spaces, projects, bindings and
  configurations are also addressable by their (scoped) unique name.
- **Derived data**: project `rootPath`, scaffolded `files`, type names on dev spaces, parent
  names on children, build artifact paths and deploy commands, workspace and preview URLs.
- **Events**: `studio.<kind>.<verb>` with tenant, id, name, dev space.
- **Secrets**: service binding `credentials` are masked on every channel and kept when the
  mask is sent back; they are stored unencrypted in the snapshot files (see AD-10).

### NIV-2 – Business Rules

| ID | Rule | Error |
|---|---|---|
| BR-1 | Catalogue names are unique per tenant; extension and template names are lowercase `publisher.package`; versions are semantic versions | 409 / 422 |
| BR-2 | Predefined dev space types and extensions cannot be changed or deleted; API-created entries cannot use the predefined category/scope | 409 / 422 |
| BR-3 | Referenced extensions (types, templates, dependencies, dev spaces) must exist; new dev spaces only get active extensions; dependencies are added automatically | 404 / 409 |
| BR-4 | Catalogue entries in use (types by dev spaces; extensions by dev spaces, types, templates, dependents; templates by projects) cannot be deleted | 409 |
| BR-5 | Dev space names: letter first, letters, digits, `_`, ≤ 40, unique per tenant; owner e-mail required | 422 / 409 |
| BR-6 | Plan limits: count and running dev spaces per tenant and plan; memory (multiple of 512 MB), disk and hibernation delay per plan; free dev spaces always hibernate | 409 / 422 |
| BR-7 | Dev space transitions follow the lifecycle (§5 NLV-6); extensions and sizes change only while not running; deletion only when stopped, hibernated or failed | 409 |
| BR-8 | Projects are created in running dev spaces; name lowercase, unique per dev space; template type, required extensions and supported project types must match | 409 / 422 |
| BR-9 | Removing an extension that a project's template needs, or that another installed extension depends on, is rejected | 409 |
| BR-10 | Bindings need a URL or destination; OData providers need a path; basic / OAuth need user and secret; bindings used by run configurations cannot be deleted | 422 / 409 |
| BR-11 | Runs: entry point; ports 1024–65535; debug mode with a distinct debug port; unique valid environment names; bindings connected; ports free in the dev space; live runs cannot change or be deleted | 422 / 409 |
| BR-12 | Builds: build command; Cloud Foundry needs an MTA descriptor; HTML5 repository / ABAP only for UI projects; deploy needs a successful build; busy configurations cannot change or be deleted; 20 runs kept | 422 / 409 |
| BR-13 | Archived projects cannot be changed, run or built; projects with live runs or busy builds cannot be archived or deleted | 409 |
| BR-14 | Deleting a dev space deletes its projects, bindings and configurations; deleting a project deletes its configurations; stopping or hibernating a dev space ends its runs | — |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hexagonal architecture (domain, ports, application, persistence, infrastructure, presentation) | Business rules independent of vibe.d, OData, GTK and storage |
| AD-2 | One generic driving port shape `IManageResource<…>` and a generic interactor base with `build / apply / beforeRemove / retire / afterRemove` hooks | Eight aggregates with identical CRUD semantics; specific rules in hooks; soft delete for dev spaces, cascades for projects |
| AD-3 | Protocol-neutral resource registry shared by REST, OData, CLI and GUI | One behaviour, four channels; replaces eight hand-written controllers |
| AD-4 | Compile-time reflection codec for payloads, records, `$metadata`, tables and forms | New fields appear everywhere automatically; PATCH via `decode(patch, base)`; replaces hand-written `toJson` and enum converters |
| AD-5 | Reconciler with explicit lifecycle rules | BAS-like asynchronous semantics (dev space start, hibernation, connection tests, runs, builds, deployments) |
| AD-6 | Workspace gateway port with a simulating adapter | A real container runtime, build service and deployers can be added without touching use cases |
| AD-7 | JSON snapshot files with atomic rename and revision checks | Server, CLI and GUI share state with no database; single-writer scale |
| AD-8 | OData v4 without `$batch`, unbound actions `<Action><Type>` with `id` parameter | Simple server, UI5 `$direct` group |
| AD-9 | XSUAA via approuter; backend decodes but does not verify JWTs | Standard BTP setup; direct exposure needs signature verification |
| AD-10 | Secrets masked in adapters, stored in snapshots | Prevents disclosure through APIs and UIs; production use should move secrets to the credential store |
| AD-11 | Predefined SAP catalogue as idempotent seed, references by name | Ready-to-use dev space types and templates; names survive re-seeding and are readable in CLI/REST |
| AD-12 | Port 8111, env prefix `APPLICATION_STUDIO_`, legacy REST prefix kept | Compatibility with the previous version and the platform port allocation |
