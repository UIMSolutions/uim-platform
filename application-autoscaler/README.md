# UIM Application Autoscaler

Application Autoscaler service of the UIM Platform, modelled on the SAP BTP Application Autoscaler: applications are
**bound** to the service, a **scaling policy** sets their instance limits, **dynamic rules** scale them out and in on
standard metrics (CPU, memory, disk, throughput, response time) or **custom metrics** the applications send
themselves, and **schedules** change the limits for business hours or special dates. Every decision is recorded in an
immutable **scaling history**.

| Part | Technology | Folder |
|---|---|---|
| Backend | D, uim-framework 26.11, vibe.d 0.10.5, clean / hexagonal architecture | [backend/](backend/) |
| Frontend | SAP Fiori 3 / OpenUI5 1.120 (OData V4) | [frontend/](frontend/) |
| Approuter | `@sap/approuter` with XSUAA | [approuter/](approuter/) |
| Deployment | MTA (SAP BTP Cloud Foundry), Docker/Podman, Kubernetes | [mta.yaml](mta.yaml), [k8s/](k8s/) |
| Architecture | UML (Mermaid) and NAF v4 descriptions | [uml.md](uml.md), [nafv4.md](nafv4.md) |

One EDM model drives every adapter: the OData v4 endpoint for Fiori (incl. `$metadata` with UI annotations), the
REST API, the command line and the GtkD desktop GUI. All of them validate, authorize and answer alike.

## Concepts

| Resource | Purpose |
|---|---|
| **Binding** | An application (Cloud Foundry app GUID or workload reference) bound to the service: name, service instance, attached policy, the instance count the autoscaler set last, autoscaling active or suspended. |
| **Policy** | Minimum and maximum instances, the time zone of its schedules, active/inactive, and which applications may send custom metrics (`sameApp`, `boundApp`). |
| **Rule** | `metric operator threshold` held for a **breach duration** → **adjustment** (`+1`, `-2`, `+50%`, `-25%`), followed by a **cool-down**. |
| **Schedule** | **Recurring** (days of the week or month, `HH:MM`–`HH:MM`, optional validity dates; over midnight allowed) or **specific date** (`start`–`end`). While active, its limits replace the policy's; `initialMinInstanceCount` raises the instances once at its start. |
| **Metric sample** | A measured value (`cpu`, `memoryutil`, …, or a custom name such as `jobqueue`) of a binding with its time and source. |
| **Scaling event** | The history entry of a decision: trigger (dynamic rule, schedule, policy limits, manual), instances before/after, metric value, threshold, reason, platform message, status. |

### How a decision is made (`domain/services/scaling_decider.d`)

1. **Limits**: an active specific-date schedule, else an active recurring schedule, else the policy.
2. Instances **outside the limits** are brought inside (trigger `limits` or `schedule`); a schedule that has just
   started raises the instances to its initial minimum.
3. Each enabled **rule** is checked against the binding's samples: the newest sample must be fresh
   (`metricStaleSeconds`, default 600) and the comparison must have held without interruption for the breach
   duration. Rules inside the cool-down since the binding's last scaling are skipped.
4. **Scale-out wins over scale-in** (availability first); among scale-out rules the largest target, among scale-in
   rules the smallest reduction wins. The target is limited to the instance limits.
5. A change goes to the platform through the `IInstanceController` port (`simulate` or `http`); success or failure
   is recorded as a scaling event, the binding keeps the instance count the platform reports.

### Business rules (enforced by the use cases)

- Instance counts are 1 … 1000 (bindings may start at 0); maximum ≥ minimum for policies and schedules; initial minimum 0 or within the schedule limits.
- Thresholds of percentage metrics (`cpu`, `cpuutil`, `memoryutil`, `diskutil`) are 1 … 100; breach duration and cool-down are 60 … 3600 s; adjustments need a sign.
- Custom rules need a custom metric name that is not a standard metric; metric names are 1–100 of `[A-Za-z0-9_.-]`.
- Policy names are unique per tenant; application GUIDs are unique per tenant and immutable; a binding's instance count changes only through the scaling engine or a manual scaling (both recorded).
- Enabled specific-date schedules of a policy must not overlap; rules and schedules stay with their policy.
- A policy used by bindings cannot be deleted; deleting a policy removes its rules and schedules, deleting a binding its samples and history.
- Custom metrics from another application are accepted only if the policy allows `boundApp` and the sender is bound to the same service instance.
- Metric values are ≥ 0 and not in the future; samples older than `metricRetentionHours` (48) and events older than `eventRetentionDays` (30) are purged.
- Suspended bindings, bindings without policy and inactive policies are skipped by the engine; manual scaling stays possible (1 … the policy maximum) and also starts the cool-down.

## Project layout

```text
application-autoscaler/
├── mta.yaml                      SAP BTP deployment (backend, approuter, XSUAA, user-provided config)
├── backend/                      D / vibe.d service
│   ├── dub.sdl                   configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json       defaults (overridden by AUTOSCALER_* env and VCAP_SERVICES)
│   ├── source/app.d · cli.d · gui.d                       entry points
│   ├── source/uim/platform/application_autoscaler/
│   │   ├── domain/               entities, types (ids, time zones, adjustments, scopes), enumerations,
│   │   │                         exceptions, services (rule evaluator, scaling decider)
│   │   ├── ports/                usecases, services, repositories, storages, messaging, gateways
│   │   ├── application/          dtos, services (support, statistics, capabilities, demo data), usecases
│   │   ├── persistence/          repositories, storages (batching memory/file), mappers, records
│   │   ├── infrastructure/       configuration, security (PBKDF2, HS256, XSUAA), logging, monitoring,
│   │   │                         clients (clock, instance controller), workers (scaling worker), container
│   │   └── presentation/         odata (model, engine), http (REST, auth, health), web (Fiori), cli, gui
│   ├── tests/autoscaler_flows.d  integration tests
│   └── Dockerfile · Containerfile
├── frontend/                     Fiori app: manifest, Component (login), views, controllers, fragments,
│                                 model, i18n (en, de), localService (metadata + mock data), test (QUnit, OPA5)
├── approuter/                    xs-app.json, xs-security.json, default-env.json (local only, git-ignored)
└── k8s/                          deployment, service, configmap, secret.example
```

## Build and run

Requirements: dmd ≥ 2.112 or ldc ≥ 1.40, dub; the shared package `../service` of the uim-platform repository.

```bash
cd backend
dub build                     # server  → build/uim-application-autoscaler-platform-service
dub build --config=cli        # CLI     → build/uim-application-autoscaler-cli
dub build --config=gui        # GtkD    → build/uim-application-autoscaler-gui (needs GTK 3)
dub test  --config=defaultTest
```

### Local development

```bash
cd backend
AUTOSCALER_JWT_SECRET="$(openssl rand -base64 48)" AUTOSCALER_ADMIN_PASSWORD='change me now' \
  ./build/uim-application-autoscaler-platform-service
# Fiori app:  http://localhost:8097/app/index.html      (log in as admin; "Create Demo Content" in an empty tenant)
# OData:      http://localhost:8097/odata/v4/autoscaler/$metadata
# REST:       http://localhost:8097/api/v1/autoscaler/capabilities
# Health:     http://localhost:8097/health
```

`config/default.json` uses `authMode: "jwt"` and a file store (`data/application-autoscaler.json`), which server, CLI
and GUI share. Without `adminPassword` the first start creates `admin` with a random password and logs it once.
`AUTOSCALER_AUTH_MODE=open` switches the login off (development only). The scaling worker evaluates all autoscaled
bindings every `evaluationIntervalSeconds` (30); `0` evaluates on demand only.

With the demo content (three policies, five bindings, recent samples), the first evaluation during business hours
(Mon–Fri 08:00–18:00 UTC) raises the web applications to the schedule's initial minimum of 4 and scales the invoice
worker by +50 % on its custom metric `jobqueue`; after the cool-down `order-service` (CPU 91 %) gets two more
instances.

### CLI

```bash
./build/uim-application-autoscaler-cli help
./build/uim-application-autoscaler-cli seed
./build/uim-application-autoscaler-cli bind shop guid-shop --policy=web-standard --instances=2
./build/uim-application-autoscaler-cli simulate shop cpu 95 --seconds=240     # load for the last 4 minutes
./build/uim-application-autoscaler-cli preview shop                           # what would happen
./build/uim-application-autoscaler-cli evaluate shop                          # do it
./build/uim-application-autoscaler-cli scale shop 6 "load test"
./build/uim-application-autoscaler-cli history shop
./build/uim-application-autoscaler-cli list Rules --filter="policyId eq 'web-standard'"
./build/uim-application-autoscaler-cli token admin                            # bearer token (jwt mode)
./build/uim-application-autoscaler-cli passwd admin 'a new password'
```

The generic commands `sets`, `metadata`, `list`, `count`, `get`, `create`, `update`, `delete` and `invoke` work on
every entity set and action; `--json` prints machine readable output, `--tenant` selects the tenant.

### Container / Kubernetes / BTP

```bash
# from the repository root (path dependency on ../../service)
docker build -f application-autoscaler/backend/Dockerfile -t uim-platform/application-autoscaler .
cp k8s/secret.example.yaml k8s/secret.yaml   # fill in jwt secret and admin password
kubectl apply -f k8s/
mbt build && cf deploy mta_archives/uim-application-autoscaler_2.0.0.mtar   # SAP BTP
```

On SAP BTP the approuter serves the Fiori app and logs users in with XSUAA; the backend switches to `xsuaa` mode
automatically when the XSUAA binding is present. File storage keeps a single-node snapshot — run one instance.

## Authentication and authorization

| Mode | When | Login | Tokens |
|---|---|---|---|
| `jwt` | `authMode: "jwt"` (default in `config/default.json`, container, Kubernetes) | built-in: Fiori login dialog → `POST /auth/login` | HS256, signed with `jwtSecret` (≥ 32 characters), lifetime `tokenTtlSeconds` |
| `xsuaa` | an XSUAA binding in `VCAP_SERVICES` (BTP) — always wins | approuter (SAP ID service / IdP) | RS256 tokens of XSUAA, forwarded by the approuter |
| `open` | `authMode: "open"` | none — tenant from `X-Tenant-Id`, user from `X-User-Id` | — (local development only) |

| Method | Path | |
|---|---|---|
| GET | `/auth/config` | `{mode, loginRequired, loginUrl, defaultTenant}` (public) |
| POST | `/auth/login` | `{username, password, tenant?}` (JSON or form) → `{access_token, token_type, expires_in, scope, user}` |
| GET | `/auth/me` | the caller: user, tenant, scopes |
| POST | `/auth/password` | `{currentPassword, newPassword}` — change the own password |
| POST | `/auth/logout` | stateless; the client discards the token |

Tokens carry XSUAA compatible claims (`sub`, `user_name`, `zid` = tenant, `scope[]`, `exp`, `jti`), so REST and OData
verify both kinds alike. Passwords are stored as salted PBKDF2-HMAC-SHA256 hashes (120 000 rounds, rehashed when the
rounds increase); unknown users and wrong passwords answer the same and take the same time; 5 failed logins lock the
account for 15 minutes; the last administrator cannot be deleted, locked or lose the Admin scope.

| Scope | Allows | XSUAA role template |
|---|---|---|
| `Read` | read everything, preview decisions | Viewer |
| `Operate` | send metrics, evaluate, scale manually, simulate load, suspend / resume | Operator |
| `Manage` | bindings, policies, rules, schedules, attach / detach, purge, demo content (implies Operate) | ScalingAdministrator |
| `Admin` | users of the built-in login | Administrator |

The Fiori app keeps the token per browser tab (`sessionStorage`), sends it with every OData request, shows actions by
scope and returns to the login dialog when a token expires. `/health` stays public for probes.

## APIs

### OData v4 — `/odata/v4/autoscaler`

Entity sets: `Bindings`, `Policies`, `Rules`, `Schedules`, `MetricSamples` (create, delete), `ScalingEvents` (read
only), `Users` (Admin), `Statistics` (singleton). Query options: `$filter`, `$orderby`, `$top`, `$skip`, `$count`,
`$select`, `$search`; `$batch` is supported. Bindings carry derived facts: policy name, effective limits and their
source (policy or schedule), utilization, sample and event counts, last decision.

Unbound actions: `EvaluateBinding(id)`, `PreviewScaling(id)`, `EvaluateAll()`, `ScaleBinding(id, instances, reason?)`,
`SuspendBinding(id)`, `ResumeBinding(id)`, `AttachPolicy(id, policyId)`, `DetachPolicy(id)`, `ActivatePolicy(id)`,
`DeactivatePolicy(id)`, `CopyPolicy(id, newId?)`, `SimulateLoad(bindingId, metricName, value, durationSeconds?,
stepSeconds?)`, `PurgeMetrics()`, `SeedDemoData()`.

### REST — `/api/v1/autoscaler`

CRUD for `bindings`, `policies`, `rules`, `schedules`, `metric-samples`, `scaling-events` (read), `users`
(`GET /<r>` with OData query options → `{count, resources}`, `POST` → 201, `PUT`/`PATCH`, `DELETE` → 204), plus:

| Method | Path | |
|---|---|---|
| POST | `/bindings/{id}/evaluate` | evaluate now → evaluation result |
| GET | `/bindings/{id}/preview` | the decision without applying it |
| POST | `/bindings/{id}/scale` | `{instances, reason?}` |
| POST | `/bindings/{id}/suspend` · `/resume` | pause / continue autoscaling |
| POST · DELETE | `/bindings/{id}/policy` | attach `{policyId}` · detach |
| GET · POST | `/bindings/{id}/metrics` | samples (newest first) · `{metricName, value, unit?, measuredAt?}` |
| GET | `/bindings/{id}/history` | scaling events (newest first) |
| POST | `/bindings/{id}/simulate` | `{metricName, value, durationSeconds?, stepSeconds?}` |
| POST | `/apps/{appGuid}/metrics` | sent by the application: `{metricName, value, unit?}` or `{metrics: [{name, value}, …], senderAppGuid?}` |
| POST | `/policies/{id}/activate` · `/deactivate` · `/copy` | status, copy with rules and schedules (inactive) |
| GET | `/policies/{id}/rules` · `/schedules` | children |
| POST | `/scaling/evaluate` · `/metrics/purge` · `/demo-data` | engine run, retention, demo content |
| GET | `/statistics` · `/capabilities` · `/meta` | KPIs, limits and enumerations |

Errors answer `{"error": {code, message, requestId, target}}` with 400 / 401 / 403 / 404 / 405 / 409 / 422 / 500.

## Instance controller

`instanceMode: "simulate"` (default) accepts every target. `instanceMode: "http"` POSTs
`{tenant, bindingId, appGuid, appName, currentInstances, instances, reason}` to `instanceUrl` — e.g. a small adapter
calling the Cloud Foundry v3 API (`POST /v3/apps/{guid}/processes/web/actions/scale`) or the Kubernetes scale
subresource. A 2xx answer succeeds (an optional `{"instances": n}` reports the count actually set); anything else is
recorded as a failed scaling. `AUTOSCALER_INSTANCE_AUTHORIZATION` is sent as `Authorization` header.

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `AUTOSCALER_<KEY>` environment
variables → `VCAP_SERVICES` (user-provided service `application-autoscaler-config`, XSUAA) → CLI options.

| Key | Default | |
|---|---|---|
| `port`, `host` | 8097, 0.0.0.0 | |
| `storage`, `dataFile` | memory (file in default.json), `data/application-autoscaler.json` | |
| `authMode`, `jwtSecret`, `tokenTtlSeconds` | open (jwt in default.json), random, 3600 | |
| `adminUser`, `adminPassword`, `passwordIterations` | admin, generated, 120000 | |
| `maxFailedLogins`, `lockSeconds`, `minPasswordLength` | 5, 900, 10 | |
| `evaluationIntervalSeconds`, `purgeEveryRuns`, `workerTenants` | 30, 20, `["default"]` | |
| `metricStaleSeconds`, `metricRetentionHours`, `eventRetentionDays` | 600, 48, 30 | |
| `recordIgnored` | false | also record evaluations that changed nothing |
| `instanceMode`, `instanceUrl`, `instanceTimeoutSeconds` | simulate, –, 30 | |
| `apiPath`, `odataPath`, `frontendDir` | `/api/v1`, `/odata/v4/autoscaler`, `../frontend` | |
| `maxPageSize`, `maxRequestBytes` | 500, 1 MiB | |

`uim-application-autoscaler-cli config` prints the effective configuration with secrets masked.

## Tests

```bash
cd backend && dub test --config=defaultTest      # 34 modules: unit tests of every layer + tests/autoscaler_flows.d
```

The integration tests cover the demo flow (schedule start, cool-down, dynamic scale-out, custom metric percentages,
stale metrics, suspend / manual scaling, cascades), the business rules, REST and OData over vibe.d test requests, the
built-in login with every scope, the CLI, the batching file store and the worker. The Fiori app has QUnit tests
(`frontend/test/unit`) and an OPA5 journey (`frontend/test/integration`, needs a running backend in `open` mode with
demo content): open `http://localhost:8097/app/test/testsuite.qunit.html`.

## License

Apache 2.0 — see the LICENSE file of the uim-platform repository.
