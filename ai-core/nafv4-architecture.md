# NAF v4 Architecture Description — AI Core Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> AI Core Service — full ML lifecycle API (AI API v2) covering resource groups,
> scenarios, executables, configurations, executions, deployments, artifacts,
> metrics, and Docker registry secrets.

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
AI Core
├── C1.1  Resource Group Management
│   ├── C1.1.1  Tenant-scoped resource group provisioning
│   ├── C1.1.2  Docker registry secret management
│   └── C1.1.3  Object store secret management
│
├── C1.2  Scenario Management
│   ├── C1.2.1  Scenario registration
│   ├── C1.2.2  Executable cataloguing
│   └── C1.2.3  Artifact registration (Dataset, Model, ResultSet, Other)
│
├── C1.3  Configuration Management
│   ├── C1.3.1  Execution / Deployment configuration
│   └── C1.3.2  Parameter binding
│
├── C1.4  Training Execution
│   ├── C1.4.1  Execution creation and lifecycle (pending → running → completed / failed)
│   ├── C1.4.2  Execution scheduling (cron-based)
│   └── C1.4.3  Metric logging and retrieval
│
├── C1.5  Model Deployment
│   ├── C1.5.1  Deployment provisioning (unknown → running)
│   ├── C1.5.2  Target status management (running / stopped / deleted)
│   └── C1.5.3  Deployment query by configuration
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide an AI API v2-compatible ML lifecycle management service modelled on SAP AI Core. |
| **Vision** | Enable data scientists and MLOps teams to register scenarios, train models, schedule executions, track metrics, and deploy models through a unified REST API. |
| **Scope** | End-to-end ML workflow from artifact registration and training to model deployment and inference. |
| **Stakeholders** | Data Scientists, ML Engineers, Platform Operators, AI Application Developers. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
AI Core Service Offerings
├── SVC-RG     Resource Group Service
├── SVC-SCN    Scenario Service
├── SVC-EXEC   Executable Service
├── SVC-ART    Artifact Service
├── SVC-CFG    Configuration Service
├── SVC-RUN    Execution Service
├── SVC-SCH    Execution Schedule Service
├── SVC-DEP    Deployment Service
├── SVC-MET    Metric Service
├── SVC-DRS    Docker Registry Secret Service
└── SVC-HLTH   Health Service
```

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-RG-CRUD | Resource Group | `/api/v1/resource-groups` | GET, POST, PUT, DELETE |
| SVC-SCN-CRUD | Scenario | `/api/v1/scenarios` | GET, POST, PUT, DELETE |
| SVC-EXEC-CRUD | Executable | `/api/v1/executables` | GET, POST, DELETE |
| SVC-ART-CRUD | Artifact | `/api/v1/artifacts` | GET, POST, DELETE |
| SVC-CFG-CRUD | Configuration | `/api/v1/configurations` | GET, POST, PUT, DELETE |
| SVC-RUN-CRUD | Execution | `/api/v1/executions` | GET, POST, DELETE |
| SVC-RUN-START | Execution Start | `/api/v1/executions/{id}/start` | POST |
| SVC-RUN-STOP | Execution Stop | `/api/v1/executions/{id}/stop` | POST |
| SVC-SCH-CRUD | Execution Schedule | `/api/v1/execution-schedules` | GET, POST, DELETE |
| SVC-DEP-CRUD | Deployment | `/api/v1/deployments` | GET, POST, PATCH, DELETE |
| SVC-MET-CRUD | Metric Logging | `/api/v1/metrics` | GET, POST, DELETE |
| SVC-DRS-CRUD | Docker Registry Secret | `/api/v1/docker-registry-secrets` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
┌─────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  ML Engineer /   │ ─────────────────> │  AI Core Service             │
│  AI Application  │                    │  port 10001                   │
└─────────────────┘                    └──────────────┬───────────────┘
                                                       │
                              ┌────────────────────────▼──────────────────┐
                              │        UIM Platform (In-Memory Store)     │
                              └───────────────────────────────────────────┘
```

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Key Relationships |
|---|---|
| `ResourceGroup` | Root aggregate; scopes Scenarios and DockerRegistrySecrets |
| `Scenario` | Owns Executables, Artifacts, and Configurations |
| `Executable` | Defines the executable code blueprint for a Scenario |
| `Artifact` | Dataset / Model / ResultSet registered for a Scenario |
| `Configuration` | Parameterizes Executables; parent of Executions and Deployments |
| `Execution` | A single training run; produces Metrics; lifecycle: pending→running→completed/failed |
| `ExecutionSchedule` | Cron-based trigger for automatic Executions |
| `Deployment` | A serving runtime for a trained model; lifecycle: unknown→running→stopped |
| `Metric` | Time-stamped metric sample emitted by an Execution |
| `DockerRegistrySecret` | Registry credentials scoped to a ResourceGroup |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
Kubernetes Cluster — Namespace: uim-platform
│
├── ConfigMap: ai-core-config
│   AI_CORE_HOST: "0.0.0.0"
│   AI_CORE_PORT: "10001"
│
├── Deployment: ai-core
│   replicas: 1
│   image: uim-platform/ai-core:latest
│   port: 10001
│   livenessProbe:  GET /api/v1/health :10001
│   readinessProbe: GET /api/v1/health :10001
│   resources: { req: 64Mi/100m, limit: 256Mi/500m }
│   securityContext: runAsNonRoot
│
└── Service: ai-core (ClusterIP :10001)
```

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

| Information Object | Format | Transport | Notes |
|---|---|---|---|
| Scenario | JSON | REST over HTTP | Versioned; scoped to ResourceGroup |
| Artifact | JSON | REST over HTTP | Kind: Dataset, Model, ResultSet, Other |
| Configuration | JSON | REST over HTTP | Links Scenario → Executable |
| Execution | JSON | REST over HTTP | Lifecycle status field; completionStatus on finish |
| Metric | JSON | REST over HTTP | Append-only; timestamped |
| Deployment | JSON | REST over HTTP | targetStatus drives lifecycle transitions |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | AI API v2 alignment | Ensures compatibility with SAP AI Core client tooling |
| AD-2 | In-memory repositories | Fast startup; swap for PostgreSQL in production |
| AD-3 | Port 10001 | High-numbered port space for AI/ML services |
| AD-4 | Execution lifecycle via status enum | Mirrors SAP AI Core status model exactly |
| AD-5 | Immutable metrics | Append-only guarantees; no metric updates |
| AD-6 | Multi-stage Dockerfile / Containerfile | Minimal OCI runtime image |
