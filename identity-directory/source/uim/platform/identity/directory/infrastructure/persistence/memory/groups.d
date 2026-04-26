/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.groups;

// import uim.platform.identity.directory.domain.entities.group;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.groups;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for group persistence.
class MemoryGroupRepository : TenantRepository!(Group, GroupId), GroupRepository {

  bool existsByDisplayName(TenantId tenantId, string displayName) {
    return findAll().any!(g => g.tenantId == tenantId && g.displayName == displayName);
  }
  
  Group findByDisplayName(TenantId tenantId, string displayName) {
    foreach (g; findAll()) {
      if (g.tenantId == tenantId && g.displayName == displayName)
        return g;
    }
    return Group.init;
  }

  size_t countByMember(string memberId) {
    return findByMember(memberId).length;
  }
  Group[] filterByMember(Group[] groups, string memberId) {
    return groups.filter!(g => g.hasMember(memberId)).array;
  }
  Group[] findByMember(string memberId) {
    return findAll().filter!(g => g.hasMember(memberId)).array;
  }

  void removeByMember(string memberId) {
    findByMember(memberId).each!(g => {
      g.removeMember(memberId);
      store[g.id] = g; // Update the group in the store after modification
    });
  }
}
