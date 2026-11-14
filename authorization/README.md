# UIM Platform — Authorization Management Service

An Authorization Management Service in the style of the **SAP Cloud Identity Services – Authorization Management Service (AMS)**:
applications and their APIs, **base and custom policies** with attribute conditions, **policy assignments** to users and groups,
**runtime authorization decisions** and a **decision log**.

The service is built with **D / vibe.d 0.10.3** using **hexagonal (Clean) Architecture** and ships with

| Channel | Path / binary | Purpose |
|---|---|---|
| **OData v4** | `/odata/v4/authorization` | SAP Fiori app, `$metadata` with UI annotations, `$batch`, unbound actions |
| **JSON API** | `/api/v1/...` | REST/JSON, paths and bodies of release 1 still accepted |
| **vibe.d REST** | `/rest/v1/authorization/...` | runtime API for applications (`check`, effective policies) |
| **Web dashboard** | `/web` | server-side rendered Diet template with daisyUI |
| **SAP Fiori 3 app** | `frontend/` (`/app` locally, approuter on BTP) | administration cockpit |
| **CLI** | `uim-authorization-cli` | administration and scripting (`check` returns exit code 3 on deny) |
| **GtkD GUI** | `uim-authorization-gui` | desktop client (GTK 3) |

All channels go through **one `ODataEngine`** built from **one EDM model**, so validation, scopes, query options
(`$filter`, `$orderby`, `$select`, `$search`, `$top`, `$skip`, `$count`) and error semantics are identical everywhere.

---

## Project layout

```
authorization/
├── mta.yaml                 MTA descriptor (backend + approuter + XSUAA)
├── backend/                 D / vibe.d service
│   ├── dub.sdl              configurations: defaultRun, cli, gui, defaultTest
│   ├── config/default.json  defaults (overridden by env vars and VCAP_SERVICES)
│   ├── views/dashboard.dt   Diet template of /web
│   ├── tests/lifecycle.d    end-to-end tests (dub test)
│   ├── Dockerfile, Containerfile
│   └── source/
│       ├── app.d  cli.d  gui.d            entry points (composition roots)
│       └── uim/platform/authorization/
│           ├── domain/          entities, types (ids, conditions, attributes), enumerations,
│           │                    exceptions, services (PolicyEvaluator, base policy templates)
│           ├── ports/           usecases, services, repositories, storages, messaging, driving.d
│           ├── application/     usecases (interactors), services (statistics, demo data), dtos
│           ├── persistence/     repositories, mappers, records, storages (memory/file/MongoDB)
│           ├── infrastructure/  configuration, security (XSUAA/JWT), logging, workers, container
│           └── presentation/    odata, http, rest, web, cli, gui
├── frontend/                SAP Fiori 3 / UI5 app (uim.authorization)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/metadata.xml
│   └── test/ (QUnit formatter tests, OPA5 journey)
├── approuter/               @sap/approuter: xs-app.json, xs-security.json, default-env.example.json
└── k8s/                     ConfigMap, Deployment, Service
```

## Domain

| Object | Description | Rules |
|---|---|---|
| **Application** | owner of APIs and policies (`incident-management`) | name unique per tenant; delete cascades to APIs, policies, assignments |
| **Application API** | endpoint + operations of an application | name unique per application |
| **Policy** | grants `action` on `resource`, optionally restricted by **conditions** | name unique per application; `*` wildcard, `Sales*` prefix, action lists `Read, Update`; **base** policies keep resource/action/conditions; **disabled** policies grant nothing and cannot be assigned |
| **Assignment** | policy → user or group, optionally time bound (`validFrom`/`validTo`) | one assignment per principal and policy; `validTo` after `validFrom` |
| **Decision** | logged answer of an authorization check | immutable; pruned after `decisionRetentionDays` |

**Conditions** are written as text, e.g. `country eq US; department in Sales,Support; level ge 3; email exists`.
Operators: `eq ne contains startsWith endsWith in notIn lt le gt ge exists` (numeric comparison if both sides are numbers;
legacy symbols `== != < <= > >=` are accepted).

**Evaluation**: access is granted if at least one *active* policy of the application that is *effectively assigned* to the user
(directly or via one of the given groups) matches resource, action and **all** conditions against the request attributes.

Base policies (seeded per application, idempotent): `admin` (`*`/`*`), `reader` (`*`/`Read`), `support` (`Incident`/`Read`).

## OData v4 service (`/odata/v4/authorization`)

| Entity set | Operations | Notes |
|---|---|---|
| `Applications` | CRUD | `apiCount`, `policyCount` computed |
| `ApplicationApis` | CRUD | `operations` = `Collection(Edm.String)` |
| `Policies` | CRUD | `conditions` as text, `kind` (base/custom, immutable), `status` |
| `Assignments` | create, update validity, delete | `effective` computed |
| `Decisions` | read | newest first |
| `Statistics` | singleton | KPI figures of the tenant |

Actions: `EvaluateAuthorization` (scope **Check**), `SeedBasePolicies`, `EnablePolicy`, `DisablePolicy`, `PruneDecisions`,
`SeedDemoData` (scope **Admin**). Reads need **Read**, changes **Admin** (enforced when a token verifier is configured).

```sh
curl -H 'X-Tenant-Id: default' 'http://localhost:8117/odata/v4/authorization/Policies?$filter=kind eq '\''custom'\''&$select=name,conditions'
curl -H 'X-Tenant-Id: default' -H 'Content-Type: application/json' -X POST \
  http://localhost:8117/odata/v4/authorization/EvaluateAuthorization \
  -d '{"principalId":"alice","application":"incident-management","resource":"Incident","action":"Read","attributes":"country=US"}'
```

## JSON API (`/api/v1`)

| Method & path | Description |
|---|---|
| `GET/POST /api/v1/{applications,application-apis,policies,policy-assignments}` | list (`?filter=&orderby=&select=&search=&top=&skip=`) / create |
| `GET/PUT/PATCH/DELETE /api/v1/{resource}/{id}` | read / merge update / delete |
| `GET /api/v1/decisions[/{id}]` | decision log |
| `GET /api/v1/policies/base` | base policies |
| `POST /api/v1/policies/seed-base` | `{applicationId}` or `{applicationName}` (created if missing) |
| `POST /api/v1/policies/{id}/enable` · `/disable` | policy lifecycle |
| `POST /api/v1/authorization/evaluate` | `{principalId, applicationId (id or name), resource, action, attributes: {..}, groups: [..]}` |
| `GET /api/v1/principals/{user|group}/{id}/policies` | effective policies (`?application=&groups=`) |
| `GET /api/v1/statistics`, `GET /api/v1/health`, `GET /health` | figures, health |

Release 1 bodies are accepted: `conditions` as `[{attribute, op, value}]`, `isBasePolicy`, attributes as object.
Lists return `{items, totalCount}`; errors `{"error": {"code", "message"}}` with 400/401/403/404/409/422.

## vibe.d REST interface (`/rest/v1/authorization`)

`POST /check` `{principalId, application, resource, action, groups?, attributes?}` ·
`GET /principals/{id}/policies?application=&groups=` · `GET /statistics` — tenant via `X-Tenant-Id`, token via `Authorization`.

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `AUTHORIZATION_<KEY>` env vars →
Cloud Foundry (`PORT`, `VCAP_SERVICES`, user-provided service `authorization-config`) → CLI/GUI options.

| Key | Env var | Default |
|---|---|---|
| `port` / `host` | `AUTHORIZATION_PORT` / `_HOST` | `8117` / `0.0.0.0` |
| `storage` | `AUTHORIZATION_STORAGE` | `memory` (`file`, `mongodb`) — `default.json`: `file` |
| `dataFile` | `AUTHORIZATION_DATA_FILE` | `data/authorization.json` (shared by server, CLI, GUI) |
| `mongoUri` / `mongoDb` / `mongoCollection` | `AUTHORIZATION_MONGO_URI` / `_MONGO_DB` / `_MONGO_COLLECTION` | `mongodb://localhost:27017` / `uim_authorization` / `documents` |
| `defaultTenant` | `AUTHORIZATION_DEFAULT_TENANT` | `default` |
| `apiPath` / `restPath` / `odataPath` / `webPath` | … | `/api/v1` / `/rest/v1/authorization` / `/odata/v4/authorization` / `/web` |
| `recordDecisions` | `AUTHORIZATION_RECORD_DECISIONS` | `true` |
| `decisionRetentionDays` / `decisionPruneMinutes` | … | `90` / `0` (worker off) |
| `seedBasePolicies`, `seedTenantId`, `seedAppName`, `seedOrganizationId` | `AUTHORIZATION_SEED_*` | `true`, `default`, `authorization-management`, `global` |
| `seedDemoData` | `AUTHORIZATION_SEED_DEMO_DATA` | `false` — `default.json`: `true` |
| `requireAuthentication` / `jwtSecret` | … | `false` / `""` (HS256 for non-BTP setups) |
| `frontendDir` | `AUTHORIZATION_FRONTEND_DIR` | `../frontend` |

Legacy variables `AUTHORIZATION_STORAGE_BACKEND` (`MEMORY|FILE|MONGODB`) and `AUTHORIZATION_FILE_PATH` are still honoured.
With an **XSUAA binding** the backend verifies RS256 tokens and enforces the scopes `Read`, `Admin`, `Check`.

## Build, test and run

```sh
cd backend
dub test --config=defaultTest                 # unit + end-to-end tests
dub build                                     # server  → build/uim-authorization-platform-service
dub build --config=cli                        # CLI     → build/uim-authorization-cli
dub build --config=gui                        # GUI     → build/uim-authorization-gui (needs GTK 3)

./build/uim-authorization-platform-service    # http://localhost:8117/app/index.html  ·  /web  ·  /odata/v4/authorization/$metadata
```

### CLI

```sh
./build/uim-authorization-cli seed
./build/uim-authorization-cli list Policies --filter="kind eq 'custom'" --select=name,conditions
./build/uim-authorization-cli create Policies --applicationId=<id> --name=eu-reader --resource='*' --action=Read --conditions="region in EU"
./build/uim-authorization-cli check alice incident-management Incident Read --attributes=country=US   # exit 0 = permit, 3 = deny
./build/uim-authorization-cli effective alice --groups=Support
./build/uim-authorization-cli invoke DisablePolicy --id=<policyId>
./build/uim-authorization-cli stats --json
```

Global options: `--tenant`, `--user`, `--json`, `--csv`, `--storage`, `--data-file`, `--config-dir`.

### GUI

`./build/uim-authorization-gui [--tenant=<id>] [--data-file=<path>] [--refresh=<seconds>]` — a page per entity set
(filter, search, create/edit/delete forms generated from the EDM model), the statistics sheet and an action runner
(e.g. *EvaluateAuthorization*). With file storage it auto-refreshes and shares data with server and CLI.

### Fiori app

Served by the backend at `/app/index.html` during development; on BTP by the approuter. Tabs: Applications, Policies,
Assignments, **Check Access** (EvaluateAuthorization), Decision Log; object pages for applications and policies;
KPI header bound to `/Statistics`. Languages: English, German. Tests: `frontend/test/testsuite.qunit.html`.

### SAP BTP (Cloud Foundry)

```sh
mbt build && cf deploy mta_archives/uim-authorization_2.0.0.mtar
```

Local approuter: `cd approuter && cp default-env.example.json default-env.json && npm install && npm run start:local`.

### Containers & Kubernetes

```sh
# from the uim-platform repository root (the backend depends on ../../service)
docker build -f authorization/backend/Dockerfile -t uim-authorization .
podman build -f authorization/backend/Containerfile -t uim-authorization .
docker run -p 8117:8117 -v ams-data:/data uim-authorization

kubectl apply -f k8s/configmap.yaml -f k8s/deployment.yaml -f k8s/service.yaml
```

## Documentation

- [UML.md](UML.md) — component, class, sequence and deployment diagrams
- [NAFv4.md](NAFv4.md) — NATO Architecture Framework v4 description

References: [AMS in SAP Cloud Identity Services](https://community.sap.com/t5/technology-blogs-by-sap/authorization-management-service-in-sap-cloud-identity-service/ba-p/13881014) ·
[XSUAA to AMS](https://github.com/SAP-samples/btp-developer-guide-cap/blob/main/documentation/xsuaa-to-ams/README.md)
