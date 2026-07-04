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
}
