/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.clusters;
import uim.platform.databricks;

mixin(ShowModule!());

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
