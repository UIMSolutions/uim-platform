/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.user_assignments;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

interface UserAssignmentRepository : ITenantRepository!(UserAssignment, UserAssignmentId) {

  size_t countByUser(TenantId tenantId, UserId userId);
  UserAssignment[] findByUser(TenantId tenantId, UserId userId);
  void removeByUser(TenantId tenantId, UserId userId);

  size_t countByRoleCollection(TenantId tenantId, RoleCollectionId rcId);
  UserAssignment[] findByRoleCollection(TenantId tenantId, RoleCollectionId rcId);
  void removeByRoleCollection(TenantId tenantId, RoleCollectionId rcId);

  
}
