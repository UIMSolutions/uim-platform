# NAF v4 Architecture Description — Advanced Event Mesh Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Advanced Event Mesh Service — multi-protocol event brokering, topic/queue
> management, event schema governance, subscription routing, and cross-broker
> mesh bridging modelled on SAP Integration Suite, Advanced Event Mesh.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Advanced Event Mesh
├── C1.1  Broker Service Management
│   ├── C1.1.1  Provision and configure brokers
│   ├── C1.1.2  Multi-cloud deployment
│   └── C1.1.3  Broker lifecycle and monitoring
│
├── C1.2  EventQueue Management
│   ├── C1.2.1  Create / delete queues
│   ├── C1.2.2  TTL and capacity policies
│   └── C1.2.3  EventQueue monitoring
│
├── C1.3  Topic Management
│   ├── C1.3.1  Topic hierarchy definition
│   └── C1.3.2  Wildcard pattern subscription
│
├── C1.4  Subscription Management
│   ├── C1.4.1  Push and pull subscriptions
│   └── C1.4.2  Dead-letter routing
│
├── C1.5  Event Messaging
│   ├── C1.5.1  Publish events
│   └── C1.5.2  Consume and acknowledge messages
│
├── C1.6  Schema Management
│   └── C1.6.1  JSON / Avro schema registry
│
├── C1.7  Application Management
│   └── C1.7.1  Register publishing / consuming applications
│
├── C1.8  Mesh Bridge Management
│   └── C1.8.1  Cross-broker event forwarding
│
└── C1.9  Cross-Cutting
    ├── C1.9.1  Tenant isolation
    └── C1.9.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide advanced event mesh capabilities modelled on SAP Integration Suite, Advanced Event Mesh (Solace-based). |
| **Vision** | Enable event-driven architectures across BTP with high-throughput, multi-protocol (AMQP, MQTT, REST) broker infrastructure. |
| **Scope** | Broker services, queues, topics, subscriptions, event messages, schemas, applications, and mesh bridges. |
| **Stakeholders** | Integration Architects, Application Developers, Platform Operators. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-BROKER-CRUD | Broker Service | `/api/v1/broker-services` | GET, POST, DELETE |
| SVC-QUEUE-CRUD | EventQueue | `/api/v1/queues` | GET, POST, DELETE |
| SVC-TOPIC-CRUD | Topic | `/api/v1/topics` | GET, POST, DELETE |
| SVC-SUB-CRUD | Subscription | `/api/v1/subscriptions` | GET, POST, DELETE |
| SVC-MSG-PUB | Event Message | `/api/v1/messages` | GET, POST |
| SVC-SCHEMA-CRUD | Event Schema | `/api/v1/schemas` | GET, POST, DELETE |
| SVC-APP-CRUD | Event Application | `/api/v1/applications` | GET, POST, DELETE |
| SVC-BRIDGE-CRUD | Mesh Bridge | `/api/v1/bridges` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Publisher App /    │ ─────────────────> │  Advanced Event Mesh Service │
│  Consumer App       │                    │  port 8108                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `BrokerService` | Root; hosts Queues and Topics |
| `EventQueue` | Durable message store; associated with BrokerService |
| `Topic` | Pub/sub channel; associated with BrokerService |
| `Subscription` | Consumer binding to EventQueue or Topic |
| `EventMessage` | Single event payload; routed via Topic or EventQueue |
| `EventSchema` | JSON/Avro schema registered for Topics |
| `EventApplication` | Publisher or consumer identity |
| `MeshBridge` | Cross-broker event forwarding |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: advanced-events-config
│   ADVANCED_EVENTS_HOST: "0.0.0.0"
│   ADVANCED_EVENTS_PORT: "8108"
├── Deployment: advanced-events  port: 8108
└── Service: advanced-events (ClusterIP :8108)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Broker-centric model | Mirrors Solace/AEM broker concept |
| AD-2 | Schema registry | Enforces contract-first event design |
| AD-3 | Mesh bridge entity | Supports cross-regional event routing |
| AD-4 | In-memory repositories | Fast testing; swap for Solace API in production |
| AD-5 | Port 8108 | Consistent UIM platform port allocation |
