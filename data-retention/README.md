# Data Retention Manager Service

A microservice providing data retention management capabilities similar to **SAP Data Retention Manager**. Built with D and vibe.d using a combination of clean and hexagonal architecture. Enables managing residence and retention rules to block or destroy personal data and related transactional data for applications, irrespective of the data model they use.

## Features

- **Business Purpose Management** -- Create business purpose rules for a given application group with associated legal grounds. Define residence and retention periods for all legal grounds; end-of-purpose is calculated based on the reference date.
- **Legal Ground Management** -- Define legal bases for data processing (consent, contract, legal obligation, vital interest, public interest, legitimate interest) and associate them with business purposes.
- **Retention Rules Handling** -- Create retention rules for each legal ground to define when application data needs to be blocked or deleted after the residence period ends, with configurable duration, period unit, and expiry action.
- **Residence Rules Handling** -- Create residence rules for each legal ground to define how long personal data may be actively used before it must be blocked, with configurable duration and period unit.
- **Data Subject Management** -- Register and track data subjects with lifecycle status management (active, blocked, marked-for-deletion, deleted, archived). Block data subjects when end-of-purpose is reached.
- **Delete Data Subject Information** -- Check end-of-purpose of data subjects for a given application group at each application level, triggering block or deletion requests based on retention period completion.
- **Archiving and Destruction** -- Archive or destruct legal grounds and transactions (with or without data subject reference). Selection criteria help choose the application and range of transactions to be archived or destructed.
- **Application Group Management** -- Organize applications into logical groups with global, regional, or local scope for structured retention policy application.
- **Legal Entity Management** -- Manage legal entities with country and region information to support jurisdiction-specific retention requirements.
- **Data Subject Role Management** -- Define roles for data subjects (e.g., customer, employee, vendor) to categorize retention obligations.
- **Retention Period Evaluation** -- Domain service that evaluates whether data is within residence, within retention, at end-of-purpose, or at end-of-retention based on configured rules.
- **Multitenancy Support** -- Full tenant isolation for all entities and operations.

## Architecture

```
+-----------------------------------------------------+
|                  Presentation Layer                  |
|  BusinessPurposeController  LegalGroundController    |
|  RetentionRuleController  ResidenceRuleController    |
|  DataSubjectController  DeletionRequestController    |
|  ArchivingJobController  ApplicationGroupController  |
|  LegalEntityController  DataSubjectRoleController    |
+-----------------------------------------------------+
|                  Application Layer                   |
|  ManageBusinessPurposesUC  ManageLegalGroundsUC      |
|  ManageRetentionRulesUC  ManageResidenceRulesUC      |
|  ManageDataSubjectsUC  ManageDeletionRequestsUC      |
|  ManageArchivingJobsUC  ManageApplicationGroupsUC    |
|  ManageLegalEntitiesUC  ManageDataSubjectRolesUC     |
+-----------------------------------------------------+
|                   Domain Layer                       |
|  Entities  Repository Interfaces  Domain Services    |
|  RetentionEvaluator  Enumerations  Value Types       |
+-----------------------------------------------------+
|                Infrastructure Layer                  |
|  MemoryRepositories  AppConfig  Container            |
+-----------------------------------------------------+
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/health` | Health check |
| **Business Purposes** | | |
| GET | `/api/v1/data-retention/business-purposes` | List all business purposes |
| GET | `/api/v1/data-retention/business-purposes/{id}` | Get business purpose by ID |
| POST | `/api/v1/data-retention/business-purposes` | Create business purpose |
| PUT | `/api/v1/data-retention/business-purposes/{id}` | Update business purpose |
| POST | `/api/v1/data-retention/business-purposes/{id}/activate` | Activate business purpose |
| DELETE | `/api/v1/data-retention/business-purposes/{id}` | Delete business purpose |
| **Legal Grounds** | | |
| GET | `/api/v1/data-retention/legal-grounds` | List all legal grounds |
| GET | `/api/v1/data-retention/legal-grounds/{id}` | Get legal ground by ID |
| POST | `/api/v1/data-retention/legal-grounds` | Create legal ground |
| PUT | `/api/v1/data-retention/legal-grounds/{id}` | Update legal ground |
| DELETE | `/api/v1/data-retention/legal-grounds/{id}` | Delete legal ground |
| **Retention Rules** | | |
| GET | `/api/v1/data-retention/retention-rules` | List all retention rules |
| GET | `/api/v1/data-retention/retention-rules/{id}` | Get retention rule by ID |
| POST | `/api/v1/data-retention/retention-rules` | Create retention rule |
| PUT | `/api/v1/data-retention/retention-rules/{id}` | Update retention rule |
| DELETE | `/api/v1/data-retention/retention-rules/{id}` | Delete retention rule |
| **Residence Rules** | | |
| GET | `/api/v1/data-retention/residence-rules` | List all residence rules |
| GET | `/api/v1/data-retention/residence-rules/{id}` | Get residence rule by ID |
| POST | `/api/v1/data-retention/residence-rules` | Create residence rule |
| PUT | `/api/v1/data-retention/residence-rules/{id}` | Update residence rule |
| DELETE | `/api/v1/data-retention/residence-rules/{id}` | Delete residence rule |
| **Data Subjects** | | |
| GET | `/api/v1/data-retention/data-subjects` | List all data subjects |
| GET | `/api/v1/data-retention/data-subjects/{id}` | Get data subject by ID |
| POST | `/api/v1/data-retention/data-subjects` | Create data subject |
| PUT | `/api/v1/data-retention/data-subjects/{id}` | Update data subject |
| POST | `/api/v1/data-retention/data-subjects/{id}/block` | Block data subject |
| DELETE | `/api/v1/data-retention/data-subjects/{id}` | Delete data subject |
| **Deletion Requests** | | |
| GET | `/api/v1/data-retention/deletion-requests` | List all deletion requests |
| GET | `/api/v1/data-retention/deletion-requests/{id}` | Get deletion request by ID |
| POST | `/api/v1/data-retention/deletion-requests` | Create deletion request |
| PUT | `/api/v1/data-retention/deletion-requests/{id}` | Update deletion request |
| DELETE | `/api/v1/data-retention/deletion-requests/{id}` | Delete deletion request |
| **Archiving Jobs** | | |
| GET | `/api/v1/data-retention/archiving-jobs` | List all archiving jobs |
| GET | `/api/v1/data-retention/archiving-jobs/{id}` | Get archiving job by ID |
| POST | `/api/v1/data-retention/archiving-jobs` | Create archiving job |
| PUT | `/api/v1/data-retention/archiving-jobs/{id}` | Update archiving job |
| DELETE | `/api/v1/data-retention/archiving-jobs/{id}` | Delete archiving job |
| **Application Groups** | | |
| GET | `/api/v1/data-retention/application-groups` | List all application groups |
| GET | `/api/v1/data-retention/application-groups/{id}` | Get application group by ID |
| POST | `/api/v1/data-retention/application-groups` | Create application group |
| PUT | `/api/v1/data-retention/application-groups/{id}` | Update application group |
| DELETE | `/api/v1/data-retention/application-groups/{id}` | Delete application group |
| **Legal Entities** | | |
| GET | `/api/v1/data-retention/legal-entities` | List all legal entities |
| GET | `/api/v1/data-retention/legal-entities/{id}` | Get legal entity by ID |
| POST | `/api/v1/data-retention/legal-entities` | Create legal entity |
| PUT | `/api/v1/data-retention/legal-entities/{id}` | Update legal entity |
| DELETE | `/api/v1/data-retention/legal-entities/{id}` | Delete legal entity |
| **Data Subject Roles** | | |
| GET | `/api/v1/data-retention/data-subject-roles` | List all data subject roles |
| GET | `/api/v1/data-retention/data-subject-roles/{id}` | Get data subject role by ID |
| POST | `/api/v1/data-retention/data-subject-roles` | Create data subject role |
| PUT | `/api/v1/data-retention/data-subject-roles/{id}` | Update data subject role |
| DELETE | `/api/v1/data-retention/data-subject-roles/{id}` | Delete data subject role |

## Domain Concepts

### Retention Lifecycle

```
  Reference Date
       |
       v
  +-----------+     +----------------+     +-------------------+
  | Residence |---->| Retention      |---->| End of Retention  |
  | Period    |     | (Blocked) Per. |     | (Deletion)        |
  +-----------+     +----------------+     +-------------------+
  Data actively      Data blocked,          Data permanently
  used for           available only         deleted or
  business           for legal audits       anonymized
```

- **Residence Period**: Time during which personal data can be actively used for the declared business purpose.
- **Retention Period**: Time after residence during which data is blocked but retained for legal compliance.
- **End of Retention**: Data is permanently deleted or anonymized.

### Legal Ground Types

| Type | Description |
|------|-------------|
| `consent` | Data subject has given consent |
| `contract` | Processing necessary for contract performance |
| `legalObligation` | Processing necessary for legal compliance |
| `vitalInterest` | Processing necessary to protect vital interests |
| `publicInterest` | Processing necessary for public interest tasks |
| `legitimateInterest` | Processing necessary for legitimate interests |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DATA_RETENTION_HOST` | `0.0.0.0` | Server bind address |
| `DATA_RETENTION_PORT` | `8112` | Server listen port |

## Build and Run

### Local

```sh
dub build
./build/uim-data-retention-platform-service
```

### Docker

```sh
docker build -t uim-data-retention .
docker run -p 8112:8112 uim-data-retention
```

### Podman

```sh
podman build -t uim-data-retention -f Containerfile .
podman run -p 8112:8112 uim-data-retention
```

### Kubernetes

```sh
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Testing

```sh
dub test
```

## License

See the repository root LICENSE file.
