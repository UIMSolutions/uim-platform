/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.team_member;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

/// A TeamMember represents a person (identified by userId/email) belonging to
/// a team and having one or more member functions and a RACI role.
struct TeamMember {
    mixin TenantEntity!(TeamMemberId);

    string teamId;          // linked TeamId value
    UserId userId;          // identity user ID (from Identity Authentication)
    string email;
    string displayName;
    string functionId;      // linked MemberFunctionId value
    MemberRole role         = MemberRole.responsible;
    long validFrom          = 0;
    long validTo            = 0;   // 0 = no expiry

    Json toJson() const {
        return entityToJson
            .set("teamId",      teamId)
            .set("userId",      userId)
            .set("email",       email)
            .set("displayName", displayName)
            .set("functionId",  functionId)
            .set("role",        role.to!string)
            .set("validFrom",   validFrom)
            .set("validTo",     validTo);
    }
}
