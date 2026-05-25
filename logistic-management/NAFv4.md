# NAF v4 Architecture Views — Logistics Management Service

## NV-1: Overview (Capability Vision)

The **Logistics Management Service** provides a cloud-native, tenant-aware REST API that mirrors
SAP Logistics Management capabilities for the UIM Platform. It covers:

- **Transportation Management**: Freight orders, carrier assignment, transport modes, status tracking
- **Outbound Logistics**: Outbound shipments, outbound delivery documents with line items
- **Inbound Logistics**: Inbound shipments, inbound delivery processing
- **Warehouse Management**: Warehouse orders grouping tasks; individual pick/pack/put-away/transfer tasks
- **Process Automation**: Domain-enforced status transitions validated by the `LogisticsPlanner` domain service
- **Multi-tenant Isolation**: All data is scoped by `tenantId`
- **Pluggable Persistence**: In-memory (dev), NDJSON files (edge), MongoDB (production)
- **Container-ready**: Docker, Podman, Kubernetes (port 8086)

---

## NV-2: Capability Taxonomy

| Tier | Capability |
|------|-----------|
| Transportation | Create freight orders, assign carriers, track transit status |
| Outbound | Create outbound deliveries, transition picking/packing/shipping |
| Inbound | Create inbound deliveries, goods receipt processing |
| Warehouse | Create warehouse orders per delivery; manage pick/pack/put-away tasks |
| Task Execution | Confirm warehouse tasks, bulk queue management |
| Carrier Master | Maintain carrier master data, supported transport modes |
| Health | Liveness/readiness health endpoint |

---

## NOV-1: Operational Concept

```
External Systems (SAP S/4HANA, EWM, TM, SAP BTP)
         │  REST / JSON
         ▼
┌─────────────────────────────────────┐
│        Logistics Management         │
│        Service (port 8086)          │
│                                     │
│  HTTP Adapter → Use Cases → Domain  │
│         │                           │
│  Persistence (Memory/File/Mongo)    │
└─────────────────────────────────────┘
         │  K8s Service (ClusterIP)
         ▼
   Other Platform Services
```

---

## NOV-2: Operational Node Connectivity

| Node A | Interface | Node B | Protocol |
|--------|-----------|--------|----------|
| API Client | REST/JSON | HTTP Adapter | HTTP/1.1 |
| HTTP Adapter | D function call | Use Case Layer | In-process |
| Use Case Layer | Repository interface | Memory Repo | In-process |
| Use Case Layer | Repository interface | File Repo | Local FS |
| Use Case Layer | Repository interface | MongoDB Repo | TCP/27017 |
| Kubernetes Pod | TCP 8086 | ClusterIP Service | TCP |
| External Load Balancer | TCP 80/443 | ClusterIP Service | TCP |

---

## NSV-1: Service Taxonomy

| Service | Path | Method(s) |
|---------|------|-----------|
| Carrier — List | `/api/v1/carriers` | GET |
| Carrier — Create | `/api/v1/carriers` | POST |
| Carrier — Get | `/api/v1/carriers/{id}` | GET |
| Carrier — Update | `/api/v1/carriers/{id}` | PUT |
| Carrier — Delete | `/api/v1/carriers/{id}` | DELETE |
| Freight Order — List | `/api/v1/freight-orders` | GET |
| Freight Order — Create | `/api/v1/freight-orders` | POST |
| Freight Order — Get | `/api/v1/freight-orders/{id}` | GET |
| Freight Order — Update | `/api/v1/freight-orders/{id}` | PUT |
| Freight Order — Delete | `/api/v1/freight-orders/{id}` | DELETE |
| Freight Order — Transition | `/api/v1/freight-orders/{id}/transition` | POST |
| Shipment — List | `/api/v1/shipments` | GET |
| Shipment — Create | `/api/v1/shipments` | POST |
| Shipment — Get | `/api/v1/shipments/{id}` | GET |
| Shipment — Update | `/api/v1/shipments/{id}` | PUT |
| Shipment — Delete | `/api/v1/shipments/{id}` | DELETE |
| Delivery — List | `/api/v1/deliveries` | GET |
| Delivery — Create | `/api/v1/deliveries` | POST |
| Delivery — Get | `/api/v1/deliveries/{id}` | GET |
| Delivery — Update/Transition | `/api/v1/deliveries/{id}` | PUT |
| Delivery — Delete | `/api/v1/deliveries/{id}` | DELETE |
| Warehouse Order — List | `/api/v1/warehouse-orders` | GET |
| Warehouse Order — Create | `/api/v1/warehouse-orders` | POST |
| Warehouse Order — Get | `/api/v1/warehouse-orders/{id}` | GET |
| Warehouse Order — Update | `/api/v1/warehouse-orders/{id}` | PUT |
| Warehouse Order — Delete | `/api/v1/warehouse-orders/{id}` | DELETE |
| Warehouse Task — List | `/api/v1/warehouse-tasks` | GET |
| Warehouse Task — Create | `/api/v1/warehouse-tasks` | POST |
| Warehouse Task — Get | `/api/v1/warehouse-tasks/{id}` | GET |
| Warehouse Task — Delete | `/api/v1/warehouse-tasks/{id}` | DELETE |
| Warehouse Task — Confirm | `/api/v1/warehouse-tasks/{id}/confirm` | POST |
| Health | `/api/v1/health` | GET |

---

## NSV-2: Service Data Flow

```
POST /api/v1/deliveries
  └─► DeliveryController.createHandler
        └─► ManageDeliveriesUseCase.createDelivery
              ├─► DeliveryRepository.save   (persistence)
              └─► CommandResult → HTTP 201

PUT /api/v1/deliveries/{id}  { "status":"picking" }
  └─► DeliveryController.updateHandler
        └─► ManageDeliveriesUseCase.updateDeliveryStatus
              ├─► DeliveryRepository.findById
              ├─► LogisticsPlanner.canTransitionDelivery  (guard)
              ├─► DeliveryRepository.save   (updated status)
              └─► CommandResult → HTTP 200

DELETE /api/v1/deliveries/{id}
  └─► DeliveryController.deleteHandler
        └─► ManageDeliveriesUseCase.deleteDelivery
              ├─► WarehouseOrderRepository.removeByDelivery  (cascade)
              └─► DeliveryRepository.remove → HTTP 204
```

---

## NSV-4: Service Behaviour (Status State Machines)

### Freight Order

```
draft ──────► planned ──────► inTransit ──────► delivered
  │               │
  └── cancelled ──┘── cancelled
```

### Delivery

```
created ──► picking ──► packed ──► shipped ──► delivered
  │            │           │
  └────────────┴───────────┴── cancelled
```

### Warehouse Task

```
created ──► queued ──► inProgress ──► confirmed
  │            │            │
  └────────────┴────────────┴── cancelled
```

---

## NTV-1: Technical Architecture

| Layer | Technology |
|-------|-----------|
| Language | D (dlang), LDC 1.40.1 |
| HTTP Framework | vibe.d 0.10.x |
| Build Tool | DUB (dub.sdl) |
| Serialization | vibe-serialization (JSON) |
| Container | Docker (multi-stage, ubuntu:24.04 runtime) |
| Orchestration | Kubernetes — Deployment, Service, ConfigMap |
| Default Storage | In-memory (`TenantRepository!(T, Id)` base class) |
| File Storage | NDJSON files (stub — `LOGMGMT_DATA_DIR`) |
| MongoDB Storage | vibe.d MongoDB driver (stub — `LOGMGMT_MONGO_URI`) |
| Architecture Patterns | Hexagonal (Ports and Adapters), Clean Architecture, MVC (web/cli/gui) |
| Security | Non-root container user, tenant-scoped data isolation |
| Observability | `/api/v1/health` liveness + readiness probes |

---

## NCV-1: Capability to Service Mapping

| Capability | Service(s) |
|-----------|-----------|
| Carrier master data | `CarrierController` |
| Freight / transport order management | `FreightOrderController` |
| Outbound logistics | `ShipmentController` + `DeliveryController` |
| Inbound logistics | `ShipmentController` (direction=inbound) + `DeliveryController` (direction=inbound) |
| Warehouse task execution | `WarehouseTaskController` |
| Warehouse order management | `WarehouseOrderController` |
| Status transition validation | `LogisticsPlanner` (domain service) |
| Health monitoring | `HealthController` |

---

## NCV-2: System Context

```
┌──────────────────────────────────────────────────────────────────┐
│                        UIM Platform                              │
│                                                                  │
│  ┌──────────────────┐   ┌──────────────────┐                    │
│  │ connectivity     │   │ destination      │ ... other services │
│  └──────────────────┘   └──────────────────┘                    │
│                                                                  │
│  ┌──────────────────────────────────────────┐                   │
│  │       logistic-management                │                   │
│  │  Carriers / Freight Orders / Shipments   │                   │
│  │  Deliveries / Wh.Orders / Wh.Tasks       │                   │
│  └──────────────────────────────────────────┘                   │
└──────────────────────────────────────────────────────────────────┘
         │  REST
         ▼
   SAP S/4HANA / SAP EWM / SAP TM / 3rd-party WMS
```

---

## NSOV-1: Service-Oriented View

| Concern | Decision |
|---------|----------|
| API style | REST/JSON over HTTP/1.1 |
| Auth | Tenant ID passed via `X-Tenant-ID` header (extensible to OAuth2/XSUAA) |
| Versioning | URL-based (`/api/v1/`) |
| Error format | `{ "error": "...", "statusCode": N }` |
| Idempotency | PUT operations are idempotent (full entity update) |
| Cascade deletes | Delivery delete cascades to warehouse orders; warehouse order delete cascades to tasks |
| Domain validation | `LogisticsPlanner` enforces status machine transitions at application layer |
| Multi-tenancy | All repository calls are scoped by `tenantId` |
| Observability | Health endpoint, structured log output planned |
