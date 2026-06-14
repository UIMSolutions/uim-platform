# DMS Integration Platform Service

SAP Document Management Service — Integration Option implementation using D/vibe.d with clean hexagonal architecture.

## Overview

The **DMS Integration Platform Service** (`uim-dms-integration-platform-service`) implements the capabilities of the **SAP Document Management Service, integration option** on SAP BTP. It provides a CMIS-compliant document management backbone that supports multiple repository types (managed, external, Google Workspace, OpenText, SharePoint, S/4HANA DMS), full document lifecycle management, folder hierarchies, document versioning, and fine-grained permission control.

## Features

- **Repository Management** — Create and manage document repositories; supports managed and external repository types; activation/deactivation lifecycle; default repository selection
- **Document Management** — Full CRUD with checkout/checkin/cancelCheckout lifecycle; document publish and archive workflows; move between folders; full-text search by name
- **Folder Hierarchy** — Nested folder trees with root/standard/system/virtual/archive types; move folders; depth and path tracking
- **Document Versioning** — Automatic major/minor version creation on checkin; version label tracking; protect latest versions from deletion
- **Permission Management** — Grant/revoke permissions per document or folder; principal types: user, group, everyone; permission types: read, write, delete, readWrite, full; inherited vs direct permissions

## Architecture

The service follows **hexagonal (ports & adapters) architecture** with four layers:

```
presentation/       HTTP controllers (vibe.d URLRouter)
application/        Use cases + DTOs
domain/             Entities, value objects, repository interfaces, domain services
infrastructure/     In-memory repository implementations, DI container, config
```

## API Endpoints

### Repositories

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/dms-integration/repositories` | List all repositories |
| POST | `/api/v1/dms-integration/repositories` | Create a repository |
| GET | `/api/v1/dms-integration/repositories/:id` | Get repository by ID |
| PUT | `/api/v1/dms-integration/repositories/:id` | Update / activate / deactivate |
| DELETE | `/api/v1/dms-integration/repositories/:id` | Delete a repository |

**PUT actions** (via `action` field): `activate`, `deactivate`

### Documents

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/dms-integration/documents` | List documents (query: `search`, `folderId`, `status=checkedOut`) |
| POST | `/api/v1/dms-integration/documents` | Upload / create a document |
| GET | `/api/v1/dms-integration/documents/:id` | Get document by ID |
| PUT | `/api/v1/dms-integration/documents/:id` | Update / lifecycle action |
| DELETE | `/api/v1/dms-integration/documents/:id` | Delete a document |

**PUT actions**: `checkout`, `checkin`, `cancelCheckout`, `move`, `publish`, `archive`

### Folders

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/dms-integration/folders` | List folders (query: `parentId`, `repositoryId`) |
| POST | `/api/v1/dms-integration/folders` | Create a folder |
| GET | `/api/v1/dms-integration/folders/:id` | Get folder by ID |
| PUT | `/api/v1/dms-integration/folders/:id` | Update / move folder |
| DELETE | `/api/v1/dms-integration/folders/:id` | Delete folder |

**PUT actions**: `move`

### Document Versions

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/dms-integration/document-versions` | List versions (query: `documentId`, `filter=major/latest`) |
| POST | `/api/v1/dms-integration/document-versions` | Create a version |
| GET | `/api/v1/dms-integration/document-versions/:id` | Get version by ID |
| DELETE | `/api/v1/dms-integration/document-versions/:id` | Delete a version |

### Permissions

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/dms-integration/permissions` | List permissions (query: `documentId`, `folderId`, `principalId`) |
| POST | `/api/v1/dms-integration/permissions` | Grant a permission |
| GET | `/api/v1/dms-integration/permissions/:id` | Get permission by ID |
| DELETE | `/api/v1/dms-integration/permissions/:id` | Revoke a permission |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `DMS_INTEGRATION_HOST` | `0.0.0.0` | Bind address |
| `DMS_INTEGRATION_PORT` | `8109` | HTTP port |

## Running

### Local (dub)

```bash
cd dms-integration
dub run
```

### Docker

```bash
docker build -t uim-platform/dms-integration:latest .
docker run -p 8109:8109 uim-platform/dms-integration:latest
```

### Podman

```bash
podman build -f Containerfile -t uim-platform/dms-integration:latest .
podman run -p 8109:8109 uim-platform/dms-integration:latest
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Dependencies

- **D / LDC2** compiler
- **vibe.d 0.10.3** — async HTTP server
- **vibe-http 1.5.1** — HTTP primitives
- **uim-platform:service** — shared platform primitives (TenantRepository, HealthController, IdTemplate, etc.)
