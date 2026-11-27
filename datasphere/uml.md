# UML — UIM Datasphere

Diagrams of the Datasphere service 2.0 (Mermaid). Source: [backend/source/uim/platform/datasphere](backend/source/uim/platform/datasphere).

## 1. Domain model

Every entity mixes in `TenantEntity` (`tenantId`, `id`, `createdAt/By`, `updatedAt/By`). References between
entities are ids; all space-scoped entities carry `spaceId`.

```mermaid
classDiagram
  direction LR
  class Space {
    SpaceId id  «technical name»
    string name
    SpaceStatus status
    int priority 1..8
    long diskQuotaBytes
    long memoryQuotaBytes
    long usedDiskBytes
    bool auditLogEnabled
    string lockedReason
    +fits(bytes) bool
    +requireActive(op)
  }
  class SpaceMember {
    string userName
    string displayName
    SpaceRole role
  }
  class Connection {
    ConnectionType connectionType
    string host
    int port
    string database
    string user
    string password «write-only»
    string[] properties
    ConnectionStatus status
    string statusMessage
    +endpoint() string
    +invalidate()
  }
  class RemoteTable {
    string name
    string remoteSchema
    string remoteObject
    ReplicationMode replicationMode
    ReplicationStatus replicationStatus
    string[] columns
    long rowCount
    long sizeBytes
    +holdsData() bool
    +dropReplica()
  }
  class DataView {
    string name
    ViewSemantic semantic
    string sqlExpression
    string[] sourceObjects «derived»
    string[] columns
    bool exposed
    DeploymentStatus deploymentStatus
    bool persisted
    long rowCount
    long persistedBytes
  }
  class DataFlow {
    string name
    string[] sourceObjects
    string[] transforms
    string targetTable
    LoadMode loadMode
    DeploymentStatus deploymentStatus
    RunStatus lastRunStatus
    long targetRows
    long targetBytes
  }
  class DataTask {
    TaskType taskType
    string targetObjectId
    ScheduleFrequency frequency
    int intervalMinutes
    long startAt
    ScheduleStatus status
    int maxRetries
    long nextRunAt
    RunStatus lastRunStatus
    int consecutiveFailures
    +isDue(at) bool
    +reschedule(after)
  }
  class TaskChain {
    string[] taskIds «ordered»
    FailurePolicy failurePolicy
    ScheduleFrequency frequency
    long nextRunAt
    RunStatus lastRunStatus
  }
  class TaskRun {
    RunObjectType objectType
    string objectId
    string taskId
    string chainRunId
    RunTrigger trigger
    RunStatus status
    int attempts
    long startedAt
    long durationMs
    long rowsProcessed
    long sizeBytes
    string message
  }
  class DataAccessControl {
    string criteriaColumn
    CriteriaOperator criteriaOperator
    string[] criteriaValues
    string[] targetViewIds
    string[] assignedUsers
    bool enabled
  }
  class CatalogAsset {
    AssetType assetType
    string sourceObjectId
    string owner
    QualityStatus qualityStatus
    Sensitivity sensitivity
    string[] tags
    string[] glossaryTerms
    long accessCount
    +searchScore(text) int
  }
  class UserAccount {
    string displayName
    string passwordHash
    string[] scopes
    bool locked
    int failedLogins
    long lockedUntil
  }

  Space "1" o-- "*" SpaceMember
  Space "1" o-- "*" Connection
  Connection "1" <-- "*" RemoteTable : connectionId
  Space "1" o-- "*" RemoteTable
  Space "1" o-- "*" DataView
  Space "1" o-- "*" DataFlow
  DataView ..> RemoteTable : reads (FROM/JOIN)
  DataView ..> DataView : reads
  DataFlow ..> RemoteTable : sourceObjects
  DataFlow ..> DataView : sourceObjects
  Space "1" o-- "*" DataTask
  DataTask ..> RemoteTable : replication
  DataTask ..> DataFlow : dataFlow
  DataTask ..> DataView : viewPersistence
  TaskChain "*" --> "*" DataTask : steps
  TaskRun ..> DataTask : taskId
  TaskRun ..> TaskRun : chainRunId
  DataAccessControl "*" --> "*" DataView : protects
  CatalogAsset ..> DataView : describes
  CatalogAsset ..> RemoteTable : describes
```

Domain services (pure functions): `columns` (parse `NAME:TYPE(len) key`, row width), `sql` (tokenizer, single
read-only SELECT, sources), `schedules` (next firing), `access` (row level decision), `lifecycle` (deployment
status after a change, disk usage of a space).

## 2. Hexagonal components

```mermaid
flowchart LR
  subgraph Driving adapters
    ODATA[OData v4 controller<br/>/odata/v4/datasphere]
    REST[REST controller<br/>/api/v1/datasphere]
    AUTH[Auth controller<br/>/auth/*]
    CLI[CLI]
    GUI[GtkD GUI]
    WORKER[Scheduler worker]
  end
  ENGINE[ODataEngine<br/>model + providers + actions]
  subgraph Application
    UC[Interactors<br/>spaces · integration · modeling · scheduling · access]
    RUN[RunService]
    STATS[Statistics]
  end
  subgraph Domain
    ENT[Entities]
    DS[Domain services]
  end
  subgraph Driven ports
    REPO[(IDspRepository*)]
    UOW[IDspUnitOfWork]
    PROC[IProcessingEngine]
    CLK[IClock]
    AUD[IAuditTrail]
    CRED[IPasswordHasher · ITokenIssuer]
  end
  subgraph Driven adapters
    DOC[DocumentRepository<br/>Batching file / memory store]
    SIM[SimulatedProcessingEngine]
    SYS[SystemClock]
    LOG[LoggingAuditTrail]
    SEC[PBKDF2 · HS256 issuer]
  end
  ODATA --> ENGINE
  REST --> ENGINE
  CLI --> ENGINE
  GUI --> ENGINE
  AUTH --> UC
  WORKER --> UC
  ENGINE -->|DspPorts| UC
  ENGINE --> STATS
  UC --> RUN
  UC --> ENT
  RUN --> DS
  UC --> REPO & UOW & CLK & AUD & CRED
  RUN --> PROC
  REPO -.-> DOC
  UOW -.-> DOC
  PROC -.-> SIM
  CLK -.-> SYS
  AUD -.-> LOG
  CRED -.-> SEC
```

`DspContainer` (infrastructure) wires everything once and is shared by server, CLI and GUI.

## 3. Deployment status of views and data flows

```mermaid
stateDiagram-v2
  [*] --> notDeployed
  notDeployed --> deployed : Deploy (sources exist)
  deployed --> changesToDeploy : SQL / columns / sources / transforms changed
  changesToDeploy --> deployed : Deploy
  deployed --> deployed : Run / Persist
```

## 4. Connection, replication and schedule states

```mermaid
stateDiagram-v2
  state Connection {
    [*] --> untested
    untested --> valid : Validate ok
    untested --> invalid : Validate failed
    valid --> untested : host/port/db/user/password/type changed
    invalid --> untested : changed
    valid --> invalid : Validate failed
    invalid --> valid : Validate ok
  }
  state RemoteTable {
    [*] --> notReplicated
    notReplicated --> replicated : snapshot ok
    notReplicated --> active : realtime ok
    notReplicated --> failed : snapshot failed
    failed --> replicated : snapshot ok
    replicated --> notReplicated : DropReplica / mode remote
    active --> notReplicated : DropReplica / mode remote
  }
  state Schedule {
    [*] --> activeSchedule
    activeSchedule --> paused : Pause
    paused --> activeSchedule : Resume
  }
```

## 5. Run (activity) — `RunService.execute`

```mermaid
flowchart TD
  A[start run: TaskRun status running] --> B{space exists and active?}
  B -- no --> F[failed: space locked / not found]
  B -- yes --> C[load object]
  C --> D{deployed? connection valid?<br/>untested → validate first}
  D -- no --> F2[failed: not deployed / invalid connection]
  D -- yes --> E[IProcessingEngine: replicate · runDataFlow · persistView]
  E -- error --> F3[failed: engine message]
  E -- ok --> Q{usage − old + new ≤ disk quota?}
  Q -- no --> F4[failed: disk quota exceeded]
  Q -- yes --> U[update object rows/size/timestamps]
  U --> S[refresh space usage]
  S --> OK[completed]
  F & F2 & F3 & F4 & OK --> L[save run, audit run.completed / run.failed]
```

## 6. Sequence — task chain run

```mermaid
sequenceDiagram
  actor U as User / Scheduler
  participant API as REST / OData
  participant TC as ManageTaskChainsUseCase
  participant R as RunService
  participant P as IProcessingEngine
  participant DB as Repositories (batch)
  U->>API: POST /task-chains/nightly/run
  API->>TC: runChain(t, nightly, actor)
  TC->>R: runChain(chain, manual)
  R->>DB: save chain run (running)
  loop each step (one storage batch)
    R->>R: runTask(task, chain, chainRunId)
    loop attempt 1..maxRetries+1
      R->>P: replicate / runDataFlow / persistView
      P-->>R: rows, duration, message
      R->>DB: save step run, update object, space usage
    end
    alt step failed and policy stop
      R->>DB: later steps → cancelled runs
    end
  end
  R->>DB: finish chain run, update chain (last run, next run)
  R-->>API: chain run
  API-->>U: 200 {status, message: "4 of 4 steps completed"}
```

## 7. Sequence — scheduler worker

```mermaid
sequenceDiagram
  participant T as vibe.d timer
  participant W as SchedulerWorker
  participant M as MonitorRunsUseCase
  participant R as RunService
  T->>W: every schedulerIntervalSeconds
  W->>M: runDue(tenant, "scheduler")
  M->>M: due chains (nextRunAt ≤ now), then due tasks not in those chains
  alt space locked
    M->>M: skipped, reschedule
  else
    M->>R: runChain / runTask (trigger schedule)
  end
  M-->>W: SchedulerSummary
  W->>W: metrics; every purgeEveryRuns-th run: purgeRuns
```

## 8. Sequence — row access check

```mermaid
sequenceDiagram
  actor U as Analyst
  participant API as /views/{id}/check-access
  participant V as ManageViewsUseCase
  participant A as access.evaluateAccess
  U->>API: {user: "bob", row: {"COUNTRY": "DE"}}
  API->>V: checkAccess(t, view, user, row)
  V->>A: controls of the space
  A->>A: protecting = enabled controls with view in targetViewIds
  alt none protects
    A-->>V: allowed (unprotected)
  else user assigned and criteria match
    A-->>V: allowed, matchedControls
  else
    A-->>V: denied, reason
  end
  V-->>U: AccessDecision
```

## 9. Sequence — built-in login (authMode jwt)

```mermaid
sequenceDiagram
  actor B as Browser (Fiori)
  participant AC as AuthController
  participant UC as AccessUseCase
  participant H as Pbkdf2PasswordHasher
  participant I as Hs256TokenIssuer
  participant OD as OData controller
  B->>AC: GET /auth/config
  AC-->>B: {mode: jwt, loginRequired: true}
  B->>AC: POST /auth/login {username, password}
  AC->>UC: login
  UC->>H: verify(password, hash)
  alt wrong / unknown / locked
    UC-->>AC: unauthorized (failed logins counted, lock after 5)
    AC-->>B: 401
  else
    UC->>I: issue(tenant, user, scopes)
    I-->>UC: HS256 JWT (sub, zid, scope[], exp)
    AC-->>B: {access_token, expires_in, user}
  end
  B->>OD: GET /odata/v4/datasphere/Spaces (Authorization: Bearer …)
  OD->>OD: verify signature + expiry, enforce entity set scopes
  OD-->>B: 200 / 401 / 403
```

## 10. Deployment

```mermaid
flowchart LR
  subgraph BTP[SAP BTP Cloud Foundry — mta.yaml]
    AR[datasphere-approuter<br/>Fiori app in resources/] -->|destination datasphere-srv<br/>forwardAuthToken| SRV[datasphere-srv<br/>binary_buildpack]
    AR --- XS[(datasphere-xsuaa)]
    SRV --- XS
    SRV --- CFG[(datasphere-config<br/>user-provided)]
  end
  subgraph K8S[Kubernetes — k8s/]
    SVC[Service :8095] --> POD[Deployment 1 replica<br/>uim-platform/datasphere]
    POD --- PVC[(PVC /data<br/>datasphere.json)]
    POD --- CM[(ConfigMap)]
    POD --- SEC[(Secret: JWT secret,<br/>admin password)]
  end
```
