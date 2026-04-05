# Job Scheduling Service

SAP BTP-style Job Scheduling Service built with D, vibe-d, and uim-framework.

Define and manage one-time and recurring jobs using flexible schedules. This service provides similar features to the SAP Job Scheduling Service for SAP BTP.

## Features

- **Flexible scheduling** - Cron expressions, repeatInterval, repeatAt, and human-readable schedule formats
- **Jobs and Schedules** - CRUD operations on jobs and their associated schedules
- **Run Logs** - Track execution history for each schedule run with status transitions
- **Multitenancy** - Tenant-aware via `X-Tenant-Id` header
- **Synchronous and asynchronous mode** - Support for both short-running and long-running jobs
- **Bulk operations** - Activate or deactivate all schedules for a job
- **Search** - Search jobs and schedules across a service instance
- **Global configuration** - Per-tenant configuration parameters (retries, timeouts, async mode)
- **Health endpoint** - Liveness and readiness probes

## Architecture

Hexagonal (ports and adapters) architecture with clean separation:

```
domain/           - Entities, value types, repository interfaces, domain services
application/      - Use cases, DTOs, command results
presentation/     - HTTP controllers, JSON serialization, routing
infrastructure/   - Configuration, DI container, in-memory persistence
```

## API Endpoints

### Jobs
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/scheduler/jobs` | Create a job (with optional inline schedules) |
| GET | `/api/v1/scheduler/jobs` | Retrieve all jobs |
| GET | `/api/v1/scheduler/jobs/{id}` | Retrieve job details |
| PUT | `/api/v1/scheduler/jobs/{id}` | Update a job |
| DELETE | `/api/v1/scheduler/jobs/{id}` | Delete a job and all its schedules |
| GET | `/api/v1/scheduler/jobs/count` | Get active/inactive job counts |
| GET | `/api/v1/scheduler/jobs/search?q=` | Search jobs by name/description |

### Schedules
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/scheduler/jobs/{id}/schedules` | Create a schedule |
| GET | `/api/v1/scheduler/jobs/{id}/schedules` | List schedules for a job |
| GET | `/api/v1/scheduler/jobs/{id}/schedules/{sid}` | Get schedule details |
| PUT | `/api/v1/scheduler/jobs/{id}/schedules/{sid}` | Update a schedule |
| DELETE | `/api/v1/scheduler/jobs/{id}/schedules/{sid}` | Delete a schedule |
| PUT | `/api/v1/scheduler/jobs/{id}/schedules/activate` | Activate/deactivate all schedules |
| GET | `/api/v1/scheduler/schedules/search?q=` | Search schedules across all jobs |

### Run Logs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/scheduler/jobs/{id}/runLogs` | Get run logs for a job |
| GET | `/api/v1/scheduler/jobs/{id}/schedules/{sid}/runLogs` | Get run logs for a schedule |
| PUT | `/api/v1/scheduler/jobs/{id}/runLogs/{rid}` | Update run log status (async callback) |

### Configuration
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/scheduler/configuration` | Get global parameters |
| PUT | `/api/v1/scheduler/configuration` | Update global parameters |

### Health
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd job-scheduling
dub run --config=defaultRun

# Run tests
dub test
```

## Docker / Podman

```bash
# Docker
docker build -t uim-platform/cloud-job-scheduling:latest .
docker run -p 8096:8096 uim-platform/cloud-job-scheduling:latest

# Podman
podman build -f Containerfile -t uim-platform/cloud-job-scheduling:latest .
podman run -p 8096:8096 uim-platform/cloud-job-scheduling:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JOB_SCHEDULING_HOST` | `0.0.0.0` | Bind address |
| `JOB_SCHEDULING_PORT` | `8096` | Listen port |

## License

Apache-2.0
