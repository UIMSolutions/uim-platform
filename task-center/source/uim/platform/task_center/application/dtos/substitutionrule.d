module uim.platform.task_center.application.dtos.substitutionrule;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:
struct CreateSubstitutionRuleRequest {
    TenantId tenantId;
    string id;
    string userId;
    string substituteId;
    string taskDefinitionId;
    string startDate;
    string endDate;
    bool isAutoForward;
    string createdBy;
}

struct UpdateSubstitutionRuleRequest {
    TenantId tenantId;
    string id;
    string substituteId;
    string taskDefinitionId;
    string startDate;
    string endDate;
    bool isAutoForward;
    string modifiedBy;
}
