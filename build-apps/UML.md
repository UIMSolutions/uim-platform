# Build Apps — UML Diagrams

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class Application {
        +ApplicationId id
        +TenantId tenantId
        +string name
        +string description
        +ApplicationType type
        +ApplicationStatus status
        +string version_
        +string owner
        +string iconUrl
        +string themeConfig
        +string globalStyles
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +applicationToJson() Json
    }

    class Page {
        +PageId id
        +TenantId tenantId
        +ApplicationId applicationId
        +string name
        +string description
        +PageType type
        +string layoutConfig
        +string componentTree
        +string styleOverrides
        +string dataBindings
        +string navigationConfig
        +int sortOrder
        +bool isHomePage
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +pageToJson() Json
    }

    class UIComponent {
        +UIComponentId id
        +TenantId tenantId
        +string name
        +string description
        +ComponentCategory category
        +ComponentStatus status
        +string version_
        +string propertySchema
        +string eventDefinitions
        +string styleProperties
        +string iconUrl
        +string previewUrl
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +uiComponentToJson() Json
    }

    class DataEntity {
        +DataEntityId id
        +TenantId tenantId
        +ApplicationId applicationId
        +string name
        +string description
        +DataEntityStatus status
        +string fields
        +string validationRules
        +string defaultValues
        +string indexes
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +dataEntityToJson() Json
    }

    class DataConnection {
        +DataConnectionId id
        +TenantId tenantId
        +ApplicationId applicationId
        +string name
        +string description
        +ConnectionType type
        +ConnectionStatus status
        +AuthMethod authMethod
        +string endpoint
        +string credentials
        +string schema_
        +string mappingConfig
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +dataConnectionToJson() Json
    }

    class LogicFlow {
        +LogicFlowId id
        +TenantId tenantId
        +ApplicationId applicationId
        +PageId pageId
        +string name
        +string description
        +FlowTrigger trigger
        +FlowStatus status
        +string steps
        +string variables
        +string errorHandling
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +logicFlowToJson() Json
    }

    class AppBuild {
        +AppBuildId id
        +TenantId tenantId
        +ApplicationId applicationId
        +string name
        +string description
        +BuildTarget buildTarget
        +BuildStatus buildStatus
        +string version_
        +string buildConfig
        +string signingConfig
        +string artifactUrl
        +string buildLog
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +appBuildToJson() Json
    }

    class ProjectMember {
        +ProjectMemberId id
        +TenantId tenantId
        +ApplicationId applicationId
        +string userId
        +string displayName
        +string email
        +MemberRole role
        +MemberStatus status
        +string permissions
        +string invitedAt
        +string joinedAt
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +projectMemberToJson() Json
    }

    Application "1" --> "*" Page : contains
    Application "1" --> "*" DataEntity : defines
    Application "1" --> "*" DataConnection : connects
    Application "1" --> "*" LogicFlow : uses
    Application "1" --> "*" AppBuild : builds
    Application "1" --> "*" ProjectMember : members
    Page "1" --> "*" LogicFlow : triggers
```

## Class Diagram — Repository Interfaces

```mermaid
classDiagram
    class ApplicationRepository {
        <<interface>>
        +existsById(ApplicationId) bool
        +findById(ApplicationId) Application
        +findAll() Application[]
        +findByTenant(TenantId) Application[]
        +findByOwner(string) Application[]
        +findByStatus(ApplicationStatus) Application[]
        +save(Application)
        +update(Application)
        +remove(ApplicationId)
    }

    class PageRepository {
        <<interface>>
        +existsById(PageId) bool
        +findById(PageId) Page
        +findAll() Page[]
        +findByTenant(TenantId) Page[]
        +findByApplication(ApplicationId) Page[]
        +save(Page)
        +update(Page)
        +remove(PageId)
    }

    class DataEntityRepository {
        <<interface>>
        +existsById(DataEntityId) bool
        +findById(DataEntityId) DataEntity
        +findAll() DataEntity[]
        +findByTenant(TenantId) DataEntity[]
        +findByApplication(ApplicationId) DataEntity[]
        +save(DataEntity)
        +update(DataEntity)
        +remove(DataEntityId)
    }

    class DataConnectionRepository {
        <<interface>>
        +existsById(DataConnectionId) bool
        +findById(DataConnectionId) DataConnection
        +findAll() DataConnection[]
        +findByTenant(TenantId) DataConnection[]
        +findByApplication(ApplicationId) DataConnection[]
        +findByType(ConnectionType) DataConnection[]
        +save(DataConnection)
        +update(DataConnection)
        +remove(DataConnectionId)
    }

    class MemoryApplicationRepository {
        -Application[] store
    }
    class MemoryPageRepository {
        -Page[] store
    }
    class MemoryDataEntityRepository {
        -DataEntity[] store
    }
    class MemoryDataConnectionRepository {
        -DataConnection[] store
    }

    ApplicationRepository <|.. MemoryApplicationRepository
    PageRepository <|.. MemoryPageRepository
    DataEntityRepository <|.. MemoryDataEntityRepository
    DataConnectionRepository <|.. MemoryDataConnectionRepository
```

## Sequence Diagram — Create Application

```mermaid
sequenceDiagram
    participant Client
    participant ApplicationController
    participant ManageApplicationsUseCase
    participant BuildAppsValidator
    participant ApplicationRepository

    Client->>ApplicationController: POST /api/v1/build-apps/applications
    ApplicationController->>ApplicationController: Parse JSON body
    ApplicationController->>ManageApplicationsUseCase: create(dto)
    ManageApplicationsUseCase->>BuildAppsValidator: validateApplication(entity)
    BuildAppsValidator-->>ManageApplicationsUseCase: validation result
    alt Validation fails
        ManageApplicationsUseCase-->>ApplicationController: CommandResult(error)
        ApplicationController-->>Client: 400 Bad Request
    else Validation passes
        ManageApplicationsUseCase->>ApplicationRepository: save(entity)
        ApplicationRepository-->>ManageApplicationsUseCase: saved
        ManageApplicationsUseCase-->>ApplicationController: CommandResult(success, id)
        ApplicationController-->>Client: 201 Created {id, message}
    end
```

## Sequence Diagram — Build App for Target Platform

```mermaid
sequenceDiagram
    participant Client
    participant AppBuildController
    participant ManageAppBuildsUseCase
    participant AppBuildRepository

    Client->>AppBuildController: POST /api/v1/build-apps/app-builds
    AppBuildController->>AppBuildController: Parse build config
    AppBuildController->>ManageAppBuildsUseCase: create(dto)
    ManageAppBuildsUseCase->>AppBuildRepository: save(entity)
    AppBuildRepository-->>ManageAppBuildsUseCase: saved
    ManageAppBuildsUseCase-->>AppBuildController: CommandResult(success, id)
    AppBuildController-->>Client: 201 Created {id, message}
```

## Component Diagram

```mermaid
graph TB
    subgraph Presentation
        AC[ApplicationController]
        PC[PageController]
        UIC[UIComponentController]
        DEC[DataEntityController]
        DCC[DataConnectionController]
        LFC[LogicFlowController]
        ABC[AppBuildController]
        PMC[ProjectMemberController]
        HC[HealthController]
    end

    subgraph Application
        MAU[ManageApplicationsUseCase]
        MPU[ManagePagesUseCase]
        MUIC[ManageUIComponentsUseCase]
        MDEU[ManageDataEntitiesUseCase]
        MDCU[ManageDataConnectionsUseCase]
        MLFU[ManageLogicFlowsUseCase]
        MABU[ManageAppBuildsUseCase]
        MPMU[ManageProjectMembersUseCase]
    end

    subgraph Domain
        ENT[Entities]
        REPO[Repository Interfaces]
        VAL[BuildAppsValidator]
    end

    subgraph Infrastructure
        MEM[Memory Repositories]
        CFG[AppConfig]
        CNT[Container]
    end

    AC --> MAU
    PC --> MPU
    UIC --> MUIC
    DEC --> MDEU
    DCC --> MDCU
    LFC --> MLFU
    ABC --> MABU
    PMC --> MPMU

    MAU --> REPO
    MPU --> REPO
    MUIC --> REPO
    MDEU --> REPO
    MDCU --> REPO
    MLFU --> REPO
    MABU --> REPO
    MPMU --> REPO

    MEM -.-> REPO
```
