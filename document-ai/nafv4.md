# NAF v4 Architecture Description — UIM Document AI

> NATO Architecture Framework v4 description of the UIM Document AI service 2.0: extraction of header fields and
> line items from business documents with review, confirmation, enrichment matching and model training (SAP Document
> Information Extraction style), with a D/vibe.d backend, an SAP Fiori 3 / OpenUI5 frontend, built-in JWT login or
> SAP XSUAA.

---

## 1. Grid mapping

| NAF v4 viewpoint | Subject | Section |
|---|---|---|
| C1 Capability Taxonomy · C2 Enterprise Vision | what the service is able to do and why | §2 |
| C4 Standard Processes / L4 Logical Activities | upload, extraction, review, confirmation, training, login | §3 |
| S1 Service Taxonomy · S4 Service Functions | OData, REST, CLI, GUI, auth | §4 |
| L2 Logical Scenario · L3 Node Interactions | operational nodes and information flows | §5 |
| L7 Logical Data Model | entities and relations | §6 |
| P1 Resource Types · P2 Resource Structure | software components and layers | §7 |
| P4 Resource Functions / P5 Resource Connectivity | deployment | §8 |
| A8 Standards Profile | standards and technologies | §9 |
| Cr Security / constraints | authentication, authorization, data protection | §10 |
| Ar Architecture decisions | decisions and rationale | §11 |

---

## 2. Capability viewpoint

### C1 — Capability taxonomy

```text
Document AI
├── C1.1 Document intake
│   ├── upload registration (file type detection, language, labels)
│   ├── classification by document type (category, accepted file types, default schema)
│   └── client separation and document quotas
├── C1.2 Information extraction
│   ├── header fields and line items per schema
│   ├── extraction methods: ML model, generative AI, template based, hybrid
│   ├── confidence per value, review threshold, missing required values
│   └── pluggable engine (simulation / external HTTP service), background processing
├── C1.3 Human review
│   ├── review queue (documents that need review)
│   ├── correction of values (type checked, original kept)
│   └── confirmation / rejection (final states)
├── C1.4 Enrichment
│   ├── master data records (supplier, customer, employee, business entity, material)
│   └── matching of extracted header values (matched / ambiguous / unmatched, score)
├── C1.5 Extraction design
│   ├── schemas with versioned, frozen-on-activation fields
│   └── templates per sender layout
├── C1.6 Model training
│   ├── training jobs on confirmed documents (data feedback per client)
│   └── accuracy from the correction rate, model versions
├── C1.7 Monitoring
│   └── KPIs (pending, to review, confirmed, failed, confidence, correction rate, accuracy), health, events
└── C1.8 Access control
    ├── built-in login (JWT HS256, PBKDF2, lockout) or XSUAA (RS256)
    └── scopes Read / Process / Manage / Admin
```

### C2 — Enterprise vision

| Goal | Measure in the service |
|---|---|
| Less manual data entry | documents are extracted automatically; people only review values below the confidence threshold |
| Trustworthy data | required values must be present to confirm; corrections are recorded with the original value and the person |
| Continuous improvement | confirmed documents train the model; the correction rate and the model accuracy are visible KPIs |
| Clean master data links | header values are matched with supplier / customer records |
| Separation of organizational units | clients with quotas and a data feedback switch, tenants via JWT `zid` |
| Runs anywhere | same binary on a workstation, in a container, on Kubernetes and on SAP BTP |

---

## 3. Processes (C4 / L4)

| # | Process | Actor | Steps | Rules |
|---|---|---|---|---|
| P1 | Design extraction | Extraction expert (Manage) | create schema → add header and line item fields → activate → assign as default schema of a document type → optional template | fields frozen when active; changes by copy (version + 1) |
| P2 | Upload | Clerk (Process), API client | register file metadata, type, client, labels | file type accepted, active schema, language supported, client quota |
| P3 | Extract | worker / clerk | engine returns values → values stored → summary and enrichment match | replaces previous values; failures keep the reason |
| P4 | Review and correct | Clerk | open "needs review" documents → correct values | only while `done`; values type checked; match recomputed |
| P5 | Confirm / reject | Clerk | confirm or reject with reason | confirm needs required values; final |
| P6 | Train | Extraction expert | create job → start → worker completes after training time | ≥ minTrainingDocuments confirmed, data feedback allowed, one running job per schema |
| P7 | Administer access | Administrator (Admin) | create users with scopes, lock/unlock, reset passwords | last administrator protected |

---

## 4. Service viewpoint (S1 / S4)

| Service | Interface | Functions |
|---|---|---|
| S1 Document AI OData service | OData v4 `/odata/v4/document-ai` (`$metadata` with UI.LineItem / HeaderInfo / SelectionFields annotations, `$batch`) | CRUD of 10 entity sets, Statistics singleton, 13 unbound actions |
| S2 Document AI REST API | JSON `/api/v1/document-ai` | same resources and operations, review queue, capabilities, meta |
| S3 Authentication service | `/auth/config`, `/auth/login`, `/auth/me`, `/auth/password`, `/auth/logout` | built-in login, token issuing, own password |
| S4 Health | `/health`, `/api/v1/health` | liveness/readiness, worker metrics |
| S5 Fiori app | `/app` (local / container) or approuter (BTP) | KPI header, documents, review with corrections, schemas and fields, templates, master data, training, users |
| S6 CLI | `uim-document-ai-cli` | generic entity commands + upload, extract, values, correct, confirm, review, schemas, training, token, passwd |
| S7 Desktop GUI | `uim-document-ai-gui` (GtkD) | model driven entity browser with actions |
| S8 Extraction engine (consumed) | HTTP POST to `extractionUrl` | values with confidence per document |

All driving adapters call one `ODataEngine` bound to the driving ports, so validation, authorization (scopes per
entity set and action) and error mapping are identical everywhere.

---

## 5. Logical / operational viewpoint (L2 / L3)

```text
 ┌────────────┐  OData/REST + JWT   ┌──────────────────────────────────────────────┐  HTTP (http mode)  ┌───────────────────┐
 │ Clerk /    │ ──────────────────▶ │ Document AI node                             │ ─────────────────▶ │ Extraction engine │
 │ Expert /   │ ◀────────────────── │  presentation → application → domain         │ ◀───────────────── │ (OCR / ML / LLM)  │
 │ Admin      │   rows, KPIs         │  persistence (JSON snapshot) · worker · auth │   values+confidence └───────────────────┘
 └────────────┘                      └──────────────────────────────────────────────┘
       ▲  login (xsuaa mode)                    │ events (structured log lines)
 ┌────────────┐                                 ▼
 │ Approuter  │ ── forwards token ──▶   log / audit collector
 │ + XSUAA    │
 └────────────┘
```

| Information flow | From → to | Content | Protection |
|---|---|---|---|
| IF1 document registration | user / client system → service | file metadata, labels | bearer token, scope Process |
| IF2 extraction request | service → extraction engine | document metadata, schema fields, template | HTTPS, Authorization from `DOCAI_EXTRACTION_AUTHORIZATION` |
| IF3 extraction result | engine → service | values, confidence, positions | validated, type checked |
| IF4 review data | service → Fiori | values, confidence levels, match | token, scope Read |
| IF5 corrections / confirmation | Fiori → service | corrected values, decisions | token, scope Process, audited (`correctedBy`, `confirmedBy`) |
| IF6 events | service → log | event type, ids, states (no values, no secrets) | structured JSON log |

---

## 6. Logical data model (L7)

| Entity | Key attributes | Relations |
|---|---|---|
| Client | name (unique), documentQuota, dataFeedbackEnabled | documents, schemas, types, templates, enrichment, training (optional owner) |
| DocumentType | name (unique per client), category, defaultSchemaId, supportedFileTypes | → Schema (default) |
| Schema | name, category, status, version, supportedLanguages, basedOnId | 1 : n SchemaField |
| SchemaField | schemaId, fieldScope, sequence, name (unique per schema + scope), valueType, required, default | → Schema |
| DocumentTemplate | schemaId (immutable), senderName, status, sampleDocumentIds | → Schema |
| AiDocument | fileName, fileType, size, pages, language, status, method, labels, confidence summary, match | → Schema, DocumentType, Template, Client, EnrichmentData; 1 : n ExtractedField |
| ExtractedField | documentId, fieldScope, rowIndex, name, valueType, value, originalValue, confidence, page, corrected | → AiDocument, SchemaField |
| EnrichmentData | subtype, externalId, name, attributes (key=value) | optional → Client, DocumentType |
| TrainingJob | schemaId, status, documentCount, fieldCount, accuracy, modelVersion | → Schema; uses confirmed AiDocuments |
| UserAccount | id (user name), passwordHash, scopes, locked, failedLogins | — |

All entities are tenant scoped and audited (`createdAt/By`, `updatedAt/By`). Records are flat JSON documents in the
collections `dai.<entity>`; the mapping is derived from the entity declarations at compile time.

---

## 7. Resource viewpoint (P1 / P2)

| Resource | Type | Layer |
|---|---|---|
| `uim.platform.document_ai.domain` | D package | entities, value types, enumerations, exceptions, pure domain services |
| `…ports` | D interfaces | driving (use cases, statistics) and driven (repositories, unit of work, gateways, events) |
| `…application` | D classes | use cases (master data, schemas, documents, review, training, access), statistics, capabilities, demo data, DTOs |
| `…persistence` | D classes | generic document repository, record mapper, batching memory / file document stores |
| `…infrastructure` | D classes | configuration loader, security (HS256 issuer, PBKDF2, XSUAA RS256), logging, metrics, extraction engines, worker, container |
| `…presentation` | D classes | EDM model + engine bindings, REST / auth / health controllers, static Fiori, CLI, GtkD GUI |
| `uim-platform:service` | shared D library | OData v4 engine and controller, document stores, token verifiers, CLI and GUI frameworks |
| Fiori app `uim.documentai` | OpenUI5 1.120 | Component (login flow), Main / DocumentDetail / SchemaDetail views, dialogs, i18n en/de |
| Approuter | Node.js `@sap/approuter` | XSUAA login, routing, CSRF |

---

## 8. Physical deployment (P4 / P5)

### SAP BTP (Cloud Foundry) — `mta.yaml`

| Module / resource | Type | Notes |
|---|---|---|
| `document-ai-srv` | binary_buildpack | D server built with ldc2, health check `/health`, file snapshot (single instance) |
| `document-ai-approuter` | approuter.nodejs | serves the Fiori app, forwards the XSUAA token to `document-ai-srv` |
| `document-ai-xsuaa` | xsuaa / application | scopes and role collections from `approuter/xs-security.json` |
| `document-ai-config` | user-provided service | runtime overrides (e.g. `extractionMode`, `extractionUrl`, `minConfidence`) |

### Kubernetes — `k8s/`

| Object | Notes |
|---|---|
| ConfigMap `document-ai-config` | `DOCAI_*` settings (jwt mode, worker, thresholds, extraction mode) |
| Secret `document-ai-secret` | `DOCAI_JWT_SECRET`, `DOCAI_ADMIN_PASSWORD`, optional `DOCAI_EXTRACTION_AUTHORIZATION` (from `secret.example.yaml`) |
| Deployment `document-ai` | 1 replica (file snapshot), non-root, read-only root file system, probes on `/health` |
| PVC `document-ai-data` | `/data/document-ai.json` |
| Service `document-ai` | port 80 → 8096 |

Containers: `backend/Dockerfile` / `Containerfile` (multi-stage ldc build from the repository root, Ubuntu 24.04
runtime, Fiori app under `/app`).

---

## 9. Standards profile (A8)

| Area | Standard / technology |
|---|---|
| Data access | OData v4.0 (JSON format, `$metadata` CSDL XML, `$batch`), OASIS vocabularies Core, Common, UI |
| API | REST / JSON, HTTP status semantics (400, 401, 403, 404, 405, 409, 422) |
| Identity | JWT (RFC 7519) HS256 / RS256, OAuth 2.0 bearer tokens (RFC 6750), XSUAA claim layout (`zid`, `scope`, `user_name`) |
| Passwords | PBKDF2-HMAC-SHA256 (RFC 8018), 128-bit salt |
| Values | ISO 8601 dates, ISO 4217 currency codes, ISO 639-1 languages, IANA MIME types |
| UI | SAP Fiori 3 design (sap_fiori_3), OpenUI5 1.120, i18n properties (en, de) |
| Deployment | MTA 3.3 (SAP BTP), OCI images, Kubernetes |
| Languages | D (dmd 2.112 / ldc 1.40), vibe.d 0.10.5, JavaScript ES5 (UI5 modules) |

---

## 10. Security and constraints

| Topic | Measure |
|---|---|
| Authentication | `jwt` (built-in login), `xsuaa` (approuter, RS256) or `open` (development only); `/health` and `/auth/config` public |
| Authorization | scopes per entity set (read / write) and per action enforced in the `ODataEngine` for OData, REST, CLI and GUI alike |
| Credentials | PBKDF2 hashes only, rehash on login when rounds increase, uniform answers for unknown users and wrong passwords, lockout after `maxFailedLogins` |
| Tokens | HS256 secret ≥ 32 characters (random per process if not configured, with a warning), TTL 60 s … 7 days, tampered tokens rejected |
| Secrets | from environment / Kubernetes secret / XSUAA binding; masked in `config` output; never stored in records or events |
| Data protection | file content is not stored; events carry ids and states, not extracted values; clients can exclude their documents from training |
| Input validation | ids, file names (no paths), labels, value types, enumerations, sizes and limits checked in the domain |
| Constraints | file storage is a single-node snapshot (one replica / instance); the simulated engine is no OCR — production needs `extractionMode: http` |

---

## 11. Architecture decisions

| # | Decision | Rationale |
|---|---|---|
| AD1 | Hexagonal layering under `backend/source/uim/platform/document_ai` (domain, ports, application, persistence, infrastructure, presentation) | business rules testable without HTTP or storage; adapters replaceable |
| AD2 | One EDM model and `ODataEngine` drive OData, REST, CLI and GUI | one place for validation, scopes and error mapping; Fiori metadata for free |
| AD3 | Extracted values as their own entity set instead of nested JSON | OData filtering, per-value correction and audit, Fiori tables without client-side parsing |
| AD4 | Extraction behind the `IExtractionEngine` port with simulated and HTTP adapters | runs and tests without an AI backend; production engines plug in without code changes |
| AD5 | Background worker for pending documents and training, inline mode with `workerIntervalSeconds = 0` | uploads answer fast; CLI / GUI / tests process synchronously |
| AD6 | Built-in JWT login with XSUAA compatible claims, XSUAA binding wins | same authorization code on BTP and off BTP; Fiori login dialog when no approuter |
| AD7 | Batching unit of work over the JSON snapshot store | an extraction with dozens of values costs one file write; server, CLI and GUI share the file |
| AD8 | Schema fields frozen on activation, copies as new versions | extracted values and trained models stay consistent with their schema |
| AD9 | Accuracy derived from corrections of confirmed documents | a measurable, explainable model quality without a separate evaluation set |
| AD10 | Replaced the first-generation API (`/api/v1/AiDocument/jobs`, `X-Client-Id`) | consistent resources, OData parity, client as a regular reference |
