# NAF v4 Architecture Description — UIM Cloud Portal Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Cloud Portal Service — enterprise portal site management with pages, tiles,
> catalogs, theming, navigation, roles, and i18n.

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
Cloud Portal
├── C1.1  Site Management
│   ├── C1.1.1  Site CRUD
│   │   ├── Create / update / delete portal sites
│   │   └── URL-friendly alias (slug) for each site
│   ├── C1.1.2  Site Settings
│   │   ├── Logo, favicon, footer, copyright text
│   │   ├── Default and supported languages (i18n)
│   │   └── Feature toggles (personalization, notifications, search, user actions)
│   ├── C1.1.3  Publishing Lifecycle
│   │   ├── Status: Draft → Published → Unpublished → Archived
│   │   └── Publish validation (name required, at least one page, non-archived)
│   └── C1.1.4  Theme Binding
│       └── Each site references a Theme for visual identity
│
├── C1.2  Page Management
│   ├── C1.2.1  Page CRUD
│   │   ├── Create / update / delete pages within a site
│   │   └── URL-friendly alias, sort ordering, visibility toggle
│   ├── C1.2.2  Layout Modes
│   │   └── Freeform, Anchored, 2-Column, 3-Column, Dashboard
│   └── C1.2.3  Role-Gated Visibility
│       └── Pages visible only to users with assigned roles
│
├── C1.3  Section & Tile Management
│   ├── C1.3.1  Section CRUD
│   │   ├── Sections within pages grouping tiles
│   │   └── Configurable grid columns (default 4)
│   ├── C1.3.2  Tile CRUD (App Launchers)
│   │   ├── 5 tile types: Static, Dynamic, Custom, News, KPI
│   │   ├── 6 app types: SAPUI5, WebDynpro, SAP GUI HTML, URL, Web Component, Native
│   │   ├── Navigation targets: In-Place, New Window, Embedded
│   │   └── KPI configuration (service URL, refresh interval, number unit, target, indicator color)
│   └── C1.3.3  Tile Configuration
│       └── Dynamic tiles with OData service binding and size behavior
│
├── C1.4  Content Administration
│   ├── C1.4.1  Catalog Management
│   │   ├── Group tiles into administrative catalogs
│   │   ├── Link catalogs to content providers
│   │   └── Role-based access to catalogs
│   └── C1.4.2  Content Provider Management
│       ├── Provider types: Local, Remote, Federated
│       ├── Bearer-token authentication for remote providers
│       └── Sync tracking (lastSyncedAt)
│
├── C1.5  Navigation
│   ├── C1.5.1  Menu Item Management
│   │   ├── Hierarchical menus (parent–child via parentId)
│   │   ├── Internal page links or external URLs
│   │   └── Role-gated visibility per menu item
│   └── C1.5.2  Content Resolver
│       └── Resolve full site tree: Site → Pages → Sections → Tiles + MenuItems
│
├── C1.6  Access Control
│   ├── C1.6.1  Role Management
│   │   ├── CRUD for portal access roles
│   │   └── Role scopes: Site, Catalog, Group, Page
│   └── C1.6.2  User & Group Assignment
│       └── Assign users and groups to roles
│
├── C1.7  Theming
│   ├── C1.7.1  Theme Management
│   │   ├── CRUD for theme definitions
│   │   └── Base themes: SAP Fiori 3, SAP Horizon, etc.
│   ├── C1.7.2  Color Palette (10 colors)
│   │   └── Primary, Secondary, Accent, Background, Shell, Text, Link, Header, Footer, Tile Background
│   ├── C1.7.3  Font Configuration
│   │   └── Font family, header font family, font sizes
│   ├── C1.7.4  Theme Modes
│   │   └── Light, Dark, High Contrast, High Contrast Dark
│   └── C1.7.5  Custom CSS
│       └── Tenant-provided CSS overrides
│
└── C1.8  Internationalization (i18n)
    ├── C1.8.1  Translation Management
    │   ├── CRUD for translation entries
    │   └── Generic: any resource type + field name + ISO 639-1 language code
    └── C1.8.2  Resource Coverage
        └── Translatable resources: Site, Page, Tile, Section, MenuItem
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a multi-tenant, role-gated enterprise portal with personalized content, theming, and navigation as a composable microservice. |
| **Vision** | Enable organizations to build SAP Fiori Launchpad-style portal experiences — managing sites, app launchers, catalogs, themes, and translations — modelled after SAP Build Work Zone. |
| **Scope** | All portal site definitions, page structures, tile configurations, navigation hierarchies, themes, roles, and translations within the UIM Platform. |
| **Stakeholders** | Portal Administrators, Content Managers, UX Designers, Application Developers, End Users. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Portal Service Offerings
├── SVC-SITE   Site Service
│   ├── SVC-SITE-CRUD    CRUD operations
│   └── SVC-SITE-PUB     Publish workflow
│
├── SVC-PAGE   Page Service
│   └── SVC-PAGE-CRUD    CRUD operations
│
├── SVC-SEC    Section Service
│   └── SVC-SEC-CRUD     CRUD operations
│
├── SVC-TILE   Tile Service
│   └── SVC-TILE-CRUD    CRUD operations
│
├── SVC-CAT    Catalog Service
│   └── SVC-CAT-CRUD     CRUD operations
│
├── SVC-PROV   Provider Service
│   └── SVC-PROV-CRUD    CRUD operations
│
├── SVC-ROLE   Role Service
│   └── SVC-ROLE-CRUD    CRUD operations
│
├── SVC-THM    Theme Service
│   └── SVC-THM-CRUD     CRUD operations
│
├── SVC-MENU   Menu Item Service
│   └── SVC-MENU-CRUD    CRUD operations
│
├── SVC-I18N   Translation Service
│   └── SVC-I18N-CRUD    CRUD operations
│
└── SVC-HLTH   Health Service
    └── SVC-HLTH-CHECK   Liveness probe
```

### NSOV-2 – Service Definitions

| Service ID | Name | Interface | Protocol | Path Prefix | Methods |
|---|---|---|---|---|---|
| SVC-SITE-CRUD | Site Management | REST/JSON | HTTP/1.1 | `/api/v1/sites` | GET, POST, PUT, DELETE |
| SVC-SITE-PUB | Site Publish | REST/JSON | HTTP/1.1 | `/api/v1/sites/{id}/publish` | POST |
| SVC-PAGE-CRUD | Page Management | REST/JSON | HTTP/1.1 | `/api/v1/pages` | GET, POST, PUT, DELETE |
| SVC-SEC-CRUD | Section Management | REST/JSON | HTTP/1.1 | `/api/v1/sections` | GET, POST, PUT, DELETE |
| SVC-TILE-CRUD | Tile Management | REST/JSON | HTTP/1.1 | `/api/v1/tiles` | GET, POST, PUT, DELETE |
| SVC-CAT-CRUD | Catalog Management | REST/JSON | HTTP/1.1 | `/api/v1/catalogs` | GET, POST, PUT, DELETE |
| SVC-PROV-CRUD | Provider Management | REST/JSON | HTTP/1.1 | `/api/v1/providers` | GET, POST, PUT, DELETE |
| SVC-ROLE-CRUD | Role Management | REST/JSON | HTTP/1.1 | `/api/v1/roles` | GET, POST, PUT, DELETE |
| SVC-THM-CRUD | Theme Management | REST/JSON | HTTP/1.1 | `/api/v1/themes` | GET, POST, PUT, DELETE |
| SVC-MENU-CRUD | Menu Item Management | REST/JSON | HTTP/1.1 | `/api/v1/menu-items` | GET, POST, PUT, DELETE |
| SVC-I18N-CRUD | Translation Management | REST/JSON | HTTP/1.1 | `/api/v1/translations` | GET, POST, PUT, DELETE |
| SVC-HLTH-CHECK | Health Check | REST/JSON | HTTP/1.1 | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
                                ┌─────────────────────────┐
                                │    API Gateway / LB      │
                                └────────────┬────────────┘
                                             │ HTTP :8083
                                             ▼
                  ┌──────────────────────────────────────────────────┐
                  │           Cloud Portal Service                    │
                  │                                                  │
                  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
                  │  │  Site    │  │   Page   │  │ Section  │      │
                  │  │Controller│  │Controller│  │Controller│      │
                  │  └────┬─────┘  └────┬─────┘  └────┬─────┘      │
                  │  ┌────┴────┐  ┌─────┴────┐  ┌─────┴────┐      │
                  │  │  Tile   │  │ Catalog  │  │ Provider │      │
                  │  │Controller│  │Controller│  │Controller│      │
                  │  └────┬────┘  └────┬─────┘  └────┬─────┘      │
                  │  ┌────┴────┐  ┌────┴─────┐  ┌────┴─────┐      │
                  │  │  Role   │  │  Theme   │  │ MenuItem │      │
                  │  │Controller│  │Controller│  │Controller│      │
                  │  └────┬────┘  └────┬─────┘  └────┬─────┘      │
                  │       │      ┌─────┴─────┐       │              │
                  │       │      │Translation│       │              │
                  │       │      │Controller │       │              │
                  │       │      └─────┬─────┘       │              │
                  │       │            │             │              │
                  │  ┌────▼────────────▼─────────────▼──────┐      │
                  │  │         Use Case Layer                │      │
                  │  │  10 use case classes orchestrating    │      │
                  │  │  domain logic & repository access     │      │
                  │  └────────────────┬─────────────────────┘      │
                  │                   │                              │
                  │  ┌────────────────▼───────────────────────┐     │
                  │  │         Domain Services                │     │
                  │  │  ContentResolver (site tree expansion) │     │
                  │  │  SitePublisher (publish validation)    │     │
                  │  └────────────────┬───────────────────────┘     │
                  │                   │                              │
                  │  ┌────────────────▼───────────────────────┐     │
                  │  │     In-Memory Repository Adapters       │     │
                  │  │ (10 repositories, swappable via ports)  │     │
                  │  └─────────────────────────────────────────┘     │
                  └──────────────────────────────────────────────────┘
                                             │
                             ┌───────────────┼───────────────┐
                             ▼               ▼               ▼
                     ┌──────────┐   ┌──────────────┐  ┌────────────┐
                     │ Audit Log│   │  Identity &   │  │ Analytics  │
                     │ Service  │   │  Directory    │  │  Service   │
                     └──────────┘   └──────────────┘  └────────────┘
```

**Operational Information Exchanges:**

| Exchange | From | To | Content | Frequency |
|---|---|---|---|---|
| OIE-1 | Portal Admin | Portal Service | Site/page/tile definitions | On demand |
| OIE-2 | Content Manager | Portal Service | Catalog & provider configuration | On demand |
| OIE-3 | UX Designer | Portal Service | Theme definitions & custom CSS | On demand |
| OIE-4 | Portal Service | Identity & Directory | Role membership resolution | Per request |
| OIE-5 | Portal Service | Audit Log Service | Portal operations audit trail | Per operation |
| OIE-6 | End User (via gateway) | Portal Service | Resolved site tree request | On demand |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

```
┌──────────────────────────────────────────────────────────────────┐
│  Site Domain                                                      │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  Site             │──1:N──│  Page                 │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: SiteId        │       │ id: PageId            │            │
│  │ tenantId          │       │ siteId: SiteId        │            │
│  │ name, description │       │ tenantId              │            │
│  │ alias_ : string   │       │ title, description    │            │
│  │ status: SiteStatus│       │ alias_ : string       │            │
│  │ themeId: ThemeId  │       │ layout: PageLayout    │            │
│  │ settings          │       │ sectionIds: SectionId[]│           │
│  │ pageIds: PageId[] │       │ allowedRoleIds        │            │
│  │ menuItemIds       │       │ sortOrder, visible    │            │
│  │ allowedRoleIds    │       └──────────────────────┘            │
│  └──────────────────┘                                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Content Domain                                                   │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  Section          │──1:N──│  Tile                 │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: SectionId     │       │ id: TileId            │            │
│  │ pageId: PageId    │       │ tenantId              │            │
│  │ tenantId          │       │ catalogId: CatalogId  │            │
│  │ title             │       │ title, subtitle       │            │
│  │ tileIds: TileId[] │       │ tileType: TileType    │            │
│  │ sortOrder, visible│       │ appType: AppType      │            │
│  │ columns: int      │       │ url, appId            │            │
│  └──────────────────┘       │ navigationTarget      │            │
│                              │ config: TileConfig    │            │
│                              │ allowedRoleIds        │            │
│                              └──────────────────────┘            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Catalog Domain                                                   │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  Catalog          │──N:1──│  ContentProvider      │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: CatalogId     │       │ id: ProviderId        │            │
│  │ tenantId          │       │ tenantId              │            │
│  │ title, description│       │ name, description     │            │
│  │ providerId        │       │ providerType          │            │
│  │ tileIds: TileId[] │       │ contentEndpointUrl    │            │
│  │ allowedRoleIds    │       │ authToken             │            │
│  │ active: bool      │       │ catalogIds            │            │
│  └──────────────────┘       │ active, lastSyncedAt  │            │
│                              └──────────────────────┘            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Navigation Domain                                                │
│                                                                   │
│  ┌──────────────────────────┐                                    │
│  │  MenuItem                 │                                    │
│  ├──────────────────────────┤                                    │
│  │ id: MenuItemId            │                                    │
│  │ siteId: SiteId            │                                    │
│  │ tenantId                  │                                    │
│  │ title, icon               │                                    │
│  │ parentId: MenuItemId      │  (self-referencing hierarchy)     │
│  │ targetPageId: PageId      │                                    │
│  │ targetUrl: string         │                                    │
│  │ navigationTarget          │                                    │
│  │ allowedRoleIds            │                                    │
│  │ sortOrder, visible        │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Access Control Domain                                            │
│                                                                   │
│  ┌──────────────────────────┐                                    │
│  │  Role                     │                                    │
│  ├──────────────────────────┤                                    │
│  │ id: RoleId                │                                    │
│  │ tenantId                  │                                    │
│  │ name, description         │                                    │
│  │ scope_: RoleScope         │  (site / catalog / group / page)  │
│  │ userIds: string[]         │                                    │
│  │ groupIds: string[]        │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Theming Domain                                                   │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  Theme            │──1:1──│  ThemeColors          │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: ThemeId       │       │ primaryColor          │            │
│  │ tenantId          │       │ secondaryColor        │            │
│  │ name, description │       │ accentColor           │            │
│  │ mode: ThemeMode   │       │ backgroundColor       │            │
│  │ baseTheme: string │       │ shellColor            │            │
│  │ customCss: string │       │ textColor, linkColor  │            │
│  │ isDefault: bool   │       │ headerColor           │            │
│  └──────────────────┘       │ footerColor           │            │
│          │                   │ tileBackgroundColor   │            │
│          │                   └──────────────────────┘            │
│          │               ┌──────────────────────┐                │
│          └───────1:1─────│  ThemeFonts           │                │
│                          ├──────────────────────┤                │
│                          │ fontFamily            │                │
│                          │ headerFontFamily      │                │
│                          │ fontSize              │                │
│                          │ headerFontSize        │                │
│                          └──────────────────────┘                │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Internationalization Domain                                      │
│                                                                   │
│  ┌──────────────────────────┐                                    │
│  │  Translation              │                                    │
│  ├──────────────────────────┤                                    │
│  │ id: TranslationId         │                                    │
│  │ tenantId                  │                                    │
│  │ resourceType: string      │  ("site", "page", "tile", ...)   │
│  │ resourceId: string        │                                    │
│  │ fieldName: string         │  ("title", "description", ...)   │
│  │ language: string          │  (ISO 639-1: "de", "fr", ...)    │
│  │ value: string             │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘
```

**Key Enumerations:**

| Enum | Values |
|---|---|
| SiteStatus | draft, published, unpublished, archived |
| PageLayout | freeform, anchored, twoColumn, threeColumn, dashboard |
| TileType | static_, dynamic, custom, news, kpi |
| AppType | sapui5, webDynpro, sapGuiHtml, url, webComponent, native_ |
| ProviderType | local, remote, federated |
| ThemeMode | light, dark, highContrast, highContrastDark |
| NavigationTarget | inPlace, newWindow, embedded |
| TransportStatus | pending, inProgress, completed, failed |
| RoleScope | site, catalog, group, page |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
┌─────────────────────────────────────────────────────────────┐
│  Deployment Node: Application Server                         │
│  OS: Linux                                                   │
│  Runtime: Native D binary (compiled with dub + DMD/LDC)     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Artifact: cloud-portal (executable)                │     │
│  │  Source:   portal/source/**/*.d                     │     │
│  │  Binary:   portal/build/cloud-portal                │     │
│  │  Port:     8083 (configurable CPS_PORT)             │     │
│  │  Protocol: HTTP/1.1 (vibe.d event loop)             │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Environment Variables:                                      │
│  ┌──────────┬──────────┬────────────────────────────┐      │
│  │ Name     │ Default  │ Description                 │      │
│  ├──────────┼──────────┼────────────────────────────┤      │
│  │ CPS_HOST │ 0.0.0.0  │ HTTP bind address           │      │
│  │ CPS_PORT │ 8083     │ HTTP listen port            │      │
│  └──────────┴──────────┴────────────────────────────┘      │
│                                                              │
│  Dependencies:                                               │
│  ┌────────────────────────────┬──────────┐                  │
│  │ Package                    │ Version  │                  │
│  ├────────────────────────────┼──────────┤                  │
│  │ vibe-d                     │ ~>0.10.1 │                  │
│  │ vibe-d:crypto              │ ~>0.10.1 │                  │
│  └────────────────────────────┴──────────┘                  │
│                                                              │
│  Persistence: In-memory (ephemeral)                          │
│  Scaling: Stateless - horizontally scalable with external    │
│           persistence adapter                                │
└─────────────────────────────────────────────────────────────┘
```

**Deployment Constraints:**

| Constraint | Description |
|---|---|
| DC-1 | Single-process, multi-threaded via vibe.d fibers |
| DC-2 | In-memory persistence is non-durable; data is lost on restart |
| DC-3 | Swapping to durable persistence requires implementing port interfaces (10 repositories) |
| DC-4 | X-Tenant-Id header required for multi-tenant data isolation |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

**Information Flows:**

| Flow ID | Source | Target | Data | Format | Trigger |
|---|---|---|---|---|---|
| IF-1 | Portal Admin | SiteController | Site definition + settings | JSON | User action |
| IF-2 | Portal Admin | PageController | Page definition + layout | JSON | User action |
| IF-3 | Portal Admin | SectionController | Section definition + columns | JSON | User action |
| IF-4 | Portal Admin | TileController | Tile + TileConfiguration | JSON | User action |
| IF-5 | Content Manager | CatalogController | Catalog definition | JSON | User action |
| IF-6 | Content Manager | ProviderController | Provider config + auth token | JSON | User action |
| IF-7 | Portal Admin | RoleController | Role definition + user/group IDs | JSON | User action |
| IF-8 | UX Designer | ThemeController | Theme + colors + fonts + CSS | JSON | User action |
| IF-9 | Portal Admin | MenuItemController | Menu item hierarchy | JSON | User action |
| IF-10 | Translator | TranslationController | Translation entry (resource + lang) | JSON | User action |
| IF-11 | SitePublisher | SiteController | Publish validation result | Internal | Publish action |
| IF-12 | ContentResolver | Client | Resolved site tree (Site + Pages + Sections + Tiles + MenuItems) | JSON | Render request |

**Data Sensitivity:**

| Data Element | Classification | Handling |
|---|---|---|
| Auth tokens (content providers) | Secret | Tenant-isolated, encrypted at rest in production |
| Role assignments (userIds, groupIds) | Internal | Tenant-isolated, no cross-tenant access |
| Site definitions & content | Business configuration | Tenant-scoped |
| Theme custom CSS | Low sensitivity | Tenant-scoped, sanitized before rendering |
| Translations | Business content | Tenant-scoped |

---

## 8. Traceability Matrix

| Capability | Service(s) | Entity/ies | Controller | Use Case |
|---|---|---|---|---|
| C1.1 Site Management | SVC-SITE-* | Site, SiteSettings | SiteController | ManageSitesUseCase |
| C1.2 Page Management | SVC-PAGE-* | Page | PageController | ManagePagesUseCase |
| C1.3 Section & Tile | SVC-SEC-*, SVC-TILE-* | Section, Tile, TileConfiguration | SectionController, TileController | ManageSectionsUseCase, ManageTilesUseCase |
| C1.4 Content Admin | SVC-CAT-*, SVC-PROV-* | Catalog, ContentProvider | CatalogController, ProviderController | ManageCatalogsUseCase, ManageProvidersUseCase |
| C1.5 Navigation | SVC-MENU-* | MenuItem | MenuItemController | ManageMenuItemsUseCase |
| C1.6 Access Control | SVC-ROLE-* | Role | RoleController | ManageRolesUseCase |
| C1.7 Theming | SVC-THM-* | Theme, ThemeColors, ThemeFonts | ThemeController | ManageThemesUseCase |
| C1.8 i18n | SVC-I18N-* | Translation | TranslationController | ManageTranslationsUseCase |
