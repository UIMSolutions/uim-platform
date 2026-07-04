/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.responsibility_context;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

/// A ResponsibilityContext represents a type of business object or process for
/// which agent determination can be triggered (e.g. "Purchase Order", "Invoice").
struct ResponsibilityContext {
    mixin TenantEntity!(ResponsibilityContextId);

    string name;
    string description;
    string objectType;         // technical object type identifier
    string namespace_;         // e.g. "com.sap.procurement"
    ContextStatus status       = ContextStatus.active;
    string[] ruleIds;          // linked ResponsibilityRuleId values

    Json toJson() const {
        return entityToJson
            .set("name",        name)
            .set("description", description)
            .set("objectType",  objectType)
            .set("namespace",   namespace_)
            .set("status",      status.to!string)
            .set("ruleCount",   ruleIds.length.to!string);
    }
}
