module uim.platform.databricks.infrastructure.persistence.memory.ml_models;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryMlModelRepository : TentRepository!(MlModel, MlModelId), MlModelRepository {
  MlModel[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(m => m.workspaceId == workspaceId).array;
  }

  MlModel[] findByStage(TenantId tenantId, ModelStage stage) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(m => m.latestStage == stage).array;
  }

  MlModel findByName(TenantId tenantId, string name) {
    import std.algorithm : find;
    import std.array : empty, front;
    auto results = findByTenant(tenantId).find!(m => m.name == name);
    return results.empty ? MlModel.init : results.front;
  }
}
