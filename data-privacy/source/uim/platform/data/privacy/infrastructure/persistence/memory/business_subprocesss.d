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
  private BusinessSubprocess[BusinessSubprocessId][TenantId] store;

  BusinessSubprocess[] findByTenant(TenantId tenantId) {
    if (!(tenantId in store))
      return null;

    return store[tenantId].byValue.filter!(s => s.tenantId == tenantId).array;
  }

  bool existsById(BusinessSubprocessId tenantId, id tenantId) {
    return (existsByTenant(tenantId) && (id in store[tenantId]));
  }

  BusinessSubprocess findById(BusinessSubprocessId tenantId, id tenantId) {
    if (!(tenantId in store) || !(id in store[tenantId]))
      return BusinessSubprocess.init;

    return store[tenantId][id];
  }

  BusinessSubprocess[] findByParentProcess(TenantId tenantId, BusinessProcessId parentId) {
    if (!existsByTenant(tenantId))
      return null;

    return store[tenantId].byValue.filter!(s => s.parentProcessId == parentId).array;
  }

  void save(BusinessSubprocess entity) {
    if (!existsByTenant(entity.tenantId)) {
      BusinessSubprocess[BusinessSubprocessId] subprocesses;
      store[entity.tenantId] = subprocesses;
    }
    store[entity.tenantId][entity.id] = entity;
  }

  void update(BusinessSubprocess entity) {
    if (!existsById(entity.id, entity.tenantId)) {
      return;
    }

    store[entity.tenantId][entity.id] = entity;
  }

  void remove(BusinessSubprocessId tenantId, id tenantId) {
    BusinessSubprocess[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
