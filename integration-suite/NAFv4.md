# NAF v4 Architecture Description — Integration Suite Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Integration Suite Service — Cloud Integration (iPaaS), API Management,
> Advanced Event Mesh, B2B / Trading Partner Management, and Message Mapping.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Integration Suite
├── C1.1  Cloud Integration (iPaaS)
│   ├── C1.1.1  Integration Package management (versioned artefact containers)
│   ├── C1.1.2  Integration Flow design and deployment
│   │   ├── C1.1.2.1  Sender / receiver adapter configuration (HTTP, SOAP, REST,
│   │   │             OData, SFTP, JDBC, JMS, AMQP, Kafka, Mail, S/4HANA, …)
│   │   ├── C1.1.2.2  Message processing step orchestration
│   │   └── C1.1.2.3  Deploy / undeploy lifecycle management
│   └── C1.1.3  Message Mapping (structure transformations)
│       ├── C1.1.3.1  Source/target standard catalogue (EDI, IDoc, XML, JSON)
│       └── C1.1.3.2  Mapping expression evaluation
│
├── C1.2  API Management
│   ├── C1.2.1  API Proxy management
│   │   ├── C1.2.1.1  Policy chain composition (security, quota, spike-arrest,
│   │   │             cache, analytics, mediation, transform, routing)
│   │   └── C1.2.1.2  Draft → Published → Deprecated → Retired lifecycle
│   └── C1.2.2  API Product management
│       ├── C1.2.2.1  Proxy bundling into products
│       ├── C1.2.2.2  Scope and environment assignment
│       └── C1.2.2.3  Public / internal visibility control
│
├── C1.3  Advanced Event Mesh
│   ├── C1.3.1  Message Queue provisioning and lifecycle
│   │   ├── C1.3.1.1  Configurable size / retention / dead-letter queues
│   │   └── C1.3.1.2  Active / Suspended / Deleted status management
│   └── C1.3.2  Topic Subscription management
│       ├── C1.3.2.1  Pattern-based topic routing to queues
│       └── C1.3.2.2  Protocol plug-in (HTTP, AMQP, MQTT, …)
│
├── C1.4  B2B / Trading Partner Management
│   ├── C1.4.1  Trading partner registry (EDI X12, EDIFACT, AS2, XML, …)
│   ├── C1.4.2  Partner type classification (trading partner, company)
│   └── C1.4.3  Contact and system identifier management
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Multi-tenant isolation via X-Tenant-Id header
    ├── C1.5.2  Health monitoring (liveness / readiness probes)
    └── C1.5.3  Structured JSON error responses
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a SAP Integration Suite-compatible integration platform service covering iPaaS, API management, event mesh, and B2B capabilities. |
| **Vision** | Enable integration developers, API designers, and B2B operators to design, deploy, and monitor end-to-end integration scenarios through a unified REST API, CLI, web UI, and GUI. |
| **Scope** | Integration flows (end-to-end message exchange), API proxies/products (API gateway), event queues/subscriptions (pub/sub), and trading partner agreements. |
| **Stakeholders** | Integration Developers, API Designers, B2B Specialists, Platform Operators, Enterprise Architects. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Integration Suite Service Offerings
├── SVC-CI       Cloud Integration Service
│   ├── SVC-CI-PKG   Package Service (CRUD + versioning)
│   ├── SVC-CI-FLOW  Flow Service (CRUD + deploy/undeploy)
│   └── SVC-CI-MAP   Message Mapping Service (CRUD + evaluation)
├── SVC-APIM     API Management Service
│   ├── SVC-APIM-PROXY   API Proxy Service (CRUD + publish)
│   └── SVC-APIM-PROD    API Product Service (CRUD + publish)
├── SVC-AEM      Advanced Event Mesh Service
│   ├── SVC-AEM-QUEUE    Queue Service (CRUD + lifecycle)
│   └── SVC-AEM-SUB      Subscription Service (CRUD + queue filter)
├── SVC-B2B      B2B Service
│   └── SVC-B2B-PARTNER  Trading Partner Service (CRUD + activate)
└── SVC-HEALTH   Health Monitoring Service
```

### NSOV-2 – Service Definitions

| Service ID | Endpoint | Methods | Description |
|---|---|---|---|
| SVC-CI-PKG | `/api/v1/integration/packages` | GET, POST, PUT, DELETE | Integration package lifecycle |
| SVC-CI-FLOW | `/api/v1/integration/flows` | GET, POST, PUT, DELETE | Integration flow lifecycle |
| SVC-CI-FLOW-DEPLOY | `/api/v1/integration/flows/deploy/:id` | POST | Deploy integration flow |
| SVC-CI-MAP | `/api/v1/integration/mappings` | GET, POST, PUT, DELETE | Message mapping lifecycle |
| SVC-APIM-PROXY | `/api/v1/apimanagement/proxies` | GET, POST, PUT, DELETE | API proxy lifecycle |
| SVC-APIM-PROXY-PUB | `/api/v1/apimanagement/proxies/publish/:id` | POST | Publish API proxy |
| SVC-APIM-PROD | `/api/v1/apimanagement/products` | GET, POST, PUT, DELETE | API product lifecycle |
| SVC-APIM-PROD-PUB | `/api/v1/apimanagement/products/publish/:id` | POST | Publish API product |
| SVC-AEM-QUEUE | `/api/v1/eventmesh/queues` | GET, POST, PUT, DELETE | Message queue lifecycle |
| SVC-AEM-SUB | `/api/v1/eventmesh/subscriptions` | GET, POST, PUT, DELETE | Topic subscription lifecycle |
| SVC-B2B-PARTNER | `/api/v1/b2b/partners` | GET, POST, PUT, DELETE | Trading partner lifecycle |
| SVC-HEALTH | `/api/v1/health` | GET | Service health status |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
┌──────────────────────────────────────────────────────────────────────────┐
│  External Consumers                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐  ┌─────────────┐ │
│  │ Integration │  │ API Gateway │  │ Event Producer │  │  B2B System │ │
│  │  Developer  │  │   Client    │  │   / Consumer   │  │  (Partner)  │ │
│  └──────┬──────┘  └──────┬──────┘  └───────┬────────┘  └──────┬──────┘ │
└─────────┼────────────────┼─────────────────┼─────────────────┼──────────┘
          │  REST/HTTP      │  REST/HTTP       │  REST/HTTP       │  REST/HTTP
          ▼                 ▼                  ▼                  ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    Integration Suite Service (:8096)                   │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │  Cloud       │  │  API        │  │  Event Mesh  │  │  B2B       │  │
│  │  Integration │  │  Management │  │              │  │  Service   │  │
│  │  Controller  │  │  Controller │  │  Controller  │  │  Controller│  │
│  └──────┬───────┘  └──────┬──────┘  └──────┬───────┘  └─────┬─────┘  │
│         │                 │                 │                │         │
│  ┌──────▼──────────────────▼─────────────────▼────────────────▼──────┐ │
│  │                     Application Use Cases                         │ │
│  └──────────────────────────────┬────────────────────────────────────┘ │
│  ┌───────────────────────────────▼────────────────────────────────────┐ │
│  │               Domain (Entities + Ports + Validators)               │ │
│  └───────────────────────────────┬────────────────────────────────────┘ │
│  ┌───────────────────────────────▼────────────────────────────────────┐ │
│  │   Infrastructure (Memory │ File │ MongoDB Repositories)            │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Key Relationships |
|---|---|
| `IntegrationPackage` | Contains 0..* `IntegrationFlow`, 0..* `MessageMapping` |
| `IntegrationFlow` | Belongs to `IntegrationPackage`; has sender/receiver `AdapterType` |
| `MessageMapping` | Belongs to `IntegrationPackage`; source/target standard pair |
| `ApiProxy` | Standalone; policy chain; lifecycle status |
| `ApiProduct` | References 1..* `ApiProxy`; has scopes and environments |
| `MessageQueue` | Standalone; contains dead-letter config; 0..* `TopicSubscription` |
| `TopicSubscription` | Belongs to `MessageQueue`; topic pattern + protocol/endpoint |
| `TradingPartner` | Standalone; B2B standard; contact info |
| `IntegrationUser` | Standalone; role (developer, operator, admin, viewer) |

All entities carry `TenantId` for multi-tenant isolation and `id`, `createdAt`, `updatedAt` fields from the `TenantEntity` mixin.

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

#### Docker / Podman (single container)

```
Host OS
└── Container Runtime (Docker / Podman)
    └── integration-suite container
        ├── Binary: uim-integration-suite-platform-service
        ├── Port: 8096 (HTTP)
        └── Storage: in-memory (default)
```

#### Kubernetes

```
Kubernetes Cluster
└── Namespace: uim-platform
    ├── ConfigMap: integration-suite-config
    │   └── INTEGRATION_SUITE_HOST=0.0.0.0
    │   └── INTEGRATION_SUITE_PORT=8096
    ├── Deployment: integration-suite
    │   └── Pod: integration-suite-<hash>
    │       └── Container: integration-suite
    │           ├── Image: uim-platform/integration-suite:latest
    │           ├── Port: 8096
    │           ├── LivenessProbe: GET /api/v1/health
    │           ├── ReadinessProbe: GET /api/v1/health
    │           └── Resources: 64Mi–256Mi RAM, 100m–500m CPU
    └── Service: integration-suite (ClusterIP :8096)
```

**Build pipeline:**
1. Stage 1 — `dlang2/ldc-ubuntu:1.40.1` compiles release binary via `dub build`
2. Stage 2 — `ubuntu:24.04` minimal runtime; non-root `appuser`

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

#### Request / Response Contract

All endpoints accept and return `application/json`. Request bodies use camelCase field names. Tenant is resolved from the `X-Tenant-Id` HTTP header.

**Successful response (single entity):**
```json
{
  "id": "pkg-001",
  "tenantId": "tenant-a",
  "name": "My Package",
  "version": "1.0.0",
  "status": "draft",
  ...
}
```

**Successful response (collection):**
```json
[
  { "id": "pkg-001", ... },
  { "id": "pkg-002", ... }
]
```

**Error response:**
```json
{ "error": "Package name is required" }
```

**Health response:**
```json
{ "status": "UP", "service": "integration-suite" }
```

#### Enum Values

| Enum | Values |
|---|---|
| `ArtifactStatus` | `draft`, `deployed`, `undeployed`, `starting`, `stopping`, `error` |
| `DeploymentStatus` | `stopped`, `running`, `error` |
| `FlowDirection` | `inbound`, `outbound`, `bidirectional` |
| `AdapterType` | `http`, `soap`, `rest`, `odata`, `sftp`, `jdbc`, `jms`, `amqp`, `kafka`, `mail`, `successFactors`, `s4hana`, `ariba`, `openConnector` |
| `PolicyType` | `security`, `quota`, `spikeArrest`, `cache`, `analytics`, `mediation`, `transform`, `routing` |
| `ApiProxyStatus` | `draft`, `published`, `deprecated`, `retired` |
| `QueueStatus` | `active`, `suspended`, `deleted` |
| `SubscriptionStatus` | `active`, `inactive`, `error` |
| `PartnerType` | `tradingPartner`, `company` |
| `B2bStandard` | `ediX12`, `edifact`, `as2`, `xml`, `json`, `idoc`, `other` |
| `MappingStatus` | `draft`, `active`, `inactive` |
| `IntegrationUserRole` | `developer`, `operator`, `admin`, `viewer` |
