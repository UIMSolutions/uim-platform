/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.infrastructure.persistence.memory.groups;
// import uim.platform.identity_directory.domain.entities.group;

// import uim.platform.identity_directory.domain.ports.repositories.groups;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for group persistence.
class MemoryGroupRepository : TenantRepository!(IAMGroup, IAMGroupId), GroupRepository {

  bool existsByDisplayName(TenantId tenantId, string displayName) {
    return findByTenant(tenantId).any!(g => g.tenantId == tenantId && g.displayName == displayName);
  }
  
  IAMGroup findByDisplayName(TenantId tenantId, string displayName) {
    foreach (g; findByTenant(tenantId)) {
      if (g.tenantId == tenantId && g.displayName == displayName)
        return g;
    }
    return IAMGroup.init;
  }

  size_t countByMember(string memberId) {
    return findByMember(memberId).length;
  }
  IAMGroup[] filterByMember(IAMGroup[] groups, string memberId) {
    return groups.filter!(g => g.hasMember(memberId)).array;
  }
  IAMGroup[] findByMember(string memberId) {
    return findByTenant(tenantId).filter!(g => g.hasMember(memberId)).array;
  }

  void removeByMember(string memberId) {
    findByMember(memberId).each!(g => {
      g.removeMember(memberId);
      store[g.id] = g; // Update the group in the store after modification
    });
  }
}
