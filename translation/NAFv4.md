# NAF v4 Architecture Description — Translation Hub Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Translation Hub Service — AI-powered software and document translation,
> custom translation memory management, and async job processing.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Translation Hub
├── C1.1  Language Discovery
│   ├── C1.1.1  Enumerate supported source/target languages
│   ├── C1.1.2  Enumerate translation domains
│   └── C1.1.3  Enumerate text types
│
├── C1.2  Software Translation
│   ├── C1.2.1  Translate UI texts (labels, tooltips, error messages)
│   ├── C1.2.2  Batch translation of multiple strings
│   └── C1.2.3  Quality score estimation per translation
│
├── C1.3  Document Translation
│   ├── C1.3.1  Synchronous document / text body translation
│   └── C1.3.2  Asynchronous document translation with job tracking
│
├── C1.4  Translation Project Management
│   ├── C1.4.1  Create / update / delete projects (file, Git, ABAP, API)
│   ├── C1.4.2  Assign source / target languages and provider per project
│   └── C1.4.3  Track project lifecycle (draft → active → completed)
│
├── C1.5  Company Translation Memory (MLTR)
│   ├── C1.5.1  Upload and manage custom glossary entries
│   ├── C1.5.2  Enforce mandatory terms in translations
│   └── C1.5.3  Filter entries by language pair and domain
│
├── C1.6  Translation Provider Selection
│   ├── C1.6.1  SAP MLTR (verified translations)
│   ├── C1.6.2  Neural Machine Translation (SAP MT engine)
│   ├── C1.6.3  Company MLTR (custom memory)
│   └── C1.6.4  LLM-based translation (generative AI hub)
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Multi-tenant isolation (X-Tenant-Id)
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Streamline and automate multilingual translation of SAP and BTP application texts and documents. |
| **Vision** | Provide a single platform for all translation needs — UI strings, documentation, and documents — with AI-powered quality and intelligent data reuse from custom glossaries. |
| **Scope** | Software text translation, document translation (sync/async), project management, glossary (company MLTR), language/domain/text-type discovery. |
| **Stakeholders** | Application Developers, Translators, Language Managers, Content Owners, SAP Administrators. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Translation Hub Service (SVC-TRANS)
├── SVC-TRANS-DISC    Discovery services (languages, domains, text types)
├── SVC-TRANS-SW      Software translation service
├── SVC-TRANS-DOC     Document translation service
├── SVC-TRANS-PROJ    Translation project management service
├── SVC-TRANS-GLOSS   Company glossary (MLTR) service
├── SVC-TRANS-JOB     Async translation job service
└── SVC-TRANS-HEALTH  Health check service
```

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-TRANS-DISC-LANG | Languages | `/api/v1/translation/languages` | GET |
| SVC-TRANS-DISC-DOM | Domains | `/api/v1/translation/domains` | GET |
| SVC-TRANS-DISC-TT | Text Types | `/api/v1/translation/text-types` | GET |
| SVC-TRANS-SW | Translate Texts | `/api/v1/translation/translate` | POST |
| SVC-TRANS-DOC-SYNC | Translate Document (sync) | `/api/v1/translation/documents/translate` | POST |
| SVC-TRANS-DOC-ASYNC | Translate Document (async) | `/api/v1/translation/documents/translate/async` | POST |
| SVC-TRANS-PROJ | Translation Projects | `/api/v1/translation/projects` | GET, POST, PUT, DELETE |
| SVC-TRANS-GLOSS | Glossary Entries | `/api/v1/translation/glossaries` | GET, POST, PUT, DELETE |
| SVC-TRANS-JOB | Async Jobs | `/api/v1/translation/jobs` | GET, POST |
| SVC-TRANS-JOB-CANCEL | Cancel Job | `/api/v1/translation/jobs/{id}/cancel` | POST |
| SVC-TRANS-HEALTH | Health | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
┌──────────────────────────────────────────────────────────────────┐
│  External Consumers                                              │
│                                                                  │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────────────┐  │
│  │ SAP UI5/     │  │ ABAP Backend  │  │ CI/CD Pipeline       │  │
│  │ Build Apps   │  │ (Translation  │  │ (Automated           │  │
│  │              │  │  Extensions)  │  │  file translation)   │  │
│  └──────┬───────┘  └──────┬────────┘  └──────────┬───────────┘  │
└─────────┼─────────────────┼──────────────────────┼──────────────┘
          │  HTTP/JSON       │  HTTP/JSON            │  HTTP/JSON
          ▼                 ▼                        ▼
┌─────────────────────────────────────────────────────────────────┐
│  Translation Hub Service  (port 8096)                           │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Presentation Layer (vibe.d HTTP Controllers)            │   │
│  │  LanguageCtrl │ DomainCtrl │ TextTypeCtrl                │   │
│  │  TranslationCtrl │ TranslationProjectCtrl                │   │
│  │  GlossaryCtrl │ DocumentTranslationCtrl                  │   │
│  │  TranslationJobCtrl │ HealthCtrl                         │   │
│  └─────────────────────────┬────────────────────────────────┘   │
│                            │                                    │
│  ┌─────────────────────────▼────────────────────────────────┐   │
│  │  Application Layer (Use Cases)                           │   │
│  │  ManageTranslationProjectsUseCase                        │   │
│  │  ManageGlossaryEntriesUseCase                            │   │
│  │  ManageTranslationJobsUseCase                            │   │
│  │  PerformTranslationUseCase                               │   │
│  └─────────────────────────┬────────────────────────────────┘   │
│                            │                                    │
│  ┌─────────────────────────▼────────────────────────────────┐   │
│  │  Domain Layer                                            │   │
│  │  TranslationProject │ GlossaryEntry │ TranslationJob     │   │
│  │  TranslationEngine (domain service)                      │   │
│  │  Repository Ports (interfaces)                           │   │
│  └─────────────────────────┬────────────────────────────────┘   │
│                            │                                    │
│  ┌─────────────────────────▼────────────────────────────────┐   │
│  │  Infrastructure Layer                                    │   │
│  │  MemoryTranslationProjectRepository                      │   │
│  │  MemoryGlossaryEntryRepository                           │   │
│  │  MemoryTranslationJobRepository                          │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Key Fields | Relationships |
|---|---|---|
| `TranslationProject` | id, tenantId, name, sourceLanguage, targetLanguages[], projectType, status, provider | independent root |
| `GlossaryEntry` | id, tenantId, sourceLanguage, targetLanguage, sourceTerm, targetTerm, domainName | independent root |
| `TranslationJob` | id, tenantId, jobType, sourceLanguage, targetLanguage, provider, status, inputContent, outputContent | independent root |

### Key Value Types

| Type | Base | Description |
|---|---|---|
| `TranslationProjectId` | string | Unique project identifier |
| `GlossaryEntryId` | string | Unique glossary entry identifier |
| `TranslationJobId` | string | Unique async job identifier |
| `TenantId` | string | Tenant scope |

### Enumerations

| Enum | Values |
|---|---|
| `ProjectType` | `file`, `git`, `abap`, `api` |
| `ProjectStatus` | `draft`, `active`, `inProgress`, `completed`, `archived` |
| `TranslationProvider` | `mltr`, `machineMt`, `companyMltr`, `llm` |
| `JobStatus` | `pending`, `processing`, `completed`, `failed`, `cancelled` |
| `JobType` | `software`, `document`, `text` |
| `QualityLevel` | `excellent`, `good`, `adequate`, `poor`, `unknown` |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

#### Container

```
Image:    uim-platform/cloud-translation:latest
Base:     ubuntu:24.04 (runtime)
Builder:  dlang2/ldc-ubuntu:1.40.1
Binary:   uim-translation-platform-service
Port:     8096
User:     appuser (non-root)
```

#### Build pipeline (multi-stage)

```
Stage 1 (builder)          Stage 2 (runtime)
┌───────────────────┐       ┌────────────────────┐
│ dlang2/ldc-ubuntu │       │ ubuntu:24.04        │
│                   │       │                    │
│ dub build         │──────▶│ appuser (non-root) │
│ → release binary  │ COPY  │ EXPOSE 8096        │
│                   │       │ HEALTHCHECK curl   │
└───────────────────┘       └────────────────────┘
```

#### Kubernetes resources

| Resource | Name | Notes |
|---|---|---|
| Deployment | `cloud-translation` | 1 replica, resource limits 64–256 Mi |
| Service | `cloud-translation` | ClusterIP, port 8096 |
| ConfigMap | `cloud-translation-config` | `TRANSLATION_HOST`, `TRANSLATION_PORT` |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

#### REST Contract — Key Request/Response Shapes

**POST `/api/v1/translation/translate`**

```
Request:
  sourceLanguage: string (BCP-47)
  targetLanguage: string (BCP-47)
  texts:          string[]
  domain:         string (optional)
  textType:       string (optional)
  provider:       "mltr" | "machineMt" | "companyMltr" | "llm"

Response 200:
  translations[]:
    sourceText:      string
    translatedText:  string
    qualityScore:    int (0-100)
    qualityLevel:    "excellent" | "good" | "adequate" | "poor"
    provider:        string
```

**POST `/api/v1/translation/jobs`**

```
Request:
  sourceLanguage: string
  targetLanguage: string
  content:        string
  contentType:    string (MIME type, default "text/plain")
  jobType:        "software" | "document" | "text"
  provider:       string

Response 202:
  jobId:   string
  status:  "pending"
  message: string
```

**GET `/api/v1/translation/jobs/{id}`**

```
Response 200:
  id:                string
  status:            "pending" | "processing" | "completed" | "failed" | "cancelled"
  qualityScore:      int (set when completed)
  translatedContent: string (set when completed)
  errorMessage:      string (set when failed)
  completedAt:       long (epoch ms, set when completed)
```

#### Error Envelope

All error responses follow:
```json
{ "error": "<message>", "statusCode": <int> }
```

#### Multi-Tenancy

All entities are scoped to `TenantId` derived from the `X-Tenant-Id` HTTP header.
Requests without this header receive tenant `""` (single-tenant mode).
