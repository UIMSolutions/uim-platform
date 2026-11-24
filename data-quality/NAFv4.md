# NAF v4 Architecture Description — Data Quality Service

Architecture description of the UIM Data Quality service following the
NATO Architecture Framework v4 (NAF v4). It covers the views that matter
for a single, self-contained platform service: concepts (C), service
specification (S), logical specification (L), physical resources (P) and
architecture meta-data (A).

| Item | Value |
|---|---|
| Subject | UIM Data Quality service, version 2.0.0 |
| Scope | Backend (D / vibe.d), Fiori app (OpenUI5), approuter, deployment (BTP, Kubernetes) |
| Purpose | Basis for development, operation, security review and integration |
| Related documents | [README.md](README.md) (usage, configuration), [UML.md](UML.md) (diagrams) |

## 1. NAF v4 grid mapping

| | Taxonomy | Structure | Connectivity | Processes | States | Sequences | Information | Constraints | Roadmap |
|---|---|---|---|---|---|---|---|---|---|
| **Concepts (C)** | C1 §2 | | C3 §2 | | | | | | C2 §2 |
| **Service specification (S)** | S1 §3 | S2 §3 | S3 §3 | S4 §3 | S5 §3 | | | | |
| **Logical specification (L)** | L1 §4 | | L2 §4 | L4 §4 | | L6 §4 | L7 §4 | L8 §4 | |
| **Physical resources (P)** | P1 §5 | P2 §5 | | P4 §5 | | P5 §5 | | | |
| **Architecture meta-data (A)** | A1 §6 | | | | A3 §6 | | | A7 §6 | A8 §6 |

## 2. Concepts (C)

### C1 – Capability taxonomy

```
Data Quality Management
├── C1.1 Data catalog
│   ├── Datasets (master, reference, transactional data)
│   ├── Records (ordered name=value fields)
│   └── Bulk import (CSV, JSON)
├── C1.2 Data validation
│   ├── Rule catalog (9 rule types, severities, priorities, dataset patterns)
│   ├── Record validation (on change) and dataset validation (on demand)
│   ├── Violations with correction suggestions
│   └── Stateless validation service for integrations
├── C1.3 Data profiling
│   ├── Type detection, completeness, uniqueness, ranges, lengths
│   └── Top values and value patterns
├── C1.4 Matching and consolidation
│   ├── Duplicate detection (exact, fuzzy, phonetic, composite)
│   └── Golden record resolution with field merge
├── C1.5 Data cleansing
│   ├── Cleansing rule catalog (11 transformations incl. enrichment)
│   ├── Cleansing jobs (dry run, change log, revalidation)
│   └── Address cleansing and plausibility (≈ 30 postal formats)
├── C1.6 Quality monitoring
│   ├── Scorecards over five dimensions with rating
│   ├── Trend snapshots
│   └── Tenant statistics (KPI header)
└── C1.7 Access control
    ├── Built-in login with user accounts and JWT (HS256)
    ├── SAP XSUAA integration (RS256, approuter)
    └── Scope based authorization (Read, Manage, Admin)
```

### C2 – Enterprise vision

Data stewards see the quality of every dataset at a glance, understand each
defect down to record, field and rule, and fix defects at the source with
repeatable rules instead of manual edits. Integrations reuse the same rules
through a stateless API, so data is checked before it enters a system.
The service runs stand-alone (one binary, one data file, built-in login) or
as an SAP BTP application behind the approuter with XSUAA.

Roadmap (not implemented):

| Step | Capability |
|---|---|
| R1 | Database document store (PostgreSQL / SAP HANA JSON) for multiple instances |
| R2 | Scheduled validations and alerting on score drops |
| R3 | Postal reference data and geocoding for address verification |
| R4 | Blocking keys for fuzzy matching of large datasets |
| R5 | Refresh tokens / OpenID Connect for the built-in login |

### C3 – Capability dependencies

| Capability | Depends on |
|---|---|
| C1.2 Validation | C1.1 (records), reference datasets of C1.1 for `referenceData` rules |
| C1.3 Profiling | C1.1 |
| C1.4 Matching | C1.1; C1.2 to revalidate merged golden records |
| C1.5 Cleansing | C1.1; C1.1 reference datasets for `enrich`; C1.2 to revalidate |
| C1.6 Monitoring | C1.2 (violations), C1.3 (completeness), C1.4 (open duplicates) |
| all | C1.7 (every call is authorized per scope) |

## 3. Service specification (S)

### S1 – Service taxonomy

| Service | Kind | Consumers | Interface |
|---|---|---|---|
| S1.1 Data Quality OData service | management | Fiori app, CLI, GUI | OData V4 `/odata/v4/data-quality` |
| S1.2 Data Quality REST service | integration | external systems, scripts | REST `/api/v1` |
| S1.3 Authentication service | security | Fiori app, scripts | REST `/auth` |
| S1.4 Health service | operations | Cloud Foundry, Kubernetes | `GET /health` |
| S1.5 Fiori app | user interface | data stewards, administrators | `/app` (stand-alone) or approuter |
| S1.6 Command line / desktop GUI | administration | operators | `uim-data-quality-cli`, `uim-data-quality-gui` |

### S2 – Service structure

All adapters use the same driving ports (`DqPorts`), so every service
offers identical behaviour and the same business rules:

```
S1.1 OData ─┐
S1.2 REST  ─┤
S1.3 Auth  ─┼─▶ driving ports ─▶ interactors ─▶ domain services
S1.6 CLI   ─┤        (DqPorts)                 └▶ driven ports ─▶ storage, security, events
S1.6 GUI   ─┘
```

### S3 – Service interfaces

| Interface | Protocol / format | Authentication | Notes |
|---|---|---|---|
| OData V4 | HTTP/JSON, `$batch`, `$metadata` with UI annotations | Bearer JWT (HS256 or XSUAA RS256) | key `<datasetId>~<id>` for dataset scoped sets |
| REST `/api/v1` | HTTP/JSON, `text/csv` for imports | Bearer JWT | errors `{"error": {code, message, requestId, target}}` |
| Auth `/auth` | HTTP/JSON, form-urlencoded login | public: `config`, `login`; token: `me`, `password` | tokens carry XSUAA compatible claims |
| Health | HTTP/JSON | none | status, version, storage, security mode |
| CLI | process arguments, text or `--json` | local, trusted | same storage file as the server |

### S4 – Service functions

| Function | OData | REST | CLI |
|---|---|---|---|
| Maintain datasets / records | `Datasets`, `Records` CRUD | `POST /datasets/{id}/records` | `create`, `update`, `delete`, `import` |
| Maintain rules | `ValidationRules`, `CleansingRules` CRUD | — | `create`, `update` |
| Validate | `ValidateDataset`, `ValidateRecord` | `POST /validate`, `/datasets/{id}/validate` | `validate` |
| Profile | `ProfileDataset`, `ColumnProfiles` | `POST /profiles`, `/datasets/{id}/profile` | `profile` |
| Match | `DetectDuplicates`, `ResolveMatchGroup`, `MatchGroups` | `POST /duplicates/detect`, `/datasets/{id}/duplicates` | `duplicates` |
| Cleanse | `CleansingJobs`, `RunCleansingJob`, `CancelCleansingJob`, `Addresses` | `POST /addresses/cleanse` | `cleanse` |
| Monitor | `ComputeScorecard`, `TakeSnapshot`, `QualitySnapshots`, `Statistics` | `GET /datasets`, `/datasets/{id}/scorecard` | `scorecard`, `stats` |
| Administer users | `Users` (Admin scope) | `/auth/password` | `passwd`, `token` |

### S5 – Service states

| Element | States |
|---|---|
| Validation / cleansing rule | draft → active ⇄ inactive (only active rules run) |
| Cleansing job | pending → running → completed / failed; pending → cancelled |
| Match group | open → resolved |
| User account | active ⇄ temporarily locked (failed logins); active ⇄ locked (administrator) |
| Service | UP (health) after configuration, storage and security are initialised |

## 4. Logical specification (L)

### L1 – Node types

| Node | Responsibility |
|---|---|
| N1 Browser (Fiori app) | user interaction, session (token in sessionStorage) |
| N2 Approuter (BTP only) | XSUAA login, routing, CSRF protection, static app |
| N3 Data quality backend | all services S1.1 – S1.4, background job worker |
| N4 Identity provider | XSUAA (BTP) or the backend's built-in login |
| N5 Data store | document store (memory or JSON snapshot file) |
| N6 Operator workstation | CLI and GUI on the same data file |
| N7 Integration client | calls REST/OData with a bearer token |

### L2 – Logical scenario (node connectivity)

```
Stand-alone / Kubernetes                      SAP BTP
  N1 ──HTTPS──▶ N3 (/app, /auth, /odata)        N1 ──▶ N2 ──XSUAA login──▶ N4
  N7 ──HTTPS──▶ N3 (/auth/login, /api/v1)            N2 ──forwardAuthToken──▶ N3
  N3 ──▶ N5 (file)                                   N3 ──verify (RS256 key)──▶ N4
  N6 ──▶ N5 (same file)                              N3 ──▶ N5
```

### L4 – Logical activities (data quality cycle)

```
 import / maintain records
          │
          ▼
 validate ──▶ violations ──▶ scorecard + snapshot
          │                        │
          ▼                        ▼
 profile ──▶ completeness     monitor trend, KPIs
          │
          ▼
 detect duplicates ──▶ resolve golden records (merge)
          │
          ▼
 cleanse (rules, jobs, addresses) ──▶ revalidate ──▶ improved score
```

### L6 – Logical sequence

The relevant sequences are given in [UML.md §7](UML.md#7-sequence-diagrams):
login and authorized OData call, dataset validation, cleansing job with
revalidation, golden record resolution.

### L7 – Logical data model

| Entity | Key | Main attributes | Relations |
|---|---|---|---|
| Dataset | id | name, category, scores (5 dimensions), validated/profiled/checked at | owns records, violations, profiles, groups, jobs, snapshots |
| DataRecord | datasetId~id | fields[], qualityScore, violationCount, worstSeverity | — |
| ValidationRule | id | type, severity, status, pattern/range/values/expression/reference, priority | produces violations |
| Violation | datasetId~recordId:ruleId | field, value, severity, message, suggestion | record, rule |
| CleansingRule | id | action, parameters, status, priority | used by jobs |
| CleansingJob | datasetId~id | status, dryRun, counts, changeLog | rules |
| MatchGroup | datasetId~id | strategy, threshold, candidates (record, score), survivor, resolved | records |
| ColumnProfile | datasetId~field | type, completeness, uniqueness, range, top values, patterns | — |
| QualitySnapshot | datasetId~id | scores, record and violation counts, time | — |
| PostalAddress | id | input, standardized output, quality, changes | optional source record |
| UserAccount | user name | display name, password hash, scopes, lock state | — |

All entities carry tenant and audit fields; every collection is partitioned
by tenant.

### L8 – Logical constraints

| # | Constraint |
|---|---|
| L8.1 | Ids: 1–64 characters `[A-Za-z0-9._-]`, first a letter or digit; field names start with a letter or `_`. |
| L8.2 | Only active rules run; rules apply to datasets matching their pattern, in priority order. |
| L8.3 | Empty values violate only `required` rules; all other rule types skip them. |
| L8.4 | Info violations are reported but do not lower scores. |
| L8.5 | A dataset used as reference data (validation) or lookup data (cleansing) cannot be deleted. |
| L8.6 | Only pending cleansing jobs can be cancelled; running jobs cannot be deleted. |
| L8.7 | A resolved match group cannot be resolved again; the survivor must be a candidate. |
| L8.8 | Fuzzy and composite matching are limited to `maxPairwiseRecords` (20 000) records. |
| L8.9 | Passwords: ≥ 10 characters, not only digits; stored only as salted PBKDF2 hashes. |
| L8.10 | The last unlocked administrator cannot be deleted, locked or demoted; nobody deletes or locks the own account. |
| L8.11 | After 5 failed logins an account is locked for 15 minutes (configurable). |
| L8.12 | Reads need `Read`, changes and analyses `Manage`, user administration `Admin`. |

## 5. Physical resource specification (P)

### P1 – Resource types

| Resource | Technology |
|---|---|
| Backend executable | D (dmd / ldc2), vibe.d 0.10.x, uim-framework 26.11, uim-platform:service |
| CLI / GUI executables | same code base, `dub --config=cli` / `--config=gui` (GtkD 3) |
| Fiori app | OpenUI5 1.120 (sap.m, sap.f, sap.ui.layout), theme sap_fiori_3 |
| Approuter | Node.js ≥ 20, `@sap/approuter` |
| Identity | SAP XSUAA (BTP) or built-in accounts with HS256 JWTs |
| Storage | in-memory or JSON snapshot file (`data/data-quality.json`) |
| Runtime | Cloud Foundry binary buildpack; container image (Ubuntu 24.04); Kubernetes |

### P2 – Resource structure

```
data-quality/
├── mta.yaml                    MTA: backend, approuter, XSUAA, user-provided config
├── backend/
│   ├── dub.sdl                 configurations: defaultRun, cli, gui, defaultTest
│   ├── config/default.json     defaults (authMode jwt, file storage)
│   ├── Dockerfile, Containerfile
│   ├── source/app.d, cli.d, gui.d
│   ├── source/uim/platform/data_quality/{domain,ports,application,persistence,infrastructure,presentation}
│   └── tests/data_quality_flows.d
├── frontend/                   manifest.json, Component.js, view/, controller/, fragment/,
│                               model/ (models, formatter, dialogs, session), i18n/ (en, de),
│                               localService/ (metadata, mock data), test/ (QUnit, OPA5)
├── approuter/                  package.json, xs-app.json, xs-security.json, default-env.json (local)
└── k8s/                        configmap, secret.example, deployment (+ PVC), service
```

### P4 – Resource functions

| Resource | Functions |
|---|---|
| `uim-data-quality-platform-service` | S1.1–S1.4, Fiori app at `/app`, cleansing job worker, administrator bootstrap |
| `uim-data-quality-cli` | entity CRUD, actions, import, validate, profile, duplicates, cleanse, scorecard, `token`, `passwd`, `config` |
| `uim-data-quality-gui` | model driven entity browser with action runner |
| Approuter | XSUAA login, routes `/odata/v4/data-quality`, `/api/v1`, `/auth/(config\|me)`, `/health`, static app |
| XSUAA | scopes Read/Manage/Admin, role collections Viewer, Steward, Administrator |

### P5 – Resource interactions

| From | To | Interaction |
|---|---|---|
| Browser | backend `/auth/login` | user name + password → JWT (jwt mode) |
| Browser | approuter | XSUAA login, session cookie (BTP) |
| Approuter | backend | destination `data-quality-srv`, forwards the XSUAA token |
| Backend | XSUAA binding | reads `verificationkey` from `VCAP_SERVICES` |
| Backend | file system | snapshot read on change, write per batch (temp file + rename) |
| CLI | file system | same snapshot as the server |
| Job worker | interactors | runs pending cleansing jobs every `jobIntervalSeconds` |

## 6. Architecture meta-data (A)

### A1 – Meta-data

| Item | Value |
|---|---|
| Architecture | UIM Data Quality service |
| Version | 2.0.0 |
| Framework | NAF v4 (subset of views relevant for one service) |
| Notation | tables, text diagrams, Mermaid (UML.md) |
| Date | November 2026 |

### A3 – Architecture status

| Area | Status |
|---|---|
| Domain, ports, interactors, persistence | implemented, unit and integration tested (`dub test`) |
| OData, REST, auth, CLI | implemented, tested over vibe.d test requests |
| Built-in login / JWT | implemented: PBKDF2 (RFC test vectors), lockout, scopes, admin protection |
| Fiori app | implemented: login, user menu, datasets, scorecards, violations, rules, cleansing, duplicates, addresses, users; QUnit and OPA5 tests |
| GtkD GUI | implemented on the shared entity browser |
| Multi instance storage, postal reference data | roadmap (C2) |

### A7 – Standards

| Standard | Use |
|---|---|
| OData V4 (OASIS) | management API, `$metadata`, `$batch`, query options |
| SAP UI vocabularies | Fiori annotations (UI.LineItem, UI.HeaderInfo, …) |
| RFC 7519 / 7515 (JWT, JWS) | access tokens, HS256 and RS256 |
| RFC 8018 (PBKDF2) | password hashing with HMAC-SHA256 |
| RFC 4180 | CSV import |
| ISO 3166-1 alpha-2 | country codes |
| ISO 8601 | timestamps |
| SAP Fiori 3 design | user interface |

### A8 – Architecture decisions

| # | Decision | Rationale |
|---|---|---|
| AD1 | Hexagonal / clean architecture with one set of driving ports for all adapters | OData, REST, CLI, GUI and the worker behave identically; domain stays testable without I/O |
| AD2 | One EDM model drives OData, CLI and GUI | no duplicated adapter code; new entity sets appear everywhere |
| AD3 | Records as ordered `name=value` fields instead of fixed schemas | any dataset can be checked without schema maintenance |
| AD4 | Score dimensions derived from rule types | the scorecard explains itself: each violation belongs to one dimension |
| AD5 | Latest violations per record and rule, history as snapshots | bounded storage, trend still available |
| AD6 | Unit of work on the document store | bulk operations write the snapshot once instead of per document |
| AD7 | Built-in login issuing HS256 JWTs, verified like XSUAA tokens | stand-alone operation without an identity provider; one token path for all adapters; XSUAA on BTP without code changes |
| AD8 | PBKDF2-HMAC-SHA256 from Phobos | no native crypto dependency; parameters stored with each hash and upgraded on login |
| AD9 | OData model created after login in the Fiori app | `$metadata` and every request carry the bearer token |
| AD10 | Server computed `…Text` properties for collections | the OData V4 model cannot bind collection values to controls |
| AD11 | Pure domain services with delegate based reference lookups | reference data is loaded once per run and the services stay free of repositories |
