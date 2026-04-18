# HTML5 Application Repository Service

A central repository service for HTML5 application static content, inspired by SAP HTML5 Application Repository Service for SAP BTP. Built with D language (dlang), vibe.d HTTP framework, and clean/hexagonal architecture.

## Features

- **HTML5 App Management** - Register and manage HTML5 applications with namespace support, public/private visibility, and tenant isolation
- **Version Management** - Track application versions with status lifecycle (draft, active, deprecated, archived)
- **File Storage** - Upload, download, and manage static content files (HTML, CSS, JavaScript, images, fonts, JSON, XML) with automatic content type detection and ETag generation
- **Service Instances** - Manage app-host and app-runtime service instances with storage quota tracking (100 MB default)
- **Zero-Downtime Deployment** - Orchestrated deployments that atomically switch active versions, decoupling static content updates from application router
- **Route Management** - Configure URL path prefix routing to map requests to HTML5 applications
- **Content Caching** - Runtime content caching with TTL-based expiration, hit counting, and bulk purge for high-performance content delivery
- **Content Serving** - Direct static content serving endpoint with correct Content-Type headers
- **Deployment History** - Full audit trail of deploy/undeploy operations per application
- **Multitenancy** - Complete tenant isolation across all entities via X-Tenant-Id header
- **Validation** - Application name, version code, file path, and deployment size validation with configurable limits (100 MB max, 50 deploys/min, 300 req/sec)
- **Health Monitoring** - Health check endpoint for container orchestration

## Architecture

Clean Architecture + Hexagonal Architecture (Ports and Adapters)

Domain Layer (innermost)
  - Entities: HtmlApp, AppVersion, AppFile, ServiceInstance, DeploymentRecord, AppRoute, ContentCache
  - Ports: 7 Repository interfaces (driven adapter contracts)
  - Services: ContentDeliveryService, DeploymentValidator, VisibilityService

Application Layer
  - DTOs: Request/Response data transfer objects
  - Use Cases: ManageHtmlApps, ManageAppVersions, ManageAppFiles, ManageServiceInstances,
               DeployApplication, ManageAppRoutes, ManageContentCache, GetDeploymentHistory, GetOverview

Infrastructure Layer
  - Config: Environment-based configuration (HTML_REPO_HOST, HTML_REPO_PORT)
  - Container: Dependency injection wiring
  - Persistence: In-memory repository implementations

Presentation Layer (outermost)
  - HTTP Controllers: 10 vibe.d REST API handlers
  - JSON Utils: Serialization helpers

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/apps` | Manage HTML5 applications |
| CRUD | `/api/v1/versions` | Manage application versions |
| CRUD | `/api/v1/files` | Upload and manage static content files |
| CRUD | `/api/v1/instances` | Manage service instances (app-host/app-runtime) |
| POST/GET | `/api/v1/deployments` | Deploy applications and view deployment history |
| CRUD | `/api/v1/routes` | Manage application route configurations |
| CRUD | `/api/v1/cache` | Manage content cache entries |
| POST | `/api/v1/cache/purge` | Purge expired cache entries |
| GET | `/api/v1/content/*` | Serve static content with correct Content-Type |
| GET | `/api/v1/overview` | Get system overview/dashboard |
| GET | `/api/v1/health` | Health check |

## Build and Run

### Local Development

```
cd html-repository
dub run
```

The service starts on port 8097 by default.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `HTML_REPO_HOST` | `0.0.0.0` | Bind address |
| `HTML_REPO_PORT` | `8097` | Listen port |

### Docker

```
cd html-repository
docker build -t uim-html-repository .
docker run -p 8097:8097 uim-html-repository
```

### Podman

```
cd html-repository
podman build -t uim-html-repository -f Containerfile .
podman run -p 8097:8097 uim-html-repository
```

### Kubernetes

```
kubectl apply -f html-repository/k8s/configmap.yaml
kubectl apply -f html-repository/k8s/deployment.yaml
kubectl apply -f html-repository/k8s/service.yaml
```

## Inspired By

[SAP HTML5 Application Repository Service for SAP BTP](https://help.sap.com/docs/btp/sap-business-technology-platform/html5-application-repository-service-for-sap-btp) - providing central storage, versioning, zero-downtime deployment, public/private authorization, caching, and multitenancy for HTML5 static content.
