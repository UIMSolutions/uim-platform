# Service Manager — UIM Platform

A service manager modelled on **SAP BTP Service Manager**. It is the central registry of runtime
**platforms** and **Open Service Broker (OSB)** compatible **service brokers**, and it keeps their
**catalog** of offerings and plans in sync. It provisions **service instances** and **bindings**,
tracks every broker call as an **operation**, and attaches **labels** to any resource.

The backend is written in D with vibe.d 0.10.3 and follows hexagonal (Clean) Architecture. One
EDM model drives four front ends that behave the same way:

| Front end | Entry point | Purpose |
|---|---|---|
| **OData v4** | `/odata/v4/service-manager` | SAP Fiori 3 UI (`$metadata` with UI annotations, `$batch`, `$filter`, `$search`, `$count`, actions) |
| **REST / JSON** | `/api/v1/service-manager` | scripts, other services, the legacy paths of v1 |
| **CLI** | `uim-service-manager-cli` | administration, automation, demo data |
| **GtkD GUI** | `uim-service-manager-gui` | desktop entity browser (GTK 3) |

All four call the same driving ports through the same `ODataEngine`. Validation, scopes, query
options and error codes are therefore identical everywhere.

## What it does

- **Platforms**: register Cloud Foundry, Kubernetes, Kyma, Neo or other environments. Credentials are write-only.
- **Service brokers**: register OSB brokers and **sync the catalog** (`GET /v2/catalog`, `X-Broker-API-Version: 2.17`). The sync creates and updates offerings and plans by catalog id, and it marks offerings the broker no longer advertises as `removed`. It can also run periodically in the background.
- **Catalog**: offerings (category, bindable, plan-updateable, tags) and plans (pricing, quota `maxInstances`, schemas).
- **Instances**: provisioning, plan and parameter updates, and deprovisioning, governed by a lifecycle state machine and provisioning rules.
- **Bindings**: created only for ready, usable and bindable instances. Credentials are generated when the caller supplies none.
- **Operations**: every create, update, delete, bind and unbind call is recorded. In **asynchronous** mode, operations stay `inProgress` until a broker callback finishes them (`CompleteOperation`).
- **Labels**: key/value pairs on any resource. A key is unique per resource, and labels are deleted together with their resource.
- **Statistics**: a singleton with tenant KPIs (ready, pending and failed instances; running and failed operations; and more).
- **Multi-tenancy**: each tenant is isolated, selected by the token, by `X-Tenant-Id`, or by `--tenant`.

### Business rules

| Rule | Error |
|---|---|
| Names are unique: platforms, brokers and instances per tenant; offerings per broker; plans per offering; bindings per instance | 409 Conflict |
| New instances need an `active` broker, an `available` offering, free plan quota and an `active` platform (if one is given) | 422 BusinessRuleViolation |
| A plan change must stay within the same offering, and the offering must be `planUpdateable` | 422 |
| Bindings need an instance in state `created`, a usable instance, and a bindable offering and plan | 422 |
| Delete is refused while the resource is still used: a platform hosting instances, a broker with instances, an offering with plans, a plan with instances, an instance with bindings, an operation that is still running | 422 |
| Lifecycle transitions are enforced (see [UML.md](UML.md#state-machines)) | 422 |
| Unknown properties, wrong EDM types, invalid enum values, invalid JSON text | 400 BadRequest |
| Broker unreachable, or broker returned an invalid catalog | 502 BadGateway |

## Layout

```
service-manager/
├── mta.yaml                    MTA: backend + approuter + XSUAA for SAP BTP (mbt build → cf deploy)
├── backend/                    D / vibe.d service
│   ├── dub.sdl                 configs: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json     default configuration
│   ├── tests/                  integration tests (dub test --config=defaultTest)
│   ├── Dockerfile, Containerfile
│   └── source/
│       ├── app.d  cli.d  gui.d             entry points (composition roots)
│       └── uim/platform/service_manager/
│           ├── domain/          entities, enumerations, types (ids, catalog), services
│           │                    (validation, lifecycle, provisioning policy, catalog reconciler), exceptions
│           ├── ports/           usecases (driving), services, repositories, gateways (driven), driving.d
│           ├── application/     usecases (interactors), services (operation tracker, statistics,
│           │                    resource directory, demo data), dtos
│           ├── persistence/     repositories (DocumentRepository), mappers, records, storages
│           ├── infrastructure/  configuration, security, clients (OSB), workers (catalog sync),
│           │                    logging, container (composition root)
│           └── presentation/    odata (EDM model, engine wiring, serializers), http (REST, health),
│                                cli, gui (GtkD), web (static Fiori app)
├── frontend/                   SAP Fiori 3 / UI5 app (view, controller, fragment, model, i18n, localService, test)
├── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only, git-ignored)
├── k8s/                        ConfigMap, Deployment (+PVC), Service
├── README.md  UML.md  NAFv4.md
```

## Build and run

Prerequisites: a D compiler (DMD 2.11x or LDC 1.40+) and DUB. The backend depends on
`uim-platform:service` from the repository root, using the path dependency `../..`.

```bash
cd service-manager/backend

dub build                      # server   → build/uim-service-manager-platform-service
dub build --config=cli         # CLI      → build/uim-service-manager-cli
dub build --config=gui         # GtkD GUI → build/uim-service-manager-gui (needs GTK 3 runtime)
dub test  --config=defaultTest # unit + integration tests
```

### Local development

```bash
cd service-manager/backend
./build/uim-service-manager-cli seed                 # demo platforms, broker, catalog, instance, binding
./build/uim-service-manager-platform-service         # http://localhost:8113
```

- Fiori app: <http://localhost:8113/app/index.html>, served from `../frontend` when `frontendDir` is set.
- OData: <http://localhost:8113/odata/v4/service-manager/$metadata>
- REST: <http://localhost:8113/api/v1/service-manager/service-instances>
- GUI: `./build/uim-service-manager-gui --refresh=5`

With `storage: "file"` (the default in `config/default.json`), the server, the CLI and the GUI
share the snapshot file `data/service-manager.json`. Changes made in one appear in the others.

Running through the approuter locally: fill in `approuter/default-env.json`, then run
`cd approuter && npm install && npm start`, and open <http://localhost:5000>.

### CLI

```bash
CLI=./build/uim-service-manager-cli
$CLI help
$CLI sets                                              # entity sets, singleton, actions
$CLI list ServiceInstances --filter="status eq 'created'" --orderby=name --select=name,status
$CLI create ServiceBrokers --name=my-broker --brokerUrl=https://broker.example.com --credentials=user:pw
$CLI sync-catalog <brokerId>            # or: sync-catalog --all
$CLI create ServiceInstances --name=orders-db --planId=<planId> --parameters='{"size":"S"}'
$CLI create ServiceBindings --name=orders-key --instanceId=<instanceId>
$CLI complete-operation <operationId> [--failed --error="broker timeout"]   # asynchronous mode
$CLI delete ServiceInstances <id> --yes
$CLI stats --json
$CLI config                              # effective configuration, secrets masked
```

Global options: `--tenant`, `--user`, `--json`, `--csv`, `--storage=memory|file`,
`--data-file=<path>`, `--config-dir=<dir>`, `--async`.
Exit codes: `0` ok, `1` business or protocol error, `2` usage error.

## HTTP interfaces

### OData v4: `/odata/v4/service-manager`

| Entity set | Key | Read scope | Write scope | Operations |
|---|---|---|---|---|
| `Platforms` | `id` | Read | Admin | CRUD |
| `ServiceBrokers` | `id` | Read | Admin | CRUD |
| `ServiceOfferings` | `id` | Read | Admin | CRUD |
| `ServicePlans` | `id` | Read | Admin | CRUD |
| `ServiceInstances` | `id` | Read | Write | CRUD (`DELETE` = deprovision) |
| `ServiceBindings` | `id` | Read | Write | create, read, delete (bindings are immutable) |
| `Operations` | `id` | Read | Admin | read, delete (final operations only) |
| `Labels` | `id` | Read | Write | CRUD |
| `Statistics` (singleton) | `tenantId` | Read | — | read |

Actions, which require the `Admin` scope:

- `POST SyncBrokerCatalog` with `{"brokerId": "…"}` returns a `CatalogSyncResult`.
- `POST CompleteOperation` with `{"operationId": "…", "succeeded": true, "errorMessage": "…"}` returns an `OperationResult`.

Supported: `$filter`, `$orderby`, `$select`, `$search`, `$top`, `$skip`, `$count`, `/$count`,
`$batch` (multipart and JSON), `Prefer: return=minimal`, `X-CSRF-Token: Fetch`. Server-driven paging
is limited by `maxPageSize`.

### REST: `/api/v1/service-manager`

| Method | Path | Result |
|---|---|---|
| GET | `/{resource}?filter=&orderby=&select=&search=&top=&skip=` | `{"items": [...], "totalCount": n}` |
| POST | `/{resource}` | 201 entity |
| GET | `/{resource}/{id}` | entity |
| PUT / PATCH | `/{resource}/{id}` | merged entity |
| DELETE | `/{resource}/{id}` | 204 |
| GET | `/statistics` | statistics |
| POST | `/service-brokers/{id}/sync` | catalog sync result |
| POST | `/operations/{id}/complete` | operation result (body: `succeeded`, `errorMessage`) |
| GET | `/health`, `/api/v1/service-manager/health` | `{"status": "UP", ...}` |

`{resource}` is one of `platforms`, `service-brokers`, `service-offerings`, `service-plans`,
`service-instances`, `service-bindings`, `operations`, `labels`. Errors have the form
`{"error": {"code": "...", "message": "..."}}` and carry the HTTP status from the rules table above.

## Configuration

Precedence, lowest first: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json`
→ `SERVICE_MANAGER_*` environment variables → Cloud Foundry `PORT` / `VCAP_SERVICES` → command line
options (CLI and GUI).

| Key | Environment variable | Default | Meaning |
|---|---|---|---|
| `host` / `port` | `SERVICE_MANAGER_HOST` / `_PORT` | `0.0.0.0` / `8113` | listen address |
| `storage` | `SERVICE_MANAGER_STORAGE` | `memory` (`file` in default.json) | `memory` or `file` |
| `dataFile` | `SERVICE_MANAGER_DATA_FILE` | `data/service-manager.json` | JSON snapshot of the file store |
| `defaultTenant` | `SERVICE_MANAGER_DEFAULT_TENANT` | `default` | tenant if neither token nor header names one |
| `restPath` / `odataPath` | `…_REST_PATH` / `…_ODATA_PATH` | `/api/v1/service-manager` / `/odata/v4/service-manager` | service roots |
| `maxPageSize` | `…_MAX_PAGE_SIZE` | `200` | server-driven paging |
| `syncProvisioning` | `…_SYNC_PROVISIONING` | `true` | `false` = asynchronous operations |
| `brokerApiVersion` / `brokerTimeoutSeconds` | `…_BROKER_API_VERSION` / `…_BROKER_TIMEOUT_SECONDS` | `2.17` / `10` | OSB client |
| `catalogSyncMinutes` / `catalogSyncTenants` | `…_CATALOG_SYNC_MINUTES` / `…_CATALOG_SYNC_TENANTS` | `0` / `["default"]` | background catalog sync (`0` = off) |
| `requireAuthentication` / `jwtSecret` | `…_REQUIRE_AUTHENTICATION` / `…_JWT_SECRET` | `false` / `""` | HS256 bearer tokens outside BTP |
| `frontendDir` | `…_FRONTEND_DIR` | `../frontend` | serve the Fiori app at `/app` (`""` = off) |

**Security**: when an XSUAA service is bound (`VCAP_SERVICES`), tokens are verified with RS256 and
the scopes `Read`, `Write` and `Admin` are enforced. Without XSUAA, `requireAuthentication` together
with `jwtSecret` enables HS256. Otherwise the service is open for local development, and the
tenant and user come from the `X-Tenant-Id` and `X-User-Id` headers.

## Deployment

**SAP BTP / Cloud Foundry**

```bash
mbt build && cf deploy mta_archives/uim-service-manager_2.0.0.mtar
```

Assign the role collections `ServiceManagerViewer`, `ServiceManagerDeveloper` or `ServiceManagerAdministrator`.

**Docker / Podman** (build context: the repository root)

```bash
docker build -f service-manager/backend/Dockerfile -t uim-platform/service-manager .
docker run -p 8113:8113 -v sm-data:/data uim-platform/service-manager
```

**Kubernetes**: `kubectl apply -f k8s/`. This creates a ConfigMap, a Deployment with a PVC on `/data`, and a ClusterIP Service on port 8113.

> The JSON file store is single-writer and keeps the whole data set in one file. Use it for
> development, demos and single-node setups. For production, add a database-backed
> `IDocumentStore` (a driven port of `uim-platform:service`). Nothing above the persistence
> layer changes.

## Testing

- `dub test --config=defaultTest` runs the domain unit tests, the mapper and repository tests, the
  config tests, the OSB parser tests, the CLI end-to-end test, and `tests/lifecycle.d`. The
  lifecycle suite covers asynchronous provisioning, quotas, retired offerings, label cascades,
  write-only secrets and tenant isolation.
- Frontend: `frontend/test/testsuite.qunit.html` (formatter unit tests, OPA5 journey).

## Changes in 2.0

- Moved to the `backend/`, `frontend/`, `approuter/` layout with `mta.yaml`.
- Added an OData v4 endpoint, a CLI, a GtkD GUI and a SAP Fiori 3 app. All of them, and REST, go through one engine.
- Added real business rules: a lifecycle state machine, provisioning policy, quotas, referential integrity and unique names.
- Added OSB catalog sync with reconciliation and an optional background worker.
- Added asynchronous operations with `CompleteOperation`. Synchronous mode remains the default.
- Added a persistent, shared file store, replacing the in-memory-only store.
- Added typed configuration with the environment, profile and VCAP layers, and XSUAA/HS256 security.
- Secrets of platforms and brokers are now write-only.
- REST: deletes answer `204`, lists answer `{items, totalCount}`, and errors use a uniform `{error: {code, message}}` body.
  The `POST /operations` endpoint was removed, because operations are created by the service.

## License

Apache-2.0
