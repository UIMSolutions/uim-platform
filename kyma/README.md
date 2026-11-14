# UIM Kyma Runtime Service

A D/vibe.d service modelled on **SAP BTP, Kyma runtime**: provision Kyma runtimes
(managed Kubernetes clusters), manage namespaces, Kyma modules, serverless functions,
API rules, BTP service instances and bindings, eventing subscriptions and connected
applications. A built-in **reconciler** moves resources through their lifecycle like
the Kyma control plane does, and every workload can be rendered as the Kubernetes
custom resource Kyma would apply.

One hexagonal core, four driving adapters:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST `/api/v1` | `uim-kyma-platform-service` | JSON API for scripts and other services |
| OData v4 `/odata/v4/kyma` | `uim-kyma-platform-service` | SAP Fiori 3 / UI5 frontend |
| CLI | `uim-kyma-cli` | administration and automation |
| GtkD GUI | `uim-kyma-gui` | desktop client |

Server, CLI and GUI share the same snapshot storage (`backend/data/*.json`), so a
change made in one is visible in the others.

## Project layout

```
kyma/
├── mta.yaml                    MTA descriptor (backend + approuter + XSUAA) for SAP BTP / Cloud Foundry
├── backend/                    D 2.11x / vibe.d 0.10.3
│   ├── dub.sdl                 configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json     default configuration
│   └── source/
│       ├── app.d · cli.d · gui.d                  composition roots
│       └── uim/platform/kyma/
│           ├── domain/          entities, types (ids, value objects, quantities), enumerations,
│           │                    services (validators, plan policy, module catalogue, lifecycle,
│           │                    manifests), exceptions
│           ├── ports/           usecases, services (driving) · repositories, storages,
│           │                    messaging, gateways (driven)
│           ├── application/     usecases (one interactor per aggregate + reconcile),
│           │                    services (cascade deletion, statistics), dtos (specs, requests)
│           ├── persistence/     repositories, storages (JSON snapshot files, memory),
│           │                    mappers (reflection based), records (collections, envelope)
│           ├── infrastructure/  configuration, logging, security (XSUAA identity),
│           │                    clients (cluster gateway), workers (reconciler), container (DI)
│           ├── presentation/    resources (protocol-neutral adapters + registry), http (REST),
│           │                    odata (model, $metadata, query engine, controller), cli, gui, web
│           └── helpers/         codec (struct ⇄ JSON reflection), enums, json, time
├── frontend/                   SAP Fiori 3 / UI5 app (uim.kyma)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/metadata.xml   generated $metadata for offline development
│   └── test/                   QUnit (formatter) and OPA5 journeys
└── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
```

## Domain model

| Aggregate | Parent | Lifecycle (reconciler) | Notable rules |
|---|---|---|---|
| `KymaEnvironment` | tenant | provisioning → running; stopping → stopped; updating → running | plan limits (nodes, regions), trial/free expiry, default modules istio + api-gateway + btp-operator, delete cascades |
| `KymaNamespace` | environment | — | DNS-1123 name, reserved names (`kyma-system`, …), quota validation, delete cascades |
| `ServerlessFunction` | namespace | building → deploying → running | needs **serverless** module; replicas, timeout, env var names, CPU/memory request ≤ limit, dependency format per runtime |
| `ApiRule` | namespace | notReady → ok | needs **api-gateway**; host defaults to `<name>.<cluster domain>` and is unique per runtime; JWT rules need https issuers |
| `ServiceInstance` | namespace | creating/updating → ready | needs **btp-operator**; cannot be deleted while bindings exist |
| `ServiceBinding` | service instance | creating → ready (after its instance) | secret name, credential keys, maintains the instance's binding count |
| `EventSubscription` | namespace | pending → active; pause / resume | needs **eventing** (which needs **nats**); sink derived from a service reference |
| `KymaModule` | environment | installing → enabled; uninstalling → disabled | dependency checks on enable, dependents and remaining workloads block disable |
| `KymaApplication` | environment | pairing → connected | needs **application-connector**; bind/unbind namespaces |

Business errors are mapped consistently in every adapter: **404** not found,
**409** conflict (duplicate, wrong state, missing module), **422** business rule violated,
**400** malformed input.

## Build and run

The backend depends on the parent package `uim-platform:service` (`path="../.."`).

```sh
cd kyma/backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:8095/
dub run                         # = --config=defaultRun

# Command line interface
dub build --config=cli
./build/uim-kyma-cli help
./build/uim-kyma-cli environments create --name=dev --plan=azure
./build/uim-kyma-cli namespaces create --environmentId=dev --name=shop --labels=team=orders
./build/uim-kyma-cli modules create --environmentId=dev --moduleType=serverless
./build/uim-kyma-cli functions create --namespaceId=shop --name=hello --sourceCode=@handler.js
./build/uim-kyma-cli reconcile          # or let the server's reconciler run
./build/uim-kyma-cli functions list --namespaceName=shop
./build/uim-kyma-cli functions manifest hello   # Function CR as JSON
./build/uim-kyma-cli stats --json

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub run --config=gui -- --tenant=default

# Unit tests (domain rules, codec, persistence, use cases, adapters, an end-to-end scenario)
dub test
```

CLI conventions: every resource supports `list | get | create | update | delete |
manifest | fields | <action>`; ids or unique names are accepted; `--kebab-case`
options equal `--camelCase` fields; lists are comma separated, labels `k=v,k2=v2`,
structured fields (API rule `rules`, application `apis`) JSON; `@file` reads a value
from a file; `--json` gives machine readable output. Exit codes: 0 ok, 1 failed, 2 usage.

### Fiori app

Served by the backend at `/` for local development (`frontendDir`, default
`../frontend`). The app uses relative service URLs (`odata/v4/kyma/`), so the same
build works behind the approuter. It shows a KPI header (Statistics singleton), one tab
per resource with create / delete / lifecycle actions, the Kubernetes manifest of the
selected entry, a **Reconcile** button, and an environment object page with its
modules, namespaces and applications.

```sh
cd frontend && npm install && npm start     # UI5 tooling, uses localService/metadata.xml offline
```

### Deploy to SAP BTP (Cloud Foundry)

```sh
mbt build && cf deploy mta_archives/uim-kyma_1.0.0.mtar
```

`mta.yaml` deploys the backend (binary buildpack), the approuter (serving the Fiori app)
and an XSUAA instance (`approuter/xs-security.json`: roles KymaViewer, KymaDeveloper,
KymaAdmin). Locally, run the approuter with `approuter/default-env.json`
(simulated `VCAP_SERVICES`; git-ignored, never deployed).

## Configuration

Precedence (lowest → highest): compiled defaults → `config/default.json`
(or `KYMA_CONFIG_FILE`) → environment variables → `VCAP_SERVICES` credentials of a
service named or tagged `kyma-config`.

| Key | Env variable | Default | Description |
|---|---|---|---|
| `host` | `KYMA_HOST` | `0.0.0.0` | bind address |
| `port` | `KYMA_PORT` / `PORT` | `8095` | listen port |
| `logLevel` | `KYMA_LOG_LEVEL` | `info` | trace, debug, info, warn, error, none |
| `storage` | `KYMA_STORAGE` | `file` | `file` (JSON snapshots) or `memory` |
| `dataDir` | `KYMA_DATA_DIR` | `data` | snapshot directory (shared by server, CLI, GUI) |
| `defaultTenant` | `KYMA_DEFAULT_TENANT` | `default` | tenant if no token / `X-Tenant-Id` |
| `odataPath` | `KYMA_ODATA_PATH` | `/odata/v4/kyma` | OData service root |
| `reconcileIntervalSeconds` | `KYMA_RECONCILE_INTERVAL` | `10` | reconciler period, 0 = off |
| `reconcileTenants` | `KYMA_RECONCILE_TENANTS` | `default` | tenants reconciled by the server |
| `frontendDir` | `KYMA_FRONTEND_DIR` | `../frontend` | serve the Fiori app ("" = off) |

CLI and GUI accept `--data-dir`, `--storage` and `--tenant` on top.

**Identity:** tenant and user come from the XSUAA bearer token (`zid`, `user_name`) or the
`X-Tenant-Id` / `X-User-Id` headers. The backend decodes but does **not verify** the JWT
signature; it relies on the approuter. Do not expose the backend directly without adding
signature verification.

## REST API (`/api/v1`)

| Method | Path | Description |
|---|---|---|
| GET | `/{resource}[?field=value…]` | list → `{ "items": [...], "count": n }`, filtered by payload fields |
| POST | `/{resource}` | create → 201 with the resource |
| GET | `/{resource}/{id}` | read |
| PATCH / PUT | `/{resource}/{id}` | partial update (unspecified fields keep their value) |
| DELETE | `/{resource}/{id}` | delete → 204 |
| GET | `/{resource}/{id}/manifest` | Kubernetes custom resource |
| POST | `/{resource}/{id}/{action}` | lifecycle action |
| GET | `/statistics` | figures of the tenant |
| POST | `/reconcile` | run one reconciliation pass |
| GET | `/resources` | catalogue: paths, input fields, actions |
| GET | `/health` | health check |

Resources and actions: `environments` (start, stop), `namespaces`, `functions`,
`api-rules`, `service-instances`, `service-bindings`, `event-subscriptions`
(pause, resume), `modules` (enable, disable), `applications` (connect, disconnect,
bind, unbind — the latter two with `{"namespace": "<name>"}`).

Errors: `{ "error": { "code": "Conflict", "message": "…" } }`.

> Breaking change: the former action routes `/api/v1/<resource>/<verb>/{id}` are now
> `/api/v1/<resource>/{id}/<verb>`.

## OData v4 (`/odata/v4/kyma`)

Generated from the same resource catalogue as REST:

- Entity sets `Environments, Namespaces, Functions, ApiRules, ServiceInstances,
  ServiceBindings, EventSubscriptions, Modules, Applications` with GET, POST, PATCH, DELETE
- Singleton `Statistics`; complex types `KeyValue, ApiRuleEntry, AppApiEntry, AppEventEntry, ReconcileResult`
- Unbound actions `Reconcile`, `StartEnvironment`, `StopEnvironment`, `PauseEventSubscription`,
  `ResumeEventSubscription`, `EnableModule`, `DisableModule`, `ConnectApplication`,
  `DisconnectApplication`, `BindApplication`, `UnbindApplication` (parameter `id`, plus `namespace`)
- Query options `$filter` (eq ne gt ge lt le, and or not, contains startswith endswith,
  tolower toupper), `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, `/$count`
- `$metadata` with `Common.Label` and capability annotations
- No `$batch`: the UI5 model uses `groupId: "$direct"`.

## Architecture notes

- **Reflection codec.** Persistence records, REST/OData payloads, OData `$metadata`,
  CLI tables and GUI forms are all derived from the domain structs at compile time
  (`helpers/codec.d`). Adding a field to an entity and its spec makes it available in every
  adapter. `decode(patch, base)` provides PATCH semantics.
- **Resource registry.** `presentation/resources` wraps each driving port in a
  protocol-neutral adapter (JSON in/out, columns, actions). REST, OData, CLI and GUI are
  thin protocol layers on top of it.
- **Cluster gateway.** Interactors hand rendered custom resources to `IClusterGateway`.
  The default `RecordingClusterGateway` only records them; a kube-apiserver client can be
  plugged in without touching the use cases.
- **Snapshot storage.** One JSON file per collection, written atomically (temp file +
  rename) and reloaded when another process changed it. Suitable for local and
  single-instance use, not for concurrent writers at scale.

See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the NAF v4 architecture description.

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
