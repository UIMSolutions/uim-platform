# Document Management Service

A D/vibe.d microservice implementing SAP Document Management Service (DMS)-like functionality for the UIM Platform. Provides repository management, folder hierarchies, document storage with versioning, sharing, permissions, and content browsing.

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

- **Domain**: Repositories, folders, documents, document versions, shares, permissions, favorites
- **Application**: Use cases orchestrating domain logic, request/response DTOs
- **Infrastructure**: In-memory repository adapters, environment-based configuration, dependency injection container
- **Presentation**: HTTP controllers with JSON serialization, health endpoint

## Features

- **Repositories** — Manage document repositories with configurable storage backends
- **Folders** — Hierarchical folder structures within repositories
- **Documents** — Upload, download, and manage documents with metadata
- **Versioning** — Document version history and version lifecycle management
- **Sharing** — Share documents and folders with internal and external users
- **Permissions** — Fine-grained access control for repositories, folders, and documents
- **Browse** — Navigate repository content with folder-level listing
- **Favorites** — Bookmark documents and folders for quick access

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/repositories` | Manage document repositories |
| CRUD | `/api/v1/folders` | Manage folders |
| CRUD | `/api/v1/documents` | Manage documents |
| CRUD | `/api/v1/versions` | Manage document versions |
| CRUD | `/api/v1/shares` | Manage document and folder shares |
| CRUD | `/api/v1/permissions` | Manage access permissions |
| GET | `/api/v1/browse/{folderId}` | Browse folder contents |
| GET | `/api/v1/health` | Health check |

## Running

```bash
# Build and run locally
cd dms-application
dub run

# Run tests
dub test
```

The service starts on port **8094** by default.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DMS_HOST` | `0.0.0.0` | Bind address |
| `DMS_PORT` | `8094` | Listen port |

## License

Apache-2.0
