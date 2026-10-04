# UML — Identity Platform Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

## Class Diagram

```mermaid
classDiagram
    %% Domain Entities
    class IdmUser {
        +UserId id
        +TenantId tenantId
        +string userName
        +string email
        +string displayName
        +string firstName
        +string lastName
        +UserStatus status
        +UserType type_
        +string[] groups
        +string[] roles
        +toJson() Json
    }

    class IDMGroup {
        +IDMGroupId id
        +TenantId tenantId
        +string name
        +string description
        +GroupType type_
        +string[] memberIds
        +toJson() Json
    }

    class Application {
        +ApplicationId id
        +TenantId tenantId
        +string name
        +AppProtocol protocol
        +AppStatus status
        +string clientId
        +string[] redirectUris
        +AuthScheme authScheme
        +toJson() Json
    }

    class IdentityProvider {
        +IdentityProviderId id
        +TenantId tenantId
        +string name
        +IdpType type_
        +IdpStatus status
        +string entityId
        +string ssoUrl
        +bool isDefault
        +toJson() Json
    }

    class ProvisioningJob {
        +ProvisioningJobId id
        +TenantId tenantId
        +string name
        +string sourceSystem
        +string targetSystem
        +JobType type_
        +JobStatus status
        +toJson() Json
    }

    %% Repository Interfaces (Ports)
    class UserRepository {
        <<interface>>
        +save(IdmUser)
        +findById(TenantId, UserId) IdmUser
        +findByTenant(TenantId) IdmUser[]
        +findByEmail(TenantId, string) IdmUser
        +findByStatus(TenantId, UserStatus) IdmUser[]
    }

    class GroupRepository {
        <<interface>>
        +save(IDMGroup)
        +findById(TenantId, IDMGroupId) IDMGroup
        +findByMember(TenantId, UserId) IDMGroup[]
    }

    class ApplicationRepository {
        <<interface>>
        +save(Application)
        +findByClient(TenantId, string) Application
        +findByProtocol(TenantId, AppProtocol) Application[]
    }

    class IdentityProviderRepository {
        <<interface>>
        +save(IdentityProvider)
        +findByEntityId(TenantId, string) IdentityProvider
        +findDefault(TenantId) IdentityProvider
    }

    class ProvisioningJobRepository {
        <<interface>>
        +save(ProvisioningJob)
        +findByStatus(TenantId, JobStatus) ProvisioningJob[]
        +findByTargetSystem(TenantId, string) ProvisioningJob[]
    }

    %% Use Cases
    class ManageUsersUseCase {
        -UserRepository repo
        +createUser(UserDTO) UseCaseResult
        +updateUser(UserDTO) UseCaseResult
        +deleteUser(TenantId, UserId) UseCaseResult
        +getUser(TenantId, UserId) IdmUser
        +listUsers(TenantId) IdmUser[]
        +findByEmail(TenantId, string) IdmUser
    }

    class ManageGroupsUseCase {
        -GroupRepository repo
        +createGroup(GroupDTO) UseCaseResult
        +addMember(TenantId, IDMGroupId, UserId) UseCaseResult
        +removeMember(TenantId, IDMGroupId, UserId) UseCaseResult
    }

    class ManageApplicationsUseCase {
        -ApplicationRepository repo
        +createApplication(ApplicationDTO) UseCaseResult
    }

    class ManageIdentityProvidersUseCase {
        -IdentityProviderRepository repo
        +createIdentityProvider(IdentityProviderDTO) UseCaseResult
        +findDefault(TenantId) IdentityProvider
    }

    class ManageProvisioningJobsUseCase {
        -ProvisioningJobRepository repo
        +createJob(ProvisioningJobDTO) UseCaseResult
        +startJob(TenantId, ProvisioningJobId) UseCaseResult
        +finishJob(TenantId, ProvisioningJobId, bool) UseCaseResult
        +cancelJob(TenantId, ProvisioningJobId) UseCaseResult
    }

    %% Controllers
    class UserController {
        -ManageUsersUseCase usecase
        +registerRoutes(URLRouter)
    }

    class GroupController {
        -ManageGroupsUseCase usecase
        +registerRoutes(URLRouter)
    }

    class ApplicationController {
        -ManageApplicationsUseCase usecase
        +registerRoutes(URLRouter)
    }

    class IdentityProviderController {
        -ManageIdentityProvidersUseCase usecase
        +registerRoutes(URLRouter)
    }

    class ProvisioningJobController {
        -ManageProvisioningJobsUseCase usecase
        +registerRoutes(URLRouter)
        +handleStart(req, res)
        +handleCancel(req, res)
    }

    %% Persistence Adapters
    class UserRepository {
        -IdmUser[string] store
    }
    class FileUserRepository {
        -string dataDir
        -IdmUser[string] store
    }
    class MongoUserRepository {
        -MongoCollection collection
    }

    %% Relationships
    IdmUser --> IDMGroup : "member of"
    Application --> IdentityProvider : "delegates auth to"
    ProvisioningJob --> IdmUser : "provisions"

    ManageUsersUseCase --> UserRepository
    ManageGroupsUseCase --> GroupRepository
    ManageApplicationsUseCase --> ApplicationRepository
    ManageIdentityProvidersUseCase --> IdentityProviderRepository
    ManageProvisioningJobsUseCase --> ProvisioningJobRepository

    MemoryUserRepository ..|> UserRepository
    FileUserRepository ..|> UserRepository
    MongoUserRepository ..|> UserRepository

    UserController --> ManageUsersUseCase
    GroupController --> ManageGroupsUseCase
    ApplicationController --> ManageApplicationsUseCase
    IdentityProviderController --> ManageIdentityProvidersUseCase
    ProvisioningJobController --> ManageProvisioningJobsUseCase
```

---

## Layer Dependency Diagram

```mermaid
graph TD
    subgraph Presentation
        HTTP[HTTP Controllers]
        CLI[CLI MVC]
        WEB[Web MVC]
    end
    subgraph Application
        UC[Use Cases]
        DTO[DTOs]
    end
    subgraph Domain
        ENT[Entities]
        REP[Repository Interfaces]
        SVC[Domain Services]
    end
    subgraph Infrastructure
        MEM[Memory Adapters]
        FILE[File Adapters]
        MONGO[MongoDB Adapters]
        CFG[Config]
        CONT[Container]
    end

    HTTP --> UC
    CLI --> UC
    WEB --> UC
    UC --> REP
    UC --> ENT
    MEM --> REP
    FILE --> REP
    MONGO --> REP
    CONT --> MEM
    CONT --> FILE
    CONT --> MONGO
    CONT --> UC
    CONT --> HTTP
```

---

## Provisioning Job Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending : createJob
    pending --> running : startJob
    running --> success : finishJob(success=true)
    running --> failed : finishJob(success=false)
    pending --> cancelled : cancelJob
    running --> cancelled : cancelJob
    success --> [*]
    failed --> [*]
    cancelled --> [*]
```
