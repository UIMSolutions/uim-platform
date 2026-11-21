# UIM AI Core Service

A machine learning lifecycle runtime for the UIM platform, modelled on **SAP AI
Core** and its **AI API v2**. Teams register scenarios and executables
(templates), bind them into configurations, run training **executions**, serve
models as **deployments**, track **artifacts** and **metrics**, and schedule
recurring runs. Everything is isolated by tenant and **resource group**.

| Layer | Technology |
| --- | --- |
| Backend | D, uim-framework 26.11, vibe.d 0.10.5, hexagonal / Clean Architecture ([backend/](backend/)) |
| Client API | AI API v2 under `/api/v2` (`/lm/...`, `/admin/...`, header `AI-Resource-Group`) |
| Management API | OData v4 for SAP Fiori (`/odata/v4/ai-core`, `$metadata` with UI annotations, `$batch`) |
| Admin tools | Command line interface (`uim-ai-core-cli`), GtkD 3 desktop GUI (`uim-ai-core-gui`) |
| Frontend | SAP Fiori 3 / OpenUI5 1.120 ([frontend/](frontend/)) |
| Cloud | SAP BTP Cloud Foundry: approuter + XSUAA ([approuter/](approuter/)), [mta.yaml](mta.yaml); Kubernetes ([k8s/](k8s/)); Docker/Podman |

The OData, CLI and GUI adapters run through **one EDM model and one
`ODataEngine`** from the shared `service` package, so validation, scopes,
`$filter`/`$orderby`/`$search` and errors behave the same everywhere. The AI
API controller calls the same driving ports directly and speaks the SAP AI
Core wire format.

See [UML.md](UML.md) for class, component, state and sequence diagrams and
[NAFv4.md](NAFv4.md) for the NATO Architecture Framework v4 description.

---

## What the service does

| Resource | Purpose |
| --- | --- |
| **Resource groups** | Isolation unit for ML resources (one per team, customer or stage). Ids follow the AI Core rules (3–253 chars, `a-z 0-9 . -`). The group named `default` is created on first use. Deleting a group removes everything in it, but only when nothing is running. |
| **Scenarios** | One AI use case (e.g. `text-classification`). It groups executables, configurations and artifacts. |
| **Executables** | Versioned templates of a scenario: a **workflow** (training / batch → executions) or **serving** (inference → deployments). They declare parameters (with optional defaults) and input/output artifact slots (`key:kind`). |
| **Configurations** | Immutable bindings of an executable's parameters and input artifacts. Unknown or missing mandatory parameters, unbound inputs, artifacts from another scenario or of the wrong kind are rejected. |
| **Executions** | One run of a workflow configuration: `PENDING → RUNNING → COMPLETED`, or `STOPPING → STOPPED`. On completion, one artifact per output slot is registered (`ai://default/<group>/executions/<id>/<key>`). |
| **Deployments** | A serving runtime of a serving configuration with an inference URL. Supports stop / restart, rollout of a new configuration (`lastOperation = UPDATE`) and a time to live (≥ 10 min). |
| **Artifacts** | Datasets, models and result sets referenced by URL (`ai://`, `s3://`, `gs://`, `https://`, …). An artifact bound by a configuration cannot be deleted. |
| **Execution schedules** | 5-field cron (UTC) with an optional validity window. They start executions of a workflow configuration. Each records `nextRunAt`, `lastRunAt` and the last execution. |
| **Metrics** | Numeric values per execution, name and step (re-logging the same name and step replaces the value), plus key/value tags on the execution. |
| **Secrets** | Docker registry secrets (tenant wide) and object store secrets (per group). Secret material is reduced to a SHA-256 fingerprint and never returned. |

### Runtime simulation

The service does not start containers. A **reconciler** advances the
lifecycles with configurable durations (`LifecyclePolicy`). It runs as a
background worker every `reconcileIntervalSeconds` for the tenants in
`reconcileTenants`, and on demand (OData action `Reconcile`, CLI `reconcile`).
It:

- provisions resource groups (`provisionSeconds`, 0 = immediately),
- starts executions after `executionStartSeconds` and completes them after `executionRunSeconds`, registering their output artifacts,
- starts deployments after `deploymentStartSeconds`, stops them when their TTL has elapsed, and finishes `STOPPING`,
- fires due schedules and plans their next slot (a failing schedule moves on to its next slot and emits `schedule.failed`).

Every state change is published through the `IAiCoreEventPublisher` port. The
default adapter writes structured JSON log lines (`execution.completed`,
`deployment.running`, `schedule.fired`, …).

### Business rules

- Workflow configurations can only be executed or scheduled; serving configurations can only be deployed (HTTP 412 / OData 422 otherwise).
- Runs and deployments must be stopped (not `PENDING`, `RUNNING` or `STOPPING`) before they can be deleted. Deleting an execution also removes its metrics.
- Scenarios, executables, configurations and artifacts cannot be deleted while other resources reference them.
- Executions and deployments need a `PROVISIONED` group; groups in status `ERROR` are not usable.
- PATCH `targetStatus`: executions accept `STOPPED` and `DELETED`; deployments accept `RUNNING` (restart), `STOPPED` and `DELETED`.

---

## Architecture

```
backend/source/uim/platform/ai_core/
├── domain/          entities, types (ids, keys, labels, time), enumerations, exceptions,
│                    services (identifiers, cron, lifecycle state machines, binding rules)
├── ports/           usecases (driving), services, repositories, storages, gateways (IClock),
│                    messaging (IAiCoreEventPublisher), driving.d (AiCorePorts)
├── application/     usecases (manage/*, reconcile), services (statistics, demo data,
│                    interactor base), dtos (requests, filters, results, Patch!T)
├── persistence/     records (collections), mappers (entity ↔ JSON record),
│                    repositories (tenant / group document repositories), storages (factory)
├── infrastructure/  configuration, logging (+ event publisher), security (XSUAA / HS256),
│                    clients (system / manual clock), workers (reconciler), container.d
└── presentation/    http (AI API v2 + health), odata (EDM model, engine, serializers,
                     payloads), web (Fiori under /app), cli, gui, rest, unix
```

Dependencies point inwards: the domain knows no framework, the application
knows ports only, and adapters are wired in one composition root
(`AiCoreContainer`), which the server, CLI and GUI share.

**Keys.** Everything below a resource group is addressed by (group, id). In
storage and OData the composite key is `"<resourceGroupId>~<id>"` (property
`key`); `id` and `resourceGroupId` are also exposed for filtering. The AI API
takes the group from the `AI-Resource-Group` header.

**Persistence.** A tenant-partitioned JSON document store (`memory` or `file`).
The `file` store is a single snapshot that the server, CLI and GUI can share:
it suits development and single-node operation.

---

## AI API v2

All `/lm/*` routes and `/admin/objectStoreSecrets` are scoped by the
`AI-Resource-Group` header. If the header is missing, `defaultResourceGroup` is
used. Lists answer `{count, resources}` and are paged with `$top` / `$skip`.
Errors answer `{"error": {code, message, requestId, target, details}}` with
400 / 401 / 403 / 404 / 409 / 412 / 500.

| Method | Path (prefix `/api/v2`) | Notes |
| --- | --- | --- |
| GET | `/lm/meta` | Capabilities, limits, extensions |
| GET POST | `/lm/scenarios` | Create is an extension (AI Core syncs scenarios from Git) |
| GET PATCH DELETE | `/lm/scenarios/{id}` | |
| GET | `/lm/scenarios/{id}/versions` | Distinct executable versions |
| GET POST | `/lm/scenarios/{id}/executables` | `?versionId=`; body: `parameters[{name, default}]`, `inputArtifacts[{name, kind}]`, `deployable` or `type` |
| GET PATCH DELETE | `/lm/scenarios/{id}/executables/{executableId}` | |
| GET | `/lm/executables` | Flat list, `?scenarioId=` |
| GET POST | `/lm/configurations` | `?scenarioId=&executableIds=a,b` |
| GET DELETE | `/lm/configurations/{id}` | |
| GET POST PATCH | `/lm/executions` | PATCH = bulk: `{"executions": [{"id", "targetStatus"}]}` |
| GET PATCH DELETE | `/lm/executions/{id}` | `?scenarioId=&configurationId=&executableIds=&status=&executionScheduleId=` on lists |
| GET POST PATCH | `/lm/deployments` | POST `{configurationId, ttl: "30m" \| "12h" \| "7d"}`; PATCH = bulk |
| GET PATCH DELETE | `/lm/deployments/{id}` | PATCH `{targetStatus}` and/or `{configurationId}` |
| GET POST | `/lm/artifacts` | `?scenarioId=&executionId=&kind=&name=` |
| GET DELETE | `/lm/artifacts/{id}` | |
| GET POST | `/lm/executionSchedules` | `{configurationId, cron, name, start, end, status}` |
| GET PATCH DELETE | `/lm/executionSchedules/{id}` | |
| GET PATCH DELETE | `/lm/metrics` | GET `?executionIds=a,b`; PATCH `{executionId, metrics[{name, value, step, timestamp, labels}], tags[{name, value}]}`; DELETE `?executionId=` |
| GET | `/lm/{configurations,executions,deployments,artifacts,executionSchedules}/$count` | Plain number |
| GET POST | `/admin/resourceGroups` | `{resourceGroupId, labels[{key, value}]}` |
| GET PATCH DELETE | `/admin/resourceGroups/{id}` | DELETE cascades |
| GET POST | `/admin/dockerRegistrySecrets` | `{name, data: {".dockerconfigjson": "…"}}` or `{name, server, username, password}` |
| GET PATCH DELETE | `/admin/dockerRegistrySecrets/{name}` | |
| GET POST | `/admin/objectStoreSecrets` | `{name, type, bucket, endpoint, region, pathPrefix, data: {AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY}}` |
| GET PATCH DELETE | `/admin/objectStoreSecrets/{name}` | |
| GET | `/health`, `/api/v1/health`, `/api/v2/health` | Liveness / readiness |

```bash
H='-H AI-Resource-Group:default -H Content-Type:application/json'
curl -s $H localhost:8090/api/v2/lm/configurations -d '{"name":"train","scenarioId":"text-classification",
  "executableId":"text-clf-train","inputArtifactBindings":[{"key":"training-data","artifactId":"support-tickets-2026"}]}'
curl -s $H localhost:8090/api/v2/lm/executions -d '{"configurationId":"<id>"}'
curl -s $H -X PATCH localhost:8090/api/v2/lm/executions/<id> -d '{"targetStatus":"STOPPED"}'
```

## OData v4 (Fiori)

`/odata/v4/ai-core`: entity sets `ResourceGroups`, `Scenarios`,
`Executables`, `Configurations`, `Executions`, `Deployments`, `Artifacts`,
`ExecutionSchedules`, `Metrics`, `DockerRegistrySecrets`,
`ObjectStoreSecrets` and the singleton `Statistics`. Actions: `StopExecution`,
`StopDeployment`, `ResumeDeployment`, `TriggerSchedule`, `ClearMetrics`,
`Reconcile`, `SeedDemoData`. Labels and bindings are collections of
`"key=value"` strings; executable parameters are `"key=default"` and slots
`"key:kind"`.

## Frontend

A Fiori 3 app (`sap.f.DynamicPage`) served by the backend under `/app` for
local development and by the approuter on BTP:

- a KPI header bound to `Statistics`, and a resource group filter that applies to every group-scoped table,
- tabs for executions, deployments, scenarios, executables, configurations, artifacts, schedules, resource groups and secrets,
- create dialogs for every resource (the dialog run from a configuration picks execution or deployment automatically),
- detail pages for executions (output artifacts, metrics, stop, clear metrics), deployments (stop / restart, roll out another serving configuration) and scenarios,
- English and German texts, QUnit tests (formatter, models), an OPA5 journey, and `localService/` metadata plus mock data generated from the demo content.

---

## Build, run, test

```bash
cd ai-core/backend
dub build                          # server  → build/uim-ai-core-platform-service
dub build --config=cli             # CLI     → build/uim-ai-core-cli
dub build --config=gui             # GtkD    → build/uim-ai-core-gui
dub test                           # unit + integration tests (tests/ai_core_flows.d)

./build/uim-ai-core-cli seed --data-file=data/ai-core.json     # demo content
./build/uim-ai-core-platform-service                           # http://localhost:8090/app/index.html
```

The integration tests cover the full lifecycle against a manual clock (cron
slots, TTL expiry, configuration rollout, cascading deletes), the OData
semantics (composite keys, 400/404/405/409/422), the AI API over vibe.d test
requests (envelopes, paging, bulk PATCH, metrics, admin API, 401), and the
shared file store.

### CLI

```bash
uim-ai-core-cli sets | metadata | stats | config
uim-ai-core-cli list Executions --filter="status eq 'RUNNING'" --orderby="submissionTime desc"
uim-ai-core-cli get Deployments default~<id>
uim-ai-core-cli run default train-default            # start an execution
uim-ai-core-cli deploy default serve-v1 --ttl=3600    # create a deployment
uim-ai-core-cli stop Executions default~<id>
uim-ai-core-cli reconcile --times=3
uim-ai-core-cli invoke TriggerSchedule --key=default~nightly-retraining
```

Global options: `--tenant`, `--storage=memory|file`, `--data-file`, `--config-dir`, `--json`, `--csv`.

### Configuration

Precedence (lowest → highest): built-in defaults → `config/default.json` →
`config/<UIM_PROFILE>.json` → `AICORE_<KEY>` environment variables →
Cloud Foundry (`PORT`, `VCAP_APPLICATION`, the user-provided service
`ai-core-config`) → CLI options.

| Key (env) | Default | Meaning |
| --- | --- | --- |
| `port` (`AICORE_PORT`) | `8090` | HTTP port |
| `storage` (`AICORE_STORAGE`) | `memory` (`file` in `config/default.json`) | `memory` or `file` |
| `dataFile` (`AICORE_DATA_FILE`) | `data/ai-core.json` | Snapshot of the file store |
| `defaultTenant` | `default` | Tenant without `X-Tenant-Id` / token |
| `defaultResourceGroup` | `default` | Group without header; created on first use (`""` = off) |
| `aiApiPath` / `odataPath` | `/api/v2` / `/odata/v4/ai-core` | Mount points |
| `requireAuthentication`, `jwtSecret` | `false`, `""` | HS256 tokens outside BTP (XSUAA binding = RS256, always on) |
| `reconcileIntervalSeconds` | `5` | Background reconciler (0 = manual only) |
| `reconcileTenants` | `["default"]` | Tenants of the background reconciler (env: comma list) |
| `provisionSeconds`, `executionStartSeconds`, `executionRunSeconds`, `deploymentStartSeconds` | `0`, `2`, `30`, `5` | Simulated runtime durations |
| `publicUrl`, `inferenceBaseUrl` | `http://localhost:<port>`, `<publicUrl><aiApiPath>/inference` | Base of deployment URLs |
| `frontendDir` | `../frontend` | Fiori app under `/app` (`""` on BTP) |
| `maxPageSize` | `200` | OData server-driven paging |

### Security

| Mode | When | Behaviour |
| --- | --- | --- |
| `xsuaa` | XSUAA binding in `VCAP_SERVICES` | RS256 tokens required. `Read` for reads, `Manage` for writes and actions |
| `hs256` | `requireAuthentication` + `jwtSecret` | Same, with HS256 tokens |
| `open` | Otherwise (local development) | Tenant from `X-Tenant-Id`, user from `X-User-Id` |

Role collections: `AiCoreViewer` (Read) and `AiCoreOperator` (Read + Manage), see [approuter/xs-security.json](approuter/xs-security.json).

---

## Deployment

**SAP BTP Cloud Foundry**

```bash
cd ai-core
mbt build && cf deploy mta_archives/uim-ai-core_2.0.0.mtar
```

Local approuter: copy real XSUAA credentials into
`approuter/default-env.json` (git-ignored), then run `npm start` in
`approuter/` (port 5000, backend at `http://localhost:8090`).

**Docker / Podman** (build context: repository root)

```bash
docker build -f ai-core/backend/Dockerfile -t uim-platform/ai-core .
podman build -f ai-core/backend/Containerfile -t uim-platform/ai-core .
docker run -p 8090:8090 -v ai-core-data:/data uim-platform/ai-core
```

**Kubernetes**

```bash
kubectl apply -f ai-core/k8s/configmap.yaml -f ai-core/k8s/deployment.yaml -f ai-core/k8s/service.yaml
```

The file store is a single-node snapshot, so keep one replica (the manifest
uses `Recreate` and an `emptyDir` at `/data`; use a PersistentVolumeClaim to
keep data across pod restarts).

## Project layout

```
ai-core/
├── mta.yaml                 MTA: backend + approuter + XSUAA + user-provided config
├── backend/                 D / vibe.d service (dub.sdl, config/, source/, tests/, Dockerfile, Containerfile)
├── frontend/                Fiori 3 / OpenUI5 app (manifest.json, view/, controller/, fragment/, model/,
│                            i18n/, localService/, test/)
├── approuter/               @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
├── k8s/                     ConfigMap, Deployment, Service
├── README.md · UML.md · NAFv4.md
```

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
