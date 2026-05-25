# SAP Snowflake — UIM Platform Service

A vibe.d / D-language microservice that implements features similar to **SAP Snowflake** in SAP Business Data Cloud (BDC). It follows a combination of **Hexagonal Architecture** (ports & adapters) and **Clean Architecture** (layered dependency rule), with **MVC stubs** for CLI, Web, and GUI presentation layers.

---

## Features

| Feature | Description |
|---|---|
| Snowflake Account Provisioning | Request, provision, and activate Snowflake accounts integrated with SAP BDC entitlements |
| Zero-Copy Connector Management | Manage connectors linking SAP BDC data products to Snowflake via invitation-based enrollment |
| Warehouse Management | Create and manage Snowflake virtual warehouses with size and auto-suspend/resume settings |
| Database Management | Manage Snowflake databases with retention day configuration |
| Data Product Shares | Share SAP BDC data products into Snowflake with sync lifecycle management |
| Role Management | Manage Snowflake roles and privileges per tenant account |
| Tenant User Management | Manage tenant users with role-based access (admin / editor / viewer) |
| Provisioning Requests | Track and manage end-to-end account provisioning lifecycle |

---

## Architecture

```
snowflake/
├── source/
│   ├── app.d                            ← Entry point
│   └── uim/platform/snowflake/
│       ├── domain/                      ← Entities, Ports (interfaces), Domain Services
│       │   ├── entities/
│       │   ├── ports/repositories/
│       │   └── services/
│       ├── application/                 ← Use Cases, DTOs
│       │   ├── dto.d
│       │   └── usecases/manage/
│       ├── infrastructure/              ← Config, Container, Memory Repos
│       │   ├── config_.d
│       │   ├── container.d
│       │   └── persistence/memory/
│       └── presentation/
│           ├── http/                    ← REST API controllers
│           ├── cli/  (controllers/ models/ views/)
│           ├── web/  (controllers/ models/ views/)
│           └── gui/  (controllers/ models/ views/)
├── Dockerfile
├── Containerfile
└── k8s/
    ├── deployment.yaml
    ├── service.yaml
    └── configmap.yaml
```

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/health` | Health check |
| GET/POST | `/api/v1/snowflake/accounts` | List / create Snowflake accounts |
| GET/PUT/DELETE | `/api/v1/snowflake/accounts/*` | Get / update / delete account |
| POST | `/api/v1/snowflake/accounts/*/activate` | Activate account |
| GET/POST | `/api/v1/snowflake/connectors` | List / create zero-copy connectors |
| GET/PUT/DELETE | `/api/v1/snowflake/connectors/*` | Get / update / delete connector |
| POST | `/api/v1/snowflake/connectors/*/enroll` | Enroll connector |
| GET/POST | `/api/v1/snowflake/warehouses` | List / create warehouses |
| GET/PUT/DELETE | `/api/v1/snowflake/warehouses/*` | Get / update / delete warehouse |
| GET/POST | `/api/v1/snowflake/databases` | List / create databases |
| GET/PUT/DELETE | `/api/v1/snowflake/databases/*` | Get / update / delete database |
| GET/POST | `/api/v1/snowflake/shares` | List / create data product shares |
| GET/PUT/DELETE | `/api/v1/snowflake/shares/*` | Get / update / delete share |
| POST | `/api/v1/snowflake/shares/*/sync` | Trigger share sync |
| GET/POST | `/api/v1/snowflake/roles` | List / create roles |
| GET/PUT/DELETE | `/api/v1/snowflake/roles/*` | Get / update / delete role |
| GET/POST | `/api/v1/snowflake/users` | List / create tenant users |
| GET/PUT/DELETE | `/api/v1/snowflake/users/*` | Get / update / delete user |
| GET/POST | `/api/v1/snowflake/requests` | List / create provisioning requests |
| GET/DELETE | `/api/v1/snowflake/requests/*` | Get / delete provisioning request |
| POST | `/api/v1/snowflake/requests/*/process` | Mark request processing |
| POST | `/api/v1/snowflake/requests/*/complete` | Mark request completed |
| POST | `/api/v1/snowflake/requests/*/fail` | Mark request failed |

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `SNOWFLAKE_HOST` | `0.0.0.0` | Bind address |
| `SNOWFLAKE_PORT` | `8100` | HTTP port |

---

## Build & Run

### Native
```bash
cd snowflake
dub build --build=release
./build/uim-snowflake-platform-service
```

### Docker
```bash
docker build -t cloud-snowflake .
docker run -p 8100:8100 cloud-snowflake
```

### Podman
```bash
podman build -f Containerfile -t cloud-snowflake .
podman run -p 8100:8100 cloud-snowflake
```

### Kubernetes
```bash
kubectl apply -f k8s/
```

---

## References

- [SAP BDC Feature Scope](https://help.sap.com/docs/business-data-cloud/feature-scope-description-business-data-cloud/features)
- [SAP Help Portal — Business Data Cloud](https://help.sap.com/docs/business-data-cloud)
