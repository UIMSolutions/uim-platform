/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.roles;

// import uim.platform.portal.domain.entities.role;
// import uim.platform.portal.domain.types;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Port: outgoing — role persistence.
interface RoleRepository {
  Role findById(RoleId id);
  Role findByName(TenantId tenantId, string name);
  Role[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  Role[] findByUser(string userId);
  void save(Role role);
  void update(Role role);
  void remove(RoleId id);
}
