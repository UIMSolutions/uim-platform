# Monitoring Service

A D/vibe.d microservice implementing cloud platform monitoring functionality for the UIM Platform. Provides resource monitoring, metric ingestion and querying, health checks, alerting rules, alert management, notification channels, and a monitoring dashboard.

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

- **Domain**: Monitored resources, metrics, metric definitions, health checks, health check results, alert rules, alerts, notification channels
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Resources** — Register and manage monitored platform resources
- **Metrics** — Ingest time-series metrics with batch ingestion support and summary views
- **Metric Definitions** — Define metric schemas, units, and threshold configurations
- **Health Checks** — Configure health checks for monitored resources with result tracking
- **Alert Rules** — Define threshold-based alert rules linked to metric definitions
- **Alerts** — View, acknowledge, and resolve triggered alerts
- **Notification Channels** — Configure email, webhook, or Slack channels for alert delivery
- **Dashboard** — Aggregated platform monitoring dashboard view

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/resources` | Manage monitored resources |
| POST/GET | `/api/v1/metrics` | Ingest and query metrics |
| POST | `/api/v1/metrics/batch` | Batch-ingest metrics |
| GET | `/api/v1/metrics/summary` | Get metrics summary |
| CRUD | `/api/v1/metric-definitions` | Manage metric definitions |
| CRUD | `/api/v1/checks` | Manage health checks |
| POST | `/api/v1/checks/results` | Submit health check results |
| GET | `/api/v1/checks/results/{checkId}` | Get results for a health check |
| CRUD | `/api/v1/alert-rules` | Manage alert rules |
| GET | `/api/v1/alerts` | List active alerts |
| POST | `/api/v1/alerts/acknowledge` | Acknowledge an alert |
| POST | `/api/v1/alerts/resolve` | Resolve an alert |
| CRUD | `/api/v1/channels` | Manage notification channels |
| GET | `/api/v1/dashboard` | Get monitoring dashboard |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build and run locally
cd monitoring
dub run

# Run tests
dub test
```

The service starts on port **8093** by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MONITORING_HOST` | `0.0.0.0` | Bind address |
| `MONITORING_PORT` | `8093` | Listen port |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
