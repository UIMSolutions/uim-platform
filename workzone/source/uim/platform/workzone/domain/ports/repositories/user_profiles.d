/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.user_profiles;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.user_profile;

interface UserProfileRepository : ITenantRepository!(UserProfile, UserProfileId) {

  bool existsByUserId(UserId usertenantId, id tenantId);
  UserProfile findByUserId(UserId usertenantId, id tenantId);
  void removeByUserId(UserId usertenantId, id tenantId);

  size_t countByGroup(GroupId grouptenantId, id tenantId);
  UserProfile[] findByGroup(GroupId grouptenantId, id tenantId);
  void removeByGroup(GroupId grouptenantId, id tenantId);

}
