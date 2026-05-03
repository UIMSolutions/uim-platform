/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.workpages;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.workpage;
// import uim.platform.workzone.domain.ports.repositories.workpages;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryWorkpageRepository : TenantRepository!(Workpage, WorkpageId), WorkpageRepository {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  Workpage[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(p => p.workspaceId == workspaceId).array;
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    findByWorkspace(tenantId, workspaceId).each!(p => remove(p));
  }
}
