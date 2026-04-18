# Data Attribute Recommendation Service

A D/vibe.d microservice implementing SAP Data Attribute Recommendation-like functionality for the UIM Platform. Provides ML-driven attribute suggestion with dataset management, model training, deployment, and inference pipelines.

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

- **Domain**: Datasets, data records, models, deployments, inference requests, monitoring data
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Datasets** — Upload and manage labelled datasets with validation and processing pipelines
- **Data Records** — Manage individual data records within datasets
- **Models** — Define and train attribute recommendation models
- **Deployments** — Deploy trained models for real-time inference
- **Inference** — Submit inference requests and retrieve attribute recommendation results
- **Monitoring** — Track training job status, deployment health, and pipeline metrics

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/datasets` | Manage training datasets |
| POST | `/api/v1/datasets/validate/{id}` | Validate a dataset |
| POST | `/api/v1/datasets/process/{id}` | Process a dataset for training |
| CRUD | `/api/v1/data-records` | Manage data records |
| CRUD | `/api/v1/models` | Manage recommendation models |
| POST | `/api/v1/models/train/{id}` | Start model training |
| CRUD | `/api/v1/deployments` | Manage model deployments |
| POST | `/api/v1/inference` | Submit an inference request |
| GET | `/api/v1/inference/results/{id}` | Retrieve inference results |
| GET | `/api/v1/monitoring/jobs` | Get training job monitoring data |
| GET | `/api/v1/monitoring/deployments` | Get deployment monitoring data |
| GET | `/api/v1/monitoring/pipeline` | Get pipeline overview |
| GET | `/api/v1/health` | Health check |

## Build and Run

```bash
# Build and run locally
cd data-attribute-recommendation
dub run

# Run tests
dub test
```

The service starts on port **8092** by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DAR_HOST` | `0.0.0.0` | Bind address |
| `DAR_PORT` | `8092` | Listen port |

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
