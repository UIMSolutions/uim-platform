# UIM Cloud Transport Management

A service modelled on **SAP Cloud Transport Management (CTM)** for the UIM Platform:
it models a transport landscape (nodes connected by routes), takes transport
requests (MTA archives, integration content, HTML5 apps, ABAP content), moves
them through the **import queues** of the nodes, deploys them and records every
step in an audit trail.

| Part | Technology | Path |
|---|---|---|
| Backend | D, vibe.d 0.10.3, hexagonal / Clean Architecture | [`backend/`](backend/) |
| Fiori UI | SAP Fiori 3 / UI5 1.120 (OData V4 model) | [`frontend/`](frontend/) |
| Approuter | `@sap/approuter` + XSUAA | [`approuter/`](approuter/) |
| Deployment | MTA (`mbt build` → `cf deploy`), Docker/Podman, Kubernetes | [`mta.yaml`](mta.yaml), [`backend/Dockerfile`](backend/Dockerfile), [`k8s/`](k8s/) |

The backend has four driving adapters on the same application core:

| Adapter | Entry point | Build |
|---|---|---|
| REST API `/api/v1/transport/*` + OData v4 `/odata/v4/transport/` + Fiori app | `source/app.d` | `dub build` |
| Command line interface `uim-transport-cli` | `source/cli.d` | `dub build --config=cli` |
| GtkD desktop GUI `uim-transport-gui` | `source/gui.d` | `dub build --config=gui` |
| Auto-import worker (background, inside the server) | `infrastructure/workers` | — |

All of them share the same JSON snapshot storage (`backend/data/` by default),
so a request created in the CLI shows up in the Fiori app and the GUI.

More documentation: [UML.md](UML.md) (class, component and sequence diagrams) and
[NAFv4.md](NAFv4.md) (NATO Architecture Framework v4 description).

---

## Transport workflow

```text
             export                   import (deploy)            forward (automatic)
 request ──────────────► queue(QA) ─────────────────► QA ok ─────────────────► queue(PROD) ──► …
 (source node DEV)        via route DEV→QA                     if QA.isForwardEnabled
```

1. **Register** a transport request (name, content type, version, archive URL, source node).
2. **Export** it: it is added to the import queues of all follow-on nodes of its
   source node (destinations of *enabled* routes whose destination node is enabled).
3. **Import** a node's queue: every selected, pending entry is deployed through the
   `IDeploymentGateway` port. The result is `success`, `warning` or `failed`.
4. After a successful import the request is **forwarded** to the next nodes if the
   node has *forward enabled*.
5. Failed / finished entries can be **reset** (status `repeating`) and imported again.
6. The request status is **aggregated** from its queue entries:
   failed > running > repeating > in transit (`running`) > warning > success.

Business rules enforced by the use cases:

* node names are unique per tenant; a node used by routes cannot be deleted;
* routes must connect two existing, different nodes, must be unique, and the
  landscape must stay **acyclic**;
* a request can wait only once in the same queue; running imports block deletion;
* every export, import, forward, reset and delete writes a `TransportAction`.

The bundled `SimulatedDeploymentGateway` is deterministic: disabled node → failed,
`storageUrl` starting with `fail:` → failed, no `storageUrl` → warning (metadata
only), otherwise success. Replace it with a real client (CF Deploy Service, ABAP
CTS, Kyma) by implementing `IDeploymentGateway` and wiring it in the `Container`.

---

## Architecture (backend)

```text
backend/
├── dub.sdl                     configurations: defaultRun · cli · gui · defaultTest · …
├── config/default.json         default configuration
├── Dockerfile / Containerfile  container build (context = repository root)
└── source/
    ├── app.d  cli.d  gui.d     entry points (composition roots)
    └── uim/platform/transport/
        ├── domain/             pure business core
        │   ├── entities/       TransportNode, TransportRoute, TransportRequest,
        │   │                   ImportQueueEntry, TransportAction
        │   ├── types/          strongly typed IDs
        │   ├── enumerations/   NodeType, NodeStatus, RouteStatus, ContentType, RequestStatus,
        │   │                   ImportStatus, ActionType, ActionStatus + name parsing
        │   ├── services/       TransportValidator, TransportLandscape (graph, cycle check),
        │   │                   aggregateRequestStatus
        │   └── exceptions/     TransportException
        ├── ports/
        │   ├── usecases/       driving: IManageTransportNodes/Routes/Requests, IManageImportQueue,
        │   │                   IManageTransportActions, ITransportOperations
        │   ├── services/       driving: ITransportStatisticsService, ITransportLandscapeService
        │   ├── driving.d       TransportPorts — the bundle every adapter receives
        │   ├── repositories/   driven: one repository port per aggregate
        │   ├── storages/       driven: ISnapshotStorage
        │   ├── gateways/       driven: IDeploymentGateway
        │   └── messaging/      driven: ITransportEventPublisher (+ topics)
        ├── application/
        │   ├── dtos/           Create/Update…Input, Export/Import/ForwardInput, ImportRunSummary,
        │   │                   TransportStatistics
        │   ├── usecases/manage/      CRUD use cases with business rules
        │   ├── usecases/operations/  TransportOperationsUseCase (export → import → forward)
        │   └── services/       statistics & landscape, action recorder, status sync, results
        ├── persistence/
        │   ├── repositories/   TenantRepository based implementations
        │   ├── storages/       JsonFileSnapshotStorage, MemorySnapshotStorage, SnapshotTenantStore
        │   ├── mappers/        entity ⇄ record
        │   └── records/        collection names, snapshot envelope (schemaVersion)
        ├── infrastructure/
        │   ├── configuration/  TransportConfig + loadConfig (defaults → file → env → VCAP_SERVICES)
        │   ├── security/       XSUAA JWT claims / X-Tenant-Id → RequestIdentity
        │   ├── logging/        log level, LogEventPublisher, MemoryEventPublisher
        │   ├── clients/        SimulatedDeploymentGateway
        │   ├── workers/        AutoImportWorker
        │   └── container.d     dependency injection
        └── presentation/
            ├── http/           REST controllers (vibe.d)
            ├── odata/          OData v4: EDM model, $metadata, query options, serializers, actions
            ├── cli/            argument parser + commands
            ├── gui/            GtkD window (only in --config=gui)
            ├── web/            serves frontend/ for local development
            └── tabular.d       table projections shared by CLI and GUI
```

Dependencies point inwards only: presentation → ports ← application → domain;
persistence and infrastructure implement driven ports. Adapters receive the
`TransportPorts` bundle and never see concrete use cases or repositories.

---

## Build, test and run

Prerequisites: `dmd` or `ldc2`, `dub`; for the GUI GTK 3.24 development files.

```sh
cd transport/backend
dub test                              # unit tests (incl. an end-to-end DEV → QA → PROD workflow)
dub build                             # server  → build/uim-transport-platform-service
dub build --config=cli                # CLI     → build/uim-transport-cli
dub build --config=gui                # GUI     → build/uim-transport-gui

./build/uim-transport-platform-service    # http://localhost:8117  (Fiori app at /index.html)
```

### Command line interface

```sh
./build/uim-transport-cli demo                    # sample landscape DEV → QA → PROD + one request
./build/uim-transport-cli landscape
./build/uim-transport-cli queue import QA         # import QA, forwards to PROD
./build/uim-transport-cli queue list --node=PROD
./build/uim-transport-cli requests create --name=my-app --source=DEV \
      --url=https://repo/my-app-1.2.mtar --version=1.2 --export
./build/uim-transport-cli actions list --request=my-app
./build/uim-transport-cli stats --json
./build/uim-transport-cli metadata > ../frontend/localService/metadata.xml
./build/uim-transport-cli help                    # all commands
```

Nodes and requests can be addressed by ID or name. Global options: `--tenant`,
`--data-dir`, `--storage=memory`, `--user`, `--json`. Exit codes: `0` ok, `1`
failure (including imports with failed entries), `2` usage error.

### Desktop GUI

```sh
./build/uim-transport-gui [--tenant=default] [--data-dir=data]
```

Tabs: Overview (key figures), Landscape (topology tree), Nodes, Routes, Transport
Requests, Import Queues (node filter, import all / single entry, reset, toggle
selection, import log) and Audit Trail. The window refreshes every 15 s to pick up
changes made by the server or the CLI.

### Fiori app

Served by the backend at `http://localhost:8117/index.html` (local development,
`frontendDir`), or by the approuter on Cloud Foundry. Contents: KPI header bound
to the `Statistics` singleton, request status tiles, landscape list, tables for
nodes, routes, requests (with detail page: queue entries and history), import
queues (multi-select import / reset / delete, selection switch) and the audit
trail. Workflow buttons call the OData actions. `frontend/test/` holds QUnit
formatter tests and an OPA5 journey.

```sh
cd frontend && npm install && npm start     # ui5 serve (standalone, needs a backend proxy or mock)
```

### SAP BTP / Cloud Foundry

```sh
cd transport
mbt build && cf deploy mta_archives/uim-transport_2.0.0.mtar
```

Locally with XSUAA: start the backend, fill `approuter/default-env.json`
(git-ignored) and run `npm run start:local` in `approuter/` → <http://localhost:5000>.

Role collections: *UIM Transport Viewer* (read), *UIM Transport Operator*
(export/import/forward/reset), *UIM Transport Administrator* (landscape maintenance).

### Container / Kubernetes

```sh
# from the uim-platform repository root
docker build -f transport/backend/Dockerfile -t uim-platform/transport .
docker run -p 8117:8117 -v transport-data:/data uim-platform/transport

kubectl apply -f transport/k8s/
```

---

## Configuration

Precedence: compiled defaults → `config/default.json` (or `TM_CONFIG_FILE`) →
environment variables → `VCAP_SERVICES` (credentials of the service named or
tagged `transport-config`, highest priority).

| Key | Environment | Default | Description |
|---|---|---|---|
| `host` | `TM_HOST` (legacy `TRANSPORT_HOST`) | `0.0.0.0` | bind address |
| `port` | `TM_PORT`, `PORT` (legacy `TRANSPORT_PORT`) | `8117` | HTTP port |
| `logLevel` | `TM_LOG_LEVEL` | `info` | trace, debug, info, warn, error, none |
| `storage` | `TM_STORAGE` | `file` | `file` (shared JSON snapshots) or `memory` |
| `dataDir` | `TM_DATA_DIR` | `data` | snapshot directory |
| `defaultTenant` | `TM_DEFAULT_TENANT` | `default` | tenant without token / `X-Tenant-Id` |
| `odataPath` | `TM_ODATA_PATH` | `/odata/v4/transport` | OData service root |
| `autoImportIntervalMinutes` | `TM_AUTO_IMPORT_INTERVAL` | `0` (off) | auto-import worker period |
| `autoImportTenants` | `TM_AUTO_IMPORT_TENANTS` | `default` | tenants processed by the worker |
| `frontendDir` | `TM_FRONTEND_DIR` | `../frontend` | serve the Fiori app ("" = off) |

The tenant of a request comes from the XSUAA token (`zid`), else the `X-Tenant-Id`
header, else `defaultTenant`. **The backend decodes but does not verify JWT
signatures** — it relies on the approuter/XSUAA in front of it. Do not expose it
directly without adding signature verification.

---

## REST API (`/api/v1/transport`)

| Method | Path | Description |
|---|---|---|
| GET/POST | `/nodes` | list / create nodes |
| GET/PUT/DELETE | `/nodes/{id or name}` | read / update (`{"action": "enable" \| "disable" \| "check"}` or fields) / delete |
| GET/POST | `/routes` | list / create routes |
| GET/PUT/DELETE | `/routes/{id}` | read / update (`{"action": "enable" \| "disable"}` or fields) / delete |
| GET/POST | `/requests` | list / create (`"export": true` exports immediately) |
| GET/PUT/DELETE | `/requests/{id}` | read / `{"action": "export", "nodeId"?}` · `{"action": "forward", "fromNodeId"}` · `{"status": …}` · fields / delete (incl. queue entries) |
| GET/POST | `/queue-entries[?nodeId=…]` | list / enqueue manually |
| GET/PUT/DELETE | `/queue-entries/{id}` | read / `{"action": "reset" \| "select" \| "deselect"}` or `{"status": …}` / remove |
| GET/POST | `/actions` | audit trail (newest first) / record |
| GET/PUT | `/actions/{id}` | read / set `actionStatus` |
| POST | `/nodes-import` | import a queue: `{"nodeId", "entryIds"?: […]}` |
| GET | `/statistics` | key figures |
| GET | `/landscape` | nodes, routes and a text rendering of the topology |
| GET | `/api/v1/health` | health check |

## OData v4 (`/odata/v4/transport/`)

Entity sets `TransportNodes`, `TransportRoutes`, `TransportRequests`,
`ImportQueueEntries`, `TransportActions` (read-only except insert), singleton
`Statistics`, and the unbound actions `ExportRequest`, `ImportNode`,
`ForwardRequest`, `ResetQueueEntry`, `EnableNode`, `DisableNode`,
`CheckConnection`, `EnableRoute`, `DisableRoute` (all return `OperationResult`).
Supported: `$metadata` (with `Common.Label` and capability annotations), `$filter`
(eq ne gt ge lt le, and or not, contains startswith endswith tolower toupper),
`$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, `/$count`, PATCH
semantics. `$batch` is not supported — the UI5 model uses `groupId: "$direct"`.

```sh
curl -s 'localhost:8117/odata/v4/transport/TransportRequests?$filter=status eq '"'"'failed'"'"'&$select=name,errorMessage'
curl -s -X POST localhost:8117/odata/v4/transport/ImportNode -H 'Content-Type: application/json' \
     -d '{"nodeId": "<id>"}'
```

---

## Related SAP documentation

* [SAP Cloud Transport Management – What Is?](https://help.sap.com/docs/TRANSPORT_MANAGEMENT_SERVICE/7f7160ec0d8546c6b3eab72fb5ad6fd8/5fef9d6b1cb047b2b18d9eb57aa15352.html)
* [Feature Scope Description (PDF)](https://help.sap.com/doc/b5430836c20d4bd8a975cb4d48b4e7a5/Cloud/en-US/Transport_Management_FSD.pdf)
