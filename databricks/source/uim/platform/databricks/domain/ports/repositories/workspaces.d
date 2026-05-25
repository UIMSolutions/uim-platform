module uim.platform.databricks.domain.ports.repositories.workspaces;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

interface WorkspaceRepository : TenantRepository!(Workspace, WorkspaceId) {
  Workspace[] findByStatus(TenantId tenantId, WorkspaceStatus status);
  Workspace[] findByRegion(TenantId tenantId, string region);
  Workspace[] findByTier(TenantId tenantId, WorkspaceTier tier);
}
