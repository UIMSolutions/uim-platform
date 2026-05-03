/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.user_profiles;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.user_profile;
// import uim.platform.workzone.domain.ports.repositories.user_profiles;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class MemoryUserProfileRepository : TenantRepository!(UserProfile, UserProfileId), UserProfileRepository {

  // #region ByUserId
  bool existsByUserId(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).any!(p => p.userId == userId);
  }

  UserProfile findByUserId(TenantId tenantId, UserId userId) {
    foreach (p; findByTenant(tenantId))
      if (p.userId == userId)
        return p;
    return UserProfile.init;
  }

  void removeByUserId(TenantId tenantId, UserId userId) {
    foreach (p; findByTenant(tenantId))
      if (p.userId == userId) {
        remove(p.id);
        break;
      }
  }
  // #endregion ByUserId

  // #region ByGroup
  size_t countByGroup(TenantId tenantId, GroupId groupId) {
    return findByGroup(tenantId, groupId).length;
  }

  UserProfile[] findByGroup(TenantId tenantId, GroupId groupId) {
    UserProfile[] result;
    foreach (p; findByTenant(tenantId)) {
      foreach (gid; p.groupIds)
        if (gid == groupId)
        {
          result ~= p;
          break;
        }
    }
    return result;
  }

  void removeByGroup(TenantId tenantId, GroupId groupId) {
    findByGroup(tenantId, groupId).each!(p => remove(p));
  }
  // #endregion ByGroup

}
