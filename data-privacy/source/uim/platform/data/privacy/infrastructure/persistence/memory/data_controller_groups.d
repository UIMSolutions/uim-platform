/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.data_controller_groups;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_controller_group;
// import uim.platform.data.privacy.domain.ports.data_controller_group_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDataControllerGroupRepository : DataControllerGroupRepository {
  private DataControllerGroup[] store;

  DataControllerGroup[] findByTenant(TenantId tenantId) {
    DataControllerGroup[] result;
    foreach (s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  DataControllerGroup* findById(DataControllerGroupId tenantId, id tenantId) {
    foreach (s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  void save(DataControllerGroup entity) {
    store ~= entity;
  }

  void update(DataControllerGroup entity) {
    foreach (s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(DataControllerGroupId tenantId, id tenantId) {
    DataControllerGroup[] kept;
    foreach (s; findByTenant(tenantId))
      if (!(s.id == id))
        kept ~= s;
    store = kept;
  }
}
