# Integration Automation – NAF v4 Architecture Description

This document describes the **UIM Integration Automation Platform Service**
using the **NATO Architecture Framework v4 (NAF v4)** viewpoints, adapted for
a microservice based on SAP Cloud Integration Automation Service (CIAS)
concepts.

---

## 1. NAF v4 Grid Mapping

| Viewpoint | View | Section |
|---|---|---|
| **NCV** – Capability | C1 – Capability Taxonomy | §2 |
| **NCV** – Capability | C2 – Enterprise Vision | §2 |
| **NSOV** – Service | NSOV-1 – Service Taxonomy | §3 |
| **NSOV** – Service | NSOV-2 – Service Definitions | §3 |
| **NOV** – Operational | NOV-2 – Operational Node Connectivity | §4 |
| **NLV** – Logical | NLV-1 – Logical Data Model | §5 |
| **NPV** – Physical | NPV-1 – Physical Deployment | §6 |
| **NIV** – Information | NIV-1 – Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
C1  Integration Automation Capability
├── C1.1  Scenario Management
│   ├── C1.1.1  Scenario Lifecycle (Draft → Active → Deprecated → Archived)
│   ├── C1.1.2  Scenario Templates with Step Definitions
│   └── C1.1.3  Scenario Categorisation (Lead-to-Cash, Source-to-Pay, ...)
├── C1.2  Workflow Orchestration
│   ├── C1.2.1  Workflow Instance Creation from Scenario Templates
│   ├── C1.2.2  Workflow State Machine (Planned → InProgress → Completed / Failed / Terminated / Suspended)
│   ├── C1.2.3  Workflow Advancement (dependency-based step progression)
│   └── C1.2.4  Tenant Concurrency Limit (max 15 active workflows)
├── C1.3  Task / Step Execution
│   ├── C1.3.1  Step Types (Manual, Automated, Approval, Notification)
│   ├── C1.3.2  Step Lifecycle (Pending → InProgress → Completed / Failed / Skipped / Blocked)
│   ├── C1.3.3  Task Assignment & My-Tasks View
│   └── C1.3.4  Step Dependency Management
├── C1.4  System Landscape
│   ├── C1.4.1  SAP System Registry (S/4HANA, BTP, SuccessFactors, Ariba, Concur, ...)
│   ├── C1.4.2  Third-Party & On-Premise System Registration
│   └── C1.4.3  Connection Testing & Status Monitoring
├── C1.5  Destination Management
│   ├── C1.5.1  Protocol Support (HTTP, RFC, OData, SOAP, REST API)
│   ├── C1.5.2  Authentication Methods (Basic, OAuth2, Certificate, SAML, Principal Propagation)
│   └── C1.5.3  Proxy Routing (Internet, On-Premise, Private Link)
└── C1.6  Monitoring & Audit
    ├── C1.6.1  Execution Log Recording
    ├── C1.6.2  Failure Filtering & Analysis
    └── C1.6.3  Per-Workflow Summary Aggregation
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide guided, semi-automated integration workflows for complex SAP and third-party system landscapes |
| **Vision** | A single orchestration hub that standardises integration runbooks, reduces manual effort, and provides full auditability of integration tasks |
| **Strategic Goal** | Accelerate SAP S/4HANA migration and hybrid cloud integration projects by offering reusable scenario templates with step-by-step guidance |
| **Scope** | Manages the full lifecycle from scenario definition through workflow execution, system connectivity, and post-execution monitoring |
| **Stakeholders** | Integration Consultants, SAP Basis Administrators, Cloud Architects, Project Managers, Compliance Officers |

---

## 3. Service View (NSOV)

### NSOV-1 – Service Taxonomy

```
NSOV-1  Integration Automation Services
├── SVC-SCEN   Scenario Management Services
├── SVC-WF     Workflow Orchestration Services
├── SVC-STEP   Step / Task Execution Services
├── SVC-SYS    System Landscape Services
├── SVC-DEST   Destination Management Services
├── SVC-MON    Monitoring & Execution Log Services
└── SVC-HEALTH Health / Readiness Services
```

### NSOV-2 – Service Definitions

| Service ID | Name | Interface | Protocol | Path Prefix | Methods |
|---|---|---|---|---|---|
| SVC-SCEN-LIST | List Scenarios | REST | HTTP/JSON | `/api/v1/scenarios` | GET |
| SVC-SCEN-CREATE | Create Scenario | REST | HTTP/JSON | `/api/v1/scenarios` | POST |
| SVC-SCEN-GET | Get Scenario | REST | HTTP/JSON | `/api/v1/scenarios/{id}` | GET |
| SVC-SCEN-UPDATE | Update Scenario | REST | HTTP/JSON | `/api/v1/scenarios/{id}` | PUT |
| SVC-SCEN-DELETE | Delete Scenario | REST | HTTP/JSON | `/api/v1/scenarios/{id}` | DELETE |
| SVC-WF-LIST | List Workflows | REST | HTTP/JSON | `/api/v1/workflows` | GET |
| SVC-WF-CREATE | Create Workflow | REST | HTTP/JSON | `/api/v1/workflows` | POST |
| SVC-WF-GET | Get Workflow | REST | HTTP/JSON | `/api/v1/workflows/{id}` | GET |
| SVC-WF-START | Start Workflow | REST | HTTP/JSON | `/api/v1/workflows/start/{id}` | POST |
| SVC-WF-SUSPEND | Suspend Workflow | REST | HTTP/JSON | `/api/v1/workflows/suspend/{id}` | POST |
| SVC-WF-RESUME | Resume Workflow | REST | HTTP/JSON | `/api/v1/workflows/resume/{id}` | POST |
| SVC-WF-TERM | Terminate Workflow | REST | HTTP/JSON | `/api/v1/workflows/terminate/{id}` | POST |
| SVC-WF-DELETE | Delete Workflow | REST | HTTP/JSON | `/api/v1/workflows/{id}` | DELETE |
| SVC-STEP-LIST | List Steps | REST | HTTP/JSON | `/api/v1/steps` | GET |
| SVC-STEP-CREATE | Create Step | REST | HTTP/JSON | `/api/v1/steps` | POST |
| SVC-STEP-GET | Get Step | REST | HTTP/JSON | `/api/v1/steps/{id}` | GET |
| SVC-STEP-START | Start Step | REST | HTTP/JSON | `/api/v1/steps/start/{id}` | POST |
| SVC-STEP-COMPLETE | Complete Step | REST | HTTP/JSON | `/api/v1/steps/complete/{id}` | POST |
| SVC-STEP-FAIL | Fail Step | REST | HTTP/JSON | `/api/v1/steps/fail/{id}` | POST |
| SVC-STEP-SKIP | Skip Step | REST | HTTP/JSON | `/api/v1/steps/skip/{id}` | POST |
| SVC-STEP-MY | My Tasks | REST | HTTP/JSON | `/api/v1/my-tasks` | GET |
| SVC-STEP-DELETE | Delete Step | REST | HTTP/JSON | `/api/v1/steps/{id}` | DELETE |
| SVC-SYS-LIST | List Systems | REST | HTTP/JSON | `/api/v1/systems` | GET |
| SVC-SYS-CREATE | Register System | REST | HTTP/JSON | `/api/v1/systems` | POST |
| SVC-SYS-GET | Get System | REST | HTTP/JSON | `/api/v1/systems/{id}` | GET |
| SVC-SYS-UPDATE | Update System | REST | HTTP/JSON | `/api/v1/systems/{id}` | PUT |
| SVC-SYS-TEST | Test Connection | REST | HTTP/JSON | `/api/v1/systems/test/{id}` | POST |
| SVC-SYS-DELETE | Delete System | REST | HTTP/JSON | `/api/v1/systems/{id}` | DELETE |
| SVC-DEST-LIST | List Destinations | REST | HTTP/JSON | `/api/v1/destinations` | GET |
| SVC-DEST-CREATE | Create Destination | REST | HTTP/JSON | `/api/v1/destinations` | POST |
| SVC-DEST-GET | Get Destination | REST | HTTP/JSON | `/api/v1/destinations/{id}` | GET |
| SVC-DEST-UPDATE | Update Destination | REST | HTTP/JSON | `/api/v1/destinations/{id}` | PUT |
| SVC-DEST-DELETE | Delete Destination | REST | HTTP/JSON | `/api/v1/destinations/{id}` | DELETE |
| SVC-MON-LOGS | List Execution Logs | REST | HTTP/JSON | `/api/v1/monitoring/logs` | GET |
| SVC-MON-FAIL | List Failures | REST | HTTP/JSON | `/api/v1/monitoring/failures` | GET |
| SVC-MON-SUM | Workflow Summary | REST | HTTP/JSON | `/api/v1/monitoring/summary/{id}` | GET |
| SVC-HEALTH | Health Check | REST | HTTP/JSON | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
                     ┌──────────────────────────────────┐
                     │          HTTP Clients             │
                     │  (Browser / CLI / API Consumer)   │
                     └──────────────┬───────────────────┘
                                    │ HTTP / JSON
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Presentation Layer             │
                     │  ┌────────────────────────────┐  │
                     │  │ ScenarioController         │  │
                     │  │ WorkflowController         │  │
                     │  │ StepController             │  │
                     │  │ SystemController           │  │
                     │  │ DestinationController      │  │
                     │  │ MonitoringController       │  │
                     │  │ HealthController           │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ calls
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Application Layer              │
                     │  ┌────────────────────────────┐  │
                     │  │ ManageScenariosUseCase      │  │
                     │  │ ManageWorkflowsUseCase      │  │
                     │  │ ManageStepsUseCase          │  │
                     │  │ ManageSystemsUseCase        │  │
                     │  │ ManageDestinationsUseCase   │  │
                     │  │ MonitorExecutionsUseCase    │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ depends on ports
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Domain Layer                   │
                     │  ┌────────────────────────────┐  │
                     │  │ Entities:                   │  │
                     │  │   IntegrationScenario       │  │
                     │  │   Workflow, WorkflowStep    │  │
                     │  │   SystemConnection          │  │
                     │  │   Destination               │  │
                     │  │   ExecutionLog              │  │
                     │  ├────────────────────────────┤  │
                     │  │ Ports (Interfaces):         │  │
                     │  │   ScenarioRepository        │  │
                     │  │   WorkflowRepository        │  │
                     │  │   StepRepository            │  │
                     │  │   SystemRepository          │  │
                     │  │   DestinationRepository     │  │
                     │  │   ExecutionLogRepository    │  │
                     │  ├────────────────────────────┤  │
                     │  │ Domain Services:            │  │
                     │  │   WorkflowEngine            │  │
                     │  │   StepExecutor              │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ implements
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Infrastructure Layer           │
                     │  ┌────────────────────────────┐  │
                     │  │ AppConfig (CIA_HOST/PORT)   │  │
                     │  │ Container (DI wiring)       │  │
                     │  ├────────────────────────────┤  │
                     │  │ In-Memory Repositories:     │  │
                     │  │   MemoryScenarioRepo      │  │
                     │  │   MemoryWorkflowRepo      │  │
                     │  │   MemoryStepRepo          │  │
                     │  │   MemorySystemRepo        │  │
                     │  │   MemoryDestinationRepo   │  │
                     │  │   MemoryExecutionLogRepo  │  │
                     │  └────────────────────────────┘  │
                     └──────────────────────────────────┘
                                    │
                     ┌──────────────┼───────────────────┐
                     ▼              ▼                    ▼
              ┌──────────┐  ┌──────────────┐  ┌────────────┐
              │ Audit Log│  │ Identity &   │  │  Portal    │
              │ Service  │  │ Directory    │  │  Service   │
              └──────────┘  └──────────────┘  └────────────┘
```

**Operational Information Exchanges:**

| Exchange | From | To | Content | Frequency |
|---|---|---|---|---|
| OIE-1 | Client | Integration Automation | Scenario definitions & templates | On demand |
| OIE-2 | Client | Integration Automation | Workflow creation & lifecycle commands | On demand |
| OIE-3 | Client | Integration Automation | Step execution commands (start, complete, fail, skip) | Per task |
| OIE-4 | Client | Integration Automation | System landscape registrations & updates | On demand |
| OIE-5 | Client | Integration Automation | Destination configurations | On demand |
| OIE-6 | Integration Automation | Client | Execution logs, failure reports, workflow summaries | On demand |
| OIE-7 | Integration Automation | Target System | Connection test probes | Per test request |
| OIE-8 | Integration Automation | Audit Log | Operation audit trail | Per operation |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

```
┌──────────────────────────────────────────────────────────────────┐
│  Scenario Domain                                                  │
│                                                                   │
│  ┌─────────────────────────────┐                                 │
│  │  IntegrationScenario         │                                 │
│  ├─────────────────────────────┤                                 │
│  │ id : ScenarioId              │                                 │
│  │ tenantId : TenantId          │    ┌───────────────────────┐   │
│  │ name, description : string   │1:N │ ScenarioStepTemplate   │   │
│  │ category : ScenarioCategory  │───▸├───────────────────────┤   │
│  │ version_ : string            │    │ name, description      │   │
│  │ status : ScenarioStatus      │    │ type_ : StepType       │   │
│  │ sourceSystemType : SystemType│    │ priority : StepPriority │   │
│  │ targetSystemType : SystemType│    │ sequenceNumber : int    │   │
│  │ prerequisites : string[]     │    │ assignedRole : string   │   │
│  │ createdBy : string           │    │ instructions : string   │   │
│  │ createdAt, updatedAt : long  │    │ automationEndpoint      │   │
│  └─────────────────────────────┘    │ automationPayload       │   │
│                                      │ requiresSourceSystem    │   │
│                                      │ requiresTargetSystem    │   │
│                                      │ dependsOnSteps : int[]  │   │
│                                      │ estimatedDurationMinutes│   │
│                                      └───────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Workflow Domain                                                  │
│                                                                   │
│  ┌─────────────────────────────┐    ┌────────────────────────┐   │
│  │  Workflow                    │1:N │  WorkflowStep           │   │
│  ├─────────────────────────────┤───▸├────────────────────────┤   │
│  │ id : WorkflowId              │    │ id : StepId             │   │
│  │ tenantId : TenantId          │    │ workflowId : WorkflowId │   │
│  │ scenarioId : ScenarioId      │    │ tenantId : TenantId     │   │
│  │ name, description : string   │    │ name, description       │   │
│  │ status : WorkflowStatus      │    │ type_ : StepType        │   │
│  │ currentStepIndex : int       │    │ status : StepStatus     │   │
│  │ totalSteps : int             │    │ priority : StepPriority  │   │
│  │ completedSteps : int         │    │ sequenceNumber : int    │   │
│  │ sourceSystemId : SystemId    │    │ assignedTo : UserId     │   │
│  │ targetSystemId : SystemId    │    │ assignedRole : string   │   │
│  │ createdBy : UserId           │    │ instructions : string   │   │
│  │ startedAt, completedAt       │    │ automationEndpoint      │   │
│  │ createdAt, updatedAt : long  │    │ automationPayload       │   │
│  └─────────────────────────────┘    │ sourceSystemId          │   │
│                                      │ targetSystemId          │   │
│                                      │ dependencies : StepId[] │   │
│                                      │ result : string         │   │
│                                      │ errorMessage : string   │   │
│                                      │ startedAt, completedAt  │   │
│                                      │ createdAt : long        │   │
│                                      │ estimatedDurationMinutes│   │
│                                      └────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  System Landscape Domain                                          │
│                                                                   │
│  ┌─────────────────────────────┐    ┌────────────────────────┐   │
│  │  SystemConnection            │1:N │  Destination            │   │
│  ├─────────────────────────────┤───▸├────────────────────────┤   │
│  │ id : SystemId                │    │ id : DestinationId      │   │
│  │ tenantId : TenantId          │    │ tenantId : TenantId     │   │
│  │ name, description : string   │    │ name, description       │   │
│  │ systemType : SystemType      │    │ systemId : SystemId     │   │
│  │ host : string                │    │ destinationType         │   │
│  │ port : ushort                │    │ url : string            │   │
│  │ client : string              │    │ authenticationType      │   │
│  │ protocol : string            │    │ proxyType : ProxyType   │   │
│  │ status : ConnectionStatus    │    │ cloudConnectorLocationId│   │
│  │ environment : string         │    │ user : string           │   │
│  │ region : string              │    │ tokenServiceUrl         │   │
│  │ systemId : string (SID)      │    │ tokenServiceUser        │   │
│  │ tenant : string              │    │ audience, scope_        │   │
│  │ createdBy : string           │    │ isEnabled : bool        │   │
│  │ createdAt, updatedAt : long  │    │ createdBy : string      │   │
│  └─────────────────────────────┘    │ createdAt, updatedAt    │   │
│                                      └────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Execution Domain                                                 │
│                                                                   │
│  ┌──────────────────────────────────────────┐                    │
│  │  ExecutionLog                             │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ id : ExecutionLogId                       │                    │
│  │ workflowId : WorkflowId                   │                    │
│  │ stepId : StepId                           │                    │
│  │ tenantId : TenantId                       │                    │
│  │ action : string                           │                    │
│  │ outcome : ExecutionOutcome                │                    │
│  │ message : string                          │                    │
│  │ details : string                          │                    │
│  │ executedBy : string                       │                    │
│  │ durationMs : long                         │                    │
│  │ timestamp : long                          │                    │
│  └──────────────────────────────────────────┘                    │
│                                                                   │
│  ┌──────────────────────────────────────────┐                    │
│  │  WorkflowSummary  «read model»            │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ workflowId : WorkflowId                   │                    │
│  │ workflowName : string                     │                    │
│  │ status : WorkflowStatus                   │                    │
│  │ totalSteps, completedSteps : int          │                    │
│  │ inProgressSteps, pendingSteps : int       │                    │
│  │ failedSteps, skippedSteps : int           │                    │
│  │ totalLogEntries : long                    │                    │
│  └──────────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

**Key Enumerations:**

| Enum | Values |
|---|---|
| ScenarioStatus | Draft, Active, Deprecated, Archived |
| WorkflowStatus | Planned, InProgress, Completed, Terminated, Failed, Suspended |
| StepType | Manual, Automated, Approval, Notification |
| StepStatus | Pending, InProgress, Completed, Skipped, Failed, Blocked |
| StepPriority | Low, Medium, High, Critical |
| SystemType | SapS4Hana, SapS4HanaCloud, SapBtp, SapSuccessFactors, SapAriba, SapConcur, SapFieldglass, SapIntegratedBusinessPlanning, SapBuildWorkZone, OnPremise, ThirdParty |
| ConnectionStatus | Active, Inactive, Error, Testing |
| DestinationType | HTTP, RFC, OData, SOAP, RestApi |
| AuthenticationType | Basic, OAuth2ClientCredentials, OAuth2Saml, Certificate, SamlBearer, PrincipalPropagation, NoAuthentication |
| ProxyType | Internet, OnPremise, PrivateLink |
| ExecutionOutcome | Success, Failure, Skipped, Timeout, Error |
| ScenarioCategory | LeadToCash, SourceToPay, RecruitToRetire, DesignToOperate, BtpServices, S4HanaIntegration, CommunicationManagement, Custom |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
┌─────────────────────────────────────────────────────────────┐
│  Deployment Node: Application Server                         │
│  OS: Linux                                                   │
│  Runtime: Native D binary (compiled with dub + DMD/LDC)     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Artifact: uim-integration-automation-platform-     │     │
│  │           service (executable)                      │     │
│  │  Source:   integration-automation/source/**/*.d      │     │
│  │  Binary:   integration-automation/build/             │     │
│  │            uim-integration-automation-platform-      │     │
│  │            service                                   │     │
│  │  Port:     8090 (configurable CIA_PORT)              │     │
│  │  Protocol: HTTP/1.1 (vibe.d event loop)              │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Environment Variables:                                      │
│  ┌────────────────┬──────────┬──────────────────────┐       │
│  │ Name           │ Default  │ Description           │       │
│  ├────────────────┼──────────┼──────────────────────┤       │
│  │ CIA_HOST       │ 0.0.0.0  │ HTTP bind address     │       │
│  │ CIA_PORT       │ 8090     │ HTTP listen port      │       │
│  └────────────────┴──────────┴──────────────────────┘       │
│                                                              │
│  Dependencies:                                               │
│  ┌────────────────────────────┬──────────┐                  │
│  │ Package                    │ Version  │                  │
│  ├────────────────────────────┼──────────┤                  │
│  │ uim-platform:service       │ local    │                  │
│  └────────────────────────────┴──────────┘                  │
│                                                              │
│  Persistence: In-memory (ephemeral)                          │
│  Scaling: Stateless – horizontally scalable with external    │
│           persistence adapter                                │
└─────────────────────────────────────────────────────────────┘
```

**Deployment Constraints:**

| Constraint | Description |
|---|---|
| DC-1 | Single-process, multi-threaded via vibe.d fibers |
| DC-2 | In-memory persistence is non-durable; data is lost on restart |
| DC-3 | Swapping to durable persistence requires implementing 6 repository interfaces |
| DC-4 | 15-concurrent-workflow limit is enforced per tenant in memory; external store needed for multi-instance deployments |
| DC-5 | WorkflowSummary is a computed read model aggregated from Workflow, WorkflowStep, and ExecutionLog data at query time |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

**Information Flows:**

| Flow ID | Source | Target | Data | Format | Trigger |
|---|---|---|---|---|---|
| IF-1 | Client | ScenarioController | Scenario definitions, step templates, tags, category | JSON | User action |
| IF-2 | Client | WorkflowController | Workflow creation (scenarioId, tenantId), lifecycle commands | JSON | User action |
| IF-3 | Client | StepController | Step creation, completion notes, failure reasons, skip reasons | JSON | Task action |
| IF-4 | Client | SystemController | System registration (type, host, port), connection test requests | JSON | Admin action |
| IF-5 | Client | DestinationController | Destination config (URL, auth, proxy, linked system) | JSON | Admin action |
| IF-6 | Client | MonitoringController | Query for logs, failures, summaries | JSON | On demand |
| IF-7 | StepExecutor | ExecutionLogRepo | Execution log entry (outcome, message, durationMs, timestamp) | Internal | Per step transition |
| IF-8 | ManageWorkflowsUseCase | ScenarioRepo | Read scenario template to generate workflow steps | Internal | On workflow create |
| IF-9 | ManageDestinationsUseCase | SystemRepo | Validate that linked systemId exists | Internal | On destination create |
| IF-10 | WorkflowEngine | WorkflowRepo | Count active workflows per tenant for limit check | Internal | On workflow start |
| IF-11 | MonitorExecutionsUseCase | StepRepo + LogRepo | Aggregate per-workflow summary (completed, failed, skipped counts) | Internal | On demand |

**Data Sensitivity:**

| Data Element | Classification | Handling |
|---|---|---|
| Destination credentials (auth config) | Secret | AuthenticationType stored; actual secrets not persisted in this layer |
| System connection details (host, port, client, SID) | Infrastructure-internal | Used for connection testing; access restricted to admin roles |
| Workflow execution logs | Operational | Retained for audit; may contain error messages and duration metrics |
| Scenario templates & step templates | Business-internal | Reusable across tenants; category-scoped |
| Tenant identifiers | PII-adjacent | Used for multi-tenant isolation via X-Tenant-Id header |
| User identifiers | PII-adjacent | Stored in createdBy, assignedTo, executedBy fields for audit trail |

---

## 8. Traceability Matrix

| Capability | Service(s) | Entity/ies | Controller | Use Case |
|---|---|---|---|---|
| C1.1 Scenario Management | SVC-SCEN-* | IntegrationScenario, ScenarioStepTemplate | ScenarioController | ManageScenariosUseCase |
| C1.2 Workflow Orchestration | SVC-WF-* | Workflow | WorkflowController | ManageWorkflowsUseCase |
| C1.2.3 Workflow Advancement | (internal) | Workflow, WorkflowStep | — | WorkflowEngine |
| C1.2.4 Tenant Limit | (internal) | Workflow | — | WorkflowEngine |
| C1.3 Task / Step Execution | SVC-STEP-* | WorkflowStep | StepController | ManageStepsUseCase |
| C1.3 Step Lifecycle | (internal) | WorkflowStep, ExecutionLog | — | StepExecutor |
| C1.4 System Landscape | SVC-SYS-* | SystemConnection | SystemController | ManageSystemsUseCase |
| C1.5 Destinations | SVC-DEST-* | Destination | DestinationController | ManageDestinationsUseCase |
| C1.6 Monitoring | SVC-MON-* | ExecutionLog, WorkflowSummary | MonitoringController | MonitorExecutionsUseCase |

---

*Document generated for the UIM Platform Integration Automation Service.*
*Authors: UIM Platform Team*
*© 2018–2026 UIM Platform Team — Proprietary*
