/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.role_collections;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class MemoryRoleCollectionRepository : TenantRepository!(RoleCollectionEntity, RoleCollectionId), RoleCollectionRepository {

  bool existsByName(TenantId tenantId, string name) {
    return find(tenantId).any!(rc => rc.name == name);
  }

  RoleCollectionEntity findByName(TenantId tenantId, string name) {
    foreach (rc; find(tenantId))
      if (rc.name == name)
        return rc;
    return RoleCollectionEntity.init;
  }

  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }
}
