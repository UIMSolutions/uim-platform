/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.repositories.users;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class UserRepository : TenantRepository!(IdmUser, UserId), IUserRepository {
    IdmUser findByUserName(TenantId tenantId, string userName) {
        foreach (u; findByTenant(tenantId))
            if (u.userName == userName) return u;
        return IdmUser.init;
    }

    IdmUser findByEmail(TenantId tenantId, string email) {
        foreach (u; findByTenant(tenantId))
            if (u.email == email) return u;
        return IdmUser.init;
    }

    IdmUser[] findByStatus(TenantId tenantId, UserStatus status) {
        return findByTenant(tenantId).filter!(u => u.status == status).array;
    }

    IdmUser[] findByType(TenantId tenantId, UserType type_) {
        return findByTenant(tenantId).filter!(u => u.type_ == type_).array;
    }

    IdmUser[] findByGroup(TenantId tenantId, IDMGroupId groupId) {
        import std.algorithm : canFind;
        return findByTenant(tenantId).filter!(u => u.groups.canFind(groupId.value)).array;
    }
}
