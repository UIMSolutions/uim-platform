# NAFv4 Architecture Description — Redis on SAP BTP, Hyperscaler Option

**NATO Architecture Framework v4 (NAFv4)** views for the UIM Platform Redis service.

---

## 1. Architecture Overview (NAFv4 — NV-1: Overview)

| Attribute | Value |
|---|---|
| **Service Name** | Redis on SAP BTP, Hyperscaler Option |
| **Version** | 1.0.0 |
| **Date** | 2026-05-19 |
| **Classification** | Unclassified |
| **Owner** | UIM Platform Team |
| **Technology** | D (dlang), vibe.d, MongoDB, Docker/Podman, Kubernetes |

### Mission Statement
Provide a managed, multi-hyperscaler Redis cache service on SAP BTP that abstracts provisioning, binding, configuration, and operational management of in-memory key–value stores for application teams.

---

## 2. Capability View (NAFv4 — NCV-2: Enterprise Vision)

### Capabilities

```
Redis Platform Service Capabilities
├── C1: Service Instance Management
│   ├── C1.1: Provision Redis Instance
│   ├── C1.2: Update Instance Configuration
│   ├── C1.3: Deprovision Instance
│   └── C1.4: Query Instance Status
├── C2: Service Binding Management
│   ├── C2.1: Create Binding (generate credentials)
│   ├── C2.2: Rotate Credentials
│   └── C2.3: Delete Binding
├── C3: Configuration Management
│   ├── C3.1: Set Eviction Policy
│   ├── C3.2: Configure TLS
│   ├── C3.3: Set Persistence Mode (RDB/AOF)
│   └── C3.4: Configure Keyspace Notifications
├── C4: Cache Data Management
│   ├── C4.1: Read/Write Cache Entries
│   ├── C4.2: Set TTL on Keys
│   └── C4.3: Manage Redis Data Types
├── C5: Operational Monitoring
│   ├── C5.1: Collect Memory Metrics
│   ├── C5.2: Monitor Connection Count
│   ├── C5.3: Track Hit Rate
│   └── C5.4: Observe Eviction/Expiry Statistics
├── C6: Backup and Recovery
│   ├── C6.1: Define Backup Schedule
│   ├── C6.2: Set Retention Policy
│   └── C6.3: Monitor Backup Status
└── C7: Access Control
    ├── C7.1: Manage IP Allowlists
    ├── C7.2: Manage IP Denylists
    └── C7.3: Network Ingress/Egress Rules
```

---

## 3. Operational Node View (NAFv4 — NOV-2: Operational Node Connectivity)

```
┌─────────────────────────────────────────────────────────┐
│                   SAP BTP Platform                       │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │           Redis Platform Service                │    │
│  │                                                 │    │
│  │  ┌────────────┐  ┌──────────────┐               │    │
│  │  │ HTTP REST  │  │  Web UI MVC  │               │    │
│  │  │ Controllers│  │  Controllers │               │    │
│  │  └────────────┘  └──────────────┘               │    │
│  │         │                │                      │    │
│  │  ┌──────▼────────────────▼──────┐               │    │
│  │  │       Use Case Layer         │               │    │
│  │  │  (Manage*UseCase classes)    │               │    │
│  │  └──────────────┬───────────────┘               │    │
│  │                 │                               │    │
│  │  ┌──────────────▼───────────────┐               │    │
│  │  │       Domain Layer           │               │    │
│  │  │  (Entities, Repositories)    │               │    │
│  │  └──────────────┬───────────────┘               │    │
│  │                 │                               │    │
│  │  ┌──────────────▼───────────────┐               │    │
│  │  │   Infrastructure Layer       │               │    │
│  │  │  Memory │ File │ MongoDB      │               │    │
│  │  └──────────────────────────────┘               │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────┐   ┌──────────────────────────────┐     │
│  │  MongoDB    │   │  Hyperscaler Redis Instances  │     │
│  │  (Metadata) │   │  AWS/Azure/GCP/AliCloud       │     │
│  └─────────────┘   └──────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘

External Nodes:
  ┌──────────────────────┐     ┌────────────────────────────┐
  │  App Developer       │────▶│  Redis Platform Service     │
  │  (Consumer)          │     │  :8130 REST API             │
  └──────────────────────┘     └────────────────────────────┘
  
  ┌──────────────────────┐
  │  CF Service Broker   │────▶│  Provision/Bind/Unbind/Delete │
  └──────────────────────┘
```

---

## 4. System View (NAFv4 — NSV-1: System Interface Description)

### System Interfaces

| Interface | Protocol | Format | Description |
|---|---|---|---|
| HTTP REST API | HTTP/1.1 | JSON | Primary programmatic API |
| Web UI | HTTP/1.1 | HTML | Browser-based management UI |
| CLI | stdio | Text | Terminal-based management |
| MongoDB | TCP/27017 | BSON | Metadata persistence |
| Health Endpoint | HTTP/1.1 | JSON | K8s liveness/readiness probes |
| Configuration | Environment Variables | String | Runtime configuration |

### External Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| D Language | 2.x (LDC 1.40.1) | Runtime & compilation |
| vibe.d | 0.10.x | HTTP server, async I/O |
| vibe-http | 1.4.x | HTTP types |
| vibe-data | — | JSON serialization |
| MongoDB | 6.x+ | Production persistence |
| Ubuntu | 24.04 | Runtime container OS |

---

## 5. Technical Standards (NAFv4 — NTV-1: Technical Standards Profile)

| Category | Standard | Notes |
|---|---|---|
| Architecture | Hexagonal (Ports & Adapters) | Domain isolation |
| Architecture | Clean Architecture | Dependency rule enforced |
| Presentation | MVC (Model-View-Controller) | CLI, Web, GUI layers |
| API | REST / JSON | HTTP/1.1 |
| Container | OCI (Docker/Podman) | Multi-stage build |
| Orchestration | Kubernetes 1.26+ | Deployment manifests |
| Security | TLS 1.2+ | In-transit encryption |
| Data | BSON / JSON | MongoDB storage |
| Auth | OAuth2 (delegated) | Service binding credentials |
| Logging | Structured (JSON) | Observability |
| Health | Kubernetes probes | `/health` endpoint |
| Build | DUB | D package manager |
| License | Apache-2.0 | Open source |

---

## 6. Service Instance Lifecycle (NAFv4 — NOV-5: Operational Activity Model)

```
                     ┌──────────────┐
                     │ provisioning │◄──── POST /instances
                     └──────┬───────┘
                            │ (async: hyperscaler allocates)
                     ┌──────▼───────┐
                     │    active    │◄──── GET/PUT /instances/:id
                     └──────┬───────┘
              ┌─────────────┼─────────────┐
              │             │             │
       ┌──────▼──┐   ┌──────▼──┐   ┌─────▼────┐
       │ updating│   │ deleting│   │  failed  │
       └──────┬──┘   └──────┬──┘   └──────────┘
              │             │
       ┌──────▼──┐   ┌──────▼──┐
       │  active │   │ deleted │
       └─────────┘   └─────────┘
```

---

## 7. Persistence Strategy (NAFv4 — NSV-4: Systems Functionality Description)

### Memory Persistence
- **Use**: Unit tests, development demos
- **Thread safety**: D associative arrays with copy-on-write semantics
- **Limitations**: Data lost on restart

### File Persistence
- **Use**: Development / single-node deployments
- **Format**: One JSON file per entity type per tenant
- **Location**: Configurable via `REDIS_FILE_PATH` env var
- **Thread safety**: File-level locking on writes

### MongoDB Persistence
- **Use**: Production deployments
- **Collections**: One collection per entity type
- **Indexing**: `tenantId` + entity-specific fields
- **Connection**: vibe.d MongoClient with configurable URI
- **Resilience**: Connection pooling, automatic reconnect

---

## 8. Security Architecture (NAFv4 — NSV-7: Security Architecture)

| Threat | Mitigation |
|---|---|
| Credential exposure | Binding passwords never logged; excluded from GET responses |
| Unauthorized access | OAuth2 / service binding per application |
| Network sniffing | TLS 1.2+ required for Redis connections |
| IP-based attacks | Network access control (CIDR allowlist/denylist) |
| Injection (NoSQL) | Parameterized MongoDB queries; no string interpolation |
| DoS | Resource limits in K8s (CPU/memory requests & limits) |
| Container escape | Non-root `appuser` in Docker/Podman images |
| Secret sprawl | Secrets via K8s Secrets, not ConfigMap |

---

## 9. Deployment View (NAFv4 — NSV-2: Systems Communication Description)

### Kubernetes Topology

```
Namespace: uim-platform
│
├── Deployment: uim-redis-platform-service
│   ├── Replicas: 1 (scale as needed)
│   ├── Image: uim-redis-platform-service:latest
│   ├── Port: 8130
│   ├── Resources: requests 64Mi/50m  limits 256Mi/500m
│   ├── LivenessProbe: GET /health
│   └── ReadinessProbe: GET /health
│
├── Service: uim-redis-platform-service
│   ├── Type: ClusterIP
│   └── Port: 8130 → 8130
│
└── ConfigMap: uim-redis-platform-config
    ├── REDIS_HOST: 0.0.0.0
    ├── REDIS_PORT: 8130
    └── REDIS_PERSISTENCE: memory
```

### Multi-Stage Docker Build

```
Stage 1 (build): dlang2/ldc-ubuntu:1.40.1
  └─ dub build --build=release --config=defaultRun

Stage 2 (runtime): ubuntu:24.04
  ├─ Copy binary from stage 1
  ├─ Install libcurl, ca-certificates
  ├─ Create non-root appuser
  ├─ EXPOSE 8130
  └─ HEALTHCHECK curl /health
```

---

## 10. Information Exchange (NAFv4 — NIOV-1)

### REST API Request/Response Schema

**ServiceInstance (create request)**
```json
{
  "name": "my-redis",
  "planId": "plan-premium-001",
  "region": "eu-west-1",
  "hyperscaler": "aws",
  "redisVersion": "7.x",
  "memoryMb": 1024,
  "maxConnections": 1000,
  "tlsEnabled": true,
  "haEnabled": true,
  "persistenceMode": "rdb"
}
```

**ServiceInstance (response)**
```json
{
  "id": "inst-abc123",
  "tenantId": "tenant-001",
  "name": "my-redis",
  "status": "provisioning",
  "hyperscaler": "aws",
  "region": "eu-west-1",
  "redisVersion": "7.x",
  "memoryMb": 1024,
  "tlsEnabled": true,
  "haEnabled": true,
  "persistenceMode": "rdb",
  "provisionedAt": 1747612800000,
  "message": "Service instance created successfully",
  "statusCode": 201
}
```

**CommandResult (mutation response)**
```json
{
  "success": true,
  "id": "inst-abc123",
  "error": ""
}
```
