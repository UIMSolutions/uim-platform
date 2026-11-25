# UML — UIM Document AI

Diagrams of the redesigned service (backend 2.0). Mermaid renders them on GitHub/GitLab and in most Markdown viewers.

## 1. Domain model

```mermaid
classDiagram
  direction LR
  class Client {
    +ClientId id
    +string name
    +int documentQuota
    +bool dataFeedbackEnabled
    +admits(documents) bool
  }
  class DocumentType {
    +DocumentTypeId id
    +string name
    +DocumentCategory category
    +SchemaId defaultSchemaId
    +string[] supportedFileTypes
    +accepts(FileType) bool
  }
  class Schema {
    +SchemaId id
    +string name
    +DocumentCategory category
    +SchemaStatus status
    +string[] supportedLanguages
    +int version
    +SchemaId basedOnId
    +activate(fields, headerFields, now)
    +deprecate()
  }
  class SchemaField {
    +SchemaFieldId id
    +SchemaId schemaId
    +FieldScope fieldScope
    +int sequenceNumber
    +string name
    +string label
    +FieldValueType valueType
    +bool required
    +string defaultValue
    +string description
  }
  class DocumentTemplate {
    +TemplateId id
    +SchemaId schemaId
    +string name
    +string senderName
    +TemplateStatus status
    +string[] sampleDocumentIds
  }
  class AiDocument {
    +DocumentId id
    +string fileName
    +FileType fileType
    +long fileSize
    +int pageCount
    +string language
    +ExtractionMethod extractionMethod
    +DocumentStatus status
    +string[] labels
    +double overallConfidence
    +int lowConfidenceCount
    +int correctedFieldCount
    +MatchStatus matchStatus
    +double matchScore
    +confirm(by, now)
    +reject(reason, by, now)
    +needsReview() bool
  }
  class ExtractedField {
    +ExtractedFieldId id
    +DocumentId documentId
    +FieldScope fieldScope
    +int rowIndex
    +string name
    +FieldValueType valueType
    +bool required
    +string value
    +string originalValue
    +double confidence
    +int page
    +string coordinates
    +bool corrected
    +correct(value, by)
    +isMissing() bool
  }
  class EnrichmentData {
    +EnrichmentDataId id
    +EnrichmentSubtype subtype
    +string externalId
    +string name
    +string[] attributes
    +appliesTo(client, type) bool
  }
  class TrainingJob {
    +TrainingJobId id
    +SchemaId schemaId
    +TrainingJobStatus status
    +string modelVersion
    +int documentCount
    +double accuracy
    +start(documents, fields, now)
    +complete(accuracy, version, now)
    +cancel(now)
  }
  class UserAccount {
    +UserAccountId id
    +string displayName
    +string passwordHash
    +string[] scopes
    +bool locked
    +int failedLogins
    +recordFailure(now, max, lockSeconds)
  }

  Schema "1" *-- "0..*" SchemaField : fields
  DocumentType "0..*" --> "0..1" Schema : default schema
  DocumentTemplate "0..*" --> "1" Schema
  AiDocument "0..*" --> "1" Schema
  AiDocument "0..*" --> "0..1" DocumentType
  AiDocument "0..*" --> "0..1" DocumentTemplate
  AiDocument "0..*" --> "0..1" Client
  AiDocument "1" *-- "0..*" ExtractedField : values
  ExtractedField "0..*" --> "1" SchemaField
  AiDocument "0..*" --> "0..1" EnrichmentData : matched record
  TrainingJob "0..*" --> "1" Schema
  TrainingJob ..> AiDocument : confirmed documents
```

Every entity is tenant scoped (`TenantEntity` mixin: `tenantId`, `id`, `createdAt/By`, `updatedAt/By`). Optional
references (`clientId`, `documentTypeId`, …) left empty mean "shared by all".

## 2. Hexagonal components

```mermaid
flowchart LR
  subgraph presentation[presentation — driving adapters]
    ODATA[OData v4 controller + ODataEngine]
    REST[DaiApiController /api/v1/document-ai]
    AUTH[AuthController /auth]
    HEALTH[DaiHealthController /health]
    WEB[FrontendController /app]
    CLI[CLI commands]
    GUI[GtkD entity browser]
  end
  subgraph ports[ports]
    UC[[IProcessDocuments · IReviewFields · IManageSchemas · IManageSchemaFields · IManageTemplates
    IManageDocumentTypes · IManageEnrichmentData · IManageClients · IManageTrainingJobs · IAuthenticate · IManageUsers]]
    STAT[[IDaiStatisticsService]]
    REPO[[IDaiRepository&lt;E,Id&gt; ×10]]
    UOW[[IDaiUnitOfWork]]
    GW[[IExtractionEngine · IClock · IPasswordHasher · ITokenIssuer]]
    EV[[IDaiEventPublisher]]
  end
  subgraph application[application]
    INT[ProcessDocumentsUseCase · ReviewFieldsUseCase · ManageSchemasUseCase · ManageSchemaFieldsUseCase
    ManageTemplatesUseCase · master data use cases · ManageTrainingJobsUseCase · AccessUseCase]
    SVC[DaiStatisticsService · capabilities · demo data]
  end
  subgraph domain[domain]
    ENT[entities · types · enumerations · exceptions]
    DS[file types · field values · confidence · enrichment matcher · training evaluator]
  end
  subgraph persistence[persistence]
    DR[DocumentRepository&lt;E,Id&gt; + mappers]
    ST[BatchingFileDocumentStore / BatchingMemoryDocumentStore]
  end
  subgraph infrastructure[infrastructure]
    EXT[SimulatedExtractionEngine / HttpExtractionEngine]
    SEC[SecuritySetup · Hs256TokenIssuer · Pbkdf2PasswordHasher · RS256 XSUAA verifier]
    WRK[ProcessingWorker + ProcessingMetrics]
    CFG[DaiConfig loader]
    LOG[LoggingEventPublisher]
    CON[DaiContainer — composition root]
  end

  ODATA & REST & CLI & GUI --> UC
  AUTH --> UC
  WRK --> UC
  UC -.implemented by.-> INT
  STAT -.implemented by.-> SVC
  INT --> ENT & DS
  INT --> REPO & UOW & GW & EV
  REPO -.implemented by.-> DR --> ST
  UOW -.implemented by.-> ST
  GW -.implemented by.-> EXT & SEC
  EV -.implemented by.-> LOG
  CON --> CFG & SEC & EXT & DR & INT & ODATA
```

Dependencies point inwards: the domain knows nothing of vibe.d, JSON stores or HTTP; use cases see only ports; the
container wires adapters to ports once for server, CLI and GUI.

## 3. Document lifecycle

```mermaid
stateDiagram-v2
  [*] --> pending : upload (schema active, quota, file type)
  pending --> done : extract — values, confidence, enrichment match
  pending --> failed : extraction error
  failed --> done : reprocess
  done --> done : correct value / reprocess
  done --> pending : schema, template, method or language changed
  done --> confirmed : confirm (required values present)
  done --> rejected : reject (reason)
  failed --> rejected : reject (reason)
  confirmed --> [*]
  rejected --> [*]
```

## 4. Schema and template lifecycles

```mermaid
stateDiagram-v2
  state Schema {
    [*] --> draft : create / copy (version + 1)
    draft --> active : activate (≥ 1 header field) — fields frozen
    active --> deprecated : deprecate — no new documents
  }
  state Template {
    [*] --> tdraft : create
    tdraft --> tactive : activate (schema active)
    tactive --> inactive : deactivate
    inactive --> tactive : activate
  }
```

## 5. Training job lifecycle

```mermaid
stateDiagram-v2
  [*] --> pending
  pending --> running : start (schema not draft, ≥ minTrainingDocuments confirmed, none running for the schema)
  running --> completed : worker after trainingSeconds — accuracy, model version
  running --> failed : no training data left
  pending --> cancelled : cancel
  running --> cancelled : cancel
  failed --> running : start
  cancelled --> running : start
```

## 6. Sequence — upload, extraction, review and confirmation

```mermaid
sequenceDiagram
  actor U as Clerk (Fiori)
  participant O as ODataController / ODataEngine
  participant P as ProcessDocumentsUseCase
  participant R as ReviewFieldsUseCase
  participant E as IExtractionEngine
  participant S as Repositories + IDaiUnitOfWork
  U->>O: POST /Documents {fileName, documentTypeId, labels}
  O->>P: create(CreateCommand!DocumentInput)
  P->>S: document type, schema (active, language), template, client quota
  P->>S: save(document pending)
  U->>O: POST /ExtractDocument {id}
  O->>P: extract(t, id)
  P->>E: extract(document, schema, fields, template)
  E-->>P: values with confidence
  P->>S: batch { remove old values, save values, summary, enrichment match, save document done }
  O-->>U: document (confidencePercent, lowConfidenceCount, matchStatus)
  U->>O: POST /CorrectField {id, value}
  O->>R: correct(t, fieldId, value)
  R->>S: batch { save value (corrected, original kept), recompute summary + match }
  U->>O: POST /ConfirmDocument {id}
  O->>P: confirm — required header values present?
  P->>S: save(document confirmed)
```

## 7. Sequence — background worker

```mermaid
sequenceDiagram
  participant T as vibe.d timer (workerIntervalSeconds)
  participant W as ProcessingWorker
  participant P as IProcessDocuments
  participant J as IManageTrainingJobs
  participant M as ProcessingMetrics
  loop every interval, never overlapping
    T->>W: runOnce()
    loop worker tenants
      W->>P: processPending(t, "worker", maxDocumentsPerRun)
      W->>J: advance(t, "worker") — complete due training jobs
    end
    W->>M: record(extracted, failed, trainings)
  end
```

## 8. Sequence — built-in login (authMode jwt)

```mermaid
sequenceDiagram
  actor U as User
  participant C as Component.js / session.js
  participant A as AuthController
  participant AC as AccessUseCase
  participant H as Pbkdf2PasswordHasher
  participant I as Hs256TokenIssuer
  C->>A: GET /auth/config
  A-->>C: {mode: "jwt", loginRequired: true}
  U->>C: user name, password (LoginDialog)
  C->>A: POST /auth/login
  A->>AC: login(LoginRequest)
  AC->>H: verify(password, hash)
  alt wrong / unknown / locked
    AC-->>A: unauthorized (failed login counted, lock after 5)
    A-->>C: 401
  else ok
    AC->>I: issue(tenant, user, scopes)
    A-->>C: {access_token, expires_in, scope "Read Process …", user}
    C->>C: sessionStorage; ODataModel with Authorization header; buttons by scope
  end
  C->>A: OData / REST with Bearer token → verified (HS256), scopes enforced by ODataEngine
```

## 9. Deployment

```mermaid
flowchart TB
  subgraph btp[SAP BTP Cloud Foundry — mta.yaml]
    AR[document-ai-approuter<br/>approuter.nodejs + Fiori resources]
    SRV[document-ai-srv<br/>binary_buildpack]
    XS[(document-ai-xsuaa)]
    UPS[(document-ai-config<br/>user-provided)]
    AR -- destination document-ai-srv, forwardAuthToken --> SRV
    AR --- XS
    SRV --- XS
    SRV --- UPS
  end
  subgraph k8s[Kubernetes — k8s/]
    SVC[Service :80] --> POD[Deployment document-ai :8096<br/>Fiori under /app]
    POD --- PVC[(PVC /data<br/>document-ai.json)]
    POD --- CM[ConfigMap DOCAI_*] & SEC[Secret jwt / admin password]
  end
  EXTS[(external extraction service<br/>extractionMode http)]
  SRV -.-> EXTS
  POD -.-> EXTS
```
