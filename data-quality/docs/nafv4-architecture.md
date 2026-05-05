# NAF v4 Architecture Description — Data Quality Management Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Data Quality Management (DQM) microservice.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Data Quality Management
├── C1.1  Data Validation
│   ├── C1.1.1  Rule Management
│   │   ├── Create / Update / Delete validation rules
│   │   └── Rule types: required, format, range, enumeration, length, cross-field, custom, reference-data
│   ├── C1.1.2  Single-Record Validation
│   └── C1.1.3  Batch Validation
│
├── C1.2  Address Cleansing
│   ├── C1.2.1  Address Standardization (trim, case, abbreviation expansion)
│   ├── C1.2.2  Country & Postal Code Normalization
│   ├── C1.2.3  Address Quality Assessment
│   └── C1.2.4  Geocoding (rooftop, interpolated, centroid, postal-code, city)
│
├── C1.3  Duplicate Detection & Resolution
│   ├── C1.3.1  Matching Strategies
│   │   ├── Exact Match
│   │   ├── Fuzzy Match (Jaro-Winkler)
│   │   ├── Phonetic Match (Soundex)
│   │   └── Composite Match (weighted multi-strategy)
│   ├── C1.3.2  Match Group Management
│   └── C1.3.3  Survivor / Golden-Record Selection
│
├── C1.4  Data Profiling
│   ├── C1.4.1  Column-Level Statistics (completeness, uniqueness, type, min/max/mean)
│   ├── C1.4.2  Top-Value Analysis
│   └── C1.4.3  Pattern Distribution
│
├── C1.5  Data Cleansing
│   ├── C1.5.1  Cleansing Rule Management
│   │   └── Actions: trim, normalizeCase, regexReplace, defaultValue, mapValues, enrichment
│   └── C1.5.2  Cleansing Job Execution (async batch processing)
│
└── C1.6  Quality Monitoring
    ├── C1.6.1  Quality Dashboard Computation
    ├── C1.6.2  Dimension Scoring (completeness, validity, uniqueness, consistency, accuracy)
    └── C1.6.3  Quality Rating (excellent / good / fair / poor / critical)
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Ensure enterprise data meets defined quality standards before downstream consumption. |
| **Vision** | Provide automated, real-time data quality measurement, cleansing, and monitoring as a composable microservice within the UIM Platform. |
| **Scope** | All structured data flowing through the UIM Platform requiring validation, deduplication, address cleansing, profiling, or quality scoring. |
| **Stakeholders** | Data Stewards, Data Engineers, Application Developers, Compliance Officers. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
DQM Service Offerings
├── SVC-VAL   Validation Service
│   ├── SVC-VAL-RULE   Rule CRUD
│   ├── SVC-VAL-SINGLE Validate single record
│   └── SVC-VAL-BATCH  Validate record batch
│
├── SVC-ADDR  Address Service
│   ├── SVC-ADDR-CLEAN  Cleanse single address
│   ├── SVC-ADDR-BATCH  Cleanse batch addresses
│   └── SVC-ADDR-LIST   List cleansed addresses
│
├── SVC-DUP   Duplicate Detection Service
│   ├── SVC-DUP-DETECT  Run detection
│   ├── SVC-DUP-RESOLVE Resolve match group
│   └── SVC-DUP-LIST    List/get match groups
│
├── SVC-PROF  Profiling Service
│   ├── SVC-PROF-RUN    Profile dataset
│   └── SVC-PROF-GET    List/get profiles
│
├── SVC-CLN   Cleansing Service
│   ├── SVC-CLN-RULE    Cleansing rule CRUD
│   └── SVC-CLN-JOB     Cleansing job lifecycle
│
├── SVC-DASH  Dashboard Service
│   └── SVC-DASH-COMP   Compute quality dashboard
│
└── SVC-HLTH  Health Service
    └── SVC-HLTH-CHECK  Readiness / liveness probe
```

### NSOV-2 – Service Definitions

| Service ID | Name | Interface | Protocol | Path Prefix | Methods |
|---|---|---|---|---|---|
| SVC-VAL-RULE | Validation Rule Management | REST/JSON | HTTP/1.1 | `/api/v1/validation-rules` | GET, POST, PUT, DELETE |
| SVC-VAL-SINGLE | Single Validation | REST/JSON | HTTP/1.1 | `/api/v1/validate` | POST |
| SVC-VAL-BATCH | Batch Validation | REST/JSON | HTTP/1.1 | `/api/v1/validate/batch` | POST |
| SVC-ADDR-CLEAN | Address Cleansing | REST/JSON | HTTP/1.1 | `/api/v1/addresses/cleanse` | POST |
| SVC-ADDR-BATCH | Batch Address Cleansing | REST/JSON | HTTP/1.1 | `/api/v1/addresses/cleanse/batch` | POST |
| SVC-DUP-DETECT | Duplicate Detection | REST/JSON | HTTP/1.1 | `/api/v1/duplicates/detect` | POST |
| SVC-DUP-RESOLVE | Duplicate Resolution | REST/JSON | HTTP/1.1 | `/api/v1/duplicates/resolve` | POST |
| SVC-PROF-RUN | Dataset Profiling | REST/JSON | HTTP/1.1 | `/api/v1/profiles` | POST |
| SVC-CLN-RULE | Cleansing Rule Management | REST/JSON | HTTP/1.1 | `/api/v1/cleansing-rules` | GET, POST, PUT, DELETE |
| SVC-CLN-JOB | Cleansing Job Management | REST/JSON | HTTP/1.1 | `/api/v1/cleansing-jobs` | GET, POST |
| SVC-DASH-COMP | Dashboard Computation | REST/JSON | HTTP/1.1 | `/api/v1/dashboard` | POST |
| SVC-HLTH-CHECK | Health Check | REST/JSON | HTTP/1.1 | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
                                ┌─────────────────────────┐
                                │    API Gateway / LB      │
                                └────────────┬────────────┘
                                             │ HTTP :8086
                                             ▼
                  ┌──────────────────────────────────────────────────┐
                  │           Data Quality Management Service        │
                  │                                                  │
                  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
                  │  │Validation│  │ Address  │  │Duplicate │      │
                  │  │Controller│  │Controller│  │Controller│      │
                  │  └────┬─────┘  └────┬─────┘  └────┬─────┘      │
                  │       │             │             │              │
                  │  ┌────▼─────┐  ┌────▼─────┐  ┌───▼──────┐     │
                  │  │Validate  │  │Cleanse   │  │Detect    │     │
                  │  │Data UC   │  │Address UC│  │Dupes UC  │     │
                  │  └────┬─────┘  └────┬─────┘  └───┬──────┘     │
                  │       │             │             │              │
                  │  ┌────▼─────────────▼─────────────▼──────┐     │
                  │  │         Domain Services                │     │
                  │  │  ValidationEngine  AddressCleanser     │     │
                  │  │  DuplicateDetector QualityScorer       │     │
                  │  └────────────────┬───────────────────────┘     │
                  │                   │                              │
                  │  ┌────────────────▼───────────────────────┐     │
                  │  │     In-Memory Repository Adapters       │     │
                  │  │ (7 repositories, swappable via ports)   │     │
                  │  └─────────────────────────────────────────┘     │
                  └──────────────────────────────────────────────────┘
                                             │
                             ┌───────────────┼───────────────┐
                             ▼               ▼               ▼
                     ┌──────────┐   ┌──────────────┐  ┌────────────┐
                     │ Audit Log│   │  Identity &   │  │  Portal    │
                     │ Service  │   │  Directory    │  │  Service   │
                     └──────────┘   └──────────────┘  └────────────┘
```

**Operational Information Exchanges:**

| Exchange | From | To | Content | Frequency |
|---|---|---|---|---|
| OIE-1 | External System | DQM | Record data for validation | On demand |
| OIE-2 | External System | DQM | Address data for cleansing | On demand |
| OIE-3 | External System | DQM | Record set for deduplication | On demand |
| OIE-4 | DQM | Audit Log Service | Quality operations audit trail | Per operation |
| OIE-5 | DQM | Portal Service | Dashboard data | On demand |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

```
┌──────────────────────────────────────────────────────────────────┐
│  Validation Domain                                                │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  ValidationRule   │──1:N──│  ValidationResult    │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: ValidationRuleId        │       │ recordId: RecordId    │            │
│  │ tenantId          │       │ tenantId              │            │
│  │ name              │       │ isValid: bool          │            │
│  │ ruleType: RuleType│       │ qualityScore: double   │            │
│  │ severity          │       │ violations: Violation[]│            │
│  │ status: RuleStatus│       │ timestamp             │            │
│  │ fieldName         │       └──────────────────────┘            │
│  │ parameters: map   │                                            │
│  └──────────────────┘                                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Address Domain                                                   │
│                                                                   │
│  ┌──────────────────────────┐                                    │
│  │  AddressRecord            │                                    │
│  ├──────────────────────────┤                                    │
│  │ id: AddressId             │                                    │
│  │ tenantId                  │                                    │
│  │ street1, street2, city    │                                    │
│  │ state, postalCode, country│                                    │
│  │ addressType: AddressType  │                                    │
│  │ quality: AddressQuality   │                                    │
│  │ latitude, longitude       │                                    │
│  │ geocodePrecision          │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Duplicate Detection Domain                                       │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  MatchGroup       │──1:N──│  MatchCandidate      │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: MatchGroupId  │       │ recordId: RecordId    │            │
│  │ tenantId          │       │ confidenceScore       │            │
│  │ strategy          │       │ confidence: enum      │            │
│  │ threshold         │       │ fieldMatches[]        │            │
│  │ survivorId        │       └──────────────────────┘            │
│  │ resolved: bool    │                                            │
│  └──────────────────┘                                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Profiling Domain                                                 │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  DataProfile      │──1:N──│  ColumnProfile       │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: DataProfileId     │       │ columnName            │            │
│  │ tenantId          │       │ dataType: enum        │            │
│  │ datasetId         │       │ totalCount, nullCount │            │
│  │ totalRecords      │       │ uniqueCount           │            │
│  │ completenessScore │       │ minValue, maxValue    │            │
│  │ uniquenessScore   │       │ meanValue             │            │
│  │ timestamp         │       │ topValues: map        │            │
│  └──────────────────┘       │ patterns: map         │            │
│                              └──────────────────────┘            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Cleansing Domain                                                 │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  CleansingRule    │       │  CleansingJob         │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: CleansingRuleId        │       │ id: CleansingJobId    │            │
│  │ tenantId          │       │ tenantId              │            │
│  │ name, fieldName   │       │ datasetId             │            │
│  │ action: enum      │       │ ruleIds: CleansingRuleId[]     │            │
│  │ parameters: map   │       │ status: JobStatus     │            │
│  │ priority: int     │       │ totalRecords          │            │
│  │ active: bool      │       │ processedRecords      │            │
│  └──────────────────┘       │ errorCount            │            │
│                              └──────────────────────┘            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Quality Dashboard                                                │
│                                                                   │
│  ┌──────────────────────────────────────────┐                    │
│  │  QualityDashboard                         │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ tenantId, datasetId                       │                    │
│  │ overallScore: double                      │                    │
│  │ rating: QualityRating                     │                    │
│  │ completeness / validity / uniqueness /     │                    │
│  │ consistency / accuracy : double            │                    │
│  │ totalRecords, validRecords, ...            │                    │
│  │ rulesBySeverity: RuleSeverityCount[]       │                    │
│  │ trends: QualityTrendPoint[]                │                    │
│  └──────────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

**Key Enumerations:**

| Enum | Values |
|---|---|
| RuleType | required, format, range, enumeration, length, crossField, custom, referenceData |
| RuleSeverity | critical, high, medium, low, info |
| RuleStatus | active, inactive, draft, deprecated_ |
| QualityRating | excellent, good, fair, poor, critical |
| JobStatus | pending, running, completed, failed, cancelled |
| AddressType | residential, commercial, poBox, military, other |
| AddressQuality | verified, standardized, partial, unverified, invalid |
| MatchConfidence | high, medium, low, none |
| MatchStrategy | exact, fuzzy, phonetic, composite |
| CleansingAction | trim, normalizeCase, regexReplace, defaultValue, mapValues, enrichment |
| GeocodePrecision | rooftop, interpolated, centroid, postalCode, city, none |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
┌─────────────────────────────────────────────────────────────┐
│  Deployment Node: Application Server                         │
│  OS: Linux                                                   │
│  Runtime: Native D binary (compiled with dub + DMD/LDC)     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Artifact: data-quality (executable)                │     │
│  │  Source:   data-quality/source/**/*.d               │     │
│  │  Binary:   data-quality/build/data-quality          │     │
│  │  Port:     8086 (configurable DQ_PORT)              │     │
│  │  Protocol: HTTP/1.1 (vibe.d event loop)             │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Environment Variables:                                      │
│  ┌─────────┬──────────┬────────────────────────────┐       │
│  │ Name    │ Default  │ Description                 │       │
│  ├─────────┼──────────┼────────────────────────────┤       │
│  │ DQ_HOST │ 0.0.0.0  │ HTTP bind address           │       │
│  │ DQ_PORT │ 8086     │ HTTP listen port            │       │
│  └─────────┴──────────┴────────────────────────────┘       │
│                                                              │
│  Dependencies:                                               │
│  ┌────────────────────────────┬──────────┐                  │
│  │ Package                    │ Version  │                  │
│  ├────────────────────────────┼──────────┤                  │
│  │ vibe-d                     │ ~>0.10.1 │                  │
│  └────────────────────────────┴──────────┘                  │
│                                                              │
│  Persistence: In-memory (ephemeral)                          │
│  Scaling: Stateless – horizontally scalable with external    │
│           persistence adapter                                │
└─────────────────────────────────────────────────────────────┘
```

**Deployment Constraints:**

| Constraint | Description |
|---|---|
| DC-1 | Single-process, multi-threaded via vibe.d fibers |
| DC-2 | In-memory persistence is non-durable; data is lost on restart |
| DC-3 | Swapping to durable persistence requires implementing port interfaces (7 repositories) |
| DC-4 | X-Tenant-Id header required for multi-tenant data isolation |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

**Information Flows:**

| Flow ID | Source | Target | Data | Format | Trigger |
|---|---|---|---|---|---|
| IF-1 | Client | ValidationRuleController | Rule definition | JSON | User action |
| IF-2 | ValidateController | ValidationEngine | Record + active rules | Internal | API call |
| IF-3 | ValidationEngine | ValidationResultRepo | Validation results | Internal | Post-validation |
| IF-4 | Client | AddressController | Raw address | JSON | API call |
| IF-5 | AddressCleanser | AddressRepo | Standardized address | Internal | Post-cleansing |
| IF-6 | Client | DuplicateController | Record set + config | JSON | API call |
| IF-7 | DuplicateDetector | MatchGroupRepo | Match groups | Internal | Post-detection |
| IF-8 | Client | ProfileController | Dataset records | JSON | API call |
| IF-9 | ProfileDataUseCase | DataProfileRepo | Column profiles | Internal | Post-profiling |
| IF-10 | Client | DashboardController | Dataset ID | JSON | API call |
| IF-11 | QualityScorer | Client | Dashboard with scores | JSON | Response |

**Data Sensitivity:**

| Data Element | Classification | Handling |
|---|---|---|
| Address records | PII (Personally Identifiable) | Tenant-isolated, no cross-tenant access |
| Record data (validation input) | Business-confidential | Tenant-isolated |
| Validation rules | Business configuration | Tenant-scoped |
| Quality scores / profiles | Operational metadata | Tenant-scoped |

---

## 8. Traceability Matrix

| Capability | Service(s) | Entity/ies | Controller | Use Case |
|---|---|---|---|---|
| C1.1 Validation | SVC-VAL-* | ValidationRule, ValidationResult | ValidationRuleController, ValidateController | ManageValidationRulesUseCase, ValidateDataUseCase |
| C1.2 Address Cleansing | SVC-ADDR-* | AddressRecord | AddressController | CleanseAddressesUseCase |
| C1.3 Duplicate Detection | SVC-DUP-* | MatchGroup | DuplicateController | DetectDuplicatesUseCase |
| C1.4 Data Profiling | SVC-PROF-* | DataProfile | ProfileController | ProfileDataUseCase |
| C1.5 Data Cleansing | SVC-CLN-* | CleansingRule, CleansingJob | CleansingRuleController, CleansingJobController | ManageCleansingRulesUseCase, ManageCleansingJobsUseCase |
| C1.6 Quality Monitoring | SVC-DASH-* | QualityDashboard | DashboardController | ComputeDashboardUseCase |

---

*Document generated for the UIM Platform Data Quality Management Service.*
*Authors: Ozan Nurettin Süel, UI Manufaktur*
*© 2018–2026 UIM Platform Team — Apache-2.0*
