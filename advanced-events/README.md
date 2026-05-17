# Event Mesh Service

A microservice providing event mesh capabilities similar to **SAP Integration Suite, Advanced Event Mesh**. Built with D and vibe.d using a combination of clean and hexagonal architecture.

## Features

- **Event Broker Services** — Provision and manage event broker instances across multiple cloud providers (AWS, Azure, GCP)
- **Queues** — Create and manage message queues with configurable capacity and TTL
- **Topics** — Define topic hierarchies for publish/subscribe messaging patterns
- **Subscriptions** — Subscribe consumers to topics with filtering and delivery guarantees
- **Event Messages** — Publish, route, and acknowledge events across the mesh
- **Event Schemas** — Register and version event schemas (Avro, JSON Schema, Protobuf) via an integrated Event Portal
- **Event Applications** — Register producer and consumer applications participating in the mesh
- **Mesh Bridges** — Bridge event brokers across regions and clouds for hybrid/multi-cloud topologies

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  BrokerServiceController  QueueController           │
│  TopicController  SubscriptionController            │
│  EventMessageController  EventSchemaController      │
│  EventApplicationController  MeshBridgeController   │
├─────────────────────────────────────────────────────┤
│                  Application Layer                   │
│  ManageBrokerServicesUseCase  ManageQueuesUseCase    │
│  ManageTopicsUseCase  ManageSubscriptionsUseCase     │
│  ManageEventMessagesUseCase  ManageEventSchemasUseCase│
│  ManageEventApplicationsUseCase  ManageMeshBridgesUseCase│
├─────────────────────────────────────────────────────┤
│                   Domain Layer                       │
│  Entities  Repository Interfaces  Domain Services   │
├─────────────────────────────────────────────────────┤
│                Infrastructure Layer                  │
│  MemoryRepositories  AppConfig  Container           │
└─────────────────────────────────────────────────────┘
```

## API Endpoints

| Method | Endpoint | Description |
|--------|--------|-------------|
| GET | `/health` | Health check |
| **Broker Services** | | |
| GET | `/api/v1/event-mesh/broker-services` | List all broker services |
| GET | `/api/v1/event-mesh/broker-services/{id}` | Get broker service by ID |
| GET | `/api/v1/event-mesh/broker-services/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/broker-services` | Create broker service |
| PUT | `/api/v1/event-mesh/broker-services/{id}` | Update broker service |
| DELETE | `/api/v1/event-mesh/broker-services/{id}` | Delete broker service |
| **Queues** | | |
| GET | `/api/v1/event-mesh/queues` | List all queues |
| GET | `/api/v1/event-mesh/queues/{id}` | Get queue by ID |
| GET | `/api/v1/event-mesh/queues/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/queues` | Create queue |
| PUT | `/api/v1/event-mesh/queues/{id}` | Update queue |
| DELETE | `/api/v1/event-mesh/queues/{id}` | Delete queue |
| **Topics** | | |
| GET | `/api/v1/event-mesh/topics` | List all topics |
| GET | `/api/v1/event-mesh/topics/{id}` | Get topic by ID |
| GET | `/api/v1/event-mesh/topics/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/topics` | Create topic |
| PUT | `/api/v1/event-mesh/topics/{id}` | Update topic |
| DELETE | `/api/v1/event-mesh/topics/{id}` | Delete topic |
| **Subscriptions** | | |
| GET | `/api/v1/event-mesh/subscriptions` | List all subscriptions |
| GET | `/api/v1/event-mesh/subscriptions/{id}` | Get subscription by ID |
| GET | `/api/v1/event-mesh/subscriptions/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/subscriptions` | Create subscription |
| PUT | `/api/v1/event-mesh/subscriptions/{id}` | Update subscription |
| DELETE | `/api/v1/event-mesh/subscriptions/{id}` | Delete subscription |
| **Event Messages** | | |
| GET | `/api/v1/event-mesh/messages` | List all messages |
| GET | `/api/v1/event-mesh/messages/{id}` | Get message by ID |
| GET | `/api/v1/event-mesh/messages/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/messages/publish` | Publish event message |
| POST | `/api/v1/event-mesh/messages/{id}/acknowledge` | Acknowledge message |
| DELETE | `/api/v1/event-mesh/messages/{id}` | Delete message |
| **Event Schemas** | | |
| GET | `/api/v1/event-mesh/schemas` | List all schemas |
| GET | `/api/v1/event-mesh/schemas/{id}` | Get schema by ID |
| GET | `/api/v1/event-mesh/schemas/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/schemas` | Create schema |
| PUT | `/api/v1/event-mesh/schemas/{id}` | Update schema |
| DELETE | `/api/v1/event-mesh/schemas/{id}` | Delete schema |
| **Event Applications** | | |
| GET | `/api/v1/event-mesh/applications` | List all applications |
| GET | `/api/v1/event-mesh/applications/{id}` | Get application by ID |
| GET | `/api/v1/event-mesh/applications/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/applications` | Create application |
| PUT | `/api/v1/event-mesh/applications/{id}` | Update application |
| DELETE | `/api/v1/event-mesh/applications/{id}` | Delete application |
| **Mesh Bridges** | | |
| GET | `/api/v1/event-mesh/bridges` | List all mesh bridges |
| GET | `/api/v1/event-mesh/bridges/{id}` | Get mesh bridge by ID |
| GET | `/api/v1/event-mesh/bridges/by-tenant/{tenantId}` | List by tenant |
| POST | `/api/v1/event-mesh/bridges` | Create mesh bridge |
| PUT | `/api/v1/event-mesh/bridges/{id}` | Update mesh bridge |
| DELETE | `/api/v1/event-mesh/bridges/{id}` | Delete mesh bridge |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `EVENT_MESH_HOST` | `0.0.0.0` | Server bind address |
| `EVENT_MESH_PORT` | `8108` | Server listen port |

## Build and Run

### Local

```bash
dub build
./uim-event-mesh-platform-service
```

### Docker

```bash
docker build -t uim-event-mesh .
docker run -p 8108:8108 uim-event-mesh
```

### Podman

```bash
podman build -t uim-event-mesh -f Containerfile .
podman run -p 8108:8108 uim-event-mesh
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
