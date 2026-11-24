# UML — Data Quality Service

Diagrams of the data quality service (Mermaid). Code lives under
`backend/source/uim/platform/data_quality/`; the layers are described in
[README.md](README.md), the architecture views in [NAFv4.md](NAFv4.md).

Contents:

1. Domain model
2. Value types and domain services
3. Ports and interactors
4. Component diagram (hexagonal layers)
5. Persistence
6. State machines
7. Sequence diagrams
8. Deployment diagram

## 1. Domain model

Every entity mixes in `TenantEntity!(Id)` (tenantId, id, createdAt/By,
updatedAt/By). Resources inside a dataset carry `datasetId` and are
addressed by the composite key `<datasetId>~<id>`. Special ids: a violation
is `<recordId>:<ruleId>`, a column profile is the field name, a user account
is the user name. `IDocumentStore` comes from uim-platform:service.

```mermaid
classDiagram
  direction LR

  class Dataset {
    DatasetId id
    string name
    string description
    string category
    QualityScores scores
    long scoredAt
    long validatedAt
    long profiledAt
    long duplicatesCheckedAt
    isScored() bool
  }

  class DataRecord {
    RecordId id
    DatasetId datasetId
    FieldValue[] fields
    double qualityScore
    int rulesChecked
    int violationCount
    string worstSeverity
    long validatedAt
    resetValidation()
  }

  class ValidationRule {
    ValidationRuleId id
    string name
    string datasetPattern
    string fieldName
    RuleType ruleType
    RuleSeverity severity
    RuleStatus status
    string pattern
    string minValue
    string maxValue
    string[] allowedValues
    bool caseSensitive
    string crossFieldName
    string operator
    string expression
    string referenceDataset
    string referenceField
    int priority
    appliesTo(DatasetId) bool
    dimension() QualityDimension
  }

  class Violation {
    ViolationId id
    DatasetId datasetId
    RecordId recordId
    ValidationRuleId ruleId
    RuleType ruleType
    string fieldName
    string fieldValue
    RuleSeverity severity
    string message
    string suggestedValue
    affectsScore() bool
  }

  class CleansingRule {
    CleansingRuleId id
    string name
    string datasetPattern
    string fieldName
    CleansingAction action
    RuleStatus status
    string findPattern
    string replaceWith
    string defaultValue
    string lookupDataset
    string lookupKeyField
    string lookupValueField
    string sourceField
    int priority
  }

  class CleansingJob {
    CleansingJobId id
    DatasetId datasetId
    CleansingRuleId[] ruleIds
    bool dryRun
    bool revalidate
    JobStatus status
    long changedRecords
    long changedFields
    string[] changeLog
    start() complete() fail() cancel()
  }

  class MatchGroup {
    MatchGroupId id
    DatasetId datasetId
    MatchStrategy strategy
    double threshold
    string[] matchFields
    MatchCandidate[] candidates
    RecordId survivorRecordId
    bool resolved
    resolve(RecordId, long)
    duplicates() RecordId[]
  }

  class MatchCandidate {
    RecordId recordId
    double score
    MatchConfidence confidence
  }

  class ColumnProfile {
    ColumnProfileId id
    DatasetId datasetId
    int position
    ColumnStats stats
  }

  class QualitySnapshot {
    SnapshotId id
    DatasetId datasetId
    QualityScores scores
    long recordCount
    long violationCount
    long takenAt
  }

  class PostalAddress {
    AddressId id
    string sourceRecordId
    AddressInput input
    AddressOutcome output
  }

  class UserAccount {
    UserAccountId id
    string displayName
    string passwordHash
    string[] scopes
    bool locked
    int failedLogins
    long lockedUntil
    long lastLoginAt
    isLockedAt(long) bool
    recordFailure(long, int, long)
    recordSuccess(long)
  }

  Dataset "1" *-- "*" DataRecord
  Dataset "1" *-- "*" Violation
  Dataset "1" *-- "*" ColumnProfile
  Dataset "1" *-- "*" MatchGroup
  Dataset "1" *-- "*" CleansingJob
  Dataset "1" *-- "*" QualitySnapshot
  DataRecord "1" -- "*" Violation : has
  ValidationRule "1" -- "*" Violation : found
  MatchGroup "1" *-- "2..*" MatchCandidate
  MatchCandidate "*" --> "1" DataRecord
  CleansingJob "*" --> "*" CleansingRule : applies
  ValidationRule ..> Dataset : referenceDataset
  CleansingRule ..> Dataset : lookupDataset
```

### Enumerations

```mermaid
classDiagram
  class RuleType {
    <<enumeration>>
    required
    format
    range
    length
    enumeration
    crossField
    custom
    referenceData
    unique
  }
  class QualityDimension {
    <<enumeration>>
    completeness
    validity
    uniqueness
    consistency
    accuracy
  }
  class RuleSeverity {
    <<enumeration>>
    info
    warning
    error
    critical
  }
  class RuleStatus {
    <<enumeration>>
    draft
    active
    inactive
  }
  class JobStatus {
    <<enumeration>>
    pending
    running
    completed
    failed
    cancelled
  }
  class CleansingAction {
    <<enumeration>>
    trim
    collapseWhitespace
    upperCase
    lowerCase
    titleCase
    removeDiacritics
    replace
    defaultValue
    clear
    standardizeCountry
    enrich
  }
  class MatchStrategy {
    <<enumeration>>
    exact
    fuzzy
    phonetic
    composite
  }
  class QualityRating {
    <<enumeration>>
    excellent
    good
    fair
    poor
    critical
  }
  class AddressQuality {
    <<enumeration>>
    verified
    corrected
    partial
    invalid
    unverifiable
  }
  RuleType ..> QualityDimension : dimensionOf()
```

## 2. Value types and domain services

```mermaid
classDiagram
  direction LR
  class FieldValue {
    string name
    string value
  }
  class QualityScores {
    double completeness
    double validity
    double uniqueness
    double consistency
    double accuracy
    overall() double
    rating() QualityRating
  }
  class ColumnStats {
    string fieldName
    ProfiledType detectedType
    long missingCount
    long distinctCount
    double completeness
    double uniqueness
    string minValue
    string maxValue
    double mean
    string[] topValues
    string[] patterns
  }
  class AddressInput
  class AddressOutcome {
    string country
    bool countryRecognized
    bool postalCodePlausible
    AddressQuality quality
    string[] changes
  }

  class ValidationEngine {
    check(rules, fields, lookup) RecordCheck
    checkUniqueness(rules, records, ids) RuleFinding[][]
  }
  class RecordCheck {
    int rulesChecked
    RuleFinding[] findings
    score() double
    worstSeverity() string
  }
  class RuleExpression {
    Comparison[] premise
    Comparison[] conclusion
  }
  class CleansingEngine {
    apply(rules, fields, lookup) CleansingOutcome
  }
  class AddressCleanser {
    cleanse(AddressInput) AddressOutcome
  }
  class DuplicateDetector {
    detect(records, fields, strategy, threshold) DetectedGroup[]
  }
  class DataProfiler {
    profile(records, topN) ColumnStats[]
  }
  class QualityScorer {
    score(ScoreInput) QualityScores
  }
  class Similarity {
    <<module>>
    jaroWinkler(a, b) double
    soundex(s) string
  }

  ValidationEngine --> RecordCheck
  ValidationEngine ..> RuleExpression : custom rules
  DuplicateDetector ..> Similarity
  ValidationEngine ..> Similarity : suggestions
  CleansingEngine ..> AddressCleanser : countryCode()
  AddressCleanser --> AddressOutcome
  DataProfiler --> ColumnStats
  QualityScorer --> QualityScores
```

The domain services are pure: no I/O, no framework types. Reference data
reaches them through delegates (`ReferenceLookup`, `EnrichmentLookup`) that
the application layer fills from the record repository.

## 3. Ports and interactors

```mermaid
classDiagram
  direction LR
  class IManageDatasets {
    <<interface>>
  }
  class IManageRecords {
    <<interface>>
  }
  class IManageValidationRules {
    <<interface>>
  }
  class IManageCleansingRules {
    <<interface>>
  }
  class IValidateData {
    <<interface>>
  }
  class IProfileData {
    <<interface>>
  }
  class IDetectDuplicates {
    <<interface>>
  }
  class IScorecards {
    <<interface>>
  }
  class IManageCleansingJobs {
    <<interface>>
  }
  class ICleanseAddresses {
    <<interface>>
  }
  class IAuthenticate {
    <<interface>>
  }
  class IManageUsers {
    <<interface>>
  }
  class IDqStatisticsService {
    <<interface>>
  }

  class DqInteractor {
    <<abstract>>
    DqRepositories repos
    IClock clock
    IDqEventPublisher events
    IDqUnitOfWork unitOfWork
    DqPolicy policy
  }

  DqInteractor <|-- ManageDatasetsUseCase
  DqInteractor <|-- ManageRecordsUseCase
  DqInteractor <|-- ManageValidationRulesUseCase
  DqInteractor <|-- ManageCleansingRulesUseCase
  DqInteractor <|-- ValidateDataUseCase
  DqInteractor <|-- ProfileDataUseCase
  DqInteractor <|-- DetectDuplicatesUseCase
  DqInteractor <|-- ManageScorecardsUseCase
  DqInteractor <|-- ManageCleansingJobsUseCase
  DqInteractor <|-- CleanseAddressesUseCase
  DqInteractor <|-- AccessUseCase

  IManageDatasets <|.. ManageDatasetsUseCase
  IManageRecords <|.. ManageRecordsUseCase
  IManageValidationRules <|.. ManageValidationRulesUseCase
  IManageCleansingRules <|.. ManageCleansingRulesUseCase
  IValidateData <|.. ValidateDataUseCase
  IProfileData <|.. ProfileDataUseCase
  IDetectDuplicates <|.. DetectDuplicatesUseCase
  IScorecards <|.. ManageScorecardsUseCase
  IManageCleansingJobs <|.. ManageCleansingJobsUseCase
  ICleanseAddresses <|.. CleanseAddressesUseCase
  IAuthenticate <|.. AccessUseCase
  IManageUsers <|.. AccessUseCase
  IDqStatisticsService <|.. DqStatisticsService

  ManageRecordsUseCase --> ValidateDataUseCase : auto-validate
  ValidateDataUseCase --> ManageScorecardsUseCase : snapshot
  ProfileDataUseCase --> ManageScorecardsUseCase
  DetectDuplicatesUseCase --> ValidateDataUseCase
  DetectDuplicatesUseCase --> ManageScorecardsUseCase
  ManageCleansingJobsUseCase --> ValidateDataUseCase : revalidate
  ManageCleansingJobsUseCase --> IManageCleansingRules
  ValidateDataUseCase --> IManageValidationRules
```

Driven ports:

```mermaid
classDiagram
  direction LR
  class IDqTenantRepository~E, Id~ {
    <<interface>>
    findAll(t) E[]
    findById(t, id) E
    existsById(t, id) bool
    countAll(t) size_t
    save(e)
    removeById(t, id) bool
  }
  class IDqScopedRepository~E, Id~ {
    <<interface>>
    findAll(t) E[]
    findByDataset(t, ds) E[]
    findById(t, ds, id) E
    countByDataset(t, ds) size_t
    save(e)
    removeById(t, ds, id) bool
    removeByDataset(t, ds) size_t
  }
  class IDqUnitOfWork {
    <<interface>>
    batch(work)
  }
  class IDocumentStore {
    <<interface>>
    all() get() put() remove() count()
  }
  class IDqEventPublisher {
    <<interface>>
    publish(type, tenant, subject, data)
  }
  class IClock {
    <<interface>>
    now() long
  }
  class IPasswordHasher {
    <<interface>>
    hash(password) string
    verify(password, encoded) bool
    needsRehash(encoded) bool
  }
  class ITokenIssuer {
    <<interface>>
    issue(tenant, user, scopes) IssuedToken
  }

  IDqTenantRepository <|-- IDatasetRepository
  IDqTenantRepository <|-- IValidationRuleRepository
  IDqTenantRepository <|-- ICleansingRuleRepository
  IDqTenantRepository <|-- IAddressRepository
  IDqTenantRepository <|-- IUserAccountRepository
  IDqScopedRepository <|-- IRecordRepository
  IDqScopedRepository <|-- IViolationRepository
  IDqScopedRepository <|-- ICleansingJobRepository
  IDqScopedRepository <|-- IMatchGroupRepository
  IDqScopedRepository <|-- IColumnProfileRepository
  IDqScopedRepository <|-- ISnapshotRepository

  IPasswordHasher <|.. Pbkdf2PasswordHasher
  ITokenIssuer <|.. Hs256TokenIssuer
  IClock <|.. SystemClock
  IClock <|.. ManualClock
  IDqEventPublisher <|.. LoggingEventPublisher
  IDqUnitOfWork <|.. BatchingFileDocumentStore
  IDqUnitOfWork <|.. BatchingMemoryDocumentStore
  IDocumentStore <|.. BatchingFileDocumentStore
  IDocumentStore <|.. BatchingMemoryDocumentStore
```

## 4. Component diagram (hexagonal layers)

```mermaid
flowchart LR
  subgraph Clients
    FIORI[Fiori app<br/>OpenUI5]
    EXT[Integrations<br/>REST clients]
    OPS[CLI / GtkD GUI]
  end

  subgraph Presentation
    AUTH[AuthController<br/>/auth]
    REST[DqApiController<br/>/api/v1]
    ODATA[ODataController + engine<br/>/odata/v4/data-quality]
    WEB[FrontendController<br/>/app]
    CLI[CLI commands]
    GUI[Entity browser]
  end

  subgraph Application
    UC[Interactors<br/>datasets, records, rules,<br/>validation, profiling, duplicates,<br/>scorecards, jobs, addresses, access]
    APPSVC[Statistics, ReferenceData,<br/>demo data]
  end

  subgraph Domain
    ENT[Entities and value types]
    DSVC[Validation engine, expressions,<br/>cleansing engine, address cleanser,<br/>duplicate detector, profiler, scorer]
  end

  subgraph Ports
    DRIVING[Driving ports<br/>DqPorts]
    DRIVEN[Driven ports<br/>repositories, unit of work,<br/>events, clock, hasher, issuer]
  end

  subgraph Infrastructure
    CFG[Configuration<br/>defaults → json → DQ_* → VCAP]
    SEC[Security<br/>XSUAA RS256 / HS256 / PBKDF2]
    WRK[Cleansing job worker]
    LOG[Structured logging, events]
    CONT[DqContainer<br/>composition root]
  end

  subgraph Persistence
    REPO[Document repositories<br/>+ mappers]
    STORE[Batching memory / file store]
  end

  FIORI --> AUTH
  FIORI --> ODATA
  FIORI --> WEB
  EXT --> REST
  EXT --> AUTH
  OPS --> CLI
  OPS --> GUI
  AUTH --> DRIVING
  REST --> DRIVING
  ODATA --> DRIVING
  CLI --> ODATA
  GUI --> ODATA
  WRK --> DRIVING
  DRIVING --> UC
  UC --> DSVC
  UC --> ENT
  UC --> APPSVC
  UC --> DRIVEN
  DRIVEN --> REPO
  DRIVEN --> SEC
  DRIVEN --> LOG
  REPO --> STORE
  CONT -.wires.-> UC
  CONT -.wires.-> REPO
  CONT -.wires.-> SEC
  CFG -.-> CONT
  SEC -.verifies tokens.-> AUTH
  SEC -.verifies tokens.-> REST
  SEC -.verifies tokens.-> ODATA
```

Dependencies point inwards: the domain knows nothing of ports, vibe.d or
storage; interactors only know ports; adapters only know driving ports.

## 5. Persistence

```mermaid
erDiagram
  DATASETS ||--o{ RECORDS : "dq.records"
  DATASETS ||--o{ VIOLATIONS : "dq.violations"
  DATASETS ||--o{ COLUMN_PROFILES : "dq.columnProfiles"
  DATASETS ||--o{ MATCH_GROUPS : "dq.matchGroups"
  DATASETS ||--o{ CLEANSING_JOBS : "dq.cleansingJobs"
  DATASETS ||--o{ SNAPSHOTS : "dq.snapshots"
  RECORDS ||--o{ VIOLATIONS : "recordId"
  VALIDATION_RULES ||--o{ VIOLATIONS : "ruleId"

  DATASETS {
    string key "id"
    string tenantId
    json scores
  }
  RECORDS {
    string key "datasetId~id"
    string datasetId
    json fields "[{name, value}]"
  }
  VIOLATIONS {
    string key "datasetId~recordId:ruleId"
  }
  VALIDATION_RULES {
    string key "id"
  }
  CLEANSING_RULES {
    string key "id"
  }
  ADDRESSES {
    string key "id"
    json input
    json output
  }
  USERS {
    string key "user name"
    string passwordHash "pbkdf2-sha256$iter$salt$hash"
    json scopes
  }
```

Each collection is partitioned by tenant (`IDocumentStore`: collection →
tenant → key → JSON document). The file store keeps one JSON snapshot;
`IDqUnitOfWork.batch` defers the snapshot write to the end of a batch.

## 6. State machines

Cleansing job:

```mermaid
stateDiagram-v2
  [*] --> pending : createCleansingJob
  pending --> running : start (worker / RunCleansingJob)
  pending --> cancelled : cancel
  running --> completed : all records processed
  running --> failed : error
  completed --> [*]
  failed --> [*]
  cancelled --> [*]
```

Match group:

```mermaid
stateDiagram-v2
  [*] --> open : detectDuplicates
  open --> open : record deleted (candidate removed)
  open --> [*] : fewer than 2 candidates / dismissed / re-detection
  open --> resolved : resolve(survivor[, merge])
  resolved --> [*] : dismissed or dataset deleted
```

User account (built-in login):

```mermaid
stateDiagram-v2
  [*] --> active : createUser / ensureAdministrator
  active --> active : login ok (failedLogins = 0)
  active --> temporarilyLocked : maxFailedLogins wrong passwords
  temporarilyLocked --> active : lockSeconds elapsed / new password
  active --> locked : administrator locks
  locked --> active : administrator unlocks
  active --> [*] : deleted (not the own account, not the last admin)
```

Validation rule / cleansing rule: `draft → active ⇄ inactive`; only active
rules run.

## 7. Sequence diagrams

### Login and an authorized OData call (authMode jwt)

```mermaid
sequenceDiagram
  actor U as User
  participant UI as Fiori app
  participant A as AuthController
  participant AC as AccessUseCase
  participant H as Pbkdf2PasswordHasher
  participant T as Hs256TokenIssuer
  participant O as ODataController
  participant E as ODataEngine

  UI->>A: GET /auth/config
  A-->>UI: {mode: jwt, loginRequired: true}
  U->>UI: user name, password
  UI->>A: POST /auth/login
  A->>AC: login(LoginRequest)
  AC->>H: verify(password, hash)
  alt wrong password
    AC->>AC: recordFailure (lock after 5)
    A-->>UI: 401 Invalid user name or password
  else ok
    AC->>T: issue(tenant, user, scopes)
    T-->>AC: HS256 JWT (exp, zid, scope[])
    A-->>UI: {access_token, expires_in, scope, user}
  end
  UI->>UI: sessionStorage, create ODataModel with Authorization header
  UI->>O: GET /Datasets (Bearer)
  O->>O: Hs256TokenVerifier.verify → RequestContext(tenant, user, scopes)
  O->>E: query (enforceScopes: Read)
  E-->>UI: rows
```

### Validating a dataset

```mermaid
sequenceDiagram
  participant C as Client (OData action ValidateDataset)
  participant V as ValidateDataUseCase
  participant R as IManageValidationRules
  participant RD as ReferenceData
  participant VE as ValidationEngine
  participant UOW as IDqUnitOfWork
  participant S as ManageScorecardsUseCase

  C->>V: validateDataset(tenant, dataset)
  V->>R: applicableValidationRules (active, pattern, priority)
  V->>V: load records
  loop every record
    V->>VE: check(rules, fields, RD.contains)
    VE->>RD: referenceData lookups (indexed once)
  end
  V->>VE: checkUniqueness(rules, records)
  V->>UOW: batch { replace violations, update records, dataset.validatedAt }
  Note over UOW: file store: one snapshot write
  V->>S: takeSnapshot → scores (5 dimensions), trend point
  V-->>C: ValidationRunResult
```

### Cleansing job with revalidation

```mermaid
sequenceDiagram
  participant W as CleansingJobWorker (timer)
  participant J as ManageCleansingJobsUseCase
  participant CE as CleansingEngine
  participant V as ValidateDataUseCase

  W->>J: runPendingJobs(tenant)
  J->>J: job.start()
  J->>J: rules (job.ruleIds or all active matching)
  loop every record (one batch)
    J->>CE: apply(rules, fields, ReferenceData.lookup)
    CE-->>J: fields', changes
    J->>J: save record (unless dry run), log changes
  end
  J->>J: job.complete() / fail()
  opt changed records and revalidate
    J->>V: validateDataset
  end
```

### Resolving duplicates into a golden record

```mermaid
sequenceDiagram
  participant UI as Fiori app
  participant D as DetectDuplicatesUseCase
  participant V as ValidateDataUseCase
  participant S as ManageScorecardsUseCase

  UI->>D: ResolveMatchGroup(key, survivor, merge = true)
  D->>D: group.resolve(survivor)
  loop every duplicate
    D->>D: fill empty survivor fields, delete record and its violations
  end
  D->>V: validateRecord(survivor)
  D->>S: computeScorecard
  D-->>UI: {removedRecords, mergedFields}
```

## 8. Deployment diagram

```mermaid
flowchart TB
  subgraph BTP[SAP BTP Cloud Foundry]
    AR[data-quality-approuter<br/>approuter.nodejs + Fiori app]
    SRV[data-quality-srv<br/>binary_buildpack<br/>uim-data-quality-platform-service]
    XSUAA[(XSUAA<br/>data-quality-xsuaa)]
    UPS[(user-provided service<br/>data-quality-config)]
  end
  Browser((Browser)) -->|HTTPS| AR
  AR -->|login| XSUAA
  AR -->|destination data-quality-srv<br/>forwardAuthToken| SRV
  SRV -.verificationkey.-> XSUAA
  SRV -.overrides.-> UPS

  subgraph K8S[Kubernetes / container]
    POD[Deployment data-quality<br/>1 replica, DQ_AUTH_MODE=jwt]
    PVC[(PVC /data<br/>data-quality.json)]
    SEC[(Secret<br/>DQ_JWT_SECRET, DQ_ADMIN_PASSWORD)]
    CM[(ConfigMap)]
  end
  Browser2((Browser / API client)) -->|Service :80 → 8086<br/>/app, /auth, /api/v1, /odata| POD
  POD --> PVC
  SEC -.env.-> POD
  CM -.env.-> POD
```
