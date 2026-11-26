# UML — UIM Application Autoscaler

Diagrams in Mermaid. They describe version 2.0 of the service (`backend/source/uim/platform/application_autoscaler`).

## 1. Domain model

```mermaid
classDiagram
  direction LR

  class TenantEntity {
    <<mixin>>
    TenantId tenantId
    Id id
    UserId createdBy
    long createdAt
    UserId updatedBy
    long updatedAt
  }

  class AppBinding {
    string name
    string appGuid
    string serviceInstanceId
    string description
    ScalingPolicyId policyId
    BindingStatus status
    int currentInstances
    long lastScaledAt
    long lastEvaluatedAt
    string lastDecision
    hasPolicy() bool
    isAutoscaled() bool
    validate()
  }

  class ScalingPolicy {
    string name
    string description
    int instanceMinCount
    int instanceMaxCount
    string timezone
    PolicyStatus status
    MetricAllowFrom customMetricAllowFrom
    isActive() bool
    limit(int) int
    validate()
  }

  class ScalingRule {
    ScalingPolicyId policyId
    MetricType metricType
    string customMetricName
    ComparisonOperator operator
    double threshold
    int breachDurationSeconds
    int coolDownSeconds
    string adjustment
    bool enabled
    metricName() string
    direction() ScalingDirection
    validate()
  }

  class ScalingSchedule {
    ScalingPolicyId policyId
    string name
    ScheduleKind kind
    string startTime
    string endTime
    string[] daysOfWeek
    string[] daysOfMonth
    string startDate
    string endDate
    string startDateTime
    string endDateTime
    int instanceMinCount
    int instanceMaxCount
    int initialMinInstanceCount
    bool enabled
    activeSince(now, zone) long
    occursOn(Date) bool
    validate()
  }

  class MetricSample {
    AppBindingId bindingId
    string metricName
    double value
    string unit
    long measuredAt
    string source
    isCustom() bool
  }

  class ScalingEvent {
    AppBindingId bindingId
    ScalingPolicyId policyId
    ScalingRuleId ruleId
    ScheduleId scheduleId
    ScalingTrigger trigger
    ScalingDirection direction
    ScalingStatus status
    int oldInstances
    int newInstances
    string metricName
    double metricValue
    double threshold
    string reason
    string message
  }

  class UserAccount {
    string displayName
    string passwordHash
    string[] scopes
    bool locked
    int failedLogins
    long lockedUntil
    long lastLoginAt
    isLockedAt(now) bool
    recordFailure(now, max, lockSeconds)
    recordSuccess(now)
  }

  class Adjustment {
    <<value>>
    int amount
    bool percent
    applyTo(int) int
    scalesOut() bool
  }

  class MetricType {
    <<enumeration>>
    cpu
    cpuutil
    memoryused
    memoryutil
    disk
    diskutil
    throughput
    responsetime
    custom
  }

  class ScalingTrigger {
    <<enumeration>>
    dynamic
    schedule
    limits
    manual
  }

  TenantEntity <|.. AppBinding
  TenantEntity <|.. ScalingPolicy
  TenantEntity <|.. ScalingRule
  TenantEntity <|.. ScalingSchedule
  TenantEntity <|.. MetricSample
  TenantEntity <|.. ScalingEvent
  TenantEntity <|.. UserAccount

  AppBinding "0..*" --> "0..1" ScalingPolicy : policyId
  ScalingPolicy "1" *-- "0..*" ScalingRule : policyId
  ScalingPolicy "1" *-- "0..*" ScalingSchedule : policyId
  AppBinding "1" *-- "0..*" MetricSample : bindingId
  AppBinding "1" *-- "0..*" ScalingEvent : bindingId
  ScalingEvent "0..*" --> "0..1" ScalingRule : ruleId
  ScalingEvent "0..*" --> "0..1" ScalingSchedule : scheduleId
  ScalingRule ..> Adjustment : parses
  ScalingRule ..> MetricType
  ScalingEvent ..> ScalingTrigger
```

Composition (`*--`) means a cascade on delete: deleting a policy removes its rules and schedules, deleting a binding
removes its samples and history. A policy referenced by bindings cannot be deleted.

## 2. Hexagonal components

```mermaid
flowchart LR
  subgraph presentation[presentation — driving adapters]
    ODATA[OData v4 controller + ODataEngine]
    REST[AasApiController /api/v1/autoscaler]
    AUTH[AuthController /auth]
    HEALTH[AasHealthController /health]
    WEB[FrontendController /app]
    CLI[CLI commands]
    GUI[GtkD entity browser]
  end
  subgraph ports[ports]
    UC[[IManageBindings · IManagePolicies · IManageRules · IManageSchedules
    IManageMetrics · IScalingEngine · IAuthenticate · IManageUsers]]
    STAT[[IAasStatisticsService]]
    REPO[[IAasRepository&lt;E,Id&gt; ×7]]
    UOW[[IAasUnitOfWork]]
    GW[[IInstanceController · IClock · IPasswordHasher · ITokenIssuer]]
    EV[[IAasEventPublisher]]
  end
  subgraph application[application]
    INT[ManageBindingsUseCase · ManagePoliciesUseCase · ManageRulesUseCase · ManageSchedulesUseCase
    ManageMetricsUseCase · ScalingEngineUseCase · AccessUseCase]
    SVC[AasStatisticsService · capabilities · demo data]
  end
  subgraph domain[domain]
    ENT[entities · types · enumerations · exceptions]
    DS[rule evaluator · scaling decider]
  end
  subgraph persistence[persistence]
    DR[DocumentRepository&lt;E,Id&gt; + mappers]
    ST[BatchingFileDocumentStore / BatchingMemoryDocumentStore]
  end
  subgraph infrastructure[infrastructure]
    INS[SimulatedInstanceController / HttpInstanceController]
    SEC[SecuritySetup · Hs256TokenIssuer · Pbkdf2PasswordHasher · RS256 XSUAA verifier]
    WRK[ScalingWorker + WorkerMetrics]
    CFG[AasConfig loader]
    LOG[LoggingEventPublisher]
    CON[AasContainer — composition root]
  end

  ODATA & REST & CLI & GUI --> UC
  AUTH --> UC
  WRK --> UC
  UC -.implemented by.-> INT
  STAT -.implemented by.-> SVC
  INT --> ENT & DS
  INT --> REPO & UOW & GW & EV
  REPO -.implemented by.-> DR --> ST
  UOW -.implemented by.-> ST
  GW -.implemented by.-> INS & SEC
  EV -.implemented by.-> LOG
  CON --> CFG & SEC & INS & DR & INT & ODATA
```

Dependencies point inwards: the domain knows nothing of vibe.d, JSON stores or HTTP; the scaling decision is a pure
function of binding, policy, rules, schedules, samples and time; use cases see only ports; the container wires
adapters to ports once for server, CLI and GUI.

## 3. Binding states

```mermaid
stateDiagram-v2
  [*] --> Unmanaged : create (no policy)
  [*] --> Autoscaled : create with policy
  Unmanaged --> Autoscaled : AttachPolicy
  Autoscaled --> Unmanaged : DetachPolicy
  Autoscaled --> Suspended : SuspendBinding
  Suspended --> Autoscaled : ResumeBinding
  Autoscaled --> Autoscaled : EvaluateBinding / worker (instances change)
  Autoscaled --> Autoscaled : ScaleBinding (manual)
  Suspended --> Suspended : ScaleBinding (manual)
  Unmanaged --> Unmanaged : ScaleBinding (manual, 1…1000)
  Autoscaled --> Paused : DeactivatePolicy
  Paused --> Autoscaled : ActivatePolicy
  Unmanaged --> [*] : delete (samples + history removed)
  Suspended --> [*] : delete
  Autoscaled --> [*] : delete

  note right of Paused : policy inactive — the engine skips the binding
```

## 4. Policy and schedule states

```mermaid
stateDiagram-v2
  state Policy {
    [*] --> active : create
    active --> inactive : DeactivatePolicy
    inactive --> active : ActivatePolicy
    active --> [*] : delete (only without bindings)
    inactive --> [*] : delete (only without bindings)
    active --> inactiveCopy : CopyPolicy
    inactiveCopy : inactive copy with all rules and schedules
  }
  state Schedule {
    [*] --> waiting
    waiting --> applying : start time reached (policy time zone)
    applying --> waiting : end time reached
    applying --> applying : limits replace the policy limits;\ninitial minimum applied once
    waiting --> disabled : enabled = false
    disabled --> waiting : enabled = true
  }
```

## 5. Scaling decision (activity)

```mermaid
flowchart TD
  S([evaluate binding]) --> A{suspended · no policy ·\npolicy inactive?}
  A -- yes --> SKIP[ignored: reason stored on the binding]
  A -- no --> L[limits = active specific-date schedule\nelse active recurring schedule\nelse policy]
  L --> B{instances outside\nthe limits?}
  B -- yes --> T1[target = clamp — trigger limits / schedule]
  B -- no --> C{schedule just started and\ninstances < initial minimum?}
  C -- yes --> T2[target = initial minimum — trigger schedule]
  C -- no --> R[check each enabled rule:\nfresh newest sample · comparison held\nfor the breach duration]
  R --> D{breached rules outside\ntheir cool-down?}
  D -- no --> NONE[ignored: no breach / cooling down / stale]
  D -- yes --> P[scale-out rules first — largest target\nelse scale-in — smallest reduction\ntarget limited to the limits]
  P --> E{target ≠ instances?}
  E -- no --> NONE
  E -- yes --> T3[target — trigger dynamic]
  T1 & T2 & T3 --> X[IInstanceController.scale]
  X --> F{platform ok?}
  F -- yes --> OK[event succeeded · binding.currentInstances = reported · lastScaledAt = now]
  F -- no --> KO[event failed · instances unchanged]
  NONE --> REC{recordIgnored?}
  REC -- yes --> IGN[event ignored]
```

## 6. Sequence — metrics, evaluation and scaling

```mermaid
sequenceDiagram
  autonumber
  participant App as Bound application / collector
  participant API as REST /apps/{guid}/metrics
  participant M as ManageMetricsUseCase
  participant W as ScalingWorker (timer)
  participant E as ScalingEngineUseCase
  participant D as decideScaling (domain)
  participant P as IInstanceController
  participant R as Repositories

  App->>API: POST {metricName: "jobqueue", value: 240}
  API->>M: submit(appGuid, …) — scope Operate
  M->>R: binding by appGuid · sender check (sameApp / boundApp)
  M->>R: save MetricSample
  API-->>App: 201 {count, resources}

  W->>E: evaluateAll(tenant) every evaluationIntervalSeconds
  E->>R: bindings, active policies (one batch)
  loop each autoscaled binding
    E->>R: rules, schedules, samples
    E->>D: decideScaling(binding, policy, rules, schedules, samples, now, stale)
    D-->>E: ScalingDecision (trigger, target, rule, limits, reason)
    alt target ≠ current
      E->>P: scale(appGuid, current, target, reason)
      P-->>E: success, instances, message
      E->>R: save ScalingEvent · update binding (instances, lastScaledAt)
    else nothing to do
      E->>R: update binding (lastEvaluatedAt, lastDecision)
    end
  end
  E-->>W: EvaluationSummary
```

## 7. Sequence — Fiori evaluation of one binding

```mermaid
sequenceDiagram
  autonumber
  actor U as Operator
  participant UI as Fiori BindingDetail
  participant OD as ODataController
  participant EN as ODataEngine
  participant E as ScalingEngineUseCase

  U->>UI: press "Preview"
  UI->>OD: POST /odata/v4/autoscaler/PreviewScaling {id}
  OD->>EN: invoke (scope Read)
  EN->>E: preview(tenant, id)
  E-->>UI: EvaluationResult (status "preview") → message box
  U->>UI: press "Evaluate"
  UI->>OD: POST EvaluateBinding {id} (Bearer token)
  OD->>EN: invoke (scope Operate)
  EN->>E: evaluate(tenant, id, actor)
  E-->>UI: EvaluationResult (succeeded / ignored / failed, eventId)
  UI->>OD: refresh Bindings · ScalingEvents · Statistics
```

## 8. Sequence — built-in login (authMode jwt)

```mermaid
sequenceDiagram
  autonumber
  actor U as User
  participant C as Fiori Component
  participant A as AuthController
  participant AC as AccessUseCase
  participant H as Pbkdf2PasswordHasher
  participant T as Hs256TokenIssuer
  participant OD as OData / REST

  C->>A: GET /auth/config
  A-->>C: {mode: "jwt", loginRequired: true}
  C->>U: login dialog
  U->>C: user, password, tenant?
  C->>A: POST /auth/login
  A->>AC: login(tenant, user, password)
  AC->>H: verify(password, hash) — dummy hash for unknown users
  alt wrong or locked
    AC-->>A: unauthorized (failed logins counted, lock after maxFailedLogins)
    A-->>C: 401
  else ok
    AC->>T: issue(tenant, user, scopes)
    T-->>AC: HS256 JWT (sub, user_name, zid, scope[], exp, jti)
    A-->>C: {access_token, expires_in, scope, user}
    C->>C: sessionStorage · OData model with Authorization header
    C->>OD: GET /odata/v4/autoscaler/$metadata, Bindings, Statistics …
    OD-->>C: 200 (scopes enforced per set and action)
  end
```

## 9. Deployment

```mermaid
flowchart TB
  subgraph BTP[SAP BTP · Cloud Foundry — mta.yaml]
    AR[application-autoscaler-approuter\n@sap/approuter + Fiori resources]
    SRV[application-autoscaler-srv\nbinary buildpack · D executable]
    XS[(XSUAA\napplication-autoscaler-xsuaa)]
    UPS[(user-provided service\napplication-autoscaler-config)]
    AR -- destination application-autoscaler-srv\nforwardAuthToken --> SRV
    AR -. login .-> XS
    SRV -. verificationkey .-> XS
    SRV -. overrides .-> UPS
  end
  subgraph K8S[Kubernetes — k8s/]
    POD[Deployment application-autoscaler\n1 replica · Recreate]
    PVC[(PVC application-autoscaler-data\n/data snapshot)]
    CM[ConfigMap] --> POD
    SEC[Secret jwt secret · admin password] --> POD
    POD --> PVC
    SVC[Service :80 → 8097] --> POD
  end
  PLAT[Platform adapter\ninstanceMode http] <-. POST instances .- SRV
  PLAT <-. POST instances .- POD
  Browser((Browser)) --> AR
  Browser --> SVC
```
