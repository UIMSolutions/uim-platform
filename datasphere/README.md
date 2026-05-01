# SAP Datasphere Service for UIM Platform

A BTP-style Datasphere service built with D language using vibe.d, following clean and hexagonal architecture principles.

## Features

- **Spaces** - Isolated workspaces for data management with storage quotas and member management
- **Connections** - Connect to data sources (HANA, S/4HANA, BW, OData, SQL, Kafka, etc.)
- **Remote Tables** - Virtual access to remote data with replication support (realtime, scheduled, snapshot)
- **Data Flows** - ETL/ELT data pipelines with scheduling
- **Views** - SQL/graphical views with semantic types (fact, dimension, analytical, etc.)
- **Tasks** - Scheduled data processing tasks with retry support
- **DSTask Chains** - Chain multiple tasks with success/failure routing
- **Data Access Controls** - Row-level security with criteria-based filtering
- **Catalog** - Data discovery, governance, and full-text search

## Architecture

```
datasphere/
  source/
    app.d                          # Entry point - composition root
    uim/platform/datasphere/
      domain/                      # Core business logic (no dependencies)
        types.d                    # Type aliases and enums
        entities/                  # Domain entities (Space, Connection, View, etc.)
        ports/repositories/        # Repository interfaces (driven ports)
        services/                  # Domain services (validators, schedulers)
      application/                 # Use cases (application services)
        dto.d                      # Request/Response DTOs
        usecases/manage/           # CRUD use cases per entity
      infrastructure/              # Adapters and configuration
        config.d                   # Environment-based configuration
        container.d                # DI container (composition root)
        persistence/memory/        # In-memory repository implementations
      presentation/                # Driving adapters
        http/controllers/          # vibe.d HTTP controllers
        http/json_utils.d          # JSON serialization helpers
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/datasphere/spaces` | Manage spaces |
| GET/POST/DELETE | `/api/v1/datasphere/connections` | Manage data source connections |
| GET/POST/DELETE | `/api/v1/datasphere/remoteTables` | Manage remote tables |
| GET/POST/DELETE | `/api/v1/datasphere/dataFlows` | Manage data flows |
| GET/POST/PUT/DELETE | `/api/v1/datasphere/views` | Manage views |
| GET/POST/DELETE | `/api/v1/datasphere/tasks` | Manage scheduled tasks |
| GET/POST/DELETE | `/api/v1/datasphere/taskChains` | Manage task chains |
| GET/POST/DELETE | `/api/v1/datasphere/dataAccessControls` | Manage data access controls |
| GET/POST/DELETE | `/api/v1/datasphere/catalog` | Manage catalog assets |
| GET | `/api/v1/datasphere/catalog/search?q=` | Search catalog |
| GET | `/api/v1/health` | Health check |

## Headers

- `X-Tenant-Id` - Tenant identifier for multi-tenancy
- `X-Space-Id` - Space identifier for space-scoped operations

## Build and Run

```bash
# Build and run
cd datasphere
dub run --config=defaultRun

# Run tests
dub test --config=defaultTest
```

## Container Build

```bash
# Docker
docker build -t uim-platform/cloud-datasphere:latest .

# Podman
podman build -f Containerfile -t uim-platform/cloud-datasphere:latest .
```

## Kubernetes Deployment

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DATASPHERE_HOST` | `0.0.0.0` | Listen address |
| `DATASPHERE_PORT` | `8095` | Listen port |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
