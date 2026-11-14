# UML — Task Center

These diagrams describe the 2.0 implementation in
`backend/source/uim/platform/task_center/`.

## Component diagram (hexagonal architecture)

```mermaid
flowchart LR
  subgraph Clients
    Fiori[SAP Fiori 3 app]
    Apps[Integrations / scripts]
    Admin[Operator shell]
    Desk[Desktop user]
  end

  subgraph Providers[Task providers]
    S4[(S/4HANA)]
    SF[(SuccessFactors)]
    Custom[(Custom REST)]
  end

  subgraph BTP[SAP BTP]
    AR[approuter + XSUAA]
  end

  subgraph Presentation[presentation — driving adapters]
    OD[ODataController\n/odata/v4/task-center]
    REST[TaskCenterRestController\n/api/v1/task-center]
    CLI[CLI commands\nuim-task-center-cli]
    GUI[GtkD entity browser\nuim-task-center-gui]
    WEB[FrontendController /app]
    ENG{{ODataEngine\nEDM model + providers}}
  end

  subgraph Application
    UC[Manage* use cases]
    PROC[ProcessTasks]
    SYNC[SyncTaskProviders]
    SVC[Statistics · DemoData · events]
  end

  subgraph Domain
    ENT[Entities]
    POL[TaskLifecycle · SubstitutionPolicy]
  end

  subgraph Ports
    PIN[driving: usecases · services]
    POUT[driven: repositories · storages\ngateways · messaging]
  end

  subgraph Persistence
    REPO[DocumentRepository × 8]
    MAP[mappers · records]
    STORE[(Memory / File\nDocumentStore)]
  end

  subgraph Infrastructure
    CFG[configuration]
    SEC[security: XSUAA RS256 / HS256]
    LOG[structured logging\nLoggingTaskEventPublisher]
    HTTPC[HttpTaskProviderClient]
    WRK[ProviderSyncWorker]
    CONT[TaskCenterContainer]
  end

  Fiori --> AR --> OD
  Apps --> REST
  Admin --> CLI
  Desk --> GUI
  OD --> ENG
  REST --> ENG
  CLI --> ENG
  GUI --> ENG
  ENG --> PIN
  PIN -.implemented by.-> UC & PROC & SYNC & SVC
  UC & PROC & SYNC --> POL
  POL --> ENT
  UC & PROC & SYNC & SVC --> POUT
  POUT -.implemented by.-> REPO & HTTPC & LOG
  REPO --> MAP --> STORE
  HTTPC --> S4 & SF & Custom
  WRK --> SYNC
  CONT -.wires.-> ENG & UC & REPO & HTTPC
  OD & REST --> SEC
```

Dependencies point inwards: `domain` imports nothing of the outer layers,
`application` depends on `ports` interfaces only, adapters depend on ports.

## Domain class diagram

```mermaid
classDiagram
  direction LR

  class UIMTask {
    TaskId id
    TenantId tenantId
    TaskDefinitionId definitionId
    TaskProviderId providerId
    string externalTaskId
    string title
    string description
    TaskStatus status
    TaskPriority priority
    TaskCategory category
    TaskOutcome outcome
    string assignee
    string substitutedFor
    string creator
    string processor
    string sourceApplication
    string[] allowedActions
    string customAttributes
    bool isClaimed
    string claimedBy
    string dueDate
    long completedAt
    isFinished() bool
    isOverdue(today) bool
    allows(ActionType) bool
    validate()
  }

  class TaskDefinition {
    TaskDefinitionId id
    TaskProviderId providerId
    string name
    TaskCategory category
    TaskPriority defaultPriority
    string[] allowedActions
    string taskSchema
    int dueInDays
    bool isActive
    bool requiresClaim
    validate()
  }

  class TaskProvider {
    TaskProviderId id
    string name
    ProviderType providerType
    ProviderStatus status
    AuthenticationType authType
    string endpointUrl
    string authEndpointUrl
    string clientId
    string clientSecret
    long lastSyncAt
    string lastSyncError
    canSync() bool
    validate()
  }

  class TaskComment {
    TaskCommentId id
    TaskId taskId
    string author
    string content
  }

  class TaskAttachment {
    TaskAttachmentId id
    TaskId taskId
    string fileName
    long fileSize
    string mimeType
    string url
    AttachmentStatus status
    string uploadedBy
  }

  class TaskAction {
    TaskActionId id
    TaskId taskId
    ActionType actionType
    string performedBy
    long performedAt
    string forwardTo
    string comment
    TaskStatus fromStatus
    TaskStatus toStatus
  }

  class SubstitutionRule {
    SubstitutionRuleId id
    string userId
    string substituteId
    TaskDefinitionId definitionId
    SubstitutionStatus status
    string startDate
    string endDate
    bool isAutoForward
    effectiveStatus(today) SubstitutionStatus
    appliesTo(assignee, definition, today) bool
  }

  class UserTaskFilter {
    UserTaskFilterId id
    string userId
    string name
    FilterCriterion[] criteria
    bool isDefault
    toODataFilter(user) string
  }

  class FilterCriterion {
    FilterCriterionType criterionType
    string value
  }

  TaskProvider "1" o-- "*" TaskDefinition : offers
  TaskProvider "1" o-- "*" UIMTask : federates
  TaskDefinition "1" o-- "*" UIMTask : template of
  UIMTask "1" *-- "*" TaskComment
  UIMTask "1" *-- "*" TaskAttachment
  UIMTask "1" *-- "*" TaskAction : audit trail
  SubstitutionRule "*" --> "0..1" TaskDefinition : scoped to
  UserTaskFilter "1" *-- "*" FilterCriterion
```

Every entity mixes in `TenantEntity` (id, tenantId, createdAt/By, updatedAt/By).

### Enumerations and domain services

```mermaid
classDiagram
  class TaskStatus { <<enumeration>> open reserved inProgress forwarded completed cancelled failed }
  class TaskPriority { <<enumeration>> low medium high veryHigh }
  class TaskCategory { <<enumeration>> approval review toDoItem notification action workflow informational }
  class TaskOutcome { <<enumeration>> none approved rejected completed cancelled }
  class ActionType { <<enumeration>> claim release forward approve reject complete cancel escalate resubmit }
  class ProviderType { <<enumeration>> s4hana successFactors ariba fieldglass concur sapBuild custom }
  class ProviderStatus { <<enumeration>> active inactive syncing error }
  class AuthenticationType { <<enumeration>> none oauth2 basicAuth apiKey certificate saml }
  class SubstitutionStatus { <<enumeration>> active inactive pending expired }
  class AttachmentStatus { <<enumeration>> uploaded processing available deleted }
  class FilterCriterionType { <<enumeration>> status priority provider category dueDate assignee creator taskDefinition }

  class TaskLifecycle {
    <<domain service>>
    checkAction(task, action, input)
    applyAction(task, action, input) TaskStatus
    availableActions(task, actor, requiresClaim) ActionType[]
    escalated(priority) TaskPriority
  }
  class SubstitutionPolicy {
    <<domain service>>
    resolveRecipient(rules, assignee, definition, today) Recipient
    checkForwardingCycle(rules, candidate, today)
    periodsOverlap(s1, e1, s2, e2) bool
  }
  class TaskCenterException {
    TaskCenterErrorKind kind
  }
  class TaskCenterErrorKind { <<enumeration>> invalid notFound conflict ruleViolation forbidden gateway }
  TaskCenterException --> TaskCenterErrorKind
```

## Ports and application

```mermaid
classDiagram
  direction TB
  class TaskCenterPorts {
    IManageTasks tasks
    IProcessTasks processing
    IManageTaskDefinitions definitions
    IManageTaskProviders providers
    ISyncTaskProviders sync
    IManageTaskComments comments
    IManageTaskAttachments attachments
    IManageSubstitutionRules substitutions
    IManageUserTaskFilters filters
    ITaskCenterStatistics statistics
  }

  class IProcessTasks {
    <<interface>>
    perform(PerformTaskActionRequest) TaskActionResult
    listActions(tenant) TaskAction[]
  }
  class ISyncTaskProviders {
    <<interface>>
    sync(tenant, providerId, actor) SyncResult
    syncAll(tenant, actor) SyncResult[]
  }
  class IManageTasks {
    <<interface>>
    listTasks / getTask
    createTask(CreateTaskRequest)
    updateTask(UpdateTaskRequest)
    deleteTask(tenant, id)
  }

  class ITaskRepository {
    <<interface>>
    findByProvider / findByDefinition / findByAssignee
    findByExternalId(tenant, provider, externalId)
  }
  class ITaskProviderGateway {
    <<interface>>
    fetchTasks(ProviderConnection) ProviderTask[]
  }
  class ITaskEventPublisher {
    <<interface>>
    publish(TaskDomainEvent)
  }
  class IDocumentStore {
    <<interface>>
    all / get / put / remove / count
  }

  class ProcessTasksUseCase
  class SyncTaskProvidersUseCase
  class ManageTasksUseCase
  class HttpTaskProviderClient
  class StaticTaskProviderGateway
  class LoggingTaskEventPublisher
  class TaskRepository

  IProcessTasks <|.. ProcessTasksUseCase
  ISyncTaskProviders <|.. SyncTaskProvidersUseCase
  IManageTasks <|.. ManageTasksUseCase
  ITaskProviderGateway <|.. HttpTaskProviderClient
  ITaskProviderGateway <|.. StaticTaskProviderGateway
  ITaskEventPublisher <|.. LoggingTaskEventPublisher
  ITaskRepository <|.. TaskRepository
  TaskRepository --> IDocumentStore
  SyncTaskProvidersUseCase --> ITaskProviderGateway
  SyncTaskProvidersUseCase --> IManageTasks : imports via
  ProcessTasksUseCase --> ITaskRepository
  ProcessTasksUseCase --> ITaskEventPublisher
  TaskCenterPorts --> IProcessTasks
  TaskCenterPorts --> ISyncTaskProviders
  TaskCenterPorts --> IManageTasks
```

## State machines

### Task

```mermaid
stateDiagram-v2
  [*] --> open : create / import
  [*] --> reserved : import (provider reserved it for the assignee)
  open --> inProgress : claim
  reserved --> inProgress : claim (assignee only)
  forwarded --> inProgress : claim
  inProgress --> open : release (claimer only)
  open --> forwarded : forward
  reserved --> forwarded : forward
  inProgress --> forwarded : forward (claimer)
  forwarded --> forwarded : forward
  open --> completed : approve / reject / complete
  inProgress --> completed : approve / reject / complete (claimer)
  forwarded --> completed : approve / reject / complete
  open --> cancelled : cancel
  inProgress --> cancelled : cancel (claimer)
  forwarded --> cancelled : cancel
  open --> failed : provider reports failure
  completed --> open : resubmit
  cancelled --> open : resubmit
  failed --> open : resubmit
```

`escalate` keeps the status and raises the priority. Definitions with
*requires claim* only accept decisions in `inProgress`.

### Substitution rule (effective status)

```mermaid
stateDiagram-v2
  [*] --> pending : startDate in the future
  [*] --> active : no startDate / started
  pending --> active : startDate reached
  active --> expired : endDate passed
  active --> inactive : owner deactivates
  pending --> inactive : owner deactivates
  inactive --> active : owner activates
```

### Task provider

```mermaid
stateDiagram-v2
  [*] --> inactive
  inactive --> active : activate
  active --> inactive : deactivate
  active --> error : sync failed
  error --> active : sync succeeded
  error --> inactive : deactivate
```

## Sequence: claim and approve a task (Fiori, OData)

```mermaid
sequenceDiagram
  actor U as User (anna)
  participant F as Fiori app
  participant AR as approuter
  participant OC as ODataController
  participant E as ODataEngine
  participant P as ProcessTasksUseCase
  participant L as TaskLifecycle
  participant R as Repositories
  participant EV as ITaskEventPublisher

  U->>F: open task, press Claim
  F->>AR: POST /odata/v4/task-center/PerformTaskAction {taskId, action: claim}
  AR->>OC: forward + JWT
  OC->>OC: verify token → RequestContext(tenant, anna, scopes)
  OC->>E: invoke("PerformTaskAction") — scope Process
  E->>P: perform(request)
  P->>R: task, definition (requiresClaim)
  P->>L: applyAction(task, claim, input)
  L-->>P: from = open, task.status = inProgress
  P->>R: save task, save TaskAction(open → inProgress)
  P->>EV: sap.taskcenter.task.claimed
  P-->>E: TaskActionResult
  E-->>OC: Task row (availableActions for anna)
  OC-->>F: 200 Task
  F->>F: refresh, read availableActions → show Approve / Reject
  U->>F: Approve, comment "Within budget"
  F->>OC: PerformTaskAction {action: approve, comment}
  OC->>E: invoke
  E->>P: perform
  P->>L: applyAction(approve) — claimer, requiresClaim ok
  P->>R: save task (completed / approved), TaskAction, TaskComment
  P->>EV: sap.taskcenter.task.approved
  OC-->>F: 200 Task
```

## Sequence: provider sync (federation)

```mermaid
sequenceDiagram
  participant W as ProviderSyncWorker / CLI sync / SyncProvider action
  participant S as SyncTaskProvidersUseCase
  participant G as HttpTaskProviderClient
  participant X as Provider endpoint
  participant M as ManageTasksUseCase
  participant SP as SubstitutionPolicy
  participant R as Repositories

  W->>S: sync(tenant, providerId)
  S->>R: provider (active, endpointUrl?)
  S->>G: fetchTasks(connection)
  G->>X: (OAuth2 token) GET endpointUrl
  X-->>G: JSON feed (array | value | d.results | tasks)
  G-->>S: ProviderTask[] (statuses / priorities normalized)
  loop every provider task
    S->>R: findByExternalId(provider, externalId)
    alt unknown and not finished
      S->>M: createTask(definition by name, initialStatus)
      M->>SP: resolveRecipient(rules, assignee)
      M->>R: save task
    else known and unfinished
      S->>R: save refreshed task (title, priority, due date, closed?)
    end
  end
  S->>R: provider.status = active, lastSyncAt
  S-->>W: SyncResult{fetched, created, updated, skipped}
  Note over S,G: transport / format errors → provider.status = error,\nlastSyncError, SyncResult.error (other providers continue)
```

## Deployment diagram

```mermaid
flowchart TB
  subgraph CF[SAP BTP · Cloud Foundry space]
    AR[task-center-approuter\nnode.js · Fiori resources]
    SRV[task-center-srv\nbinary buildpack\nuim-task-center-platform-service]
    UAA[(task-center-xsuaa\nxsuaa · application)]
    UPS[(task-center-config\nuser-provided)]
    AR -- destination task-center-srv\nforwardAuthToken --> SRV
    AR -. login .-> UAA
    SRV -. VCAP_SERVICES verificationkey .-> UAA
    SRV -. syncTenants .-> UPS
  end
  Browser((Browser)) --> AR
  SRV --> Prov[(Task providers)]

  subgraph K8s[Kubernetes · namespace uim-platform]
    DEP[Deployment task-center\nreplicas 1 · Recreate]
    CM[ConfigMap task-center-config]
    SVCK[Service task-center :8103]
    VOL[(volume /data)]
    CM --> DEP
    SVCK --> DEP
    DEP --> VOL
  end

  subgraph Desktop[Workstation]
    CLIX[uim-task-center-cli]
    GUIX[uim-task-center-gui]
    FILE[(data/task-center.json)]
    CLIX --> FILE
    GUIX --> FILE
  end
```
