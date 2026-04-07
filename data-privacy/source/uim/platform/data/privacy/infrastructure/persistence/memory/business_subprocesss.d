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
class MemoryBusinessSubprocessRepository : BusinessSubprocessRepository {
  private BusinessSubprocess[] store;

  BusinessSubprocess[] findByTenant(TenantId tenantId) {
    BusinessSubprocess[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  BusinessSubprocess* findById(BusinessSubprocessId id, TenantId tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  BusinessSubprocess[] findByParentProcess(TenantId tenantId, BusinessProcessId parentId) {
    BusinessSubprocess[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.parentProcessId == parentId)
        result ~= s;
    return result;
  }

  void save(BusinessSubprocess entity) {
    store ~= entity;
  }

  void update(BusinessSubprocess entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(BusinessSubprocessId id, TenantId tenantId) {
    BusinessSubprocess[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
