module uim.platform.situation_automation.application.dtos.sizuation_template;

struct CreateSituationTemplateRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string category;
    string defaultSeverity;
    string entityTypeId;
    string sourceSystem;
    string sourceTemplateId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    string escalationTargetUserId;
    UserId createdBy;
}

struct UpdateSituationTemplateRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string category;
    string defaultSeverity;
    string entityTypeId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    string escalationTargetUserId;
    UserId updatedBy;
}