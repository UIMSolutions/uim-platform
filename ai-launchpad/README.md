# AI Launchpad Service

A D/vibe.d microservice implementing SAP AI Launchpad-like functionality for the UIM Platform. Provides a unified management interface for AI runtimes, workspaces, ML lifecycle, and Generative AI Hub capabilities.

## Architecture

Clean/Hexagonal architecture with four layers:

```
┌─────────────────────────────────────────┐
│  Presentation (HTTP Controllers)        │
├─────────────────────────────────────────┤
│  Application (Use Cases, DTOs)          │
├─────────────────────────────────────────┤
│  Domain (Entities, Ports, Services)     │
├─────────────────────────────────────────┤
│  Infrastructure (Repos, Config, DI)     │
└─────────────────────────────────────────┘
```

- **Domain**: Core business entities, repository port interfaces, domain services (connection validation, prompt enrichment)
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

| Area                            | Capabilities                                                                                 |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| **Connection Management** | Connect to AI runtimes (SAP AI Core, third-party), credential masking, connection validation |
| **Workspace Management**  | Multi-tenant workspace isolation, connection grouping                                        |
| **Scenario Browsing**     | Sync and browse ML scenarios from connected runtimes                                         |
| **Configuration**         | Create training/serving configurations with parameter and artifact bindings                  |
| **Execution Lifecycle**   | Create, monitor, stop, delete ML training executions with bulk operations                    |
| **Deployment Lifecycle**  | Create, scale, stop deployments with TTL and bulk operations                                 |
| **Model Registry**        | Register, version, and manage trained ML models                                              |
| **Dataset Registry**      | Register and manage training/inference datasets                                              |
| **Generative AI Hub**     | Prompt management with versioning, collections, model parameters                             |
| **Resource Groups**       | Administrative resource group management with labels                                         |
| **Usage Statistics**      | Execution/deployment counts, training hours, inference requests, cost estimates              |

## API Endpoints

### Connection & Workspace Management

| Method | Path                         | Description                                            |
| ------ | ---------------------------- | ------------------------------------------------------ |
| POST   | `/api/v1/connections`      | Create connection                                      |
| GET    | `/api/v1/connections`      | List connections (filter by `X-Workspace-Id` header) |
| GET    | `/api/v1/connections/{id}` | Get connection                                         |
| PATCH  | `/api/v1/connections/{id}` | Update connection                                      |
| DELETE | `/api/v1/connections/{id}` | Delete connection                                      |
| POST   | `/api/v1/workspaces`       | Create workspace                                       |
| GET    | `/api/v1/workspaces`       | List workspaces (filter by `X-Tenant-Id` header)     |
| GET    | `/api/v1/workspaces/{id}`  | Get workspace                                          |
| PATCH  | `/api/v1/workspaces/{id}`  | Update workspace                                       |
| DELETE | `/api/v1/workspaces/{id}`  | Delete workspace                                       |

### AI Lifecycle

| Method | Path                            | Description                                    |
| ------ | ------------------------------- | ---------------------------------------------- |
| POST   | `/api/v1/scenarios/sync`      | Sync scenario from runtime                     |
| GET    | `/api/v1/scenarios`           | List scenarios (filter by `X-Connection-Id`) |
| GET    | `/api/v1/scenarios/{id}`      | Get scenario                                   |
| DELETE | `/api/v1/scenarios/{id}`      | Delete scenario                                |
| POST   | `/api/v1/configurations`      | Create configuration                           |
| GET    | `/api/v1/configurations`      | List configurations                            |
| GET    | `/api/v1/configurations/{id}` | Get configuration                              |
| DELETE | `/api/v1/configurations/{id}` | Delete configuration                           |
| POST   | `/api/v1/executions`          | Create execution                               |
| GET    | `/api/v1/executions`          | List executions                                |
| GET    | `/api/v1/executions/{id}`     | Get execution                                  |
| PATCH  | `/api/v1/executions/{id}`     | Update execution status                        |
| PATCH  | `/api/v1/executions/bulk`     | Bulk update executions                         |
| DELETE | `/api/v1/executions/{id}`     | Delete execution                               |
| POST   | `/api/v1/deployments`         | Create deployment                              |
| GET    | `/api/v1/deployments`         | List deployments                               |
| GET    | `/api/v1/deployments/{id}`    | Get deployment                                 |
| PATCH  | `/api/v1/deployments/{id}`    | Update deployment                              |
| PATCH  | `/api/v1/deployments/bulk`    | Bulk update deployments                        |
| DELETE | `/api/v1/deployments/{id}`    | Delete deployment                              |
| POST   | `/api/v1/models`              | Register model                                 |
| GET    | `/api/v1/models`              | List models                                    |
| GET    | `/api/v1/models/{id}`         | Get model                                      |
| PATCH  | `/api/v1/models/{id}`         | Update model                                   |
| DELETE | `/api/v1/models/{id}`         | Delete model                                   |
| POST   | `/api/v1/datasets`            | Register dataset                               |
| GET    | `/api/v1/datasets`            | List datasets                                  |
| GET    | `/api/v1/datasets/{id}`       | Get dataset                                    |
| PATCH  | `/api/v1/datasets/{id}`       | Update dataset                                 |
| DELETE | `/api/v1/datasets/{id}`       | Delete dataset                                 |

### Generative AI Hub

| Method | Path                                      | Description                                  |
| ------ | ----------------------------------------- | -------------------------------------------- |
| POST   | `/api/v1/genai/prompts`                 | Create prompt                                |
| GET    | `/api/v1/genai/prompts`                 | List prompts (filter by `X-Collection-Id`) |
| GET    | `/api/v1/genai/prompts/{id}`            | Get prompt                                   |
| PATCH  | `/api/v1/genai/prompts/{id}`            | Update prompt                                |
| POST   | `/api/v1/genai/prompt-collections`      | Create prompt collection                     |
| GET    | `/api/v1/genai/prompt-collections`      | List prompt collections                      |
| GET    | `/api/v1/genai/prompt-collections/{id}` | Get prompt collection                        |
| PATCH  | `/api/v1/genai/prompt-collections/{id}` | Update prompt collection                     |
| DELETE | `/api/v1/genai/prompt-collections/{id}` | Delete prompt collection                     |

### Admin & Monitoring

| Method | Path                                   | Description              |
| ------ | -------------------------------------- | ------------------------ |
| POST   | `/api/v1/admin/resource-groups`      | Create resource group    |
| GET    | `/api/v1/admin/resource-groups`      | List resource groups     |
| GET    | `/api/v1/admin/resource-groups/{id}` | Get resource group       |
| PATCH  | `/api/v1/admin/resource-groups/{id}` | Update resource group    |
| DELETE | `/api/v1/admin/resource-groups/{id}` | Delete resource group    |
| GET    | `/api/v1/statistics`                 | Get usage statistics     |
| GET    | `/api/v1/capabilities`               | Get service capabilities |
| GET    | `/api/v1/health`                     | Health check             |

## Building

```bash
cd ai-launchpad
dub build
```

## Running

```bash
# Default (port 8097)
dub run

# Custom port
AILP_PORT=9000 dub run
```

## Docker

```bash
docker build -t uim-ai-launchpad .
docker run -p 8097:8097 uim-ai-launchpad
```

## Podman

```bash
podman build -f Containerfile -t uim-ai-launchpad .
podman run -p 8097:8097 uim-ai-launchpad
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Environment Variable | Default     | Description  |
| -------------------- | ----------- | ------------ |
| `AILP_HOST`        | `0.0.0.0` | Bind address |
| `AILP_PORT`        | `8097`    | Listen port  |

## Project Structure

```
ai-launchpad/
  source/
    app.d                          # Entry point
    uim/platform/ai_launchpad/
      domain/
        types.d                    # ID aliases, enums
        entities/                  # 12 entity structs
        ports/                     # 12 repository interfaces
        services/                  # ConnectionValidator, PromptEnricher
      application/
        dto.d                      # 22 request/response DTOs
        usecases/                 # 13 use case classes
      infrastructure/
        config.d                   # AppConfig + env loading
        container.d                # DI wiring
        persistence/memory/        # 12 in-memory repositories
      presentation/http/
        controllers/               # 14 HTTP controllers
  k8s/                             # Kubernetes manifests
  Dockerfile                       # Docker build
  Containerfile                    # Podman build
  dub.sdl                         # Package configuration
```
