# UML — Translation Hub Service

Diagrams of the hexagonal backend (`backend/source/uim/platform/translation`), the
Fiori frontend and the BTP deployment. All diagrams are Mermaid.

## Class Diagram — Domain Entities

All aggregates mix in `TenantEntity` (`tenantId`, `id`, `createdBy/At`, `updatedBy/At`).
Project texts belong to one project and carry one `TextTranslation` per target language.
Jobs of type `software` reference a project; text and document jobs carry their content.

```mermaid
classDiagram
    class TranslationProject {
        +TranslationProjectId id
        +string name
        +string description
        +ProjectType projectType
        +string sourceLanguage
        +string[] targetLanguages
        +TranslationProvider provider
        +string domainName
        +string repositoryUrl
        +string baseBranch
        +string abapSystemId
        +ProjectStatus status
        +int textCount
        +int completionPercent
        +long lastTranslatedAt
    }
    class ProjectText {
        +ProjectTextId id
        +TranslationProjectId projectId
        +string projectName
        +string name «text key»
        +string sourceText
        +TextType textType
        +int maxLength
        +string context
        +TextTranslation[] translations
        +TextStatus status
    }
    class TextTranslation {
        <<value object>>
        +string language
        +string text
        +TranslationProvider provider
        +int qualityScore
        +int glossaryHits
        +bool reviewed
        +long translatedAt
    }
    class GlossaryEntry {
        +GlossaryEntryId id
        +string name «derived»
        +string sourceLanguage
        +string targetLanguage
        +string sourceTerm
        +string targetTerm
        +string domainName
        +string context
        +bool mandatory
        +bool caseSensitive
    }
    class TranslationJob {
        +TranslationJobId id
        +string name «derived»
        +JobType jobType
        +TranslationProjectId projectId
        +string sourceLanguage
        +string targetLanguage
        +TranslationProvider provider
        +string domainName
        +string contentType
        +string content
        +string translatedContent
        +int characterCount
        +int qualityScore
        +QualityLevel qualityLevel
        +int glossaryHits
        +JobStatus status
        +string statusMessage
        +int attempts
        +long startedAt
        +long completedAt
    }
    class Language {
        <<reference data>>
        +string id
        +string name
        +string nativeName
        +bool rightToLeft
    }
    class TranslationDomain {
        <<reference data>>
        +string id
        +string name
    }
    class TextTypeInfo {
        <<reference data>>
        +string id
        +string name
        +string description
        +int recommendedMaxLength
    }

    TranslationProject "1" --> "*" ProjectText : texts (cascade delete)
    ProjectText "1" *-- "*" TextTranslation : translations
    TranslationJob "*" ..> "0..1" TranslationProject : software job
    GlossaryEntry ..> TranslationDomain : domainName
    TranslationProject ..> Language : source / targets
    ProjectText ..> TextTypeInfo : textType
```

## Class Diagram — Enumerations

```mermaid
classDiagram
    class ProjectType { <<enumeration>> file git abap api }
    class ProjectStatus { <<enumeration>> draft active inProgress completed archived }
    class TextStatus { <<enumeration>> untranslated partial translated reviewed }
    class TextType { <<enumeration>> uiText tooltip errorMessage documentation notification emailBody reportTitle log }
    class TranslationProvider { <<enumeration>> mltr machineMt companyMltr llm }
    class QualityLevel { <<enumeration>> excellent good adequate poor unknown }
    class JobType { <<enumeration>> text document software }
    class JobStatus { <<enumeration>> pending processing completed failed cancelled }
```

## Class Diagram — Domain and Application Services

```mermaid
classDiagram
    class languages {
        <<domain service>>
        +supportedLanguages Language[44]
        +normalizeLanguage(tag) string
        +requireLanguage(what, tag) string
        +validateLanguagePair(source, target)
        +requireTargetLanguages(source, targets) string[]
    }
    class glossary {
        <<domain service>>
        +applicableEntries(entries, src, tgt, domain, provider) GlossaryEntry[]
        +protectTerms(text, entries) ProtectedText
        +restoreTerms(text, targets, out hits) string
    }
    class quality {
        <<domain service>>
        +qualityLevelOf(score) QualityLevel
        +adjustQuality(score, hits, length, maxLength) int
        +averageQuality(scores) int
    }
    class lifecycle {
        <<domain service>>
        +textStatusOf(translations, targets) TextStatus
        +completionOf(texts, targets) int
        +progressStatus(current, percent, count) ProjectStatus
        +ensureWritable(project)
        +ensureProcessable / ensureCancellable / ensureRetryable(job)
    }
    class Translator {
        <<application service>>
        +resolveProvider(name) TranslationProvider
        +translate(tenant, text, src, tgt, provider, domain, type, maxLength) TranslatedText
        +translateDocument(tenant, content, contentType, src, tgt, provider, domain) DocumentTranslationResult
    }
    class ProjectTranslationService {
        <<application service>>
        +translateText(ref text, project, languages, force, ref run)
        +translateProject(project, languages, force, actor) ProjectRun
        +refresh(tenant, projectId)
        +restatus(project)
    }
    class ITranslationProviderGateway {
        <<driven port>>
        +translate(text, src, tgt, provider, domain, type) ProviderTranslation
        +available(provider) bool
    }
    class SimulatedTranslationProvider
    Translator --> ITranslationProviderGateway
    Translator --> IGlossaryRepository
    Translator ..> glossary
    Translator ..> quality
    ProjectTranslationService --> Translator
    ProjectTranslationService ..> lifecycle
    SimulatedTranslationProvider ..|> ITranslationProviderGateway
```

## State Diagram — Lifecycles

```mermaid
stateDiagram-v2
    state "TranslationProject" as P {
        [*] --> draft
        draft --> active : activate / first translation run
        active --> inProgress : texts partly translated
        inProgress --> completed : every text in every target language
        completed --> inProgress : new target language / new or changed text
        draft --> archived : archive
        active --> archived : archive
        inProgress --> archived : archive
        completed --> archived : archive
        archived --> active : reopen (status from progress)
    }
```

```mermaid
stateDiagram-v2
    state "ProjectText" as T {
        [*] --> untranslated
        untranslated --> partial : some target languages
        untranslated --> translated : all target languages
        partial --> translated : all target languages
        translated --> reviewed : review (all languages)
        reviewed --> partial : target language added
        translated --> untranslated : source text changed
        partial --> untranslated : source text changed
    }
```

```mermaid
stateDiagram-v2
    state "TranslationJob" as J {
        [*] --> pending : submit
        pending --> processing : worker / process
        processing --> completed
        processing --> failed : business error (stored in statusMessage)
        pending --> cancelled : cancel
        processing --> cancelled : cancel
        failed --> pending : retry
        cancelled --> pending : retry
    }
```

## Activity Diagram — Translation pipeline (`Translator.translate`)

```mermaid
flowchart TD
    A([text, src, tgt, provider, domain, textType]) --> B{provider available?}
    B -- no --> X[409 Conflict]
    B -- yes --> C[glossary entries of the language pair]
    C --> D[applicableEntries:<br/>domain match · mandatory, or optional for companyMltr<br/>longest terms first]
    D --> E[protectTerms: whole words → ⟦n⟧]
    E --> F[gateway.translate]
    F --> G[restoreTerms: ⟦n⟧ → target term, count hits]
    G --> H[adjustQuality: engine score + 2·hits − 20 if > maxLength]
    H --> I{longer than maxLength /<br/>text type recommendation?}
    I -- yes --> J[truncationRisk = true]
    I -- no --> K
    J --> K([TranslatedText])
```

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
    subgraph Driving["Driving adapters (presentation)"]
        REST["http · TranslationRestController<br/>/api/v1/translation"]
        OD["odata · TranslationODataController<br/>/odata/v4/translation + $metadata"]
        CLI["cli · TranslationCli"]
        GUI["gui · TranslationWindow (GtkD)"]
        WEB["web · FrontendController<br/>Fiori app (local dev)"]
        REG["resources · ResourceRegistry<br/>4 × ResourceAdapter · 4 × CatalogAdapter"]
    end
    subgraph Core["Application core"]
        PORTS["ports · TranslationPorts<br/>IManageResource&lt;…&gt; × 4 · IPerformTranslationUseCase<br/>ITranslationCatalogService · ITranslationStatisticsService"]
        UC["application · ResourceUseCase&lt;…&gt; × 4 · PerformTranslationUseCase<br/>Translator · ProjectTranslationService<br/>Catalog · Statistics · EventRecorder"]
        DOM["domain · entities · languages · catalogs<br/>glossary · quality · names · lifecycle"]
    end
    subgraph Driven["Driven adapters"]
        REPO["persistence · 4 repositories<br/>RecordMapper&lt;T&gt;"]
        STORE["storages · SnapshotTenantStore<br/>JsonFileSnapshotStorage"]
        PROV["clients · SimulatedTranslationProvider<br/>(ITranslationProviderGateway)"]
        PUB["logging · LogEventPublisher<br/>(ITranslationEventPublisher)"]
    end
    INFRA["infrastructure · TranslationConfig · identity · JobWorker · Container"]

    REST --> REG
    OD --> REG
    CLI --> REG
    GUI --> REG
    REG --> PORTS
    PORTS --> UC
    UC --> DOM
    UC --> REPO
    UC --> PROV
    UC --> PUB
    REPO --> STORE
    STORE --> FILES[("data/*.json")]
    INFRA -. wires .-> UC
    INFRA -. wires .-> REPO
    INFRA -. runs .-> PORTS
```

Dependencies point inwards. Presentation knows only `TranslationPorts`. Use cases know
only the port interfaces (`TranslationRepositories`, `ITranslationProviderGateway`,
`ITranslationEventPublisher`).

## Class Diagram — Generic use cases and adapters

```mermaid
classDiagram
    class IManageResource~TEntity,TId,TCreate,TUpdate~ {
        <<interface>>
        +create(TCreate) UsecaseResult
        +update(TUpdate) UsecaseResult
        +remove(TenantId, TId, UserId) UsecaseResult
        +get(TenantId, TId) TEntity
        +list(TenantId) TEntity[]
    }
    class ResourceUseCase~TEntity,TId,TCreate,TUpdate~ {
        <<abstract>>
        #build(TCreate) TEntity
        #apply(ref TEntity, TSpec)
        #beforeRemove(TEntity)
        #afterCreate / afterUpdate / afterRemove
        #transition(tenant, id, actor, verb, change) UsecaseResult
        #requireProject(tenant, id) TranslationProject
    }
    class ManageProjectsUseCase {
        +activate() +translate(force) +archive() +reopen()
    }
    class ManageProjectTextsUseCase {
        +translate() +setTranslation(language, text) +review(language)
    }
    class ManageGlossaryUseCase
    class ManageJobsUseCase {
        +process() +processPending(limit) JobRunReport +cancel() +retry()
    }
    class IResourceAdapter {
        <<interface>>
        +path() setName() typeName() title()
        +parentField() updatable() readOnly()
        +fields() inputFields() recordTypes() columns() actions()
        +list(tenant, filters) Json[]
        +get / create / update / remove / invoke
    }
    class ResourceAdapter~TEntity,TId,TCreate,TUpdate~
    class CatalogAdapter~T~ {
        «read-only: 405 on writes»
    }
    class ResourceRegistry {
        +byPath(path) bySet(set) byODataAction(name)
        +resolve(adapter, tenant, idOrName) string
        +withReferences(tenant, body) Json
        +translateTexts(who, body) Json
        +translateDocument(who, body) Json
        +processJobs(tenant) Json
        +statistics(tenant) Json
    }

    ResourceUseCase ..|> IManageResource
    ManageProjectsUseCase --|> ResourceUseCase
    ManageProjectTextsUseCase --|> ResourceUseCase
    ManageGlossaryUseCase --|> ResourceUseCase
    ManageJobsUseCase --|> ResourceUseCase
    ResourceAdapter ..|> IResourceAdapter
    CatalogAdapter ..|> IResourceAdapter
    ResourceAdapter --> IManageResource
    ResourceRegistry o-- IResourceAdapter
    TranslationRestController --> ResourceRegistry
    TranslationODataController --> ResourceRegistry
    TranslationCli --> ResourceRegistry
    TranslationWindow --> ResourceRegistry
```

## Sequence Diagram — Fiori translates a project

```mermaid
sequenceDiagram
    actor U as Translator (browser)
    participant AR as Approuter (XSUAA)
    participant OD as TranslationODataController
    participant RG as ResourceRegistry
    participant UC as ManageProjectsUseCase
    participant PT as ProjectTranslationService
    participant TR as Translator
    participant GW as ITranslationProviderGateway
    participant RP as Repositories

    U->>AR: POST /odata/v4/translation/TranslateTranslationProject {"id"}
    AR->>OD: forward (+ JWT)
    OD->>RG: byODataAction → projects.invoke("translate")
    RG->>UC: translate(tenant, id, force=false, actor)
    UC->>RP: project (ensureWritable)
    UC->>PT: translateProject(project)
    loop every text × target language without translation
        PT->>TR: translate(text, src, lang, provider, domain, type, maxLength)
        TR->>RP: glossary.findByLanguagePair
        TR->>GW: translate(protected text)
        GW-->>TR: text + engine score
        TR-->>PT: TranslatedText (glossary restored, quality)
        PT->>RP: texts.update
    end
    PT->>RP: refresh project (textCount, completion, status)
    UC-->>RG: UsecaseResult
    RG-->>OD: project payload
    OD-->>U: 200 TranslationProject (status completed, 100 %)
```

## Sequence Diagram — Asynchronous document job

```mermaid
sequenceDiagram
    participant C as Client
    participant REST as TranslationRestController
    participant J as ManageJobsUseCase
    participant W as JobWorker (timer)
    participant TR as Translator
    participant R as IJobRepository

    C->>REST: POST /api/v1/translation/documents/translate/async
    REST->>J: create(SubmitJobRequest document)
    J->>R: save (pending)
    REST-->>C: 202 + Location /jobs/{id}
    W->>J: processPending(tenant, 20)
    J->>R: update (processing, attempts+1)
    J->>TR: translateDocument(content, contentType, …)
    TR-->>J: translatedContent, quality, glossaryHits
    J->>R: update (completed | failed + statusMessage)
    C->>REST: GET /api/v1/translation/jobs/{id}
    REST-->>C: 200 {status: completed, translatedContent}
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
    participant CLI as uim-translation-cli
    participant FS as data/*.json
    participant SRV as server (SnapshotTenantStore)
    CLI->>FS: import-texts Webshop i18n.properties → project_texts.json (temp + rename)
    SRV->>FS: next read: revision (mtime) changed → reload
    SRV-->>SRV: TranslationProjects('…').textCount = 3
```

## Deployment Diagram — SAP BTP (Cloud Foundry)

```mermaid
flowchart TB
    subgraph User["Browser"]
        FIORI["Fiori app uim.translation<br/>(OData V4 model, $direct)"]
    end
    subgraph CF["Cloud Foundry space (mta.yaml)"]
        AR["translation-approuter<br/>@sap/approuter · resources/ = frontend"]
        SRV["translation-srv<br/>binary_buildpack · uim-translation-platform-service<br/>REST · OData v4 · JobWorker"]
        XSUAA[("translation-xsuaa<br/>xsuaa / application")]
        CFG[("translation-config<br/>user-provided")]
    end
    subgraph Desktop["Workstation"]
        CLIX["uim-translation-cli"]
        GUIX["uim-translation-gui (GtkD)"]
        DATA[("data/*.json")]
    end
    FIORI -->|HTTPS| AR
    AR -->|"destination translation-srv<br/>forwardAuthToken"| SRV
    AR -.-> XSUAA
    SRV -.-> XSUAA
    SRV -.->|VCAP_SERVICES| CFG
    CLIX --> DATA
    GUIX --> DATA
```
