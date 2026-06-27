/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.groups;

// import uim.platform.identity.directory.domain.entities.group;

import uim.platform.identity.directory;

// mixin(ShowModule!());

@safe:
/// Port: outgoing — group persistence.
interface GroupRepository : ITentRepository!(IAMGroup, IAMGroupId) {
  
  bool existsByDisplayName(TenantId tenantId, string displayName);
  IAMGroup findByDisplayName(TenantId tenantId, string displayName);
  void removeByDisplayName(TenantId tenantId, string displayName);
  
  size_t countByMember(string memberId);
  IAMGroup[] findByMember(string memberId);
  void removeByMember(string memberId);
  
}
