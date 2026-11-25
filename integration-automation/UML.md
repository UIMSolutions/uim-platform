# UML — UIM Integration Automation

Diagrams of the redesigned service (backend 2.0). Mermaid renders them on GitHub/GitLab and in most Markdown viewers.

## 1. Domain model

```mermaid
classDiagram
  direction LR
  class SystemConnection {
    +SystemConnectionId id
    +string name
    +SystemType systemType
    +string host
    +int port
    +string protocol
    +string client
    +string sid
    +SystemEnvironment environment
    +string region
    +ConnectionStatus status
    +long lastTestedAt
    +string lastTestMessage
    +recordTest(reachable, message, at)
    +validate()
  }
  class Destination {
    +DestinationId id
    +string name
    +SystemConnectionId systemId
    +DestinationType destinationType
    +string url
    +AuthenticationType authentication
    +ProxyType proxyType
    +string locationId
    +string user
    +string tokenServiceUrl
    +bool enabled
    +validate()
  }
  class IntegrationScenario {
    +ScenarioId id
    +string name
    +ScenarioCategory category
    +string version_
    +ScenarioStatus status
    +SystemType sourceSystemType
    +SystemType targetSystemType
    +string[] prerequisites
    +ScenarioId basedOnId
    +activate(templates, at)
    +deprecate()
    +archive()
  }
  class ScenarioTask {
    +ScenarioTaskId id
    +ScenarioId scenarioId
    +int sequenceNumber
    +string name
    +TaskType taskType
    +TaskPriority priority
    +string assignedRole
    +string instructions
    +DestinationId destinationId
    +string automationEndpoint
    +string automationPayload
    +bool requiresSourceSystem
    +bool requiresTargetSystem
    +bool afterPrevious
    +string[] dependsOn
    +int estimatedMinutes
  }
  class Workflow {
    +WorkflowId id
    +ScenarioId scenarioId
    +string scenarioVersion
    +string name
    +WorkflowStatus status
    +SystemConnectionId sourceSystemId
    +SystemConnectionId targetSystemId
    +int totalTasks
    +int completedTasks
    +int failedTasks
    +int progressPercent
    +WorkflowTaskId currentTaskId
    +start(at) / suspend() / resume()
    +terminate(reason, at)
    +apply(WorkflowProgress, at)
  }
  class WorkflowTask {
    +WorkflowTaskId id
    +WorkflowId workflowId
    +ScenarioTaskId templateId
    +TaskStatus status
    +string assignedTo
    +string[] dependsOn
    +string result
    +string errorMessage
    +int attempts
    +start() / complete() / fail()
    +skip() / retry()
  }
  class ExecutionLog {
    +ExecutionLogId id
    +WorkflowId workflowId
    +WorkflowTaskId taskId
    +string action
    +ExecutionOutcome outcome
    +string message
    +string details
    +string executedBy
    +long durationMs
  }
  class UserAccount {
    +UserAccountId id
    +string displayName
    +string passwordHash
    +string[] scopes
    +bool locked
    +int failedLogins
    +long lockedUntil
    +recordFailure() / recordSuccess()
  }
  class WorkflowEngine {
    <<domain service>>
    +progressOf(tasks) WorkflowProgress
    +readyTasks(tasks)
    +openDependencies(task, tasks)
  }
  class ScenarioPlanner {
    <<domain service>>
    +templateDependencies(template, templates)
    +checkTemplateDependencies(template, templates)
    +planTasks(templates, …) WorkflowTask[]
  }

  SystemConnection "1" <-- "0..*" Destination : systemId
  IntegrationScenario "1" *-- "1..*" ScenarioTask : templates
  ScenarioTask "0..*" --> "0..1" Destination : destinationId
  ScenarioTask "0..*" --> "0..*" ScenarioTask : dependsOn
  IntegrationScenario "1" <-- "0..*" Workflow : instance of
  Workflow "1" *-- "1..*" WorkflowTask : tasks
  Workflow "0..*" --> "0..1" SystemConnection : source / target
  WorkflowTask "0..*" --> "0..*" WorkflowTask : dependsOn
  WorkflowTask "0..*" --> "0..1" ScenarioTask : templateId
  Workflow "1" <-- "0..*" ExecutionLog : workflowId
  ScenarioPlanner ..> WorkflowTask : creates
  WorkflowEngine ..> Workflow : progress
```

Every entity mixes in `TenantEntity` (tenantId, id, createdAt/By, updatedAt/By). Enumerations are string valued
(`ScenarioStatus`, `ScenarioCategory`, `SystemType`, `SystemEnvironment`, `ConnectionStatus`, `DestinationType`,
`AuthenticationType`, `ProxyType`, `TaskType`, `TaskPriority`, `TaskStatus`, `WorkflowStatus`, `ExecutionOutcome`).

## 2. Hexagonal components

```mermaid
flowchart TB
  subgraph presentation [presentation — driving adapters]
    OD[ODataController<br/>/odata/v4/integration-automation]
    REST[IaApiController<br/>/api/v1/integration-automation]
    AUTH[AuthController<br/>/auth]
    HL[IaHealthController]
    WEB[FrontendController /app]
    CLI[buildIaCli]
    GUI[runIaGui GtkD]
    ENG[ODataEngine<br/>integrationAutomationModel]
  end
  subgraph application [application]
    UC1[ManageSystemsUseCase<br/>ManageDestinationsUseCase]
    UC2[ManageScenariosUseCase<br/>ManageScenarioTasksUseCase]
    UC3[ManageWorkflowsUseCase]
    UC4[ProcessTasksUseCase]
    UC5[MonitorExecutionsUseCase]
    UC6[AccessUseCase]
    SVC[IaStatisticsService · seedDemoData]
  end
  subgraph domain [domain]
    ENT[entities · types · enumerations · exceptions]
    DS[WorkflowEngine · ScenarioPlanner]
  end
  subgraph ports [ports]
    PIN[IManageSystems · IManageDestinations · IManageScenarios · IManageScenarioTasks<br/>IManageWorkflows · IProcessTasks · IMonitorExecutions · IAuthenticate · IManageUsers]
    POUT[I…Repository · IIaUnitOfWork · IIaEventPublisher<br/>IAutomationGateway · IConnectivityProbe · IClock · IPasswordHasher · ITokenIssuer]
  end
  subgraph infrastructure [infrastructure / persistence — driven adapters]
    REPO[DocumentRepository&lt;E&gt;<br/>Batching Memory/File store]
    AG[Simulated / Http AutomationGateway]
    CP[Simulated / Tcp ConnectivityProbe]
    SEC[SecuritySetup · Hs256TokenIssuer · Rs256 verifier · Pbkdf2PasswordHasher]
    WRK[AutomationWorker]
    LOG[LoggingEventPublisher]
    CFG[loadIaConfig]
    CON[IaContainer — composition root]
  end
  OD --> ENG
  REST --> ENG
  CLI --> ENG
  GUI --> ENG
  AUTH --> PIN
  ENG --> PIN
  WRK --> PIN
  PIN -.implemented by.-> application
  application --> domain
  application --> POUT
  POUT -.implemented by.-> REPO
  POUT -.implemented by.-> AG
  POUT -.implemented by.-> CP
  POUT -.implemented by.-> SEC
  POUT -.implemented by.-> LOG
  CON --> application
  CON --> infrastructure
```

## 3. Workflow lifecycle

```mermaid
stateDiagram-v2
  [*] --> planned : create (active scenario)
  planned --> inProgress : start
  inProgress --> suspended : suspend
  failed --> suspended : suspend
  suspended --> inProgress : resume (no failed task)
  suspended --> failed : resume (a task failed)
  inProgress --> failed : a task fails
  failed --> inProgress : retry / skip the failed task
  inProgress --> completed : every task completed or skipped
  planned --> terminated : terminate
  inProgress --> terminated : terminate
  suspended --> terminated : terminate
  failed --> terminated : terminate
  completed --> [*]
  terminated --> [*]
```

## 4. Task lifecycle

```mermaid
stateDiagram-v2
  [*] --> pending
  pending --> inProgress : start (dependencies done) / automation claims it
  inProgress --> completed : complete / approve / automation 2xx
  inProgress --> failed : fail / reject / automation error or timeout
  pending --> failed : fail
  failed --> pending : retry (attempts + 1 on next start)
  pending --> skipped : skip (reason; not approvals)
  failed --> skipped : skip (reason; not approvals)
  completed --> [*]
  skipped --> [*]
```

## 5. Scenario lifecycle

```mermaid
stateDiagram-v2
  [*] --> draft : create / copy as new version
  draft --> active : activate (≥ 1 template, consistent dependencies)
  active --> deprecated : deprecate (no new workflows)
  deprecated --> active : activate
  draft --> archived : archive
  deprecated --> archived : archive
  note right of draft : task templates can only change here
```

## 6. Sequence — instantiate and run a workflow

```mermaid
sequenceDiagram
  actor O as Operator (Execute)
  participant UI as Fiori app
  participant OD as ODataController / ODataEngine
  participant WF as ManageWorkflowsUseCase
  participant SP as ScenarioPlanner
  participant TK as ProcessTasksUseCase
  participant WE as WorkflowEngine
  participant R as Repositories (batch)
  O->>UI: New Workflow (scenario, source, target, start now)
  UI->>OD: POST /Workflows
  OD->>WF: create(CreateWorkflowCommand)
  WF->>R: scenario active? templates? open workflows < limit? systems match?
  WF->>SP: planTasks(templates, source, target)
  SP-->>WF: tasks with mapped dependencies
  WF->>R: save workflow + tasks + log "workflow.created" (one snapshot write)
  UI->>OD: POST /StartWorkflow {id}
  OD->>WF: start → refreshWorkflow (WorkflowEngine.progressOf)
  O->>UI: Start / Complete task
  UI->>OD: POST /StartTask, /CompleteTask {id, result}
  OD->>TK: start / complete
  TK->>WE: openDependencies(task, tasks)
  TK->>R: save task + log + workflow progress
```

## 7. Sequence — automated task execution

```mermaid
sequenceDiagram
  participant W as AutomationWorker (timer) / RunAutomatedTasks
  participant TK as ProcessTasksUseCase
  participant WE as WorkflowEngine
  participant G as IAutomationGateway (simulate | http)
  participant D as Destination API
  participant R as Repositories
  W->>TK: runAutomation(tenant)
  loop every running workflow, until no machine task is ready
    TK->>WE: readyTasks(tasks) ∩ {automated, notification}
    TK->>R: task.start("automation") — claim before the call
    alt automated
      TK->>G: execute(url = destination.url + endpoint, payload)
      G->>D: POST payload (Authorization from IA_DESTINATION_<NAME>_AUTHORIZATION)
      D-->>G: HTTP status, body
    else notification
      TK->>G: notify(task) (webhook)
    end
    G-->>TK: AutomationResult {success, timedOut, message, details, durationMs}
    TK->>R: complete | fail, log "automation.succeeded|failed|timedOut", refresh workflow
  end
```

## 8. Sequence — built-in login (authMode jwt)

```mermaid
sequenceDiagram
  actor U as User
  participant C as Component.js / session.js
  participant A as AuthController
  participant AC as AccessUseCase
  participant H as Pbkdf2PasswordHasher
  participant I as Hs256TokenIssuer
  C->>A: GET /auth/config
  A-->>C: {mode: "jwt", loginRequired: true}
  U->>C: user name, password (LoginDialog)
  C->>A: POST /auth/login
  A->>AC: login(LoginRequest)
  AC->>H: verify(password, hash)
  alt wrong / unknown / locked
    AC-->>A: unauthorized (failed login counted, lock after 5)
    A-->>C: 401
  else ok
    AC->>I: issue(tenant, user, scopes)
    A-->>C: {access_token, expires_in, scope "Read Execute …", user}
    C->>C: sessionStorage; ODataModel with Authorization header; buttons by scope
  end
  C->>A: OData / REST with Bearer token → verified (HS256), scopes enforced by ODataEngine
```

## 9. Deployment

```mermaid
flowchart LR
  B[Browser] -->|HTTPS| AR["approuter<br/>(Node.js, XSUAA login)"]
  AR -->|"/odata, /api, /auth (forwardAuthToken)"| BE["integration-automation-srv<br/>(D binary, binary_buildpack)"]
  AR -->|static| RES["resources/ (Fiori app)"]
  AR <--> XS[(XSUAA)]
  BE <--> XS
  BE --- CFG[(integration-automation-config<br/>user-provided)]
  BE --- FS[(data/integration-automation.json)]
  BE -->|automated tasks| APIs[(Destination APIs<br/>S/4HANA, SuccessFactors, BTP, …)]
  BE -->|connection tests| SYS[(Landscape systems)]
```
