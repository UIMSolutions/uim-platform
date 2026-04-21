# UIM Integration Automation Platform Service

A microservice for guided integration workflow automation, system landscape
management, and destination connectivity, inspired by **SAP Cloud Integration
Automation Service (CIAS)**. Built with **D** and **vibe.d**, following
**Clean Architecture** and **Hexagonal Architecture** (Ports & Adapters)
principles.

Part of the [UIM Platform](https://www.sueel.de/uim/sap) suite.

## Features

| Capability | Description |
|---|---|
| **Integration Scenarios** | Pre-built and custom scenario templates with step definitions, category taxonomy (Lead-to-Cash, Source-to-Pay, Recruit-to-Retire, Design-to-Operate, etc.), and lifecycle management (Draft → Active → Deprecated → Archived) |
| **Workflow Orchestration** | Runtime workflow instances derived from scenario templates with state machine (Planned → In Progress → Completed / Terminated / Failed / Suspended), dependency-based step ordering, and tenant-level limit of 15 concurrent workflows |
| **Workflow Steps / Tasks** | Four step types (Manual, Automated, Approval, Notification) with priority levels (Low → Critical), assignee tracking, dependency management, and guided task completion |
| **System Landscape** | Registry of SAP and third-party systems (S/4HANA, S/4HANA Cloud, BTP, SuccessFactors, Ariba, Concur, Fieldglass, IBP, Build Work Zone, On-Premise, Third-Party) with connection testing and status monitoring |
| **Destinations** | Named connectivity endpoints supporting HTTP, RFC, OData, SOAP, and REST API protocols with authentication methods (Basic, OAuth2 Client Credentials, OAuth2 SAML, Certificate, SAML Bearer, Principal Propagation, No Auth) and proxy routing (Internet, On-Premise, Private Link) |
| **Monitoring & Execution Logs** | Execution history with outcome tracking (Success, Failure, Skipped, Timeout, Error), failure filtering, and per-workflow summary aggregation |
| **Workflow Engine** | Domain service for advancing workflows through steps, checking dependency satisfaction, and enforcing the 15-workflow-per-tenant concurrency limit |
| **Step Executor** | Domain service for step lifecycle transitions (start, complete, fail, skip) with automatic execution log recording |

## Architecture

```
integration-automation/
├── source/
│   ├── app.d                                  # Entry point & composition root
│   ├── domain/                                # Pure business logic (no dependencies)
│   │   ├── types.d                            #   Type aliases & enums
│   │   ├── entities/                          #   Core domain structs
│   │   │   ├── integration_scenario.d         #     Scenario templates with step definitions
│   │   │   ├── workflow.d                     #     Runtime workflow instances
│   │   │   ├── workflow_step.d                #     Individual task / step execution
│   │   │   ├── system_connection.d            #     System landscape entries
│   │   │   ├── destination.d                  #     Connectivity endpoints
│   │   │   └── execution_log.d                #     Audit trail for step executions
│   │   ├── ports/                             #   Repository interfaces (ports)
│   │   │   ├── scenario_repository.d
│   │   │   ├── workflow_repository.d
│   │   │   ├── step_repository.d
│   │   │   ├── system_repository.d
│   │   │   ├── destination_repository.d
│   │   │   └── execution_log_repository.d
│   │   └── services/                          #   Stateless domain services
│   │       ├── workflow_engine.d              #     Workflow advancement & limit enforcement
│   │       └── step_executor.d                #     Step lifecycle transitions & logging
│   ├── application/                           #   Application layer (use cases)
│   │   ├── dto.d                              #     Request / Response DTOs & CommandResult
│   │   └── usecases/                         #     Application services
│   │       ├── manage.scenarios.d
│   │       ├── manage.workflows.d
│   │       ├── manage.steps.d
│   │       ├── manage.systems.d
│   │       ├── manage.destinations.d
│   │       └── monitor_executions.d
│   ├── infrastructure/                        #   Technical adapters
│   │   ├── config.d                           #     Environment-based configuration
│   │   ├── container.d                        #     Dependency injection wiring
│   │   └── persistence/                       #     In-memory repository implementations
│   │       ├── in_memory_scenario_repo.d
│   │       ├── in_memory_workflow_repo.d
│   │       ├── in_memory_step_repo.d
│   │       ├── in_memory_system_repo.d
│   │       ├── in_memory_destination_repo.d
│   │       └── in_memory_execution_log_repo.d
│   └── presentation/                          #   HTTP driving adapters
│       └── http/
│           ├── json_utils.d                   #     JSON helper functions
│           ├── health_controller.d
│           ├── scenario_controller.d
│           ├── workflow_controller.d
│           ├── step_controller.d
│           ├── system_controller.d
│           ├── destination_controller.d
│           └── monitoring_controller.d
└── dub.sdl
```

## Multi-Tenancy

Every request must include the `X-Tenant-Id` HTTP header to scope data to a
specific tenant. Step-level operations also use `X-User-Id` for task assignment
and audit trail purposes.

| Header | Required | Description |
|---|---|---|
| `X-Tenant-Id` | **Yes** | Tenant identifier — all reads/writes are scoped to this tenant |
| `X-User-Id` | Contextual | User identifier — required for step start/complete/fail/skip and my-tasks |

## REST API

All endpoints are prefixed with `/api/v1/`. Request and response bodies use
`Content-Type: application/json`.

### Health

```
GET  /api/v1/health                         → {"status":"UP","service":"integration-automation"}
```

### Integration Scenarios

```
GET    /api/v1/scenarios                    List all scenarios
POST   /api/v1/scenarios                    Create a scenario
GET    /api/v1/scenarios/{id}               Get scenario by ID
PUT    /api/v1/scenarios/{id}               Update a scenario
DELETE /api/v1/scenarios/{id}               Delete a scenario
```

### Workflows

```
GET    /api/v1/workflows                    List all workflows
POST   /api/v1/workflows                    Create a workflow from a scenario template
GET    /api/v1/workflows/{id}               Get workflow by ID
POST   /api/v1/workflows/start/{id}         Start a workflow
POST   /api/v1/workflows/suspend/{id}       Suspend a running workflow
POST   /api/v1/workflows/resume/{id}        Resume a suspended workflow
POST   /api/v1/workflows/terminate/{id}     Terminate a workflow
DELETE /api/v1/workflows/{id}               Delete a workflow
```

### Workflow Steps / Tasks

```
GET    /api/v1/steps                        List all steps
POST   /api/v1/steps                        Create a step
GET    /api/v1/steps/{id}                   Get step by ID
POST   /api/v1/steps/start/{id}             Start a step
POST   /api/v1/steps/complete/{id}          Complete a step
POST   /api/v1/steps/fail/{id}              Fail a step
POST   /api/v1/steps/skip/{id}              Skip a step
GET    /api/v1/my-tasks                     List tasks assigned to authenticated user
DELETE /api/v1/steps/{id}                   Delete a step
```

### System Landscape

```
GET    /api/v1/systems                      List all systems
POST   /api/v1/systems                      Register a system
GET    /api/v1/systems/{id}                 Get system by ID
PUT    /api/v1/systems/{id}                 Update a system
POST   /api/v1/systems/test/{id}            Test system connectivity
DELETE /api/v1/systems/{id}                 Delete a system
```

### Destinations

```
GET    /api/v1/destinations                 List all destinations
POST   /api/v1/destinations                 Create a destination
GET    /api/v1/destinations/{id}            Get destination by ID
PUT    /api/v1/destinations/{id}            Update a destination
DELETE /api/v1/destinations/{id}            Delete a destination
```

### Monitoring

```
GET    /api/v1/monitoring/logs              List all execution logs
GET    /api/v1/monitoring/failures          List failed execution logs
GET    /api/v1/monitoring/summary/{id}      Get workflow execution summary
```

## Build and Run

```bash
# Build
cd integration-automation
dub build

# Run (default: 0.0.0.0:8090)
./build/uim-integration-automation-platform-service

# Override host/port via environment
CIA_HOST=127.0.0.1 CIA_PORT=9090 ./build/uim-integration-automation-platform-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `CIA_HOST` | `0.0.0.0` | HTTP bind address |
| `CIA_PORT` | `8090` | HTTP listen port |

## Domain Model Overview

### Type Aliases

| Alias | Underlying | Purpose |
|---|---|---|
| `ScenarioId` | `string` | Integration scenario identifier |
| `WorkflowId` | `string` | Workflow instance identifier |
| `StepId` | `string` | Workflow step identifier |
| `SystemConnectionId` | `string` | System landscape entry identifier |
| `DestinationId` | `string` | Destination endpoint identifier |
| `TaskAssignmentId` | `string` | Task assignment identifier |
| `ExecutionLogId` | `string` | Execution log entry identifier |
| `TenantId` | `string` | Tenant identifier |
| `UserId` | `string` | User identifier |

### Enumerations

| Enum | Values |
|---|---|
| **ScenarioStatus** | Draft, Active, Deprecated, Archived |
| **WorkflowStatus** | Planned, InProgress, Completed, Terminated, Failed, Suspended |
| **StepType** | Manual, Automated, Approval, Notification |
| **StepStatus** | Pending, InProgress, Completed, Skipped, Failed, Blocked |
| **StepPriority** | Low, Medium, High, Critical |
| **SystemType** | SapS4Hana, SapS4HanaCloud, SapBtp, SapSuccessFactors, SapAriba, SapConcur, SapFieldglass, SapIntegratedBusinessPlanning, SapBuildWorkZone, OnPremise, ThirdParty |
| **ConnectionStatus** | Active, Inactive, Error, Testing |
| **DestinationType** | HTTP, RFC, OData, SOAP, RestApi |
| **AuthenticationType** | Basic, OAuth2ClientCredentials, OAuth2Saml, Certificate, SamlBearer, PrincipalPropagation, NoAuthentication |
| **ProxyType** | Internet, OnPremise, PrivateLink |
| **ExecutionOutcome** | Success, Failure, Skipped, Timeout, Error |
| **ScenarioCategory** | LeadToCash, SourceToPay, RecruitToRetire, DesignToOperate, BtpServices, S4HanaIntegration, CommunicationManagement, Custom |

### Domain Services

- **WorkflowEngine** — advances a workflow through its steps based on dependency resolution, enforces the 15-concurrent-workflow limit per tenant
- **StepExecutor** — manages step lifecycle transitions (start → complete / fail / skip) and automatically records execution log entries

### Entities

#### IntegrationScenario

| Field | Type | Description |
|---|---|---|
| `id` | `ScenarioId` | Unique scenario identifier |
| `tenantId` | `TenantId` | Owning tenant |
| `name` | `string` | Scenario name (e.g. "SAP S/4HANA Cloud Integration") |
| `description` | `string` | Detailed description |
| `category` | `ScenarioCategory` | Taxonomy category |
| `version_` | `string` | Version string (default `"1.0"`) |
| `status` | `ScenarioStatus` | Lifecycle state (default `draft`) |
| `sourceSystemType` | `SystemType` | Source system type for this scenario |
| `targetSystemType` | `SystemType` | Target system type for this scenario |
| `prerequisites` | `string[]` | Prerequisite descriptions |
| `stepTemplates` | `ScenarioStepTemplate[]` | Ordered step definitions |
| `createdBy` | `string` | Creator user ID |
| `createdAt` | `long` | Creation timestamp (hnsecs) |
| `updatedAt` | `long` | Last update timestamp |

#### ScenarioStepTemplate

| Field | Type | Description |
|---|---|---|
| `name` | `string` | Step name |
| `description` | `string` | Step description |
| `type_` | `StepType` | Manual, Automated, Approval, or Notification |
| `priority` | `StepPriority` | Priority level (default `medium`) |
| `sequenceNumber` | `int` | Execution order number |
| `assignedRole` | `string` | Role responsible for the task |
| `instructions` | `string` | Detailed task instructions |
| `automationEndpoint` | `string` | API endpoint for automated steps |
| `automationPayload` | `string` | Payload template for automation |
| `requiresSourceSystem` | `bool` | Whether step uses source system |
| `requiresTargetSystem` | `bool` | Whether step uses target system |
| `dependsOnSteps` | `int[]` | Sequence numbers of prerequisite steps |
| `estimatedDurationMinutes` | `int` | Estimated time to complete |

#### Workflow

| Field | Type | Description |
|---|---|---|
| `id` | `WorkflowId` | Unique workflow identifier |
| `tenantId` | `TenantId` | Owning tenant |
| `scenarioId` | `ScenarioId` | Parent scenario template |
| `name` | `string` | Workflow name |
| `description` | `string` | Description |
| `status` | `WorkflowStatus` | State machine state (default `planned`) |
| `currentStepIndex` | `int` | 0-based index of current step |
| `totalSteps` | `int` | Total number of steps |
| `completedSteps` | `int` | Count of completed steps |
| `sourceSystemConnectionId` | `SystemConnectionId` | Selected source system |
| `targetSystemConnectionId` | `SystemConnectionId` | Selected target system |
| `createdBy` | `string` | Creator user ID |
| `startedAt` | `long` | Workflow start timestamp |
| `completedAt` | `long` | Workflow completion timestamp |
| `createdAt` | `long` | Creation timestamp |
| `updatedAt` | `long` | Last update timestamp |

#### WorkflowStep

| Field | Type | Description |
|---|---|---|
| `id` | `StepId` | Unique step identifier |
| `workflowId` | `WorkflowId` | Parent workflow |
| `tenantId` | `TenantId` | Owning tenant |
| `name` | `string` | Step name |
| `description` | `string` | Step description |
| `type_` | `StepType` | Step type |
| `status` | `StepStatus` | Current status (default `pending`) |
| `priority` | `StepPriority` | Priority level (default `medium`) |
| `sequenceNumber` | `int` | Execution order number |
| `assignedTo` | `string` | Assigned user ID |
| `assignedRole` | `string` | Required role |
| `instructions` | `string` | Detailed instructions |
| `automationEndpoint` | `string` | Endpoint for automated execution |
| `automationPayload` | `string` | Payload for automated execution |
| `sourceSystemConnectionId` | `SystemConnectionId` | Source system reference |
| `targetSystemConnectionId` | `SystemConnectionId` | Target system reference |
| `dependencies` | `StepId[]` | IDs of steps that must complete first |
| `result` | `string` | Outcome details / response |
| `errorMessage` | `string` | Error message on failure |
| `startedAt` | `long` | Step start timestamp |
| `completedAt` | `long` | Step completion timestamp |
| `createdAt` | `long` | Creation timestamp |
| `estimatedDurationMinutes` | `int` | Estimated time to complete |

#### SystemConnection

| Field | Type | Description |
|---|---|---|
| `id` | `SystemConnectionId` | Unique system identifier |
| `tenantId` | `TenantId` | Owning tenant |
| `name` | `string` | System display name (e.g. "Production S/4HANA") |
| `description` | `string` | Description |
| `systemType` | `SystemType` | Type of SAP or third-party system |
| `host` | `string` | Hostname or IP |
| `port` | `ushort` | Port number |
| `client` | `string` | SAP client number |
| `protocol` | `string` | Protocol (default `"https"`) |
| `status` | `ConnectionStatus` | Connection status (default `inactive`) |
| `environment` | `string` | e.g. "production", "staging", "dev" |
| `region` | `string` | e.g. "eu10", "us20" |
| `systemId` | `string` | SAP System ID (SID) |
| `tenant` | `string` | Subaccount / tenant identifier |
| `createdBy` | `string` | Creator user ID |
| `createdAt` | `long` | Creation timestamp |
| `updatedAt` | `long` | Last update timestamp |

#### Destination

| Field | Type | Description |
|---|---|---|
| `id` | `DestinationId` | Unique destination identifier |
| `tenantId` | `TenantId` | Owning tenant |
| `name` | `string` | Unique destination name per tenant |
| `description` | `string` | Description |
| `systemId` | `SystemConnectionId` | Linked system connection |
| `destinationType` | `DestinationType` | Protocol (HTTP, RFC, OData, SOAP, RestApi) |
| `url` | `string` | Full URL for the destination |
| `authenticationType` | `AuthenticationType` | Authentication method |
| `proxyType` | `ProxyType` | Routing (default `internet`) |
| `cloudConnectorLocationId` | `string` | For on-premise routing |
| `user` | `string` | Basic auth user |
| `tokenServiceUrl` | `string` | OAuth token endpoint |
| `tokenServiceUser` | `string` | OAuth token service user |
| `audience` | `string` | OAuth audience |
| `scope_` | `string` | OAuth scope |
| `isEnabled` | `bool` | Whether destination is active (default `true`) |
| `createdBy` | `string` | Creator user ID |
| `createdAt` | `long` | Creation timestamp |
| `updatedAt` | `long` | Last update timestamp |

#### ExecutionLog

| Field | Type | Description |
|---|---|---|
| `id` | `ExecutionLogId` | Unique log identifier |
| `workflowId` | `WorkflowId` | Parent workflow |
| `stepId` | `StepId` | Related step |
| `tenantId` | `TenantId` | Owning tenant |
| `action` | `string` | Action name (e.g. "step.started", "step.completed") |
| `outcome` | `ExecutionOutcome` | Execution outcome |
| `message` | `string` | Human-readable message |
| `details` | `string` | Extended info (JSON payload, error trace) |
| `executedBy` | `string` | User ID or "system" |
| `durationMs` | `long` | Execution duration in milliseconds |
| `timestamp` | `long` | Event timestamp |

### Business Rules

| Rule | Description |
|---|---|
| **Workflow Limit** | Max 15 active (in-progress) workflows per tenant |
| **Scenario Must Be Active** | A workflow can only be created from a scenario in `active` status |
| **Dependency Resolution** | A step cannot start until all steps in its `dependencies` list are `completed` |
| **Step State Machine** | `pending` → `inProgress` → `completed` / `failed` / `skipped`; steps in `blocked` state wait for dependencies |
| **Workflow Advancement** | After a step completes or is skipped, the `WorkflowEngine` checks if the next pending step's dependencies are met and advances `currentStepIndex` |
| **Workflow Completion** | When all steps are completed or skipped, the workflow automatically transitions to `completed` |
| **Unique Destination Names** | Destination names must be unique within a tenant |
| **System Validation** | When creating a destination with a `systemId`, the referenced system must exist |
| **Connection Testing** | `POST /api/v1/systems/test/{id}` simulates a test and sets the system status to `active` |

### Error Response Format

All error responses return a JSON body:

```json {
  "error": "Human-readable error message",
  "status": 400
}
```

| HTTP Status | Meaning |
|---|---|
| `200` | Success |
| `201` | Created (POST with new resource) |
| `400` | Validation error or business rule violation |
| `404` | Resource not found |
| `500` | Internal server error |

### Request / Response Examples

#### Create a Scenario

```bash
curl -X POST http://localhost:8090/api/v1/scenarios \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-001" \
  -d '{
    "name": "S/4HANA Cloud Migration",
    "description": "End-to-end S/4HANA Cloud integration setup",
    "category": "s4HanaIntegration",
    "version": "1.0",
    "sourceSystemType": "sapS4Hana",
    "targetSystemType": "sapS4HanaCloud",
    "createdBy": "admin",
    "prerequisites": ["VPN connectivity established", "SAP user accounts provisioned"],
    "stepTemplates": [
      {
        "name": "Configure RFC Connection",
        "description": "Set up RFC destination in SM59",
        "type_": "manual",
        "priority": "high",
        "sequenceNumber": 1,
        "assignedRole": "BASIS_ADMIN",
        "instructions": "Open SM59 and create a new RFC destination..."
      }
    ]
  }'
```

Response (`201`):

```json { "id": "550e8400-e29b-41d4-a716-446655440000" }
```

#### Create a Workflow from Scenario

```bash
curl -X POST http://localhost:8090/api/v1/workflows \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-001" \
  -d '{
    "scenarioId": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Q1 Migration Workflow",
    "sourceSystemConnectionId": "sys-001",
    "targetSystemConnectionId": "sys-002",
    "createdBy": "project-manager"
  }'
```

#### Start and Complete a Step

```bash
# Start a step
curl -X POST http://localhost:8090/api/v1/steps/start/step-uuid \
  -H "X-Tenant-Id: tenant-001" \
  -H "X-User-Id: basis-admin-01"

# Complete a step
curl -X POST http://localhost:8090/api/v1/steps/complete/step-uuid \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: tenant-001" \
  -d '{ "completedBy": "basis-admin-01", "result": "RFC destination created successfully" }'
```

#### Get Workflow Summary

```bash
curl http://localhost:8090/api/v1/monitoring/summary/workflow-uuid \
  -H "X-Tenant-Id: tenant-001"
```

Response:

```json {
  "workflowId": "workflow-uuid",
  "workflowName": "Q1 Migration Workflow",
  "status": "inProgress",
  "totalSteps": 5,
  "completedSteps": 2,
  "inProgressSteps": 1,
  "pendingSteps": 2,
  "failedSteps": 0,
  "skippedSteps": 0,
  "totalLogEntries": 5
}
```

---

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        HTTP Clients                              │
│               (Browser / CLI / API Consumer)                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │ HTTP/JSON + X-Tenant-Id header
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Presentation Layer  «driving adapters»                          │
│                                                                  │
│  ScenarioController · WorkflowController · StepController        │
│  SystemController · DestinationController · MonitoringController │
│  HealthController                                                │
└──────────────────────────┬──────────────────────────────────────┘
                           │ delegates to
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Application Layer  «use cases»                                  │
│                                                                  │
│  ManageScenariosUseCase · ManageWorkflowsUseCase                 │
│  ManageStepsUseCase     · ManageSystemsUseCase                   │
│  ManageDestinationsUseCase · MonitorExecutionsUseCase             │
└──────────────────────────┬──────────────────────────────────────┘
                           │ depends on ports + domain services
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Domain Layer  «pure business logic»                             │
│                                                                  │
│  Entities:  IntegrationScenario · Workflow · WorkflowStep        │
│             SystemConnection · Destination · ExecutionLog         │
│                                                                  │
│  Ports:     ScenarioRepository · WorkflowRepository              │
│             StepRepository · SystemRepository                    │
│             DestinationRepository · ExecutionLogRepository        │
│                                                                  │
│  Services:  WorkflowEngine · StepExecutor                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │ implemented by
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Infrastructure Layer  «driven adapters»                         │
│                                                                  │
│  AppConfig (CIA_HOST/CIA_PORT)  ·  Container (DI wiring)         │
│                                                                  │
│  MemoryScenarioRepo · MemoryWorkflowRepo                    │
│  MemoryStepRepo     · MemorySystemRepo                      │
│  MemoryDestinationRepo · MemoryExecutionLogRepo              │
└─────────────────────────────────────────────────────────────────┘
```

---

*Part of the [UIM Platform](https://www.sueel.de/uim/sap) suite.*
*© 2018–2026, Ozan Nurettin Suel, UI Manufaktur — Apache-2.0*

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
