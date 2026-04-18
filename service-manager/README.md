# SAP Service Manager - Platform Service

A microservice implementing SAP Service Manager capabilities using D (dlang) and vibe.d, following clean and hexagonal architecture principles.

SAP Service Manager is the central registry for service brokers and platforms in SAP BTP. It enables consuming platform services in connected runtime environments, tracking service instance creation, and sharing services between environments.

## Features

- **Platform/Environment Management** - Register and manage runtime environments (Cloud Foundry, Kubernetes, Kyma)
- **Service Broker Registry** - Register Open Service Broker API-compatible brokers that advertise service catalogs
- **Service Offerings Catalog** - Browse available services advertised by registered brokers
- **Service Plans** - View and manage capability tiers for each service offering
- **Service Instance Lifecycle** - Provision, update, and deprovision service instances
- **Service Bindings** - Create and manage credentials/access details for service instances
- **Async Operation Tracking** - Monitor long-running provisioning and deprovisioning operations
- **Label Management** - Attach key-value metadata labels to any resource for filtering and organization
- **Multi-tenant Support** - Full tenant isolation across all resources
- **Health Monitoring** - Built-in health check endpoint

## Architecture

```
+--------------------------------------------------+
|                  Presentation Layer               |
|  (HTTP Controllers, JSON serialization, Routing)  |
+--------------------------------------------------+
|                  Application Layer                |
|  (Use Cases, DTOs, Command Results)               |
+--------------------------------------------------+
|                   Domain Layer                    |
|  (Entities, Value Types, Repository Interfaces,   |
|   Domain Services, Enumerations)                  |
+--------------------------------------------------+
|                Infrastructure Layer               |
|  (Config, DI Container, Memory Repositories)      |
+--------------------------------------------------+
```

## Domain Concepts

| Entity | Description |
|--------|-------------|
| Platform | Registered runtime environment (CF, K8s, Kyma) for hosting applications |
| ServiceBroker | OSB API-compatible broker advertising service catalogs |
| ServiceOffering | Service advertised by a broker with metadata and capabilities |
| ServicePlan | Specific tier/configuration of a service offering |
| ServiceInstance | Provisioned, running copy of a service plan |
| ServiceBinding | Access credentials and connection details for an instance |
| Operation | Async operation tracking for provisioning/deprovisioning |
| Label | Key-value metadata attached to resources |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/service-manager/platforms` | List all platforms |
| POST | `/api/v1/service-manager/platforms` | Register a platform |
| GET | `/api/v1/service-manager/platforms/:id` | Get platform details |
| PUT | `/api/v1/service-manager/platforms/:id` | Update a platform |
| DELETE | `/api/v1/service-manager/platforms/:id` | Deregister a platform |
| GET | `/api/v1/service-manager/service-brokers` | List all service brokers |
| POST | `/api/v1/service-manager/service-brokers` | Register a service broker |
| GET | `/api/v1/service-manager/service-brokers/:id` | Get broker details |
| PUT | `/api/v1/service-manager/service-brokers/:id` | Update a service broker |
| DELETE | `/api/v1/service-manager/service-brokers/:id` | Deregister a service broker |
| GET | `/api/v1/service-manager/service-offerings` | List service offerings |
| POST | `/api/v1/service-manager/service-offerings` | Create a service offering |
| GET | `/api/v1/service-manager/service-offerings/:id` | Get offering details |
| PUT | `/api/v1/service-manager/service-offerings/:id` | Update an offering |
| DELETE | `/api/v1/service-manager/service-offerings/:id` | Remove an offering |
| GET | `/api/v1/service-manager/service-plans` | List service plans |
| POST | `/api/v1/service-manager/service-plans` | Create a service plan |
| GET | `/api/v1/service-manager/service-plans/:id` | Get plan details |
| PUT | `/api/v1/service-manager/service-plans/:id` | Update a plan |
| DELETE | `/api/v1/service-manager/service-plans/:id` | Remove a plan |
| GET | `/api/v1/service-manager/service-instances` | List service instances |
| POST | `/api/v1/service-manager/service-instances` | Provision a service instance |
| GET | `/api/v1/service-manager/service-instances/:id` | Get instance details |
| PUT | `/api/v1/service-manager/service-instances/:id` | Update an instance |
| DELETE | `/api/v1/service-manager/service-instances/:id` | Deprovision an instance |
| GET | `/api/v1/service-manager/service-bindings` | List service bindings |
| POST | `/api/v1/service-manager/service-bindings` | Create a service binding |
| GET | `/api/v1/service-manager/service-bindings/:id` | Get binding details |
| PUT | `/api/v1/service-manager/service-bindings/:id` | Update a binding |
| DELETE | `/api/v1/service-manager/service-bindings/:id` | Delete a binding |
| GET | `/api/v1/service-manager/operations` | List operations |
| POST | `/api/v1/service-manager/operations` | Create an operation |
| GET | `/api/v1/service-manager/operations/:id` | Get operation status |
| PUT | `/api/v1/service-manager/operations/:id` | Update operation status |
| DELETE | `/api/v1/service-manager/operations/:id` | Remove an operation |
| GET | `/api/v1/service-manager/labels` | List labels |
| POST | `/api/v1/service-manager/labels` | Create a label |
| GET | `/api/v1/service-manager/labels/:id` | Get label details |
| PUT | `/api/v1/service-manager/labels/:id` | Update a label |
| DELETE | `/api/v1/service-manager/labels/:id` | Delete a label |
| GET | `/health` | Health check |

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `SERVICE_MANAGER_HOST` | `0.0.0.0` | Server bind address |
| `SERVICE_MANAGER_PORT` | `8113` | Server port |

## Build and Run

### Prerequisites

- D compiler (LDC 1.40.1+ recommended)
- DUB package manager

### Local Development

```bash
# Build
dub build --config=defaultRun

# Run
./uim-service-manager-platform-service

# Build as library (for testing)
dub build --config=defaultTest
```

### Docker

```bash
docker build -t uim-platform/service-manager:latest .
docker run -p 8113:8113 uim-platform/service-manager:latest
```

### Podman

```bash
podman build -t uim-platform/service-manager:latest -f Containerfile .
podman run -p 8113:8113 uim-platform/service-manager:latest
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Project Structure

```
service-manager/
  source/
    app.d                                          # Entry point
    uim/platform/service_manager/
      package.d                                    # Umbrella module
      domain/
        types.d                                    # Domain ID types
        enumerations.d                             # Domain enums
        entities/                                  # Domain entities
        ports/repositories/                        # Repository interfaces
        services/                                  # Domain services
      application/
        dto.d                                      # Request DTOs
        usecases/manage/                           # Use case implementations
      infrastructure/
        config.d                                   # App configuration
        container.d                                # DI container
        persistence/memory/                        # In-memory repositories
      presentation/http/
        controllers/                               # HTTP controllers
  dub.sdl                                          # Build configuration
  Dockerfile                                       # Docker build
  Containerfile                                    # Podman build
  k8s/                                             # Kubernetes manifests
  README.md
  UML.md
  NAFv4.md
```

## License

Apache-2.0
