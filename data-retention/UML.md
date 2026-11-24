# UML — UIM Data Retention

Diagrams of the redesigned service (backend 2.0). Mermaid renders them on GitHub/GitLab and in most Markdown viewers.

## 1. Domain model

```mermaid
classDiagram
  direction LR
  class ApplicationGroup {
    +ApplicationGroupId id
    +string name
    +ApplicationGroupScope scope_
    +string[] applicationIds
    +bool active
  }
  class LegalEntity {
    +LegalEntityId id
    +string name
    +string country  ISO 3166-1
    +string region
    +bool active
  }
  class DataSubjectRole {
    +DataSubjectRoleId id
    +string name
    +bool active
  }
  class BusinessPurpose {
    +BusinessPurposeId id
    +string name
    +BusinessPurposeStatus status
    +long activatedAt
    +activate(now)
    +deactivate()
    +deprecate()
    +appliesRules() bool
  }
  class LegalGround {
    +LegalGroundId id
    +string name
    +LegalGroundType type
    +string legalReference
    +bool active
  }
  class ResidenceRule {
    +RetentionPeriod period
    +bool active
  }
  class RetentionRule {
    +RetentionPeriod period
    +DeletionAction actionOnExpiry
    +bool active
  }
  class RetentionPeriod {
    <<value>>
    +int duration
    +PeriodUnit unit
    +addTo(stdTime) long
    +text() string
  }
  class DataSubject {
    +DataSubjectId id
    +string externalId  personal data
    +string displayName  personal data
    +long referenceDate
    +LifecycleStatus lifecycleStatus
    +bool legalHold
    +RetentionEvaluation evaluation  derived
    +block(now)
    +archive(now)
    +markForDeletion(now)
    +destroy(now, method)
    +setLegalHold(hold, reason)
  }
  class DeletionRequest {
    +DeletionAction action
    +DeletionRequestStatus status
    +string reason
    +long earliestDeletionAt
    +complete() reject() fail() cancel()
  }
  class ArchivingJob {
    +ArchivingOperation operation
    +JobStatus status
    +bool dryRun
    +long referenceBefore
    +long scheduledAt
    +long selected archived destroyed skipped failed
    +start() finish() fail() cancel()
  }
  class UserAccount {
    +UserAccountId id
    +string passwordHash
    +string[] scopes
    +bool locked
    +int failedLogins
    +long lockedUntil
  }
  class RetentionEvaluation {
    <<derived>>
    +RetentionPhase phase
    +LegalGroundId governingLegalGroundId
    +long endOfPurpose
    +long endOfRetention
    +DeletionAction actionOnExpiry
    +dueForBlocking(status) bool
    +dueForDestruction(status, hold) bool
  }

  BusinessPurpose --> ApplicationGroup : for
  BusinessPurpose --> DataSubjectRole : about
  BusinessPurpose --> "0..1" LegalEntity : under
  BusinessPurpose "1" *-- "*" LegalGround : legal grounds
  LegalGround "1" *-- "0..1" ResidenceRule
  LegalGround "1" *-- "0..1" RetentionRule
  ResidenceRule *-- RetentionPeriod
  RetentionRule *-- RetentionPeriod
  DataSubject --> BusinessPurpose : processed for
  DataSubject --> ApplicationGroup
  DataSubject --> "0..1" LegalGround : restricted to
  DataSubject --> "0..1" DataSubjectRole
  DataSubject --> "0..1" LegalEntity
  DataSubject ..> RetentionEvaluation : evaluated as
  DeletionRequest --> DataSubject
  ArchivingJob --> ApplicationGroup
```

All entities mix in `TenantEntity` (tenantId, id, createdAt/By, updatedAt/By). Enumerations are string valued:
`ApplicationGroupScope`, `BusinessPurposeStatus`, `LegalGroundType`, `PeriodUnit`, `DeletionAction`,
`LifecycleStatus`, `RetentionPhase`, `DeletionRequestStatus`, `ArchivingOperation`, `JobStatus`.

## 2. Hexagonal components

```mermaid
flowchart TB
  subgraph Presentation["presentation (driving adapters)"]
    ODATA["odata<br/>ODataController + dataRetentionEngine"]
    REST["http<br/>DrApiController · AuthController · DrHealthController"]
    WEB["web<br/>FrontendController (/app)"]
    CLI["cli<br/>buildDrCli"]
    GUI["gui<br/>runDrGui (GtkD)"]
    WORKER["infrastructure/workers<br/>RetentionWorker (timers)"]
  end
  subgraph Ports["ports"]
    DP["DrPorts (driving)<br/>IManageResource&lt;E,Id,Input&gt;, IManageBusinessPurposes,<br/>IManageDataSubjects, IRetentionChecks, IManageDeletionRequests,<br/>IManageArchivingJobs, IDrStatisticsService, IDrLookups, IAuthenticate, IManageUsers"]
    DRV["driven<br/>IDrRepository&lt;E,Id&gt; ×11 · IDrUnitOfWork · IDrEventPublisher<br/>IClock · IPasswordHasher · ITokenIssuer"]
  end
  subgraph Application["application"]
    UC["usecases<br/>ResourceInteractor&lt;E,Id,Input&gt; → master data, purposes, grounds, rules, data subjects<br/>RetentionChecksUseCase · ManageDeletionRequestsUseCase · ManageArchivingJobsUseCase · AccessUseCase"]
    SVC["services<br/>RuleBook · DrStatisticsService · DrLookupsService · seedDemoData · DrPolicy"]
  end
  subgraph Domain["domain"]
    ENT["entities · types · enumerations · exceptions"]
    EVAL["services<br/>evaluateRetention()"]
  end
  subgraph Persistence["persistence (driven adapters)"]
    REPO["DocumentRepository&lt;E,Id&gt; → 11 repositories"]
    MAP["mappers<br/>entityToRecord / recordToEntity (compile-time reflection)"]
    STORE["storages<br/>BatchingMemoryDocumentStore · BatchingFileDocumentStore"]
  end
  subgraph Infra["infrastructure"]
    CFG["configuration<br/>DrConfig / loadDrConfig"]
    SEC["security<br/>SecuritySetup · Hs256TokenIssuer · Pbkdf2PasswordHasher · Rs256 (XSUAA)"]
    LOG["logging<br/>LoggingEventPublisher"]
    CLK["clients<br/>SystemClock / ManualClock"]
    CON["DrContainer (composition root)"]
  end

  ODATA & REST & CLI & GUI --> DP
  WORKER --> DP
  DP -.implemented by.-> UC
  UC --> SVC --> EVAL
  UC --> ENT
  UC --> DRV
  REPO & STORE -.implement.-> DRV
  REPO --> MAP
  SEC & LOG & CLK -.implement.-> DRV
  CON --> UC & REPO & STORE & SEC & CFG
```

Dependencies point inwards: the domain knows nothing about ports, the application only about ports and domain,
adapters only about ports. `DrContainer` wires everything once for server, CLI and GUI.

## 3. Lifecycle of a data subject

```mermaid
stateDiagram-v2
  [*] --> active : registered
  active --> blocked : end of purpose (check) / block / rejected erasure
  active --> archived : archiving job (blocks first)
  blocked --> archived : archiving job
  active --> markedForDeletion : end of retention (check)
  blocked --> markedForDeletion : end of retention (check)
  archived --> markedForDeletion : end of retention (check)
  markedForDeletion --> blocked : legal hold set (not archived)
  markedForDeletion --> archived : legal hold set (archived)
  active --> deleted : erasure without retention obligation
  blocked --> deleted : destruction (job / request)
  archived --> deleted : destruction (job / request)
  markedForDeletion --> deleted : destruction (job / request)
  deleted --> [*] : tombstone (no personal data)
  note right of markedForDeletion : legal hold forbids marking and destruction
```

## 4. Retention phases

```mermaid
stateDiagram-v2
  direction LR
  noRule : noRule\n(purpose inactive or no residence rule)
  withinResidence : withinResidence\n(now < end of purpose)
  withinRetention : withinRetention\n(end of purpose ≤ now < end of retention)
  endOfRetention : endOfRetention\n(now ≥ end of retention)
  [*] --> noRule
  [*] --> withinResidence
  withinResidence --> withinRetention : time passes
  withinRetention --> endOfRetention : time passes
```

## 5. Sequence — end-of-purpose check

```mermaid
sequenceDiagram
  actor DPO as Data protection officer
  participant UI as Fiori app
  participant OD as ODataController
  participant EN as ODataEngine
  participant UC as RetentionChecksUseCase
  participant RB as RuleBook
  participant EV as evaluateRetention
  participant RP as DataSubjectRepository
  participant ST as BatchingFileDocumentStore

  DPO->>UI: Check End of Purpose (group, simulate?)
  UI->>OD: POST /CheckEndOfPurpose {applicationGroupId, simulate}
  OD->>OD: verify bearer token, resolve tenant
  OD->>EN: invoke(ctx, "CheckEndOfPurpose")
  EN->>EN: checkScope(Manage)
  EN->>UC: checkEndOfPurpose(request)
  UC->>RP: findByReference(applicationGroupId)
  UC->>ST: batch { … }
  loop every data subject not destroyed
    UC->>RB: evaluate(subject, now)
    RB->>RB: rules of the purpose (cached)
    RB->>EV: referenceDate, legal ground rules, now
    EV-->>UC: phase, end of purpose / retention
    alt end of retention, no legal hold
      UC->>RP: save(markForDeletion)
    else past end of purpose and active
      UC->>RP: save(block)
    end
  end
  ST-->>ST: one snapshot write
  UC-->>OD: EndOfPurposeCheckResult
  OD-->>UI: 200 {checked, blocked, markedForDeletion, legalHolds}
```

## 6. Sequence — erasure request against a retention obligation

```mermaid
sequenceDiagram
  participant W as RetentionWorker
  participant UC as ManageDeletionRequestsUseCase
  participant RB as RuleBook
  participant DS as DataSubject
  W->>UC: processPending(tenant)
  UC->>RB: evaluate(subject)
  alt legal hold
    UC->>DS: block(); request.reject("legal hold")
  else endOfRetention or retention = 0
    UC->>DS: destroy(delete | anonymize)
    UC-->>UC: request.complete()
  else retention obligation open
    UC->>DS: block()
    UC-->>UC: request.reject(earliestDeletion = end of retention)
  end
```

## 7. Sequence — built-in login (authMode jwt)

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
    A-->>C: {access_token, expires_in, scope, user}
    C->>C: sessionStorage; ODataModel with Authorization header
  end
```

## 8. Deployment

```mermaid
flowchart LR
  B[Browser] -->|HTTPS| AR["approuter<br/>(Node.js, XSUAA login)"]
  AR -->|"/odata, /api, /auth (forwardAuthToken)"| BE["data-retention-srv<br/>(D binary, binary_buildpack)"]
  AR -->|static| RES["resources/ (Fiori app)"]
  AR <--> XS[(XSUAA)]
  BE <--> XS
  BE --- CFG[(data-retention-config<br/>user-provided)]
  BE --- FS[(data/data-retention.json)]
```
