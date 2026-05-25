module uim.platform.databricks.application.usecases.manage_ml_experiments;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class ManageMlExperimentsUseCase {
private:
  MlExperimentRepository _repo;

public:
  this(MlExperimentRepository repo) { _repo = repo; }

  UseCaseResult!MlExperiment create(CreateMlExperimentRequest r) {
    auto e = MlExperiment();
    e.id               = r.id;
    e.tenantId         = r.tenantId;
    e.workspaceId      = r.workspaceId;
    e.name             = r.name;
    e.artifactLocation = r.artifactLocation;
    e.lifecycleStage   = "active";
    e.ownerId          = r.ownerId;
    e.tags             = r.tags;
    import std.datetime : Clock;
    e.creationTime   = Clock.currTime().toUnixTime() * 1000;
    e.lastUpdateTime = e.creationTime;
    _repo.save(e);
    return UseCaseResult!MlExperiment(true, "ML experiment created", e);
  }

  UseCaseResult!(MlExperiment[]) list(TenantId tenantId) {
    return UseCaseResult!(MlExperiment[])(true, "", _repo.findByTenant(tenantId));
  }

  UseCaseResult!MlExperiment get(TenantId tenantId, MlExperimentId id) {
    auto e = _repo.find(tenantId, id);
    if (e == MlExperiment.init)
      return UseCaseResult!MlExperiment(false, "ML experiment not found", MlExperiment.init);
    return UseCaseResult!MlExperiment(true, "", e);
  }

  UseCaseResult!MlExperiment update(UpdateMlExperimentRequest r) {
    auto e = _repo.find(r.tenantId, r.id);
    if (e == MlExperiment.init)
      return UseCaseResult!MlExperiment(false, "ML experiment not found", MlExperiment.init);
    if (r.name.length > 0) e.name = r.name;
    if (r.tags.length > 0) e.tags = r.tags;
    import std.datetime : Clock;
    e.lastUpdateTime = Clock.currTime().toUnixTime() * 1000;
    _repo.save(e);
    return UseCaseResult!MlExperiment(true, "ML experiment updated", e);
  }

  UseCaseResult!bool remove(TenantId tenantId, MlExperimentId id) {
    auto e = _repo.find(tenantId, id);
    if (e == MlExperiment.init)
      return UseCaseResult!bool(false, "ML experiment not found", false);
    e.lifecycleStage = "deleted";
    _repo.save(e);
    return UseCaseResult!bool(true, "ML experiment deleted", true);
  }
}
