module uim.platform.service_manager.infrastructure.persistence.memory.memory_service_plan_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServicePlanRepository : TenantRepository!(ServicePlan, ServicePlanId), ServicePlanRepository {
    
    // TODO
}
