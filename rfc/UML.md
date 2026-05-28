# UIM RFC Interface — UML Diagrams

## 1. Domain Model (Class Diagram)

```plantuml
@startuml domain-model

package "domain" {

  enum RfcType {
    sRFC
    aRFC
    tRFC
    qRFC
    bgRFC
    ldq
  }

  enum RfcStatus {
    pending
    executing
    queued
    committed
    rolledBack
    succeeded
    failed
    timedOut
  }

  enum ParameterDirection {
    import_
    export_
    changing
    tables
  }

  enum ConnectionType {
    abapSystem
    httpConnection
    tcpIpConnection
    logicalDestination
    internalCall
    sncDestination
  }

  enum LuwStatus {
    open
    executing
    committed
    rolledBack
  }

  class Destination {
    +DestinationId id
    +TenantId tenantId
    +ConnectionType connectionType
    +string host
    +ushort port
    +SystemId systemId
    +bool useSNC
    +bool active
    +isNull() bool
    +toJson() Json
    +{static} create(...) Destination
  }

  class FunctionModule {
    +FunctionModuleId id
    +TenantId tenantId
    +string functionGroup
    +string shortText
    +string remoteEnabled
    +RfcParameter[] parameters
    +bool active
    +isNull() bool
    +toJson() Json
    +{static} create(...) FunctionModule
  }

  class RfcParameter {
    +string name
    +ParameterDirection direction
    +string typeName
    +string defaultValue
    +bool optional
  }

  class RfcCall {
    +RfcCallId id
    +TenantId tenantId
    +DestinationId destinationId
    +FunctionModuleId functionModule
    +RfcType rfcType
    +RfcStatus status
    +TidValue tid
    +QueueName queueName
    +ParameterValue[] importParams
    +ParameterValue[] exportParams
    +isNull() bool
    +toJson() Json
    +{static} create(...) RfcCall
  }

  class Tid {
    +TidValue value
    +TenantId tenantId
    +DestinationId destinationId
    +LuwStatus status
    +RfcCallId[] callIds
    +isNull() bool
    +toJson() Json
    +{static} create(...) Tid
  }

  class RfcQueueEntry {
    +string id
    +QueueName queueName
    +QueueDirection direction
    +TidValue tid
    +RfcCallId callId
    +int sequenceNr
    +RfcStatus status
    +isNull() bool
    +toJson() Json
  }

  class RfcExecutor {
    +execute(RfcCall, Destination, FunctionModule) ExecuteResult
  }

  class TidManager {
    +createTid(tenantId, dest) Tid
    +isDuplicate(tenantId, value) bool
    +beginExecution(tenantId, value) bool
    +commit(tenantId, value) bool
    +rollback(tenantId, value) bool
  }

  class QueueProcessor {
    +processQueue(tenantId, queueName) int
  }

  FunctionModule "1" *-- "0..*" RfcParameter
  RfcCall --> Destination
  RfcCall --> FunctionModule
  RfcCall --> Tid
  RfcQueueEntry --> Tid
  RfcQueueEntry --> RfcCall
  QueueProcessor --> RfcExecutor
  QueueProcessor --> TidManager
}
@enduml
```

---

## 2. Hexagonal Architecture (Component Diagram)

```plantuml
@startuml hexagonal

rectangle "External World" {
  actor "HTTP Client" as http_client
  actor "CLI User" as cli_user
}

rectangle "Presentation (Driving Adapters)" {
  component DestinationController
  component FunctionModuleController
  component CallController
  component QueueController
  component HealthController
  component RfcCliRunner
}

rectangle "Application (Use Cases)" {
  component InvokeRfcUseCase
  component ManageDestinationsUseCase
  component ManageFunctionModulesUseCase
  component ManageCallsUseCase
  component ManageQueuesUseCase
}

rectangle "Domain (Core)" {
  component RfcExecutor
  component TidManager
  component QueueProcessor
  component Entities
}

rectangle "Infrastructure (Driven Adapters)" {
  component MemoryDestinationRepository
  component MemoryFunctionModuleRepository
  component MemoryRfcCallRepository
  component MemoryTidRepository
  component MemoryRfcQueueRepository
  component SrvConfig
}

http_client --> DestinationController
http_client --> CallController
cli_user --> RfcCliRunner

DestinationController --> ManageDestinationsUseCase
CallController --> InvokeRfcUseCase
CallController --> ManageCallsUseCase
QueueController --> ManageQueuesUseCase
RfcCliRunner --> InvokeRfcUseCase

InvokeRfcUseCase --> RfcExecutor
InvokeRfcUseCase --> TidManager
ManageQueuesUseCase --> QueueProcessor

MemoryDestinationRepository ..|> DestinationRepository
MemoryRfcCallRepository ..|> RfcCallRepository

@enduml
```

---

## 3. RFC Call Lifecycle (Sequence Diagram — sRFC)

```plantuml
@startuml srfc-sequence

actor Client
participant CallController
participant InvokeRfcUseCase
participant DestinationRepository
participant FunctionModuleRepository
participant RfcExecutor
participant RfcCallRepository

Client -> CallController : POST /api/v1/rfc/calls\n{rfcType:"sRFC", ...}
CallController -> InvokeRfcUseCase : invoke(req)
InvokeRfcUseCase -> DestinationRepository : findById(tenantId, destinationId)
InvokeRfcUseCase -> FunctionModuleRepository : findById(tenantId, functionModule)
InvokeRfcUseCase -> RfcCallRepository : save(call{status=executing})
InvokeRfcUseCase -> RfcExecutor : execute(call, dest, fm)
RfcExecutor --> InvokeRfcUseCase : ExecuteResult{success=true, exportParams=[...]}
InvokeRfcUseCase -> RfcCallRepository : update(call{status=succeeded})
InvokeRfcUseCase --> CallController : InvokeRfcResponse{success, callId, exportParams}
CallController --> Client : 200 OK\n{success:true, callId:..., exportParams:[...]}

@enduml
```

---

## 4. tRFC Call Lifecycle (Sequence Diagram)

```plantuml
@startuml trfc-sequence

actor Client
participant CallController
participant InvokeRfcUseCase
participant TidManager
participant TidRepository
participant RfcExecutor
participant RfcCallRepository

Client -> CallController : POST /api/v1/rfc/calls\n{rfcType:"tRFC", ...}
CallController -> InvokeRfcUseCase : invoke(req)
InvokeRfcUseCase -> TidManager : createTid(tenantId, destinationId)
TidManager -> TidRepository : save(Tid{status=open})
TidManager --> InvokeRfcUseCase : Tid{value="TID-XXXX"}
InvokeRfcUseCase -> RfcCallRepository : save(call{tid="TID-XXXX", status=executing})
InvokeRfcUseCase -> TidManager : beginExecution(TID-XXXX)
InvokeRfcUseCase -> RfcExecutor : execute(call, dest, fm)
RfcExecutor --> InvokeRfcUseCase : ExecuteResult{success=true}
InvokeRfcUseCase -> RfcCallRepository : update(call{status=succeeded})
InvokeRfcUseCase -> TidManager : commit(TID-XXXX)
TidManager -> TidRepository : update(Tid{status=committed})
InvokeRfcUseCase --> CallController : InvokeRfcResponse{success, tid="TID-XXXX"}
CallController --> Client : 200 OK\n{success:true, tid:"TID-XXXX"}

@enduml
```

---

## 5. qRFC Enqueue + Process (Sequence Diagram)

```plantuml
@startuml qrfc-sequence

actor Client
participant CallController
participant InvokeRfcUseCase
participant RfcQueueRepository
participant QueueController
participant QueueProcessor
participant RfcExecutor

Client -> CallController : POST /api/v1/rfc/calls\n{rfcType:"qRFC", queueName:"ZQUEUE01"}
CallController -> InvokeRfcUseCase : invoke(req)
InvokeRfcUseCase -> RfcQueueRepository : save(RfcQueueEntry{status=queued, seq=0})
InvokeRfcUseCase --> CallController : {success:true, status:"queued", tid:...}
CallController --> Client : 200 OK

...later...

Client -> QueueController : POST /api/v1/rfc/queues/ZQUEUE01/process
QueueController -> QueueProcessor : processQueue(tenantId, "ZQUEUE01")
loop for each pending entry (ordered by sequenceNr)
  QueueProcessor -> RfcExecutor : execute(call, dest, fm)
  RfcExecutor --> QueueProcessor : ExecuteResult{success}
  QueueProcessor -> RfcQueueRepository : update(entry{status=succeeded})
end
QueueController --> Client : {processed:1}

@enduml
```
