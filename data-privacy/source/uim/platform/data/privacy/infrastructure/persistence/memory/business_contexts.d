/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.business_contexts;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_context;
// import uim.platform.data.privacy.domain.ports.business_context_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryBusinessContextRepository : BusinessContextRepository {
  private BusinessContext[] store;

  BusinessContext[] findByTenant(TenantId tenantId) {
    BusinessContext[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  BusinessContext* findById(BusinessContextId tenantId, id tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  BusinessContext[] findByStatus(TenantId tenantId, BusinessContextStatus status) {
    BusinessContext[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  BusinessContext[] findByControllerGroup(TenantId tenantId, DataControllerGroupId groupId) {
    BusinessContext[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.controllerGroupId == groupId)
        result ~= s;
    return result;
  }

  void save(BusinessContext entity) {
    store ~= entity;
  }

  void update(BusinessContext entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(BusinessContextId tenantId, id tenantId) {
    BusinessContext[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
