/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.role_collections;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

interface RoleCollectionRepository : ITenantRepository!(RoleCollectionEntity, RoleCollectionId) {

  bool existsByName(TenantId tenantId, string name);
  RoleCollectionEntity findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

}
