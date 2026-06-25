# UML — Feature Flags Service

## Domain Model

```plantuml
@startuml

package "Domain" {

  enum FlagType {
    BOOLEAN
    STRING
    JSON
    NUMBER
  }

  enum FlagState {
    ENABLED
    DISABLED
    ARCHIVED
  }

  enum RuleType {
    USER_MATCH
    TENANT_MATCH
    PERCENTAGE_ROLLOUT
    ATTRIBUTE_MATCH
  }

  enum AuditAction {
    CREATED
    UPDATED
    DELETED
    ENABLED
    DISABLED
    ARCHIVED
  }

  class FeatureFlag {
    +FlagId id
    +TenantId tenantId
    +string name
    +string description
    +FlagType type
    +FlagState state
    +ServiceInstanceId instanceId
    +string defaultVariant
    +FlagVariant[] variants
    +TargetingRule[] rules
    +string[string] labels
    +string createdAt
    +long updatedAt
    +string createdBy
    +string updatedBy
    +bool isNull()
    +FlagVariant findVariant(string key)
  }

  class FlagVariant {
    +VariantId id
    +string key
    +string name
    +string description
    +string value
    +uint weight
  }

  class TargetingRule {
    +RuleId id
    +RuleType type
    +string name
    +string variantKey
    +uint priority
    +string[] targetIds
    +uint rolloutPercentage
    +string[string] attributeConstraints
  }

  class ServiceInstance {
    +ServiceInstanceId id
    +TenantId tenantId
    +string name
    +string description
    +string bindingGuid
    +string[string] labels
    +string createdAt
    +long updatedAt
  }

  class AuditEntry {
    +AuditEntryId id
    +TenantId tenantId
    +AuditAction action
    +string entityType
    +string entityId
    +string entityName
    +string performedBy
    +string performedAt
  }

  class FlagEvaluator {
    +EvaluationResult evaluate(FeatureFlag, EvaluationContext)
    -bool matchesRule(TargetingRule, EvaluationContext)
    -uint stableHashPercent(string id)
  }

  class EvaluationContext {
    +TenantId tenantId
    +UserId userId
    +string[string] attributes
  }

  class EvaluationResult {
    +string flagName
    +string variantKey
    +string variantValue
    +FlagType type
    +bool enabled
    +string reason
  }

  FeatureFlag "1" *-- "many" FlagVariant
  FeatureFlag "1" *-- "many" TargetingRule
  FeatureFlag "many" --> "1" ServiceInstance
  FlagEvaluator ..> FeatureFlag
  FlagEvaluator ..> EvaluationContext
  FlagEvaluator ..> EvaluationResult
}

@enduml
```

---

## Ports & Adapters (Hexagonal Architecture)

```plantuml
@startuml

interface FeatureFlagRepository {
  +save(FeatureFlag)
  +update(FeatureFlag)
  +remove(FeatureFlag)
  +findById(TenantId, FlagId) : FeatureFlag
  +findByName(TenantId, ServiceInstanceId, string) : FeatureFlag
  +findByTenant(TenantId) : FeatureFlag[]
  +findByInstance(TenantId, ServiceInstanceId) : FeatureFlag[]
  +findByState(TenantId, ServiceInstanceId, FlagState) : FeatureFlag[]
  +countByInstance(TenantId, ServiceInstanceId) : size_t
}

interface ServiceInstanceRepository {
  +save(ServiceInstance)
  +update(ServiceInstance)
  +remove(ServiceInstance)
  +findById(TenantId, ServiceInstanceId) : ServiceInstance
  +findByName(TenantId, string) : ServiceInstance
  +findByTenant(TenantId) : ServiceInstance[]
  +countByTenant(TenantId) : size_t
}

interface AuditEntryRepository {
  +append(AuditEntry)
  +findByTenant(TenantId) : AuditEntry[]
  +findByEntity(TenantId, string) : AuditEntry[]
  +findByTenantPaged(TenantId, offset, limit) : AuditEntry[]
}

class MemoryFeatureFlagRepository
class FileFeatureFlagRepository
class MongoDbFeatureFlagRepository

class MemoryServiceInstanceRepository
class FileServiceInstanceRepository
class MongoDbServiceInstanceRepository

class MemoryAuditEntryRepository
class FileAuditEntryRepository
class MongoDbAuditEntryRepository

FeatureFlagRepository <|.. MemoryFeatureFlagRepository
FeatureFlagRepository <|.. FileFeatureFlagRepository
FeatureFlagRepository <|.. MongoDbFeatureFlagRepository

ServiceInstanceRepository <|.. MemoryServiceInstanceRepository
ServiceInstanceRepository <|.. FileServiceInstanceRepository
ServiceInstanceRepository <|.. MongoDbServiceInstanceRepository

AuditEntryRepository <|.. MemoryAuditEntryRepository
AuditEntryRepository <|.. FileAuditEntryRepository
AuditEntryRepository <|.. MongoDbAuditEntryRepository

@enduml
```

---

## Application Layer — Use Cases

```plantuml
@startuml

class ManageFeatureFlagsUseCase {
  -FeatureFlagRepository repo
  -AuditEntryRepository audit
  +getFlag(TenantId, FlagId) : FeatureFlag
  +getFlagByName(TenantId, ServiceInstanceId, string) : FeatureFlag
  +listFlags(TenantId) : FeatureFlag[]
  +listFlagsByInstance(TenantId, ServiceInstanceId) : FeatureFlag[]
  +createFlag(CreateFeatureFlagRequest) : FlagResult
  +updateFlag(TenantId, FlagId, UpdateFeatureFlagRequest) : FlagResult
  +patchFlagState(TenantId, FlagId, PatchFeatureFlagRequest) : FlagResult
  +deleteFlag(TenantId, FlagId, string) : FlagResult
}

class EvaluateFlagsUseCase {
  -FeatureFlagRepository repo
  -FlagEvaluator evaluator
  +evaluate(EvaluationRequest) : EvaluationResult
  +evaluateAll(BulkEvaluationRequest) : EvaluationResult[]
}

class ManageServiceInstancesUseCase {
  -ServiceInstanceRepository repo
  -AuditEntryRepository audit
  +getInstance(TenantId, ServiceInstanceId) : ServiceInstance
  +listInstances(TenantId) : ServiceInstance[]
  +createInstance(CreateServiceInstanceRequest) : FlagResult
  +updateInstance(TenantId, ServiceInstanceId, UpdateServiceInstanceRequest) : FlagResult
  +deleteInstance(TenantId, ServiceInstanceId, string) : FlagResult
}

ManageFeatureFlagsUseCase --> FeatureFlagRepository
ManageFeatureFlagsUseCase --> AuditEntryRepository
EvaluateFlagsUseCase --> FeatureFlagRepository
EvaluateFlagsUseCase --> FlagEvaluator
ManageServiceInstancesUseCase --> ServiceInstanceRepository
ManageServiceInstancesUseCase --> AuditEntryRepository

@enduml
```

---

## Presentation Layer — MVC

```plantuml
@startuml

package "HTTP Controllers" {
  class FeatureFlagController {
    +registerRoutes(URLRouter)
    -handleList(req, res)
    -handleCreate(req, res)
    -handleGet(req, res)
    -handleUpdate(req, res)
    -handlePatch(req, res)
    -handleDelete(req, res)
  }
  class EvaluationController {
    +registerRoutes(URLRouter)
    -handleEvaluate(req, res)
    -handleEvaluateAll(req, res)
  }
  class ServiceInstanceController {
    +registerRoutes(URLRouter)
    -handleList(req, res)
    -handleCreate(req, res)
    -handleGet(req, res)
    -handleUpdate(req, res)
    -handleDelete(req, res)
  }
}

package "Web Views" {
  class FeatureFlagWebView {
    +registerRoutes(URLRouter)
    -renderList(req, res)
    -renderDetail(req, res)
  }
}

package "CLI Commands" {
  class FeatureFlagCliCommand {
    +listFlags(tenantId, instanceId)
    +getFlag(tenantId, id)
    +enableFlag(tenantId, id, updatedBy)
    +disableFlag(tenantId, id, updatedBy)
    +archiveFlag(tenantId, id, updatedBy)
    +deleteFlag(tenantId, id, deletedBy)
  }
  class EvaluationCliCommand {
    +evaluate(tenantId, instanceId, flagName, userId, attributes)
    +evaluateAll(tenantId, instanceId, userId, attributes)
  }
}

package "GUI Widgets" {
  class FeatureFlagWidget {
    +buildListViewModel(tenantId, instanceId) : FlagRowViewModel[]
    +buildDetailViewModel(tenantId, id) : FlagDetailViewModel
  }
}

FeatureFlagController --> ManageFeatureFlagsUseCase
EvaluationController --> EvaluateFlagsUseCase
ServiceInstanceController --> ManageServiceInstancesUseCase
FeatureFlagWebView --> ManageFeatureFlagsUseCase
FeatureFlagCliCommand --> ManageFeatureFlagsUseCase
EvaluationCliCommand --> EvaluateFlagsUseCase
FeatureFlagWidget --> ManageFeatureFlagsUseCase

@enduml
```

---

## Evaluation Flow Sequence

```plantuml
@startuml
actor "SDK Client" as client
participant "EvaluationController" as ctrl
participant "EvaluateFlagsUseCase" as uc
participant "FeatureFlagRepository" as repo
participant "FlagEvaluator" as eval

client -> ctrl : GET /api/v1/feature-flags/evaluate/dark-mode\n?tenantId=t1&userId=u1
ctrl -> uc : evaluate(EvaluationRequest)
uc -> repo : findByName(tenantId, instanceId, "dark-mode")
repo --> uc : FeatureFlag
uc -> eval : evaluate(flag, EvaluationContext{t1, u1})
eval -> eval : sort rules by priority
loop each rule
  eval -> eval : matchesRule(rule, ctx)
  alt rule matches
    eval --> uc : EvaluationResult(variantKey, "RULE_MATCH")
  end
end
eval --> uc : EvaluationResult(defaultVariant, "DEFAULT")
uc --> ctrl : EvaluationResult
ctrl --> client : 200 OK { flagName, variantKey, variantValue, enabled, reason }
@enduml
```
