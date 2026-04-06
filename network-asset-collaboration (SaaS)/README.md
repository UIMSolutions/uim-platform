# Network Asset Collaboration Service

A microservice implementing features similar to SAP Business Network Asset Collaboration (SAP AIN) - a global registry of equipment using common definitions shared between manufacturers, OEMs, operators, and service providers.

Built with D (dlang) and vibe.d using a combination of clean and hexagonal architecture patterns.

## Features

- **Equipment Registry** - Global registry of physical assets with serial numbers, locations, firmware tracking, and lifecycle management
- **Model Management** - Equipment model templates and definitions shared across the network
- **Company Profiles** - Business partner profiles for manufacturers, operators, service providers, OEMs, and distributors
- **Document Management** - Manuals, certificates, drawings, specifications, maintenance plans, service bulletins, and safety sheets
- **Announcements and Service Bulletins** - Recalls, safety alerts, end-of-life notices, upgrade announcements with severity levels
- **Failure Mode Analysis (FMEA)** - Failure mode definitions with cause, effect, detection, mitigation, and risk priority numbers
- **Spare Parts Catalog** - Parts catalog linked to models and equipment with manufacturer, quantity, and criticality tracking
- **Performance Indicators** - Equipment measurements (temperature, pressure, vibration, humidity, voltage, etc.) with threshold alerts

## Architecture

```
source/
  uim/platform/network_asset_collaboration/
    domain/           # Entities, repository interfaces, domain services
    application/      # DTOs, use cases
    infrastructure/   # Config, container (DI), in-memory persistence
    presentation/     # HTTP controllers, JSON serialization
```

### Layers

| Layer | Responsibility |
|-------|---------------|
| **Domain** | Equipment, Model, CompanyProfile, Document, Announcement, FailureMode, SparePart, Indicator entities; repository interfaces; AssetValidator |
| **Application** | EquipmentDTO/ModelDTO/etc.; ManageEquipment/ManageModels/etc. use cases |
| **Infrastructure** | AppConfig (port 8104); Container (DI wiring); Memory repositories |
| **Presentation** | REST controllers; JSON serialization helpers |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/network-asset-collaboration/equipment` | List equipment |
| POST | `/api/v1/network-asset-collaboration/equipment` | Create equipment |
| GET | `/api/v1/network-asset-collaboration/equipment/:id` | Get equipment by ID |
| PUT | `/api/v1/network-asset-collaboration/equipment/:id` | Update equipment |
| DELETE | `/api/v1/network-asset-collaboration/equipment/:id` | Delete equipment |
| GET | `/api/v1/network-asset-collaboration/models` | List models |
| POST | `/api/v1/network-asset-collaboration/models` | Create model |
| GET | `/api/v1/network-asset-collaboration/models/:id` | Get model by ID |
| PUT | `/api/v1/network-asset-collaboration/models/:id` | Update model |
| DELETE | `/api/v1/network-asset-collaboration/models/:id` | Delete model |
| GET | `/api/v1/network-asset-collaboration/companies` | List company profiles |
| POST | `/api/v1/network-asset-collaboration/companies` | Create company profile |
| GET | `/api/v1/network-asset-collaboration/companies/:id` | Get company profile |
| PUT | `/api/v1/network-asset-collaboration/companies/:id` | Update company profile |
| DELETE | `/api/v1/network-asset-collaboration/companies/:id` | Delete company profile |
| GET | `/api/v1/network-asset-collaboration/documents` | List documents |
| POST | `/api/v1/network-asset-collaboration/documents` | Create document |
| GET | `/api/v1/network-asset-collaboration/documents/:id` | Get document |
| PUT | `/api/v1/network-asset-collaboration/documents/:id` | Update document |
| DELETE | `/api/v1/network-asset-collaboration/documents/:id` | Delete document |
| GET | `/api/v1/network-asset-collaboration/announcements` | List announcements |
| POST | `/api/v1/network-asset-collaboration/announcements` | Create announcement |
| GET | `/api/v1/network-asset-collaboration/announcements/:id` | Get announcement |
| PUT | `/api/v1/network-asset-collaboration/announcements/:id` | Update announcement |
| DELETE | `/api/v1/network-asset-collaboration/announcements/:id` | Delete announcement |
| GET | `/api/v1/network-asset-collaboration/failure-modes` | List failure modes |
| POST | `/api/v1/network-asset-collaboration/failure-modes` | Create failure mode |
| GET | `/api/v1/network-asset-collaboration/failure-modes/:id` | Get failure mode |
| PUT | `/api/v1/network-asset-collaboration/failure-modes/:id` | Update failure mode |
| DELETE | `/api/v1/network-asset-collaboration/failure-modes/:id` | Delete failure mode |
| GET | `/api/v1/network-asset-collaboration/spare-parts` | List spare parts |
| POST | `/api/v1/network-asset-collaboration/spare-parts` | Create spare part |
| GET | `/api/v1/network-asset-collaboration/spare-parts/:id` | Get spare part |
| PUT | `/api/v1/network-asset-collaboration/spare-parts/:id` | Update spare part |
| DELETE | `/api/v1/network-asset-collaboration/spare-parts/:id` | Delete spare part |
| GET | `/api/v1/network-asset-collaboration/indicators` | List indicators |
| POST | `/api/v1/network-asset-collaboration/indicators` | Create indicator |
| GET | `/api/v1/network-asset-collaboration/indicators/:id` | Get indicator |
| DELETE | `/api/v1/network-asset-collaboration/indicators/:id` | Delete indicator |
| GET | `/health` | Health check |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `NETWORK_ASSET_COLLABORATION_HOST` | `0.0.0.0` | Server bind address |
| `NETWORK_ASSET_COLLABORATION_PORT` | `8104` | Server port |

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
docker build -t uim-platform/network-asset-collaboration:latest .

# Run container
docker run -p 8104:8104 uim-platform/network-asset-collaboration:latest
```

## Podman

```bash
# Build image
podman build -t uim-platform/network-asset-collaboration:latest -f Containerfile .

# Run container
podman run -p 8104:8104 uim-platform/network-asset-collaboration:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## License

Apache 2.0 - see LICENSE.txt
