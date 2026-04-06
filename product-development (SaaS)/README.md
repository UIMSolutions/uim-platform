# Product Development Service

A microservice implementing features similar to SAP Integrated Product Development (SAP IPD/PLM EPD) - a comprehensive solution for managing product lifecycle, bills of material, engineering change management, document management, specification management, formulation/recipe management, collaboration, and enterprise product structures.

Built with D (dlang) and vibe.d using a combination of clean and hexagonal architecture patterns.

## Features

- **Product Management** - Core product registry with type classification (discrete, process, configurable), lifecycle phases, versioning, and categorization
- **Bill of Material (BOM) Management** - Engineering and manufacturing BOMs with components, quantities, plant assignments, and version control
- **Change Request Management** - Engineering change requests with priority, category, impact analysis, affected documents/BOMs tracking, and approval workflows
- **Document Management** - Technical document registry with versioning, file metadata, document numbering, language support, and approval workflows
- **Specification Management** - Product specifications with properties, target values, tolerance limits, test methods, and compliance standards
- **Recipe/Formulation Management** - Recipe definitions with ingredients, batch sizing, yield tracking, shelf life, and storage conditions
- **Collaboration Management** - Design reviews, cross-functional tasks, issue tracking, and team collaboration with participant management
- **Product Structure Management** - Enterprise product structure hierarchy with variant conditions, configuration profiles, and mandatory/optional nodes

## Architecture

```
source/
  uim/platform/product_development/
    domain/           # Entities, repository interfaces, domain services
    application/      # DTOs, use cases
    infrastructure/   # Config, container (DI), in-memory persistence
    presentation/     # HTTP controllers, JSON serialization
```

### Layers

| Layer | Responsibility |
|-------|---------------|
| **Domain** | Product, BillOfMaterial, ChangeRequest, Document, Specification, Recipe, Collaboration, ProductStructure entities; repository interfaces; ProductValidator |
| **Application** | ProductDTO/BillOfMaterialDTO/etc.; ManageProducts/ManageBoms/etc. use cases |
| **Infrastructure** | AppConfig (port 8106); Container (DI wiring); Memory repositories |
| **Presentation** | REST controllers; JSON serialization helpers |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/product-development/products` | List products |
| POST | `/api/v1/product-development/products` | Create product |
| GET | `/api/v1/product-development/products/:id` | Get product by ID |
| PUT | `/api/v1/product-development/products/:id` | Update product |
| DELETE | `/api/v1/product-development/products/:id` | Delete product |
| GET | `/api/v1/product-development/boms` | List bills of material |
| POST | `/api/v1/product-development/boms` | Create BOM |
| GET | `/api/v1/product-development/boms/:id` | Get BOM by ID |
| PUT | `/api/v1/product-development/boms/:id` | Update BOM |
| DELETE | `/api/v1/product-development/boms/:id` | Delete BOM |
| GET | `/api/v1/product-development/change-requests` | List change requests |
| POST | `/api/v1/product-development/change-requests` | Create change request |
| GET | `/api/v1/product-development/change-requests/:id` | Get change request by ID |
| PUT | `/api/v1/product-development/change-requests/:id` | Update change request |
| DELETE | `/api/v1/product-development/change-requests/:id` | Delete change request |
| GET | `/api/v1/product-development/documents` | List documents |
| POST | `/api/v1/product-development/documents` | Create document |
| GET | `/api/v1/product-development/documents/:id` | Get document by ID |
| PUT | `/api/v1/product-development/documents/:id` | Update document |
| DELETE | `/api/v1/product-development/documents/:id` | Delete document |
| GET | `/api/v1/product-development/specifications` | List specifications |
| POST | `/api/v1/product-development/specifications` | Create specification |
| GET | `/api/v1/product-development/specifications/:id` | Get specification by ID |
| PUT | `/api/v1/product-development/specifications/:id` | Update specification |
| DELETE | `/api/v1/product-development/specifications/:id` | Delete specification |
| GET | `/api/v1/product-development/recipes` | List recipes |
| POST | `/api/v1/product-development/recipes` | Create recipe |
| GET | `/api/v1/product-development/recipes/:id` | Get recipe by ID |
| PUT | `/api/v1/product-development/recipes/:id` | Update recipe |
| DELETE | `/api/v1/product-development/recipes/:id` | Delete recipe |
| GET | `/api/v1/product-development/collaborations` | List collaborations |
| POST | `/api/v1/product-development/collaborations` | Create collaboration |
| GET | `/api/v1/product-development/collaborations/:id` | Get collaboration by ID |
| PUT | `/api/v1/product-development/collaborations/:id` | Update collaboration |
| DELETE | `/api/v1/product-development/collaborations/:id` | Delete collaboration |
| GET | `/api/v1/product-development/structures` | List product structures |
| POST | `/api/v1/product-development/structures` | Create product structure |
| GET | `/api/v1/product-development/structures/:id` | Get product structure by ID |
| PUT | `/api/v1/product-development/structures/:id` | Update product structure |
| DELETE | `/api/v1/product-development/structures/:id` | Delete product structure |
| GET | `/health` | Health check |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `PRODUCT_DEVELOPMENT_HOST` | `0.0.0.0` | Server bind address |
| `PRODUCT_DEVELOPMENT_PORT` | `8106` | Server port |

## Build and Run

```bash
# Build
dub build

# Run
dub run

# Test
dub test
```

## Docker

```bash
# Build image
docker build -t uim-platform/product-development:latest .

# Run container
docker run -p 8106:8106 uim-platform/product-development:latest
```

## Podman

```bash
# Build image
podman build -t uim-platform/product-development:latest -f Containerfile .

# Run container
podman run -p 8106:8106 uim-platform/product-development:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## License

Apache 2.0 - see LICENSE.txt
