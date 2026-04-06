/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.automation_rule;

import uim.platform.situation_automation.domain.types;

struct RuleCondition {
    string field;
    ConditionOperator operator;
    string value;
    LogicalOperator logicalOp;
}

struct RuleAction {
    string actionId;
    string[][] parameters;
    int order;
    bool stopOnFailure;
}

struct AutomationRule {
    AutomationRuleId id;
    SituationTemplateId templateId;
    TenantId tenantId;
    string name;
    string description;
    RuleStatus status;
    RulePriority priority;
    RuleCondition[] conditions;
    RuleAction[] actions;
    int executionOrder;
    bool enabled;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
    long lastTriggeredAt;
    long triggerCount;
    long successCount;
    long failureCount;
}
