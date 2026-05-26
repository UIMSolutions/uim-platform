# UIM Print Platform Service

A cloud-native print queue management service for the UIM Platform, modeled on the SAP BTP Print Service. Built with [D language](https://dlang.org/) and [vibe.d](https://vibed.org/) using Hexagonal/Clean Architecture.

---

## Overview

The UIM Print Platform Service manages the full lifecycle of cloud print jobs: clients register with the service, documents are uploaded, tasks are queued to print queues, and connected printers (via SAP Print Client or compatible agents) poll and execute the print jobs.

## Features

| Feature | Description |
|---|---|
| Print Queues | Tenant-aware queues routing tasks to physical/virtual printers |
| Print Tasks | Job lifecycle tracking: pending → fetched → processing → printed/failed |
| Printers | Printer registration (IPP, LPD, USB, CUPS, Virtual) |
| Print Documents | Document storage and format management (PDF, ZPL, PCL, PostScript, …) |
| Print Clients | Client agent registration with token-based authentication |

## Architecture

```
┌────────────────────────────────────────────┐
│              Presentation Layer             │
│  HTTP Controllers  │  Web UI  │  CLI        │
├────────────────────────────────────────────┤
│              Application Layer              │
│  Use Cases  │  DTOs  │  Command/Query       │
├────────────────────────────────────────────┤
│               Domain Layer                  │
│  Entities  │  Repository Ports  │  Services │
├────────────────────────────────────────────┤
│            Infrastructure Layer             │
│  Memory  │  File  │  MongoDB  │  Config     │
└────────────────────────────────────────────┘
```

### Hexagonal Architecture Ports & Adapters

| Port (Interface) | Memory Adapter | File Adapter | MongoDB Adapter |
|---|---|---|---|
| `PrintQueueRepository` | `MemoryPrintQueueRepository` | `FilePrintQueueRepository` | `MongoPrintQueueRepository` |
| `PrintTaskRepository` | `MemoryPrintTaskRepository` | `FilePrintTaskRepository` | `MongoPrintTaskRepository` |
| `PrinterRepository` | `MemoryPrinterRepository` | `FilePrinterRepository` | `MongoPrinterRepository` |
| `PrintDocumentRepository` | `MemoryPrintDocumentRepository` | `FilePrintDocumentRepository` | `MongoPrintDocumentRepository` |
| `PrintClientRepository` | `MemoryPrintClientRepository` | `FilePrintClientRepository` | `MongoPrintClientRepository` |

---

## REST API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/health` | Health check |
| GET | `/api/v1/print/queues` | List queues for tenant |
| POST | `/api/v1/print/queues` | Create queue |
| GET | `/api/v1/print/queues/:id` | Get queue by ID |
| PUT | `/api/v1/print/queues/:id` | Update queue |
| DELETE | `/api/v1/print/queues/:id` | Delete queue |
| GET | `/api/v1/print/tasks` | List tasks for tenant |
| POST | `/api/v1/print/tasks` | Create task |
| GET | `/api/v1/print/tasks/:id` | Get task by ID |
| PUT | `/api/v1/print/tasks/:id` | Update task status |
| DELETE | `/api/v1/print/tasks/:id` | Delete task |
| GET | `/api/v1/print/printers` | List printers |
| POST | `/api/v1/print/printers` | Register printer |
| GET | `/api/v1/print/printers/:id` | Get printer |
| PUT | `/api/v1/print/printers/:id` | Update printer |
| DELETE | `/api/v1/print/printers/:id` | Delete printer |
| GET | `/api/v1/print/documents` | List documents |
| POST | `/api/v1/print/documents` | Upload document |
| GET | `/api/v1/print/documents/:id` | Get document |
| DELETE | `/api/v1/print/documents/:id` | Delete document |
| GET | `/api/v1/print/clients` | List clients |
| POST | `/api/v1/print/clients` | Register client |
| GET | `/api/v1/print/clients/:id` | Get client |
| PUT | `/api/v1/print/clients/:id` | Update client |
| DELETE | `/api/v1/print/clients/:id` | Delete client |

### Web UI

| Method | Path | Description |
|---|---|---|
| GET | `/web/print/queues` | HTML queue list |
| GET | `/web/print/tasks` | HTML task list |

---

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `PRINT_HOST` | `0.0.0.0` | Bind address |
| `PRINT_PORT` | `8120` | Listen port |
| `PRINT_BACKEND` | `memory` | Storage backend: `memory`, `file`, `mongodb` |
| `PRINT_DATA_DIR` | `/data/print` | Directory for file backend |
| `PRINT_MONGO_URI` | `mongodb://localhost:27017` | MongoDB connection URI |
| `PRINT_MONGO_DB` | `uim_print` | MongoDB database name |

---

## Storage Backends

### Memory
Default. All data lives in-process — suitable for development and testing.

### File
JSON files in `PRINT_DATA_DIR`. Persistent across restarts; no external dependencies.

### MongoDB
Uses vibe.d's built-in MongoDB driver. Set `PRINT_MONGO_URI` and `PRINT_MONGO_DB`.

---

## Running with Docker / Podman

```bash
# Build
docker build -t uim-platform/print:latest .

# Run with memory backend
docker run -p 8120:8120 uim-platform/print:latest

# Run with file backend
docker run -p 8120:8120 \
  -e PRINT_BACKEND=file \
  -e PRINT_DATA_DIR=/data/print \
  -v /host/print-data:/data/print \
  uim-platform/print:latest

# Run with MongoDB
docker run -p 8120:8120 \
  -e PRINT_BACKEND=mongodb \
  -e PRINT_MONGO_URI=mongodb://mongo:27017 \
  uim-platform/print:latest
```

Same commands work with `podman`.

---

## Running on Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/deployment.yaml
```

---

## Development

```bash
# Build
dub build

# Run tests
dub test

# Run locally
PRINT_PORT=8120 dub run
```

---

## References

- [SAP BTP Print Service Documentation](https://help.sap.com/viewer/product/SCP_PRINT_SERVICE/SHIP/en-US)
- [SAP Print Service PDF Guide](https://help.sap.com/doc/4e8b1f3ae56d4de2a60d9b60685fe83a/SHIP/en-US/8c0d3ecb69d64505b9fcd4c2086fc8b7.pdf)
- [vibe.d](https://vibed.org/)
- [D Language](https://dlang.org/)
