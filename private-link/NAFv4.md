# NAF v4 Architecture Views — SAP Private Link Service (UIM Platform)

> **NATO Architecture Framework v4 (NAFv4)** structured views for the
> Private Link Service microservice within UIM Platform.

---

## NV-1 — Overview & Scope

| Attribute | Value |
|---|---|
| **System Name** | UIM Private Link Platform Service |
| **Version** | 1.0.0 |
| **Date** | 2026-05-25 |
| **Status** | Development |
| **Owner** | UI Manufaktur / Ozan Nurettin Süel |
| **License** | Apache-2.0 |
| **Language** | D (dlang) with vibe.d framework |
| **Architecture Style** | Hexagonal (Ports & Adapters) + Clean Architecture |

### Mission Statement

Provide private, non-public-internet connectivity between applications running
on a cloud platform (SAP BTP analog) and IaaS provider services (Azure, AWS,
GCP) by managing private endpoints, service instances, and application bindings.

### Scope

- Full lifecycle management of private link **service instances**
- Approval workflow for **private endpoints** issued by IaaS providers
- **Service bindings** that deliver hostname + private IP to consuming applications
- Multi-tenant isolation across all resources
- Pluggable storage: in-memory, NDJSON file-based, MongoDB

---

## NV-2 — Capability Taxonomy

```
Private Link Service
├── Instance Management
│   ├── Create service instance (specify IaaS resource ID, provider, plan)
│   ├── Read / list service instances
│   ├── Update instance metadata
│   └── Delete instance (cascades endpoint + bindings)
├── Endpoint Management
│   ├── Provision private endpoint (triggers IaaS provider workflow)
│   ├── Approve private endpoint (supply IP, hostname, port from IaaS side)
│   ├── Reject / disconnect endpoint
│   ├── Update endpoint status
│   └── Delete endpoint
├── Binding Management
│   ├── Create service binding (requires instance.status == ready)
│   ├── List / get bindings (returns hostname + IP credentials)
│   └── Delete binding
├── Observability
│   └── Health check endpoint (/api/v1/health)
└── Storage Adapters
    ├── In-memory (default)
    ├── File-based NDJSON (PRIVLINK_DATA_DIR)
    └── MongoDB (PRIVLINK_MONGO_URI)
```

---

## NOV-1 — Operational Concept

```
┌───────────────────────────────────────────────────────────────────┐
│                        Cloud Platform (BTP)                       │
│                                                                   │
│  ┌──────────────────────┐     ┌────────────────────────────────┐  │
│  │   Application / CF   │────▶│  Private Link Service (8087)   │  │
│  │   (consuming app)    │     │  - Service Instances           │  │
│  │                      │     │  - Private Endpoints           │  │
│  └──────────────────────┘     │  - Service Bindings            │  │
│                               └───────────────┬────────────────┘  │
└───────────────────────────────────────────────┼───────────────────┘
                                                │ Private Network
                                                │ (no public internet)
┌───────────────────────────────────────────────┼───────────────────┐
│                    IaaS Provider Account       │                   │
│                                               ▼                   │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │  IaaS Service (Azure Storage / AWS RDS / GCP SQL / ...)    │   │
│  │  Private Endpoint: 10.0.1.5 / my-svc.privatelink.azure.com │   │
│  └────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────┘
```

### Operational Steps

1. **Operator** creates a `ServiceInstance` by providing the IaaS resource ID.
2. Service creates a `PrivateEndpoint` with status `pendingAcceptance`.
3. **IaaS Provider** approves the connection, calling `POST .../approve` with
   the assigned private IP address and hostname.
4. Instance status transitions to `ready`.
5. **Application** creates a `ServiceBinding`; receives the hostname + IP.
6. Application connects to the IaaS service over the private network.

---

## NOV-2 — Operational Node Connectivity

```
┌─────────────────────────────────────────────────────────────┐
│  Node: BTP Platform                                         │
│                                                             │
│  ┌──────────────────┐  REST/HTTP   ┌──────────────────────┐ │
│  │  Admin / DevOps  │─────────────▶│  Private Link HTTP   │ │
│  │  (CF CLI / UI)   │              │  Controller :8087    │ │
│  └──────────────────┘              └──────────┬───────────┘ │
│                                               │             │
│  ┌──────────────────────────────────────────┐ │             │
│  │  Consuming Application (CF App)          │ │             │
│  │  Uses hostname from ServiceBinding       │ │             │
│  └──────────────────────────────────────────┘ │             │
└───────────────────────────────────────────────┼─────────────┘
                                                │ Private Link
┌───────────────────────────────────────────────▼─────────────┐
│  Node: IaaS Provider (Azure / AWS / GCP)                    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  IaaS Service with Private Endpoint                  │   │
│  │  Calls POST /api/v1/private-endpoints/:id/approve    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## NSV-1 — Service Taxonomy

| Service | Interface | Protocol | Port |
|---|---|---|---|
| Service Instance Management | REST JSON | HTTP/1.1 | 8087 |
| Private Endpoint Management | REST JSON | HTTP/1.1 | 8087 |
| Service Binding Management | REST JSON | HTTP/1.1 | 8087 |
| Health Check | REST JSON | HTTP/1.1 | 8087 |

---

## NSV-2 — System & Service Interconnect

```
External Clients
  │
  ├── CF CLI / BTP Cockpit ──────────────────────▶ POST /api/v1/service-instances
  ├── IaaS Provider callback ────────────────────▶ POST /api/v1/private-endpoints/:id/approve
  └── Application (via binding credentials) ─────▶ TCP private network (no HTTP to this service)

Internal Components
  HTTP Controllers ──▶ Use Cases ──▶ Domain Services ──▶ Repositories ──▶ Storage
```

---

## NSV-4 — Technology Forecast

| Layer | Technology | Version | Rationale |
|---|---|---|---|
| Language | D (dlang) | LDC 1.40 | Performance, safety, systems-level |
| HTTP framework | vibe.d | 0.10.x | Async I/O, URLRouter, JSON |
| Build system | DUB | 1.x | D standard package manager |
| Containerisation | Docker / Podman | latest | OCI-compliant images |
| Orchestration | Kubernetes | 1.28+ | Production deployment |
| Storage (default) | In-memory | — | Zero-config, development |
| Storage (optional) | MongoDB | 7.x | Persistent production storage |
| Storage (optional) | NDJSON files | — | Lightweight persistence |

---

## NTV-1 — Technical Standards Profile

| Standard | Specification |
|---|---|
| REST API | HTTP/1.1, JSON bodies, ISO 8601 timestamps |
| Container image | OCI Image Specification 1.0 |
| Kubernetes | Deployment + Service + ConfigMap |
| Security | Non-root container user, read-only filesystem, no privilege escalation |
| Health | `GET /api/v1/health` → `{"status":"UP","service":"private-link"}` |
| Tenant isolation | Every entity carries `tenantId`; all queries are tenant-scoped |
| Error responses | `{"message":"...","statusCode":<int>}` |

---

## NCV-1 — Concept of Operations for Containers

### Docker

```bash
# Build
docker build -t uim-private-link-platform-service:1.0.0 .

# Run (in-memory)
docker run --rm -p 8087:8087 uim-private-link-platform-service:1.0.0

# Run (MongoDB)
docker run --rm -p 8087:8087 \
  -e PRIVLINK_MONGO_URI=mongodb://mongo:27017/private_link \
  uim-private-link-platform-service:1.0.0
```

### Podman

```bash
podman build -t uim-private-link-platform-service:1.0.0 -f Containerfile .
podman run --rm -p 8087:8087 uim-private-link-platform-service:1.0.0
```

### Kubernetes

```bash
kubectl apply -f k8s/
kubectl rollout status deployment/uim-private-link-platform-service
kubectl port-forward svc/uim-private-link-platform-service 8087:8087
curl http://localhost:8087/api/v1/health
```

---

## NCV-2 — Deployment View

```
Kubernetes Cluster (namespace: uim-platform)
│
├── ConfigMap: private-link-config
│   └── PRIVLINK_HOST=0.0.0.0
│   └── PRIVLINK_PORT=8087
│
├── Deployment: uim-private-link-platform-service
│   └── Pod: uim-private-link-platform-service-<hash>
│       └── Container: private-link
│           ├── Image: uim-private-link-platform-service:latest
│           ├── Port: 8087
│           ├── Resources: req(64Mi/50m) lim(256Mi/500m)
│           ├── LivenessProbe:  GET /api/v1/health
│           └── ReadinessProbe: GET /api/v1/health
│
└── Service: uim-private-link-platform-service
    └── Type: ClusterIP
    └── Port: 8087 → 8087
```

---

## NSOV-1 — Security Architecture

| Control | Implementation |
|---|---|
| Container hardening | Non-root user (UID 1000), `readOnlyRootFilesystem: true`, all capabilities dropped |
| Tenant isolation | `tenantId` required on every request (`X-Tenant-Id` header); enforced in all use cases |
| No credential leakage | ServiceBinding response does not include IaaS credentials; only hostname + private IP |
| Transport | Deploy behind TLS-terminating ingress in production (not handled in service itself) |
| Injection prevention | All inputs validated at use case boundary before persistence |
| Dependency | Only `uim-platform:service` and vibe.d dependencies |
