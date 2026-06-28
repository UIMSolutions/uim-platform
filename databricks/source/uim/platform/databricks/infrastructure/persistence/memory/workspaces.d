module uim.platform.databricks.infrastructure.persistence.memory.workspaces;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryWorkspaceRepository : TenantRepository!(Workspace, WorkspaceId), WorkspaceRepository {
  Workspace[] findByStatus(TenantId tenantId, WorkspaceStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(w => w.status == status).array;
  }

  Workspace[] findByRegion(TenantId tenantId, string region) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(w => w.region == region).array;
  }

  Workspace[] findByTier(TenantId tenantId, WorkspaceTier tier) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(w => w.tier == tier).array;
  }
}
