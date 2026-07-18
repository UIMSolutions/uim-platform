/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.ml_models;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MemoryMlModelRepository : TenantRepository!(MlModel, MlModelId), MlModelRepository {
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
