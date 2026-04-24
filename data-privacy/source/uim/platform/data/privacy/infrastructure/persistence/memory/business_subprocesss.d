/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.business_subprocesses;
  
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_subprocess;
// import uim.platform.data.privacy.domain.ports.business_subprocess_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryBusinessSubprocessRepository : TenantRepository!(BusinessSubprocess, BusinessSubprocessId), BusinessSubprocessRepository {

  size_t countByParentProcess(TenantId tenantId, BusinessProcessId parentId) {
    return findByParentProcess(tenantId, parentId).length;
  }

  BusinessSubprocess[] filterByParentProcess(BusinessSubprocess[] subprocesses, BusinessProcessId parentId) {
    return subprocesses.filter!(s => s.parentProcessId == parentId).array;
  }

  BusinessSubprocess[] findByParentProcess(TenantId tenantId, BusinessProcessId parentId) {
    return filterByParentProcess(findByTenant(tenantId), parentId);
  }

  void removeByParentProcess(TenantId tenantId, BusinessProcessId parentId) {
    findByParentProcess(tenantId, parentId).each!(entity => remove(entity.id));
  }

}
