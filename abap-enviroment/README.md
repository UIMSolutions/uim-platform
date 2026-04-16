# ABAP Environment Service

A D/vibe.d microservice implementing SAP BTP ABAP Environment-like functionality for the UIM Platform. Provides ABAP system lifecycle management, software component versioning, communication arrangements, and business user/role administration.

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

- **Domain**: System instances, software components, communication arrangements, service bindings, business users, business roles, transport requests, application jobs
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **System Instances** — Provision and manage ABAP system instances with lifecycle operations
- **Software Components** — Version-controlled ABAP software component management with pull/checkout support
- **Communication Arrangements** — Configure inbound/outbound communication arrangements for system integration
- **Service Bindings** — Manage service bindings for ABAP system connectivity
- **Business Users** — ABAP business user lifecycle (create, lock, unlock, password reset)
- **Business Roles** — Role management with authorization assignment
- **Transport Requests** — ABAP transport request workflow (create, release, import)
- **Application Jobs** — Schedule and monitor ABAP application jobs

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/systems` | Manage ABAP system instances |
| CRUD | `/api/v1/software-components` | Manage software components |
| POST | `/api/v1/software-components/pull/{id}` | Pull software component version |
| CRUD | `/api/v1/communication-arrangements` | Manage communication arrangements |
| CRUD | `/api/v1/service-bindings` | Manage service bindings |
| CRUD | `/api/v1/business-users` | Manage business users |
| POST | `/api/v1/business-users/lock/{id}` | Lock a business user |
| POST | `/api/v1/business-users/unlock/{id}` | Unlock a business user |
| CRUD | `/api/v1/business-roles` | Manage business roles |
| CRUD | `/api/v1/transports` | Manage transport requests |
| POST | `/api/v1/transports/release/{id}` | Release a transport request |
| POST | `/api/v1/transports/import/{id}` | Import a transport request |
| CRUD | `/api/v1/application-jobs` | Manage application jobs |
| POST | `/api/v1/application-jobs/schedule/{id}` | Schedule an application job |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd abap-enviroment
dub run

# Run tests
dub test
```

The service starts on port **8090** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ABAP_HOST` | `0.0.0.0` | Bind address |
| `ABAP_PORT` | `8090` | Listen port |

## License

Apache-2.0
