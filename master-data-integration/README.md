# Master Data Integration Service

A D/vibe.d microservice implementing SAP Master Data Integration (MDI)-like functionality for the UIM Platform. Provides master data orchestration across connected business systems with change-log-based delta distribution, key mapping, client management, and replication job scheduling.

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

- **Domain**: Master data objects, data models, distribution models, key mappings, clients, replication jobs, filter rules, change log entries
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Master Data** — Manage master data objects with global ID lookup
- **Data Models** — Define master data schemas and entity structures
- **Distribution Models** — Configure how master data is distributed to connected systems, with activate/deactivate lifecycle
- **Key Mappings** — Maintain cross-system key mappings for master data objects with lookup support
- **Clients** — Manage connected client systems with connect/disconnect operations
- **Replication Jobs** — Schedule and control master data replication jobs (start, pause, cancel)
- **Filter Rules** — Define filter criteria to control which data is replicated to which clients
- **Change Log** — Delta-based change log with delta token support for incremental data synchronisation

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/master-data` | Manage master data objects |
| GET | `/api/v1/master-data/lookup?globalId=...` | Look up a master data object by global ID |
| CRUD | `/api/v1/data-models` | Manage master data models |
| CRUD | `/api/v1/distribution-models` | Manage distribution models |
| POST | `/api/v1/distribution-models/activate/{id}` | Activate a distribution model |
| POST | `/api/v1/distribution-models/deactivate/{id}` | Deactivate a distribution model |
| CRUD | `/api/v1/key-mappings` | Manage key mappings |
| GET | `/api/v1/key-mappings/lookup?...` | Look up a key mapping |
| CRUD | `/api/v1/clients` | Manage connected clients |
| POST | `/api/v1/clients/connect/{id}` | Connect a client |
| POST | `/api/v1/clients/disconnect/{id}` | Disconnect a client |
| CRUD | `/api/v1/replication-jobs` | Manage replication jobs |
| POST | `/api/v1/replication-jobs/start/{id}` | Start a replication job |
| POST | `/api/v1/replication-jobs/pause/{id}` | Pause a replication job |
| POST | `/api/v1/replication-jobs/cancel/{id}` | Cancel a replication job |
| CRUD | `/api/v1/filter-rules` | Manage replication filter rules |
| GET | `/api/v1/change-log` | Get the full change log |
| GET | `/api/v1/change-log?deltaToken=...` | Get incremental changes since a delta token |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build and run locally
cd master-data-integration
dub run

# Run tests
dub test
```

The service starts on port **8096** by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MDI_HOST` | `0.0.0.0` | Bind address |
| `MDI_PORT` | `8096` | Listen port |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
