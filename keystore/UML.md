# UML — Keystore Service

## Component Diagram (Hexagonal Architecture)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          Keystore Service                                    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Presentation Layer (Driving Adapters)             │    │
│  │  ┌───────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │    │
│  │  │ KeystoreController│  │KeyEntryController│  │KeyPasswordCtrl   │ │    │
│  │  │ /api/v1/keystores │  │ /…/entries       │  │ /api/v1/passwords│ │    │
│  │  └────────┬──────────┘  └────────┬─────────┘  └────────┬─────────┘ │    │
│  └───────────┼────────────────────  ┼────────────────────  ┼───────────┘    │
│              │                      │                      │                │
│  ┌───────────▼──────────────────────▼──────────────────────▼───────────┐   │
│  │                       Application Layer                              │   │
│  │   ManageKeystoresUseCase   ManageKeyEntriesUseCase                  │   │
│  │   ManageKeyPasswordsUseCase                                         │   │
│  │   DTO: UploadKeystoreRequest, ImportKeyEntryRequest,                │   │
│  │        SetPasswordRequest, CommandResult                             │   │
│  └───────────────────────────────┬──────────────────────────────────────┘  │
│                                  │                                          │
│  ┌───────────────────────────────▼──────────────────────────────────────┐  │
│  │                         Domain Layer                                  │  │
│  │   Entities: KeystoreEntity, KeyEntry, KeyPassword                    │  │
│  │   Types:    KeystoreFormat, KeystoreLevel, KeyEntryType              │  │
│  │   Ports:    KeystoreRepository, KeyEntryRepository,                  │  │
│  │             KeyPasswordRepository (interfaces)                       │  │
│  │   Services: KeystoreSearchService (scope resolution)                │  │
│  └───────────────────────────────┬──────────────────────────────────────┘  │
│                                  │                                          │
│  ┌───────────────────────────────▼──────────────────────────────────────┐  │
│  │                  Infrastructure Layer (Driven Adapters)               │  │
│  │   MemoryKeystoreRepository   MemoryKeyEntryRepository                │  │
│  │   MemoryKeyPasswordRepository                                        │  │
│  │   AppConfig (env vars)   Container (DI)                              │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Class Diagram

### Domain — Entities

```
┌──────────────────────────────────┐
│ KeystoreEntity                   │
├──────────────────────────────────┤
│ id           : KeystoreId        │
│ name         : string            │
│ description  : string            │
│ format       : KeystoreFormat    │
│ level        : KeystoreLevel     │
│ content      : string (base64)   │
│ accountId    : string            │
│ applicationId: string            │
│ subscriptionId: string           │
│ createdBy    : string            │
│ modifiedBy   : string            │
│ createdAt    : long              │
│ updatedAt    : long              │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ KeyEntry                         │
├──────────────────────────────────┤
│ id           : KeyEntryId        │
│ keystoreId   : KeystoreId        │
│ alias_       : string            │
│ entryType    : KeyEntryType      │
│ content      : string (base64)   │
│ format       : string            │
│ subject      : string            │
│ issuer       : string            │
│ serialNumber : string            │
│ notBefore    : long              │
│ notAfter     : long              │
│ createdAt    : long              │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ KeyPassword                      │
├──────────────────────────────────┤
│ id            : KeyPasswordId    │
│ alias_        : string           │
│ passwordValue : string           │
│ accountId     : string           │
│ applicationId : string           │
│ tenantId      : string           │
│ createdAt     : long             │
│ updatedAt     : long             │
└──────────────────────────────────┘
```

---

### Domain — Repository Interfaces (Ports)

```
«interface»                           «interface»
KeystoreRepository                    KeyEntryRepository
─────────────────                     ──────────────────
+ existsById(id)                      + existsById(id)
+ findById(id)                        + findById(id)
+ existsByName(…)                     + existsByAlias(keystoreId, alias)
+ findByName(…)                       + findByAlias(keystoreId, alias)
+ findByAccount(accountId)            + findByKeystore(keystoreId)
+ findByApplication(…)                + save / update / remove
+ findBySubscription(…)               + countByKeystore(keystoreId)
+ save / update / remove / count

«interface»
KeyPasswordRepository
──────────────────────
+ existsByAlias(accountId, appId, alias)
+ findByAlias(accountId, appId, alias)
+ findByApplication(accountId, appId)
+ save / update / removeByAlias
+ countByApplication(…)
```

---

### Keystore Scope Resolution Sequence

```
Client
  │
  │  GET /api/v1/keystores/resolve?name=myks&accountId=acc1&applicationId=app1
  ▼
KeystoreController.handleResolve()
  │
  ▼
KeystoreSearchService.findByName(accountId, applicationId, subscriptionId, name)
  │
  ├─► 1. findByName(accountId, subscriptionId, subscription, name) → not found
  ├─► 2. findByName(accountId, applicationId,  application,  name) → not found
  └─► 3. findByName(accountId, "",             account,      name) → found ✓
  │
  ▼
KeystoreController → 200 OK + JSON
```

---

## Deployment Diagram

```
┌──────────────────────────────────────────────────────────┐
│  Kubernetes Cluster                                       │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Namespace: uim-platform                          │   │
│  │                                                   │   │
│  │  ┌──────────────────┐   ┌─────────────────────┐  │   │
│  │  │  ConfigMap       │   │  Service (ClusterIP) │  │   │
│  │  │  keystore-config │   │  port: 8115          │  │   │
│  │  └──────────────────┘   └──────────┬──────────┘  │   │
│  │                                    │               │   │
│  │  ┌─────────────────────────────────▼───────────┐  │   │
│  │  │  Deployment: keystore (1 replica)            │  │   │
│  │  │  Image: uim-platform/keystore:latest         │  │   │
│  │  │  Container port: 8115                        │  │   │
│  │  │  Liveness:  GET /api/v1/health               │  │   │
│  │  │  Readiness: GET /api/v1/health               │  │   │
│  │  │  Memory: 64Mi–256Mi  CPU: 100m–500m          │  │   │
│  │  │  runAsNonRoot: true                          │  │   │
│  │  │  readOnlyRootFilesystem: true                │  │   │
│  │  └─────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```
