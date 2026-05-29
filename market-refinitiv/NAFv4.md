# NAFv4 Architecture - Market Rates Management (Refinitiv)

## 1. Capability View

- Capability: Market rates lifecycle management for enterprise applications
- External alignment: SAP BTP Market Rates Management with Refinitiv-oriented provider integration
- Main outcomes:
- Reliable ingestion and distribution of rates
- Multi-tenant isolation
- Auditable business operations

## 2. Logical View (Clean + Hexagonal)

- Domain layer:
- Entities: `MarketRate`, `Provider`, `AuditLog`
- Policies: quota validation, data validation
- Application layer:
- Use cases for upload/download/query/delete, provider CRUD, and audit access
- Port interfaces:
- `MarketRateRepository`, `ProviderRepository`, `AuditLogRepository`
- Adapter layer:
- Driving adapters: HTTP MVC, CLI MVC, Web MVC, GUI MVC
- Driven adapters: Memory, File, MongoDB persistence

## 3. Deployment View

- Runtime: native Linux binary built from DUB
- Containers: Dockerfile and Containerfile included
- Orchestration: Kubernetes manifests in `k8s/`
- Network:
- Service exposes HTTP port `8098`
- Health endpoint: `GET /api/v1/health`

## 4. Data View

- Tenant-partitioned data model
- Primary aggregates:
- Market rates by provider/category/date/key
- Provider master data
- Immutable or append-style business audit records
- Persistence strategies:
- MEMORY: in-process hash maps
- FILE: JSON documents and NDJSON logs
- MONGODB: collection-backed repository adapters

## 5. Security and Operations

- Non-root container runtime user
- Health probes and resource requests in Kubernetes deployment
- Configuration by environment variables (12-factor style)
- Backend switching without domain/application code changes

## 6. SAP Concept Mapping

- SAP provider/source concept -> `Provider` + `providerCode`
- SAP market data category concept -> `MarketDataCategory`
- SAP upload/download operations -> dedicated application use cases and HTTP endpoints
- SAP business logging concept -> `AuditLog` repository and API controller

## 7. Technology Stack

- Language: D
- Web framework: vibe.d
- Architecture: Clean + Hexagonal + MVC presentation adapters
- Persistence: Memory, File, MongoDB
- Packaging: DUB
- Runtime targets: local, Docker, Podman, Kubernetes
