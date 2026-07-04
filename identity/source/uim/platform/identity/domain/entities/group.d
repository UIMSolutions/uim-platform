/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Identity IDMGroup entity — user groups and authorization groups.
module uim.platform.identity.domain.entities.group;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

struct IDMGroup {
    mixin TenantEntity!IDMGroupId;

    string name;
    string description;
    GroupType type_ = GroupType.userGroup;
    string[] memberIds;     // User IDs belonging to this group

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("type", type_.to!string);
        auto members = Json.emptyArray;
        foreach (m; memberIds) members ~= Json(m);
        j["members"] = members;
        return j;
    }
}
