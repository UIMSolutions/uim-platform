/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.memory.groups;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

class MemoryGroupRepository : TenantRepository!(Group, GroupId), GroupRepository {
    Group findByName(TenantId tenantId, string name) {
        foreach (g; findByTenant(tenantId))
            if (g.name == name) return g;
        return Group.init;
    }

    Group[] findByType(TenantId tenantId, GroupType type_) {
        return findByTenant(tenantId).filter!(g => g.type_ == type_).array;
    }

    Group[] findByMember(TenantId tenantId, UserId userId) {
        import std.algorithm : canFind;
        return findByTenant(tenantId).filter!(g => g.memberIds.canFind(userId.value)).array;
    }
}
