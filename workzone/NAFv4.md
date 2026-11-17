# NAF v4 Architecture Description — Work Zone Service

> NATO Architecture Framework v4 (NAF v4) description of the UIM Platform
> Work Zone service: a digital workplace modelled on SAP Build Work Zone —
> collaborative workspaces (pages, widgets, content, feeds, events, surveys, forum,
> knowledge base), a personal inbox (tasks, notifications), integration of cards,
> apps, external content and shell plugins, and launchpad sites with navigation,
> themes, roles and user profiles — exposed through REST, OData v4 (SAP Fiori 3), a
> CLI and a GtkD desktop GUI.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – Capability View | C1 Capability Taxonomy, C2 Enterprise Vision, C3 Capability Dependencies | §2 |
| **NSV** – Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions, NSOV-3 Service Interfaces | §3 |
| **NOV** – Operational View | NOV-1 Concept, NOV-2 Node Connectivity, NOV-5 Operational Activities | §4 |
| **NLV** – Logical View | NLV-1 Logical Data Model, NLV-2 Logical Components, NLV-6 State Transitions | §5 |
| **NPV** – Physical View | NPV-1 Physical Deployment, NPV-2 Configuration | §6 |
| **NIV** – Information View | NIV-1 Information Structure, NIV-2 Business Rules | §7 |
| **Architecture decisions** | — | §8 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Work Zone
├── C1.1  Collaboration
│   ├── C1.1.1  Workspaces (types, members & roles, feature toggles, archive / suspend / restore)
│   ├── C1.1.2  Workpages from page templates (one default page per workspace)
│   ├── C1.1.3  Widgets showing integration cards or business apps (4 column grid)
│   ├── C1.1.4  Content: blog posts, wiki pages, announcements, documents (publish, pin, like)
│   ├── C1.1.5  Activity feed (written automatically for joins, publications, replies, events)
│   ├── C1.1.6  Events (time window, attendees, status follows the clock)
│   ├── C1.1.7  Surveys (questions, activation, single response rule, closing)
│   ├── C1.1.8  Forum (topics, replies, pin / lock / close)
│   ├── C1.1.9  Knowledge base (review workflow, versioning, four-eyes publishing)
│   └── C1.1.10 Channels (activity and external feeds)
├── C1.2  Personal Inbox
│   ├── C1.2.1  Tasks (own and federated, priority, due date, overdue detection)
│   └── C1.2.2  Notifications (priority, read / unread / dismiss, expiry)
├── C1.3  Integration
│   ├── C1.3.1  UI integration cards (sap.card manifest, data source, auth)
│   ├── C1.3.2  Business app registry (launch target, platforms, SSO)
│   ├── C1.3.3  External content providers (connect, sync, scheduled refresh)
│   └── C1.3.4  Shell plugins (hook points, site assignment)
├── C1.4  Sites
│   ├── C1.4.1  Sites (alias, theme, settings, publish / maintenance / archive)
│   ├── C1.4.2  Navigation (links, apps, workpages, groups; nested, cycle free)
│   ├── C1.4.3  Themes on SAP base themes (one default)
│   └── C1.4.4  Page templates (sections, layouts, allowed widget sizes)
├── C1.5  Administration
│   ├── C1.5.1  Roles and permissions (verb:object)
│   ├── C1.5.2  User groups (security, distribution, dynamic)
│   ├── C1.5.3  Tags (hierarchical)
│   ├── C1.5.4  User profiles (default roles, groups, login tracking)
│   └── C1.5.5  Predefined content (roles, themes, templates, tags — idempotent seed)
└── C1.6  Operations
    ├── C1.6.1  Housekeeping (time driven transitions, scheduled syncs)
    ├── C1.6.2  Statistics / KPIs
    ├── C1.6.3  Multi-tenancy (XSUAA zone, X-Tenant-Id)
    └── C1.6.4  Shared persistence for server, CLI and GUI
```

### C2 – Enterprise Vision

Provide a single, tenant-aware digital workplace in which teams collaborate and
users find their work: business apps, cards, tasks and notifications in one place,
with SAP Fiori 3 user experience on SAP BTP. Business rules stay in the domain core,
so every channel behaves the same: browser, scripted CLI, desktop GUI, or a third
system using REST or OData.

### C3 – Capability Dependencies

| Capability | Depends on |
|---|---|
| C1.1.2 Workpages | C1.1.1 (active workspace), C1.4.4 (template), C1.5.1 (roles) |
| C1.1.3 Widgets | C1.1.2, C1.3.1 / C1.3.2 (active card or app) |
| C1.1.4 Content | C1.1.1 (active workspace, wiki toggle), C1.5.3 (tags) |
| C1.1.5 Feed | C1.1.1 (feeds enabled), C1.5.4 (display names) |
| C1.1.8 Forum · C1.1.9 Knowledge base | C1.1.1 (feature toggle) |
| C1.2.2 Notifications | C1.5.4 (recipient profile, once profiles are maintained) |
| C1.4.1 Sites | C1.4.3 (theme), C1.4.2 (publishing needs navigation) |
| C1.4.2 Navigation | C1.4.1, C1.3.2, C1.1.2 |
| C1.3.4 Shell plugins | C1.4.1 |
| C1.5.2 Groups · C1.5.4 Profiles | C1.5.1 |
| C1.6.1 Housekeeping | C1.1.6, C1.1.7, C1.2, C1.3.3 |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Work Zone Service
├── Resource services (24): workspaces, workpages, widgets, channels, content, feeds,
│   events, surveys, forum-topics, knowledge-base, tasks, notifications, cards, apps,
│   content-providers, shell-plugins, sites, navigation-items, themes, page-templates,
│   roles, groups, tags, user-profiles
│     └── uniform operations: list (filter) · get · create · update · delete · <actions>
├── Housekeeping service       (run time driven transitions)
├── Seed service               (predefined content)
├── Statistics service         (KPIs)
├── Resource catalogue service (fields, columns, references, actions)
└── Health service
```

### NSOV-2 – Service Definitions

| Service | Port | Behaviour |
|---|---|---|
| Manage workspaces | `IManageWorkspacesUseCase` | CRUD, add / remove member, change role, archive / suspend / restore; delete cascades |
| Manage workpages / widgets | `IManageWorkpagesUseCase`, `IManageWidgetsUseCase` | default page, template, grid placement, move |
| Manage content / feed | `IManageContentUseCase`, `IManageFeedEntriesUseCase` | publish, archive, pin, like; feed posts |
| Manage events / surveys / forum / knowledge base | `IManageEventsUseCase`, `IManageSurveysUseCase`, `IManageForumTopicsUseCase`, `IManageKnowledgeBaseUseCase` | lifecycles of §5 |
| Manage tasks / notifications | `IManageTasksUseCase`, `IManageNotificationsUseCase` | start, complete, cancel, reopen; read, unread, dismiss |
| Manage cards / apps / providers / plugins | `IManageCardsUseCase`, `IManageAppsUseCase`, `IManageContentProvidersUseCase`, `IManageShellPluginsUseCase` | activation, deprecation, connect / sync |
| Manage sites / navigation / themes / templates | `IManageSitesUseCase`, `IManageNavigationItemsUseCase`, `IManageThemesUseCase`, `IManagePageTemplatesUseCase` | publish, maintenance, default theme / template |
| Manage roles / groups / tags / profiles | `IManageRolesUseCase`, `IManageGroupsUseCase`, `IManageTagsUseCase`, `IManageUserProfilesUseCase` | protected references, group members, login tracking |
| Housekeeping | `IHousekeepingUseCase` | `HousekeepingReport(examined, changed, changes)` |
| Seed | `IWorkzoneSeedService` | `SeedReport(created, skipped, items)` |
| Statistics | `IWorkzoneStatisticsService` | `WorkzoneStatistics` (28 figures) |

Each mutation returns a `UsecaseResult`. Failures carry 404 (not found), 409
(conflict with state) or 422 (business rule).

### NSOV-3 – Service Interfaces

| Interface | Protocol | Consumers |
|---|---|---|
| REST `/api/v1/<resource>[/<id>[/<action>]]`, `/statistics`, `/housekeeping`, `/seed`, `/resources`, `/health` | HTTP/JSON | integrations, scripts, Fiori (catalogue) |
| OData v4 `/odata/v4/workzone` — 24 entity sets, `Statistics` singleton, unbound actions `<Action><Type>`, `RunHousekeeping`, `SeedContent`; `$filter $orderby $select $top $skip $count $search`; property access | OData v4 JSON, CSDL | SAP Fiori 3 / UI5 app, OData clients |
| CLI `uim-workzone-cli <resource> <verb>` | process / stdout (table or `--json`) | administrators, CI pipelines |
| GtkD GUI `uim-workzone-gui` | desktop | administrators |
| Domain events `workzone.<kind>.<verb>` | `IWorkzoneEventPublisher` (log; Event Mesh ready) | downstream systems |
| Content provider gateway | `IContentProviderGateway` (simulated; BTP destinations ready) | external content sources |

---

## 4. Operational View (NOV)

### NOV-1 – Concept

Employees open the Work Zone Fiori app through the approuter (XSUAA login).
Contributors maintain workspaces, pages and content. Site and content
administrators curate apps, cards, providers, themes and navigation. The service
applies the business rules. A background worker keeps time-dependent states
current. Administrators script bulk changes with the CLI or work offline-capable
on the desktop GUI against the same data.

### NOV-2 – Operational Node Connectivity

| From | To | Exchange |
|---|---|---|
| Employee (browser) | Approuter | HTTPS, XSUAA OAuth2 login, CSRF token |
| Approuter | Work Zone backend | OData v4 / REST with forwarded JWT |
| Administrator | CLI / GUI | local process, shared snapshot directory |
| Work Zone backend | External content providers | connect / sync through the gateway |
| Work Zone backend | Event broker / log | domain events |

### NOV-5 – Operational Activities

| Activity | Actor | Service |
|---|---|---|
| Set up a workspace, invite members, assign roles | Workspace owner | workspaces (create, add-member, change-role) |
| Compose a workpage with cards and apps | Contributor | workpages, widgets |
| Write and publish content, run surveys, discuss | Contributor | content, surveys, forum-topics |
| Review and publish knowledge articles | Reviewer (≠ author) | knowledge-base (submit, publish) |
| Work through tasks and notifications | Employee | tasks, notifications |
| Register apps and cards, connect providers | Content manager | apps, cards, content-providers |
| Build and publish a site | Site administrator | sites, navigation-items, themes, shell-plugins |
| Maintain roles, groups, users, tags | Tenant administrator | roles, groups, user-profiles, tags |
| Keep states current | System (worker) | housekeeping |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Key relations | Lifecycle attribute |
|---|---|---|
| Workspace | members (WorkspaceMember[]) | status |
| Workpage | workspaceId, templateId | isDefault, visible |
| PageWidget | workpageId, workspaceId, cardId \| appId | visible |
| WorkspaceChannel | workspaceId | active |
| ContentItem | workspaceId, authorId, tags (names) | status, pinned |
| FeedEntry | workspaceId, actorId | — |
| CalendarEvent | workspaceId, organizerId, attendeeIds | status |
| Survey | workspaceId, questions (SurveyQuestion[]) | status |
| ForumTopic | workspaceId, authorId | status, pinned, locked |
| KnowledgeBaseArticle | workspaceId, relatedArticleIds | status, version |
| WorkTask | assigneeId | status |
| Notification | recipientId | status |
| Card · AppRegistration | — | active · status |
| ExternalContentProvider | — | status |
| ShellPlugin | assignedSites (names) | status |
| Site | themeId, allowedRoles (names) | status |
| NavigationItem | siteId, parentId, targetAppId, targetWorkpageId | visible |
| Theme · PageTemplate | sections (TemplateSection[]) | isDefault, predefined |
| Role · UserGroup · Tag · UserProfile | roles / groups / parentTag (names), userId | predefined · active |

### NLV-2 – Logical Components

| Layer | Components |
|---|---|
| Domain | 24 entities; value objects (WorkspaceMember, TemplateSection, SurveyQuestion, KeyValue); enumerations; services `membership`, `names`, `schedule`, `navigation`, `scoping`; exceptions |
| Ports | driving `WorkzonePorts` (24 use case ports + housekeeping, statistics, seed); driven `IWorkzoneRepository`, `ISnapshotStorage`, `IWorkzoneEventPublisher`, `IContentProviderGateway` |
| Application | `ResourceUseCase` base + 24 interactors, `HousekeepingUseCase`, `CascadeDeleter`, `FeedRecorder`, `WorkzoneSeedService`, `WorkzoneStatisticsService`, specs / requests / reports |
| Persistence | `WorkzoneRepository`, `SnapshotTenantStore`, `RecordMapper`, `JsonFileSnapshotStorage`, `MemorySnapshotStorage`, collections |
| Infrastructure | `Container`, `WorkzoneConfig` (file / env / VCAP), XSUAA identity, `LogEventPublisher`, `SimulatedContentProviderGateway`, `HousekeepingWorker` |
| Presentation | `ResourceRegistry` + `ResourceAdapter`; REST, OData v4 (model, `$metadata`, query engine), CLI, GtkD GUI, frontend server |
| Frontend | UI5 component `uim.workzone`: ToolPage shell, overview (KPIs, tiles), generic list page and create / edit dialog driven by the resource catalogue, workspace object page |

### NLV-6 – State Transitions

| Entity | Transitions (action / *time*) |
|---|---|
| Workspace | active → archived · suspended (archive · suspend) → active (restore) |
| ContentItem | draft → published (publish) → archived (archive) |
| KnowledgeBaseArticle | draft → review (submit) → published (publish, version + 1) → draft (edit); → archived |
| Survey | draft → active (activate) → closed (close / *endsAt*) → archived |
| CalendarEvent | scheduled → ongoing (*startsAt*) → completed (*endsAt*); → cancelled |
| WorkTask | open → inProgress (start) → completed · cancelled; open / inProgress → overdue (*dueAt*); completed / cancelled → open (reopen) |
| Notification | unread / actionRequired → read ⇄ unread → dismissed (dismiss / *expiresAt*) |
| ForumTopic | open ⇄ closed (close / reopen); flags pinned, locked |
| Site | draft → published (publish) ⇄ maintenance; published → draft (unpublish); → archived |
| ExternalContentProvider | disconnected → connected · error (connect); connected → synced (sync / *refresh interval*) → error |
| AppRegistration · Card · ShellPlugin · UserProfile | active ⇄ inactive; apps → deprecated |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

| Node | Artifact | Notes |
|---|---|---|
| SAP BTP Cloud Foundry | `workzone-srv` (binary_buildpack, `uim-workzone-platform-service`) | built by `mbt build` (`dub build --build=release`); health check `/api/v1/health` |
| SAP BTP Cloud Foundry | `workzone-approuter` (@sap/approuter, Fiori app in `resources/`) | XSUAA, CSRF, destination `workzone-srv` |
| SAP BTP services | `workzone-xsuaa` (xsuaa / application), `workzone-config` (user-provided) | scopes WorkzoneViewer / Contributor / Admin |
| Container runtime | image from `backend/Dockerfile` (server + CLI) | port 8084, volume `/data` |
| Workstation | `uim-workzone-cli`, `uim-workzone-gui` (GTK 3.24) | same snapshot directory as a local server |

### NPV-2 – Configuration

Configuration is applied as compiled defaults → `config/default.json` → `WORKZONE_*`
environment (`PORT` on Cloud Foundry, legacy `WZ_HOST` / `WZ_PORT`) →
`VCAP_SERVICES` (`workzone-config`). The settings are:

- host and port
- log level
- storage (`file` | `memory`) and data directory
- default tenant
- OData path
- housekeeping interval and tenants
- predefined content seeding
- frontend directory

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

- **Payload / OData format:**
  - JSON with the entity field names; a trailing `_` is dropped (`alias`, `body`, `version`)
  - timestamps as ISO 8601 / `Edm.DateTimeOffset`
  - enums by name
  - value object lists as collections of complex types
- **Records (persistence):** the same structure with raw std-time numbers. One snapshot file per collection: `{schemaVersion, collection, records[]}`, written atomically.
- **Secrets** (`authToken`, `authConfig`) are stored, masked on output (`********`), and kept when a masked value is sent back.
- **Identity:** tenant from the XSUAA `zid` claim or the `X-Tenant-Id` header; user from the `user_name` claim or the `X-User-Id` header; else `anonymous`.

### NIV-2 – Business Rules

| # | Rule |
|---|---|
| BR-01 | Workspace names and aliases (slug, 2–64 chars) are unique per tenant; the alias is derived from the name if empty. |
| BR-02 | A workspace always has at least one owner; the creator becomes owner; members are unique. |
| BR-03 | Only active workspaces accept new pages, widgets, channels, content, events, surveys, topics, articles and members. |
| BR-04 | Wiki pages, forum topics, knowledge base articles and feed entries need the corresponding workspace feature. |
| BR-05 | Deleting a workspace deletes its pages, widgets, channels, content, feed, events, surveys, topics and articles. |
| BR-06 | Workpage titles are unique per workspace; the first page and any page marked default become the only default page. |
| BR-07 | A widget shows exactly one active card or active app and fits into the 4 column grid. |
| BR-08 | Cards used by widgets cannot be deleted or deactivated; apps used by widgets or navigation cannot be deleted. |
| BR-09 | Content can be published only from draft and with a body; publication writes a feed entry. Tags must exist. |
| BR-10 | Knowledge base articles are published from review by someone other than the author; publication increments the version. |
| BR-11 | Survey questions are locked once active; choice questions need two options; one response per user unless allowed. |
| BR-12 | Events end after they start; all-day events span whole days; the status follows the clock. |
| BR-13 | Pending tasks past their due date become overdue; completed and cancelled tasks can be reopened. |
| BR-14 | Notifications go to users with a profile (once profiles exist) and are dismissed when they expire. |
| BR-15 | Sites need a visible navigation item to be published; published sites cannot be deleted; deletion removes navigation and plugin assignments. |
| BR-16 | Navigation entries nest only under group entries of the same site and never form cycles; group entries with children cannot be deleted. |
| BR-17 | One default theme and one default page template per tenant; predefined, default or used themes / templates cannot be deleted. |
| BR-18 | Permissions have the form `verb:object` (`*` allowed); roles used anywhere and predefined roles cannot be deleted. |
| BR-19 | Tags form a tree without cycles; tags with children or in use cannot be deleted. |
| BR-20 | One profile per user; profiles receive the default roles; e-mail must be valid. |
| BR-21 | Content providers need an http(s) endpoint and credentials for authenticated access; syncs require a connection. |
| BR-22 | URLs are http(s) or application relative; colours are hex; custom CSS contains no markup. |

---

## 8. Architecture Decisions

| # | Decision | Rationale |
|---|---|---|
| AD-01 | Hexagonal architecture with separate `ports`, `application`, `domain`, `persistence`, `infrastructure`, `presentation` layers | business rules are independent of protocols and storage; all four channels behave identically |
| AD-02 | Domain entities are plain structs; serialization through a compile-time reflection codec | no hand-written `toJson` per entity; one codec yields payloads, records, PATCH semantics and field metadata |
| AD-03 | One generic repository port (`findByName`, `findByWorkspace`, `findMatching`) | 24 aggregates without 24 repository implementations |
| AD-04 | Protocol-neutral `ResourceAdapter` registry | REST, OData `$metadata`, CLI and GUI are generated from the same definitions; the Fiori app reads the same catalogue |
| AD-05 | Flattened settings instead of nested objects; value object lists as complex type collections | 1:1 mapping to OData properties and Fiori forms |
| AD-06 | References to roles, groups and sites by name, all others by id; adapters resolve names to ids | readable CLI usage and payloads; ids stay stable |
| AD-07 | JSON snapshot files with revision based reload | server, CLI and GUI share data without a database; replaceable through `ISnapshotStorage` |
| AD-08 | Time driven transitions in an explicit housekeeping use case with an injectable clock | deterministic tests; same behaviour from worker, CLI, GUI and OData |
| AD-09 | Gateway and event publisher behind ports with simulated / log adapters | runnable without external systems; production adapters plug in without domain changes |
| AD-10 | Approuter + XSUAA in front; backend trusts forwarded tokens | standard SAP BTP security model; direct exposure requires signature validation (documented) |
| AD-11 | No `$batch`; UI5 model in `$direct` mode, writes via a small fetch client with CSRF handling | simpler server; predictable error handling per request |
