module uim.platform.databricks.infrastructure.persistence.memory.notebooks;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryNotebookRepository : TenantRepository!(Notebook, NotebookId), NotebookRepository {
  Notebook[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(n => n.workspaceId == workspaceId).array;
  }

  Notebook[] findByLanguage(TenantId tenantId, NotebookLanguage language) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(n => n.language == language).array;
  }

  Notebook[] findByStatus(TenantId tenantId, NotebookStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(n => n.status == status).array;
  }

  Notebook findByPath(TenantId tenantId, string path) {
    import std.algorithm : find;
    import std.array : empty, front;
    auto results = find(tenantId).find!(n => n.path == path);
    return results.empty ? Notebook.init : results.front;
  }
}
