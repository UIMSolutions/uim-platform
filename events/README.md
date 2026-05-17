# SAP Event Mesh Service

A microservice modelling the **SAP Event Mesh** (formerly SAP Enterprise Messaging) capabilities on SAP BTP, built with [D](https://dlang.org/) and [vibe.d](https://vibed.org/) following **Hexagonal (Ports & Adapters)** and **Clean Architecture** principles.

---

## Features

| Resource | Description |
|---|---|
| **Messaging Services** | Service instances with dedicated namespaces for event routing |
| **Message Clients** | OAuth2-based client applications with protocol bindings (AMQP, MQTT, REST) |
| **Queues** | Durable message queues with configurable size, TTL, and dead-letter routing |
| **Queue Subscriptions** | Topic-pattern-based subscriptions that route events into queues |
| **Webhooks** | HTTP push delivery endpoints with OAuth2 / Basic / API-key auth |
| **Event Channels** | Named publish-subscribe channels with AsyncAPI definition support |
| **Message Bindings** | Bindings between message clients and queues/channels with permission scopes |
| **Health** | Liveness/readiness probe endpoint |

---

## Architecture

```
events/
├── source/
│   ├── app.d                          ← Entry point
│   └── uim/platform/events/
│       ├── package.d
│       ├── domain/                    ← Core business logic (no external deps)
│       │   ├── enumerations.d
│       │   ├── types.d
│       │   ├── entities/              ← Domain structs
│       │   ├── repositories/          ← Port interfaces (ITenantRepository)
│       │   └── services/              ← Domain validators
│       ├── application/               ← Use case orchestration
│       │   ├── dto.d                  ← Request/response transfer objects
│       │   └── usecases/manage/       ← ManageXxxUseCase classes
│       ├── infrastructure/            ← Adapters (config, DI, persistence)
│       │   ├── config.d               ← Env-var-based AppConfig
│       │   ├── container.d            ← Manual DI container
│       │   └── persistence/memory/    ← In-memory repository implementations
│       └── presentation/
│           └── http/controllers/      ← vibe.d HTTP controllers
```

**Dependency rule:** arrows always point inward.  
`presentation → application → domain ← infrastructure`

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/sap-event-mesh/messaging-services` | List messaging service instances |
| POST | `/api/v1/sap-event-mesh/messaging-services` | Create messaging service instance |
| GET | `/api/v1/sap-event-mesh/messaging-services/:id` | Get messaging service by ID |
| PUT | `/api/v1/sap-event-mesh/messaging-services/:id` | Update messaging service |
| DELETE | `/api/v1/sap-event-mesh/messaging-services/:id` | Delete messaging service |
| GET | `/api/v1/sap-event-mesh/message-clients` | List message clients |
| POST | `/api/v1/sap-event-mesh/message-clients` | Create message client |
| GET | `/api/v1/sap-event-mesh/message-clients/:id` | Get message client by ID |
| PUT | `/api/v1/sap-event-mesh/message-clients/:id` | Update message client |
| DELETE | `/api/v1/sap-event-mesh/message-clients/:id` | Delete message client |
| GET | `/api/v1/sap-event-mesh/queues` | List queues |
| POST | `/api/v1/sap-event-mesh/queues` | Create queue |
| GET | `/api/v1/sap-event-mesh/queues/:id` | Get queue by ID |
| PUT | `/api/v1/sap-event-mesh/queues/:id` | Update queue |
| DELETE | `/api/v1/sap-event-mesh/queues/:id` | Delete queue |
| GET | `/api/v1/sap-event-mesh/queue-subscriptions` | List queue subscriptions |
| POST | `/api/v1/sap-event-mesh/queue-subscriptions` | Create queue subscription |
| GET | `/api/v1/sap-event-mesh/queue-subscriptions/:id` | Get queue subscription by ID |
| PUT | `/api/v1/sap-event-mesh/queue-subscriptions/:id` | Update queue subscription |
| DELETE | `/api/v1/sap-event-mesh/queue-subscriptions/:id` | Delete queue subscription |
| GET | `/api/v1/sap-event-mesh/webhooks` | List webhooks |
| POST | `/api/v1/sap-event-mesh/webhooks` | Create webhook |
| GET | `/api/v1/sap-event-mesh/webhooks/:id` | Get webhook by ID |
| PUT | `/api/v1/sap-event-mesh/webhooks/:id` | Update webhook |
| DELETE | `/api/v1/sap-event-mesh/webhooks/:id` | Delete webhook |
| GET | `/api/v1/sap-event-mesh/event-channels` | List event channels |
| POST | `/api/v1/sap-event-mesh/event-channels` | Create event channel |
| GET | `/api/v1/sap-event-mesh/event-channels/:id` | Get event channel by ID |
| PUT | `/api/v1/sap-event-mesh/event-channels/:id` | Update event channel |
| DELETE | `/api/v1/sap-event-mesh/event-channels/:id` | Delete event channel |
| GET | `/api/v1/sap-event-mesh/message-bindings` | List message bindings |
| POST | `/api/v1/sap-event-mesh/message-bindings` | Create message binding |
| GET | `/api/v1/sap-event-mesh/message-bindings/:id` | Get message binding by ID |
| PUT | `/api/v1/sap-event-mesh/message-bindings/:id` | Update message binding |
| DELETE | `/api/v1/sap-event-mesh/message-bindings/:id` | Delete message binding |
| GET | `/api/v1/health` | Health check |

---

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `SAP_EVENT_MESH_HOST` | `0.0.0.0` | HTTP bind address |
| `SAP_EVENT_MESH_PORT` | `8109` | HTTP port |

---

## Build & Run

### Local (dub)

```bash
cd events
dub run --config=defaultRun
```

### Docker

```bash
docker build -t uim-platform/sap-event-mesh:latest .
docker run -p 8109:8109 \
  -e SAP_EVENT_MESH_HOST=0.0.0.0 \
  -e SAP_EVENT_MESH_PORT=8109 \
  uim-platform/sap-event-mesh:latest
```

### Podman

```bash
podman build -f Containerfile -t uim-platform/sap-event-mesh:latest .
podman run -p 8109:8109 \
  -e SAP_EVENT_MESH_HOST=0.0.0.0 \
  -e SAP_EVENT_MESH_PORT=8109 \
  uim-platform/sap-event-mesh:latest
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Testing

```bash
# Unit tests
dub test

# Health check
curl http://localhost:8109/api/v1/health

# Create a messaging service
curl -X POST http://localhost:8109/api/v1/sap-event-mesh/messaging-services \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: tenant-1" \
  -d '{
    "id": "svc-001",
    "name": "My Event Mesh",
    "namespace": "my-company/my-app",
    "plan": "standard",
    "region": "eu10",
    "createdBy": "admin"
  }'
```

---

## References

- [SAP Event Mesh documentation](https://help.sap.com/viewer/product/SAP_ENTERPRISE_MESSAGING/Cloud/en-US)
- [SAP Enterprise Messaging FSD](https://help.sap.com/doc/e56d7e676cc74906b813d226062d8634/Cloud/en-US/EnterpriseMessaging_FSD_en.pdf)
