/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.user_profile_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.user_profile;
import uim.platform.workzone.domain.ports.repositories.user_profiles;

// import std.algorithm : filter;
// import std.array : array;

class MemoryUserProfileRepository : UserProfileRepository {
  private UserProfile[UserProfileId] store;

  UserProfile[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(p => p.tenantId == tenantId).array;
  }

  UserProfile* findById(UserProfileId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  UserProfile* findByUserId(UserId userId, TenantId tenantId) {
    foreach (ref p; store.byValue())
      if (p.tenantId == tenantId && p.userId == userId)
        return &p;
    return null;
  }

  UserProfile[] findByGroup(GroupId groupId, TenantId tenantId) {
    UserProfile[] result;
    foreach (ref p; store.byValue()) {
      if (p.tenantId != tenantId)
        continue;
      foreach (ref gid; p.groupIds)
        if (gid == groupId)
        {
          result ~= p;
          break;
        }
    }
    return result;
  }

  void save(UserProfile profile) {
    store[profile.id] = profile;
  }

  void update(UserProfile profile) {
    store[profile.id] = profile;
  }

  void remove(UserProfileId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
