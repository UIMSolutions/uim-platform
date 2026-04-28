# Service Manager - UML Diagrams

## Class Diagram

```mermaid
classDiagram
    class Platform {
        +PlatformId id
        +TenantId tenantId
        +string name
        +string description
        +PlatformType type
        +PlatformStatus status
        +string brokerUrl
        +string credentials
        +string region
        +string subaccountId
        +long createdAt
        +long updatedAt
    }

    class ServiceBroker {
        +ServiceBrokerId id
        +TenantId tenantId
        +string name
        +string description
        +string brokerUrl
        +ServiceBrokerStatus status
        +long lastCatalogFetch
        +long createdAt
        +long updatedAt
    }

    class ServiceOffering {
        +ServiceOfferingId id
        +TenantId tenantId
        +ServiceBrokerId brokerId
        +string name
        +string catalogName
        +ServiceOfferingStatus status
        +ServiceCategory category
        +bool bindable
        +string tags
        +long createdAt
    }

    class ServicePlan {
        +ServicePlanId id
        +TenantId tenantId
        +ServiceOfferingId offeringId
        +string name
        +ServicePlanPricing pricing
        +bool free
        +bool bindable
        +int maxInstances
        +string schemas
        +long createdAt
    }

    class ServiceInstance {
        +ServiceInstanceId id
        +TenantId tenantId
        +string name
        +ServicePlanId planId
        +ServiceOfferingId offeringId
        +PlatformId platformId
        +ServiceInstanceStatus status
        +string parameters
        +bool shared
        +bool usable
        +long createdAt
    }

    class ServiceBinding {
        +ServiceBindingId id
        +TenantId tenantId
        +string name
        +ServiceInstanceId instanceId
        +ServiceBindingStatus status
        +string credentials
        +string parameters
        +long createdAt
    }

    class Operation {
        +OperationId id
        +TenantId tenantId
        +string resourceId
        +string resourceType
        +OperationType type
        +OperationStatus status
        +string errorMessage
        +long startedAt
        +long completedAt
    }

    class Label {
        +LabelId id
        +TenantId tenantId
        +string resourceId
        +string resourceType
        +string key
        +string value
        +long createdAt
    }

    ServiceBroker "1" --> "*" ServiceOffering : advertises
    ServiceOffering "1" --> "*" ServicePlan : provides
    ServicePlan "1" --> "*" ServiceInstance : provisions
    ServiceInstance "1" --> "*" ServiceBinding : binds
    Platform "1" --> "*" ServiceInstance : hosts
    ServiceInstance "1" --> "*" Operation : tracks
    ServiceBinding "1" --> "*" Operation : tracks
    Label "*" --> "1" ServiceInstance : labels
    Label "*" --> "1" ServiceBinding : labels
```

## Repository Interfaces

```mermaid
classDiagram
    class PlatformRepository {
        <<interface>>
        +findByTenant(TenantId) Platform[]
        +findById(TenantId, PlatformId) Platform*
        +save(Platform) void
        +update(Platform) void
        +removeById(tenantId, PlatformId) void
        +countByTenant(TenantId) ulong
    }

    class ServiceBrokerRepository {
        <<interface>>
        +findByTenant(TenantId) ServiceBroker[]
        +findById(TenantId, ServiceBrokerId) ServiceBroker*
        +save(ServiceBroker) void
        +update(ServiceBroker) void
        +removeById(tenantId, ServiceBrokerId) void
    }

    class ServiceOfferingRepository {
        <<interface>>
        +findByTenant(TenantId) ServiceOffering[]
        +findById(TenantId, ServiceOfferingId) ServiceOffering*
        +save(ServiceOffering) void
        +update(ServiceOffering) void
        +removeById(tenantId, ServiceOfferingId) void
    }

    class ServicePlanRepository {
        <<interface>>
        +findByTenant(TenantId) ServicePlan[]
        +findById(TenantId, ServicePlanId) ServicePlan*
        +save(ServicePlan) void
        +update(ServicePlan) void
        +removeById(tenantId, ServicePlanId) void
    }

    class ServiceInstanceRepository {
        <<interface>>
        +findByTenant(TenantId) ServiceInstance[]
        +findById(TenantId, ServiceInstanceId) ServiceInstance*
        +save(ServiceInstance) void
        +update(ServiceInstance) void
        +removeById(tenantId, ServiceInstanceId) void
    }

    class ServiceBindingRepository {
        <<interface>>
        +findByTenant(TenantId) ServiceBinding[]
        +findById(TenantId, ServiceBindingId) ServiceBinding*
        +save(ServiceBinding) void
        +update(ServiceBinding) void
        +removeById(tenantId, ServiceBindingId) void
    }

    class OperationRepository {
        <<interface>>
        +findByTenant(TenantId) Operation[]
        +findById(TenantId, OperationId) Operation*
        +save(Operation) void
        +update(Operation) void
        +removeById(tenantId, OperationId) void
    }

    class LabelRepository {
        <<interface>>
        +findByTenant(TenantId) Label[]
        +findById(TenantId, LabelId) Label*
        +findByResource(TenantId, string, string) Label[]
        +save(Label) void
        +update(Label) void
        +removeById(tenantId, LabelId) void
    }
```

## Domain Service

```mermaid
classDiagram
    class CatalogAggregator {
        -ServiceOfferingRepository offeringRepo
        -ServicePlanRepository planRepo
        +getAvailableOfferings(TenantId) ServiceOffering[]
        +getPlansForOffering(TenantId, ServiceOfferingId) ServicePlan[]
        +canProvision(TenantId, ServicePlanId) bool
    }

    CatalogAggregator --> ServiceOfferingRepository
    CatalogAggregator --> ServicePlanRepository
```

## Component Diagram

```mermaid
graph TB
    subgraph Presentation
        PC[EnvironmentController]
        BC[ServiceBrokerController]
        OC[ServiceOfferingController]
        PLC[ServicePlanController]
        IC[ServiceInstanceController]
        BIC[ServiceBindingController]
        OPC[OperationController]
        LC[LabelController]
        HC[HealthController]
    end

    subgraph Application
        MPC[ManagePlatformsUseCase]
        MBC[ManageServiceBrokersUseCase]
        MOC[ManageServiceOfferingsUseCase]
        MPLC[ManageServicePlansUseCase]
        MIC[ManageServiceInstancesUseCase]
        MBIC[ManageServiceBindingsUseCase]
        MOPC[ManageOperationsUseCase]
        MLC[ManageLabelsUseCase]
    end

    subgraph Domain
        PE[Platform]
        SB[ServiceBroker]
        SO[ServiceOffering]
        SP[ServicePlan]
        SI[ServiceInstance]
        SBI[ServiceBinding]
        OP[Operation]
        LB[Label]
        CA[CatalogAggregator]
    end

    subgraph Infrastructure
        MPR[MemoryPlatformRepo]
        MSBR[MemoryServiceBrokerRepo]
        MSOR[MemoryServiceOfferingRepo]
        MSPR[MemoryServicePlanRepo]
        MSIR[MemoryServiceInstanceRepo]
        MSBIR[MemoryServiceBindingRepo]
        MOPR[MemoryOperationRepo]
        MLR[MemoryLabelRepo]
    end

    PC --> MPC
    BC --> MBC
    OC --> MOC
    PLC --> MPLC
    IC --> MIC
    BIC --> MBIC
    OPC --> MOPC
    LC --> MLC

    MPC --> MPR
    MBC --> MSBR
    MOC --> MSOR
    MPLC --> MSPR
    MIC --> MSIR
    MBIC --> MSBIR
    MOPC --> MOPR
    MLC --> MLR
```

## Sequence Diagrams

### Service Instance Provisioning

```mermaid
sequenceDiagram
    participant Client
    participant Controller as ServiceInstanceController
    participant UseCase as ManageServiceInstancesUseCase
    participant Repo as ServiceInstanceRepository

    Client->>Controller: POST /service-instances
    Controller->>Controller: Parse JSON body
    Controller->>Controller: Extract tenant ID
    Controller->>UseCase: create(tenantId, request)
    UseCase->>UseCase: Validate request
    UseCase->>UseCase: Generate instance ID
    UseCase->>Repo: save(instance)
    Repo-->>UseCase: void
    UseCase-->>Controller: CommandResult(success, id)
    Controller-->>Client: 201 {"id": "..."}
```

### Service Binding Creation

```mermaid
sequenceDiagram
    participant Client
    participant Controller as ServiceBindingController
    participant UseCase as ManageServiceBindingsUseCase
    participant Repo as ServiceBindingRepository

    Client->>Controller: POST /service-bindings
    Controller->>Controller: Parse JSON body
    Controller->>UseCase: create(tenantId, request)
    UseCase->>UseCase: Validate instanceId present
    UseCase->>UseCase: Generate binding ID
    UseCase->>Repo: save(binding)
    Repo-->>UseCase: void
    UseCase-->>Controller: CommandResult(success, id)
    Controller-->>Client: 201 {"id": "..."}
```

### Service Broker Registration

```mermaid
sequenceDiagram
    participant Client
    participant Controller as ServiceBrokerController
    participant UseCase as ManageServiceBrokersUseCase
    participant Repo as ServiceBrokerRepository

    Client->>Controller: POST /service-brokers
    Controller->>Controller: Parse JSON body
    Controller->>UseCase: create(tenantId, request)
    UseCase->>UseCase: Validate name and brokerUrl
    UseCase->>UseCase: Generate broker ID
    UseCase->>Repo: save(broker)
    Repo-->>UseCase: void
    UseCase-->>Controller: CommandResult(success, id)
    Controller-->>Client: 201 {"id": "..."}
```

### Platform Registration

```mermaid
sequenceDiagram
    participant Client
    participant Controller as EnvironmentController
    participant UseCase as ManagePlatformsUseCase
    participant Repo as PlatformRepository

    Client->>Controller: POST /platforms
    Controller->>Controller: Parse JSON request
    Controller->>UseCase: create(tenantId, request)
    UseCase->>UseCase: Validate platform name
    UseCase->>UseCase: Generate platform ID
    UseCase->>Repo: save(platform)
    Repo-->>UseCase: void
    UseCase-->>Controller: CommandResult(success, id)
    Controller-->>Client: 201 {"id": "..."}
```

## State Diagrams

### Service Instance Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Creating : POST /service-instances
    Creating --> Created : Provisioning succeeded
    Creating --> Failed : Provisioning error
    Created --> Updating : PUT /service-instances/:id
    Updating --> Created : Update succeeded
    Updating --> Failed : Update error
    Created --> Deleting : DELETE /service-instances/:id
    Deleting --> [*] : Deprovisioning complete
    Deleting --> Orphaned : Deprovisioning timeout
    Failed --> Deleting : DELETE /service-instances/:id
    Orphaned --> Deleting : Force delete
```

### Service Binding Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Creating : POST /service-bindings
    Creating --> Created : Binding succeeded
    Creating --> Failed : Binding error
    Created --> Deleting : DELETE /service-bindings/:id
    Deleting --> [*] : Unbinding complete
    Failed --> Deleting : DELETE /service-bindings/:id
```

### Operation Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Pending : Operation created
    Pending --> InProgress : Execution starts
    InProgress --> Succeeded : Completed successfully
    InProgress --> Failed : Error occurred
    Succeeded --> [*]
    Failed --> [*]
```
