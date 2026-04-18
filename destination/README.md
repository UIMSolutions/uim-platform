# Destination Service

A D/vibe.d microservice implementing SAP BTP Destination Service-like functionality for the UIM Platform. Provides centralised management of connectivity destinations, certificates, and destination fragments for outbound HTTP/RFC connections.

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

- **Domain**: Destinations, certificates, destination fragments, destination lookups, auth tokens
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Destinations** — Create and manage named connectivity destinations (HTTP, RFC, LDAP) with authentication configuration
- **Destination Lookup** — Find destinations by name for use in connectivity flows
- **Certificates** — Store and manage client certificates used by destination configurations
- **Certificate Validation** — Validate certificate validity and expiry
- **Certificate Expiry Alerts** — List certificates approaching expiry
- **Destination Fragments** — Define reusable destination configuration fragments

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/destinations` | Manage connectivity destinations |
| GET | `/api/v1/destinations/find?name=<name>` | Look up a destination by name |
| CRUD | `/api/v1/certificates` | Manage client certificates |
| GET | `/api/v1/certificates/expiring` | List expiring certificates |
| POST | `/api/v1/certificates/validate/{id}` | Validate a certificate |
| CRUD | `/api/v1/fragments` | Manage destination fragments |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build and run locally
cd destination
dub run

# Run tests
dub test
```

The service starts on port **8094** by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DESTINATION_HOST` | `0.0.0.0` | Bind address |
| `DESTINATION_PORT` | `8094` | Listen port |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
