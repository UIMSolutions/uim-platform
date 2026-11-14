# NAF v4 Architecture Description — Kyma Runtime Service

> NATO Architecture Framework v4 (NAF v4) description of the UIM Platform Kyma
> Runtime service: provisioning of Kyma runtimes and management of namespaces,
> modules, serverless functions, API rules, BTP services, eventing and connected
> applications — exposed through REST, OData v4 (SAP Fiori), a CLI and a desktop GUI.

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
Kyma Runtime
├── C1.1  Runtime Management
│   ├── C1.1.1  Provision runtimes per plan (AWS, Azure, GCP, SAP Converged Cloud, trial, free)
│   ├── C1.1.2  Resize (autoscaler), OIDC configuration, administrators
│   ├── C1.1.3  Stop / start (hibernation)
│   └── C1.1.4  Expiry of trial / free runtimes, cascading deletion
├── C1.2  Namespace Management
│   └── C1.2.1  Namespaces with quotas, labels, annotations, Istio injection
├── C1.3  Module Management
│   ├── C1.3.1  Default modules (istio, api-gateway, btp-operator)
│   ├── C1.3.2  Enable / disable with dependency and usage checks
│   └── C1.3.3  Channels (regular, fast) and versions
├── C1.4  Serverless
│   └── C1.4.1  Node.js 20/22 and Python 3.12 functions, scaling, resources, env vars
├── C1.5  API Exposure
│   └── C1.5.1  API rules (noAuth, JWT, OAuth2 introspection, extAuth), CORS
├── C1.6  Service Consumption
│   ├── C1.6.1  BTP service instances (BTP service operator)
│   └── C1.6.2  Service bindings delivered as secrets
├── C1.7  Eventing
│   └── C1.7.1  Subscriptions (exact / prefix types, sink, filters), pause / resume
├── C1.8  Application Connectivity
│   └── C1.8.1  Register external systems, pair, bind to namespaces
├── C1.9  Reconciliation & Manifests
│   ├── C1.9.1  Lifecycle reconciliation (simulated control plane)
│   └── C1.9.2  Kubernetes custom resources for every workload
└── C1.10 Cross-Cutting
    ├── C1.10.1 Multi-tenancy (XSUAA zone / X-Tenant-Id)
    ├── C1.10.2 Statistics and health
    └── C1.10.3 Four access channels: REST, OData v4 / Fiori, CLI, desktop GUI
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a management service modelled on SAP BTP, Kyma runtime for the UIM platform. |
| **Vision** | Teams extend business systems with Kubernetes-native functions, APIs, services and events in governed runtimes — from the browser (Fiori), the terminal (CLI) or the desktop (GtkD). |
| **Scope** | Runtime, namespace, module, function, API rule, service instance/binding, subscription and application lifecycle; reconciliation; manifest rendering. Not in scope: running real clusters (pluggable via the cluster gateway). |
| **Stakeholders** | Extension developers, platform engineers, cloud architects, operators. |

### C3 – Capability Dependencies

| Capability | Depends on |
|---|---|
| C1.4 Serverless | C1.3 module `serverless` |
| C1.5 API Exposure | C1.3 module `api-gateway` → `istio` |
| C1.6 Service Consumption | C1.3 module `btp-operator` |
| C1.7 Eventing | C1.3 module `eventing` → `nats` |
| C1.8 Application Connectivity | C1.3 module `application-connector` → `istio`, `eventing` |
| C1.2 – C1.8 | C1.1 runtime (workloads progress only on an operational runtime) |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Kyma Runtime Services
├── Resource Management (REST /api/v1 · OData v4 entity sets)
│   ├── Environments · Namespaces · Modules · Applications
│   └── Functions · ApiRules · ServiceInstances · ServiceBindings · EventSubscriptions
├── Lifecycle Operations (REST actions · OData unbound actions)
├── Reconciliation (POST /reconcile · Reconcile action · background worker)
├── Manifests (GET /<resource>/<id>/manifest)
├── Statistics (GET /statistics · Statistics singleton)
└── Catalogue & Health (GET /resources · GET /health · $metadata)
```

### NSOV-2 – Service Definitions

| Service ID | Name | REST | OData v4 | Operations |
|---|---|---|---|---|
| SVC-ENV | Environment | `/api/v1/environments` | `Environments` | CRUD, start, stop, manifest (Kyma CR) |
| SVC-NS | Namespace | `/api/v1/namespaces` | `Namespaces` | CRUD, manifest |
| SVC-FN | Serverless Function | `/api/v1/functions` | `Functions` | CRUD, manifest |
| SVC-AR | API Rule | `/api/v1/api-rules` | `ApiRules` | CRUD, manifest |
| SVC-SI | Service Instance | `/api/v1/service-instances` | `ServiceInstances` | CRUD, manifest |
| SVC-SB | Service Binding | `/api/v1/service-bindings` | `ServiceBindings` | CRUD, manifest |
| SVC-ES | Event Subscription | `/api/v1/event-subscriptions` | `EventSubscriptions` | CRUD, pause, resume, manifest |
| SVC-MOD | Kyma Module | `/api/v1/modules` | `Modules` | enable (create), update, enable, disable, delete |
| SVC-APP | Application | `/api/v1/applications` | `Applications` | CRUD, connect, disconnect, bind, unbind |
| SVC-REC | Reconciliation | `POST /api/v1/reconcile` | `Reconcile` | one pass per tenant |
| SVC-STAT | Statistics | `GET /api/v1/statistics` | `Statistics` | read |
| SVC-CAT | Catalogue | `GET /api/v1/resources` | `$metadata` | read |
| SVC-HLTH | Health | `GET /api/v1/health` | — | read |

### NSOV-3 – Service Interfaces

| Interface | Protocol | Consumer | Notes |
|---|---|---|---|
| REST | HTTP/JSON | scripts, services | `{items, count}` lists, field filters, PATCH semantics, `{error:{code,message}}` |
| OData v4 | HTTP/JSON + CSDL | SAP Fiori / UI5 | `$filter $orderby $select $top $skip $count $search`, no `$batch` (`$direct`) |
| CLI | process | operators, CI | same verbs for all resources, `--json`, exit codes 0/1/2 |
| GUI | GtkD 3 | operators | tabs per resource, forms derived from the specs, auto refresh |
| Cluster gateway | Kubernetes API (port) | — | default adapter records applied manifests |

---

## 4. Operational View (NOV)

### NOV-1 – Concept

```
 Extension developer ──Fiori (browser)──┐
 Platform engineer ────CLI / GUI ───────┤      ┌──────────────────────────────┐
 CI pipeline ──────────REST ────────────┼────▶ │  Kyma Runtime Service        │ ──manifests──▶ Kubernetes API
 Other UIM services ───REST / OData ────┘      │  (reconciler, rules, store)  │                 (pluggable)
                                               └──────────────────────────────┘
```

### NOV-2 – Operational Node Connectivity

| From | To | Information exchanged | Channel |
|---|---|---|---|
| Browser | Approuter | UI, user session | HTTPS, XSUAA login |
| Approuter | Kyma service | OData / REST requests + JWT | HTTPS (destination `kyma-srv`) |
| CLI / GUI | Snapshot files | resource state | local file system |
| Kyma service | Snapshot files | resource state | local file system |
| Kyma service | Cluster gateway | Kubernetes custom resources | port `IClusterGateway` |
| Kyma service | Event publisher | domain events `kyma.<kind>.<verb>` | port `IKymaEventPublisher` |

### NOV-5 – Operational Activities

1. **Provision** a runtime → default modules installing → reconcile → running.
2. **Prepare** a namespace, enable the modules the workloads need.
3. **Deploy** functions, expose them with API rules, provision and bind services, subscribe to events.
4. **Operate**: inspect statistics and manifests, pause subscriptions, stop/start runtimes.
5. **Decommission**: delete namespaces or runtimes (cascading), trial runtimes expire.

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Parent | Key relationships |
|---|---|---|
| `KymaEnvironment` | tenant | root; owns namespaces, modules, applications |
| `KymaNamespace` | environment | scopes functions, API rules, service instances, subscriptions |
| `KymaModule` | environment | `requiredModules` → other modules |
| `KymaApplication` | environment | `boundNamespaces` → namespaces (by name) |
| `ServerlessFunction` | namespace | — |
| `ApiRule` | namespace | `serviceName` → service in the namespace; `rules` (ApiRuleEntry) |
| `ServiceInstance` | namespace | owns service bindings |
| `ServiceBinding` | service instance | secret in the instance's namespace |
| `EventSubscription` | namespace | `source`, `sinkUrl` |

Value objects: `KeyValue`, `ApiRuleEntry`, `AppApiEntry`, `AppEventEntry`, resource quantities.

### NLV-2 – Logical Components

| Layer | Components |
|---|---|
| Domain | entities, enumerations, value types, validators (names, quotas, functions, API rules, subscriptions), environment policy (plans), module catalogue, lifecycle, manifests, exceptions |
| Ports | driving: `IManageResource<…>` ×9, `IReconcileUseCase`, `IKymaStatisticsService`; driven: repositories ×9, `ISnapshotStorage`, `IKymaEventPublisher`, `IClusterGateway` |
| Application | `ResourceUseCase<…>` interactors ×9, `ReconcileUseCase`, `KymaStatisticsService`, `CascadeDeleter`, DTO specs / requests |
| Persistence | repositories, `SnapshotTenantStore`, `JsonFileSnapshotStorage`, `MemorySnapshotStorage`, `RecordMapper<T>`, collections |
| Infrastructure | `KymaConfig`, identity (XSUAA claims), logging, `RecordingClusterGateway`, `ReconcileWorker`, `Container` |
| Presentation | `ResourceRegistry` / `ResourceAdapter<…>`, `KymaRestController`, `KymaODataController`, `KymaCli`, `KymaWindow`, `FrontendController` |

### NLV-6 – State Transitions

| Entity | Transitions (→ by reconciler, ⇒ by user action) |
|---|---|
| Environment | provisioning → running ⇒ stopping → stopped ⇒ updating → running; running ⇒ updating (update) |
| Function | building → deploying → running; any ⇒ building (update) |
| API rule | notReady → ok; any ⇒ notReady (update) |
| Service instance | creating → ready ⇒ updating → ready |
| Service binding | creating → ready (when the instance is ready) |
| Subscription | pending → active ⇒ paused ⇒ pending |
| Module | installing → enabled ⇒ uninstalling → disabled ⇒ installing |
| Application | disconnected ⇒ pairing → connected ⇒ disconnected |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
SAP BTP subaccount — Cloud Foundry space            (mta.yaml: uim-kyma)
├── kyma-approuter   approuter.nodejs, 256M   Fiori app + routes /odata/v4/kyma, /api/v1
├── kyma-srv         binary_buildpack, 256M   uim-kyma-platform-service, health /api/v1/health
├── kyma-xsuaa       xsuaa / application      roles KymaViewer, KymaDeveloper, KymaAdmin
└── kyma-config      user-provided            runtime overrides via VCAP_SERVICES

Workstation
├── uim-kyma-cli     dub --config=cli
├── uim-kyma-gui     dub --config=gui (GTK 3.24)
└── backend/data/*.json   shared snapshot storage
```

### NPV-2 – Configuration

| Setting | Source (lowest → highest) | Default |
|---|---|---|
| host / port | defaults → `config/default.json` → `KYMA_HOST` / `KYMA_PORT`, `PORT` → `VCAP_SERVICES` | 0.0.0.0 / 8095 |
| storage / dataDir | … `KYMA_STORAGE` / `KYMA_DATA_DIR` | file / data |
| reconcile | … `KYMA_RECONCILE_INTERVAL`, `KYMA_RECONCILE_TENANTS` | 10 s / default |
| OData root | … `KYMA_ODATA_PATH` | /odata/v4/kyma |
| frontend | … `KYMA_FRONTEND_DIR` | ../frontend |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

- **Payloads** (REST, OData): entity fields, timestamps ISO 8601 (`Edm.DateTimeOffset`),
  enums by name, labels as `[{key, value}]` (maps and `k=v` accepted on input).
- **Records** (snapshot files): `{ "schemaVersion": 1, "collection": "...", "records": [...] }`,
  timestamps as std time numbers; unknown or missing fields fall back to defaults.
- **Manifests**: `serverless.kyma-project.io/v1alpha2 Function`, `gateway.kyma-project.io/v2 APIRule`,
  `services.cloud.sap.com/v1 ServiceInstance / ServiceBinding`,
  `eventing.kyma-project.io/v1alpha2 Subscription`, `v1 Namespace`, `operator.kyma-project.io/v1beta2 Kyma`.
- **Events**: `kyma.<kind>.<verb>` with tenant, id, name, environment.
- **Secrets**: binding credentials are never stored; only the secret name and credential keys.

### NIV-2 – Business Rules

| ID | Rule | Error |
|---|---|---|
| BR-1 | Names are DNS-1123 labels; hosts are DNS names | 422 |
| BR-2 | Names are unique per parent (tenant / environment / namespace); API rule hosts unique per runtime | 409 |
| BR-3 | Plan limits: node range, regions; trial and free runtimes expire after 14 / 30 days | 422 |
| BR-4 | Workloads require their module to be enabled in the runtime | 409 |
| BR-5 | Modules require their dependencies; modules with dependents or workloads cannot be disabled | 409 |
| BR-6 | CPU / memory requests must not exceed limits | 422 |
| BR-7 | Functions: replicas, fixed scaling, timeout 1–900 s, env var names, dependency format | 422 |
| BR-8 | API rules: ≥ 1 rule, paths start with "/", JWT needs https issuers, CORS needs origins | 422 |
| BR-9 | Service instances with bindings cannot be deleted | 409 |
| BR-10 | Reserved namespaces (`kyma-system`, `kube-system`, …) cannot be created | 422 |
| BR-11 | Deleting a runtime or namespace deletes all contained resources | — |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hexagonal architecture (domain, ports, application, persistence, infrastructure, presentation) | Business rules independent of vibe.d, OData, GTK and storage |
| AD-2 | One generic driving port shape `IManageResource<…>` and a generic interactor base | Nine aggregates with identical CRUD semantics; specific rules live in hooks |
| AD-3 | Protocol-neutral resource registry shared by REST, OData, CLI and GUI | One behaviour, four channels; no duplicated mapping code |
| AD-4 | Compile-time reflection codec for payloads, records, `$metadata`, tables and forms | New fields appear everywhere automatically; PATCH via `decode(patch, base)` |
| AD-5 | Simulated reconciler with explicit lifecycle rules | Kyma-like asynchronous semantics without a real cluster |
| AD-6 | Cluster gateway port with a recording adapter | Real kube-apiserver integration can be added without touching use cases |
| AD-7 | JSON snapshot files with atomic rename and revision checks | Server, CLI and GUI share state with no database; single-writer scale |
| AD-8 | OData v4 without `$batch`, unbound actions with `id` parameter | Simple server, UI5 `$direct` group |
| AD-9 | XSUAA via approuter; backend decodes but does not verify JWTs | Standard BTP setup; direct exposure needs signature verification |
| AD-10 | Port 8095, env prefix `KYMA_` | Consistent with the previous version and platform port allocation |
