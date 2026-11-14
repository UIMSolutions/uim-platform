# UIM Translation Hub Service

A D/vibe.d service modelled on **SAP Translation Hub** on SAP BTP. It translates
software texts and documents and manages the translation of applications:

- **Text translation**: UI strings, messages and other software texts, with a quality
  estimate for each text.
- **Document translation**: plain text, Markdown, HTML, JSON (string values only) and
  `.properties` files (values only). The structure of the document is kept.
- **Translation projects** (file, Git, ABAP, API) hold source **texts** identified by
  text keys. Each text has one translation per target language, which can be machine
  translated, set by hand and reviewed.
- **Company glossary** (company MLTR): mandatory terms are enforced by every provider.
  Optional terms are applied only by `companyMltr`.
- **Asynchronous jobs** for text blocks, documents or whole projects. A background
  worker processes them.
- **Reference data**: 44 languages (BCP-47), 20 translation domains, 8 text types and
  4 providers (`mltr`, `machineMt`, `companyMltr`, `llm`).

One hexagonal core, four driving adapters:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST `/api/v1/translation` | `uim-translation-platform-service` | JSON API for build pipelines and other services (paths of the previous API) |
| OData v4 `/odata/v4/translation` | `uim-translation-platform-service` | SAP Fiori 3 / UI5 frontend |
| CLI | `uim-translation-cli` | translation, `.properties` import/export, administration |
| GtkD GUI | `uim-translation-gui` | desktop client with a translator workbench |

The server, CLI and GUI share the same snapshot storage (`backend/data/*.json`). A
change made in one of them is visible in the others.

## Project layout

```
translation/
├── mta.yaml                    MTA descriptor (backend + approuter + XSUAA) for SAP BTP / Cloud Foundry
├── backend/                    D 2.11x / vibe.d 0.10.3
│   ├── dub.sdl                 configurations: defaultRun (server), cli, gui, defaultTest
│   ├── config/default.json     default configuration
│   ├── Dockerfile · Containerfile   container image (build from the repository root)
│   └── source/
│       ├── app.d · cli.d · gui.d                  composition roots
│       └── uim/platform/translation/
│           ├── domain/          entities (project, text, glossary entry, job), types (ids,
│           │                    value objects, reference data), enumerations, exceptions,
│           │                    services (languages, catalogs, glossary, quality, names, lifecycle)
│           ├── ports/           usecases, services (driving) · repositories, storages,
│           │                    messaging, gateways (driven: ITranslationProviderGateway)
│           ├── application/     usecases (one interactor per aggregate + synchronous translate),
│           │                    services (Translator pipeline, project translation, catalog,
│           │                    statistics, events), dtos (specs, requests, results)
│           ├── persistence/     repositories, storages (JSON snapshot files, memory),
│           │                    mappers (reflection based), records (collections, envelope)
│           ├── infrastructure/  configuration, logging, security (XSUAA identity),
│           │                    clients (simulated provider), workers (job worker), container (DI)
│           ├── presentation/    resources (protocol-neutral adapters + registry), http (REST),
│           │                    odata (model, $metadata, query engine, controller), cli, gui, web
│           └── helpers/         codec (struct ⇄ JSON reflection), enums, json, time
├── frontend/                   SAP Fiori 3 / UI5 app (uim.translation)
│   ├── view/ controller/ fragment/ model/ i18n/ (en, de)
│   ├── localService/           $metadata and mock data captured from the backend
│   └── test/                   QUnit (formatter) and OPA5 journey
├── approuter/                  @sap/approuter: xs-app.json, xs-security.json, default-env.json (local only)
└── k8s/                        ConfigMap, Deployment, Service
```

## Domain model

| Aggregate | Parent | Lifecycle | Notable rules |
|---|---|---|---|
| `TranslationProject` | — | draft → active → inProgress ⇄ completed; any → archived → active | name unique per tenant and fixed; source language fixed once texts exist; Git projects need a repository URL; ABAP projects need a system ID; archived projects are read-only; deleting a project deletes its texts and is blocked while a job for it is open |
| `ProjectText` | project | untranslated → partial → translated → reviewed | text key unique per project (`[A-Za-z0-9_.-]`); changing the source text discards its translations; translations of reviewed texts are never overwritten by machine runs |
| `GlossaryEntry` | — | — | term unique per language pair and domain (case-insensitive); source and target language must differ |
| `TranslationJob` | (project for `software`) | pending → processing → completed / failed; pending/processing → cancelled; failed/cancelled → pending (retry) | immutable after submission; failures are stored in the job (`statusMessage`), never lost |

All aggregates are tenant scoped (`TenantEntity`: `tenantId`, `id`, `createdBy/At`, `updatedBy/At`).

### Translation pipeline (`Translator`)

1. Select the glossary entries for the request: same language pair (primary subtag),
   matching domain or no domain, and mandatory (optional entries too for `companyMltr`).
   Longer terms come first.
2. Replace whole-word occurrences of the glossary terms by placeholders `⟦n⟧`. The
   engine cannot translate or break them.
3. Call the provider gateway (`ITranslationProviderGateway`).
4. Put the target terms in place of the placeholders and count the glossary hits.
5. Estimate quality: the engine score, +2 per glossary hit, −20 if the text exceeds an
   explicit `maxLength`. Report a truncation risk when the text type's recommended
   length is exceeded.

Project runs, single-text translation, jobs and synchronous requests all use this
pipeline.

## Build and run

```bash
cd backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:8096/
dub build && ./build/uim-translation-platform-service

# Command line interface
dub build --config=cli
./build/uim-translation-cli translate "Save" "Cancel" --from=en --to=de
./build/uim-translation-cli glossaries create --source-language=en --target-language=de \
    --source-term=invoice --target-term=Faktura --mandatory
./build/uim-translation-cli projects create --name=Webshop --target-languages=de,fr,es
./build/uim-translation-cli import-texts Webshop i18n.properties
./build/uim-translation-cli projects translate Webshop
./build/uim-translation-cli texts list --project-id=Webshop --status=partial
./build/uim-translation-cli export-texts Webshop de --out=i18n_de.properties
./build/uim-translation-cli translate-document --from=en --to=fr --file=readme.md --out=readme.fr.md
./build/uim-translation-cli jobs create --job-type=software --project-id=Webshop
./build/uim-translation-cli process-jobs
./build/uim-translation-cli help

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub build --config=gui && ./build/uim-translation-gui [--tenant=<id>] [--data-dir=<dir>]

# Unit tests (domain rules, codec, persistence, use cases, adapters, CLI, an end-to-end scenario)
dub test --config=defaultTest
```

Every resource supports the same CLI verbs: `list [--field=value …]`, `get`, `create`,
`update`, `delete`, `fields` and its actions (`projects translate Webshop --force`,
`texts set-translation <id> --language=de --text="Sichern"`). Ids and project
references also accept unique names. Add `--json` for machine-readable output.

### Fiori app

The backend serves `frontend/` at `/` for local development (`frontendDir`). The app
has these tabs:

- **Overview**: KPI header and tiles.
- **Translate**: a workbench with language, provider, domain and text type selection.
  It calls `TranslateTexts`, and the input can also be submitted as a job.
- **Projects**: activate, translate all, archive and reopen. Opening a project shows
  an object page with its texts, manual translation and review.
- **Texts**, **Glossary** and **Jobs**: process, cancel and retry jobs.
- **Languages**.

To work without a backend, use `localService/` (metadata and mock data captured from a
seeded backend). The UI runs on the OData V4 model with `groupId: "$direct"`.

### Deploy to SAP BTP (Cloud Foundry)

```bash
mbt build && cf deploy mta_archives/uim-translation_1.0.0.mtar
```

The approuter authenticates with XSUAA and forwards `/odata/v4/translation/*` and
`/api/v1/*` to the backend (destination `translation-srv`). The role collections are
*UIM Translation Viewer*, *UIM Translator* and *UIM Translation Administrator* (see
`approuter/README.md`).

### Container / Kubernetes

```bash
# from the uim-platform repository root
podman build -f translation/backend/Containerfile -t uim-platform/cloud-translation .
kubectl apply -f translation/k8s/
```

The image contains the server, the CLI, the default configuration and the Fiori app.
Snapshots go to `/app/data`, which the Deployment mounts as an `emptyDir`. Use a
PersistentVolumeClaim to keep the data across restarts.

## Configuration

Precedence (lowest → highest):

1. compiled defaults
2. `config/default.json` (or `TRANSLATION_CONFIG_FILE`)
3. environment variables
4. `VCAP_SERVICES`: the credentials of a service named or tagged `translation-config`

| Key | Env | Default | Meaning |
|---|---|---|---|
| `serviceName` | `TRANSLATION_SERVICE_NAME` | Translation Hub Service | |
| `host` / `port` | `TRANSLATION_HOST` / `TRANSLATION_PORT`, `PORT` | 0.0.0.0 / 8096 | listener |
| `logLevel` | `TRANSLATION_LOG_LEVEL` | info | trace, debug, info, warn, error, none |
| `storage` | `TRANSLATION_STORAGE` | file | `file` (JSON snapshots) or `memory` |
| `dataDir` | `TRANSLATION_DATA_DIR` | data | snapshot directory |
| `defaultTenant` | `TRANSLATION_DEFAULT_TENANT` | default | tenant used when there is no token and no `X-Tenant-Id` |
| `odataPath` | `TRANSLATION_ODATA_PATH` | /odata/v4/translation | |
| `restPath` | `TRANSLATION_REST_PATH` | /api/v1/translation | |
| `jobIntervalSeconds` | `TRANSLATION_JOB_INTERVAL` | 5 | job worker period, 0 = off |
| `jobTenants` | `TRANSLATION_JOB_TENANTS` | default | comma separated |
| `providers` | `TRANSLATION_PROVIDERS` | mltr,machineMt,companyMltr,llm | available providers (the others answer 409) |
| `defaultProvider` | `TRANSLATION_DEFAULT_PROVIDER` | machineMt | used when a request names none |
| `maxTextLength` | `TRANSLATION_MAX_TEXT_LENGTH` | 5000 | per text in `translate` |
| `maxBatchSize` | `TRANSLATION_MAX_BATCH_SIZE` | 100 | texts per `translate` request |
| `maxDocumentLength` | `TRANSLATION_MAX_DOCUMENT_LENGTH` | 1000000 | characters per document / job |
| `frontendDir` | `TRANSLATION_FRONTEND_DIR` | ../frontend | "" = do not serve the UI |

Tenant and user come from the XSUAA bearer token (`zid`, `user_name`) or from the
`X-Tenant-Id` / `X-User-Id` headers. The backend decodes the token but does **not**
verify its signature, because it relies on the approuter. Verify JWTs before you
expose the backend directly.

## REST API (`/api/v1/translation`)

| Method | Path | |
|---|---|---|
| POST | `/translate` | `{"sourceLanguage", "targetLanguage", "texts": [...]` (or `"text"`)`, "provider", "domainName", "textType"}` |
| POST | `/documents/translate` | `{"sourceLanguage", "targetLanguage", "content", "contentType", "provider", "domainName"}` |
| POST | `/documents/translate/async` | same body → 202, a submitted document job |
| GET | `/<resource>[?<field>=<value>…]` | list, filtered by payload fields → `{items, count}` |
| POST | `/<resource>` | create → 201 |
| GET | `/<resource>/{id}` | read |
| PATCH (PUT) | `/<resource>/{id}` | partial update |
| DELETE | `/<resource>/{id}` | → 204 |
| POST | `/<resource>/{id}/<action>` | action; parameters go in the JSON body |
| POST | `/process-jobs` | process pending jobs now |
| GET | `/statistics` | KPIs |
| GET | `/resources` | catalogue: resources, input fields, actions |
| GET | `/api/v1/health` | liveness / readiness |

| Resource | Access | Actions |
|---|---|---|
| `projects` | read/write | `activate`, `translate {force}`, `archive`, `reopen` |
| `texts` | read/write (`projectId` = id or project name) | `translate`, `set-translation {language, text}`, `review {language}` |
| `glossaries` | read/write | — |
| `jobs` | create/delete (immutable) | `process`, `cancel`, `retry` |
| `languages`, `domains`, `text-types`, `providers` | read-only | — |

Errors have the form `{"error": {"code": "NotFound|Conflict|BusinessRuleViolation|BadRequest|MethodNotAllowed|…", "message": "…"}}`,
with status 400 / 404 / 405 / 409 / 422 / 500.

## OData v4 (`/odata/v4/translation`)

- Entity sets:
  - `TranslationProjects`, `ProjectTexts` and `GlossaryEntries`.
  - `TranslationJobs`, which is not updatable.
  - `Languages`, `TranslationDomains`, `TextTypes` and `Providers`, which are read-only.
- Singleton `Statistics`. Complex types `TextTranslation`, `TranslatedText`,
  `TranslateTextsResult`, `DocumentTranslationResult` and `JobRunReport`.
- Unbound actions named `<Action><Type>`, each with the parameter `id`:
  - Projects: `ActivateTranslationProject`, `TranslateTranslationProject(force)`,
    `ArchiveTranslationProject`, `ReopenTranslationProject`.
  - Texts: `TranslateProjectText`, `SetTranslationProjectText(language, text)`,
    `ReviewProjectText(language)`.
  - Jobs: `ProcessTranslationJob`, `CancelTranslationJob`, `RetryTranslationJob`.
- Other unbound actions:
  - `TranslateTexts(sourceLanguage, targetLanguage, texts: Collection(Edm.String), provider, domainName, textType)`
  - `TranslateDocument(…)`
  - `ProcessJobs()`
- Query options: `$filter` (eq ne gt ge lt le and or not, contains startswith endswith
  tolower toupper), `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search` and
  `/$count`.
- `$metadata` carries `Common.Label` and capability annotations (Insertable /
  Updatable / Deletable).
- There is no `$batch`; the UI5 model uses `groupId: "$direct"`.

## Changes from the previous version

The service was rebuilt on the hexagonal layout of `connectivity` and the
`fiori-vibed-architecture` skill.

- **Layout:**
  - The module moved from `translation/source` to `translation/backend`. In the root
    `dub.sdl` the entry is now `subPackage "translation/backend"`; it is still
    commented out there.
  - New: `frontend/`, `approuter/`, `mta.yaml`.
  - The container files moved to `backend/` and are built from the repository root.
  - CI (`.github/workflows/translation.yml`) builds the server and the CLI and runs
    the tests in `backend/`.
  - The two prebuilt binaries in the old `build/` were removed from git.
- **New features:**
  - OData v4 with the Fiori app, the CLI (incl. `.properties` import/export) and the
    GtkD GUI with a translator workbench.
  - Project texts with per-language translations, manual translation and review.
  - Project runs, project progress (`textCount`, `completionPercent`) and project
    status from progress, plus archive and reopen.
  - Glossary enforcement (placeholder protection, mandatory vs optional, domains).
  - Quality adjustment and truncation risk.
  - Structure-preserving document translation (JSON, properties).
  - A job worker with retry; `software` jobs translate a project.
  - Read-only reference data sets and statistics.
  - Persistence in JSON snapshots (`storage=memory` keeps the old behaviour), a
    configuration file and `VCAP_SERVICES`.
- **Routes:**
  - The paths below `/api/v1/translation` are kept: `translate`,
    `documents/translate[/async]`, `projects`, `glossaries`, `jobs`,
    `jobs/{id}/cancel`, `languages`, `domains`, `text-types`.
  - `PATCH` was added; PUT is still accepted.
  - New: `texts`, `providers`, `process-jobs`, `statistics`, `resources`.
- **Payloads:**
  - List responses are `{items, count}` instead of per-resource keys (`entries`,
    `projects`, `resources`).
  - The glossary `domain` is now `domainName`; `domain` is still accepted in translate
    requests.
  - Errors are `{error: {code, message}}`.
  - Timestamps are ISO 8601 strings.
  - Jobs return `translatedContent`, `qualityLevel`, `glossaryHits`, `statusMessage`
    and `attempts`.
- **Fixed:**
  - `GET /languages` never answered with languages: the handler was named
    `listhandler` and did not override `listHandler`.
  - `GET /glossaries/{id}` returned only the id, not the entry.
  - `/documents/translate/async` translated synchronously instead of creating a job.
  - Submitted jobs were never processed (there was no worker), and `cancel` read the
    id from the wrong path segment.
  - Glossary entries were stored but never applied to translations.
  - Unknown providers, project types and statuses were silently replaced by defaults.
    They now fail with 422.
  - Languages were not validated.
  - `POST /translate` wrapped errors in a success response.

## Architecture notes

- **Reflection codec.** Persistence records, REST/OData payloads, OData `$metadata`,
  CLI tables and GUI forms are all derived from the domain structs at compile time
  (`helpers/codec.d`). A field added to an entity and its spec is available in every
  adapter. `decode(patch, base)` gives PATCH semantics.
- **Resource registry.** `presentation/resources` wraps each driving port in a
  protocol-neutral adapter: JSON in and out, columns, actions, immutable resources,
  and read-only `CatalogAdapter`s for reference data. REST, OData, CLI and GUI are
  thin protocol layers on top of it.
- **Provider gateway.** `ITranslationProviderGateway` is the only seam to translation
  engines. The default `SimulatedTranslationProvider` is deterministic: a small en→de/fr/es/it
  terminology dictionary is applied word by word (case is kept), and unknown words
  lower the quality score. Real SAP MLTR, neural MT or generative AI hub clients can
  replace it without changing the use cases.
- **Events.** Every lifecycle change is published through `ITranslationEventPublisher`
  (default: the technical log): `translation.project.translated`,
  `translation.job.completed`, and so on.
- **Snapshot storage.** There is one JSON file per collection. Writes are atomic (temp
  file + rename), and a collection is reloaded when another process changed it. This
  suits local and single-instance use, not many concurrent writers.

See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the NAF v4 architecture description.

## License

Apache 2.0 — see `LICENSE.txt` in the repository root.
