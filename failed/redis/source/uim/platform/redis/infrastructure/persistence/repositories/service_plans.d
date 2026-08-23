/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.repositories.service_plans;

import uim.platform.redis;
import std.algorithm : filter, any;
import std.array : array;

mixin(ShowModule!());

@safe:

class ServicePlanRepository
    : TenantRepository!(ServicePlan, ServicePlanId)
    , IBaseRepositoryServicePlanRepository
{
    size_t countByTier(TenantId tenantId, PlanTier tier) {
        return findByTier(tenantId, tier).length;
    }

    ServicePlan[] filterByTier(ServicePlan[] records, PlanTier tier) {
        return records.filter!(e => e.tier == tier).array;
    }

     ServicePlan[] findByTier(TenantId tenantId, PlanTier tier) {
        return filterByTier(findByTenant(tenantId), tier);
    }

    void removeByTier(TenantId tenantId, PlanTier tier) {
        findByTier(tenantId, tier).each!(entity => remove(entity));
    }

    size_t countByAvailable(TenantId tenantId, bool available) {
        return findByAvailable(tenantId, available).length;
    }

    ServicePlan[] filterByAvailable(ServicePlan[] records, bool available) {
        return records.filter!(e => e.available == available).array;
    }

    ServicePlan[] findByAvailable(TenantId tenantId, bool available) {
        return filterByAvailable(findByTenant(tenantId), available);
    }

    void removeByAvailable(TenantId tenantId, bool available) {
        findByAvailable(tenantId, available).each!(entity => remove(entity));
    }

     bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(e => e.name == name);
    }
}
