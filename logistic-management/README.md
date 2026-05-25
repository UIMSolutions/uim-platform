# SAP Logistics Management — UIM Platform Service

A cloud-native microservice that mirrors SAP Logistics Management (SAP BTP) capabilities, built with **D** (dlang), **vibe.d**, and **hexagonal (Ports & Adapters) + Clean Architecture**.

---

## Features

| Domain Aggregate    | Key Operations |
|---------------------|----------------|
| **Carrier**         | CRUD, activate/suspend carriers |
| **Freight Order**   | Create, update, status transitions (draft → planned → in_transit → delivered) |
| **Shipment**        | Outbound/inbound shipment lifecycle |
| **Delivery**        | Inbound/outbound delivery with line items, status transitions |
| **Warehouse Order** | Group tasks, cascade delete |
| **Warehouse Task**  | Pick/Pack/Put-away/Transfer/Count tasks, confirm endpoint |

---

## Quick Start

### Docker / Podman

```bash
# Build
docker build -t uim-logistic-management:latest .
# Podman
podman build -f Containerfile -t uim-logistic-management:latest .

# Run (in-memory, default port 8086)
docker run -p 8086:8086 uim-logistic-management:latest

# Run with file persistence
docker run -p 8086:8086 \
  -e LOGMGMT_DATA_DIR=/data \
  -v $(pwd)/data:/data \
  uim-logistic-management:latest

# Run with MongoDB
docker run -p 8086:8086 \
  -e LOGMGMT_MONGO_URI=mongodb://mongo:27017/logistic_management \
  uim-logistic-management:latest
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Local DUB

```bash
cd logistic-management
dub run
```

---

## Environment Variables

| Variable             | Default        | Description |
|----------------------|----------------|-------------|
| `LOGMGMT_HOST`       | `0.0.0.0`      | Listen address |
| `LOGMGMT_PORT`       | `8086`         | Listen port |
| `LOGMGMT_MONGO_URI`  | *(empty)*      | MongoDB URI (enables Mongo persistence) |
| `LOGMGMT_DATA_DIR`   | *(empty)*      | Directory for NDJSON files (enables file persistence) |

---

## Storage Backends

| Backend   | Trigger                  | Notes |
|-----------|--------------------------|-------|
| Memory    | Default (no env set)     | Lost on restart; suitable for development |
| Files     | `LOGMGMT_DATA_DIR` set   | NDJSON files, one per aggregate |
| MongoDB   | `LOGMGMT_MONGO_URI` set  | Persistent, scalable |

---

## REST API Reference

### Health

```
GET  /api/v1/health
```

---

### Carriers

```
GET    /api/v1/carriers              List all carriers
POST   /api/v1/carriers              Create carrier
GET    /api/v1/carriers/{id}         Get carrier by ID
PUT    /api/v1/carriers/{id}         Update carrier
DELETE /api/v1/carriers/{id}         Delete carrier
```

**Create carrier request body:**
```json
{
  "name": "FastShip GmbH",
  "description": "Express road transport",
  "contactEmail": "ops@fastship.example",
  "contactPhone": "+49-30-12345678",
  "addressStreet": "Berliner Str. 42",
  "addressCity": "Berlin",
  "addressCountry": "DE",
  "taxId": "DE123456789",
  "supportedModes": ["road", "rail"]
}
```

---

### Freight Orders

```
GET    /api/v1/freight-orders              List all freight orders
POST   /api/v1/freight-orders              Create freight order
GET    /api/v1/freight-orders/{id}         Get freight order
PUT    /api/v1/freight-orders/{id}         Update freight order
DELETE /api/v1/freight-orders/{id}         Delete freight order
POST   /api/v1/freight-orders/{id}/transition   Transition status
```

**Transition request body:**
```json
{
  "status": "planned",
  "statusMessage": "Carrier confirmed",
  "actualDepartureAt": 0,
  "actualArrivalAt": 0
}
```

**Status flow:** `draft` → `planned` → `inTransit` → `delivered` (or `cancelled`)

---

### Shipments

```
GET    /api/v1/shipments              List shipments
POST   /api/v1/shipments              Create shipment
GET    /api/v1/shipments/{id}         Get shipment
PUT    /api/v1/shipments/{id}         Update shipment
DELETE /api/v1/shipments/{id}         Delete shipment
```

---

### Deliveries

```
GET    /api/v1/deliveries              List deliveries
POST   /api/v1/deliveries              Create delivery (with line items)
GET    /api/v1/deliveries/{id}         Get delivery
PUT    /api/v1/deliveries/{id}         Update delivery status
DELETE /api/v1/deliveries/{id}         Delete delivery (cascades warehouse orders)
```

**Status flow:** `created` → `picking` → `packed` → `shipped` → `delivered` (or `cancelled`)

---

### Warehouse Orders

```
GET    /api/v1/warehouse-orders              List warehouse orders
POST   /api/v1/warehouse-orders              Create warehouse order
GET    /api/v1/warehouse-orders/{id}         Get warehouse order
PUT    /api/v1/warehouse-orders/{id}         Update warehouse order
DELETE /api/v1/warehouse-orders/{id}         Delete order (cascades tasks)
```

---

### Warehouse Tasks

```
GET    /api/v1/warehouse-tasks              List tasks
POST   /api/v1/warehouse-tasks              Create task
GET    /api/v1/warehouse-tasks/{id}         Get task
DELETE /api/v1/warehouse-tasks/{id}         Delete task
POST   /api/v1/warehouse-tasks/{id}/confirm Confirm task execution
```

**Confirm request body:**
```json
{
  "assignedTo": "john.doe",
  "confirmedAt": 1735689600000
}
```

**Task types:** `picking`, `packing`, `putaway`, `transfer`, `counting`

**Status flow:** `created` → `queued` → `inProgress` → `confirmed` (or `cancelled`)

---

## Architecture

```
presentation/http    ← REST controllers (vibe.d URLRouter)
presentation/web     ← Web UI stub (MVC, Diet templates)
presentation/cli     ← CLI stub (MVC, argv parsing)
presentation/gui     ← Desktop GUI stub (MVC, dlangui/GtkD)
        │
application/         ← Use cases + DTOs
        │
domain/              ← Entities, value types, port interfaces, domain services
        │
infrastructure/      ← Memory / File / MongoDB repositories, DI container, config
```

---

## License

Apache 2.0 — Copyright © 2018-2026 Ozan Nurettin Süel (UI-Manufaktur UG)
