# UIM Document AI

Document AI service of the UIM Platform, modelled on SAP Document Information Extraction: business documents
(invoices, purchase orders, receipts, …) are uploaded, their **header fields and line items are extracted with
confidence scores**, people **review and correct** the values, **confirm** the document, and the confirmed
documents **train** the extraction model. Extracted values are **matched with enrichment data** (supplier,
customer and employee master data).

| Part | Technology | Folder |
|---|---|---|
| Backend | D, uim-framework 26.11, vibe.d 0.10.5, clean / hexagonal architecture | [backend/](backend/) |
| Frontend | SAP Fiori 3 / OpenUI5 1.120 (OData V4) | [frontend/](frontend/) |
| Approuter | `@sap/approuter` with XSUAA | [approuter/](approuter/) |
| Deployment | MTA (SAP BTP Cloud Foundry), Docker/Podman, Kubernetes | [mta.yaml](mta.yaml), [k8s/](k8s/) |
| Architecture | UML (Mermaid) and NAF v4 descriptions | [uml.md](uml.md), [nafv4.md](nafv4.md) |

One EDM model drives every adapter: the OData v4 endpoint for Fiori (incl. `$metadata` with UI annotations), the
REST API, the command line and the GtkD desktop GUI. All of them validate, authorize and answer alike.

## Concepts

| Resource | Purpose |
|---|---|
| **Document** | An uploaded file (metadata: name, type, size, pages, language, labels) and its processing state. The file content stays with the caller. |
| **Extracted value** | One value of a document: a header field (row 0) or a cell of a line item (row 1..n), with confidence, page and position. Corrections keep the original value. |
| **Schema** | The header fields and line item columns to extract (name, label, type, required, default, description = prompt for generative AI). |
| **Template** | The layout of one sender for a schema; template based extraction is more confident. |
| **Document type** | Category, default schema and accepted file types (e.g. "Supplier Invoice": pdf, png, jpeg, tiff). |
| **Enrichment record** | Master data (`senderName=ACME Corp`, `senderCity=Berlin`) that extracted header values are matched with. |
| **Client** | A sub-tenant with a document quota and a data-feedback switch (may its confirmed documents train models?). |
| **Training job** | Trains the model of a schema with the confirmed documents; the accuracy is the share of values that needed no correction. |

### Lifecycles

```text
Document        pending ──extract──▶ done ──confirm──▶ confirmed
                   │                  │  └──reject───▶ rejected
                   └──────────────▶ failed ──extract / reject
                (done → pending when schema, template, method or language change)
Schema          draft ──activate──▶ active ──deprecate──▶ deprecated        (copy → new draft, version + 1)
Template        draft ──activate──▶ active ◀──▶ inactive
Training job    pending ──start──▶ running ──(worker, trainingSeconds)──▶ completed | failed
                pending / running ──cancel──▶ cancelled (startable again)
```

### Business rules (enforced by the use cases)

- The file type is detected from the name (`pdf, png, jpg/jpeg, tif/tiff, xlsx, docx`) and must be accepted by the document type.
- A document needs an **active** schema (explicit or the default of its document type) that supports its language; a template must be active and belong to that schema.
- The **client quota** limits the number of documents per client (0 = unlimited).
- The extraction replaces all values of a document; header fields always get a value row (empty if not found), defaults fill gaps with reduced confidence, values that do not match their type are marked unsure.
- Values below `minConfidence` (default 0.7) and missing required values make a document **need review**.
- Values can only be **corrected** while the document is `done`; numbers use `.`, dates `YYYY-MM-DD`, currencies ISO 4217.
- **Confirming** needs every required header value. Confirmed and rejected documents are final.
- The **enrichment match** scores each record by the share of its attributes equal to the extracted header value (case and blank insensitive): ≥ 0.8 matched, ≥ 0.4 ambiguous; it is recomputed after corrections.
- Schema fields are frozen once the schema is active — copy the schema to change them. A schema needs a header field to be activated.
- Training needs an active schema and `minTrainingDocuments` (default 3) confirmed documents of clients with data feedback enabled; one running job per schema. Model versions are `<schema>-v<n>`.
- Resources in use (schemas, document types, clients, templates of open documents, running training jobs) cannot be deleted.

## Project layout

```text
document-ai/
├── mta.yaml                      SAP BTP deployment (backend, approuter, XSUAA, user-provided config)
├── k8s/                          ConfigMap, Secret example, Deployment + PVC, Service
├── approuter/                    xs-app.json, xs-security.json (scopes / role collections), default-env.json (local only)
├── frontend/                     Fiori app: Component.js, manifest.json, view/, controller/, fragment/, model/, i18n/ (en, de),
│                                 localService/ (metadata.xml + mock data), test/ (QUnit, OPA5)
└── backend/
    ├── dub.sdl                   configurations: defaultRun (server), cli, gui, defaultTest
    ├── config/default.json       defaults (port 8096, file storage, jwt login, worker every 5 s)
    ├── tests/                    integration tests across all layers
    └── source/
        ├── app.d  cli.d  gui.d   entry points (composition roots)
        └── uim/platform/document_ai/
            ├── domain/           entities, types (ids, scopes, pairs, time), enumerations, exceptions,
            │                     services (file types, value checks, confidence, enrichment matcher, training evaluator)
            ├── ports/            usecases, services (statistics), repositories, storages (unit of work),
            │                     messaging (events), gateways (clock, extraction engine, password hasher, token issuer)
            ├── application/      usecases (master data, schemas, documents, training, access), services, dtos
            ├── persistence/      generic document repository, entity ↔ record mapping, batching file/memory store
            ├── infrastructure/   configuration, security (JWT, PBKDF2), logging, monitoring, clients
            │                     (simulated / HTTP extraction engine), workers, container
            └── presentation/     odata (EDM model + engine), http (REST, /auth, /health), web (/app), cli, gui
```

## Build and run

Prerequisites: D compiler (dmd 2.112 or ldc2 1.40), dub, the shared library [`../service`](../service).

```bash
cd backend
dub build                     # server  → build/uim-document-ai-platform-service
dub build --config=cli        # CLI     → build/uim-document-ai-cli
dub build --config=gui        # GtkD    → build/uim-document-ai-gui (needs GTK 3)
dub test                      # unit and integration tests
```

### Local development

```bash
cd backend
DOCAI_ADMIN_PASSWORD='choose a password' ./build/uim-document-ai-platform-service
# Fiori app:  http://localhost:8096/app/index.html       (log in as admin; "Create Demo Content" in an empty tenant)
# OData:      http://localhost:8096/odata/v4/document-ai/$metadata
# REST:       http://localhost:8096/api/v1/document-ai/capabilities
# Health:     http://localhost:8096/health

DOCAI_AUTH_MODE=open ./build/uim-document-ai-platform-service    # without login (development only)
```

Without `DOCAI_ADMIN_PASSWORD`, the first start creates the user `admin` with a generated password and logs it once.
Without `DOCAI_JWT_SECRET`, tokens are signed with a random secret and become invalid on restart.

The frontend also runs stand-alone with the UI5 tooling (`cd frontend && npm install && npm start`); it then needs the
backend for data (or a mock server using `localService/`).

### CLI

The CLI uses the same container and storage as the server; with `--data-file` it works on the server's snapshot.

```bash
./build/uim-document-ai-cli help
./build/uim-document-ai-cli seed --data-file=data/document-ai.json
./build/uim-document-ai-cli upload invoice-42.pdf --type=supplier-invoice --label=senderName=ACME\ Corp --extract
./build/uim-document-ai-cli values <document>                 # extracted values with confidence
./build/uim-document-ai-cli correct <value id> 1250.00
./build/uim-document-ai-cli confirm <document>
./build/uim-document-ai-cli review                            # documents that need a review
./build/uim-document-ai-cli fields invoice | copy invoice invoice-v2 | activate invoice-v2
./build/uim-document-ai-cli train train-invoice
./build/uim-document-ai-cli list Documents --filter="needsReview eq true" --json
./build/uim-document-ai-cli token admin | passwd admin '<new password>' | stats | config
```

Generic, model driven commands for every entity set: `sets`, `metadata`, `list`, `count`, `get`, `create`, `update`,
`delete`, `invoke`.

### Container / Kubernetes / BTP

```bash
# from the repository root (path dependency on ../../service)
docker build -f document-ai/backend/Dockerfile -t uim-platform/document-ai .
docker run -p 8096:8096 -e DOCAI_JWT_SECRET=… -e DOCAI_ADMIN_PASSWORD=… -v docai-data:/data uim-platform/document-ai

kubectl apply -f k8s/configmap.yaml -f k8s/secret.yaml -f k8s/deployment.yaml -f k8s/service.yaml   # secret.yaml from secret.example.yaml

mbt build && cf deploy mta_archives/uim-document-ai_2.0.0.mtar                                     # SAP BTP
```

## Authentication and authorization

| Mode | When | Login | Tokens |
|---|---|---|---|
| `jwt` | `authMode: "jwt"` (default in `config/default.json`, container, Kubernetes) | built-in: Fiori login dialog → `POST /auth/login` | HS256, signed with `jwtSecret` (≥ 32 characters), lifetime `tokenTtlSeconds` |
| `xsuaa` | an XSUAA binding in `VCAP_SERVICES` (BTP) — always wins | approuter (SAP ID service / IdP) | RS256 tokens of XSUAA, forwarded by the approuter |
| `open` | `authMode: "open"` | none — tenant from `X-Tenant-Id`, user from `X-User-Id` | — (local development only) |

Endpoints of the built-in login:

| Method | Path | |
|---|---|---|
| GET | `/auth/config` | `{mode, loginRequired, loginUrl, defaultTenant}` (public) |
| POST | `/auth/login` | `{username, password, tenant?}` (JSON or form) → `{access_token, token_type, expires_in, scope, user}` |
| GET | `/auth/me` | the caller: user, tenant, scopes |
| POST | `/auth/password` | `{currentPassword, newPassword}` — change the own password |
| POST | `/auth/logout` | stateless; the client discards the token |

Tokens carry XSUAA compatible claims (`sub`, `user_name`, `zid` = tenant, `scope[]`, `exp`, …), so REST and OData
verify both kinds alike. Passwords are stored as salted PBKDF2-HMAC-SHA256 hashes (120 000 rounds); unknown users and
wrong passwords answer the same; 5 failed logins lock the account for 15 minutes; the last administrator cannot be
deleted, locked or lose the Admin scope.

| Scope | Allows | XSUAA role template |
|---|---|---|
| `Read` | read everything | Viewer |
| `Process` | upload, extract, correct, confirm and reject documents | DocumentClerk |
| `Manage` | schemas and fields, templates, document types, enrichment data, clients, training (implies Process) | ExtractionExpert |
| `Admin` | users of the built-in login | Administrator |

The Fiori app keeps the token per browser tab (`sessionStorage`), sends it with every OData request, shows actions by
scope and returns to the login dialog when a token expires. `/health` stays public for probes.

## APIs

### OData v4 — `/odata/v4/document-ai`

Entity sets: `Documents`, `ExtractedFields` (PATCH `value` = correction), `Schemas`, `SchemaFields`, `Templates`,
`DocumentTypes`, `EnrichmentData`, `Clients`, `TrainingJobs`, `Users` (Admin), `Statistics` (singleton).
Query options: `$filter`, `$orderby`, `$top`, `$skip`, `$count`, `$select`, `$search`; `$batch` is supported.

Unbound actions: `ExtractDocument(id)`, `ConfirmDocument(id)`, `RejectDocument(id, reason)`,
`ProcessPendingDocuments()`, `CorrectField(id, value)`, `ActivateSchema(id)`, `DeprecateSchema(id)`,
`CopySchema(id, newId?)`, `ActivateTemplate(id)`, `DeactivateTemplate(id)`, `StartTraining(id)`,
`CancelTraining(id)`, `SeedDemoData()`.

### REST — `/api/v1/document-ai`

CRUD for `documents`, `extracted-fields` (read, PATCH), `schemas`, `schema-fields`, `templates`, `document-types`,
`enrichment-data`, `clients`, `training-jobs`, `users` (`GET /<r>` with OData query options → `{count, resources}`,
`GET/PUT/PATCH/DELETE /<r>/{id}`, `POST /<r>` → 201).

| Method | Path | |
|---|---|---|
| POST | `/documents/{id}/extract` · `/confirm` · `/reject {reason}` | processing |
| GET | `/documents/{id}/fields` | values: header fields, then line items |
| POST | `/documents/process` | extract the pending documents now |
| GET | `/review` | documents that need a review |
| POST | `/extracted-fields/{id}/correct {value}` | correction |
| POST | `/schemas/{id}/activate` · `/deprecate` · `/copy {newId?}` · GET `/schemas/{id}/fields` | schemas |
| POST | `/templates/{id}/activate` · `/deactivate` | templates |
| POST | `/training-jobs/{id}/start` · `/cancel` | training |
| GET | `/statistics` · `/capabilities` · `/meta` | KPIs, supported features, enumerations |
| POST | `/demo-data` | demo content for an empty tenant |

Errors: `{"error": {code, message, requestId, target}}` with 400 (invalid), 401, 403 (scope), 404, 405, 409
(conflict), 422 (business rule), 500.

> The API of the first generation (`/api/v1/AiDocument/jobs`, `X-Client-Id` header, snake_case enumeration values)
> was replaced; clients use the resources above and pass the client as `clientId`.

## Extraction engine

| `extractionMode` | Behaviour |
|---|---|
| `simulate` (default) | No OCR: deterministic, plausible values per field type and name; line item amounts add up to net, tax and gross. Labels `<field>=<value>` are recognized with high confidence; `simulate=failure` makes the extraction fail. About one in 13 unguided header values is "not found", which is what the review is for. |
| `http` | POSTs `{tenantId, document, schema, fields[], template?}` to `extractionUrl` and reads `{"fields": [{name, scope?, rowIndex?, value, confidence?, page?, coordinates?}], "pageCount"?}`. The `Authorization` header comes from the environment variable `DOCAI_EXTRACTION_AUTHORIZATION`. |

Pending documents are extracted by the background worker every `workerIntervalSeconds` (max `maxDocumentsPerRun` per
tenant), which also completes training jobs. With `workerIntervalSeconds = 0`, uploads are extracted inline.

## Configuration

Precedence: built-in defaults → `config/default.json` → `config/<UIM_PROFILE>.json` → `DOCAI_<KEY>` environment
variables → Cloud Foundry (`PORT`, `VCAP_SERVICES`: credentials of the user-provided service `document-ai-config`,
XSUAA binding) → command line options.

| Key (env) | Default | |
|---|---|---|
| `port` (`DOCAI_PORT`) | 8096 | |
| `storage` (`DOCAI_STORAGE`) | memory (`file` in default.json) | `memory` or `file` (JSON snapshot shared by server, CLI, GUI) |
| `dataFile` (`DOCAI_DATA_FILE`) | data/document-ai.json | |
| `authMode` (`DOCAI_AUTH_MODE`) | open (`jwt` in default.json) | `open` or `jwt`; XSUAA binding wins |
| `jwtSecret` (`DOCAI_JWT_SECRET`) | "" = random per start | ≥ 32 characters |
| `tokenTtlSeconds` | 3600 | |
| `adminUser` / `adminPassword` (`DOCAI_ADMIN_PASSWORD`) | admin / generated | first administrator in jwt mode |
| `passwordIterations`, `maxFailedLogins`, `lockSeconds`, `minPasswordLength` | 120000, 5, 900, 10 | |
| `minConfidence` | 0.7 | review threshold |
| `minTrainingDocuments`, `trainingSeconds` | 3, 30 | |
| `workerIntervalSeconds`, `workerTenants`, `maxDocumentsPerRun` | 5, ["default"], 50 | |
| `extractionMode`, `extractionUrl`, `extractionTimeoutSeconds` | simulate, "", 60 | |
| `apiPath`, `odataPath`, `frontendDir`, `maxPageSize`, `maxRequestBytes` | /api/v1, /odata/v4/document-ai, ../frontend, 200, 4 MiB | |

`./build/uim-document-ai-cli config` prints the effective configuration with secrets masked.

## Tests

```bash
cd backend && dub test        # 39 modules: domain rules, mapping, security, configuration and the integration suite
```

[backend/tests/document_ai_flows.d](backend/tests/document_ai_flows.d) runs the whole flow across the layers: seed →
upload → extraction → review and correction → confirmation → training; the business rules; REST and OData over
vibe.d test requests; the JWT login with the four scopes, lockout and tampered tokens; the CLI; and the batching file
store (one snapshot write per extraction).

Frontend: `frontend/test/testsuite.qunit.html` — QUnit tests of formatter, models, dialog payloads and session, and an
OPA5 journey against a running backend in open mode (`http://localhost:8096/app/test/integration/opaTests.qunit.html`).

## License

Apache 2.0 — see the repository root [LICENSE](../LICENSE).
