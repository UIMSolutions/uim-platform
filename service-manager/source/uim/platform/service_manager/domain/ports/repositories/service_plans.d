module uim.platform.service_manager.domain.ports.repositories.service_plan_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServicePlanRepository : ITenantRepository!(ServicePlan, ServicePlanId) {
    
    size_t countByPricing(TenantId tenantId, ServicePlanPricing pricing);
    ServicePlan[] filterByPricing(ServicePlan[] plans, ServicePlanPricing pricing);
    ServicePlan[] findByPricing(TenantId tenantId, ServicePlanPricing pricing);
    void removeByPricing(TenantId tenantId, ServicePlanPricing pricing);
}
