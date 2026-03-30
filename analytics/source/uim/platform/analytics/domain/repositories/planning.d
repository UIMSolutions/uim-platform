module uim.platform.analytics.domain.repositories.planning;

// import uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

interface PlanningRepository {
    PlanningModel findById(EntityId id);
    PlanningModel[] findAll();
    void save(PlanningModel model);
    void remove(EntityId id);
}
