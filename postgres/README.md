# PostgreSQL on SAP BTP, Hyperscaler Option — UIM Platform Service

A managed **PostgreSQL** database service for SAP BTP, Hyperscaler Option, built with [D language](https://dlang.org/) and [vibe.d](https://vibed.org/), implementing **Hexagonal Architecture** (Ports & Adapters) combined with **Clean Architecture** layering.

## Overview

This service mirrors the **PostgreSQL (postgresql-db)** offering on SAP BTP that provides managed PostgreSQL databases backed by hyperscaler infrastructure (AWS, Azure, GCP, Alibaba Cloud).

### Service Plans

| Plan     | Description                          | Multi-AZ | Max Memory |
|----------|--------------------------------------|----------|-----------|
| standard | Standard PostgreSQL service offering | Optional | 64 GB     |
| premium  | Premium PostgreSQL service offering  | Required | 512 GB    |

### Domain Entities

| Entity             | Description                                              |
|--------------------|----------------------------------------------------------|
| ServiceInstance    | A PostgreSQL database instance with version, memory, storage |
| ServiceBinding     | Credentials binding to an application                    |
| ServicePlan        | Available service plans (standard / premium)             |
| Configuration      | Instance-level settings: audit log, parameters, locale   |
| BackupPolicy       | Backup retention, scheduling and status                  |
| DatabaseUser       | PostgreSQL users and their roles on an instance          |
| DatabaseExtension  | PostgreSQL extensions enabled on an instance             |
| MaintenanceWindow  | Planned maintenance schedules                            |

## Architecture

```
postgres/
├── source/
│   ├── app.d                        # Entry point
│   └── uim/platform/postgres/
│       ├── package.d
│       ├── domain/                  # Business logic (no framework dependencies)
│       │   ├── types.d              # Value-object ID types
│       │   ├── enumerations.d       # Domain enums
│       │   ├── entities/            # Domain entities (structs with toJson)
│       │   ├── repositories/        # Port interfaces
│       │   └── services/            # Domain services
│       ├── application/             # Use cases & DTOs
│       │   ├── dto.d
│       │   └── usecases/manage/
│       ├── presentation/
│       │   ├── http/                # REST API controllers
│       │   ├── cli/                 # CLI MVC (model/view/controller)
│       │   ├── web/                 # Web MVC (HTML, model/view/controller)
│       │   └── gui/                 # GUI MVC (Json widget-tree descriptors)
│       └── infrastructure/
│           ├── config.d
│           ├── container.d          # Dependency injection
│           └── persistence/
│               ├── memory/          # In-memory repositories
│               ├── file/            # File-based JSON repositories
│               └── mongodb/         # MongoDB repositories
├── Dockerfile
├── Containerfile
└── k8s/
    ├── deployment.yaml
    ├── service.yaml
    └── configmap.yaml
```

## API Endpoints

| Method | Path                                  | Description                         |
|--------|---------------------------------------|-------------------------------------|
| GET    | /api/v1/postgres/instances            | List all service instances          |
| POST   | /api/v1/postgres/instances            | Create a new service instance       |
| GET    | /api/v1/postgres/instances/:id        | Get a service instance              |
| PUT    | /api/v1/postgres/instances/:id        | Update a service instance           |
| DELETE | /api/v1/postgres/instances/:id        | Delete a service instance           |
| GET    | /api/v1/postgres/bindings             | List all service bindings           |
| POST   | /api/v1/postgres/bindings             | Create a service binding            |
| GET    | /api/v1/postgres/bindings/:id         | Get a service binding               |
| DELETE | /api/v1/postgres/bindings/:id         | Delete a service binding            |
| GET    | /api/v1/postgres/plans                | List service plans                  |
| GET    | /api/v1/postgres/configurations       | List configurations                 |
| POST   | /api/v1/postgres/configurations       | Create configuration                |
| GET    | /api/v1/postgres/backup-policies      | List backup policies                |
| GET    | /api/v1/postgres/db-users             | List database users                 |
| POST   | /api/v1/postgres/db-users             | Create database user                |
| GET    | /api/v1/postgres/extensions           | List extensions                     |
| POST   | /api/v1/postgres/extensions           | Enable extension                    |
| GET    | /api/v1/postgres/maintenance-windows  | List maintenance windows            |
| GET    | /health                               | Health check                        |

## Configuration

| Environment Variable       | Default                    | Description                        |
|----------------------------|----------------------------|------------------------------------|
| POSTGRES_HOST              | 0.0.0.0                    | Listen host                        |
| POSTGRES_PORT              | 8131                       | Listen port                        |
| POSTGRES_PERSISTENCE       | memory                     | Backend: memory / file / mongodb   |
| POSTGRES_FILE_PATH         | ./data                     | Base path for file persistence     |
| POSTGRES_MONGODB_URI       | mongodb://localhost:27017  | MongoDB connection URI             |
| POSTGRES_MONGODB_DB        | postgres                   | MongoDB database name              |

## Running Locally

```bash
dub run -- # starts on 0.0.0.0:8131
```

## Docker / Podman

```bash
docker build -t uim-postgres-platform-service .
docker run -p 8131:8131 uim-postgres-platform-service
# or with Podman:
podman build -t uim-postgres-platform-service .
podman run -p 8131:8131 uim-postgres-platform-service
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Instance Creation Example

```json
POST /api/v1/postgres/instances
{
  "name": "my-pg-instance",
  "planId": "standard",
  "engineVersion": "15",
  "memory": 4,
  "storage": 100,
  "multiAz": true,
  "region": "eu-central-1",
  "hyperscaler": "aws"
}
```

## References

- [PostgreSQL on SAP BTP, Hyperscaler Option](https://help.sap.com/viewer/product/PostgreSQL/Cloud/en-US)
- [Provision PostgreSQL](https://help.sap.com/viewer/b3fe3621fa4a4ed28d7bbe3d6d88f036/Cloud/en-US/2df35cb1c431436cb54ae2467571a031.html)
- [Feature Scope Description](https://help.sap.com/doc/937fff80a94e413681298439b201e5f7/Cloud/en-US/FSD_PostgreSQL.pdf)
