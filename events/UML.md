# UML — SAP Event Mesh Service

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class MessagingService {
        +MessagingServiceId id
        +TenantId tenantId
        +string name
        +string description
        +string namespace
        +MessagingServiceStatus status
        +MessagingServicePlan plan
        +string region
        +string datacenter
        +string tokenEndpoint
        +string messagingEndpoint
        +Json toJson()
    }

    class MessageClient {
        +MessageClientId id
        +TenantId tenantId
        +MessagingServiceId serviceId
        +string name
        +MessageClientStatus status
        +MessageClientProtocol protocol
        +string xsappname
        +string clientId
        +string namespace
        +string permittedNamespace
        +Json toJson()
    }

    class Queue {
        +QueueId id
        +TenantId tenantId
        +MessagingServiceId serviceId
        +string name
        +QueueStatus status
        +QueueAccessType accessType
        +string maxMessageSizeBytes
        +string maxQueueSizeBytes
        +string maxConsumers
        +string deadLetterQueue
        +bool egressEnabled
        +bool ingressEnabled
        +Json toJson()
    }

    class QueueSubscription {
        +QueueSubscriptionId id
        +TenantId tenantId
        +QueueId queueId
        +MessagingServiceId serviceId
        +string name
        +QueueSubscriptionStatus status
        +string topicPattern
        +string namespace
        +Json toJson()
    }

    class Webhook {
        +WebhookId id
        +TenantId tenantId
        +MessagingServiceId serviceId
        +QueueSubscriptionId subscriptionId
        +string name
        +WebhookStatus status
        +string url
        +WebhookAuthType authenticationType
        +WebhookDeliveryMode deliveryMode
        +string pushInterval
        +Json toJson()
    }

    class EventChannel {
        +EventChannelId id
        +TenantId tenantId
        +MessagingServiceId serviceId
        +string name
        +EventChannelStatus status
        +EventChannelType channelType
        +string namespace
        +string topicName
        +string asyncapiDefinition
        +Json toJson()
    }

    class MessageBinding {
        +MessageBindingId id
        +TenantId tenantId
        +MessageClientId clientId
        +MessagingServiceId serviceId
        +QueueId queueId
        +EventChannelId channelId
        +MessageBindingStatus status
        +MessageBindingPermission permission
        +Json toJson()
    }

    MessagingService "1" --> "0..*" MessageClient : hosts
    MessagingService "1" --> "0..*" Queue : owns
    MessagingService "1" --> "0..*" EventChannel : defines
    Queue "1" --> "0..*" QueueSubscription : has
    QueueSubscription "1" --> "0..*" Webhook : triggers
    MessageClient "1" --> "0..*" MessageBinding : bound via
    Queue "1" --> "0..*" MessageBinding : bound in
    EventChannel "1" --> "0..*" MessageBinding : bound in
```

---

## Class Diagram — Repository Interfaces

```mermaid
classDiagram
    class MessagingServiceRepository {
        <<interface>>
        +findByTenant(TenantId) MessagingService[]
        +findById(TenantId, MessagingServiceId) MessagingService
        +findByStatus(TenantId, MessagingServiceStatus) MessagingService[]
        +findByNamespace(TenantId, string) MessagingService[]
        +save(MessagingService)
        +update(MessagingService)
        +remove(MessagingService)
    }

    class QueueRepository {
        <<interface>>
        +findByTenant(TenantId) Queue[]
        +findByService(TenantId, MessagingServiceId) Queue[]
        +findByStatus(TenantId, QueueStatus) Queue[]
        +removeByService(TenantId, MessagingServiceId)
    }

    class WebhookRepository {
        <<interface>>
        +findByService(TenantId, MessagingServiceId) Webhook[]
        +findByStatus(TenantId, WebhookStatus) Webhook[]
        +findBySubscription(TenantId, QueueSubscriptionId) Webhook[]
    }

    class MemoryMessagingServiceRepository {
        -MessagingService[] store
        +findByStatus() MessagingService[]
        +findByNamespace() MessagingService[]
    }

    MemoryMessagingServiceRepository ..|> MessagingServiceRepository
```

---

## Use Case Diagram

```mermaid
flowchart LR
    subgraph Actor
        A[Platform Consumer]
    end
    subgraph UseCases["Application Use Cases"]
        UC1[Manage Messaging Services]
        UC2[Manage Message Clients]
        UC3[Manage Queues]
        UC4[Manage Queue Subscriptions]
        UC5[Manage Webhooks]
        UC6[Manage Event Channels]
        UC7[Manage Message Bindings]
    end
    A --> UC1
    A --> UC2
    A --> UC3
    A --> UC4
    A --> UC5
    A --> UC6
    A --> UC7
```

---

## Component Diagram

```mermaid
flowchart TB
    subgraph Presentation["Presentation Layer (HTTP)"]
        C1[MessagingServiceController]
        C2[MessageClientController]
        C3[QueueController]
        C4[QueueSubscriptionController]
        C5[WebhookController]
        C6[EventChannelController]
        C7[MessageBindingController]
        HC[HealthController]
    end

    subgraph Application["Application Layer"]
        UC1[ManageMessagingServicesUseCase]
        UC2[ManageMessageClientsUseCase]
        UC3[ManageQueuesUseCase]
        UC4[ManageQueueSubscriptionsUseCase]
        UC5[ManageWebhooksUseCase]
        UC6[ManageEventChannelsUseCase]
        UC7[ManageMessageBindingsUseCase]
    end

    subgraph Domain["Domain Layer"]
        E1[MessagingService]
        E2[MessageClient]
        E3[Queue]
        E4[QueueSubscription]
        E5[Webhook]
        E6[EventChannel]
        E7[MessageBinding]
        V[EventsValidator]
    end

    subgraph Infrastructure["Infrastructure Layer"]
        CFG[Config]
        CTR[Container]
        MEM1[MemoryMessagingServiceRepository]
        MEM2[MemoryMessageClientRepository]
        MEM3[MemoryQueueRepository]
        MEM4[MemoryQueueSubscriptionRepository]
        MEM5[MemoryWebhookRepository]
        MEM6[MemoryEventChannelRepository]
        MEM7[MemoryMessageBindingRepository]
    end

    C1 --> UC1
    C2 --> UC2
    C3 --> UC3
    C4 --> UC4
    C5 --> UC5
    C6 --> UC6
    C7 --> UC7

    UC1 --> E1
    UC1 --> V
    UC2 --> E2
    UC3 --> E3
    UC4 --> E4
    UC5 --> E5
    UC6 --> E6
    UC7 --> E7

    MEM1 --> E1
    MEM2 --> E2
    MEM3 --> E3
    MEM4 --> E4
    MEM5 --> E5
    MEM6 --> E6
    MEM7 --> E7

    CTR --> UC1
    CTR --> MEM1
```

---

## Sequence Diagram — Create Queue with Subscription and Webhook

```mermaid
sequenceDiagram
    participant Client as API Client
    participant QC as QueueController
    participant QUC as ManageQueuesUseCase
    participant QR as QueueRepository

    participant SC as QueueSubscriptionController
    participant SUC as ManageQueueSubscriptionsUseCase
    participant SR as QueueSubscriptionRepository

    participant WC as WebhookController
    participant WUC as ManageWebhooksUseCase
    participant WR as WebhookRepository

    Client->>QC: POST /queues { name, serviceId }
    QC->>QUC: createQueue(dto)
    QUC->>QR: save(queue)
    QR-->>QUC: ok
    QUC-->>QC: CommandResult(true, queueId)
    QC-->>Client: 201 { id }

    Client->>SC: POST /queue-subscriptions { queueId, topicPattern }
    SC->>SUC: createSubscription(dto)
    SUC->>SR: save(subscription)
    SR-->>SUC: ok
    SUC-->>SC: CommandResult(true, subscriptionId)
    SC-->>Client: 201 { id }

    Client->>WC: POST /webhooks { subscriptionId, url }
    WC->>WUC: createWebhook(dto)
    WUC->>WR: save(webhook)
    WR-->>WUC: ok
    WUC-->>WC: CommandResult(true, webhookId)
    WC-->>Client: 201 { id }
```

---

## Sequence Diagram — Publish Event via Event Channel

```mermaid
sequenceDiagram
    participant P as Publisher Client
    participant EC as EventChannelController
    participant ECUC as ManageEventChannelsUseCase
    participant ECR as EventChannelRepository
    participant MBC as MessageBindingController
    participant MBUC as ManageMessageBindingsUseCase

    P->>EC: POST /event-channels { namespace, topicName }
    EC->>ECUC: createChannel(dto)
    ECUC->>ECR: save(channel)
    ECR-->>ECUC: ok
    ECUC-->>EC: CommandResult(true, channelId)
    EC-->>P: 201 { id }

    P->>MBC: POST /message-bindings { clientId, channelId, permission=publish }
    MBC->>MBUC: createBinding(dto)
    MBUC-->>MBC: CommandResult(true, bindingId)
    MBC-->>P: 201 { id }
```
