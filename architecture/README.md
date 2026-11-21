# UIM TOGAF Building Blocks Service

This service is a D + vibe.d microservice for managing TOGAF building blocks with a Clean + Hexagonal architecture approach.

## Managed Building Block Types

- Architecture Building Block (`architecture`)
- Solution Building Block (`solution`)
- Data Building Block (`data`)
- Business Building Block (`business`)
- Technology Building Block (`technology`)

## Architecture Style

The service uses:

- Clean Architecture layers: presentation, application, domain, infrastructure.
- Hexagonal ports/adapters: use cases depend on repository interfaces, while infrastructure provides concrete adapters.

## API

Base path: `/api/v1/building-blocks`

- `GET /api/v1/health`
- `GET /api/v1/building-blocks`
- `GET /api/v1/building-blocks/types/:type`
- `GET /api/v1/building-blocks/:id`
- `POST /api/v1/building-blocks`
- `PUT /api/v1/building-blocks/:id`
- `DELETE /api/v1/building-blocks/:id`

Example create payload:

```json
{
  "type": "architecture",
  "name": "Canonical Integration Pattern",
  "description": "Reusable event-driven integration style",
  "owner": "enterprise-architecture",
  "lifecycleState": "identified",
  "status": "active",
  "versionLabel": "1.0.0",
  "tags": ["integration", "event", "reusable"]
}
```

## Build and Run

```bash
cd architecture
dub run --config=defaultRun
```

Environment variables:

- `ARCHITECTURE_HOST` (default `0.0.0.0`)
- `ARCHITECTURE_PORT` (default `8122`)

## Docker and Podman

```bash
# Docker
docker build -t uim-platform/architecture:latest .
docker run -p 8122:8122 uim-platform/architecture:latest

# Podman
podman build -f Containerfile -t uim-platform/architecture:latest .
podman run -p 8122:8122 uim-platform/architecture:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
