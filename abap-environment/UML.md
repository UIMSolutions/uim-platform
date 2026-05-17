# UML — ABAP Environment Service

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class SystemInstance {
        +SystemInstanceId id
        +TenantId tenantId
        +string name
        +string description
        +string systemId
        +string systemType
        +string status
        +string region
        +string serviceUrl
        +Json toJson()
    }
    class SoftwareComponent {
        +SoftwareComponentId id
        +TenantId tenantId
        +SystemInstanceId instanceId
        +string name
        +string version
        +string packageName
        +string status
        +Json toJson()
    }
    class CommunicationArrangement {
        +CommunicationArrangementId id
        +TenantId tenantId
        +SystemInstanceId instanceId
        +string name
        +string communicationScenario
        +string authenticationType
        +string status
        +Json toJson()
    }
    class ServiceBinding {
        +ServiceBindingId id
        +TenantId tenantId
        +SystemInstanceId instanceId
        +string bindingType
        +string credentials
        +string status
        +Json toJson()
    }
    class BusinessUser {
        +BusinessUserId id
        +TenantId tenantId
        +SystemInstanceId instanceId
        +string username
        +string email
        +string firstName
        +string lastName
        +string status
        +Json toJson()
    }
    class BusinessRole {
        +BusinessRoleId id
        +TenantId tenantId
        +SystemInstanceId instanceId
        +string roleName
        +string roleTemplate
        +string description
        +Json toJson()
    }
    class TransportRequest {
        +TransportRequestId id
        +TenantId tenantId
        +SystemInstanceId instanceId
        +string name
        +string category
        +string status
        +string owner
        +Json toJson()
    }
    class CatalogAssignment {
        +CatalogAssignmentId id
        +TenantId tenantId
        +BusinessRoleId roleId
        +string catalogId
        +string catalogName
        +string assignmentStatus
        +Json toJson()
    }
    class ApplicationJob {
        +ApplicationJobId id
        +TenantId tenantId
        +SystemInstanceId instanceId
        +string jobName
        +string jobTemplate
        +string status
        +string cronExpression
        +Json toJson()
    }
    class ExecutionLog {
        +ExecutionLogId id
        +TenantId tenantId
        +string jobId
        +string status
        +string message
        +long startedAt
        +long finishedAt
        +Json toJson()
    }

    SystemInstance "1" --> "0..*" SoftwareComponent : hosts
    SystemInstance "1" --> "0..*" CommunicationArrangement : configures
    SystemInstance "1" --> "0..*" ServiceBinding : provides
    SystemInstance "1" --> "0..*" BusinessUser : manages
    SystemInstance "1" --> "0..*" BusinessRole : owns
    SystemInstance "1" --> "0..*" TransportRequest : tracks
    SystemInstance "1" --> "0..*" ApplicationJob : schedules
    BusinessRole "1" --> "0..*" CatalogAssignment : assigns
    ApplicationJob "1" --> "0..*" ExecutionLog : records
```

---

## Component Diagram

```mermaid
flowchart TB
    subgraph Presentation["Presentation Layer (HTTP)"]
        C1[SystemInstanceController]
        C2[SoftwareComponentController]
        C3[CommunicationArrangementController]
        C4[ServiceBindingController]
        C5[BusinessUserController]
        C6[BusinessRoleController]
        C7[TransportRequestController]
        C8[CatalogAssignmentController]
        C9[ApplicationJobController]
        HC[HealthController]
    end
    subgraph Application["Application Layer"]
        UC1[ManageSystemInstancesUseCase]
        UC2[ManageSoftwareComponentsUseCase]
        UC3[ManageCommunicationArrangementsUseCase]
        UC4[ManageServiceBindingsUseCase]
        UC5[ManageBusinessUsersUseCase]
        UC6[ManageBusinessRolesUseCase]
        UC7[ManageTransportRequestsUseCase]
        UC8[ManageCatalogAssignmentsUseCase]
        UC9[ManageApplicationJobsUseCase]
    end
    subgraph Domain["Domain Layer"]
        E1[SystemInstance]
        E2[SoftwareComponent]
        E3[CommunicationArrangement]
        E4[ServiceBinding]
        E5[BusinessUser]
        E6[BusinessRole]
        E7[TransportRequest]
        E8[CatalogAssignment]
        E9[ApplicationJob]
        E10[ExecutionLog]
    end
    subgraph Infrastructure["Infrastructure Layer"]
        MEM[Memory Repositories ×10]
        CFG[SrvConfig — port 10000]
        CTR[Container / buildContainer]
    end

    C1 --> UC1
    C2 --> UC2
    C3 --> UC3
    C5 --> UC5
    C6 --> UC6
    C7 --> UC7
    C9 --> UC9

    UC1 --> E1
    UC5 --> E5
    UC6 --> E6
    UC9 --> E9

    MEM --> E1
    CTR --> UC1
    CTR --> MEM
```

---

## Sequence Diagram — Transport Request Release

```mermaid
sequenceDiagram
    participant Client
    participant TC as TransportRequestController
    participant TUC as ManageTransportRequestsUseCase
    participant TR as TransportRequestRepository

    Client->>TC: POST /transports { name, category, instanceId }
    TC->>TUC: createTransportRequest(dto)
    TUC->>TR: save(transportRequest)
    TR-->>TUC: ok
    TUC-->>TC: CommandResult(true, id)
    TC-->>Client: 201 { id }

    Client->>TC: POST /transports/release/{id}
    TC->>TUC: releaseTransportRequest(id)
    TUC->>TR: findById(id)
    TR-->>TUC: transportRequest
    TUC->>TUC: validate status = "modifiable"
    TUC->>TR: update(status = "released")
    TUC-->>TC: CommandResult(true, id)
    TC-->>Client: 200 { id }
```

---

## Sequence Diagram — Business User Lifecycle

```mermaid
sequenceDiagram
    participant Admin
    participant BC as BusinessUserController
    participant BUC as ManageBusinessUsersUseCase
    participant BR as BusinessUserRepository

    Admin->>BC: POST /business-users { username, email }
    BC->>BUC: createBusinessUser(dto)
    BUC->>BR: save(user)
    BR-->>BUC: ok
    BUC-->>BC: CommandResult(true, id)
    BC-->>Admin: 201 { id }

    Admin->>BC: POST /business-users/lock/{id}
    BC->>BUC: lockUser(id)
    BUC->>BR: findById(id) → update status=locked
    BUC-->>BC: CommandResult(true, id)
    BC-->>Admin: 200 { id }
```
