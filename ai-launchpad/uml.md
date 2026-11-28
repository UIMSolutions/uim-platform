# UML — UIM AI Launchpad

Diagrams of the AI Launchpad service 2.0 (Mermaid). Source:
[backend/source/uim/platform/ai_launchpad](backend/source/uim/platform/ai_launchpad).

## 1. Domain model

Every entity mixes in `TenantEntity` (`tenantId`, `id`, `createdAt/By`, `updatedAt/By`). References between
entities are ids. Executions and deployments copy `scenarioId` and `connectionId` from their configuration so
that they can be filtered without joins.

```mermaid
classDiagram
  direction LR
  class Workspace {
    string name
    string description
    WorkspaceStatus status
    +requireActive(op)
  }
  class Connection {
    WorkspaceId workspaceId
    string name
    ConnectionType connectionType
    string url
    string authUrl
    string clientId
    string clientSecret «write-only»
    string defaultResourceGroup
    ConnectionStatus status
    string statusMessage
    long lastValidatedAt
    +invalidate(reason)
    +requireActive(op)
  }
  class ResourceGroup {
    ConnectionId connectionId
    string[] labels
    ResourceGroupStatus status
    +requireReady(op)
  }
  class Scenario {
    ConnectionId connectionId
    string name
    string[] executables
    string[] labels
    +offers(executable) bool
  }
  class Configuration {
    ScenarioId scenarioId
    ConnectionId connectionId
    string name
    string executableId
    string[] parameters «key=value»
    string[] inputArtifacts «key=artifactId»
    +artifactIds() string[]
  }
  class Execution {
    ConfigurationId configurationId
    ResourceGroupId resourceGroupId
    ExecutionStatus status
    long startedAt
    long completedAt
    long durationSeconds
    +start(now)
    +complete(now, ok, msg)
    +stop(now, by)
  }
  class Deployment {
    ConfigurationId configurationId
    ResourceGroupId resourceGroupId
    DeploymentStatus status
    string deploymentUrl
    int minReplicas 1..10
    int maxReplicas 1..10
    int ttlMinutes
    +markRunning(now, url)
    +stop(now, reason)
    +restart()
    +isExpiredAt(now) bool
  }
  class Model {
    ScenarioId scenarioId
    string executionId
    string name
    string version
    string url
    double sizeMiB
    ArtifactStatus status
  }
  class Dataset {
    ScenarioId scenarioId
    string name
    string url
    double sizeMiB
    ArtifactStatus status
  }
  class PromptCollection {
    WorkspaceId workspaceId
    string name
  }
  class Prompt {
    PromptCollectionId collectionId
    string modelName
    string systemMessage
    string userMessage
    double temperature
    int maxTokens
    double topP
    PromptStatus status
    int version
    string lastOutput
    int runCount
    +inputParams() string[]
    +requireRunnable()
  }
  class Tile {
    string title
    string subtitle
    string icon
    string groupName
    int sortOrder
    TileTargetType targetType
    string target
    string kpi
    string requiredScope
    bool visible
    +permits(scopes) bool
  }
  class Role {
    string name
    string[] scopes
    bool builtIn
  }
  class UserAccount {
    string displayName
    string email
    string passwordHash «never exposed»
    string[] roles
    bool locked
    int failedLogins
    long lockedUntil
    long lastLoginAt
    +recordFailure(now, max, lock)
    +recordSuccess(now)
  }
  class LogEntry {
    LogCategory category
    LogSeverity severity
    string eventType
    string subject
    string message
    string details
  }

  Workspace "1" o-- "*" Connection
  Workspace "1" o-- "*" PromptCollection
  Connection "1" o-- "*" ResourceGroup
  Connection "1" o-- "*" Scenario
  Scenario "1" o-- "*" Configuration
  Scenario "1" o-- "*" Model
  Scenario "1" o-- "*" Dataset
  Configuration ..> Dataset : input artifact
  Configuration ..> Model : input artifact
  Configuration "1" o-- "*" Execution
  Configuration "1" o-- "*" Deployment
  ResourceGroup "1" o-- "*" Execution
  ResourceGroup "1" o-- "*" Deployment
  Execution "0..1" <-- "*" Model : produced by
  PromptCollection "1" o-- "*" Prompt
  UserAccount "*" --> "1..*" Role
  LogEntry ..> UserAccount : createdBy
```

## 2. Hexagonal components

```mermaid
flowchart LR
  subgraph Driving["Driving adapters (presentation)"]
    UI["Fiori launchpad<br/>(frontend)"]
    OD["ODataController<br/>/odata/v4/ai-launchpad"]
    REST["AilpApiController<br/>/api/v1/ai-launchpad"]
    AUTH["AuthController<br/>/auth/*"]
    CLI["CLI"]
    GUI["GtkD GUI"]
    W["HousekeepingWorker<br/>(timer)"]
  end
  subgraph Core["Application core"]
    ENG["ODataEngine<br/>(EDM model, scopes, validation)"]
    P["AilpPorts<br/>(driving ports)"]
    UC["Use cases<br/>runtimes · lifecycle · registry · reconcile<br/>genai · launchpad · access · logging"]
    D["Domain<br/>entities · rules · services"]
  end
  subgraph Driven["Driven adapters"]
    REPO["DocumentRepositories"]
    STORE["Memory / File store<br/>(batching unit of work)"]
    RT["SimulatedAiRuntime<br/>(IAiRuntime)"]
    SEC["Pbkdf2PasswordHasher<br/>Hs256TokenIssuer"]
    AUD["LoggingAuditTrail<br/>(log line + LogEntries)"]
    CLK["SystemClock"]
  end
  UI --> OD
  UI --> AUTH
  OD --> ENG
  REST --> ENG
  CLI --> ENG
  GUI --> ENG
  ENG --> P
  AUTH --> P
  W --> P
  P --> UC
  UC --> D
  UC --> REPO --> STORE
  UC --> RT
  UC --> SEC
  UC --> AUD --> REPO
  UC --> CLK
```

Layer rules: `domain` depends on nothing; `ports` on the domain and the DTOs; `application` implements
the driving ports against the driven ports; `persistence` and `infrastructure` implement the driven
ports; `presentation` only talks to `AilpPorts` and the `ODataEngine`. `AilpContainer` wires everything.

## 3. Execution and deployment states

```mermaid
stateDiagram-v2
  direction LR
  state Execution {
    [*] --> pending : create
    pending --> running : reconcile (runtime started)
    running --> completed : reconcile (succeeded)
    running --> failed : reconcile (failed)
    pending --> stopped : StopExecution
    running --> stopped : StopExecution
    completed --> [*]
    failed --> [*]
    stopped --> [*]
  }
```

```mermaid
stateDiagram-v2
  direction LR
  state Deployment {
    [*] --> pending : create
    pending --> running : reconcile (URL assigned)
    pending --> dead : reconcile (did not start)
    running --> stopped : StopDeployment / TTL expired
    pending --> stopped : StopDeployment
    stopped --> pending : StartDeployment
    dead --> pending : StartDeployment
  }
```

## 4. Connection states

```mermaid
stateDiagram-v2
  direction LR
  [*] --> pending : create
  pending --> active : ValidateConnection ok
  pending --> error : ValidateConnection failed
  active --> pending : URL / credentials changed
  error --> pending : URL / credentials changed
  error --> active : ValidateConnection ok
  active --> error : ValidateConnection failed
```

## 5. Sequence — login with the built-in JWT

```mermaid
sequenceDiagram
  autonumber
  actor U as User
  participant C as Component.js
  participant A as AuthController
  participant UC as AccessUseCase
  participant H as Pbkdf2PasswordHasher
  participant T as Hs256TokenIssuer
  participant L as LoggingAuditTrail
  U->>C: open /app/index.html
  C->>A: GET /auth/config
  A-->>C: {mode: "jwt", loginRequired: true}
  C->>U: login dialog
  U->>C: user + password
  C->>A: POST /auth/login
  A->>UC: login(LoginRequest)
  UC->>H: verify(password, hash)
  alt wrong password / unknown user / locked
    UC->>L: login.failed | login.locked
    UC-->>A: unauthorized
    A-->>C: 401 "Invalid user name or password"
  else ok
    UC->>UC: scopes = union(scopes of roles)
    UC->>T: issue(tenant, user, scopes)
    UC->>L: login.succeeded
    A-->>C: {access_token, expires_in, user{roles, scopes}}
    C->>C: sessionStorage, ODataModel with Bearer header
    C->>U: launchpad (tiles filtered by scope)
  end
```

## 6. Sequence — launchpad

```mermaid
sequenceDiagram
  autonumber
  participant LC as Launchpad.controller
  participant OD as ODataController
  participant E as ODataEngine
  participant TU as ManageTilesUseCase
  participant S as AilpStatisticsService
  LC->>OD: GET /LaunchpadTiles?$orderby=sortOrder (Bearer)
  OD->>E: query(ctx, "LaunchpadTiles")
  E->>E: check scope Read
  E->>TU: launchpad(tenant, ctx.scopes, enforceScopes)
  TU->>TU: visible tiles permitted by the scopes, sorted by group and order
  TU->>S: compute(tenant) (once, if a tile shows a KPI)
  TU-->>E: LaunchpadTile[] with kpiValue
  E-->>LC: rows
  LC->>LC: group by groupName → GenericTiles
  Note over LC: press → router.navTo(route, tab) or window.open(url)
```

## 7. Sequence — reconcile worker

```mermaid
sequenceDiagram
  autonumber
  participant W as HousekeepingWorker
  participant R as ReconcileRuntimeUseCase
  participant RT as IAiRuntime
  participant DB as Repositories (batch)
  participant L as LoggingAuditTrail
  loop every reconcileIntervalSeconds, per worker tenant
    W->>R: reconcile(tenant, "system")
    R->>DB: active executions and deployments
    loop each workload (max maxReconcileBatch)
      alt deployment TTL expired
        R->>DB: stop + save
        R->>L: deployment.expired
      else
        R->>RT: pollExecution / pollDeployment
        RT-->>R: RuntimeState(status, message, url)
        R->>DB: apply transition + save
        R->>L: execution.started / completed / failed, deployment.running / dead
      end
    end
    R-->>W: ReconcileSummary
    opt every purgeEveryRuns-th run
      W->>DB: purge log entries older than logRetentionDays
    end
  end
```

## 8. Sequence — playground run

```mermaid
sequenceDiagram
  autonumber
  actor U as User (Operate)
  participant G as GenAI.controller
  participant E as ODataEngine
  participant P as ManagePromptsUseCase
  participant RT as IAiRuntime
  participant L as LoggingAuditTrail
  U->>G: select prompt, fill {{inputs}}, Run
  G->>E: RunPrompt(id, inputs JSON)
  E->>E: check scope Operate
  E->>P: run(tenant, id, inputs, actor)
  P->>P: requireRunnable, renderTemplate(system), renderTemplate(user)
  P->>RT: complete(prompt, system, user)
  RT-->>P: output, tokens, latency
  P->>P: lastOutput, lastRunAt, runCount++
  P->>L: prompt.run (version, model, token counts — no text)
  P-->>G: PromptRunResult
```

## 9. Deployment

```mermaid
flowchart TB
  subgraph BTP["SAP BTP Cloud Foundry (mta.yaml)"]
    AR["ai-launchpad-approuter<br/>(approuter.nodejs, Fiori resources)"]
    SRV["ai-launchpad-srv<br/>(binary_buildpack, D executable)"]
    XS[("ai-launchpad-xsuaa<br/>xs-security.json")]
    CFG[("ai-launchpad-config<br/>user-provided")]
  end
  Browser --> AR
  AR -- "forwardAuthToken (RS256)" --> SRV
  AR --- XS
  SRV --- XS
  SRV --- CFG
  subgraph K8S["Kubernetes (k8s/)"]
    POD["Deployment ai-launchpad-service<br/>1 replica, Recreate"]
    PVC[("PVC ai-launchpad-data<br/>/data/ai-launchpad.json")]
    CM["ConfigMap + Secret<br/>AILP_*"]
  end
  POD --- PVC
  CM --> POD
```
