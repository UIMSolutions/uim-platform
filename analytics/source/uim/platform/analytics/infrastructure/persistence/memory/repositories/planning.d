/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.planning;
// import uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.repositories.planning;
import uim.platform.analytics.domain.values.common;

class MemoryPlanningRepository : TenantRepository!(PlanningModel, PlanningModelId), PlanningRepository {
 
  size_t countByStatus(TenantId tenantId, PlanningStatus status) {
    return findByStatus(tenantId, status).length;
  }
  PlanningModel[] filterByStatus(PlanningModel[] models, PlanningStatus status) {
    return models.filter!(m => m.status == status).array;
  }
  PlanningModel[] findByStatus(TenantId tenantId, PlanningStatus status) {
    return filterByStatus(findByTenant(tenantId), status);  
  }

  void removeByStatus(TenantId tenantId, PlanningStatus status) {
    foreach(m; findByStatus(tenantId, status)) {
      remove(m);
    }
  }

}
