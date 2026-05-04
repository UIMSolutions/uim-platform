/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.workspaces;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.workspace;
// import uim.platform.workzone.domain.ports.repositories.workspaces;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryWorkspaceRepository : TenantRepository!(Workspace, WorkspaceId), WorkspaceRepository {

  bool existsByAlias(TenantId tenantId, string alias_) {
    return findByTenant(tenantId).any!(w => w.alias_ == alias_);
  }

  Workspace findByAlias(TenantId tenantId, string alias_) {
    foreach (w; findByTenant(tenantId))
      if (w.alias_ == alias_)
        return w;
    return Workspace.init;
  }

  void removeByAlias(TenantId tenantId, string alias_) {
    remove(findByAlias(tenantId, alias_));
  }

  size_t countByMember(TenantId tenantId, UserId userId) {
    return findByMember(tenantId, userId).length;
  }
  
  Workspace[] findByMember(TenantId tenantId, UserId userId) {
    Workspace[] result;
    foreach (w; findByTenant(tenantId)) {
      foreach (m; w.members)
        if (m.userId == userId) {
          result ~= w;
          break;
        }
    }
    return result;
  }

  void removeByMember(TenantId tenantId, UserId userId) {
    findByMember(tenantId, userId).each!(w => remove(w));
  }

}
