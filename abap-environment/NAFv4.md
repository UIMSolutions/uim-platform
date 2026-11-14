# NAF v4 Architecture Description — ABAP Environment Service

> NATO Architecture Framework v4 (NAF v4) description of the UIM Platform ABAP
> Environment service: provisioning of ABAP systems and management of software
> components (gCTS), communication arrangements, service bindings, business roles and
> users, transport requests and application jobs — exposed through REST, OData v4
> (SAP Fiori), a CLI and a desktop GUI.

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
ABAP Environment
├── C1.1  System Management
│   ├── C1.1.1  Provision systems per plan (standard, development, test, production, free)
│   ├── C1.1.2  SAP system ID assignment (derived or given, reserved SIDs rejected)
│   ├── C1.1.3  Resize (ABAP runtime, HANA memory) and software upgrades
│   ├── C1.1.4  Suspend / resume
│   └── C1.1.5  Deprovisioning with cascading deletion
├── C1.2  Software Lifecycle (gCTS)
│   ├── C1.2.1  Register software components (namespaces, repository, branch strategy)
│   ├── C1.2.2  Clone, pull, checkout branch
│   └── C1.2.3  Commit history
├── C1.3  Communication Management
│   ├── C1.3.1  Communication arrangements per scenario and communication system
│   ├── C1.3.2  Authentication: basic, OAuth 2.0 client credentials / SAML bearer, client certificate
│   └── C1.3.3  Inbound and outbound services; activate / deactivate
├── C1.4  Service Exposure
│   ├── C1.4.1  RAP service bindings (OData V4/V2 UI & Web API, SOAP, REST, SQL, RFC)
│   └── C1.4.2  Publish, unpublish, deprecate; derived service and $metadata URLs
├── C1.5  Identity & Access
│   ├── C1.5.1  Business roles (catalogs, restricted / unrestricted access)
│   └── C1.5.2  Business users (lock / unlock, password reset, role assignment)
├── C1.6  Change & Transport Management
│   ├── C1.6.1  Transport requests (workbench, customizing, transport of copies)
│   ├── C1.6.2  Tasks with object lists; release of tasks and requests
│   └── C1.6.3  Import into the target system
├── C1.7  Application Jobs
│   ├── C1.7.1  Schedule (once, hourly, daily, weekly, monthly; cron validation)
│   └── C1.7.2  Run now, cancel, reactivate; execution history
└── C1.8  Cross-Cutting
    ├── C1.8.1  Multi-tenancy (XSUAA zone / X-Tenant-Id)
    ├── C1.8.2  Reconciliation (simulated landscape), statistics and health
    └── C1.8.3  Four access channels: REST, OData v4 / Fiori, CLI, desktop GUI
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a management service modelled on SAP BTP, ABAP environment for the UIM platform. |
| **Vision** | Teams run ABAP Cloud development landscapes — systems, code lines, integrations, services, users, transports and jobs — from the browser (Fiori), the terminal (CLI) or the desktop (GtkD). |
| **Scope** | System, software component, communication, service binding, role, user, transport and job lifecycle; reconciliation; statistics. Not in scope: executing ABAP code or running real systems (pluggable via the landscape gateway). |
| **Stakeholders** | ABAP developers, landscape administrators, integration specialists, identity administrators, operators. |

### C3 – Capability Dependencies

| Capability | Depends on |
|---|---|
| C1.2 – C1.5, C1.7 (create) | C1.1 an **active** system |
| C1.2 clone / pull, C1.7 runs | C1.1 the system is active while the reconciler processes them |
| C1.5.2 role assignment | C1.5.1 roles of the same system |
| C1.6.3 import | C1.6.2 released request; C1.1 an active target system |
| C1.1.5 deprovisioning | removes everything of C1.2 – C1.7 in the system |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
ABAP Environment Services
├── Resource Management (REST /api/v1 · OData v4 entity sets)
│   ├── Systems
│   ├── SoftwareComponents · CommunicationArrangements · ServiceBindings
│   ├── BusinessRoles · BusinessUsers
│   └── TransportRequests · ApplicationJobs
├── Lifecycle Operations (REST actions · OData unbound actions)
├── Reconciliation (POST /reconcile · Reconcile action · background worker)
├── Statistics (GET /statistics · Statistics singleton)
└── Catalogue & Health (GET /resources · GET /health · $metadata)
```

### NSOV-2 – Service Definitions

| Service ID | Name | REST | OData v4 | Operations |
|---|---|---|---|---|
| SVC-SYS | System | `/api/v1/systems` | `Systems` | CRUD (delete = deprovision), suspend, resume, upgrade |
| SVC-SC | Software Component | `/api/v1/software-components` | `SoftwareComponents` | CRUD, clone, pull, checkout |
| SVC-CA | Communication Arrangement | `/api/v1/communication-arrangements` | `CommunicationArrangements` | CRUD, activate, deactivate |
| SVC-SB | Service Binding | `/api/v1/service-bindings` | `ServiceBindings` | CRUD, publish, unpublish, deprecate |
| SVC-BR | Business Role | `/api/v1/business-roles` | `BusinessRoles` | CRUD, add-catalog, remove-catalog |
| SVC-BU | Business User | `/api/v1/business-users` | `BusinessUsers` | CRUD, lock, unlock, reset-password, assign-role, unassign-role |
| SVC-TR | Transport Request | `/api/v1/transports` | `TransportRequests` | CRUD, add-task, release-task, release, import |
| SVC-JOB | Application Job | `/api/v1/application-jobs` | `ApplicationJobs` | CRUD, run, cancel, reactivate |
| SVC-REC | Reconciliation | `POST /api/v1/reconcile` | `Reconcile` | one pass per tenant |
| SVC-STAT | Statistics | `GET /api/v1/statistics` | `Statistics` | read |
| SVC-CAT | Catalogue | `GET /api/v1/resources` | `$metadata` | read |
| SVC-HLTH | Health | `GET /api/v1/health` | — | read |

### NSOV-3 – Service Interfaces

| Interface | Protocol | Consumer | Notes |
|---|---|---|---|
| REST | HTTP/JSON | scripts, services | `{items, count}` lists, field filters, PATCH semantics, system references by id or name, `{error:{code,message}}` |
| OData v4 | HTTP/JSON + CSDL | SAP Fiori / UI5 | `$filter $orderby $select $top $skip $count $search`, no `$batch` (`$direct`) |
| CLI | process | administrators, CI | same verbs for all resources, `--json`, exit codes 0/1/2 |
| GUI | GtkD 3 | administrators | tabs per resource, forms derived from the specs, masked secrets, auto refresh |
| Landscape gateway | port `IAbapLandscapeGateway` | — | provisioning, gCTS head commit, transport import, job runtime; default adapter simulates |
| Event publisher | port `IAbapEventPublisher` | event broker | `abap.<kind>.<verb>`; default adapter logs |

---

## 4. Operational View (NOV)

### NOV-1 – Concept

```
 ABAP developer ───────Fiori (browser)──┐
 Landscape admin ──────CLI / GUI ───────┤      ┌──────────────────────────────┐
 CI / CD pipeline ─────REST ────────────┼────▶ │  ABAP Environment Service    │ ──▶ ABAP landscape
 Other UIM services ───REST / OData ────┘      │  (reconciler, rules, store)  │     (provisioning, gCTS,
                                               └──────────────────────────────┘      transports, jobs — pluggable)
```

### NOV-2 – Operational Node Connectivity

| From | To | Information exchanged | Channel |
|---|---|---|---|
| Browser | Approuter | UI, user session | HTTPS, XSUAA login |
| Approuter | ABAP environment service | OData / REST requests + JWT | HTTPS (destination `abap-environment-srv`) |
| CLI / GUI | Snapshot files | object state | local file system |
| ABAP environment service | Snapshot files | object state | local file system |
| ABAP environment service | Landscape gateway | provisioning, commits, imports, job runs | port `IAbapLandscapeGateway` |
| ABAP environment service | Event publisher | domain events `abap.<kind>.<verb>` | port `IAbapEventPublisher` |

### NOV-5 – Operational Activities

1. **Provision** development and production systems → reconcile → active.
2. **Set up development**: register software components and clone them; create business roles and users.
3. **Integrate**: create communication arrangements; create and publish service bindings.
4. **Transport**: record changes in tasks, release tasks and the request, import into production.
5. **Operate**: schedule application jobs, watch statistics, lock users, suspend/resume or upgrade systems.
6. **Decommission**: delete objects or whole systems (asynchronous, cascading).

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Parent | Key relationships |
|---|---|---|
| `SystemInstance` | tenant | root; owns all other aggregates; unique name and SID |
| `SoftwareComponent` | system | `commitHistory` (ComponentCommit) |
| `CommunicationArrangement` | system | `scenarioId`, `communicationSystem`; inbound / outbound `CommunicationEndpoint`s |
| `ServiceBinding` | system | `serviceDefinition`; `ExposedEndpoint`s |
| `BusinessRole` | system | `businessCatalogs`, `restrictionTypes` |
| `BusinessUser` | system | `roleAssignments` (RoleAssignment) → business roles of the same system |
| `TransportRequest` | source system | `targetSystemId` → system; `tasks` (TransportTask) |
| `ApplicationJob` | system | `parameters` (KeyValue); `executionHistory` (JobExecutionLog) |

Value objects: `KeyValue`, `ComponentCommit`, `CommunicationEndpoint`, `ExposedEndpoint`,
`RoleAssignment`, `TransportTask`, `JobExecutionLog`.

### NLV-2 – Logical Components

| Layer | Components |
|---|---|
| Domain | entities, enumerations, ids and value objects, naming rules (ABAP names, SIDs, users, e-mail), system lifecycle, communication policy, transport policy, job schedule, service URLs, exceptions |
| Ports | driving: `IManageResource<…>` ×8, `IReconcileUseCase`, `IAbapStatisticsService`; driven: repositories ×8, `ISnapshotStorage`, `IAbapEventPublisher`, `IAbapLandscapeGateway` |
| Application | `ResourceUseCase<…>` interactors ×8, `ReconcileUseCase`, `AbapStatisticsService`, `CascadeDeleter`, DTO specs / requests |
| Persistence | `SystemInstanceRepository`, `SystemScopedRepository<…>` ×7, `SnapshotTenantStore`, `JsonFileSnapshotStorage`, `MemorySnapshotStorage`, `RecordMapper<T>`, collections |
| Infrastructure | `AbapConfig`, identity (XSUAA claims), logging, `SimulatedLandscapeGateway`, `ReconcileWorker`, `Container` |
| Presentation | `ResourceRegistry` / `ResourceAdapter<…>`, `AbapRestController`, `AbapODataController`, `AbapCli`, `AbapWindow`, `FrontendController` |

### NLV-6 – State Transitions

| Entity | Transitions (→ by reconciler, ⇒ by user action) |
|---|---|
| System | provisioning → active ⇒ updating (upgrade/resize) → active; active ⇒ suspended ⇒ active; active/suspended/error ⇒ deleting → removed |
| Software component | notCloned ⇒ cloning → cloned ⇒ pulling (pull/checkout) → cloned; cloning/pulling → error ⇒ cloning |
| Communication arrangement | active ⇒ inactive ⇒ active |
| Service binding | unpublished ⇒ published ⇒ deprecated; published/deprecated ⇒ unpublished |
| Business user | active ⇒ locked ⇒ active |
| Transport request | modifiable ⇒ released ⇒ importing → imported \| error ⇒ importing |
| Transport task | modifiable ⇒ released |
| Application job | scheduled → running (due) → completed \| failed \| scheduled (recurring); ⇒ running (run); ⇒ canceled ⇒ scheduled (reactivate) |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
SAP BTP subaccount — Cloud Foundry space                 (mta.yaml: uim-abap-environment)
├── abap-environment-approuter  approuter.nodejs, 256M   Fiori app + routes /odata/v4/abap-environment, /api/v1
├── abap-environment-srv        binary_buildpack, 256M   uim-abap-environment-platform-service, health /api/v1/health
├── abap-environment-xsuaa      xsuaa / application      roles AbapViewer, AbapDeveloper, AbapAdmin
└── abap-config                 user-provided            runtime overrides via VCAP_SERVICES

Workstation
├── uim-abap-cli     dub --config=cli
├── uim-abap-gui     dub --config=gui (GTK 3.24)
└── backend/data/*.json   shared snapshot storage
```

### NPV-2 – Configuration

| Setting | Source (lowest → highest) | Default |
|---|---|---|
| host / port | defaults → `config/default.json` → `ABAP_HOST` / `ABAP_PORT`, `PORT` → `VCAP_SERVICES` | 0.0.0.0 / 10001 |
| storage / dataDir | … `ABAP_STORAGE` / `ABAP_DATA_DIR` | file / data |
| reconcile | … `ABAP_RECONCILE_INTERVAL`, `ABAP_RECONCILE_TENANTS` | 10 s / default |
| OData root | … `ABAP_ODATA_PATH` | /odata/v4/abap-environment |
| frontend | … `ABAP_FRONTEND_DIR` | ../frontend |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

- **Payloads** (REST, OData): entity fields, timestamps ISO 8601 (`Edm.DateTimeOffset`),
  enums by name, key/value lists as `[{key, value}]` (maps and `k=v` accepted on input),
  structured lists (endpoints, tasks, history) as arrays of complex types.
- **Records** (snapshot files): `{ "schemaVersion": 1, "collection": "...", "records": [...] }`,
  timestamps as std time numbers; unknown or missing fields fall back to defaults.
- **Identifiers**: UUIDs; transports additionally carry the number `<SID>K9nnnnn`, tasks `<number>-nn`.
- **Events**: `abap.<kind>.<verb>` with tenant, id, name, system.
- **Secrets**: `communicationPassword` and `clientSecret` are masked on every channel and kept
  when the mask is sent back; they are stored unencrypted in the snapshot files (see AD-10).

### NIV-2 – Business Rules

| ID | Rule | Error |
|---|---|---|
| BR-1 | System names and SIDs are unique per tenant; SID = 3 chars, uppercase letter first, not SAP-reserved | 409 / 422 |
| BR-2 | Sizes are multiples of 16 GB (ABAP 16–1024, HANA 16–4096); free plan: 16 GB ABAP, ≤ 32 GB HANA, one per tenant | 422 / 409 |
| BR-3 | System transitions follow the lifecycle (§5 NLV-6); upgrades need a newer `YYMM` version and an active system | 409 / 422 |
| BR-4 | Components, arrangements, bindings, users, transports and jobs are created in active systems only | 409 |
| BR-5 | ABAP object names: A–Z, 0–9, `_`, optional `/NAMESPACE/`, length limits; component names match their namespace | 422 |
| BR-6 | Names are unique per system (components, arrangements, bindings, roles, users, jobs); user e-mails unique per system | 409 |
| BR-7 | A component's repository is fixed after the first clone; busy components cannot change or be deleted | 409 |
| BR-8 | Arrangements: scenario `SAP_COM_nnnn` or `Z…`/`Y…`; credentials per auth method; inbound needs authentication; one arrangement per scenario and communication system | 422 / 409 |
| BR-9 | Published bindings cannot be deleted; type and definition change only while unpublished | 409 |
| BR-10 | Restricted roles need restriction types, unrestricted roles have none; assigned roles cannot be deleted | 422 / 409 |
| BR-11 | Transports: target ≠ source; tasks hold `R3TR`/`LIMU` objects; tasks must be released (and non-empty) before the request; only modifiable requests change or delete; import needs a released request | 422 / 409 |
| BR-12 | Jobs: template is an ABAP name; cron has 5 valid fields; parameter names unique; running jobs cannot change or be deleted | 422 / 409 |
| BR-13 | Deleting a system deletes all contained objects; pending imports into it fail | — |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hexagonal architecture (domain, ports, application, persistence, infrastructure, presentation) | Business rules independent of vibe.d, OData, GTK and storage |
| AD-2 | One generic driving port shape `IManageResource<…>` and a generic interactor base with `build / apply / beforeRemove / retire` hooks | Eight aggregates with identical CRUD semantics; specific rules live in hooks; soft delete for systems |
| AD-3 | Protocol-neutral resource registry shared by REST, OData, CLI and GUI | One behaviour, four channels; no duplicated mapping code (replaces 4 × 8 hand-written controllers, views and models) |
| AD-4 | Compile-time reflection codec for payloads, records, `$metadata`, tables and forms | New fields appear everywhere automatically; PATCH via `decode(patch, base)`; replaces hand-written `toJson` and enum converters |
| AD-5 | Reconciler with explicit lifecycle rules | ABAP-environment-like asynchronous semantics (provisioning, clone, import, job runs) |
| AD-6 | Landscape gateway port with a simulating adapter | Real provisioning, gCTS and job APIs can be added without touching use cases |
| AD-7 | JSON snapshot files with atomic rename and revision checks | Server, CLI and GUI share state with no database; single-writer scale |
| AD-8 | OData v4 without `$batch`, unbound actions `<Action><Type>` with `id` parameter | Simple server, UI5 `$direct` group |
| AD-9 | XSUAA via approuter; backend decodes but does not verify JWTs | Standard BTP setup; direct exposure needs signature verification |
| AD-10 | Secrets masked in adapters, stored in snapshots | Prevents disclosure through APIs and UIs; production use should move secrets to the credential store |
| AD-11 | Port 10001, env prefix `ABAP_`, REST resource paths unchanged | Compatibility with the previous version and platform port allocation |
