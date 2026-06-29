/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.application.usecases.manage_ml_models;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class ManageMlModelsUseCase {
private:
  MlModelRepository _repo;

public:
  this(MlModelRepository repo) { _repo = repo; }

  UseCaseResult!MlModel create(CreateMlModelRequest r) {
    auto m = MlModel();
    m.id            = r.id;
    m.tenantId      = r.tenantId;
    m.workspaceId   = r.workspaceId;
    m.name          = r.name;
    m.description   = r.description;
    m.latestStage   = ModelStage.none_;
    m.latestVersion = "1";
    m.ownerId       = r.ownerId;
    m.source        = r.source;
    m.tags          = r.tags;
    import std.datetime : Clock;
    m.creationTime  = Clock.currTime().toUnixTime() * 1000;
    m.lastUpdatedAt = m.creationTime;
    _repo.save(m);
    return UseCaseResult!MlModel(true, "ML model registered", m);
  }

  UseCaseResult!(MlModel[]) list(TenantId tenantId) {
    return UseCaseResult!(MlModel[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!MlModel get(TenantId tenantId, MlModelId id) {
    auto m = _repo.findById(tenantId, id);
    if (m.isNull)
      return UseCaseResult!MlModel(false, "ML model not found", MlModel.init);
    return UseCaseResult!MlModel(true, "", m);
  }

  UseCaseResult!MlModel update(UpdateMlModelRequest r) {
    auto m = _repo.find(r.tenantId, r.id);
    if (m.isNull)
      return UseCaseResult!MlModel(false, "ML model not found", MlModel.init);
    if (r.description.length > 0) m.description = r.description;
    if (r.tags.length        > 0) m.tags         = r.tags;
    m.latestStage = r.latestStage;
    import std.datetime : Clock;
    m.lastUpdatedAt = Clock.currTime().toUnixTime() * 1000;
    _repo.save(m);
    return UseCaseResult!MlModel(true, "ML model updated", m);
  }

  UseCaseResult!bool remove(TenantId tenantId, MlModelId id) {
    auto m = _repo.findById(tenantId, id);
    if (m.isNull)
      return UseCaseResult!bool(false, "ML model not found", false);
    _repo.remove(m);
    return UseCaseResult!bool(true, "ML model deleted", true);
  }
}
