/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.repositories.service_plans;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

interface ServicePlanRepository : ITenantRepository!(ServicePlan, ServicePlanId) {
    ServicePlan[] findByTier(TenantId tenantId, PlanTier tier);
    ServicePlan[] findAvailable(TenantId tenantId);
    bool nameExists(TenantId tenantId, string name);
}
