# UML — Integration Suite Service

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class IntegrationPackage {
        +IntegrationPackageId id
        +TenantId tenantId
        +string name
        +string version_
        +string description
        +string vendor
        +string category
        +string[] tags
        +ArtifactStatus status
        +Json toJson()
    }
    class IntegrationFlow {
        +IntegrationFlowId id
        +TenantId tenantId
        +IntegrationPackageId packageId
        +string name
        +string version_
        +ArtifactStatus status
        +DeploymentStatus deploymentStatus
        +FlowDirection direction
        +AdapterType senderAdapterType
        +AdapterType receiverAdapterType
        +string senderEndpoint
        +string receiverEndpoint
        +string[] steps
        +Json toJson()
    }
    class MessageMapping {
        +MessageMappingId id
        +TenantId tenantId
        +IntegrationPackageId packageId
        +string name
        +string sourceStandard
        +string targetStandard
        +string sourceSchema
        +string targetSchema
        +string mappingExpression
        +MappingStatus status
        +Json toJson()
    }
    class ApiProxy {
        +ApiProxyId id
        +TenantId tenantId
        +string name
        +string version_
        +string targetEndpoint
        +string basePath
        +string[] policies
        +ApiProxyStatus status
        +Json toJson()
    }
    class ApiProduct {
        +ApiProductId id
        +TenantId tenantId
        +string name
        +string[] apiProxyIds
        +string[] scopes
        +string[] environments
        +bool isPublic
        +ApiProxyStatus status
        +Json toJson()
    }
    class MessageQueue {
        +MessageQueueId id
        +TenantId tenantId
        +string name
        +int maxMessageSize
        +int maxQueueSize
        +int retentionPeriod
        +bool deadLetterQueue
        +QueueStatus status
        +Json toJson()
    }
    class TopicSubscription {
        +TopicSubscriptionId id
        +TenantId tenantId
        +MessageQueueId queueId
        +string topicPattern
        +string protocol
        +string endpoint
        +SubscriptionStatus status
        +Json toJson()
    }
    class TradingPartner {
        +TradingPartnerId id
        +TenantId tenantId
        +string name
        +PartnerType partnerType
        +B2bStandard standard
        +string contactEmail
        +bool active
        +Json toJson()
    }
    class IntegrationUser {
        +IntegrationUserId id
        +TenantId tenantId
        +string email
        +string firstName
        +string lastName
        +IntegrationUserRole role
        +bool active
        +Json toJson()
    }

    IntegrationPackage "1" --> "0..*" IntegrationFlow : contains
    IntegrationPackage "1" --> "0..*" MessageMapping : contains
    ApiProduct "1" --> "0..*" ApiProxy : references
    MessageQueue "1" --> "0..*" TopicSubscription : has subscriptions
```

---

## Class Diagram — Application Layer

```mermaid
classDiagram
    class ManageIntegrationPackagesUseCase {
        -IntegrationPackageRepository _repo
        +create(CreatePackageRequest) CommandResult
        +getAll(tenantId) CommandResult
        +getById(tenantId, id) CommandResult
        +update(UpdatePackageRequest) CommandResult
        +remove(tenantId, id) CommandResult
    }
    class ManageIntegrationFlowsUseCase {
        -IntegrationFlowRepository _repo
        +create(CreateFlowRequest) CommandResult
        +getAll(tenantId) CommandResult
        +getById(tenantId, id) CommandResult
        +update(UpdateFlowRequest) CommandResult
        +deploy(DeployFlowRequest) CommandResult
        +remove(tenantId, id) CommandResult
    }
    class ManageApiProxiesUseCase {
        -ApiProxyRepository _repo
        +create(CreateApiProxyRequest) CommandResult
        +getAll(tenantId) CommandResult
        +getById(tenantId, id) CommandResult
        +update(UpdateApiProxyRequest) CommandResult
        +publish(tenantId, id) CommandResult
        +remove(tenantId, id) CommandResult
    }
    class ManageApiProductsUseCase {
        -ApiProductRepository _repo
        +create(CreateApiProductRequest) CommandResult
        +getAll(tenantId) CommandResult
        +publish(tenantId, id) CommandResult
        +remove(tenantId, id) CommandResult
    }
    class ManageMessageQueuesUseCase {
        -MessageQueueRepository _repo
        +create(CreateQueueRequest) CommandResult
        +update(UpdateQueueRequest) CommandResult
        +remove(tenantId, id) CommandResult
    }
    class ManageTopicSubscriptionsUseCase {
        -TopicSubscriptionRepository _repo
        +create(CreateSubscriptionRequest) CommandResult
        +listByQueue(tenantId, queueId) CommandResult
        +update(UpdateSubscriptionRequest) CommandResult
        +remove(tenantId, id) CommandResult
    }
```

---

## Class Diagram — Infrastructure Layer

```mermaid
classDiagram
    class IntegrationPackageRepository {
        <<interface>>
        +findByStatus(TenantId, ArtifactStatus) IntegrationPackage[]
        +findByVendor(TenantId, string) IntegrationPackage[]
    }
    class MemoryIntegrationPackageRepository {
        +findByStatus(TenantId, ArtifactStatus) IntegrationPackage[]
        +findByVendor(TenantId, string) IntegrationPackage[]
    }
    class IntegrationFlowRepository {
        <<interface>>
        +findByPackage(TenantId, IntegrationPackageId) IntegrationFlow[]
        +findByStatus(TenantId, ArtifactStatus) IntegrationFlow[]
        +findByDeploymentStatus(TenantId, DeploymentStatus) IntegrationFlow[]
    }
    class MemoryIntegrationFlowRepository {
        +findByPackage(TenantId, IntegrationPackageId) IntegrationFlow[]
        +findByStatus(TenantId, ArtifactStatus) IntegrationFlow[]
        +findByDeploymentStatus(TenantId, DeploymentStatus) IntegrationFlow[]
    }
    IntegrationPackageRepository <|.. MemoryIntegrationPackageRepository
    IntegrationFlowRepository <|.. MemoryIntegrationFlowRepository
```

---

## Sequence Diagram — Deploy Integration Flow

```mermaid
sequenceDiagram
    actor Client
    participant Controller as IntegrationFlowController
    participant UseCase as ManageIntegrationFlowsUseCase
    participant Repo as MemoryIntegrationFlowRepository

    Client->>+Controller: POST /api/v1/integration/flows/deploy/:id
    Controller->>+UseCase: deploy(DeployFlowRequest)
    UseCase->>+Repo: getById(tenantId, flowId)
    Repo-->>-UseCase: IntegrationFlow
    UseCase->>UseCase: set status=deployed, deploymentStatus=running
    UseCase->>+Repo: update(tenantId, flow)
    Repo-->>-UseCase: ok
    UseCase-->>-Controller: CommandResult(true, flow.toJson())
    Controller-->>-Client: 200 OK { flow JSON }
```

---

## Sequence Diagram — Publish API Proxy

```mermaid
sequenceDiagram
    actor Client
    participant Ctrl as ApiProxyController
    participant UC as ManageApiProxiesUseCase
    participant Repo as MemoryApiProxyRepository

    Client->>+Ctrl: POST /api/v1/apimanagement/proxies/publish/:id
    Ctrl->>+UC: publish(tenantId, id)
    UC->>+Repo: getById(tenantId, id)
    Repo-->>-UC: ApiProxy
    UC->>UC: set status = published
    UC->>+Repo: update(tenantId, proxy)
    Repo-->>-UC: ok
    UC-->>-Ctrl: CommandResult(true, proxy.toJson())
    Ctrl-->>-Client: 200 OK { proxy JSON }
```

---

## Component Diagram

```mermaid
graph TB
    subgraph Presentation
        HTTP["HTTP Controllers<br/>(REST/JSON)"]
        CLI["CLI Controller<br/>(MVC)"]
        WEB["Web Controller<br/>(MVC / Diet)"]
        GUI["GUI Controller<br/>(MVC / DlangUI)"]
    end

    subgraph Application
        UC_PKG["ManageIntegrationPackagesUseCase"]
        UC_FLOW["ManageIntegrationFlowsUseCase"]
        UC_PROXY["ManageApiProxiesUseCase"]
        UC_PROD["ManageApiProductsUseCase"]
        UC_QUEUE["ManageMessageQueuesUseCase"]
        UC_SUB["ManageTopicSubscriptionsUseCase"]
        UC_PARTNER["ManageTradingPartnersUseCase"]
        UC_MAPPING["ManageMessageMappingsUseCase"]
    end

    subgraph Domain
        ENTITIES["Entities"]
        PORTS["Repository Interfaces (Ports)"]
        VALIDATORS["IntegrationValidator"]
    end

    subgraph Infrastructure
        MEM["Memory Repositories"]
        FILES["File Repositories (planned)"]
        MONGO["MongoDB Repositories (planned)"]
        CONFIG["SrvConfig / loadConfig()"]
        CONTAINER["Container / buildContainer()"]
    end

    HTTP --> UC_PKG & UC_FLOW & UC_PROXY & UC_PROD & UC_QUEUE & UC_SUB & UC_PARTNER & UC_MAPPING
    CLI --> UC_PKG & UC_FLOW
    WEB --> UC_PKG & UC_FLOW & UC_PROXY
    GUI --> UC_PKG & UC_FLOW

    UC_PKG & UC_FLOW & UC_PROXY & UC_PROD & UC_QUEUE & UC_SUB & UC_PARTNER & UC_MAPPING --> PORTS
    UC_PKG & UC_FLOW --> VALIDATORS

    PORTS <|-- MEM
    PORTS <|-- FILES
    PORTS <|-- MONGO

    CONTAINER --> MEM & UC_PKG & UC_FLOW & HTTP
    CONFIG --> CONTAINER
```
