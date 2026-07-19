/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.memory.service_instances;

import uim.platform.redis;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryServiceInstanceRepository
    : TenantRepository!(ServiceInstance, ServiceInstanceId)
    , ServiceInstanceRepository
{
    override ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    override ServiceInstance[] findByPlan(TenantId tenantId, ServicePlanId planId) {
        return findByTenant(tenantId).filter!(e => e.planId == planId).array;
    }

    override ServiceInstance[] findByHyperscaler(TenantId tenantId, Hyperscaler hs) {
        return findByTenant(tenantId).filter!(e => e.hyperscaler == hs).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        import std.algorithm : any;
        return findByTenant(tenantId).any!(e => e.name == name);
    }
}
