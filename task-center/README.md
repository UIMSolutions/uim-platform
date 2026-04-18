# Task Center Service

A unified task inbox microservice inspired by **SAP Task Center**, built with **D (dlang)** and **vibe.d** using clean and hexagonal architecture principles. It federates tasks from multiple provider applications into a single entry point, enabling users to access, process, and manage all their business-critical tasks from one place.

## Features

- **Task Federation** - Connect multiple task provider systems (SAP S/4HANA, SuccessFactors, Ariba, Fieldglass, Concur, SAP Build, custom) and aggregate tasks into a unified cache
- **Unified Inbox** - Single REST API to access all assigned tasks across all connected providers
- **Task Processing** - Approve, reject, forward, claim, release, escalate, complete, or cancel tasks
- **Task Definitions** - Define and manage task types with categories, schemas, and allowed actions
- **Provider Management** - Register, activate, deactivate, and sync task provider connectors
- **Substitution Management** - Configure delegation rules for task handling during user absences, with optional auto-forwarding
- **Task Comments** - Add and manage comments on tasks for collaboration
- **Task Attachments** - Attach supporting documents and files to tasks
- **Action Audit Log** - Full history of all task actions performed, for compliance and traceability
- **Saved Filters** - Users can save personal filter configurations for quick task retrieval
- **Health Endpoint** - Kubernetes-ready `/health` probe

## Architecture

```
task-center/
  source/
    app.d                          # Entry point
    uim/platform/task_center/
      package.d                    # Root module
      domain/
        types.d                    # ID aliases and enums
        entities/                  # Task, TaskDefinition, TaskProvider, etc.
        ports/repositories/        # Repository interfaces
        services/                  # TaskValidator
      application/
        dto.d                      # Request/Response DTOs
        usecases/manage/           # Use cases per entity
      infrastructure/
        config.d                   # AppConfig, loadConfig()
        container.d                # DI container wiring
        persistence/memory/        # In-memory repository implementations
        persistence/files/         # (placeholder) File-based persistence
        persistence/mongo/         # (placeholder) MongoDB persistence
      presentation/
        http/json_utils.d          # JSON helpers
        http/controllers/          # HTTP controllers per entity
```

The service follows **hexagonal (ports and adapters)** architecture:
- **Domain layer**: Pure business logic with no framework dependencies
- **Application layer**: Use cases orchestrating domain operations
- **Infrastructure layer**: Adapters for persistence, configuration, and DI
- **Presentation layer**: HTTP controllers exposing REST endpoints

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/task-center/tasks` | List tasks (filter by `assignee`, `status`, `providerId`) |
| `POST` | `/api/v1/task-center/tasks` | Create a task |
| `GET` | `/api/v1/task-center/tasks/:id` | Get task by ID |
| `PUT` | `/api/v1/task-center/tasks/:id` | Update a task |
| `POST` | `/api/v1/task-center/tasks/:id/claim` | Claim a task |
| `POST` | `/api/v1/task-center/tasks/:id/release` | Release a claimed task |
| `POST` | `/api/v1/task-center/tasks/:id/forward` | Forward task to another user |
| `POST` | `/api/v1/task-center/tasks/:id/complete` | Complete a task |
| `POST` | `/api/v1/task-center/tasks/:id/cancel` | Cancel a task |
| `DELETE` | `/api/v1/task-center/tasks/:id` | Delete a task |
| `GET` | `/api/v1/task-center/definitions` | List task definitions |
| `POST` | `/api/v1/task-center/definitions` | Create a task definition |
| `GET` | `/api/v1/task-center/definitions/:id` | Get task definition |
| `PUT` | `/api/v1/task-center/definitions/:id` | Update a task definition |
| `POST` | `/api/v1/task-center/definitions/:id/activate` | Activate a task definition |
| `POST` | `/api/v1/task-center/definitions/:id/deactivate` | Deactivate a task definition |
| `DELETE` | `/api/v1/task-center/definitions/:id` | Delete a task definition |
| `GET` | `/api/v1/task-center/providers` | List task providers |
| `POST` | `/api/v1/task-center/providers` | Register a provider |
| `GET` | `/api/v1/task-center/providers/:id` | Get provider details |
| `PUT` | `/api/v1/task-center/providers/:id` | Update a provider |
| `POST` | `/api/v1/task-center/providers/:id/activate` | Activate a provider |
| `POST` | `/api/v1/task-center/providers/:id/deactivate` | Deactivate a provider |
| `POST` | `/api/v1/task-center/providers/:id/sync` | Trigger provider sync |
| `DELETE` | `/api/v1/task-center/providers/:id` | Delete a provider |
| `GET` | `/api/v1/task-center/comments` | List comments (filter by `taskId`) |
| `POST` | `/api/v1/task-center/comments` | Add a comment |
| `GET` | `/api/v1/task-center/comments/:id` | Get comment |
| `PUT` | `/api/v1/task-center/comments/:id` | Update a comment |
| `DELETE` | `/api/v1/task-center/comments/:id` | Delete a comment |
| `GET` | `/api/v1/task-center/attachments` | List attachments (filter by `taskId`) |
| `POST` | `/api/v1/task-center/attachments` | Create attachment metadata |
| `GET` | `/api/v1/task-center/attachments/:id` | Get attachment |
| `DELETE` | `/api/v1/task-center/attachments/:id` | Delete attachment |
| `GET` | `/api/v1/task-center/substitutions` | List substitution rules (filter by `userId`) |
| `POST` | `/api/v1/task-center/substitutions` | Create a substitution rule |
| `GET` | `/api/v1/task-center/substitutions/:id` | Get substitution rule |
| `PUT` | `/api/v1/task-center/substitutions/:id` | Update a substitution rule |
| `POST` | `/api/v1/task-center/substitutions/:id/activate` | Activate a rule |
| `POST` | `/api/v1/task-center/substitutions/:id/deactivate` | Deactivate a rule |
| `DELETE` | `/api/v1/task-center/substitutions/:id` | Delete a rule |
| `GET` | `/api/v1/task-center/actions` | List task actions (filter by `taskId`) |
| `POST` | `/api/v1/task-center/actions` | Record a task action |
| `GET` | `/api/v1/task-center/actions/:id` | Get action details |
| `DELETE` | `/api/v1/task-center/actions/:id` | Delete action record |
| `GET` | `/api/v1/task-center/filters` | List saved filters (filter by `userId`) |
| `POST` | `/api/v1/task-center/filters` | Create a filter |
| `GET` | `/api/v1/task-center/filters/:id` | Get filter |
| `PUT` | `/api/v1/task-center/filters/:id` | Update a filter |
| `POST` | `/api/v1/task-center/filters/:id/default` | Set filter as default |
| `DELETE` | `/api/v1/task-center/filters/:id` | Delete a filter |
| `GET` | `/health` | Health check |

All endpoints accept `X-Tenant-Id` header for multi-tenancy.

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `TASK_CENTER_HOST` | `0.0.0.0` | Bind address |
| `TASK_CENTER_PORT` | `8103` | Listen port |

## Build and Run

```bash
# Build
dub build

# Run
./uim-task-center-platform-service

# Test
dub test
```

## Docker / Podman

```bash
# Build with Docker
docker build -t uim-platform/task-center:latest .

# Build with Podman
podman build -t uim-platform/task-center:latest -f Containerfile .

# Run
docker run -p 8103:8103 uim-platform/task-center:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Supported Provider Types

| Provider Type | Description |
|--------------|-------------|
| `s4hana` | SAP S/4HANA |
| `successFactors` | SAP SuccessFactors |
| `ariba` | SAP Ariba |
| `fieldglass` | SAP Fieldglass |
| `concur` | SAP Concur |
| `sapBuild` | SAP Build Process Automation |
| `custom` | Custom provider application |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
