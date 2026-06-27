module uim.platform.databricks.infrastructure.persistence.memory.clusters;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryClusterRepository : TenantRepository!(Cluster, ClusterId), ClusterRepository {
  Cluster[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(c => c.workspaceId == workspaceId).array;
  }

  Cluster[] findByState(TenantId tenantId, ClusterState state) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(c => c.state == state).array;
  }

  Cluster[] findByType(TenantId tenantId, ClusterType clusterType) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(c => c.clusterType == clusterType).array;
  }
}
