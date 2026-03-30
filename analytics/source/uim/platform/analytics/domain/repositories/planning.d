module analytics.domain.repositories.planning;

import analytics.domain.entities.planning;
import analytics.domain.values.common;

interface PlanningRepository {
    PlanningModel findById(EntityId id);
    PlanningModel[] findAll();
    void save(PlanningModel model);
    void remove(EntityId id);
}
