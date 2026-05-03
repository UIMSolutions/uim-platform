/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.user_profiles;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.user_profile;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface UserProfileRepository : ITenantRepository!(UserProfile, UserProfileId) {

  bool existsByUserId(TenantId tenantId, UserId userId);
  UserProfile findByUserId(TenantId tenantId, UserId userId);
  void removeByUserId(TenantId tenantId, UserId userId);

  size_t countByGroup(TenantId tenantId, GroupId groupId);
  UserProfile[] findByGroup(TenantId tenantId, GroupId groupId);
  void removeByGroup(TenantId tenantId, GroupId groupId);

}
