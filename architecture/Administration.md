# Administration Guide - TOGAF Building Blocks Service

## Runtime Configuration

Environment variables:

- `ARCHITECTURE_HOST` (default `0.0.0.0`)
- `ARCHITECTURE_PORT` (default `8122`)

## Local Operations

Build:

```bash
cd architecture
dub build --config=defaultRun
```

Test:

```bash
cd architecture
dub test
```

Run:

```bash
cd architecture
dub run --config=defaultRun
```

## Container Operations

Docker:

```bash
docker build -t uim-platform/architecture:latest .
docker run --rm -p 8122:8122 \
  -e ARCHITECTURE_HOST=0.0.0.0 \
  -e ARCHITECTURE_PORT=8122 \
  uim-platform/architecture:latest
```

Podman:

```bash
podman build -f Containerfile -t uim-platform/architecture:latest .
podman run --rm -p 8122:8122 uim-platform/architecture:latest
```

## Kubernetes Operations

Deploy:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Check rollout:

```bash
kubectl rollout status deployment/architecture -n uim-platform
```

Port-forward for testing:

```bash
kubectl port-forward service/architecture 8122:8122 -n uim-platform
```

## Health and Probes

The deployment uses:

- Liveness probe: `GET /api/v1/health`
- Readiness probe: `GET /api/v1/health`

## Operational Notes

- Storage adapter is currently in-memory repository implementation.
- For production persistence, create additional driven adapters behind the repository port.
- The app follows DI in `infrastructure/container.d`; replace repository wiring there for other backends.
