/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.dto;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

struct ResponsibilityRuleDTO {
    ResponsibilityRuleId ruleId;
    TenantId tenantId;
    string name;
    string description;
    string ruleType;
    string status;
    string expression;
    string priority;
    string contextId;
    string teamId;
    UserId createdBy;
    UserId updatedBy;
}

struct TeamCategoryDTO {
    TeamCategoryId categoryId;
    TenantId tenantId;
    string name;
    string description;
    string code;
    UserId createdBy;
    UserId updatedBy;
}

struct TeamTypeDTO {
    TeamTypeId typeId;
    TenantId tenantId;
    string name;
    string description;
    string code;
    string categoryId;
    UserId createdBy;
    UserId updatedBy;
}

struct TeamDTO {
    TeamId teamId;
    TenantId tenantId;
    string name;
    string description;
    string teamTypeId;
    string categoryId;
    string status;
    string scope_;
    UserId createdBy;
    UserId updatedBy;
}

struct TeamMemberDTO {
    TeamMemberId memberId;
    TenantId tenantId;
    string teamId;
    UserId userId;
    string email;
    string displayName;
    string functionId;
    string role;
    long validFrom;
    long validTo;
    UserId createdBy;
    UserId updatedBy;
}

struct MemberFunctionDTO {
    MemberFunctionId functionId;
    TenantId tenantId;
    string name;
    string description;
    string code;
    string status;
    UserId createdBy;
    UserId updatedBy;
}

struct ResponsibilityContextDTO {
    ResponsibilityContextId contextId;
    TenantId tenantId;
    string name;
    string description;
    string objectType;
    string namespace_;
    string status;
    UserId createdBy;
    UserId updatedBy;
}

struct ResponsibilityDefinitionDTO {
    ResponsibilityDefinitionId definitionId;
    TenantId tenantId;
    string name;
    string description;
    string contextId;
    string ruleId;
    string teamId;
    string status;
    string scope_;
    string validFrom;
    string validTo;
    UserId createdBy;
    UserId updatedBy;
}

struct DetermineAgentsRequest {
    TenantId tenantId;
    string contextId;
    string objectType;
    string objectId;
    string callerApp;
}

struct DetermineAgentsResult {
    bool success;
    string[] agents;
    string logId;
    string error;
}
