# UIM Integration Automation

Guided integration workflows in the style of **SAP Cloud Integration Automation Service (CIAS)**: integration
experts describe an integration once as a **scenario** with task templates; operators instantiate it as a
**workflow** for a concrete pair of systems, work through the manual and approval tasks, and the service executes
the automated tasks through **destinations** — with dependencies, monitoring and a complete execution log.

- **Backend** — D, uim-framework 26.11, vibe.d 0.10.5, hexagonal / clean architecture (`backend/`)
- **Frontend** — SAP Fiori 3 / OpenUI5 1.120 app (`frontend/`)
- **Approuter** — SAP BTP entry point with XSUAA (`approuter/`), MTA deployment (`mta.yaml`), Kubernetes (`k8s/`)
- **Interfaces** — OData v4 (Fiori), REST, CLI, GtkD desktop GUI — all driven by one EDM model
- **Security** — built-in login with JWT (HS256, PBKDF2 passwords, lockout), XSUAA (RS256) on BTP, or open for development

See [UML.md](UML.md) for class, component, state and sequence diagrams and [NAFv4.md](NAFv4.md) for the NATO
Architecture Framework v4 description.

---

## Concepts

```text
System ──< Destination                     the landscape: where integrations happen and how APIs are reached
Scenario ──< ScenarioTask (template)       the reusable definition (draft → active → deprecated → archived)
Scenario ──< Workflow ──< WorkflowTask     an instance for one source and one target system
Workflow ──< ExecutionLog                  everything that happened, by whom, with which outcome
```

| Concept | Meaning |
|---|---|
| **System** | An SAP or third-party system of the landscape (S/4HANA Cloud, SuccessFactors, BTP, Ariba, …) with host, port, client, SID, environment and the result of the last connection test. |
| **Destination** | How automated tasks reach an API: type (HTTP, OData, SOAP, REST, RFC), URL, authentication, proxy (internet, Cloud Connector, private link). Secrets are never stored. |
| **Scenario** | Category (Lead-to-Cash, Source-to-Pay, …), version, required source/target system types, prerequisites. |
| **Task template** | A guided step: manual, approval, automated (destination + endpoint + payload) or notification; role, instructions, priority, estimate, dependencies. |
| **Workflow** | A running instance: status, progress, current task, source and target system. |
| **Task** | A copy of a template inside a workflow with its own status, assignee, result, error, attempts and duration. |

### Task types

| Type | Processed by | Notes |
|---|---|---|
| `manual` | a person | start → complete with a result, or fail with an error |
| `approval` | a person | complete = approve, fail = reject; **cannot be skipped** |
| `automated` | the automation gateway | `POST`/`GET` destination URL + endpoint; 2xx = success |
| `notification` | the automation gateway | informs the role / assignee (webhook in `http` mode) and completes |

### Dependencies

A template depends on the templates with the **next lower sequence number** (`afterPrevious`, default) and on any
templates listed in `dependsOn`. Dependencies may only point to *lower* sequence numbers, so the graph is always
acyclic and tasks with the same sequence number run in parallel. A task is **ready** when all its dependencies are
completed or skipped.

### Lifecycles

```text
Scenario   draft ──activate──▶ active ──deprecate──▶ deprecated ──archive──▶ archived
             └────────────────archive─────────────────────────────▲
Workflow   planned ──start──▶ inProgress ⇄ suspended
                               │  ▲ retry / skip
                               ▼  │
                              failed          inProgress ──(all tasks done)──▶ completed
           any open ──terminate──▶ terminated
Task       pending ──start──▶ inProgress ──complete──▶ completed
                                         └──fail────▶ failed ──retry──▶ pending
           pending | failed ──skip──▶ skipped (not approvals)
```

### Business rules (enforced by the use cases)

| Rule | |
|---|---|
| Open workflow limit | at most `maxOpenWorkflows` (default **15**, the SAP CIAS limit) planned, running, suspended or failed workflows per tenant |
| Active scenarios only | workflows are created from **active** scenarios with at least one task template |
| Frozen templates | task templates change only while the scenario is a **draft**; category, version and system types of a non-draft scenario are fixed — *copy as new version* creates a draft `1.0 → 1.1` with remapped templates |
| Systems | required when a template needs them, must exist, must differ and must match the scenario's system types (`any` = no restriction) |
| Dependencies | a task starts only when its dependencies are done; a failed task fails the workflow until it is retried or skipped |
| Running workflows | tasks change only while the workflow is in progress or failed (not planned, suspended or finished) |
| Assignees | must be valid user names; when the built-in login has users, the user must exist |
| References | systems, destinations and scenarios cannot be deleted while destinations, templates or workflows use them; only planned or finished workflows can be deleted (the log is kept) |
| Unique names | destination names are unique per tenant (case insensitive) |

---

## Project layout

```text
integration-automation/
├── mta.yaml                      SAP BTP deployment (backend, approuter, XSUAA, config service)
├── backend/                      D / vibe.d service
│   ├── dub.sdl                   configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json       defaults (overridden by IA_* env vars and VCAP_SERVICES)
│   ├── source/app.d | cli.d | gui.d
│   ├── source/uim/platform/integration_automation/
│   │   ├── domain/               entities, types (ids, time, scopes), enumerations, exceptions,
│   │   │                         services (WorkflowEngine, ScenarioPlanner — pure functions)
│   │   ├── ports/                usecases, services, repositories, storages, messaging, gateways
│   │   ├── application/          use cases, application services (statistics, demo data), DTOs
│   │   ├── infrastructure/       configuration, logging, security (JWT, PBKDF2), clients
│   │   │                         (automation gateway, connectivity probe, clock), workers, container
│   │   ├── persistence/          document repositories, batching stores, mappers, records
│   │   └── presentation/         odata (EDM model + engine), http (REST, auth, health), web, cli, gui
│   ├── tests/                    integration tests across all layers
│   └── Dockerfile | Containerfile
├── frontend/                     SAP Fiori 3 / OpenUI5 app
│   ├── manifest.json | Component.js | index.html
│   ├── view/ controller/ fragment/   Main (tabs), WorkflowDetail, ScenarioDetail, dialogs
│   ├── model/                    models, formatter, session (JWT login), dialog definitions
│   ├── i18n/                     English, German
│   ├── localService/             $metadata and mock data captured from the backend
│   └── test/                     QUnit (formatter, models, session), OPA5 journey
├── approuter/                    @sap/approuter: xs-app.json, xs-security.json, default-env.json (local, ignored)
└── k8s/                          deployment, service, configmap, secret example
```

---

## Build and run

Requirements: `dub` with `dmd` or `ldc2`; the shared library `../../service` (path dependency).

```bash
cd backend
dub build                      # server   → build/uim-integration-automation-platform-service
dub build --config=cli         # CLI      → build/uim-integration-automation-cli
dub build --config=gui         # GtkD GUI → build/uim-integration-automation-gui
dub test                       # unit and integration tests
```

### Local development

```bash
cd backend
IA_AUTH_MODE=open ./build/uim-integration-automation-platform-service
# Fiori app:  http://localhost:8090/app/index.html     ("Create Demo Content" in an empty tenant)
# OData:      http://localhost:8090/odata/v4/integration-automation/$metadata
# REST:       http://localhost:8090/api/v1/integration-automation/meta
```

With the defaults (`config/default.json`: `authMode: jwt`, `storage: file`) the server creates the user `admin` on
first start and logs a generated password once (set `IA_ADMIN_PASSWORD` and `IA_JWT_SECRET` to choose them). The
Fiori app then shows a login dialog.

### CLI

The CLI uses the same container and storage; with `--data-file` it shares the JSON snapshot with a running server.

```bash
./build/uim-integration-automation-cli help
./build/uim-integration-automation-cli seed --data-file=data/integration-automation.json
./build/uim-integration-automation-cli list Workflows --filter="status eq 'inProgress'"
./build/uim-integration-automation-cli tasks wf-employee-wave1
./build/uim-integration-automation-cli task-start <task> ; ./build/uim-integration-automation-cli complete <task> "done"
./build/uim-integration-automation-cli instantiate sf-s4-employee --source=sf-prd --target=s4-cloud-prd --start
./build/uim-integration-automation-cli run                # ready automated / notification tasks
./build/uim-integration-automation-cli token admin        # access token (jwt mode)
```

Further commands: `stats`, `test`, `activate`, `deprecate`, `archive`, `copy`, `start`, `suspend`, `resume`,
`terminate`, `fail`, `skip`, `retry`, `assign`, `purge`, `passwd`, `config` and the generic `sets`, `metadata`,
`get`, `create`, `update`, `delete`, `invoke` (all with `--json` / `--csv`).

### Container / Kubernetes / BTP

```bash
# from the repository root (path dependency on ../../service)
docker build -f integration-automation/backend/Dockerfile -t uim-platform/integration-automation .
kubectl apply -f integration-automation/k8s/          # after copying secret.example.yaml to secret.yaml
mbt build && cf deploy mta_archives/uim-integration-automation_2.0.0.mtar   # SAP BTP Cloud Foundry
```

Locally behind the approuter: `cd approuter && npm install && npm start` with `default-env.json` pointing to
`http://localhost:8090`.

---

## Authentication and authorization

| Mode | Selected by | Behaviour |
|---|---|---|
| `xsuaa` | XSUAA binding in `VCAP_SERVICES` | approuter login, RS256 tokens verified, scopes enforced |
| `jwt` | `authMode: "jwt"` (or `requireAuthentication: true`) | built-in login (`/auth/login`), HS256 tokens, scopes enforced |
| `open` | `authMode: "open"` | no authentication (local development); tenant from `X-Tenant-Id`, user from `X-User-Id` |

| Scope | Allows | XSUAA role template |
|---|---|---|
| `Read` | read everything | Viewer |
| `Execute` | create and run workflows; start, complete, fail, skip, retry and assign tasks; run automation | TaskProcessor |
| `Manage` | maintain systems, destinations, scenarios and templates; test connections; purge the log (implies `Execute`) | IntegrationExpert |
| `Admin` | manage the users of the built-in login (`/Users`) | Administrator |

Built-in login endpoints:

| Method | Path | Purpose |
|---|---|---|
| GET | `/auth/config` | `{mode, loginRequired}` (public) |
| POST | `/auth/login` | `{username, password, tenant?}` (JSON or form) → `{access_token, token_type, expires_in, scope, user}` |
| GET | `/auth/me` | the caller |
| POST | `/auth/password` | `{currentPassword, newPassword}` |
| POST | `/auth/logout` | 204 (stateless) |

Tokens carry XSUAA compatible claims (`sub`, `user_id`, `user_name`, `zid`, `scope[]`, `exp`, `jti`). Passwords:
PBKDF2-HMAC-SHA256 (120 000 rounds, random salt, transparent rehash), at least 10 characters. After 5 failed logins
the account is locked for 15 minutes; unknown users and wrong passwords answer alike. The last administrator cannot
be deleted, locked or demoted. The Fiori app shows a login dialog in `jwt` mode, keeps the token per browser tab and
offers password change and sign-out in the user menu; buttons follow the scopes of the session.

### Destination credentials

Passwords, client secrets and certificates are never stored by this service. In `automationMode: http` the
automation gateway sends the `Authorization` header from the environment variable
`IA_DESTINATION_<NAME>_AUTHORIZATION` (destination name upper case, other characters `_`, e.g.
`IA_DESTINATION_S4_BUSINESS_PARTNER_AUTHORIZATION="Bearer …"`); the Destinations list shows the variable name.

---

## APIs

### OData v4 — `/odata/v4/integration-automation`

| Entity set | Operations | Write scope |
|---|---|---|
| `Systems`, `Destinations`, `Scenarios`, `ScenarioTasks` | CRUD | Manage |
| `Workflows` | create (from a scenario), PATCH name/description, delete | Execute |
| `WorkflowTasks` | read, PATCH `assignedTo` / `priority` | Execute |
| `ExecutionLogs` | read only | — |
| `Users` | CRUD | Admin |
| `Statistics` | singleton | — |

Actions: `TestSystemConnection`, `ActivateScenario`, `DeprecateScenario`, `ArchiveScenario`, `CopyScenario`,
`StartWorkflow`, `SuspendWorkflow`, `ResumeWorkflow`, `TerminateWorkflow`, `StartTask`, `CompleteTask`, `FailTask`,
`SkipTask`, `RetryTask`, `AssignTask`, `RunAutomatedTasks`, `PurgeExecutionLogs`, `SeedDemoData`.
`$metadata` carries Fiori annotations (`UI.LineItem`, `UI.SelectionFields`, `UI.HeaderInfo`, `Common.Label`,
`Core.Computed`, `Core.Immutable`). Supported: `$filter`, `$orderby`, `$select`, `$top`, `$skip`, `$count`,
`$search`, `$batch`, server-driven paging.

### REST — `/api/v1/integration-automation`

| Method | Path | |
|---|---|---|
| GET/POST | `/{resource}` | `systems`, `destinations`, `scenarios`, `scenario-tasks`, `workflows`, `tasks`, `execution-logs`, `users` — lists answer `{count, resources}` and accept OData query options |
| GET/PUT/PATCH/DELETE | `/{resource}/{id}` | |
| POST | `/systems/{id}/test` | connection test |
| POST | `/scenarios/{id}/activate` · `/deprecate` · `/archive` · `/copy` `{newId?}` | |
| GET | `/scenarios/{id}/tasks` | templates in sequence |
| POST | `/workflows/{id}/start` · `/suspend` · `/resume` · `/terminate` `{reason?}` | |
| GET | `/workflows/{id}/tasks` · `/workflows/{id}/logs` | |
| POST | `/tasks/{id}/start` · `/complete` `{result?}` · `/fail` `{errorMessage}` · `/skip` `{reason}` · `/retry` · `/assign` `{assignedTo?, priority?}` | |
| GET | `/my-tasks` | open tasks assigned to the caller |
| POST | `/automation/run` `{workflowId?}` | run ready automated tasks |
| POST | `/execution-logs/purge` `{olderThanDays}` | |
| GET | `/statistics` · `/meta` | |
| POST | `/demo-data` | demo content for an empty tenant |

Errors: `{"error": {code, message, requestId, target}}` with 400 (invalid), 401, 403 (scope), 404, 405, 409 (conflict),
422 (business rule) and 500. Health: `GET /health` and `/api/v1/health` (public).

---

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `IA_*` environment variables →
Cloud Foundry (`PORT`, `VCAP_SERVICES`, user-provided service `integration-automation-config`) → CLI options.
`CIA_HOST` / `CIA_PORT` of the first generation still work.

| Key | Env | Default | |
|---|---|---|---|
| `port` / `host` | `IA_PORT` / `IA_HOST` | `8090` / `0.0.0.0` | |
| `storage` / `dataFile` | `IA_STORAGE` / `IA_DATA_FILE` | `memory` / `data/integration-automation.json` | `file`: JSON snapshot shared by server, CLI and GUI (single node) |
| `authMode` | `IA_AUTH_MODE` | `open` | `open` or `jwt` (XSUAA binding wins) |
| `jwtSecret` | `IA_JWT_SECRET` | random per start | ≥ 32 characters |
| `tokenTtlSeconds` | `IA_TOKEN_TTL_SECONDS` | `3600` | |
| `adminUser` / `adminPassword` | `IA_ADMIN_USER` / `IA_ADMIN_PASSWORD` | `admin` / generated | first administrator in `jwt` mode |
| `maxFailedLogins` / `lockSeconds` / `minPasswordLength` | | `5` / `900` / `10` | |
| `maxOpenWorkflows` | `IA_MAX_OPEN_WORKFLOWS` | `15` | `0` = unlimited |
| `workerIntervalSeconds` | `IA_WORKER_INTERVAL_SECONDS` | `5` | automation worker; `0` = run automated tasks inline |
| `workerTenants` | `IA_WORKER_TENANTS` | `["default"]` | comma separated in env |
| `automationMode` | `IA_AUTOMATION_MODE` | `simulate` | `simulate` or `http` |
| `automationTimeoutSeconds` | `IA_AUTOMATION_TIMEOUT_SECONDS` | `30` | |
| `notificationWebhookUrl` | `IA_NOTIFICATION_WEBHOOK_URL` | — | notifications in `http` mode |
| `connectivityMode` | `IA_CONNECTIVITY_MODE` | `simulate` | `simulate` or `tcp` (connection tests) |
| `logRetentionDays` | `IA_LOG_RETENTION_DAYS` | `0` | daily purge of older log entries; `0` = keep |
| `frontendDir` | `IA_FRONTEND_DIR` | `../frontend` | serves the Fiori app under `/app` (empty on BTP) |
| `apiPath` / `odataPath` / `maxPageSize` / `maxRequestBytes` | | `/api/v1` / `/odata/v4/integration-automation` / `200` / 4 MiB | |

`config/default.json` sets `storage: file`, `authMode: jwt` and `logRetentionDays: 90` for a ready-to-use local
installation. `./build/uim-integration-automation-cli config` prints the effective configuration (secrets masked).

---

## Tests

```bash
cd backend && dub test
```

29 test modules: domain (entities, state machines, workflow engine, scenario planner, scopes), persistence mapping,
configuration, security (PBKDF2 vectors, token issuing), automation and connectivity adapters, and
`tests/integration_automation_flows.d` — the guided workflow end to end through the ports, the business rules,
failing automation / suspend / terminate / housekeeping, REST and OData over vibe.d test requests, the JWT login with
the scopes Read / Execute / Manage / Admin, the CLI and the batching file store.

Frontend: `frontend/test/unit/unitTests.qunit.html` (formatter, models, dialogs, session) and the OPA5 journey
`frontend/test/integration/opaTests.qunit.html` (against a running backend with demo data, served under `/app/test/`).

---

## License

Apache 2.0 — © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
