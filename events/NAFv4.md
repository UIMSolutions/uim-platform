# NAF v4 Architecture Description — Events Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Events Service — event channel management, messaging services, queues,
> queue subscriptions, webhooks, and message client management modelled on
> SAP Event Mesh (SAP Integration Suite).

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** | NSOV-2 Service Definitions | §3 |
| **NOV** | NOV-2 Operational Node Connectivity | §4 |
| **NLV** | NLV-1 Logical Data Model | §5 |
| **NPV** | NPV-1 Physical Deployment | §6 |
| **NIV** | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Events
├── C1.1  Messaging Services
│   └── C1.1.1  Create and manage messaging service instances
│
├── C1.2  Event Channels
│   ├── C1.2.1  Topic-based event channel management
│   └── C1.2.2  Channel access control
│
├── C1.3  Queue Management
│   ├── C1.3.1  Durable queue creation
│   └── C1.3.2  Queue subscription bindings
│
├── C1.4  Webhook Management
│   └── C1.4.1  HTTP push webhook registration
│
├── C1.5  Message Client Management
│   └── C1.5.1  Client credentials and bindings
│
├── C1.6  Message Bindings
│   └── C1.6.1  Queue-to-channel binding rules
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide lightweight event mesh capabilities modelled on SAP Event Mesh. |
| **Vision** | Enable loosely coupled event-driven integration for BTP applications with topic-based routing and durable queues. |
| **Scope** | Messaging services, event channels, queues, queue subscriptions, webhooks, message clients, and message bindings. |
| **Stakeholders** | Integration Architects, Application Developers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-MS-CRUD | Messaging Service | `/api/v1/messaging-services` | GET, POST, DELETE |
| SVC-CH-CRUD | Event Channel | `/api/v1/event-channels` | GET, POST, DELETE |
| SVC-QUE-CRUD | Queue | `/api/v1/queues` | GET, POST, DELETE |
| SVC-QS-CRUD | Queue Subscription | `/api/v1/queue-subscriptions` | GET, POST, DELETE |
| SVC-WH-CRUD | Webhook | `/api/v1/webhooks` | GET, POST, DELETE |
| SVC-MB-CRUD | Message Binding | `/api/v1/message-bindings` | GET, POST, DELETE |
| SVC-MC-CRUD | Message Client | `/api/v1/message-clients` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Publisher /        │ ─────────────────> │  Events Service              │
│  Consumer App       │                    │  port 8109                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `MessagingService` | Root; parent of EventChannels |
| `EventChannel` | Topic-based pub/sub channel |
| `Queue` | Durable message store |
| `QueueSubscription` | Binds Queue to EventChannel |
| `Webhook` | HTTP push delivery target |
| `MessageBinding` | Routing rule binding |
| `MessageClient` | Consumer/producer credential |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: events-config
│   EVENTS_HOST: "0.0.0.0"
│   EVENTS_PORT: "8109"
├── Deployment: events  port: 8109
└── Service: events (ClusterIP :8109)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Topic-based routing | Aligns with SAP Event Mesh namespace model |
| AD-2 | Durable queues | Enables reliable guaranteed delivery |
| AD-3 | Webhook support | HTTP push for serverless consumers |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8109 | Consistent UIM platform port allocation |
