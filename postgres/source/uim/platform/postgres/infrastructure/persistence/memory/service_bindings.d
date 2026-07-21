/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.repositories.service_bindings;

import uim.platform.postgres;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository
    : TenantRepository!(ServiceBinding, ServiceBindingId)
    , ServiceBindingRepository
{
    override ServiceBinding[] findByInstance(TenantId t, ServiceInstanceId instanceId) {
        return findByTenant(t).filter!(e => e.instanceId == instanceId).array;
    }
    override ServiceBinding[] findByStatus(TenantId t, BindingStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override ServiceBinding findByInstanceAndApp(TenantId t, ServiceInstanceId iid, string appId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == iid && e.appId == appId).array;
        return r.length > 0 ? r[0] : ServiceBinding.init;
    }
}
