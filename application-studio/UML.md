# Application Studio — UML Diagrams

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class DevSpace {
        +DevSpaceId id
        +TenantId tenantId
        +string name
        +string description
        +DevSpaceStatus status
        +DevSpacePlan plan
        +DevSpaceTypeId devSpaceTypeId
        +string extensions
        +string owner
        +string region
        +string lastAccessedAt
        +string hibernateAfterDays
        +string memoryLimit
        +string diskLimit
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +devSpaceToJson() Json
    }

    class DevSpaceType {
        +DevSpaceTypeId id
        +TenantId tenantId
        +string name
        +string description
        +DevSpaceTypeCategory category
        +string predefinedExtensions
        +string supportedProjectTypes
        +string runtimeStack
        +string iconUrl
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +devSpaceTypeToJson() Json
    }

    class Extension {
        +ExtensionId id
        +TenantId tenantId
        +string name
        +string description
        +ExtensionScope scope_
        +ExtensionStatus status
        +string version_
        +string publisher
        +string category
        +string dependencies
        +string capabilities
        +string iconUrl
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +extensionToJson() Json
    }

    class Project {
        +ProjectId id
        +TenantId tenantId
        +DevSpaceId devSpaceId
        +string name
        +string description
        +ProjectType projectType
        +ProjectStatus status
        +ProjectTemplateId templateId
        +string rootPath
        +string gitRepositoryUrl
        +string gitBranch
        +string namespace_
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +projectToJson() Json
    }

    class ProjectTemplate {
        +ProjectTemplateId id
        +TenantId tenantId
        +string name
        +string description
        +TemplateCategory category
        +ProjectType targetProjectType
        +string version_
        +string requiredExtensions
        +string scaffoldConfig
        +string defaultFiles
        +string iconUrl
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +projectTemplateToJson() Json
    }

    class ServiceBinding {
        +ServiceBindingId id
        +TenantId tenantId
        +DevSpaceId devSpaceId
        +string name
        +string description
        +ServiceProviderType providerType
        +BindingStatus status
        +string serviceUrl
        +string servicePath
        +string authType
        +string credentials
        +string systemAlias
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +serviceBindingToJson() Json
    }

    class RunConfiguration {
        +RunConfigurationId id
        +TenantId tenantId
        +ProjectId projectId
        +string name
        +string description
        +RunMode mode
        +RunStatus status
        +string entryPoint
        +string arguments
        +string environmentVars
        +string port
        +string debugPort
        +string lastRunAt
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +runConfigurationToJson() Json
    }

    class BuildConfiguration {
        +BuildConfigurationId id
        +TenantId tenantId
        +ProjectId projectId
        +string name
        +string description
        +BuildStatus status
        +DeployTarget deployTarget
        +string buildCommand
        +string deployCommand
        +string artifactPath
        +string mtaDescriptor
        +string lastBuildAt
        +string lastDeployAt
        +string buildLog
        +string createdAt
        +string updatedAt
        +UserId createdBy
        +UserId modifiedBy
        +buildConfigurationToJson() Json
    }

    DevSpace --> DevSpaceType : devSpaceTypeId
    Project --> DevSpace : devSpaceId
    Project --> ProjectTemplate : templateId
    ServiceBinding --> DevSpace : devSpaceId
    RunConfiguration --> Project : projectId
    BuildConfiguration --> Project : projectId
```

## Repository Interfaces

```mermaid
classDiagram
    class DevSpaceRepository {
        <<interface>>
        +existsById(DevSpaceId) bool
        +findById(DevSpaceId) DevSpace
        +findAll() DevSpace[]
        +findByTenant(TenantId) DevSpace[]
        +findByOwner(string) DevSpace[]
        +findByStatus(DevSpaceStatus) DevSpace[]
        +save(DevSpace) void
        +update(DevSpace) void
        +remove(DevSpaceId) void
    }

    class DevSpaceTypeRepository {
        <<interface>>
        +existsById(DevSpaceTypeId) bool
        +findById(DevSpaceTypeId) DevSpaceType
        +findAll() DevSpaceType[]
        +findByTenant(TenantId) DevSpaceType[]
        +findByCategory(DevSpaceTypeCategory) DevSpaceType[]
        +save(DevSpaceType) void
        +update(DevSpaceType) void
        +remove(DevSpaceTypeId) void
    }

    class ExtensionRepository {
        <<interface>>
        +existsById(ExtensionId) bool
        +findById(ExtensionId) Extension
        +findAll() Extension[]
        +findByTenant(TenantId) Extension[]
        +findByScope(ExtensionScope) Extension[]
        +findByStatus(ExtensionStatus) Extension[]
        +save(Extension) void
        +update(Extension) void
        +remove(ExtensionId) void
    }

    class ProjectRepository {
        <<interface>>
        +existsById(ProjectId) bool
        +findById(ProjectId) Project
        +findAll() Project[]
        +findByTenant(TenantId) Project[]
        +findByDevSpace(DevSpaceId) Project[]
        +findByType(ProjectType) Project[]
        +save(Project) void
        +update(Project) void
        +remove(ProjectId) void
    }

    class ProjectTemplateRepository {
        <<interface>>
        +existsById(ProjectTemplateId) bool
        +findById(ProjectTemplateId) ProjectTemplate
        +findAll() ProjectTemplate[]
        +findByTenant(TenantId) ProjectTemplate[]
        +findByCategory(TemplateCategory) ProjectTemplate[]
        +save(ProjectTemplate) void
        +update(ProjectTemplate) void
        +remove(ProjectTemplateId) void
    }

    class ServiceBindingRepository {
        <<interface>>
        +existsById(ServiceBindingId) bool
        +findById(ServiceBindingId) ServiceBinding
        +findAll() ServiceBinding[]
        +findByTenant(TenantId) ServiceBinding[]
        +findByDevSpace(DevSpaceId) ServiceBinding[]
        +findByStatus(BindingStatus) ServiceBinding[]
        +save(ServiceBinding) void
        +update(ServiceBinding) void
        +remove(ServiceBindingId) void
    }

    class RunConfigurationRepository {
        <<interface>>
        +existsById(RunConfigurationId) bool
        +findById(RunConfigurationId) RunConfiguration
        +findAll() RunConfiguration[]
        +findByTenant(TenantId) RunConfiguration[]
        +findByProject(ProjectId) RunConfiguration[]
        +save(RunConfiguration) void
        +update(RunConfiguration) void
        +remove(RunConfigurationId) void
    }

    class BuildConfigurationRepository {
        <<interface>>
        +existsById(BuildConfigurationId) bool
        +findById(BuildConfigurationId) BuildConfiguration
        +findAll() BuildConfiguration[]
        +findByTenant(TenantId) BuildConfiguration[]
        +findByProject(ProjectId) BuildConfiguration[]
        +findByStatus(BuildStatus) BuildConfiguration[]
        +save(BuildConfiguration) void
        +update(BuildConfiguration) void
        +remove(BuildConfigurationId) void
    }

    MemoryDevSpaceRepository ..|> DevSpaceRepository
    MemoryDevSpaceTypeRepository ..|> DevSpaceTypeRepository
    MemoryExtensionRepository ..|> ExtensionRepository
    MemoryProjectRepository ..|> ProjectRepository
    MemoryProjectTemplateRepository ..|> ProjectTemplateRepository
    MemoryServiceBindingRepository ..|> ServiceBindingRepository
    MemoryRunConfigurationRepository ..|> RunConfigurationRepository
    MemoryBuildConfigurationRepository ..|> BuildConfigurationRepository
```

## Use Case Diagram

```mermaid
graph LR
    Developer((Developer))
    Admin((Admin))

    Developer --> ManageDevSpaces[Manage Dev Spaces]
    Developer --> ManageProjects[Manage Projects]
    Developer --> ManageRunConfigurations[Manage Run Configurations]
    Developer --> ManageBuildConfigurations[Manage Build Configurations]
    Developer --> ManageServiceBindings[Manage Service Bindings]

    Admin --> ManageDevSpaceTypes[Manage Dev Space Types]
    Admin --> ManageExtensions[Manage Extensions]
    Admin --> ManageProjectTemplates[Manage Project Templates]
```

## Component Diagram

```mermaid
graph TB
    subgraph Presentation
        DSC[DevSpaceController]
        DSTC[DevSpaceTypeController]
        EC[ExtensionController]
        PC[ProjectController]
        PTC[ProjectTemplateController]
        SBC[ServiceBindingController]
        RCC[RunConfigurationController]
        BCC[BuildConfigurationController]
        HC[HealthController]
    end

    subgraph Application
        MDSU[ManageDevSpacesUseCase]
        MDSTU[ManageDevSpaceTypesUseCase]
        MEU[ManageExtensionsUseCase]
        MPU[ManageProjectsUseCase]
        MPTU[ManageProjectTemplatesUseCase]
        MSBU[ManageServiceBindingsUseCase]
        MRCU[ManageRunConfigurationsUseCase]
        MBCU[ManageBuildConfigurationsUseCase]
    end

    subgraph Infrastructure
        MDSR[MemoryDevSpaceRepository]
        MDSTR[MemoryDevSpaceTypeRepository]
        MER[MemoryExtensionRepository]
        MPR[MemoryProjectRepository]
        MPTR[MemoryProjectTemplateRepository]
        MSBR[MemoryServiceBindingRepository]
        MRCR[MemoryRunConfigurationRepository]
        MBCR[MemoryBuildConfigurationRepository]
    end

    DSC --> MDSU --> MDSR
    DSTC --> MDSTU --> MDSTR
    EC --> MEU --> MER
    PC --> MPU --> MPR
    PTC --> MPTU --> MPTR
    SBC --> MSBU --> MSBR
    RCC --> MRCU --> MRCR
    BCC --> MBCU --> MBCR
```

## Sequence Diagram — Create Dev Space

```mermaid
sequenceDiagram
    participant Client
    participant DevSpaceController
    participant ManageDevSpacesUseCase
    participant StudioValidator
    participant MemoryDevSpaceRepository

    Client->>DevSpaceController: POST /api/v1/application-studio/dev-spaces
    DevSpaceController->>ManageDevSpacesUseCase: create(DevSpaceDTO)
    ManageDevSpacesUseCase->>StudioValidator: isValidDevSpace(devSpace)
    StudioValidator-->>ManageDevSpacesUseCase: true
    ManageDevSpacesUseCase->>MemoryDevSpaceRepository: save(devSpace)
    MemoryDevSpaceRepository-->>ManageDevSpacesUseCase: void
    ManageDevSpacesUseCase-->>DevSpaceController: CommandResult(success)
    DevSpaceController-->>Client: 201 Created {id, message}
```

## Sequence Diagram — Create Project from Template

```mermaid
sequenceDiagram
    participant Client
    participant ProjectController
    participant ManageProjectsUseCase
    participant StudioValidator
    participant MemoryProjectRepository

    Client->>ProjectController: POST /api/v1/application-studio/projects
    ProjectController->>ManageProjectsUseCase: create(ProjectDTO)
    ManageProjectsUseCase->>StudioValidator: isValidProject(project)
    StudioValidator-->>ManageProjectsUseCase: true
    ManageProjectsUseCase->>MemoryProjectRepository: save(project)
    MemoryProjectRepository-->>ManageProjectsUseCase: void
    ManageProjectsUseCase-->>ProjectController: CommandResult(success)
    ProjectController-->>Client: 201 Created {id, message}
```
