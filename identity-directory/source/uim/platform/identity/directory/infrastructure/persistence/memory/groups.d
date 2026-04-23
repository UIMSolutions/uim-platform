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
class MemoryGroupRepository : GroupRepository {
  private Group[GroupId] store;

  bool existsById(GroupId id) {
    return (id in store) ? true : false;
  }

  Group findById(GroupId id) {
    return (id in store) ? store[id] : Group.init;
  }

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

  size_t countByTenant(TenantId tenantId) {
    size_t count;
    foreach (g; findAll()) {
      if (g.tenantId == tenantId)
        count++;
    }
    return count;
  }

  Group[] findByTenant(TenantId tenantId) {
    return findAll().filter!(g => g.tenantId == tenantId).array;
  }

  Group[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    Group[] result;
    uint idx;
    foreach (g; findByTenant(tenantId)) {
      if (idx >= offset && result.length < limit)
        result ~= g;
      idx++;
    }
    return result;
  }

  Group[] findByMember(string memberId) {
    return findAll().filter!(g => g.hasMember(memberId)).array;
  }

  void save(Group group) {
    store[group.id] = group;
  }

  void update(Group group) {
    store[group.id] = group;
  }

  void remove(GroupId id) {
    store.remove(id);
  }
}
