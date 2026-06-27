/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.memory.database_users;

import uim.platform.postgres;
import std.algorithm : filter, any;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryDatabaseUserRepository
    : TentRepository!(DatabaseUser, DatabaseUserId)
    , DatabaseUserRepository
{
    override DatabaseUser[] findByInstance(TenantId t, ServiceInstanceId instanceId) {
        return findByTenant(t).filter!(e => e.instanceId == instanceId).array;
    }
    override DatabaseUser[] findByStatus(TenantId t, UserStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override bool usernameExists(TenantId t, ServiceInstanceId instanceId, string username) {
        return findByTenant(t).any!(e => e.instanceId == instanceId && e.username == username);
    }
}
