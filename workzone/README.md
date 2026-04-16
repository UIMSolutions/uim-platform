# Work Zone Service

A D/vibe.d microservice implementing SAP Work Zone-like functionality for the UIM Platform. Provides collaborative digital workplace capabilities including workspaces, work pages, integration cards, content management, feeds, notifications, tasks, channels, app registrations, and widgets.

## Architecture

Clean/Hexagonal architecture with four layers:

```
┌─────────────────────────────────────────┐
│  Presentation (HTTP Controllers)        │
├─────────────────────────────────────────┤
│  Application (Use Cases, DTOs)          │
├─────────────────────────────────────────┤
│  Domain (Entities, Ports, Services)     │
├─────────────────────────────────────────┤
│  Infrastructure (Repos, Config, DI)     │
└─────────────────────────────────────────┘
```

- **Domain**: Workspaces, work pages, cards, content items, feed entries, notifications, tasks, channels, app registrations, widgets, sites, themes, roles, user profiles, navigation items, shell plugins, surveys, events, knowledge base articles, forum topics, tags, page templates, groups, external content providers
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Workspaces** — Create and manage collaborative digital workspaces
- **Work Pages** — Compose and manage work pages within workspaces
- **Integration Cards** — Manage UI5 integration card definitions for embedding business content
- **Content Management** — Manage knowledge base articles, documents, and other content items
- **Feeds** — Social feed entries within workspaces
- **Notifications** — Push and manage workspace notifications
- **Tasks** — Personal and workspace task management
- **Channels** — Manage communication channels for broadcasts and announcements
- **App Registrations** — Register and configure embedded business applications
- **Widgets** — Define and manage reusable UI widgets for work pages

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/workspaces` | Manage workspaces |
| CRUD | `/api/v1/workpages` | Manage work pages |
| CRUD | `/api/v1/cards` | Manage integration cards |
| CRUD | `/api/v1/content` | Manage content items |
| CRUD | `/api/v1/feeds` | Manage feed entries |
| CRUD | `/api/v1/notifications` | Manage notifications |
| CRUD | `/api/v1/tasks` | Manage tasks |
| CRUD | `/api/v1/channels` | Manage channels |
| CRUD | `/api/v1/apps` | Manage app registrations |
| CRUD | `/api/v1/widgets` | Manage widgets |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd workzone
dub run

# Run tests
dub test
```

The service starts on port **8084** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WZ_HOST` | `0.0.0.0` | Bind address |
| `WZ_PORT` | `8084` | Listen port |

## License

Apache-2.0
