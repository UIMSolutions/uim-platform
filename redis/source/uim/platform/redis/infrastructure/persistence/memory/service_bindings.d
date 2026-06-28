/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.memory.service_bindings;

import uim.platform.redis;
import std.algorithm : filter, any;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository
    : TenantRepository!(ServiceBinding, ServiceBindingId)
    , ServiceBindingRepository
{
    override ServiceBinding[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return find(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    override ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    override ServiceBinding findByInstanceAndApp(TenantId tenantId, ServiceInstanceId instanceId, string appId) {
        auto results = find(tenantId).filter!(e => e.instanceId == instanceId && e.appId == appId).array;
        return results.length > 0 ? results[0] : ServiceBinding.init;
    }
}
