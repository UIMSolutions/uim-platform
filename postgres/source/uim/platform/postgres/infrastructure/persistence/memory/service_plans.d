/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.memory.service_plans;

import uim.platform.postgres;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryServicePlanRepository
    : TenantRepository!(ServicePlan, ServicePlanId)
    , ServicePlanRepository
{
    override ServicePlan[] findByTier(TenantId t, PlanTier tier) {
        return findByTenant(t).filter!(e => e.tier == tier).array;
    }
    override ServicePlan[] findAvailable(TenantId t) {
        return findByTenant(t).filter!(e => e.available).array;
    }
    override bool nameExists(TenantId t, string name) {
        return findByTenant(t).any!(e => e.name == name);
    }
}
