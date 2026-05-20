# UIM UI Flexibility Platform Service — UML Documentation

## 1. Hexagonal Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ HTTP         │  │ CLI MVC      │  │ Web MVC      │  │ GUI MVC    │  │
│  │ Controllers  │  │ (models/     │  │ (models/     │  │ (models/   │  │
│  │ /keyuser/v2/ │  │  views/      │  │  views/      │  │  views/    │  │
│  │ /user/v2/    │  │  ctrls)      │  │  ctrls)      │  │  ctrls)    │  │
│  │ /api/v2/     │  └──────────────┘  └──────────────┘  └────────────┘  │
│  └──────────────┘                                                       │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │ calls
┌──────────────────────────────────▼──────────────────────────────────────┐
│                       APPLICATION LAYER                                 │
│  ManageFlexChangesUseCase    ManageFlexVariantsUseCase                  │
│  ManageFlexVersionsUseCase   ManageFlexDraftsUseCase                    │
│  ManageFlexPersonalizationsUseCase  ManageFlexApplicationsUseCase       │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │ uses (ports)
┌──────────────────────────────────▼──────────────────────────────────────┐
│                         DOMAIN LAYER                                    │
│  Entities: FlexChange  FlexVariant  FlexVersion  FlexDraft              │
│            FlexPersonalization  FlexApplication                         │
│  Ports (interfaces): FlexChangeRepository  FlexVariantRepository        │
│                      FlexVersionRepository  FlexDraftRepository         │
│                      FlexPersonalizationRepository  FlexApplicationRepository │
│  Services: FlexValidator                                                │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │ implemented by
┌──────────────────────────────────▼──────────────────────────────────────┐
│                     INFRASTRUCTURE LAYER                                │
│  Memory: MemoryFlexChangeRepository  MemoryFlexVariantRepository  ...   │
│  Files:  FileFlexChangeRepository                                       │
│  MongoDB: MongoFlexChangeRepository (stub)                              │
│  Config: SrvConfig + loadConfig()                                       │
│  Container: buildContainer(SrvConfig) → Container                       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Domain Entity Class Diagram

```
┌────────────────────────────────────────┐
│ FlexChange                             │
├────────────────────────────────────────┤
│ id_: FlexChangeId                      │
│ tenant_: string                        │
│ appId_: string                         │
│ namespace_: string                     │
│ layer_: ChangeLayer                    │
│ changeType_: ChangeType                │
│ selector_: string (JSON)               │
│ content_: string (JSON)                │
│ reference_: string                     │
│ support_: string                       │
│ dependentSelector_: string             │
│ createdBy_, updatedBy_: string         │
│ createdAtTicks_, updatedAtTicks_: long │
│ isActive_: bool                        │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ FlexVariant                            │
├────────────────────────────────────────┤
│ id_: FlexVariantId                     │
│ tenant_, appId_: string                │
│ variantType_: VariantType              │
│ variantName_: string                   │
│ content_: string                       │
│ isDefault_, isPublic_: bool            │
│ layer_: ChangeLayer                    │
│ author_: string                        │
│ createdAtTicks_, updatedAtTicks_: long │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ FlexVersion                            │
├────────────────────────────────────────┤
│ id_: FlexVersionId                     │
│ tenant_, appId_: string                │
│ versionNumber_: long                   │
│ displayName_, description_: string     │
│ status_: VersionStatus                 │
│ activatedAt_, activatedBy_: string     │
│ changeCount_: long                     │
│ changeIds_: string[]                   │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ FlexDraft                              │
├────────────────────────────────────────┤
│ id_: FlexDraftId                       │
│ tenant_, appId_: string                │
│ changeIds_: string[]                   │
│ changeCount_: long                     │
│ updatedAt_, updatedBy_: string         │
│ baseVersionId_: string                 │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ FlexPersonalization                    │
├────────────────────────────────────────┤
│ id_: FlexPersonalizationId             │
│ tenant_, appId_, userId_: string       │
│ controlId_: string                     │
│ scope_: PersonalizationScope           │
│ changeType_: ChangeType                │
│ content_: string                       │
│ updatedAt_: string                     │
│ isSynced_: bool                        │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ FlexApplication                        │
├────────────────────────────────────────┤
│ id_: FlexApplicationId                 │
│ tenant_, namespace_, appId_: string    │
│ description_: string                   │
│ isActive_: bool                        │
│ validFrom_, validTo_: string           │
│ owner_, version_: string               │
└────────────────────────────────────────┘
```

---

## 3. Sequence Diagrams

### 3.1 Create Flex Change (Key User)

```
Client           FlexChangesController     ManageFlexChangesUseCase    FlexChangeRepository
  │                     │                           │                         │
  │ POST /keyuser/v2/changes                         │                         │
  │────────────────────>│                           │                         │
  │                     │ createChange(req)         │                         │
  │                     │──────────────────────────>│                         │
  │                     │                           │ FlexValidator.validate  │
  │                     │                           │─────────────────────────│ (internal)
  │                     │                           │ repo.save(tenantId, c)  │
  │                     │                           │────────────────────────>│
  │                     │                           │<────────────────────────│
  │                     │ CommandResult(true, id)   │                         │
  │                     │<──────────────────────────│                         │
  │ 201 {id, status}    │                           │                         │
  │<────────────────────│                           │                         │
```

### 3.2 Activate Version

```
Client              FlexVersionsController    ManageFlexVersionsUseCase    FlexVersionRepository
  │                        │                           │                         │
  │ POST /keyuser/v2/versions/{id}/activate             │                         │
  │───────────────────────>│                           │                         │
  │                        │ activateVersion(r)        │                         │
  │                        │──────────────────────────>│                         │
  │                        │                           │ findById(tenant,id)     │
  │                        │                           │────────────────────────>│
  │                        │                           │ findActiveByApp(...)    │
  │                        │                           │────────────────────────>│
  │                        │                           │ update(current→archived)│
  │                        │                           │────────────────────────>│
  │                        │                           │ update(v→active)        │
  │                        │                           │────────────────────────>│
  │                        │ CommandResult(true, id)   │                         │
  │                        │<──────────────────────────│                         │
  │ 200 {id, activated}    │                           │                         │
  │<───────────────────────│                           │                         │
```

### 3.3 Reset User Personalizations

```
Client             FlexPersonalizationsController    ManageFlexPersonalizationsUseCase
  │                            │                                 │
  │ DELETE /user/v2/personalizations?appId=A&userId=U            │
  │───────────────────────────>│                                 │
  │                            │ resetUserPersonalizations(...)  │
  │                            │────────────────────────────────>│
  │                            │                                 │ repo.removeByUser(...)
  │                            │ CommandResult(true, userId)     │
  │                            │<────────────────────────────────│
  │ 204 No Content             │                                 │
  │<───────────────────────────│                                 │
```

---

## 4. Storage Backend Selection

```
loadConfig()
     │
     ▼
buildContainer(config)
     │
     ├── storage == memory_  →  MemoryFlexChangeRepository (all entities)
     ├── storage == files_   →  FileFlexChangeRepository + MemoryXxx for others
     └── storage == mongodb_ →  MongoFlexChangeRepository (stub) + MemoryXxx for others
```
