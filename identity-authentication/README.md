# Identity Authentication Service

A D/vibe.d microservice implementing SAP Cloud Identity Services — Authentication (IAS)-like functionality for the UIM Platform. Provides authentication flows, user and group management, application registration, tenant configuration, and policy enforcement.

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

- **Domain**: Users, groups, applications, tenants, policies, sessions, tokens, identity provider configurations, risk rules
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, JWT-based token handling, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Authentication** — Login flow and token issuance (JWT-based)
- **Users** — User lifecycle management with profile attributes and group membership
- **Groups** — Group management for role-based access control
- **Applications** — Register and configure OIDC/SAML applications
- **Tenants** — Multi-tenant configuration management
- **Policies** — Authentication and password policies including MFA settings
- **Identity Providers** — Configure external identity providers (IdP)
- **Risk Rules** — Define risk-based authentication rules

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/auth/login` | Authenticate a user |
| POST | `/api/v1/auth/token` | Issue/refresh an access token |
| GET | `/api/v1/auth/health` | Authentication health check |
| CRUD | `/api/v1/users` | Manage users |
| CRUD | `/api/v1/groups` | Manage groups |
| CRUD | `/api/v1/applications` | Manage registered applications |
| CRUD | `/api/v1/tenants` | Manage tenants |
| CRUD | `/api/v1/policies` | Manage authentication policies |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build and run locally
cd identity-authentication
dub run

# Run tests
dub test
```

The service starts on port **8080** by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `IAS_HOST` | `0.0.0.0` | Bind address |
| `IAS_PORT` | `8080` | Listen port |
| `IAS_JWT_SECRET` | _(empty)_ | Secret key for JWT token signing |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
