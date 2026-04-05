# Document AI Service — UML Diagrams

## 1. Component Diagram — Hexagonal Architecture

```mermaid
graph TB
    subgraph Clients["External Clients"]
        REST["REST API Consumer"]
        K8S["Kubernetes Probes"]
    end

    subgraph Presentation["Presentation Layer (Driving Adapters)"]
        DC["DocumentController"]
        SC["SchemaController"]
        TC["TemplateController"]
        DTC["DocumentTypeController"]
        EDC["EnrichmentDataController"]
        TJC["TrainingJobController"]
        CC["ClientController"]
        CAP["CapabilitiesController"]
        HLC["HealthController"]
        JU["json_utils"]
    end

    subgraph Application["Application Layer (Use Cases)"]
        PDU["ProcessDocumentsUseCase"]
        MSU["ManageSchemasUseCase"]
        MTU["ManageTemplatesUseCase"]
        MDTU["ManageDocumentTypesUseCase"]
        MEDU["ManageEnrichmentDataUseCase"]
        MTJU["ManageTrainingJobsUseCase"]
        MCU["ManageClientsUseCase"]
        GCU["GetCapabilitiesUseCase"]
        DTO["DTOs"]
    end

    subgraph Domain["Domain Layer (Core)"]
        subgraph Entities
            DOC["Document"]
            SCH["Schema"]
            TPL["Template"]
            DT["DocumentType"]
            ER["ExtractionResult"]
            ED["EnrichmentData"]
            TJ["TrainingJob"]
            CL["Client"]
        end
        subgraph Ports["Ports (Interfaces)"]
            DRI["DocumentRepository"]
            ERRI["ExtractionResultRepository"]
            SRI["SchemaRepository"]
            TRI["TemplateRepository"]
            DTRI["DocumentTypeRepository"]
            EDRI["EnrichmentDataRepository"]
            TJRI["TrainingJobRepository"]
            CRI["ClientRepository"]
        end
        subgraph Services["Domain Services"]
            DV["DocumentValidator"]
            EM["EnrichmentMatcher"]
        end
        TYP["Types & Enums"]
    end

    subgraph Infrastructure["Infrastructure Layer (Driven Adapters)"]
        subgraph Memory["In-Memory Repositories"]
            MDR["MemoryDocumentRepo"]
            MERR["MemoryExtractionResultRepo"]
            MSR["MemorySchemaRepo"]
            MTR["MemoryTemplateRepo"]
            MDTR["MemoryDocumentTypeRepo"]
            MEDR["MemoryEnrichmentDataRepo"]
            MTJR["MemoryTrainingJobRepo"]
            MCR["MemoryClientRepo"]
        end
        ACFG["AppConfig + loadConfig()"]
        CONT["Container + buildContainer()"]
    end

    REST --> DC & SC & TC & DTC & EDC & TJC & CC & CAP
    K8S --> HLC
    DC --> PDU
    SC --> MSU
    TC --> MTU
    DTC --> MDTU
    EDC --> MEDU
    TJC --> MTJU
    CC --> MCU
    CAP --> GCU
    PDU --> DRI & ERRI
    MSU --> SRI
    MTU --> TRI
    MDTU --> DTRI
    MEDU --> EDRI
    MTJU --> TJRI & DRI
    MCU --> CRI
    DRI -.->|implements| MDR
    ERRI -.->|implements| MERR
    SRI -.->|implements| MSR
    TRI -.->|implements| MTR
    DTRI -.->|implements| MDTR
    EDRI -.->|implements| MEDR
    TJRI -.->|implements| MTJR
    CRI -.->|implements| MCR
```

## 2. Class Diagram — Domain Model

```mermaid
classDiagram
    class Document {
        +DocumentId id
        +TenantId tenantId
        +ClientId clientId
        +string fileName
        +FileType fileType
        +DocumentCategory category
        +DocumentTypeId documentTypeId
        +DocumentStatus status
        +string language
        +long fileSize
        +int pageCount
        +string mimeType
        +SchemaId schemaId
        +TemplateId templateId
        +ExtractionMethod extractionMethod
        +DocumentLabel[] labels
        +long uploadedAt
        +long processedAt
        +long createdAt
        +long modifiedAt
    }

    class DocumentLabel {
        +string key
        +string value
    }

    class Schema {
        +SchemaId id
        +TenantId tenantId
        +ClientId clientId
        +DocumentTypeId documentTypeId
        +string name
        +string description
        +SchemaStatus status
        +SchemaField[] headerFields
        +LineItemField[] lineItemFields
        +string[] supportedLanguages
        +long createdAt
        +long modifiedAt
    }

    class SchemaField {
        +string name
        +string label
        +FieldValueType type
        +bool required
        +string description
        +string defaultValue
        +string format
    }

    class LineItemField {
        +string name
        +string label
        +FieldValueType type
        +bool required
        +string description
    }

    class Template {
        +TemplateId id
        +TenantId tenantId
        +ClientId clientId
        +SchemaId schemaId
        +DocumentTypeId documentTypeId
        +string name
        +string description
        +TemplateStatus status
        +TemplateRegion[] regions
        +string[] sampleDocumentIds
        +long createdAt
        +long modifiedAt
    }

    class TemplateRegion {
        +string fieldName
        +int page
        +double x
        +double y
        +double width
        +double height
    }

    class DocumentType {
        +DocumentTypeId id
        +TenantId tenantId
        +ClientId clientId
        +string name
        +string description
        +DocumentCategory category
        +SchemaId defaultSchemaId
        +string[] supportedFileTypes
        +long createdAt
        +long modifiedAt
    }

    class ExtractionResult {
        +ExtractionResultId id
        +TenantId tenantId
        +ClientId clientId
        +DocumentId documentId
        +SchemaId schemaId
        +ExtractionMethod method
        +ExtractedField[] headerFields
        +LineItem[] lineItems
        +double overallConfidence
        +int extractedFieldCount
        +int totalPages
        +long processedAt
        +long createdAt
    }

    class ExtractedField {
        +string name
        +string value
        +FieldValueType type
        +double confidence
        +int page
        +string coordinates
    }

    class LineItem {
        +int rowIndex
        +ExtractedField[] fields
    }

    class EnrichmentData {
        +EnrichmentDataId id
        +TenantId tenantId
        +ClientId clientId
        +DocumentTypeId documentTypeId
        +string name
        +string description
        +string subtype
        +EnrichmentField[] fields
        +long createdAt
        +long modifiedAt
    }

    class EnrichmentField {
        +string key
        +string value
    }

    class TrainingJob {
        +TrainingJobId id
        +TenantId tenantId
        +ClientId clientId
        +DocumentTypeId documentTypeId
        +SchemaId schemaId
        +string name
        +string description
        +string modelVersion
        +TrainingJobStatus status
        +string statusMessage
        +int documentCount
        +double accuracy
        +TrainingMetric[] metrics
        +long startedAt
        +long completedAt
        +long createdAt
        +long modifiedAt
    }

    class TrainingMetric {
        +string name
        +double value
        +long timestamp
    }

    class Client {
        +ClientId id
        +TenantId tenantId
        +string name
        +string description
        +int documentQuota
        +int documentsProcessed
        +bool dataFeedbackEnabled
        +ClientLabel[] labels
        +long createdAt
        +long modifiedAt
    }

    class ClientLabel {
        +string key
        +string value
    }

    Document "1" --> "0..1" ExtractionResult : produces
    Document "*" --> "1" DocumentType : classified as
    Document "*" --> "0..1" Schema : extracted with
    Document "*" --> "0..1" Template : matched by
    Schema "*" --> "1" DocumentType : defines fields for
    Template "*" --> "1" Schema : maps regions to
    Template "*" --> "1" DocumentType : targets
    EnrichmentData "*" --> "1" DocumentType : enriches
    TrainingJob "*" --> "1" DocumentType : trains on
    TrainingJob "*" --> "1" Schema : uses
    Client "1" --> "*" Document : owns
    Document *-- DocumentLabel
    Schema *-- SchemaField
    Schema *-- LineItemField
    Template *-- TemplateRegion
    ExtractionResult *-- ExtractedField
    ExtractionResult *-- LineItem
    EnrichmentData *-- EnrichmentField
    TrainingJob *-- TrainingMetric
    Client *-- ClientLabel
```

## 3. Enumeration Diagram

```mermaid
classDiagram
    class DocumentStatus {
        <<enumeration>>
        pending
        processing
        completed
        failed
        confirmed
    }

    class TrainingJobStatus {
        <<enumeration>>
        pending
        running
        completed
        failed
        cancelled
    }

    class ExtractionMethod {
        <<enumeration>>
        ml_model
        generative_ai
        template_based
        hybrid
    }

    class DocumentCategory {
        <<enumeration>>
        invoice
        purchase_order
        payment_advice
        delivery_note
        credit_memo
        bank_statement
        receipt
        contract
        customs_declaration
        bill_of_lading
        letter_of_credit
        general
        custom
    }

    class FieldValueType {
        <<enumeration>>
        string_
        number_
        date_
        boolean_
        currency
        address
        line_items
    }

    class ConfidenceLevel {
        <<enumeration>>
        high
        medium
        low
    }

    class EnrichmentMatchStatus {
        <<enumeration>>
        matched
        unmatched
        ambiguous
    }

    class FileType {
        <<enumeration>>
        pdf
        png
        jpeg
        tiff
        xlsx
        docx
    }

    class SchemaStatus {
        <<enumeration>>
        active
        inactive
        draft
    }

    class TemplateStatus {
        <<enumeration>>
        active
        inactive
        draft
    }
```

## 4. Sequence Diagram — Document Upload & Extraction

```mermaid
sequenceDiagram
    actor Client
    participant DC as DocumentController
    participant PDU as ProcessDocumentsUseCase
    participant DV as DocumentValidator
    participant DR as MemoryDocumentRepo
    participant ERR as MemoryExtractionResultRepo

    Client->>DC: POST /api/v1/document/jobs<br/>{fileName, mimeType, schemaId, ...}
    DC->>DC: Parse JSON, extract X-Tenant-Id
    DC->>PDU: uploadDocument(UploadDocumentRequest)
    PDU->>DV: validateFileType(fileName)
    DV-->>PDU: ValidationResult{valid: true}
    PDU->>PDU: Generate UUID
    PDU->>PDU: Build Document entity<br/>(status = pending)
    PDU->>DR: save(Document)
    DR-->>PDU: void
    PDU->>PDU: Simulate extraction<br/>(status → processing → completed)
    PDU->>PDU: Build ExtractionResult<br/>(headerFields, lineItems, confidence)
    PDU->>ERR: save(ExtractionResult)
    ERR-->>PDU: void
    PDU->>DR: update(Document with processedAt)
    DR-->>PDU: void
    PDU-->>DC: CommandResult(success, documentId)
    DC-->>Client: 201 Created {id, message}
```

## 5. Sequence Diagram — Confirm Extraction Results

```mermaid
sequenceDiagram
    actor Client
    participant DC as DocumentController
    participant PDU as ProcessDocumentsUseCase
    participant DR as MemoryDocumentRepo
    participant ERR as MemoryExtractionResultRepo

    Client->>DC: POST /api/v1/document/jobs/{id}/confirm<br/>{correctedFields: [...]}
    DC->>DC: Parse JSON, extract tenant/client
    DC->>PDU: confirmDocument(ConfirmDocumentRequest)
    PDU->>DR: findById(tenantId, documentId)
    DR-->>PDU: Document (status = completed)
    PDU->>PDU: Set status = confirmed
    PDU->>PDU: Apply corrected fields (data feedback)
    PDU->>DR: update(Document)
    DR-->>PDU: void
    PDU-->>DC: CommandResult(success)
    DC-->>Client: 200 OK {id, message}
```

## 6. Sequence Diagram — Enrichment Matching

```mermaid
sequenceDiagram
    actor System
    participant EM as EnrichmentMatcher
    participant EDR as MemoryEnrichmentDataRepo

    System->>EDR: findByDocumentType(tenantId, docTypeId)
    EDR-->>System: EnrichmentData[] candidates
    System->>EM: matchEnrichmentData(ExtractionResult, candidates)
    EM->>EM: For each candidate:<br/>Compare fields by key/value
    EM->>EM: Calculate match score<br/>(matchedFields / totalFields)
    EM->>EM: Select highest scoring candidate
    alt score >= 0.8
        EM-->>System: EnrichmentMatchResult<br/>(status = matched)
    else score >= 0.4
        EM-->>System: EnrichmentMatchResult<br/>(status = ambiguous)
    else score < 0.4
        EM-->>System: EnrichmentMatchResult<br/>(status = unmatched)
    end
```

## 7. Sequence Diagram — Training Job Lifecycle

```mermaid
sequenceDiagram
    actor Client
    participant TJC as TrainingJobController
    participant MTJU as ManageTrainingJobsUseCase
    participant TJR as MemoryTrainingJobRepo
    participant DR as MemoryDocumentRepo

    Client->>TJC: POST /api/v1/training/jobs<br/>{documentTypeId, schemaId, name}
    TJC->>MTJU: create(CreateTrainingJobRequest)
    MTJU->>MTJU: Generate UUID
    MTJU->>MTJU: Build TrainingJob (status = pending)
    MTJU->>TJR: save(TrainingJob)
    TJR-->>MTJU: void
    MTJU-->>TJC: CommandResult(success, jobId)
    TJC-->>Client: 201 Created

    Note over Client,DR: Later: Update status via PATCH

    Client->>TJC: PATCH /api/v1/training/jobs/{id}<br/>{targetStatus: "running"}
    TJC->>MTJU: patchStatus(PatchTrainingJobRequest)
    MTJU->>TJR: findById(tenantId, jobId)
    TJR-->>MTJU: TrainingJob
    MTJU->>DR: countByDocumentType(tenantId, docTypeId)
    DR-->>MTJU: documentCount
    MTJU->>MTJU: Update status, set startedAt
    MTJU->>TJR: update(TrainingJob)
    TJR-->>MTJU: void
    MTJU-->>TJC: CommandResult(success)
    TJC-->>Client: 200 OK
```

## 8. State Diagram — Document Processing Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending : Upload received
    pending --> processing : Extraction starts
    processing --> completed : Extraction successful
    processing --> failed : Extraction error
    completed --> confirmed : User confirms results
    confirmed --> [*]
    failed --> [*]
```

## 9. State Diagram — Training Job Lifecycle

```mermaid
stateDiagram-v2
    [*] --> pending : Job created
    pending --> running : Training started
    running --> completed : Training successful
    running --> failed : Training error
    pending --> cancelled : User cancels
    running --> cancelled : User cancels
    completed --> [*]
    failed --> [*]
    cancelled --> [*]
```

## 10. Deployment Diagram

```mermaid
graph TB
    subgraph K8S["Kubernetes Cluster"]
        subgraph Pod["Pod: cloud-document-ai"]
            SVC["uim-document-ai<br/>-platform-service<br/>Port 8096"]
            MEM["In-Memory Store"]
            SVC --> MEM
        end
        CM["ConfigMap<br/>cloud-document-ai-config<br/>DOCAI_HOST=0.0.0.0<br/>DOCAI_PORT=8096"]
        KSVC["Service<br/>cloud-document-ai<br/>ClusterIP:8096"]
        CM -.->|envFrom| Pod
        KSVC -->|routes to| Pod
    end

    subgraph Build["Container Build (Multi-Stage)"]
        B1["Stage 1: dlang2/ldc-ubuntu:1.40.1<br/>Build binary"]
        B2["Stage 2: ubuntu:24.04<br/>Runtime image"]
        B1 -->|COPY binary| B2
    end

    actor CLIENT["API Consumer"]
    CLIENT -->|HTTP :8096| KSVC
```

## 11. Package Dependency Diagram

```mermaid
graph TD
    APP["app.d"] --> CONT["infrastructure.container"]
    CONT --> MEM_REPOS["infrastructure.persistence.memory.*"]
    CONT --> USECASES["application.use_cases.*"]
    CONT --> CONTROLLERS["presentation.http.controllers.*"]
    CONT --> CONFIG["infrastructure.config"]

    CONTROLLERS --> USECASES
    CONTROLLERS --> DTO["application.dto"]
    CONTROLLERS --> JSON["presentation.http.json_utils"]

    USECASES --> PORTS["domain.ports.*"]
    USECASES --> DTO
    USECASES --> DOMAIN_SVC["domain.services"]

    MEM_REPOS -.->|implements| PORTS
    PORTS --> ENTITIES["domain.entities.*"]
    ENTITIES --> TYPES["domain.types"]
    DOMAIN_SVC --> ENTITIES
    DOMAIN_SVC --> TYPES
```

## 12. Domain Services Detail

```mermaid
classDiagram
    class DocumentValidator {
        +validateFileType(fileName: string) ValidationResult
        +detectFileType(fileName: string) FileType
    }

    class ValidationResult {
        +bool valid
        +string error
    }

    class EnrichmentMatcher {
        +matchEnrichmentData(result: ExtractionResult, candidates: EnrichmentData[]) EnrichmentMatchResult
    }

    class EnrichmentMatchResult {
        +EnrichmentDataId matchedId
        +EnrichmentMatchStatus status
        +double matchScore
        +string[] matchedFields
    }

    DocumentValidator --> ValidationResult : returns
    EnrichmentMatcher --> EnrichmentMatchResult : returns
    EnrichmentMatcher --> ExtractionResult : takes
    EnrichmentMatcher --> EnrichmentData : takes
```
