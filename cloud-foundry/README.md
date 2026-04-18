# Cloud Foundry Runtime Service

A D/vibe.d microservice implementing SAP BTP Cloud Foundry Runtime-like functionality for the UIM Platform. Provides organisation, space, application, service, route, buildpack, and domain lifecycle management.

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

- **Domain**: Organizations, spaces, applications, service instances, service bindings, routes, domains, buildpacks
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Organizations** — Create and manage CF organizations with suspend/activate lifecycle
- **Spaces** — Manage Cloud Foundry spaces within organizations
- **Applications** — Deploy and manage CF applications with start/stop/restart/scale and environment variable management
- **Service Instances** — Provision and manage CF service instances
- **Service Bindings** — Bind service instances to applications
- **Routes** — Manage HTTP routes with map/unmap operations
- **Domains** — Register and manage CF domains
- **Buildpacks** — Manage Cloud Foundry buildpacks
- **Monitoring** — App-level and space-level metrics and health views

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/orgs` | Manage organizations |
| POST | `/api/v1/orgs/suspend/{id}` | Suspend an organization |
| POST | `/api/v1/orgs/activate/{id}` | Reactivate an organization |
| CRUD | `/api/v1/spaces` | Manage spaces |
| CRUD | `/api/v1/apps` | Manage applications |
| POST | `/api/v1/apps/start/{id}` | Start an application |
| POST | `/api/v1/apps/stop/{id}` | Stop an application |
| POST | `/api/v1/apps/restart/{id}` | Restart an application |
| POST | `/api/v1/apps/scale/{id}` | Scale an application |
| GET | `/api/v1/apps/env/{id}` | Get application environment variables |
| CRUD | `/api/v1/service-instances` | Manage service instances |
| CR_D | `/api/v1/service-bindings` | Manage service bindings |
| CR_D | `/api/v1/routes` | Manage routes |
| POST | `/api/v1/routes/map/{id}` | Map a route to an app |
| POST | `/api/v1/routes/unmap/{id}` | Unmap a route from an app |
| CR_D | `/api/v1/domains` | Manage domains |
| CRUD | `/api/v1/buildpacks` | Manage buildpacks |
| GET | `/api/v1/monitoring/apps` | List app monitoring data |
| GET | `/api/v1/monitoring/apps/{id}` | Get app monitoring details |
| GET | `/api/v1/monitoring/spaces/{id}` | Get space monitoring summary |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build and run locally
cd cloud-foundry
dub run

# Run tests
dub test
```

The service starts on port **8091** by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CF_HOST` | `0.0.0.0` | Bind address |
| `CF_PORT` | `8091` | Listen port |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
