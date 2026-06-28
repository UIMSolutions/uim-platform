# UML — Logistics Management Service

## 1. Domain Class Diagram

```plantuml
@startuml domain-class-diagram
skinparam classAttributeIconSize 0
skinparam shadowing false

package "Domain" {

  enum CarrierStatus { active, inactive, suspended }
  enum TransportMode { road, rail, sea, air, multimodal }
  enum FreightOrderStatus { draft, planned, inTransit, delivered, cancelled }
  enum ShipmentStatus { created, inProgress, shipped, delivered, cancelled }
  enum DeliveryStatus { created, picking, packed, shipped, delivered, cancelled }
  enum WarehouseTaskType { picking, packing, putaway, transfer, counting }
  enum WarehouseTaskStatus { created, queued, inProgress, confirmed, cancelled }
  enum WarehouseOrderStatus { created, released, inProgress, completed, cancelled }
  enum LogisticsDirection { outbound, inbound }

  class Carrier {
    +CarrierId id
    +TenantId tenantId
    +String name
    +String contactEmail
    +String contactPhone
    +String addressCountry
    +CarrierStatus status
    +TransportMode[] supportedModes
  }

  class FreightOrder {
    +FreightOrderId id
    +TenantId tenantId
    +String orderNumber
    +String originName
    +String destinationName
    +CarrierId carrierId
    +TransportMode transportMode
    +FreightOrderStatus status
    +Double weightKg
    +Double volumeM3
  }

  class Shipment {
    +ShipmentId id
    +TenantId tenantId
    +String shipmentNumber
    +LogisticsDirection direction
    +ShipmentStatus status
    +FreightOrderId freightOrderId
    +String warehouseId
    +String partnerId
  }

  class Delivery {
    +DeliveryId id
    +TenantId tenantId
    +String deliveryNumber
    +LogisticsDirection direction
    +DeliveryStatus status
    +ShipmentId shipmentId
    +DeliveryItem[] items
  }

  class DeliveryItem {
    +String productId
    +Double quantity
    +String unit
  }

  class WarehouseOrder {
    +WarehouseOrderId id
    +TenantId tenantId
    +String orderNumber
    +WarehouseOrderStatus status
    +DeliveryId deliveryId
    +String warehouseId
    +String assignedTo
  }

  class WarehouseTask {
    +WarehouseTaskId id
    +TenantId tenantId
    +String taskNumber
    +WarehouseTaskType taskType
    +WarehouseTaskStatus status
    +WarehouseOrderId warehouseOrderId
    +String productId
    +Double quantity
    +String assignedTo
  }

  class LogisticsPlanner {
    +isCarrierAvailable(tenantId, carrierId): bool
    +canTransitionDelivery(current, next): bool
    +canTransitionFreightOrder(current, next): bool
    +canTransitionTask(current, next): bool
  }

  FreightOrder "1" --> "1" Carrier : uses
  Shipment "0..*" --> "1" FreightOrder : belongs to
  Delivery "0..*" --> "1" Shipment : belongs to
  Delivery "1" *-- "0..*" DeliveryItem : contains
  WarehouseOrder "0..*" --> "1" Delivery : for delivery
  WarehouseTask "0..*" --> "1" WarehouseOrder : part of
  LogisticsPlanner ..> Carrier : validates
}
@enduml
```

---

## 2. Hexagonal Architecture (Ports & Adapters)

```plantuml
@startuml hexagonal
skinparam defaultTextAlignment center
skinparam shadowing false

rectangle "External World" as ext #lightgray {
  rectangle "HTTP Client" as http
  rectangle "CLI" as cli
  rectangle "Web Browser" as web
  rectangle "MongoDB" as mongo
  rectangle "File System" as files
  rectangle "Memory" as mem
}

hexagon "Logistic Management\nApplication Core" as core #lightyellow {
  rectangle "Ports (Interfaces)" as ports #lightblue {
    rectangle "CarrierRepository" as cr
    rectangle "FreightOrderRepository" as for
    rectangle "ShipmentRepository" as sr
    rectangle "DeliveryRepository" as dr
    rectangle "WarehouseOrderRepository" as wor
    rectangle "WarehouseTaskRepository" as wtr
  }
  rectangle "Domain\n(Entities + Services)" as domain #lightyellow
  rectangle "Application\n(Use Cases + DTOs)" as app #lightyellow
}

http --> core : REST API (Driving Port)
cli --> core : CLI Commands (Driving Port)
web --> core : Web UI (Driving Port)
core --> mongo : Driven Port (MongoDB Adapter)
core --> files : Driven Port (File Adapter)
core --> mem   : Driven Port (Memory Adapter)
@enduml
```

---

## 3. Delivery Status Transition Sequence

```plantuml
@startuml delivery-sequence
skinparam shadowing false
actor "WMS Operator" as op
participant "DeliveryController" as ctrl
participant "ManageDeliveriesUseCase" as uc
participant "LogisticsPlanner" as planner
participant "DeliveryRepository" as repo

op -> ctrl : PUT /api/v1/deliveries/{id}\n{ "status": "picking" }
ctrl -> uc  : updateDeliveryStatus(tenantId, id, req)
uc -> repo  : find(tenantId, id)
repo --> uc : Delivery(status=created)
uc -> planner : canTransitionDelivery(created, picking)
planner --> uc : true
uc -> repo  : save(updated delivery)
uc --> ctrl : CommandResult(success=true)
ctrl --> op : HTTP 200 { id, statusCode: 200 }
@enduml
```

---

## 4. Warehouse Task Confirm Sequence

```plantuml
@startuml task-confirm-sequence
skinparam shadowing false
actor "Warehouse Worker" as worker
participant "WarehouseTaskController" as ctrl
participant "ManageWarehouseTasksUseCase" as uc
participant "LogisticsPlanner" as planner
participant "WarehouseTaskRepository" as repo

worker -> ctrl : POST /api/v1/warehouse-tasks/{id}/confirm\n{ assignedTo, confirmedAt }
ctrl -> uc : confirmTask(tenantId, id, req)
uc -> repo : find(tenantId, id)
repo --> uc : WarehouseTask(status=inProgress)
uc -> planner : canTransitionTask(inProgress, confirmed)
planner --> uc : true
uc -> repo : save(task, status=confirmed, confirmedAt=now)
uc --> ctrl : CommandResult(success=true)
ctrl --> worker : HTTP 200 { id, statusCode: 200 }
@enduml
```

---

## 5. Persistence Strategy Component Diagram

```plantuml
@startuml persistence-strategy
skinparam shadowing false

component "Use Case" as uc
interface "CarrierRepository" as iface

component "MemoryCarrierRepository" as mem
component "FileCarrierRepository\n(NDJSON stub)" as file
component "MongoCarrierRepository\n(stub)" as mongo

uc --> iface
iface <|.. mem
iface <|.. file
iface <|.. mongo

note bottom of mem  : Default (no env config)
note bottom of file : LOGMGMT_DATA_DIR set
note bottom of mongo : LOGMGMT_MONGO_URI set
@enduml
```
