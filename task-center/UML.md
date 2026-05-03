# Task Center Service - UML Diagrams

## Class Diagram - Domain Entities

```mermaid
classDiagram
    class Task {
        +string id
        +TenantId tenantId
        +string taskDefinitionId
        +string providerId
        +string externalTaskId
        +string title
        +string description
        +TaskStatus status
        +TaskPriority priority
        +TaskCategory category
        +string assignee
        +string creator
        +string processor
        +string sourceApplication
        +ActionType[] allowedActions
        +bool isClaimed
        +string claimedBy
        +string dueDate
        +string completedAt
    }

    class TaskDefinition {
        +string id
        +TenantId tenantId
        +string providerId
        +string name
        +string description
        +TaskCategory category
        +ActionType[] allowedActions
        +string taskSchema
        +bool isActive
        +bool requiresClaim
    }

    class TaskProvider {
        +string id
        +TenantId tenantId
        +string name
        +string description
        +ProviderType providerType
        +ProviderStatus status
        +AuthenticationType authType
        +string endpointUrl
        +string authEndpointUrl
        +string clientId
        +string lastSyncAt
        +string lastSyncError
        +long taskCount
    }

    class SubstitutionRule {
        +string id
        +TenantId tenantId
        +string userId
        +string substituteId
        +string taskDefinitionId
        +SubstitutionStatus status
        +string startDate
        +string endDate
        +bool isAutoForward
    }

    class TaskComment {
        +string id
        +TenantId tenantId
        +string taskId
        +string author
        +string content
        +string createdAt
    }

    class TaskAttachment {
        +string id
        +TenantId tenantId
        +string taskId
        +string fileName
        +string fileSize
        +string mimeType
        +AttachmentStatus status
        +string uploadedBy
    }

    class TaskAction {
        +string id
        +TenantId tenantId
        +string taskId
        +ActionType actionType
        +string performedBy
        +string forwardTo
        +string comment
        +string performedAt
    }

    class UserTaskFilter {
        +string id
        +TenantId tenantId
        +string userId
        +string name
        +string description
        +FilterCriterion[] criteria
        +bool isDefault
    }

    class FilterCriterion {
        +FilterCriterionType criterionType
        +string value
    }

    Task --> TaskDefinition : defined by
    Task --> TaskProvider : sourced from
    Task "1" --> "*" TaskComment : has
    Task "1" --> "*" TaskAttachment : has
    Task "1" --> "*" TaskAction : tracked by
    TaskDefinition --> TaskProvider : belongs to
    SubstitutionRule --> TaskDefinition : scoped to
    UserTaskFilter --> FilterCriterion : contains
```

## Class Diagram - Enumerations

```mermaid
classDiagram
    class TaskStatus {
        <<enumeration>>
        open
        inProgress
        completed
        cancelled
        failed
        forwarded
        reserved
    }

    class TaskPriority {
        <<enumeration>>
        low
        medium
        high
        veryHigh
    }

    class TaskCategory {
        <<enumeration>>
        approval
        review
        toDoItem
        notification
        action
        workflow
        informational
    }

    class ProviderType {
        <<enumeration>>
        s4hana
        successFactors
        ariba
        fieldglass
        concur
        sapBuild
        custom
    }

    class ActionType {
        <<enumeration>>
        approve
        reject
        forward
        claim
        release
        escalate
        complete
        cancel
        resubmit
    }

    class SubstitutionStatus {
        <<enumeration>>
        active
        inactive
        expired
        pending
    }
```

## Sequence Diagram - Task Processing Flow

```mermaid
sequenceDiagram
    participant Client
    participant TaskCtrl as TaskController
    participant TaskUC as ManageTasksUseCase
    participant TaskRepo as TaskRepository
    participant ActionCtrl as TaskActionController
    participant ActionUC as ManageTaskActionsUseCase
    participant ActionRepo as TaskActionRepository

    Client->>TaskCtrl: POST /tasks/:id/claim {userId}
    TaskCtrl->>TaskUC: claim(tenantId, id, userId)
    TaskUC->>TaskRepo: findById(tenantId, id)
    TaskRepo-->>TaskUC: Task
    TaskUC->>TaskRepo: update(tenantId, task)
    TaskRepo-->>TaskUC: void
    TaskUC-->>TaskCtrl: CommandResult(success)
    TaskCtrl-->>Client: 200 {id, message}

    Client->>ActionCtrl: POST /actions {taskId, actionType: claim}
    ActionCtrl->>ActionUC: create(request)
    ActionUC->>ActionRepo: save(tenantId, action)
    ActionRepo-->>ActionUC: void
    ActionUC-->>ActionCtrl: CommandResult(success)
    ActionCtrl-->>Client: 201 {id, message}

    Client->>TaskCtrl: POST /tasks/:id/complete
    TaskCtrl->>TaskUC: complete(tenantId, id)
    TaskUC->>TaskRepo: findById(tenantId, id)
    TaskRepo-->>TaskUC: Task
    TaskUC->>TaskRepo: update(tenantId, task)
    TaskRepo-->>TaskUC: void
    TaskUC-->>TaskCtrl: CommandResult(success)
    TaskCtrl-->>Client: 200 {id, message}
```

## Sequence Diagram - Task Federation (Provider Sync)

```mermaid
sequenceDiagram
    participant Admin
    participant ProvCtrl as TaskProviderController
    participant ProvUC as ManageTaskProvidersUseCase
    participant ProvRepo as TaskProviderRepository

    Admin->>ProvCtrl: POST /providers {name, type: s4hana, endpointUrl}
    ProvCtrl->>ProvUC: create(request)
    ProvUC->>ProvRepo: save(tenantId, provider)
    ProvRepo-->>ProvUC: void
    ProvUC-->>ProvCtrl: CommandResult(success)
    ProvCtrl-->>Admin: 201 {id, message}

    Admin->>ProvCtrl: POST /providers/:id/activate
    ProvCtrl->>ProvUC: activate(tenantId, id)
    ProvUC->>ProvRepo: findById(tenantId, id)
    ProvRepo-->>ProvUC: TaskProvider
    ProvUC->>ProvRepo: update(tenantId, provider)
    ProvRepo-->>ProvUC: void
    ProvUC-->>ProvCtrl: CommandResult(success)
    ProvCtrl-->>Admin: 200 {id, message}

    Admin->>ProvCtrl: POST /providers/:id/sync
    ProvCtrl->>ProvUC: sync(tenantId, id)
    ProvUC->>ProvRepo: findById(tenantId, id)
    ProvRepo-->>ProvUC: TaskProvider
    ProvUC->>ProvRepo: update(tenantId, provider)
    ProvRepo-->>ProvUC: void
    ProvUC-->>ProvCtrl: CommandResult(success)
    ProvCtrl-->>Admin: 200 {id, message}
```

## Sequence Diagram - Substitution Management

```mermaid
sequenceDiagram
    participant User
    participant SubCtrl as SubstitutionRuleController
    participant SubUC as ManageSubstitutionRulesUseCase
    participant SubRepo as SubstitutionRuleRepository

    User->>SubCtrl: POST /substitutions {userId, substituteId, startDate, endDate}
    SubCtrl->>SubUC: create(request)
    SubUC->>SubRepo: save(tenantId, rule)
    SubRepo-->>SubUC: void
    SubUC-->>SubCtrl: CommandResult(success)
    SubCtrl-->>User: 201 {id, message}

    User->>SubCtrl: POST /substitutions/:id/activate
    SubCtrl->>SubUC: activate(tenantId, id)
    SubUC->>SubRepo: findById(tenantId, id)
    SubRepo-->>SubUC: SubstitutionRule
    SubUC->>SubRepo: update(tenantId, rule)
    SubRepo-->>SubUC: void
    SubUC-->>SubCtrl: CommandResult(success)
    SubCtrl-->>User: 200 {id, message}
```

## Component Diagram

```mermaid
graph TB
    subgraph "Presentation Layer"
        TC[TaskController]
        TDC[TaskDefinitionController]
        TPC[TaskProviderController]
        TCC[TaskCommentController]
        TAC[TaskAttachmentController]
        SRC[SubstitutionRuleController]
        TACC[TaskActionController]
        UFC[UserTaskFilterController]
        HC[HealthController]
    end

    subgraph "Application Layer"
        MTU[ManageTasksUseCase]
        MTDU[ManageTaskDefinitionsUseCase]
        MTPU[ManageTaskProvidersUseCase]
        MTCU[ManageTaskCommentsUseCase]
        MTAU[ManageTaskAttachmentsUseCase]
        MSRU[ManageSubstitutionRulesUseCase]
        MTACU[ManageTaskActionsUseCase]
        MUFU[ManageUserTaskFiltersUseCase]
    end

    subgraph "Domain Layer"
        TR[TaskRepository]
        TDR[TaskDefinitionRepository]
        TPR[TaskProviderRepository]
        TCR[TaskCommentRepository]
        TAR[TaskAttachmentRepository]
        SRR[SubstitutionRuleRepository]
        TACR[TaskActionRepository]
        UFR[UserTaskFilterRepository]
        TV[TaskValidator]
    end

    subgraph "Infrastructure Layer"
        MTR[MemoryTaskRepository]
        MTDR[MemoryTaskDefinitionRepository]
        MTPR[MemoryTaskProviderRepository]
        MTCR[MemoryTaskCommentRepository]
        MTAR[MemoryTaskAttachmentRepository]
        MSRR[MemorySubstitutionRuleRepository]
        MTACR[MemoryTaskActionRepository]
        MUFR[MemoryUserTaskFilterRepository]
        CFG[AppConfig]
        CNT[Container]
    end

    TC --> MTU
    TDC --> MTDU
    TPC --> MTPU
    TCC --> MTCU
    TAC --> MTAU
    SRC --> MSRU
    TACC --> MTACU
    UFC --> MUFU

    MTU --> TR
    MTDU --> TDR
    MTPU --> TPR
    MTCU --> TCR
    MTAU --> TAR
    MSRU --> SRR
    MTACU --> TACR
    MUFU --> UFR

    MTR -.-> TR
    MTDR -.-> TDR
    MTPR -.-> TPR
    MTCR -.-> TCR
    MTAR -.-> TAR
    MSRR -.-> SRR
    MTACR -.-> TACR
    MUFR -.-> UFR
```

## State Diagram - Task Lifecycle

```mermaid
stateDiagram-v2
    [*] --> open : Task created
    open --> inProgress : claim
    open --> forwarded : forward
    open --> cancelled : cancel
    inProgress --> completed : complete
    inProgress --> open : release
    inProgress --> forwarded : forward
    inProgress --> cancelled : cancel
    inProgress --> failed : error
    forwarded --> open : accepted
    forwarded --> inProgress : claim
    reserved --> open : release
    reserved --> inProgress : claim
    completed --> [*]
    cancelled --> [*]
    failed --> open : retry
    failed --> [*]
```

## State Diagram - Provider Lifecycle

```mermaid
stateDiagram-v2
    [*] --> inactive : Provider registered
    inactive --> active : activate
    active --> inactive : deactivate
    active --> syncing : sync
    syncing --> active : sync complete
    syncing --> error : sync failed
    error --> active : activate
    error --> inactive : deactivate
```

## State Diagram - Substitution Rule Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending : Rule created
    pending --> active : activate
    active --> inactive : deactivate
    active --> expired : end date reached
    inactive --> active : activate
    expired --> [*]
```
