# HANA Cloud Service

A SAP BTP-style HANA Cloud management service built with D, vibe-d, and uim-framework using hexagonal (clean) architecture.

## Features

- **Instance Management** — Create, start, stop, update, and delete SAP HANA Cloud database instances with configurable size, region, and networking
- **Data Lake** — Manage HANA Data Lake instances with hot/warm/cold storage tiers and multi-format support (Parquet, CSV, ORC, JSON, Avro)
- **Schema Management** — Create and manage database schemas (standard, HDI, virtual, system, temporary)
- **Database Users** — Full user lifecycle with multiple auth types (password, Kerberos, SAML, X.509, JWT, LDAP), role and privilege management
- **Backup & Recovery** — Full, incremental, differential, log, and snapshot backups with scheduling and encryption
- **Alerting** — Threshold-based alerts across performance, availability, storage, memory, CPU, replication, backup, security categories with acknowledgment workflow
- **HDI Containers** — Manage HANA Deployment Infrastructure containers for application development
- **Replication Tasks** — Real-time, scheduled, snapshot, and log-based data replication between sources
- **Configuration** — System, database, tenant, and session scoped configuration parameters
- **Database Connections** — Connection management for JDBC, ODBC, hdbsql, Node.js, Python, Java, Go, .NET with connection pooling
- **Multi-Tenancy** — Tenant isolation via `X-Tenant-Id` header on all API endpoints
- **Health Check** — Kubernetes-ready liveness and readiness probe endpoint

## Architecture

```
Hexagonal Architecture (Ports & Adapters + Clean Architecture)

┌─────────────────────────────────────────────────┐
│                Presentation Layer                │
│     HTTP Controllers (Driving Adapters)          │
│  Instance | DataLake | Schema | User | Backup    │
│  Alert | HDI | Replication | Config | Connection │
│  Health                                          │
├─────────────────────────────────────────────────┤
│                Application Layer                 │
│     Use Cases + DTOs                             │
│  ManageInstances | ManageDataLakes | ...         │
├─────────────────────────────────────────────────┤
│                 Domain Layer                     │
│  Entities | Value Types | Ports | Domain Svc     │
│  InstanceValidator                               │
├─────────────────────────────────────────────────┤
│              Infrastructure Layer                │
│     Config | Container (DI) | Persistence        │
│  In-Memory Repositories (Driven Adapters)        │
└─────────────────────────────────────────────────┘
```

## API Endpoints

**Base URL:** `/api/v1/hana`

### Instances

| Method | Path | Description |
|--------|------|-------------|
| POST | `/instances` | Create a new HANA instance |
| GET | `/instances` | List all instances for tenant |
| GET | `/instances/{id}` | Get instance by ID |
| PUT | `/instances/{id}` | Update instance |
| DELETE | `/instances/{id}` | Delete instance |
| POST | `/instances/{id}/actions` | Perform action (start/stop/restart) |

### Data Lakes

| Method | Path | Description |
|--------|------|-------------|
| POST | `/dataLakes` | Create a data lake |
| GET | `/dataLakes` | List data lakes |
| GET | `/dataLakes/{id}` | Get data lake by ID |
| PUT | `/dataLakes/{id}` | Update data lake |
| DELETE | `/dataLakes/{id}` | Delete data lake |

### Schemas

| Method | Path | Description |
|--------|------|-------------|
| POST | `/schemas` | Create a schema |
| GET | `/schemas` | List schemas |
| GET | `/schemas/{id}` | Get schema by ID |
| PUT | `/schemas/{id}` | Update schema |
| DELETE | `/schemas/{id}` | Delete schema |

### Database Users

| Method | Path | Description |
|--------|------|-------------|
| POST | `/users` | Create a database user |
| GET | `/users` | List users |
| GET | `/users/{id}` | Get user by ID |
| PUT | `/users/{id}` | Update user |
| DELETE | `/users/{id}` | Delete user |

### Backups

| Method | Path | Description |
|--------|------|-------------|
| POST | `/backups` | Create/schedule a backup |
| GET | `/backups` | List backups |
| GET | `/backups/{id}` | Get backup by ID |
| PUT | `/backups/{id}` | Update backup |
| DELETE | `/backups/{id}` | Delete backup |

### Alerts

| Method | Path | Description |
|--------|------|-------------|
| POST | `/alerts` | Create an alert definition |
| GET | `/alerts` | List alerts |
| GET | `/alerts/{id}` | Get alert by ID |
| PUT | `/alerts/{id}` | Update alert |
| DELETE | `/alerts/{id}` | Delete alert |
| PUT | `/alerts/{id}/acknowledge` | Acknowledge alert |

### HDI Containers

| Method | Path | Description |
|--------|------|-------------|
| POST | `/hdiContainers` | Create HDI container |
| GET | `/hdiContainers` | List HDI containers |
| GET | `/hdiContainers/{id}` | Get HDI container by ID |
| PUT | `/hdiContainers/{id}` | Update HDI container |
| DELETE | `/hdiContainers/{id}` | Delete HDI container |

### Replication Tasks

| Method | Path | Description |
|--------|------|-------------|
| POST | `/replicationTasks` | Create replication task |
| GET | `/replicationTasks` | List replication tasks |
| GET | `/replicationTasks/{id}` | Get replication task by ID |
| PUT | `/replicationTasks/{id}` | Update replication task |
| DELETE | `/replicationTasks/{id}` | Delete replication task |

### Configurations

| Method | Path | Description |
|--------|------|-------------|
| POST | `/configurations` | Create configuration parameter |
| GET | `/configurations` | List configurations |
| GET | `/configurations/{id}` | Get configuration by ID |
| PUT | `/configurations/{id}` | Update configuration |
| DELETE | `/configurations/{id}` | Delete configuration |

### Database Connections

| Method | Path | Description |
|--------|------|-------------|
| POST | `/connections` | Create connection |
| GET | `/connections` | List connections |
| GET | `/connections/{id}` | Get connection by ID |
| PUT | `/connections/{id}` | Update connection |
| DELETE | `/connections/{id}` | Delete connection |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Health check |

## Build & Run

### Prerequisites

- D compiler (LDC 1.40.1+ recommended)
- dub package manager

### Build

```bash
cd hana
dub build --config=defaultRun
```

### Run

```bash
./build/uim-hana-platform-service
```

### Test

```bash
dub test --config=defaultTest
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HANA_HOST` | `0.0.0.0` | Bind address |
| `HANA_PORT` | `8097` | Listen port |

## Docker

```bash
docker build -t uim-hana-platform-service .
docker run -p 8097:8097 uim-hana-platform-service
```

## Podman

```bash
podman build -f Containerfile -t uim-hana-platform-service .
podman run -p 8097:8097 uim-hana-platform-service
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Project Structure

```
hana/
├── dub.sdl                          # Build configuration
├── Dockerfile                       # Docker multi-stage build
├── Containerfile                    # Podman build
├── k8s/                             # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── docs/                            # Architecture documentation
│   ├── uml.md                       # UML diagrams (Mermaid)
│   └── nafv4.md                     # NAF v4 architecture document
└── source/
    ├── app.d                        # Entry point
    └── uim/platform/hana/
        ├── domain/                  # Core business logic
        │   ├── types.d              # ID aliases and enums
        │   ├── entities/            # 10 domain entities
        │   ├── ports/repositories/  # Repository interfaces
        │   └── services/            # Domain validators
        ├── application/             # Use cases and DTOs
        │   ├── dto.d
        │   └── usecases/manage/     # 10 use case classes
        ├── presentation/            # HTTP controllers
        │   └── http/
        │       ├── json_utils.d
        │       └── controllers/     # 11 controllers
        └── infrastructure/          # Config, DI, persistence
            ├── config.d
            ├── container.d
            └── persistence/memory/  # 10 in-memory repos
```

## License

Apache-2.0
