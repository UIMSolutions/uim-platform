# Usage Data Management Service for UIM Platform

A **D language / vibe.d** microservice modelling the capabilities of the **SAP Usage Data Management Service for SAP BTP**. It collects raw usage records, aggregates them into monthly and daily reports, tracks cost distribution across subaccounts, and maintains a service metric catalog — all behind a RESTful API.

## Features

| Feature | Description |
|---|---|
| Usage Record Ingestion | Submit and retrieve individual usage records per global account / subaccount / service / metric |
| Monthly Usage Reports | Aggregated consumption per global account, year and month |
| Daily Usage Reports | Granular subaccount consumption per calendar day |
| Monthly Cost Reports | CPEA / PAYG cost distribution per subaccount and metric |
| Service Metric Catalog | Discoverable metric definitions with billable flag and commercial model |
| Health Endpoint | `/api/v1/health` for liveness checks |

## Architecture

Clean + Hexagonal (Ports & Adapters) following the repo convention:

```
source/uim/platform/usage_data/
  domain/               # Pure business logic — no framework deps
    entities/
    enumerations/
    ports/repositories/
    services/
    values/
  app/                  # Application use-cases and DTOs
    dto/
    usecases/
  infrastructure/       # Framework / IO implementations
    config.d
    adapters/
    persistence/memory/repositories/
    web/
      handlers/
      middleware.d
      routes.d
  helpers/
  package.d
source/app.d            # Composition root
```

## API

Base path: `/api/v1/usage-data`

### Health

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/health` | Liveness check |

### Usage Records

| Method | Path | Description |
|---|---|---|
| GET | `/usage-records` | List all usage records |
| POST | `/usage-records` | Submit a new usage record |
| GET | `/usage-records/:id` | Get a single record |
| DELETE | `/usage-records/:id` | Delete a record |

### Monthly Usage Reports

| Method | Path | Description |
|---|---|---|
| GET | `/reports/monthly` | List all monthly reports |
| POST | `/reports/monthly` | Create a report |
| GET | `/reports/monthly/:id` | Get a report |
| DELETE | `/reports/monthly/:id` | Delete a report |

### Daily Usage Reports

| Method | Path | Description |
|---|---|---|
| GET | `/reports/daily` | List all daily reports |
| POST | `/reports/daily` | Create a report |
| GET | `/reports/daily/:id` | Get a report |
| DELETE | `/reports/daily/:id` | Delete a report |

### Monthly Cost Reports

| Method | Path | Description |
|---|---|---|
| GET | `/reports/costs` | List all cost reports |
| POST | `/reports/costs` | Create a cost report |
| GET | `/reports/costs/:id` | Get a cost report |
| DELETE | `/reports/costs/:id` | Delete a cost report |

### Service Metrics

| Method | Path | Description |
|---|---|---|
| GET | `/metrics` | List all service metrics |
| POST | `/metrics` | Register a metric definition |
| GET | `/metrics/:id` | Get a metric |
| DELETE | `/metrics/:id` | Delete a metric |

## Configuration

| Env Variable | Default | Description |
|---|---|---|
| `USAGE_DATA_HOST` | `0.0.0.0` | Bind address |
| `USAGE_DATA_PORT` | `10004` | Listen port |

## Building

```bash
# Local build
dub build --config=default

# Docker
docker build -t uim-usage-data-platform-service .

# Podman
podman build -t uim-usage-data-platform-service .
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Related SAP BTP Service

[SAP Usage Data Management Service for SAP BTP](https://discovery-center.cloud.sap/serviceCatalog/usage-data-management-service)
