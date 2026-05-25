# UML — SAP Private Link Service (UIM Platform)

## 1. Domain Class Diagram

```plantuml
@startuml private-link-domain

skinparam classAttributeIconSize 0
skinparam class {
  BackgroundColor #F8F8FF
  BorderColor     #444
}

package "domain.types" {
  class ServiceInstanceId  { +string value }
  class PrivateEndpointId  { +string value }
  class ServiceBindingId   { +string value }
}

package "domain.enumerations" {
  enum IaasProvider      { azure; aws; gcp }
  enum InstanceStatus    { pending; provisioning; ready; failed; suspended; deleted_ }
  enum EndpointStatus    { pendingAcceptance; approved; rejected; disconnected; ready; failed }
  enum BindingStatus     { creating; active; deleting; deleted_ }
  enum ServicePlan       { standard; premium }
  enum NetworkDirection  { inbound; outbound }
}

package "domain.entities" {
  class ServiceInstance {
    +ServiceInstanceId id
    +TenantId tenantId
    +string name
    +string description
    +string resourceId
    +IaasProvider iaasProvider
    +ServicePlan plan
    +string region
    +string subaccountId
    +InstanceStatus status
    +string statusMessage
    +PrivateEndpointId privateEndpointId
    +long createdAt
    +long updatedAt
    +Json toJson()
  }

  class PrivateEndpoint {
    +PrivateEndpointId id
    +TenantId tenantId
    +ServiceInstanceId serviceInstanceId
    +string name
    +string privateIpAddress
    +string hostname
    +ushort port
    +EndpointStatus status
    +string statusMessage
    +string providerEndpointId
    +IaasProvider iaasProvider
    +string region
    +long approvedAt
    +long createdAt
    +long updatedAt
    +Json toJson()
  }

  class ServiceBinding {
    +ServiceBindingId id
    +TenantId tenantId
    +ServiceInstanceId serviceInstanceId
    +string applicationId
    +string hostname
    +string privateIpAddress
    +ushort port
    +BindingStatus status
    +long createdAt
    +long deletedAt
    +Json toJson()
  }
}

package "domain.ports.repositories" {
  interface ServiceInstanceRepository {
    +bool existsByName(TenantId, string)
    +ServiceInstance findByName(TenantId, string)
    +ServiceInstance[] findByStatus(TenantId, InstanceStatus)
    +ServiceInstance[] findByIaasProvider(TenantId, IaasProvider)
  }

  interface PrivateEndpointRepository {
    +PrivateEndpoint[] findByServiceInstance(TenantId, ServiceInstanceId)
    +PrivateEndpoint[] findByStatus(TenantId, EndpointStatus)
    +void removeByServiceInstance(TenantId, ServiceInstanceId)
  }

  interface ServiceBindingRepository {
    +ServiceBinding[] findByServiceInstance(TenantId, ServiceInstanceId)
    +ServiceBinding[] findByApplication(TenantId, string)
    +void removeByServiceInstance(TenantId, ServiceInstanceId)
  }
}

package "domain.services" {
  class EndpointResolver {
    -PrivateEndpointRepository endpoints
    +PrivateEndpoint resolveForInstance(TenantId, ServiceInstanceId)
    +bool isReachable(TenantId, ServiceInstanceId)
  }
}

ServiceInstance       "1" --> "0..1" PrivateEndpoint : references
PrivateEndpoint       "0..*" -- "1"  ServiceInstance : belongs to
ServiceBinding        "0..*" -- "1"  ServiceInstance : binds
EndpointResolver      --> PrivateEndpointRepository : uses

ServiceInstanceRepository ..> ServiceInstance
PrivateEndpointRepository ..> PrivateEndpoint
ServiceBindingRepository  ..> ServiceBinding

@enduml
```

---

## 2. Hexagonal Architecture Diagram

```plantuml
@startuml private-link-hexagon

skinparam componentStyle rectangle

package "Primary Adapters (Driving)" {
  [HTTP REST Controller]   as HTTP
  [CLI Controller]         as CLI
  [Web Controller]         as WEB
  [GUI Controller]         as GUI
}

package "Application Core" {
  package "Use Cases" {
    [ManageServiceInstancesUseCase]  as UC1
    [ManagePrivateEndpointsUseCase]  as UC2
    [ManageServiceBindingsUseCase]   as UC3
  }
  package "Domain" {
    [ServiceInstance]  as E1
    [PrivateEndpoint]  as E2
    [ServiceBinding]   as E3
    [EndpointResolver] as DS1
  }
  package "Ports (interfaces)" {
    [ServiceInstanceRepository]  as P1
    [PrivateEndpointRepository]  as P2
    [ServiceBindingRepository]   as P3
  }
}

package "Secondary Adapters (Driven)" {
  [MemoryServiceInstanceRepository] as M1
  [MemoryPrivateEndpointRepository] as M2
  [MemoryServiceBindingRepository]  as M3
  [FileServiceInstanceRepository]   as F1
  [MongoServiceInstanceRepository]  as DB1
}

HTTP --> UC1
HTTP --> UC2
HTTP --> UC3
CLI  --> UC1
CLI  --> UC2
CLI  --> UC3
WEB  --> UC1
GUI  --> UC1

UC1 --> P1
UC1 --> P2
UC2 --> P2
UC2 --> P1
UC3 --> P3
UC3 --> P1
UC3 --> P2
UC3 --> DS1
DS1 --> P2

P1 <|.. M1
P1 <|.. F1
P1 <|.. DB1
P2 <|.. M2
P3 <|.. M3

@enduml
```

---

## 3. Private Endpoint Approval Sequence Diagram

```plantuml
@startuml private-link-approval-sequence

actor "Platform Admin" as Admin
participant "HTTP Controller\n(PrivateEndpoint)" as Ctrl
participant "ManagePrivateEndpoints\nUseCase" as UC
participant "ServiceInstance\nRepository" as IR
participant "PrivateEndpoint\nRepository" as ER
participant "IaaS Provider\n(Azure/AWS/GCP)" as IaaS

== Create Service Instance ==
Admin -> Ctrl : POST /api/v1/service-instances\n{name, resourceId, iaasProvider}
Ctrl -> UC : createInstance(req)
UC -> IR : save(ServiceInstance{status=pending})
UC --> Ctrl : CommandResult{id}
Ctrl --> Admin : 201 Created {id}

== Create Private Endpoint ==
Admin -> Ctrl : POST /api/v1/private-endpoints\n{serviceInstanceId, name, ...}
Ctrl -> UC : createEndpoint(req)
UC -> IR : findById(serviceInstanceId)
IR --> UC : ServiceInstance
UC -> ER : save(PrivateEndpoint{status=pendingAcceptance})
UC -> IR : update(instance{status=provisioning})
UC --> Ctrl : CommandResult{endpointId}
Ctrl --> Admin : 201 Created {id}

== IaaS Approves Connection ==
IaaS -> Ctrl : POST /api/v1/private-endpoints/:id/approve\n{providerEndpointId, privateIpAddress, hostname, port}
Ctrl -> UC : approveEndpoint(req)
UC -> ER : update(endpoint{status=approved, hostname, ip, port})
UC -> IR : update(instance{status=ready})
UC --> Ctrl : CommandResult
Ctrl --> IaaS : 200 OK

== Application Creates Binding ==
Admin -> Ctrl : POST /api/v1/service-bindings\n{serviceInstanceId, applicationId}
Ctrl -> UC : createBinding(req)
UC -> IR : findById(serviceInstanceId) → ready
UC -> ER : resolveForInstance → hostname + ip
UC -> ER : save(ServiceBinding{hostname, ip, status=active})
UC --> Ctrl : CommandResult{bindingId}
Ctrl --> Admin : 201 Created {id, hostname, privateIpAddress}

@enduml
```

---

## 4. Infrastructure / Persistence Strategy Diagram

```plantuml
@startuml private-link-persistence

interface ServiceInstanceRepository
interface PrivateEndpointRepository
interface ServiceBindingRepository

class MemoryServiceInstanceRepository  implements ServiceInstanceRepository
class MemoryPrivateEndpointRepository  implements PrivateEndpointRepository
class MemoryServiceBindingRepository   implements ServiceBindingRepository

class FileServiceInstanceRepository    implements ServiceInstanceRepository
class MongoServiceInstanceRepository   implements ServiceInstanceRepository

note bottom of MemoryServiceInstanceRepository
  Default backend.
  Active when PRIVLINK_MONGO_URI
  and PRIVLINK_DATA_DIR are unset.
end note

note bottom of FileServiceInstanceRepository
  Activated when
  PRIVLINK_DATA_DIR is set.
  Persists NDJSON files.
end note

note bottom of MongoServiceInstanceRepository
  Activated when
  PRIVLINK_MONGO_URI is set.
  Full MongoDB persistence.
end note

@enduml
```
