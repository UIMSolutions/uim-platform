/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.groups;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.group;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface GroupRepository : ITenantRepository!(Group, GroupId) {

  size_t countByMember(TenantId tenantId, UserId userId);
  Group[] findByMember(TenantId tenantId, UserId userId);
  void removeByMember(TenantId tenantId, UserId userId);

}
