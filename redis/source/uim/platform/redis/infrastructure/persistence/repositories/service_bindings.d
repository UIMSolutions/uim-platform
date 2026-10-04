/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.repositories.service_bindings;

import uim.platform.redis;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:

class ServiceBindingRepository
    : TenantRepository!(ServiceBinding, ServiceBindingId)
    , IServiceBindingRepository
{
    // #region ByInstance
    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }
     ServiceBinding[] filterByInstance(ServiceBinding[] records, ServiceInstanceId instanceId) {
        return records.filter!(s => s.instanceId == instanceId).array;
    }

     ServiceBinding[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return filterByInstance(findByTenant(tenantId), instanceId);
    }

    void removeByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        findByInstance(tenantId, instanceId).each!(entity => remove(entity));
    }
    // #endregion ByInstance

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, BindingStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ServiceBinding[] filterByStatus(ServiceBinding[] records, BindingStatus status) {
        return records.filter!(s => s.status == status).array;
    }   

     ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, BindingStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }
    // #endregion ByStatus

         ServiceBinding findByInstanceAndApp(TenantId tenantId, ServiceInstanceId instanceId, string appId) {
        auto results = filterByInstance(findByTenant(tenantId), instanceId).filter!(e => e.appId == appId).array;
        return results.length > 0 ? results[0] : ServiceBinding.init;
    }
}
