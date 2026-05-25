# SAP Private Link Service — UIM Platform

A **D-language** / **vibe.d** microservice that mirrors the features of
[SAP Private Link Service on BTP](https://help.sap.com/docs/private-link).

It establishes private connectivity between applications running on a cloud
platform and services hosted in IaaS provider accounts (Azure, AWS, GCP)
**without routing traffic over the public internet**.

---

## Architecture

The service follows **Hexagonal (Ports & Adapters) Architecture** combined with
**Clean Architecture** layering:

```
┌──────────────────────────────────────────────────────────────┐
│  Presentation                                                │
│   HTTP  (vibe.d REST API)    ← primary adapter               │
│   CLI   (privlink-cli)       ← primary adapter               │
│   Web   (Diet HTML views)    ← primary adapter               │
│   GUI   (desktop/component)  ← primary adapter               │
├──────────────────────────────────────────────────────────────┤
│  Application                                                 │
│   Use Cases: ManageServiceInstances, ManagePrivateEndpoints, │
│              ManageServiceBindings                           │
│   DTOs: CreateServiceInstanceRequest, ApproveEndpointRequest │
├──────────────────────────────────────────────────────────────┤
│  Domain                                                      │
│   Entities: ServiceInstance, PrivateEndpoint, ServiceBinding │
│   Ports:    ServiceInstanceRepository, PrivateEndpointRepo,  │
│             ServiceBindingRepository                         │
│   Services: EndpointResolver                                 │
├──────────────────────────────────────────────────────────────┤
│  Infrastructure                                              │
│   Memory repos (default)  ← secondary adapter               │
│   File repos (NDJSON)     ← secondary adapter               │
│   MongoDB repos           ← secondary adapter               │
│   Config / DI Container                                      │
└──────────────────────────────────────────────────────────────┘
```

---

## Features

| Feature | Description |
|---|---|
| **Private Endpoints** | Provision private endpoints for IaaS services (Azure, AWS, GCP) |
| **Approval Workflow** | Approve or reject incoming endpoint connection requests |
| **Service Instances** | Lifecycle management: create → provision → ready → delete |
| **Service Bindings** | Bind service instances to applications; returns hostname + IP |
| **Multi-tenant** | All resources are tenant-scoped |
| **Multi-storage** | In-memory, file (NDJSON), MongoDB via env-var switch |
| **Health endpoint** | `GET /api/v1/health` for liveness/readiness probes |
| **Container-ready** | Docker, Podman (Containerfile), Kubernetes manifests included |

---

## REST API

### Service Instances

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/service-instances` | Create a service instance |
| `GET` | `/api/v1/service-instances` | List all service instances |
| `GET` | `/api/v1/service-instances/:id` | Get a service instance |
| `PUT` | `/api/v1/service-instances/:id` | Update a service instance |
| `DELETE` | `/api/v1/service-instances/:id` | Delete a service instance |

**Create request body:**
```json
{
  "name": "my-azure-storage-link",
  "description": "Private link to Azure Storage",
  "resourceId": "/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Storage/storageAccounts/mystore",
  "iaasProvider": "azure",
  "plan": "standard",
  "region": "westeurope",
  "subaccountId": "sub-abc123"
}
```

### Private Endpoints

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/private-endpoints` | Create a private endpoint |
| `GET` | `/api/v1/private-endpoints` | List all private endpoints |
| `GET` | `/api/v1/private-endpoints/:id` | Get a private endpoint |
| `PUT` | `/api/v1/private-endpoints/:id` | Update endpoint status |
| `POST` | `/api/v1/private-endpoints/:id/approve` | Approve an endpoint (set IP, hostname, port) |
| `DELETE` | `/api/v1/private-endpoints/:id` | Delete a private endpoint |

**Approve request body:**
```json
{
  "providerEndpointId": "/subscriptions/xxx/.../privateEndpoints/my-ep",
  "privateIpAddress": "10.0.1.5",
  "hostname": "my-store.privatelink.blob.core.windows.net",
  "port": 443
}
```

### Service Bindings

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/service-bindings` | Bind a service instance to an app |
| `GET` | `/api/v1/service-bindings` | List all bindings |
| `GET` | `/api/v1/service-bindings/:id` | Get a binding (includes hostname + IP) |
| `DELETE` | `/api/v1/service-bindings/:id` | Delete a binding |

### Health

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/health` | Service health check |

---

## Quick Start

### Build and run locally

```bash
cd private-link
dub run --config=defaultRun
```

### Docker

```bash
docker build -t uim-private-link-platform-service .
docker run -p 8087:8087 \
  -e PRIVLINK_HOST=0.0.0.0 \
  -e PRIVLINK_PORT=8087 \
  uim-private-link-platform-service
```

### Podman

```bash
podman build -t uim-private-link-platform-service -f Containerfile .
podman run -p 8087:8087 uim-private-link-platform-service
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Storage Backends

| Backend | Activation | Notes |
|---|---|---|
| **In-memory** | default (no env vars) | Lost on restart |
| **File (NDJSON)** | `PRIVLINK_DATA_DIR=/var/lib/private-link` | Persisted NDJSON files |
| **MongoDB** | `PRIVLINK_MONGO_URI=mongodb://...` | Full persistence |

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PRIVLINK_HOST` | `0.0.0.0` | Bind address |
| `PRIVLINK_PORT` | `8087` | Listen port |
| `PRIVLINK_MONGO_URI` | *(empty)* | MongoDB connection string |
| `PRIVLINK_DATA_DIR` | *(empty)* | File storage directory |

---

## Project Structure

```
private-link/
├── dub.sdl                     # DUB build configuration
├── Dockerfile                  # Multi-stage Docker build
├── Containerfile               # Podman / OCI compatible
├── README.md
├── UML.md                      # UML class/sequence diagrams
├── NAFv4.md                    # NAF v4 architecture views
├── k8s/
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── source/
    ├── app.d                   # Entry point
    └── uim/platform/private_link/
        ├── domain/             # Entities, ports, domain services
        ├── application/        # Use cases, DTOs
        ├── presentation/       # HTTP, CLI, Web, GUI layers
        ├── infrastructure/     # Config, DI, persistence adapters
        └── helpers/
```

---

## License

Apache-2.0 — Copyright © 2018-2026 Ozan Nurettin Süel
