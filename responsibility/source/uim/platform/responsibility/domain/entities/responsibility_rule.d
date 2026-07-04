/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.responsibility_rule;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

/// A responsibility rule defines the logic used to determine agents for a
/// given business context. It can be a direct assignment, a business rule
/// expression, a team-based lookup, or a hierarchical escalation.
struct ResponsibilityRule {
    mixin TenantEntity!(ResponsibilityRuleId);

    string name;
    string description;
    RuleType ruleType     = RuleType.directAssignment;
    RuleStatus status     = RuleStatus.active;
    string expression;        // business rule expression or script
    string priority;          // numeric string, lower = higher priority
    string contextId;         // linked ResponsibilityContextId value
    string teamId;            // linked TeamId value (for teamBased rules)

    Json toJson() const {
        return entityToJson
            .set("name",        name)
            .set("description", description)
            .set("ruleType",    ruleType.to!string)
            .set("status",      status.to!string)
            .set("expression",  expression)
            .set("priority",    priority)
            .set("contextId",   contextId)
            .set("teamId",      teamId);
    }
}
