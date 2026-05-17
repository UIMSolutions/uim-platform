/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.user_assignments;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class MemoryUserAssignmentRepository : UserAssignmentRepository {
  private UserAssignmentEntity[UserAssignmentId] store;

  bool existsById(UserAssignmentId id) {
    return (id in store) !is null;
  }

  UserAssignmentEntity findById(UserAssignmentId id) {
    return existsById(id) ? store[id] : UserAssignmentEntity.init;
  }

  UserAssignmentEntity[] findAll() {
    return store.values.dup;
  }

  UserAssignmentEntity[] findByUserId(string userId) {
    return store.values.filter!(ua => ua.userId == userId).array;
  }

  UserAssignmentEntity[] findByRoleCollectionId(RoleCollectionId rcId) {
    return store.values.filter!(ua => ua.roleCollectionId == rcId).array;
  }

  void save(UserAssignmentEntity ua) {
    store[ua.id] = ua;
  }

  void remove(UserAssignmentId id) {
    store.remove(id);
  }

  size_t count() {
    return store.length;
  }
}
