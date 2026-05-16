/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.planning;
// import uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.repositories.planning;
// import uim.platform.analytics.domain.values.common;
// import uim.platform.analytics.domain.values.time_granularity;
// import uim.platform.analytics.app.dto.planning;


import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class PlanningUseCases {
  private PlanningRepository repo;

  this(PlanningRepository repo) {
    this.repo = repo;
  }

  PlanningModelResponse createPlanningModel(CreatePlanningModelRequest req) {
    TimeGranularity gran;
    try {
      gran = req.granularity.to!TimeGranularity;
    }
    catch (Exception) {
      gran = TimeGranularity.Monthly;
    }
    auto pm = PlanningModel.create(req.name, req.description, req.datasetId, gran, req.userId);
    repo.save(pm);
    return PlanningModelResponse.fromEntity(pm);
  }

  PlanningModelResponse getById(string id) {
    return PlanningModelResponse.fromEntity(repo.findById(EntityId(id)));
  }

  PlanningModelResponse[] listPlanningModels(TenantId tenantId) {
    return repo.findByTenant(tenantId).map!(pm => PlanningModelResponse.fromEntity(pm)).array;
  }

  PlanningModelResponse lockPlanningModel(TenantId tenantId, string id) {
    auto pm = repo.findById(EntityId(id));
    if (pm.isNull)
      return PlanningModelResponse.init;
    pm.lock();
    repo.save(pm);
    return PlanningModelResponse.fromEntity(pm);
  }

  PlanningModelResponse approvePlanningModel(TenantId tenantId, string id) {
    auto pm = repo.findById(EntityId(id));
    if (pm.isNull)
      return PlanningModelResponse.init;
    pm.approve();
    repo.save(pm);
    return PlanningModelResponse.fromEntity(pm);
  }

  CommandResult deletePlanningModel(TenantId tenantId, string id) {
    repo.remove(EntityId(id));
  }
}
