/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.situation_template;

import uim.platform.situation_automation.domain.types;

struct ConditionDefinition {
    string field;
    ConditionOperator operator;
    string value;
    string valueType;
}

struct SituationTemplate {
    SituationTemplateId id;
    TenantId tenantId;
    string name;
    string description;
    SituationCategory category;
    SituationSeverity defaultSeverity;
    TemplateStatus status;
    string entityTypeId;
    ConditionDefinition[] conditions;
    string[] suggestedActionIds;
    string sourceSystem;
    string sourceTemplateId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    string escalationTargetUserId;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
