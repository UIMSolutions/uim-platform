# UIM Task Center

A unified inbox for human tasks, modelled on **SAP Task Center**: it federates
tasks from S/4HANA, SuccessFactors, Ariba, Fieldglass, Concur, SAP Build and
custom REST providers into one place, where users claim, forward, approve,
reject, complete, cancel, escalate and resubmit them.

| | |
| --- | --- |
| Backend | D, vibe.d 0.10.x, hexagonal / clean architecture (`backend/source/uim/platform/task_center/`) |
| APIs | **OData v4** (SAP Fiori, `$metadata` with UI annotations, `$batch`) and **REST/JSON** |
| Front ends | **SAP Fiori 3 / UI5** app, **command line interface**, **GtkD desktop GUI** |
| Deployment | SAP BTP Cloud Foundry (`mta.yaml`: backend + approuter + XSUAA), container image, Kubernetes |

All four front ends (OData, REST, CLI, GUI) drive **one `ODataEngine` built from
one EDM model**, so validation, scopes, query options and error semantics are
identical everywhere.

## What the service does

- **Federation** — task providers are polled through the `ITaskProviderGateway`
  port. New tasks are imported (definition defaults and substitution rules
  applied), known tasks are refreshed by `(providerId, externalTaskId)`, tasks
  the provider reports completed/cancelled/failed are closed. Feeds may be a
  JSON array, OData v4 `value`, OData v2 `d.results` or `tasks`; SAP workflow
  field names (`InstanceID`, `TaskTitle`, `Status READY|RESERVED|…`,
  `Priority VERY_HIGH`, `CompletionDeadline`) are understood. Authentication:
  OAuth 2.0 client credentials (token cached), Basic, API key.
- **Task lifecycle** — a state machine in the domain (`TaskLifecycle`), see
  below. Every action is recorded as an immutable **TaskAction** (audit trail)
  and published as a domain event (`sap.taskcenter.task.<step>`).
- **Task definitions** — category, default priority, SLA (`dueInDays` → due
  date), allowed actions, *requires claim*.
- **Substitution** — users delegate their tasks for a period, optionally with
  **auto-forwarding** of new (and forwarded) tasks; rules bound to a definition
  win over global ones; auto-forward **cycles are refused**. Effective status
  `active | pending | expired | inactive` is derived from the dates.
- **Collaboration** — comments (only the author may edit/delete) and
  attachment metadata (≤ 25 MB, no path separators, http(s) download URL).
- **Saved filters** — `type=value` criteria (`assignee=$me,priority=high,…`)
  translated into an OData `$filter`; one default filter per user.
- **Statistics** — open / in progress / overdue / high priority / unassigned
  tasks, decisions, providers in error, active substitutions.

### Task lifecycle

```text
 open / reserved / forwarded ──claim──▶ inProgress ──release──▶ open
 any unfinished ──forward(to)──▶ forwarded            (claim dropped, substitution applied)
 any unfinished ──approve | reject | complete──▶ completed (outcome approved | rejected | completed)
 any unfinished ──cancel──▶ cancelled
 any unfinished ──escalate──▶ same status, priority + 1
 completed | cancelled | failed ──resubmit──▶ open   (outcome cleared)
```

Business rules: approve/reject need an *approval* or *review* task (or an
explicit allowed action); a non-empty `allowedActions` list restricts approve,
reject, complete, cancel, escalate and resubmit; definitions with
*requires claim* accept decisions only from the claimer; a task claimed by
someone else can neither be claimed, released, forwarded nor decided by you;
reserved tasks can only be claimed by their assignee; finished tasks cannot be
edited. Each task row carries **`availableActions` for the calling user**, which
drives the Fiori buttons.

## Quick start

```bash
cd backend
dub test                                   # unit + integration tests
dub build                                  # → build/uim-task-center-platform-service
dub build --config=cli                     # → build/uim-task-center-cli
dub build --config=gui                     # → build/uim-task-center-gui (needs GTK 3)

./build/uim-task-center-cli seed           # demo data into config/default.json's data file
./build/uim-task-center-platform-service   # http://localhost:8103
```

Open <http://localhost:8103/app/index.html> for the Fiori app (served by the
backend in development; on BTP the approuter serves it). In open mode the user
is taken from the `X-User-Id` header — the app has an *Acting as* field for this.

### Command line

```bash
./build/uim-task-center-cli help
./build/uim-task-center-cli inbox --user=anna                    # unfinished tasks, overdue first
./build/uim-task-center-cli claim po-4711 --user=anna
./build/uim-task-center-cli approve po-4711 --user=anna --comment="Terms checked"
./build/uim-task-center-cli forward onboard-erin dora --user=carl  # dora's substitute gets it
./build/uim-task-center-cli history po-4711
./build/uim-task-center-cli comment leave-ben "Team calendar checked" --user=carl
./build/uim-task-center-cli filter anna-urgent                   # tasks of a saved filter
./build/uim-task-center-cli sync --all                           # pull all active providers
./build/uim-task-center-cli stats --json
# generic, model driven commands for every entity set:
./build/uim-task-center-cli list Tasks --filter="priority eq 'veryHigh'" --orderby="dueDate asc" --count
./build/uim-task-center-cli create SubstitutionRules --userId=anna --substituteId=ben --isAutoForward=true
./build/uim-task-center-cli metadata                             # OData CSDL
```

Global options: `--tenant`, `--user`, `--json`, `--csv`, `--storage=memory|file`,
`--data-file=<path>` (shared with server and GUI), `--config-dir`. Exit codes:
0 success, 1 business/technical failure, 2 usage error.

### Desktop GUI (GtkD)

```bash
./build/uim-task-center-gui --user=anna [--tenant=default] [--data-file=data/task-center.json] [--refresh=5]
```

A page per entity set (filter/search, create/edit/delete forms generated from
the EDM types), the Statistics sheet and an action runner for
`PerformTaskAction`, `SyncProvider` and `SyncAllProviders`. With a file store it
refreshes periodically, so it can run next to the server.

## APIs

### OData v4 — `/odata/v4/task-center`

| Entity set | Writable | Notes |
| --- | --- | --- |
| `Tasks` | create/update/delete (*Manage*) | `status`, `outcome`, `availableActions`, `isOverdue`, counts are computed |
| `TaskDefinitions` | ✓ (*Manage*) | `taskCount`, `openTaskCount` computed |
| `TaskProviders` | ✓ (*Manage*) | `clientSecret` write-only (`hasSecret`), sync status computed |
| `TaskComments` | ✓ (*Process*) | `author` = caller |
| `TaskAttachments` | ✓ (*Process*) | metadata only |
| `TaskActions` | read only | audit trail |
| `SubstitutionRules` | ✓ (*Process*) | own rules; others' with *Manage* |
| `UserTaskFilters` | ✓ (*Process*) | `odataFilter` computed |
| `Statistics` | singleton | key figures |

Actions: `PerformTaskAction(taskId, action, forwardTo?, comment?) → Task` (*Process*),
`SyncProvider(providerId) → SyncResult`, `SyncAllProviders() → Collection(SyncResult)` (*Manage*).
Query options: `$filter`, `$orderby`, `$select`, `$search`, `$top`, `$skip`,
`$count`; `$batch`; `IEEE754Compatible`. The `$metadata` carries
`UI.HeaderInfo`, `UI.LineItem`, `UI.SelectionFields`, `Common.Label`,
`Core.Computed`/`Core.Immutable`.

```bash
curl "localhost:8103/odata/v4/task-center/Tasks?\$filter=assignee eq 'anna'&\$select=title,status,availableActions" -H "X-User-Id: anna"
curl -X POST localhost:8103/odata/v4/task-center/PerformTaskAction -H "X-User-Id: anna" \
     -H "Content-Type: application/json" -d '{"taskId": "po-4711", "action": "claim"}'
```

### REST — `/api/v1/task-center`

The 1.x resource paths are kept and now run through the same engine.

| Method | Path | |
| --- | --- | --- |
| GET / POST | `/{tasks,definitions,providers,comments,attachments,actions,substitutions,filters}` | list (`filter`, `orderby`, `select`, `search`, `top`, `skip` → `{items, totalCount}`) / create |
| GET / PUT / PATCH / DELETE | `/<resource>/:id` | read / merge / delete |
| POST | `/tasks/:id/{claim,release,forward,approve,reject,complete,cancel,escalate,resubmit}` | body `{"forwardTo", "comment"}` (`toUser` accepted) |
| GET | `/tasks/:id/{comments,attachments,actions}` | children of a task |
| POST | `/providers/:id/sync`, `/providers/sync` | federation |
| POST | `/{providers,definitions,substitutions}/:id/{activate,deactivate}`, `/filters/:id/default` | 1.x shortcuts |
| GET | `/statistics`, `/health` | |

Errors: `{"error": {"code", "message"}}` — 400 invalid, 401/403 auth/scope or
not your task, 404, 409 conflict (e.g. already claimed), 422 business rule,
502 provider failed.

### Security

| Mode | When | Identity |
| --- | --- | --- |
| `xsuaa` | an XSUAA binding in `VCAP_SERVICES` | RS256 JWT; scopes `Read`, `Process`, `Manage` enforced |
| `hs256` | `requireAuthentication` + `jwtSecret` | HS256 JWT (tests, non-BTP) |
| `open` | otherwise (development) | `X-Tenant-Id`, `X-User-Id` headers |

Role templates (`approuter/xs-security.json`): *Viewer*, *TaskProcessor*,
*Administrator*; role collections `TaskCenterViewer`, `TaskCenterUser`,
`TaskCenterAdministrator`.

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json`
→ `TASK_CENTER_<KEY>` environment variables → Cloud Foundry (`PORT`,
`VCAP_SERVICES`, user-provided service `task-center-config`) → CLI/GUI options.

| Key (env) | Default | |
| --- | --- | --- |
| `port` (`TASK_CENTER_PORT`) | 8103 | |
| `host` (`TASK_CENTER_HOST`) | 0.0.0.0 | |
| `storage` (`TASK_CENTER_STORAGE`) | memory (`file` in `config/default.json`) | `memory` or `file` |
| `dataFile` (`TASK_CENTER_DATA_FILE`) | data/task-center.json | JSON snapshot shared by server, CLI, GUI |
| `defaultTenant` | default | |
| `restPath` / `odataPath` | /api/v1/task-center, /odata/v4/task-center | |
| `maxPageSize` | 200 | server-driven paging |
| `requireAuthentication`, `jwtSecret` | false, "" | HS256 mode |
| `frontendDir` (`TASK_CENTER_FRONTEND_DIR`) | ../frontend | "" disables `/app` |
| `syncIntervalSeconds` (`TASK_CENTER_SYNC_INTERVAL_SECONDS`) | 0 | background provider sync, 0 = on demand |
| `syncTenants` (`TASK_CENTER_SYNC_TENANTS`) | ["default"] | comma separated in env |
| `providerTimeoutSeconds` | 15 | HTTP timeout towards providers |

`uim-task-center-cli config` prints the effective configuration (secrets masked).

## Deployment

```bash
# SAP BTP Cloud Foundry (approuter + XSUAA + backend)
mbt build && cf deploy mta_archives/uim-task-center_2.0.0.mtar

# Local approuter (copy and fill approuter/default-env.json — never committed)
cd approuter && npm install && npm start      # http://localhost:5000

# Container (build context = repository root)
docker build -f task-center/backend/Dockerfile -t uim-platform/task-center .
podman build -f task-center/backend/Containerfile -t uim-platform/task-center .
docker run -p 8103:8103 -v tc-data:/data uim-platform/task-center

# Kubernetes
kubectl apply -f k8s/
```

The file store is a single-writer snapshot: run one instance (the manifests use
`replicas: 1`, `Recreate`). For durable data mount a persistent volume at `/data`.

## Layout

```text
task-center/
  mta.yaml                 MTA: backend, approuter, XSUAA, user-provided config
  backend/
    dub.sdl                configurations defaultRun | cli | gui | defaultTest
    config/default.json    local defaults
    source/app.d cli.d gui.d   entry points (server, CLI, GtkD GUI)
    source/uim/platform/task_center/
      domain/              entities, types, enumerations, exceptions,
                           services (task_lifecycle, substitution_policy)
      ports/               usecases, services (driving) · repositories, storages,
                           gateways, messaging (driven)
      application/         usecases (Manage*, ProcessTasks, SyncTaskProviders),
                           services (statistics, demo data, events), dtos
      persistence/         records, mappers, repositories, storages
      infrastructure/      configuration, security, logging (+ event publisher),
                           clients (HTTP provider gateway), workers (provider sync), container
      presentation/        odata (model, engine, payloads, serializers), http (REST,
                           health), cli, gui, web (Fiori files), rest, unix
    tests/                 integration tests (OData controller, scopes, lifecycle)
    Dockerfile Containerfile
  frontend/                SAP Fiori 3 app (manifest, views, controllers, fragments,
                           model, i18n en/de, localService, QUnit/OPA5 tests)
  approuter/               xs-app.json, xs-security.json, default-env.json (git-ignored)
  k8s/                     configmap, deployment, service
  README.md UML.md NAFv4.md
```

See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the architecture description.
