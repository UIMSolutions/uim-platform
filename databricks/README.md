# UIM Databricks Platform Service

A D-language microservice modelling the features of **SAP Databricks** (SAP Business Data Cloud) built with vibe.d, following **Clean + Hexagonal Architecture** and the **MVC pattern** for all presentation layers.

## Features

| Domain | Capabilities |
|--------|-------------|
| Workspaces | Provision, manage, and delete Databricks workspaces |
| Clusters | Interactive and job clusters, auto-scaling, Spark version management |
| Notebooks | Python / Scala / R / SQL notebooks with version tracking |
| Jobs | Scheduled and triggered batch jobs with retry policies |
| Job Runs | Run history, state tracking (running/succeeded/failed/timedOut) |
| Delta Tables | Unity Catalog-based Delta Lake table management |
| Data Products | SAP BDC data product publishing and sharing |
| ML Experiments | MLflow experiment tracking and run comparison |
| ML Models | Model registry, stage promotion (staging/production/archived) |
| SQL Warehouses | Classic, Pro, and Serverless SQL warehouses |

## Architecture

```
databricks/
  source/uim/platform/databricks/
    domain/            # Entities, port interfaces, enumerations (pure D)
    application/       # Use cases, DTOs
    infrastructure/    # DI container, memory/file/mongo repositories
    presentation/
      http/            # vibe.d REST controllers (MVC)
      cli/             # CLI command handlers (MVC stub)
      web/             # Diet template web UI (MVC stub)
      gui/             # gtk-d desktop UI (MVC stub)
```

Architecture follows [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/) — the domain and application layers have zero framework dependencies.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Health check |
| POST/GET | `/api/v1/databricks/workspaces` | Create / list workspaces |
| GET/PUT/DELETE | `/api/v1/databricks/workspaces/*` | Get / update / delete workspace |
| POST/GET | `/api/v1/databricks/clusters` | Create / list clusters |
| GET/PUT/DELETE | `/api/v1/databricks/clusters/*` | Get / update / delete cluster |
| POST/GET | `/api/v1/databricks/notebooks` | Create / list notebooks |
| GET/PUT/DELETE | `/api/v1/databricks/notebooks/*` | Get / update / delete notebook |
| POST/GET | `/api/v1/databricks/jobs` | Create / list jobs |
| GET/PUT/DELETE | `/api/v1/databricks/jobs/*` | Get / update / delete job |
| POST/GET | `/api/v1/databricks/jobruns` | Create / list job runs |
| GET/PUT/DELETE | `/api/v1/databricks/jobruns/*` | Get / update / delete job run |
| POST/GET | `/api/v1/databricks/tables` | Create / list Delta tables |
| GET/PUT/DELETE | `/api/v1/databricks/tables/*` | Get / update / delete Delta table |
| POST/GET | `/api/v1/databricks/dataproducts` | Create / list data products |
| GET/PUT/DELETE | `/api/v1/databricks/dataproducts/*` | Get / update / delete data product |
| POST/GET | `/api/v1/databricks/experiments` | Create / list ML experiments |
| GET/PUT/DELETE | `/api/v1/databricks/experiments/*` | Get / update / delete experiment |
| POST/GET | `/api/v1/databricks/models` | Create / list ML models |
| GET/PUT/DELETE | `/api/v1/databricks/models/*` | Get / update / delete ML model |
| POST/GET | `/api/v1/databricks/warehouses` | Create / list SQL warehouses |
| GET/PUT/DELETE | `/api/v1/databricks/warehouses/*` | Get / update / delete warehouse |

All requests/responses are `application/json`. Tenant isolation via `X-Tenant-Id` header.

## Persistence

| Backend | Status |
|---------|--------|
| In-memory | Active (default) |
| Files | Stub (planned) |
| MongoDB | Stub (planned) |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABRICKS_HOST` | `0.0.0.0` | Bind address |
| `DATABRICKS_PORT` | `8104` | Listen port |

## Build & Run

### Local (dub)
```bash
cd databricks
dub run --config=defaultRun
```

### Docker
```bash
docker build -f databricks/Dockerfile -t uim-databricks-platform-service .
docker run -p 8104:8104 uim-databricks-platform-service
```

### Podman
```bash
podman build -f databricks/Containerfile -t uim-databricks-platform-service .
podman run -p 8104:8104 uim-databricks-platform-service
```

### Kubernetes
```bash
kubectl apply -f databricks/k8s/configmap.yaml
kubectl apply -f databricks/k8s/deployment.yaml
kubectl apply -f databricks/k8s/service.yaml
```

## Test
```bash
dub test --root=databricks
```
