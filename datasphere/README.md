# UIM Datasphere

A business data fabric service in the style of **SAP Datasphere**: spaces with disk quotas and members,
connections to source systems, remote tables (federated or replicated), SQL views with semantic usage and
persistence, data flows, tasks and task chains with schedules and retries, a run monitor, row level security
(data access controls) and a governed catalog.

| Part | Technology | Where |
|---|---|---|
| Backend | D, vibe.d 0.10.5, uim-framework, shared `uim-platform:service` (OData v4 engine, document stores, security) | [backend/](backend/) |
| Frontend | SAP Fiori 3 / OpenUI5 1.120, OData V4 model | [frontend/](frontend/) |
| Approuter | `@sap/approuter`, XSUAA | [approuter/](approuter/) |
| Deployment | MTA (SAP BTP Cloud Foundry), Docker / Podman, Kubernetes | [mta.yaml](mta.yaml), [backend/Dockerfile](backend/Dockerfile), [k8s/](k8s/) |
| Architecture | UML and NAF v4 | [uml.md](uml.md), [nafv4.md](nafv4.md) |

Version 2.0 is a redesign of the former single-folder service: hexagonal layers with ports, one model-driven OData
engine behind REST, OData, CLI and GUI, a file or in-memory document store, a simulated processing engine,
a background scheduler, the built-in **JWT login** (and XSUAA on BTP), and a Fiori app.

---

## Concepts

| Concept | Meaning |
|---|---|
| **Space** | Isolated workspace (technical name, e.g. `SALES`) with disk and memory quota, priority 1–8, audit log flag. A **locked** space allows no runs and no new objects. |
| **Member** | A user with a scoped role in a space: viewer, modeler, integrator, administrator. The last administrator of a space stays. |
| **Connection** | Source system of a space: SAP HANA, S/4HANA, BW/4HANA, HANA data lake files, OData, SQL, ABAP, Kafka, files. Status *untested → valid / invalid*; the password is **write-only**. |
| **Remote table** | A remote object of a connection. Access *remote* (federated), *snapshot*, *scheduled* or *realtime* (only HANA, S/4HANA, ABAP, Kafka). Columns `NAME:TYPE(len) [key]`. |
| **View** | A single read-only `SELECT` (or `WITH … SELECT`). Sources are derived from `FROM` / `JOIN`; semantic usage relational / analytical dataset, fact, dimension, text, hierarchy; may be **exposed** and **persisted**. |
| **Data flow** | Sources → transformations (`filter:`, `projection:`, `join:`, `union:`, `aggregation:`, `calculated:`, `script:`) → target table; load mode append / truncate / upsert. |
| **Deployment** | Views and data flows are *notDeployed → deployed*; a design-time change of a deployed object sets *changesToDeploy*. Only deployed objects run. |
| **Task** | Runs one object: replication (remote table), data flow or view persistence — manual, every *n* minutes, hourly, daily, weekly or monthly, with retries. |
| **Task chain** | Tasks in order; on a failed step **stop** (later steps cancelled) or **continue**. |
| **Run** | Log entry of every replication, data flow run, persistence and chain run (with its steps): trigger, attempt, rows, size, duration, message. |
| **Data access control** | Row level security: users assigned to the control see the rows whose criteria column matches (`equals`, `oneOf`, `startsWith`, `between`). A view protected by an enabled control hides every other row. |
| **Catalog asset** | Governed description of an object: business name, owner, quality, sensitivity, tags, glossary terms; ranked search. |

### How a run works (`application/services/runner.d`)

1. The space must exist and be active, otherwise the run **fails** (it never throws).
2. Replication: an *untested* connection is validated first; an invalid connection fails the run.
3. The **processing engine** port does the work; the shipped adapter is a deterministic simulation
   (`infrastructure/clients/processing.d`): unreachable hosts (`*.invalid`, `unreachable`) fail, a remote object
   called `MISSING…` does not exist, rows follow from the object name, a `filter` keeps 40 % and an `aggregation` 5 %.
4. The new size (rows × column widths) is checked against the **disk quota** of the space; above it the run fails.
5. The object (row count, size, timestamps, last run) and the space usage are updated; the run is logged and audited.
6. Tasks retry `maxRetries` times (each attempt is a run); chains run their steps inside one storage batch.
7. The **scheduler worker** (every `schedulerIntervalSeconds`) runs due chains first, then due tasks that are not
   part of a chain run in the same pass; due schedules of locked spaces are skipped and planned again.

### Business rules (enforced by the use cases)

* Space deletion is refused while it contains objects; its members and runs go with it. The disk quota cannot be
  set below the used disk; a space can only be unlocked when it fits its quota again.
* Connections, remote tables, views, data flows and tasks cannot be deleted while other objects use them
  (remote tables / views / flow targets read by views and data flows, objects of tasks, tasks of chains, views
  protected by data access controls).
* Technical names are unique per space (remote tables, views, data flow targets; case insensitive).
* View SQL is a single `SELECT`; `INSERT`, `UPDATE`, `DELETE`, `DROP`, `CREATE`, `GRANT`, … and multiple statements
  are refused. On deployment every source must be an object of the space.
* References stay inside a space: connections of remote tables, targets of tasks, steps of chains, protected
  views of data access controls, described objects of catalog assets.
* Changing host, port, database, user, password or type of a connection resets it to *untested*; switching a
  remote table back to *remote* drops its replica.
* Immutable after creation: `spaceId` of every object, `name` of remote tables / views / data flows,
  `connectionId` of remote tables, `taskType` of tasks, `userName` of members.

---

## Project layout

```text
datasphere/
├── mta.yaml                     MTA: backend + approuter + XSUAA + user-provided config
├── approuter/                   xs-app.json (routes), xs-security.json (scopes, roles), default-env.json (local)
├── frontend/                    Fiori 3 app (uim.datasphere): view/ controller/ model/ fragment/ i18n/ localService/ test/
├── k8s/                         configmap, secret.example, deployment (+ PVC), service
└── backend/
    ├── dub.sdl                  configurations: defaultRun (server), cli, gui (GtkD), defaultTest
    ├── config/default.json      defaults (overridden by DATASPHERE_* env and VCAP_SERVICES)
    ├── Dockerfile, Containerfile
    ├── tests/datasphere_flows.d integration tests across all layers
    └── source/
        ├── app.d  cli.d  gui.d  entry points
        └── uim/platform/datasphere/
            ├── domain/          entities, types (ids, time, scopes), enumerations, exceptions,
            │                    services (columns, sql, schedules, access, lifecycle)
            ├── ports/           usecases (driving), services, repositories, storages, messaging, gateways (driven)
            ├── application/     dtos, usecases (spaces, integration, modeling, scheduling, access),
            │                    services (runner, statistics, capabilities, demo data)
            ├── persistence/     records, mappers (compile-time entity ↔ record), repositories, storages (batching)
            ├── infrastructure/  configuration, security (PBKDF2, HS256 tokens, XSUAA), logging, clients
            │                    (clock, processing engine), workers (scheduler), monitoring, container
            └── presentation/    odata (model, engine, serializers, payloads), http (api, auth, health),
                                 web (Fiori files), cli, gui
```

---

## Build and run

Requirements: dmd ≥ 2.110 or ldc2 ≥ 1.40, dub, the sibling [service](../service) package. For the GUI: GTK 3.24.

```bash
cd datasphere/backend
dub build                     # server      → build/uim-datasphere-platform-service
dub build --config=cli        # CLI         → build/uim-datasphere-cli
dub build --config=gui        # GtkD GUI    → build/uim-datasphere-gui
dub test  --config=defaultTest
```

> **Note (2026-11-26):** `uim-framework` 26.11.1 from the dub registry does not compile with dmd 2.114
> (`LightOnCommand` & co. in `oop/patterns/commands/command.d` do not implement `IUndoableCommand`), and
> 26.11.2+ dropped `uim.services`, which `../service` needs. This affects every service of the repository, not
> this one in particular. The build was verified against a local copy of 26.11.1 with those demo classes
> disabled; a fixed framework release is required for a plain `dub build`.

### Local development

```bash
cd datasphere/backend
./build/uim-datasphere-platform-service
# first start in jwt mode (config/default.json): the log shows the generated password of "admin" once
# Fiori app:  http://localhost:8095/app/index.html   (log on as admin; "Create Demo Content" in an empty tenant)
# OData:      http://localhost:8095/odata/v4/datasphere/$metadata
# REST:       http://localhost:8095/api/v1/datasphere/capabilities
# Health:     http://localhost:8095/health

# without login (development only)
DATASPHERE_AUTH_MODE=open DATASPHERE_STORAGE=memory ./build/uim-datasphere-platform-service
```

A short tour with `curl` (authMode open):

```bash
API=http://localhost:8095/api/v1/datasphere
curl -X POST $API/demo-data                                         # SALES + HR spaces, nightly chain already run
curl "$API/spaces/SALES/remote-tables?\$select=name,replicationStatus,rowCount"
curl -X POST $API/remote-tables/gl/replicate                        # load a snapshot → the run
curl -X POST $API/task-chains/nightly/run                           # run all steps
curl "$API/runs?\$filter=status eq 'failed'&\$orderby=startedAt desc"
curl -X POST $API/views/sales-orders/check-access -H 'Content-Type: application/json' \
     -d '{"user":"bob","row":{"COUNTRY":"DE"}}'                     # → allowed: false (row level security)
curl "$API/catalog/search?q=revenue"
```

### CLI

The CLI uses the same container and storage as the server (`--data-file` shares the snapshot):

```bash
./build/uim-datasphere-cli help
./build/uim-datasphere-cli seed --data-file=data/datasphere.json
./build/uim-datasphere-cli spaces
./build/uim-datasphere-cli run nightly                 # task, task chain or data flow (exit 3 if the run failed)
./build/uim-datasphere-cli replicate customers
./build/uim-datasphere-cli deploy sales-orders
./build/uim-datasphere-cli validate LEGACY
./build/uim-datasphere-cli check-access sales-orders ada '{"COUNTRY":"CH"}'
./build/uim-datasphere-cli runs SALES --status=failed
./build/uim-datasphere-cli schedule                    # run the due schedules now
./build/uim-datasphere-cli list Views --filter="deploymentStatus eq 'changesToDeploy'"
./build/uim-datasphere-cli token admin                 # bearer token (jwt mode, configured jwtSecret)
./build/uim-datasphere-cli passwd admin 'new secret 123'
```

Generic, model driven commands: `sets`, `metadata`, `list`, `count`, `get`, `create`, `update`, `delete`, `invoke`.

### Container / Kubernetes / BTP

```bash
# from the repository root (path dependency on ../../service)
docker build -f datasphere/backend/Dockerfile -t uim-platform/datasphere .
podman build -f datasphere/backend/Containerfile -t uim-platform/datasphere .

cp datasphere/k8s/secret.example.yaml datasphere/k8s/secret.yaml   # fill in, never commit
kubectl apply -f datasphere/k8s/

cd datasphere && mbt build && cf deploy mta_archives/uim-datasphere_2.0.0.mtar
```

---

## Authentication and authorization

| Mode | Selected by | Login | Tokens |
|---|---|---|---|
| `xsuaa` | an XSUAA binding in `VCAP_SERVICES` (always wins) | approuter | RS256 of XSUAA, scopes enforced |
| `jwt` | `authMode: "jwt"` (default in `config/default.json`) | `POST /auth/login` (built-in users) | HS256 with `jwtSecret`, scopes enforced |
| `open` | `authMode: "open"` | none | tenant from `X-Tenant-Id`, user from `X-User-Id` (development) |

Built-in login:

* `POST /auth/login {username, password, tenant?}` → `{access_token, token_type, expires_in, scope, user}`
  (also form encoded); `GET /auth/config`, `GET /auth/me`, `POST /auth/password`, `POST /auth/logout`.
* Passwords: PBKDF2-HMAC-SHA256 (120 000 rounds, random salt), at least 10 characters; 5 failed logins lock the
  account for 15 minutes; unknown users and wrong passwords answer alike.
* Tokens carry XSUAA compatible claims (`sub`, `user_name`, `zid` = tenant, `scope[]`, `exp`, `jti`).
* On the first start the administrator (`adminUser`, password `adminPassword` or generated and logged once) is
  created; without `jwtSecret` a random secret is used and tokens end with the process.
* The Fiori app shows a login dialog, keeps the token in `sessionStorage`, offers password change and log off;
  administrators maintain users in the **Users** tab.

| Scope | Allows | Implied by |
|---|---|---|
| `Read` | read everything (but users), check row access | every scope |
| `Integrate` | validate connections, replicate, run data flows, persist views, deploy, run / pause / resume tasks and chains, run due schedules | Model, Manage |
| `Model` | maintain remote tables, views, data flows, data access controls, catalog | Manage |
| `Manage` | maintain spaces, members, connections, tasks, task chains; lock spaces; purge runs; demo content | — |
| `Admin` | user accounts of the built-in login | — |

XSUAA role templates: Viewer, Integrator, Modeler, SpaceAdministrator, Administrator.

---

## APIs

### OData v4 — `/odata/v4/datasphere`

Entity sets: `Spaces`, `Members`, `Connections`, `RemoteTables`, `Views`, `DataFlows`, `Tasks`, `TaskChains`,
`Runs` (read only), `AccessControls`, `CatalogAssets`, `Users`, singleton-like `Statistics('<tenant>')`.
Query options `$filter`, `$orderby`, `$top`, `$skip`, `$count`, `$search`, `$select`; `$batch`; Fiori UI
annotations (LineItem, SelectionFields, HeaderInfo) in `$metadata`.

Unbound actions: `LockSpace`, `UnlockSpace`, `ValidateConnection`, `ReplicateRemoteTable`, `DropReplica`,
`DeployView`, `PersistView`, `RemovePersistence`, `CheckDataAccess`, `DeployDataFlow`, `RunDataFlow`, `RunTask`,
`PauseTask`, `ResumeTask`, `RunTaskChain`, `PauseTaskChain`, `ResumeTaskChain`, `RunDueSchedules`, `PurgeRuns`,
`SeedDemoData`.

### REST — `/api/v1/datasphere`

| Method | Path | |
|---|---|---|
| GET / POST | `/{resource}` | list (OData query options) / create → 201 |
| GET / PUT / PATCH / DELETE | `/{resource}/{id}` | read / partial update / delete → 204 |
| POST | `/spaces/{id}/lock` `{reason}` · `/unlock` | |
| GET | `/spaces/{id}/{members,connections,remote-tables,views,data-flows,tasks,task-chains,runs,access-controls,catalog}` | |
| POST | `/connections/{id}/validate` | |
| POST | `/remote-tables/{id}/replicate` · `/drop-replica` | run · remote table |
| POST | `/views/{id}/deploy` · `/persist` · `/remove-persistence` · `/check-access {user, row}` | |
| POST | `/data-flows/{id}/deploy` · `/run` | |
| POST / GET | `/tasks/{id}/run` · `/pause` · `/resume` · `/runs` | |
| POST / GET | `/task-chains/{id}/run` · `/pause` · `/resume` · `/runs` | |
| GET | `/runs/{id}/steps` | step runs of a chain run |
| GET | `/catalog/search?q=…&space=…` | ranked |
| POST | `/scheduler/run` · `/runs/purge` · `/demo-data` | |
| GET | `/statistics` · `/capabilities` · `/meta` | |

Resources: `spaces`, `members`, `connections`, `remote-tables`, `views`, `data-flows`, `tasks`, `task-chains`,
`runs`, `access-controls`, `catalog`, `users`. Errors: `{"error": {code, message, requestId, target}}` with
400 / 401 / 403 / 404 / 405 / 409 / 413 / 422 / 500.

---

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `DATASPHERE_<KEY>`
environment variables → `VCAP_SERVICES` (user-provided service `datasphere-config`, Cloud Foundry `PORT`) →
CLI options. `uim-datasphere-cli config` prints the effective values (secrets masked).

| Key (env `DATASPHERE_…`) | Default | |
|---|---|---|
| `host`, `port` | `0.0.0.0`, `8095` | |
| `storage`, `dataFile` | `memory`, `data/datasphere.json` | `file` = JSON snapshot shared by server, CLI, GUI (single node) |
| `defaultTenant` | `default` | |
| `apiPath`, `odataPath` | `/api/v1`, `/odata/v4/datasphere` | |
| `authMode` | `open` (`jwt` in `config/default.json`) | `open` · `jwt`; XSUAA binding wins |
| `jwtSecret`, `tokenTtlSeconds` | random, `3600` | secret ≥ 32 characters |
| `adminUser`, `adminPassword` | `admin`, generated | first administrator |
| `passwordIterations`, `minPasswordLength` | `120000`, `10` | |
| `maxFailedLogins`, `lockSeconds` | `5`, `900` | |
| `enforceQuota` | `true` | runs above the disk quota fail |
| `runRetentionDays` | `30` | finished runs are purged afterwards |
| `schedulerIntervalSeconds`, `purgeEveryRuns`, `workerTenants` | `60`, `60`, `["default"]` | `0` = on demand only |
| `maxSchedulerBatch` | `100` | tasks + chains per scheduler run |
| `federatedRowEstimate` | `10000` | rows assumed for a non-replicated source |
| `processingMode`, `simulatedFailurePercent` | `simulate`, `0` | chaos testing |
| `frontendDir` | `../frontend` | `""` on BTP (the approuter serves the app) |
| `maxPageSize`, `maxRequestBytes` | `500`, `4194304` | |

---

## Tests

```bash
cd backend && dub test --config=defaultTest          # 42 modules: unit tests + tests/datasphere_flows.d
# frontend (served by the backend):
#   http://localhost:8095/app/test/unit/unitTests.qunit.html
#   http://localhost:8095/app/test/integration/opaTests.qunit.html   (authMode open, demo content)
```

The integration suite covers the demo content, modeling rules, runs with quota and locked spaces, retries,
stop / continue chains, the scheduler and the worker, row level security, the catalog, members, the REST API and
OData endpoint over vibe.d test requests, the JWT login with every scope, the CLI and the batching file store.

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
