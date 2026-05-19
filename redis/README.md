# Redis on SAP BTP, Hyperscaler Option — UIM Platform Service

A D/vibe.d microservice implementing the **Redis on SAP BTP, Hyperscaler Option** feature set, following **clean + hexagonal architecture** with a full MVC presentation stack and multi-backend persistence.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Domain Model](#domain-model)
- [Persistence Backends](#persistence-backends)
- [Presentation Layers](#presentation-layers)
- [API Reference](#api-reference)
- [Configuration](#configuration)
- [Running Locally](#running-locally)
- [Docker / Podman](#docker--podman)
- [Kubernetes](#kubernetes)
- [Development](#development)

---

## Overview

This service models the lifecycle management of **Redis cache instances** on SAP BTP hyperscalers (AWS ElastiCache, Azure Cache for Redis, GCP Memorystore, AliCloud ApsaraDB for Redis).  
It provides:
- Service instance provisioning and management
- Service binding / credential management
- Service plan catalogue
- Per-instance configuration (eviction policies, TLS, persistence mode)
- Cache entry management (key–value, hash, list, set, sorted set, stream, bitmap)
- Operational metrics
- Backup policy management
- Network access control

---

## Features

| Feature | Description |
|---|---|
| **Instance Lifecycle** | Provision, update, and delete Redis instances |
| **Service Binding** | Bind instances to applications; credential rotation |
| **Flexible Plans** | Free / Basic / Standard / Premium with HA and persistence options |
| **Configuration** | Per-instance eviction policy, max-memory, TLS, keyspace events |
| **Cache Entry API** | Manage key–value data of all Redis data types |
| **Metrics** | Memory usage, connected clients, hit rate, evictions |
| **Backup Policies** | Schedule-based RDB/AOF backup with retention |
| **Access Control** | IP allowlist / deny-list per instance |
| **High Availability** | Multi-AZ replica configuration |
| **TLS** | In-transit encryption support |
| **Multi-Hyperscaler** | AWS, Azure, GCP, AliCloud |

---

## Architecture

```
redis/
├── source/
│   ├── app.d                           # Entry point
│   └── uim/platform/redis/
│       ├── package.d
│       ├── domain/                     # Core business logic (no external deps)
│       │   ├── enumerations.d
│       │   ├── types.d
│       │   ├── entities/               # Aggregate roots & value objects
│       │   ├── repositories/           # Repository interfaces (ports)
│       │   └── services/               # Domain services (validation)
│       ├── application/                # Use-case orchestration
│       │   ├── dto.d
│       │   └── usecases/manage/        # One use-case class per aggregate
│       ├── presentation/
│       │   ├── http/controllers/       # REST API (vibe.d URLRouter)
│       │   ├── cli/                    # CLI MVC (models / views / controllers)
│       │   ├── web/                    # Web MVC (models / views / controllers)
│       │   └── gui/                    # GUI MVC (models / views / controllers)
│       └── infrastructure/
│           ├── config.d
│           ├── container.d             # Dependency-injection wiring
│           └── persistence/
│               ├── memory/             # In-memory (default, test-friendly)
│               ├── file/               # JSON file store (development)
│               └── mongodb/            # MongoDB (production)
├── Dockerfile
├── Containerfile
├── dub.sdl
└── k8s/
    ├── deployment.yaml
    ├── service.yaml
    └── configmap.yaml
```

### Hexagonal Architecture

```
                        [ CLI / Web / GUI / HTTP ]
                                   │
                          Presentation Layer
                                   │
                          Application Layer (Use Cases)
                                   │
                             Domain Layer ◄──── Domain Services
                                   │
                         Infrastructure Layer
                   (Memory │ File │ MongoDB repositories)
```

Dependency rule: outer layers depend on inner layers; domain has **zero** infrastructure imports.

---

## Domain Model

| Entity | Key Fields |
|---|---|
| `ServiceInstance` | id, tenantId, name, planId, status, hyperscaler, region, redisVersion, memoryMb, tlsEnabled, haEnabled |
| `ServiceBinding` | id, tenantId, instanceId, appId, credentials (host, port, password, tls) |
| `ServicePlan` | id, name, tier, memoryMb, maxConnections, haEnabled, persistenceEnabled |
| `Configuration` | id, instanceId, maxMemoryPolicy, timeout, tlsEnabled, persistenceMode |
| `CacheEntry` | id, instanceId, key, value, entryType, ttl |
| `Metric` | id, instanceId, timestamp, memoryUsedMb, hitRate, commandsPerSecond |
| `BackupPolicy` | id, instanceId, schedule, retentionDays, storageLocation, status |
| `AccessControl` | id, instanceId, cidrBlock, direction, action |

---

## Persistence Backends

| Backend | Module | Use Case |
|---|---|---|
| **Memory** | `infrastructure.persistence.memory` | Tests, quick demos |
| **File** | `infrastructure.persistence.file` | Development, single-node |
| **MongoDB** | `infrastructure.persistence.mongodb` | Production deployments |

Switch backend by changing the repository implementations wired in `infrastructure/container.d`.

---

## Presentation Layers

### HTTP REST (`presentation/http`)
Full CRUD REST API for every domain entity. See [API Reference](#api-reference).

### CLI MVC (`presentation/cli`)
Model–View–Controller for terminal/script interaction. Controllers parse `string[]` args, use cases provide data, views render formatted text.

### Web MVC (`presentation/web`)
Model–View–Controller for a web UI rendered via vibe.d web routes. Controllers handle `HTTPServerRequest`/`HTTPServerResponse`, views emit HTML, models carry display state.

### GUI MVC (`presentation/gui`)
Model–View–Controller scaffold for a desktop/embedded GUI toolkit. Controllers dispatch commands, views render widget trees, models hold observable state.

---

## API Reference

### Service Instances
| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/redis/instances` | List all instances |
| POST | `/api/v1/redis/instances` | Create instance |
| GET | `/api/v1/redis/instances/:id` | Get instance |
| PUT | `/api/v1/redis/instances/:id` | Update instance |
| DELETE | `/api/v1/redis/instances/:id` | Delete instance |

### Service Bindings
| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/redis/bindings` | List bindings |
| POST | `/api/v1/redis/bindings` | Create binding |
| GET | `/api/v1/redis/bindings/:id` | Get binding |
| DELETE | `/api/v1/redis/bindings/:id` | Delete binding |

### Service Plans
| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/redis/plans` | List plans |
| POST | `/api/v1/redis/plans` | Create plan |
| GET | `/api/v1/redis/plans/:id` | Get plan |
| PUT | `/api/v1/redis/plans/:id` | Update plan |
| DELETE | `/api/v1/redis/plans/:id` | Delete plan |

### Configurations
`/api/v1/redis/configurations` — GET, POST, GET/:id, PUT/:id, DELETE/:id

### Cache Entries
`/api/v1/redis/cache-entries` — GET, POST, GET/:id, PUT/:id, DELETE/:id

### Metrics
`/api/v1/redis/metrics` — GET, POST, GET/:id, DELETE/:id

### Backup Policies
`/api/v1/redis/backup-policies` — GET, POST, GET/:id, PUT/:id, DELETE/:id

### Access Controls
`/api/v1/redis/access-controls` — GET, POST, GET/:id, PUT/:id, DELETE/:id

### Health
| Method | Path | Description |
|---|---|---|
| GET | `/health` | Liveness / readiness probe |

---

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `REDIS_HOST` | `0.0.0.0` | Bind host |
| `REDIS_PORT` | `8130` | Listen port |
| `REDIS_PERSISTENCE` | `memory` | `memory` / `file` / `mongodb` |
| `REDIS_FILE_PATH` | `./data` | Data directory for file persistence |
| `REDIS_MONGODB_URI` | `mongodb://localhost:27017` | MongoDB connection URI |
| `REDIS_MONGODB_DB` | `redis_platform` | MongoDB database name |

---

## Running Locally

```bash
# Build
dub build --config=defaultRun

# Run (in-memory persistence)
./uim-redis-platform-service

# Run (file persistence)
REDIS_PERSISTENCE=file REDIS_FILE_PATH=/tmp/redis-data ./uim-redis-platform-service

# Run (mongodb persistence)
REDIS_PERSISTENCE=mongodb REDIS_MONGODB_URI=mongodb://localhost:27017 ./uim-redis-platform-service

# Run tests
dub test
```

---

## Docker / Podman

```bash
# Build image (Docker)
docker build -t uim-redis-platform-service:latest .

# Build image (Podman)
podman build -t uim-redis-platform-service:latest -f Containerfile .

# Run container
docker run -d \
  -p 8130:8130 \
  -e REDIS_HOST=0.0.0.0 \
  -e REDIS_PORT=8130 \
  uim-redis-platform-service:latest

# Run with MongoDB backend
docker run -d \
  -p 8130:8130 \
  -e REDIS_PERSISTENCE=mongodb \
  -e REDIS_MONGODB_URI=mongodb://mongo:27017 \
  uim-redis-platform-service:latest
```

---

## Kubernetes

```bash
# Apply all manifests
kubectl apply -f k8s/

# Check deployment
kubectl get pods -l app=uim-redis-platform-service

# Check logs
kubectl logs -l app=uim-redis-platform-service
```

The k8s manifests deploy the service on port 8130 with a `ClusterIP` service and a `ConfigMap` for environment configuration.

---

## Development

```bash
# Run in verbose mode (all debug versions)
dub run --config=verbose

# Run with module visibility
dub run --config=modules
```

### Adding a New Persistence Backend
1. Create `infrastructure/persistence/<backend>/` directory
2. Implement each repository interface from `domain/repositories/`
3. Wire new repository implementations in `infrastructure/container.d`

### Switching Backends at Runtime
Update `buildContainer()` in `infrastructure/container.d` to read `REDIS_PERSISTENCE` and select the appropriate repository implementations.
