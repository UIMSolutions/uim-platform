# Master Data Governance — UML Diagrams

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class BusinessPartner {
        +BusinessPartnerId id
        +TenantId tenantId
        +string bpNumber
        +BPCategory category
        +BPStatus status
        +BPLegalForm legalForm
        +ValidationStatus validationStatus
        +string firstName
        +string lastName
        +string title
        +string gender
        +string dateOfBirth
        +string nationality
        +string organizationName
        +string organizationNameAdditional
        +string industryCode
        +string industryDescription
        +string email
        +string phone
        +string mobile
        +string fax
        +string website
        +string street
        +string houseNumber
        +string postalCode
        +string city
        +string region
        +string country
        +string addressType
        +string taxNumber
        +string vatNumber
        +string taxJurisdiction
        +string roles
        +string bankAccountNumber
        +string bankRoutingNumber
        +string bankName
        +string bankCountry
        +string externalBpId
        +string sourceSystem
        +int qualityScore
        +string lastReplicatedAt
        +string searchTerms
        +string language
        +toJson() Json
    }

    class ChangeRequest {
        +ChangeRequestId id
        +TenantId tenantId
        +BusinessPartnerId businessPartnerId
        +ChangeRequestStatus status
        +ChangeRequestType requestType
        +string subject
        +string description
        +string changedFields
        +string proposedValues
        +string currentValues
        +string comments
        +string reviewerComments
        +UserId requestedBy
        +UserId reviewedBy
        +UserId decidedBy
        +string dueDate
        +string submittedAt
        +string reviewStartedAt
        +string decidedAt
        +int priority
        +string externalReference
        +toJson() Json
    }

    class DataQualityRule {
        +DataQualityRuleId id
        +TenantId tenantId
        +string name
        +string description
        +string fieldName
        +string fieldPath
        +RuleType ruleType
        +RuleSeverity severity
        +string condition
        +string errorMessage
        +string bpCategory
        +bool isActive
        +int weight
        +string validValues
        +string regexPattern
        +string minValue
        +string maxValue
        +toJson() Json
    }

    class DataQualityScore {
        +DataQualityScoreId id
        +TenantId tenantId
        +BusinessPartnerId businessPartnerId
        +int overallScore
        +int completenessScore
        +int consistencyScore
        +int accuracyScore
        +int uniquenessScore
        +QualityStatus qualityStatus
        +string lastEvaluatedAt
        +string evaluationDetails
        +string failedRules
        +string passedRules
        +int totalRulesChecked
        +int failedRulesCount
        +toJson() Json
    }

    class Replication {
        +ReplicationId id
        +TenantId tenantId
        +BusinessPartnerId businessPartnerId
        +string targetSystem
        +string targetSystemType
        +ReplicationType replicationType
        +ReplicationStatus status
        +UserId triggeredBy
        +string scheduledAt
        +string startedAt
        +long completedAt
        +string errorMessage
        +string replicatedFields
        +int retryCount
        +int maxRetries
        +string correlationId
        +string batchId
        +toJson() Json
    }

    BusinessPartner "1" --> "0..*" ChangeRequest : governs
    BusinessPartner "1" --> "0..1" DataQualityScore : evaluated by
    BusinessPartner "1" --> "0..*" Replication : replicated via
    DataQualityRule "0..*" --> "0..*" BusinessPartner : validates
```

## Sequence Diagram — Change Request Approval Workflow

```mermaid
sequenceDiagram
    participant U as User
    participant API as REST API
    participant UC as ManageChangeRequestsUseCase
    participant Repo as ChangeRequestRepository
    participant R as Reviewer

    U->>API: POST /change-requests (subject, bpId, changedFields)
    API->>UC: createChangeRequest(dto)
    UC->>Repo: save(changeRequest {status=draft})
    Repo-->>UC: saved
    UC-->>API: CommandResult(success, id)
    API-->>U: 201 Created {id}

    U->>API: PUT /change-requests/:id {action=submit}
    API->>UC: submitChangeRequest(id, userId)
    UC->>Repo: findById(id)
    Repo-->>UC: ChangeRequest
    UC->>Repo: update({status=submitted})
    UC-->>API: CommandResult(success)
    API-->>U: 200 OK

    R->>API: PUT /change-requests/:id {action=approve, comments}
    API->>UC: approveChangeRequest(id, reviewerId, comments)
    UC->>Repo: findById(id)
    Repo-->>UC: ChangeRequest
    UC->>Repo: update({status=approved, decidedBy=reviewerId})
    UC-->>API: CommandResult(success)
    API-->>R: 200 OK
```

## Sequence Diagram — Business Partner Creation with Quality Evaluation

```mermaid
sequenceDiagram
    participant C as Client
    participant API as REST API
    participant BPUC as ManageBusinessPartnersUseCase
    participant DQUC as ManageDataQualityScoresUseCase
    participant BPRepo as BusinessPartnerRepository
    participant DQRepo as DataQualityScoreRepository

    C->>API: POST /business-partners (organizationName, country, email, ...)
    API->>BPUC: createBusinessPartner(dto)
    BPUC->>BPUC: MasterdataGovernanceValidator.isValidBusinessPartner()
    BPUC->>BPRepo: save(bp {validationStatus=notValidated})
    BPRepo-->>BPUC: saved
    BPUC-->>API: CommandResult(success, id)
    API-->>C: 201 Created {id}

    C->>API: POST /data-quality-scores (bpId, completeness=80, accuracy=75, ...)
    API->>DQUC: createDataQualityScore(dto)
    DQUC->>DQUC: calculates qualityStatus from overallScore
    DQUC->>DQRepo: save(score {qualityStatus=good})
    DQRepo-->>DQUC: saved
    DQUC-->>API: CommandResult(success, id)
    API-->>C: 201 Created {id}
```

## State Diagram — Change Request Lifecycle

```mermaid
stateDiagram-v2
    [*] --> draft : create
    draft --> submitted : submit
    submitted --> inReview : reviewer opens
    inReview --> approved : approve
    inReview --> rejected : reject
    inReview --> revisionRequested : request revision
    submitted --> revisionRequested : request revision
    revisionRequested --> submitted : resubmit
    draft --> withdrawn : withdraw
    submitted --> withdrawn : withdraw
    inReview --> withdrawn : withdraw
    approved --> [*]
    rejected --> [*]
    withdrawn --> [*]
```

## State Diagram — Replication Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending : create replication
    pending --> inProgress : start processing
    pending --> cancelled : cancel
    inProgress --> completed : success
    inProgress --> failed : error
    failed --> pending : retry
    cancelled --> [*]
    completed --> [*]
    skipped --> [*]
```

## Component Diagram

```mermaid
graph TB
    subgraph "Presentation Layer"
        BPC[BusinessPartnerController]
        CRC[ChangeRequestController]
        DQRC[DataQualityRuleController]
        DQSC[DataQualityScoreController]
        RC[ReplicationController]
        HC[HealthController]
    end

    subgraph "Application Layer"
        BPUC[ManageBusinessPartnersUseCase]
        CRUC[ManageChangeRequestsUseCase]
        DQRUC[ManageDataQualityRulesUseCase]
        DQSUC[ManageDataQualityScoresUseCase]
        RUC[ManageReplicationsUseCase]
    end

    subgraph "Domain Layer"
        BPE[BusinessPartner entity]
        CRE[ChangeRequest entity]
        DQRE[DataQualityRule entity]
        DQSE[DataQualityScore entity]
        RE[Replication entity]
        VAL[MasterdataGovernanceValidator]
    end

    subgraph "Infrastructure Layer"
        MBPR[MemoryBusinessPartnerRepository]
        MCRR[MemoryChangeRequestRepository]
        MDQRR[MemoryDataQualityRuleRepository]
        MDQSR[MemoryDataQualityScoreRepository]
        MRR[MemoryReplicationRepository]
        CFG[SrvConfig]
        CON[Container]
    end

    BPC --> BPUC
    CRC --> CRUC
    DQRC --> DQRUC
    DQSC --> DQSUC
    RC --> RUC

    BPUC --> BPE
    BPUC --> VAL
    CRUC --> CRE
    CRUC --> VAL
    DQRUC --> DQRE
    DQSUC --> DQSE
    RUC --> RE
    RUC --> VAL

    BPUC --> MBPR
    CRUC --> MCRR
    DQRUC --> MDQRR
    DQSUC --> MDQSR
    RUC --> MRR
```
