# UML — Object Store Service

Diagrams of the UIM Object Store service (Mermaid). Package and module names refer
to `backend/source/uim/platform/object_store/`.

## Class Diagram — Domain Entities

```mermaid
classDiagram
  class TenantEntity {
    <<mixin>>
    +TenantId tenantId
    +TId id
    +UserId createdBy
    +long createdAt
    +UserId updatedBy
    +long updatedAt
    +isNull() bool
    +update(UserId)
  }

  class Bucket {
    +string name
    +string description
    +IaasProvider provider
    +string region
    +StorageClass storageClass
    +bool versioningEnabled
    +EncryptionType encryptionType
    +string encryptionKeyId
    +bool publicAccessBlocked
    +long quotaBytes
    +BucketStatus status
    +MetadataEntry[] labels
    +long usedBytes
    +int objectCount
    +int versionCount
  }

  class StorageObject {
    +BucketId bucketId
    +string bucketName
    +string name «key»
    +string contentType
    +long size
    +string etag «MD5»
    +MetadataEntry[] metadata
    +StorageClass storageClass
    +ObjectStatus status
    +bool legalHold
    +int currentVersion
    +int versionCount
    +ObjectVersionId currentVersionId
  }

  class ObjectVersion {
    +StorageObjectId objectId
    +BucketId bucketId
    +string objectKey
    +string name «v‹n›»
    +int versionNumber
    +long size
    +string etag
    +string contentType
    +string blobId «SHA-256»
    +bool isLatest
    +bool isDeleteMarker
  }

  class AccessPolicy {
    +BucketId bucketId
    +string name
    +PolicyEffect effect
    +string[] principals
    +PolicyAction[] actions
    +string[] resources
    +bool enabled
  }

  class LifecycleRule {
    +BucketId bucketId
    +string name
    +string prefix
    +RuleStatus status
    +int expirationDays
    +int transitionDays
    +StorageClass transitionStorageClass
    +int noncurrentVersionExpirationDays
    +long lastAppliedAt
    +int lastExpired
    +int lastTransitioned
    +int lastVersionsPurged
  }

  class CorsRule {
    +BucketId bucketId
    +string name
    +string[] allowedOrigins
    +CorsMethod[] allowedMethods
    +string[] allowedHeaders
    +string[] exposedHeaders
    +int maxAgeSeconds
  }

  class ServiceBinding {
    +BucketId bucketId
    +string name
    +BindingPermission permission
    +BindingStatus status
    +long expiresAt
    +string accessKeyId
    +string secretHash «salted SHA-256»
    +string secretSalt
    +long lastRotatedAt
    +long lastUsedAt
  }

  class MetadataEntry {
    <<value>>
    +string key
    +string value
  }

  TenantEntity <|.. Bucket
  TenantEntity <|.. StorageObject
  TenantEntity <|.. ObjectVersion
  TenantEntity <|.. AccessPolicy
  TenantEntity <|.. LifecycleRule
  TenantEntity <|.. CorsRule
  TenantEntity <|.. ServiceBinding

  Bucket "1" *-- "0..*" StorageObject : contains
  StorageObject "1" *-- "1..*" ObjectVersion : versions
  Bucket "1" *-- "0..*" AccessPolicy
  Bucket "1" *-- "0..*" LifecycleRule
  Bucket "1" *-- "0..*" CorsRule
  Bucket "1" *-- "0..*" ServiceBinding
  Bucket ..> MetadataEntry : labels
  StorageObject ..> MetadataEntry : metadata
```

## Class Diagram — Enumerations and Reference Data

```mermaid
classDiagram
  class IaasProvider {
    <<enum>>
    aws
    azure
    gcp
    alibaba
  }
  class StorageClass {
    <<enum>>
    standard
    infrequentAccess
    nearline
    coldline
    archive
  }
  class BucketStatus {
    <<enum>>
    active
    suspended
  }
  class ObjectStatus {
    <<enum>>
    active
    archived
    deleted
  }
  class EncryptionType {
    <<enum>>
    none
    sseS3
    sseKms
    sseC
  }
  class PolicyEffect {
    <<enum>>
    allow
    deny
  }
  class PolicyAction {
    <<enum>>
    read
    write
    delete
    list
    all
  }
  class BindingPermission {
    <<enum>>
    readOnly
    readWrite
    admin
  }
  class BindingStatus {
    <<enum>>
    active
    revoked
    expired
  }
  class RuleStatus {
    <<enum>>
    enabled
    disabled
  }
  class CorsMethod {
    <<enum>>
    get
    put
    post
    delete
    head
  }
  class ContentEncoding {
    <<enum>>
    text
    base64
  }
  class Region {
    <<reference>>
    +string id
    +string name
    +IaasProvider provider
    +string location
  }
  class StorageClassInfo {
    <<reference>>
    +string id
    +int minStorageDays
    +int relativeCost
    +bool requiresRestore
  }
  Region --> IaasProvider
```

## Class Diagram — Domain and Application Services

```mermaid
classDiagram
  class naming {
    <<domain service>>
    +bucketNameError(name) string
    +validateObjectKey(key, maxLength)
    +wildcardMatch(text, pattern) bool
  }
  class checksums {
    <<domain service>>
    +contentEtag(data) string «MD5»
    +contentAddress(data) string «SHA-256»
    +hashSecret(secret, salt) string
    +constantTimeEquals(a, b) bool
    +newAccessKeyId() string
    +newSecretAccessKey() string
  }
  class bucket_rules {
    <<domain service>>
    +validateEncryption(Bucket)
    +validateQuota(Bucket)
    +ensureQuota(Bucket, delta)
    +ensureWritable(Bucket)
    +ensureNotOnHold(StorageObject)
    +ensureReadable(StorageObject)
  }
  class access_evaluator {
    <<domain service>>
    +evaluateAccess(policies, principal, action, key, publicAccessBlocked) AccessDecision
  }
  class cors_matcher {
    <<domain service>>
    +validateCorsRule(CorsRule)
    +matchCors(rules, origin, method, headers) CorsDecision
  }
  class lifecycle_planner {
    <<domain service>>
    +validateLifecycleRule(LifecycleRule)
    +planLifecycle(rules, objects, versions, now) LifecycleStep[]
  }
  class catalogs {
    <<domain service>>
    +supportedRegions
    +storageClassCatalog
    +requireRegion(provider, region, default) string
  }

  class ObjectStorageService {
    <<application service>>
    -ObjectStoreRepositories repos
    -IBlobStorage blobs
    -StorageLimits limits
    +write(bucket, key, ContentSource, ...) StorageObject
    +deleteObject(StorageObject, actor) bool
    +purgeObject(StorageObject)
    +purgeVersion(ObjectVersion, actor)
    +read(tenant, bucket, key, version) ObjectContent
    +recount(tenant, bucket)
  }
  class ObjectStoreStatisticsService {
    <<application service>>
    +statistics(tenant) ObjectStoreStatistics
  }
  class ObjectStoreCatalogService {
    <<application service>>
    +regions() Region[]
    +storageClasses() StorageClassInfo[]
  }
  class EventRecorder {
    <<application service>>
    +publish(topic, payload)
  }

  ObjectStorageService ..> bucket_rules
  ObjectStorageService ..> checksums
  ObjectStorageService ..> naming
  ObjectStorageService --> IBlobStorage
  ObjectStoreCatalogService ..> catalogs
```

## Class Diagram — Use Cases and Ports

```mermaid
classDiagram
  class IManageResource~TEntity,TId,TCreate,TUpdate~ {
    <<driving port>>
    +create(TCreate) UsecaseResult
    +update(TUpdate) UsecaseResult
    +remove(tenant, id, actor) UsecaseResult
    +get(tenant, id) TEntity
    +list(tenant) TEntity[]
  }
  class ResourceUseCase~TEntity,TId,TCreate,TUpdate~ {
    <<abstract>>
    #build(TCreate) TEntity
    #apply(ref TEntity, TSpec)
    #beforeRemove(TEntity)
    #afterCreate / afterUpdate / afterRemove
    #transition(tenant, id, actor, verb, change) UsecaseResult
    #publish(TEntity, verb)
  }
  class BucketChildUseCase~TEntity,TId,TCreate,TUpdate~ {
    <<abstract>>
    #check(ref TEntity, Bucket)
    +listByBucket(tenant, bucket) TEntity[]
  }

  IManageResource <|.. ResourceUseCase
  ResourceUseCase <|-- BucketChildUseCase
  ResourceUseCase <|-- ManageBucketsUseCase
  ResourceUseCase <|-- ManageObjectsUseCase
  ResourceUseCase <|-- ManageVersionsUseCase
  BucketChildUseCase <|-- ManageAccessPoliciesUseCase
  BucketChildUseCase <|-- ManageLifecycleRulesUseCase
  BucketChildUseCase <|-- ManageCorsRulesUseCase
  BucketChildUseCase <|-- ManageServiceBindingsUseCase

  class ManageBucketsUseCase {

    +suspend()

    +resume()

    +empty()

    +findByName()

  }
  class ManageObjectsUseCase {
    +put(PutObjectRequest)
    +read()
    +listing()
    +archive()
    +restore()
    +hold()
    +copy()
  }
  class ManageVersionsUseCase {
    +listByObject()
    +promote()
  }
  class ManageAccessPoliciesUseCase {
    +evaluate(EvaluateAccessRequest) AccessDecision
  }
  class ManageLifecycleRulesUseCase {
    +run(tenant, bucket, now, actor) LifecycleRunReport
    +apply()
  }
  class ManageCorsRulesUseCase {
    +check(CheckCorsRequest) CorsDecision
  }
  class ManageServiceBindingsUseCase {
    +revoke()
    +rotate()
    +verify() CredentialCheck
    +takeIssuedSecret()
  }

  class ObjectStorePorts {
    <<port bundle>>
    buckets · objects · versions · policies · lifecycleRules · corsRules · bindings · catalog · statistics
  }

  class IBucketRepository {

    <<driven port>>

    +findByName()

  }
  class IBucketChildRepository~TEntity,TId~ {
    <<driven port>>
    +findByBucket()
    +findByName()
  }
  class IObjectVersionRepository {
    <<driven port>>
    +findByObject()
    +findByBucket()
    +countByBlob()
  }
  class IBlobStorage {
    <<driven port>>
    +put()
    +get()
    +exists()
    +remove()
  }
  class ISnapshotStorage {
    <<driven port>>
    +load()
    +store()
    +revision()
  }
  class IKeyManagementGateway {
    <<driven port>>
    +checkKey(tenant, provider, keyId) string
  }
  class IObjectStoreEventPublisher {
    <<driven port>>
    +publish(topic, payload)
  }

  ManageBucketsUseCase --> IKeyManagementGateway
  ManageObjectsUseCase --> ObjectStorageService
  ManageVersionsUseCase --> ObjectStorageService
  ManageLifecycleRulesUseCase --> ObjectStorageService
  ResourceUseCase --> EventRecorder
  EventRecorder --> IObjectStoreEventPublisher
```

## State Diagram — Lifecycles

```mermaid
stateDiagram-v2
  state "Bucket" as B {
    [*] --> active : create
    active --> suspended : suspend
    suspended --> active : resume
    active --> [*] : delete (must be empty)
  }
```

```mermaid
stateDiagram-v2
  state "StorageObject" as O {
    [*] --> active : put / create / copy
    active --> active : put (new version)
    active --> archived : archive · lifecycle → archive
    archived --> active : restore
    active --> deleted : delete (versioned bucket → delete marker)
    archived --> deleted : delete / expire (versioned)
    deleted --> active : delete the marker · promote a version · put
    active --> [*] : delete (unversioned) · empty bucket
    deleted --> [*] : delete again (permanent)
    note right of active : legalHold blocks put, delete and expiry
  }
```

```mermaid
stateDiagram-v2
  state "ServiceBinding" as S {
    [*] --> active : create (secret shown once)
    active --> active : rotate (new secret shown once)
    active --> expired : expiresAt reached
    expired --> active : update expiresAt
    active --> revoked : revoke
    expired --> revoked : revoke
    revoked --> [*] : delete
  }
```

## Activity Diagram — Writing an object (`ObjectStorageService.write`)

```mermaid
flowchart TD
  A[put / create / update content / copy / promote] --> B{bucket active?}
  B -- no --> X1[409 suspended]
  B -- yes --> C{valid key, size ≤ maxObjectSize?}
  C -- no --> X2[422 / 413]
  C -- yes --> D{object exists?}
  D -- yes --> E{legal hold or archived?}
  E -- yes --> X3[409]
  E -- no --> F
  D -- no --> F[quota check: +size − released bytes if unversioned]
  F -- exceeded --> X4[422 quota]
  F -- ok --> G{content given as blob? copy/promote}
  G -- no --> H[blob = SHA-256 put into IBlobStorage; ETag = MD5]
  G -- yes --> I[reuse blob id and ETag]
  H --> J[save ObjectVersion n+1, isLatest]
  I --> J
  J --> K{versioning enabled?}
  K -- yes --> L[previous latest → isLatest = false]
  K -- no --> M[purge older versions; GC unreferenced blobs]
  L --> N[update object: size, etag, type, metadata, class, status = active]
  M --> N
  N --> O[recount bucket usage] --> P[publish objectstore.object.*]
```

## Activity Diagram — Data plane authorization (`ResourceRegistry.authorize`)

```mermaid
flowchart TD
  A[content API / PutObjectContent / CLI put·get·ls·rm] --> B{binding credentials?}
  B -- yes --> C[verify access key + secret: salted SHA-256, constant time]
  C -- invalid / revoked / expired --> D[403]
  C -- valid --> E{binding bound to this bucket?}
  E -- no --> D
  E -- yes --> F{permission permits action?}
  F -- no --> D
  F -- yes --> G[principal = binding:name]
  B -- no --> H[principal = user id from XSUAA token, else anonymous]
  G --> I{bucket has enabled policies?}
  H --> I
  I -- no --> OK[allowed]
  I -- yes --> J[evaluateAccess]
  J -- explicit deny / no allow --> D
  J -- allow --> OK
```

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
  subgraph Presentation["Presentation (driving adapters)"]
    REST[REST controller<br/>/api/v1/object-store]
    CONTENT[Content controller<br/>/content/bucket/key]
    ODATA[OData v4 controller<br/>+ $metadata]
    CLI[CLI]
    GUI[GtkD GUI]
    WEB[Fiori static files]
    REG[ResourceRegistry<br/>ResourceAdapter / CatalogAdapter]
  end
  subgraph Ports
    DP[ObjectStorePorts<br/>driving ports]
    RP[Repository ports]
    SP[ISnapshotStorage · IBlobStorage]
    GP[IKeyManagementGateway]
    MP[IObjectStoreEventPublisher]
  end
  subgraph Application
    UC[Use cases<br/>buckets · objects · versions · policies · lifecycle · cors · bindings]
    AS[ObjectStorageService · Statistics · Catalog · EventRecorder]
  end
  subgraph Domain
    ENT[Entities · values · enums]
    DS[naming · checksums · bucket_rules<br/>access_evaluator · cors_matcher · lifecycle_planner · catalogs]
  end
  subgraph Persistence
    REPO[Repositories]
    SNAP[SnapshotTenantStore<br/>JSON files / memory]
    BLOB[FileBlobStorage / MemoryBlobStorage]
  end
  subgraph Infrastructure
    CFG[Configuration]
    SEC[XSUAA identity]
    KMS[Simulated KMS client]
    LOG[Logging / LogEventPublisher]
    WRK[LifecycleWorker]
    CON[Container]
  end

  REST & CONTENT & ODATA & CLI & GUI --> REG --> DP
  DP -. implemented by .-> UC
  UC --> AS --> DS
  UC --> ENT
  UC --> RP
  AS --> SP
  UC --> GP
  AS --> MP
  RP -. implemented by .-> REPO --> SNAP
  SP -. implemented by .-> BLOB
  GP -. implemented by .-> KMS
  MP -. implemented by .-> LOG
  WRK --> DP
  CON --> UC & REPO & BLOB & KMS & LOG
  REST & CONTENT & ODATA --> SEC
```

## Sequence Diagram — Fiori uploads a file

```mermaid
sequenceDiagram
  actor U as User
  participant F as Fiori app (BucketDetail)
  participant AR as Approuter
  participant OD as OData controller
  participant R as ResourceRegistry
  participant UC as ManageObjectsUseCase
  participant S as ObjectStorageService
  participant B as IBlobStorage

  U->>F: choose file (FileUploader)
  F->>F: FileReader → base64
  F->>AR: POST /odata/v4/object-store/PutObjectContent (JWT session, CSRF token)
  AR->>OD: forward with bearer token
  OD->>R: putContentJson(identity, body)
  R->>R: authorize(principal = user, action = write, key) — policies
  R->>UC: put(PutObjectRequest)
  UC->>S: write(bucket, key, data, …)
  S->>B: put(tenant, data) → blobId (SHA-256)
  S->>S: save version n+1, update object, recount bucket
  UC-->>R: UsecaseResult(id)
  R-->>OD: StorageObject payload
  OD-->>F: 200 (Int64 as strings)
  F->>AR: GET /api/v1/object-store/buckets/{id}/list?prefix=…&delimiter=/
  F-->>U: folder refreshed, toast "uploaded (version n)"
```

## Sequence Diagram — Service binding uses the content API

```mermaid
sequenceDiagram
  actor A as Admin
  participant C as CLI / Fiori
  participant UC as ManageServiceBindingsUseCase
  participant App as Client application
  participant CT as Content controller
  participant R as ResourceRegistry

  A->>C: bindings create --bucket-id=media --name=ci --permission=readWrite
  C->>UC: create → accessKeyId, secret (salted hash stored)
  UC-->>C: binding + secretAccessKey (only this once)
  A->>App: configure endpoint, access key id, secret
  App->>CT: PUT /content/media/builds/app.zip (Authorization: OSK id:secret)
  CT->>R: putContent(caller)
  R->>UC: verify(accessKeyId, secret) → valid, readWrite, bucket media
  R->>R: permits(readWrite, write) · policies for binding:ci
  R-->>CT: object (version, ETag)
  CT-->>App: 200 ETag, X-Version-Number
  A->>C: bindings rotate ci → new secret; old secret → 403
```

## Sequence Diagram — Lifecycle run

```mermaid
sequenceDiagram
  participant W as LifecycleWorker (timer) / ApplyLifecycle action
  participant UC as ManageLifecycleRulesUseCase
  participant P as lifecycle_planner
  participant S as ObjectStorageService

  W->>UC: run(tenant, bucket = all, now)
  loop each bucket with enabled rules
    UC->>P: planLifecycle(rules, objects, versions, now)
    P-->>UC: steps (expire · transition · purgeVersion)
    loop each step
      alt expire
        UC->>S: deleteObject (delete marker if versioned)
      else transition
        UC->>UC: storageClass = target (archive → status archived)
      else purgeVersion
        UC->>S: purgeVersion (GC blob)
      end
    end
    UC->>UC: rules.lastAppliedAt / lastExpired / …
  end
  UC-->>W: LifecycleRunReport (+ event objectstore.lifecycle.applied)
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
  participant CLI as uim-object-store-cli
  participant FS as dataDir (snapshots + blobs)
  participant SRV as server (SnapshotTenantStore)
  CLI->>FS: write object_store_objects.json (tmp + rename), blobs/<tenant>/<id>
  SRV->>FS: revision changed? (mtime)
  FS-->>SRV: yes → reload collection
  SRV-->>SRV: serves the new object
```

## Deployment Diagram — SAP BTP (Cloud Foundry)

```mermaid
flowchart TB
  user([Browser]) -->|HTTPS| ar
  client([Client app with access key]) -->|HTTPS| ar
  subgraph CF["Cloud Foundry space (mta.yaml)"]
    ar["object-store-approuter<br/>@sap/approuter + Fiori app (resources/)"]
    srv["object-store-srv<br/>binary buildpack · uim-object-store-platform-service<br/>dataDir: snapshots + blobs"]
  end
  xsuaa[(XSUAA<br/>object-store-xsuaa)]
  ups[(user-provided service<br/>object-store-config)]
  ar -->|destination object-store-srv,<br/>forwardAuthToken| srv
  ar --- xsuaa
  srv --- xsuaa
  srv --- ups
```

Kubernetes (`k8s/`): Deployment `cloud-object-store` (port 8092, non-root,
read-only root filesystem, `/app/data` volume), Service, ConfigMap.
