module uim.platform.analytics.app.usecases.planning;

// import uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.repositories.planning;
// import uim.platform.analytics.domain.values.common;
// import uim.platform.analytics.domain.values.time_granularity;
// import uim.platform.analytics.app.dto.planning;
// import std.conv : to;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class PlanningUseCases {
    private PlanningRepository repo;

    this(PlanningRepository repo) {
        this.repo = repo;
    }

    PlanningModelResponse create(CreatePlanningModelRequest req) {
        TimeGranularity gran;
        try {
            gran = req.granularity.to!TimeGranularity;
        } catch (Exception) {
            gran = TimeGranularity.Monthly;
        }
        auto pm = PlanningModel.create(req.name, req.description, req.datasetId, gran, req.userId);
        repo.save(pm);
        return PlanningModelResponse.fromEntity(pm);
    }

    PlanningModelResponse getById(string id) {
        return PlanningModelResponse.fromEntity(repo.findById(EntityId(id)));
    }

    PlanningModelResponse[] list() {
        PlanningModelResponse[] result;
        foreach (pm; repo.findAll())
            result ~= PlanningModelResponse.fromEntity(pm);
        return result;
    }

    PlanningModelResponse lock(string id) {
        auto pm = repo.findById(EntityId(id));
        if (pm is null) return PlanningModelResponse.init;
        pm.lock();
        repo.save(pm);
        return PlanningModelResponse.fromEntity(pm);
    }

    PlanningModelResponse approve(string id) {
        auto pm = repo.findById(EntityId(id));
        if (pm is null) return PlanningModelResponse.init;
        pm.approve();
        repo.save(pm);
        return PlanningModelResponse.fromEntity(pm);
    }

    void remove(string id) {
        repo.remove(EntityId(id));
    }
}
