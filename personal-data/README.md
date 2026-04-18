# Personal Data Manager Service

A GDPR-compliant personal data management service inspired by **SAP Personal Data Manager**. Built with D (dlang) and vibe.d using clean/hexagonal architecture principles.

## Overview

The Personal Data Manager Service provides a centralized information framework for managing personal data across multiple applications. It supports the key GDPR rights and data protection processes:

- **Identify Data Subjects** - Search for data subjects by name, email, or organization (private and corporate)
- **Process Data Subject Requests** - Create, track, and resolve DSARs (Data Subject Access Requests) for GDPR Articles 15-22
- **Track Personal Data Records** - Catalog which personal data is stored per application per data subject
- **Register Applications** - Register and manage applications that store personal data
- **Manage Processing Purposes** - Define legal bases and purposes for data processing (GDPR Article 6)
- **Consent Management** - Record, track, and withdraw consent with full audit trail
- **Data Retention Rules** - Define and enforce retention periods with auto-delete support
- **Audit Logging** - Comprehensive logging of all data processing operations

## Architecture

```
personal-data/
  source/
    app.d                           # Entry point
    uim/platform/personal_data/
      package.d                     # Root module
      domain/                       # Domain layer (entities, ports, services)
        types.d                     # ID aliases, enums (RequestType, LegalBasis, etc.)
        entities/                   # 8 domain entities
        ports/repositories/         # 8 repository interfaces
        services/                   # Domain validation services
      application/                  # Application layer (use cases, DTOs)
        dto.d                       # Request/response DTOs
        usecases/manage/            # 8 use case classes
      infrastructure/               # Infrastructure layer
        config.d                    # AppConfig, loadConfig()
        container.d                 # DI container wiring
        persistence/memory/         # In-memory repository implementations
        persistence/files/          # File-based persistence (placeholder)
        persistence/mongo/          # MongoDB persistence (placeholder)
      presentation/                 # Presentation layer
        http/json_utils.d           # JSON helpers
        http/controllers/           # 8 HTTP controllers
  Dockerfile                        # Docker multi-stage build
  Containerfile                     # Podman-compatible container build
  k8s/                              # Kubernetes manifests
```

## Domain Model

| Entity | Description |
|--------|-------------|
| **DataSubject** | Person whose personal data is managed (private, corporate, employee, contractor, minor) |
| **DataSubjectRequest** | GDPR request (information, correction, erasure, restriction, portability, objection, consent withdrawal) |
| **PersonalDataRecord** | Individual personal data field stored by an application for a data subject |
| **RegisteredApplication** | Application registered with PDM that stores personal data |
| **ProcessingPurpose** | Legal basis and purpose for data processing (consent, contract, legal obligation, vital interest, public task, legitimate interest) |
| **ConsentRecord** | Consent given or withdrawn by a data subject for a specific purpose |
| **RetentionRule** | Data retention period and auto-delete policy |
| **DataProcessingLog** | Audit trail entry for data processing operations |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/personal-data/subjects` | List data subjects |
| GET | `/api/v1/personal-data/subjects/search?firstName=&lastName=&email=` | Search data subjects |
| GET | `/api/v1/personal-data/subjects/{id}` | Get data subject |
| POST | `/api/v1/personal-data/subjects` | Create data subject |
| PUT | `/api/v1/personal-data/subjects/{id}` | Update data subject |
| POST | `/api/v1/personal-data/subjects/{id}/block` | Block data subject |
| POST | `/api/v1/personal-data/subjects/{id}/erase` | Erase (anonymize) data subject |
| DELETE | `/api/v1/personal-data/subjects/{id}` | Delete data subject |
| GET | `/api/v1/personal-data/requests` | List requests (filter: `?dataSubjectId=`, `?status=`) |
| GET | `/api/v1/personal-data/requests/{id}` | Get request |
| POST | `/api/v1/personal-data/requests` | Create DSAR |
| PUT | `/api/v1/personal-data/requests/{id}` | Update request status/assignment |
| DELETE | `/api/v1/personal-data/requests/{id}` | Delete request |
| GET | `/api/v1/personal-data/records` | List records (filter: `?dataSubjectId=`, `?applicationId=`) |
| GET | `/api/v1/personal-data/records/{id}` | Get record |
| POST | `/api/v1/personal-data/records` | Create record |
| DELETE | `/api/v1/personal-data/records/{id}` | Delete record |
| GET | `/api/v1/personal-data/applications` | List registered applications |
| GET | `/api/v1/personal-data/applications/{id}` | Get application |
| POST | `/api/v1/personal-data/applications` | Register application |
| PUT | `/api/v1/personal-data/applications/{id}` | Update application |
| POST | `/api/v1/personal-data/applications/{id}/activate` | Activate application |
| POST | `/api/v1/personal-data/applications/{id}/suspend` | Suspend application |
| DELETE | `/api/v1/personal-data/applications/{id}` | Delete application |
| GET | `/api/v1/personal-data/purposes` | List processing purposes |
| GET | `/api/v1/personal-data/purposes/{id}` | Get purpose |
| POST | `/api/v1/personal-data/purposes` | Create purpose |
| PUT | `/api/v1/personal-data/purposes/{id}` | Update purpose |
| DELETE | `/api/v1/personal-data/purposes/{id}` | Delete purpose |
| GET | `/api/v1/personal-data/consents` | List consents (filter: `?dataSubjectId=`) |
| GET | `/api/v1/personal-data/consents/{id}` | Get consent |
| POST | `/api/v1/personal-data/consents` | Record consent |
| POST | `/api/v1/personal-data/consents/{id}/withdraw` | Withdraw consent |
| DELETE | `/api/v1/personal-data/consents/{id}` | Delete consent |
| GET | `/api/v1/personal-data/retention-rules` | List retention rules |
| GET | `/api/v1/personal-data/retention-rules/{id}` | Get retention rule |
| POST | `/api/v1/personal-data/retention-rules` | Create retention rule |
| PUT | `/api/v1/personal-data/retention-rules/{id}` | Update retention rule |
| DELETE | `/api/v1/personal-data/retention-rules/{id}` | Delete retention rule |
| GET | `/api/v1/personal-data/logs` | List logs (filter: `?dataSubjectId=`, `?requestId=`) |
| GET | `/api/v1/personal-data/logs/{id}` | Get log entry |
| POST | `/api/v1/personal-data/logs` | Create log entry |
| DELETE | `/api/v1/personal-data/logs/{id}` | Delete log entry |
| GET | `/api/v1/health` | Health check |

## GDPR Request Types

| Type | GDPR Article | Description |
|------|-------------|-------------|
| `information` | Art. 15 | Right of access - data subject can request information about stored personal data |
| `correction` | Art. 16 | Right to rectification - request correction of inaccurate personal data |
| `erasure` | Art. 17 | Right to erasure (right to be forgotten) - request deletion of personal data |
| `restriction` | Art. 18 | Right to restriction of processing |
| `portability` | Art. 20 | Right to data portability - receive data in machine-readable format |
| `objection` | Art. 21 | Right to object to processing |
| `consentWithdrawal` | Art. 7(3) | Withdraw previously given consent |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `PERSONAL_DATA_HOST` | `0.0.0.0` | Bind address |
| `PERSONAL_DATA_PORT` | `8102` | Listen port |

## Build and Run

```bash
# Build
dub build --config=defaultRun

# Run
./build/uim-personal-data-platform-service

# Docker
docker build -t uim-platform/cloud-personal-data .
docker run -p 8102:8102 uim-platform/cloud-personal-data

# Podman
podman build -f Containerfile -t uim-platform/cloud-personal-data .
podman run -p 8102:8102 uim-platform/cloud-personal-data

# Kubernetes
kubectl apply -f k8s/
```

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
