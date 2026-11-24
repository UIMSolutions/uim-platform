# NAF v4 Architecture Description — UIM Data Retention

> NATO Architecture Framework v4 description of the UIM Data Retention service 2.0: rule based blocking, archiving
> and destruction of personal data (SAP Data Retention Manager style) with a D/vibe.d backend, an SAP Fiori 3 /
> OpenUI5 frontend, built-in JWT login or SAP XSUAA.

---

## 1. Grid mapping

| NAF v4 viewpoint | Subject | Section |
|---|---|---|
| C1 Capability Taxonomy · C2 Enterprise Vision | what the service is able to do and why | §2 |
| C4 Standard Processes / L4 Logical Activities | end-of-purpose, erasure, archiving, login | §3 |
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
CAP-DR   Data Retention Management
├── CAP-DR-1  Retention policy definition
│   ├── 1.1  Application groups, legal entities, data subject roles (master data)
│   ├── 1.2  Business purposes with lifecycle (inactive → active → deprecated)
│   ├── 1.3  Legal grounds (GDPR Art. 6 bases, legal references)
│   └── 1.4  Residence and retention rules per legal ground (calendar periods, action on expiry)
├── CAP-DR-2  Retention evaluation
│   ├── 2.1  End of purpose / end of retention per data subject (longest obligation governs)
│   ├── 2.2  Live evaluation on every read (no stale results)
│   └── 2.3  What-if simulation for a reference date
├── CAP-DR-3  Data subject lifecycle enforcement
│   ├── 3.1  End-of-purpose check (block, mark for deletion; simulation; periodic)
│   ├── 3.2  Legal hold
│   ├── 3.3  Archiving and destruction jobs (scheduled, on demand, dry run)
│   └── 3.4  Destruction by deletion or anonymization with tombstone proof
├── CAP-DR-4  Data subject rights
│   └── 4.1  Deletion / restriction requests with retention precedence (GDPR Art. 17 (3) b, Art. 18)
├── CAP-DR-5  Access management
│   ├── 5.1  Built-in login (JWT HS256, PBKDF2, lockout), user administration
│   └── 5.2  SAP XSUAA integration (RS256, role collections)
└── CAP-DR-6  Operations
    ├── 6.1  Multi-tenancy (tenant isolation of all data)
    ├── 6.2  Statistics / KPIs, health probes, structured logs, business events
    └── 6.3  Layered configuration (files, env, VCAP_SERVICES)
```

### C2 — Enterprise vision

| Aspect | Statement |
|---|---|
| Mission | Keep personal data exactly as long as purpose and law require — no longer, no shorter. |
| Vision | Retention policies become executable: defined once, evaluated continuously, enforced auditable. |
| Scope | Policy definition, evaluation, blocking, archiving, destruction and erasure requests for application groups. |
| Out of scope | Physical deletion inside the source applications (they consume the decisions via OData/REST/events). |
| Stakeholders | Data protection officers, compliance and legal, auditors, application owners, platform operators. |
| Outcomes | GDPR Art. 5 (1) e storage limitation, Art. 17/18 handling, demonstrable accountability (Art. 5 (2)). |

---

## 3. Processes (C4 / L4)

| ID | Process | Trigger | Steps | Result |
|---|---|---|---|---|
| PR-1 | Define retention policy | DPO | group, role, entity → purpose → legal grounds → residence/retention rules → activate (needs a complete ground) | active purpose |
| PR-2 | End-of-purpose check | DPO, or worker every `endOfPurposeCheckSeconds` | evaluate subjects → block past end of purpose → mark past end of retention (legal hold excluded) | check result, events |
| PR-3 | Erasure request | data subject via DPO / application | create request → worker or DPO processes → destroy, or block + reject with earliest date | request status |
| PR-4 | Archiving / destruction | schedule or "run now" | select group subjects past end of purpose → archive; past end of retention → delete/anonymize; skip legal holds | job counters + log |
| PR-5 | Legal hold | legal department | set hold with reason → excluded from marking/destruction → release | subject flag |
| PR-6 | Sign-in | user | `/auth/config` → login dialog → `/auth/login` → token in session storage | bearer token |

---

## 4. Service viewpoint (S1 / S4)

| Service ID | Service | Interface | Consumers | Scope |
|---|---|---|---|---|
| SVC-ODATA | Retention OData service | `/odata/v4/data-retention` (12 sets, 14 actions, `$batch`) | Fiori app, integrations | Read / Manage / Admin |
| SVC-REST | Retention REST API | `/api/v1/data-retention/...` (CRUD + operations, legacy paths) | applications, scripts | Read / Manage |
| SVC-AUTH | Login service | `/auth/config, /login, /me, /password, /logout` | Fiori app, clients | public / authenticated |
| SVC-HEALTH | Health | `/health`, `/api/v1/health` | Kubernetes, Cloud Foundry | public |
| SVC-UI | Fiori app | `/app/index.html` (local) or approuter | end users | via SVC-ODATA |
| SVC-CLI | Administration CLI | `uim-data-retention-cli` | operators | local, trusted |
| SVC-GUI | Desktop browser | `uim-data-retention-gui` (GtkD) | operators | local, trusted |
| SVC-WORKER | Background processing | timers in the server process | — | technical user `retention-worker` |

All interfaces call the same `ODataEngine` → driving ports, so validation, scopes and error semantics are identical.

---

## 5. Logical / operational viewpoint (L2 / L3)

```text
 ┌──────────────┐   HTTPS (OAuth2)   ┌──────────────┐   HTTP + JWT    ┌───────────────────────────────┐
 │ DPO / Auditor │ ─────────────────▶ │  Approuter   │ ──────────────▶ │  Data Retention Service        │
 │  (Browser)    │ ◀───────────────── │  (XSUAA)     │                 │  OData · REST · Auth · Worker  │
 └──────────────┘                    └──────────────┘                 └──────────────┬────────────────┘
        │  local development: /app + /auth/login (authMode jwt)                      │
        └────────────────────────────────────────────────────────────────────────────┤
 ┌──────────────┐   REST / OData + JWT                                               │ events (log / broker)
 │ Applications │ ◀──────────────────────────────────────────────────────────────────┤
 │ (ERP, HR, …) │   block / destroy decisions                                        ▼
 └──────────────┘                                                         ┌──────────────────────┐
 ┌──────────────┐   local process (trusted)                               │ Document store        │
 │ Operator CLI │ ───────────────────────────────────────────────────────▶│ memory | JSON snapshot│
 └──────────────┘                                                         └──────────────────────┘
```

| Flow | From → To | Content | Classification |
|---|---|---|---|
| IF-1 | Browser → Service | OData requests, policy maintenance | internal |
| IF-2 | Service → Browser | data subjects (external id, name, dates) | **personal data** |
| IF-3 | Applications ↔ Service | registration of subjects, decisions | personal data (ids) |
| IF-4 | Service → Log/Broker | business events (ids, counts only) | internal, no personal data |
| IF-5 | Service ↔ Store | records incl. password hashes | personal data, secrets |

---

## 6. Logical data model (L7)

| Entity | Key | Relations | Notes |
|---|---|---|---|
| ApplicationGroup | id | — | scope global/regional/local, application ids |
| LegalEntity | id | — | ISO 3166-1 country |
| DataSubjectRole | id | — | |
| BusinessPurpose | id | → ApplicationGroup, DataSubjectRole, LegalEntity? | status inactive/active/deprecated |
| LegalGround | id | → BusinessPurpose (immutable) | GDPR Art. 6 type, legal reference |
| ResidenceRule | id | → LegalGround (1:0..1), BusinessPurpose | period |
| RetentionRule | id | → LegalGround (1:0..1), BusinessPurpose | period, action on expiry |
| DataSubject | id | → BusinessPurpose, ApplicationGroup, LegalGround?, Role?, LegalEntity? | external id unique per group; lifecycle; legal hold; derived evaluation |
| DeletionRequest | id | → DataSubject | no personal data |
| ArchivingJob | id | → ApplicationGroup | counters, log (ids only) |
| UserAccount | id (user name) | — | PBKDF2 hash, scopes, lockout |
| Statistics | tenant | aggregate | singleton |

Every record carries `tenantId` and audit attributes (`createdAt/By`, `updatedAt/By`). Details: [UML.md](UML.md) §1.

---

## 7. Resource viewpoint (P1 / P2)

| Resource | Type | Realisation |
|---|---|---|
| RES-BE | Service binary | D (dmd/ldc2), vibe.d 0.10.5, uim-framework 26.11, shared `service` package (OData engine, CLI, GUI, security context) |
| RES-UI | Web application | OpenUI5 1.120, sap_fiori_3, XML views, OData V4 model, i18n en/de |
| RES-AR | Approuter | @sap/approuter 20, xs-app.json routes, xs-security.json |
| RES-CLI / RES-GUI | Executables | same container and storage as the server |
| RES-STORE | Persistence | in-memory or JSON snapshot file with batched writes (one write per batch) |

Backend layering (hexagonal / clean):

| Layer | Packages | Depends on |
|---|---|---|
| Domain | entities, types, enumerations, exceptions, services (`evaluateRetention`) | — |
| Ports | usecases, services, repositories, storages, messaging, gateways | domain |
| Application | usecases (`ResourceInteractor` generic + specific), services (`RuleBook`, statistics, lookups, demo data), dtos | ports, domain |
| Persistence | records, mappers (compile-time reflection), repositories, storages | ports |
| Infrastructure | configuration, logging, security, clients, workers, container | ports, application |
| Presentation | odata, http, web, cli, gui | ports (driving) |

---

## 8. Physical deployment (P4 / P5)

### SAP BTP (Cloud Foundry) — `mta.yaml`

| Module / resource | Type | Notes |
|---|---|---|
| data-retention-srv | binary_buildpack | `ldc2` release build, health check `/health`, 256 MB |
| data-retention-approuter | approuter.nodejs | serves the Fiori app, forwards the token |
| data-retention-xsuaa | xsuaa / application | scopes Read, Manage, Admin; role collections |
| data-retention-config | user-provided | runtime overrides (worker, periodic check) |

### Kubernetes — `k8s/`

```text
Deployment data-retention (1 replica, Recreate — file store is single node)
├── container uim-platform/data-retention:latest  :8112, non-root, read-only root fs
│   ├── envFrom ConfigMap data-retention-config (DR_*), Secret data-retention-secret (DR_JWT_SECRET, DR_ADMIN_PASSWORD)
│   ├── volume /data ← PVC data-retention-data (1 Gi)
│   └── probes GET /health
└── Service data-retention  :80 → 8112
```

---

## 9. Standards profile (A8)

| Area | Standard |
|---|---|
| Data protection | GDPR Art. 5 (1) e, 6, 17, 18; BDSG §26; HGB §257 / AO §147 (demo rules) |
| API | OData v4.0 (CSDL, JSON format, `$batch`), SAP UI / Common vocabularies, REST/JSON |
| Security | OAuth 2.0 bearer tokens, JWT (RFC 7519) HS256/RS256, PBKDF2 (RFC 8018), SAP XSUAA |
| Dates | ISO 8601 (Edm.Date, Edm.DateTimeOffset, UTC) |
| Countries | ISO 3166-1 alpha-2 |
| UI | SAP Fiori 3 design, OpenUI5 |
| Deployment | MTA 3.3, Cloud Foundry, OCI images, Kubernetes |

---

## 10. Security and constraints

| ID | Control |
|---|---|
| SEC-1 | Authentication modes `xsuaa` (RS256 verification), `jwt` (built-in login, HS256 ≥ 32 char secret), `open` (development only) |
| SEC-2 | Scopes enforced by the engine for OData and REST: Read, Manage, Admin; Simulate needs Read only |
| SEC-3 | Passwords: PBKDF2-HMAC-SHA256, 120 000 rounds, random salt, rehash on login; min. 10 characters |
| SEC-4 | Lockout after 5 failed logins for 15 min; uniform error and timing for unknown users |
| SEC-5 | Last administrator cannot be deleted, locked or demoted; own account cannot be deleted/locked |
| SEC-6 | Secrets masked in `config` output; `default-env.json` and `k8s/secret.yaml` git-ignored |
| DP-1 | Retention obligations take precedence over erasure; legal hold blocks destruction |
| DP-2 | Destruction removes external id and name; tombstone keeps only ids, dates, method |
| DP-3 | Events, logs, deletion requests and job logs contain ids and counts, no personal data |
| CON-1 | File storage: single instance (snapshot); horizontal scaling needs a shared document store adapter |
| CON-2 | CLI/GUI are trusted local adapters (no scope enforcement) — restrict OS access accordingly |

---

## 11. Architecture decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hexagonal layering under `backend/source/uim/platform/data_retention` | business rules testable without HTTP/storage; adapters swappable |
| AD-2 | One EDM model drives OData, REST, CLI and GUI | identical validation, scopes and errors on every channel |
| AD-3 | Evaluation is derived on read, never stored | rule changes take effect immediately; no stale phases |
| AD-4 | Longest legal obligation governs | conservative, matches SAP DRM semantics |
| AD-5 | Calendar arithmetic for periods | the former 30-day/365-day approximation drifted by days |
| AD-6 | Erasure rejected only for retention > 0 | consent-based data is erasable on request; legal obligations win |
| AD-7 | Tombstones instead of physical record removal | accountability: proof of when and how data was destroyed |
| AD-8 | Generic `ResourceInteractor` and reflection based mappers | one implementation of PATCH, immutables, auditing and persistence for all maintained resources |
| AD-9 | Batching unit of work | a check over thousands of subjects writes the snapshot once |
| AD-10 | Built-in JWT login next to XSUAA | usable stand-alone (on-premise, Kubernetes) and on BTP with the same code |
| AD-11 | REST keeps the `/api/v1/data-retention/...` paths | existing integrations keep working |
| AD-12 | Port 8112 | UIM platform port allocation |
