module uim.platform.service_manager.infrastructure.persistence.memory.service_plans;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServicePlanRepository : TenantRepository!(ServicePlan, ServicePlanId), ServicePlanRepository {

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
        this.removeAll(this.findByPricing(tenantId, pricing));
    }

}
