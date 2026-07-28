/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.infrastructure.persistence.repositories.service_plans;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServicePlanRepository : TenantRepository!(ServicePlan, ServicePlanId), IServicePlanRepository {

    size_t countByPricing(TenantId tenantId, ServicePlanPricing pricing) {
        return this.findByPricing(tenantId, pricing).length;
    }
    ServicePlan[] filterByPricing(ServicePlan[] plans, ServicePlanPricing pricing) {
        return plans.filter!(p => p.pricing == pricing).array;
    }
    ServicePlan[] findByPricing(TenantId tenantId, ServicePlanPricing pricing) {
        return this.filterByPricing(this.findByTenant(tenantId), pricing);
    }
    void removeByPricing(TenantId tenantId, ServicePlanPricing pricing) {
        this.findByPricing(tenantId, pricing).each!(p => this.remove(p));
    }

}

///
unittest {
    assert(tenantRepositoryTest(new ServicePlanRepository()));
}
