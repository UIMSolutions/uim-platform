module uim.platform.databricks.domain.ports.repositories.clusters;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

interface ClusterRepository : TentRepository!(Cluster, ClusterId) {
  Cluster[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  Cluster[] findByState(TenantId tenantId, ClusterState state);
  Cluster[] findByType(TenantId tenantId, ClusterType clusterType);
}
