/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.memory.access_controls;

import uim.platform.redis;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryAccessControlRepository
    : TenantRepository!(AccessControl, AccessControlId)
    , AccessControlRepository
{
    override AccessControl[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    override AccessControl[] findByStatus(TenantId tenantId, AccessControlStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    override bool cidrExists(TenantId tenantId, ServiceInstanceId instanceId, string cidr) {
        return findByTenant(tenantId).any!(e => e.instanceId == instanceId && e.cidr == cidr);
    }
}
