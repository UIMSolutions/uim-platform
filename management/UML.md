# UML — Cloud Management Service

Diagrams of the hexagonal architecture in `backend/source/uim/platform/management/`.

## Component diagram — ports and adapters

```mermaid
flowchart LR
  subgraph Driving["Driving adapters (presentation)"]
    FIORI["Fiori 3 cockpit<br/>(frontend/)"] -->|OData v4| ODATA["ManagementODataController<br/>/odata/v4/management"]
    HTTP["HTTP controllers<br/>/api/v1"]
    REST["vibe.d REST interfaces<br/>/rest/v1"]
    CLI["ManagementCli<br/>uim-management-cli"]
    GUI["ManagementWindow (GtkD)<br/>uim-management-gui"]
  end

  subgraph Core["Application core"]
    PORTS(["ManagementPorts<br/>(driving ports)"])
    UC["Use cases<br/>Manage* / QueryEnvironmentEvents / GetAccountOverview"]
    SVC["Application services<br/>PlatformEventRecorder · DemoDataService"]
    DOM["Domain<br/>entities · EntitlementEvaluator · EnvironmentProvisioner"]
  end

  subgraph Driven["Driven adapters"]
    REPO["Repositories<br/>(TenantRepository)"]
    SNAP["SnapshotTenantStore + mappers"]
    STORE["JsonFileSnapshotStorage / MemorySnapshotStorage"]
    PUB["LogEventPublisher"]
    GW["SimulatedProvisioningClient"]
  end

  ODATA & HTTP & REST & CLI & GUI --> PORTS
  PORTS --> UC
  UC --> SVC
  UC --> DOM
  UC -->|IXxxRepository| REPO
  SVC -->|IPlatformEventPublisher| PUB
  UC -->|IProvisioningGateway| GW
  REPO --> SNAP -->|ISnapshotStorage| STORE
```

The container (`infrastructure/container.d`) is the only place that knows
concrete classes. Server, CLI and GUI each build their own container on the same
`dataDir`, so they share data; `SnapshotTenantStore` reloads a collection when
another process changed its file.

## Class diagram — domain

```mermaid
classDiagram
  class GlobalAccount {
    +GlobalAccountId id
    +TenantId tenantId
    +string displayName
    +LicenseType licenseType
    +GlobalAccountStatus status
    +string region
    +int maxSubaccounts
    +int maxDirectories
    +int currentSubaccounts «derived»
    +int currentDirectories «derived»
    +suspend(UserId)
    +reactivate(UserId)
    +ensureSubaccountCapacity(size_t)
    +ensureDirectoryCapacity(size_t)
  }
  class AccountDirectory {
    +DirectoryId id
    +GlobalAccountId globalAccountId
    +DirectoryId parentDirectoryId
    +DirectoryStatus status
    +DirectoryFeature[] features
    +isRoot() bool
  }
  class Subaccount {
    +SubaccountId id
    +GlobalAccountId globalAccountId
    +DirectoryId parentDirectoryId
    +string subdomain
    +string region
    +SubaccountStatus status
    +SubaccountUsage usage
    +suspend(UserId)
    +reactivate(UserId)
    +moveTo(DirectoryId, UserId)
  }
  class ServicePlan {
    +ServicePlanId id
    +string serviceName
    +string planName
    +ServicePlanCategory category
    +ServicePlanStatus status
    +PricingModel pricingModel
    +int maxQuota
    +string[] availableRegions
    +isUnlimited() bool
    +availableIn(string) bool
  }
  class Entitlement {
    +EntitlementId id
    +ServicePlanId servicePlanId
    +int quotaAssigned
    +int quotaUsed
    +bool unlimited
    +EntitlementStatus status
    +reassign(int, bool, UserId)
    +revoke(UserId)
    +isOverQuota() bool
  }
  class Environment {
    +EnvironmentId id
    +SubaccountId subaccountId
    +EnvironmentType environmentType
    +EnvironmentStatus status
    +string technicalKey
    +isLive() bool
  }
  class Subscription {
    +SubscriptionId id
    +SubaccountId subaccountId
    +string appName
    +SubscriptionStatus status
    +unsubscribe(UserId)
    +isLive() bool
  }
  class Label {
    +LabeledResourceType resourceType
    +string resourceId
    +string key
    +string[] values
  }
  class EnvironmentEvent {
    +EnvironmentEventCategory category
    +EnvironmentEventSeverity severity
    +string eventType
    +UserId initiatedBy
    +long timestamp
  }

  GlobalAccount "1" o-- "*" AccountDirectory
  AccountDirectory "0..1" o-- "*" AccountDirectory : parent
  GlobalAccount "1" o-- "*" Subaccount
  AccountDirectory "0..1" o-- "*" Subaccount
  Subaccount "1" o-- "*" Environment
  Subaccount "1" o-- "*" Subscription
  ServicePlan "1" -- "*" Entitlement
  Subaccount "0..1" -- "*" Entitlement
  Label ..> Subaccount : tags
  EnvironmentEvent ..> GlobalAccount : scope
```

All entities mix in `TenantEntity` (`tenantId`, `id`, `createdBy/At`,
`updatedBy/At`; timestamps in stdTime hnsecs). Invalid lifecycle transitions
throw `InvalidStateTransition`, limits throw `LimitExceeded`; the use cases turn
them into `UsecaseResult` codes (`ResultCode`: 400, 404, 409, 422).

## Class diagram — driving ports

```mermaid
classDiagram
  class ManagementPorts {
    +IManageGlobalAccountsUseCase globalAccounts
    +IManageDirectoriesUseCase directories
    +IManageSubaccountsUseCase subaccounts
    +IManageEntitlementsUseCase entitlements
    +IManageEnvironmentsUseCase environments
    +IManageSubscriptionsUseCase subscriptions
    +IManageServicePlansUseCase servicePlans
    +IManageLabelsUseCase labels
    +IQueryEnvironmentEventsUseCase events
    +IPruneEventsUseCase pruneEvents
    +IGetAccountOverviewUseCase overview
    +IDemoDataService demoData
  }
  class ManageSubaccountsUseCase
  class ManageEntitlementsUseCase
  class PlatformEventRecorder {
    +record(TenantId, EventScope, category, eventType, description, UserId, severity, details)
  }
  class IProvisioningGateway {
    <<interface>>
    +provisionEnvironment(Environment, Subaccount) ProvisioningResult
    +deprovisionEnvironment(Environment) ProvisioningResult
    +subscribe(Subscription, Subaccount) ProvisioningResult
    +unsubscribe(Subscription) ProvisioningResult
  }
  ManagementPorts --> ManageSubaccountsUseCase : subaccounts
  ManagementPorts --> ManageEntitlementsUseCase : entitlements
  ManageSubaccountsUseCase --> PlatformEventRecorder
  ManageEntitlementsUseCase --> EntitlementEvaluator
  ManageEntitlementsUseCase --> PlatformEventRecorder
  ManageEnvironmentsUseCase --> IProvisioningGateway
  ManageEnvironmentsUseCase --> EnvironmentProvisioner
```

## Sequence — provision an environment from the Fiori cockpit

```mermaid
sequenceDiagram
  actor Admin
  participant UI as Fiori cockpit
  participant AR as Approuter (XSUAA)
  participant OD as ManagementODataController
  participant UC as ManageEnvironmentsUseCase
  participant EP as EnvironmentProvisioner
  participant GW as IProvisioningGateway
  participant R as EnvironmentRepository
  participant EV as PlatformEventRecorder

  Admin->>UI: Create environment (dialog)
  UI->>AR: POST /odata/v4/management/Environments
  AR->>OD: forward + bearer token
  OD->>OD: resolveIdentity (zid, user_name)
  OD->>UC: createEnvironment(request)
  UC->>EP: validateProvisioning(type, plan, subaccount, existing)
  EP-->>UC: valid
  UC->>R: save(status = creating)
  UC->>GW: provisionEnvironment
  GW-->>UC: technicalKey, dashboard URL
  UC->>R: update(status = active)
  UC->>EV: record("environment.created")
  UC-->>OD: UsecaseResult(201, id)
  OD-->>UI: 201 Environment entity
```

## Sequence — CLI and GUI share data with the server

```mermaid
sequenceDiagram
  participant CLI as uim-management-cli
  participant FS as data/*.json
  participant SRV as server (SnapshotTenantStore)
  CLI->>FS: write subaccounts.json (temp file + rename)
  SRV->>FS: revision(subaccounts) changed?
  SRV->>FS: reload collection
  SRV-->>SRV: new subaccount visible in OData / GUI
```
