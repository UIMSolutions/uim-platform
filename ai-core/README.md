# AI Core Service

A D/vibe.d microservice implementing SAP AI Core-like functionality for the UIM Platform. Provides a full ML lifecycle API (AI API v2) covering scenarios, executables, configurations, executions, deployments, artifacts, metrics, and resource group administration.

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

- **Domain**: Scenarios, executables, configurations, executions, deployments, artifacts, metrics, resource groups, Docker registry secrets, object store secrets, execution schedules
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Scenarios** — Register and manage ML scenarios as reusable workflow templates
- **Executables** — Define training and serving executables with parameter/artifact bindings
- **Configurations** — Create parameterised training/serving configurations referencing executables
- **Executions** — Trigger and monitor ML training executions with bulk operations
- **Deployments** — Deploy trained models with TTL, scaling, and bulk lifecycle management
- **Artifacts** — Register and manage model artifacts and datasets
- **Metrics** — Ingest and query execution metrics with filtering
- **Resource Groups** — Administrative resource group management with label support
- **Capabilities** — Expose service capabilities via the AI API v2 meta endpoint

## API Endpoints

### AI API v2 — ML Lifecycle

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v2/lm/meta` | Service capabilities |
| CRUD | `/api/v2/lm/scenarios` | Manage ML scenarios |
| CRUD | `/api/v2/lm/executables` | Manage executables |
| CRUD | `/api/v2/lm/configurations` | Manage configurations |
| CRUD+PATCH | `/api/v2/lm/executions` | Manage executions (with bulk PATCH) |
| CRUD+PATCH | `/api/v2/lm/deployments` | Manage deployments (with bulk PATCH) |
| CRUD | `/api/v2/lm/artifacts` | Manage artifacts |
| GET+PATCH | `/api/v2/lm/metrics` | Ingest and query metrics |

### Admin

| Method | Path | Description |
|--------|------|-------------|
| CRUD+PATCH | `/api/v2/admin/resourceGroups` | Manage resource groups |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd ai-core
dub run

# Run tests
dub test
```

The service starts on port **8090** by default.

## Docker

```bash
docker build -t uim-ai-core .
docker run -p 8090:8090 uim-ai-core
```

## Podman

```bash
podman build -f Containerfile -t uim-ai-core .
podman run -p 8090:8090 uim-ai-core
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AICORE_HOST` | `0.0.0.0` | Bind address |
| `AICORE_PORT` | `8090` | Listen port |

## License

Apache-2.0
