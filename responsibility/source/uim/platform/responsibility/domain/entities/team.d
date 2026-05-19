/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.team;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

/// A Team is a named group of members that can be assigned responsibilities.
struct Team {
    mixin TenantEntity!(TeamId);

    string name;
    string description;
    string teamTypeId;      // linked TeamTypeId value
    string categoryId;      // denormalized for fast filtering
    TeamStatus status       = TeamStatus.active;
    AssignmentScope scope_  = AssignmentScope.global_;
    string[] memberIds;     // linked TeamMemberIds

    Json toJson() const {
        import std.algorithm : map;
        import std.array : array;
        return entityToJson
            .set("name",         name)
            .set("description",  description)
            .set("teamTypeId",   teamTypeId)
            .set("categoryId",   categoryId)
            .set("status",       status.to!string)
            .set("scope",        scope_.to!string)
            .set("memberCount",  memberIds.length.to!string);
    }
}
