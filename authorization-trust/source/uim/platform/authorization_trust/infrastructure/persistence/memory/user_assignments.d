/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.user_assignments;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class MemoryUserAssignmentRepository : TenantRepository!(UserAssignment, UserAssignmentId), UserAssignmentRepository {

  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }

  UserAssignment[] filterByUser(UserAssignment[] uas, UserId userId) {
    return uas.filter!(ua => ua.userId == userId).array;
  }
  UserAssignment[] findByUser(TenantId tenantId, UserId userId) {
    return filterByUser(find(tenantId), userId);
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(ua => remove(ua));
  }

  size_t countByRoleCollection(TenantId tenantId, RoleCollectionId rcId) {
    return findByRoleCollection(tenantId, rcId).length;
  }
  UserAssignment[] filterByRoleCollection(UserAssignment[] uas, RoleCollectionId rcId) {
    return uas.filter!(ua => ua.roleCollectionId == rcId).array;
  }
  UserAssignment[] findByRoleCollection(TenantId tenantId, RoleCollectionId rcId) {
    return filterByRoleCollection(find(tenantId), rcId);
  }
  void removeByRoleCollection(TenantId tenantId, RoleCollectionId rcId) {
    findByRoleCollection(tenantId, rcId).each!(ua => remove(ua));
  }

}
