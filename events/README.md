# UIM Event Mesh

An **SAP Event Mesh** style messaging service for the UIM platform: messaging
services with their own namespaces, message clients, durable queues with topic
subscriptions, webhooks (push delivery), event channels and client bindings —
plus real **topic-based publishing, queue consumption, redelivery and
dead-lettering**.

| Layer | Technology |
|---|---|
| Backend | D, vibe.d 0.10.3, hexagonal / Clean Architecture ([backend/](backend/)) |
| APIs | OData v4 for SAP Fiori (`/odata/v4/event-mesh`), REST/JSON (`/api/v1/event-mesh`) |
| Admin tools | Command line interface (`uim-event-mesh-cli`), GtkD 3 desktop GUI (`uim-event-mesh-gui`) |
| Frontend | SAP Fiori 3 / UI5 1.120 ([frontend/](frontend/)) |
| Cloud | SAP BTP Cloud Foundry: approuter + XSUAA ([approuter/](approuter/)), [mta.yaml](mta.yaml); Kubernetes ([k8s/](k8s/)) |

All four driving adapters (OData, REST, CLI, GUI) run through **one EDM model
and one `ODataEngine`** from `uim-platform:service`, so validation, scopes,
`$filter`/`$orderby`/`$search` and error semantics are identical everywhere.

---

## What the service does

| Resource | Purpose |
|---|---|
| **Messaging services** | Own a namespace (`acme/sales/orders`). The plan (`dev`, `standard`, `premium`) sets the quotas: clients, queues, queue depth and message size. Explicit values override the plan. |
| **Queues** | Durable FIFO stores of one service, with depth/size limits, message TTL, max. redeliveries, a dead letter queue (same service, no cycles) and ingress/egress switches. |
| **Queue subscriptions** | Route events into a queue by topic pattern: `*` matches one segment, a trailing `#` matches the rest. The pattern must lie in the service namespace. |
| **Webhooks** | Push the messages of a queue to an HTTP endpoint (none / Basic / API key / OAuth2 client credentials). `atLeastOnce` keeps a message until a 2xx answer; `atMostOnce` removes it after the first attempt. |
| **Event channels** | Document concrete topics (optionally with an AsyncAPI definition). An inactive channel blocks publishing to its topic. |
| **Message clients** | OAuth2 applications of a service (AMQP, MQTT, HTTP REST) with a permitted namespace. A secret is generated if none is given, and it is never returned. |
| **Message bindings** | Grant a client `publish`, `subscribe`, `publishSubscribe` or `manage` on exactly one queue or channel. |
| **Queue messages** | Copies of a published event, one per matching queue. Reading lists them, deleting acknowledges them. |

### Message flow

```text
publish(topic, payload)                       ┌─ queue A ── consume / webhook push ──▶ endpoint
  ├─ service active? topic in namespace?      │      │ failure: retry ≤ maxRedeliveryCount
  ├─ client active, namespace, publish binding│      └─▶ dead letter queue (or discard)
  ├─ payload ≤ quota                          │
  └─ route: active subscriptions × pattern ───┼─ queue B (full / ingress off → rejected)
                                              └─ …
```

### Business rules (enforced in the application layer)

* Unique service names and namespaces per tenant. Unique client and queue names per service. One channel per topic. No duplicate subscription pattern per queue, and no duplicate binding per client and target.
* Quotas: number of clients and queues per service, queue depth and message size. A violation answers **422 QuotaExceeded**.
* A service cannot be deleted while it still has clients, queues or channels. A queue cannot be deleted while a webhook pushes it or while another queue uses it as dead letter queue (**422**). Deleting a queue removes its subscriptions, bindings and messages. Deleting a client or channel removes its bindings.
* Expired messages are skipped when reading and removed when consuming, by the delivery worker, or with `expire`.

---

## Quick start

Requirements: `dub`, `dmd` or `ldc2`; GTK 3 only for the GUI.

```bash
cd backend
dub build                       # server   → build/uim-event-mesh-platform-service
dub build --config=cli          # CLI      → build/uim-event-mesh-cli
dub build --config=gui          # GtkD GUI → build/uim-event-mesh-gui
dub test                        # unit + end-to-end tests

./build/uim-event-mesh-cli seed               # demo scenario into data/event-mesh.json
./build/uim-event-mesh-platform-service       # http://localhost:8109
```

Open **http://localhost:8109/app/index.html** for the Fiori app. The server
serves `../frontend` locally; on BTP the approuter does it. The server, the
CLI and the GUI share the same JSON snapshot (`storage: file`), so changes made
in one show up in the others.

### Command line

```bash
CLI=./build/uim-event-mesh-cli
$CLI help
$CLI sets                                             # entity sets, singleton, actions
$CLI list Queues --filter="messageCount gt 0" --orderby="name"
$CLI create Queues --serviceId=sales-orders --name=acme/sales/orders/billing --deadLetterQueueId=orders-dlq
$CLI create QueueSubscriptions --queueId=<id> --topicPattern='acme/sales/orders/ce/*'
$CLI publish acme/sales/orders/ce/created '{"orderId":"1"}' --client=webshop
$CLI publish acme/sales/orders/ce/created @order.json --service=sales-orders
$CLI consume orders-created --max=5 --json
$CLI update Webhooks erp-webhook --status=active --url=https://erp.example.com/hook
$CLI deliver --all                                    # push now (exit 1 if a delivery failed)
$CLI purge orders-audit --yes
$CLI stats
$CLI config                                           # effective configuration, secrets masked
```

Global options: `--tenant=<id>`, `--storage=memory|file`, `--data-file=<path>`,
`--config-dir=<dir>`, `--json` / `--csv`.

### Desktop GUI (GtkD)

```bash
./build/uim-event-mesh-gui --data-file=data/event-mesh.json --refresh=5
```

The GUI is the model-driven entity browser of `uim-platform:service`: one page
per entity set with `$filter`/`$search`, create/edit/delete forms generated
from the EDM types, the Statistics sheet, and runners for `PublishEvent`,
`ConsumeMessages`, `PurgeQueue` and `DeliverWebhook`. With file storage it
refreshes itself, so it can sit next to the running server.

---

## APIs

### OData v4 — `/odata/v4/event-mesh`

`$metadata` includes Fiori annotations (UI.HeaderInfo, UI.LineItem,
UI.SelectionFields, Core.Computed/Immutable, Capabilities). It supports `$batch`,
`$count`, `$filter`, `$orderby`, `$select`, `$search`, `$top`, `$skip`,
server-side paging and `IEEE754Compatible`.

| Entity set | Write | Scope (read / write) |
|---|---|---|
| `MessagingServices`, `MessageClients`, `Queues`, `QueueSubscriptions`, `Webhooks`, `EventChannels`, `MessageBindings` | POST / PATCH / DELETE | `Read` / `Manage` |
| `QueueMessages` | DELETE (= acknowledge) | `Read` / `Consume` |
| `Statistics` (singleton) | — | `Read` |

| Action | Parameters | Returns | Scope |
|---|---|---|---|
| `PublishEvent` | `topic`, `payload`, `serviceId` or `clientId`, `contentType` | `PublishResult` (messageId, queueIds, rejectedQueueIds) | `Publish` |
| `ConsumeMessages` | `queueId`, `maxMessages` (1–1000), `clientId` | `Collection(QueueMessage)` | `Consume` |
| `PurgeQueue` | `queueId` | `PurgeResult` | `Manage` |
| `DeliverWebhook` | `webhookId` | `DeliveryResult` | `Manage` |

Secrets (`clientSecret`, webhook `credentials`) are write-only: reads return
`null` plus `hasSecret` / `hasCredentials`.

### REST — `/api/v1/event-mesh`

`messaging-services`, `message-clients`, `queues`, `queue-subscriptions`,
`webhooks`, `event-channels`, `message-bindings`, `messages`:
`GET` (with `filter`, `orderby`, `select`, `search`, `top`, `skip`) → `{items, totalCount}`,
`POST`, `GET/PUT/PATCH/DELETE /:id`. In addition:

```text
POST /api/v1/event-mesh/events                 {"topic", "payload", "serviceId"|"clientId"}
POST /api/v1/event-mesh/queues/:id/consume     {"maxMessages": 10}
POST /api/v1/event-mesh/queues/:id/purge
POST /api/v1/event-mesh/webhooks/:id/deliver
GET  /api/v1/event-mesh/statistics
GET  /health
```

Errors use `{"error": {"code", "message"}}` with these statuses: 400 invalid,
404 not found, 409 conflict, 422 business rule or quota, 401 / 403 security.

---

## Configuration

Precedence (lowest → highest): built-in defaults → `backend/config/default.json`
→ `config/<UIM_PROFILE>.json` → `EVENT_MESH_<KEY>` environment variables
(camelCase → UPPER_SNAKE) → Cloud Foundry (`PORT`, `VCAP_SERVICES`) → CLI options.

| Key | Default | Meaning |
|---|---|---|
| `port` / `host` | `8109` / `0.0.0.0` | HTTP listener |
| `storage` | `memory` (`file` in default.json) | `memory` or `file` (JSON snapshot) |
| `dataFile` | `data/event-mesh.json` | snapshot shared by server, CLI and GUI |
| `defaultTenant` | `default` | tenant if no token or `X-Tenant-Id` header |
| `restPath` / `odataPath` | `/api/v1/event-mesh` / `/odata/v4/event-mesh` | API roots |
| `maxPageSize` | `200` | server-side paging |
| `requireAuthentication` / `jwtSecret` | `false` / — | HS256 tokens outside BTP |
| `frontendDir` | `../frontend` | Fiori app under `/app` (empty = off) |
| `deliveryIntervalSeconds` | `0` | background webhook delivery and expiry (0 = manual) |
| `webhookTimeoutSeconds` | `10` | HTTP timeout of webhook calls |
| `deliveryTenants` | `["default"]` | tenants processed by the worker |

Security: with an XSUAA binding in `VCAP_SERVICES`, the service requires RS256
tokens and enforces the scopes `Read`, `Manage`, `Publish` and `Consume` (see
[approuter/xs-security.json](approuter/xs-security.json)). Without one,
local development is open: the tenant comes from `X-Tenant-Id` and the user
from `X-User-Id`.

---

## Deployment

```bash
# SAP BTP Cloud Foundry (approuter + XSUAA + backend)
mbt build && cf deploy mta_archives/uim-event-mesh_2.0.0.mtar

# Local approuter (copy and fill approuter/default-env.json — never committed)
cd approuter && npm install && npm start          # http://localhost:5000

# Container (build context = repository root)
docker build -f events/backend/Dockerfile -t uim-platform/event-mesh .
kubectl apply -f events/k8s/
```

The file store keeps messages on one node. Run a **single instance** and give it
a persistent volume (`/data`) if messages must survive restarts.

---

## Layout

```text
events/
├── mta.yaml                      MTA: backend + approuter + XSUAA
├── backend/                      D / vibe.d (dub package "events")
│   ├── config/default.json
│   ├── source/app.d | cli.d | gui.d          entry points (server, CLI, GtkD)
│   └── source/uim/platform/events/
│       ├── domain/               entities, types (ids, topics), enumerations, services, exceptions
│       ├── ports/                usecases, messaging, services, repositories, storages, gateways
│       ├── application/          usecases (interactors), services (statistics, demo data), dtos
│       ├── persistence/          repositories, storages, mappers, records
│       ├── infrastructure/       configuration, security, logging, clients, workers, container
│       └── presentation/         odata, http, cli, gui, web, rest, unix
├── frontend/                     SAP Fiori 3 app (uim.eventmesh)
├── approuter/                    @sap/approuter, xs-app.json, xs-security.json
└── k8s/                          ConfigMap, Deployment, Service
```

See [UML.md](UML.md) for the diagrams and [NAFv4.md](NAFv4.md) for the NAF v4
architecture description.
