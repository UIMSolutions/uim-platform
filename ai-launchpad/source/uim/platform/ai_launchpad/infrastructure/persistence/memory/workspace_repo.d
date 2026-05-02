/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.workspaces;

// import uim.platform.ai_launchpad.domain.ports.repositories.workspaces;
// import uim.platform.ai_launchpad.domain.entities.workspace : Workspace;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryWorkspaceRepository : TenantRepository!(Workspace, WorkspaceId), WorkspaceRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(w => w.name == name);
  }

  Workspace findByName(TenantId tenantId, string name) {
    foreach (w; findByTenant(tenantId))
      if (w.name == name)
        return w;
    return Workspace.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (w; findByTenant(tenantId))
      if (w.name == name) {
        remove(w);
        return;
      }
  }

  size_t countByStatus(TenantId tenantId, WorkspaceStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Workspace[] findByStatus(TenantId tenantId, WorkspaceStatus status) {
    return findByTenant(tenantId).filter!(w => w.status == status).array;
  }

  void removeByStatus(TenantId tenantId, WorkspaceStatus status) {
    findByStatus(tenantId, status).each!(w => remove(w));
  }
}
