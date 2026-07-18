/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.notebooks;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MemoryNotebookRepository : TenantRepository!(Notebook, NotebookId), NotebookRepository {
  Notebook[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(n => n.workspaceId == workspaceId).array;
  }

  Notebook[] findByLanguage(TenantId tenantId, NotebookLanguage language) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(n => n.language == language).array;
  }

  Notebook[] findByStatus(TenantId tenantId, NotebookStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(n => n.status == status).array;
  }

  Notebook findByPath(TenantId tenantId, string path) {
    import std.algorithm : find;
    import std.array : empty, front;
    auto results = findByTenant(tenantId).find!(n => n.path == path);
    return results.empty ? Notebook.init : results.front;
  }
}
