# UML — Kyma Runtime Service

Diagrams of the hexagonal backend (`backend/source/uim/platform/kyma`), the Fiori
frontend and the BTP deployment. All diagrams are Mermaid.

## Class Diagram — Domain Entities

All aggregates mix in `TenantEntity` (`tenantId`, `id`, `createdBy/At`, `updatedBy/At`).

```mermaid
classDiagram
    class KymaEnvironment {
        +KymaEnvironmentId id
        +SubaccountId subaccountId
        +ClusterId clusterId
        +string name
        +KymaPlan plan
        +string region
        +string kubernetesVersion
        +EnvironmentStatus status
        +string machineType
        +int autoScalerMin
        +int autoScalerMax
        +string oidcIssuerUrl
        +string shootDomain
        +string kubeApiServerUrl
        +string[] administrators
        +long expiresAt
        +isOperational() bool
        +isExpired(now) bool
    }
    class KymaNamespace {
        +NamespaceId id
        +KymaEnvironmentId environmentId
        +string name
        +NamespaceStatus status
        +string cpuRequest / cpuLimit
        +string memoryRequest / memoryLimit
        +int podLimit
        +QuotaEnforcement quotaEnforcement
        +bool istioInjection
        +KeyValue[] labels
        +KeyValue[] annotations
    }
    class ServerlessFunction {
        +ServerlessFunctionId id
        +NamespaceId namespaceId
        +string namespaceName
        +string name
        +FunctionRuntime runtime
        +FunctionStatus status
        +string sourceCode
        +string handler
        +string dependencies
        +ScalingType scalingType
        +int minReplicas / maxReplicas
        +KeyValue[] envVars
        +int timeoutSeconds
        +internalUrl() string
    }
    class ApiRule {
        +ApiRuleId id
        +NamespaceId namespaceId
        +string name
        +ApiRuleStatus status
        +string serviceName
        +int servicePort
        +string gateway
        +string host
        +ApiRuleEntry[] rules
        +bool corsEnabled
        +url() string
    }
    class ApiRuleEntry {
        <<value>>
        +string path
        +ApiHttpMethod[] methods
        +AccessStrategy accessStrategy
        +string[] requiredScopes
        +string[] audiences
        +string[] trustedIssuers
    }
    class ServiceInstance {
        +ServiceInstanceId id
        +NamespaceId namespaceId
        +string name
        +ServiceInstanceStatus status
        +string serviceOfferingName
        +string servicePlanName
        +string parametersJson
        +int bindingCount
    }
    class ServiceBinding {
        +ServiceBindingId id
        +ServiceInstanceId serviceInstanceId
        +string name
        +ServiceBindingStatus status
        +string secretName
        +string[] credentialKeys
    }
    class EventSubscription {
        +EventSubscriptionId id
        +NamespaceId namespaceId
        +string name
        +SubscriptionStatus status
        +string source
        +string[] eventTypes
        +EventTypeEncoding typeEncoding
        +string sinkUrl
        +int maxInFlightMessages
        +KeyValue[] filterAttributes
    }
    class KymaModule {
        +KymaModuleId id
        +KymaEnvironmentId environmentId
        +ModuleType moduleType
        +string name
        +ModuleStatus status
        +string version
        +ModuleChannel channel
        +string customResourcePolicy
        +string[] requiredModules
    }
    class KymaApplication {
        +ApplicationId id
        +KymaEnvironmentId environmentId
        +string name
        +AppConnectivityStatus status
        +AppRegistrationType registrationType
        +string connectorUrl
        +AppApiEntry[] apis
        +AppEventEntry[] events
        +string[] boundNamespaces
    }

    KymaEnvironment "1" *-- "0..*" KymaNamespace : contains
    KymaEnvironment "1" *-- "3..*" KymaModule : enables
    KymaEnvironment "1" *-- "0..*" KymaApplication : connects
    KymaNamespace "1" *-- "0..*" ServerlessFunction : runs
    KymaNamespace "1" *-- "0..*" ApiRule : exposes
    KymaNamespace "1" *-- "0..*" ServiceInstance : hosts
    KymaNamespace "1" *-- "0..*" EventSubscription : subscribes
    ServiceInstance "1" *-- "0..*" ServiceBinding : binds
    ApiRule "1" *-- "1..*" ApiRuleEntry
    KymaApplication ..> KymaNamespace : bound to (by name)
    KymaModule ..> KymaModule : requires
```

`*--` marks cascading deletion: deleting an environment or namespace removes everything inside it.
A service instance with bindings cannot be deleted.

## State Diagram — Lifecycles driven by the reconciler

```mermaid
stateDiagram-v2
    state "KymaEnvironment" as Env {
        [*] --> provisioning : create
        provisioning --> running : reconcile
        running --> updating : update
        updating --> running : reconcile
        running --> stopping : stop
        stopping --> stopped : reconcile
        stopped --> updating : start
    }
    state "ServerlessFunction" as Fn {
        [*] --> building : create / update
        building --> deploying : reconcile
        deploying --> running : reconcile
    }
    state "KymaModule" as Mod {
        [*] --> installing : enable
        installing --> enabled : reconcile
        enabled --> uninstalling : disable
        uninstalling --> disabled : reconcile
        disabled --> installing : enable
    }
    state "EventSubscription" as Sub {
        [*] --> pending : create / update
        pending --> active : reconcile
        active --> paused : pause
        pending --> paused : pause
        paused --> pending : resume
    }
```

Further transitions: API rule `notReady → ok`, service instance `creating/updating → ready`,
service binding `creating → ready` once its instance is ready, application
`disconnected → pairing (connect) → connected`. Workloads only progress on an operational
runtime; expired trial/free runtimes are deleted by the reconciler.

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
    subgraph Driving["Driving adapters (presentation)"]
        REST["http · KymaRestController<br/>/api/v1"]
        OD["odata · KymaODataController<br/>/odata/v4/kyma + $metadata"]
        CLI["cli · KymaCli"]
        GUI["gui · KymaWindow (GtkD)"]
        WEB["web · FrontendController<br/>Fiori app (local dev)"]
        REG["resources · ResourceRegistry<br/>9 × ResourceAdapter"]
    end
    subgraph Core["Application core"]
        PORTS["ports · KymaPorts<br/>IManageResource&lt;…&gt; × 9<br/>IReconcileUseCase · IKymaStatisticsService"]
        UC["application · ResourceUseCase&lt;…&gt; × 9<br/>ReconcileUseCase · KymaStatisticsService<br/>CascadeDeleter"]
        DOM["domain · entities · validators<br/>environment policy · module catalogue<br/>lifecycle · manifests"]
    end
    subgraph Driven["Driven adapters"]
        REPO["persistence · 9 repositories<br/>RecordMapper&lt;T&gt;"]
        STORE["storages · SnapshotTenantStore<br/>JsonFileSnapshotStorage"]
        GW["clients · RecordingClusterGateway<br/>(IClusterGateway)"]
        PUB["logging · LogEventPublisher<br/>(IKymaEventPublisher)"]
    end
    INFRA["infrastructure · KymaConfig · identity · ReconcileWorker · Container"]

    REST --> REG
    OD --> REG
    CLI --> REG
    GUI --> REG
    REG --> PORTS
    PORTS --> UC
    UC --> DOM
    UC --> REPO
    UC --> GW
    UC --> PUB
    REPO --> STORE
    STORE --> FILES[("data/*.json")]
    INFRA -. wires .-> UC
    INFRA -. wires .-> REPO
    INFRA -. runs .-> PORTS
```

Dependencies point inwards: presentation knows only `KymaPorts`; use cases know only
port interfaces (`KymaRepositories`, `IClusterGateway`, `IKymaEventPublisher`).

## Class Diagram — Generic use cases and adapters

```mermaid
classDiagram
    class IManageResource~TEntity,TId,TCreate,TUpdate~ {
        <<interface>>
        +create(TCreate) UsecaseResult
        +update(TUpdate) UsecaseResult
        +remove(TenantId, TId, UserId) UsecaseResult
        +get(TenantId, TId) TEntity
        +list(TenantId) TEntity[]
        +manifest(TenantId, TId) Json
    }
    class ResourceUseCase~TEntity,TId,TCreate,TUpdate~ {
        <<abstract>>
        #build(TCreate) TEntity
        #apply(ref TEntity, TSpec)
        #render(TEntity) Json
        #beforeRemove(TEntity)
        #transition(…) UsecaseResult
        #requireModule(tenant, env, WorkloadKind)
        #synchronize(TEntity, verb)
    }
    class ManageFunctionsUseCase
    class ManageEventSubscriptionsUseCase {
        +pause() UsecaseResult
        +resume() UsecaseResult
    }
    class ManageModulesUseCase {
        +enable() UsecaseResult
        +disable() UsecaseResult
    }
    class IResourceAdapter {
        <<interface>>
        +path() / setName() / typeName()
        +fields() FieldInfo[]
        +inputFields() FieldInfo[]
        +columns() / actions()
        +list(tenant, filters) Json[]
        +get / create / update / remove / invoke / manifest
    }
    class ResourceAdapter~TEntity,TId,TCreate,TUpdate~ {
        -Port port
        +column(header, field)
        +action(name, label, handler)
    }
    class ResourceRegistry {
        +adapters() IResourceAdapter[]
        +byPath() / bySet() / byODataAction()
        +resolve(adapter, tenant, idOrName)
        +statistics() / reconcile()
    }

    IManageResource <|.. ResourceUseCase
    ResourceUseCase <|-- ManageFunctionsUseCase
    ResourceUseCase <|-- ManageEventSubscriptionsUseCase
    ResourceUseCase <|-- ManageModulesUseCase
    IResourceAdapter <|.. ResourceAdapter
    ResourceAdapter --> IManageResource : port
    ResourceRegistry o-- "9" IResourceAdapter
```

Payloads, records, `$metadata`, CLI tables and GUI forms are derived from the D structs by
`helpers/codec` (`encode`, `decode(json, base)`, `describe!T`, `assignMatching`).

## Sequence Diagram — Fiori creates a function

```mermaid
sequenceDiagram
    actor Dev as Developer
    participant UI as Fiori app (OData V4 model)
    participant AR as Approuter (XSUAA)
    participant OD as KymaODataController
    participant AD as ResourceAdapter (functions)
    participant UC as ManageFunctionsUseCase
    participant DOM as FunctionValidator / module catalogue
    participant REPO as FunctionRepository
    participant GW as IClusterGateway

    Dev->>UI: Create function (dialog)
    UI->>AR: POST /odata/v4/kyma/Functions {namespaceId, name, sourceCode}
    AR->>OD: forward + JWT
    OD->>OD: resolveIdentity(JWT / X-Tenant-Id)
    OD->>AD: create(identity, body)
    AD->>AD: decode!FunctionSpec(body)
    AD->>UC: create(CreateFunctionRequest)
    UC->>UC: requireNamespace, requireModule(serverless)
    UC->>DOM: validate(function)
    alt rule violated
        DOM-->>UC: KymaValidationException
        UC-->>AD: UsecaseResult(code 422)
        AD-->>OD: ResourceError 422
        OD-->>UI: {"error": {"code": "BusinessRuleViolation"}}
    else ok
        UC->>REPO: save (status building)
        UC->>GW: apply(Function CR)
        UC-->>AD: UsecaseResult(id)
        AD-->>OD: payload
        OD-->>UI: 201 Function
    end
```

## Sequence Diagram — Reconciliation

```mermaid
sequenceDiagram
    participant W as ReconcileWorker (timer) / CLI "reconcile" / OData "Reconcile"
    participant UC as ReconcileUseCase
    participant L as lifecycle.advance()
    participant R as repositories

    W->>UC: reconcile(tenant)
    loop every environment
        alt expired trial / free
            UC->>R: CascadeDeleter.clearEnvironment + remove
        else
            UC->>L: advance(environment)
            UC->>R: update if changed
            opt environment operational
                UC->>L: advance(modules, functions, API rules, instances)
                UC->>L: advance(bindings, using the instance status)
                UC->>L: advance(subscriptions, applications)
                UC->>R: update changed resources
            end
        end
    end
    UC-->>W: ReconcileReport(examined, advanced, changes)
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
    actor Admin
    participant CLI as uim-kyma-cli
    participant FS as data/*.json
    participant SRV as server (SnapshotTenantStore)

    Admin->>CLI: functions create --namespaceId=shop --name=hello --sourceCode=@h.js
    CLI->>FS: write functions.json.tmp → rename
    SRV->>FS: revision changed? (mtime)
    SRV->>FS: reload functions.json
    SRV-->>SRV: next request / reconcile sees "hello"
```

## Deployment Diagram — SAP BTP (Cloud Foundry)

```mermaid
flowchart LR
    U[Browser] -->|HTTPS| AR["kyma-approuter<br/>@sap/approuter + Fiori app (resources/)"]
    AR -->|login| X[(XSUAA kyma-xsuaa<br/>KymaViewer · KymaDeveloper · KymaAdmin)]
    AR -->|"destination kyma-srv<br/>/odata/v4/kyma · /api/v1 + JWT"| S["kyma-srv<br/>binary_buildpack<br/>uim-kyma-platform-service"]
    S --> D[("data/*.json<br/>container disk")]
    C[(user-provided kyma-config)] -. VCAP_SERVICES .-> S
    A[Admin workstation] -->|uim-kyma-cli · uim-kyma-gui| L[("local data/*.json")]
```
