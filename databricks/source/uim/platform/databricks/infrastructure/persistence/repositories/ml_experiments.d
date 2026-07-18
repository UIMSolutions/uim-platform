/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.ml_experiments;
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
