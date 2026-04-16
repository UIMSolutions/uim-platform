# Data Privacy Integration Service

A D/vibe.d microservice implementing SAP Data Privacy Integration-like functionality for the UIM Platform. Provides comprehensive personal data lifecycle management including data subjects, consent tracking, deletion/blocking/correction requests, retention rules, anonymisation, and GDPR compliance workflows.

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

- **Domain**: Data subjects, personal data models, deletion/blocking/correction/archive/destruction requests, legal grounds, retention rules, consents, data retrievals, data controllers, business contexts/processes, purpose records, rule sets, information reports, anonymisation configurations
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Data Subjects** — Register and manage data subjects for GDPR compliance
- **Personal Data Models** — Define schemas mapping business entities to personal data attributes
- **Deletion Requests** — Workflow for data deletion with configurable approval steps
- **Blocking Requests** — Temporarily restrict access to personal data
- **Correction Requests** — Process data subject rectification requests
- **Archive Requests** — Workflow for archiving personal data
- **Destruction Requests** — Permanent data destruction with audit trail
- **Legal Grounds** — Define and manage legal bases for data processing
- **Retention Rules** — Configure data retention periods and expiry policies
- **Consents** — Track and manage data subject consent records
- **Data Retrievals** — Respond to data subject access requests (data portability)
- **Data Controllers** — Register data controllers and controller groups
- **Business Contexts/Processes** — Map personal data to business context and processes
- **Purpose Records** — Record purposes for personal data use
- **Consent Purposes** — Link consents to specific processing purposes
- **Rule Sets** — Define processing rule sets for automated compliance checks
- **Information Reports** — Generate compliance information reports
- **Anonymisation Configs** — Configure anonymisation transformations for personal data

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/data-subjects` | Manage data subjects |
| CRUD | `/api/v1/personal-data-models` | Manage personal data models |
| CRUD | `/api/v1/deletion-requests` | Manage deletion requests |
| CRUD | `/api/v1/blocking-requests` | Manage blocking requests |
| CRUD | `/api/v1/legal-grounds` | Manage legal grounds |
| CRUD | `/api/v1/retention-rules` | Manage retention rules |
| CRUD | `/api/v1/consents` | Manage consent records |
| CRUD | `/api/v1/data-retrievals` | Manage data retrieval requests |
| CRUD | `/api/v1/data-controllers` | Manage data controllers |
| CRUD | `/api/v1/controller-groups` | Manage data controller groups |
| CRUD | `/api/v1/business-contexts` | Manage business contexts |
| CRUD | `/api/v1/business-processes` | Manage business processes |
| CRUD | `/api/v1/business-subprocesses` | Manage business subprocesses |
| CRUD | `/api/v1/correction-requests` | Manage correction requests |
| CRUD | `/api/v1/archive-requests` | Manage archive requests |
| CRUD | `/api/v1/destruction-requests` | Manage destruction requests |
| CRUD | `/api/v1/purpose-records` | Manage purpose records |
| CRUD | `/api/v1/consent-purposes` | Manage consent purposes |
| CRUD | `/api/v1/rule-sets` | Manage compliance rule sets |
| CRUD | `/api/v1/information-reports` | Manage information reports |
| CRUD | `/api/v1/anonymization-configs` | Manage anonymisation configurations |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd data-privacy
dub run

# Run tests
dub test
```

The service starts on port **8089** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DP_HOST` | `0.0.0.0` | Bind address |
| `DP_PORT` | `8089` | Listen port |

## License

Apache-2.0
