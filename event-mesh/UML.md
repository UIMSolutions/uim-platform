# Event Mesh — UML Diagrams

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class BrokerService {
        +BrokerServiceId id
        +TenantId tenantId
        +string name
        +string description
        +BrokerType brokerType
        +BrokerServiceClass serviceClass
        +CloudProvider cloudProvider
        +string region
        +BrokerStatus status
        +string createdAt
        +string updatedAt
        +toJson() Json
    }

    class Queue {
        +QueueId id
        +TenantId tenantId
        +string name
        +string description
        +BrokerServiceId brokerServiceId
        +QueueType queueType
        +long maxCapacity
        +long ttlSeconds
        +QueueStatus status
        +string createdAt
        +string updatedAt
        +toJson() Json
    }

    class Topic {
        +TopicId id
        +TenantId tenantId
        +string name
        +string description
        +BrokerServiceId brokerServiceId
        +string topicPattern
        +TopicStatus status
        +string createdAt
        +string updatedAt
        +toJson() Json
    }

    class EventSubscription {
        +SubscriptionId id
        +TenantId tenantId
        +string name
        +string description
        +TopicId topicId
        +QueueId queueId
        +string filterExpression
        +SubscriptionStatus status
        +string createdAt
        +string updatedAt
        +toJson() Json
    }

    class EventMessage {
        +EventMessageId id
        +TenantId tenantId
        +TopicId topicId
        +EventSchemaId schemaId
        +string payload
        +string contentType
        +EventMessageStatus status
        +string publishedAt
        +string acknowledgedAt
        +toJson() Json
    }

    class EventSchema {
        +EventSchemaId id
        +TenantId tenantId
        +string name
        +string description
        +SchemaFormat format
        +string version
        +string definition
        +string createdAt
        +string updatedAt
        +toJson() Json
    }

    class EventApplication {
        +EventApplicationId id
        +TenantId tenantId
        +string name
        +string description
        +BrokerServiceId brokerServiceId
        +string applicationUrl
        +ProtocolType protocol
        +string createdAt
        +string updatedAt
        +toJson() Json
    }

    class MeshBridge {
        +MeshBridgeId id
        +TenantId tenantId
        +string name
        +string description
        +BrokerServiceId sourceBrokerId
        +BrokerServiceId targetBrokerId
        +BridgeType bridgeType
        +string topicFilter
        +BridgeStatus status
        +string createdAt
        +string updatedAt
        +toJson() Json
    }

    BrokerService "1" --> "*" Queue : hosts
    BrokerService "1" --> "*" Topic : hosts
    BrokerService "1" --> "*" EventApplication : connects
    Topic "1" --> "*" EventSubscription : subscribedBy
    Queue "1" --> "*" EventSubscription : delivers to
    Topic "1" --> "*" EventMessage : receives
    EventSchema "1" --> "*" EventMessage : validates
    BrokerService "1" --> "*" MeshBridge : source
    BrokerService "1" --> "*" MeshBridge : target
```

## Class Diagram — Repository Interfaces

```mermaid
classDiagram
    class IBrokerServiceRepository {
        <<interface>>
        +findAll() BrokerService[]
        +findByTenant(tenantId) BrokerService[]
        +findById(id) BrokerService
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }

    class IQueueRepository {
        <<interface>>
        +findAll() Queue[]
        +findByTenant(tenantId) Queue[]
        +findById(id) Queue
        +findByBrokerServiceId(id) Queue[]
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }

    class ITopicRepository {
        <<interface>>
        +findAll() Topic[]
        +findByTenant(tenantId) Topic[]
        +findById(id) Topic
        +findByBrokerServiceId(id) Topic[]
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }

    class ISubscriptionRepository {
        <<interface>>
        +findAll() EventSubscription[]
        +findByTenant(tenantId) EventSubscription[]
        +findById(id) EventSubscription
        +findByTopicId(id) EventSubscription[]
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }

    class IEventMessageRepository {
        <<interface>>
        +findAll() EventMessage[]
        +findByTenant(tenantId) EventMessage[]
        +findById(id) EventMessage
        +findByTopicId(id) EventMessage[]
        +findByStatus(status) EventMessage[]
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }

    class IEventSchemaRepository {
        <<interface>>
        +findAll() EventSchema[]
        +findByTenant(tenantId) EventSchema[]
        +findById(id) EventSchema
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }

    class IEventApplicationRepository {
        <<interface>>
        +findAll() EventApplication[]
        +findByTenant(tenantId) EventApplication[]
        +findById(id) EventApplication
        +findByBrokerServiceId(id) EventApplication[]
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }

    class IMeshBridgeRepository {
        <<interface>>
        +findAll() MeshBridge[]
        +findByTenant(tenantId) MeshBridge[]
        +findById(id) MeshBridge
        +findByStatus(status) MeshBridge[]
        +save(entity) void
        +update(entity) void
        +removeById(id) void
    }
```

## Use Case Diagram

```mermaid
graph LR
    subgraph Actors
        A[API Client]
    end

    subgraph "Event Mesh Service"
        UC1[Manage Broker Services]
        UC2[Manage Queues]
        UC3[Manage Topics]
        UC4[Manage Subscriptions]
        UC5[Publish / Acknowledge Messages]
        UC6[Manage Event Schemas]
        UC7[Manage Event Applications]
        UC8[Manage Mesh Bridges]
        UC9[Health Check]
    end

    A --> UC1
    A --> UC2
    A --> UC3
    A --> UC4
    A --> UC5
    A --> UC6
    A --> UC7
    A --> UC8
    A --> UC9
```

## Component Diagram

```mermaid
graph TB
    subgraph Presentation
        C1[BrokerServiceController]
        C2[QueueController]
        C3[TopicController]
        C4[SubscriptionController]
        C5[EventMessageController]
        C6[EventSchemaController]
        C7[EventApplicationController]
        C8[MeshBridgeController]
    end

    subgraph Application
        U1[ManageBrokerServicesUseCase]
        U2[ManageQueuesUseCase]
        U3[ManageTopicsUseCase]
        U4[ManageSubscriptionsUseCase]
        U5[ManageEventMessagesUseCase]
        U6[ManageEventSchemasUseCase]
        U7[ManageEventApplicationsUseCase]
        U8[ManageMeshBridgesUseCase]
    end

    subgraph Domain
        E[Entities]
        R[Repository Interfaces]
        V[EventMeshValidator]
    end

    subgraph Infrastructure
        MR[Memory Repositories]
        CFG[AppConfig]
        DI[Container]
    end

    C1 --> U1
    C2 --> U2
    C3 --> U3
    C4 --> U4
    C5 --> U5
    C6 --> U6
    C7 --> U7
    C8 --> U8

    U1 --> R
    U2 --> R
    U3 --> R
    U4 --> R
    U5 --> R
    U6 --> R
    U7 --> R
    U8 --> R

    U1 --> V
    U2 --> V
    U3 --> V
    U4 --> V
    U5 --> V
    U6 --> V
    U7 --> V
    U8 --> V

    MR -.-> R

    DI --> MR
    DI --> U1
    DI --> U2
    DI --> U3
    DI --> U4
    DI --> U5
    DI --> U6
    DI --> U7
    DI --> U8
    DI --> C1
    DI --> C2
    DI --> C3
    DI --> C4
    DI --> C5
    DI --> C6
    DI --> C7
    DI --> C8
```

## Sequence Diagram — Publish Event Message

```mermaid
sequenceDiagram
    participant Client
    participant Controller as EventMessageController
    participant UseCase as ManageEventMessagesUseCase
    participant Repo as IEventMessageRepository

    Client->>Controller: POST /api/v1/event-mesh/messages/publish
    Controller->>UseCase: publish(dto)
    UseCase->>UseCase: validate message
    UseCase->>Repo: save(eventMessage)
    Repo-->>UseCase: void
    UseCase-->>Controller: EventMessage
    Controller-->>Client: 201 Created (JSON)
```

## Sequence Diagram — Create Mesh Bridge

```mermaid
sequenceDiagram
    participant Client
    participant Controller as MeshBridgeController
    participant UseCase as ManageMeshBridgesUseCase
    participant Repo as IMeshBridgeRepository

    Client->>Controller: POST /api/v1/event-mesh/bridges
    Controller->>UseCase: create(dto)
    UseCase->>UseCase: validate bridge
    UseCase->>Repo: save(meshBridge)
    Repo-->>UseCase: void
    UseCase-->>Controller: MeshBridge
    Controller-->>Client: 201 Created (JSON)
```
