# UIM RFC Interface Service

A SAP RFC (Remote Function Call) interface microservice built with **D** and **vibe.d**, following hexagonal (ports & adapters) and clean architecture principles.

## Overview

This service provides a platform-native RFC gateway that models all SAP RFC variants as defined in the [SAP S/4HANA connectivity documentation](https://help.sap.com/docs/SAP_S4HANA_ON-PREMISE/753088fc00704d0a80e7fbd6803c8adb/4888068ad9134076e10000000a42189d.html):

| RFC Type | Description |
|----------|-------------|
| **sRFC** | Synchronous RFC — caller blocks until the remote function returns; both systems must be available |
| **aRFC** | Asynchronous RFC — control returns immediately after dispatch; called system must be available at dispatch time |
| **tRFC** | Transactional RFC — guarantees exactly-once execution via Transaction ID (TID); called system may be temporarily unavailable |
| **qRFC** | Queued RFC — extends tRFC with named inbound/outbound queues for ordered LUW (Logical Unit of Work) execution |
| **bgRFC** | Background RFC — successor to tRFC/qRFC with improved performance characteristics |
| **LDQ** | Local Data Queue — pull-based variant; data stored locally until retrieved by the external application |

## Architecture

```
rfc/
├── source/uim/platform/rfc/
│   ├── domain/            # Pure business logic — no infrastructure dependencies
│   │   ├── types.d        # Enums and type aliases (RfcType, RfcStatus, ParameterDirection …)
│   │   ├── entities/      # Destination, FunctionModule, RfcCall, Tid, RfcQueueEntry
│   │   ├── ports/         # Repository interfaces (hexagonal input/output ports)
│   │   └── services/      # RfcExecutor, TidManager, QueueProcessor
│   ├── application/       # Use cases orchestrating domain objects
│   │   ├── dto.d           # Request/Response DTOs
│   │   └── usecases/      # InvokeRfc, Manage{Destinations,FunctionModules,Calls,Queues}
│   ├── infrastructure/    # Technical adapters
│   │   ├── config.d        # SrvConfig — reads RFC_HOST / RFC_PORT
│   │   ├── persistence/   # In-memory repository adapters
│   │   └── container.d    # Dependency injection container
│   └── presentation/      # Entry-point adapters
│       ├── http/           # vibe.d HTTP controllers
│       └── cli/            # Interactive REPL
└── source/app.d            # Entry point (--cli flag or HTTP server)
```

## RFC Concepts

### Transaction ID (TID)
A 24-character GUID assigned to a Logical Unit of Work (LUW). The RFC runtime records the TID on first receipt, executes the LUW, and marks it committed. Duplicate TIDs are silently ignored — this is the exactly-once guarantee of tRFC.

### Logical Unit of Work (LUW)
A sequence of function module calls that must be executed atomically (all-or-nothing). In tRFC/qRFC the LUW is either committed or rolled back as a unit.

### qRFC Queue
A named FIFO queue. All LUWs enqueued into the same named queue are processed in sequence-number order, ensuring that business data is applied in the correct order even when the remote system is temporarily unavailable.

## HTTP API

### RFC Destinations (SM59 equivalent)

```http
GET    /api/v1/rfc/destinations          # list destinations
POST   /api/v1/rfc/destinations          # register destination
GET    /api/v1/rfc/destinations/{id}     # get destination
PUT    /api/v1/rfc/destinations/{id}     # update destination
DELETE /api/v1/rfc/destinations/{id}     # delete destination
```

### RFC Function Modules (SE37 equivalent)

```http
GET    /api/v1/rfc/functions             # list function modules
POST   /api/v1/rfc/functions             # register function module
GET    /api/v1/rfc/functions/{id}        # get function module
PUT    /api/v1/rfc/functions/{id}        # update function module
DELETE /api/v1/rfc/functions/{id}        # delete function module
```

### RFC Calls

```http
POST   /api/v1/rfc/calls                 # invoke RFC (all types)
GET    /api/v1/rfc/calls                 # list calls (?status=succeeded)
GET    /api/v1/rfc/calls/{id}            # get call record
DELETE /api/v1/rfc/calls/{id}            # delete call record
```

#### Invoke RFC — example request body

```json
{
  "destinationId": "S4H_PRD",
  "functionModule": "RFC_READ_TABLE",
  "rfcType": "sRFC",
  "importParams": [
    { "name": "QUERY_TABLE", "value": "MARA" },
    { "name": "ROWCOUNT",    "value": "10" }
  ]
}
```

For tRFC/qRFC the response includes a `tid` field. For qRFC also specify `"queueName": "ZQUEUE01"`.

### qRFC Queue Management

```http
GET    /api/v1/rfc/queues/{name}         # list entries in queue
POST   /api/v1/rfc/queues/{name}/process # process all pending entries
DELETE /api/v1/rfc/queues/entries/{id}   # delete a queue entry
```

### Health

```http
GET /api/v1/health                       # returns {"status":"UP","service":"RFC Interface"}
```

## CLI

```bash
./uim-rfc-platform-service --cli
```

| Command | Description |
|---------|-------------|
| `call <dest> <fm> [srfc\|arfc\|trfc\|qrfc\|bgrfc]` | Invoke a remote function module |
| `destinations` | List registered RFC destinations |
| `functions` | List registered function modules |
| `status <call-id>` | Show call status and result |
| `add-destination <id> <host> [abapSystem\|http\|tcpip]` | Register a destination |
| `help` | Show available commands |
| `exit` | Quit |

## Building

```bash
# Build the executable
dub build --root=rfc --build=release --config=defaultRun

# Run tests
dub test --root=rfc
```

## Docker / Podman

```bash
# Docker
docker build -f rfc/Dockerfile -t uim-rfc-platform-service .

# Podman
podman build -f rfc/Containerfile -t uim-rfc-platform-service .

# Run
docker run -p 8092:8092 uim-rfc-platform-service
```

## Kubernetes

```bash
kubectl apply -f rfc/k8s/configmap.yaml
kubectl apply -f rfc/k8s/deployment.yaml
kubectl apply -f rfc/k8s/service.yaml
```

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `RFC_HOST` | `0.0.0.0` | Bind address |
| `RFC_PORT` | `8092` | Listening port |

## License

Apache 2.0 — see [LICENSE](../LICENSE).
