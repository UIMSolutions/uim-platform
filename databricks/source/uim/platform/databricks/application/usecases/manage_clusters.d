module uim.platform.databricks.application.usecases.manage_clusters;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class ManageClustersUseCase {
private:
  ClusterRepository _repo;

public:
  this(ClusterRepository repo) { _repo = repo; }

  UseCaseResult!Cluster create(CreateClusterRequest r) {
    auto c = Cluster();
    c.id                    = r.id;
    c.tenantId              = r.tenantId;
    c.workspaceId           = r.workspaceId;
    c.name                  = r.name;
    c.clusterType           = r.clusterType;
    c.state                 = ClusterState.pending;
    c.nodeType              = r.nodeType;
    c.driverNodeType        = r.driverNodeType;
    c.numWorkers            = r.numWorkers;
    c.autoscaleEnabled      = r.autoscaleEnabled;
    c.autoscaleMinWorkers   = r.autoscaleMinWorkers;
    c.autoscaleMaxWorkers   = r.autoscaleMaxWorkers;
    c.autoTerminationMinutes= r.autoTerminationMinutes;
    c.sparkVersion          = r.sparkVersion;
    c.runtimeVersion        = r.runtimeVersion;
    c.creatorId             = r.creatorId;
    import std.datetime : Clock;
    c.startTime = Clock.currTime().toUnixTime() * 1000;
    _repo.save(c);
    return UseCaseResult!Cluster(true, "Cluster created", c);
  }

  UseCaseResult!(Cluster[]) list(TenantId tenantId) {
    return UseCaseResult!(Cluster[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!Cluster get(TenantId tenantId, ClusterId id) {
    auto c = _repo.find(tenantId, id);
    if (c == Cluster.init)
      return UseCaseResult!Cluster(false, "Cluster not found", Cluster.init);
    return UseCaseResult!Cluster(true, "", c);
  }

  UseCaseResult!Cluster update(UpdateClusterRequest r) {
    auto c = _repo.find(r.tenantId, r.id);
    if (c == Cluster.init)
      return UseCaseResult!Cluster(false, "Cluster not found", Cluster.init);
    if (r.name.length > 0)   c.name       = r.name;
    c.numWorkers            = r.numWorkers;
    c.autoscaleEnabled      = r.autoscaleEnabled;
    c.autoscaleMinWorkers   = r.autoscaleMinWorkers;
    c.autoscaleMaxWorkers   = r.autoscaleMaxWorkers;
    c.autoTerminationMinutes= r.autoTerminationMinutes;
    _repo.save(c);
    return UseCaseResult!Cluster(true, "Cluster updated", c);
  }

  UseCaseResult!bool remove(TenantId tenantId, ClusterId id) {
    auto c = _repo.find(tenantId, id);
    if (c == Cluster.init)
      return UseCaseResult!bool(false, "Cluster not found", false);
    c.state = ClusterState.terminated;
    _repo.save(c);
    return UseCaseResult!bool(true, "Cluster terminated", true);
  }
}
