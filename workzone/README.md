# UIM Work Zone Service

A digital workplace service for the UIM Platform, modelled on **SAP Build Work Zone**:
collaborative **workspaces** with workpages, widgets, content, feeds, events, surveys,
forums and a knowledge base; a personal **inbox** of tasks and notifications;
**integration** of UI cards, business apps, external content providers and shell
plugins; and launchpad **sites** with navigation, themes, page templates, roles,
groups, tags and user profiles.

The backend is written in D on vibe.d 0.10 and follows a hexagonal (Clean)
architecture. It offers four driving adapters on top of the same ports:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST | `/api/v1/<resource>` | JSON API, resource catalogue, health check |
| OData v4 | `/odata/v4/workzone` | SAP Fiori 3 / UI5 frontend (`$metadata`, `$filter`, `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, actions) |
| CLI | `uim-workzone-cli` | Administration and scripting |
| GUI | `uim-workzone-gui` | GtkD 3 desktop client |

The server, the CLI and the GUI share data through JSON snapshot files, so a change
made in one of them shows up in the others.

## Project layout

```
workzone/
├── mta.yaml                    MTA descriptor (backend + approuter + XSUAA) for SAP BTP
├── README.md · UML.md · NAFv4.md
├── backend/                    D / vibe.d service
│   ├── dub.sdl                 configurations: defaultRun, cli, gui, defaultTest
│   ├── config/default.json     default settings (overridden by env and VCAP_SERVICES)
│   ├── Dockerfile · Containerfile
│   ├── docs/ · tests/ · views/ · build/
│   └── source/
│       ├── app.d · cli.d · gui.d                      entry points (composition roots)
│       └── uim/platform/workzone/
│           ├── helpers/        codec (struct ⇄ JSON by reflection), enums, json, time
│           ├── domain/         entities, types, enumerations, services, exceptions
│           ├── ports/          usecases, services, repositories, storages, messaging, gateways
│           ├── application/    usecases (interactors, housekeeping), services, dtos
│           ├── persistence/    repositories, storages, mappers, records
│           ├── infrastructure/ configuration, logging, security, clients, workers, container
│           └── presentation/   resources (protocol neutral), http, odata, cli, gui, web
├── frontend/                   SAP Fiori 3 / UI5 app (uim.workzone)
│   ├── manifest.json · Component.js · index.html
│   ├── view/ · controller/ · fragment/ · model/ · i18n/ · css/
│   ├── localService/           $metadata and the resource catalogue for offline work
│   └── test/                   QUnit (formatter, service) and OPA5 journeys
└── approuter/                  @sap/approuter: XSUAA login, CSRF, routing
```

The previous single-package implementation was moved to `legacy/`. It is no
longer built and can be deleted once nothing refers to it.

## Domain model

24 aggregates, all tenant scoped:

| Area | Aggregates (REST path) | Highlights |
|---|---|---|
| Collaboration | `workspaces`, `workpages`, `widgets`, `channels`, `content`, `feeds`, `events`, `surveys`, `forum-topics`, `knowledge-base` | members and roles, feature toggles, one default page per workspace, 4 column widget grid, publish / review workflows, activity feed |
| Inbox | `tasks`, `notifications` | overdue tasks, expiring notifications, read / dismiss |
| Integration | `cards`, `apps`, `content-providers`, `shell-plugins` | cards and apps in use are protected, provider connect / sync through a gateway |
| Sites & administration | `sites`, `navigation-items`, `themes`, `page-templates`, `roles`, `groups`, `tags`, `user-profiles` | publishing needs navigation, nested navigation without cycles, one default theme / template, roles in use are protected |

The main business rules:

- **Workspaces.** The creator becomes owner, and the last owner can neither leave nor be demoted. Names and URL aliases are unique. Archived and suspended workspaces accept no new content. Deleting a workspace deletes everything inside it.
- **Feature toggles.** Wiki pages, forum topics, knowledge base articles and feed entries need the matching workspace feature.
- **Widgets** show exactly one *active* card or app and must fit into the 4 column grid (`col + width ≤ 4`).
- **Knowledge base.** Articles go draft → review → published. Another user than the author must publish (four-eyes rule). Every publication raises the version, and editing a published article sends it back to draft.
- **Surveys.** Questions are fixed once a survey is active. Choice questions need at least two options. Each user answers once unless multiple responses are allowed.
- **Sites.** A site needs at least one visible navigation item before it can be published. Published sites cannot be deleted. Navigation items nest only under group entries of the same site, without cycles.
- **Housekeeping** applies the time-driven transitions. It runs in the server every 30 s, and on demand through the CLI, the GUI or the OData action `RunHousekeeping`:
  - tasks past their due date become **overdue**
  - events move scheduled → ongoing → completed
  - active surveys close at their end date
  - notifications are dismissed when they expire
  - connected content providers sync when their refresh interval has passed
- **Seed.** Installs predefined content: 6 roles, 4 SAP themes, 4 page templates and 6 tags. It is idempotent and runs on server start for the default tenant.

## Build and run

The backend depends on `uim-platform:service` through a path dependency (`../..`).

```bash
cd backend

# HTTP server: REST + OData v4 + Fiori app at http://localhost:8084/
dub build                      # → build/uim-workzone-platform-service
./build/uim-workzone-platform-service

# Command line interface
dub build --config=cli         # → build/uim-workzone-cli
./build/uim-workzone-cli help
./build/uim-workzone-cli seed
./build/uim-workzone-cli workspaces create --name="Sales EMEA" --type=team
./build/uim-workzone-cli workspaces add-member "Sales EMEA" --user-id=bob --role=contributor
./build/uim-workzone-cli workpages create --workspace-id="Sales EMEA" --title=Pipeline --template-id=Dashboard
./build/uim-workzone-cli cards create --title="Open Opportunities" --data-source-url=/odata/v4/sales/Opportunities
./build/uim-workzone-cli widgets create --workpage-id=Pipeline --card-id="Open Opportunities" --size=large
./build/uim-workzone-cli content create --workspace-id="Sales EMEA" --title="Q4 Plan" --body=@q4.md --tags=Sales
./build/uim-workzone-cli content publish "Q4 Plan"
./build/uim-workzone-cli tasks create --title="Approve discount" --assignee-id=bob --due-at=2026-11-30
./build/uim-workzone-cli housekeeping
./build/uim-workzone-cli stats --json

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub build --config=gui && ./build/uim-workzone-gui --tenant=default

# Unit tests: domain rules, codec, persistence, interactors, adapters,
# an end-to-end scenario, OData $metadata and the CLI
dub test --config=defaultTest
```

CLI conventions:

- Every resource supports `list`, `get`, `create`, `update`, `delete`, `fields` and its own actions.
- Resources can be addressed by id or by a unique name, title, alias or user id.
- Options may be written `--kebab-case` or `--camelCase`.
- Lists are given as `a,b`, key/value pairs as `k=v,k2=v2`, and structured fields (members, questions, sections) as JSON.
- `@file` reads a value from a file.

### Fiori app

The backend serves `../frontend` at `/` for local development (`frontendDir`).
Open http://localhost:8084/. The app is metadata driven:

- The side navigation groups all entity sets.
- List pages, create/edit forms and action menus are built from the resource catalogue (`GET /api/v1/resources`).
- Lifecycle buttons call the unbound OData actions.
- The overview binds the `Statistics` singleton (KPI header and tiles).
- Workspaces open an object page with members, workpages, content, events and the activity feed.

With the UI5 tooling instead: `cd frontend && npm install && npm start`.
Behind the approuter: `cd approuter && cp default-env.example.json default-env.json && npm install && npm run start:local`.

### Deploy

```bash
# SAP BTP (Cloud Foundry)
mbt build && cf deploy mta_archives/uim-workzone_1.0.0.mtar

# Container (build context: the uim-platform repository root)
docker build -f workzone/backend/Dockerfile -t uim-platform/workzone .
docker run -p 8084:8084 -v workzone-data:/data uim-platform/workzone
```

## Configuration

Settings are applied in this order, lowest priority first:

1. compiled defaults
2. `config/default.json`, or the file named by `WORKZONE_CONFIG_FILE`
3. environment variables
4. `VCAP_SERVICES` — the credentials of a service named or tagged `workzone-config`

| Setting | Environment | Default |
|---|---|---|
| `host` / `port` | `WORKZONE_HOST` / `WORKZONE_PORT`, `PORT` (CF), legacy `WZ_HOST` / `WZ_PORT` | `0.0.0.0` / `8084` |
| `logLevel` | `WORKZONE_LOG_LEVEL` | `info` |
| `storage` | `WORKZONE_STORAGE` | `file` (`memory` = volatile) |
| `dataDir` | `WORKZONE_DATA_DIR` | `data` |
| `defaultTenant` | `WORKZONE_DEFAULT_TENANT` | `default` |
| `odataPath` | `WORKZONE_ODATA_PATH` | `/odata/v4/workzone` |
| `housekeepingIntervalSeconds` | `WORKZONE_HOUSEKEEPING_INTERVAL` | `30` (0 = off) |
| `housekeepingTenants` | `WORKZONE_HOUSEKEEPING_TENANTS` | `default` |
| `seedContent` | `WORKZONE_SEED_CONTENT` | `true` |
| `frontendDir` | `WORKZONE_FRONTEND_DIR` | `../frontend` (`""` = off) |

The caller is resolved in this order:

1. The XSUAA bearer token: `zid` → tenant, `user_name` → user.
2. The `X-Tenant-Id` / `X-User-Id` headers.
3. The configured default tenant and the user `anonymous`.

The backend does **not** verify token signatures. Run it behind the approuter, or
add JWKS validation, before exposing it directly.

## REST API (`/api/v1`)

| Method | Path | |
|---|---|---|
| `GET` | `/<resource>[?<field>=<value>…]` | `{ "items": [...], "count": n }` |
| `POST` | `/<resource>` | create → 201 |
| `GET` | `/<resource>/<id|name>` | read |
| `PATCH` / `PUT` | `/<resource>/<id|name>` | partial update |
| `DELETE` | `/<resource>/<id|name>` | 204 |
| `POST` | `/<resource>/<id|name>/<action>` | e.g. `/workspaces/sales-emea/add-member {"userId": "bob"}` |
| `GET` | `/statistics` · `/resources` · `/health` | figures, catalogue (fields, columns, actions), health |
| `POST` | `/housekeeping` · `/seed` | time-driven transitions, predefined content |

Reference fields accept an id or a unique name or title: `workspaceId`,
`workpageId`, `siteId`, `themeId`, `templateId`, `cardId`, `appId`, `targetAppId`,
`targetWorkpageId` and `parentId`.

Errors look like `{ "error": { "code", "message" } }`:

| Status | Meaning |
|---|---|
| 400 | invalid payload |
| 404 | not found |
| 409 | conflict with the current state |
| 422 | business rule violated |

Secrets (`authToken`, `authConfig`) are masked as `********`. A masked value sent
back in a PATCH keeps the stored secret.

## OData v4 (`/odata/v4/workzone`)

- **Entity sets:** one per resource, e.g. `Workspaces`, `ContentItems`, `KnowledgeBaseArticles`, `UserGroups`.
- **Singleton:** `Statistics`.
- **Complex types:** `WorkspaceMember`, `TemplateSection`, `SurveyQuestion`, `KeyValue`.
- **Single properties:** `<Set>('<key>')/<property>` is supported, including collections such as `members`.
- **Unbound actions:** `<Action><Type>` with parameter `id` plus the action's own parameters (e.g. `PublishContentItem`, `AddMemberWorkspace {id, userId, displayName, role}`), and `RunHousekeeping` / `SeedContent`.
- **`$metadata`** carries `Common.Label` and the Capabilities insert/update/delete annotations.
- **`$batch` is not supported.** The UI5 model uses `groupId: "$direct"`.

## Changes from the previous version

- The code moved into the `backend/` · `frontend/` · `approuter/` layout with `mta.yaml`.
- The architecture now has separate `ports`, `persistence` and `infrastructure/{configuration,logging,security,clients,workers}` layers.
- Domain entities are plain structs. Serialization is done by a generic reflection codec, so the hand-written `toJson` methods are gone.
- Nested settings objects were flattened (e.g. `Workspace.settings.enableForum` → `enableForum`, `Card.dataSource.url` → `dataSourceUrl`) so they map 1:1 to OData properties and Fiori forms.
- Some entities and fields were renamed:
  - `WZTask` → `WorkTask`, `WZGroup` → `UserGroup`, `Event` → `CalendarEvent`, `Channel` → `WorkspaceChannel`, `Widget` → `PageWidget`
  - timestamps end in `At` (`dueDate` → `dueAt`, `startTime` → `startsAt`)
  - role, group and site references are kept **by name** (`allowedRoles`, `roles`, `assignedSites`)
- The REST resources are generated, with the same verbs for every resource. The old paths (`/workspaces`, `/workpages`, `/cards`, `/content`, `/feeds`, `/notifications`, `/tasks`, `/channels`, `/apps`, `/widgets`) are kept, and the other 14 resources are now exposed too.
- New: business rules, lifecycle actions, housekeeping, seed content, statistics, JSON file persistence shared by server / CLI / GUI, configuration from file / env / VCAP_SERVICES, XSUAA identity, and an end-to-end unit test scenario.

## Architecture notes

- **Dependencies point inwards.** The presentation layer only sees `WorkzonePorts`. Interactors only see `WorkzoneRepositories`, `IWorkzoneEventPublisher` and `IContentProviderGateway`.
- **One generic repository.** `IWorkzoneRepository!(E, Id)` (`findByName`, `findByWorkspace`, `findMatching`) serves all 24 aggregates. Storage is pluggable: in memory, or JSON snapshots that reload when another process changes the file.
- **One generic adapter.** `ResourceAdapter` wraps each port once. REST, OData `$metadata`, CLI tables and forms, and the GtkD GUI are all generated from the same registry.
- **Simulated gateway.** `SimulatedContentProviderGateway` stands in for remote content sources and is deterministic. Replace it with a BTP destination client for production. `LogEventPublisher` likewise stands in for SAP Event Mesh.
- See [UML.md](UML.md) for diagrams and [NAFv4.md](NAFv4.md) for the NAF v4 architecture description.

## License

Apache-2.0 — Copyright © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
