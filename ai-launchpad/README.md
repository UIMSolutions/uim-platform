# UIM AI Launchpad

An AI Launchpad in the style of **SAP AI Launchpad**: one place to manage AI runtimes, the machine
learning life cycle and generative AI — with a **launchpad of tiles** and an **administration** for
users, roles, the audit log and the tile catalog.

| Layer | Technology |
|---|---|
| Backend | D, vibe.d 0.10.5, uim-framework, `uim-platform:service` (OData v4 engine, document stores, security) |
| Frontend | SAP Fiori 3 / OpenUI5 1.120 launchpad (`sap.f.ShellBar`, `sap.m.GenericTile`, dynamic pages) |
| Security | Built-in login with PBKDF2 passwords and HS256 **JWT**, or SAP XSUAA via the approuter |
| Deployment | MTA (SAP BTP Cloud Foundry), container image, Kubernetes |

Version 2.0 replaces the former in-memory REST service: the API moved to `/api/v1/ai-launchpad/…`,
OData v4 was added and the old flat `source/` layout became `backend/`, `frontend/` and `approuter/`.

## Concepts

| Area | Resources | What it does |
|---|---|---|
| **Launchpad** | LaunchpadTiles | The tiles of the current user, grouped by section, with live KPI values. Tiles open an app route (`lifecycle/executions`) or a URL. Users only see tiles whose required scope they hold. |
| **AI runtimes** | Workspaces, Connections, ResourceGroups | A connection to an AI runtime (SAP AI Core or a custom AI API) has a service URL, an OAuth token URL and client credentials. The secret is write-only. A connection must be **validated** before it can be used. |
| **ML operations** | Scenarios, Configurations, Executions, Deployments | A configuration binds an executable of a scenario to parameters and input artifacts. Executions (training) and deployments (inference) run it in a resource group. |
| **ML registry** | Models, Datasets | Trained models (name + version unique per scenario) and datasets. |
| **Generative AI hub** | PromptCollections, Prompts, playground | Prompt templates with `{{placeholders}}`, model and sampling parameters, versions, and a playground that renders and runs them. |
| **Administration** | Users, Roles, LogEntries, Tiles | Accounts of the built-in login, roles (sets of scopes), the persistent audit log and the tile catalog. |

### Life cycle and reconciliation

```text
Execution   pending ──▶ running ──▶ completed | failed          pending | running ──stop──▶ stopped
Deployment  pending ──▶ running ──stop / TTL──▶ stopped ──start──▶ pending              pending ──▶ dead
```

New executions and deployments start as `pending`. The **reconcile worker** (every
`reconcileIntervalSeconds`, also the *Synchronize* button, `POST /reconcile` and `cli reconcile`)
polls the runtime for every active workload, applies the reported transitions and stops deployments
whose time to live ended.

The runtime gateway (`ports/gateways/runtime.d`) is implemented by a **deterministic simulation**
(`infrastructure/clients/runtime.d`), so the launchpad works without an SAP AI Core tenant:

- validation needs an `https` URL, an auth URL, a client ID and a secret; hosts containing `unreachable` or `invalid` fail
- executions complete after `simulatedExecutionSeconds`; the configuration parameter `simulate.outcome=failed` makes them fail
- deployments run after `simulatedDeploymentSeconds` at `<connection url>/inference/deployments/<id>`; `simulate.outcome=dead` lets them die
- prompts get a deterministic answer naming the model and echoing the request

A real AI API client only has to implement `IAiRuntime`.

### Business rules (enforced by the use cases)

- Workspaces can only be deleted without connections and prompt collections; inactive workspaces take no new connections or collections.
- Connections can only be deleted without scenarios and resource groups. Changing URL, auth URL, client ID, secret or type resets the status to `pending`.
- Executions and deployments need an **active** connection and a **ready** resource group of that connection (default: the connection's default resource group).
- A configuration uses an executable the scenario offers; its input artifacts must be datasets or models of the same scenario. It is **immutable once used** by an execution or deployment.
- Only finished executions and stopped / dead deployments can be deleted; only active deployments can be scaled (1–10 replicas, `min ≤ max`).
- Resource groups cannot be disabled or deleted while workloads are active in them.
- Models that name an execution need a **completed** execution of the same scenario. Artifacts bound as configuration inputs cannot be deleted or archived.
- Changing the messages or the model of a prompt raises its **version**. Archived prompts cannot run; every placeholder needs an input.
- There is always an unlocked user with the Admin scope: the last one cannot be deleted, locked, demoted — also not by changing or deleting a role. Users cannot lock or delete themselves.
- Built-in roles cannot be deleted; the Administrator role keeps all scopes. Roles assigned to users cannot be deleted.
- Tiles must point to an app route (`[a-z0-9/-]`) or an http(s) URL, use an `sap-icon://` icon, a known KPI and a known scope.

## Authentication and authorization

`authMode` selects how callers are identified; an XSUAA binding in `VCAP_SERVICES` always wins.

| Mode | Login | Tokens | Scopes |
|---|---|---|---|
| `jwt` (default in `config/default.json`) | Login dialog of the launchpad → `POST /auth/login` | HS256, signed with `jwtSecret` | From the user's roles |
| `xsuaa` | Approuter (SAP ID / IdP) | RS256 from XSUAA | From role collections (`xs-security.json`) |
| `open` | none — local development only | – | All |

### Scopes and roles

| Scope | Grants | Implies |
|---|---|---|
| `Read` | the launchpad and every app except the administration | – |
| `Operate` | validate connections, start / stop executions and deployments, run prompts, reconcile | Read |
| `Develop` | maintain scenarios, configurations, models, datasets, prompt collections, prompts | Operate |
| `Manage` | maintain workspaces, connections, resource groups; demo content | Develop |
| `Admin` | users, roles, audit log, tiles | Read |

Built-in roles (also the XSUAA role templates): **Viewer** (Read), **Operator** (+Operate),
**Developer** (+Develop), **Manager** (+Manage), **Administrator** (all). Administrators can add
custom roles, e.g. an *Auditor* with `Read, Admin`.

### Login flow

1. First start in `jwt` mode: if the tenant has no users, the user `adminUser` (default `admin`) is
   created with the Administrator role. Without `adminPassword` a random password is generated and
   logged **once**.
2. `POST /auth/login {username, password[, tenant]}` checks a salted PBKDF2-SHA256 hash
   (`passwordIterations`). Unknown users and wrong passwords give the same answer; `maxFailedLogins`
   failures lock the account for `lockSeconds`.
3. The JWT carries XSUAA-compatible claims (`sub`, `user_name`, `zid`, `scope[]`, `roles[]`, `exp`).
   The launchpad keeps it in `sessionStorage` and sends it as `Authorization: Bearer …` with every
   OData and REST request.
4. `GET /auth/me` returns the caller, `POST /auth/password` changes the own password,
   `POST /auth/logout` lets the client forget the token.

Without `jwtSecret` a random secret is used and tokens end with the process — set
`AILP_JWT_SECRET` (≥ 32 characters) in production.

### Audit log

Every state change, login, password change and administration action is written as a JSON log line
**and** stored in the audit log (`LogEntries`, administration → *Audit Log*): time, user, event type,
subject, category (security, administration, runtime, lifecycle, genai, system), severity and the
changed field names. Passwords, secrets and prompt contents are never logged. Entries older than
`logRetentionDays` are purged by the worker (every `purgeEveryRuns`-th run) or on demand.

## Project layout

```text
ai-launchpad/
├── mta.yaml                      SAP BTP: backend + approuter + XSUAA + user-provided config
├── backend/
│   ├── dub.sdl                   configurations defaultRun | cli | gui | defaultTest
│   ├── config/default.json       defaults (overridden by AILP_* env and VCAP_SERVICES)
│   ├── Dockerfile, Containerfile
│   ├── tests/launchpad_flows.d   integration tests across all layers
│   └── source/
│       ├── app.d  cli.d  gui.d   entry points (HTTP server, CLI, GtkD GUI)
│       └── uim/platform/ai_launchpad/
│           ├── domain/           entities, types (ids, scopes, time), enumerations, exceptions,
│           │                     services (labels, prompt templates, roles)
│           ├── ports/            usecases, services, repositories, storages, messaging, gateways
│           ├── application/      dtos, usecases (runtimes, lifecycle, registry, reconcile, genai,
│           │                     launchpad, access, logging), services (statistics, tiles, demo data)
│           ├── persistence/      repositories, storages (memory / file, batching), mappers, records
│           ├── infrastructure/   configuration, security (JWT, PBKDF2), logging (audit trail),
│           │                     clients (clock, simulated runtime), workers, monitoring, container
│           └── presentation/     odata (EDM model, engine), http (REST, auth, health), web, cli, gui
├── frontend/                     Fiori 3 / OpenUI5 launchpad
│   ├── manifest.json  Component.js  index.html
│   ├── view/                     App (ShellBar), Launchpad, Runtimes, Lifecycle, GenAI, Admin
│   ├── controller/  model/  fragment/  i18n/ (en, de)
│   ├── localService/             metadata.xml and mock data generated from the demo content
│   └── test/                     QUnit unit tests, OPA5 journey
├── approuter/                    xs-app.json, xs-security.json, default-env.json (local, git-ignored)
└── k8s/                          ConfigMap, Secret example, Deployment + PVC, Service
```

## Build and run

The backend depends on the shared package `../../service`, which needs **uim-framework 26.11.1**
(26.11.2 dropped `uim.services`).

```bash
cd backend
dub build                       # HTTP server  → build/uim-ai-launchpad-platform-service
dub build --config=cli          # CLI          → build/uim-ai-launchpad-cli
dub build --config=gui          # GtkD GUI     → build/uim-ai-launchpad-gui
dub test                        # unit and integration tests
```

### Local development

```bash
cd backend
./build/uim-ai-launchpad-platform-service
# first start in jwt mode: the log shows the generated password of "admin" once
# Launchpad: http://localhost:8097/app/index.html   (log on as admin; "Create Demo Content" in an empty tenant)
# OData:     http://localhost:8097/odata/v4/ai-launchpad/$metadata
# REST:      http://localhost:8097/api/v1/ai-launchpad/capabilities
# Health:    http://localhost:8097/health

# without login (development only)
AILP_AUTH_MODE=open AILP_STORAGE=memory ./build/uim-ai-launchpad-platform-service
```

With the approuter (XSUAA) locally: fill in `approuter/default-env.json` from a service key, then
`cd approuter && npm install && npm start` (port 5000).

### CLI

The CLI uses the same container and storage as the server (share a `--data-file` with it).

```bash
./build/uim-ai-launchpad-cli help
./build/uim-ai-launchpad-cli seed --data-file=data/ai-launchpad.json
./build/uim-ai-launchpad-cli launchpad                       # tiles with KPI values
./build/uim-ai-launchpad-cli validate aicore-eu
./build/uim-ai-launchpad-cli execute fraud-train --resource-group=fraud-team
./build/uim-ai-launchpad-cli deploy fraud-serve --replicas=3 --ttl=120
./build/uim-ai-launchpad-cli reconcile
./build/uim-ai-launchpad-cli run-prompt summarize-ticket language=English "ticket=Printer prints blank pages"
./build/uim-ai-launchpad-cli logs --severity=warning --top=20
./build/uim-ai-launchpad-cli token admin                     # bearer token for scripts
./build/uim-ai-launchpad-cli passwd admin 'a new long password'
./build/uim-ai-launchpad-cli list Prompts --filter="status eq 'active'"   # generic entity commands
```

Exit codes: `0` success, `1` error, `2` usage, `3` the operation ran but failed (invalid connection).

### Container / Kubernetes / BTP

```bash
# from the repository root (path dependency on ../../service)
docker build -f ai-launchpad/backend/Dockerfile -t uim-platform/ai-launchpad .
docker run -p 8097:8097 -e AILP_JWT_SECRET=$(openssl rand -base64 48) -e AILP_ADMIN_PASSWORD='change me now!' \
  -v ailp-data:/data uim-platform/ai-launchpad

kubectl apply -f ai-launchpad/k8s/configmap.yaml
cp ai-launchpad/k8s/secret.example.yaml ai-launchpad/k8s/secret.yaml   # fill in, never commit
kubectl apply -f ai-launchpad/k8s/secret.yaml -f ai-launchpad/k8s/deployment.yaml -f ai-launchpad/k8s/service.yaml

cd ai-launchpad && mbt build && cf deploy mta_archives/uim-ai-launchpad_2.0.0.mtar
```

The file storage is a single-node snapshot: run one replica (`strategy: Recreate`).

## APIs

### OData v4 — `/odata/v4/ai-launchpad`

Entity sets: `Workspaces`, `Connections`, `ResourceGroups`, `Scenarios`, `Configurations`,
`Executions`, `Deployments`, `Models`, `Datasets`, `PromptCollections`, `Prompts`, `Tiles`,
`LaunchpadTiles` (read only), `Users`, `Roles`, `LogEntries` (read only) and the singleton
`Statistics`. `$filter`, `$orderby`, `$top`, `$skip`, `$count`, `$search`, `$select` and `$batch`
are supported; `$metadata` carries the Fiori UI annotations.

Actions: `ValidateConnection(id)`, `StopExecution(id)`, `StopDeployment(id)`, `StartDeployment(id)`,
`RunPrompt(id, inputs)`, `Reconcile`, `PurgeLogs`, `RestoreDefaultTiles`, `SeedDemoData`.

### REST — `/api/v1/ai-launchpad`

| Method | Path | Description |
|---|---|---|
| GET | `/<resource>[?$filter=…&$orderby=…&$top=…&$search=…]` | list → `{count, resources}` |
| GET / POST / PUT / PATCH / DELETE | `/<resource>[/{id}]` | read, create (201), change, delete (204) |
| GET | `/launchpad` | the tiles of the caller with KPI values |
| POST | `/connections/{id}/validate` | validate with the runtime |
| POST | `/executions/{id}/stop` | stop an execution |
| POST | `/deployments/{id}/stop`, `/deployments/{id}/start` | stop / restart a deployment |
| POST | `/prompts/{id}/run` `{inputs: {name: value}}` | run a prompt (playground) |
| GET | `/workspaces/{id}/connections`, `/connections/{id}/scenarios`, `/scenarios/{id}/executions`, … | children |
| POST | `/reconcile`, `/logs/purge`, `/tiles/restore-defaults`, `/demo-data` | operations |
| GET | `/statistics`, `/capabilities`, `/meta` | KPIs and service description |

Resources: `workspaces`, `connections`, `resource-groups`, `scenarios`, `configurations`,
`executions`, `deployments`, `models`, `datasets`, `prompt-collections`, `prompts`, `tiles`,
`users`, `roles`, `logs`. Errors answer `{"error": {code, message, requestId, target}}` with
400 / 401 / 403 / 404 / 405 / 409 / 413 / 422 / 500.

### Auth and health

`GET /auth/config`, `POST /auth/login`, `GET /auth/me`, `POST /auth/password`, `POST /auth/logout`,
`GET /health` (also `/api/v1/health`, with the reconcile worker metrics).

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `AILP_<KEY>`
environment variables (e.g. `AILP_JWT_SECRET`) → `VCAP_SERVICES` (user-provided service
`ai-launchpad-config`) → command line options.

| Key | Default | Meaning |
|---|---|---|
| `port` / `host` | 8097 / 0.0.0.0 | HTTP listener (Cloud Foundry: `PORT`) |
| `storage` / `dataFile` | memory / `data/ai-launchpad.json` | `memory` or `file` (JSON snapshot shared by server, CLI, GUI) |
| `authMode` | open (`jwt` in `default.json`) | `open` or `jwt`; an XSUAA binding switches to `xsuaa` |
| `jwtSecret` | random per start | HS256 secret, ≥ 32 characters |
| `tokenTtlSeconds` | 3600 | token lifetime |
| `adminUser` / `adminPassword` | admin / generated | first administrator |
| `passwordIterations` | 120000 | PBKDF2 rounds |
| `maxFailedLogins` / `lockSeconds` | 5 / 900 | temporary account lock |
| `minPasswordLength` | 10 | password policy |
| `logRetentionDays` / `persistAuditLog` | 30 / true | audit log |
| `reconcileIntervalSeconds` / `purgeEveryRuns` | 15 / 240 | worker; 0 = on demand only |
| `workerTenants` | `["default"]` | tenants of the worker (and bootstrapped with roles and tiles) |
| `simulatedExecutionSeconds` / `simulatedDeploymentSeconds` / `simulatedFailurePercent` | 60 / 5 / 0 | runtime simulation |
| `frontendDir` | `../frontend` | serve the launchpad under `/app` (`""` on BTP: the approuter serves it) |
| `apiPath` / `odataPath` | `/api/v1` / `/odata/v4/ai-launchpad` | endpoints |

`uim-ai-launchpad-cli config` prints the effective configuration with secrets masked.

## Tests

```bash
cd backend && dub test        # 46 modules: domain, ports, application, persistence, infrastructure,
                              # presentation and tests/launchpad_flows.d (REST, OData, JWT, CLI, file store)
# frontend (served by the backend):
#   http://localhost:8097/app/test/unit/unitTests.qunit.html
#   http://localhost:8097/app/test/integration/opaTests.qunit.html   (authMode open, demo content)
```

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
