# Automation Pilot Service

A microservice providing DevOps automation capabilities similar to **SAP Automation Pilot**. Built with D and vibe.d using a combination of clean and hexagonal architecture. Enables designing and running automation flows for routine operations, scheduled tasks, and event-driven workflows.

## Features

- **Catalog Management** -- Organize commands into logical catalogs with versioning, tagging, and built-in/custom classification for structured command discovery
- **Command Design** -- Define automation workflows with input/output schemas, multi-step execution logic, timeout policies, retry strategies, and version control
- **Command Inputs** -- Create reusable key-value input sets for command executions with support for sensitive value masking and cross-command sharing
- **Execution Engine** -- Execute commands on-demand with real-time status tracking, input binding, output capture, error logging, and duration measurement
- **Scheduled Executions** -- Schedule one-time or recurring command runs using cron expressions with retry configuration, enable/disable toggles, and next-run tracking
- **Trigger Management** -- Configure event-driven automation triggers with event type/source filtering, filter expressions, and input mapping from event payloads to command inputs
- **Service Accounts** -- Manage API access credentials with permission scoping, client ID tracking, expiration policies, and status lifecycle management
- **Content Connectors** -- Connect to external repositories (GitHub) for backup/restore of automation content with branch and path configuration

## Architecture

```
+-----------------------------------------------------+
|                  Presentation Layer                  |
|  CatalogController  CommandController               |
|  CommandInputController  ExecutionController        |
|  ScheduledExecutionController  TriggerController    |
|  ServiceAccountController  ContentConnectorCtrl     |
+-----------------------------------------------------+
|                  Application Layer                   |
|  ManageCatalogsUseCase  ManageCommandsUseCase       |
|  ManageCommandInputsUC  ManageExecutionsUseCase     |
|  ManageScheduledExecsUC  ManageTriggersUseCase      |
|  ManageServiceAccountsUC  ManageContentConnectorsUC |
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
| **Catalogs** | | |
| GET | `/api/v1/automation-pilot/catalogs` | List all catalogs |
| GET | `/api/v1/automation-pilot/catalogs/{id}` | Get catalog by ID |
| POST | `/api/v1/automation-pilot/catalogs` | Create catalog |
| PUT | `/api/v1/automation-pilot/catalogs/{id}` | Update catalog |
| DELETE | `/api/v1/automation-pilot/catalogs/{id}` | Delete catalog |
| **Commands** | | |
| GET | `/api/v1/automation-pilot/commands` | List all commands |
| GET | `/api/v1/automation-pilot/commands/{id}` | Get command by ID |
| POST | `/api/v1/automation-pilot/commands` | Create command |
| PUT | `/api/v1/automation-pilot/commands/{id}` | Update command |
| DELETE | `/api/v1/automation-pilot/commands/{id}` | Delete command |
| **Inputs** | | |
| GET | `/api/v1/automation-pilot/inputs` | List all inputs |
| GET | `/api/v1/automation-pilot/inputs/{id}` | Get input by ID |
| POST | `/api/v1/automation-pilot/inputs` | Create input |
| PUT | `/api/v1/automation-pilot/inputs/{id}` | Update input |
| DELETE | `/api/v1/automation-pilot/inputs/{id}` | Delete input |
| **Executions** | | |
| GET | `/api/v1/automation-pilot/executions` | List all executions |
| GET | `/api/v1/automation-pilot/executions/{id}` | Get execution by ID |
| POST | `/api/v1/automation-pilot/executions` | Create execution |
| PUT | `/api/v1/automation-pilot/executions/{id}` | Update execution |
| DELETE | `/api/v1/automation-pilot/executions/{id}` | Delete execution |
| **Scheduled Executions** | | |
| GET | `/api/v1/automation-pilot/scheduled-executions` | List all scheduled executions |
| GET | `/api/v1/automation-pilot/scheduled-executions/{id}` | Get scheduled execution by ID |
| POST | `/api/v1/automation-pilot/scheduled-executions` | Create scheduled execution |
| PUT | `/api/v1/automation-pilot/scheduled-executions/{id}` | Update scheduled execution |
| DELETE | `/api/v1/automation-pilot/scheduled-executions/{id}` | Delete scheduled execution |
| **Triggers** | | |
| GET | `/api/v1/automation-pilot/triggers` | List all triggers |
| GET | `/api/v1/automation-pilot/triggers/{id}` | Get trigger by ID |
| POST | `/api/v1/automation-pilot/triggers` | Create trigger |
| PUT | `/api/v1/automation-pilot/triggers/{id}` | Update trigger |
| DELETE | `/api/v1/automation-pilot/triggers/{id}` | Delete trigger |
| **Service Accounts** | | |
| GET | `/api/v1/automation-pilot/service-accounts` | List all service accounts |
| GET | `/api/v1/automation-pilot/service-accounts/{id}` | Get service account by ID |
| POST | `/api/v1/automation-pilot/service-accounts` | Create service account |
| PUT | `/api/v1/automation-pilot/service-accounts/{id}` | Update service account |
| DELETE | `/api/v1/automation-pilot/service-accounts/{id}` | Delete service account |
| **Content Connectors** | | |
| GET | `/api/v1/automation-pilot/content-connectors` | List all content connectors |
| GET | `/api/v1/automation-pilot/content-connectors/{id}` | Get content connector by ID |
| POST | `/api/v1/automation-pilot/content-connectors` | Create content connector |
| PUT | `/api/v1/automation-pilot/content-connectors/{id}` | Update content connector |
| DELETE | `/api/v1/automation-pilot/content-connectors/{id}` | Delete content connector |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `AUTOMATION_PILOT_HOST` | `0.0.0.0` | Server bind address |
| `AUTOMATION_PILOT_PORT` | `8110` | Server listen port |

## Build and Run

### Local

```bash
dub build
./uim-automation-pilot-platform-service
```

### Docker

```bash
docker build -t uim-automation-pilot .
docker run -p 8110:8110 uim-automation-pilot
```

### Podman

```bash
podman build -t uim-automation-pilot -f Containerfile .
podman run -p 8110:8110 uim-automation-pilot
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
