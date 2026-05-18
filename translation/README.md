# Translation Hub Service — UIM Platform

A BTP-style Translation Hub service built with D language and vibe.d, following clean and hexagonal architecture principles. Modelled after **SAP Translation Hub** on SAP BTP.

## Features

| Feature | Description |
|---|---|
| **Software Translation** | Translate UI texts, labels, error messages via synchronous API |
| **Document Translation** | Translate full documents / large text blocks, sync and async |
| **Translation Projects** | Create and manage projects for file, Git, ABAP, and API-based translation workflows |
| **Company Glossary (MLTR)** | Upload and manage custom translation memory to enforce preferred or mandatory terms |
| **Multiple Providers** | Switch between MLTR, Neural MT, Company MLTR, and LLM per request |
| **Quality Estimation** | Every translation response includes a quality score (0–100) and quality level |
| **Languages Endpoint** | Discover all 44+ supported BCP-47 language codes |
| **Domains Endpoint** | Discover supported translation domains (IT, HR, Finance, …) |
| **Text Types Endpoint** | Discover supported text type categories (uiText, tooltip, errorMessage, …) |
| **Async Jobs** | Submit long-running document translation jobs, poll for status, retrieve results |
| **Multi-Tenancy** | All data scoped to `X-Tenant-Id` header |
| **Health Check** | `/api/v1/health` endpoint for liveness/readiness probes |

## Architecture

```
translation/
  source/
    app.d                                  # Entry point — composition root
    uim/platform/translation/
      domain/                              # Core business logic (no external dependencies)
        types.d                            # ID structs and domain enums
        entities/                          # Domain entities
          translation_project.d            # Software translation project
          glossary_entry.d                 # Company MLTR entry
          translation_job.d                # Async job tracking
        ports/repositories/               # Repository interfaces (driven ports)
          translation_projects.d
          glossary_entries.d
          translation_jobs.d
        services/
          translation_engine.d             # Domain service: mock MT engine
      application/                         # Use cases (application layer)
        dto.d                              # Request DTOs
        usecases/manage/
          translation_projects.d           # CRUD use case
          glossary_entries.d               # CRUD use case
          translation_jobs.d               # Submit / poll / cancel async jobs
          translations.d                   # Synchronous translate use case
      infrastructure/                      # Adapters and wiring
        config.d                           # Environment-based configuration
        container.d                        # DI container
        persistence/memory/               # In-memory repository implementations
          translation_project_repo.d
          glossary_entry_repo.d
          translation_job_repo.d
      presentation/
        http/controllers/                  # vibe.d HTTP controllers (driving adapters)
          language.d
          domain_.d
          text_type.d
          translation.d
          translation_project.d
          glossary.d
          document_translation.d
          translation_job.d
```

## API Endpoints

### Discovery

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/translation/languages` | List all supported BCP-47 language codes |
| `GET` | `/api/v1/translation/domains` | List supported translation domains |
| `GET` | `/api/v1/translation/text-types` | List supported text types |

### Software Translation (Synchronous)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/translation/translate` | Translate one or more UI texts synchronously |

**Request body:**
```json
{
  "sourceLanguage": "en",
  "targetLanguage": "de",
  "texts": ["Save", "Cancel", "Delete"],
  "domain": "IT",
  "textType": "uiText",
  "provider": "mltr"
}
```

**Response:**
```json
{
  "translations": [
    { "sourceText": "Save", "translatedText": "[MLTR:de] Save", "qualityScore": 92, "qualityLevel": "excellent" }
  ],
  "sourceLanguage": "en",
  "targetLanguage": "de"
}
```

### Document Translation (Synchronous)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/translation/documents/translate` | Translate document content synchronously |

### Translation Projects

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/translation/projects` | List all projects |
| `GET` | `/api/v1/translation/projects/{id}` | Get project details |
| `POST` | `/api/v1/translation/projects` | Create a new project |
| `PUT` | `/api/v1/translation/projects/{id}` | Update project |
| `DELETE` | `/api/v1/translation/projects/{id}` | Delete project |

### Company Glossary (MLTR)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/translation/glossaries` | List all glossary entries |
| `GET` | `/api/v1/translation/glossaries/{id}` | Get entry |
| `POST` | `/api/v1/translation/glossaries` | Add a new entry |
| `PUT` | `/api/v1/translation/glossaries/{id}` | Update entry |
| `DELETE` | `/api/v1/translation/glossaries/{id}` | Remove entry |

### Async Translation Jobs

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/v1/translation/jobs` | Submit a new async translation job |
| `GET` | `/api/v1/translation/jobs` | List all jobs for the tenant |
| `GET` | `/api/v1/translation/jobs/{id}` | Get job status and result |
| `POST` | `/api/v1/translation/jobs/{id}/cancel` | Cancel a pending job |

### Health

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/health` | Service health check |

## Request Headers

| Header | Description |
|--------|-------------|
| `X-Tenant-Id` | Tenant identifier (required for multi-tenant operations) |
| `Content-Type` | `application/json` for all mutation endpoints |

## Translation Providers

| Provider ID | Description |
|-------------|-------------|
| `mltr` | SAP Multilingual Text Repository — verified translations |
| `machineMt` | SAP Neural Machine Translation — AI-powered MT |
| `companyMltr` | Company MLTR — your own custom translation memory |
| `llm` | Large Language Model (generative AI hub) |

## Build and Run

```bash
cd translation
dub run --config=defaultRun
dub test --config=defaultTest
```

## Container Build

```bash
# Docker
docker build -t uim-platform/cloud-translation:latest .

# Podman
podman build -f Containerfile -t uim-platform/cloud-translation:latest .
```

## Kubernetes Deployment

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `TRANSLATION_HOST` | `0.0.0.0` | Listen address |
| `TRANSLATION_PORT` | `8096` | Listen port |

## License

See the repository root [LICENSE](../LICENSE) file.
