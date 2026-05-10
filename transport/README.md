# Transport Platform Service

A microservice implementing **SAP Cloud Transport Management**-like capabilities for the UIM Platform.  
Built with [D](https://dlang.org/) + [vibe.d](https://vibed.org/) following **Clean + Hexagonal Architecture**.

---

## Overview

SAP Cloud Transport Management (CTM) enables controlled propagation of software deliverables across deployment landscapes. This service mirrors those capabilities within the UIM Platform:

- Model transport **nodes** (Cloud Foundry spaces, ABAP systems, Kyma clusters)
- Define directed **routes** between nodes (transport landscape topology)
- Register **transport requests** (MTA archives, integration content, HTML5 apps)
- Manage **import queues** per node (enqueue, import, reset, schedule)
- Record full **audit trail** of all transport actions

---

## Architecture

```
transport/
├── source/
│   ├── app.d                          Entry point
│   └── uim/platform/transport/
│       ├── package.d
│       ├── domain/                    Business rules, entities, ports
│       │   ├── enumerations.d
│       │   ├── types.d
│       │   ├── entities/              TransportNode, TransportRoute, TransportRequest,
│       │   │                          ImportQueueEntry, TransportAction
│       │   ├── repositories/          Port interfaces (ITenantRepository extensions)
│       │   └── services/              TransportValidator
│       ├── application/               Use cases, DTOs
│       │   ├── dtos/dto.d
│       │   └── usecases/manage/       ManageTransportNodes/Routes/Requests/
│       │                              ManageImportQueueEntries/TransportActions
│       ├── infrastructure/            Adapters, config, DI container
│       │   ├── config.d
│       │   ├── container.d
│       │   └── persistence/memory/    In-memory repository adapters
│       └── presentation/http/         HTTP controllers (vibe.d)
│           └── controllers/           TransportNode/Route/Request/
│                                      ImportQueueEntry/TransportActionController
├── k8s/
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile
└── Containerfile
```

### Hexagonal Architecture Layers

| Layer | Responsibility |
|---|---|
| **Domain** | Entities, value types, port interfaces, domain services (validation) |
| **Application** | Use cases orchestrating domain operations; DTOs for input/output |
| **Infrastructure** | In-memory repository adapters, config loader, DI container |
| **Presentation** | HTTP controllers registering vibe.d routes, JSON serialization |

---

## Domain Model

### Entities

| Entity | Description |
|---|---|
| `TransportNode` | A deployment target/source (CF space, ABAP, Kyma, Neo) |
| `TransportRoute` | Directed link from source node to destination node |
| `TransportRequest` | Unit of transport: MTA archive, integration content package, etc. |
| `ImportQueueEntry` | Pending/active/done import at a specific node |
| `TransportAction` | Audit record of every transport operation |

### Key Enumerations

- **NodeType**: `cloudFoundry`, `abap`, `neo`, `kyma`, `other`
- **ContentType**: `mtaArchive`, `integrationContent`, `htmlApp`, `abapCorContent`, `other`
- **RequestStatus**: `initial`, `running`, `success`, `failed`, `warning`, `outdated`, `repeating`
- **ImportStatus**: `initial`, `running`, `success`, `failed`, `warning`, `repeating`
- **ActionType**: `export_`, `import_`, `forward`, `reset`, `delete_`, `schedule`

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/transport/nodes` | List all transport nodes |
| POST | `/api/v1/transport/nodes` | Create a transport node |
| GET | `/api/v1/transport/nodes/:id` | Get a transport node |
| PUT | `/api/v1/transport/nodes/:id` | Update / enable / disable a node |
| DELETE | `/api/v1/transport/nodes/:id` | Delete a transport node |
| GET | `/api/v1/transport/routes` | List all transport routes |
| POST | `/api/v1/transport/routes` | Create a route |
| GET | `/api/v1/transport/routes/:id` | Get a route |
| PUT | `/api/v1/transport/routes/:id` | Update / enable / disable a route |
| DELETE | `/api/v1/transport/routes/:id` | Delete a route |
| GET | `/api/v1/transport/requests` | List all transport requests |
| POST | `/api/v1/transport/requests` | Register a transport request |
| GET | `/api/v1/transport/requests/:id` | Get a transport request |
| PUT | `/api/v1/transport/requests/:id` | Update request status |
| DELETE | `/api/v1/transport/requests/:id` | Delete a transport request |
| GET | `/api/v1/transport/queue-entries` | List import queue entries |
| POST | `/api/v1/transport/queue-entries` | Enqueue a request for import |
| GET | `/api/v1/transport/queue-entries/:id` | Get a queue entry |
| PUT | `/api/v1/transport/queue-entries/:id` | Update status / reset entry |
| DELETE | `/api/v1/transport/queue-entries/:id` | Remove from queue |
| GET | `/api/v1/transport/actions` | List audit actions |
| POST | `/api/v1/transport/actions` | Record a transport action |
| GET | `/api/v1/transport/actions/:id` | Get an audit action |
| PUT | `/api/v1/transport/actions/:id` | Update action status |
| GET | `/health` | Health check |

---

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `TRANSPORT_HOST` | `0.0.0.0` | Bind address |
| `TRANSPORT_PORT` | `8117` | HTTP port |

---

## Building & Running

### Local (dub)

```sh
cd transport
dub run
```

### Docker / Podman

```sh
# Docker
docker build -t uim-transport-platform-service .
docker run -p 8117:8117 uim-transport-platform-service

# Podman
podman build -t uim-transport-platform-service -f Containerfile .
podman run -p 8117:8117 uim-transport-platform-service
```

### Kubernetes

```sh
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Health Check

```sh
curl http://localhost:8117/health
# {"status":"UP","service":"Transport Platform Service"}
```

---

## Related SAP Documentation

- [SAP Cloud Transport Management – What Is?](https://help.sap.com/docs/TRANSPORT_MANAGEMENT_SERVICE/7f7160ec0d8546c6b3eab72fb5ad6fd8/5fef9d6b1cb047b2b18d9eb57aa15352.html)
- [Feature Scope Description (PDF)](https://help.sap.com/doc/b5430836c20d4bd8a975cb4d48b4e7a5/Cloud/en-US/Transport_Management_FSD.pdf)
