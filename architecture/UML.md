# UML — Architecture Repository

Diagrams of the architecture repository service (`architecture/backend`, module
`uim.platform.architecture`), drawn with Mermaid. Entity fields, port names, state transitions and
adapters are taken from the source code.

Contents

1. [Component view](#1-component-view)
2. [Layers and packages](#2-layers-and-packages)
3. [Domain model](#3-domain-model)
4. [Enumerations and the ArchiMate catalogue](#4-enumerations-and-the-archimate-catalogue)
5. [Lifecycle state machine](#5-lifecycle-state-machine)
6. [Ports and interactors](#6-ports-and-interactors)
7. [Persistence](#7-persistence)
8. [Presentation adapters](#8-presentation-adapters)
9. [Sequences](#9-sequences)
10. [Deployment](#10-deployment)

---

## 1. Component view

```mermaid
flowchart LR
  subgraph Browser
    UI["Fiori 3 app<br/>uim.architecture<br/>(OpenUI5, OData V4 model)"]
  end
  subgraph BTP["SAP BTP, Cloud Foundry"]
    AR["architecture-approuter<br/>@sap/approuter<br/>xs-app.json"]
    XS[("architecture-xsuaa")]
    CFG[("architecture-config<br/>user-provided")]
    subgraph SRV["architecture-srv (D / vibe.d)"]
      OD["OData v4<br/>/odata/v4/architecture"]
      REST["REST<br/>/api/v1"]
      H["/health"]
      ENG["ODataEngine<br/>(EDM model)"]
      APP["Use cases"]
      DOM["Domain"]
      ST[("Document store<br/>memory | file")]
    end
  end
  CLI["uim-architecture-cli"] --> ENG
  GUI["uim-architecture-gui (GtkD)"] --> ENG
  UI -->|HTTPS| AR
  AR -->|login / token| XS
  AR -->|"destination architecture-srv<br/>(forwardAuthToken)"| OD
  AR --> REST
  OD --> ENG
  REST --> ENG
  ENG --> APP --> DOM
  APP --> ST
  SRV -. VCAP_SERVICES .-> XS
  SRV -. VCAP_SERVICES .-> CFG
```

The OData controller, the REST facade, the CLI and the GUI all go through **one `ODataEngine`**. Payload
validation, scope checks and error mapping are therefore identical on every channel.

---

## 2. Layers and packages

```mermaid
flowchart TB
  subgraph presentation
    p_odata[odata<br/>model · engine · payloads · serializers · errors]
    p_http[http<br/>ArchitectureApiController · ArchitectureHealthController]
    p_web[web<br/>FrontendController]
    p_cli[cli<br/>buildArchitectureCli]
    p_gui[gui<br/>runArchitectureGui]
  end
  subgraph infrastructure
    i_cfg[configuration<br/>ArchitectureConfig]
    i_sec[security<br/>SecuritySetup]
    i_log[logging<br/>LoggingEventPublisher]
    i_clk[clients<br/>SystemClock · FixedClock]
    i_con[container<br/>ArchitectureContainer]
  end
  subgraph persistence
    s_rep[repositories<br/>DocumentRepository · BuildingBlockRepository · RelationshipRepository]
    s_map[mappers<br/>blockToRecord · recordToBlock · …]
    s_rec[records<br/>Collections]
    s_sto[storages<br/>createDocumentStore]
  end
  subgraph application
    a_uc[usecases<br/>ManageBuildingBlocks · ManageRelationships · AnalyzeArchitecture · ExportArchiMate]
    a_svc[services<br/>ArchitectureInteractor · DemoDataSeeder]
    a_dto[dtos<br/>BlockValues · Create/Update requests · filters · SeedResult]
  end
  subgraph ports
    po_uc[usecases<br/>IManageBuildingBlocks · IManageRelationships · IAnalyzeArchitecture · IExportArchitecture · ISeedDemoData]
    po_rep[repositories<br/>IBuildingBlockRepository · IRelationshipRepository]
    po_oth[storages · messaging · gateways<br/>IDocumentStore · IArchitectureEventPublisher · IClock]
  end
  subgraph domain
    d_ent[entities<br/>BuildingBlock · Relationship]
    d_typ[types · enumerations]
    d_svc[services<br/>lifecycle · rules · analysis]
    d_exc[exceptions<br/>ArchitectureException]
  end
  presentation --> application
  presentation --> ports
  infrastructure --> application
  infrastructure --> persistence
  application --> ports
  application --> domain
  persistence --> ports
  persistence --> domain
  ports --> domain
```

Dependencies point inwards. The domain has no framework or I/O dependencies. `ArchitectureContainer`
is the only place that wires concrete classes together.

---

## 3. Domain model

```mermaid
classDiagram
  direction LR
  class BuildingBlock {
    <<aggregate root>>
    +TenantId tenantId
    +BuildingBlockId id
    +BlockKind kind
    +string name
    +string description
    +string owner
    +LifecycleStatus status = proposed
    +string versionLabel = "1.0.0"
    +string[] tags
    +string elementType
    +string viewpoint
    +string capability
    +string[] interfaces
    +BuildingBlockId realizesId
    +string vendor
    +string endpoint
    +string dataClassification
    +string dataOwner
    +string sourceSystem
    +string factSheetType
    +string factSheetId
    +long validUntil
    +long createdAt / updatedAt
    +UserId createdBy / updatedBy
    +domain() ArchiMateDomain
    +aspect() ArchiMateAspect
    +effectiveElementType() string
    +displayName() string
    +validate()
  }
  class Relationship {
    <<aggregate root>>
    +TenantId tenantId
    +RelationshipId id
    +ArchiMateRelationshipType type
    +BuildingBlockId sourceId
    +BuildingBlockId targetId
    +string description
    +validate()
    +involves(BuildingBlockId) bool
  }
  class ElementTypeInfo {
    <<value>>
    +string name
    +ArchiMateDomain domain
    +ArchiMateAspect aspect
  }
  BuildingBlock "1" <-- "0..*" Relationship : source
  BuildingBlock "1" <-- "0..*" Relationship : target
  BuildingBlock "0..*" --> "0..1" BuildingBlock : realizes (SBB → ABB)
  BuildingBlock ..> ElementTypeInfo : elementType

  class ImpactAnalysis {
    <<value>>
    +BuildingBlockId root
    +ImpactedBlock[] impacted
    +direct() size_t
    +total() size_t
    +maxDepth() size_t
  }
  class ImpactedBlock {
    <<value>>
    +BuildingBlockId id
    +string name
    +BlockKind kind
    +LifecycleStatus status
    +size_t depth
    +ArchiMateRelationshipType via
    +BuildingBlockId viaBlock
  }
  class PhaseOutRisk {
    <<value>>
    +BuildingBlock block
    +BuildingBlockId[] dependents
  }
  class ArchitectureStatistics {
    <<value>>
    +size_t blocks
    +size_t[BlockKind] byKind
    +size_t[LifecycleStatus] byStatus
    +size_t relationships
    +size_t architectureBlocks
    +size_t realizedArchitectureBlocks
    +size_t gaps / orphans / phaseOutRisks / expired
    +coveragePercent() long
  }
  class DependencyEdge {
    <<value>>
    +BuildingBlockId provider
    +BuildingBlockId dependent
    +ArchiMateRelationshipType type
  }
  ImpactAnalysis *-- ImpactedBlock
```

**Invariants (`BuildingBlock.validate`)**

* The id matches `[a-z0-9][a-z0-9._-]{0,63}`. Name and version are required, and every text field has a
  length limit. A list has at most 50 entries of at most 128 characters each.
* `data` blocks are passive structure elements. `technology` blocks are technology elements. `business`
  blocks are business, strategy or motivation elements.
* `realizesId` is set only on `solution` blocks and never points to the block itself.
  `dataClassification` is set only on `data` blocks and must be a valid value.

**Domain services**

| Module | Functions |
|---|---|
| `services/lifecycle` | `nextStatuses`, `canTransition`, `requireTransition`, `requireDeletable` |
| `services/rules` | `relationshipViolation`, `requireValidRelationship`, `sourceImpactsTarget`, `carriesDependency` |
| `services/analysis` | `dependencyEdges`, `realizersOf`, `findGaps`, `findOrphans`, `findPhaseOutRisks`, `analyzeImpact`, `computeStatistics`, `indexById` |

---

## 4. Enumerations and the ArchiMate catalogue

```mermaid
classDiagram
  class BlockKind {
    <<enumeration>>
    architecture (ABB)
    solution (SBB)
    data (DBB)
    business (BBB)
    technology (TBB)
  }
  class LifecycleStatus {
    <<enumeration>>
    proposed
    approved
    inDevelopment
    active
    deprecated
    retired
  }
  class ArchiMateDomain {
    <<enumeration>>
    common
    motivation
    strategy
    business
    application
    technology
    implementationAndMigration
  }
  class ArchiMateAspect {
    <<enumeration>>
    activeStructure
    behavior
    passiveStructure
    motivation
    composite
  }
  class ArchiMateRelationshipType {
    <<enumeration>>
    composition
    aggregation
    assignment
    realization
    serving
    access
    influence
    triggering
    flow
    specialization
    association
  }
  class DataClassification {
    <<enumeration>>
    public
    internal
    confidential
    restricted
  }
```

`archimateElementTypes` lists the 60 element types of ArchiMate 3.2 with their domain and aspect.
Physical elements are filed under `technology`. `leanixFactSheetTypes` lists the SAP LeanIX fact sheet
types. Parsing ignores case and the characters `-`, `_` and space. Values from 1.x are accepted as well,
such as `identified`, `used-by` and `ABB`.

---

## 5. Lifecycle state machine

```mermaid
stateDiagram-v2
  [*] --> proposed : create (default)
  proposed --> approved : approve
  proposed --> retired : reject
  approved --> proposed : back to review
  approved --> inDevelopment : start build
  approved --> active : go live
  approved --> retired : cancel
  inDevelopment --> approved : back
  inDevelopment --> active : go live
  inDevelopment --> retired : cancel
  active --> deprecated : phase out
  deprecated --> active : reinstate
  deprecated --> retired : decommission
  retired --> [*]

  note right of active
    active and deprecated blocks
    cannot be deleted
  end note
  note right of retired
    final; no new relationships;
    does not close gaps
  end note
```

Only the `ChangeStatus` action (scope **Govern**) and `POST /api/v1/building-blocks/{id}/status` perform
transitions. On PATCH, `status` is immutable.

---

## 6. Ports and interactors

```mermaid
classDiagram
  direction TB
  class IManageBuildingBlocks {
    <<interface>>
    +createBlock(CreateBlockRequest) BuildingBlock
    +updateBlock(UpdateBlockRequest) BuildingBlock
    +changeStatus(TenantId, BuildingBlockId, string status, UserId) BuildingBlock
    +getBlock(TenantId, BuildingBlockId) BuildingBlock
    +listBlocks(TenantId, BlockFilter) BuildingBlock[]
    +deleteBlock(TenantId, BuildingBlockId, UserId)
  }
  class IManageRelationships {
    <<interface>>
    +createRelationship(CreateRelationshipRequest) Relationship
    +updateRelationship(UpdateRelationshipRequest) Relationship
    +getRelationship(TenantId, RelationshipId) Relationship
    +listRelationships(TenantId, RelationshipFilter) Relationship[]
    +deleteRelationship(TenantId, RelationshipId, UserId)
  }
  class IAnalyzeArchitecture {
    <<interface>>
    +statistics(TenantId) ArchitectureStatistics
    +gaps(TenantId) BuildingBlock[]
    +orphans(TenantId) BuildingBlock[]
    +phaseOutRisks(TenantId) PhaseOutRisk[]
    +impact(TenantId, BuildingBlockId) ImpactAnalysis
  }
  class IExportArchitecture {
    <<interface>>
    +exportArchiMate(TenantId, string modelName) string
  }
  class ISeedDemoData {
    <<interface>>
    +seed(TenantId, UserId) SeedResult
  }
  class ArchitecturePorts {
    <<struct>>
    blocks
    relationships
    analysis
    exporter
    seeder
  }
  class ArchitectureInteractor {
    <<abstract>>
    #ArchitectureRepositories repos
    #IClock clock
    #IArchitectureEventPublisher events
    #emit(type, tenant, subject, data)
    #stamp(entity, actor)
    #touch(entity, actor)
    #loadBlock(tenant, id) BuildingBlock
  }
  class ManageBuildingBlocksUseCase
  class ManageRelationshipsUseCase
  class AnalyzeArchitectureUseCase
  class ExportArchiMateUseCase
  class DemoDataSeeder

  ArchitectureInteractor <|-- ManageBuildingBlocksUseCase
  ArchitectureInteractor <|-- ManageRelationshipsUseCase
  ArchitectureInteractor <|-- AnalyzeArchitectureUseCase
  ArchitectureInteractor <|-- ExportArchiMateUseCase
  IManageBuildingBlocks <|.. ManageBuildingBlocksUseCase
  IManageRelationships <|.. ManageRelationshipsUseCase
  IAnalyzeArchitecture <|.. AnalyzeArchitectureUseCase
  IExportArchitecture <|.. ExportArchiMateUseCase
  ISeedDemoData <|.. DemoDataSeeder
  DemoDataSeeder --> IManageBuildingBlocks
  DemoDataSeeder --> IManageRelationships
  ArchitecturePorts o-- IManageBuildingBlocks
  ArchitecturePorts o-- IManageRelationships
  ArchitecturePorts o-- IAnalyzeArchitecture
  ArchitecturePorts o-- IExportArchitecture
  ArchitecturePorts o-- ISeedDemoData

  class BlockValues {
    <<dto>>
    Nullable~string~ name, description, owner, status, versionLabel,
    elementType, viewpoint, capability, realizesId, vendor, endpoint,
    dataClassification, dataOwner, sourceSystem, factSheetType,
    factSheetId, validUntil
    Nullable~string[]~ tags, interfaces
  }
  ManageBuildingBlocksUseCase ..> BlockValues : applyValues()
```

`BlockValues` holds only the values that were sent, so the same DTO serves create and PATCH.
Enumerations arrive as text and the use case parses them, so every channel gets the same error message.

**Domain events** (`IArchitectureEventPublisher`, written as JSON log lines by `LoggingEventPublisher`):
`block.created`, `block.updated`, `block.statusChanged {from, to}`,
`block.deleted {relationshipsRemoved, realizationsCleared}`, `relationship.created`,
`relationship.updated`, `relationship.deleted`.

---

## 7. Persistence

```mermaid
classDiagram
  direction LR
  class IDocumentStore {
    <<interface · uim-platform:service>>
    +all(collection, tenant) Json[]
    +get(collection, tenant, key) Json
    +put(collection, tenant, key, Json)
    +remove(collection, tenant, key) bool
    +count(collection, tenant) size_t
  }
  class MemoryDocumentStore
  class FileDocumentStore
  IDocumentStore <|.. MemoryDocumentStore
  MemoryDocumentStore <|-- FileDocumentStore

  class IArchitectureRepository~TEntity, TId~ {
    <<interface>>
    +findAll(TenantId) TEntity[]
    +findById(TenantId, TId) TEntity
    +existsById(TenantId, TId) bool
    +countAll(TenantId) size_t
    +save(TEntity)
    +removeById(TenantId, TId) bool
  }
  class IBuildingBlockRepository {
    <<interface>>
    +findRealizing(TenantId, BuildingBlockId abb) BuildingBlock[]
  }
  class IRelationshipRepository {
    <<interface>>
    +findByBlock(TenantId, BuildingBlockId) Relationship[]
    +removeByBlock(TenantId, BuildingBlockId) size_t
  }
  class DocumentRepository~TEntity, TId, toRecord, fromRecord~
  class BuildingBlockRepository
  class RelationshipRepository

  IArchitectureRepository <|-- IBuildingBlockRepository
  IArchitectureRepository <|-- IRelationshipRepository
  IArchitectureRepository <|.. DocumentRepository
  DocumentRepository <|-- BuildingBlockRepository
  DocumentRepository <|-- RelationshipRepository
  IBuildingBlockRepository <|.. BuildingBlockRepository
  IRelationshipRepository <|.. RelationshipRepository
  DocumentRepository --> IDocumentStore
```

| Collection | Key | Record |
|---|---|---|
| `buildingBlocks` | block id | flat JSON. Times are std time (hnsecs), enumerations are their string value, `schema: 2` |
| `relationships` | relationship id | `type`, `sourceId`, `targetId`, `description` and the audit fields |

Documents are partitioned by tenant. When a record is read, unknown fields are ignored and missing fields
take their defaults, so 1.x records stay readable.

---

## 8. Presentation adapters

```mermaid
classDiagram
  direction LR
  class ODataEngine {
    <<uim-platform:service>>
    +provide(set, IEntitySetProvider)
    +handle(action, handler)
    +query / read / create / update / remove / invoke
    +bool enforceScopes
  }
  class architectureModel {
    <<function>>
    BuildingBlocks · Relationships · Gaps · Orphans
    PhaseOutRisks · ElementTypes · Statistics
    ChangeStatus · AnalyzeImpact · ExportArchiMate · SeedDemoData
  }
  class architectureEngine {
    <<function>>
    PortProvider(DelegateEntitySetProvider) per set
  }
  class ODataController {
    <<uim-platform:service>>
    $metadata · $batch · CSRF
  }
  class ArchitectureApiController {
    /api/v1/building-blocks …
    legacyAliases()
    filterBlocks()
  }
  class ArchitectureHealthController
  class FrontendController {
    /app/* (local dev)
  }
  class CliApplication {
    <<uim-platform:service>>
    sets · list · get · create · update · delete · invoke
    + stats · seed · status · relate · impact · gaps · export · config
  }
  class EntityBrowserWindow {
    <<GtkD · uim-platform:service>>
  }
  architectureEngine ..> architectureModel
  architectureEngine --> ODataEngine : builds
  ODataController --> ODataEngine
  ArchitectureApiController --> ODataEngine
  CliApplication --> ODataEngine
  EntityBrowserWindow --> ODataEngine
  architectureEngine ..> ArchitecturePorts
```

The adapters map errors in one way: `ArchitectureException` becomes `EntitySetException` through
`translated()`. The kind `invalid` maps to 400, `notFound` to 404, `conflict` to 409 and
`ruleViolation` to 422. A missing scope gives 403 and a missing token in `xsuaa` or `hs256` mode gives
401.

---

## 9. Sequences

### 9.1 Lifecycle transition from the Fiori app

```mermaid
sequenceDiagram
  autonumber
  actor Board as Architecture board
  participant UI as Fiori BlockDetail
  participant AR as Approuter
  participant OC as ODataController
  participant E as ODataEngine
  participant UC as ManageBuildingBlocksUseCase
  participant L as lifecycle (domain)
  participant R as BuildingBlockRepository
  Board->>UI: Lifecycle ▸ "Active"
  UI->>UI: formatter.nextStatuses(status) → ActionSheet
  UI->>AR: POST /odata/v4/architecture/ChangeStatus {id, status}
  AR->>OC: + Bearer JWT (forwardAuthToken)
  OC->>E: invoke(ctx, "ChangeStatus")
  E->>E: checkScope("Govern")
  E->>UC: changeStatus(t, id, "active", actor)
  UC->>R: findById
  UC->>L: requireTransition(approved, active)
  UC->>UC: checkRealization · validate · touch
  UC->>R: save
  UC-->>E: block (event block.statusChanged)
  E-->>OC: {id, previousStatus, status}
  OC-->>UI: 200
  UI->>UI: refresh model (header KPIs, lists)
```

### 9.2 Creating a relationship (rules)

```mermaid
sequenceDiagram
  autonumber
  participant C as Client (REST/OData/CLI)
  participant E as ODataEngine
  participant UC as ManageRelationshipsUseCase
  participant BR as BuildingBlockRepository
  participant RR as RelationshipRepository
  participant RU as rules (domain)
  C->>E: create("Relationships", {type, sourceId, targetId})
  E->>E: validatePayload (EDM types, mandatory, unknown properties)
  E->>UC: createRelationship(request)
  UC->>UC: parseRelationshipType
  UC->>BR: findById(source), findById(target)
  alt a block does not exist
    UC-->>C: 400 invalid
  end
  UC->>RU: requireValidRelationship(source, target, type)
  alt ArchiMate / TOGAF rule violated
    RU-->>C: 422 BusinessRuleViolation
  end
  UC->>RR: findByBlock(source) — duplicate?
  alt duplicate
    UC-->>C: 409 conflict
  end
  UC->>RR: save
  UC-->>C: 201 row (with sourceName, targetName)
```

### 9.3 Impact analysis

```mermaid
sequenceDiagram
  autonumber
  participant UI as Fiori / REST / CLI
  participant E as ODataEngine
  participant A as AnalyzeArchitectureUseCase
  participant D as analysis (domain)
  UI->>E: invoke("AnalyzeImpact", {id})
  E->>A: impact(t, id)
  A->>A: loadBlock (404 if missing)
  A->>D: analyzeImpact(id, blocks, relationships)
  D->>D: dependencyEdges() — direction per relationship type + realizesId
  loop breadth first, cycles cut
    D->>D: dependents of frontier → ImpactedBlock(depth, via, viaBlock)
  end
  D-->>UI: Collection(ImpactedBlock)
```

### 9.4 Deleting a building block

```mermaid
sequenceDiagram
  autonumber
  participant C as Client
  participant UC as ManageBuildingBlocksUseCase
  participant L as lifecycle
  participant RR as RelationshipRepository
  participant BR as BuildingBlockRepository
  C->>UC: deleteBlock(t, id, actor)
  UC->>BR: findById (404)
  UC->>L: requireDeletable — active / deprecated → 422
  UC->>RR: removeByBlock(id)
  UC->>BR: findRealizing(id) → clear realizesId, save
  UC->>BR: removeById
  UC-->>C: 204 (event block.deleted)
```

---

## 10. Deployment

```mermaid
flowchart TB
  subgraph MTA["mta.yaml — uim-architecture 2.0.0"]
    M1["architecture-srv<br/>binary_buildpack · 256M<br/>./uim-architecture-platform-service<br/>health: /health"]
    M2["architecture-approuter<br/>approuter.nodejs · 256M<br/>resources/ = frontend"]
    R1[("architecture-xsuaa<br/>xsuaa / application<br/>xs-security.json")]
    R2[("architecture-config<br/>user-provided")]
  end
  M2 -- "destinations: architecture-srv" --> M1
  M1 --> R1
  M1 --> R2
  M2 --> R1

  subgraph K8S["Kubernetes (k8s/)"]
    K1["ConfigMap architecture-config"]
    K2["Deployment architecture<br/>1 replica · Recreate · non-root<br/>probes /health"]
    K3[("PVC architecture-data 1Gi<br/>/data/architecture.json")]
    K4["Service architecture :8122"]
  end
  K1 --> K2
  K2 --> K3
  K4 --> K2
```

| Artefact | Built from | Runs |
|---|---|---|
| `uim-architecture-platform-service` | `dub build --config=defaultRun` | HTTP server (REST, OData, `/app`) |
| `uim-architecture-cli` | `dub build --config=cli` | administration and scripting on the same store |
| `uim-architecture-gui` | `dub build --config=gui` | GtkD desktop browser |
| container image | `backend/Dockerfile` / `Containerfile` (repository root as the build context) | server + CLI + frontend |
