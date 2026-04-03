# Cloud Logging Service

A cloud logging service for the UIM Platform, inspired by the SAP Cloud Logging Service for SAP BTP. Built with D language (dlang), vibe.d HTTP framework, and clean/hexagonal architecture.

## Features

- **Log Ingestion** - Structured log ingestion via REST API (single and batch)
- **Distributed Tracing** - Span-based trace collection and correlation
- **Search and Query** - Full-text search across logs with filtering by level, stream, trace, time range
- **Log Streams** - Organize logs into named streams with configurable routing
- **Dashboards** - Custom dashboards with configurable panels (charts, tables, counters)
- **Retention Policies** - Configurable data retention per data type (logs, traces, metrics)
- **Alert Rules** - Pattern-based alerting with contains, regex, threshold, and absence conditions
- **Alert Management** - Alert lifecycle (open, acknowledge, resolve) with notification
- **Notification Channels** - Email, webhook, and Slack notification targets
- **Ingestion Pipelines** - Configurable data processing pipelines with transform processors
- **Health Monitoring** - Health check endpoint for container orchestration

## Architecture

```
Clean Architecture + Hexagonal Architecture (Ports and Adapters)

Domain Layer (innermost)
  - Entities: LogEntry, LogStream, Span, Dashboard, RetentionPolicy,
              AlertRule, Alert, NotificationChannel, Pipeline, IngestionToken
  - Ports: Repository interfaces (driven adapter contracts)
  - Services: LogParser, RetentionEvaluator, PatternMatcher

Application Layer
  - DTOs: Request/Response data transfer objects
  - Use Cases: IngestLogs, IngestTraces, SearchLogs, ManageLogStreams,
               ManageDashboards, ManageRetentionPolicies, ManageAlertRules,
               ManageAlerts, ManageNotificationChannels, ManagePipelines,
               GetOverview

Infrastructure Layer
  - Config: Environment-based configuration
  - Container: Dependency injection wiring
  - Persistence: In-memory repository implementations

Presentation Layer (outermost)
  - HTTP Controllers: vibe.d REST API handlers
  - JSON Utils: Serialization helpers
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/logs` | Ingest a single log entry |
| POST | `/api/v1/logs/batch` | Ingest a batch of log entries |
| GET | `/api/v1/logs/{id}` | Get log entry by ID |
| POST | `/api/v1/traces/spans` | Ingest a single span |
| POST | `/api/v1/traces/spans/batch` | Ingest a batch of spans |
| GET | `/api/v1/traces/{traceId}` | Get all spans for a trace |
| GET | `/api/v1/search?q=...` | Search logs with filters |
| CRUD | `/api/v1/streams` | Manage log streams |
| CRUD | `/api/v1/dashboards` | Manage dashboards |
| CRUD | `/api/v1/retention` | Manage retention policies |
| CRUD | `/api/v1/alert-rules` | Manage alert rules |
| GET | `/api/v1/alerts` | List alerts |
| POST | `/api/v1/alerts/acknowledge` | Acknowledge an alert |
| POST | `/api/v1/alerts/resolve` | Resolve an alert |
| CRUD | `/api/v1/channels` | Manage notification channels |
| CRUD | `/api/v1/pipelines` | Manage ingestion pipelines |
| GET | `/api/v1/overview` | Get system overview summary |
| GET | `/api/v1/health` | Health check |

All endpoints expect `X-Tenant-Id` header for multi-tenancy.

## Build

```bash
# Build
dub build --config=defaultRun

# Run
./build/uim-logging-platform-service

# Test
dub test
```

## Container

```bash
# Docker
docker build -t uim-platform/cloud-logging:latest .
docker run -p 8094:8094 uim-platform/cloud-logging:latest

# Podman
podman build -f Containerfile -t uim-platform/cloud-logging:latest .
podman run -p 8094:8094 uim-platform/cloud-logging:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `LOGGING_HOST` | `0.0.0.0` | Bind address |
| `LOGGING_PORT` | `8094` | Listen port |

## License

Apache 2.0 - See [LICENSE](../LICENSE) for details.
