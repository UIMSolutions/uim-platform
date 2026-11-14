# UIM ABAP Environment Service

A D/vibe.d service modelled on **SAP BTP, ABAP environment** (Steampunk): provision
ABAP systems and manage what lives in them — gCTS software components, communication
arrangements, RAP service bindings, business roles and users, transport requests and
application jobs. A built-in **reconciler** drives the asynchronous parts of the
lifecycle (provisioning, upgrades, deprovisioning, clone/pull, transport imports and
job runs) against a pluggable landscape gateway.

One hexagonal core, four driving adapters:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST `/api/v1` | `uim-abap-environment-platform-service` | JSON API for scripts and other services |
| OData v4 `/odata/v4/abap-environment` | `uim-abap-environment-platform-service` | SAP Fiori 3 / UI5 frontend |
| CLI | `uim-abap-cli` | administration and automation |
| GtkD GUI | `uim-abap-gui` | desktop client |

Server, CLI and GUI share the same snapshot storage (`backend/data/*.json`), so a
change made in one is visible in the others.

## Project layout

```
abap-environment/
├── mta.yaml                    MTA descriptor (backend + approuter + XSUAA) for SAP BTP / Cloud Foundry
├── backend/                    D 2.11x / vibe.d 0.10.3
│   ├── dub.sdl                 configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json     default configuration
│   └── source/
│       ├── app.d · cli.d · gui.d                  composition roots
│       └── uim/platform/abap_environment/
│           ├── domain/          entities, types (ids, value objects), enumerations,
│           │                    services (names & SIDs, system lifecycle, communication
│           │                    policy, transport policy, job schedule, service URLs), exceptions
│           ├── ports/           usecases, services (driving) · repositories, storages,
│           │                    messaging, gateways (driven)
│           ├── application/     usecases (one interactor per aggregate + reconcile),
│           │                    services (cascade deletion, statistics), dtos (specs, requests)
│           ├── persistence/     repositories, storages (JSON snapshot files, memory),
│           │                    mappers (reflection based), records (collections, envelope)
│           ├── infrastructure/  configuration, logging, security (XSUAA identity),
│           │                    clients (simulated landscape), workers (reconciler), container (DI)
│           ├── presentation/    resources (protocol-neutral adapters + registry), http (REST),
│           │                    odata (model, $metadata, query engine, controller), cli, gui, web
│           └── helpers/         codec (struct ⇄ JSON reflection), enums, json, time
├── frontend/                   SAP Fiori 3 / UI5 app (uim.abap)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/           $metadata and mock data captured from the backend
│   └── test/                   QUnit (formatter) and OPA5 journey
└── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
```

## Domain model

| Aggregate | Parent | Lifecycle (reconciler) | Notable rules |
|---|---|---|---|
| `SystemInstance` | tenant | provisioning → active; updating → active; deleting → removed | unique name and SID per tenant; SID = 3 chars, letter first, not SAP-reserved (derived from the name if empty); sizes are multiples of 16 GB; one free-plan system per tenant; resize/upgrade only when active; deletion cascades |
| `SoftwareComponent` | system | cloning → cloned; pulling → cloned (error if the branch cannot be read) | needs an active system; ABAP name (`ZTRAVEL`, `/DMO/FLIGHT`) matching its namespace; http(s) repository; repository fixed after the first clone; branch changes via checkout |
| `CommunicationArrangement` | system | — | scenario `SAP_COM_nnnn` or customer `Z…`/`Y…`; credentials required per auth method; inbound needs authentication; one arrangement per scenario and communication system; **password and client secret are masked** |
| `ServiceBinding` | system | — | created **unpublished**; ABAP names; service and `$metadata` URL derived from type, definition and version; type/definition change only while unpublished; published bindings cannot be deleted |
| `BusinessRole` | system | — | ABAP name; catalogs normalised and de-duplicated; restricted ⇔ restriction types; cannot be deleted while assigned |
| `BusinessUser` | system | — | unique user name and e-mail per system; roles by id or name of the same system; lock/unlock, password reset |
| `TransportRequest` | source system | importing → imported \| error (waits for an active target) | number `<SID>K9nnnnn`; target ≠ source; tasks `R3TR/LIMU <type> <name>`; all tasks released (and objects present) before the request; only modifiable requests change or delete |
| `ApplicationJob` | system | due → running → completed \| failed; recurring → scheduled | ABAP template name; 5-field cron validation; unique parameter names; history capped at 20 runs |

## Build and run

```sh
cd abap-environment/backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:10001/
dub run                                   # = --config=defaultRun

# Command line interface
dub build --config=cli
./build/uim-abap-cli systems create --name=dev --admin-email=admin@example.com
./build/uim-abap-cli systems create --name=prd --admin-email=admin@example.com --plan=production
./build/uim-abap-cli reconcile            # provisioning → active (the server does this every 10 s)
./build/uim-abap-cli software-components create --systemInstanceId=dev --name=ZTRAVEL \
    --repository-url=https://github.com/acme/ztravel.git
./build/uim-abap-cli software-components clone ZTRAVEL
./build/uim-abap-cli transports create --sourceSystemId=dev --targetSystemId=prd \
    --description="Travel app" --owner=DEV
./build/uim-abap-cli transports add-task DEVK900001 --objects="R3TR CLAS ZCL_TRAVEL,R3TR DDLS ZI_TRAVEL"
./build/uim-abap-cli transports release-task DEVK900001 --task=DEVK900001-01
./build/uim-abap-cli transports release DEVK900001
./build/uim-abap-cli transports import DEVK900001
./build/uim-abap-cli stats --json

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub run --config=gui -- --tenant=default

# Unit tests (domain rules, codec, persistence, use cases, adapters, an end-to-end scenario)
dub test --config=defaultTest
```

`uim-abap-cli help` lists every command; `<resource> fields` shows the settable fields.
Objects are addressed by id or by unique name everywhere.

### Fiori app

With the server running, open <http://localhost:10001/index.html>: KPI header and
overview tiles (`Statistics` singleton), one tab per entity set with create, delete,
search and all lifecycle actions, and a system object page with the system's
components, bindings, arrangements, users, roles, transports and jobs.
`frontend/localService` holds `$metadata` and mock data captured from the backend, and
`npm test` in `frontend/` serves the QUnit/OPA5 test suite.

### Deploy to SAP BTP (Cloud Foundry)

```sh
mbt build && cf deploy mta_archives/uim-abap-environment_1.0.0.mtar
```

`mta.yaml` deploys the backend (binary buildpack), the approuter (serving the Fiori app)
and an XSUAA instance (`approuter/xs-security.json`: roles AbapViewer, AbapDeveloper,
AbapAdmin). Locally, run the approuter with `approuter/default-env.json`
(simulated `VCAP_SERVICES`; git-ignored, never deployed).

## Configuration

Precedence (lowest → highest): compiled defaults → `config/default.json`
(or `ABAP_CONFIG_FILE`) → environment variables → `VCAP_SERVICES` credentials of a
service named or tagged `abap-config`.

| Key | Env variable | Default | Description |
|---|---|---|---|
| `host` | `ABAP_HOST` | `0.0.0.0` | bind address |
| `port` | `ABAP_PORT` / `PORT` | `10001` | listen port |
| `logLevel` | `ABAP_LOG_LEVEL` | `info` | trace, debug, info, warn, error, none |
| `storage` | `ABAP_STORAGE` | `file` | `file` (JSON snapshots) or `memory` |
| `dataDir` | `ABAP_DATA_DIR` | `data` | snapshot directory (shared by server, CLI, GUI) |
| `defaultTenant` | `ABAP_DEFAULT_TENANT` | `default` | tenant if no token / `X-Tenant-Id` |
| `odataPath` | `ABAP_ODATA_PATH` | `/odata/v4/abap-environment` | OData service root |
| `reconcileIntervalSeconds` | `ABAP_RECONCILE_INTERVAL` | `10` | reconciler period, 0 = off |
| `reconcileTenants` | `ABAP_RECONCILE_TENANTS` | `default` | tenants reconciled by the server |
| `frontendDir` | `ABAP_FRONTEND_DIR` | `../frontend` | serve the Fiori app ("" = off) |

CLI and GUI accept `--data-dir`, `--storage` and `--tenant` on top.

**Identity:** tenant and user come from the XSUAA bearer token (`zid`, `user_name`) or the
`X-Tenant-Id` / `X-User-Id` headers. The backend decodes but does **not verify** the JWT
signature; it relies on the approuter. Do not expose the backend directly without adding
signature verification.

**Secrets:** communication passwords and client secrets are masked (`********`) in every
adapter, and sending the mask back keeps the stored value. They are, however, stored in
plain text in the snapshot files — protect `dataDir`, or move secrets to the credential
store before using real credentials.

## REST API (`/api/v1`)

| Method | Path | Description |
|---|---|---|
| GET | `/{resource}[?field=value…]` | list → `{ "items": [...], "count": n }`, filtered by payload fields |
| POST | `/{resource}` | create → 201 with the resource |
| GET | `/{resource}/{id}` | read |
| PATCH / PUT | `/{resource}/{id}` | partial update (unspecified fields keep their value) |
| DELETE | `/{resource}/{id}` | delete → 204 (systems: deprovisioning starts) |
| POST | `/{resource}/{id}/{action}` | lifecycle action, parameters as JSON body |
| GET | `/statistics` | figures of the tenant |
| POST | `/reconcile` | run one reconciliation pass |
| GET | `/resources` | catalogue: paths, input fields, actions and their parameters |
| GET | `/health` | health check |

| Resource | Actions (parameters) |
|---|---|
| `systems` | `suspend`, `resume`, `upgrade` (`softwareVersion`) |
| `software-components` | `clone`, `pull`, `checkout` (`branch`) |
| `communication-arrangements` | `activate`, `deactivate` |
| `service-bindings` | `publish`, `unpublish`, `deprecate` |
| `business-roles` | `add-catalog`, `remove-catalog` (`catalog`) |
| `business-users` | `lock`, `unlock`, `reset-password`, `assign-role`, `unassign-role` (`role`) |
| `transports` | `add-task` (`objects`, `owner`, `description`), `release-task` (`task`), `release`, `import` |
| `application-jobs` | `run`, `cancel`, `reactivate` |

System references (`systemInstanceId`, `sourceSystemId`, `targetSystemId`) accept an id
or a unique system name. Errors: `{ "error": { "code": "Conflict", "message": "…" } }`
with 400 (bad input), 404, 409 (state or duplicate), 422 (business rule).

## OData v4 (`/odata/v4/abap-environment`)

Generated from the same resource catalogue as REST:

- Entity sets `Systems, SoftwareComponents, CommunicationArrangements, ServiceBindings,
  BusinessRoles, BusinessUsers, TransportRequests, ApplicationJobs` with GET, POST, PATCH, DELETE
- Singleton `Statistics`; complex types `ComponentCommit, CommunicationEndpoint,
  ExposedEndpoint, RoleAssignment, TransportTask, JobExecutionLog, KeyValue, ReconcileResult`
- Unbound action `Reconcile` and one action per lifecycle action, named
  `<Action><EntityType>`: `SuspendSystem`, `UpgradeSystem`, `CloneSoftwareComponent`,
  `PublishServiceBinding`, `AssignRoleBusinessUser`, `ReleaseTaskTransportRequest`,
  `ImportTransportRequest`, `RunApplicationJob`, … (parameter `id` plus the action's parameters)
- Query options `$filter` (eq ne gt ge lt le, and or not, contains startswith endswith,
  tolower toupper), `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, `/$count`
- `$metadata` with `Common.Label` and capability annotations
- No `$batch`: the UI5 model uses `groupId: "$direct"`.

## Changes from the previous version

The service was rebuilt on the hexagonal layout shared with `kyma` and `management`.

- **Layout:** the module moved to `abap-environment/backend` (root `dub.sdl`:
  `subPackage "abap-environment/backend"`); new `frontend/`, `approuter/` and `mta.yaml`.
- **Persistence:** in-memory only → JSON snapshots shared by server, CLI and GUI (`storage=memory` keeps the old behaviour).
- **Action routes:** `/api/v1/<resource>/<verb>/{id}` → `/api/v1/<resource>/{id}/<verb>`
  (e.g. `/transports/release/{id}` → `/transports/{id}/release`; `/transports/tasks/{id}` → `/transports/{id}/add-task`).
- **Payloads:** `ServiceBinding.instanceId` → `systemInstanceId`, `definitionId` → `serviceDefinition`;
  `BusinessUser.username` → `name`, `roleIds` → `roles`; `BusinessRole.assignedCatalogs` → `businessCatalogs`;
  `ApplicationJob.jobParameters` (object) → `parameters` (`[{key, value}]`, objects are still accepted);
  timestamps are ISO 8601 strings.
- **Enumerations:** binding types `odataV4Ui/odataV4WebApi/odataV2Ui/odataV2WebApi/soapHttp/restHttp/sqlWebApi/inboundRfc`;
  binding status `unpublished/published/deprecated`; component types `development/businessConfiguration`;
  transport status gains `importing`; direction gains `both`.
- **Behaviour:** service bindings start unpublished; deleting a system is asynchronous and
  cascades; transports are numbered `<SID>K9nnnnn`; secrets are masked.
- **Fixed:** releasing a transport task did not persist (the loop changed a copy);
  multi-error messages were assembled incorrectly; the README stated port 10000 while the service used 10001.

## Architecture notes

- **Reflection codec.** Persistence records, REST/OData payloads, OData `$metadata`,
  CLI tables and GUI forms are all derived from the domain structs at compile time
  (`helpers/codec.d`). Adding a field to an entity and its spec makes it available in every
  adapter. `decode(patch, base)` provides PATCH semantics.
- **Resource registry.** `presentation/resources` wraps each driving port in a
  protocol-neutral adapter (JSON in/out, columns, actions, secret masking). REST, OData,
  CLI and GUI are thin protocol layers on top of it.
- **Landscape gateway.** The reconciler talks to `IAbapLandscapeGateway` (provisioning,
  gCTS, transport import, job runtime). The default `SimulatedLandscapeGateway` derives
  results deterministically — repository URLs containing `invalid` fail to clone, transports
  whose description contains `[fail]` fail to import, and the job parameter
  `simulateReturnCode=<n>` sets a run's return code. Real clients can be plugged in
  without touching the use cases.
- **Snapshot storage.** One JSON file per collection, written atomically (temp file +
  rename) and reloaded when another process changed it. Suitable for local and
  single-instance use, not for concurrent writers at scale.

See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the NAF v4 architecture description.

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
