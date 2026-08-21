# AiDocument AI Service


## Documentation update

This AiDocument is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

A AiDocument AI microservice for the UIM Platform that provides intelligent AiDocument processing, extraction, and management capabilities — similar to the SAP AiDocument AI Service for SAP BTP.

Built with **D (dlang)** and **vibe.d**, following **Clean/Hexagonal Architecture** principles.

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Presentation (HTTP Controllers / Driving Adapters)  │
├─────────────────────────────────────────────────┤
│  Application (Use Cases / DTOs)                 │
├─────────────────────────────────────────────────┤
│  Domain (Entities / Ports / Services / Types)   │
├─────────────────────────────────────────────────┤
│  Infrastructure (Config / DI Container /        │
│                   Persistence / Driven Adapters) │
└─────────────────────────────────────────────────┘
```

- **Domain Layer** — Entities, value types, port interfaces (repository contracts), domain services (validation, enrichment matching)
- **Application Layer** — Use cases orchestrating domain logic, DTOs for request/response boundaries
- **Infrastructure Layer** — Configuration, dependency injection container, in-memory repository implementations
- **Presentation Layer** — HTTP controllers (vibe.d), JSON serialization utilities

## API Endpoints

### AiDocument Processing
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/AiDocument/jobs` | Upload a AiDocument for processing |
| GET | `/api/v1/AiDocument/jobs` | List AiDocument jobs |
| GET | `/api/v1/AiDocument/jobs/{id}` | Get a specific AiDocument job |
| DELETE | `/api/v1/AiDocument/jobs/{id}` | Delete a AiDocument job |
| POST | `/api/v1/AiDocument/jobs/{id}/confirm` | Confirm extraction results |
| GET | `/api/v1/AiDocument/jobs/{id}/results` | Get extraction results |

### Schema Management
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/schemas` | Create a schema |
| GET | `/api/v1/schemas` | List schemas |
| GET | `/api/v1/schemas/{id}` | Get a schema |
| PUT | `/api/v1/schemas/{id}` | Update a schema |
| DELETE | `/api/v1/schemas/{id}` | Delete a schema |

### Template Management
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/templates` | Create a template |
| GET | `/api/v1/templates` | List templates |
| GET | `/api/v1/templates/{id}` | Get a template |
| PUT | `/api/v1/templates/{id}` | Update a template |
| DELETE | `/api/v1/templates/{id}` | Delete a template |

### AiDocument Types
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/AiDocument-types` | Create a AiDocument type |
| GET | `/api/v1/AiDocument-types` | List AiDocument types |
| GET | `/api/v1/AiDocument-types/{id}` | Get a AiDocument type |
| PUT | `/api/v1/AiDocument-types/{id}` | Update a AiDocument type |
| DELETE | `/api/v1/AiDocument-types/{id}` | Delete a AiDocument type |

### Enrichment Data
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/enrichment-data` | Create enrichment data |
| GET | `/api/v1/enrichment-data` | List enrichment data |
| GET | `/api/v1/enrichment-data/{id}` | Get enrichment data |
| PUT | `/api/v1/enrichment-data/{id}` | Update enrichment data |
| DELETE | `/api/v1/enrichment-data/{id}` | Delete enrichment data |

### Training Jobs
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/training/jobs` | Create a training job |
| GET | `/api/v1/training/jobs` | List training jobs |
| GET | `/api/v1/training/jobs/{id}` | Get a training job |
| PATCH | `/api/v1/training/jobs/{id}` | Update training job status |
| DELETE | `/api/v1/training/jobs/{id}` | Delete a training job |

### Client Management (Admin)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/admin/clients` | Create a client |
| GET | `/api/v1/admin/clients` | List clients |
| GET | `/api/v1/admin/clients/{id}` | Get a client |
| PATCH | `/api/v1/admin/clients/{id}` | Update a client |
| DELETE | `/api/v1/admin/clients/{id}` | Delete a client |

### Capabilities & Health
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/capabilities` | Get service capabilities |
| GET | `/api/v1/health` | Health check |

## Building

```bash
# Build the service
cd AiDocument-ai
dub build

# Run tests
dub test
```

## Docker

```bash
docker build -t uim-AiDocument-ai -f Dockerfile .
docker run -p 8096:8096 uim-AiDocument-ai
```

## Podman

```bash
podman build -t uim-AiDocument-ai -f Containerfile .
podman run -p 8096:8096 uim-AiDocument-ai
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `DOCAI_HOST` | `0.0.0.0` | Bind address |
| `DOCAI_PORT` | `8096` | Listen port |

## Features

- **AiDocument Upload & Extraction** — Upload PDF, PNG, JPEG, TIFF documents for automated field extraction
- **Schema Management** — Define extraction schemas with typed fields and validation rules
- **Template Management** — Create templates linking schemas to AiDocument types with field mappings
- **AiDocument Type Classification** — Categorize documents (invoices, purchase orders, receipts, etc.)
- **Enrichment Data Matching** — Match extracted data against master data with configurable scoring
- **Training Jobs** — Train custom extraction models on your AiDocument types
- **Multi-tenant Client Management** — Isolate data per tenant/client
- **Capabilities Discovery** — Query supported extraction methods, file types, and features

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
