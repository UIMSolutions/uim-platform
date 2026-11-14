# Agentry Service

A metadata-driven mobile application platform in the style of **SAP BTP Agentry**: author app definitions, release versions, enroll devices, track data synchronisation with SAP backends and roll out deployments.

- **Backend:** D + vibe.d 0.10.x, hexagonal / clean architecture
- **Interfaces:** REST (`/api/v1`), vibe.d REST interface (`/rest/v1`), **OData v4** (`/odata/v4/agentry`), **command line** (`uim-agentry-cli`), **GtkD desktop GUI** (`uim-agentry-gui`)
- **Frontend:** SAP Fiori 3 / UI5 app on the OData v4 service
- **Deployment:** SAP BTP Cloud Foundry (`mta.yaml`, approuter + XSUAA), Docker/Podman, Kubernetes

## Project layout

```
agentry/
├── mta.yaml                    MTA descriptor: backend + approuter + XSUAA
├── backend/                    D / vibe.d service
│   ├── dub.sdl                 configurations: defaultRun (server), cli, gui, defaultTest …
│   ├── config/default.json     default configuration
│   ├── source/app.d            HTTP server composition root
│   ├── source/cli.d            CLI entry point
│   ├── source/gui.d            GtkD entry point
│   └── source/uim/platform/agentry/
│       ├── domain/             entities, types, enumerations, services (validator, lifecycle), exceptions
│       ├── ports/              driving (usecases, services, AgentryPorts) + driven (repositories, storages, messaging, gateways)
│       ├── application/        use cases, statistics service, DTOs
│       ├── persistence/        repositories, JSON snapshot storage, mappers, records
│       ├── infrastructure/     configuration, logging, security (XSUAA/JWT), clients (backend probe), workers, DI container
│       └── presentation/       http, rest, odata, web, cli, gui (+ shared payloads / tabular)
├── frontend/                   SAP Fiori 3 / UI5 app (view, controller, model, i18n, localService, test)
├── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
└── k8s/                        Kubernetes manifests
```

## Architecture

Dependencies point inwards only. Every presentation adapter (REST, REST interface, OData, CLI, GUI) receives the same `AgentryPorts` bundle of driving-port interfaces from the DI `Container`, so business rules exist exactly once.

```
 REST ─┐  OData ─┐  CLI ─┐  GtkD ─┐
       └─────────┴──────┴────────┴──▶ AgentryPorts (IManage…UseCase, IAgentryStatisticsService)
                                          │
                                 application/usecases ──▶ domain (validator, lifecycle rules)
                                          │
              ┌───────────────────────────┼─────────────────────────────┐
     I…Repository ports            IBackendProbe              IAgentryEventPublisher
              │                           │                             │
 persistence (memory | JSON snapshots)  HttpBackendProbe        LogEventPublisher
```

### Business rules

| Object | Lifecycle | Notable rules |
|---|---|---|
| Mobile application | draft → active ⇄ deprecated → archived | unique package name per tenant, reverse-domain package name |
| App definition | draft → published → archived → draft | metadata (JSON/XML) is syntax-checked; only valid drafts can be published; published metadata is immutable |
| App version | pending → published ⇄ deprecated → withdrawn | requires a published definition of the same application and an artifact URL; version numbers unique per app |
| Device | enrolled → active ⇄ suspended → removed | inherits the application platform; a completed sync activates it and records the installed version |
| Sync session | pending → inProgress → completed / failed / cancelled (failed → pending = retry) | suspended/removed devices may not sync; watchdog fails sessions running longer than `syncTimeoutMinutes` |
| Backend connection | inactive / active / error / testing | `TestBackendConnection` probes the URL; changing the URL resets the status |
| Deployment | pending → deploying → deployed / failed → rolledBack | only published versions; start resolves target devices by scope (device / group / tenant); rollback records the previously deployed version |

Use case results map to HTTP status codes uniformly: `400` invalid input, `404` not found, `409` duplicate, `422` business rule / lifecycle violation.

## Building and running

```bash
cd backend
dub build                      # server  → build/uim-agentry-platform-service
dub build --config=cli         # CLI     → build/uim-agentry-cli
dub build --config=gui         # GtkD    → build/uim-agentry-gui   (needs GTK 3.24)
dub test                       # unit tests
```

Server, CLI and GUI share the same data when `storage` is `file` (one JSON snapshot per collection in `dataDir`, written atomically and reloaded when another process changes it).

```bash
./build/uim-agentry-platform-service          # http://localhost:8117 — Fiori app at /index.html
./build/uim-agentry-cli help
./build/uim-agentry-gui --tenant=default
```

### CLI examples

```bash
uim-agentry-cli apps create --name="Field Service" --package=com.example.fs --platform=ios --offline
uim-agentry-cli definitions create --app=<appId> --name=Main --file=definition.json
uim-agentry-cli definitions publish <defId>
uim-agentry-cli versions create --app=<appId> --definition=<defId> --version=1.0.0 --artifact=https://cdn/fs.ipa
uim-agentry-cli versions publish <verId>
uim-agentry-cli devices enroll --app=<appId> --name=Tech-01 --os=17.4 --group=north
uim-agentry-cli deployments create --version=<verId> --scope=group --group=north
uim-agentry-cli deployments start <depId>
uim-agentry-cli connections test <conId>
uim-agentry-cli stats --json
```

Exit codes: `0` success, `1` rejected by the service, `2` usage error.

## Configuration

Precedence (lowest → highest): compiled defaults → `config/default.json` (or `AGENTRY_CONFIG_FILE`) → environment → `VCAP_SERVICES` credentials of a service named/tagged `agentry-config`.

| Key | Environment | Default |
|---|---|---|
| `host` / `port` | `AGENTRY_HOST` / `AGENTRY_PORT`, `PORT` | `0.0.0.0` / `8117` |
| `logLevel` | `AGENTRY_LOG_LEVEL` | `info` |
| `storage` | `AGENTRY_STORAGE` | `file` (`memory` = volatile) |
| `dataDir` | `AGENTRY_DATA_DIR` | `data` |
| `defaultTenant` | `AGENTRY_DEFAULT_TENANT` | `default` |
| `odataPath` | `AGENTRY_ODATA_PATH` | `/odata/v4/agentry` |
| `frontendDir` | `AGENTRY_FRONTEND_DIR` | `../frontend` (`""` = off) |
| `probeTimeoutSeconds` | `AGENTRY_PROBE_TIMEOUT` | `5` (`0` disables connectivity tests) |
| `watchdogIntervalMinutes` | `AGENTRY_WATCHDOG_INTERVAL` | `0` (off) |
| `syncTimeoutMinutes` | `AGENTRY_SYNC_TIMEOUT` | `60` |
| `watchdogTenants` | `AGENTRY_WATCHDOG_TENANTS` | `default` |

The tenant is taken from the XSUAA JWT (`zid`) when present, otherwise from `X-Tenant-Id`; the acting user from the token or `X-User-Id`. **JWT signatures are not verified by the backend** — it relies on the approuter; do not expose it directly.

## APIs

### OData v4 — `/odata/v4/agentry/`

Entity sets (full CRUD, `$filter $orderby $select $top $skip $count $search`): `MobileApplications`, `AppDefinitions`, `AppVersions`, `Devices`, `SyncSessions`, `BackendConnections`, `Deployments`; singleton `Statistics`.

Unbound actions (`POST`, JSON body with `id` plus parameters, returns the entity):
`SetMobileApplicationStatus(status)`, `ValidateAppDefinition`, `PublishAppDefinition`, `ArchiveAppDefinition`, `PublishAppVersion`, `WithdrawAppVersion`, `SetDeviceStatus(status)`, `StartSyncSession`, `CompleteSyncSession(bytesSent, bytesReceived, recordsSent, recordsReceived)`, `FailSyncSession(errorMessage)`, `CancelSyncSession`, `TestBackendConnection`, `StartDeployment`, `CompleteDeployment(devicesSucceeded, devicesFailed)`, `RollbackDeployment`.

`$batch` is not supported — the UI5 model uses `groupId: "$direct"`. `Edm.Int64` values are sent as strings when the client requests `IEEE754Compatible=true`.

### REST — `/api/v1/agentry/<resource>`

`GET/POST /<resource>`, `GET/PUT/DELETE /<resource>/:id` for `mobile-applications`, `app-definitions`, `app-versions`, `devices`, `sync-sessions`, `backend-connections`, `deployments`. `PUT` merges the supplied fields into the stored entity. Health: `GET /api/v1/health`.

### vibe.d REST interface — `/rest/v1/agentry/app-definitions`

`GET /`, `GET /:id`, `POST /`, `PUT /:id`, `POST /:id/publish`, `DELETE /:id`.

## Deployment

```bash
mbt build && cf deploy mta_archives/uim-agentry_1.0.0.mtar          # SAP BTP Cloud Foundry
docker build -f agentry/backend/Dockerfile -t uim-platform/agentry .  # from the uim-platform root
kubectl apply -f k8s/
```

For a local approuter see [approuter/README.md](approuter/README.md). The Fiori app can also run standalone with `cd frontend && npm start` (UI5 tooling); tests are under `frontend/test/testsuite.qunit.html`.

See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the architecture framework views.

## License

Apache-2.0 — Copyright (c) 2018-2026 Ozan Nurettin Suel
