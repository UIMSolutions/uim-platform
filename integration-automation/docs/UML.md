# Integration Automation – Architecture (PlantUML)

```plantuml
@startuml Integration Automation – Hexagonal Architecture

!define PRESENTATION_COLOR #E3F2FD
!define APPLICATION_COLOR  #FFF3E0
!define DOMAIN_COLOR       #E8F5E9
!define INFRA_COLOR        #F3E5F5
!define PORT_COLOR         #E1F5FE
!define SERVICE_COLOR      #FFF8E1
!define VALUE_COLOR        #FFFDE7

skinparam class {
  BackgroundColor    WHITE
  BorderColor        #37474F
  ArrowColor         #37474F
  FontSize           11
}

skinparam package {
  FontSize          12
  FontStyle         bold
  BorderThickness   2
}

title UIM Integration Automation Platform Service\nClean + Hexagonal Architecture

' ============================================================
' PRESENTATION LAYER (Driving Adapters)
' ============================================================

package "Presentation Layer  «driving adapters»" as PRES <<Rectangle>> {
  skinparam packageBackgroundColor PRESENTATION_COLOR

  package "HTTP Controllers" as HANDLERS <<Rectangle>> {
    class HealthController << (H,#EF5350) >> {
      GET /api/v1/health
    }

    class ScenarioController << (H,#EF5350) >> {
      GET    /api/v1/scenarios
      POST   /api/v1/scenarios
      GET    /api/v1/scenarios/{id}
      PUT    /api/v1/scenarios/{id}
      DELETE /api/v1/scenarios/{id}
    }

    class WorkflowController << (H,#EF5350) >> {
      GET    /api/v1/workflows
      POST   /api/v1/workflows
      GET    /api/v1/workflows/{id}
      POST   /api/v1/workflows/start/{id}
      POST   /api/v1/workflows/suspend/{id}
      POST   /api/v1/workflows/resume/{id}
      POST   /api/v1/workflows/terminate/{id}
      DELETE /api/v1/workflows/{id}
    }

    class StepController << (H,#EF5350) >> {
      GET    /api/v1/steps
      POST   /api/v1/steps
      GET    /api/v1/steps/{id}
      POST   /api/v1/steps/start/{id}
      POST   /api/v1/steps/complete/{id}
      POST   /api/v1/steps/fail/{id}
      POST   /api/v1/steps/skip/{id}
      GET    /api/v1/my-tasks
      DELETE /api/v1/steps/{id}
    }

    class SystemController << (H,#EF5350) >> {
      GET    /api/v1/systems
      POST   /api/v1/systems
      GET    /api/v1/systems/{id}
      PUT    /api/v1/systems/{id}
      POST   /api/v1/systems/test/{id}
      DELETE /api/v1/systems/{id}
    }

    class DestinationController << (H,#EF5350) >> {
      GET    /api/v1/destinations
      POST   /api/v1/destinations
      GET    /api/v1/destinations/{id}
      PUT    /api/v1/destinations/{id}
      DELETE /api/v1/destinations/{id}
    }

    class MonitoringController << (H,#EF5350) >> {
      GET /api/v1/monitoring/logs
      GET /api/v1/monitoring/failures
      GET /api/v1/monitoring/summary/{id}
    }
  }
}

' ============================================================
' APPLICATION LAYER (Use Cases & Outgoing Ports)
' ============================================================

package "Application Layer  «use cases»" as APP <<Rectangle>> {
  skinparam packageBackgroundColor APPLICATION_COLOR

  package "Use Cases" as USECASES <<Rectangle>> {
    class ManageScenariosUseCase << (U,#FF7043) >> {
      + createScenario(req) : CommandResult
      + updateScenario(id, req) : CommandResult
      + getScenario(id) : IntegrationScenario
      + listScenarios() : IntegrationScenario[]
      + deleteScenario(id) : CommandResult
    }

    class ManageWorkflowsUseCase << (U,#FF7043) >> {
      + createWorkflow(req) : CommandResult
      + getWorkflow(id) : Workflow
      + listWorkflows() : Workflow[]
      + startWorkflow(id) : CommandResult
      + suspendWorkflow(id) : CommandResult
      + resumeWorkflow(id) : CommandResult
      + terminateWorkflow(id) : CommandResult
      + deleteWorkflow(id) : CommandResult
    }

    class ManageStepsUseCase << (U,#FF7043) >> {
      + createStep(req) : CommandResult
      + getStep(id) : WorkflowStep
      + listSteps() : WorkflowStep[]
      + startStep(id, userId) : CommandResult
      + completeStep(req) : CommandResult
      + failStep(req) : CommandResult
      + skipStep(req) : CommandResult
      + assignStep(req) : CommandResult
      + getMyTasks(userId) : WorkflowStep[]
      + getTasksByRole(role) : WorkflowStep[]
    }

    class ManageSystemsUseCase << (U,#FF7043) >> {
      + createSystem(req) : CommandResult
      + updateSystem(id, req) : CommandResult
      + getSystem(id) : SystemConnection
      + listSystems() : SystemConnection[]
      + testConnection(id) : CommandResult
      + deleteSystem(id) : CommandResult
    }

    class ManageDestinationsUseCase << (U,#FF7043) >> {
      + createDestination(req) : CommandResult
      + updateDestination(id, req) : CommandResult
      + getDestination(id) : Destination
      + listDestinations() : Destination[]
      + deleteDestination(id) : CommandResult
    }

    class MonitorExecutionsUseCase << (U,#FF7043) >> {
      + getAllLogs(tenantId) : ExecutionLog[]
      + getWorkflowLogs(workflowId) : ExecutionLog[]
      + getStepLogs(stepId) : ExecutionLog[]
      + getFailures(tenantId) : ExecutionLog[]
      + getLogsByTimeRange(from, to) : ExecutionLog[]
      + getWorkflowSummary(id) : WorkflowSummary
    }
  }
}

' ============================================================
' DOMAIN LAYER
' ============================================================

package "Domain Layer  «business logic»" as DOMAIN <<Rectangle>> {
  skinparam packageBackgroundColor DOMAIN_COLOR

  package "Entities" as ENTITIES <<Rectangle>> {
    class IntegrationScenario << (E,#66BB6A) >> {
      id : ScenarioId
      tenantId : TenantId
      name, description : string
      category : ScenarioCategory
      version_ : string
      status : ScenarioStatus
      sourceSystemType : SystemType
      targetSystemType : SystemType
      prerequisites : string[]
      stepTemplates : ScenarioStepTemplate[]
      createdBy : string
      createdAt, updatedAt : long
    }

    class ScenarioStepTemplate << (V,#FDD835) >> {
      name, description : string
      type_ : StepType
      priority : StepPriority
      sequenceNumber : int
      assignedRole : string
      instructions : string
      automationEndpoint : string
      automationPayload : string
      requiresSourceSystem : bool
      requiresTargetSystem : bool
      dependsOnSteps : int[]
      estimatedDurationMinutes : int
    }

    class Workflow << (E,#66BB6A) >> {
      id : WorkflowId
      tenantId : TenantId
      scenarioId : ScenarioId
      name, description : string
      status : WorkflowStatus
      currentStepIndex : int
      totalSteps : int
      completedSteps : int
      sourceSystemId : SystemId
      targetSystemId : SystemId
      createdBy : string
      startedAt, completedAt : long
      createdAt, updatedAt : long
    }

    class WorkflowStep << (E,#66BB6A) >> {
      id : StepId
      workflowId : WorkflowId
      tenantId : TenantId
      name, description : string
      type_ : StepType
      status : StepStatus
      priority : StepPriority
      sequenceNumber : int
      assignedTo : UserId
      assignedRole : string
      instructions : string
      automationEndpoint : string
      automationPayload : string
      sourceSystemId : SystemId
      targetSystemId : SystemId
      dependencies : StepId[]
      result : string
      errorMessage : string
      startedAt, completedAt : long
      createdAt : long
      estimatedDurationMinutes : int
    }

    class SystemConnection << (E,#66BB6A) >> {
      id : SystemId
      tenantId : TenantId
      name, description : string
      systemType : SystemType
      host : string
      port : ushort
      client : string
      protocol : string
      status : ConnectionStatus
      environment : string
      region : string
      systemId : string
      tenant : string
      createdBy : string
      createdAt, updatedAt : long
    }

    class Destination << (E,#66BB6A) >> {
      id : DestinationId
      tenantId : TenantId
      name, description : string
      systemId : SystemId
      destinationType : DestinationType
      url : string
      authenticationType : AuthenticationType
      proxyType : ProxyType
      cloudConnectorLocationId : string
      user : string
      tokenServiceUrl : string
      tokenServiceUser : string
      audience, scope_ : string
      isEnabled : bool
      createdBy : string
      createdAt, updatedAt : long
    }

    class ExecutionLog << (E,#66BB6A) >> {
      id : ExecutionLogId
      workflowId : WorkflowId
      stepId : StepId
      tenantId : TenantId
      action : string
      outcome : ExecutionOutcome
      message, details : string
      executedBy : string
      durationMs : long
      timestamp : long
    }
  }

  package "Repository Interfaces  «ports»" as REPOS <<Rectangle>> {
    skinparam packageBackgroundColor PORT_COLOR

    interface ScenarioRepository << (P,#42A5F5) >> {
      findByTenant(tenantId)
      findById(id, tenantId)
      findByCategory(tenantId, category)
      findByStatus(tenantId, status)
      findBySystemType(tenantId, systemType)
      save() / update() / remove()
    }

    interface WorkflowRepository << (P,#42A5F5) >> {
      findByTenant(tenantId)
      findById(id, tenantId)
      findByScenario(tenantId, scenarioId)
      findByStatus(tenantId, status)
      findByCreator(tenantId, createdBy)
      countByTenant() / countActiveByTenant()
      save() / update() / remove()
    }

    interface StepRepository << (P,#42A5F5) >> {
      findByWorkflow(workflowId, tenantId)
      findById(id, tenantId)
      findByAssignee(tenantId, assignedTo)
      findByRole(tenantId, assignedRole)
      findByStatus(workflowId, tenantId, status)
      findBySequence(workflowId, tenantId, seq)
      save() / update() / remove()
      removeByWorkflow(workflowId, tenantId)
    }

    interface SystemRepository << (P,#42A5F5) >> {
      findByTenant(tenantId)
      findById(id, tenantId)
      findByType(tenantId, systemType)
      findByStatus(tenantId, status)
      save() / update() / remove()
    }

    interface DestinationRepository << (P,#42A5F5) >> {
      findByTenant(tenantId)
      findById(id, tenantId)
      findBySystem(tenantId, systemId)
      findByName(tenantId, name)
      findEnabled(tenantId)
      save() / update() / remove()
    }

    interface ExecutionLogRepository << (P,#42A5F5) >> {
      findByWorkflow(workflowId, tenantId)
      findByStep(stepId, tenantId)
      findByTenant(tenantId)
      findByOutcome(tenantId, outcome)
      findByTimeRange(tenantId, from, to)
      countByWorkflow(workflowId, tenantId)
      save() / removeByWorkflow()
      removeOlderThan(tenantId, before)
    }
  }

  package "Domain Services" as DSVC <<Rectangle>> {
    skinparam packageBackgroundColor SERVICE_COLOR

    class WorkflowEngine << (S,#FFB74D) >> {
      + areDependenciesMet(step, tenantId) : bool
      + advanceWorkflow(workflowId, tenantId) : bool
      + isWorkflowLimitReached(tenantId) : bool
      --
      Max 15 concurrent workflows per tenant
      Dependency-based step progression
    }

    class StepExecutor << (S,#FFB74D) >> {
      + startStep(stepId, tenantId, userId) : bool
      + completeStep(stepId, tenantId, userId, result) : bool
      + failStep(stepId, tenantId, userId, errorMsg) : bool
      + skipStep(stepId, tenantId, userId, reason) : bool
      --
      Automatically records ExecutionLog entries
      Tracks durationMs for completed steps
    }
  }

  package "Value Objects & Enums" as VALS <<Rectangle>> {
    skinparam packageBackgroundColor VALUE_COLOR

    enum ScenarioStatus {
      Draft, Active
      Deprecated, Archived
    }

    enum WorkflowStatus {
      Planned, InProgress
      Completed, Terminated
      Failed, Suspended
    }

    enum StepType {
      Manual, Automated
      Approval, Notification
    }

    enum StepStatus {
      Pending, InProgress
      Completed, Skipped
      Failed, Blocked
    }

    enum SystemType {
      SapS4Hana, SapS4HanaCloud
      SapBtp, SapSuccessFactors
      SapAriba, SapConcur
      SapFieldglass, SapIBP
      SapBuildWorkZone
      OnPremise, ThirdParty
    }

    enum DestinationType {
      HTTP, RFC, OData
      SOAP, RestApi
    }

    enum AuthenticationType {
      Basic, OAuth2ClientCredentials
      OAuth2Saml, Certificate
      SamlBearer, PrincipalPropagation
      NoAuthentication
    }

    enum ScenarioCategory {
      LeadToCash, SourceToPay
      RecruitToRetire, DesignToOperate
      BtpServices, S4HanaIntegration
      CommunicationManagement, Custom
    }

    enum StepPriority {
      Low, Medium
      High, Critical
    }

    enum ConnectionStatus {
      Active, Inactive
      Error, Testing
    }

    enum ProxyType {
      Internet, OnPremise
      PrivateLink
    }

    enum ExecutionOutcome {
      Success, Failure
      Skipped, Timeout
      Error
    }
  }

  package "Read Models" as READS <<Rectangle>> {
    skinparam packageBackgroundColor #E8EAF6

    class WorkflowSummary << (R,#7986CB) >> {
      workflowId : WorkflowId
      workflowName : string
      status : WorkflowStatus
      totalSteps : int
      completedSteps : int
      inProgressSteps : int
      pendingSteps : int
      failedSteps : int
      skippedSteps : int
      totalLogEntries : long
    }
  }
}

' ============================================================
' INFRASTRUCTURE LAYER (Driven Adapters)
' ============================================================

package "Infrastructure Layer  «driven adapters»" as INFRA <<Rectangle>> {
  skinparam packageBackgroundColor INFRA_COLOR

  class AppConfig << (F,#90A4AE) >> {
    host : string = "0.0.0.0"
    port : ushort = 8090
    serviceName : string
  }

  class Container << (F,#90A4AE) >> {
    buildContainer(config) : Container
    --
    Wires all dependencies
  }

  package "In-Memory Persistence" as PERSIST <<Rectangle>> {
    class InMemoryScenarioRepo << (A,#B0BEC5) >>
    class InMemoryWorkflowRepo << (A,#B0BEC5) >>
    class InMemoryStepRepo << (A,#B0BEC5) >>
    class InMemorySystemRepo << (A,#B0BEC5) >>
    class InMemoryDestinationRepo << (A,#B0BEC5) >>
    class InMemoryExecutionLogRepo << (A,#B0BEC5) >>
  }
}

' ============================================================
' RELATIONSHIPS – Controller → Use Case
' ============================================================

ScenarioController    --> ManageScenariosUseCase
WorkflowController    --> ManageWorkflowsUseCase
StepController        --> ManageStepsUseCase
SystemController      --> ManageSystemsUseCase
DestinationController --> ManageDestinationsUseCase
MonitoringController  --> MonitorExecutionsUseCase

' ============================================================
' RELATIONSHIPS – Use Case → Repository Port
' ============================================================

ManageScenariosUseCase    --> ScenarioRepository
ManageWorkflowsUseCase    --> WorkflowRepository
ManageWorkflowsUseCase    --> ScenarioRepository : reads templates
ManageStepsUseCase        --> StepRepository
ManageSystemsUseCase      --> SystemRepository
ManageDestinationsUseCase --> DestinationRepository
ManageDestinationsUseCase --> SystemRepository : validates system
MonitorExecutionsUseCase  --> ExecutionLogRepository
MonitorExecutionsUseCase  --> WorkflowRepository : reads workflow
MonitorExecutionsUseCase  --> StepRepository : counts steps

' ============================================================
' RELATIONSHIPS – Use Case → Domain Service
' ============================================================

ManageWorkflowsUseCase --> WorkflowEngine : enforces limit
ManageStepsUseCase     --> StepExecutor : lifecycle transitions

' ============================================================
' RELATIONSHIPS – Domain Service → Repository Port
' ============================================================

WorkflowEngine --> WorkflowRepository : checks tenant limit
WorkflowEngine --> StepRepository : reads step status
StepExecutor   --> StepRepository : updates step status
StepExecutor   --> ExecutionLogRepository : records logs

' ============================================================
' RELATIONSHIPS – Adapter implements Port
' ============================================================

InMemoryScenarioRepo     ..|> ScenarioRepository
InMemoryWorkflowRepo     ..|> WorkflowRepository
InMemoryStepRepo         ..|> StepRepository
InMemorySystemRepo       ..|> SystemRepository
InMemoryDestinationRepo  ..|> DestinationRepository
InMemoryExecutionLogRepo ..|> ExecutionLogRepository

' ============================================================
' ENTITY ASSOCIATIONS
' ============================================================

IntegrationScenario "1" *-- "0..*" ScenarioStepTemplate : stepTemplates
Workflow "1" --> "1" IntegrationScenario : scenarioId
WorkflowStep "0..*" --> "1" Workflow : workflowId
Destination "0..*" --> "0..1" SystemConnection : systemId
ExecutionLog "0..*" --> "1" Workflow : workflowId
ExecutionLog "0..*" --> "1" WorkflowStep : stepId
MonitorExecutionsUseCase ..> WorkflowSummary : produces

' ============================================================
' LEGEND
' ============================================================

legend bottom right
  | Symbol | Layer |
  | (H) | Controller (Presentation) |
  | (U) | Use Case (Application) |
  | (E) | Entity (Domain) |
  | (P) | Port / Interface |
  | (S) | Domain Service |
  | (V) | Value Object / Struct |
  | (R) | Read Model |
  | (A) | Adapter (Infrastructure) |
  | (F) | Framework / Config |
  |→| depends on |
  |..|>| implements |
  |..>| produces |
  |*--| composition |
endlegend

footer UIM Platform – Integration Automation Service\n© 2018-2026 UIM Platform Team
@enduml
```
