# Data Quality Management Service

A microservice for enterprise data quality management, inspired by SAP Data Quality
Management (DQM). Built with **D** and **vibe.d**, following **Clean Architecture**
and **Hexagonal Architecture** (Ports & Adapters) principles.

Part of the [UIM Platform](https://www.sueel.de/uim/sap) suite.

## Features

| Capability | Description |
|---|---|
| **Validation Rules** | Configurable rules (required, format, range, enumeration, length, cross-field, custom, reference data) with severity levels and priority ordering |
| **Record Validation** | Single and batch validation of records against active rules, producing per-record quality scores and violation reports |
| **Address Cleansing** | Whitespace trimming, case normalization, country ISO-2 standardization, postal code formatting, address abbreviation expansion |
| **Geocoding** | Latitude/longitude with precision levels (rooftop, interpolated, centroid, postal code, city) |
| **Duplicate Detection** | Exact, fuzzy (Jaro-Winkler), phonetic (Soundex), and composite (weighted multi-strategy) matching with configurable thresholds |
| **Duplicate Resolution** | Golden record / survivor selection workflow |
| **Data Profiling** | Column-level statistics — completeness, uniqueness, type detection, min/max/mean, top values, pattern distribution |
| **Cleansing Rules** | Configurable transformations — trim, normalize case, regex replace, default values, enrichment lookups |
| **Cleansing Jobs** | Asynchronous batch cleansing with progress tracking |
| **Quality Dashboard** | Weighted scoring across five dimensions (completeness 25%, validity 30%, uniqueness 20%, consistency 15%, accuracy 10%) with ratings from Excellent to Critical |

## Architecture

```
data-quality/
├── source/
│   ├── app.d                          # Entry point
│   ├── domain/                        # Pure business logic (no dependencies)
│   │   ├── types.d                    #   Type aliases and enums
│   │   ├── entities/                  #   Core domain structs
│   │   │   ├── validation_rule.d
│   │   │   ├── validation_result.d
│   │   │   ├── address_record.d
│   │   │   ├── match_group.d
│   │   │   ├── data_profile.d
│   │   │   ├── cleansing_rule.d
│   │   │   ├── cleansing_job.d
│   │   │   └── quality_dashboard.d
│   │   ├── ports/                     #   Repository interfaces (hexagonal boundary)
│   │   │   ├── validation_rule_repository.d
│   │   │   ├── validation_result_repository.d
│   │   │   ├── address_repository.d
│   │   │   ├── match_group_repository.d
│   │   │   ├── data_profile_repository.d
│   │   │   ├── cleansing_rule_repository.d
│   │   │   └── cleansing_job_repository.d
│   │   └── services/                  #   Stateless domain services
│   │       ├── validation_engine.d
│   │       ├── address_cleanser.d
│   │       ├── duplicate_detector.d
│   │       └── quality_scorer.d
│   ├── application/                   #   Use case orchestration
│   │   ├── dto.d                      #   Request/response DTOs
│   │   └── usecases/
│   │       ├── manage_validation_rules.d
│   │       ├── validate_data.d
│   │       ├── cleanse_addresses.d
│   │       ├── detect_duplicates.d
│   │       ├── profile_data.d
│   │       ├── manage_cleansing_rules.d
│   │       ├── manage_cleansing_jobs.d
│   │       └── compute_dashboard.d
│   ├── infrastructure/                #   Technical adapters
│   │   ├── config.d                   #   Environment-based configuration
│   │   ├── container.d                #   Manual dependency injection
│   │   └── persistence/               #   In-memory repository implementations
│   │       ├── in_memory_validation_rule_repo.d
│   │       ├── in_memory_validation_result_repo.d
│   │       ├── in_memory_address_repo.d
│   │       ├── in_memory_match_group_repo.d
│   │       ├── in_memory_data_profile_repo.d
│   │       ├── in_memory_cleansing_rule_repo.d
│   │       └── in_memory_cleansing_job_repo.d
│   └── presentation/                  #   HTTP driving adapters
│       └── http/
│           ├── json_utils.d
│           ├── health_controller.d
│           ├── validation_rule_controller.d
│           ├── validate_controller.d
│           ├── address_controller.d
│           ├── duplicate_controller.d
│           ├── profile_controller.d
│           ├── cleansing_rule_controller.d
│           ├── cleansing_job_controller.d
│           └── dashboard_controller.d
└── dub.sdl
```

## REST API

All endpoints require `X-Tenant-Id` header for multi-tenant isolation.

### Validation Rules

```
POST   /api/v1/validation-rules          Create a validation rule
GET    /api/v1/validation-rules          List rules for tenant
GET    /api/v1/validation-rules/{id}     Get rule by ID
PUT    /api/v1/validation-rules/{id}     Update a rule
DELETE /api/v1/validation-rules/{id}     Delete a rule
```

### Data Validation

```
POST   /api/v1/validate                  Validate a single record
POST   /api/v1/validate/batch            Validate multiple records
GET    /api/v1/validate/results/{id}     Get validation result by record ID
```

### Address Cleansing

```
POST   /api/v1/addresses/cleanse         Cleanse a single address
POST   /api/v1/addresses/cleanse/batch   Cleanse multiple addresses
GET    /api/v1/addresses                 List cleansed addresses
```

### Duplicate Detection

```
POST   /api/v1/duplicates/detect         Run duplicate detection
POST   /api/v1/duplicates/resolve        Resolve a match group (select survivor)
GET    /api/v1/duplicates                List unresolved match groups
GET    /api/v1/duplicates/{id}           Get match group by ID
```

### Data Profiling

```
POST   /api/v1/profiles                  Profile a dataset
GET    /api/v1/profiles                  List profiles for tenant
GET    /api/v1/profiles/{id}             Get profile by ID
```

### Cleansing Rules

```
POST   /api/v1/cleansing-rules           Create a cleansing rule
GET    /api/v1/cleansing-rules           List rules for tenant
GET    /api/v1/cleansing-rules/{id}      Get rule by ID
PUT    /api/v1/cleansing-rules/{id}      Update a rule
DELETE /api/v1/cleansing-rules/{id}      Delete a rule
```

### Cleansing Jobs

```
POST   /api/v1/cleansing-jobs            Create a cleansing job
GET    /api/v1/cleansing-jobs            List jobs for tenant
GET    /api/v1/cleansing-jobs/{id}       Get job by ID
```

### Quality Dashboard

```
POST   /api/v1/dashboard                 Compute quality dashboard for a dataset
```

### Health

```
GET    /api/v1/health                    Service health check
```

## Build and Run

```bash
# Build
cd data-quality
dub build

# Run (default: 0.0.0.0:8086)
./build/data-quality

# Override host/port via environment
DQ_HOST=127.0.0.1 DQ_PORT=9090 ./build/data-quality
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `DQ_HOST` | `0.0.0.0` | Bind address |
| `DQ_PORT` | `8086` | Listen port |

## Quality Scoring Model

The dashboard computes an overall quality score as a weighted average of five dimensions:

| Dimension | Weight | Source |
|---|---|---|
| Completeness | 25% | Data profiling (non-null field %) |
| Validity | 30% | Validation results (rules passed %) |
| Uniqueness | 20% | Data profiling (unique value %) |
| Consistency | 15% | Cross-field validation results |
| Accuracy | 10% | Address verification, reference data matches |

Ratings:

| Rating | Score Range |
|---|---|
| Excellent | >= 95% |
| Good | >= 80% |
| Fair | >= 60% |
| Poor | >= 40% |
| Critical | < 40% |

## Technology

- **Language:** D (dub package manager)
- **HTTP Framework:** vibe.d 0.10.x
- **Persistence:** In-memory (swappable via port interfaces)
- **Architecture:** Clean + Hexagonal (Ports & Adapters) + DDD

## License

Proprietary — UIM Platform Team
