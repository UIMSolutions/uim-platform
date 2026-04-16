# Content Agent Service

A D/vibe.d microservice implementing SAP Content Agent Service-like functionality for the UIM Platform. Provides content package assembly, provider synchronisation, transport lifecycle management, import/export orchestration, and activity tracking.

## Architecture

Clean/Hexagonal architecture with four layers:

```
┌─────────────────────────────────────────┐
│  Presentation (HTTP Controllers)        │
├─────────────────────────────────────────┤
│  Application (Use Cases, DTOs)          │
├─────────────────────────────────────────┤
│  Domain (Entities, Ports, Services)     │
├─────────────────────────────────────────┤
│  Infrastructure (Repos, Config, DI)     │
└─────────────────────────────────────────┘
```

- **Domain**: Packages, providers, transports, exports, imports, queues, activities
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Packages** — Manage content packages with assembly support for bundling artefacts
- **Providers** — Register and synchronise content providers
- **Transports** — Full transport lifecycle (create, release, cancel) for content delivery
- **Exports** — Initiate and track export operations for content packages
- **Imports** — Initiate and track import operations for incoming content
- **Queues** — Manage content processing queues
- **Activities** — Audit trail and summary of content agent operations

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/packages` | Manage content packages |
| POST | `/api/v1/packages/assemble` | Assemble a content package |
| CRUD | `/api/v1/providers` | Manage content providers |
| POST | `/api/v1/providers/sync` | Synchronise a provider |
| CRUD | `/api/v1/transports` | Manage transport requests |
| POST | `/api/v1/transports/release` | Release a transport |
| POST | `/api/v1/transports/cancel` | Cancel a transport |
| POST/GET | `/api/v1/exports` | Initiate and list exports |
| POST/GET | `/api/v1/imports` | Initiate and list imports |
| CRUD | `/api/v1/queues` | Manage content queues |
| GET | `/api/v1/activities` | List content agent activities |
| GET | `/api/v1/activities/summary` | Get activity summary |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd content-agent
dub run

# Run tests
dub test
```

The service starts on port **8092** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CONTENT_AGENT_HOST` | `0.0.0.0` | Bind address |
| `CONTENT_AGENT_PORT` | `8092` | Listen port |

## License

Apache-2.0
