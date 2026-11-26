# UIM Application Event Hub

Application Event Hub service of the UIM Platform, modelled on **SAP Cloud Application Event Hub**: the SAP cloud
systems of a customer landscape (S/4HANA Cloud, SuccessFactors, side-by-side extensions on SAP BTP, …) are
**registered** and grouped into **formations**; producers publish business events as **CloudEvents 1.0**; a catalog
of **event types** says what may be published; **subscriptions** route matching events — narrowed by **filters** —
to a **channel** of a consumer (a webhook or a pull queue); delivery is **at least once** with exponential back-off,
and messages the hub gives up on become **dead letters** that operators requeue or discard.

| Part | Technology | Folder |
|---|---|---|
| Backend | D, uim-framework 26.11, vibe.d 0.10.5, clean / hexagonal architecture | [backend/](backend/) |
| Frontend | SAP Fiori 3 / OpenUI5 1.120 (OData V4) | [frontend/](frontend/) |
| Approuter | `@sap/approuter` with XSUAA | [approuter/](approuter/) |
| Deployment | MTA (SAP BTP Cloud Foundry), Docker/Podman, Kubernetes | [mta.yaml](mta.yaml), [k8s/](k8s/) |
| Architecture | UML (Mermaid) and NAF v4 descriptions | [uml.md](uml.md), [nafv4.md](nafv4.md) |

One EDM model drives every adapter: the OData v4 endpoint for Fiori (incl. `$metadata` with UI annotations), the
REST API, the command line and the GtkD desktop GUI. All of them validate, authorize and answer alike. Login is
built in (JWT, scopes) or handled by the approuter with XSUAA.

## Concepts

| Resource | Purpose |
|---|---|
| **Formation** | The systems of one landscape that may exchange events. Subscriptions connect systems of the same formation only; an inactive formation routes nothing. |
| **System** | A registered SAP cloud system, `producer`, `consumer` or `both`; its id is the CloudEvents `source` of its events. Inactive systems neither publish nor receive. |
| **Event type** | Catalog entry, e.g. `sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1`, with owner, category and schema version; `active`, `deprecated` (still delivered, no new subscriptions) or `retired` (refused). |
| **Channel** | Where a consumer receives messages: a **webhook** (HTTP POST of the CloudEvent) or a **queue** (the consumer pulls and acknowledges); delivery mode `atLeastOnce` or `atMostOnce`; maximum message size; `active`, `draining` (no new messages, pending ones are still delivered) or `inactive` (messages wait). |
| **Subscription** | Producer → consumer for an event type or **pattern** (`*` = one segment, a trailing `*` = the rest), over a channel of the consumer, with max. retries and the first back-off; `active` or `paused`. Its health is `ok`, `warning` (retries / paused) or `error` (open dead letters). |
| **Filter** | A rule of a subscription on an envelope attribute (`type`, `source`, `subject`, …) or the payload (`data.country`): operators `equals`, `notEquals`, `contains`, `startsWith`, `endsWith`, `oneOf`, `exists`. Every include filter must match; one matching exclude filter rejects. |
| **Message** | One event routed to one subscription: payload, attempts, next attempt, last error, `pending` → `delivered` / `queued` / `retrying` → `deadLettered` / `dropped`. |
| **Dead letter** | A message the hub gave up on (retries exhausted, payload above the channel limit, channel deleted) — `open`, `requeued` or `discarded`. |

### How an event travels (`application/usecases/publishing.d`, `delivery.d`)

1. **Validate**: CloudEvents 1.0 envelope (`specversion`, `id` — generated if missing —, `source`, `type`), payload
   at most `maxPayloadBytes` (1 MiB); structured, batch (`{"events": […]}`) and binary (`ce-*` headers) content
   modes.
2. **Authorize the producer**: the `source` is an active system that produces; the type is in the catalog, not
   retired and — if the event type has an owner — published by that owner (`requireRegisteredTopics`).
3. **Idempotency**: the same event id of the same source again returns the first result (`duplicate: true`).
4. **Route** (pure domain service `domain/services/router.d`): every subscription of the producer whose pattern
   matches; paused subscriptions, inactive consumers / formations and channels that are not active are skipped;
   filters are applied; payloads above the channel limit become dead letters at once.
5. **Deliver** (first attempt during the publish call when `deliverOnPublish`): webhook → `delivered` on HTTP 2xx;
   queue → `queued` until the consumer acknowledges. A failed attempt schedules a retry after
   `retryBackoffSeconds · 2^(attempt-1)` (capped by `maxBackoffSeconds`); after `1 + maxRetries` attempts the message
   becomes a **dead letter**. At-most-once channels drop failed messages.
6. The **delivery worker** retries due messages every `dispatchIntervalSeconds` and applies the retention periods
   (`messageRetentionHours`, `deadLetterRetentionDays`).

### Business rules (enforced by the use cases)

- Ids are 1–64 of `[A-Za-z0-9._-]`; event types are dot separated segments (≤ 256 characters) and unique per tenant;
  the event type of a catalog entry, the type and consumer of a channel, and producer and consumer of a subscription
  are immutable.
- Subscriptions: the producer produces, the consumer consumes, the channel belongs to the consumer, both systems
  belong to the same formation (or both to none), exact types must be registered and active; a subscription is
  unique per producer, consumer, type and channel. Deleting it removes its filters, its messages stay.
- Systems used by subscriptions cannot leave their formation or lose the needed role; systems, formations, event
  types and channels in use are not deleted (`422`). A channel with undelivered messages is not deleted.
- Webhooks need an http(s) endpoint; channel limits are 1 KiB … 16 MiB; retries 0 … 20; back-off 1 … 3600 s.
- Only open messages can be delivered now; only queued messages can be acknowledged; only open dead letters can be
  requeued or discarded; a purged message cannot be requeued.

## Project layout

```text
application-events/
├── mta.yaml                      SAP BTP deployment (backend, approuter, XSUAA, user-provided config)
├── backend/                      D / vibe.d service
│   ├── dub.sdl                   configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json       local defaults (overridden by APPEVENTS_* env and VCAP_SERVICES)
│   ├── Dockerfile, Containerfile
│   ├── tests/event_hub_flows.d   integration tests across all layers
│   └── source/
│       ├── app.d · cli.d · gui.d entry points
│       └── uim/platform/application_events/
│           ├── domain/           entities, types (ids, time, scopes, CloudEvent), enumerations, exceptions,
│           │                     services (event type patterns, filters, retries, router)
│           ├── ports/            usecases, services, repositories, storages, messaging (audit), gateways
│           ├── application/      usecases (landscape, catalog, subscriptions, publishing, delivery, access),
│           │                     services (support, statistics, capabilities, demo data), dtos
│           ├── persistence/      repositories, storages (batching memory / file store), mappers, records
│           ├── infrastructure/   configuration, logging, security (JWT, PBKDF2), clients (delivery gateways,
│           │                     clock), workers (delivery), monitoring, container (composition root)
│           └── presentation/     odata (model, engine), http (REST, auth, health), web (Fiori), cli, gui
├── frontend/                     SAP Fiori 3 app (Component.js, manifest.json, view/, controller/, fragment/,
│                                 model/, i18n/ en + de, localService/ metadata + mock data, test/ QUnit + OPA5)
├── approuter/                    xs-app.json, xs-security.json, package.json, default-env.json (local, git-ignored)
└── k8s/                          deployment (+PVC), service, configmap, secret.example
```

## Build and run

Requirements: a D compiler (tested with DMD 2.114; the container build uses LDC 1.40), dub, and the shared `service` package at `../../service`.

```bash
cd backend
dub build                     # server  → build/uim-application-events-platform-service
dub build --config=cli        # CLI     → build/uim-application-events-cli
dub build --config=gui        # GtkD    → build/uim-application-events-gui (needs GTK 3)
dub test --config=defaultTest # unit + integration tests
```

### Local development

```bash
cd backend
./build/uim-application-events-platform-service
# first start in jwt mode: the log shows the generated password of "admin" once
# Fiori app:  http://localhost:8132/app/index.html      (sign in as admin; "Create Demo Landscape" in an empty tenant)
# OData:      http://localhost:8132/odata/v4/appevents/$metadata
# REST:       http://localhost:8132/api/v1/appevents/capabilities
# Health:     http://localhost:8132/health
```

Without login (development only): `APPEVENTS_AUTH_MODE=open ./build/uim-application-events-platform-service`.
With the approuter and a real XSUAA instance: fill `approuter/default-env.json` from a service key and run
`npm start` in `approuter/` (port 5000). The frontend runs standalone against the mock data with `npm start` in
`frontend/` (UI5 tooling).

Publish an event:

```bash
curl -X POST http://localhost:8132/api/v1/appevents/events \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/cloudevents+json" \
  -d '{"specversion":"1.0","type":"sap.s4.beh.salesorder.v1.SalesOrder.Created.v1","source":"s4",
       "subject":"SalesOrder/4711","data":{"salesOrder":"4711","netAmount":1250.5}}'
# → 202 {"routed":1,"queued":1,"outcomes":[{"subscriptionId":"orders-to-analytics","status":"queued",…}],…}

# binary content mode
curl -X POST http://localhost:8132/api/v1/appevents/events -H "Authorization: Bearer $TOKEN" \
  -H "ce-specversion: 1.0" -H "ce-type: sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1" \
  -H "ce-source: s4" -H "ce-id: bp-1000044" -H "Content-Type: application/json" -d '{"country":"DE"}'

# the analytics consumer pulls its queue and acknowledges
curl -H "Authorization: Bearer $TOKEN" "http://localhost:8132/api/v1/appevents/channels/analytics-queue/pull?max=10"
curl -X POST -H "Authorization: Bearer $TOKEN" http://localhost:8132/api/v1/appevents/messages/<id>/ack
```

### CLI

The CLI uses the same container as the server; with `--data-file` it shares the server's JSON snapshot.

```bash
CLI="./build/uim-application-events-cli --data-file=data/application-events.json"
$CLI help
$CLI seed                                                   # demo landscape (empty tenant)
$CLI publish sap.s4.beh.salesorder.v1.SalesOrder.Created.v1 s4 '{"salesOrder":"9"}' --subject=SalesOrder/9
$CLI preview sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1 s4 '{"country":"US"}'
$CLI messages hires-to-crm --status=retrying
$CLI dispatch                                               # deliver all due messages now
$CLI dead-letters ; $CLI requeue <id> ; $CLI requeue --all --subscription=hires-to-crm ; $CLI discard <id>
$CLI pull analytics-queue --max=5 ; $CLI ack <message>
$CLI pause bp-to-crm ; $CLI resume bp-to-crm
$CLI channel-status crm-webhook draining ; $CLI type-status bp-changed deprecated
$CLI assign landscape ext-app ; $CLI unassign ext-app ; $CLI filters bp-to-crm
$CLI stats ; $CLI purge ; $CLI capabilities ; $CLI config
$CLI list Subscriptions --filter="health eq 'error'"        # generic: sets, metadata, list, get, create, update, delete, invoke
$CLI token admin ; $CLI passwd admin '<new password>'
```

### Container / Kubernetes / BTP

```bash
# from the repository root (path dependency on ../../service)
docker build -f application-events/backend/Dockerfile -t uim-platform/application-events .
docker run -p 8132:8132 -v aeh-data:/data \
  -e APPEVENTS_JWT_SECRET="$(openssl rand -base64 48)" -e APPEVENTS_ADMIN_PASSWORD='change me now!' \
  uim-platform/application-events

cp k8s/secret.example.yaml k8s/secret.yaml   # fill in, never commit
kubectl apply -f k8s/

mbt build && cf deploy mta_archives/uim-application-events_2.0.0.mtar
```

The file store is a single-node JSON snapshot (one replica, `Recreate` strategy, a persistent volume).

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
account for 15 minutes; the last administrator cannot be deleted, locked or lose the Admin scope. The first start in
`jwt` mode creates the administrator (`adminUser`, `adminPassword` or a generated password logged once).

| Scope | Allows | XSUAA role template |
|---|---|---|
| `Read` | read everything, routing preview | Viewer |
| `Publish` | publish events — for the technical users of producer systems | Producer |
| `Operate` | deliver now, dispatch, pull / acknowledge queues, requeue / discard dead letters, pause / resume subscriptions (implies Publish) | Operator |
| `Manage` | formations, systems, event types, channels, subscriptions, filters, purge, demo content (implies Operate) | IntegrationAdministrator |
| `Admin` | users of the built-in login | Administrator |

A producer system gets a user with `Publish` only (`POST /api/v1/appevents/users` with `"scopes": ["Publish"]`), a
queue consumer one with `Operate`. The Fiori app keeps the token per browser tab (`sessionStorage`), sends it with
every OData request, shows actions by scope and returns to the login dialog when a token expires. `/health` stays
public for probes.

## APIs

### OData v4 — `/odata/v4/appevents`

Entity sets `Formations`, `Systems`, `EventTypes`, `Channels`, `Subscriptions`, `Filters` (read / write),
`Messages`, `DeadLetters` (read only), `Users` (Admin) and the singleton `Statistics('<tenant>')`, with `$filter`,
`$orderby`, `$top`, `$skip`, `$count`, `$search`, `$select` and `$batch`. Rows carry derived facts (names of
referenced systems and channels, counters, subscription health, last event).

Actions: `PublishEvent` / `PreviewRouting` (`type, source, subject?, id?, time?, data?` as JSON text), `DispatchDue`,
`DeliverMessage`, `AcknowledgeMessage`, `RequeueDeadLetter`, `RequeueDeadLetters(subscriptionId?)`,
`DiscardDeadLetter`, `PauseSubscription`, `ResumeSubscription`, `SetChannelStatus`, `SetEventTypeStatus`,
`SetSystemStatus`, `SetFormationStatus`, `AssignSystem`, `UnassignSystem`, `PurgeMessages`, `SeedDemoData`.

### REST — `/api/v1/appevents`

| Method | Path | |
|---|---|---|
| GET / POST | `/<resource>` | list (`{count, resources}`, OData query options) / create → 201 |
| GET / PUT / PATCH / DELETE | `/<resource>/{id}` | read / partial update / delete → 204 |
| POST | `/events` | publish: structured, batch (`{"events": […]}` or `[…]` → 207) or binary (`ce-*` headers) → 202 |
| POST | `/events/preview` | routing without delivery |
| POST | `/formations/{id}/activate` · `/deactivate` · `/systems {systemId}` | status, assign a system |
| DELETE | `/formations/{id}/systems/{systemId}` | remove a system from the formation |
| POST | `/systems/{id}/activate` · `/deactivate` | |
| POST | `/event-types/{id}/status` | `{status: active / deprecated / retired}` |
| POST | `/channels/{id}/activate` · `/deactivate` · `/drain` | |
| GET | `/channels/{id}/messages` · `/channels/{id}/pull?max=10` | messages of a channel / queued messages of a queue |
| POST | `/subscriptions/{id}/pause` · `/resume` · `/dead-letters/requeue` | |
| GET | `/subscriptions/{id}/filters` · `/messages` · `/dead-letters` · `/formations/{id}/systems` · `/systems/{id}/channels` | children |
| POST | `/messages/{id}/deliver` · `/messages/{id}/ack` · `/messages/purge` | |
| POST | `/dead-letters/{id}/requeue` · `/discard` | |
| POST | `/delivery/dispatch` · `/demo-data` | |
| GET | `/statistics` · `/capabilities` · `/meta` · `/api/v1/health` | |

Resources: `formations`, `systems`, `event-types`, `channels`, `subscriptions`, `filters`, `messages`, `dead-letters`,
`users`. Errors answer `{"error": {code, message, requestId, target}}` with 400 / 401 / 403 / 404 / 405 / 409 / 413 /
422 / 500.

## Delivery gateway

`deliveryMode: "simulate"` (default for development) accepts every webhook except hosts ending in `.invalid` or
endpoints containing `/fail` (they answer 503 — the demo's onboarding webhook shows retries and dead letters).
`deliveryMode: "http"` POSTs the CloudEvent in structured mode (`application/cloudevents+json`, headers `ce-id`,
`ce-type`, `ce-source`, `X-Correlation-Id`) with `deliveryTimeoutSeconds`; an optional `Authorization` header comes
from `APPEVENTS_DELIVERY_AUTHORIZATION`. Any 2xx is a success.

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `APPEVENTS_<KEY>` environment
variables → Cloud Foundry (`PORT`, `VCAP_SERVICES`: XSUAA binding, user-provided service `application-events-config`)
→ CLI options.

| Key (env `APPEVENTS_…`) | Default | |
|---|---|---|
| `port` / `host` | 8132 / 0.0.0.0 | |
| `storage` / `dataFile` | memory (file in config, container) / `data/application-events.json` | `memory` or `file` |
| `authMode` | open (jwt in config, container) | `open`, `jwt`; an XSUAA binding switches to `xsuaa` |
| `jwtSecret` / `tokenTtlSeconds` | random per start / 3600 | secret ≥ 32 characters |
| `adminUser` / `adminPassword` | admin / generated | first administrator in jwt mode |
| `passwordIterations` · `maxFailedLogins` · `lockSeconds` · `minPasswordLength` | 120000 · 5 · 900 · 10 | |
| `requireRegisteredTopics` | true | events and exact subscriptions need a catalog entry |
| `deliverOnPublish` | true | first attempt during the publish call |
| `maxPayloadBytes` · `maxBatchEvents` · `maxRequestBytes` | 1 MiB · 100 · 4 MiB | |
| `maxBackoffSeconds` | 3600 | cap of the exponential back-off |
| `messageRetentionHours` · `deadLetterRetentionDays` | 72 · 30 | purge of finished messages / resolved dead letters |
| `dispatchIntervalSeconds` · `purgeEveryRuns` · `maxDispatchBatch` · `workerTenants` | 10 · 360 · 500 · default | delivery worker (0 = on demand) |
| `deliveryMode` · `deliveryTimeoutSeconds` | simulate · 10 | `simulate` or `http` |
| `apiPath` · `odataPath` · `frontendDir` | /api/v1 · /odata/v4/appevents · ../frontend | `frontendDir: ""` behind the approuter |

`GET /health` reports mode, storage, gateway and the worker counters; `cli config` shows the effective configuration
with secrets masked.

## Tests

```bash
cd backend && dub test --config=defaultTest
```

Unit tests sit next to the code (CloudEvent parsing, event type patterns, filters, back-off, router, entities,
mappers, configuration, PBKDF2 vectors, JWT round trip, batching store). `tests/event_hub_flows.d` runs the demo
landscape end to end with a manual clock (filtered, delivered, queued, retrying → dead letter → requeue), the business
rules, the REST API (structured, binary and batch publishing, pull / ack) and the OData endpoint over vibe.d test
requests, the JWT login with all scopes, the CLI, the batching file store and the delivery worker. The frontend has
QUnit tests (`frontend/test/unit`) and an OPA5 journey (`frontend/test/integration`, against a running backend).

## License

Apache 2.0 — see the repository's LICENSE file.
