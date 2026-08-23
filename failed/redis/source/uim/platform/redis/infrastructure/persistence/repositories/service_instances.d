/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.repositories.service_instances;

import uim.platform.redis;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class ServiceInstanceRepository : TenantRepository!(ServiceInstance, ServiceInstanceId), ServiceInstanceRepository {
    // #region ByStatus
    size_t countByStatus(TenantId tenantId, InstanceStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ServiceInstance[] filterByStatus(ServiceInstance[] records, InstanceStatus status) {
        return records.filter!(s => s.status == status).array;
    }

    ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, InstanceStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }
    // #endregion ByStatus  

    // #region ByPlan
    size_t countByPlan(TenantId tenantId, ServicePlanId planId) {
        return findByPlan(tenantId, planId).length;
    }

    ServiceInstance[] filterByPlan(ServiceInstance[] records, ServicePlanId planId) {
        return records.filter!(e => e.planId == planId).array;
    }

    ServiceInstance[] findByPlan(TenantId tenantId, ServicePlanId planId) {
        return filterByPlan(findByTenant(tenantId), planId);
    }

    void removeByPlan(TenantId tenantId, ServicePlanId planId) {
        findByPlan(tenantId, planId).each!(entity => remove(entity));
    }
    // #endregion ByPlan

    // #region ByHyperscaler
    size_t countByHyperscaler(TenantId tenantId, Hyperscaler hs) {
        return findByHyperscaler(tenantId, hs).length;
    }

    ServiceInstance[] filterByHyperscaler(ServiceInstance[] records, Hyperscaler hs) {
        return records.filter!(e => e.hyperscaler == hs).array;
    }

    ServiceInstance[] findByHyperscaler(TenantId tenantId, Hyperscaler hs) {
        return filterByHyperscaler(findByTenant(tenantId), hs);
    }

    void removeByHyperscaler(TenantId tenantId, Hyperscaler hs) {
        findByHyperscaler(tenantId, hs).each!(entity => remove(entity));
    }
    // #endregion ByHyperscaler

    bool nameExists(TenantId tenantId, string name) {
        import std.algorithm : any;

        return findByTenant(tenantId).any!(e => e.name == name);
    }
}
