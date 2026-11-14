# UIM Audit Log Service

A multi-tenant audit log service in the style of the **SAP BTP Audit Log Service**,
built with **D / vibe.d 0.10** using hexagonal **Clean Architecture**.
It has an **SAP Fiori 3 (UI5)** frontend, an **approuter** with XSUAA, and four
driving adapters on the same core:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST | `/api/v1/*` | integration API for services that write audit records |
| **OData v4** | `/odata/v4/auditlog/` | Fiori / UI5 (`$metadata`, `$filter`, `$orderby`, `$select`, `$count`, `$search`, CRUD, action) |
| **CLI** | `uim-auditlog-cli` | administration, scripting, JSON output |
| **GtkD GUI** | `uim-auditlog-gui` | desktop client (GTK 3) |

All adapters use only the driving ports (`AuditLogPorts`). They share data through
the configured snapshot storage, so an entry written with the CLI appears in the
GUI and the Fiori app.

Part of the UIM Platform suite.

## Features

| Capability | Description |
|---|---|
| Audit log writing | 4 categories, 4 severities, 19 actions; tenant config checks (category toggles, minimum severity, excluded services, masking, rate limit) |
| Retrieval | paginated, category and time-range filters; by id, user or correlation id |
| Security events | login/logout/MFA/token events with risk level and an automatic parent audit entry |
| Data access (GDPR) | who read whose data, which fields, purpose and channel |
| Configuration changes | old/new value pairs and a justification |
| Retention | policies (default 90 days), manual or scheduled enforcement across all record types |
| Exports | JSON/CSV export jobs with download |
| Statistics | per-tenant KPIs (Fiori header and tiles, GUI overview, `cli stats`) |

## Project layout

```
auditlog/
├── mta.yaml                     MTA descriptor (backend + approuter + XSUAA)
├── backend/                     D / vibe.d service
│   ├── dub.sdl                  configurations: defaultRun | cli | gui | defaultTest
│   ├── config/default.json      default configuration
│   └── source/
│       ├── app.d                HTTP server composition root
│       ├── cli.d                CLI entry point
│       ├── gui.d                GtkD entry point
│       └── uim/platform/auditlog/
│           ├── domain/          entities, types, enumerations, services, exceptions
│           ├── application/     usecases/{write,retrieve,manage}, services, dtos
│           ├── ports/           usecases, services, repositories, storages, messaging, gateways
│           │                    + driving.d (AuditLogPorts bundle)
│           ├── infrastructure/  configuration, logging, security (XSUAA JWT), workers, container
│           ├── persistence/     repositories, storages (memory, JSON file), mappers, records
│           └── presentation/
│               ├── http/        REST controllers (/api/v1)
│               ├── odata/       OData v4: EDM model, $metadata, query engine, serializers
│               ├── cli/         argument parser + command dispatcher
│               ├── gui/         GtkD main window (built only with --config=gui)
│               ├── web/         serves frontend/ at "/" for local development
│               └── tabular.d    table projections shared by CLI and GUI
├── frontend/                    SAP Fiori 3 / UI5 app (namespace uim.auditlog)
│   ├── manifest.json            OData V4 model → odata/v4/auditlog/ ($direct, no $batch)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/            metadata.xml + mock data
│   └── test/                    QUnit (formatter) + OPA5 journey
└── approuter/                   @sap/approuter, xs-app.json, xs-security.json
```

The dependency rule: `presentation → ports ← application → domain`, and
`persistence → ports`. Only `infrastructure/container.d` and the three entry
points know concrete classes.

## Build and run

Requirements: `dmd` or `ldc2`, `dub`. The GUI also needs GTK 3.24 development
libraries; gtk-d 3.11 is fetched by dub.

```sh
cd backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:8085/
dub run

# Command line interface
dub build --config=cli
./build/uim-auditlog-cli help
./build/uim-auditlog-cli logs write --message="Role changed" --category=configuration --user=alice
./build/uim-auditlog-cli logs list --category=securityEvents --from=2026-11-01 --json
./build/uim-auditlog-cli retention create --name="90 days" --days=90 --default
./build/uim-auditlog-cli retention enforce
./build/uim-auditlog-cli exports create --format=csv && ./build/uim-auditlog-cli exports download <id> --out=audit.csv

# Desktop GUI (GtkD)
dub run --config=gui -- --tenant=default

# Unit tests
dub test --config=defaultTest
```

CLI exit codes: `0` success, `1` failure (not found, validation), `2` usage error.

### Fiori app

- **Local, without login:** `dub run` serves `../frontend` at `/` (setting
  `frontendDir`). Open `http://localhost:8085/`.
- **Local, with XSUAA:** put credentials in `approuter/default-env.json`
  (git-ignored), then run `cd approuter && npm install && npm run start:local`
  and open `http://localhost:5000`.
- **Tests:** `frontend/test/testsuite.qunit.html`.

The UI has a KPI header (Statistics singleton) and an overview with category and
severity tiles. It has filterable audit log tables with detail navigation, plus
tabs for security events, data access and configuration changes. Retention
policies can be created and deleted, and retention can be enforced through the
`EnforceRetention` action. The audit configuration is edited inline (PATCH), and
JSON/CSV exports can be created and downloaded.

### Deploy to SAP BTP (Cloud Foundry)

```sh
mbt build            # builds the D binary (binary_buildpack) and the approuter incl. frontend
cf deploy mta_archives/uim-auditlog_1.0.0.mtar
```

Then assign the role collections **UIM Audit Log Viewer** or **UIM Audit Log
Administrator**.

> The `file` storage writes JSON snapshots to the container disk, which is
> ephemeral on Cloud Foundry. Use it for demos only. For production, implement
> `ISnapshotStorage` or the repository ports with a database adapter.

## Configuration

Precedence, lowest to highest: compiled defaults → `config/default.json` (or
`AL_CONFIG_FILE`) → environment → `VCAP_SERVICES` (credentials of the service
named or tagged `auditlog-config`). The CLI and GUI also accept `--data-dir`,
`--storage` and `--tenant`.

| Key | Env | Default | Meaning |
|---|---|---|---|
| host / port | `AL_HOST` / `AL_PORT`, `PORT` | 0.0.0.0 / 8085 | listener |
| storage | `AL_STORAGE` | file | `file` (shared JSON snapshots) or `memory` |
| dataDir | `AL_DATA_DIR` | data | snapshot directory |
| defaultTenant | `AL_DEFAULT_TENANT` | default | tenant when no JWT or `X-Tenant-Id` is given |
| odataPath | `AL_ODATA_PATH` | /odata/v4/auditlog | OData service root |
| retentionIntervalMinutes | `AL_RETENTION_INTERVAL` | 0 (off) | background retention worker |
| retentionTenants | `AL_RETENTION_TENANTS` | default | tenants for the worker (comma separated) |
| frontendDir | `AL_FRONTEND_DIR` | ../frontend | serve the Fiori app at `/` (`""` = off) |

**Tenant and identity:** taken from the XSUAA bearer token (`zid`, `user_name`),
or from the `X-Tenant-Id` / `X-User-Id` headers. The backend decodes the token
but does **not** verify its signature. Expose it only behind the approuter, or
add JWKS validation.

## OData v4

```
GET    /odata/v4/auditlog/                      service document
GET    /odata/v4/auditlog/$metadata             CSDL with Common.Label / Capabilities annotations
GET    /odata/v4/auditlog/AuditLogs?$filter=category eq 'dataAccess' and contains(tolower(message),'profile')
         &$orderby=timestamp desc&$select=message,userId&$top=50&$skip=0&$count=true
GET    /odata/v4/auditlog/AuditLogs('<id>')
POST   /odata/v4/auditlog/AuditLogs | SecurityEvents | DataAccessLogs | ConfigChangeLogs
POST/PATCH/DELETE  RetentionPolicies, AuditConfigs     DELETE ExportJobs   POST ExportJobs
GET    /odata/v4/auditlog/Statistics            singleton
POST   /odata/v4/auditlog/EnforceRetention      unbound action → RetentionResult
```

`$batch` is not supported, so the UI5 model uses `groupId: "$direct"`.

## REST API (`/api/v1`)

```
POST/GET  /auditlog                GET /auditlog/{id}
CRUD      /retention               CRUD /configs
POST/GET  /exports                 GET /exports/{id}   GET /exports/{id}/download   DELETE /exports/{id}
POST      /security-events         POST /data-access   POST /config-changes
GET       /health
```

## Domain model

| Enum | Values |
|---|---|
| AuditCategory | securityEvents, configuration, dataAccess, dataModification |
| AuditSeverity | info, warning, error, critical |
| AuditAction | create, read, update, delete, login, logout, loginFailed, passwordChange, roleAssign, roleRevoke, policyChange, configChange, export, dataAccess, consentChange, tokenIssue, tokenRevoke, mfaEnroll, mfaVerify |
| AuditOutcome | success, failure, denied, error |
| RetentionStatus | active, inactive, expired |
| ExportStatus / ExportFormat | pending, inProgress, completed, failed / json, csv |
| ConfigStatus | enabled, disabled |

Domain services: **AuditPolicy** (decides whether an entry is logged, and masks
fields), **AuditFilterService** (search and pagination), **RetentionEnforcer**
(purges expired records of all four stores).

See [UML.md](UML.md) for class, component and sequence diagrams.

## License

Apache-2.0 © 2018-2026 Ozan Nurettin Süel
