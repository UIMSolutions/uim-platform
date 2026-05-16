/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.user_assignments;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface UserAssignmentRepository : ITenantRepository!(UserAssignmentEntity, UserAssignmentId) {

  size_t countByUserId(string userId);
  UserAssignmentEntity[] findByUserId(string userId);
  void removeByUserId(string userId);

  size_t countByRoleCollectionId(RoleCollectionId rcId);
  UserAssignmentEntity[] findByRoleCollectionId(RoleCollectionId rcId);
  void removeByRoleCollectionId(RoleCollectionId rcId);
  
}
