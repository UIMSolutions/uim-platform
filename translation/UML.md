# UML — Translation Hub Service

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class TranslationProject {
        +TranslationProjectId id
        +TenantId tenantId
        +string name
        +string description
        +ProjectType projectType
        +string sourceLanguage
        +string[] targetLanguages
        +ProjectStatus status
        +TranslationProvider provider
        +string repositoryUrl
        +string baseBranch
        +string abapSystemId
        +long createdAt
        +long updatedAt
        +Json toJson()
    }

    class GlossaryEntry {
        +GlossaryEntryId id
        +TenantId tenantId
        +string sourceLanguage
        +string targetLanguage
        +string sourceTerm
        +string targetTerm
        +string domainName
        +string context
        +bool mandatory
        +long createdAt
        +Json toJson()
    }

    class TranslationJob {
        +TranslationJobId id
        +TenantId tenantId
        +JobType jobType
        +string sourceLanguage
        +string targetLanguage
        +TranslationProvider provider
        +JobStatus status
        +string inputContent
        +string outputContent
        +string contentType
        +int qualityScore
        +long completedAt
        +Json toJson()
    }

    class TranslationResult {
        +string sourceText
        +string translatedText
        +string sourceLanguage
        +string targetLanguage
        +TranslationProvider provider
        +int qualityScore
        +QualityLevel qualityLevel
    }

    TranslationProject --> ProjectType
    TranslationProject --> ProjectStatus
    TranslationProject --> TranslationProvider
    TranslationJob --> JobStatus
    TranslationJob --> JobType
    TranslationJob --> TranslationProvider
    TranslationResult --> TranslationProvider
    TranslationResult --> QualityLevel
```

## Class Diagram — Hexagonal Architecture

```mermaid
classDiagram
    %% Domain
    class TranslationProjectRepository {
        <<interface>>
        +save(TranslationProject)
        +findById(TenantId, TranslationProjectId) TranslationProject
        +findByTenant(TenantId) TranslationProject[]
        +update(TranslationProject)
        +remove(TranslationProject)
    }
    class GlossaryEntryRepository {
        <<interface>>
        +save(GlossaryEntry)
        +findById(TenantId, GlossaryEntryId) GlossaryEntry
        +findByTenant(TenantId) GlossaryEntry[]
        +update(GlossaryEntry)
        +remove(GlossaryEntry)
    }
    class TranslationJobRepository {
        <<interface>>
        +save(TranslationJob)
        +findById(TenantId, TranslationJobId) TranslationJob
        +findByTenant(TenantId) TranslationJob[]
        +update(TranslationJob)
    }
    class TranslationEngine {
        +translate(text, srcLang, tgtLang, provider) TranslationResult
        +translateBatch(texts[], srcLang, tgtLang, provider) TranslationResult[]
        +supportsLanguagePair(src, tgt) bool
        +supportedLanguages() string[]
    }

    %% Application
    class ManageTranslationProjectsUseCase {
        +createProject(CreateTranslationProjectRequest) CommandResult
        +listProjects(TenantId) TranslationProject[]
        +getProject(TenantId, TranslationProjectId) TranslationProject
        +updateProject(UpdateTranslationProjectRequest) CommandResult
        +deleteProject(TenantId, TranslationProjectId) CommandResult
    }
    class ManageGlossaryEntriesUseCase {
        +createEntry(CreateGlossaryEntryRequest) CommandResult
        +listEntries(TenantId) GlossaryEntry[]
        +getEntry(TenantId, GlossaryEntryId) GlossaryEntry
        +updateEntry(UpdateGlossaryEntryRequest) CommandResult
        +deleteEntry(TenantId, GlossaryEntryId) CommandResult
    }
    class ManageTranslationJobsUseCase {
        +submitJob(SubmitTranslationJobRequest) CommandResult
        +processJob(TenantId, TranslationJobId) CommandResult
        +listJobs(TenantId) TranslationJob[]
        +getJob(TenantId, TranslationJobId) TranslationJob
        +cancelJob(TenantId, TranslationJobId) CommandResult
    }
    class PerformTranslationUseCase {
        +translateTexts(TranslateTextRequest) Json
        +translateDocument(TranslateDocumentRequest) Json
        +supportedLanguages() string[]
    }

    %% Infrastructure
    class MemoryTranslationProjectRepository {
        +existsByName(TenantId, string) bool
        +findByName(TenantId, string) TranslationProject
    }
    class MemoryGlossaryEntryRepository {
        +findByLanguagePair(TenantId, src, tgt) GlossaryEntry[]
        +findByDomain(TenantId, string) GlossaryEntry[]
    }
    class MemoryTranslationJobRepository {
        +findByStatus(TenantId, JobStatus) TranslationJob[]
        +findPending(TenantId) TranslationJob[]
    }

    %% Presentation
    class TranslationProjectController {
        +registerRoutes(URLRouter)
        +handleCreate(req, res)
        +handleList(req, res)
        +handleGet(req, res)
        +handleUpdate(req, res)
        +handleDelete(req, res)
    }
    class TranslationController {
        +registerRoutes(URLRouter)
        +handleTranslate(req, res)
    }
    class TranslationJobController {
        +registerRoutes(URLRouter)
        +handleSubmit(req, res)
        +handleList(req, res)
        +handleGet(req, res)
        +handleCancel(req, res)
    }

    ManageTranslationProjectsUseCase --> TranslationProjectRepository
    ManageGlossaryEntriesUseCase --> GlossaryEntryRepository
    ManageTranslationJobsUseCase --> TranslationJobRepository
    ManageTranslationJobsUseCase --> TranslationEngine
    PerformTranslationUseCase --> TranslationEngine
    MemoryTranslationProjectRepository ..|> TranslationProjectRepository
    MemoryGlossaryEntryRepository ..|> GlossaryEntryRepository
    MemoryTranslationJobRepository ..|> TranslationJobRepository
    TranslationProjectController --> ManageTranslationProjectsUseCase
    TranslationController --> PerformTranslationUseCase
    TranslationJobController --> ManageTranslationJobsUseCase
```

## Sequence Diagram — Synchronous Text Translation

```mermaid
sequenceDiagram
    participant Client
    participant TranslationController
    participant PerformTranslationUseCase
    participant TranslationEngine

    Client->>TranslationController: POST /api/v1/translation/translate
    TranslationController->>PerformTranslationUseCase: translateTexts(request)
    PerformTranslationUseCase->>TranslationEngine: translateBatch(texts, src, tgt, provider)
    TranslationEngine-->>PerformTranslationUseCase: TranslationResult[]
    PerformTranslationUseCase-->>TranslationController: Json (translations array)
    TranslationController-->>Client: 200 OK { translations, qualityScores }
```

## Sequence Diagram — Async Document Translation Job

```mermaid
sequenceDiagram
    participant Client
    participant TranslationJobController
    participant ManageTranslationJobsUseCase
    participant TranslationJobRepository
    participant TranslationEngine

    Client->>TranslationJobController: POST /api/v1/translation/jobs
    TranslationJobController->>ManageTranslationJobsUseCase: submitJob(request)
    ManageTranslationJobsUseCase->>TranslationJobRepository: save(job{status=pending})
    ManageTranslationJobsUseCase-->>TranslationJobController: CommandResult(jobId)
    TranslationJobController-->>Client: 202 Accepted { jobId }

    Note over Client: Poll for status...

    Client->>TranslationJobController: GET /api/v1/translation/jobs/{id}
    TranslationJobController->>ManageTranslationJobsUseCase: getJob(tenantId, jobId)
    ManageTranslationJobsUseCase->>TranslationJobRepository: findById(tenantId, jobId)
    TranslationJobRepository-->>ManageTranslationJobsUseCase: TranslationJob
    ManageTranslationJobsUseCase-->>TranslationJobController: TranslationJob
    TranslationJobController-->>Client: 200 OK { status, translatedContent }
```

## State Diagram — Translation Job Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending: submit job
    pending --> processing: processJob()
    processing --> completed: translation OK
    processing --> failed: translation error
    pending --> cancelled: cancelJob()
    completed --> [*]
    failed --> [*]
    cancelled --> [*]
```

## Component Diagram — Deployment View

```mermaid
graph TB
    subgraph "Kubernetes / Cloud Foundry"
        subgraph "Translation Hub Pod"
            APP[uim-translation-platform-service :8096]
        end
        CFG[ConfigMap\nTRANSLATION_HOST\nTRANSLATION_PORT]
        SVC[Service\nClusterIP :8096]
    end

    subgraph "Clients"
        UI[SAP Build Apps / UI5]
        ABAP[ABAP Backend]
        PIPE[CI/CD Pipeline]
    end

    UI --> SVC
    ABAP --> SVC
    PIPE --> SVC
    SVC --> APP
    CFG -.->|env vars| APP
```
