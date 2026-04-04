/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.workspace_repo;

import uim.platform.ai_launchpad.domain.ports.repositories.workspaces;
import uim.platform.ai_launchpad.domain.entities.workspace : Workspace;
import uim.platform.ai_launchpad.domain.types;

class MemoryWorkspaceRepository : IWorkspaceRepository {
  private Workspace[string] store;

  void save(Workspace w) {
    store[w.id] = w;
  }

  Workspace findById(WorkspaceId id) {
    if (auto p = id in store) return *p;
    return Workspace.init;
  }

  Workspace[] findByTenant(TenantId tenantId) {
    Workspace[] result;
    foreach (ref w; store) {
      if (w.tenantId == tenantId) result ~= w;
    }
    return result;
  }

  Workspace[] findAll() {
    return store.values;
  }

  void remove(WorkspaceId id) {
    store.remove(id);
  }
}
