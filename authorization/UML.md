# UML — Authorization Management Service

Diagrams of the D/vibe.d backend (hexagonal architecture), the SAP Fiori frontend and the deployment.
Module root: `backend/source/uim/platform/authorization/`.

## 1. Component diagram (hexagonal architecture)

```mermaid
flowchart LR
  subgraph Clients
    Fiori[SAP Fiori 3 app<br/>frontend/]
    Apps[Business applications]
    Admin[Administrators]
  end

  subgraph Presentation["presentation (driving adapters)"]
    OData[odata<br/>ODataController + engine binding]
    Http[http<br/>JSON API /api/v1 · health]
    Rest[rest<br/>vibe.d REST /rest/v1/authorization]
    Web[web<br/>Diet dashboard /web · Fiori /app]
    Cli[cli<br/>uim-authorization-cli]
    Gui[gui<br/>GtkD entity browser]
  end

  Engine[[ODataEngine<br/>one EDM model:<br/>validation · scopes · $query]]

  subgraph Application
    UC[usecases<br/>ManageApplications · ManageApplicationApis<br/>ManagePolicies · ManageAssignments<br/>EvaluateAuthorization · QueryDecisions]
    Svc[services<br/>StatisticsService · DemoDataService]
  end

  subgraph Domain
    Ent[entities<br/>ManagedApplication · ApplicationApi<br/>AuthorizationPolicy · PolicyAssignment · DecisionRecord]
    Eval[services<br/>PolicyEvaluator · base policy templates]
  end

  subgraph Ports
    PIn[usecases / services<br/>AuthorizationPorts]
    POut[repositories · storages · messaging]
  end

  subgraph Persistence
    Repo[repositories<br/>DocumentRepository + 5 repos]
    Map[mappers / records]
    Store[(storages<br/>memory · JSON file · MongoDB)]
  end

  subgraph Infrastructure
    Cfg[configuration]
    Sec[security<br/>XSUAA RS256 / HS256]
    Log[logging<br/>LogDecisionPublisher]
    Wrk[workers<br/>DecisionRetentionWorker]
    Ctr[container]
  end

  Fiori --> OData
  Apps --> Rest & Http & OData
  Admin --> Cli & Gui & Web
  OData & Http & Rest & Web & Cli & Gui --> Engine
  Http & Rest --> PIn
  Engine --> PIn
  PIn --> UC & Svc
  UC --> Ent & Eval
  UC --> POut
  POut --> Repo --> Map --> Store
  UC -. publish .-> Log
  Wrk --> PIn
  Ctr -. wires .-> Engine & UC & Repo
  Sec -. RequestContext .-> Http & Rest & OData & Web
```

## 2. Domain class diagram

```mermaid
classDiagram
  class ManagedApplication {
    +ManagedApplicationId id
    +TenantId tenantId
    +string name
    +string organizationId
    +string description
    +validate()
  }
  class ApplicationApi {
    +ApplicationApiId id
    +ManagedApplicationId applicationId
    +string name
    +string endpoint
    +string[] operations
    +validate()
  }
  class AuthorizationPolicy {
    +PolicyId id
    +ManagedApplicationId applicationId
    +string name
    +string description
    +string resource
    +string action
    +PolicyCondition[] conditions
    +PolicyKind kind
    +PolicyStatus status
    +isBase() bool
    +isActive() bool
    +enable()
    +disable()
    +validate()
  }
  class PolicyCondition {
    <<value object>>
    +string attribute
    +ConditionOperator operator
    +string value
    +toText() string
  }
  class PolicyAssignment {
    +PolicyAssignmentId id
    +PolicyId policyId
    +PrincipalType principalType
    +string principalId
    +long validFrom
    +long validTo
    +isEffective(at) bool
    +appliesTo(user, groups) bool
    +validate()
  }
  class DecisionRecord {
    +DecisionRecordId id
    +string principalId
    +string[] groups
    +ManagedApplicationId applicationId
    +string resource
    +string action
    +string attributes
    +bool allowed
    +string reason
    +string[] matchedPolicyIds
    +string channel
  }
  class PolicyEvaluator {
    <<domain service>>
    +resourceMatches(policy, requested) bool
    +actionMatches(policy, requested) bool
    +conditionMatches(condition, attributes) bool
    +decide(AccessRequest, policies, assignments) AccessDecision
  }
  class PolicyKind { <<enumeration>> base custom }
  class PolicyStatus { <<enumeration>> active disabled }
  class PrincipalType { <<enumeration>> user group }
  class ConditionOperator { <<enumeration>> eq ne contains startsWith endsWith in notIn lt le gt ge exists }

  ManagedApplication "1" *-- "*" ApplicationApi
  ManagedApplication "1" *-- "*" AuthorizationPolicy
  AuthorizationPolicy "1" *-- "*" PolicyCondition
  AuthorizationPolicy "1" o-- "*" PolicyAssignment
  ManagedApplication "1" <.. "*" DecisionRecord
  PolicyEvaluator ..> AuthorizationPolicy
  PolicyEvaluator ..> PolicyAssignment
  AuthorizationPolicy --> PolicyKind
  AuthorizationPolicy --> PolicyStatus
  PolicyAssignment --> PrincipalType
  PolicyCondition --> ConditionOperator
```

All entities mix in `TenantEntity` (`id`, `tenantId`, `createdAt/By`, `updatedAt/By`) from `uim-platform:service`.

## 3. Ports and adapters (class diagram)

```mermaid
classDiagram
  class AuthorizationPorts {
    <<driving ports>>
    IManageApplications applications
    IManageApplicationApis apis
    IManagePolicies policies
    IManageAssignments assignments
    IEvaluateAuthorization evaluation
    IQueryDecisions decisions
    IAuthorizationStatistics statistics
    IDemoDataService demoData
  }
  class IEntityRepository~TEntity,TId~ {
    <<driven port>>
    findAll(tenant) TEntity[]
    findById(tenant, id) TEntity
    countAll(tenant) size_t
    save(entity)
    removeById(tenant, id) bool
  }
  class IDocumentStore {
    <<driven port>>
    all(collection, tenant) Json[]
    get(collection, tenant, key) Json
    put(collection, tenant, key, doc)
    remove(collection, tenant, key) bool
    count(collection, tenant) size_t
  }
  class IDecisionPublisher { <<driven port>> publish(decision) }
  class DocumentRepository~TEntity,TId~
  class MemoryDocumentStore
  class FileDocumentStore
  class MongoDocumentStore
  class LogDecisionPublisher
  class EvaluateAuthorizationUseCase
  class AuthorizationContainer {
    config
    store
    ports
    engine
    bootstrap()
  }

  IEntityRepository <|.. DocumentRepository
  DocumentRepository --> IDocumentStore
  IDocumentStore <|.. MemoryDocumentStore
  IDocumentStore <|.. FileDocumentStore
  IDocumentStore <|.. MongoDocumentStore
  IDecisionPublisher <|.. LogDecisionPublisher
  EvaluateAuthorizationUseCase --> IDecisionPublisher
  AuthorizationContainer --> AuthorizationPorts
  AuthorizationContainer --> IDocumentStore
```

Repositories: `ApplicationRepository`, `ApplicationApiRepository`, `PolicyRepository`, `AssignmentRepository`,
`DecisionRepository` (collections `ams.applications`, `ams.applicationApis`, `ams.policies`, `ams.assignments`, `ams.decisions`).

## 4. Sequence — runtime authorization check

```mermaid
sequenceDiagram
  autonumber
  participant App as Application / Fiori
  participant AR as Approuter (XSUAA)
  participant OD as ODataController / REST
  participant EN as ODataEngine
  participant UC as EvaluateAuthorizationUseCase
  participant PE as PolicyEvaluator
  participant RP as Repositories
  participant PB as IDecisionPublisher

  App->>AR: POST /odata/v4/authorization/EvaluateAuthorization
  AR->>OD: forward + JWT
  OD->>OD: resolveRequestContext (tenant zid, scopes)
  OD->>EN: invoke(ctx, "EvaluateAuthorization", params)
  EN->>EN: check scope "Check", validate parameters
  EN->>UC: evaluate(EvaluateAuthorizationRequest)
  UC->>RP: resolve application (id or name)
  UC->>RP: policies of application, assignments of tenant
  UC->>PE: decide(request, policies, assignments)
  PE-->>UC: AccessDecision(allowed, matched policies, reason)
  UC->>RP: save DecisionRecord (if recordDecisions)
  UC->>PB: publish(decision)
  UC-->>EN: AuthorizationResult
  EN-->>OD: AuthorizationResult row
  OD-->>App: 200 {allowed, reason, matchedPolicies, decisionId}
```

## 5. Sequence — create a policy from the Fiori app

```mermaid
sequenceDiagram
  autonumber
  participant UI as Fiori (ODataModel V4)
  participant OD as ODataController
  participant EN as ODataEngine
  participant UC as ManagePoliciesUseCase
  participant RP as PolicyRepository

  UI->>OD: POST /Policies {applicationId, name, resource, action, conditions}
  OD->>EN: create(ctx, "Policies", payload)
  EN->>EN: scope Admin, validatePayload (types, mandatory, computed dropped)
  EN->>UC: createPolicy(parseConditions(...))
  UC->>UC: validate · application exists · name unique
  UC->>RP: save
  UC-->>EN: AuthorizationPolicy
  EN-->>UI: 201 policy row (applicationName, assignmentCount)
```

## 6. Policy state machine

```mermaid
stateDiagram-v2
  [*] --> active: create / seed base
  active --> disabled: DisablePolicy
  disabled --> active: EnablePolicy
  active --> [*]: delete (assignments removed)
  disabled --> [*]: delete
  note right of disabled: grants nothing,\ncannot be newly assigned
```

## 7. Frontend structure (SAP Fiori 3)

```mermaid
flowchart TB
  Component[Component.js<br/>manifest.json] --> App[App.view]
  App --> Main[Main.view<br/>KPI header · tabs: Applications, Policies,<br/>Assignments, Check Access, Decision Log]
  App --> AppDetail[ApplicationDetail.view<br/>ObjectPage: general, APIs, policies]
  App --> PolDetail[PolicyDetail.view<br/>ObjectPage: rule, assignments]
  Main & AppDetail & PolDetail --> Base[BaseController<br/>create dialogs · callAction · confirmDelete]
  Base --> Frag[fragments<br/>CreateApplication · CreateApplicationApi<br/>CreatePolicy · CreateAssignment]
  Base --> Model[model/models.js · formatter.js]
  Component --> OData[(ODataModel V4<br/>/odata/v4/authorization/)]
```

## 8. Deployment

```mermaid
flowchart LR
  subgraph BTP["SAP BTP — Cloud Foundry (mta.yaml)"]
    AR[authorization-approuter<br/>@sap/approuter + Fiori resources]
    SRV[authorization-srv<br/>binary_buildpack<br/>uim-authorization-platform-service]
    XS[(authorization-xsuaa<br/>scopes Read · Admin · Check)]
    UPS[(authorization-config<br/>user-provided)]
  end
  subgraph K8s["Kubernetes (k8s/)"]
    POD[Deployment authorization] --- CM[ConfigMap]
    POD --- SVC[Service :8117]
    POD --> MDB[(MongoDB)]
  end
  subgraph Desktop
    CLI[uim-authorization-cli]
    GUI[uim-authorization-gui]
    FILE[(data/authorization.json)]
  end
  Browser --> AR --> SRV
  AR --- XS
  SRV --- XS
  SRV --- UPS
  CLI --- FILE
  GUI --- FILE
```
