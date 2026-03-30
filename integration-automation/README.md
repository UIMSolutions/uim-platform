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
│   │   └── use_cases/                         #     Application services
│   │       ├── manage_scenarios.d
│   │       ├── manage_workflows.d
│   │       ├── manage_steps.d
│   │       ├── manage_systems.d
│   │       ├── manage_destinations.d
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

## REST API

All endpoints are prefixed with `/api/v1/`.

### Health

```
GET  /api/v1/health                         → {"status":"healthy","service":"integration-automation","version":"1.0.0"}
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
| `SystemId` | `string` | System landscape entry identifier |
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
