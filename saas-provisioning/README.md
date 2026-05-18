# SAP SaaS Provisioning Service

A D/vibe.d implementation of the SAP BTP SaaS Provisioning service, following Clean Architecture combined with Hexagonal (Ports and Adapters) principles.

## Overview

The SaaS Provisioning service enables SaaS application providers to register their multitenant applications and manage tenant subscriptions on SAP Business Technology Platform (SAP BTP). It provides subscription lifecycle management, tenant onboarding/offboarding, and job tracking for asynchronous operations.

## Features

- **Application Registration**: Register and manage multitenant SaaS applications with metadata, URLs, and subscription plans
- **Subscription Management**: Subscribe and unsubscribe tenants (subaccounts) to/from SaaS applications
- **Job Tracking**: Track asynchronous subscription/unsubscription jobs with status and progress
- **Multi-tenant Support**: Full tenant isolation for all data and operations
- **Health Check**: Kubernetes-ready liveness and readiness probes

## Architecture

The service implements a combination of Clean Architecture and Hexagonal Architecture:

```
presentation/   ← HTTP controllers, CLI, GUI, Web adapters
    └── http/controllers/
infrastructure/ ← Concrete implementations (in-memory repos, config)
    └── persistence/memory/
application/    ← Use cases, DTOs
    └── usecases/manage/
domain/         ← Entities, ports (interfaces), value objects, services
    ├── entities/
    ├── ports/repositories/
    └── services/
```

## API Endpoints

### Applications

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/saas-provisioning/applications` | List all registered SaaS applications |
| POST | `/api/v1/saas-provisioning/applications` | Register a new SaaS application |
| GET | `/api/v1/saas-provisioning/applications/:id` | Get a specific SaaS application |
| PUT | `/api/v1/saas-provisioning/applications/:id` | Update a SaaS application |
| DELETE | `/api/v1/saas-provisioning/applications/:id` | Deregister a SaaS application |

### Subscriptions

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/saas-provisioning/subscriptions` | List subscriptions (filter by `?appName=`) |
| POST | `/api/v1/saas-provisioning/subscriptions` | Subscribe a tenant to a SaaS app |
| GET | `/api/v1/saas-provisioning/subscriptions/:id` | Get a specific subscription |
| PUT | `/api/v1/saas-provisioning/subscriptions/:id` | Update a subscription |
| DELETE | `/api/v1/saas-provisioning/subscriptions/:id` | Unsubscribe a tenant |

### Jobs

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/saas-provisioning/jobs` | List all subscription jobs |
| GET | `/api/v1/saas-provisioning/jobs/:id` | Get a specific job |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Health check endpoint |

## Configuration

| Environment Variable | Default | Description |
|----------------------|---------|-------------|
| `SAAS_PROVISIONING_HOST` | `0.0.0.0` | Bind address |
| `SAAS_PROVISIONING_PORT` | `8096` | Listen port |

## Building

### Prerequisites

- D compiler (LDC recommended)
- DUB package manager

### Local Build

```bash
cd saas-provisioning
dub build
```

### Run

```bash
dub run
# or
./build/uim-saas-provisioning-platform-service
```

### Test

```bash
dub test
```

## Container

### Docker / Podman

```bash
# Build
docker build -t uim-saas-provisioning:latest .
# or
podman build -t uim-saas-provisioning:latest .

# Run
docker run -p 8096:8096 uim-saas-provisioning:latest
# or
podman run -p 8096:8096 uim-saas-provisioning:latest
```

### Containerfile (Podman-native)

```bash
podman build -f Containerfile -t uim-saas-provisioning:latest .
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Domain Model

### Entities

- **SaasApplication** — Registered multitenant SaaS application with metadata, URLs, plan, and status
- **AppSubscription** — Tenant subscription to a SaaS application with lifecycle state
- **SubscriptionJob** — Asynchronous job tracking subscribe/unsubscribe operations

### Value Objects / Enums

- `AppRegistrationStatus` — `pending`, `registered`, `updating`, `deregistering`, `error`
- `SubscriptionState` — `in_process`, `subscribed`, `subscribe_failed`, `unsubscribe_failed`, `not_subscribed`
- `JobType` — `subscribe`, `unsubscribe`, `update`
- `JobStatus` — `in_progress`, `succeeded`, `failed`
- `AppPlan` — `standard`, `professional`, `enterprise`

## License

Apache 2.0 — see [LICENSE](../LICENSE)
