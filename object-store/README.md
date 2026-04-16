# Object Store Service

A D/vibe.d microservice implementing SAP Object Store Service-like functionality for the UIM Platform. Provides S3-compatible object storage with bucket management, object versioning, access policies, lifecycle rules, CORS configuration, and service binding administration.

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

- **Domain**: Buckets, storage objects, object versions, access policies, lifecycle rules, CORS rules, service bindings
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Buckets** — Create and manage storage buckets with quota and access configuration
- **Objects** — Upload, download, copy, and delete storage objects with metadata
- **Object Versioning** — Retrieve full version history for storage objects
- **Access Policies** — Define bucket and object-level access policies
- **Lifecycle Rules** — Configure object expiry and transition lifecycle rules
- **CORS Rules** — Manage Cross-Origin Resource Sharing rules for browser clients
- **Service Bindings** — Manage service bindings that grant credential-based bucket access, with revoke support

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/buckets` | Manage storage buckets |
| CRUD | `/api/v1/objects` | Manage storage objects |
| POST | `/api/v1/objects/copy` | Copy a storage object |
| GET | `/api/v1/objects/{id}/versions` | Get object version history |
| CRUD | `/api/v1/access-policies` | Manage access policies |
| CRUD | `/api/v1/lifecycle-rules` | Manage lifecycle rules |
| CRUD | `/api/v1/cors-rules` | Manage CORS rules |
| CRUD | `/api/v1/service-bindings` | Manage service bindings |
| POST | `/api/v1/service-bindings/{id}/revoke` | Revoke a service binding |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd object-store
dub run

# Run tests
dub test
```

The service starts on port **8092** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OBJSTORE_HOST` | `0.0.0.0` | Bind address |
| `OBJSTORE_PORT` | `8092` | Listen port |

## License

Apache-2.0
