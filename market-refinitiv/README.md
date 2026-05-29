# UIM Platform - Market Rates Management (Refinitiv Data Option)

A D/vibe.d microservice inspired by SAP BTP Market Rates Management with focus on the Refinitiv data option. The service is implemented with clean architecture + hexagonal architecture and includes MVC adapters for HTTP, CLI, Web, and GUI.

## Features

- Market rates upload/download API compatible with SAP-style BYOR workflows
- Refinitiv-oriented provider management (`providerCode`, `dataSource`, categories)
- Tenant-scoped rate querying and deletion
- Business audit logging for upload/download/delete/query operations
- Storage backends:
- `MEMORY` for development
- `FILE` for durable local storage
- `MONGODB` for persistent multi-instance runtime
- Deployment support for Docker, Podman, and Kubernetes

## Architecture

- Domain: `MarketRate`, `Provider`, `AuditLog`, validators, quota rules
- Application: use cases for rates, providers, and audit retrieval
- Ports: repository interfaces for rates/providers/audit
- Adapters:
- Driving: HTTP controllers, CLI commands, Web views, GUI widgets
- Driven: memory/file/mongodb repositories

## API Endpoints

- `GET /api/v1/health`
- `POST /api/v1/market_refinitiv/upload`
- `POST /api/v1/market_refinitiv/download`
- `GET /api/v1/market_refinitiv/rates`
- `GET /api/v1/market_refinitiv/rates/{id}`
- `DELETE /api/v1/market_refinitiv/rates`
- `GET /api/v1/market_refinitiv/providers`
- `POST /api/v1/market_refinitiv/providers`
- `GET /api/v1/market_refinitiv/providers/{id}`
- `PUT /api/v1/market_refinitiv/providers/{id}`
- `DELETE /api/v1/market_refinitiv/providers/{id}`
- `GET /api/v1/market_refinitiv/auditlogs`
- `GET /web/market-refinitiv`

## Configuration

- `MARKET_REFINITIV_HOST` default `0.0.0.0`
- `MARKET_REFINITIV_PORT` default `8098`
- `MARKET_REFINITIV_SERVICE_NAME` default `uim-market-refinitiv-platform-service`
- `MARKET_REFINITIV_STORAGE_BACKEND` one of `MEMORY|FILE|MONGODB`
- `MARKET_REFINITIV_FILE_PATH` default `/data/market-refinitiv`
- `MARKET_REFINITIV_MONGO_URI` default `mongodb://localhost:27017`
- `MARKET_REFINITIV_MONGO_DB` default `market_refinitiv`

## Build and Run

```bash
cd market-refinitiv
dub run --config=defaultRun
```

## Docker

```bash
docker build -f market-refinitiv/Dockerfile -t uim-market-refinitiv-platform-service:latest .
docker run -p 8098:8098 \
  -e MARKET_REFINITIV_STORAGE_BACKEND=MEMORY \
  uim-market-refinitiv-platform-service:latest
```

## Podman

```bash
podman build -f market-refinitiv/Containerfile -t uim-market-refinitiv-platform-service:latest .
podman run -p 8098:8098 \
  -e MARKET_REFINITIV_STORAGE_BACKEND=FILE \
  -e MARKET_REFINITIV_FILE_PATH=/data/market-refinitiv \
  uim-market-refinitiv-platform-service:latest
```

## Kubernetes

```bash
kubectl apply -f market-refinitiv/k8s/configmap.yaml
kubectl apply -f market-refinitiv/k8s/deployment.yaml
kubectl apply -f market-refinitiv/k8s/service.yaml
```

## Notes on SAP Alignment

The service behavior and data model are aligned with SAP BTP Market Rates Management concepts (provider-driven upload/download, category-based instruments, tenant isolation, and auditability) while remaining framework-agnostic for self-hosted runtime.
