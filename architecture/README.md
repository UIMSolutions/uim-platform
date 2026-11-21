# UIM Architecture Repository

An architecture repository service for **TOGAF building blocks** with **ArchiMate 3.2** relationships,
lifecycle governance, gap, impact and phase-out analysis, and export to the **ArchiMate Model Exchange
File Format**. It has a D / vibe.d backend (clean hexagonal architecture), an SAP Fiori 3 / OpenUI5
frontend and an SAP approuter, and deploys as one MTA to SAP BTP, Cloud Foundry.

| | |
|---|---|
| Version | 2.0.0 |
| Backend | D, uim-framework 26.11, vibe.d 0.10.5, shared `uim-platform:service` library |
| Frontend | OpenUI5 1.120 (`sap_fiori_3`), OData V4 model |
| Interfaces | REST `/api/v1`, OData v4 `/odata/v4/architecture`, CLI, GtkD desktop GUI |
| Port | 8122 |

See [UML.md](UML.md) for class, component and sequence diagrams and [NAFv4.md](NAFv4.md) for the NATO
Architecture Framework v4 views.

---

## Contents

1. [Domain](#domain)
2. [Project layout](#project-layout)
3. [Quick start](#quick-start)
4. [Configuration](#configuration)
5. [Interfaces](#interfaces) — REST, OData, CLI, GUI
6. [Security](#security)
7. [Deployment](#deployment) — SAP BTP (MTA), Docker / Podman, Kubernetes
8. [Tests](#tests)
9. [Migrating from 1.x](#migrating-from-1x)

---

## Domain

### Building blocks

There is one aggregate, `BuildingBlock`. Its `kind` is one of five TOGAF building block kinds:

| Kind | Abbr. | Meaning | Allowed ArchiMate elements | Default element |
|---|---|---|---|---|
| `architecture` | ABB | What is needed (capability, requirements), vendor neutral | any | ApplicationComponent |
| `solution` | SBB | How it is realized (product, component); **realizes an ABB** | any | ApplicationComponent |
| `data` | DBB | Information and data objects | passive structure (DataObject, BusinessObject, Artifact, …) | DataObject |
| `business` | BBB | Business functions, processes, services | business, strategy, motivation | BusinessProcess |
| `technology` | TBB | Platforms, nodes, system software | technology (incl. physical) | Node |

Each block has an ArchiMate **element type** taken from the 60 element types of ArchiMate 3.2. The element
type determines the block's **layer** (domain) and **aspect**, and those drive the relationship rules.
Other attributes are the capability, interfaces, vendor or component, endpoint, data classification,
data owner, system of record, SAP LeanIX fact sheet type and ID, `validUntil`, tags, version, owner and
the audit fields.

### Lifecycle (governance)

```
proposed ──► approved ──► inDevelopment ──► active ──► deprecated ──► retired
   │  ▲         │  ▲            │                         │
   │  └─────────┘  └────────────┘ (back to review)        └──► active (reinstated)
   └──► retired (rejected)        approved / inDevelopment ──► retired (cancelled)
```

* A status changes only through the **ChangeStatus** action (scope `Govern`). PATCH does not change it.
* `active` and `deprecated` blocks **cannot be deleted**. Retire them first.
* `retired` is final, and a retired block cannot get new relationships.
* Deleting a block also deletes its relationships and clears `realizesId` on every SBB that pointed to it.

### Relationships

A `Relationship` is a typed, directed ArchiMate relationship (`composition`, `aggregation`, `assignment`,
`realization`, `serving`, `access`, `influence`, `triggering`, `flow`, `specialization`, `association`).
The rules are a pragmatic subset of the ArchiMate relationship table plus TOGAF rules:

| Relationship | Rule |
|---|---|
| composition / aggregation | same layer, or the whole is a composite (Grouping, Plateau, Location, …) |
| assignment | the source is an active structure element |
| access | behavior / active structure → passive structure |
| serving / triggering / flow | between behavior or active structure elements |
| influence | the target is a motivation element |
| specialization | between elements of the same type |
| realization | never ABB → SBB (an SBB realizes an ABB) |
| association | always allowed |

Duplicates (same source, type and target) are rejected (409), and so are self-relationships.

### Analysis

| Analysis | Definition |
|---|---|
| **Gaps** | ABBs (not retired) that no SBB realizes, whether through `realizesId` or a `realization` relationship. This is the TOGAF gap analysis. |
| **ABB coverage** | share of ABBs that are realized |
| **Orphans** | blocks (not retired) without any relationship or realization |
| **Phase-out risks** | deprecated or retired blocks that blocks still in use (approved, inDevelopment, active) depend on |
| **Expired** | blocks still in use whose `validUntil` has passed |
| **Impact** | all blocks that depend on a given block, transitively and breadth first, with depth and the path they are reached through |

The dependency direction follows the semantics of each relationship. For serving, realization,
assignment, triggering, flow and influence, the target depends on the source. For access, composition,
aggregation and specialization, the source depends on the target. Association carries no dependency.

---

## Project layout

```
architecture/
├── mta.yaml                    MTA: backend + approuter + XSUAA + user-provided config service
├── backend/                    D / vibe.d service
│   ├── dub.sdl                 configurations: defaultRun, cli, gui, defaultTest
│   ├── config/default.json     local defaults
│   ├── Dockerfile, Containerfile
│   ├── source/
│   │   ├── app.d  cli.d  gui.d entry points
│   │   └── uim/platform/architecture/
│   │       ├── domain/         entities, types, enumerations, services (lifecycle, rules, analysis), exceptions
│   │       ├── ports/          usecases (driving), repositories, storages, messaging, gateways (driven)
│   │       ├── application/    usecases (manage blocks/relationships, analyze, ArchiMate export), services, dtos
│   │       ├── persistence/    records, mappers, repositories, storages (memory | file)
│   │       ├── infrastructure/ configuration, security, logging, clients, container (composition root)
│   │       └── presentation/   odata (EDM model + engine), http (REST, health), web (/app), cli, gui
│   ├── tests/                  cross-layer integration tests
│   ├── docs/  views/
├── frontend/                   SAP Fiori 3 / OpenUI5 app (namespace uim.architecture)
│   ├── manifest.json  Component.js  index.html  ui5.yaml
│   ├── view/  controller/  fragment/  model/  i18n/ (en, de)
│   ├── localService/           metadata.xml + mock data (generated from the backend)
│   └── test/                   QUnit (formatter, models) and OPA5 journey
├── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
└── k8s/                        ConfigMap, Deployment (+ PVC), Service
```

One **EDM model** (`presentation/odata/model.d`) drives OData `$metadata` (including the Fiori UI
annotations), payload validation, scopes, the REST facade, the generic CLI commands and the GtkD
entity browser. All adapters call the same engine, so they validate and fail the same way.

---

## Quick start

Prerequisites: `dub` with `dmd` or `ldc2`, and the `uim-platform/service` package next to this module.

```bash
cd architecture/backend
dub build                                   # → build/uim-architecture-platform-service
./build/uim-architecture-platform-service   # http://localhost:8122
```

With `config/default.json` the server stores its data in `data/architecture.json` and creates the
**demo landscape** in the empty `default` tenant. The demo is an order-to-cash scenario on SAP BTP with
18 blocks and 15 relationships, and it contains one gap, two orphans and one phase-out risk.

| URL | |
|---|---|
| http://localhost:8122/app/index.html | Fiori app (served by the backend for local development) |
| http://localhost:8122/odata/v4/architecture/$metadata | OData service |
| http://localhost:8122/api/v1/building-blocks | REST |
| http://localhost:8122/health | health |

Run the frontend alone with the UI5 tooling: `cd frontend && npm install && npm start`.
To run through the approuter locally, start the backend and then `cd approuter && npm install && npm start`.
`default-env.json` points the `architecture-srv` destination at `http://localhost:8122`.

---

## Configuration

Precedence, from lowest to highest: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json`
→ `ARCHITECTURE_*` environment variables → Cloud Foundry (`PORT`, `VCAP_APPLICATION`, the credentials of
the user-provided service `architecture-config` in `VCAP_SERVICES`) → CLI options.

| Key | Env | Default | |
|---|---|---|---|
| `host` | `ARCHITECTURE_HOST` | `0.0.0.0` | |
| `port` | `ARCHITECTURE_PORT` / `PORT` | `8122` | |
| `storage` | `ARCHITECTURE_STORAGE` | `memory` (`file` in default.json) | `memory` or `file` |
| `dataFile` | `ARCHITECTURE_DATA_FILE` | `data/architecture.json` | snapshot shared by server, CLI and GUI |
| `defaultTenant` | `ARCHITECTURE_DEFAULT_TENANT` | `default` | used without a token or `X-Tenant-Id` |
| `apiPath` | `ARCHITECTURE_API_PATH` | `/api/v1` | |
| `odataPath` | `ARCHITECTURE_ODATA_PATH` | `/odata/v4/architecture` | |
| `maxPageSize` | `ARCHITECTURE_MAX_PAGE_SIZE` | `200` | server-driven paging |
| `requireAuthentication` | `ARCHITECTURE_REQUIRE_AUTHENTICATION` | `false` | HS256 mode, needs `jwtSecret` |
| `jwtSecret` | `ARCHITECTURE_JWT_SECRET` | — | |
| `frontendDir` | `ARCHITECTURE_FRONTEND_DIR` | `../frontend` | `""` disables `/app` (on BTP the approuter serves the UI) |
| `seedDemoData` | `ARCHITECTURE_SEED_DEMO_DATA` | `false` (`true` in default.json) | seeds the default tenant if it is empty |

`uim-architecture-cli config` prints the effective configuration with secrets masked.

---

## Interfaces

### REST — `/api/v1`

The REST API is a thin facade over the OData engine.

| Method | Path | |
|---|---|---|
| GET | `/building-blocks?kind=&status=&owner=&tag=&search=` | list (`kind` also accepts `ABB`, `SBB`, …) |
| GET | `/building-blocks/types/{kind}` | list by kind (1.x) |
| POST | `/building-blocks` | create (`id` is optional, e.g. `abb-crm`) |
| GET / PATCH / PUT / DELETE | `/building-blocks/{id}` | read / change / delete |
| POST | `/building-blocks/{id}/status` | lifecycle transition `{"status": "approved"}` |
| GET | `/building-blocks/{id}/relationships` | relationships of a block |
| GET | `/building-blocks/{id}/impact` | impact analysis |
| GET / POST | `/relationships?type=&blockId=` | list / create |
| GET / PATCH / DELETE | `/relationships/{id}` | only the description can change |
| GET | `/analysis/statistics`, `/analysis/gaps`, `/analysis/orphans`, `/analysis/phase-out-risks` | |
| GET | `/element-types` | the ArchiMate 3.2 catalogue |
| GET | `/export/archimate?modelName=` | ArchiMate exchange file (XML download) |
| POST | `/seed` | demo landscape (empty tenant only) |
| GET | `/health`, `/api/v1/health` | |

Collections are returned as `{"value": [...], "count": n}`. Errors are returned as
`{"error": {"code", "message"}}` with status 400 (invalid), 401, 403 (scope), 404, 405, 409 (conflict)
or 422 (business rule).

```bash
curl -X POST localhost:8122/api/v1/building-blocks -H 'Content-Type: application/json' -H 'X-Tenant-Id: demo' -d '{
  "id": "sbb-api-gateway", "kind": "solution", "name": "SAP API Management",
  "elementType": "ApplicationComponent", "realizesId": "abb-integration",
  "owner": "integration-team", "tags": ["api", "gateway"], "validUntil": "2029-12-31"}'

curl -X POST localhost:8122/api/v1/building-blocks/sbb-api-gateway/status -H 'Content-Type: application/json' -d '{"status":"approved"}'
curl localhost:8122/api/v1/building-blocks/tbb-postgres/impact
curl -o landscape.xml localhost:8122/api/v1/export/archimate
```

### OData v4 — `/odata/v4/architecture`

| Entity set | |
|---|---|
| `BuildingBlocks` | CRUD, with the computed fields `kindAbbreviation`, `domain`, `aspect`, `realizesName`, `relationshipCount` and `realizedByCount`. `kind` and `status` are immutable on PATCH. |
| `Relationships` | CRUD, with the computed fields `sourceName/Kind` and `targetName/Kind` |
| `Gaps`, `Orphans`, `PhaseOutRisks` | read-only analysis |
| `ElementTypes` | read-only ArchiMate catalogue (key `name`) |
| `Statistics` | singleton with the key figures |

| Action | Scope | |
|---|---|---|
| `ChangeStatus(id, status)` → `StatusResult` | Govern | |
| `AnalyzeImpact(id)` → `Collection(ImpactedBlock)` | Read | |
| `ExportArchiMate(modelName?)` → `ExportResult` | Read | XML in `content` |
| `SeedDemoData()` → `SeedResult` | Manage | |

The service supports `$filter` (`eq ne gt ge lt le and or not`, `contains`, `startswith`, `endswith`),
`$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search` and `$batch`.

### CLI

```bash
dub build --config=cli
B=./build/uim-architecture-cli
$B help
$B seed --data-file=data/architecture.json
$B list BuildingBlocks --filter="kind eq 'solution' and status eq 'active'"
$B stats
$B gaps
$B status abb-analytics approved
$B relate sbb-order-service serving bbb-order-to-cash --description="Order intake"
$B impact tbb-postgres
$B export --model-name="Target architecture" > landscape.xml
```

The generic commands `sets`, `metadata`, `list`, `count`, `get`, `create`, `update`, `delete` and
`invoke` work on every entity set and action. `--json` prints machine-readable output and `--tenant`
selects the tenant.

### Desktop GUI (GtkD)

```bash
dub build --config=gui
./build/uim-architecture-gui --data-file=data/architecture.json --refresh=5
```

The GUI has a page per entity set, with forms generated from the EDM model, the Statistics sheet and an
action runner.

### Fiori app

* **Header KPIs** (bound to `Statistics`): blocks per kind, ABB coverage with the number of gaps, the
  lifecycle distribution, phase-out risks, orphans and expired blocks, and the number of relationships.
* **Building blocks**: filter by kind (ABB/SBB/DBB/BBB/TBB segmented button) and status, full-text
  `$search`, create dialog with fields that depend on the kind.
* **Relationships**: list with a type filter, links to both ends, delete.
* **Analysis**: gaps, phase-out risks, orphans.
* **Block detail**: header facts, attributes, outgoing and incoming relationships, realizing SBBs (for
  ABBs), impact analysis, edit, **Lifecycle** (offers only the allowed transitions) and delete.
* **Export ArchiMate** downloads the exchange file.
* Available in English and German.

---

## Security

| Mode | When | Behaviour |
|---|---|---|
| `xsuaa` | an XSUAA binding with a `verificationkey` is in `VCAP_SERVICES` | RS256 tokens are required (401 without one) and scopes are enforced |
| `hs256` | `requireAuthentication=true` and `jwtSecret` is set | HS256 tokens, for tests and non-BTP setups |
| `open` | otherwise (local development) | the tenant comes from `X-Tenant-Id` and the user from `X-User-Id` |

Scopes (`approuter/xs-security.json`):

| Scope | Role templates | Grants |
|---|---|---|
| `Read` | Viewer, Architect, ArchitectureBoard | read, analysis, export |
| `Manage` | Architect, ArchitectureBoard | create, change and delete blocks and relationships, seed |
| `Govern` | ArchitectureBoard | lifecycle decisions (`ChangeStatus`) |

The tenant comes from the token's `zid`. All data is partitioned by tenant.

---

## Deployment

### SAP BTP, Cloud Foundry

```bash
mbt build                       # builds the backend with ldc2 and copies the frontend into the approuter
cf deploy mta_archives/uim-architecture_2.0.0.mtar
```

The MTA contains `architecture-srv` (binary buildpack, health check `/health`), `architecture-approuter`
(serves the Fiori app and routes `/odata/v4/architecture` and `/api/v1` with token forwarding),
`architecture-xsuaa` and the user-provided service `architecture-config` for runtime overrides, for
example `cf update-user-provided-service architecture-config -p '{"seedDemoData":true}'`.
The file store lives on the container disk, so run a single instance.

### Docker / Podman

The build context is the repository root, because the backend depends on `../../service`.

```bash
cd uim-platform
docker build -f architecture/backend/Dockerfile -t uim-platform/architecture:2.0.0 .
docker run -p 8122:8122 -v architecture-data:/data uim-platform/architecture:2.0.0
podman build -f architecture/backend/Containerfile -t uim-platform/architecture:2.0.0 .
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml -f k8s/deployment.yaml -f k8s/service.yaml
kubectl -n uim-platform port-forward service/architecture 8122:8122
```

The deployment runs one replica (`Recreate`) on a PVC, as a non-root user with a read-only root
filesystem, and has liveness and readiness probes on `/health`.

---

## Tests

```bash
cd backend && dub test          # 24 modules: domain, application, persistence, OData, REST, CLI, file store
```

* **Unit tests** live next to the code in every layer: lifecycle, ArchiMate rules, analysis, mapping,
  export, configuration and the EDM model.
* **`tests/architecture_flows.d`** covers the demo landscape statistics, the governance rules, the OData
  engine (validation, scopes, actions, `$metadata`), the REST facade with vibe.d test requests, and the
  file store surviving a restart.
* **Frontend**: `frontend/test/unit/unitTests.qunit.html` tests the formatter and models.
  `test/integration/opaTests.qunit.html` is an OPA5 journey against a running backend at
  `http://localhost:8122/app/test/...`.

---

## Migrating from 1.x

* The five entity types (`ArchitectureBlock`, `SolutionBlock`, …) are replaced by one `BuildingBlock`
  with a `kind`. Embedded relationship arrays are replaced by the `Relationship` aggregate.
* The REST paths `/api/v1/building-blocks` and `/building-blocks/types/{kind}` are kept. The 1.x field
  names `type`, `title`, `lifecycleState` and `version` are accepted as aliases, and 1.x status values
  such as `identified` map to `proposed`.
* The status no longer changes through PATCH or PUT. Use `POST /building-blocks/{id}/status` instead.
  A PATCH that tries to change it returns 400.
* The server-side Diet/PWA/UI5 pages (`/web`, `/pwa`, `/ui5`) and the `/rest/v1/*` interfaces are
  replaced by the Fiori app (`/app`), OData v4 and the REST facade.
* Data moved from the in-memory store to the `memory` or `file` document store. 1.x records stay
  readable.
