/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.member_function;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

/// A MemberFunction represents a named role or job function that can be
/// assigned to team members (e.g. "Approver", "Reviewer", "Owner").
struct MemberFunction {
    mixin TenantEntity!(MemberFunctionId);

    string name;
    string description;
    string code;               // short unique code (e.g. "APPR", "OWNR")
    FunctionStatus status      = FunctionStatus.active;

    Json toJson() const {
        return entityToJson
            .set("name",        name)
            .set("description", description)
            .set("code",        code)
            .set("status",      status.to!string);
    }
}
