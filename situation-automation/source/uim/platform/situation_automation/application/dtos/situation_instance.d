module uim.platform.situation_automation.application.dtos.situation_instance;

struct CreateSituationInstanceRequest {
    TenantId tenantId;
    string templateId;
    string id;
    string description;
    string severity;
    string entityId;
    string entityTypeId;
    string[][] contextData;
    string assignedTo;
    string sourceSystem;
    string sourceInstanceId;
    long dueAt;
}

struct UpdateSituationInstanceRequest {
    TenantId tenantId;
    string id;
    string status;
    string severity;
    string assignedTo;
}

struct ResolveSituationRequest {
    TenantId tenantId;
    string id;
    string resolutionType;
    string resolvedBy;
    string actionId;
    string ruleId;
    string outcome;
}