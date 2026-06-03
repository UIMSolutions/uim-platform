# NAFv4 - Analytics Service

## 1. Purpose

Provide an analytics-oriented service with capabilities aligned to key SAP Analytics Cloud feature domains:

- Data preparation metadata
- Analysis and visualization artifact lifecycle
- Sharing and publication state
- API-driven integration patterns

This service is an independent implementation with inspired capability coverage, not a clone of SAP internals.

## 2. Architectural Style

- Clean Architecture for dependency direction and use-case-centric orchestration
- Hexagonal Architecture for strict port-adapter boundaries
- MVC presentation variants for CLI, Web, and GUI channels

## 3. Building Blocks

- Domain: `InsightAsset`, validation rules, `AssetRepository` port
- Application: `ManageAssetsUseCase`, request DTOs, command results
- Infrastructure:
  - Memory adapter for fast local usage
  - File adapter for persistent local state
  - MongoDB adapter for scalable document storage
  - Config and dependency container
- Presentation:
  - HTTP REST API
  - CLI MVC
  - Web MVC
  - GUI MVC

## 4. Runtime View

1. Request enters via API or presentation controller.
2. Controller maps input to DTO.
3. Use case executes business flow and validation.
4. Persistence adapter (selected by config) stores and reads data.
5. Response model is rendered to JSON, CLI text, or HTML GUI view.

## 5. Deployment View

- Local: `dub run`
- Container: `Dockerfile` and `Containerfile`
- Kubernetes: Deployment + Service + ConfigMap
- Health endpoint: `/api/v1/health`

## 6. Operational Requirements

- Stateless service process; state externalized via storage adapter
- Configuration through environment variables
- Kubernetes readiness/liveness probes
- Tenant scoping by `tenantId`

## 7. Non-Functional Requirements

- Reliability:
  - memory backend for development
  - file backend for single-node persistence
  - MongoDB backend for multi-instance resilient persistence
- Security:
  - no secrets hardcoded
  - Mongo URI injected via environment/secret
- Maintainability:
  - clear layer boundaries
  - interchangeable adapters via one enum switch
- Testability:
  - use case decoupled from infrastructure through repository port

## 8. Extension Roadmap

- Add planning workflow entities and calendar tasks
- Add role-based authorization policies per tenant
- Add collaboration comments and sharing graph
- Add data-connection credential vault integration
- Add analytical query execution and cache invalidation strategies
