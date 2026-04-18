module uim.platform.service_manager.domain.ports.repositories.service_plan_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServicePlanRepository {
    ServicePlan[] findByTenant(TenantId tenantId);
    ServicePlan* findById(TenantId tenantId, ServicePlanId id);
    void save(ServicePlan entity);
    void update(ServicePlan entity);
    void remove(TenantId tenantId, ServicePlanId id);
    ulong countByTenant(TenantId tenantId);
}
