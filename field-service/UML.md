# UML Diagrams - Field Service Management

## Domain Model

```mermaid
classDiagram
    class ServiceCall {
        +ServiceCallId id
        +TenantId tenantId
        +CustomerId customerId
        +EquipmentId equipmentId
        +string subject
        +string description
        +ServiceCallStatus status
        +ServiceCallPriority priority
        +ServiceCallOrigin origin
        +ServiceCallCategory category
        +string serviceType
        +string contactPerson
        +string contactPhone
        +string contactEmail
        +string reportedDate
        +string dueDate
        +string resolvedDate
        +string resolution
        +string address
        +string latitude
        +string longitude
    }

    class Activity {
        +ActivityId id
        +TenantId tenantId
        +ServiceCallId serviceCallId
        +TechnicianId technicianId
        +string subject
        +string description
        +ActivityType activityType
        +ActivityStatus status
        +string plannedStart
        +string plannedEnd
        +string actualStart
        +string actualEnd
        +string travelTime
        +string workTime
        +string address
        +string latitude
        +string longitude
        +string notes
        +string feedbackCode
    }

    class Assignment {
        +AssignmentId id
        +TenantId tenantId
        +ActivityId activityId
        +TechnicianId technicianId
        +AssignmentStatus status
        +string assignedDate
        +string acceptedDate
        +string startedDate
        +string completedDate
        +string travelDistance
        +string schedulingPolicy
        +string matchScore
        +string notes
    }

    class Equipment {
        +EquipmentId id
        +TenantId tenantId
        +CustomerId customerId
        +string serialNumber
        +string name
        +string description
        +EquipmentType equipmentType
        +EquipmentStatus status
        +string manufacturer
        +string model
        +string installationDate
        +string warrantyEndDate
        +string locationAddress
        +string latitude
        +string longitude
        +string lastServiceDate
        +string nextServiceDate
        +string measuringPoint
    }

    class Technician {
        +TechnicianId id
        +TenantId tenantId
        +string firstName
        +string lastName
        +string email
        +string phone
        +TechnicianStatus status
        +string region
        +string address
        +string latitude
        +string longitude
        +string availabilityStart
        +string availabilityEnd
        +string maxWorkload
        +string currentWorkload
        +string travelRadius
    }

    class Customer {
        +CustomerId id
        +TenantId tenantId
        +string name
        +string description
        +CustomerType customerType
        +CustomerStatus status
        +string contactPerson
        +string email
        +string phone
        +string address
        +string website
        +string industry
        +string accountNumber
    }

    class Skill {
        +SkillId id
        +TenantId tenantId
        +TechnicianId technicianId
        +string name
        +string description
        +SkillCategory category
        +ProficiencyLevel proficiencyLevel
        +string certificationDate
        +string expirationDate
        +string certificationNumber
        +string issuingAuthority
    }

    class Smartform {
        +SmartformId id
        +TenantId tenantId
        +ServiceCallId serviceCallId
        +ActivityId activityId
        +string name
        +string description
        +SmartformType formType
        +SmartformStatus status
        +string templateId
        +string submittedBy
        +string submittedDate
        +string approvedBy
        +string formData
        +string safetyLabel
        +string signatureData
    }

    Customer "1" --> "*" ServiceCall : raises
    Customer "1" --> "*" Equipment : owns
    ServiceCall "1" --> "*" Activity : contains
    ServiceCall "1" --> "0..1" Equipment : references
    Activity "1" --> "*" Assignment : dispatched via
    Technician "1" --> "*" Assignment : assigned to
    Technician "1" --> "*" Skill : possesses
    Activity "1" --> "*" Smartform : documented by
    ServiceCall "1" --> "*" Smartform : attached to
```

## Use Case Diagram

```mermaid
graph TB
    subgraph Actors
        D[Dispatcher]
        T[Technician]
        C[Customer]
        M[Manager]
    end

    subgraph "Service Call Management"
        SC1[Create Service Call]
        SC2[Assign Priority]
        SC3[Track Resolution]
        SC4[Close Service Call]
    end

    subgraph "Planning and Dispatching"
        PD1[Schedule Activities]
        PD2[Assign Technicians]
        PD3[Best Match Technician]
        PD4[Route Optimization]
    end

    subgraph "Mobile Field Work"
        MW1[Accept Assignment]
        MW2[Update Activity Status]
        MW3[Fill Smartform]
        MW4[Capture Signature]
    end

    subgraph "Master Data"
        MD1[Manage Equipment]
        MD2[Manage Technicians]
        MD3[Manage Skills]
        MD4[Manage Customers]
    end

    C --> SC1
    D --> SC2
    D --> PD1
    D --> PD2
    D --> PD3
    D --> PD4
    T --> MW1
    T --> MW2
    T --> MW3
    T --> MW4
    M --> SC3
    M --> SC4
    M --> MD1
    M --> MD2
    M --> MD3
    M --> MD4
```

## Component Diagram

```mermaid
graph TB
    subgraph Presentation["Presentation Layer"]
        SCC[ServiceCallController]
        AC[ActivityController]
        ASC[AssignmentController]
        EC[EquipmentController]
        TC[TechnicianController]
        CC[CustomerController]
        SKC[SkillController]
        SFC[SmartformController]
        HC[HealthController]
    end

    subgraph Application["Application Layer"]
        SCUC[ManageServiceCallsUseCase]
        AUC[ManageActivitiesUseCase]
        ASUC[ManageAssignmentsUseCase]
        EUC[ManageEquipmentUseCase]
        TUC[ManageTechniciansUseCase]
        CUC[ManageCustomersUseCase]
        SKUC[ManageSkillsUseCase]
        SFUC[ManageSmartformsUseCase]
    end

    subgraph Domain["Domain Layer"]
        ENT[Entities]
        REPO[Repository Interfaces]
        VAL[FieldServiceValidator]
    end

    subgraph Infrastructure["Infrastructure Layer"]
        CFG[AppConfig]
        CON[Container]
        MEM[Memory Repositories]
    end

    SCC --> SCUC
    AC --> AUC
    ASC --> ASUC
    EC --> EUC
    TC --> TUC
    CC --> CUC
    SKC --> SKUC
    SFC --> SFUC

    SCUC --> REPO
    AUC --> REPO
    ASUC --> REPO
    EUC --> REPO
    TUC --> REPO
    CUC --> REPO
    SKUC --> REPO
    SFUC --> REPO

    SCUC --> VAL
    AUC --> VAL
    ASUC --> VAL
    EUC --> VAL
    TUC --> VAL
    CUC --> VAL
    SKUC --> VAL
    SFUC --> VAL

    MEM -.-> REPO
    CON --> MEM
    CON --> CFG
```

## Sequence Diagram - Service Call Lifecycle

```mermaid
sequenceDiagram
    participant C as Customer
    participant D as Dispatcher
    participant API as Field Service API
    participant T as Technician

    C->>API: POST /service-calls (create request)
    API-->>C: 201 Service Call Created

    D->>API: GET /service-calls (view open calls)
    API-->>D: List of service calls

    D->>API: POST /activities (plan service task)
    API-->>D: 201 Activity Created

    D->>API: POST /assignments (assign technician)
    API-->>D: 201 Assignment Created

    T->>API: PUT /assignments/:id (accept)
    API-->>T: 200 Assignment Updated

    T->>API: PUT /activities/:id (start work)
    API-->>T: 200 Activity Updated

    T->>API: POST /smartforms (fill checklist)
    API-->>T: 201 Smartform Created

    T->>API: PUT /smartforms/:id (submit with signature)
    API-->>T: 200 Smartform Updated

    T->>API: PUT /activities/:id (complete)
    API-->>T: 200 Activity Updated

    D->>API: PUT /service-calls/:id (resolve)
    API-->>D: 200 Service Call Updated
```

## State Diagram - Service Call

```mermaid
stateDiagram-v2
    [*] --> draft
    draft --> new_ : Submit
    new_ --> assigned : Assign Technician
    assigned --> inProgress : Start Work
    inProgress --> onHold : Hold
    onHold --> inProgress : Resume
    inProgress --> resolved : Resolve
    resolved --> closed : Close
    new_ --> cancelled : Cancel
    assigned --> cancelled : Cancel
    closed --> [*]
    cancelled --> [*]
```

## State Diagram - Activity

```mermaid
stateDiagram-v2
    [*] --> draft
    draft --> planned : Plan
    planned --> released : Release
    released --> dispatched : Dispatch
    dispatched --> accepted : Accept
    accepted --> inTravel : Start Travel
    inTravel --> onSite : Arrive
    onSite --> inProgress : Start Work
    inProgress --> completed : Complete
    planned --> cancelled : Cancel
    released --> cancelled : Cancel
    dispatched --> cancelled : Cancel
    completed --> [*]
    cancelled --> [*]
```
