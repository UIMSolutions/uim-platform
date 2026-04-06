# Personal Data Manager Service - UML Diagrams

## Domain Class Diagram

```mermaid
classDiagram
    class DataSubject {
        +DataSubjectId id
        +TenantId tenantId
        +DataSubjectType subjectType
        +DataSubjectStatus status
        +string firstName
        +string lastName
        +string email
        +string phone
        +string dateOfBirth
        +string organizationName
        +string organizationId
        +string externalId
        +string[] applicationIds
        +string createdBy
        +string createdAt
    }

    class DataSubjectRequest {
        +DataSubjectRequestId id
        +TenantId tenantId
        +DataSubjectId dataSubjectId
        +RequestType requestType
        +RequestStatus status
        +RequestPriority priority
        +string description
        +string[] applicationIds
        +string[] dataCategoryIds
        +ProcessingComment[] comments
        +string assignedTo
        +string dueDate
        +string rejectionReason
    }

    class PersonalDataRecord {
        +PersonalDataRecordId id
        +TenantId tenantId
        +DataSubjectId dataSubjectId
        +RegisteredApplicationId applicationId
        +DataCategoryType dataCategory
        +DataSensitivity sensitivity
        +string fieldName
        +string fieldValue
        +ProcessingPurposeId purposeId
        +LegalBasis legalBasis
        +RetentionRuleId retentionRuleId
        +bool isAnonymized
    }

    class RegisteredApplication {
        +RegisteredApplicationId id
        +TenantId tenantId
        +string name
        +string description
        +ApplicationStatus status
        +string endpointUrl
        +string apiVersion
        +string[] dataCategoryIds
        +string[] purposeIds
        +string contactEmail
        +string contactName
    }

    class ProcessingPurpose {
        +ProcessingPurposeId id
        +TenantId tenantId
        +string name
        +string description
        +PurposeStatus status
        +LegalBasis legalBasis
        +string[] dataCategoryIds
        +string[] applicationIds
        +string retentionPeriod
        +string dataProtectionOfficer
        +bool requiresConsent
    }

    class ConsentRecord {
        +ConsentRecordId id
        +TenantId tenantId
        +DataSubjectId dataSubjectId
        +ProcessingPurposeId purposeId
        +ConsentStatus status
        +string consentText
        +string consentVersion
        +string givenAt
        +string withdrawnAt
        +string expiresAt
        +string ipAddress
        +string userAgent
        +string source
    }

    class RetentionRule {
        +RetentionRuleId id
        +TenantId tenantId
        +string name
        +string description
        +RetentionRuleStatus status
        +string retentionPeriod
        +RetentionPeriodUnit periodUnit
        +bool autoDelete
        +bool notifyBeforeExpiry
        +string notifyDaysBefore
        +string[] applicationIds
    }

    class DataProcessingLog {
        +DataProcessingLogId id
        +TenantId tenantId
        +DataSubjectId dataSubjectId
        +DataSubjectRequestId requestId
        +string applicationId
        +LogEntryType entryType
        +LogSeverity severity
        +string action
        +string details
        +string[] affectedFields
        +string ipAddress
    }

    DataSubject "1" --> "*" DataSubjectRequest : triggers
    DataSubject "1" --> "*" PersonalDataRecord : owns
    DataSubject "1" --> "*" ConsentRecord : gives
    DataSubject "1" --> "*" DataProcessingLog : generates

    RegisteredApplication "1" --> "*" PersonalDataRecord : stores
    RegisteredApplication "1" --> "*" ProcessingPurpose : implements

    ProcessingPurpose "1" --> "*" ConsentRecord : requires
    ProcessingPurpose "1" --> "*" PersonalDataRecord : justifies

    RetentionRule "1" --> "*" PersonalDataRecord : governs
    DataSubjectRequest "1" --> "*" DataProcessingLog : produces
```

## Hexagonal Architecture

```mermaid
graph TB
    subgraph "Driving Adapters (Left)"
        HTTP[HTTP Controllers]
        REST[REST API Clients]
    end

    subgraph "Application Core"
        subgraph "Presentation Layer"
            DSC[DataSubjectController]
            DSRC[DataSubjectRequestController]
            PDRC[PersonalDataRecordController]
            RAC[RegisteredApplicationController]
            PPC[ProcessingPurposeController]
            CRC[ConsentRecordController]
            RRC[RetentionRuleController]
            DPLC[DataProcessingLogController]
        end

        subgraph "Application Layer"
            UCS[ManageDataSubjectsUseCase]
            UCR[ManageDataSubjectRequestsUseCase]
            UCP[ManagePersonalDataRecordsUseCase]
            UCA[ManageRegisteredApplicationsUseCase]
            UCPP[ManageProcessingPurposesUseCase]
            UCC[ManageConsentRecordsUseCase]
            UCRT[ManageRetentionRulesUseCase]
            UCL[ManageDataProcessingLogsUseCase]
        end

        subgraph "Domain Layer"
            DS[DataSubject]
            DSR[DataSubjectRequest]
            PDR[PersonalDataRecord]
            RA[RegisteredApplication]
            PP[ProcessingPurpose]
            CR[ConsentRecord]
            RR[RetentionRule]
            DPL[DataProcessingLog]
            VAL[DataSubjectValidator]
        end

        subgraph "Ports"
            PR1[DataSubjectRepository]
            PR2[DataSubjectRequestRepository]
            PR3[PersonalDataRecordRepository]
            PR4[RegisteredApplicationRepository]
            PR5[ProcessingPurposeRepository]
            PR6[ConsentRecordRepository]
            PR7[RetentionRuleRepository]
            PR8[DataProcessingLogRepository]
        end
    end

    subgraph "Driven Adapters (Right)"
        MEM[Memory Repositories]
        FILE[File Repositories]
        MONGO[MongoDB Repositories]
    end

    HTTP --> DSC & DSRC & PDRC & RAC & PPC & CRC & RRC & DPLC
    DSC --> UCS
    DSRC --> UCR
    PDRC --> UCP
    RAC --> UCA
    PPC --> UCPP
    CRC --> UCC
    RRC --> UCRT
    DPLC --> UCL

    UCS --> PR1
    UCR --> PR2
    UCP --> PR3
    UCA --> PR4
    UCPP --> PR5
    UCC --> PR6
    UCRT --> PR7
    UCL --> PR8

    PR1 & PR2 & PR3 & PR4 & PR5 & PR6 & PR7 & PR8 --> MEM
    PR1 & PR2 & PR3 & PR4 & PR5 & PR6 & PR7 & PR8 -.-> FILE
    PR1 & PR2 & PR3 & PR4 & PR5 & PR6 & PR7 & PR8 -.-> MONGO
```

## GDPR Request Processing Sequence

```mermaid
sequenceDiagram
    actor DPO as Data Protection Officer
    participant API as REST API
    participant Ctrl as DataSubjectRequestController
    participant UC as ManageDataSubjectRequestsUseCase
    participant Repo as DataSubjectRequestRepository
    participant Log as DataProcessingLogRepository

    DPO->>API: POST /api/v1/personal-data/requests
    API->>Ctrl: handleCreate(req, res)
    Ctrl->>UC: create(CreateDataSubjectRequestRequest)
    UC->>Repo: save(DataSubjectRequest)
    Repo-->>UC: ok
    UC-->>Ctrl: CommandResult{success, id}
    Ctrl-->>API: 201 Created

    DPO->>API: PUT /api/v1/personal-data/requests/{id}
    API->>Ctrl: handleUpdate(req, res)
    Ctrl->>UC: update(UpdateDataSubjectRequestRequest)
    UC->>Repo: findById(id)
    Repo-->>UC: DataSubjectRequest
    UC->>Repo: update(modified request)
    Repo-->>UC: ok
    UC-->>Ctrl: CommandResult{success}
    Ctrl-->>API: 200 OK
```

## Data Subject Erasure Sequence

```mermaid
sequenceDiagram
    actor User as Data Subject
    participant API as REST API
    participant Ctrl as DataSubjectController
    participant UC as ManageDataSubjectsUseCase
    participant Repo as DataSubjectRepository

    User->>API: POST /api/v1/personal-data/subjects/{id}/erase
    API->>Ctrl: handleErase(req, res)
    Ctrl->>UC: erase(id)
    UC->>Repo: findById(id)
    Repo-->>UC: DataSubject

    Note over UC: Anonymize personal fields
    Note over UC: firstName = "***"
    Note over UC: lastName = "***"
    Note over UC: email = ""
    Note over UC: phone = ""
    Note over UC: dateOfBirth = ""
    Note over UC: status = erased

    UC->>Repo: update(anonymized subject)
    Repo-->>UC: ok
    UC-->>Ctrl: CommandResult{success}
    Ctrl-->>API: 200 OK {"message": "Data subject erased (anonymized)"}
```

## Consent Lifecycle State Diagram

```mermaid
stateDiagram-v2
    [*] --> Active : Give Consent
    Active --> Withdrawn : Withdraw Consent
    Active --> Expired : Expiry Date Reached
    Withdrawn --> [*]
    Expired --> [*]
    Active --> Active : Update Version
```

## Request Status State Diagram

```mermaid
stateDiagram-v2
    [*] --> submitted : Create Request
    submitted --> inReview : Assign Reviewer
    inReview --> processing : Begin Processing
    processing --> completed : Finish Processing
    processing --> rejected : Reject Request
    inReview --> rejected : Reject Request
    submitted --> cancelled : Cancel Request
    inReview --> cancelled : Cancel Request
    completed --> [*]
    rejected --> [*]
    cancelled --> [*]
```

## Component Diagram

```mermaid
graph LR
    subgraph "Personal Data Manager Service"
        subgraph "API Layer"
            S[Subjects API]
            R[Requests API]
            REC[Records API]
            A[Applications API]
            P[Purposes API]
            C[Consents API]
            RET[Retention API]
            L[Logs API]
            H[Health API]
        end

        subgraph "Business Logic"
            BL1[Subject Management]
            BL2[Request Processing]
            BL3[Record Tracking]
            BL4[App Registration]
            BL5[Purpose Management]
            BL6[Consent Lifecycle]
            BL7[Retention Enforcement]
            BL8[Audit Logging]
        end

        subgraph "Data Store"
            DS[(In-Memory Store)]
        end
    end

    S --> BL1
    R --> BL2
    REC --> BL3
    A --> BL4
    P --> BL5
    C --> BL6
    RET --> BL7
    L --> BL8

    BL1 & BL2 & BL3 & BL4 & BL5 & BL6 & BL7 & BL8 --> DS
```

## Deployment Diagram

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "Pod: cloud-personal-data"
            Container[Personal Data Manager<br/>Port: 8102]
        end
        CM[ConfigMap: cloud-personal-data-config]
        SVC[Service: cloud-personal-data<br/>ClusterIP:8102]
    end

    Client[API Client] --> SVC
    SVC --> Container
    CM -.-> Container

    subgraph "Container Registry"
        IMG[uim-platform/cloud-personal-data:latest]
    end

    IMG -.-> Container
```
