/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.automation_rule;

// import uim.platform.situation_automation.domain.types;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct RuleCondition {
    string field;
    ConditionOperator operator;
    string value;
    LogicalOperator logicalOp;

    Json toJson() const {
        return Json.emptyObject
            .set("field", field)
            .set("operator", operator)
            .set("value", value)
            .set("logicalOp", logicalOp);
    }
}

struct RuleAction {
    string actionId;
    string[][] parameters;
    int order;
    bool stopOnFailure;

    Json toJson() const {
        return Json.emptyObject
            .set("actionId", actionId)
            .set("parameters", parameters)
            .set("order", order)
            .set("stopOnFailure", stopOnFailure);
    }
}

struct AutomationRule {
    mixin TenantEntity!(AutomationRuleId);

    SituationTemplateId templateId;
    string name;
    string description;
    RuleStatus status;
    RulePriority priority;
    RuleCondition[] conditions;
    RuleAction[] actions;
    int executionOrder;
    bool enabled;
    long lastTriggeredAt;
    long triggerCount;
    long successCount;
    long failureCount;

    Json toJson() const {
        auto j = entityToJson
            .set("templateId", templateId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.toString())
            .set("priority", priority.toString())
            .set("conditions", conditions.map!(c => c.toJson()).array)
            .set("actions", actions.map!(a => a.toJson()).array)
            .set("executionOrder", executionOrder)
            .set("enabled", enabled)
            .set("lastTriggeredAt", lastTriggeredAt)
            .set("triggerCount", triggerCount)
            .set("successCount", successCount)
            .set("failureCount", failureCount);

        return j;
    }
}
