# Cloud Management Service

A D/vibe.d microservice implementing SAP BTP Cloud Management Service-like functionality for the UIM Platform. Provides global account hierarchy management, directory and subaccount administration, entitlements, environment provisioning, SaaS subscriptions, service catalogue, resource labels, and platform event streaming.

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

- **Domain**: Global accounts, directories, subaccounts, entitlements, environment instances, subscriptions, service plans, labels, platform events
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Global Accounts** — Manage the root global account with suspend/reactivate lifecycle
- **Directories** — Create hierarchical account directories for organisational grouping
- **Subaccounts** — Provision and manage subaccounts with move, suspend, and reactivate operations
- **Entitlements** — Assign and revoke service entitlements across the account hierarchy
- **Environment Instances** — Provision and deprovision runtime environment instances (Cloud Foundry, Kyma)
- **Subscriptions** — Manage SaaS application subscriptions with unsubscribe support
- **Service Plans** — Browse the service and plan catalogue
- **Labels** — Manage custom labels for resource tagging and discovery
- **Platform Events** — Stream platform lifecycle events for monitoring and automation
- **Overview** — Aggregated account hierarchy and usage overview

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/accounts` | Manage global accounts |
| POST | `/api/v1/accounts/suspend/{id}` | Suspend a global account |
| POST | `/api/v1/accounts/reactivate/{id}` | Reactivate a global account |
| CRUD | `/api/v1/directories` | Manage directories |
| CRUD | `/api/v1/subaccounts` | Manage subaccounts |
| POST | `/api/v1/subaccounts/move/{id}` | Move a subaccount |
| POST | `/api/v1/subaccounts/suspend/{id}` | Suspend a subaccount |
| POST | `/api/v1/subaccounts/reactivate/{id}` | Reactivate a subaccount |
| CRUD | `/api/v1/entitlements` | Manage service entitlements |
| POST | `/api/v1/entitlements/revoke/{id}` | Revoke an entitlement |
| CRUD | `/api/v1/environments` | Manage environment instances |
| POST | `/api/v1/environments/deprovision/{id}` | Deprovision an environment instance |
| CRUD | `/api/v1/subscriptions` | Manage SaaS subscriptions |
| POST | `/api/v1/subscriptions/unsubscribe/{id}` | Unsubscribe from a SaaS application |
| CRUD | `/api/v1/service-plans` | Browse the service catalogue |
| CRUD | `/api/v1/labels` | Manage resource labels |
| GET | `/api/v1/events` | Stream platform events |
| GET | `/api/v1/overview` | Get account overview |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd management
dub run

# Run tests
dub test
```

The service starts on port **8098** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MANAGEMENT_HOST` | `0.0.0.0` | Bind address |
| `MANAGEMENT_PORT` | `8098` | Listen port |

## License

Apache-2.0
