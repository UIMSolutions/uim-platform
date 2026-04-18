# Situation Automation Service

SAP BTP-style Intelligent Situation Automation service built with D language and vibe.d, following clean/hexagonal architecture.

Automates resolution of business situations using configurable rules and actions, with monitoring dashboards and notification support.

## Features

- **Situation Templates** - Define types of business situations with conditions and severity levels
- **Situation Instances** - Track occurrences of situations with full lifecycle management
- **Situation Actions** - Configure resolution actions (API calls, webhooks, emails, scripts)
- **Automation Rules** - Map conditions to actions for automatic situation resolution
- **Entity Types** - Manage business entity types that situations relate to
- **Data Contexts** - Capture and manage context data for situation instances (with GDPR personal data deletion)
- **Notifications** - Multi-channel alerting for situation events
- **Dashboards** - Monitoring and analytics configurations

## Architecture

```
Domain Layer          - Entities, Types, Repository Interfaces, Domain Services
Application Layer     - DTOs, Use Cases (ManageSituationTemplatesUseCase, etc.)
Infrastructure Layer  - Config, DI Container, Memory Repositories
Presentation Layer    - HTTP Controllers (vibe.d), JSON Utilities
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET/POST/PUT/DELETE | `/api/v1/situation-automation/templates` | Situation templates CRUD |
| GET/POST/PUT/DELETE | `/api/v1/situation-automation/instances` | Situation instances CRUD |
| POST | `/api/v1/situation-automation/instances/{id}/resolve` | Resolve a situation |
| GET/POST/PUT/DELETE | `/api/v1/situation-automation/actions` | Situation actions CRUD |
| GET/POST/PUT/DELETE | `/api/v1/situation-automation/rules` | Automation rules CRUD |
| GET/POST/PUT/DELETE | `/api/v1/situation-automation/entity-types` | Entity types CRUD |
| GET/POST/DELETE | `/api/v1/situation-automation/data-contexts` | Data contexts |
| POST | `/api/v1/situation-automation/data-contexts/delete-personal-data` | Delete personal data |
| GET/POST/PUT/DELETE | `/api/v1/situation-automation/notifications` | Notifications CRUD |
| GET/POST/PUT/DELETE | `/api/v1/situation-automation/dashboards` | Dashboards CRUD |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build
dub build --config=defaultRun

# Run
./build/uim-situation-automation-platform-service

# Test
dub test
```

## Docker / Podman

```bash
# Docker
docker build -t uim-platform/cloud-situation-automation:latest .

# Podman
podman build -f Containerfile -t uim-platform/cloud-situation-automation:latest .

# Run
docker run -p 8100:8100 uim-platform/cloud-situation-automation:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SITUATION_AUTOMATION_HOST` | `0.0.0.0` | Bind address |
| `SITUATION_AUTOMATION_PORT` | `8100` | Listen port |
