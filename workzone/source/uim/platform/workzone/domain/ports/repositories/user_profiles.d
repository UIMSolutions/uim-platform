/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.user_profiles;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.user_profile;

interface UserProfileRepository {
  UserProfile[] findByTenant(TenantId tenantId);
  UserProfile* findById(UserProfileId id, TenantId tenantId);
  UserProfile* findByUserId(UserId userId, TenantId tenantId);
  UserProfile[] findByGroup(GroupId groupId, TenantId tenantId);
  void save(UserProfile profile);
  void update(UserProfile profile);
  void remove(UserProfileId id, TenantId tenantId);
}
