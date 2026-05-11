module uim.platform.situation_automation.application.dtos.situation_instance;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct CreateSituationInstanceRequest {
    TenantId tenantId;
    SituationTemplateId situationTemplateId;
    SituationInstanceId situationInstanceId;
    string description;
    SituationSeverity severity;
    string entityId;
    EntityTypeId entityTypeId;
    string[][] contextData;
    string assignedTo;
    string sourceSystem;
    string sourceInstanceId;
    long dueAt;
}

struct UpdateSituationInstanceRequest {
    TenantId tenantId;
    SituationInstanceId situationInstanceId;
    string status;
    SituationSeverity severity;
    string assignedTo;
}

struct ResolveSituationRequest {
    TenantId tenantId;
    SituationInstanceId situationInstanceId;
    string resolutionType;
    string resolvedBy;
    string actionId;
    string ruleId;
    string outcome;
}