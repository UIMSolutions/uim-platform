# Kyma Runtime Service

A D/vibe.d microservice implementing SAP BTP Kyma Runtime-like functionality for the UIM Platform. Provides Kubernetes-native serverless functions, API exposure rules, service catalogue integration, event-driven subscriptions, module management, and application connectivity.

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

- **Domain**: Kyma environments, namespaces, serverless functions, API rules, service instances, service bindings, event subscriptions, Kyma modules, applications
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Environments** — Provision and manage Kyma runtime environments
- **Namespaces** — Kubernetes namespace management within Kyma environments
- **Serverless Functions** — Deploy and manage serverless functions with runtime and trigger configuration
- **API Rules** — Expose services via Kyma API rules with authentication and routing policies
- **Service Instances** — Provision service instances from the service catalogue
- **Service Bindings** — Bind service instances to Kyma workloads
- **Event Subscriptions** — Subscribe to event types with pause/resume lifecycle
- **Kyma Modules** — Enable and disable Kyma runtime modules
- **Applications** — Register and manage external application connectivity

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/environments` | Manage Kyma environments |
| CRUD | `/api/v1/namespaces` | Manage namespaces |
| CRUD | `/api/v1/functions` | Manage serverless functions |
| CRUD | `/api/v1/api-rules` | Manage API exposure rules |
| CRUD | `/api/v1/service-instances` | Manage service instances |
| CRUD | `/api/v1/service-bindings` | Manage service bindings |
| CRUD | `/api/v1/event-subscriptions` | Manage event subscriptions |
| POST | `/api/v1/event-subscriptions/pause/{id}` | Pause an event subscription |
| POST | `/api/v1/event-subscriptions/resume/{id}` | Resume an event subscription |
| CRUD | `/api/v1/modules` | Manage Kyma modules |
| POST | `/api/v1/modules/disable/{id}` | Disable a Kyma module |
| CRUD | `/api/v1/applications` | Manage external applications |
| POST | `/api/v1/applications/connect/{id}` | Connect an application |
| POST | `/api/v1/applications/disconnect/{id}` | Disconnect an application |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build and run locally
cd kyma
dub run

# Run tests
dub test
```

The service starts on port **8095** by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `KYMA_HOST` | `0.0.0.0` | Bind address |
| `KYMA_PORT` | `8095` | Listen port |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
