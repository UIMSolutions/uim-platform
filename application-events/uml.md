# UML — UIM Application Event Hub

Diagrams in Mermaid. Source of truth: `backend/source/uim/platform/application_events/`.

## 1. Domain model

```mermaid
classDiagram
  direction LR
  class Formation {
    +FormationId id
    +TenantId tenantId
    +string name
    +string description
    +string globalAccountId
    +FormationStatus status
    +isActive() bool
    +validate()
  }
  class SystemRegistration {
    +SystemRegistrationId id
    +string name
    +SystemType systemType
    +string systemUrl
    +FormationId formationId
    +SystemStatus status
    +produces() bool
    +consumes() bool
    +validate()
  }
  class EventTopic {
    +EventTopicId id
    +string eventType
    +string title
    +string category
    +string version_
    +SystemRegistrationId ownerSystemId
    +TopicStatus status
    +acceptsEvents() bool
  }
  class EventChannel {
    +EventChannelId id
    +string name
    +ChannelType channelType
    +string endpoint
    +SystemRegistrationId consumerSystemId
    +DeliveryMode deliveryMode
    +ChannelStatus status
    +long maxSizeBytes
    +acceptsMessages() bool
    +delivers() bool
    +isQueue() bool
  }
  class EventSubscription {
    +EventSubscriptionId id
    +string name
    +SystemRegistrationId producerSystemId
    +SystemRegistrationId consumerSystemId
    +string eventType «pattern»
    +EventChannelId channelId
    +FormationId formationId «derived»
    +SubscriptionStatus status
    +int maxRetries
    +int retryBackoffSeconds
    +long lastMatchedAt
    +matches(type) bool
  }
  class EventFilter {
    +EventFilterId id
    +EventSubscriptionId subscriptionId
    +FilterType filterType
    +string attribute
    +EventFilterOperator operator_
    +string value
    +bool active
    +summary() string
  }
  class EventMessage {
    +EventMessageId id
    +EventSubscriptionId subscriptionId
    +EventChannelId channelId
    +SystemRegistrationId producerSystemId
    +SystemRegistrationId consumerSystemId
    +string eventId
    +string eventType
    +string subject
    +string payload
    +MessageStatus status
    +int attempts
    +int maxAttempts
    +long nextAttemptAt
    +string lastError
    +long deliveredAt
    +isDueAt(now) bool
    +toCloudEvent() CloudEvent
  }
  class DeadLetterEntry {
    +DeadLetterEntryId id
    +EventMessageId messageId
    +EventSubscriptionId subscriptionId
    +string reason
    +int attempts
    +DeadLetterStatus status
    +long resolvedAt
    +string resolvedBy
  }
  class UserAccount {
    +UserAccountId id
    +string displayName
    +string passwordHash
    +string[] scopes
    +bool locked
    +int failedLogins
    +long lockedUntil
    +recordFailure(now, max, lock)
    +recordSuccess(now)
  }
  class CloudEvent {
    «value»
    +string specVersion = "1.0"
    +string id
    +string type
    +string source
    +string subject
    +long time
    +string dataContentType
    +Json data
    +attribute(name, out found) string
    +validate()
  }

  Formation "0..1" o-- "*" SystemRegistration : groups
  SystemRegistration "1" --> "*" EventTopic : owns
  SystemRegistration "1" --> "*" EventChannel : consumes through
  SystemRegistration "1" <-- "*" EventSubscription : producer
  SystemRegistration "1" <-- "*" EventSubscription : consumer
  EventChannel "1" <-- "*" EventSubscription : delivers over
  EventSubscription "1" *-- "*" EventFilter : narrowed by
  EventSubscription "1" --> "*" EventMessage : routes
  EventMessage "1" --> "0..1" DeadLetterEntry : given up as
  EventMessage ..> CloudEvent : carries
```

Enumerations (string valued — the value is what the APIs accept and return):

| Enumeration | Values |
|---|---|
| `FormationStatus` | active, inactive |
| `SystemType` · `SystemStatus` | producer, consumer, both · active, inactive |
| `TopicStatus` | active, deprecated, retired |
| `ChannelType` · `ChannelStatus` · `DeliveryMode` | webhook, queue · active, inactive, draining · atLeastOnce, atMostOnce |
| `SubscriptionStatus` | active, paused |
| `FilterType` · `EventFilterOperator` | include, exclude · equals, notEquals, contains, startsWith, endsWith, exists, oneOf |
| `MessageStatus` | pending, retrying, queued, delivered, deadLettered, dropped |
| `DeadLetterStatus` | open, requeued, discarded |

Pure domain services: `event_types` (type / pattern syntax, `matchesEventType`), `filters` (`evaluateFilters`),
`retries` (`backoffSeconds`, `afterFailure`), `router` (`routeEvent` → `RouteDecision[]`).

## 2. Hexagonal components

```mermaid
flowchart LR
  subgraph presentation[presentation — driving adapters]
    ODATA[OData v4 controller + ODataEngine]
    REST[AehApiController /api/v1/appevents]
    AUTH[AuthController /auth]
    HEALTH[AehHealthController /health]
    WEB[FrontendController /app]
    CLI[CLI commands]
    GUI[GtkD entity browser]
  end
  subgraph ports[ports]
    UC[[IManageFormations · IManageSystems · IManageTopics · IManageChannels
    IManageSubscriptions · IManageFilters · IPublishEvents · IDeliverMessages
    IManageDeadLetters · IAuthenticate · IManageUsers]]
    STAT[[IAehStatisticsService]]
    REPO[[IAehRepository&lt;E,Id&gt; ×9]]
    UOW[[IAehUnitOfWork]]
    GW[[IDeliveryGateway · IClock · IPasswordHasher · ITokenIssuer]]
    AUD[[IAuditTrail]]
  end
  subgraph application[application]
    INT[ManageFormations · ManageSystems · ManageTopics · ManageChannels
    ManageSubscriptions · ManageFilters · PublishEvents · Delivery · Access]
    SVC[AehStatisticsService · capabilities · demo data]
  end
  subgraph domain[domain]
    ENT[entities · CloudEvent · ids · scopes · enumerations · exceptions]
    DS[event type patterns · filters · retries · router]
  end
  subgraph persistence[persistence]
    DR[DocumentRepository&lt;E,Id&gt; + mappers]
    ST[BatchingFileDocumentStore / BatchingMemoryDocumentStore]
  end
  subgraph infrastructure[infrastructure]
    DG[SimulatedDeliveryGateway / HttpDeliveryGateway]
    SEC[SecuritySetup · Hs256TokenIssuer · Pbkdf2PasswordHasher · RS256 XSUAA verifier]
    WRK[DeliveryWorker + WorkerMetrics]
    CFG[AehConfig loader]
    LOG[LoggingAuditTrail]
    CON[AehContainer — composition root]
  end

  ODATA & REST & CLI & GUI --> UC
  AUTH --> UC
  WRK --> UC
  UC -.implemented by.-> INT
  STAT -.implemented by.-> SVC
  INT --> ENT & DS
  INT --> REPO & UOW & GW & AUD
  REPO -.implemented by.-> DR --> ST
  UOW -.implemented by.-> ST
  GW -.implemented by.-> DG & SEC
  AUD -.implemented by.-> LOG
  CON --> CFG & SEC & DG & DR & INT & ODATA
```

Dependencies point inwards: the domain knows nothing of vibe.d, JSON stores or HTTP; routing is a pure function of
event, subscriptions and landscape; use cases see only ports; the container wires adapters to ports once for server,
CLI and GUI. `DeliveryUseCase` implements both `IDeliverMessages` and `IManageDeadLetters`; `PublishEventsUseCase`
uses it for the first delivery attempt.

## 3. Message states

```mermaid
stateDiagram-v2
  [*] --> pending : routed by a publish
  [*] --> deadLettered : payload above the channel limit
  pending --> delivered : webhook answered 2xx
  pending --> queued : queue channel
  pending --> retrying : attempt failed (at least once)
  pending --> dropped : attempt failed (at most once)
  retrying --> delivered : retry succeeded
  retrying --> retrying : failed again · back-off doubles
  retrying --> deadLettered : 1 + maxRetries attempts failed
  queued --> delivered : consumer acknowledges
  pending --> pending : channel inactive (waits)
  deadLettered --> pending : dead letter requeued (attempts reset)
  delivered --> [*] : purged after messageRetentionHours
  dropped --> [*] : purged
  deadLettered --> [*] : purged once the dead letter is resolved
```

## 4. Subscription, channel and dead letter states

```mermaid
stateDiagram-v2
  state Subscription {
    [*] --> active
    active --> paused : PauseSubscription
    paused --> active : ResumeSubscription
  }
  state Channel {
    [*] --> ch_active
    ch_active --> draining : no new messages
    draining --> inactive : nothing delivered
    inactive --> ch_active
    draining --> ch_active
    ch_active --> inactive
  }
  state DeadLetter {
    [*] --> open
    open --> requeued : RequeueDeadLetter
    open --> discarded : DiscardDeadLetter
    requeued --> [*] : purged after deadLetterRetentionDays
    discarded --> [*]
  }
```

Event types: `active` → `deprecated` (still published and delivered; new exact subscriptions refused) → `retired`
(events refused); any status can be set again by `SetEventTypeStatus`.

## 5. Routing (activity)

```mermaid
flowchart TD
  A[CloudEvent from a producer] --> B{envelope valid,\npayload ≤ maxPayloadBytes?}
  B -- no --> X1[400 invalid]
  B -- yes --> C{source = active producer system?}
  C -- no --> X2[404 / 422]
  C -- yes --> D{type registered, not retired,\nowner = source?}
  D -- no --> X3[422]
  D -- yes --> E{event id already routed\nfor this source?}
  E -- yes --> DUP[return first result · duplicate]
  E -- no --> F[subscriptions of the producer\nwhose pattern matches the type]
  F --> G{for each: active · consumer active ·\nformation active · channel active?}
  G -- no --> SK[skipped + reason]
  G -- yes --> H{filters pass?}
  H -- no --> FI[filtered + reason]
  H -- yes --> I{payload ≤ channel limit?}
  I -- no --> DL[message deadLettered + dead letter]
  I -- yes --> J[message pending]
  J --> K{deliverOnPublish?}
  K -- yes --> L[first attempt — see §3]
  K -- no --> M[worker attempts within dispatchIntervalSeconds]
```

## 6. Sequence — publish and webhook delivery

```mermaid
sequenceDiagram
  autonumber
  participant P as Producer (S/4HANA)
  participant R as AehApiController
  participant U as PublishEventsUseCase
  participant RT as router (domain)
  participant D as DeliveryUseCase
  participant G as IDeliveryGateway
  participant C as Consumer webhook
  participant S as repositories / store

  P->>R: POST /api/v1/appevents/events (CloudEvent, Bearer token with Publish)
  R->>R: resolve token, check scope Publish
  R->>U: publish(PublishRequest)
  U->>S: producer system, catalog entry, earlier messages of the event id
  U->>S: subscriptions of the producer, systems, formations, channels, filters
  U->>RT: routeEvent(event, subscriptions, landscape)
  RT-->>U: RouteDecision[] (routed / filtered / skipped / oversized)
  U->>S: batch: save messages (pending), dead letters (oversized), lastMatchedAt
  loop each pending message (deliverOnPublish)
    U->>D: deliverNow(message)
    D->>G: deliver(channel, message)
    G->>C: POST application/cloudevents+json (ce-id, ce-type, ce-source)
    C-->>G: 202
    G-->>D: success
    D->>S: message delivered
  end
  U-->>R: PublishResult (routed, delivered, queued, retrying, outcomes)
  R-->>P: 202 {…}
```

## 7. Sequence — retries, dead letter and requeue

```mermaid
sequenceDiagram
  autonumber
  participant W as DeliveryWorker (timer)
  participant D as DeliveryUseCase
  participant G as IDeliveryGateway
  participant S as store
  participant O as Operator (Fiori)

  W->>D: dispatchDue(tenant)
  D->>S: messages pending / retrying with nextAttemptAt ≤ now
  D->>G: deliver(channel, message)
  G-->>D: 503
  alt attempts < maxAttempts
    D->>S: retrying, nextAttemptAt = now + base·2^(attempts-1)
  else attempts = 1 + maxRetries
    D->>S: message deadLettered + DeadLetterEntry(open, reason)
  end
  O->>D: RequeueDeadLetter(id) (scope Operate)
  D->>S: dead letter requeued, message pending, attempts = 0
  D->>G: deliver(channel, message)
  G-->>D: 2xx
  D->>S: message delivered
```

## 8. Sequence — queue consumer (pull / acknowledge)

```mermaid
sequenceDiagram
  autonumber
  participant A as Consumer (Analytics)
  participant R as AehApiController
  participant D as DeliveryUseCase
  participant S as store

  Note over D,S: publish → attempt on a queue channel → message queued
  A->>R: GET /channels/analytics-queue/pull?max=10 (scope Operate)
  R->>D: pull(channel, 10)
  D->>S: queued messages of the channel, oldest first
  R-->>A: {count, resources: [message rows with payload]}
  A->>A: process
  A->>R: POST /messages/{id}/ack
  R->>D: acknowledge(id)
  D->>S: message delivered, deliveredAt
  R-->>A: 200 message row
```

## 9. Sequence — built-in login (authMode jwt)

```mermaid
sequenceDiagram
  autonumber
  participant B as Browser (Fiori)
  participant A as AuthController
  participant U as AccessUseCase
  participant H as Pbkdf2PasswordHasher
  participant I as Hs256TokenIssuer
  participant O as ODataController

  B->>A: GET /auth/config
  A-->>B: {mode: jwt, loginRequired: true}
  B->>A: POST /auth/login {username, password, tenant?}
  A->>U: login(LoginRequest)
  U->>H: verify(password, stored hash)
  alt wrong / unknown / locked
    U-->>A: unauthorized (failed logins counted, lock after 5)
    A-->>B: 401
  else ok
    U->>I: issue(tenant, user, scopes)
    I-->>U: HS256 JWT (sub, zid, scope[], exp, jti)
    A-->>B: {access_token, expires_in, scope, user}
  end
  B->>O: GET /odata/v4/appevents/Subscriptions (Authorization: Bearer …)
  O->>O: verify signature + exp, scope Read
  O-->>B: 200 rows
```

## 10. Deployment

```mermaid
flowchart LR
  subgraph btp[SAP BTP · Cloud Foundry — mta.yaml]
    AR[application-events-approuter\n@sap/approuter + Fiori resources]
    SRV[application-events-srv\nbinary_buildpack · D/vibe.d]
    XS[(XSUAA\napplication-events-xsuaa)]
    UPS[(user-provided\napplication-events-config)]
  end
  subgraph k8s[Kubernetes — k8s/]
    POD[Deployment application-events-service\nimage uim-platform/application-events]
    PVC[(PVC application-events-data\n/data/application-events.json)]
    CM[ConfigMap · Secret]
  end
  USER((Browser)) --> AR --> SRV
  AR -. login .-> XS
  SRV -. verification key .-> XS
  SRV -. overrides .-> UPS
  PROD((Producer systems)) -->|CloudEvents| SRV
  SRV -->|webhooks| CONS((Consumer systems))
  CONS -->|pull / ack| SRV
  POD --> PVC
  CM --> POD
```
