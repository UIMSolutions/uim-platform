# Data Retention Manager Service -- UML Diagrams

## Class Diagram -- Domain Entities

```mermaid
classDiagram
    class BusinessPurpose {
        +BusinessPurposeId id
        +TenantId tenantId
        +string name
        +string description
        +ApplicationGroupId applicationGroupId
        +DataSubjectRoleId dataSubjectRoleId
        +LegalEntityId legalEntityId
        +BusinessPurposeStatus status
        +long referenceDate
        +long endOfPurposeDate
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class LegalGround {
        +LegalGroundId id
        +TenantId tenantId
        +BusinessPurposeId businessPurposeId
        +string name
        +string description
        +LegalGroundType type
        +long referenceDate
        +long residenceEndDate
        +long retentionEndDate
        +bool isActive
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class RetentionRule {
        +RetentionRuleId id
        +TenantId tenantId
        +BusinessPurposeId businessPurposeId
        +LegalGroundId legalGroundId
        +int duration
        +PeriodUnit periodUnit
        +DeletionActionType actionOnExpiry
        +bool isActive
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class ResidenceRule {
        +ResidenceRuleId id
        +TenantId tenantId
        +BusinessPurposeId businessPurposeId
        +LegalGroundId legalGroundId
        +int duration
        +PeriodUnit periodUnit
        +bool isActive
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class DataSubject {
        +DataSubjectId id
        +TenantId tenantId
        +DataSubjectRoleId roleId
        +ApplicationGroupId applicationGroupId
        +string externalId
        +DataLifecycleStatus lifecycleStatus
        +long endOfPurposeDate
        +long endOfRetentionDate
        +long blockedAt
        +long deletedAt
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class DeletionRequest {
        +DeletionRequestId id
        +TenantId tenantId
        +DataSubjectId dataSubjectId
        +ApplicationGroupId applicationGroupId
        +DeletionActionType actionType
        +DeletionRequestStatus status
        +string reason
        +string requestedBy
        +long requestedAt
        +long completedAt
        +string errorMessage
        +long createdAt
        +long updatedAt
    }

    class ArchivingJob {
        +ArchivingJobId id
        +TenantId tenantId
        +ApplicationGroupId applicationGroupId
        +ArchivingOperationType operationType
        +ArchivingJobStatus status
        +string selectionCriteria
        +long scheduledAt
        +long startedAt
        +long completedAt
        +int recordsProcessed
        +int recordsFailed
        +string errorMessage
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class ApplicationGroup {
        +ApplicationGroupId id
        +TenantId tenantId
        +string name
        +string description
        +ApplicationGroupScope scope_
        +string[] applicationIds
        +bool isActive
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class LegalEntity {
        +LegalEntityId id
        +TenantId tenantId
        +string name
        +string description
        +string country
        +string region
        +bool isActive
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    class DataSubjectRole {
        +DataSubjectRoleId id
        +TenantId tenantId
        +string name
        +string description
        +bool isActive
        +UserId createdBy
        +long createdAt
        +long updatedAt
    }

    BusinessPurpose "1" --> "*" LegalGround : has legal grounds
    BusinessPurpose "1" --> "*" RetentionRule : has retention rules
    BusinessPurpose "1" --> "*" ResidenceRule : has residence rules
    BusinessPurpose "*" --> "1" ApplicationGroup : belongs to
    BusinessPurpose "*" --> "1" DataSubjectRole : scoped by
    BusinessPurpose "*" --> "1" LegalEntity : governed by
    LegalGround "1" --> "*" RetentionRule : retention rule for
    LegalGround "1" --> "*" ResidenceRule : residence rule for
    DataSubject "*" --> "1" DataSubjectRole : has role
    DataSubject "*" --> "1" ApplicationGroup : belongs to
    DataSubject "1" --> "*" DeletionRequest : deletion requests
    DeletionRequest "*" --> "1" ApplicationGroup : scoped to
    ArchivingJob "*" --> "1" ApplicationGroup : archives for
```

## Class Diagram -- Repository Interfaces

```mermaid
classDiagram
    class BusinessPurposeRepository {
        <<interface>>
        +existsById(BusinessPurposeId) bool
        +findById(BusinessPurposeId) BusinessPurpose
        +findAll(TenantId) BusinessPurpose[]
        +findByApplicationGroup(TenantId, ApplicationGroupId) BusinessPurpose[]
        +findByStatus(TenantId, BusinessPurposeStatus) BusinessPurpose[]
        +save(BusinessPurpose)
        +update(BusinessPurpose)
    }

    class LegalGroundRepository {
        <<interface>>
        +existsById(LegalGroundId) bool
        +findById(LegalGroundId) LegalGround
        +findAll(TenantId) LegalGround[]
        +findByBusinessPurpose(TenantId, BusinessPurposeId) LegalGround[]
        +findByType(TenantId, LegalGroundType) LegalGround[]
        +save(LegalGround)
        +update(LegalGround)
    }

    class RetentionRuleRepository {
        <<interface>>
        +existsById(RetentionRuleId) bool
        +findById(RetentionRuleId) RetentionRule
        +findAll(TenantId) RetentionRule[]
        +findByBusinessPurpose(TenantId, BusinessPurposeId) RetentionRule[]
        +findByLegalGround(TenantId, LegalGroundId) RetentionRule[]
        +save(RetentionRule)
        +update(RetentionRule)
    }

    class ResidenceRuleRepository {
        <<interface>>
        +existsById(ResidenceRuleId) bool
        +findById(ResidenceRuleId) ResidenceRule
        +findAll(TenantId) ResidenceRule[]
        +findByBusinessPurpose(TenantId, BusinessPurposeId) ResidenceRule[]
        +findByLegalGround(TenantId, LegalGroundId) ResidenceRule[]
        +save(ResidenceRule)
        +update(ResidenceRule)
    }

    class DataSubjectRepository {
        <<interface>>
        +existsById(DataSubjectId) bool
        +findById(DataSubjectId) DataSubject
        +findAll(TenantId) DataSubject[]
        +findByApplicationGroup(TenantId, ApplicationGroupId) DataSubject[]
        +findByLifecycleStatus(TenantId, DataLifecycleStatus) DataSubject[]
        +findByRole(TenantId, DataSubjectRoleId) DataSubject[]
        +save(DataSubject)
        +update(DataSubject)
    }

    class DeletionRequestRepository {
        <<interface>>
        +existsById(DeletionRequestId) bool
        +findById(DeletionRequestId) DeletionRequest
        +findAll(TenantId) DeletionRequest[]
        +findByDataSubject(TenantId, DataSubjectId) DeletionRequest[]
        +findByStatus(TenantId, DeletionRequestStatus) DeletionRequest[]
        +findByApplicationGroup(TenantId, ApplicationGroupId) DeletionRequest[]
        +save(DeletionRequest)
        +update(DeletionRequest)
    }

    class ArchivingJobRepository {
        <<interface>>
        +existsById(ArchivingJobId) bool
        +findById(ArchivingJobId) ArchivingJob
        +findAll(TenantId) ArchivingJob[]
        +findByApplicationGroup(TenantId, ApplicationGroupId) ArchivingJob[]
        +findByStatus(TenantId, ArchivingJobStatus) ArchivingJob[]
        +save(ArchivingJob)
        +update(ArchivingJob)
    }

    class ApplicationGroupRepository {
        <<interface>>
        +existsById(ApplicationGroupId) bool
        +findById(ApplicationGroupId) ApplicationGroup
        +findAll(TenantId) ApplicationGroup[]
        +findActive(TenantId) ApplicationGroup[]
        +save(ApplicationGroup)
        +update(ApplicationGroup)
    }

    class LegalEntityRepository {
        <<interface>>
        +existsById(LegalEntityId) bool
        +findById(LegalEntityId) LegalEntity
        +findAll(TenantId) LegalEntity[]
        +findActive(TenantId) LegalEntity[]
        +save(LegalEntity)
        +update(LegalEntity)
    }

    class DataSubjectRoleRepository {
        <<interface>>
        +existsById(DataSubjectRoleId) bool
        +findById(DataSubjectRoleId) DataSubjectRole
        +findAll(TenantId) DataSubjectRole[]
        +findActive(TenantId) DataSubjectRole[]
        +save(DataSubjectRole)
        +update(DataSubjectRole)
    }
```

## Class Diagram -- Domain Service

```mermaid
classDiagram
    class RetentionEvaluator {
        +checkEndOfPurpose(long, int, PeriodUnit, int, PeriodUnit, long) PurposeCheckResult
        +addPeriod(long, int, PeriodUnit) long
        +isResidenceExpired(long, int, PeriodUnit, long) bool
        +isRetentionExpired(long, int, PeriodUnit, long) bool
    }

    class PurposeCheckResult {
        <<enumeration>>
        withinResidence
        withinRetention
        endOfPurpose
        endOfRetention
        noRuleFound
    }

    RetentionEvaluator --> PurposeCheckResult : returns
```

## Use Case Diagram

```mermaid
graph LR
    A[API Client / DPO] --> UC1[Manage Business Purposes]
    A --> UC2[Manage Legal Grounds]
    A --> UC3[Manage Retention Rules]
    A --> UC4[Manage Residence Rules]
    A --> UC5[Manage Data Subjects]
    A --> UC6[Block Data Subject]
    A --> UC7[Manage Deletion Requests]
    A --> UC8[Manage Archiving Jobs]
    A --> UC9[Manage Application Groups]
    A --> UC10[Manage Legal Entities]
    A --> UC11[Manage Data Subject Roles]
    A --> UC12[Evaluate Retention Period]
```

## Component Diagram

```mermaid
graph TB
    subgraph Presentation["Presentation Layer (Driving Adapters)"]
        BPC[BusinessPurposeController]
        LGC[LegalGroundController]
        RRC[RetentionRuleController]
        RSC[ResidenceRuleController]
        DSC[DataSubjectController]
        DRC[DeletionRequestController]
        AJC[ArchivingJobController]
        AGC[ApplicationGroupController]
        LEC[LegalEntityController]
        DSRC[DataSubjectRoleController]
        HC[HealthController]
    end

    subgraph Application["Application Layer (Use Cases)"]
        MBPUC[ManageBusinessPurposesUC]
        MLGUC[ManageLegalGroundsUC]
        MRRUC[ManageRetentionRulesUC]
        MRSUC[ManageResidenceRulesUC]
        MDSUC[ManageDataSubjectsUC]
        MDRUC[ManageDeletionRequestsUC]
        MAJUC[ManageArchivingJobsUC]
        MAGUC[ManageApplicationGroupsUC]
        MLEUC[ManageLegalEntitiesUC]
        MDSRUC[ManageDataSubjectRolesUC]
    end

    subgraph Domain["Domain Layer"]
        E[Entities]
        RI[Repository Interfaces]
        DS[RetentionEvaluator]
        EN[Enumerations]
        VT[Value Types]
    end

    subgraph Infrastructure["Infrastructure Layer (Driven Adapters)"]
        MR[Memory Repositories]
        AC[AppConfig]
        CO[Container / DI]
    end

    BPC --> MBPUC
    LGC --> MLGUC
    RRC --> MRRUC
    RSC --> MRSUC
    DSC --> MDSUC
    DRC --> MDRUC
    AJC --> MAJUC
    AGC --> MAGUC
    LEC --> MLEUC
    DSRC --> MDSRUC

    MBPUC --> RI
    MLGUC --> RI
    MRRUC --> RI
    MRSUC --> RI
    MDSUC --> RI
    MDRUC --> RI
    MAJUC --> RI
    MAGUC --> RI
    MLEUC --> RI
    MDSRUC --> RI

    MR -.->|implements| RI
```

## Sequence Diagram -- Business Purpose Lifecycle

```mermaid
sequenceDiagram
    participant C as API Client
    participant BP as BusinessPurposeController
    participant UC as ManageBusinessPurposesUC
    participant R as BusinessPurposeRepository

    C->>BP: POST /business-purposes {name, appGroupId, legalEntityId}
    BP->>UC: create(CreateBusinessPurposeRequest)
    UC->>R: save(BusinessPurpose)
    R-->>UC: saved
    UC-->>BP: CommandResult(success, id)
    BP-->>C: 201 {id}

    C->>BP: POST /business-purposes/{id}/activate
    BP->>UC: activate(id)
    UC->>R: findById(id)
    R-->>UC: BusinessPurpose
    UC->>R: update(bp with status=active)
    R-->>UC: updated
    UC-->>BP: CommandResult(success, id)
    BP-->>C: 200 {id, status: active}
```

## Sequence Diagram -- Data Subject Blocking Workflow

```mermaid
sequenceDiagram
    participant DPO as Data Protection Officer
    participant DSC as DataSubjectController
    participant DSUC as ManageDataSubjectsUC
    participant DSR as DataSubjectRepository
    participant DRC as DeletionRequestController
    participant DRUC as ManageDeletionRequestsUC
    participant DRR as DeletionRequestRepository

    Note over DPO: End of residence period reached

    DPO->>DSC: POST /data-subjects/{id}/block
    DSC->>DSUC: block(id)
    DSUC->>DSR: findById(id)
    DSR-->>DSUC: DataSubject
    DSUC->>DSR: update(ds with status=blocked, blockedAt)
    DSR-->>DSUC: updated
    DSUC-->>DSC: CommandResult(success, id)
    DSC-->>DPO: 200 {id, lifecycleStatus: blocked}

    Note over DPO: End of retention period reached

    DPO->>DRC: POST /deletion-requests {dataSubjectId, actionType: delete}
    DRC->>DRUC: create(CreateDeletionRequestRequest)
    DRUC->>DRR: save(DeletionRequest with status=pending)
    DRR-->>DRUC: saved
    DRUC-->>DRC: CommandResult(success, id)
    DRC-->>DPO: 201 {id}
```

## Sequence Diagram -- Archiving and Destruction Workflow

```mermaid
sequenceDiagram
    participant A as Administrator
    participant AJC as ArchivingJobController
    participant AJUC as ManageArchivingJobsUC
    participant AJR as ArchivingJobRepository

    A->>AJC: POST /archiving-jobs {appGroupId, operationType: archiveAndDestruct}
    AJC->>AJUC: create(CreateArchivingJobRequest)
    AJUC->>AJR: save(ArchivingJob with status=scheduled)
    AJR-->>AJUC: saved
    AJUC-->>AJC: CommandResult(success, id)
    AJC-->>A: 201 {id}

    Note over A: Job starts processing

    A->>AJC: PUT /archiving-jobs/{id} {status: running}
    AJC->>AJUC: update(id, UpdateArchivingJobRequest)
    AJUC->>AJR: findById(id)
    AJR-->>AJUC: ArchivingJob
    AJUC->>AJR: update(job with status=running, startedAt)
    AJR-->>AJUC: updated
    AJUC-->>AJC: CommandResult(success)
    AJC-->>A: 200 {id}

    Note over A: Job completes

    A->>AJC: PUT /archiving-jobs/{id} {status: completed, recordsProcessed: 1500}
    AJC->>AJUC: update(id, UpdateArchivingJobRequest)
    AJUC->>AJR: update(job with status=completed, completedAt)
    AJR-->>AJUC: updated
    AJUC-->>AJC: CommandResult(success)
    AJC-->>A: 200 {id}
```

## Sequence Diagram -- Retention Period Evaluation

```mermaid
sequenceDiagram
    participant S as System
    participant RE as RetentionEvaluator

    S->>RE: checkEndOfPurpose(referenceDate, resDuration, resUnit, retDuration, retUnit, currentTime)
    RE->>RE: residenceEnd = addPeriod(referenceDate, resDuration, resUnit)
    RE->>RE: retentionEnd = addPeriod(residenceEnd, retDuration, retUnit)

    alt currentTime < residenceEnd
        RE-->>S: withinResidence
    else currentTime < retentionEnd
        RE-->>S: withinRetention
    else currentTime >= retentionEnd
        RE-->>S: endOfRetention
    end
```

## State Diagram -- Data Subject Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Active : Created
    Active --> Blocked : Block request / End of residence
    Blocked --> MarkedForDeletion : End of retention reached
    MarkedForDeletion --> Deleted : Deletion completed
    Active --> Archived : Archiving job
    Blocked --> Archived : Archiving job
    Deleted --> [*]
    Archived --> [*]
```

## State Diagram -- Deletion Request Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Pending : Request created
    Pending --> InProgress : Processing started
    InProgress --> Completed : Deletion successful
    InProgress --> Failed : Deletion failed
    Pending --> Cancelled : Request cancelled
    Failed --> Pending : Retry
    Completed --> [*]
    Cancelled --> [*]
```

## State Diagram -- Archiving Job Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Scheduled : Job created
    Scheduled --> Running : Execution started
    Running --> Completed : All records processed
    Running --> Failed : Error occurred
    Scheduled --> Cancelled : Job cancelled
    Failed --> Scheduled : Retry
    Completed --> [*]
    Cancelled --> [*]
```
