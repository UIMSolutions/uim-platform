# NAFv4 Architecture — SAP Build Code Platform Service

## 1. Architecture Overview (Ar)

### 1.1 Strategic Context

The **SAP Build Code Platform Service** is a UIM Platform microservice that models the capabilities of the SAP BTP **SAP Build Code** offering. It provides a unified REST API for managing the full lifecycle of enterprise application development: from AI-assisted scaffolding and coding through CI/CD pipelines to multi-environment deployments.

The service is a self-contained bounded context within the UIM Platform landscape, operating alongside peer services such as datasphere, ai-core, logging, and connectivity.

### 1.2 Architectural Style

| Dimension | Decision |
|-----------|----------|
| Architectural pattern | Hexagonal (Ports & Adapters) + Clean Architecture |
| Language / runtime | D (dlang) compiled with LDC 1.40.1 |
| HTTP framework | vibe.d 0.10.x / vibe-http 1.4.x |
| Persistence | In-memory (HashMap) — swappable via repository ports |
| Configuration | Environment variables (`BUILD_CODE_HOST`, `BUILD_CODE_PORT`) |
| Container | OCI-compliant; Dockerfile + Containerfile (multi-stage LDC → ubuntu:24.04) |
| Orchestration | Kubernetes 1.29+ (Deployment, Service, ConfigMap) |
| Dependency injection | Manual / compile-time via `buildContainer()` |

---

## 2. Capability Architecture (C)

### 2.1 Business Capabilities Modelled

| Capability | Domain Entity | Key Operations |
|-----------|--------------|----------------|
| Project Management | `Project` | Create, configure, list, archive projects |
| Dev Space Management | `DevSpace` | Provision BAS-style cloud IDE workspaces |
| Template Catalogue | `ProjectTemplate` | Manage scaffolding templates (CAP/Fiori/SAPUI5/Mobile) |
| CI/CD Pipeline Management | `Pipeline` | Define build/test/deploy pipelines with trigger strategies |
| Build Job Execution | `BuildJob` | Trigger pipeline runs, track status, store artefact references |
| Deployment Management | `Deployment` | Deploy artefacts to Cloud Foundry, Kyma, ABAP Cloud |
| AI Code Generation | `AIRequest` | Submit Joule prompts (data model, service, UI, sample data, code fragment) |
| Service Binding Management | `ServiceBinding` | Bind BTP services (HANA, Auth, Destination, …) to projects |

---

## 3. Systems Architecture (S)

### 3.1 Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────────┐
│  Presentation (HTTP)                                            │
│  ProjectController · DevSpaceController · TemplateController    │
│  PipelineController · BuildJobController · DeploymentController │
│  AIRequestController · ServiceBindingController · Health        │
├─────────────────────────────────────────────────────────────────┤
│  Application                                                    │
│  ManageProjectsUseCase · ManageDevSpacesUseCase                 │
│  ManageTemplatesUseCase · ManagePipelinesUseCase                │
│  ManageBuildJobsUseCase · ManageDeploymentsUseCase              │
│  ManageAIRequestsUseCase · ManageServiceBindingsUseCase         │
├─────────────────────────────────────────────────────────────────┤
│  Domain                                                         │
│  Entities · Repository Interfaces · ProjectValidator            │
│  QuotaService                                                   │
├─────────────────────────────────────────────────────────────────┤
│  Infrastructure                                                 │
│  MemoryXxxRepository (×8) · AppConfig · Container              │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Dependency Rule

All source-code dependencies point **inward**: Infrastructure → Application → Domain. The Domain layer has zero dependencies on any outer layer or framework.

### 3.3 Repository Port Contracts

| Interface | Key Query Methods |
|-----------|------------------|
| `ProjectRepository` | findByStatus, findByType, findByOwner, nameExists |
| `DevSpaceRepository` | findByProject, findByStatus |
| `TemplateRepository` | findByProjectType, findByTechStack, findBuiltIn |
| `PipelineRepository` | findByProject, findByStage, findActive |
| `BuildJobRepository` | findByPipeline, findByProject, findByStatus, findByBranch |
| `DeploymentRepository` | findByProject, findByEnvironment, findByStatus, findByBuildJob |
| `AIRequestRepository` | findByProject, findByStatus, findByType, findByUser |
| `ServiceBindingRepository` | findByProject, findByServiceName, findByStatus |

---

## 4. Technology Architecture (T)

### 4.1 Runtime Stack

| Component | Version | Role |
|-----------|---------|------|
| LDC (LLVM D Compiler) | 1.40.1 | D compiler — produces native binary |
| vibe.d | 0.10.x | HTTP server, JSON serialisation, async I/O |
| vibe-http | 1.4.x | HTTP request/response types, URLRouter |
| vibe-serialization | 1.2.x | Json type used throughout |
| dub | — | Package manager and build system |

### 4.2 Build Pipeline

```
dub build --build=release --config=defaultRun
  → ./build/uim-build-code-platform-service
```

Multi-stage Docker build:
1. **Stage 1** (`dlang2/ldc-ubuntu:1.40.1`): compile binary
2. **Stage 2** (`ubuntu:24.04`): copy binary, run as non-root `appuser` (UID 1000)

### 4.3 Security Controls

| Control | Implementation |
|---------|---------------|
| Non-root container | `USER appuser` (UID 1000) |
| Read-only root filesystem | `readOnlyRootFilesystem: true` |
| No privilege escalation | `allowPrivilegeEscalation: false` |
| Dropped capabilities | `capabilities.drop: [ALL]` |
| Service credentials excluded from JSON | `ServiceBinding.toJson()` omits `credentials` field |
| Input validation | `ProjectValidator` (name length, charset, prompt length) |
| Quota enforcement | `QuotaService` prevents resource exhaustion |

---

## 5. Information Architecture (I)

### 5.1 Entity Lifecycle States

**Project**: `active` → `inactive` → `archived`

**DevSpace**: `starting` → `running` ↔ `stopped` (+ `stopping`, `error`)

**BuildJob**: `queued` → `running` → `succeeded` | `failed` | `cancelled`

**Deployment**: `pending` → `deploying` → `succeeded` | `failed` | `rolling_back`

**AIRequest**: `pending` → `processing` → `completed` | `failed`

**ServiceBinding**: `active` | `inactive` | `error`

### 5.2 Multi-Tenancy

All entities carry a `tenantId` field. Every repository query is scoped to the given tenant via the `X-Tenant-Id` HTTP header. Entities from different tenants are never co-mingled in query results.

### 5.3 AI Generation Asynchrony

`POST /api/v1/buildcode/ai/generate` returns `202 Accepted` with a request ID. The caller polls `GET /api/v1/buildcode/ai/requests/:id` until `status == "completed"`. This pattern decouples the HTTP request lifetime from the (potentially long-running) AI model invocation.

---

## 6. Operational Architecture (O)

### 6.1 Health Monitoring

- `GET /api/v1/health` → `{"status":"UP","service":"SAP Build Code Platform Service"}`
- Kubernetes liveness and readiness probes both target this endpoint.

### 6.2 Resource Limits (Kubernetes)

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 500m |
| Memory | 128Mi | 512Mi |

### 6.3 Configuration Management

All runtime configuration is externalised via environment variables and mounted from a Kubernetes ConfigMap (`build-code-config`), supporting twelve-factor app principles.

### 6.4 Scalability Path

Horizontal scaling requires replacing the in-memory repositories with a distributed store (Redis, PostgreSQL, SAP HANA). The port interfaces are the only change surface — no application or presentation layer changes are required.

---

## 7. Service Integration Map

```
uim-build-code-platform-service  (port 8098)
  │
  ├── [triggers]  uim-ai-core-platform-service      (AI model invocation)
  ├── [notifies]  uim-alert-notification-platform-service
  ├── [logs to]   uim-logging-platform-service
  ├── [auth via]  uim-authorization-trust-platform-service
  ├── [connects]  uim-connectivity-platform-service
  └── [deploys to] Cloud Foundry / Kyma runtime
```
