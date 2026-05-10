# SAP Master Data Governance, Cloud Edition

A microservice implementing features similar to [SAP Master Data Governance, cloud edition (MDG CE)](https://help.sap.com/docs/MDG_CE) — a cloud solution for maintaining high-level master data quality, managing core attributes of business partners, and evaluating their quality.

Built with D (dlang) and vibe.d using a combination of clean and hexagonal architecture patterns.

## Features

- **Business Partner Management** — Full lifecycle management of business partners (organizations, persons, groups) with BP categories, roles, contact information, address data, tax information, bank details, and validation status tracking
- **Change Request Workflow** — Governance-driven approval process for master data changes with status transitions: Draft → Submitted → In Review → Approved/Rejected/Revision Requested
- **Data Quality Rules** — Configurable validation rules per BP field with rule types (required, format, range, uniqueness, consistency, referential integrity), severities (error, warning, info), and category scoping
- **Data Quality Scores** — Automated quality evaluation producing completeness, consistency, accuracy, and uniqueness scores with quality status classification (excellent, good, fair, poor)
- **Replication Management** — Track and manage replication jobs to connected systems (SAP S/4HANA, ECC, etc.) with full, delta, and selective replication types; batch processing and retry management

## Architecture

```
source/
  uim/platform/masterdata_governance/
    domain/           # Entities, repository interfaces, domain services, value types
    application/      # DTOs, use cases (business logic orchestration)
    infrastructure/   # Config, container (DI), in-memory persistence adapters
    presentation/     # HTTP controllers, REST API routing, JSON serialization
```

### Layers

| Layer | Responsibility |
|-------|---------------|
| **Domain** | BusinessPartner, ChangeRequest, DataQualityRule, DataQualityScore, Replication entities; repository port interfaces; MasterdataGovernanceValidator |
| **Application** | DTOs; ManageBusinessPartners/ManageChangeRequests/ManageDataQualityRules/ManageDataQualityScores/ManageReplications use cases |
| **Infrastructure** | SrvConfig (port 8108); Container (DI wiring); In-memory repository implementations |
| **Presentation** | REST controllers; JSON serialization helpers |

### Hexagonal Architecture (Ports & Adapters)

```
                  ┌─────────────────────────┐
  HTTP Clients ──►│  Presentation Layer      │
                  │  (REST Controllers)      │
                  └──────────┬──────────────┘
                             │
                  ┌──────────▼──────────────┐
                  │  Application Layer       │
                  │  (Use Cases / Services)  │
                  └──────────┬──────────────┘
                             │
                  ┌──────────▼──────────────┐
                  │  Domain Layer            │
                  │  (Entities + Ports)      │
                  └──────────┬──────────────┘
                             │
                  ┌──────────▼──────────────┐
                  │  Infrastructure Layer    │
                  │  (Adapters: Memory,      │
                  │   Config, Container)     │
                  └─────────────────────────┘
```

## API Endpoints

### Business Partners

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/masterdata-governance/business-partners` | List all business partners |
| POST | `/api/v1/masterdata-governance/business-partners` | Create business partner |
| GET | `/api/v1/masterdata-governance/business-partners/:id` | Get business partner by ID |
| PUT | `/api/v1/masterdata-governance/business-partners/:id` | Update business partner |
| DELETE | `/api/v1/masterdata-governance/business-partners/:id` | Delete business partner |

### Change Requests

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/masterdata-governance/change-requests` | List all change requests |
| POST | `/api/v1/masterdata-governance/change-requests` | Create change request |
| GET | `/api/v1/masterdata-governance/change-requests/:id` | Get change request by ID |
| PUT | `/api/v1/masterdata-governance/change-requests/:id` | Workflow action (submit/approve/reject/requestRevision/withdraw) |
| DELETE | `/api/v1/masterdata-governance/change-requests/:id` | Delete change request |

### Data Quality Rules

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/masterdata-governance/data-quality-rules` | List all data quality rules |
| POST | `/api/v1/masterdata-governance/data-quality-rules` | Create data quality rule |
| GET | `/api/v1/masterdata-governance/data-quality-rules/:id` | Get data quality rule by ID |
| PUT | `/api/v1/masterdata-governance/data-quality-rules/:id` | Update data quality rule |
| DELETE | `/api/v1/masterdata-governance/data-quality-rules/:id` | Delete data quality rule |

### Data Quality Scores

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/masterdata-governance/data-quality-scores` | List all data quality scores |
| POST | `/api/v1/masterdata-governance/data-quality-scores` | Create data quality score |
| GET | `/api/v1/masterdata-governance/data-quality-scores/:id` | Get data quality score by ID |
| PUT | `/api/v1/masterdata-governance/data-quality-scores/:id` | Update data quality score |
| DELETE | `/api/v1/masterdata-governance/data-quality-scores/:id` | Delete data quality score |

### Replications

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/masterdata-governance/replications` | List all replications |
| POST | `/api/v1/masterdata-governance/replications` | Create replication |
| GET | `/api/v1/masterdata-governance/replications/:id` | Get replication by ID |
| PUT | `/api/v1/masterdata-governance/replications/:id` | Cancel replication |
| DELETE | `/api/v1/masterdata-governance/replications/:id` | Delete replication |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check — returns `{"status":"UP","service":"Master Data Governance"}` |

## Change Request Workflow Actions

Send a `PUT` to `/api/v1/masterdata-governance/change-requests/:id` with:

```json
{
  "action": "submit",
  "userId": "user-id",
  "comments": "optional comment"
}
```

| Action | Allowed From Status | Result Status |
|--------|---------------------|---------------|
| `submit` | draft, revisionRequested | submitted |
| `approve` | submitted, inReview | approved |
| `reject` | submitted, inReview | rejected |
| `requestRevision` | any | revisionRequested |
| `withdraw` | any | withdrawn |

## Build

```bash
dub build --compiler=ldc2 -b release
```

## Run

```bash
MASTERDATA_GOVERNANCE_HOST=0.0.0.0 MASTERDATA_GOVERNANCE_PORT=8108 ./uim-masterdata-governance-platform-service
```

## Docker

```bash
docker build -t uim-masterdata-governance-platform-service .
docker run -p 8108:8108 uim-masterdata-governance-platform-service
```

## Podman

```bash
podman build -f Containerfile -t uim-masterdata-governance-platform-service .
podman run -p 8108:8108 uim-masterdata-governance-platform-service
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Reference

- [SAP Master Data Governance, Cloud Edition — Help Portal](https://help.sap.com/docs/MDG_CE)
- [MDG CE Application Help](https://help.sap.com/docs/MDG_CE/27ced20013d04f8bb7568ff8451c66ad)
- [MDG CE Feature Scope Description](https://help.sap.com/docs/MDG_CE/8173e3e8be68462f9ce89262427a5c54)
