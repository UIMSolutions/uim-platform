# UML — Redis on SAP BTP, Hyperscaler Option

All diagrams use **PlantUML** notation.

---

## 1. Package Overview (Component Diagram)

```plantuml
@startuml PackageOverview
skinparam packageStyle rectangle

package "redis" {
    package "domain" {
        [entities]
        [repositories <<interface>>]
        [services]
        [types]
        [enumerations]
    }
    package "application" {
        [dto]
        [usecases/manage]
    }
    package "presentation" {
        package "http" {
            [controllers]
        }
        package "cli" {
            [cli/models]
            [cli/views]
            [cli/controllers]
        }
        package "web" {
            [web/models]
            [web/views]
            [web/controllers]
        }
        package "gui" {
            [gui/models]
            [gui/views]
            [gui/controllers]
        }
    }
    package "infrastructure" {
        [config]
        [container]
        package "persistence" {
            [memory]
            [file]
            [mongodb]
        }
    }
}

[usecases/manage] --> [repositories <<interface>>]
[usecases/manage] --> [entities]
[usecases/manage] --> [dto]
[controllers] --> [usecases/manage]
[cli/controllers] --> [usecases/manage]
[web/controllers] --> [usecases/manage]
[gui/controllers] --> [usecases/manage]
[memory] ..|> [repositories <<interface>>]
[file] ..|> [repositories <<interface>>]
[mongodb] ..|> [repositories <<interface>>]
[container] --> [memory]
[container] --> [file]
[container] --> [mongodb]
[container] --> [usecases/manage]
[container] --> [controllers]
@enduml
```

---

## 2. Domain Class Diagram

```plantuml
@startuml DomainClasses
skinparam classAttributeIconSize 0

class ServiceInstance {
    +ServiceInstanceId id
    +TenantId tenantId
    +string name
    +string description
    +ServicePlanId planId
    +InstanceStatus status
    +Hyperscaler hyperscaler
    +string region
    +RedisVersion redisVersion
    +long memoryMb
    +long maxConnections
    +string host
    +ushort port
    +bool tlsEnabled
    +bool haEnabled
    +PersistenceMode persistenceMode
    +long provisionedAt
    +toJson() : Json
}

class ServiceBinding {
    +ServiceBindingId id
    +TenantId tenantId
    +ServiceInstanceId instanceId
    +string appId
    +string name
    +BindingStatus status
    +string host
    +ushort port
    +string password
    +bool tls
    +long expiresAt
    +toJson() : Json
}

class ServicePlan {
    +ServicePlanId id
    +TenantId tenantId
    +string name
    +string description
    +PlanTier tier
    +long memoryMb
    +long maxConnections
    +bool haEnabled
    +bool persistenceEnabled
    +bool tlsEnabled
    +string pricingUnit
    +bool available
    +toJson() : Json
}

class Configuration {
    +ConfigurationId id
    +TenantId tenantId
    +ServiceInstanceId instanceId
    +MaxMemoryPolicy maxMemoryPolicy
    +long timeout
    +long maxConnections
    +bool tlsEnabled
    +PersistenceMode persistenceMode
    +long maxMemoryMb
    +bool notifyKeyspaceEvents
    +toJson() : Json
}

class CacheEntry {
    +CacheEntryId id
    +TenantId tenantId
    +ServiceInstanceId instanceId
    +string key
    +string value
    +CacheEntryType entryType
    +long ttl
    +toJson() : Json
}

class Metric {
    +MetricId id
    +TenantId tenantId
    +ServiceInstanceId instanceId
    +long timestamp
    +long memoryUsedMb
    +long memoryTotalMb
    +long connectedClients
    +long commandsPerSecond
    +double hitRate
    +long evictedKeys
    +toJson() : Json
}

class BackupPolicy {
    +BackupPolicyId id
    +TenantId tenantId
    +ServiceInstanceId instanceId
    +string schedule
    +int retentionDays
    +string storageLocation
    +BackupStatus status
    +toJson() : Json
}

class AccessControl {
    +AccessControlId id
    +TenantId tenantId
    +ServiceInstanceId instanceId
    +string cidrBlock
    +string direction
    +string action
    +int priority
    +toJson() : Json
}

ServiceInstance "1" --> "0..*" ServiceBinding : bound by
ServiceInstance "1" --> "0..1" Configuration : configured by
ServiceInstance "1" --> "0..*" CacheEntry : contains
ServiceInstance "1" --> "0..*" Metric : measured by
ServiceInstance "1" --> "0..1" BackupPolicy : backed up by
ServiceInstance "1" --> "0..*" AccessControl : protected by
ServicePlan "1" --> "0..*" ServiceInstance : used by
@enduml
```

---

## 3. Hexagonal Architecture (Port & Adapter)

```plantuml
@startuml HexagonalArchitecture
skinparam rectangle {
    BackgroundColor<<domain>> LightYellow
    BackgroundColor<<port>> LightBlue
    BackgroundColor<<adapter>> LightGreen
    BackgroundColor<<driving>> LightCoral
}

rectangle "Driving Adapters" <<driving>> {
    rectangle "HTTP REST\n(vibe.d URLRouter)" as http
    rectangle "CLI\n(string[] args)" as cli
    rectangle "Web UI\n(vibe.d Web)" as web
    rectangle "GUI\n(widget toolkit)" as gui
}

rectangle "Application Core" <<domain>> {
    rectangle "Use Cases\n(Manage*UseCase)" as uc
    rectangle "Domain\n(Entities, Services)" as dom
    rectangle "Repository Ports\n(interfaces)" <<port>> as ports
}

rectangle "Driven Adapters" <<adapter>> {
    rectangle "MemoryRepository" as mem
    rectangle "FileRepository" as file
    rectangle "MongoRepository" as mongo
}

http --> uc
cli --> uc
web --> uc
gui --> uc
uc --> dom
uc --> ports
ports <|.. mem
ports <|.. file
ports <|.. mongo
@enduml
```

---

## 4. Use Case Sequence: Provision Service Instance

```plantuml
@startuml ProvisionInstance
actor "App Developer" as dev
participant "HTTP Controller\n(ServiceInstanceController)" as ctrl
participant "ManageServiceInstances\nUseCase" as uc
participant "ServiceInstance\nRepository" as repo
participant "RedisValidator" as val

dev -> ctrl : POST /api/v1/redis/instances\n{name, planId, region, ...}
ctrl -> ctrl : parse JSON body -> ServiceInstanceDTO
ctrl -> uc : createServiceInstance(dto)
uc -> repo : nameExists(tenantId, name)
repo --> uc : false
uc -> val : isValidServiceInstance(entity)
val --> uc : true
uc -> repo : save(entity)
repo --> uc : ok
uc --> ctrl : CommandResult(success=true, id=...)
ctrl --> dev : 201 Created\n{id, name, status="provisioning", ...}
@enduml
```

---

## 5. Repository Interface Hierarchy

```plantuml
@startuml RepositoryHierarchy
interface ITenantRepository<E,ID> {
    +findById(TenantId, ID) : E
    +findByTenant(TenantId) : E[]
    +save(E) : void
    +update(E) : void
    +remove(TenantId, ID) : void
    +countByTenant(TenantId) : long
}

interface ServiceInstanceRepository {
    +findByStatus(TenantId, InstanceStatus) : ServiceInstance[]
    +findByPlan(TenantId, ServicePlanId) : ServiceInstance[]
    +findByHyperscaler(TenantId, Hyperscaler) : ServiceInstance[]
    +nameExists(TenantId, string) : bool
}

interface ServiceBindingRepository {
    +findByInstance(TenantId, ServiceInstanceId) : ServiceBinding[]
    +findByApp(TenantId, string) : ServiceBinding[]
}

interface ConfigurationRepository {
    +findByInstance(TenantId, ServiceInstanceId) : Configuration[]
}

interface CacheEntryRepository {
    +findByInstance(TenantId, ServiceInstanceId) : CacheEntry[]
    +findByKey(TenantId, ServiceInstanceId, string) : CacheEntry
}

ITenantRepository <|-- ServiceInstanceRepository
ITenantRepository <|-- ServiceBindingRepository
ITenantRepository <|-- ServicePlanRepository
ITenantRepository <|-- ConfigurationRepository
ITenantRepository <|-- CacheEntryRepository
ITenantRepository <|-- MetricRepository
ITenantRepository <|-- BackupPolicyRepository
ITenantRepository <|-- AccessControlRepository

class MemoryServiceInstanceRepository implements ServiceInstanceRepository
class FileServiceInstanceRepository implements ServiceInstanceRepository
class MongoServiceInstanceRepository implements ServiceInstanceRepository
@enduml
```

---

## 6. CLI MVC Pattern

```plantuml
@startuml CliMVC
class CliServiceInstanceModel {
    +instances : ServiceInstance[]
    +selectedInstance : ServiceInstance
    +errorMessage : string
    +load(tenantId : TenantId) : void
}

class CliServiceInstanceView {
    +renderList(model : CliServiceInstanceModel) : void
    +renderDetail(instance : ServiceInstance) : void
    +renderError(msg : string) : void
}

class CliServiceInstanceController {
    -model : CliServiceInstanceModel
    -view : CliServiceInstanceView
    -useCase : ManageServiceInstancesUseCase
    +handleList(args : string[]) : void
    +handleCreate(args : string[]) : void
    +handleGet(args : string[]) : void
    +handleDelete(args : string[]) : void
}

CliServiceInstanceController --> CliServiceInstanceModel
CliServiceInstanceController --> CliServiceInstanceView
CliServiceInstanceController --> ManageServiceInstancesUseCase
CliServiceInstanceView ..> CliServiceInstanceModel : reads
@enduml
```

---

## 7. Web MVC Pattern

```plantuml
@startuml WebMVC
class WebServiceInstanceModel {
    +instances : ServiceInstance[]
    +selectedInstance : ServiceInstance
    +errorMessage : string
    +pageTitle : string
}

class WebServiceInstanceView {
    +renderList(res : HTTPServerResponse, model : WebServiceInstanceModel) : void
    +renderDetail(res : HTTPServerResponse, instance : ServiceInstance) : void
    +renderError(res : HTTPServerResponse, code : int, msg : string) : void
}

class WebServiceInstanceController {
    -model : WebServiceInstanceModel
    -view : WebServiceInstanceView
    -useCase : ManageServiceInstancesUseCase
    +registerRoutes(router : URLRouter) : void
    +handleList(req, res) : void
    +handleDetail(req, res) : void
    +handleCreate(req, res) : void
    +handleDelete(req, res) : void
}

WebServiceInstanceController --> WebServiceInstanceModel
WebServiceInstanceController --> WebServiceInstanceView
WebServiceInstanceController --> ManageServiceInstancesUseCase
WebServiceInstanceView ..> WebServiceInstanceModel : renders
@enduml
```

---

## 8. Deployment Diagram

```plantuml
@startuml Deployment
node "Kubernetes Cluster" {
    node "Pod: uim-redis-platform-service" {
        artifact "uim-redis-platform-service\n(D binary)" as svc
    }
    node "Pod: MongoDB" {
        database "MongoDB\nredis_platform" as mongo
    }
    node "ConfigMap" as cfg
}
node "Client" {
    actor "App Developer" as dev
}

dev --> svc : HTTPS :8130
svc --> mongo : mongodb://mongo:27017
svc <-- cfg : REDIS_HOST, REDIS_PORT\nREDIS_PERSISTENCE=mongodb
@enduml
```
