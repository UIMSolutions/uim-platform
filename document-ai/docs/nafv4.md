# NAF v4 Architecture Document

## Document AI Service — UIM Platform

**Version:** 1.0
**Date:** 2026-04-05
**Classification:** UNCLASSIFIED
**Status:** Baseline

---

## 1. Architecture Context (NAF v4 Grid Reference)

| NAF v4 View | Covered | Section |
|---|---|---|
| C1 — Capability Taxonomy | Yes | Section 2 |
| C2 — Enterprise Vision | Yes | Section 3 |
| S1 — Service Taxonomy | Yes | Section 4 |
| S3 — Service Interfaces | Yes | Section 5 |
| S4 — Service Functions | Yes | Section 6 |
| L2 — Logical Scenario | Yes | Section 7 |
| L4 — Logical Activities | Yes | Section 8 |
| L7 — Logical Data Model | Yes | Section 9 |
| P1 — Resource Types | Yes | Section 10 |
| P2 — Resource Structure | Yes | Section 11 |
| P4 — Resource Functions | Yes | Section 12 |
| Ar — Architecture Metadata | Yes | Section 13 |

---

## 2. C1 — Capability Taxonomy

### 2.1 Capability Overview

The Document AI Service provides intelligent document processing, data extraction, enrichment matching, and model training capabilities for the UIM Cloud Platform — analogous to the SAP Document Information Extraction Service on SAP BTP.

### 2.2 Capability Hierarchy

```
C-ROOT: Intelligent Document Processing
├── C-DA-01: Document Processing
│   ├── C-DA-01.1: Document Upload (PDF, PNG, JPEG, TIFF, XLSX, DOCX)
│   ├── C-DA-01.2: Automated Field Extraction (ML, Generative AI, Template, Hybrid)
│   ├── C-DA-01.3: Extraction Result Retrieval
│   ├── C-DA-01.4: Result Confirmation (Data Feedback Loop)
│   └── C-DA-01.5: Document Job Lifecycle Management
├── C-DA-02: Schema Management
│   ├── C-DA-02.1: Header Field Definition (typed, required, format)
│   ├── C-DA-02.2: Line Item Field Definition
│   ├── C-DA-02.3: Multi-Language Support
│   └── C-DA-02.4: Schema Lifecycle (draft → active → inactive)
├── C-DA-03: Template Management
│   ├── C-DA-03.1: Region-Based Field Mapping (page, coordinates)
│   ├── C-DA-03.2: Template-Schema Binding
│   └── C-DA-03.3: Sample Document Association
├── C-DA-04: Document Type Classification
│   ├── C-DA-04.1: Standard Categories (invoice, PO, receipt, contract, etc.)
│   ├── C-DA-04.2: Custom Document Types
│   ├── C-DA-04.3: Default Schema Assignment
│   └── C-DA-04.4: File Type Restriction per Document Type
├── C-DA-05: Enrichment Data
│   ├── C-DA-05.1: Master Data Upload
│   ├── C-DA-05.2: Enrichment Matching (scored, threshold-based)
│   └── C-DA-05.3: Match Status Classification (matched / ambiguous / unmatched)
├── C-DA-06: Model Training
│   ├── C-DA-06.1: Training Job Creation
│   ├── C-DA-06.2: Training Lifecycle (pending → running → completed/failed)
│   ├── C-DA-06.3: Accuracy and Metrics Tracking
│   └── C-DA-06.4: Model Versioning
├── C-DA-07: Client Administration
│   ├── C-DA-07.1: Client Provisioning
│   ├── C-DA-07.2: Document Quota Management
│   ├── C-DA-07.3: Data Feedback Configuration
│   └── C-DA-07.4: Usage Tracking (documentsProcessed)
├── C-DA-08: Capabilities Discovery
│   └── C-DA-08.1: Service Feature Enumeration
└── C-DA-09: Operational Monitoring
    └── C-DA-09.1: Health Check
```

---

## 3. C2 — Enterprise Vision

### 3.1 Purpose Statement

Provide an intelligent document processing service that automates the extraction of structured data from unstructured business documents, supports multiple extraction methods (ML, generative AI, template-based, hybrid), and enables continuous model improvement through data feedback and training — all accessible via a uniform REST API within the UIM Cloud Platform.

### 3.2 Strategic Goals

| ID | Goal | Priority |
|----|------|----------|
| SG-01 | Automate structured data extraction from business documents | High |
| SG-02 | Support multiple extraction methods (ML, generative AI, template, hybrid) | High |
| SG-03 | Enable data feedback loop for continuous extraction improvement | High |
| SG-04 | Provide enrichment matching against master data | Medium |
| SG-05 | Support custom model training per document type | Medium |
| SG-06 | Cover 13+ standard business document categories | Medium |
| SG-07 | Multi-tenant, multi-client data isolation | High |
| SG-08 | Cloud-native deployment (Docker, Podman, Kubernetes) | High |

### 3.3 Key Constraints

| ID | Constraint |
|----|-----------|
| CON-01 | All timestamps in UTC epoch milliseconds |
| CON-02 | Tenant identification via X-Tenant-Id header |
| CON-03 | Client identification via X-Client-Id header or request body |
| CON-04 | Supported file types: PDF, PNG, JPEG, TIFF, XLSX, DOCX |
| CON-05 | In-memory persistence for MVP (pluggable repository interfaces) |
| CON-06 | Port 8096 default, configurable via DOCAI_HOST / DOCAI_PORT |
| CON-07 | Enrichment matching thresholds: ≥0.8 matched, ≥0.4 ambiguous, <0.4 unmatched |

---

## 4. S1 — Service Taxonomy

### 4.1 Service Inventory

```
SVC-ROOT: Document AI Platform Service
├── SVC-DA-01: Document Processing Service
│   ├── Upload Document (with schema/template/docType binding)
│   ├── List Document Jobs
│   ├── Get Document Job
│   ├── Delete Document Job
│   ├── Confirm Extraction Results (data feedback)
│   └── Get Extraction Results
├── SVC-DA-02: Schema Management Service
│   ├── Create Schema (header fields, line items, languages)
│   ├── List Schemas
│   ├── Get Schema
│   ├── Update Schema
│   └── Delete Schema
├── SVC-DA-03: Template Management Service
│   ├── Create Template (regions with coordinates)
│   ├── List Templates
│   ├── Get Template
│   ├── Update Template
│   └── Delete Template
├── SVC-DA-04: Document Type Service
│   ├── Create Document Type
│   ├── List Document Types
│   ├── Get Document Type
│   ├── Update Document Type
│   └── Delete Document Type
├── SVC-DA-05: Enrichment Data Service
│   ├── Create Enrichment Data
│   ├── List Enrichment Data
│   ├── Get Enrichment Data
│   ├── Update Enrichment Data
│   └── Delete Enrichment Data
├── SVC-DA-06: Training Job Service
│   ├── Create Training Job
│   ├── List Training Jobs
│   ├── Get Training Job
│   ├── Patch Training Job Status
│   └── Delete Training Job
├── SVC-DA-07: Client Administration Service
│   ├── Create Client
│   ├── List Clients
│   ├── Get Client
│   ├── Patch Client
│   └── Delete Client
├── SVC-DA-08: Capabilities Service
│   └── Get Capabilities
└── SVC-DA-09: Health Service
    └── Health Check
```

---

## 5. S3 — Service Interfaces

### 5.1 REST API Interface Specification

**Base URL:** `/api/v1`
**Protocol:** HTTP/1.1
**Content-Type:** application/json
**Authentication:** X-Tenant-Id header (tenant identification)

#### 5.1.1 Document Processing Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Upload Document | POST | `/document/jobs` | Upload document for extraction |
| List Jobs | GET | `/document/jobs` | List document processing jobs |
| Get Job | GET | `/document/jobs/{id}` | Get document job detail |
| Delete Job | DELETE | `/document/jobs/{id}` | Delete a document job |
| Confirm Results | POST | `/document/jobs/{id}/confirm` | Confirm with corrections |
| Get Results | GET | `/document/jobs/{id}/results` | Get extraction results |

#### 5.1.2 Schema Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/schemas` | Create extraction schema |
| List | GET | `/schemas` | List schemas |
| Get | GET | `/schemas/{id}` | Get schema detail |
| Update | PUT | `/schemas/{id}` | Update schema |
| Delete | DELETE | `/schemas/{id}` | Delete schema |

#### 5.1.3 Template Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/templates` | Create template |
| List | GET | `/templates` | List templates |
| Get | GET | `/templates/{id}` | Get template detail |
| Update | PUT | `/templates/{id}` | Update template |
| Delete | DELETE | `/templates/{id}` | Delete template |

#### 5.1.4 Document Type Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/document-types` | Create document type |
| List | GET | `/document-types` | List document types |
| Get | GET | `/document-types/{id}` | Get document type |
| Update | PUT | `/document-types/{id}` | Update document type |
| Delete | DELETE | `/document-types/{id}` | Delete document type |

#### 5.1.5 Enrichment Data Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/enrichment-data` | Create enrichment data |
| List | GET | `/enrichment-data` | List enrichment data |
| Get | GET | `/enrichment-data/{id}` | Get enrichment data |
| Update | PUT | `/enrichment-data/{id}` | Update enrichment data |
| Delete | DELETE | `/enrichment-data/{id}` | Delete enrichment data |

#### 5.1.6 Training Job Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/training/jobs` | Create training job |
| List | GET | `/training/jobs` | List training jobs |
| Get | GET | `/training/jobs/{id}` | Get training job |
| Patch Status | PATCH | `/training/jobs/{id}` | Update job status |
| Delete | DELETE | `/training/jobs/{id}` | Delete training job |

#### 5.1.7 Client Administration Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/admin/clients` | Create client |
| List | GET | `/admin/clients` | List clients |
| Get | GET | `/admin/clients/{id}` | Get client |
| Patch | PATCH | `/admin/clients/{id}` | Update client |
| Delete | DELETE | `/admin/clients/{id}` | Delete client |

#### 5.1.8 Capabilities & Health Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Capabilities | GET | `/capabilities` | Service capabilities |
| Health | GET | `/health` | Health check |

### 5.2 Error Response Format

```json
{
  "error": {
    "message": "Human-readable error description",
    "code": 400
  }
}
```

### 5.3 Capabilities Response Format

```json
{
  "extraction": true,
  "classification": true,
  "enrichment": true,
  "templateMatching": true,
  "training": true,
  "dataFeedback": true,
  "multitenant": true,
  "supportedFileTypes": ["pdf", "png", "jpeg", "tiff", "xlsx", "docx"],
  "supportedLanguages": ["en", "de", "fr", "es", "it", "pt", "ja", "zh", "ko"],
  "supportedDocumentTypes": ["invoice", "purchase_order", "payment_advice", ...],
  "apiVersion": "v1"
}
```

---

## 6. S4 — Service Functions

### 6.1 Functional Decomposition

```
F-DA-01: Document Processing
  F-DA-01.1: Validate file type (DocumentValidator.validateFileType)
  F-DA-01.2: Detect file type from extension (DocumentValidator.detectFileType)
  F-DA-01.3: Generate unique document ID (UUID v4)
  F-DA-01.4: Create Document entity with status = pending
  F-DA-01.5: Execute extraction (status → processing → completed)
  F-DA-01.6: Build ExtractionResult (headerFields, lineItems, confidence scores)
  F-DA-01.7: Persist Document and ExtractionResult
  F-DA-01.8: Confirm results with corrected fields (data feedback)

F-DA-02: Schema Management
  F-DA-02.1: Define header fields (name, label, type, required, format)
  F-DA-02.2: Define line item fields
  F-DA-02.3: Manage schema lifecycle (draft → active → inactive)
  F-DA-02.4: Support multiple languages per schema

F-DA-03: Template Management
  F-DA-03.1: Define extraction regions (fieldName, page, x, y, width, height)
  F-DA-03.2: Bind templates to schemas and document types
  F-DA-03.3: Associate sample documents for validation

F-DA-04: Document Type Management
  F-DA-04.1: Map to standard categories (13 built-in + custom)
  F-DA-04.2: Assign default schema
  F-DA-04.3: Configure supported file types per doc type

F-DA-05: Enrichment Data Management
  F-DA-05.1: Store key-value enrichment fields
  F-DA-05.2: Match extraction results against enrichment candidates
  F-DA-05.3: Score matches (EnrichmentMatcher): >=0.8 matched, >=0.4 ambiguous, <0.4 unmatched
  F-DA-05.4: Return match result with score and matched field names

F-DA-06: Training Job Management
  F-DA-06.1: Create job linked to document type and schema
  F-DA-06.2: Count available training documents by type
  F-DA-06.3: Track accuracy and training metrics over time
  F-DA-06.4: Manage status transitions (pending → running → completed/failed/cancelled)

F-DA-07: Client Administration
  F-DA-07.1: Provision clients with document quota
  F-DA-07.2: Track documents processed against quota
  F-DA-07.3: Enable/disable data feedback per client
  F-DA-07.4: Label-based client organization
```

---

## 7. L2 — Logical Scenario

### 7.1 Scenario 1: Document Upload and Extraction

```
1. Client sends POST /api/v1/document/jobs with upload metadata
2. DocumentController parses JSON, extracts tenant/client IDs
3. ProcessDocumentsUseCase validates file type via DocumentValidator
4. Document entity created with status = pending
5. Document persisted via DocumentRepository
6. Extraction pipeline invoked (status → processing)
7. ExtractionResult built with headerFields, lineItems, confidence scores
8. ExtractionResult persisted via ExtractionResultRepository
9. Document status → completed, processedAt set
10. 201 Created returned with document ID
```

### 7.2 Scenario 2: Result Confirmation (Data Feedback)

```
1. Client sends POST /api/v1/document/jobs/{id}/confirm with corrections
2. Document retrieved, status verified = completed
3. Corrected fields applied to extraction result
4. Document status → confirmed
5. Feedback data available for future model training
6. 200 OK returned
```

### 7.3 Scenario 3: Enrichment Matching

```
1. After extraction, system retrieves EnrichmentData candidates for the document type
2. EnrichmentMatcher compares each candidate's fields against extracted header fields
3. Match score calculated: matchedFields / totalFields per candidate
4. Highest-scoring candidate selected
5. Threshold applied: ≥0.8 → matched, ≥0.4 → ambiguous, <0.4 → unmatched
6. EnrichmentMatchResult returned with matched ID, score, and field names
```

### 7.4 Scenario 4: Model Training Lifecycle

```
1. Client creates training job via POST /api/v1/training/jobs
2. Job created with status = pending
3. Client starts training via PATCH {targetStatus: "running"}
4. System counts available documents by type/schema
5. Training progresses with metrics recorded
6. On completion: accuracy set, status → completed
7. On failure: statusMessage set, status → failed
```

### 7.5 Scenario 5: Capabilities Discovery

```
1. Client sends GET /api/v1/capabilities
2. GetCapabilitiesUseCase returns CapabilitiesResponse
3. Response includes supported features, file types, languages, document types
4. Client configures its behavior based on available capabilities
```

---

## 8. L4 — Logical Activities

### 8.1 Document Upload Activity Flow

```
[Start]
  → Receive HTTP POST /document/jobs
  → Parse JSON Body
  → Extract X-Tenant-Id, X-Client-Id
  → Validate File Type (DocumentValidator)
    ── invalid → Return 400 Error → [End]
    ── valid →
  → Detect FileType enum from extension
  → Generate UUID
  → Build Document entity (status = pending)
  → Set uploadedAt = now()
  → Persist Document
  → Set status = processing
  → Run Extraction (ML / AI / Template / Hybrid)
  → Build ExtractionResult entity
  → Compute overallConfidence
  → Persist ExtractionResult
  → Set Document status = completed, processedAt = now()
  → Update Document
  → Return 201 Created
  → [End]
```

### 8.2 Document Processing State Machine

```
[*] → pending (upload received)
pending → processing (extraction starts)
processing → completed (extraction successful)
processing → failed (extraction error)
completed → confirmed (user confirms results)
confirmed → [*]
failed → [*]
```

### 8.3 Training Job State Machine

```
[*] → pending (job created)
pending → running (training started)
pending → cancelled (user cancels)
running → completed (training successful, accuracy recorded)
running → failed (training error, statusMessage set)
running → cancelled (user cancels)
completed → [*]
failed → [*]
cancelled → [*]
```

### 8.4 Schema Lifecycle

```
[*] → draft (schema created)
draft → active (schema activated)
active → inactive (schema deactivated)
inactive → active (schema reactivated)
```

### 8.5 Enrichment Matching Activity

```
[Start]
  → Retrieve ExtractionResult for document
  → Retrieve EnrichmentData candidates for document type
  → For each candidate:
      → Compare fields by key (case-insensitive value match)
      → Count matched fields
      → Calculate score = matchedFields / totalFields
  → Select candidate with highest score
  → Apply threshold:
      score ≥ 0.8 → status = matched
      score ≥ 0.4 → status = ambiguous
      score < 0.4 → status = unmatched
  → Return EnrichmentMatchResult
  → [End]
```

---

## 9. L7 — Logical Data Model

### 9.1 Entity Relationship Model

```
┌───────────────────┐        ┌───────────────────┐
│      Client       │1    *  │     Document      │
├───────────────────┤────────├───────────────────┤
│ id: ClientId      │        │ id: DocumentId    │
│ tenantId          │        │ tenantId          │
│ name              │        │ clientId          │
│ documentQuota     │        │ fileName          │
│ documentsProcessed│        │ fileType          │
│ dataFeedbackEnabled       │ status            │
│ labels: ClientLabel[]     │ language          │
└───────────────────┘        │ schemaId          │
                             │ templateId        │
                             │ documentTypeId    │
                             │ extractionMethod  │
                             │ labels: DocLabel[]│
                             └────────┬──────────┘
                                 1    │
                                      │ 0..1
                             ┌────────┴──────────┐
                             │ ExtractionResult   │
                             ├───────────────────┤
                             │ id                │
                             │ documentId        │
                             │ schemaId          │
                             │ method            │
                             │ headerFields:     │
                             │   ExtractedField[]│
                             │ lineItems:        │
                             │   LineItem[]      │
                             │ overallConfidence │
                             └───────────────────┘

┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│   DocumentType    │    │      Schema       │    │     Template      │
├───────────────────┤    ├───────────────────┤    ├───────────────────┤
│ id                │    │ id                │    │ id                │
│ name              │    │ documentTypeId    │    │ schemaId          │
│ category          │    │ name              │    │ documentTypeId    │
│ defaultSchemaId   │    │ status            │    │ name              │
│ supportedFileTypes│    │ headerFields:     │    │ status            │
└───┬──────┬────────┘    │   SchemaField[]   │    │ regions:          │
    │      │             │ lineItemFields:   │    │   TemplateRegion[]│
    │      │             │   LineItemField[] │    └───────────────────┘
    │      │             │ supportedLangs[]  │
    │      │             └───────────────────┘
    │      │
    │      │    ┌───────────────────┐    ┌───────────────────┐
    │      └───→│  EnrichmentData   │    │   TrainingJob     │
    │           ├───────────────────┤    ├───────────────────┤
    └──────────→│ id                │    │ id                │
                │ documentTypeId    │    │ documentTypeId    │
                │ name              │    │ schemaId          │
                │ subtype           │    │ name              │
                │ fields:           │    │ status            │
                │   EnrichmentField[]   │ accuracy          │
                └───────────────────┘    │ metrics:          │
                                         │   TrainingMetric[]│
                                         └───────────────────┘
```

### 9.2 Data Dictionary — Key Entities

| Entity | Attribute | Type | Description |
|--------|-----------|------|-------------|
| Document | fileType | FileType enum | pdf, png, jpeg, tiff, xlsx, docx |
| Document | status | DocumentStatus enum | pending, processing, completed, failed, confirmed |
| Document | extractionMethod | ExtractionMethod enum | ml_model, generative_ai, template_based, hybrid |
| Document | category | DocumentCategory enum | 13 standard categories + custom |
| ExtractionResult | overallConfidence | double | 0.0–1.0, aggregate extraction confidence |
| ExtractionResult | headerFields | ExtractedField[] | Name, value, type, confidence, page, coordinates |
| ExtractionResult | lineItems | LineItem[] | Row-indexed arrays of extracted fields |
| Schema | headerFields | SchemaField[] | Name, label, type, required, description, default, format |
| Schema | lineItemFields | LineItemField[] | Name, label, type, required, description |
| Schema | status | SchemaStatus enum | active, inactive, draft |
| Template | regions | TemplateRegion[] | fieldName, page, x, y, width, height |
| EnrichmentData | fields | EnrichmentField[] | Key-value pairs for matching |
| TrainingJob | status | TrainingJobStatus enum | pending, running, completed, failed, cancelled |
| TrainingJob | accuracy | double | 0.0–1.0, model accuracy after training |
| TrainingJob | metrics | TrainingMetric[] | Name, value, timestamp tuples |
| Client | documentQuota | int | Maximum documents allowed |
| Client | documentsProcessed | int | Current usage count |

---

## 10. P1 — Resource Types

### 10.1 Software Resources

| Resource | Type | Version | Purpose |
|----------|------|---------|---------|
| D Language (LDC) | Compiler/Runtime | 1.40.1 | Primary language |
| vibe-d | HTTP Framework | 0.10.x | HTTP server, routing, JSON |
| uim-framework | Library | 26.4.1 | Platform base classes |
| uim-platform:service | Library | internal | SAPController, UIMUseCase base |

### 10.2 Infrastructure Resources

| Resource | Type | Purpose |
|----------|------|---------|
| Ubuntu 24.04 | OS | Runtime container base |
| Docker / Podman | Container | Build and run |
| Kubernetes | Orchestrator | Production deployment |

---

## 11. P2 — Resource Structure

### 11.1 Source Code Structure

```
document-ai/
├── dub.sdl                                  # Build configuration
├── Dockerfile                               # Docker multi-stage build
├── Containerfile                            # Podman multi-stage build
├── README.md                                # Usage documentation
├── k8s/                                     # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── docs/                                    # Architecture documentation
│   ├── uml.md                               # UML diagrams (Mermaid)
│   └── nafv4.md                             # This document
└── source/
    ├── app.d                                # Entry point
    └── uim/platform/document_ai/
        ├── package.d                        # Root re-exports
        ├── domain/                          # CORE (no external deps)
        │   ├── types.d                      # 9 ID aliases, 10 enums
        │   ├── entities/                    # 8 entities with sub-structs
        │   │   ├── document.d               # Document + DocumentLabel
        │   │   ├── schema.d                 # Schema + SchemaField + LineItemField
        │   │   ├── template_.d              # Template + TemplateRegion
        │   │   ├── document_type.d          # DocumentType
        │   │   ├── extraction_result.d      # ExtractionResult + ExtractedField + LineItem
        │   │   ├── enrichment_data.d        # EnrichmentData + EnrichmentField
        │   │   ├── training_job.d           # TrainingJob + TrainingMetric
        │   │   └── client.d                 # Client + ClientLabel
        │   ├── ports/                       # 8 repository interfaces
        │   └── services/                    # 2 domain services
        │       ├── document_validator.d     # File type validation + detection
        │       └── enrichment_matcher.d     # Scored enrichment matching
        ├── application/                     # USE CASES
        │   ├── dto.d                        # Request/Result DTOs + CapabilitiesResponse
        │   └── use_cases/                   # 8 use case classes
        │       ├── process_documents.d      # Upload, list, get, delete, confirm, results
        │       ├── manage.schemas.d
        │       ├── manage.templates.d
        │       ├── manage.document_types.d
        │       ├── manage.enrichment_data.d
        │       ├── manage.training_jobs.d
        │       ├── manage.clients.d
        │       └── get_capabilities.d       # Static capabilities response
        ├── presentation/                    # DRIVING ADAPTERS
        │   └── http/
        │       ├── json_utils.d             # JSON extraction helpers
        │       └── controllers/             # 9 controllers
        │           ├── document.d
        │           ├── schema.d
        │           ├── template_.d
        │           ├── document_type.d
        │           ├── enrichment_data.d
        │           ├── training_job.d
        │           ├── client.d
        │           ├── capabilities.d
        │           └── health.d
        └── infrastructure/                  # DRIVEN ADAPTERS
            ├── config.d                     # AppConfig + env loading
            ├── container.d                  # DI wiring (8 repos → 8 use cases → 9 controllers)
            └── persistence/memory/          # 8 in-memory repository impls
```

### 11.2 Package Dependency Graph

```
app.d
 └── infrastructure/container.d (buildContainer)
      ├── infrastructure/persistence/memory/*   (8 MemoryXxxRepository)
      │    └── domain/ports/*                   (8 interfaces)
      │         └── domain/entities/*           (8 entity structs)
      │              └── domain/types           (aliases + 10 enums)
      ├── application/use_cases/*               (8 use case classes)
      │    ├── domain/ports/*
      │    ├── domain/services/*                (DocumentValidator, EnrichmentMatcher)
      │    └── application/dto                  (request/result DTOs)
      └── presentation/http/controllers/*       (9 controllers)
           ├── application/use_cases/*
           ├── application/dto
           └── presentation/http/json_utils
```

### 11.3 Key DI Wiring

| Use Case | Injected Repositories |
|----------|-----------------------|
| ProcessDocumentsUseCase | DocumentRepository, ExtractionResultRepository |
| ManageTrainingJobsUseCase | TrainingJobRepository, DocumentRepository |
| ManageSchemasUseCase | SchemaRepository |
| ManageTemplatesUseCase | TemplateRepository |
| ManageDocumentTypesUseCase | DocumentTypeRepository |
| ManageEnrichmentDataUseCase | EnrichmentDataRepository |
| ManageClientsUseCase | ClientRepository |
| GetCapabilitiesUseCase | (none — static response) |

---

## 12. P4 — Resource Functions

### 12.1 Container Build Process

```
Stage 1: Builder (dlang2/ldc-ubuntu:1.40.1)
  1. Copy dub.sdl, dub.selections.json
  2. Copy source/
  3. dub build --build=release --config=defaultRun
  Output: build/uim-document-ai-platform-service

Stage 2: Runtime (ubuntu:24.04)
  1. Install ca-certificates, curl
  2. Create non-root appuser
  3. Copy binary from builder
  4. Expose port 8096
  5. Configure health check (GET /api/v1/health)
  6. Run as appuser
```

### 12.2 Startup Sequence

```
1. loadConfig()          — Read DOCAI_HOST, DOCAI_PORT from environment
2. buildContainer()      — Wire: 8 repos → 8 use cases → 9 controllers
3. new URLRouter()       — Initialize HTTP router
4. registerRoutes()      — Register all 9 controller route sets
5. listenHTTP()          — Bind to host:port (default 0.0.0.0:8096)
6. runApplication()      — Start vibe-d event loop
```

### 12.3 Kubernetes Deployment Parameters

| Parameter | Value |
|-----------|-------|
| Replicas | 1 |
| Container Port | 8096/TCP |
| Service Type | ClusterIP |
| Memory Request | 64Mi |
| Memory Limit | 256Mi |
| CPU Request | 100m |
| CPU Limit | 500m |
| Liveness Probe | GET /api/v1/health (initialDelay 5s, period 30s) |
| Readiness Probe | GET /api/v1/health (initialDelay 3s, period 10s) |
| Security | runAsNonRoot, readOnlyRootFilesystem, no privilege escalation |
| Config Source | ConfigMap: cloud-document-ai-config |

---

## 13. Ar — Architecture Metadata

| Field | Value |
|-------|-------|
| Architecture Name | Document AI Service |
| Version | 1.0 |
| Framework | NAF v4 |
| Status | Baseline |
| Author | UIM Platform Team |
| Date Created | 2026-04-05 |
| Classification | UNCLASSIFIED |
| Platform | UIM Cloud Platform |
| Repository | UIMSolutions/uim-platform |
| Subpackage | document-ai |
| Language | D (dlang) |
| HTTP Framework | vibe-d 0.10.x |
| Base Framework | uim-framework 26.4.1 |
| Architecture Style | Hexagonal (Ports and Adapters) + Clean Architecture |
| Deployment | Docker / Podman / Kubernetes |
| Default Port | 8096 |
| Total Entities | 8 (with 8 sub-structs) |
| Total Enums | 10 |
| Total Controllers | 9 (7 domain + capabilities + health) |
| Total Use Cases | 8 |
| Total Repository Ports | 8 |
| Domain Services | 2 (DocumentValidator, EnrichmentMatcher) |
