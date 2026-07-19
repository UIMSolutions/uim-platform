/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.memory.service_plans;

import uim.platform.redis;
import std.algorithm : filter, any;
import std.array : array;
mixin(ShowModule!());

@safe:

class MemoryServicePlanRepository
    : TenantRepository!(ServicePlan, ServicePlanId)
    , ServicePlanRepository
{
    override ServicePlan[] findByTier(TenantId tenantId, PlanTier tier) {
        return findByTenant(tenantId).filter!(e => e.tier == tier).array;
    }

    override ServicePlan[] findAvailable(TenantId tenantId) {
        return findByTenant(tenantId).filter!(e => e.available).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(e => e.name == name);
    }
}
