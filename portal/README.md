# UIM Cloud Portal Service

A microservice for enterprise portal site management, inspired by **SAP Fiori
Launchpad** and **SAP Build Work Zone**. Built with **D** and **vibe.d**,
following **Clean Architecture** and **Hexagonal Architecture** (Ports &
Adapters) principles.

Part of the [UIM Platform](https://www.....de/uim/sap) suite.

## Features

| Capability | Description |
|---|---|
| **Sites** | Multi-tenant portal sites with theming, URL aliases, publishing lifecycle (Draft → Published → Unpublished → Archived), and configurable settings (logo, favicon, footer, i18n) |
| **Pages** | Site pages with multiple layout modes (Freeform, Anchored, 2-Column, 3-Column, Dashboard), role-gated visibility, and sort ordering |
| **Sections** | Page sections that group tiles into configurable grid columns |
| **Tiles (App Launchers)** | 5 tile types (Static, Dynamic, Custom, News, KPI) with 6 app types (SAPUI5, WebDynpro, SAP GUI HTML, URL, Web Component, Native), configurable navigation targets, and dynamic KPI indicators |
| **Catalogs** | Content catalogs grouping tiles for administration, linked to content providers, with role-based access |
| **Content Providers** | Local, remote, and federated content sources with bearer-token authentication and sync tracking |
| **Roles** | Role-based access control scoped to sites, catalogs, groups, or pages, with user and group assignments |
| **Themes** | Theme definitions with color palettes (10 colors), font configuration, custom CSS, and 4 modes (Light, Dark, High Contrast, High Contrast Dark) — supporting base themes like SAP Fiori 3 and SAP Horizon |
| **Menu Items** | Hierarchical navigation menus with parent–child relationships, internal page links or external URLs, and role-gated visibility |
| **Translations (i18n)** | Generic translation entries for any resource field (site, page, tile, section, menu item) with ISO 639-1 language codes |
| **Content Resolver** | Domain service that resolves a full site tree (Site → Pages → Sections → Tiles + Menu Items) for rendering |
| **Site Publisher** | Domain service that validates publishing readiness (name, pages, non-archived status) |

## Architecture

```
portal/
├── source/
│   ├── app.d                              # Entry point & composition root
│   ├── domain/                            # Pure business logic (no dependencies)
│   │   ├── types.d                        #   Type aliases and enums
│   │   ├── entities/                      #   Core domain structs
│   │   │   ├── site.d                     #     Portal site + SiteSettings
│   │   │   ├── page.d                     #     Page within a site
│   │   │   ├── section.d                  #     Section within a page
│   │   │   ├── tile.d                     #     App launcher tile + TileConfiguration
│   │   │   ├── catalog.d                  #     Content catalog
│   │   │   ├── content_provider.d         #     Content provider (local/remote/federated)
│   │   │   ├── role.d                     #     Access role
│   │   │   ├── theme.d                    #     Theme + ThemeColors + ThemeFonts
│   │   │   ├── menu_item.d               #     Navigation menu item
│   │   │   └── translation.d             #     i18n translation entry
│   │   ├── ports/                         #   Repository interfaces (hexagonal boundary)
│   │   │   ├── site_repository.d
│   │   │   ├── page_repository.d
│   │   │   ├── section_repository.d
│   │   │   ├── tile_repository.d
│   │   │   ├── catalog_repository.d
│   │   │   ├── provider_repository.d
│   │   │   ├── role_repository.d
│   │   │   ├── theme_repository.d
│   │   │   ├── menu_item_repository.d
│   │   │   └── translation_repository.d
│   │   └── services/                      #   Stateless domain services
│   │       ├── content_resolver.d         #     Resolve full site tree
│   │       └── site_publisher.d           #     Validate publish readiness
│   ├── application/                       #   Use case orchestration
│   │   ├── dto.d                          #   Request/response DTOs
│   │   └── usecases/
│   │       ├── manage.sites.d
│   │       ├── manage.pages.d
│   │       ├── manage.sections.d
│   │       ├── manage.tiles.d
│   │       ├── manage.catalogs.d
│   │       ├── manage.providers.d
│   │       ├── manage.roles.d
│   │       ├── manage.themes.d
│   │       ├── manage.menu_items.d
│   │       └── manage.translations.d
│   ├── infrastructure/                    #   Technical adapters
│   │   ├── config.d                       #   Environment-based configuration
│   │   ├── container.d                    #   Manual dependency injection
│   │   └── persistence/                   #   In-memory repository implementations
│   │       ├── in_memory_site_repo.d
│   │       ├── in_memory_page_repo.d
│   │       ├── in_memory_section_repo.d
│   │       ├── in_memory_tile_repo.d
│   │       ├── in_memory_catalog_repo.d
│   │       ├── in_memory_provider_repo.d
│   │       ├── in_memory_role_repo.d
│   │       ├── in_memory_theme_repo.d
│   │       ├── in_memory_menu_item_repo.d
│   │       └── in_memory_translation_repo.d
│   └── presentation/                      #   HTTP driving adapters
│       └── http/
│           ├── json_utils.d               #   JSON helper functions
│           ├── health_controller.d
│           ├── site_controller.d
│           ├── page_controller.d
│           ├── section_controller.d
│           ├── tile_controller.d
│           ├── catalog_controller.d
│           ├── provider_controller.d
│           ├── role_controller.d
│           ├── theme_controller.d
│           ├── menu_item_controller.d
│           └── translation_controller.d
└── dub.sdl
```

## REST API

All endpoints require `X-Tenant-Id` header for multi-tenant isolation.

### Sites

```
POST   /api/v1/sites                     Create a site
GET    /api/v1/sites                     List sites for tenant
GET    /api/v1/sites/{id}               Get site by ID
PUT    /api/v1/sites/{id}               Update a site
DELETE /api/v1/sites/{id}               Delete a site
POST   /api/v1/sites/{id}/publish        Publish a site
```

### Pages

```
POST   /api/v1/pages                     Create a page
GET    /api/v1/pages                     List pages for tenant
GET    /api/v1/pages/{id}               Get page by ID
PUT    /api/v1/pages/{id}               Update a page
DELETE /api/v1/pages/{id}               Delete a page
```

### Sections

```
POST   /api/v1/sections                  Create a section
GET    /api/v1/sections                  List sections for tenant
GET    /api/v1/sections/{id}            Get section by ID
PUT    /api/v1/sections/{id}            Update a section
DELETE /api/v1/sections/{id}            Delete a section
```

### Tiles

```
POST   /api/v1/tiles                     Create a tile
GET    /api/v1/tiles                     List tiles for tenant
GET    /api/v1/tiles/{id}               Get tile by ID
PUT    /api/v1/tiles/{id}               Update a tile
DELETE /api/v1/tiles/{id}               Delete a tile
```

### Catalogs

```
POST   /api/v1/catalogs                  Create a catalog
GET    /api/v1/catalogs                  List catalogs for tenant
GET    /api/v1/catalogs/{id}            Get catalog by ID
PUT    /api/v1/catalogs/{id}            Update a catalog
DELETE /api/v1/catalogs/{id}            Delete a catalog
```

### Content Providers

```
POST   /api/v1/providers                 Create a content provider
GET    /api/v1/providers                 List providers for tenant
GET    /api/v1/providers/{id}           Get provider by ID
PUT    /api/v1/providers/{id}           Update a provider
DELETE /api/v1/providers/{id}           Delete a provider
```

### Roles

```
POST   /api/v1/roles                     Create a role
GET    /api/v1/roles                     List roles for tenant
GET    /api/v1/roles/{id}               Get role by ID
PUT    /api/v1/roles/{id}               Update a role
DELETE /api/v1/roles/{id}               Delete a role
```

### Themes

```
POST   /api/v1/themes                    Create a theme
GET    /api/v1/themes                    List themes for tenant
GET    /api/v1/themes/{id}              Get theme by ID
PUT    /api/v1/themes/{id}              Update a theme
DELETE /api/v1/themes/{id}              Delete a theme
```

### Menu Items

```
POST   /api/v1/menu-items                Create a menu item
GET    /api/v1/menu-items                List menu items for tenant
GET    /api/v1/menu-items/{id}          Get menu item by ID
PUT    /api/v1/menu-items/{id}          Update a menu item
DELETE /api/v1/menu-items/{id}          Delete a menu item
```

### Translations

```
POST   /api/v1/translations              Create a translation
GET    /api/v1/translations              List translations for tenant
GET    /api/v1/translations/{id}        Get translation by ID
PUT    /api/v1/translations/{id}        Update a translation
DELETE /api/v1/translations/{id}        Delete a translation
```

### Health

```
GET    /api/v1/health                    Service health check
```

## Build and Run

```bash
# Build
cd portal
dub build

# Run (default: 0.0.0.0:8083)
./build/cloud-portal

# Override host/port via environment
CPS_HOST=127.0.0.1 CPS_PORT=9090 ./build/cloud-portal
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `CPS_HOST` | `0.0.0.0` | Bind address |
| `CPS_PORT` | `8083` | Listen port |

## Domain Model

```
Site ──owns──▸ Page[] ──owns──▸ Section[] ──owns──▸ Tile[]
 │                                                     │
 ├──refs──▸ Theme                                      ├──belongs to──▸ Catalog
 ├──refs──▸ MenuItem[] (hierarchical)                  └──gated by──▸ Role[]
 └──gated by──▸ Role[]
                             Catalog ──sourced from──▸ ContentProvider
                             Translation ──i18n for──▸ any resource field
```

## Technology

- **Language:** D (dub package manager)
- **HTTP Framework:** vibe.d 0.10.x
- **Persistence:** In-memory (swappable via port interfaces)
- **Architecture:** Clean + Hexagonal (Ports & Adapters) + DDD

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
