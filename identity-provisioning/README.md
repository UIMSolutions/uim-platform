# UIM Identity Provisioning Service

A D / vibe.d 0.10.3 service modelled on **SAP Cloud Identity Services — Identity
Provisioning (IPS)** for the UIM Platform. It reads users and groups from
**source systems** (SuccessFactors, SAP HCM, LDAP, Microsoft Entra ID, CSV, ...),
filters and maps their attributes with **transformations**, and writes them to
**target systems** (Identity Authentication, SCIM applications, LDAP, ...) in
**provisioning jobs** — on demand or on a schedule, as full, delta or simulated
runs. Every operation is recorded in an audit **log**; the **provisioned
entities** form the delta state that keeps repeated runs cheap.

One hexagonal core, five driving adapters:

| Adapter | Entry point | For |
|---|---|---|
| REST (JSON) | `/api/v1/...` | automation, scripts, the previous API |
| OData v4 | `/odata/v4/identity-provisioning` | the SAP Fiori 3 app (`frontend/`) |
| Fiori 3 / UI5 app | `frontend/` (served by the approuter, or by the backend locally) | administrators |
| CLI | `uim-ips-cli` | operators, CI, bulk setup |
| Desktop GUI (GtkD 3) | `uim-ips-gui` | local administration |

Server, CLI and GUI share the same JSON snapshot store, so a job run from the
CLI shows up in the Fiori app and the GUI immediately.

## Project layout

```
identity-provisioning/
├── mta.yaml                    MTA descriptor (backend + approuter + XSUAA) for SAP BTP / Cloud Foundry
├── backend/                    D / vibe.d service
│   ├── dub.sdl                 configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json     default configuration (overridden by IPS_* and VCAP_SERVICES)
│   ├── Dockerfile, Containerfile
│   └── source/
│       ├── app.d  cli.d  gui.d entry points (composition roots)
│       └── uim/platform/identity_provisioning/
│           ├── domain/         entities, types, enumerations, exceptions,
│           │                   services (transformer, planner, catalog, lifecycle, systems, names)
│           ├── ports/          usecases, services, repositories, storages, gateways, messaging
│           ├── application/    use cases (systems, transformations, jobs, monitoring),
│           │                   services (runner, statistics, catalog, demo data, events), dtos
│           ├── persistence/    repositories, storages (JSON files, memory), mappers, records
│           ├── infrastructure/ configuration, logging, security (XSUAA identity),
│           │                   clients (simulated connector), workers (scheduler), container
│           ├── presentation/   resources (protocol-neutral adapters + registry), http (REST),
│           │                   odata (v4 + $metadata), cli, gui (GtkD), web (Fiori dev server)
│           └── helpers/        reflection codec, enums, JSON, time
├── frontend/                   SAP Fiori 3 / UI5 app (uim.identityprovisioning)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/           metadata.xml + mock data (generated from the backend)
│   └── test/                   QUnit (formatter) and OPA5 (journeys)
├── approuter/                  @sap/approuter: XSUAA login, routes, roles
└── k8s/                        ConfigMap, Deployment, Service
```

## Domain model

| Aggregate | Purpose |
|---|---|
| `SourceSystem` | where identities are read from — type, URL, authentication, connector properties |
| `TargetSystem` | where identities are written to |
| `ProxySystem` | exposes the engine to an external identity management system (SCIM) |
| `Transformation` | attribute mappings + entity filter conditions of one system (read or write side) |
| `ProvisioningJob` | source → target synchronisation: type, schedule, figures of the last run |
| `ProvisionedEntity` | a user or group as last written to a target — the delta state |
| `ProvisioningLog` | immutable audit entry: one operation on one entity in one run |
| `SystemType` (reference data) | connector catalogue: ias, ldap, sapHr, successFactors, scim, csv, azureAd, custom |

### How a run works

1. **Read** all users and groups of the source (`IIdentityConnector.read`).
2. **Transform**: the source's read transformations, then the target's write
   transformations, in `sequence` order. A failing *condition* skips the entity
   (logged as `skipped`); an empty *mandatory* mapping fails it (`failed`).
3. **Plan** against the delta state (`planOperations`):
   - `full` — create new, update every existing entity, delete vanished ones
   - `delta` — create new, update changed (checksum) or previously failed, skip unchanged, delete vanished
   - `simulate` — the delta plan, logged as `simulated`, nothing is written
4. **Write** each operation to the target (`write` / `remove`); connector errors fail
   only that entity.
5. **Persist** delta state and log in one batch per collection; update the job
   figures (`read · created · updated · deleted · skipped · failed`), the system
   sync timestamps and the next scheduled run.

### Rules

- System names are unique per role; the system type must support the role
  (e.g. CSV and SAP HCM are source-only).
- URLs are validated per type (`https://` for IAS/SCIM/SuccessFactors/Graph,
  `ldap(s)://` for LDAP, `file://` for CSV); basic and OAuth authentication need a user / client id.
- **Activate** tests the connection: success → `active`, failure → `error` (HTTP 409 with the reason).
  Changing URL, type or credentials of an active system requires a new test (`configuring`).
- Jobs run only when both systems are active; running jobs cannot be changed or deleted;
  cancelled jobs must be resumed first. **Reset delta** forgets the provisioned state.
- Systems referenced by jobs or transformations cannot be deleted.
- Passwords / client secrets are stored, but never returned (`********`); sending the
  mask back keeps the stored value.

## Build and run

The backend depends on `uim-platform:service` from the repository root.

```bash
cd identity-provisioning/backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:8093/index.html
dub run

# Command line interface
dub build --config=cli
./build/uim-ips-cli help
./build/uim-ips-cli demo                                  # demo landscape (empty tenant only)
./build/uim-ips-cli provisioning-jobs list
./build/uim-ips-cli run "SuccessFactors HR → Identity Authentication (delta)"
./build/uim-ips-cli logs "Corporate LDAP → BTP Subaccount (full)" --status=failed
./build/uim-ips-cli preview "IAS users" --attributes=userName=Ada,email=Ada@ACME.com
./build/uim-ips-cli source-systems update "Corporate LDAP" --properties=sim.users=12,sim.revision=1
./build/uim-ips-cli provisioned-entities list --entity-type=group --json

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub run --config=gui -- --tenant=default

# Unit tests: domain rules, codec, persistence, use cases, adapters, CLI, end-to-end scenario
dub test --config=defaultTest
```

With `demoData` (on in `config/default.json`) the server creates a demo landscape in
an empty default tenant: SuccessFactors and LDAP sources, an IAS and a BTP target,
a SCIM proxy, three transformations and two jobs — and runs the first job.

### Simulated connector

Until real connectors are plugged in behind the `IIdentityConnector` port, the
`SimulatedIdentityConnector` behaves like one — deterministically and without
network access. Control it with connector properties on the system:

| Property | Effect |
|---|---|
| `sim.users` / `sim.groups` | number of users (default 5) and department groups (default 2) |
| `sim.domain` | e-mail domain (default: system name + `.example.com`) |
| `sim.revision` | shifts the departments — produces updates in delta runs |
| `sim.inactive` | comma separated userNames read with `active=false` |
| `sim.fail` | `connect`, `read` or `write` — simulate an outage |

Every 7th user has no e-mail address; IAS, SCIM and Entra ID targets reject such
users — handy to see failure handling in the log.

### Fiori app

Locally the backend serves `frontend/` at `/index.html`. Tabs: overview tiles,
source/target/proxy systems (create, edit, test connection, activate), transformations
(edit mappings/conditions as JSON, **preview** against sample attributes), jobs
(run, cancel, resume, reset delta; detail page with figures, run log and provisioned
entities), provisioned entities, logs and the connector catalogue. The KPI header
is bound to the `Statistics` singleton.

Tests: `frontend/test/testsuite.qunit.html` (formatter QUnit; OPA5 journeys need the
backend with demo data at the same origin).

### Deploy to SAP BTP (Cloud Foundry)

```bash
mbt build                       # from identity-provisioning/
cf deploy mta_archives/uim-identity-provisioning_1.0.0.mtar
```

Assign the role collections *UIM Identity Provisioning Viewer / Operator /
Administrator*. For local approuter tests copy an XSUAA service key into
`approuter/default-env.json` (git-ignored) and run `npm run start:local`.

### Container / Kubernetes

```bash
# from the uim-platform repository root
podman build -f identity-provisioning/backend/Containerfile -t uim-platform/identity-provisioning .
kubectl apply -f identity-provisioning/k8s/
```

The deployment mounts `/app/data` as `emptyDir`; use a PersistentVolumeClaim to keep
the delta state and logs across restarts.

## Configuration

Precedence: compiled defaults → `config/default.json` (or `IPS_CONFIG_FILE`) →
environment → `VCAP_SERVICES` (credentials of a service named or tagged
`identity-provisioning-config`).

| Variable | Key | Default | Description |
|---|---|---|---|
| `IPS_HOST` | `host` | `0.0.0.0` | bind address |
| `IPS_PORT` / `PORT` | `port` | `8093` | listen port |
| `IPS_LOG_LEVEL` | `logLevel` | `info` | trace, debug, info, warn, error, none |
| `IPS_STORAGE` | `storage` | `file` | `file` (JSON snapshots, shared by server/CLI/GUI) or `memory` |
| `IPS_DATA_DIR` | `dataDir` | `data` | snapshot directory |
| `IPS_DEFAULT_TENANT` | `defaultTenant` | `default` | tenant without token / `X-Tenant-Id` |
| `IPS_REST_PATH` | `restPath` | `/api/v1` | REST prefix |
| `IPS_ODATA_PATH` | `odataPath` | `/odata/v4/identity-provisioning` | OData service root |
| `IPS_SCHEDULER_INTERVAL` | `schedulerIntervalSeconds` | `30` | check for due jobs every N s (0 = off) |
| `IPS_SCHEDULER_TENANTS` | `schedulerTenants` | `default` | tenants the scheduler serves |
| `IPS_LOG_RETENTION_DAYS` | `logRetentionDays` | `30` | scheduler purges older log entries (0 = keep) |
| `IPS_DEMO_DATA` | `demoData` | `false` (`true` in `default.json`) | seed the demo landscape into an empty default tenant |
| `IPS_FRONTEND_DIR` | `frontendDir` | `../frontend` | serve the Fiori app locally ("" = off) |

## REST API (`/api/v1`)

Every resource supports the same verbs; tenant and user come from the XSUAA token
(`zid`, `user_name`) or the `X-Tenant-Id` / `X-User-Id` headers.

| Method | Path | Description |
|---|---|---|
| GET | `/{resource}[?field=value…]` | list (`{items, count}`), filtered by payload fields |
| POST | `/{resource}` | create (201 + `Location`) |
| GET / PATCH / PUT / DELETE | `/{resource}/{id}` | read, partial update, delete (204) |
| POST | `/{resource}/{id}/{action}` | actions (see below) |
| POST | `/transformations/{id}/preview` | apply to `{"entityType", "attributes"}` |
| POST | `/provisioning-logs/purge` | `{"olderThanDays": n}` |
| POST | `/run-due-jobs` | run every due scheduled job |
| POST | `/demo` | seed the demo landscape (empty tenant) |
| GET | `/statistics` (alias `/monitoring`) | tenant figures |
| GET | `/resources` | resource catalogue: paths, input fields, actions |
| POST | `/provisioning-jobs/run/{id}` | previous API, same as `/provisioning-jobs/{id}/run` |
| GET | `/health` | health check |

| Resource | Access | Actions |
|---|---|---|
| `source-systems`, `target-systems`, `proxy-systems` | read/write | `activate`, `deactivate`, `test-connection` |
| `transformations` | read/write | `activate`, `deactivate` |
| `provisioning-jobs` | read/write | `run`, `cancel`, `resume`, `reset` |
| `provisioned-entities`, `provisioning-logs`, `system-types` | read-only | — |

References (`sourceSystemId`, `targetSystemId`, `systemId`, `jobId`) accept an id
or a unique name. Errors: `{"error": {"code", "message"}}` with 400 (invalid payload),
404, 405 (read-only), 409 (state / duplicate / connection test failed), 422 (business rule).

## OData v4 (`/odata/v4/identity-provisioning`)

- Entity sets: `SourceSystems`, `TargetSystems`, `ProxySystems`, `Transformations`,
  `ProvisioningJobs`, `ProvisionedEntities`, `ProvisioningLogs`, `SystemTypes`; singleton `Statistics`.
- Query options: `$filter` (eq ne gt ge lt le, and/or/not, contains/startswith/endswith,
  tolower/toupper), `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`.
- Unbound actions: `<Action><Type>` per resource action (`RunProvisioningJob`,
  `TestConnectionSourceSystem`, `ActivateTargetSystem`, `ResetProvisioningJob`, …) with
  parameter `id`; `RunDueJobs`, `PreviewTransformation`, `PurgeLogs`.
- `$metadata` is generated from the same reflection data as REST, CLI and GUI
  (complex types `Attribute`, `AttributeMapping`, `EntityCondition`, …) and annotates
  labels and insert/update/delete capabilities. `$batch` is not supported — the app
  uses `groupId: "$direct"`.

## Changes from the previous version

- **Layout** moved to `backend/` · `frontend/` · `approuter/` · `mta.yaml`
  (Fiori / vibe.d architecture); the old root-level `source/`, `dub.sdl` and the
  committed binaries in `build/` are gone. `nafv4-architecture.md` is now `NAFv4.md`.
  The repository root `dub.sdl` points at `identity-provisioning/backend`.
- **New adapters:** OData v4 with generated `$metadata`, SAP Fiori 3 app, CLI, GtkD GUI.
- **Real provisioning engine** instead of 5 random users per run: connector port,
  transformation engine (mappings, functions, conditions, mandatory attributes),
  delta planner with checksums, full/delta/simulate semantics, deletions, per-entity
  failures, batched persistence.
- **Scheduling:** `intervalMinutes`, scheduler worker, cancel/resume, delta reset,
  log retention.
- **Typed configuration** (`IPS_*`, `default.json`, `VCAP_SERVICES`), persistent JSON
  snapshot storage shared by server, CLI and GUI, XSUAA-aware identity resolution.
- **Model changes:** JSON-in-string fields became typed structures
  (`properties`, `mappings`, `conditions`, `attributes`); systems got URL,
  authentication, credentials and status message; jobs got figures, schedule and
  derived names; cron `schedule` became `intervalMinutes`.
- REST paths stay under `/api/v1`; job runs move to `/provisioning-jobs/{id}/run`
  (the old `/provisioning-jobs/run/{id}` still works).

## Architecture notes

- Dependencies point inwards: `domain` ← `ports` ← `application` ← `persistence` /
  `infrastructure` ← `presentation`. The domain services (`transformer`, `planner`)
  are pure functions.
- Presentation adapters only see `ProvisioningPorts`. A protocol-neutral
  `ResourceRegistry` describes every resource once (fields by compile-time
  reflection, columns, actions); REST, OData, CLI and GUI are thin layers on top.
- Connectors are behind `IIdentityConnector`; replace the simulated connector with
  SCIM / LDAP / Graph clients in `infrastructure/clients` without touching the core.
- **Security:** the backend trusts the XSUAA token claims *as forwarded by the
  approuter*; it does not verify JWT signatures itself. Do not expose it directly.
  Credentials are stored in the snapshot files — protect the data directory or bind a
  credential store for production.

## License

See the repository root [LICENSE](../LICENSE) file.
