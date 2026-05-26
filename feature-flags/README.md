# UIM Platform — Feature Flags Service

A SAP BTP Feature Flags-compatible microservice built with **D** and **vibe.d**, following **Hexagonal Architecture** (Ports & Adapters) and **MVC** patterns across HTTP, CLI, Web and GUI presentation layers.

---

## Overview

The Feature Flags service allows developers and platform operators to manage and evaluate **feature flags** (feature toggles) without redeploying applications. It mirrors the behaviour documented in the [SAP BTP Feature Flags Service](https://help.sap.com/viewer/p/FEATURE_FLAGS).

### Core Capabilities

| Feature | Description |
|---|---|
| **Flag Management** | CRUD for feature flags with type, state, variants and targeting rules |
| **Service Instances** | Group flags per bound application (SAP BTP service-instance model) |
| **Evaluation API** | Single-flag and bulk evaluation with context (userId, tenantId, attributes) |
| **Targeting Rules** | User match, tenant match, percentage rollout, attribute match |
| **Flag Types** | `BOOLEAN`, `STRING`, `JSON`, `NUMBER` |
| **Flag States** | `ENABLED`, `DISABLED`, `ARCHIVED` |
| **Audit Log** | Immutable per-tenant audit trail of every management operation |
| **Multi-backend Storage** | In-memory, file-system (JSON/NDJSON), MongoDB |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Presentation Layer (MVC)                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌────────┐  ┌──────────┐  │
│  │ HTTP REST API│  │  Web Views   │  │  CLI   │  │  GUI     │  │
│  │ (vibe.d)     │  │  (vibe.d)    │  │ Cmds   │  │ Widgets  │  │
│  └──────┬───────┘  └──────┬───────┘  └───┬────┘  └────┬─────┘  │
├─────────┼─────────────────┼──────────────┼─────────────┼────────┤
│  Application Layer (Use Cases)                                   │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  ManageFeatureFlagsUseCase  │  EvaluateFlagsUseCase      │    │
│  │  ManageServiceInstancesUseCase                           │    │
│  └──────────────────────────┬───────────────────────────────┘    │
├───────────────────────────── ┼ ────────────────────────────────  │
│  Domain Layer                │                                   │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  Entities: FeatureFlag, FlagVariant, TargetingRule,      │    │
│  │           ServiceInstance, AuditEntry                    │    │
│  │  Ports: FeatureFlagRepository, ServiceInstanceRepository │    │
│  │         AuditEntryRepository                             │    │
│  │  Services: FlagEvaluator (pure domain logic)             │    │
│  └──────────────────────────┬───────────────────────────────┘    │
├─────────────────────────────┼───────────────────────────────────┤
│  Infrastructure Layer        │                                   │
│  ┌───────────┐  ┌──────────┐  ┌──────────────────────────────┐  │
│  │  Memory   │  │  File    │  │  MongoDB (stub+fallback)      │  │
│  │  Repos    │  │  Repos   │  │  Repos                       │  │
│  └───────────┘  └──────────┘  └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## API Reference

### Health

```
GET /api/v1/health
```

### Service Instances

```
GET    /api/v1/feature-flags/instances           # list all instances
POST   /api/v1/feature-flags/instances           # create instance
GET    /api/v1/feature-flags/instances/:id       # get instance
PUT    /api/v1/feature-flags/instances/:id       # update instance
DELETE /api/v1/feature-flags/instances/:id       # delete instance
```

### Feature Flags

```
GET    /api/v1/feature-flags/flags               # list all flags (query: tenantId, instanceId)
POST   /api/v1/feature-flags/flags               # create flag
GET    /api/v1/feature-flags/flags/:id           # get flag
PUT    /api/v1/feature-flags/flags/:id           # update flag (variants, rules, description)
PATCH  /api/v1/feature-flags/flags/:id           # state transition (ENABLED|DISABLED|ARCHIVED)
DELETE /api/v1/feature-flags/flags/:id           # delete flag
```

### Evaluation

```
GET /api/v1/feature-flags/evaluate/:flagName     # evaluate single flag
    ?instanceId=...&tenantId=...&userId=...&attr_{key}=value

GET /api/v1/feature-flags/evaluate               # evaluate all flags (bulk)
    ?instanceId=...&tenantId=...&userId=...
```

### Evaluation Response

```json
{
  "flagName": "dark-mode",
  "variantKey": "on",
  "variantValue": "true",
  "type": "BOOLEAN",
  "enabled": true,
  "reason": "RULE_MATCH"
}
```

Reason values: `DEFAULT`, `RULE_MATCH`, `DISABLED`, `ARCHIVED`, `UNKNOWN_FLAG`

---

## Create a Flag (example)

```bash
curl -X POST http://localhost:8097/api/v1/feature-flags/flags \
  -H "Content-Type: application/json" \
  -d '{
    "name": "dark-mode",
    "description": "Enables dark mode for beta users",
    "type": "BOOLEAN",
    "instanceId": "my-app-instance",
    "defaultVariant": "off",
    "variants": [
      { "key": "on",  "name": "On",  "value": "true",  "weight": 0 },
      { "key": "off", "name": "Off", "value": "false", "weight": 0 }
    ],
    "rules": [
      {
        "name": "Beta users",
        "type": "USER_MATCH",
        "variantKey": "on",
        "priority": 1,
        "targetIds": ["user-123", "user-456"]
      },
      {
        "name": "10% rollout",
        "type": "PERCENTAGE_ROLLOUT",
        "variantKey": "on",
        "priority": 2,
        "rolloutPercentage": 10
      }
    ],
    "createdBy": "admin"
  }'
```

## Evaluate a Flag

```bash
curl "http://localhost:8097/api/v1/feature-flags/evaluate/dark-mode\
?instanceId=my-app-instance&tenantId=tenant-1&userId=user-123"
```

---

## Configuration (Environment Variables)

| Variable | Default | Description |
|---|---|---|
| `FEATURE_FLAGS_HOST` | `0.0.0.0` | Bind address |
| `FEATURE_FLAGS_PORT` | `8097` | Listen port |
| `FEATURE_FLAGS_SERVICE_NAME` | `Feature Flags Service` | Display name |
| `FEATURE_FLAGS_STORAGE_BACKEND` | `MEMORY` | `MEMORY`, `FILE`, `MONGODB` |
| `FEATURE_FLAGS_FILE_PATH` | `/data/feature-flags` | Base dir for file backend |
| `FEATURE_FLAGS_MONGO_URI` | `mongodb://localhost:27017` | MongoDB connection string |
| `FEATURE_FLAGS_MONGO_DB` | `feature_flags` | MongoDB database name |

---

## Build & Run

### Local (dub)

```bash
cd feature-flags
dub run --config=defaultRun
```

### Docker

```bash
# Build from repo root
docker build -f feature-flags/Dockerfile -t uim-feature-flags-platform-service:latest .
docker run -p 8097:8097 uim-feature-flags-platform-service:latest
```

### Podman

```bash
podman build -f feature-flags/Containerfile -t uim-feature-flags-platform-service:latest .
podman run -p 8097:8097 uim-feature-flags-platform-service:latest
```

### Kubernetes

```bash
kubectl apply -f feature-flags/k8s/configmap.yaml
kubectl apply -f feature-flags/k8s/deployment.yaml
kubectl apply -f feature-flags/k8s/service.yaml
```

---

## Storage Backends

### Memory (default)
All data lives in process memory. Cleared on restart. Ideal for development and testing.

### File
Each flag and service instance is stored as a pretty-printed JSON file under `FEATURE_FLAGS_FILE_PATH/{tenantId}/{id}.json`. Audit entries are appended as NDJSON to `_audit/{tenantId}/audit.ndjson`.

### MongoDB
Falls back to in-memory until a real `vibe-d:mongo` integration is wired (see `infrastructure/persistence/mongodb_/` — the `TODO` comments). Wire up by adding `dependency "vibe-d:mongo"` to dub.sdl and implementing the collection queries.

---

## License

Apache-2.0 — Copyright 2018-2026 Ozan Nurettin Süel (UI-Manufaktur UG)
