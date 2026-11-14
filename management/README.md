# UIM Cloud Management Service

A multi-tenant account management service in the style of the **SAP BTP Cloud
Management Service**: global accounts, directories, subaccounts, entitlements,
environments (Cloud Foundry, Kyma, ABAP), SaaS subscriptions, a service catalog,
labels and an audit trail of platform events.

It is built with **D / vibe.d 0.10** in a hexagonal **Clean Architecture**, has an
**SAP Fiori 3 (UI5)** cockpit, an **approuter** with XSUAA, and five driving
adapters on the same core:

| Adapter | Entry point | Purpose |
|---|---|---|
| JSON API | `/api/v1/*` | integration API (classic HTTP controllers) |
| REST | `/rest/v1/*` | typed vibe.d REST interfaces (read API + directory creation) |
| **OData v4** | `/odata/v4/management/` | Fiori / UI5 (`$metadata`, `$filter`, `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, CRUD, actions) |
| **CLI** | `uim-management-cli` | administration, scripting, JSON output |
| **GtkD GUI** | `uim-management-gui` | desktop client (GTK 3) |

All adapters use only the driving ports (`ManagementPorts`). They share data
through the configured snapshot storage, so a subaccount created with the CLI
appears in the GUI and the Fiori app.

## Features

| Capability | Business rules |
|---|---|
| Global accounts | license types, limits for subaccounts/directories (cannot drop below usage), suspend ↔ reactivate, delete only when empty; usage counters are derived, never stale |
| Directories | up to 5 levels, parent must belong to the same global account, directory limit, delete only without children |
| Subaccounts | subdomain syntax + uniqueness, global account must be active, limit check, move within the global account, suspend ↔ reactivate, delete only without live environments/subscriptions |
| Entitlements | plan must exist, be active and provisionable; quota checked across all assignments of the plan in the global account (`maxQuota`, 0 = unlimited); region availability; quota change, revoke, delete only when unused |
| Environments | one Cloud Foundry org and one Kyma runtime per subaccount, subaccount must be active, provisioning through the `IProvisioningGateway` port |
| Subscriptions | one live subscription per app and subaccount, enriched from the application catalog, unsubscribe through the gateway |
| Service plans | catalog with category, pricing model, regions, quota unit; duplicate plans rejected; delete only when not entitled |
| Labels | one label per resource and key (values are merged) |
| Platform events | every state change is recorded with its tenant, scope and actor; filter by global account / subaccount / category / minimum severity / time; scheduled pruning |
| Overview | tenant KPIs (accounts, suspended, quota used/assigned, over-quota entitlements, warnings, last event) and per global account |
| Demo data | `seed` creates a realistic landscape through the regular use cases |

## Layout

```text
management/
├── mta.yaml                  MTA descriptor (backend + approuter + XSUAA)
├── backend/                  D / vibe.d service
│   ├── dub.sdl               configurations: defaultRun, cli, gui, defaultTest
│   ├── config/default.json   default settings
│   ├── source/app.d          HTTP server      (composition root)
│   ├── source/cli.d          command line     (composition root)
│   ├── source/gui.d          GtkD desktop GUI (composition root)
│   └── source/uim/platform/management/
│       ├── domain/           entities (with lifecycle rules), types, enumerations, services, exceptions
│       ├── ports/            usecases, services, repositories, storages, messaging, gateways, driving.d
│       ├── application/      use cases, services (event recorder, demo data, results), dtos
│       ├── persistence/      repositories, storages (memory / JSON file), mappers, records
│       ├── infrastructure/   configuration, logging, security, clients, workers, container
│       └── presentation/     http, rest, odata, cli, gui, web, tabular
├── frontend/                 SAP Fiori 3 / UI5 cockpit (OData v4)
└── approuter/                @sap/approuter, xs-app.json, xs-security.json
```

The module namespace follows the platform convention (`uim.platform.management`);
the skill's `uim/myfiori` placeholder maps to it.

## Build & run

```sh
cd backend
dub build                      # HTTP server  → build/uim-management-platform-service
dub build --config=cli         # CLI          → build/uim-management-cli
dub build --config=gui         # GtkD GUI     → build/uim-management-gui (needs GTK 3)
dub test  --config=defaultTest # unit tests

./build/uim-management-platform-service
# Fiori cockpit:  http://localhost:8098/index.html
# OData:          http://localhost:8098/odata/v4/management/$metadata
```

With `seedDemoData: true` (default in `config/default.json`) an empty default
tenant is filled with a demo landscape on start.

### CLI

```sh
./build/uim-management-cli help
./build/uim-management-cli seed
./build/uim-management-cli overview
./build/uim-management-cli subaccounts list --json
./build/uim-management-cli subaccounts create --global-account=<id> --name=QA --subdomain=acme-qa --region=eu10 --usage=test
./build/uim-management-cli entitlements assign --plan=<plan-id> --subaccount=<id> --quota=2
./build/uim-management-cli environments create --subaccount=<id> --name=qa --type=cloudFoundry
./build/uim-management-cli events list --severity=warning --limit=20
```

Exit codes: `0` ok, `1` business failure, `2` usage error. Global options:
`--tenant`, `--data-dir`, `--storage=memory`, `--json`.

### GUI

`./build/uim-management-gui [--tenant=<id>] [--data-dir=<dir>]` — one tab per
resource with create dialogs, lifecycle actions (suspend, reactivate, move,
revoke, deprovision, unsubscribe), details and a 15 s auto refresh that picks up
changes made by the server or the CLI.

## OData v4

Service root `/odata/v4/management/`, namespace `uim.management`.

| Entity set | Operations |
|---|---|
| `GlobalAccounts`, `Directories`, `Subaccounts`, `ServicePlans`, `Labels` | read, create, PATCH, delete |
| `Entitlements` | read, assign (POST), quota change (PATCH), delete |
| `Environments` | read, provision (POST), PATCH, deprovision (DELETE) |
| `Subscriptions` | read, subscribe (POST), plan change (PATCH) |
| `Events` | read-only |
| `Overview` | singleton with the tenant KPIs |

Unbound actions (POST, body `{"id": "…"}`): `SuspendGlobalAccount`,
`ReactivateGlobalAccount`, `SuspendSubaccount`, `ReactivateSubaccount`,
`MoveSubaccount` (+ `targetDirectoryId`), `RevokeEntitlement`, `Unsubscribe`,
`SeedDemoData`. They return `uim.management.ActionResult {id, success, message}`.

Errors use the OData error format; business rule violations are `422`,
conflicts `409`, unknown keys `404`. `$batch` is not supported — the UI5 model
uses `groupId: "$direct"`.

Tenant and user come from the XSUAA bearer token (`zid`, `user_name`) or the
`X-Tenant-Id` / `X-User-Id` headers. **The JWT signature is not verified by the
backend** — it must only be reachable through the approuter (or validate tokens
before exposing it directly).

## Configuration

Precedence: defaults → `config/default.json` (or `MGMT_CONFIG_FILE`) →
environment → `VCAP_SERVICES` (service named/tagged `management-config`).

| Key | Env | Default |
|---|---|---|
| `host` / `port` | `MGMT_HOST` / `MGMT_PORT`, `PORT`, legacy `MANAGEMENT_HOST` / `MANAGEMENT_PORT` | `0.0.0.0` / `8098` |
| `logLevel` | `MGMT_LOG_LEVEL` | `info` |
| `storage` | `MGMT_STORAGE` | `file` (`memory` = volatile) |
| `dataDir` | `MGMT_DATA_DIR` | `data` |
| `defaultTenant` | `MGMT_DEFAULT_TENANT` | `default` |
| `odataPath` | `MGMT_ODATA_PATH` | `/odata/v4/management` |
| `seedDemoData` | `MGMT_SEED_DEMO_DATA` | `false` (`true` in `config/default.json`) |
| `eventRetentionDays` | `MGMT_EVENT_RETENTION_DAYS` | `0` (keep) |
| `eventPruneIntervalMinutes` | `MGMT_EVENT_PRUNE_INTERVAL` | `0` (worker off) |
| `workerTenants` | `MGMT_WORKER_TENANTS` | `default` |
| `frontendDir` | `MGMT_FRONTEND_DIR` | `../frontend` (`""` = don't serve) |

## Deployment (SAP BTP, Cloud Foundry)

```sh
mbt build && cf deploy mta_archives/uim-management_1.0.0.mtar
```

The approuter is the only public entry point: it authenticates with XSUAA
(role collections *UIM Cloud Management Viewer / Administrator*), serves the
Fiori app and forwards `/odata/v4/management`, `/api/v1` and `/rest/v1` to the
backend. For local development copy `approuter/default-env.example.json` to
`approuter/default-env.json` (git-ignored) and run `npm run start:local`.

Snapshots are written to the container disk, which is ephemeral on Cloud
Foundry — bind persistent storage before keeping real data there.

## See also

- [UML.md](UML.md) — component, class and sequence diagrams
- [NAFv4.md](NAFv4.md) — NATO Architecture Framework v4 description
