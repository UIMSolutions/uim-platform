# Build Apps Service

A microservice providing no-code application development capabilities similar to **SAP Build Apps**. Built with D and vibe.d using a combination of clean and hexagonal architecture. Enables visual drag-and-drop UI building, cloud-based data persistence and backend logic, integration with SAP and external systems, and multi-target app builds for web and native mobile platforms.

## Features

- **Application Management** -- Create and manage no-code application projects with type classification (web, mobile, web and mobile), versioning, owner tracking, and lifecycle status
- **Page Management** -- Build application pages with drag-and-drop visual editor supporting page types (blank, list, detail, form, dashboard, login, settings, custom) and layout configuration
- **UI Component Library** -- Manage reusable UI components across categories with version tracking, property schemas, event definitions, and style configuration
- **Data Entities** -- Define and manage cloud-based data models with field definitions, validation rules, default values, and persistence configuration
- **Data Connections** -- Connect applications to SAP BTP destinations, OData, REST APIs, SAP S/4HANA, SAP SuccessFactors, Firebase, and custom backends with authentication management
- **Logic Flows** -- Build visual logic flows triggered by page events, data changes, app lifecycle, schedules, or manual actions with step definitions and error handling
- **App Builds** -- Configure and execute multi-target builds for web, iOS, Android, and combined platforms with signing configuration and version management
- **Project Members** -- Manage project team membership with role-based access (owner, editor, viewer, tester) and granular permissions

## Architecture

```
+-----------------------------------------------------+
|                  Presentation Layer                  |
|  ApplicationController  PageController              |
|  UIComponentController  DataEntityController        |
|  DataConnectionController  LogicFlowController      |
|  AppBuildController  ProjectMemberController        |
+-----------------------------------------------------+
|                  Application Layer                   |
|  ManageApplicationsUseCase  ManagePagesUseCase      |
|  ManageUIComponentsUseCase  ManageDataEntitiesUC    |
|  ManageDataConnectionsUC  ManageLogicFlowsUseCase   |
|  ManageAppBuildsUseCase  ManageProjectMembersUC     |
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
| **Applications** | | |
| GET | `/api/v1/build-apps/applications` | List all applications |
| GET | `/api/v1/build-apps/applications/{id}` | Get application by ID |
| POST | `/api/v1/build-apps/applications` | Create application |
| PUT | `/api/v1/build-apps/applications/{id}` | Update application |
| DELETE | `/api/v1/build-apps/applications/{id}` | Delete application |
| **Pages** | | |
| GET | `/api/v1/build-apps/pages` | List all pages |
| GET | `/api/v1/build-apps/pages/{id}` | Get page by ID |
| POST | `/api/v1/build-apps/pages` | Create page |
| PUT | `/api/v1/build-apps/pages/{id}` | Update page |
| DELETE | `/api/v1/build-apps/pages/{id}` | Delete page |
| **UI Components** | | |
| GET | `/api/v1/build-apps/ui-components` | List all UI components |
| GET | `/api/v1/build-apps/ui-components/{id}` | Get UI component by ID |
| POST | `/api/v1/build-apps/ui-components` | Create UI component |
| PUT | `/api/v1/build-apps/ui-components/{id}` | Update UI component |
| DELETE | `/api/v1/build-apps/ui-components/{id}` | Delete UI component |
| **Data Entities** | | |
| GET | `/api/v1/build-apps/data-entities` | List all data entities |
| GET | `/api/v1/build-apps/data-entities/{id}` | Get data entity by ID |
| POST | `/api/v1/build-apps/data-entities` | Create data entity |
| PUT | `/api/v1/build-apps/data-entities/{id}` | Update data entity |
| DELETE | `/api/v1/build-apps/data-entities/{id}` | Delete data entity |
| **Data Connections** | | |
| GET | `/api/v1/build-apps/data-connections` | List all data connections |
| GET | `/api/v1/build-apps/data-connections/{id}` | Get data connection by ID |
| POST | `/api/v1/build-apps/data-connections` | Create data connection |
| PUT | `/api/v1/build-apps/data-connections/{id}` | Update data connection |
| DELETE | `/api/v1/build-apps/data-connections/{id}` | Delete data connection |
| **Logic Flows** | | |
| GET | `/api/v1/build-apps/logic-flows` | List all logic flows |
| GET | `/api/v1/build-apps/logic-flows/{id}` | Get logic flow by ID |
| POST | `/api/v1/build-apps/logic-flows` | Create logic flow |
| PUT | `/api/v1/build-apps/logic-flows/{id}` | Update logic flow |
| DELETE | `/api/v1/build-apps/logic-flows/{id}` | Delete logic flow |
| **App Builds** | | |
| GET | `/api/v1/build-apps/app-builds` | List all app builds |
| GET | `/api/v1/build-apps/app-builds/{id}` | Get app build by ID |
| POST | `/api/v1/build-apps/app-builds` | Create app build |
| PUT | `/api/v1/build-apps/app-builds/{id}` | Update app build |
| DELETE | `/api/v1/build-apps/app-builds/{id}` | Delete app build |
| **Project Members** | | |
| GET | `/api/v1/build-apps/project-members` | List all project members |
| GET | `/api/v1/build-apps/project-members/{id}` | Get project member by ID |
| POST | `/api/v1/build-apps/project-members` | Create project member |
| PUT | `/api/v1/build-apps/project-members/{id}` | Update project member |
| DELETE | `/api/v1/build-apps/project-members/{id}` | Delete project member |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `BUILD_APPS_HOST` | `0.0.0.0` | Server bind address |
| `BUILD_APPS_PORT` | `8112` | Server listen port |

## Build and Run

### Local

```bash
dub build
./uim-build-apps-platform-service
```

### Docker

```bash
docker build -t uim-build-apps .
docker run -p 8112:8112 uim-build-apps
```

### Podman

```bash
podman build -t uim-build-apps -f Containerfile .
podman run -p 8112:8112 uim-build-apps
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
