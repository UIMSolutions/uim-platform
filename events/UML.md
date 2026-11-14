# UML — Event Mesh

These diagrams describe the 2.0 implementation in
`backend/source/uim/platform/events/`.

## Component diagram (hexagonal architecture)

```mermaid
flowchart LR
  subgraph Clients
    Fiori[SAP Fiori 3 app]
    Apps[Publishing / consuming apps]
    Admin[Operator shell]
    Desk[Desktop user]
    Hook[(Webhook endpoint)]
  end

  subgraph BTP[SAP BTP]
    AR[approuter + XSUAA]
  end

  subgraph Presentation[presentation — driving adapters]
    OD[ODataController\n/odata/v4/event-mesh]
    REST[EventsRestController\n/api/v1/event-mesh]
    CLI[CLI commands\nuim-event-mesh-cli]
    GUI[GtkD entity browser\nuim-event-mesh-gui]
    WEB[FrontendController /app]
    ENG{{ODataEngine\nEDM model + providers}}
  end

  subgraph Application
    UC[Manage* use cases]
    MSG[PublishEvents · ConsumeMessages\nDeliverWebhooks]
    SVC[EventsStatisticsService · DemoData]
  end

  subgraph Domain
    ENT[Entities]
    POL[topic router · quota policy\ndead letter policy · topics]
  end

  subgraph Ports
    PIN[driving: usecases · messaging · services]
    POUT[driven: repositories · storages · gateways]
  end

  subgraph Persistence
    REPO[DocumentRepository × 8]
    MAP[mappers · records]
    STORE[(Memory / File\nDocumentStore)]
  end

  subgraph Infrastructure
    CFG[configuration]
    SEC[security: XSUAA RS256 / HS256]
    LOG[structured logging]
    HTTPC[HttpWebhookClient]
    WRK[WebhookDeliveryWorker]
    CONT[EventsContainer]
  end

  Fiori --> AR --> OD
  Apps --> REST
  Apps --> OD
  Admin --> CLI
  Desk --> GUI
  OD --> ENG
  REST --> ENG
  CLI --> ENG
  GUI --> ENG
  ENG --> PIN
  PIN -.implemented by.-> UC
  PIN -.implemented by.-> MSG
  PIN -.implemented by.-> SVC
  UC --> ENT
  MSG --> POL
  UC --> POUT
  MSG --> POUT
  POUT -.implemented by.-> REPO
  POUT -.implemented by.-> HTTPC
  REPO --> MAP --> STORE
  HTTPC --> Hook
  WRK --> MSG
  CONT -.wires.-> ENG
  OD --> SEC
  REST --> SEC
```

Dependencies point inwards: `presentation → ports → application → domain`.
`persistence` and `infrastructure.clients` implement driven ports. Only
`EventsContainer`, the composition root, knows the concrete classes.

## Domain class diagram

```mermaid
classDiagram
  direction LR
  class MessagingService {
    +MessagingServiceId id
    +TenantId tenantId
    +string name
    +string namespace
    +MessagingServiceStatus status
    +MessagingServicePlan plan
    +string region
    +int maxConnections
    +int maxQueues
    +int maxQueueDepth
    +long maxMessageSize
    +string tokenEndpoint
    +string messagingEndpoint
    +isActive() bool
    +validate()
  }
  class MessageClient {
    +MessageClientId id
    +MessagingServiceId serviceId
    +string name
    +MessageClientStatus status
    +MessageClientProtocol protocol
    +string clientId
    -string clientSecret
    +string tokenUrl
    +string permittedNamespace
    +validate()
  }
  class EventQueue {
    +QueueId id
    +MessagingServiceId serviceId
    +string name
    +QueueStatus status
    +QueueAccessType accessType
    +int maxDepth
    +long maxMessageSize
    +long messageTtlSeconds
    +int maxRedeliveryCount
    +QueueId deadLetterQueueId
    +bool ingressEnabled
    +bool egressEnabled
    +acceptsMessages() bool
    +deliversMessages() bool
    +validate()
  }
  class QueueSubscription {
    +QueueSubscriptionId id
    +QueueId queueId
    +MessagingServiceId serviceId
    +string topicPattern
    +QueueSubscriptionStatus status
    +validate()
  }
  class Webhook {
    +WebhookId id
    +QueueId queueId
    +string url
    +string headers
    +WebhookStatus status
    +WebhookAuthType authenticationType
    -string credentials
    +WebhookDeliveryMode deliveryMode
    +int batchSize
    +long deliveredCount
    +long failedCount
    +long lastDeliveryAt
    +string lastError
    +headerMap() string[string]
    +validate()
  }
  class EventChannel {
    +EventChannelId id
    +MessagingServiceId serviceId
    +string topicName
    +EventChannelType channelType
    +EventChannelStatus status
    +string asyncapiDefinition
    +int retentionHours
    +int partitions
    +validate()
  }
  class MessageBinding {
    +MessageBindingId id
    +MessageClientId clientId
    +QueueId queueId
    +EventChannelId channelId
    +MessageBindingPermission permission
    +MessageBindingStatus status
    +validate()
  }
  class QueueMessage {
    +QueueMessageId id
    +QueueId queueId
    +string correlationId
    +string topic
    +string payload
    +string contentType
    +QueueMessageState state
    +int deliveryCount
    +long expiresAt
    +MessageClientId publisherId
    +QueueId originalQueueId
    +isExpired(now) bool
  }

  MessagingService "1" *-- "0..*" MessageClient
  MessagingService "1" *-- "0..*" EventQueue
  MessagingService "1" *-- "0..*" EventChannel
  EventQueue "1" *-- "0..*" QueueSubscription : routes into
  EventQueue "1" *-- "0..*" QueueMessage : stores
  EventQueue "0..1" --> "0..1" EventQueue : deadLetterQueue
  EventQueue "1" <-- "0..*" Webhook : pushes
  MessageClient "1" *-- "0..*" MessageBinding
  MessageBinding --> EventQueue : or
  MessageBinding --> EventChannel : or
```

Every entity mixes in `TenantEntity` (`tenantId`, `createdAt/By`,
`updatedAt/By`).

### Enumerations and domain services

```mermaid
classDiagram
  class MessagingServicePlan { <<enum>> dev standard premium }
  class QueueAccessType { <<enum>> exclusive nonExclusive }
  class WebhookAuthType { <<enum>> none basic oauth2 apiKey }
  class WebhookDeliveryMode { <<enum>> atLeastOnce atMostOnce }
  class MessageBindingPermission { <<enum>> publish subscribe publishSubscribe manage }
  class QueueMessageState { <<enum>> queued deadLettered }
  class DeliveryOutcome { <<enum>> remove retry deadLetter discard }

  class topics {
    <<module>>
    +isValidNamespace(ns) bool
    +isValidTopic(topic) bool
    +isValidTopicPattern(pattern) bool
    +isInNamespace(topic, ns) bool
    +isPatternInNamespace(pattern, ns) bool
    +topicMatches(pattern, topic) bool
  }
  class topic_router { <<module>> +routeTopic(subscriptions, topic) QueueId[] }
  class quota_policy {
    <<module>>
    +planDefaults(plan) ServiceQuota
    +quotaOf(service) ServiceQuota
    +effectiveDepth(queue, service) int
    +effectiveMessageSize(queue, service) long
  }
  class dead_letter_policy { <<module>> +deliveryOutcome(ok, message, queue, mode) DeliveryOutcome }
  class EventsException {
    +EventsErrorKind kind
    invalid · notFound · conflict · ruleViolation · quotaExceeded · gateway
  }
```

| Plan | Clients | Queues | Queue depth | Message size |
|---|---|---|---|---|
| dev | 10 | 10 | 1 000 | 64 KB |
| standard | 100 | 100 | 100 000 | 1 MB |
| premium | 1 000 | 1 000 | 1 000 000 | 10 MB |

## Ports and application

```mermaid
classDiagram
  direction LR
  class EventsPorts {
    services : IManageMessagingServices
    clients : IManageMessageClients
    queues : IManageQueues
    subscriptions : IManageQueueSubscriptions
    webhooks : IManageWebhooks
    channels : IManageEventChannels
    bindings : IManageMessageBindings
    publisher : IPublishEvents
    consumer : IConsumeMessages
    delivery : IDeliverWebhooks
    statistics : IEventsStatistics
  }
  class IPublishEvents { <<interface>> +publish(PublishEventRequest) PublishResult }
  class IConsumeMessages {
    <<interface>>
    +listMessages(t, queueId) QueueMessage[]
    +consume(ConsumeMessagesRequest) QueueMessage[]
    +acknowledge(t, id)
    +purge(t, queueId) size_t
    +removeExpired(t) size_t
  }
  class IDeliverWebhooks {
    <<interface>>
    +deliver(t, webhookId, actor) DeliveryResult
    +deliverAll(t, actor) DeliveryResult[]
  }
  class IEntityRepository~E, Id~ {
    <<interface>>
    +findAll(t) E[]
    +findById(t, id) E
    +existsById(t, id) bool
    +countAll(t) size_t
    +save(e)
    +removeById(t, id) bool
  }
  class IQueueMessageRepository {
    <<interface>>
    +findByQueue(t, q) QueueMessage[]
    +countByQueue(t, q) size_t
    +removeByQueue(t, q) size_t
  }
  class IWebhookEndpointGateway { <<interface>> +push(WebhookRequest) WebhookResponse }
  class IDocumentStore { <<interface>> all · get · put · remove · count }

  class PublishEventsUseCase
  class ConsumeMessagesUseCase
  class DeliverWebhooksUseCase
  class DocumentRepository~E, Id, toRecord, fromRecord~
  class HttpWebhookClient
  class RecordingWebhookGateway

  IPublishEvents <|.. PublishEventsUseCase
  IConsumeMessages <|.. ConsumeMessagesUseCase
  IDeliverWebhooks <|.. DeliverWebhooksUseCase
  IEntityRepository <|-- IQueueMessageRepository
  IEntityRepository <|.. DocumentRepository
  IWebhookEndpointGateway <|.. HttpWebhookClient
  IWebhookEndpointGateway <|.. RecordingWebhookGateway
  DeliverWebhooksUseCase --> IWebhookEndpointGateway
  DocumentRepository --> IDocumentStore
```

The seven `Manage*UseCase` classes follow the same pattern: `list`, `get`,
`create` (validation, references, uniqueness, quotas), `update` (PATCH
semantics through `Patch!T`) and `delete` (dependency checks and cascades).

## State machines

### Queue message

```mermaid
stateDiagram-v2
  [*] --> queued : publish (topic matches subscription,\nqueue accepts, depth/size ok)
  queued --> [*] : consume / acknowledge / purge
  queued --> [*] : webhook 2xx, or atMostOnce attempt
  queued --> queued : webhook failure\n(deliveryCount < maxRedeliveryCount)
  queued --> deadLettered : redeliveries exhausted\nand dead letter queue set
  queued --> [*] : redeliveries exhausted, no DLQ (discard)
  queued --> [*] : TTL expired
  deadLettered --> [*] : consume / acknowledge / purge
```

### Webhook

```mermaid
stateDiagram-v2
  [*] --> active
  active --> paused : PATCH status=paused
  paused --> active : PATCH status=active (clears lastError)
  active --> failed : PATCH status=failed
  failed --> active : PATCH status=active
  note right of active : only active webhooks are delivered\n(worker, DeliverWebhook, CLI deliver)
```

## Sequence: publish an event (OData)

```mermaid
sequenceDiagram
  autonumber
  participant App as Publisher (client "webshop")
  participant OD as ODataController
  participant EN as ODataEngine
  participant PU as PublishEventsUseCase
  participant R as Repositories
  participant D as topic router / quota policy

  App->>OD: POST /odata/v4/event-mesh/PublishEvent {topic, payload, clientId}
  OD->>EN: invoke(ctx, "PublishEvent") — scope Publish, parameter types
  EN->>PU: publish(PublishEventRequest)
  PU->>R: client, service, channel by topic, client bindings
  PU->>PU: active? topic valid and in namespace? publish binding?
  PU->>D: quotaOf(service) — payload size
  PU->>R: subscriptions of the service
  PU->>D: routeTopic(subscriptions, topic)
  loop every matching queue
    PU->>R: queue, countByQueue
    alt accepts and depth/size within effective limits
      PU->>R: save(QueueMessage copy, TTL → expiresAt)
    else
      PU-->>PU: rejectedQueueIds += queue
    end
  end
  PU-->>EN: PublishResult
  EN-->>OD: JSON
  OD-->>App: 200 {messageId, queueIds, rejectedQueueIds}
```

## Sequence: webhook delivery with redelivery and dead-lettering

```mermaid
sequenceDiagram
  autonumber
  participant W as WebhookDeliveryWorker (timer)
  participant DU as DeliverWebhooksUseCase
  participant R as Repositories
  participant P as dead letter policy
  participant G as HttpWebhookClient
  participant E as Endpoint

  W->>R: removeExpired(tenant)
  W->>DU: deliverAll(tenant)
  loop every active webhook
    DU->>R: queue, messages (oldest first, ≤ batchSize)
    loop every message
      DU->>G: push(url, headers + X-Event-Topic/X-Message-Id, auth)
      G->>E: POST payload (Basic / API key / OAuth2 bearer)
      E-->>G: HTTP status
      G-->>DU: WebhookResponse
      DU->>P: deliveryOutcome(ok, message, queue, mode)
      alt remove
        DU->>R: removeById
      else retry
        DU->>R: save(deliveryCount+1, lastError)
      else deadLetter
        DU->>R: move to deadLetterQueueId (state deadLettered)
      else discard
        DU->>R: removeById
      end
    end
    DU->>R: save(webhook counters, lastDeliveryAt, lastError)
  end
```

## Deployment diagram

```mermaid
flowchart TB
  subgraph CF[SAP BTP Cloud Foundry space]
    AR[event-mesh-approuter\n@sap/approuter + Fiori resources]
    SRV[event-mesh-srv\nbinary_buildpack\nuim-event-mesh-platform-service]
    UAA[(event-mesh-xsuaa\nxsuaa / application)]
    CFG[(event-mesh-config\nuser-provided)]
  end
  Browser((Browser)) -->|HTTPS| AR
  AR -->|destination event-mesh-srv\nforwardAuthToken| SRV
  AR -.-> UAA
  SRV -.VCAP_SERVICES.-> UAA
  SRV -.VCAP_SERVICES.-> CFG
  SRV -->|HTTPS push| EXT[(Webhook endpoints)]

  subgraph K8s[Kubernetes namespace uim-platform]
    POD[Deployment uim-event-mesh\n1 replica, /data volume]
    SVCK[Service uim-event-mesh :8109]
  end
  SVCK --> POD
```
