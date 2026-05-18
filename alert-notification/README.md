# Alert Notification Service

> **UIM Platform — Alert Notification Service**
> A D/vibe.d microservice inspired by [SAP Alert Notification Service for SAP BTP](https://help.sap.com/viewer/product/ALERT_NOTIFICATION/Cloud/en-US).

## Overview

The Alert Notification Service enables applications to **produce** alert events and route them to configured **actions** (email, webhook, Slack, JIRA, etc.) through rule-based **subscriptions** backed by flexible **conditions**.

### Key capabilities

| Capability | Description |
|---|---|
| Event production | POST events via the Producer API |
| Condition evaluation | Filter events by type, category, severity, resource name/type/instance, or tags |
| Action dispatch | Route matched events to EMAIL, SLACK, WEB_HOOK, STORE, PAGER_DUTY, JIRA, SERVICE_NOW, SIEM |
| Subscription management | Combine conditions + actions into named routing rules |
| Consumer pull API | Retrieve STORE-type matched events and undelivered events |
| Health endpoint | Liveness/readiness probe at `/api/v1/health` |

---

## Architecture

The service follows **Clean Architecture + Hexagonal (Ports and Adapters)** principles:

```
source/uim/platform/alert_notification/
├── domain/               # Core business rules (no external dependencies)
│   ├── types.d           # Enums and value-object IDs
│   ├── entities/         # AlertEvent, Condition, Action, Subscription, MatchedEvent, UndeliveredEvent
│   ├── ports/repositories/  # Repository interfaces (inbound ports)
│   └── services/         # EventMatcher, EventDispatcher (domain services)
├── application/          # Use-case orchestration
│   ├── dto.d             # Request/response data transfer objects
│   └── usecases/
│       ├── manage/       # CRUD for conditions, actions, subscriptions
│       ├── produce/      # ProduceEventsUseCase — route incoming events
│       └── consume/      # Pull matched and undelivered events
├── infrastructure/       # Adapters (outbound)
│   ├── config.d          # Environment variable configuration
│   ├── container.d       # Dependency injection wiring
│   └── persistence/memory/  # In-memory repository implementations
└── presentation/
    ├── http/controllers/ # vibe.d HTTP handlers (inbound adapter)
    └── cli/commands/     # CLI stubs
```

---

## API Reference

All paths are prefixed with `/api/v1/alert-notification`. Tenant isolation is provided by the `X-Tenant-Id` request header (defaults to `"default"` when absent).

### Producer API

| Method | Path | Description |
|---|---|---|
| POST | `/events` | Submit an alert event |

**Example request:**
```json
POST /api/v1/alert-notification/events
X-Tenant-Id: my-tenant
Content-Type: application/json

{
  "eventType": "DeploymentFailed",
  "category": "EXCEPTION",
  "severity": "ERROR",
  "subject": "Deployment of app 'orders' failed",
  "body": "Container exit code 1",
  "region": "eu10",
  "affectedResource": {
    "name": "orders",
    "type": "Cloud Foundry Application",
    "instance": "orders-backend-001"
  },
  "tags": { "team": "platform" }
}
```

### Consumer API

| Method | Path | Description |
|---|---|---|
| GET | `/matched-events` | List all stored (matched) events |
| GET | `/matched-events/:id` | Get a specific stored event |
| GET | `/undelivered-events` | List all undelivered events |
| GET | `/undelivered-events/:id` | Get a specific undelivered event |

### Management API — Conditions

| Method | Path | Description |
|---|---|---|
| POST | `/conditions` | Create a condition |
| GET | `/conditions` | List all conditions |
| GET | `/conditions/:id` | Get a condition |
| PUT | `/conditions/:id` | Update a condition |
| DELETE | `/conditions/:id` | Delete a condition |

**Condition propertyKey values:** `eventType`, `eventCategory`, `eventSeverity`, `resourceName`, `resourceType`, `resourceInstance`, `tags`

**Predicate values:** `EQUALS`, `NOT_EQUALS`, `CONTAINS`, `NOT_CONTAINS`, `ANY`

### Management API — Actions

| Method | Path | Description |
|---|---|---|
| POST | `/actions` | Create an action |
| GET | `/actions` | List all actions |
| GET | `/actions/:id` | Get an action |
| PUT | `/actions/:id` | Update an action |
| DELETE | `/actions/:id` | Delete an action |

**Action type values:** `EMAIL`, `SLACK`, `WEB_HOOK`, `STORE`, `PAGER_DUTY`, `JIRA`, `SERVICE_NOW`, `SIEM`

### Management API — Subscriptions

| Method | Path | Description |
|---|---|---|
| POST | `/subscriptions` | Create a subscription |
| GET | `/subscriptions` | List all subscriptions |
| GET | `/subscriptions/:id` | Get a subscription |
| PUT | `/subscriptions/:id` | Update a subscription |
| DELETE | `/subscriptions/:id` | Delete a subscription |

### Health

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/health` | Service health check |

---

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `ALERT_NOTIFICATION_HOST` | `0.0.0.0` | Bind address |
| `ALERT_NOTIFICATION_PORT` | `8095` | HTTP port |
| `ALERT_NOTIFICATION_MAX_EVENTS_BUFFER` | `10000` | Max in-memory events |
| `ALERT_NOTIFICATION_RETENTION_SECONDS` | `604800` | Matched event TTL (7 days) |

---

## Running

### Local (DUB)

```bash
cd alert-notification
dub run
```

### Docker

```bash
docker build -t uim-alert-notification .
docker run -p 8095:8095 uim-alert-notification
```

### Podman

```bash
podman build -t uim-alert-notification -f Containerfile .
podman run -p 8095:8095 uim-alert-notification
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## References

- [SAP Alert Notification Service Documentation](https://help.sap.com/viewer/product/ALERT_NOTIFICATION/Cloud/en-US)
- [SAP ANS Client Library](https://github.com/SAP/clm-sl-alert-notification-client)
- [SAP ANS FSD](https://help.sap.com/doc/2737fa955b6246e0b074bcdea5d690f8/Cloud/en-US/FSD_Alert_Notification_Service_en.pdf)
