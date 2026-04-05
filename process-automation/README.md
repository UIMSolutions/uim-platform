# Process Automation Service

A comprehensive process automation platform built with D (dlang) and vibe.d, following clean/hexagonal architecture. Provides features similar to SAP Build Process Automation including workflow management, task handling, business rules/decisions, forms, RPA automations, triggers, API actions, process visibility dashboards, and an artifact store.

## Features

- **Process Management** - Design, version, deploy, and manage business processes with multi-step workflows
- **Process Instances** - Start, monitor, suspend, resume, cancel, and retry process executions
- **Task Management** - Human task inbox with claim/complete workflow, priorities, due dates, and candidate assignment
- **Decisions (Business Rules)** - Decision tables and text rules with configurable hit policies
- **Forms** - Form builder with sections, fields, validation rules, and conditional visibility
- **Automations (RPA Bots)** - Desktop and cloud automations with step-by-step execution and run history
- **Triggers** - Schedule (cron), event-based, and webhook triggers to start processes automatically
- **Actions (API Integration)** - REST/OData/SOAP connectors with authentication and destination support
- **Visibility Dashboards** - Real-time and historical process monitoring with custom metrics and filters
- **Artifact Store** - Publish, discover, and reuse process content packages across projects

## Architecture

```
Clean / Hexagonal Architecture (Ports & Adapters)

+-----------------------------------------------------------+
|  Presentation (Driving Adapters)                          |
|  - HTTP Controllers (vibe.d URLRouter)                    |
|  - Health endpoint                                        |
+-----------------------------------------------------------+
|  Application Layer                                        |
|  - Use Cases (ManageProcesses, ManageTasks, ...)         |
|  - DTOs (Request/Response objects)                        |
+-----------------------------------------------------------+
|  Domain Layer (Core)                                      |
|  - Entities (Process, Task, Decision, Form, ...)         |
|  - Repository Ports (interfaces)                          |
|  - Domain Services (ProcessValidator)                     |
|  - Value Objects / Types / Enums                          |
+-----------------------------------------------------------+
|  Infrastructure (Driven Adapters)                         |
|  - In-Memory Repositories                                 |
|  - Configuration                                          |
|  - DI Container                                           |
|  - Persistence stubs (MongoDB, File-based)                |
+-----------------------------------------------------------+
```

## API Endpoints

| Resource     | Path                                          | Methods                    |
|-------------|-----------------------------------------------|----------------------------|
| Processes    | `/api/v1/process-automation/processes`         | GET, POST, PUT, DELETE     |
| Deploy       | `/api/v1/process-automation/processes/*/deploy` | POST                      |
| Instances    | `/api/v1/process-automation/instances`         | GET, POST, DELETE          |
| Inst. Action | `/api/v1/process-automation/instances/*/action` | POST                     |
| Tasks        | `/api/v1/process-automation/tasks`             | GET, POST, PUT, DELETE     |
| Claim Task   | `/api/v1/process-automation/tasks/*/claim`     | POST                       |
| Complete Task| `/api/v1/process-automation/tasks/*/complete`  | POST                       |
| Decisions    | `/api/v1/process-automation/decisions`         | GET, POST, PUT, DELETE     |
| Forms        | `/api/v1/process-automation/forms`             | GET, POST, PUT, DELETE     |
| Automations  | `/api/v1/process-automation/automations`       | GET, POST, PUT, DELETE     |
| Triggers     | `/api/v1/process-automation/triggers`          | GET, POST, PUT, DELETE     |
| Actions      | `/api/v1/process-automation/actions`           | GET, POST, PUT, DELETE     |
| Visibility   | `/api/v1/process-automation/visibility`        | GET, POST, PUT, DELETE     |
| Artifacts    | `/api/v1/process-automation/store/artifacts`   | GET, POST, PUT, DELETE     |
| Health       | `/api/v1/health`                               | GET                        |

## Build and Run

### Prerequisites

- D compiler (LDC 1.40.1+)
- DUB package manager

### Local Development

```bash
# Build
dub build --config=defaultRun

# Run
./build/uim-process-automation-platform-service

# Test
dub test
```

### Docker

```bash
# Build image
docker build -t uim-platform/cloud-process-automation:latest .

# Run container
docker run -p 8099:8099 uim-platform/cloud-process-automation:latest
```

### Podman

```bash
# Build image
podman build -f Containerfile -t uim-platform/cloud-process-automation:latest .

# Run container
podman run -p 8099:8099 uim-platform/cloud-process-automation:latest
```

### Kubernetes

```bash
# Apply manifests
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Environment Variable         | Default   | Description          |
|-----------------------------|-----------|----------------------|
| `PROCESS_AUTOMATION_HOST`    | `0.0.0.0` | Bind address         |
| `PROCESS_AUTOMATION_PORT`    | `8099`    | Listen port          |

## License

Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
