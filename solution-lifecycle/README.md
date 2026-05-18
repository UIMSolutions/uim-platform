# Solution Lifecycle Management Service

A D-language microservice implementing the core features of the **SAP Solution Lifecycle Management service for SAP BTP**. Built with [vibe.d](https://vibed.org/) using **Clean Architecture** (Hexagonal/Ports-and-Adapters) principles.

## Overview

The Solution Lifecycle Management (SLM) service provides a full API for managing the lifecycle of **Multi-Target Applications (MTA)** — the packaging and deployment format for SAP BTP solutions. It supports uploading MTA archives, deploying standard and provided solutions, subscribing to third-party solutions, tracking async operations, and transporting across landscapes.

## Features

| Feature | Description |
|---|---|
| MTA Archive Management | Upload, validate, list, and delete `.mtar` archive files |
| Solution Deployment | Deploy standard, provided, and subscribed MTA solutions |
| Solution Update | Update deployed MTAs with new archive versions |
| Solution Deletion | Async delete with operation tracking |
| Async Operations | Queue-based operation lifecycle (deploy/update/delete/subscribe/unsubscribe/abort) |
| Operation Logs | Streaming log lines per async operation |
| Subscription Management | Subscribe/unsubscribe to solutions provided by other subaccounts |
| Extension Descriptors | Apply YAML extension descriptors on deploy/subscribe |
| Multi-Tenancy | All operations scoped via `X-Tenant-Id` HTTP header |
| Health Endpoint | Liveness/readiness probe at `/api/v1/health` |

## Architecture

```
solution-lifecycle/
├── source/
│   ├── app.d                              # Entry point — composition root
│   └── uim/platform/solution_lifecycle/
│       ├── package.d                      # Umbrella module import
│       ├── domain/
│       │   ├── types.d                    # ID structs, enums
│       │   ├── entities/
│       │   │   ├── mta_archive.d          # Uploaded MTA archive
│       │   │   ├── mta.d                  # Deployed MTA solution + modules
│       │   │   ├── mta_operation.d        # Async operation record
│       │   │   └── mta_subscription.d     # Subscription to provided solution
│       │   ├── ports/repositories/        # Repository interfaces (driven ports)
│       │   └── services/
│       │       └── deployment_engine.d    # Domain service: deploy/validate logic
│       ├── application/
│       │   ├── dto.d                      # Request DTOs
│       │   └── usecases/manage/
│       │       ├── mta_archives.d         # Upload / list / delete archives
│       │       ├── mtas.d                 # Deploy / update / list / delete MTAs
│       │       ├── mta_operations.d       # Poll / abort / log operations
│       │       └── mta_subscriptions.d    # Subscribe / unsubscribe
│       ├── infrastructure/
│       │   ├── config.d                   # SrvConfig, loadConfig()
│       │   ├── container.d                # buildContainer() DI wiring
│       │   └── persistence/memory/        # In-memory repository implementations
│       └── presentation/
│           └── http/controllers/
│               ├── mta_archive.d          # /api/v1/slm/mta-archives
│               ├── mta.d                  # /api/v1/slm/mtas
│               ├── mta_operation.d        # /api/v1/slm/operations
│               └── mta_subscription.d     # /api/v1/slm/subscriptions
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── Dockerfile
├── Containerfile
├── dub.sdl
├── README.md
├── UML.md
└── NAFv4.md
```

## API Endpoints

### MTA Archives — `/api/v1/slm/mta-archives`

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/slm/mta-archives` | Register/upload an MTA archive metadata |
| `GET` | `/api/v1/slm/mta-archives` | List all archives for the tenant |
| `GET` | `/api/v1/slm/mta-archives/{id}` | Get a specific archive |
| `DELETE` | `/api/v1/slm/mta-archives/{id}` | Delete an archive |

**POST request body:**
```json
{
  "fileName": "my-app-1.0.0.mtar",
  "mtaId": "com.example.my-app",
  "mtaVersion": "1.0.0",
  "fileSizeBytes": 204800,
  "checksum": "sha256:abc123...",
  "uploadedBy": "user@example.com",
  "namespace": "",
  "targetPlatforms": ["CF", "NEO"]
}
```

### MTA Solutions — `/api/v1/slm/mtas`

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/slm/mtas` | Deploy an MTA from archive (async, returns operationId) |
| `GET` | `/api/v1/slm/mtas` | List all deployed MTAs for the tenant |
| `GET` | `/api/v1/slm/mtas/{id}` | Get a specific deployed MTA |
| `PUT` | `/api/v1/slm/mtas/{id}` | Update MTA with new archive version (async) |
| `DELETE` | `/api/v1/slm/mtas/{id}` | Delete a deployed MTA (async) |

**POST deploy request body:**
```json
{
  "archiveId": "<archive-id>",
  "solutionType": "standard",
  "spaceId": "my-cf-space",
  "deployedBy": "user@example.com",
  "namespace": "",
  "extensionDescriptor": ""
}
```

**Response (202 Accepted):**
```json
{
  "operationId": "op-tenant01-1234567890",
  "message": "Deploy operation started"
}
```

### Async Operations — `/api/v1/slm/operations`

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/slm/operations` | List all operations for the tenant |
| `GET` | `/api/v1/slm/operations/{id}` | Get operation details and current status |
| `POST` | `/api/v1/slm/operations/{id}/poll` | Advance operation one step (mock simulation) |
| `POST` | `/api/v1/slm/operations/{id}/abort` | Abort a running operation |
| `GET` | `/api/v1/slm/operations/{id}/logs` | Retrieve streaming log lines |

**Operation status values:** `queued` → `running` → `finished` / `failed` / `aborted`

### Subscriptions — `/api/v1/slm/subscriptions`

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/slm/subscriptions` | List all subscriptions for the tenant |
| `GET` | `/api/v1/slm/subscriptions/{id}` | Get a specific subscription |
| `POST` | `/api/v1/slm/subscriptions` | Subscribe to a provided solution (async) |
| `DELETE` | `/api/v1/slm/subscriptions/{id}` | Unsubscribe from a solution (async) |

**POST subscribe request body:**
```json
{
  "providerMtaId": "com.example.provider-app",
  "providerTenantId": "provider-tenant-001",
  "providerSpaceId": "provider-space",
  "subscribedBy": "user@example.com",
  "extensionDescriptor": ""
}
```

### Health — `/api/v1/health`

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/health` | Service health check |

**Response:**
```json
{ "status": "UP", "service": "solution-lifecycle" }
```

## Solution Types

| Type | Description |
|---|---|
| `standard` | Deployed only in the deploying subaccount; no subscription possible |
| `provided` | Deployed and made available for other subaccounts to subscribe |
| `subscribed` | A solution subscribed from a provider subaccount |

## MTA Module Types

| Type | Runtime |
|---|---|
| `java.main` | SAP BTP Java (main) |
| `java.tomcat` | SAP BTP Java (Tomcat) |
| `html5.application` | SAP HTML5 Application Repository |
| `nodejs` | Node.js runtime |
| `portal.site` | SAP Fiori Launchpad site |
| `jobscheduler` | SAP Job Scheduling service |
| `com.sap.application.content` | Content deployment |

## Build

```bash
# Build binary
cd solution-lifecycle
dub build --config=defaultRun

# Run tests
dub test --config=defaultTest

# Run locally
./build/uim-solution-lifecycle-platform-service
```

## Docker

```bash
# Build image (Docker)
docker build -f solution-lifecycle/Dockerfile -t uim-solution-lifecycle-platform-service:latest .

# Build image (Podman)
podman build -f solution-lifecycle/Containerfile -t uim-solution-lifecycle-platform-service:latest .

# Run container
docker run -p 8097:8097 \
  -e SOLUTION_LIFECYCLE_HOST=0.0.0.0 \
  -e SOLUTION_LIFECYCLE_PORT=8097 \
  uim-solution-lifecycle-platform-service:latest
```

## Kubernetes

```bash
kubectl apply -f solution-lifecycle/k8s/configmap.yaml
kubectl apply -f solution-lifecycle/k8s/deployment.yaml
kubectl apply -f solution-lifecycle/k8s/service.yaml

# Port-forward for local testing
kubectl port-forward svc/cloud-solution-lifecycle 8097:8097
```

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `SOLUTION_LIFECYCLE_HOST` | `0.0.0.0` | Bind address |
| `SOLUTION_LIFECYCLE_PORT` | `8097` | Listen port |

## Multi-Tenancy

All API calls must include the `X-Tenant-Id` HTTP header. Data is strictly isolated per tenant.

## References

- [SAP Solution Lifecycle Management Service](https://help.sap.com/viewer/p/SOLUTIONS_LIFECYCLE_MANAGEMENT)
- [Multitarget Applications for SAP BTP Neo Environment](https://help.sap.com/docs/BTP/ea72206b834e4ace9cd834feed6c0e09/e1bb7eb746d34237b8b47035adff5022.html)
- [Operating Solutions](https://help.sap.com/docs/BTP/ea72206b834e4ace9cd834feed6c0e09/2abf7d47063542208d0d99f7bc05f4f4.html)
- [The MTA Model v2 Specification](https://help.sap.com/doc/multitarget-application-modelv2/Cloud/en-US/The%20Multitarget%20Application%20Model.pdf)
