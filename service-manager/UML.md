# UML — Service Manager

These diagrams describe the 2.0 implementation in `backend/source/uim/platform/service_manager/`.

## Component diagram (hexagonal architecture)

```mermaid
flowchart LR
  subgraph Clients
    Fiori[SAP Fiori 3 app]
    Scripts[Scripts / services]
    Admin[Operator shell]
    Desk[Desktop user]
    Broker[(OSB service broker)]
  end

  subgraph BTP[SAP BTP]
    AR[approuter + XSUAA]
  end

  subgraph Presentation[presentation — driving adapters]
    OD[ODataController\n/odata/v4/service-manager]
    REST[ServiceManagerRestController\n/api/v1/service-manager]
    CLI[CLI commands\nuim-service-manager-cli]
    GUI[GtkD entity browser\nuim-service-manager-gui]
    WEB[FrontendController /app]
    ENG{{ODataEngine\nEDM model + providers}}
  end

  subgraph Application
    UC[Use case interactors]
    SVC[OperationTracker · StatisticsService\nResourceDirectory · DemoData]
  end

  subgraph Domain
    ENT[Entities]
    POL[Lifecycle · ProvisioningPolicy\nCatalogReconciler · Validation]
  end

  subgraph Ports
    DP[driving: IManage* · ISyncBrokerCatalog\nIServiceManagerStatistics]
    RP[driven: I*Repository]
    GP[driven: IBrokerCatalogGateway]
  end

  subgraph Persistence
    REPO[DocumentRepository + mappers]
    STORE[(IDocumentStore\nmemory | JSON file)]
  end

  subgraph Infrastructure
    CFG[ServiceManagerConfig]
    SEC[SecuritySetup RS256/HS256]
    OSB[OsbCatalogClient]
    WRK[CatalogSyncWorker]
    CNT[ServiceManagerContainer]
  end

  Fiori --> AR --> OD
  Scripts --> REST
  Admin --> CLI
  Desk --> GUI
  OD --> ENG
  REST --> ENG
  CLI --> ENG
  GUI --> ENG
  ENG --> DP
  WRK --> DP
  DP -. implemented by .-> UC
  UC --> SVC
  UC --> POL
  UC --> ENT
  UC --> RP
  UC --> GP
  RP -. implemented by .-> REPO --> STORE
  GP -. implemented by .-> OSB --> Broker
  CNT --> UC
  CNT --> REPO
  CNT --> ENG
  OD --> SEC
  REST --> SEC
```

## Domain class diagram

```mermaid
classDiagram
  direction LR
  class TenantEntity {
    <<mixin>>
    +TenantId tenantId
    +Id id
    +UserId createdBy
    +long createdAt
    +UserId updatedBy
    +long updatedAt
    +isNull() bool
  }
  class Platform {
    +string name
    +string description
    +PlatformType type
    +PlatformStatus status
    +string region
    +SubaccountId subaccountId
    +string brokerUrl
    -string credentials
    +isActive() bool
    +validate()
  }
  class ServiceBroker {
    +string name
    +string description
    +string brokerUrl
    -string credentials
    +ServiceBrokerStatus status
    +long lastCatalogFetch
    +string catalogError
    +catalogFetched(at)
    +catalogFailed(error)
    +validate()
  }
  class ServiceOffering {
    +ServiceBrokerId brokerId
    +string name
    +string catalogId
    +ServiceOfferingStatus status
    +ServiceCategory category
    +bool bindable
    +bool planUpdateable
    +bool instancesRetrievable
    +bool bindingsRetrievable
    +string[] tags
    +string metadata
    +isAvailable() bool
  }
  class ServicePlan {
    +ServiceOfferingId offeringId
    +string name
    +string catalogId
    +ServicePlanPricing pricing
    +bool bindable
    +bool planUpdateable
    +int maxInstances
    +string schemas
    +free() bool
    +quotaExhausted(n) bool
  }
  class ServiceInstance {
    +string name
    +ServicePlanId planId
    +ServiceOfferingId offeringId
    +PlatformId platformId
    +ServiceInstanceStatus status
    +string parameters
    +string context
    +string dashboardUrl
    +bool shared_
    +bool usable
    +OperationId lastOperationId
    +transitionTo(status)
    +isReady() bool
  }
  class ServiceBinding {
    +string name
    +ServiceInstanceId instanceId
    +ServiceBindingStatus status
    +string credentials
    +string parameters
    +string bindResource
    +OperationId lastOperationId
    +transitionTo(status)
  }
  class Operation {
    +ResourceType resourceType
    +string resourceId
    +OperationType type
    +OperationStatus status
    +string description
    +string errorMessage
    +long startedAt
    +long completedAt
    +start(at)
    +succeed(at)
    +fail(error, at)
    +isFinal() bool
  }
  class Label {
    +ResourceType resourceType
    +string resourceId
    +string key
    +string value
    +validate()
  }

  TenantEntity <|.. Platform
  TenantEntity <|.. ServiceBroker
  TenantEntity <|.. ServiceOffering
  TenantEntity <|.. ServicePlan
  TenantEntity <|.. ServiceInstance
  TenantEntity <|.. ServiceBinding
  TenantEntity <|.. Operation
  TenantEntity <|.. Label

  ServiceBroker "1" o-- "*" ServiceOffering : advertises
  ServiceOffering "1" o-- "*" ServicePlan : tiers
  ServicePlan "1" <-- "*" ServiceInstance : provisioned from
  Platform "0..1" <-- "*" ServiceInstance : hosted on
  ServiceInstance "1" o-- "*" ServiceBinding : bound by
  ServiceInstance "1" <.. "*" Operation : tracks
  ServiceBinding "1" <.. "*" Operation : tracks
  Label "*" ..> "1" TenantEntity : annotates any resource
```

## Ports and application

```mermaid
classDiagram
  direction TB
  class IEntityRepository~E,Id~ {
    <<interface>>
    +findAll(tenant) E[]
    +findById(tenant, id) E
    +existsById(tenant, id) bool
    +countAll(tenant) size_t
    +save(E)
    +removeById(tenant, id) bool
  }
  class IServiceInstanceRepository {
    <<interface>>
    +findByName() +findByPlan() +findByOffering() +findByPlatform()
  }
  class IBrokerCatalogGateway {
    <<interface>>
    +fetchCatalog(broker) BrokerCatalog
  }
  class IManageServiceInstances {
    <<interface>>
    +listInstances() +getInstance()
    +provisionInstance(req) +updateInstance(req)
    +deprovisionInstance(tenant, id, actor)
  }
  class ISyncBrokerCatalog {
    <<interface>>
    +syncCatalog(tenant, brokerId, actor) CatalogSyncResult
    +syncAll(tenant, actor) CatalogSyncResult[]
  }
  class ManageServiceInstancesUseCase
  class SyncBrokerCatalogUseCase
  class OperationTracker {
    +ProvisioningMode mode
    +begin(...) Operation
    +finish(ref op)
  }
  class DocumentRepository~E,Id,toRecord,fromRecord~ {
    #IDocumentStore store
    #string collection
  }
  class ServiceInstanceRepository
  class OsbCatalogClient
  class ServiceManagerPorts {
    <<struct>>
    platforms brokers offerings plans
    instances bindings operations labels
    catalogSync statistics
  }

  IEntityRepository <|-- IServiceInstanceRepository
  DocumentRepository ..|> IEntityRepository
  ServiceInstanceRepository --|> DocumentRepository
  ServiceInstanceRepository ..|> IServiceInstanceRepository
  ManageServiceInstancesUseCase ..|> IManageServiceInstances
  ManageServiceInstancesUseCase --> IServiceInstanceRepository
  ManageServiceInstancesUseCase --> OperationTracker
  SyncBrokerCatalogUseCase ..|> ISyncBrokerCatalog
  SyncBrokerCatalogUseCase --> IBrokerCatalogGateway
  OsbCatalogClient ..|> IBrokerCatalogGateway
  ServiceManagerPorts --> IManageServiceInstances
  ServiceManagerPorts --> ISyncBrokerCatalog
```

## State machines

### Service instance

```mermaid
stateDiagram-v2
  [*] --> creating : provision
  creating --> created : create op succeeded
  creating --> failed : create op failed
  creating --> deleting : deprovision
  created --> updating : plan / parameters changed
  updating --> created : update op succeeded
  updating --> failed : update op failed
  created --> deleting : deprovision
  created --> orphaned
  orphaned --> deleting
  failed --> updating : retry update
  failed --> deleting : deprovision
  deleting --> failed : delete op failed
  deleting --> [*] : delete op succeeded (removed)
```

### Service binding

```mermaid
stateDiagram-v2
  [*] --> creating : bind
  creating --> created : bind op succeeded
  creating --> failed : bind op failed
  creating --> deleting
  created --> deleting : unbind
  failed --> deleting
  deleting --> failed : unbind op failed
  deleting --> [*] : unbind op succeeded (removed)
```

### Operation

```mermaid
stateDiagram-v2
  [*] --> pending
  pending --> inProgress : start
  pending --> succeeded
  pending --> failed
  inProgress --> succeeded : CompleteOperation(succeeded=true) / sync mode
  inProgress --> failed : CompleteOperation(succeeded=false)
  succeeded --> [*]
  failed --> [*]
```

In **synchronous** mode (`syncProvisioning: true`, the default), the operation finishes within the
request and the resource reaches `created` or is removed immediately. In **asynchronous** mode, the
resource stays in its transitional state until `CompleteOperation` is called.

## Sequence: provision a service instance (OData, asynchronous mode)

```mermaid
sequenceDiagram
  autonumber
  participant UI as Fiori app
  participant AR as approuter
  participant OD as ODataController
  participant EN as ODataEngine
  participant UC as ManageServiceInstancesUseCase
  participant PP as ProvisioningPolicy
  participant OT as OperationTracker
  participant RP as Repositories / IDocumentStore

  UI->>AR: POST $batch { POST ServiceInstances {name, planId, platformId} }
  AR->>OD: forward + JWT
  OD->>OD: resolve RequestContext (tenant, user, scopes)
  OD->>EN: create("ServiceInstances", payload)
  EN->>EN: check scope Write · validate payload against EDM
  EN->>UC: provisionInstance(request)
  UC->>RP: plan, offering, broker, platform, instances of plan
  UC->>PP: checkProvisionable(broker, offering, plan, count, platform)
  UC->>OT: begin(create) → Operation inProgress
  UC->>RP: save Operation, save ServiceInstance(status=creating)
  UC-->>UI: 201 row {status: creating, lastOperationId}
  Note over UI,RP: later — broker callback or operator
  UI->>OD: POST CompleteOperation {operationId, succeeded:true}
  OD->>EN: invoke → ManageOperationsUseCase.completeOperation
  EN->>RP: Operation succeeded · ServiceInstance creating → created
```

## Sequence: catalog sync

```mermaid
sequenceDiagram
  autonumber
  participant C as CLI / REST / OData / CatalogSyncWorker
  participant UC as SyncBrokerCatalogUseCase
  participant GW as OsbCatalogClient
  participant B as Service broker
  participant RC as reconcileCatalog()
  participant RP as Repositories

  C->>UC: syncCatalog(tenant, brokerId, actor)
  UC->>RP: broker (must not be inactive)
  UC->>GW: fetchCatalog(broker)
  GW->>B: GET /v2/catalog (X-Broker-API-Version, Basic auth)
  alt broker fails
    B-->>GW: error / non-200 / invalid JSON
    GW-->>UC: ServiceManagerException(gateway)
    UC->>RP: broker.catalogFailed(msg) → registrationFailed if never synced
    UC-->>C: 502 BadGateway
  else catalog
    B-->>GW: {services:[...plans]}
    UC->>RP: offerings + plans of the broker
    UC->>RC: match by catalogId → create / update / retire (removed)
    UC->>RP: save offerings, plans; broker.catalogFetched(now)
    UC-->>C: CatalogSyncResult (+created ~updated −removed)
  end
```

## Deployment diagram

```mermaid
flowchart TB
  subgraph CF[SAP BTP Cloud Foundry space]
    AR[service-manager-approuter\nnode.js @sap/approuter\nresources/ = Fiori app]
    SRV[service-manager-srv\nbinary_buildpack\nuim-service-manager-platform-service :PORT]
    UAA[(XSUAA\nservice-manager-xsuaa)]
  end
  User((Browser)) -->|HTTPS| AR
  AR -->|destination service-manager-srv\n+ forwarded JWT| SRV
  AR --- UAA
  SRV ---|verificationkey RS256| UAA
  SRV -->|OSB HTTPS| Brokers[(Service brokers)]

  subgraph K8S[Kubernetes namespace uim-platform]
    DEP[Deployment service-manager\nimage uim-platform/service-manager]
    PVC[(PVC service-manager-data /data)]
    SVC[Service ClusterIP :8113]
    CM[ConfigMap service-manager-config]
  end
  SVC --> DEP --> PVC
  CM --> DEP
```
