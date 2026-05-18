# SAP Build Code Platform Service

A D/vibe.d microservice modelling the features of **SAP Build Code** — SAP BTP's AI-powered cloud development environment for building enterprise applications.

## Overview

SAP Build Code provides a turnkey development environment with:
- **AI-assisted code generation** (Joule copilot) — generate data models, services, sample data, and UI pages from natural-language prompts
- **Project scaffolding** from curated templates (CAP Java, CAP Node.js, SAP Fiori, SAPUI5, Mobile Services, Spring Boot)
- **Cloud dev spaces** powered by SAP Business Application Studio (BAS)
- **CI/CD pipeline management** — build, test, and deploy pipelines with manual/push/scheduled triggers
- **Multi-environment deployments** — Cloud Foundry, Kyma, ABAP Cloud, Neo
- **Service binding management** — attach BTP services (HANA, Destination, Auth, etc.) to projects

This service is built in **D (LDC 1.40.1)** using **vibe.d 0.10.x** and follows a **Hexagonal + Clean Architecture** layered model.

---

## Architecture

```
source/uim/platform/buildcode/
├── domain/            # Pure business rules — no framework dependencies
│   ├── types.d        # IDs, enums (ProjectType, TechStack, JobStatus, …)
│   ├── entities/      # Project, DevSpace, Template, Pipeline, BuildJob, Deployment,
│   │                  #   AIRequest, ServiceBinding
│   ├── ports/         # Repository interfaces (8 total)
│   └── services/      # ProjectValidator, QuotaService
├── application/       # Use-case orchestration
│   ├── dto.d          # Request/response DTOs
│   └── usecases/manage/  # One use-case class per entity
├── presentation/      # HTTP adapter (driving)
│   └── http/controllers/ # ProjectController, DevSpaceController, …, HealthController
└── infrastructure/    # Driven adapters
    ├── config.d        # AppConfig loaded from env vars
    ├── container.d     # Manual DI wiring
    └── persistence/memory/  # HashMap-backed repositories
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | `/api/v1/health` | Health check |
| GET/POST | `/api/v1/buildcode/projects` | List / create projects |
| GET/PUT/DELETE | `/api/v1/buildcode/projects/:id` | Get / update / delete project |
| GET/POST | `/api/v1/buildcode/devspaces` | List / create dev spaces |
| GET/PUT/DELETE | `/api/v1/buildcode/devspaces/:id` | Get / update status / delete dev space |
| GET/POST | `/api/v1/buildcode/templates` | List / create scaffolding templates |
| GET/DELETE | `/api/v1/buildcode/templates/:id` | Get / delete template |
| GET/POST | `/api/v1/buildcode/pipelines` | List / create CI/CD pipelines |
| GET/PUT/DELETE | `/api/v1/buildcode/pipelines/:id` | Get / update / delete pipeline |
| GET/POST | `/api/v1/buildcode/buildjobs` | List / trigger build job |
| GET/PUT | `/api/v1/buildcode/buildjobs/:id` | Get job / update status |
| GET/POST | `/api/v1/buildcode/deployments` | List / create deployment |
| GET/PUT | `/api/v1/buildcode/deployments/:id` | Get deployment / update status |
| POST   | `/api/v1/buildcode/ai/generate` | Submit Joule AI generation request |
| GET    | `/api/v1/buildcode/ai/requests` | List AI requests |
| GET/PUT | `/api/v1/buildcode/ai/requests/:id` | Get / update AI request |
| GET/POST | `/api/v1/buildcode/servicebindings` | List / create service bindings |
| GET/DELETE | `/api/v1/buildcode/servicebindings/:id` | Get / delete service binding |

### Multi-tenancy
Pass tenant identity via `X-Tenant-Id` HTTP header (defaults to `"default"` for local development).

---

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `BUILD_CODE_HOST` | `0.0.0.0` | Bind address |
| `BUILD_CODE_PORT` | `8098` | TCP port |

---

## Building

### Local (requires LDC)
```bash
cd build-code
dub build --build=release --config=defaultRun
./build/uim-build-code-platform-service
```

### Docker / Podman
```bash
# Docker
docker build -t uim-build-code-platform-service:latest .

# Podman
podman build -t uim-build-code-platform-service:latest -f Containerfile .

# Run
docker run -p 8098:8098 \
  -e BUILD_CODE_HOST=0.0.0.0 \
  -e BUILD_CODE_PORT=8098 \
  uim-build-code-platform-service:latest
```

### Kubernetes
```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Example Requests

### Create a CAP project
```http
POST /api/v1/buildcode/projects
X-Tenant-Id: tenant-1
Content-Type: application/json

{
  "name": "my-cap-app",
  "description": "Sample CAP application",
  "type": "cap",
  "techStack": "cap-nodejs",
  "ownerEmail": "developer@example.com",
  "repositoryUrl": "https://github.com/org/my-cap-app",
  "defaultBranch": "main",
  "tags": ["cap", "demo"]
}
```

### Submit an AI generation request
```http
POST /api/v1/buildcode/ai/generate
X-Tenant-Id: tenant-1
Content-Type: application/json

{
  "projectId": "<project-id>",
  "requestedBy": "developer@example.com",
  "generationType": "data-model",
  "prompt": "Create a CDS data model for an order management system with Orders, OrderItems, and Products entities",
  "targetFilePath": "db/schema.cds"
}
```

### Trigger a pipeline build
```http
POST /api/v1/buildcode/buildjobs
X-Tenant-Id: tenant-1
Content-Type: application/json

{
  "pipelineId": "<pipeline-id>",
  "commitSha": "abc1234",
  "branch": "feature/new-entity",
  "triggeredBy": "developer@example.com"
}
```

---

## Quotas

| Resource | Limit |
|----------|-------|
| Projects per tenant | 100 |
| Dev spaces per project | 5 |
| Pipelines per project | 20 |
| AI requests per day | 200 |

---

## License

Apache 2.0 — see [LICENSE](../LICENSE)
