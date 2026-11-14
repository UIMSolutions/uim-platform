# NAF v4 Architecture Description — Service Manager

> This is the NATO Architecture Framework v4 description of the UIM Platform Service Manager 2.0.
> The service is modelled on SAP BTP Service Manager. It provides a registry of platforms and Open
> Service Broker (OSB) compatible brokers, a synchronized service catalog, provisioning of service
> instances and bindings with operation tracking, and labels. It is accessible through OData v4
> (SAP Fiori), REST, a CLI and a GtkD desktop GUI.

---

## 1. NAF v4 grid coverage

| View | Viewpoints covered | Section |
|---|---|---|
| **C** Concepts | C1 Capability Taxonomy, C2 Enterprise Vision, C3 Capability Dependencies | §2 |
| **S** Service Specifications | S1 Service Taxonomy, S3 Service Interfaces, S4 Service Functions, S5 Service States | §3 |
| **L** Logical | L1 Node Types, L2 Logical Scenario, L4 Logical Activities, L6 Logical Sequence, L7 Logical Data Model, L8 Logical Constraints | §4 |
| **P** Physical Resources | P1 Resource Types, P2 Resource Structure, P4 Resource Functions, P5 Resource Interactions | §5 |
| **A** Architecture Metadata | A3 Architecture Decisions, A7 Standards | §6 |

---

## 2. Concepts (C)

### C1 — Capability taxonomy

```
CAP-SM  Service Manager
├── CAP-SM-1  Environment Registry
│   └── 1.1  Register / suspend runtime platforms (CF, Kubernetes, Kyma, Neo)
├── CAP-SM-2  Broker Federation
│   ├── 2.1  Register OSB brokers (credentials write-only)
│   ├── 2.2  Catalog synchronization (on demand, periodic)
│   └── 2.3  Catalog reconciliation (create / update / retire offerings and plans)
├── CAP-SM-3  Service Catalog
│   ├── 3.1  Offerings (category, bindability, plan updates)
│   └── 3.2  Plans (pricing, quota, parameter schemas)
├── CAP-SM-4  Service Lifecycle
│   ├── 4.1  Provision / update / deprovision instances (policy controlled)
│   ├── 4.2  Bind / unbind with credential issuing
│   └── 4.3  Operation tracking (synchronous / asynchronous with completion callback)
├── CAP-SM-5  Resource Metadata
│   └── 5.1  Labels on any resource (unique key per resource, cascade on delete)
├── CAP-SM-6  Insight
│   └── 6.1  Tenant statistics (readiness, failures, running operations)
└── CAP-SM-7  Access Channels
    ├── 7.1  OData v4 for SAP Fiori      7.2  REST/JSON
    ├── 7.3  Command line                7.4  Desktop GUI (GtkD)
```

### C2 — Enterprise vision

| Aspect | Statement |
|---|---|
| Mission | Give every BTP-style environment one broker-agnostic place to discover, provision and bind services. |
| Vision | Every service instance and credential in the platform is traceable to a plan, a broker, a platform and an operation. |
| Goals | Enforced lifecycle and integrity rules · catalog always in sync with the brokers · the same behaviour across all access channels · tenant isolation. |
| Scope | Platforms, brokers, offerings, plans, instances, bindings, operations, labels, statistics. |
| Out of scope | Executing broker provisioning calls (`PUT /v2/service_instances`). The operation model and `CompleteOperation` are the integration point for that. |
| Stakeholders | Platform operators (Admin), application developers (Write), auditors and viewers (Read), broker providers. |

### C3 — Capability dependencies

| Capability | Depends on |
|---|---|
| CAP-SM-4.1 Provision | CAP-SM-3 (available offering, plan quota), CAP-SM-2 (active broker), CAP-SM-1 (active platform, optional) |
| CAP-SM-4.2 Bind | CAP-SM-4.1 (instance `created`, usable), CAP-SM-3 (bindable offering and plan) |
| CAP-SM-3 Catalog | CAP-SM-2.2 sync, or manual maintenance |
| CAP-SM-5 Labels | Existence of the labelled resource |
| CAP-SM-7 Channels | One EDM model and one engine (see A3 AD-2) |

---

## 3. Service specifications (S)

### S1 — Service taxonomy

| Service ID | Service | Kind |
|---|---|---|
| SVC-SM-PLAT | Platform registry | entity service |
| SVC-SM-BRK | Broker registry | entity service |
| SVC-SM-CAT | Catalog (offerings, plans) | entity service |
| SVC-SM-INST | Instance lifecycle | entity service + state machine |
| SVC-SM-BIND | Binding lifecycle | entity service + state machine |
| SVC-SM-OPS | Operation tracking | entity service + action `CompleteOperation` |
| SVC-SM-SYNC | Catalog sync | action `SyncBrokerCatalog`, background worker |
| SVC-SM-LBL | Labels | entity service |
| SVC-SM-STAT | Statistics | singleton |
| SVC-SM-HLTH | Health | `GET /health` |

### S3 — Service interfaces

| Interface | Protocol | Root | Consumers |
|---|---|---|---|
| IF-ODATA | OData v4 (JSON, `$batch`, CSDL with UI and Common annotations) | `/odata/v4/service-manager` | SAP Fiori app (through the approuter) |
| IF-REST | HTTP/JSON | `/api/v1/service-manager` | scripts, other platform services |
| IF-CLI | process arguments, text/JSON/CSV | `uim-service-manager-cli` | operators, CI |
| IF-GUI | GTK 3 | `uim-service-manager-gui` | desktop operators |
| IF-OSB | OSB API 2.17 client, `GET /v2/catalog` | `<brokerUrl>` | outbound to brokers |
| IF-HEALTH | HTTP | `/health` | Cloud Foundry, Kubernetes probes |

Entity sets: `Platforms`, `ServiceBrokers`, `ServiceOfferings`, `ServicePlans`, `ServiceInstances`,
`ServiceBindings`, `Operations`, `Labels`, and the singleton `Statistics`.
Actions: `SyncBrokerCatalog(brokerId)` and `CompleteOperation(operationId, succeeded, errorMessage)`.

### S4 — Service functions and policies

| Function | Policy / rule | Failure |
|---|---|---|
| Provision instance | active broker · available offering · plan quota · active platform · unique name | 422 / 409 |
| Change plan | same offering · offering `planUpdateable` · quota of the new plan | 422 |
| Bind | instance `created` and usable · bindable offering and plan · unique name per instance | 422 / 409 |
| Delete | refused while the resource is in use (platform→instances, broker→instances, offering→plans, plan→instances, instance→bindings, operation still running) | 422 |
| Sync catalog | broker not inactive · valid OSB catalog | 422 / 502 |
| Any write | EDM type and property validation · enum values · JSON text fields | 400 |

### S5 — Service states

Instances move through `creating → created ⇄ updating`, then `deleting → (removed)`, with `failed`
and `orphaned` as error states. Bindings move through `creating → created → deleting → (removed)`,
with `failed`. Operations move through `pending → inProgress → succeeded | failed`. The complete
diagrams are in [UML.md § State machines](UML.md#state-machines).

---

## 4. Logical (L)

### L1 — Node types

| Node | Responsibility |
|---|---|
| N-UI | SAP Fiori 3 app (UI5 1.120, OData V4 model) |
| N-AR | approuter: login (XSUAA), CSRF, routing, static resources |
| N-SRV | Service Manager backend (REST, OData, worker) |
| N-ADM | CLI / GUI on an operator workstation (shares the data file in single-node setups) |
| N-UAA | XSUAA: token issuing, scopes Read / Write / Admin |
| N-BRK | External OSB service brokers |
| N-STORE | Document store (memory or JSON snapshot; a database adapter can be plugged in) |

### L2 — Logical scenario (connectivity)

```
 N-UI ──HTTPS──▶ N-AR ──HTTPS + JWT──▶ N-SRV ──OSB HTTPS──▶ N-BRK
                   │                     │  ▲
                   └──── N-UAA ◀─────────┘  │ (RS256 verification key)
 N-ADM (CLI / GUI) ── in-process engine ────┴──▶ N-STORE ◀── N-SRV
```

### L4 — Logical activities (provision → use → retire)

1. Admin registers a platform and a broker (SVC-SM-PLAT, SVC-SM-BRK).
2. Admin or the worker syncs the catalog (SVC-SM-SYNC), which creates offerings and plans.
3. Developer provisions an instance (SVC-SM-INST), which starts an operation (SVC-SM-OPS).
4. In asynchronous mode, the broker callback or an operator completes the operation.
5. Developer creates a binding and receives the credentials (SVC-SM-BIND).
6. Developer adds labels for grouping (SVC-SM-LBL).
7. Retiring a service: unbind, then deprovision. Labels are removed with the resource.

### L6 — Logical sequences

See [UML.md](UML.md): *Sequence: provision a service instance* and *Sequence: catalog sync*.

### L7 — Logical data model

| Entity | Key | Relationships | Notable attributes |
|---|---|---|---|
| Platform | id | 1 → * ServiceInstance (optional) | type, status, region, subaccountId, credentials (secret) |
| ServiceBroker | id | 1 → * ServiceOffering | brokerUrl, status, lastCatalogFetch, catalogError, credentials (secret) |
| ServiceOffering | id | * → 1 broker, 1 → * plans | catalogId, status, category, bindable, planUpdateable, tags |
| ServicePlan | id | * → 1 offering, 1 → * instances | catalogId, pricing, maxInstances, schemas |
| ServiceInstance | id | * → 1 plan / offering, * → 0..1 platform, 1 → * bindings | status, parameters, context, shared, usable, lastOperationId |
| ServiceBinding | id | * → 1 instance | status, credentials, parameters, bindResource |
| Operation | id | * → 1 instance or binding | type, status, errorMessage, startedAt, completedAt |
| Label | id | * → 1 resource (typed reference) | resourceType, resourceId, key (unique per resource), value |

Every entity carries `tenantId`, `createdAt/By` and `updatedAt/By`.

### L8 — Logical constraints

- **Tenant isolation**: every query and command is scoped to the caller's tenant.
- **Write-only secrets**: platform and broker credentials are never returned (`hasCredentials` flag only).
- **Referential integrity** without a database: enforced in the use cases.
- **One model**: all channels share the EDM model, the scopes and the validation.

---

## 5. Physical resources (P)

### P1 / P2 — Resource types and structure

| Resource | Technology |
|---|---|
| `uim-service-manager-platform-service` | D (DMD/LDC), vibe.d 0.10.3, uim-framework 26.11, uim-platform:service |
| `uim-service-manager-cli` | same code base, `--config=cli` |
| `uim-service-manager-gui` | same code base, GtkD 3.11 / GTK 3.24, `--config=gui` |
| Fiori app | SAPUI5 1.120, `sap_fiori_3`, OData V4 model |
| approuter | Node.js ≥ 20, `@sap/approuter` 20 |
| Data | `IDocumentStore`: `MemoryDocumentStore` or `FileDocumentStore` (atomic JSON snapshot) |

Backend structure (hexagonal): `domain` → `ports` → `application` → `persistence` /
`infrastructure` → `presentation`. Composition roots: `source/app.d`, `cli.d`, `gui.d`, and
`infrastructure/container.d`.

### P4 / P5 — Deployment and interactions

**SAP BTP Cloud Foundry** (`mta.yaml`)

```
MTA uim-service-manager 2.0.0
├── service-manager-srv        binary_buildpack · 256M · health /health
│     env SERVICE_MANAGER_STORAGE=file, FRONTEND_DIR=""
│     requires service-manager-xsuaa  → RS256 + scope enforcement
├── service-manager-approuter  approuter.nodejs · resources/ = frontend
│     destination service-manager-srv (forwardAuthToken)
└── service-manager-xsuaa      xsuaa/application · xs-security.json
      scopes Read, Write, Admin · role collections Viewer / Developer / Administrator
```

**Kubernetes** (`k8s/`)

```
Namespace uim-platform
├── ConfigMap service-manager-config   SERVICE_MANAGER_* (storage file, catalog sync 15 min)
├── Secret    service-manager-secrets  jwtSecret (optional, HS256)
├── Deployment service-manager         1 replica, Recreate, non-root, probes /health
│     └── PVC service-manager-data → /data/service-manager.json
└── Service service-manager            ClusterIP :8113
```

**Container**: `backend/Dockerfile` / `Containerfile` (multi-stage LDC 1.40 → Ubuntu 24.04; volume `/data`; port 8113).

---

## 6. Architecture metadata (A)

### A3 — Architecture decisions

| ID | Decision | Rationale | Consequence |
|---|---|---|---|
| AD-1 | Hexagonal / Clean Architecture with explicit driving and driven ports | Business rules are independent of protocols and storage | Interactors are testable with an in-memory store and a fake broker gateway |
| AD-2 | **One EDM model and one `ODataEngine` for OData, REST, CLI and GUI** (generic adapters of uim-platform:service) | No duplicated controllers; identical validation, scopes and errors on every channel | Previously about 1,200 lines of hand-written REST controllers; now one model, about 400 lines of wiring, and a generic REST adapter |
| AD-3 | Typed domain exceptions (`invalid`, `notFound`, `conflict`, `ruleViolation`, `gateway`) translated per channel | The domain knows nothing about HTTP | 400 / 404 / 409 / 422 / 502 and CLI exit codes 1 / 2 |
| AD-4 | Explicit state machines for instances, bindings and operations | Illegal transitions cannot happen | Asynchronous broker flows are supported through `CompleteOperation` |
| AD-5 | Synchronous provisioning by default, asynchronous optional | Simple demos and tests; realistic OSB flows on demand | `syncProvisioning` switch |
| AD-6 | Catalog reconciliation matched on broker catalog ids; missing offerings are retired, not deleted | Instances keep valid references | The `removed` status blocks new instances only |
| AD-7 | Document store port (`IDocumentStore`) with memory and file implementations | No database needed for development; server, CLI and GUI share data | The file store is single-writer: keep one replica or plug in a database adapter |
| AD-8 | Write-only secrets | Credentials are never leaked through list or read APIs | `hasCredentials` flag instead |
| AD-9 | Layered configuration (defaults → file → profile → env → VCAP → CLI) | 12-factor and Cloud Foundry friendly | Typed `ServiceManagerConfig`, validated at start |
| AD-10 | XSUAA (RS256) on BTP, HS256 elsewhere, open for local development | Same binary in every environment | Scopes are enforced only when authentication is active |
| AD-11 | Port 8113 | Consistent UIM platform port allocation | — |

### A7 — Standards

| Standard | Use |
|---|---|
| OASIS OData v4.0 (CSDL, JSON format, `$batch`) | IF-ODATA |
| SAP OData vocabularies (UI, Common), OData Core and Capabilities | Fiori annotations in `$metadata` |
| Open Service Broker API 2.17 | IF-OSB catalog |
| OAuth 2.0 / JWT (RS256, HS256) | security |
| SAP Fiori 3 design guidelines / SAPUI5 | frontend |
| MTA 3.3 | BTP deployment |
| OCI container image, Kubernetes apps/v1 | container deployment |
