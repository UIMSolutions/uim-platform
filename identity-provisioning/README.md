# Identity Provisioning Service

A D/vibe.d microservice implementing SAP Cloud Identity Services — Provisioning (IPS)-like functionality for the UIM Platform. Provides source/target/proxy system configuration, provisioning job execution, transformation rules, provisioned entity tracking, and audit logging.

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

- **Domain**: Source systems, target systems, proxy systems, provisioning jobs, transformations, provisioned entities, provisioning logs
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Source Systems** — Configure identity source systems (LDAP, SAP HR, IAS, custom) with connector settings
- **Target Systems** — Configure identity target systems (IAS, SAP apps, LDAP) for provisioning
- **Proxy Systems** — Set up proxy systems that act as both source and target
- **Transformations** — Define mapping and transformation rules for identity attribute conversion
- **Provisioning Jobs** — Schedule and trigger provisioning runs with read/resync support
- **Provisioned Entities** — Track all provisioned users and groups with their current state
- **Monitoring** — View provisioning job status, logs, and entity counts

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/source-systems` | Manage source systems |
| CRUD | `/api/v1/target-systems` | Manage target systems |
| CRUD | `/api/v1/proxy-systems` | Manage proxy systems |
| CRUD | `/api/v1/transformations` | Manage transformation rules |
| CRUD | `/api/v1/provisioning-jobs` | Manage provisioning jobs |
| POST | `/api/v1/provisioning-jobs/run/{id}` | Trigger a provisioning job |
| GET | `/api/v1/monitoring` | Get provisioning monitoring data |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd identity-provisioning
dub run

# Run tests
dub test
```

The service starts on port **8093** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `IPS_HOST` | `0.0.0.0` | Bind address |
| `IPS_PORT` | `8093` | Listen port |

## License

Apache-2.0
