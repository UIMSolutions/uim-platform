/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.user_assignments;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface UserAssignmentRepository {
  bool                 existsById(UserAssignmentId id);
  UserAssignmentEntity findById(UserAssignmentId id);

  UserAssignmentEntity[] findAll();
  UserAssignmentEntity[] findByUserId(string userId);
  UserAssignmentEntity[] findByRoleCollectionId(RoleCollectionId rcId);

  void save(UserAssignmentEntity ua);
  void remove(UserAssignmentId id);

  size_t count();
}
