/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.infrastructure.persistence.repositories.business_processes;

// import uim.platform.data_privacy.domain.entities.business_process;
// import uim.platform.data_privacy.domain.ports.business_process_repository;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
class BusinessProcessRepository : TenantRepository!(BusinessProcess, BusinessProcessId), BusinessProcessRepository {

  size_t countByController(TenantId tenantId, DataControllerId controllerId) {
    return findByController(tenantId, controllerId).length;
  }

  BusinessProcess[] filterByController(BusinessProcess[] processes, DataControllerId controllerId) {
    return processes.filter!(s => s.controllerId == controllerId).array;
  }

  BusinessProcess[] findByController(TenantId tenantId, DataControllerId controllerId) {
    return filterByController(findByTenant(tenantId), controllerId);
  }

  void removeByController(TenantId tenantId, DataControllerId controllerId) {
    findByController(tenantId, controllerId).each!(entity => remove(entity));
  }

}
