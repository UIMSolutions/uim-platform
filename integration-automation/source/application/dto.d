module application.dto;

import domain.types;
import domain.entities.integration_scenario : ScenarioStepTemplate;
import domain.entities.workflow_step : WorkflowStep;

// ──────────────── Integration Scenario DTOs ────────────────

struct CreateScenarioRequest
{
    TenantId tenantId;
    string name;
    string description;
    ScenarioCategory category;
    string version_;
    SystemType sourceSystemType;
    SystemType targetSystemType;
    string[] prerequisites;
    ScenarioStepTemplate[] stepTemplates;
    string createdBy;
}

struct UpdateScenarioRequest
{
    ScenarioId id;
    TenantId tenantId;
    string name;
    string description;
    ScenarioCategory category;
    string version_;
    ScenarioStatus status;
    SystemType sourceSystemType;
    SystemType targetSystemType;
    string[] prerequisites;
    ScenarioStepTemplate[] stepTemplates;
}

// ──────────────── Workflow DTOs ────────────────

struct CreateWorkflowRequest
{
    TenantId tenantId;
    ScenarioId scenarioId;
    string name;
    string description;
    SystemId sourceSystemId;
    SystemId targetSystemId;
    string createdBy;
}

struct UpdateWorkflowStatusRequest
{
    WorkflowId id;
    TenantId tenantId;
    WorkflowStatus status;
}

// ──────────────── Workflow Step DTOs ────────────────

struct CreateStepRequest
{
    WorkflowId workflowId;
    TenantId tenantId;
    string name;
    string description;
    StepType type_;
    StepPriority priority;
    int sequenceNumber;
    string assignedTo;
    string assignedRole;
    string instructions;
    string automationEndpoint;
    string automationPayload;
    SystemId sourceSystemId;
    SystemId targetSystemId;
    StepId[] dependencies;
    int estimatedDurationMinutes;
}

struct CompleteStepRequest
{
    StepId id;
    TenantId tenantId;
    UserId completedBy;
    string result;
}

struct FailStepRequest
{
    StepId id;
    TenantId tenantId;
    UserId reportedBy;
    string errorMessage;
}

struct SkipStepRequest
{
    StepId id;
    TenantId tenantId;
    UserId skippedBy;
    string reason;
}

struct AssignStepRequest
{
    StepId id;
    TenantId tenantId;
    UserId assignedTo;
    string assignedRole;
}

// ──────────────── System Connection DTOs ────────────────

struct CreateSystemRequest
{
    TenantId tenantId;
    string name;
    string description;
    SystemType systemType;
    string host;
    ushort port;
    string client;
    string protocol;
    string environment;
    string region;
    string systemId;
    string tenant;
    string createdBy;
}

struct UpdateSystemRequest
{
    SystemId id;
    TenantId tenantId;
    string name;
    string description;
    SystemType systemType;
    string host;
    ushort port;
    string client;
    string protocol;
    ConnectionStatus status;
    string environment;
    string region;
    string systemId;
    string tenant;
}

// ──────────────── Destination DTOs ────────────────

struct CreateDestinationRequest
{
    TenantId tenantId;
    string name;
    string description;
    SystemId systemId;
    DestinationType destinationType;
    string url;
    AuthenticationType authenticationType;
    ProxyType proxyType;
    string cloudConnectorLocationId;
    string user;
    string tokenServiceUrl;
    string tokenServiceUser;
    string audience;
    string scope_;
    string createdBy;
}

struct UpdateDestinationRequest
{
    DestinationId id;
    TenantId tenantId;
    string name;
    string description;
    SystemId systemId;
    DestinationType destinationType;
    string url;
    AuthenticationType authenticationType;
    ProxyType proxyType;
    string cloudConnectorLocationId;
    string user;
    string tokenServiceUrl;
    string tokenServiceUser;
    string audience;
    string scope_;
    bool isEnabled;
}

// ──────────────── Generic result ────────────────

struct CommandResult
{
    string id;
    string error;

    bool isSuccess() const
    {
        return error.length == 0;
    }
}
