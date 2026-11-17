# UML — Work Zone Service

Diagrams of the Work Zone service (backend `uim.platform.workzone`, Fiori app
`uim.workzone`, approuter). All diagrams use Mermaid.

## Class Diagram — Domain Entities

Every aggregate mixes in `TenantEntity!(Id)` (`tenantId`, `id`, `createdBy`,
`createdAt`, `updatedBy`, `updatedAt`). References to roles, groups and sites are
kept by name; all other references are typed ids.

```mermaid
classDiagram
  direction LR

  class Workspace {
    name, alias, description
    WorkspaceType type
    WorkspaceStatus status
    defaultLanguage, imageUrl
    allowExternalMembers
    enableNotifications, enableFeeds
    enableWiki, enableKnowledgeBase, enableForum
    WorkspaceMember[] members
  }
  class WorkspaceMember {
    userId, displayName
    MemberRole role
    long joinedAt
  }
  class Workpage {
    WorkspaceId workspaceId
    title, description
    PageTemplateId templateId
    sortOrder, visible, isDefault
    string[] allowedRoles
  }
  class PageWidget {
    WorkpageId workpageId
    WorkspaceId workspaceId
    title, CardId cardId, AppId appId
    WidgetSize size, row, col
    maxItems, refreshIntervalSec
    KeyValue[] parameters
  }
  class WorkspaceChannel {
    WorkspaceId workspaceId
    name, ChannelType channelType
    sourceUrl, pollIntervalSec
    authType, authToken, active
  }
  class ContentItem {
    WorkspaceId workspaceId
    title, body, summary
    ContentType contentType
    ContentStatus status
    UserId authorId, tags
    likeCount, pinned, publishedAt
  }
  class FeedEntry {
    WorkspaceId workspaceId
    UserId actorId, action
    objectType, objectId, objectTitle
    message
  }
  class CalendarEvent {
    WorkspaceId workspaceId
    title, location, meetingUrl
    EventStatus status, allDay
    startsAt, endsAt, attendeeIds
  }
  class Survey {
    WorkspaceId workspaceId
    title, SurveyStatus status
    SurveyQuestion[] questions
    anonymous, allowMultipleResponses
    responseCount, respondents
    startsAt, endsAt
  }
  class SurveyQuestion {
    questionId, text
    QuestionType questionType
    options, required, sortOrder
  }
  class ForumTopic {
    WorkspaceId workspaceId
    title, body, ForumTopicStatus status
    replyCount, pinned, locked, lastReplyAt
  }
  class KnowledgeBaseArticle {
    WorkspaceId workspaceId
    title, body, category
    KBArticleStatus status
    int version, helpfulCount, publishedAt
    relatedArticleIds
  }
  class WorkTask {
    UserId assigneeId, title
    TaskStatus status, TaskPriority priority
    sourceApp, actionUrl, dueAt, completedAt
  }
  class Notification {
    UserId recipientId, title, body
    NotificationPriority priority
    NotificationStatus status
    readAt, expiresAt
  }
  class Card {
    title, CardType cardType, active
    dataSourceUrl, dataSourceMethod
    authType, authToken
    manifestType, headerTitle, maxItems
  }
  class AppRegistration {
    name, launchUrl, vendor, version
    AppStatus status
    AppPlatform[] supportedPlatforms
    authType, enableSso, componentId
  }
  class ExternalContentProvider {
    name, ProviderType providerType
    ProviderStatus status, endpointUrl
    authType, authConfig
    refreshIntervalSec, lastSyncAt, itemCount
  }
  class ShellPlugin {
    name, version, scriptUrl
    PluginStatus status
    string[] assignedSites
    HookPoint[] hookPoints
  }
  class Site {
    name, alias, SiteStatus status
    ThemeId themeId, allowedRoles
    logoUrl, defaultLanguage, publishedAt
  }
  class NavigationItem {
    SiteId siteId, title
    NavigationItemType itemType
    targetUrl, AppId targetAppId
    WorkpageId targetWorkpageId
    NavigationItemId parentId, sortOrder
  }
  class Theme {
    name, BaseTheme baseTheme
    primaryColor … accentColor
    customCss, isDefault, predefined
  }
  class PageTemplate {
    name, TemplateSection[] sections
    isDefault, isPublic, predefined
  }
  class TemplateSection {
    sectionId, title, columns
    layoutType, WidgetSize[] allowedWidgetSizes
  }
  class Role {
    name, string[] permissions
    isDefault, predefined
  }
  class UserGroup {
    name, GroupType groupType
    string[] memberIds, string[] roles
  }
  class Tag {
    name, color, parentTag
  }
  class UserProfile {
    UserId userId, displayName, email
    department, string[] roles, string[] groups
    active, lastLoginAt
  }

  Workspace "1" *-- "*" WorkspaceMember
  Workspace "1" o-- "*" Workpage
  Workspace "1" o-- "*" WorkspaceChannel
  Workspace "1" o-- "*" ContentItem
  Workspace "1" o-- "*" FeedEntry
  Workspace "1" o-- "*" CalendarEvent
  Workspace "1" o-- "*" Survey
  Workspace "1" o-- "*" ForumTopic
  Workspace "1" o-- "*" KnowledgeBaseArticle
  Workpage "1" o-- "*" PageWidget
  Workpage "*" --> "0..1" PageTemplate : templateId
  PageWidget "*" --> "0..1" Card : cardId
  PageWidget "*" --> "0..1" AppRegistration : appId
  Survey "1" *-- "*" SurveyQuestion
  PageTemplate "1" *-- "*" TemplateSection
  Site "1" o-- "*" NavigationItem
  Site "*" --> "0..1" Theme : themeId
  NavigationItem "*" --> "0..1" NavigationItem : parentId
  NavigationItem "*" --> "0..1" AppRegistration : targetAppId
  NavigationItem "*" --> "0..1" Workpage : targetWorkpageId
  ShellPlugin "*" ..> "*" Site : assignedSites (names)
  UserGroup "*" ..> "*" Role : roles (names)
  UserProfile "*" ..> "*" Role : roles (names)
  UserProfile "*" ..> "*" UserGroup : groups (names)
  Tag "*" ..> "0..1" Tag : parentTag
  ContentItem "*" ..> "*" Tag : tags (names)
```

`o--` marks containment with cascading deletion (workspace → content, workpage →
widgets, site → navigation). `..>` marks references by name.

## State Diagram — Lifecycles

Transitions are triggered by actions (REST `POST /<resource>/<id>/<action>`, OData
`<Action><Type>`, CLI, GUI). Transitions marked *(housekeeping)* happen on their own
when time passes.

```mermaid
stateDiagram-v2
  state "Workspace" as WS {
    [*] --> active
    active --> archived : archive
    active --> suspended : suspend
    archived --> active : restore
    suspended --> active : restore
  }
  state "Content item" as CI {
    [*] --> draft
    draft --> published : publish (body required → feed entry)
    draft --> ciArchived : archive
    published --> ciArchived : archive
  }
  state "Knowledge base article" as KB {
    [*] --> kbDraft
    kbDraft --> review : submit
    review --> kbPublished : publish (reviewer ≠ author, version + 1)
    kbPublished --> kbDraft : update
    kbDraft --> kbArchived : archive
    review --> kbArchived : archive
    kbPublished --> kbArchived : archive
  }
  state "Task" as T {
    [*] --> open
    open --> inProgress : start
    open --> overdue : dueAt passed (housekeeping)
    inProgress --> overdue : dueAt passed (housekeeping)
    overdue --> overdue : start
    open --> completed : complete
    inProgress --> completed : complete
    overdue --> completed : complete
    open --> cancelled : cancel
    inProgress --> cancelled : cancel
    completed --> open : reopen
    cancelled --> open : reopen
  }
  state "Survey" as S {
    [*] --> sDraft
    sDraft --> sActive : activate (valid questions)
    sActive --> closed : close / endsAt passed (housekeeping)
    closed --> sArchived : archive
    sDraft --> sArchived : archive
  }
  state "Calendar event" as E {
    [*] --> scheduled
    scheduled --> ongoing : startsAt (housekeeping)
    ongoing --> eCompleted : endsAt (housekeeping)
    scheduled --> eCancelled : cancel
    ongoing --> eCancelled : cancel
  }
  state "Site" as SI {
    [*] --> siDraft
    siDraft --> siPublished : publish (≥ 1 visible navigation item)
    siPublished --> maintenance : start-maintenance
    maintenance --> siPublished : publish
    siPublished --> siDraft : unpublish
    maintenance --> siDraft : unpublish
    siDraft --> siArchived : archive
    siPublished --> siArchived : archive
  }
  state "Content provider" as P {
    [*] --> disconnected
    disconnected --> connected : connect (gateway ok)
    disconnected --> error : connect (gateway failed)
    error --> connected : connect
    connected --> connected : sync / refresh interval (housekeeping)
    connected --> error : sync failed
    connected --> disconnected : disconnect / endpoint changed
  }
```

Notifications: `unread` (or `actionRequired` for critical ones) → `read` ⇄ `unread` → `dismissed` (dismiss, or when `expiresAt` passes during housekeeping).

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
  subgraph Driving["Driving adapters (presentation)"]
    REST["http: WorkzoneRestController<br/>/api/v1"]
    OD["odata: WorkzoneODataController<br/>$metadata · query · actions"]
    CLI["cli: WorkzoneCli"]
    GUI["gui: WorkzoneWindow (GtkD)"]
    WEB["web: FrontendController"]
    REG["resources: ResourceRegistry<br/>ResourceAdapter × 24"]
  end
  subgraph Ports["ports"]
    DP["WorkzonePorts<br/>IManage*UseCase · IHousekeepingUseCase<br/>IWorkzoneStatisticsService · IWorkzoneSeedService"]
    RP["IWorkzoneRepository!(E, Id)<br/>WorkzoneRepositories"]
    SP["ISnapshotStorage"]
    MP["IWorkzoneEventPublisher"]
    GP["IContentProviderGateway"]
  end
  subgraph App["application"]
    UC["usecases: ResourceUseCase → Manage*UseCase<br/>HousekeepingUseCase"]
    AS["services: CascadeDeleter · FeedRecorder<br/>WorkzoneSeedService · WorkzoneStatisticsService"]
    DTO["dtos: *Spec · Create/Update requests<br/>WorkzoneStatistics · reports"]
  end
  subgraph Dom["domain"]
    ENT["entities (24 aggregates)"]
    DS["services: membership · names · schedule<br/>navigation · scoping"]
    EX["exceptions: Validation 422 · NotFound 404 · Conflict 409"]
  end
  subgraph Driven["driven adapters"]
    PER["persistence: WorkzoneRepository<br/>SnapshotTenantStore · RecordMapper"]
    STO["storages: JsonFileSnapshotStorage<br/>MemorySnapshotStorage"]
    CLT["infrastructure/clients:<br/>SimulatedContentProviderGateway"]
    LOG["infrastructure/logging:<br/>LogEventPublisher"]
  end
  INF["infrastructure: Container · WorkzoneConfig<br/>identity (XSUAA) · HousekeepingWorker"]

  REST --> REG
  OD --> REG
  CLI --> REG
  GUI --> REG
  REG --> DP
  DP -.implemented by.-> UC
  DP -.implemented by.-> AS
  UC --> RP
  UC --> MP
  UC --> GP
  UC --> DS
  AS --> RP
  DS --> ENT
  RP -.implemented by.-> PER
  PER --> SP
  SP -.implemented by.-> STO
  GP -.implemented by.-> CLT
  MP -.implemented by.-> LOG
  INF --> DP
  INF --> PER
```

## Class Diagram — Generic use cases and adapters

```mermaid
classDiagram
  class IManageResource~E, Id, C, U~ {
    <<interface>>
    +create(C) UsecaseResult
    +update(U) UsecaseResult
    +remove(TenantId, Id, UserId) UsecaseResult
    +get(TenantId, Id) E
    +list(TenantId) E[]
  }
  class ResourceUseCase~E, Id, C, U~ {
    <<abstract>>
    #WorkzoneRepositories repos
    #IWorkzoneRepository repo
    #build(C)* E
    #apply(ref E, Spec)*
    #beforeRemove(E)
    #afterCreate(E, UserId)
    #afterRemove(E)
    #transition(tenant, id, actor, verb, change)
    #requireWorkspace(tenant, id, what)
    #ensureUnique(existing, candidate)
    #ensureUniqueInWorkspace(candidate, name)
  }
  class ManageWorkspacesUseCase {
    +addMember() +removeMember() +changeRole()
    +archive() +suspend() +restore()
  }
  class ManageContentUseCase {
    +publish() +archive() +pin() +unpin() +like()
  }
  class ManageKnowledgeBaseUseCase {
    +submit() +publish() +archive() +markHelpful()
  }
  class IWorkzoneRepository~E, Id~ {
    <<interface>>
    +findByName(TenantId, string) E
    +findByWorkspace(TenantId, WorkspaceId) E[]
    +findMatching(TenantId, spec) E[]
  }
  class WorkzoneRepository~E, Id~
  class SnapshotTenantStore~E, Id, Mapper~ {
    +refresh()
    +persist()
  }
  class IResourceAdapter {
    <<interface>>
    +path() setName() typeName()
    +fields() inputFields() recordTypes()
    +columns() actions()
    +list() get() create() update() remove() invoke()
  }
  class ResourceAdapter~E, Id, C, U~ {
    +column(header, field)
    +action(name, label, handler, params)
    +secret(field)
  }
  class ResourceRegistry {
    +adapters() byPath() bySet() byODataAction()
    +resolve(adapter, tenant, idOrName)
    +withReferences(tenant, body)
    +statistics() housekeeping() seed()
  }

  IManageResource <|.. ResourceUseCase
  ResourceUseCase <|-- ManageWorkspacesUseCase
  ResourceUseCase <|-- ManageContentUseCase
  ResourceUseCase <|-- ManageKnowledgeBaseUseCase
  ResourceUseCase --> IWorkzoneRepository
  IWorkzoneRepository <|.. WorkzoneRepository
  WorkzoneRepository --> SnapshotTenantStore : ITenantStore
  IResourceAdapter <|.. ResourceAdapter
  ResourceAdapter --> IManageResource
  ResourceRegistry o-- "24" IResourceAdapter
```

The remaining 21 interactors follow the same pattern. The codec
(`helpers/codec.d`) encodes entities to payloads and records, and decodes payloads
into specs: a PATCH decodes the patch on top of the spec of the current entity.
`describe!T` generates the field metadata for OData `$metadata`, CLI `fields` and
the GUI and Fiori forms.

## Sequence Diagram — Fiori publishes content

```mermaid
sequenceDiagram
  actor U as User (browser)
  participant AR as Approuter
  participant OD as WorkzoneODataController
  participant RG as ResourceRegistry / ResourceAdapter
  participant UC as ManageContentUseCase
  participant FR as FeedRecorder
  participant R as Repositories (snapshot store)

  U->>AR: POST /odata/v4/workzone/PublishContentItem {"id": "c1"} (CSRF token)
  AR->>AR: XSUAA login, scope WorkzoneContributor
  AR->>OD: forward + Authorization: Bearer JWT
  OD->>OD: resolveIdentity (zid → tenant, user_name → user)
  OD->>RG: byODataAction("PublishContentItem") → invoke(who, "c1", "publish")
  RG->>UC: publish(tenant, ContentId("c1"), user)
  UC->>R: content.findById → draft
  UC->>R: workspaces.findById → ensureAcceptsContent
  UC->>UC: status = published, publishedAt = now
  UC->>R: content.update (snapshot file written)
  UC->>FR: record(workspace, user, "published", ...)
  FR->>R: feedEntries.save (if enableFeeds)
  UC-->>RG: UsecaseResult(ok)
  RG-->>OD: payload (ISO timestamps, enums by name)
  OD-->>U: 200 {"@odata.context": "$metadata#ContentItems/$entity", ...}
  U->>OD: GET /Statistics (KPI header refresh)
```

## Sequence Diagram — Housekeeping

```mermaid
sequenceDiagram
  participant W as HousekeepingWorker (vibe.d timer, 30 s)
  participant H as HousekeepingUseCase
  participant D as domain.schedule
  participant R as Repositories
  participant G as IContentProviderGateway

  W->>H: run(tenant)
  loop tasks, events, surveys, notifications
    H->>R: findByTenant
    H->>D: isOverdue / eventStatusAt / isExpired
    alt transition due
      H->>R: update (overdue, ongoing/completed, closed, dismissed)
    end
  end
  loop content providers
    H->>D: isDueForSync(provider, now)
    alt refresh interval elapsed
      H->>G: sync(provider)
      G-->>H: ProviderOutcome(itemCount | error)
      H->>R: update (lastSyncAt, itemCount / error)
    end
  end
  H-->>W: HousekeepingReport(examined, changed, changes)
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
  actor A as Administrator
  participant C as uim-workzone-cli
  participant F as data/*.json (JsonFileSnapshotStorage)
  participant S as uim-workzone-platform-service

  A->>C: workspaces create --name="Sales EMEA"
  C->>F: write workspaces.json.tmp → rename (atomic)
  A->>S: GET /api/v1/workspaces
  S->>F: revision changed? (mtime)
  F-->>S: reload snapshot
  S-->>A: Sales EMEA
```

## Deployment Diagram — SAP BTP (Cloud Foundry) and containers

```mermaid
flowchart TB
  subgraph Browser
    UI["Fiori 3 app uim.workzone<br/>(UI5 1.120 from ui5.sap.com)"]
  end
  subgraph CF["SAP BTP — Cloud Foundry space (mta.yaml)"]
    APR["workzone-approuter<br/>@sap/approuter + resources/ (frontend)"]
    SRV["workzone-srv<br/>binary_buildpack<br/>uim-workzone-platform-service"]
    XS[("workzone-xsuaa<br/>xsuaa / application")]
    CFG[("workzone-config<br/>user-provided service")]
  end
  subgraph K8s["Container runtime (Dockerfile)"]
    POD["uim-platform/workzone<br/>server + CLI · port 8084"]
    VOL[("/data volume<br/>JSON snapshots")]
  end

  UI -->|HTTPS| APR
  APR -->|destination workzone-srv<br/>forwardAuthToken| SRV
  APR --- XS
  SRV --- XS
  SRV ---|VCAP_SERVICES| CFG
  POD --- VOL
```
