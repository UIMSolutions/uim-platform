# UIM Application Studio Service

A D/vibe.d service modelled on **SAP Business Application Studio**: a catalogue of
dev space types, extensions and project templates, and per developer **dev spaces**
with their projects, service bindings, run configurations and build-and-deploy
configurations. A built-in **reconciler** drives the asynchronous parts of the
lifecycle (dev space start/stop, hibernation after inactivity, deletion, connection
tests, runs, builds and deployments) against a pluggable workspace gateway.

One hexagonal core, four driving adapters:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST `/api/v1` | `uim-application-studio-platform-service` | JSON API for scripts and other services |
| OData v4 `/odata/v4/application-studio` | `uim-application-studio-platform-service` | SAP Fiori 3 / UI5 frontend |
| CLI | `uim-studio-cli` | administration and automation |
| GtkD GUI | `uim-studio-gui` | desktop client |

Server, CLI and GUI share the same snapshot storage (`backend/data/*.json`), so a
change made in one is visible in the others.

## Project layout

```
application-studio/
├── mta.yaml                    MTA descriptor (backend + approuter + XSUAA) for SAP BTP / Cloud Foundry
├── k8s/                        Kubernetes manifests (ConfigMap, Deployment, Service)
├── backend/                    D 2.11x / vibe.d 0.10.3
│   ├── dub.sdl                 configurations: defaultRun (server), cli, gui, defaultTest
│   ├── Dockerfile · Containerfile
│   ├── config/default.json     default configuration
│   └── source/
│       ├── app.d · cli.d · gui.d                  composition roots
│       └── uim/platform/application_studio/
│           ├── domain/          entities, types (ids, value objects), enumerations,
│           │                    services (names, plan policy, dev space lifecycle,
│           │                    extension resolution, run policy, build policy), exceptions
│           ├── ports/           usecases, services (driving) · repositories, storages,
│           │                    messaging, gateways (driven)
│           ├── application/     usecases (one interactor per aggregate + reconcile),
│           │                    services (catalogue seeder, cascade deletion, project status,
│           │                    statistics), dtos (specs, requests, reports)
│           ├── persistence/     repositories, storages (JSON snapshot files, memory),
│           │                    mappers (reflection based), records (collections, envelope)
│           ├── infrastructure/  configuration, logging, security (XSUAA identity),
│           │                    clients (simulated workspace runtime), workers (reconciler), container (DI)
│           ├── presentation/    resources (protocol-neutral adapters + registry), http (REST),
│           │                    odata (model, $metadata, query engine, controller), cli, gui, web
│           └── helpers/         codec (struct ⇄ JSON reflection), enums, json, time
├── frontend/                   SAP Fiori 3 / UI5 app (uim.studio)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/           $metadata and mock data captured from the backend
│   └── test/                   QUnit (formatter) and OPA5 journey
└── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
```

## Domain model

| Aggregate | Parent | Lifecycle (reconciler) | Notable rules |
|---|---|---|---|
| `DevSpaceType` | tenant | — | unique name; predefined types (catalogue) are read-only and cannot be deleted; extensions must exist; in-use types cannot be deleted |
| `Extension` | tenant | — | name `publisher.package` (a–z, 0–9, `-`, `.`); semantic version; dependencies must exist; predefined ones cannot be changed, deactivated, deprecated or deleted; deletion blocked while installed, part of a type, required by a template or a dependency |
| `ProjectTemplate` | tenant | — | catalogue name; required extensions must exist; scaffold files are relative paths; unique parameter names; cannot be deleted while projects use it |
| `DevSpace` | tenant | starting/resuming → running \| error; stopping → stopped; running + idle → hibernating → hibernated; deleting → removed (cascade) | name: letters, digits, `_` (≤ 40); owner e-mail; **plan limits** (free: 2 dev spaces, 1 running, ≤ 4 GB, ≤ 10 GB disk, hibernation 1–7 days · standard: 10/2/8 GB/20 GB/≤ 14 days · professional: 50/10/16 GB/64 GB/≤ 30 days); additional extensions must be active, their dependencies are added, predefined ones are dropped; extensions and sizes change only while not running; a hibernated dev space resumes on access (`touch`); delete only when stopped/hibernated/failed |
| `Project` | dev space | building / deploying / error mirror the build configurations | created in a **running** dev space; name lowercase (≤ 64), unique per dev space; template sets the project type and files; the dev space must have the template's extensions and its type must support the project type; git URL http(s) or `git@host:path`; archive/restore; deletion cascades to run and build configurations |
| `ServiceBinding` | dev space | connecting → connected \| error (dev space running) | URL or destination required; OData providers need a service path; basic/OAuth need user and secret; **credentials are masked**; changing connection settings disconnects; cannot be deleted while a run configuration uses it |
| `RunConfiguration` | project | starting → running \| error | entry point required; ports 1024–65535; debug mode needs a distinct debug port; valid, unique environment variable names; referenced bindings must exist and be **connected** to start; ports must be free in the dev space; running configurations cannot be changed or deleted; stopping the dev space ends its runs |
| `BuildConfiguration` | project | building → succeeded \| failed; deploying → deployed \| failed | build command required; Cloud Foundry needs an MTA descriptor (default `mta.yaml`); HTML5 repository and ABAP only for UI projects; artifact path and deploy command are derived from target and project if empty; deploy needs a successful build; cancel while busy; last 20 runs kept |

The predefined **SAP catalogue** (15 extensions, 6 dev space types — SAP Fiori,
Full-Stack Cloud Application, SAP HANA Native Application, SAP Mobile Application,
SAP Workflow, Basic — and 8 project templates) is installed with
`seed` / `POST /api/v1/catalog/seed` / OData `SeedCatalog`, and by the server for the
default tenant on start (`seedCatalog`). Seeding is idempotent.

## Build and run

```sh
cd application-studio/backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:8111/
dub run                                   # = --config=defaultRun

# Command line interface
dub build --config=cli
./build/uim-studio-cli seed
./build/uim-studio-cli dev-spaces create --name=FioriDev --dev-space-type-id="SAP Fiori" --owner=jane@example.com
./build/uim-studio-cli reconcile          # starting → running (the server does this every 10 s)
./build/uim-studio-cli projects create --devSpaceId=FioriDev --name=travel-ui --templateId=fiori-list-report
./build/uim-studio-cli service-bindings create --devSpaceId=FioriDev --name=Northwind \
    --provider-type=externalOData --service-url=https://services.odata.org --service-path=/V4/Northwind/Northwind.svc/
./build/uim-studio-cli service-bindings connect Northwind
./build/uim-studio-cli run-configurations create --projectId=travel-ui --name=preview \
    --entry-point="npm start" --port=8080 --service-bindings=Northwind --environment=NODE_ENV=development
./build/uim-studio-cli run-configurations start preview
./build/uim-studio-cli build-configurations create --projectId=travel-ui --name=mta
./build/uim-studio-cli build-configurations build mta && ./build/uim-studio-cli reconcile
./build/uim-studio-cli build-configurations deploy mta
./build/uim-studio-cli stats --json

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub run --config=gui -- --tenant=default

# Unit tests (domain rules, codec, persistence, use cases, adapters, an end-to-end scenario)
dub test --config=defaultTest
```

`uim-studio-cli help` lists every command; `<resource> fields` shows the settable fields.
Objects are addressed by id or by unique name everywhere (CLI, REST paths, references in payloads).

### Fiori app

With the server running, open <http://localhost:8111/index.html>: KPI header and
overview tiles (`Statistics` singleton), one tab per entity set with create, delete,
search and all lifecycle actions, buttons for *Install SAP Catalogue* and *Reconcile*,
and a dev space object page with its projects, service bindings, run and build
configurations. `frontend/localService` holds `$metadata` and mock data captured from
the backend, and `npm test` in `frontend/` serves the QUnit/OPA5 test suite.

### Deploy

```sh
# SAP BTP (Cloud Foundry)
mbt build && cf deploy mta_archives/uim-application-studio_1.0.0.mtar

# Container / Kubernetes (build context: the uim-platform repository root)
docker build -f application-studio/backend/Dockerfile -t uim-platform/application-studio .
kubectl apply -f application-studio/k8s/
```

`mta.yaml` deploys the backend (binary buildpack), the approuter (serving the Fiori app)
and an XSUAA instance (`approuter/xs-security.json`: roles StudioViewer, StudioDeveloper,
StudioAdmin). Locally, run the approuter with `approuter/default-env.json`
(simulated `VCAP_SERVICES`; git-ignored, never deployed). The k8s Deployment mounts an
`emptyDir` at `/data`; replace it with a PersistentVolumeClaim to keep data across restarts.

## Configuration

Precedence (lowest → highest): compiled defaults → `config/default.json`
(or `APPLICATION_STUDIO_CONFIG_FILE`) → environment variables → `VCAP_SERVICES`
credentials of a service named or tagged `application-studio-config`.

| Key | Env variable | Default | Description |
|---|---|---|---|
| `host` | `APPLICATION_STUDIO_HOST` | `0.0.0.0` | bind address |
| `port` | `APPLICATION_STUDIO_PORT` / `PORT` | `8111` | listen port |
| `logLevel` | `APPLICATION_STUDIO_LOG_LEVEL` | `info` | trace, debug, info, warn, error, none |
| `storage` | `APPLICATION_STUDIO_STORAGE` | `file` | `file` (JSON snapshots) or `memory` |
| `dataDir` | `APPLICATION_STUDIO_DATA_DIR` | `data` | snapshot directory (shared by server, CLI, GUI) |
| `defaultTenant` | `APPLICATION_STUDIO_DEFAULT_TENANT` | `default` | tenant if no token / `X-Tenant-Id` |
| `odataPath` | `APPLICATION_STUDIO_ODATA_PATH` | `/odata/v4/application-studio` | OData service root |
| `reconcileIntervalSeconds` | `APPLICATION_STUDIO_RECONCILE_INTERVAL` | `10` | reconciler period, 0 = off |
| `reconcileTenants` | `APPLICATION_STUDIO_RECONCILE_TENANTS` | `default` | tenants reconciled by the server |
| `seedCatalog` | `APPLICATION_STUDIO_SEED_CATALOG` | `true` | install the SAP catalogue into the default tenant on start |
| `frontendDir` | `APPLICATION_STUDIO_FRONTEND_DIR` | `../frontend` | serve the Fiori app ("" = off) |

CLI and GUI accept `--data-dir`, `--storage` and `--tenant` on top.

**Identity:** tenant and user come from the XSUAA bearer token (`zid`, `user_name`) or the
`X-Tenant-Id` / `X-User-Id` headers. The backend decodes but does **not verify** the JWT
signature; it relies on the approuter. Do not expose the backend directly without adding
signature verification.

**Secrets:** service binding credentials are masked (`********`) in every adapter, and
sending the mask back keeps the stored value. They are, however, stored in plain text
in the snapshot files — protect `dataDir`, or move secrets to the credential store
before using real credentials.

## REST API (`/api/v1`)

| Method | Path | Description |
|---|---|---|
| GET | `/{resource}[?field=value…]` | list → `{ "items": [...], "count": n }`, filtered by payload fields |
| POST | `/{resource}` | create → 201 with the resource |
| GET | `/{resource}/{id\|name}` | read |
| PATCH / PUT | `/{resource}/{id\|name}` | partial update (unspecified fields keep their value) |
| DELETE | `/{resource}/{id\|name}` | delete → 204 (dev spaces: deletion starts) |
| POST | `/{resource}/{id\|name}/{action}` | lifecycle action, parameters as JSON body |
| GET | `/statistics` | figures of the tenant |
| POST | `/reconcile` | run one reconciliation pass |
| POST | `/catalog/seed` | install the predefined SAP catalogue |
| GET | `/resources` | catalogue: paths, input fields, actions and their parameters |
| GET | `/health` | health check |

| Resource | Parent field | Actions (parameters) |
|---|---|---|
| `dev-space-types` | — | — |
| `extensions` | — | `activate`, `deactivate`, `deprecate` |
| `project-templates` | — | — |
| `dev-spaces` | — | `start`, `stop`, `touch`, `add-extension`, `remove-extension` (`extension`) |
| `projects` | `devSpaceId` | `archive`, `restore` |
| `service-bindings` | `devSpaceId` | `connect`, `disconnect` |
| `run-configurations` | `projectId` | `start`, `stop` |
| `build-configurations` | `projectId` | `build`, `deploy`, `cancel` |

References (`devSpaceId`, `devSpaceTypeId`, `projectId`, `templateId`) accept an id or a
unique name. Errors: `{ "error": { "code": "Conflict", "message": "…" } }` with 400 (bad
input, ambiguous name), 404, 409 (state or duplicate), 422 (business rule). The previous
prefix `/api/v1/application-studio/{resource}` is still served.

## OData v4 (`/odata/v4/application-studio`)

Generated from the same resource catalogue as REST:

- Entity sets `DevSpaceTypes, Extensions, ProjectTemplates, DevSpaces, Projects,
  ServiceBindings, RunConfigurations, BuildConfigurations` with GET, POST, PATCH, DELETE
- Singleton `Statistics`; complex types `KeyValue, BuildRun, ReconcileResult, SeedResult`
- Unbound actions `Reconcile`, `SeedCatalog` and one action per lifecycle action, named
  `<Action><EntityType>`: `StartDevSpace`, `StopDevSpace`, `TouchDevSpace`,
  `AddExtensionDevSpace`, `ArchiveProject`, `ConnectServiceBinding`,
  `StartRunConfiguration`, `BuildBuildConfiguration`, `DeployBuildConfiguration`,
  `DeprecateExtension`, … (parameter `id` plus the action's parameters)
- Query options `$filter` (eq ne gt ge lt le, and or not, contains startswith endswith,
  tolower toupper), `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, `/$count`
- `$metadata` with `Common.Label` and capability annotations
- No `$batch`: the UI5 model uses `groupId: "$direct"`.

## Changes from the previous version

The service was rebuilt on the hexagonal layout shared with `abap-environment`.

- **Layout:** the module moved to `application-studio/backend` (root `dub.sdl`:
  `subPackage "application-studio/backend"`); new `frontend/`, `approuter/`, `mta.yaml`;
  Dockerfile/Containerfile moved into `backend/` (build context: repository root).
- **New adapters:** OData v4 with generated `$metadata`, CLI (`uim-studio-cli`), GtkD GUI
  (`uim-studio-gui`), SAP Fiori 3 app.
- **Persistence:** in-memory only → JSON snapshots shared by server, CLI and GUI
  (`storage=memory` keeps the old behaviour).
- **Behaviour:** dev spaces have a real lifecycle (start, stop, hibernation, resume on access,
  asynchronous deletion with cascade) and plan limits; bindings are connected/tested; runs and
  builds/deployments execute through the reconciler; projects are generated from templates
  with extension and type checks; a predefined SAP catalogue can be installed.
- **Routes:** `/api/v1/application-studio/<resource>` → `/api/v1/<resource>` (old prefix still
  served); lifecycle actions at `/api/v1/<resource>/{id}/<action>`; health check `/health` →
  `/api/v1/health` (k8s probes updated).
- **Payloads:** list fields are arrays (`extensions`, `predefinedExtensions`,
  `supportedProjectTypes`, `dependencies`, `capabilities`, `requiredExtensions`, `arguments`);
  comma separated strings are still accepted. `scaffoldConfig`/`defaultFiles` →
  `parameters` (`[{key, value}]`) / `scaffoldFiles`; `environmentVars` → `environment`
  (`[{key, value}]`, `"K=v,K2=v2"` accepted); `memoryLimit` → `memoryLimitMb`, `diskLimit` →
  `diskLimitGb`; `hibernateAfterDays`, `port` and `debugPort` are numbers (numeric strings are
  accepted); `buildLog` → `history` (runs); timestamps are ISO 8601 strings.
- **Enumerations:** dev space status `starting/running/stopping/stopped/hibernating/
  hibernated/resuming/deleting/error`; plan `free/standard/professional`; binding status gains
  `connecting`; build status gains `deploying/deployed`; project types reduced to the BAS
  generators (`basic, sapFiori, sapFioriElements, sapUi5, capNodeJs, capJava, hanaNative, mdk,
  workflow, multitarget, sideBySideExtension`); service bindings get `authType`
  (`noAuthentication/basicAuthentication/oauth2ClientCredentials/principalPropagation`).
- **Fixed:** `ProjectTemplate.title` was never serialized; `ServiceBinding` credentials were
  returned in clear text; `RunConfiguration.toJson` was not `const`; the validator accepted any
  input apart from empty names.

## Architecture notes

- **Reflection codec.** Persistence records, REST/OData payloads, OData `$metadata`,
  CLI tables and GUI forms are all derived from the domain structs at compile time
  (`helpers/codec.d`). Adding a field to an entity and its spec makes it available in every
  adapter. `decode(patch, base)` provides PATCH semantics.
- **Resource registry.** `presentation/resources` wraps each driving port in a
  protocol-neutral adapter (JSON in/out, columns, actions, secret masking, references by name).
  REST, OData, CLI and GUI are thin protocol layers on top of it.
- **Workspace gateway.** The reconciler talks to `IWorkspaceGateway` (dev space runtime,
  process runner, build service, deployers, connectivity check). The default
  `SimulatedWorkspaceGateway` derives results deterministically — a dev space whose
  description contains `[fail]` cannot start, service URLs or destinations containing
  `invalid` cannot be reached, and entry points, build or deploy commands containing `[fail]`
  fail. Real clients can be plugged in without touching the use cases.
- **Snapshot storage.** One JSON file per collection, written atomically (temp file +
  rename) and reloaded when another process changed it. Suitable for local and
  single-instance use, not for concurrent writers at scale.

See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the NAF v4 architecture description.

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
