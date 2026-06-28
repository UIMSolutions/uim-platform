# UML — Solution Lifecycle Management Service

## 1. Domain Class Diagram

```mermaid
classDiagram
    class MtaArchive {
        +MtaArchiveId id
        +TenantId tenantId
        +string fileName
        +string mtaId
        +string mtaVersion
        +long fileSizeBytes
        +string checksum
        +string uploadedBy
        +string namespace_
        +string[] targetPlatforms
        +bool validated
        +toJson() Json
    }

    class Mta {
        +MtaId id
        +TenantId tenantId
        +string mtaId
        +string version_
        +string description
        +SolutionType solutionType
        +MtaStatus status
        +string archiveId
        +string deployedBy
        +string spaceId
        +string extensionDescriptor
        +MtaModule[] modules
        +string lastOperationId
        +toJson() Json
    }

    class MtaModule {
        +string name
        +ModuleType moduleType
        +ModuleState state
        +string[] urls
    }

    class MtaOperation {
        +MtaOperationId id
        +TenantId tenantId
        +OperationType operationType
        +OperationStatus operationStatus
        +string mtaId
        +string archiveId
        +string initiatedBy
        +string errorMessage
        +int progressPercent
        +string[] logLines
        +long startedAt
        +long finishedAt
        +toJson() Json
    }

    class MtaSubscription {
        +MtaSubscriptionId id
        +TenantId tenantId
        +string mtaId
        +string mtaVersion
        +string providerTenantId
        +SubscriptionStatus subscriptionStatus
        +string subscribedBy
        +string extensionDescriptor
        +string lastOperationId
        +toJson() Json
    }

    Mta "1" *-- "0..*" MtaModule : contains
    MtaArchive ..> Mta : source for deployment
    Mta ..> MtaOperation : tracked by
    MtaSubscription ..> MtaOperation : tracked by
```

## 2. Hexagonal Architecture

```mermaid
classDiagram
    direction TB

    class MtaArchiveRepository {
        <<interface>>
        +find(tenantId) MtaArchive[]
        +save(archive)
        +remove(id)
    }
    class MtaRepository {
        <<interface>>
        +find(tenantId) Mta[]
        +save(mta)
        +update(mta)
    }
    class MtaOperationRepository {
        <<interface>>
        +find(tenantId) MtaOperation[]
        +save(op)
        +update(op)
    }
    class MtaSubscriptionRepository {
        <<interface>>
        +find(tenantId) MtaSubscription[]
        +save(sub)
        +update(sub)
    }

    class DeploymentEngine {
        +validateArchive(mtaId, version, platforms) string
        +beginDeploy(archiveId, mtaId, version, tenant) DeploymentResult
        +beginUpdate(archiveId, existingMtaId, tenant) DeploymentResult
        +beginDelete(mtaId, tenant) DeploymentResult
        +beginSubscribe(providerMtaId, providerTenant, subscriberTenant) DeploymentResult
        +beginUnsubscribe(subscriptionId, tenant) DeploymentResult
        +advanceOperation(current, percent) OperationStatus
    }

    class ManageMtaArchivesUseCase {
        +uploadArchive(r) CommandResult
        +listArchives(tenantId) MtaArchive[]
        +getArchive(tenantId, id) MtaArchive
        +deleteArchive(tenantId, id) CommandResult
    }
    class ManageMtasUseCase {
        +deployMta(r) CommandResult
        +updateMta(r) CommandResult
        +listMtas(tenantId) Mta[]
        +getMta(tenantId, id) Mta
        +deleteMta(r) CommandResult
    }
    class ManageMtaOperationsUseCase {
        +listOperations(tenantId) MtaOperation[]
        +getOperation(tenantId, id) MtaOperation
        +pollOperation(tenantId, id) CommandResult
        +abortOperation(r) CommandResult
        +getOperationLogs(tenantId, id) string[]
    }
    class ManageMtaSubscriptionsUseCase {
        +listSubscriptions(tenantId) MtaSubscription[]
        +getSubscription(tenantId, id) MtaSubscription
        +subscribe(r) CommandResult
        +unsubscribe(r) CommandResult
    }

    class MtaArchiveController {
        +registerRoutes(router)
        +handleUpload()
        +handleList()
        +handleGet()
        +handleDelete()
    }
    class MtaController {
        +registerRoutes(router)
        +handleDeploy()
        +handleList()
        +handleGet()
        +handleUpdate()
        +handleDelete()
    }
    class MtaOperationController {
        +registerRoutes(router)
        +handleList()
        +handleGet()
        +handlePoll()
        +handleAbort()
        +handleLogs()
    }
    class MtaSubscriptionController {
        +registerRoutes(router)
        +handleList()
        +handleGet()
        +handleSubscribe()
        +handleUnsubscribe()
    }

    MtaArchiveController --> ManageMtaArchivesUseCase
    MtaController --> ManageMtasUseCase
    MtaOperationController --> ManageMtaOperationsUseCase
    MtaSubscriptionController --> ManageMtaSubscriptionsUseCase

    ManageMtaArchivesUseCase --> MtaArchiveRepository
    ManageMtaArchivesUseCase --> DeploymentEngine
    ManageMtasUseCase --> MtaRepository
    ManageMtasUseCase --> MtaOperationRepository
    ManageMtasUseCase --> MtaArchiveRepository
    ManageMtasUseCase --> DeploymentEngine
    ManageMtaOperationsUseCase --> MtaOperationRepository
    ManageMtaOperationsUseCase --> DeploymentEngine
    ManageMtaSubscriptionsUseCase --> MtaSubscriptionRepository
    ManageMtaSubscriptionsUseCase --> MtaOperationRepository
    ManageMtaSubscriptionsUseCase --> DeploymentEngine
```

## 3. Sequence Diagram — Deploy MTA

```mermaid
sequenceDiagram
    participant Client
    participant MtaController
    participant ManageMtasUseCase
    participant MtaArchiveRepository
    participant DeploymentEngine
    participant MtaOperationRepository
    participant MtaRepository

    Client->>MtaController: POST /api/v1/slm/mtas {archiveId, solutionType, ...}
    MtaController->>ManageMtasUseCase: deployMta(DeployMtaRequest)
    ManageMtasUseCase->>MtaArchiveRepository: find(tenantId)
    MtaArchiveRepository-->>ManageMtasUseCase: MtaArchive[]
    ManageMtasUseCase->>DeploymentEngine: beginDeploy(archiveId, mtaId, version, tenantId)
    DeploymentEngine-->>ManageMtasUseCase: DeploymentResult{success, operationId}
    ManageMtasUseCase->>MtaOperationRepository: save(MtaOperation{queued})
    ManageMtasUseCase->>MtaRepository: save(Mta{deploying})
    ManageMtasUseCase-->>MtaController: CommandResult{success, operationId}
    MtaController-->>Client: 202 Accepted {operationId}

    Note over Client,MtaOperationRepository: Client polls operation until finished
    Client->>MtaOperationController: POST /api/v1/slm/operations/{id}/poll
    MtaOperationController->>ManageMtaOperationsUseCase: pollOperation(tenantId, id)
    ManageMtaOperationsUseCase->>DeploymentEngine: advanceOperation(queued, 0%)
    DeploymentEngine-->>ManageMtaOperationsUseCase: running, 25%
    ManageMtaOperationsUseCase->>MtaOperationRepository: update(running, 25%)
    MtaOperationController-->>Client: 200 OK {status: running, progressPercent: 25}
```

## 4. Sequence Diagram — Subscribe to Provided Solution

```mermaid
sequenceDiagram
    participant Subscriber
    participant MtaSubscriptionController
    participant ManageMtaSubscriptionsUseCase
    participant DeploymentEngine
    participant MtaOperationRepository
    participant MtaSubscriptionRepository

    Subscriber->>MtaSubscriptionController: POST /api/v1/slm/subscriptions {providerMtaId, ...}
    MtaSubscriptionController->>ManageMtaSubscriptionsUseCase: subscribe(SubscribeMtaRequest)
    ManageMtaSubscriptionsUseCase->>DeploymentEngine: beginSubscribe(providerMtaId, providerTenant, subscriberTenant)
    DeploymentEngine-->>ManageMtaSubscriptionsUseCase: DeploymentResult{success, operationId}
    ManageMtaSubscriptionsUseCase->>MtaOperationRepository: save(MtaOperation{subscribe, queued})
    ManageMtaSubscriptionsUseCase->>MtaSubscriptionRepository: save(MtaSubscription{subscribing})
    ManageMtaSubscriptionsUseCase-->>MtaSubscriptionController: CommandResult{success, operationId}
    MtaSubscriptionController-->>Subscriber: 202 Accepted {operationId}
```

## 5. State Diagram — MTA Operation Lifecycle

```mermaid
stateDiagram-v2
    [*] --> queued : operation created
    queued --> running : first poll
    running --> running : poll (progress < 100%)
    running --> finished : poll (progress = 100%)
    running --> failed : error during execution
    queued --> aborted : abort request
    running --> aborted : abort request
    finished --> [*]
    failed --> [*]
    aborted --> [*]
```

## 6. State Diagram — MTA Solution Status

```mermaid
stateDiagram-v2
    [*] --> deploying : deployMta()
    deploying --> deployed : operation finished
    deploying --> failed : operation failed
    deployed --> updating : updateMta()
    updating --> deployed : operation finished
    updating --> failed : operation failed
    deployed --> deleting : deleteMta()
    deleting --> deleted : operation finished
    failed --> deploying : retry deploy
    deleted --> [*]
```

## 7. Component Deployment Diagram

```mermaid
C4Container
    title Solution Lifecycle Management Service — Component Deployment

    Container_Boundary(slm, "solution-lifecycle container") {
        Component(api, "HTTP API (vibe.d)", "D/vibe.d", "Handles REST requests on port 8097")
        Component(domain, "Domain Layer", "D structs/classes", "MtaArchive, Mta, MtaOperation, MtaSubscription entities")
        Component(usecases, "Use Cases", "D classes", "ManageMtaArchives, ManageMtas, ManageMtaOperations, ManageMtaSubscriptions")
        Component(engine, "DeploymentEngine", "D class", "Domain service: validate, deploy, subscribe, advance operations")
        Component(repos, "Memory Repositories", "D classes", "In-memory storage implementing repository ports")

        Rel(api, usecases, "calls")
        Rel(usecases, engine, "uses")
        Rel(usecases, repos, "reads/writes")
    }

    Person(developer, "Developer / CI pipeline", "Deploys MTA solutions")
    System_Ext(mta_registry, "MTA Archive Storage", "Real: Object Store / Nexus")
    System_Ext(cf_api, "CF Deploy API", "Real: Cloud Foundry or BTP CF Deploy service")

    Rel(developer, api, "HTTP REST", "port 8097")
    Rel(engine, cf_api, "would call", "in production")
    Rel(api, mta_registry, "would stream archive to", "in production")
```
