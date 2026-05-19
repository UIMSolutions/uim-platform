# SAP Continuous Integration and Delivery — Platform Service

Microservice implementation of [SAP Continuous Integration and Delivery](https://help.sap.com/docs/continuous-integration-and-delivery) for the UIM Platform. Built with D + vibe.d using clean/hexagonal architecture.

## Features

- **Repositories** — Connect Git repositories (GitHub, GitLab, Bitbucket, Azure DevOps, Gerrit)
- **Credentials** — Manage authentication for source control and deployment targets
- **Pipelines** — Define reusable CI/CD pipeline configurations (CAP, Fiori, Kyma, ABAP, etc.)
- **Jobs** — Bind pipelines to repositories with trigger modes (manual, push, PR, scheduled, API)
- **Builds** — Track individual build executions with status, logs, and artifacts
- **Stages** — Monitor build pipeline stages (lint, tests, compliance, deploy, etc.)
- **Webhooks** — Register Git event webhooks to trigger jobs automatically
- **Deployment Targets** — Configure Cloud Foundry, Kyma, ABAP, Kubernetes, and container registry targets

## Architecture

```
integration-delivery/
  source/
    app.d                          # Entry point
    uim/platform/integration_delivery/
      domain/
        entities/                  # CicdRepository, Credential, Pipeline, Job, Build, Stage, Webhook, DeploymentTarget
        repositories/              # Repository interfaces
        services/                  # CicdValidator
      application/
        dto.d                      # Data transfer objects
        usecases/manage/           # Business use cases
      infrastructure/
        config.d                   # SrvConfig + loadConfig()
        persistence/memory/        # In-memory repository implementations
        container.d                # Dependency injection container
      presentation/
        http/controllers/          # HTTP route handlers (ManageController)
        cli/ web/ gui/             # Stub layers
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/integration-delivery/repositories` | List repositories |
| POST | `/api/v1/integration-delivery/repositories` | Create repository |
| GET | `/api/v1/integration-delivery/repositories/:id` | Get repository |
| PUT | `/api/v1/integration-delivery/repositories/:id` | Update repository |
| DELETE | `/api/v1/integration-delivery/repositories/:id` | Delete repository |
| GET | `/api/v1/integration-delivery/credentials` | List credentials |
| POST | `/api/v1/integration-delivery/credentials` | Create credential |
| GET | `/api/v1/integration-delivery/credentials/:id` | Get credential |
| PUT | `/api/v1/integration-delivery/credentials/:id` | Update credential |
| DELETE | `/api/v1/integration-delivery/credentials/:id` | Delete credential |
| GET | `/api/v1/integration-delivery/pipelines` | List pipelines |
| POST | `/api/v1/integration-delivery/pipelines` | Create pipeline |
| GET | `/api/v1/integration-delivery/pipelines/:id` | Get pipeline |
| PUT | `/api/v1/integration-delivery/pipelines/:id` | Update pipeline |
| DELETE | `/api/v1/integration-delivery/pipelines/:id` | Delete pipeline |
| GET | `/api/v1/integration-delivery/jobs` | List jobs |
| POST | `/api/v1/integration-delivery/jobs` | Create job |
| GET | `/api/v1/integration-delivery/jobs/:id` | Get job |
| PUT | `/api/v1/integration-delivery/jobs/:id` | Update job |
| DELETE | `/api/v1/integration-delivery/jobs/:id` | Delete job |
| GET | `/api/v1/integration-delivery/builds` | List builds |
| POST | `/api/v1/integration-delivery/builds` | Trigger build |
| GET | `/api/v1/integration-delivery/builds/:id` | Get build |
| PUT | `/api/v1/integration-delivery/builds/:id` | Update build status |
| DELETE | `/api/v1/integration-delivery/builds/:id` | Delete build |
| GET | `/api/v1/integration-delivery/stages` | List stages |
| POST | `/api/v1/integration-delivery/stages` | Create stage |
| GET | `/api/v1/integration-delivery/stages/:id` | Get stage |
| PUT | `/api/v1/integration-delivery/stages/:id` | Update stage |
| DELETE | `/api/v1/integration-delivery/stages/:id` | Delete stage |
| GET | `/api/v1/integration-delivery/webhooks` | List webhooks |
| POST | `/api/v1/integration-delivery/webhooks` | Create webhook |
| GET | `/api/v1/integration-delivery/webhooks/:id` | Get webhook |
| PUT | `/api/v1/integration-delivery/webhooks/:id` | Update webhook |
| DELETE | `/api/v1/integration-delivery/webhooks/:id` | Delete webhook |
| GET | `/api/v1/integration-delivery/deployment-targets` | List deployment targets |
| POST | `/api/v1/integration-delivery/deployment-targets` | Create deployment target |
| GET | `/api/v1/integration-delivery/deployment-targets/:id` | Get deployment target |
| PUT | `/api/v1/integration-delivery/deployment-targets/:id` | Update deployment target |
| DELETE | `/api/v1/integration-delivery/deployment-targets/:id` | Delete deployment target |
| GET | `/health` | Health check |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `INTEGRATION_DELIVERY_HOST` | `0.0.0.0` | Bind address |
| `INTEGRATION_DELIVERY_PORT` | `8120` | Listen port |

## Docker / Podman

```bash
# Build
docker build -t uim-integration-delivery .
# or
podman build -t uim-integration-delivery .

# Run
docker run -p 8120:8120 uim-integration-delivery
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Development

```bash
# Run tests
dub test

# Run service
dub run
```
