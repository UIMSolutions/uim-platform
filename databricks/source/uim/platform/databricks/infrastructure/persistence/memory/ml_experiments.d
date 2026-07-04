module uim.platform.databricks.infrastructure.persistence.memory.ml_experiments;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MemoryMlExperimentRepository : TenantRepository!(MlExperiment, MlExperimentId), MlExperimentRepository {
  MlExperiment[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(e => e.workspaceId == workspaceId).array;
  }

  MlExperiment[] findActive(TenantId tenantId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(e => e.lifecycleStage == "active").array;
  }

  MlExperiment findByName(TenantId tenantId, string name) {
    import std.algorithm : find;
    import std.array : empty, front;
    auto results = findByTenant(tenantId).find!(e => e.name == name);
    return results.empty ? MlExperiment.init : results.front;
  }
}
