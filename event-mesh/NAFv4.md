# NAF v4 Architecture Views — Event Mesh

NATO Architecture Framework v4 (NAFv4) views for the Event Mesh Service, modeled after SAP Integration Suite, Advanced Event Mesh.

## C1 — Capability Taxonomy

```mermaid
graph TB
    EM[Event Mesh]
    EM --> BSM[Broker Service Management]
    EM --> QMG[Queue Management]
    EM --> TMG[Topic Management]
    EM --> SUB[Subscription Management]
    EM --> MSG[Event Messaging]
    EM --> SCH[Schema Management]
    EM --> APM[Application Management]
    EM --> BRG[Mesh Bridge Management]

    BSM --> BSM1[Provision Brokers]
    BSM --> BSM2[Multi-Cloud Deployment]
    BSM --> BSM3[Broker Monitoring]
    BSM --> BSM4[Lifecycle Management]

    QMG --> QMG1[Create Queues]
    QMG --> QMG2[Configure Capacity]
    QMG --> QMG3[Set TTL Policies]
    QMG --> QMG4[Queue Monitoring]

    TMG --> TMG1[Define Topic Hierarchies]
    TMG --> TMG2[Topic Pattern Matching]
    TMG --> TMG3[Topic Lifecycle]
    TMG --> TMG4[Multi-Broker Topics]

    SUB --> SUB1[Subscribe Consumers]
    SUB --> SUB2[Filter Expressions]
    SUB --> SUB3[Delivery Guarantees]
    SUB --> SUB4[Subscription Monitoring]

    MSG --> MSG1[Publish Events]
    MSG --> MSG2[Route Messages]
    MSG --> MSG3[Acknowledge Delivery]
    MSG --> MSG4[Dead Letter Handling]

    SCH --> SCH1[Register Schemas]
    SCH --> SCH2[Version Management]
    SCH --> SCH3[Schema Validation]
    SCH --> SCH4[Format Support]

    APM --> APM1[Register Applications]
    APM --> APM2[Protocol Configuration]
    APM --> APM3[Connection Management]
    APM --> APM4[Application Monitoring]

    BRG --> BRG1[Cross-Region Bridges]
    BRG --> BRG2[Cross-Cloud Bridges]
    BRG --> BRG3[Topic Filtering]
    BRG --> BRG4[Bridge Monitoring]
```

## C2 — Enterprise Vision

The Event Mesh Service provides a comprehensive event-driven messaging platform for distributed systems. It enables:

1. **Broker Service Management** through provisioning of event broker instances across AWS, Azure, and GCP with lifecycle management, monitoring, and multi-region deployment
2. **Queue Management** through creation and configuration of message queues with capacity limits, time-to-live policies, and support for standard and priority queue types
3. **Topic Management** through definition of topic hierarchies, pattern-based routing, and topic lifecycle tracking across broker instances
4. **Subscription Management** through consumer subscriptions to topics with filtering expressions, delivery guarantees, and durable/non-durable subscription modes
5. **Event Messaging** through publish/subscribe event delivery, message routing, acknowledgment tracking, and dead letter queue handling
6. **Schema Management** (Event Portal) through schema registration in Avro, JSON Schema, and Protobuf formats with version control and compatibility validation
7. **Application Management** through registration of producer/consumer applications with support for AMQP, MQTT, REST, and WebSocket protocols
8. **Mesh Bridging** through cross-region and cross-cloud broker bridging with topic filtering, enabling hybrid and multi-cloud event topologies

## L1 — Node Types

```mermaid
graph TB
    subgraph Logical["Logical Nodes"]
        API[API Gateway Node]
        APP[Application Node]
        DATA[Data Node]
    end

    subgraph Physical["Physical Mapping"]
        K8SVC[K8s Service :8108]
        K8POD[K8s Pod — vibe.d Server]
        MEM[In-Memory Store]
    end

    API --> K8SVC
    APP --> K8POD
    DATA --> MEM
```

## L2 — Logical Scenario

```mermaid
sequenceDiagram
    participant OPS as Platform Operator
    participant PUB as Event Publisher
    participant CON as Event Consumer
    participant API as Event Mesh API :8108
    participant DB as Data Store

    OPS->>API: POST /broker-services (provision broker)
    API->>DB: Save broker service
    API-->>OPS: 201 Created

    OPS->>API: POST /topics (create topic)
    API->>DB: Save topic
    API-->>OPS: 201 Created

    OPS->>API: POST /queues (create queue)
    API->>DB: Save queue
    API-->>OPS: 201 Created

    OPS->>API: POST /schemas (register schema)
    API->>DB: Save schema
    API-->>OPS: 201 Created

    CON->>API: POST /subscriptions (subscribe to topic)
    API->>DB: Save subscription
    API-->>CON: 201 Created

    PUB->>API: POST /messages/publish (publish event)
    API->>DB: Save event message
    API-->>PUB: 201 Created

    CON->>API: GET /messages (poll for messages)
    API->>DB: Query messages by topic
    API-->>CON: Message list

    CON->>API: POST /messages/:id/acknowledge
    API->>DB: Update message status
    API-->>CON: 200 Acknowledged

    OPS->>API: POST /bridges (create mesh bridge)
    API->>DB: Save bridge
    API-->>OPS: 201 Created
```

## L4 — Logical Activity

```mermaid
graph TB
    subgraph ProvisioningFlow["Provisioning Flow"]
        A1[Request Broker] --> A2[Select Cloud Provider]
        A2 --> A3[Configure Service Class]
        A3 --> A4[Deploy Broker Instance]
        A4 --> A5[Create Topics and Queues]
        A5 --> A6[Register Schemas]
    end

    subgraph MessagingFlow["Messaging Flow"]
        B1[Producer Connects] --> B2[Validate Schema]
        B2 --> B3[Publish Event]
        B3 --> B4[Route to Topic]
        B4 --> B5[Deliver to Subscriptions]
        B5 --> B6[Consumer Acknowledges]
    end

    subgraph BridgingFlow["Bridging Flow"]
        C1[Define Bridge] --> C2[Set Topic Filter]
        C2 --> C3[Connect Source Broker]
        C3 --> C4[Replicate Events]
        C4 --> C5[Deliver to Target Broker]
    end

    A6 --> B1
    A4 --> C1
```

## P1 — Resource Types

```mermaid
graph TB
    subgraph Compute["Compute Resources"]
        POD[Kubernetes Pod]
        CTR[Container — Alpine 3.20]
        BIN[uim-event-mesh-platform-service]
    end

    subgraph Network["Network Resources"]
        SVC[K8s ClusterIP Service]
        PORT[Port 8108]
        HEALTH[Health Endpoint /health]
    end

    subgraph Storage["Storage Resources"]
        MEM[In-Memory Store]
        CFG[ConfigMap]
    end

    POD --> CTR
    CTR --> BIN
    SVC --> PORT
    PORT --> POD
    HEALTH --> BIN
    CFG --> CTR
    BIN --> MEM
```

## S1 — Service Taxonomy

```mermaid
graph TB
    subgraph External["External Services"]
        REST[REST API /api/v1/event-mesh]
        HEALTH[Health Check /health]
    end

    subgraph Internal["Internal Services"]
        BS[BrokerServiceService]
        QS[QueueService]
        TS[TopicService]
        SS[SubscriptionService]
        MS[EventMessageService]
        ES[EventSchemaService]
        AS[EventApplicationService]
        BRS[MeshBridgeService]
    end

    REST --> BS
    REST --> QS
    REST --> TS
    REST --> SS
    REST --> MS
    REST --> ES
    REST --> AS
    REST --> BRS
```

## Sv1 — Service Interface

| Service | Method | Path | Description |
|---------|--------|------|-------------|
| Broker Services | GET | `/api/v1/event-mesh/broker-services` | List all broker services |
| Broker Services | POST | `/api/v1/event-mesh/broker-services` | Create broker service |
| Broker Services | GET | `/api/v1/event-mesh/broker-services/:id` | Get by ID |
| Broker Services | PUT | `/api/v1/event-mesh/broker-services/:id` | Update |
| Broker Services | DELETE | `/api/v1/event-mesh/broker-services/:id` | Delete |
| Queues | GET | `/api/v1/event-mesh/queues` | List all queues |
| Queues | POST | `/api/v1/event-mesh/queues` | Create queue |
| Queues | GET | `/api/v1/event-mesh/queues/:id` | Get by ID |
| Queues | PUT | `/api/v1/event-mesh/queues/:id` | Update |
| Queues | DELETE | `/api/v1/event-mesh/queues/:id` | Delete |
| Topics | GET | `/api/v1/event-mesh/topics` | List all topics |
| Topics | POST | `/api/v1/event-mesh/topics` | Create topic |
| Topics | GET | `/api/v1/event-mesh/topics/:id` | Get by ID |
| Topics | PUT | `/api/v1/event-mesh/topics/:id` | Update |
| Topics | DELETE | `/api/v1/event-mesh/topics/:id` | Delete |
| Subscriptions | GET | `/api/v1/event-mesh/subscriptions` | List all subscriptions |
| Subscriptions | POST | `/api/v1/event-mesh/subscriptions` | Create subscription |
| Subscriptions | GET | `/api/v1/event-mesh/subscriptions/:id` | Get by ID |
| Subscriptions | PUT | `/api/v1/event-mesh/subscriptions/:id` | Update |
| Subscriptions | DELETE | `/api/v1/event-mesh/subscriptions/:id` | Delete |
| Messages | POST | `/api/v1/event-mesh/messages/publish` | Publish event message |
| Messages | GET | `/api/v1/event-mesh/messages` | List all messages |
| Messages | GET | `/api/v1/event-mesh/messages/:id` | Get by ID |
| Messages | POST | `/api/v1/event-mesh/messages/:id/acknowledge` | Acknowledge |
| Messages | DELETE | `/api/v1/event-mesh/messages/:id` | Delete |
| Schemas | GET | `/api/v1/event-mesh/schemas` | List all schemas |
| Schemas | POST | `/api/v1/event-mesh/schemas` | Create schema |
| Schemas | GET | `/api/v1/event-mesh/schemas/:id` | Get by ID |
| Schemas | PUT | `/api/v1/event-mesh/schemas/:id` | Update |
| Schemas | DELETE | `/api/v1/event-mesh/schemas/:id` | Delete |
| Applications | GET | `/api/v1/event-mesh/applications` | List all applications |
| Applications | POST | `/api/v1/event-mesh/applications` | Create application |
| Applications | GET | `/api/v1/event-mesh/applications/:id` | Get by ID |
| Applications | PUT | `/api/v1/event-mesh/applications/:id` | Update |
| Applications | DELETE | `/api/v1/event-mesh/applications/:id` | Delete |
| Bridges | GET | `/api/v1/event-mesh/bridges` | List all mesh bridges |
| Bridges | POST | `/api/v1/event-mesh/bridges` | Create mesh bridge |
| Bridges | GET | `/api/v1/event-mesh/bridges/:id` | Get by ID |
| Bridges | PUT | `/api/v1/event-mesh/bridges/:id` | Update |
| Bridges | DELETE | `/api/v1/event-mesh/bridges/:id` | Delete |
| Health | GET | `/health` | Service health check |
