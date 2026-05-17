# NAF v4 Architecture Description — AI Launchpad Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> AI Launchpad Service — unified management interface for AI runtimes, workspaces,
> ML lifecycle, Generative AI Hub, prompt management, and model cataloguing.

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
AI Launchpad
├── C1.1  Workspace Management
│   ├── C1.1.1  Multi-runtime workspace provisioning (AI Core, BTP)
│   ├── C1.1.2  Connection configuration
│   └── C1.1.3  Resource group scoping
│
├── C1.2  ML Lifecycle (Training)
│   ├── C1.2.1  Scenario management
│   ├── C1.2.2  Configuration management
│   ├── C1.2.3  Execution management and status tracking
│   └── C1.2.4  Dataset registration and management
│
├── C1.3  Model Deployment
│   ├── C1.3.1  Deployment provisioning
│   ├── C1.3.2  Model catalogue management
│   └── C1.3.3  Deployment status lifecycle
│
├── C1.4  Generative AI Hub
│   ├── C1.4.1  Prompt collection management
│   ├── C1.4.2  Prompt authoring and versioning
│   └── C1.4.3  Model listing by provider and capability
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Tenant isolation
    └── C1.5.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a unified AI lifecycle management interface modelled on SAP AI Launchpad. |
| **Vision** | Enable business users, data scientists, and AI engineers to manage AI runtimes, monitor training runs, deploy models, and compose Generative AI prompts through a single REST API. |
| **Scope** | Workspace provisioning, ML training and deployment lifecycle, and Generative AI Hub prompt management. |
| **Stakeholders** | AI Engineers, Data Scientists, Business Analysts, Platform Operators. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
AI Launchpad Service Offerings
├── SVC-WS     Workspace Service
├── SVC-RG     Resource Group Service
├── SVC-CON    Connection Service
├── SVC-SCN    Scenario Service
├── SVC-EXEC   Execution Service
├── SVC-DEP    Deployment Service
├── SVC-MOD    Model Catalogue Service
├── SVC-CFG    Configuration Service
├── SVC-DS     Dataset Service
├── SVC-PROM   Prompt Service
├── SVC-PC     Prompt Collection Service
└── SVC-HLTH   Health Service
```

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-WS-CRUD | Workspace Management | `/api/v1/workspaces` | GET, POST, PUT, DELETE |
| SVC-RG-CRUD | Resource Group | `/api/v1/resource-groups` | GET, POST, DELETE |
| SVC-CON-CRUD | Connection | `/api/v1/connections` | GET, POST, PUT, DELETE |
| SVC-SCN-CRUD | Scenario | `/api/v1/scenarios` | GET, POST, DELETE |
| SVC-EXEC-CRUD | Execution | `/api/v1/executions` | GET, POST, DELETE |
| SVC-DEP-CRUD | Deployment | `/api/v1/deployments` | GET, POST, PATCH, DELETE |
| SVC-MOD-CRUD | Model Catalogue | `/api/v1/models` | GET, POST, DELETE |
| SVC-CFG-CRUD | Configuration | `/api/v1/configurations` | GET, POST, DELETE |
| SVC-DS-CRUD | Dataset | `/api/v1/datasets` | GET, POST, DELETE |
| SVC-PC-CRUD | Prompt Collection | `/api/v1/prompt-collections` | GET, POST, DELETE |
| SVC-PROM-CRUD | Prompt | `/api/v1/prompts` | GET, POST, PUT, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  AI Engineer /      │ ─────────────────> │  AI Launchpad Service        │
│  Business User      │                    │  port 10002                   │
└────────────────────┘                    └──────────────┬───────────────┘
                                                          │
                              ┌───────────────────────────▼──────────────────┐
                              │         UIM Platform (In-Memory Store)       │
                              └──────────────────────────────────────────────┘
```

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Key Relationships |
|---|---|
| `Workspace` | Root aggregate; scopes all other entities |
| `ResourceGroup` | Belongs to Workspace; groups compute resources |
| `Connection` | Belongs to Workspace; references external AI runtime (AI Core, etc.) |
| `Scenario` | Belongs to Workspace; parent of Configurations and Executions |
| `Configuration` | Parameterizes a Scenario; parent of Executions and Deployments |
| `Execution` | Training run; lifecycle: pending → running → completed/failed |
| `Deployment` | Serving runtime; lifecycle: unknown → running → stopped |
| `Model` | Catalogue entry for available foundation/fine-tuned models |
| `Dataset` | Input dataset registered for training |
| `PromptCollection` | Named group of Prompts for the Generative AI Hub |
| `Prompt` | A single Generative AI prompt; references a model |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
Kubernetes Cluster — Namespace: uim-platform
│
├── ConfigMap: ai-launchpad-config
│   AI_LAUNCHPAD_HOST: "0.0.0.0"
│   AI_LAUNCHPAD_PORT: "10002"
│
├── Deployment: ai-launchpad
│   replicas: 1
│   image: uim-platform/ai-launchpad:latest
│   port: 10002
│   livenessProbe:  GET /api/v1/health :10002
│   readinessProbe: GET /api/v1/health :10002
│   resources: { req: 64Mi/100m, limit: 256Mi/500m }
│   securityContext: runAsNonRoot
│
└── Service: ai-launchpad (ClusterIP :10002)
```

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

| Information Object | Format | Transport | Notes |
|---|---|---|---|
| Workspace | JSON | REST over HTTP | Multi-runtime; root aggregate |
| Prompt | JSON | REST over HTTP | Versioned; content + model reference |
| Execution | JSON | REST over HTTP | Status lifecycle |
| Deployment | JSON | REST over HTTP | targetStatus drives transitions |
| Model | JSON | REST over HTTP | Catalogue entry; capability flags |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Workspace as root aggregate | Mirrors SAP AI Launchpad's workspace scoping model |
| AD-2 | Generative AI Hub via Prompt/PromptCollection | Captures SAP AI Launchpad GenAI Hub pattern |
| AD-3 | Port 10002 | High-numbered port for AI/ML services |
| AD-4 | In-memory repositories | Fast testing and portability |
| AD-5 | Multi-stage Dockerfile / Containerfile | Minimal OCI runtime image |
