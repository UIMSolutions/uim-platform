module uim.platform.task_center.application.dtos.substitutionrule;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:
struct CreateSubstitutionRuleRequest {
    TenantId tenantId;
    SubstitutionRuleId substitutionRuleId; // This is needed to ensure idempotency of the request. The client can generate a UUID and pass it here. If a substitution rule with the same ID already exists, the service can return the existing rule instead of creating a new one.

    UserId userId;
    UserId substituteId;
    TaskDefinitionId taskDefinitionId;
    Date startDate;
    Date endDate;
    bool isAutoForward;
    UserId createdBy;
}

struct UpdateSubstitutionRuleRequest {
    TenantId tenantId;
    SubstitutionRuleId substitutionRuleId;
    UserId substituteId;
    TaskDefinitionId taskDefinitionId;
    Date startDate;
    Date endDate;
    bool isAutoForward;
    UserId updatedBy;
}
