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
class MemoryDataControllerGroupRepository : TenantRepository!(DataControllerGroup, DataControllerGroupId), DataControllerGroupRepository {

  size_t countByName(TenantId tenantId, string name) {
    return findByName(tenantId, name).length;
  }

  DataControllerGroup[] findByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).filter!(g => g.name == name).array;
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).each!(entity => remove(entity.id));
  }
  
}
