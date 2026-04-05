/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.roles;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.role;

interface RoleRepository {
  Role[] findByTenant(TenantId tenantId);
  Role* findById(RoleId id, TenantId tenantId);
  Role[] findByUser(UserId userId, TenantId tenantId);
  void save(Role role);
  void update(Role role);
  void remove(RoleId id, TenantId tenantId);
}
