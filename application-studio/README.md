# Application Studio Service

A microservice providing cloud-based IDE capabilities similar to **SAP Business Application Studio**. Built with D and vibe.d using a combination of clean and hexagonal architecture. Enables managing development spaces, extensions, project templates, service bindings, and build/run configurations for SAP BTP application development.

## Features

- **Dev Space Management** -- Create and manage cloud-based development environments with configurable memory, disk limits, hibernation policies, and regional deployment
- **Dev Space Types** -- Define predefined and custom dev space types (SAP Fiori, CAP, HANA Native, etc.) with runtime stacks and supported project types
- **Extension Management** -- Install and manage IDE extensions and tools with scope classification (predefined, additional, third-party), versioning, and dependency tracking
- **Project Management** -- Create projects from templates or Git repositories with type classification, namespace support, and lifecycle status tracking
- **Project Templates** -- Provide scaffolding wizards for various SAP project types with configurable default files and required extension dependencies
- **Service Bindings** -- Connect dev spaces to SAP BTP services and external systems (S/4HANA, SuccessFactors, OData, REST) with authentication and credential management
- **Run Configurations** -- Configure run, debug, test, and preview modes for projects with entry points, arguments, environment variables, and port mappings
- **Build Configurations** -- Define build and deploy pipelines targeting Cloud Foundry, Kyma, ABAP, HTML5 Repository, or Docker with MTA descriptor support

## Architecture

```
+-----------------------------------------------------+
|                  Presentation Layer                  |
|  DevSpaceController  DevSpaceTypeController         |
|  ExtensionController  ProjectController             |
|  ProjectTemplateController  ServiceBindingCtrl      |
|  RunConfigurationController  BuildConfigCtrl        |
+-----------------------------------------------------+
|                  Application Layer                   |
|  ManageDevSpacesUseCase  ManageDevSpaceTypesUC      |
|  ManageExtensionsUseCase  ManageProjectsUseCase     |
|  ManageProjectTemplatesUC  ManageServiceBindingsUC  |
|  ManageRunConfigurationsUC  ManageBuildConfigsUC    |
+-----------------------------------------------------+
|                   Domain Layer                       |
|  Entities  Repository Interfaces  Domain Services   |
+-----------------------------------------------------+
|                Infrastructure Layer                  |
|  MemoryRepositories  AppConfig  Container           |
+-----------------------------------------------------+
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| **Dev Spaces** | | |
| GET | `/api/v1/application-studio/dev-spaces` | List all dev spaces |
| GET | `/api/v1/application-studio/dev-spaces/{id}` | Get dev space by ID |
| POST | `/api/v1/application-studio/dev-spaces` | Create dev space |
| PUT | `/api/v1/application-studio/dev-spaces/{id}` | Update dev space |
| DELETE | `/api/v1/application-studio/dev-spaces/{id}` | Delete dev space |
| **Dev Space Types** | | |
| GET | `/api/v1/application-studio/dev-space-types` | List all dev space types |
| GET | `/api/v1/application-studio/dev-space-types/{id}` | Get dev space type by ID |
| POST | `/api/v1/application-studio/dev-space-types` | Create dev space type |
| PUT | `/api/v1/application-studio/dev-space-types/{id}` | Update dev space type |
| DELETE | `/api/v1/application-studio/dev-space-types/{id}` | Delete dev space type |
| **Extensions** | | |
| GET | `/api/v1/application-studio/extensions` | List all extensions |
| GET | `/api/v1/application-studio/extensions/{id}` | Get extension by ID |
| POST | `/api/v1/application-studio/extensions` | Create extension |
| PUT | `/api/v1/application-studio/extensions/{id}` | Update extension |
| DELETE | `/api/v1/application-studio/extensions/{id}` | Delete extension |
| **Projects** | | |
| GET | `/api/v1/application-studio/projects` | List all projects |
| GET | `/api/v1/application-studio/projects/{id}` | Get project by ID |
| POST | `/api/v1/application-studio/projects` | Create project |
| PUT | `/api/v1/application-studio/projects/{id}` | Update project |
| DELETE | `/api/v1/application-studio/projects/{id}` | Delete project |
| **Project Templates** | | |
| GET | `/api/v1/application-studio/project-templates` | List all project templates |
| GET | `/api/v1/application-studio/project-templates/{id}` | Get project template by ID |
| POST | `/api/v1/application-studio/project-templates` | Create project template |
| PUT | `/api/v1/application-studio/project-templates/{id}` | Update project template |
| DELETE | `/api/v1/application-studio/project-templates/{id}` | Delete project template |
| **Service Bindings** | | |
| GET | `/api/v1/application-studio/service-bindings` | List all service bindings |
| GET | `/api/v1/application-studio/service-bindings/{id}` | Get service binding by ID |
| POST | `/api/v1/application-studio/service-bindings` | Create service binding |
| PUT | `/api/v1/application-studio/service-bindings/{id}` | Update service binding |
| DELETE | `/api/v1/application-studio/service-bindings/{id}` | Delete service binding |
| **Run Configurations** | | |
| GET | `/api/v1/application-studio/run-configurations` | List all run configurations |
| GET | `/api/v1/application-studio/run-configurations/{id}` | Get run configuration by ID |
| POST | `/api/v1/application-studio/run-configurations` | Create run configuration |
| PUT | `/api/v1/application-studio/run-configurations/{id}` | Update run configuration |
| DELETE | `/api/v1/application-studio/run-configurations/{id}` | Delete run configuration |
| **Build Configurations** | | |
| GET | `/api/v1/application-studio/build-configurations` | List all build configurations |
| GET | `/api/v1/application-studio/build-configurations/{id}` | Get build configuration by ID |
| POST | `/api/v1/application-studio/build-configurations` | Create build configuration |
| PUT | `/api/v1/application-studio/build-configurations/{id}` | Update build configuration |
| DELETE | `/api/v1/application-studio/build-configurations/{id}` | Delete build configuration |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `APPLICATION_STUDIO_HOST` | `0.0.0.0` | Server bind address |
| `APPLICATION_STUDIO_PORT` | `8111` | Server listen port |

## Build and Run

### Local

```bash
dub build
./uim-application-studio-platform-service
```

### Docker

```bash
docker build -t uim-application-studio .
docker run -p 8111:8111 uim-application-studio
```

### Podman

```bash
podman build -t uim-application-studio -f Containerfile .
podman run -p 8111:8111 uim-application-studio
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
