module uim.platform.databricks.domain.ports.repositories.notebooks;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

interface INotebookRepository : ITenantRepository!(Notebook, NotebookId) {
  Notebook[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  Notebook[] findByLanguage(TenantId tenantId, NotebookLanguage language);
  Notebook[] findByStatus(TenantId tenantId, NotebookStatus status);
  Notebook   findByPath(TenantId tenantId, string path);
}
