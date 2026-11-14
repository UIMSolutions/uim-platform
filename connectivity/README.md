# UIM Connectivity Service

A D/vibe.d service modelled on the **SAP BTP Connectivity and Destination services**:
named **destinations** with eleven authentication flows, **Cloud Connectors** that open a
tunnel to on-premise networks, **service channels**, **access control rules**, a
**certificate store** and a **connectivity event log**. A **connection check** resolves
a destination the way the connectivity proxy would route it (authentication settings →
certificate → Cloud Connector of the location → access rule → probe), and a periodic
**health check** detects missed connector heartbeats, expiring certificates and
destinations that became unreachable.

One hexagonal core, four driving adapters:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST `/api/v1` | `uim-connectivity-platform-service` | JSON API for scripts, Cloud Connectors and other services |
| OData v4 `/odata/v4/connectivity` | `uim-connectivity-platform-service` | SAP Fiori 3 / UI5 frontend |
| CLI | `uim-connectivity-cli` | administration and automation |
| GtkD GUI | `uim-connectivity-gui` | desktop client |

Server, CLI and GUI share the same snapshot storage (`backend/data/*.json`), so a
change made in one is visible in the others.

## Project layout

```
connectivity/
├── mta.yaml                    MTA descriptor (backend + approuter + XSUAA) for SAP BTP / Cloud Foundry
├── backend/                    D 2.11x / vibe.d 0.10.3
│   ├── dub.sdl                 configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json     default configuration
│   └── source/
│       ├── app.d · cli.d · gui.d                  composition roots
│       └── uim/platform/connectivity/
│           ├── domain/          entities, types (ids, value objects), enumerations,
│           │                    services (names, endpoints, auth flows, access control,
│           │                    lifecycle, certificate validity), exceptions
│           ├── ports/           usecases, services (driving) · repositories, storages,
│           │                    messaging, gateways (driven)
│           ├── application/     usecases (one interactor per aggregate + health check),
│           │                    services (event recorder, destination checker, connector
│           │                    cascade, statistics), dtos (specs, requests, results)
│           ├── persistence/     repositories, storages (JSON snapshot files, memory),
│           │                    mappers (reflection based), records (collections, envelope)
│           ├── infrastructure/  configuration, logging, security (XSUAA identity),
│           │                    clients (simulated probe), workers (health check), container (DI)
│           ├── presentation/    resources (protocol-neutral adapters + registry), http (REST),
│           │                    odata (model, $metadata, query engine, controller), cli, gui, web
│           └── helpers/         codec (struct ⇄ JSON reflection), enums, json, time
├── frontend/                   SAP Fiori 3 / UI5 app (uim.connectivity)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/           $metadata and mock data captured from the backend
│   └── test/                   QUnit (formatter) and OPA5 journey
└── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
```

## Domain model

| Aggregate | Parent | Lifecycle | Notable rules |
|---|---|---|---|
| `Destination` | tenant | `unchecked` → `reachable` / `unreachable` / `misconfigured` (connection check, health check) | name unique per tenant, letters/digits/`-`/`_`, immutable; URL scheme per type (`http(s)`, `ldap(s)`, `smtp(s)`/`imap(s)`/`pop3(s)`, `tcp(s)`, `rfc(s)`; RFC may use `jco.client.ashost`/`sysnr` instead); required fields per authentication type; OAuth/SAML flows need an `https` token service; `principalPropagation` only on premise; certificate given by id **or name**; **password, client secret and token service password are masked** |
| `CloudConnector` | tenant | `connected` ⇄ `disconnected`, `connected` ⇄ `maintenance`, `error` → `connected`; missed heartbeat → `disconnected` | name unique per tenant; location ID unique per subaccount (empty = default location); disconnect / maintenance closes open channels; cannot be unregistered with open channels; unregistering removes its channels and access rules |
| `ServiceChannel` | connector | `closed` → `open` → `closed` | name and virtual host:port unique per connector; opens only through a connected connector; mapping changes and deletion only when closed; 1–20 connections |
| `AccessRule` | connector | `enabled` ⇄ `disabled` | protocol, virtual host:port, internal host:port, URL path prefix with or without sub-paths; name derived from the resource if empty; one rule per resource; **longest matching prefix wins, `deny` wins ties, unknown resources are denied** |
| `Certificate` | tenant | `valid` → `expiring` → `expired`; `revoked` (final) | name unique; expiry required; SHA-1/SHA-256 fingerprint normalized; renew extends validity; revoked certificates are frozen; certificates used by destinations cannot be deleted |
| `ConnectivityLogEntry` | tenant | append-only | written by every relevant use case (connections, channels, access checks, certificate events, check results) with a default severity per event type; external events can be recorded; `PATCH` is refused; pruned to `maxLogEntries` |

### Connection check

```
authentication settings complete?        no → misconfigured
certificate exists and is usable?        no → misconfigured
proxyType = onPremise:
  Cloud Connector for the location?      no → unreachable (destinationNotFound)
  connector connected?                   no → unreachable
  access rule allows scheme/host/port/path?  no → unreachable (accessDenied)
  probe internal host via the tunnel
else probe the endpoint directly         → reachable / unreachable
```

The result (status, message, latency, time) is stored on the destination and logged.
The health check repeats it for every destination and logs only status changes.

## Build and run

```sh
cd backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:8088/
dub run                                   # = --config=defaultRun

# Command line interface
dub build --config=cli
./build/uim-connectivity-cli help
./build/uim-connectivity-cli connectors create --name="Frankfurt DC" --location-id=fra --host=scc.corp.local
./build/uim-connectivity-cli access-rules create --connector-id="Frankfurt DC" \
    --virtual-host=erp.virtual --virtual-port=443 --internal-host=erp.corp.local --internal-port=44300 \
    --url-path-prefix=/sap/opu/odata
./build/uim-connectivity-cli destinations create --name=ERP_ODATA --url=https://erp.virtual/sap/opu/odata \
    --proxy-type=onPremise --cloud-connector-location-id=fra \
    --authentication-type=basicAuthentication --user=ODATA_USER --password=@secret.txt --properties="sap-client=100"
./build/uim-connectivity-cli destinations check ERP_ODATA
./build/uim-connectivity-cli access-check "Frankfurt DC" https://erp.virtual/sap/bc/gui   # DENIED
./build/uim-connectivity-cli certificates renew erp-client --valid-days=365
./build/uim-connectivity-cli health-check
./build/uim-connectivity-cli logs list --severity=warning --json

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub run --config=gui -- --tenant=default

# Unit tests (domain rules, codec, persistence, use cases, adapters, an end-to-end scenario)
dub test --config=defaultTest
```

CLI conventions: `--kebab-case` and `--camelCase` options are equivalent; lists are
`a,b`, key/value lists `k=v,k2=v2`; `@file` reads a value from a file; connector
references (`connectorId`) accept an id or a unique name; `--actor=<id>` sets the acting
user (`createdBy`/`updatedBy`), `--tenant`, `--data-dir`, `--storage=memory` and `--json`
are global. Exit codes: 0 ok, 1 failure, 2 usage error.

### Fiori app

The backend serves `frontend/` at `/index.html` for local development
(`frontendDir`). Without a backend, `npm start` in `frontend/` runs the UI5 tooling;
`localService/` holds `$metadata` and mock data captured from a seeded backend.

Tabs: Overview (tiles), Destinations (with an object page per destination: connection,
authentication, properties, its event log, **Check Connection**), Cloud Connectors,
Service Channels, Access Rules, Certificates, Event Log (severity filter). Header
actions: **Health Check** and **Access Check**. KPIs come from the `Statistics`
singleton. English and German.

### Deploy to SAP BTP (Cloud Foundry)

```sh
mbt build            # backend (binary buildpack) + approuter (Fiori app in resources/)
cf deploy mta_archives/uim-connectivity_1.0.0.mtar
```

The approuter authenticates with XSUAA and forwards `/odata/v4/connectivity/*` and
`/api/v1/*` to the backend (destination `connectivity-srv`). Role collections:
*UIM Connectivity Viewer / Operator / Administrator* (see `approuter/README.md`).

## Configuration

Precedence (lowest → highest): compiled defaults → `config/default.json`
(or `CONN_CONFIG_FILE`) → environment variables → `VCAP_SERVICES` (credentials of a
service named or tagged `connectivity-config`).

| Key | Env | Default | Meaning |
|---|---|---|---|
| `serviceName` | `CONN_SERVICE_NAME` | Connectivity Service | |
| `host` / `port` | `CONN_HOST` / `CONN_PORT`, `PORT` | 0.0.0.0 / 8088 | listener |
| `logLevel` | `CONN_LOG_LEVEL` | info | trace, debug, info, warn, error, none |
| `storage` | `CONN_STORAGE` | file | `file` (JSON snapshots) or `memory` |
| `dataDir` | `CONN_DATA_DIR` | data | snapshot directory |
| `defaultTenant` | `CONN_DEFAULT_TENANT` | default | tenant without token / `X-Tenant-Id` |
| `odataPath` | `CONN_ODATA_PATH` | /odata/v4/connectivity | |
| `healthCheckIntervalSeconds` | `CONN_HEALTH_CHECK_INTERVAL` | 30 | 0 = off |
| `healthCheckTenants` | `CONN_HEALTH_CHECK_TENANTS` | default | comma separated |
| `heartbeatTimeoutSeconds` | `CONN_HEARTBEAT_TIMEOUT` | 300 | connected → disconnected after this |
| `certificateWarningDays` | `CONN_CERTIFICATE_WARNING_DAYS` | 30 | valid → expiring |
| `maxLogEntries` | `CONN_MAX_LOG_ENTRIES` | 5000 | per tenant, 0 = unlimited |
| `frontendDir` | `CONN_FRONTEND_DIR` | ../frontend | "" = do not serve the UI |

Tenant and user come from the XSUAA bearer token (`zid`, `user_name`) or the
`X-Tenant-Id` / `X-User-Id` headers. The backend decodes but does **not** verify the
token signature — it relies on the approuter; verify JWTs before exposing it directly.

## REST API (`/api/v1`)

| Method | Path | |
|---|---|---|
| GET | `/<resource>[?<field>=<value>…]` | list, filtered by payload fields → `{items, count}` |
| POST | `/<resource>` | create → 201 |
| GET | `/<resource>/{id}` | read |
| PATCH (PUT) | `/<resource>/{id}` | partial update; a masked secret (`********`) keeps the stored value |
| DELETE | `/<resource>/{id}` | → 204 |
| POST | `/<resource>/{id}/<action>` | action, parameters as JSON body |
| GET | `/statistics` | KPIs |
| POST | `/health-check` | run a health check pass |
| POST | `/access-check` | `{"connector": "<id or name>", "url": "https://erp.virtual/sap/opu"}` |
| GET | `/resources` | catalogue: resources, input fields, actions |
| GET | `/health` | liveness |

| Resource | Actions |
|---|---|
| `destinations` | `check` |
| `connectors` | `heartbeat {connectorVersion}`, `disconnect`, `reconnect`, `start-maintenance` |
| `channels` | `open`, `close` |
| `access-rules` | `enable`, `disable` |
| `certificates` | `revoke`, `renew {validDays}` |
| `logs` | — (append-only) |

Errors: `{"error": {"code": "NotFound|Conflict|BusinessRuleViolation|BadRequest|…", "message": "…"}}`
with 400 / 404 / 405 / 409 / 422 / 500.

## OData v4 (`/odata/v4/connectivity`)

- Entity sets `Destinations`, `CloudConnectors`, `ServiceChannels`, `AccessRules`,
  `Certificates`, `ConnectivityLogs` (not updatable); singleton `Statistics`; complex
  type `KeyValue`.
- Unbound actions `<Action><Type>` with parameter `id`: `CheckDestination`,
  `HeartbeatCloudConnector`, `DisconnectCloudConnector`, `ReconnectCloudConnector`,
  `StartMaintenanceCloudConnector`, `OpenServiceChannel`, `CloseServiceChannel`,
  `EnableAccessRule`, `DisableAccessRule`, `RevokeCertificate`, `RenewCertificate`;
  plus `RunHealthCheck` → `HealthCheckResult` and `CheckAccess(connector, url)` →
  `AccessCheckResult`.
- Query options `$filter` (eq ne gt ge lt le and or not, contains startswith endswith
  tolower toupper), `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, `/$count`.
- `$metadata` with `Common.Label` and capability annotations.
- No `$batch`: the UI5 model uses `groupId: "$direct"`.

## Changes from the previous version

The service was rebuilt on the hexagonal layout shared with `abap-environment`, `kyma`
and `management`.

- **Layout:** the module moved from `connectivity/source` to `connectivity/backend`
  (root `dub.sdl`: `subPackage "connectivity/backend"`, still commented out there); new
  `frontend/`, `approuter/`, `mta.yaml`; docs at the module root (`NAFv4.md` moved
  from `docs/`). CI (`.github/workflows/connectivity.yml`) builds server and CLI and runs
  the tests in `backend/`.
- **New:** OData v4 + Fiori app, CLI, GtkD GUI, connection check, access check, health
  check (heartbeat timeout, certificate expiry, re-checks, log retention), statistics,
  maintenance mode, channel/rule cascade on unregister, certificate renew/revoke,
  enable/disable for rules, persistence in JSON snapshots (`storage=memory` keeps the old
  behaviour), configuration file and `VCAP_SERVICES`.
- **Routes:** `/monitoring/logs` → `/logs`, `/monitoring/summary` → `/statistics`;
  `PATCH` added (PUT still accepted); action routes unchanged (`/connectors/{id}/heartbeat`,
  `/channels/{id}/open|close`). Error bodies are `{error: {code, message}}`.
- **Payloads:** destination `type` → `destinationType`, `authentication` →
  `authenticationType`, `tokenServiceURL` → `tokenServiceUrl`; channel `type` →
  `channelType`; certificate `type` → `certificateType`, `validFrom/validTo` →
  `issuedAt/expiresAt`, `active` → `status` (+ `revoke`); connector `lastHeartbeat` →
  `lastHeartbeatAt`, `connectedSince` → `connectedAt`, new required `name`; log
  `timestamp` → `occurredAt`; access rules gain `internalHost/Port`, `includeSubPaths`,
  `enabled`, `name`. Timestamps are ISO 8601 strings; secrets are masked instead of
  being replaced by `has*` flags.
- **Fixed:** updating a destination always answered "not found" (the id was never put
  into the request); ports (`port`, `virtualPort`, `backendPort`) and certificate validity
  were never read from payloads, so access rules could not match and expiry tracking
  never worked; empty or unknown enum values (`type`, `protocol`, `policy`) raised an
  unhandled conversion exception instead of a validation error; heartbeats did not update `lastHeartbeat`; the duplicate-name check
  ran before the empty-name check.

## Architecture notes

- **Reflection codec.** Persistence records, REST/OData payloads, OData `$metadata`,
  CLI tables and GUI forms are derived from the domain structs at compile time
  (`helpers/codec.d`). Adding a field to an entity and its spec makes it available in
  every adapter. `decode(patch, base)` provides PATCH semantics.
- **Resource registry.** `presentation/resources` wraps each driving port in a
  protocol-neutral adapter (JSON in/out, columns, actions, secret masking, append-only).
  REST, OData, CLI and GUI are thin protocol layers on top of it.
- **Probe gateway.** Connection checks use `IConnectivityProbe` (direct and via tunnel).
  The default `SimulatedConnectivityProbe` derives latency deterministically; hosts
  containing `invalid`, `unreachable` or `offline` refuse connections. A real HTTP/socket
  client and the Cloud Connector tunnel API can be plugged in without touching use cases.
- **Event log.** `EventRecorder` writes a log entry and publishes a message
  (`IConnectivityEventPublisher`, default: technical log) for every relevant event.
- **Snapshot storage.** One JSON file per collection, written atomically (temp file +
  rename) and reloaded when another process changed it. Suitable for local and
  single-instance use, not for concurrent writers at scale. Secrets are stored in plain
  text in the snapshots — use a credential store for production data.

See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the NAF v4 architecture description.

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
