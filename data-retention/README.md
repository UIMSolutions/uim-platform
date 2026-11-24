# UIM Data Retention

A data retention manager in the style of **SAP Data Retention Manager**: it decides, rule by rule, when personal data
must be **blocked**, **archived** and finally **destroyed** — and enforces it, including GDPR erasure requests
(Art. 17) that collide with legal retention obligations.

- **Backend** — D, uim-framework 26.11, vibe.d 0.10.5, hexagonal / clean architecture (`backend/`)
- **Frontend** — SAP Fiori 3 / OpenUI5 1.120 app (`frontend/`)
- **Approuter** — SAP BTP entry point with XSUAA (`approuter/`), MTA deployment (`mta.yaml`)
- **Interfaces** — OData v4 (Fiori), REST, CLI, GtkD desktop GUI — all driven by one EDM model
- **Security** — built-in login with JWT (HS256, PBKDF2 passwords, lockout), XSUAA (RS256) on BTP, or open for development

See [UML.md](UML.md) for class, component, state and sequence diagrams and [NAFv4.md](NAFv4.md) for the NATO
Architecture Framework v4 description.

---

## Concepts

```text
reference date ──── residence ────▶ end of purpose ──── retention ────▶ end of retention
(end of business)   data in use      → block              data blocked,   → destroy
                                                          kept for law      (delete | anonymize)
```

| Concept | Meaning |
|---|---|
| **Application group** | Applications whose personal data is managed together (e.g. ERP: S4-SD, S4-FI) |
| **Legal entity** | Company whose jurisdiction the rules follow (ISO country code) |
| **Data subject role** | Kind of person: customer, employee, marketing contact, vendor contact |
| **Business purpose** | Why the data is processed (e.g. *Sales Order Processing*); `inactive → active → deprecated` |
| **Legal ground** | Legal basis of a purpose (GDPR Art. 6: consent, contract, legal obligation, …) with a legal reference |
| **Residence rule** | How long data may be *used* after the reference date (one per legal ground) |
| **Retention rule** | How long *blocked* data must be *kept* after the end of purpose, and the action on expiry (`delete` / `anonymize`) |
| **Data subject** | The identified person, with a reference date (end of business; empty while the business is ongoing) |
| **Legal hold** | Litigation/audit freeze: stops marking and destruction |
| **Deletion request** | Request to block or erase one data subject |
| **Archiving job** | Archive and/or destroy the data subjects of an application group (scheduled, run now, dry run) |

### Rules of the evaluation

- Only **active legal grounds with an active residence rule** count. Without a retention rule, the retention is 0.
- With several legal grounds, **the latest end of retention governs** (the longest legal obligation wins).
  A data subject can be restricted to one legal ground.
- Calendar arithmetic: 31 Jan + 1 month = 28/29 Feb.
- The evaluation is **computed on every read** from the current rules — changing a rule takes effect immediately,
  nothing is stale.
- Phases: `noRule` · `withinResidence` · `withinRetention` · `endOfRetention`.

### Lifecycle of a data subject

`active → blocked → archived → markedForDeletion → deleted`

| Operation | Effect |
|---|---|
| **End-of-purpose check** | past end of purpose & active → `blocked`; past end of retention & no legal hold → `markedForDeletion`. Can simulate. |
| **Deletion request** `block` | blocks the subject |
| **Deletion request** `delete`/`anonymize` | destroys the data if the retention expired **or no retention obligation applies** (retention 0, e.g. consent); otherwise the subject is **blocked** and the request **rejected** with the earliest deletion date. Legal hold → rejected. |
| **Archiving job** `archive` / `destruct` / `archiveAndDestruct` | archives subjects past end of purpose; destroys subjects past end of retention with the rule's action; skips legal holds; `dryRun` only counts |

Destroyed subjects keep a tombstone (id, dates, method) as audit proof; external id and name are removed
(`deleted-<id>` / `anonymized-<id>`). Events and deletion requests never carry personal data.

### Business rules (enforced by the use cases)

- A purpose can only be activated with a complete legal ground (active ground + active residence rule), and an active
  purpose must keep one — removing or deactivating the last one is refused.
- Active purposes cannot be deleted; deleting an inactive purpose cascades its legal grounds and rules.
- Master data in use (by purposes, data subjects, jobs) cannot be deleted.
- One residence and one retention rule per legal ground; purpose/ground of a rule are immutable.
- External ids are unique per application group; reference dates must not lie in the future.
- Deprecated purposes accept no new data subjects but still govern existing ones.
- One pending deletion request per data subject; pending requests must be cancelled before deletion.

---

## Project layout

```text
data-retention/
├── mta.yaml                     MTA: backend + approuter + XSUAA + config service
├── backend/                     D / vibe.d service
│   ├── dub.sdl                  configurations: defaultRun, cli, gui, defaultTest
│   ├── config/default.json      defaults (overridden by DR_* env and VCAP_SERVICES)
│   ├── source/app.d | cli.d | gui.d   entry points
│   ├── source/uim/platform/data_retention/
│   │   ├── domain/              entities, types (ids, periods, time, scopes), enumerations,
│   │   │                        exceptions, services (retention evaluator)
│   │   ├── ports/               usecases, services, repositories, storages, messaging, gateways
│   │   ├── application/         usecases (interactors), services (rule book, statistics,
│   │   │                        lookups, demo data), dtos
│   │   ├── persistence/         records, mappers (compile-time reflection), repositories, storages
│   │   ├── infrastructure/      configuration, logging, security, clients, workers, container
│   │   └── presentation/        odata, http (REST, auth, health), web, cli, gui
│   ├── tests/                   integration tests across all layers
│   ├── Dockerfile, Containerfile
├── frontend/                    SAP Fiori 3 / OpenUI5 app (uim.dataretention)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/            metadata.xml + mockdata (generated from the engine)
│   └── test/                    QUnit (formatter, models, session) + OPA5 journey
├── approuter/                   xs-app.json, xs-security.json, default-env.json (local, git-ignored)
└── k8s/                         configmap, deployment (+PVC), service, secret.example
```

---

## Build and run

Requirements: `dub` with `dmd` or `ldc2`; the shared `../../service` package of the repository.

```sh
cd backend
dub build                    # HTTP server  → build/uim-data-retention-platform-service
dub build --config=cli       # CLI          → build/uim-data-retention-cli
dub build --config=gui       # GtkD GUI     → build/uim-data-retention-gui
dub test                     # unit + integration tests
```

### Local development

```sh
cd backend
./build/uim-data-retention-cli seed --data-file=data/data-retention.json   # demo content
DR_AUTH_MODE=open ./build/uim-data-retention-platform-service               # no login
# Fiori app:  http://localhost:8112/app/index.html
# OData:      http://localhost:8112/odata/v4/data-retention/$metadata
```

With the default `config/default.json` (`authMode: jwt`), the first start creates the user `admin`; the password is
`DR_ADMIN_PASSWORD` or a generated one printed once in the log. Set `DR_JWT_SECRET` (≥ 32 characters) so tokens
survive restarts.

### CLI

```sh
C="./build/uim-data-retention-cli --data-file=data/data-retention.json"
$C help
$C stats
$C list DataSubjects --filter="phase eq 'endOfRetention'"
$C check erp --simulate            # end-of-purpose check, change nothing
$C check                           # block / mark for deletion
$C simulate sales 2019-06-30       # dates for a reference date
$C hold ds-1002 "Lawsuit 42"       # legal hold (--release to lift)
$C erase ds-3002 --action=anonymize
$C run-job job-erp-destruct
$C token admin | passwd admin '<new password>' | config
```

The generic commands `sets`, `metadata`, `list`, `count`, `get`, `create`, `update`, `delete`, `invoke` work on
every entity set and action of the model.

### Container / Kubernetes / BTP

```sh
# from the repository root (path dependency on ../../service)
docker build -f data-retention/backend/Dockerfile -t uim-platform/data-retention .
kubectl apply -f k8s/configmap.yaml -f k8s/service.yaml -f k8s/deployment.yaml   # + k8s/secret.yaml from the example
mbt build && cf deploy mta_archives/uim-data-retention_2.0.0.mtar                 # SAP BTP Cloud Foundry
```

On BTP the approuter logs users in via XSUAA; the backend detects the XSUAA binding, verifies RS256 tokens and
enforces the scopes. Role collections: `DataRetentionAuditor` (Read), `DataRetentionOfficer` (Read, Manage),
`DataRetentionAdministrator`.

---

## Authentication and authorization

| Mode | Selected by | Behaviour |
|---|---|---|
| `xsuaa` | XSUAA binding in `VCAP_SERVICES` | approuter login, RS256 tokens verified, scopes enforced |
| `jwt` | `authMode: "jwt"` (or `requireAuthentication: true`) | built-in login (`/auth/login`), HS256 tokens, scopes enforced |
| `open` | `authMode: "open"` | no authentication (local development); tenant from `X-Tenant-Id` |

| Scope | Allows |
|---|---|
| `Read` | read everything, simulate retention |
| `Manage` | maintain everything, run checks, process deletion requests, run jobs |
| `Admin` | manage the users of the built-in login (`/Users`) |

Built-in login endpoints:

| Method | Path | Purpose |
|---|---|---|
| GET | `/auth/config` | `{mode, loginRequired}` (public) |
| POST | `/auth/login` | `{username, password, tenant?}` (JSON or form) → `{access_token, token_type, expires_in, scope, user}` |
| GET | `/auth/me` | the caller |
| POST | `/auth/password` | `{currentPassword, newPassword}` |
| POST | `/auth/logout` | 204 (stateless) |

Passwords: PBKDF2-HMAC-SHA256 (120 000 rounds, random salt, transparent rehash), at least 10 characters. After 5
failed logins the account is locked for 15 minutes; unknown users and wrong passwords answer alike. The last
administrator cannot be deleted, locked or demoted. The Fiori app shows a login dialog in `jwt` mode, keeps the token
per browser tab and offers password change and sign-out in the user menu.

---

## APIs

### OData v4 — `/odata/v4/data-retention`

Entity sets: `ApplicationGroups`, `LegalEntities`, `DataSubjectRoles`, `BusinessPurposes`, `LegalGrounds`,
`ResidenceRules`, `RetentionRules`, `DataSubjects`, `DeletionRequests`, `ArchivingJobs`, `Users`, singleton
`Statistics`. Supports `$filter`, `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, `$batch`, CSRF tokens
and Fiori UI annotations.

Actions: `ActivateBusinessPurpose`, `DeactivateBusinessPurpose`, `DeprecateBusinessPurpose`, `BlockDataSubject`,
`SetLegalHold`, `CheckEndOfPurpose`, `SimulateRetention`, `ProcessDeletionRequest`, `CancelDeletionRequest`,
`ProcessPendingRequests`, `RunArchivingJob`, `CancelArchivingJob`, `RunDueJobs`, `SeedDemoData`.

### REST — `/api/v1/data-retention`

Every call goes through the same engine as OData (same validation, scopes and errors). The paths of the previous
service generation keep working.

| Method | Path | |
|---|---|---|
| GET | `/{resource}` | `{count, resources}`; OData query options allowed |
| GET / POST / PUT / PATCH / DELETE | `/{resource}[/{id}]` | CRUD (PUT = partial update) |
| POST | `/business-purposes/{id}/activate` · `/deactivate` · `/deprecate` | |
| POST | `/data-subjects/{id}/block` | |
| POST | `/data-subjects/{id}/legal-hold` | `{legalHold, reason}` |
| GET | `/data-subjects/{id}/evaluation` | phase, dates, governing legal ground |
| POST | `/deletion-requests/{id}/process` · `/cancel` | |
| POST | `/archiving-jobs/{id}/run` · `/cancel` | |
| POST | `/end-of-purpose/check` | `{applicationGroupId?, simulate?}` |
| POST | `/simulate` | `{businessPurposeId, referenceDate, legalGroundId?}` |
| GET | `/statistics`, `/meta` | |
| POST | `/demo-data` | demo content in an empty tenant |

Resources: `application-groups`, `legal-entities`, `data-subject-roles`, `business-purposes`, `legal-grounds`,
`residence-rules`, `retention-rules`, `data-subjects`, `deletion-requests`, `archiving-jobs`.
Errors: `{"error": {code, message, requestId, target}}` with 400/401/403/404/405/409/422/500.

Health: `GET /health` and `GET /api/v1/health` (public).

---

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `DR_*` environment →
Cloud Foundry (`PORT`, `VCAP_SERVICES`, user-provided service `data-retention-config`) → CLI options.
`DATA_RETENTION_HOST` / `DATA_RETENTION_PORT` of the previous generation are still honoured.

| Key | Env | Default | |
|---|---|---|---|
| `host`, `port` | `DR_HOST`, `DR_PORT` | `0.0.0.0`, `8112` | |
| `storage`, `dataFile` | `DR_STORAGE`, `DR_DATA_FILE` | `memory`, `data/data-retention.json` | `file` = JSON snapshot shared by server, CLI, GUI |
| `authMode` | `DR_AUTH_MODE` | `open` (`jwt` in default.json) | `open` \| `jwt` |
| `jwtSecret` | `DR_JWT_SECRET` | random per start | ≥ 32 characters |
| `tokenTtlSeconds` | `DR_TOKEN_TTL_SECONDS` | `3600` | 60 … 604800 |
| `adminUser`, `adminPassword` | `DR_ADMIN_USER`, `DR_ADMIN_PASSWORD` | `admin`, generated | first start in jwt mode |
| `passwordIterations` | `DR_PASSWORD_ITERATIONS` | `120000` | |
| `maxFailedLogins`, `lockSeconds`, `minPasswordLength` | … | `5`, `900`, `10` | |
| `workerIntervalSeconds` | `DR_WORKER_INTERVAL_SECONDS` | `5` | pending requests + due jobs; `0` = process on creation |
| `endOfPurposeCheckSeconds` | `DR_END_OF_PURPOSE_CHECK_SECONDS` | `0` | periodic check (e.g. `86400`); `0` = on demand |
| `workerTenants` | `DR_WORKER_TENANTS` | `["default"]` | comma separated in env |
| `apiPath`, `odataPath` | | `/api/v1`, `/odata/v4/data-retention` | |
| `maxPageSize`, `maxRequestBytes` | | `200`, `4194304` | |
| `frontendDir` | `DR_FRONTEND_DIR` | `../frontend` | `""` on BTP (approuter serves the app) |

`uim-data-retention-cli config` prints the effective configuration with secrets masked.

---

## Tests

```sh
cd backend && dub test       # 29 modules: domain units + integration flows
```

The integration tests (`backend/tests/data_retention_flows.d`) run on a fixed date with a manual clock and cover the
full lifecycle through the ports (seed → check → deletion requests → archiving / destruction → legal holds), the
maintenance rules, REST and OData over vibe.d test requests, the JWT login (lockout, scopes, tampered tokens) and the
batching file store. Frontend: `frontend/test/testsuite.qunit.html` (QUnit units; OPA5 journey against a running
backend).

## License

Apache 2.0 — see the repository root LICENSE file.
