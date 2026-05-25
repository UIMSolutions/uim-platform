# SAP Integration Suite Platform Service

A D/vibe.d microservice implementing SAP Integration Suite-like functionality for the UIM Platform. Covers Cloud Integration (iPaaS), API Management, Advanced Event Mesh (AEM), B2B / Trading Partner Management, and Message Mapping.

## Architecture

Clean/Hexagonal architecture with four layers:

```
┌─────────────────────────────────────────────────────┐
│  Presentation (HTTP REST · CLI · Web UI · GUI)      │
├─────────────────────────────────────────────────────┤
│  Application (Use Cases, DTOs)                      │
├─────────────────────────────────────────────────────┤
│  Domain (Entities, Ports, Domain Services)          │
├─────────────────────────────────────────────────────┤
│  Infrastructure (Repos, Config, DI, Persistence)    │
└─────────────────────────────────────────────────────┘
```

### Domain Capabilities

| Capability | Entities |
|---|---|
| **Cloud Integration** | IntegrationPackage, IntegrationFlow, MessageMapping |
| **API Management** | ApiProxy, ApiProduct |
| **Event Mesh** | MessageQueue, TopicSubscription |
| **B2B** | TradingPartner |
| **User Management** | IntegrationUser |

### Persistence

| Adapter | Status | Description |
|---|---|---|
| **Memory** | ✓ Active | In-process hash-map; ideal for dev/test |
| **Files** | Planned | JSON file per entity type in configurable directory |
| **MongoDB** | Planned | vibe.d MongoDB driver; production-grade persistence |

### Presentation

| Layer | Pattern | Description |
|---|---|---|
| `presentation/http` | REST/JSON | vibe.d URLRouter controllers, all CRUD + lifecycle ops |
| `presentation/cli` | MVC | Command-line dispatcher; future argv parser |
| `presentation/web` | MVC | Server-side Diet template UIs |
| `presentation/gui` | MVC | Desktop GUI panels (DlangUI / WebView) |

## Features

### Cloud Integration
- **Integration Packages** — Organise flows and mappings into versioned packages
- **Integration Flows** — Design sender/receiver adapter pipelines with deploy/undeploy lifecycle
- **Message Mappings** — Source-to-target structure mappings with expression support

### API Management
- **API Proxies** — Proxy definitions with policy chains (security, quota, spike arrest, cache, transform)
- **API Products** — Product bundles composed of API proxies with scopes and environments
- **Publish lifecycle** — Draft → Published → Deprecated → Retired

### Advanced Event Mesh
- **Message Queues** — Tenant-scoped queues with configurable size, retention, and dead-letter support
- **Topic Subscriptions** — Pattern-based subscriptions linking topics to queues via pluggable protocols

### B2B / Trading Partner Management
- **Trading Partners** — B2B counterparty registry with standard (EDI X12, EDIFACT, AS2, XML, etc.) and contact details

### Cross-Cutting
- **Multi-tenancy** — All entities are tenant-scoped via `X-Tenant-Id` header
- **Health endpoint** — `GET /api/v1/health` for liveness/readiness probes
- **Structured JSON errors** — Consistent `{"error": "…"}` responses

## API Endpoints

### Cloud Integration

| Method | Path | Description |
|---|---|---|
| CRUD | `/api/v1/integration/packages` | Manage integration packages |
| CRUD | `/api/v1/integration/flows` | Manage integration flows |
| POST | `/api/v1/integration/flows/deploy/:id` | Deploy an integration flow |
| CRUD | `/api/v1/integration/mappings` | Manage message mappings |

### API Management

| Method | Path | Description |
|---|---|---|
| CRUD | `/api/v1/apimanagement/proxies` | Manage API proxies |
| POST | `/api/v1/apimanagement/proxies/publish/:id` | Publish an API proxy |
| CRUD | `/api/v1/apimanagement/products` | Manage API products |
| POST | `/api/v1/apimanagement/products/publish/:id` | Publish an API product |

### Event Mesh

| Method | Path | Description |
|---|---|---|
| CRUD | `/api/v1/eventmesh/queues` | Manage message queues |
| CRUD | `/api/v1/eventmesh/subscriptions` | Manage topic subscriptions |
| GET | `/api/v1/eventmesh/subscriptions?queueId=<id>` | Filter by queue |

### B2B

| Method | Path | Description |
|---|---|---|
| CRUD | `/api/v1/b2b/partners` | Manage trading partners |

### Users / Health

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/integration/users` | List integration users |
| GET | `/api/v1/integration/users/:id` | Get integration user |
| GET | `/api/v1/health` | Service health |

## Getting Started

### Build & Run (local)

```sh
cd integration-suite
dub run
```

### Docker

```sh
docker build -t uim-platform/integration-suite:latest .
docker run -p 8096:8096 uim-platform/integration-suite:latest
```

### Podman

```sh
podman build -f Containerfile -t uim-platform/integration-suite:latest .
podman run -p 8096:8096 uim-platform/integration-suite:latest
```

### Kubernetes

```sh
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `INTEGRATION_SUITE_HOST` | `0.0.0.0` | Bind address |
| `INTEGRATION_SUITE_PORT` | `8096` | HTTP port |

## Project Structure

```
integration-suite/
├── source/
│   ├── app.d                         — Entry point
│   └── uim/platform/integration_suite/
│       ├── domain/
│       │   ├── entities/             — Business entities
│       │   ├── ports/repositories/  — Repository interfaces (ports)
│       │   ├── services/             — Domain validators
│       │   ├── enumerations.d
│       │   └── types.d
│       ├── application/
│       │   ├── dto.d                 — Request/response DTOs
│       │   └── usecases/             — Use case classes
│       ├── infrastructure/
│       │   ├── config.d              — Environment-based configuration
│       │   ├── container.d           — DI container
│       │   └── persistence/
│       │       ├── memory/           — In-memory repository adapters
│       │       ├── files/            — File-based adapters (planned)
│       │       └── mongo/            — MongoDB adapters (planned)
│       └── presentation/
│           ├── http/controllers/     — REST API controllers
│           ├── cli/                  — CLI MVC (planned)
│           ├── web/                  — Web UI MVC (planned)
│           └── gui/                  — Desktop GUI MVC (planned)
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── Dockerfile
├── Containerfile
├── dub.sdl
├── README.md
├── UML.md
└── NAFv4.md
```

## License

Apache-2.0 — © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
