module uim.platform.databricks.domain.entities.cluster;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// A Databricks compute cluster (interactive or job cluster).
struct Cluster {
  mixin TenantEntity!(ClusterId);

  WorkspaceId  workspaceId;
  string       name;
  ClusterType  clusterType;
  ClusterState state;
  string       nodeType;
  string       driverNodeType;
  int          numWorkers;
  bool         autoscaleEnabled;
  int          autoscaleMinWorkers;
  int          autoscaleMaxWorkers;
  int          autoTerminationMinutes;
  string       sparkVersion;
  string       runtimeVersion;
  string       creatorId;
  long         startTime;    // Unix epoch ms
  long         terminatedAt; // Unix epoch ms, 0 if still running

  Json toJson() const { 
        auto j = entityToJson()
        .set("workspaceId", workspaceId)
        .set("name", name)
        .set("clusterType", clusterType)
        .set("state", state)
        .set("nodeType", nodeType)
        .set("driverNodeType", driverNodeType)
        .set("numWorkers", numWorkers)
        .set("autoscaleEnabled", autoscaleEnabled)
        .set("autoscaleMinWorkers", autoscaleMinWorkers)
        .set("autoscaleMaxWorkers", autoscaleMaxWorkers)
        .set("autoTerminationMinutes", autoTerminationMinutes)
        .set("sparkVersion", sparkVersion)
        .set("runtimeVersion", runtimeVersion)
        .set("creatorId", creatorId)
        .set("startTime", startTime)
        .set("terminatedAt", terminatedAt);
        
    return j;
  }
}
