/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.groups;

import uim.platform.identity.directory.domain.entities.group;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — group persistence.
interface GroupRepository : ITenantRepository!(Group, GroupId) {
  
  bool existsByDisplayName(TenantId tenantId, string displayName);
  Group findByDisplayName(TenantId tenantId, string displayName);
  void removeByDisplayName(TenantId tenantId, string displayName);
  
  size_t countByMember(string memberId);
  Group[] findByMember(string memberId);
  void removeByMember(string memberId);
  
}
