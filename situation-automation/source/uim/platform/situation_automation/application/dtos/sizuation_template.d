module uim.platform.situation_automation.application.dtos.situation_template;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct CreateSituationTemplateRequest {
    TenantId tenantId;
    SituationTemplateId situationTemplateId;
    string name;
    string description;
    string category;
    string defaultSeverity;
    EntityTypeId entityTypeId;
    string sourceSystem;
    string sourceTemplateId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    UserId escalationTargetUserId;
    UserId createdBy;
}

struct UpdateSituationTemplateRequest {
    TenantId tenantId;
    SituationTemplateId situationTemplateId;
    string name;
    string description;
    string category;
    string defaultSeverity;
    EntityTypeId entityTypeId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    UserId escalationTargetUserId;
    UserId updatedBy;
}