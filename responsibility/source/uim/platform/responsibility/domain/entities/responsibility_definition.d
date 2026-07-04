/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.responsibility_definition;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

/// A ResponsibilityDefinition links a rule and/or team to a context, defining
/// which agents cover what scope within a business area.
struct ResponsibilityDefinition {
    mixin TenantEntity!(ResponsibilityDefinitionId);

    string name;
    string description;
    string contextId;       // linked ResponsibilityContextId value
    string ruleId;          // linked ResponsibilityRuleId value
    string teamId;          // linked TeamId value
    DefinitionStatus status = DefinitionStatus.active;
    AssignmentScope scope_  = AssignmentScope.global_;
    string validFrom;       // ISO-8601 date string
    string validTo;         // ISO-8601 date string (empty = no expiry)
    string[] functionIds;   // member functions applicable under this definition

    Json toJson() const {
        return entityToJson
            .set("name",        name)
            .set("description", description)
            .set("contextId",   contextId)
            .set("ruleId",      ruleId)
            .set("teamId",      teamId)
            .set("status",      status.to!string)
            .set("scope",       scope_.to!string)
            .set("validFrom",   validFrom)
            .set("validTo",     validTo);
    }
}
