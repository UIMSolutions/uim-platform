/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.business_processes;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_process;
// import uim.platform.data.privacy.domain.ports.business_process_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryBusinessProcessRepository : BusinessProcessRepository {
  private BusinessProcess[] store;

  BusinessProcess[] findByTenant(TenantId tenantId) {
    BusinessProcess[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  BusinessProcess* findById(BusinessProcessId tenantId, id tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  BusinessProcess[] findByController(TenantId tenantId, DataControllerId controllerId) {
    BusinessProcess[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.controllerId == controllerId)
        result ~= s;
    return result;
  }

  void save(BusinessProcess entity) {
    store ~= entity;
  }

  void update(BusinessProcess entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(BusinessProcessId tenantId, id tenantId) {
    BusinessProcess[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
