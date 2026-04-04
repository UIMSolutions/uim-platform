/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.workspace_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workspace;
import uim.platform.workzone.domain.ports.repositories.workspaces;

// import std.algorithm : filter;
// import std.array : array;

class MemoryWorkspaceRepository : WorkspaceRepository
{
  private Workspace[WorkspaceId] store;

  Workspace[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(w => w.tenantId == tenantId).array;
  }

  Workspace* findById(WorkspaceId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Workspace* findByAlias(string alias_, TenantId tenantId)
  {
    foreach (ref w; store.byValue())
      if (w.tenantId == tenantId && w.alias_ == alias_)
        return &w;
    return null;
  }

  Workspace[] findByMember(UserId userId, TenantId tenantId)
  {
    Workspace[] result;
    foreach (ref w; store.byValue())
    {
      if (w.tenantId != tenantId)
        continue;
      foreach (ref m; w.members)
        if (m.userId == userId)
        {
          result ~= w;
          break;
        }
    }
    return result;
  }

  void save(Workspace workspace)
  {
    store[workspace.id] = workspace;
  }

  void update(Workspace workspace)
  {
    store[workspace.id] = workspace;
  }

  void remove(WorkspaceId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
