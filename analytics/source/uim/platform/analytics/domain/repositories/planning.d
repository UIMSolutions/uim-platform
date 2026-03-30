module uim.platform.analytics.domain.repositories.planning;

import uim.platform.analytics.domain.entities.planning;
import uim.platform.analytics.domain.values.common;

interface PlanningRepository {
    PlanningModel findById(EntityId id);
    PlanningModel[] findAll();
    void save(PlanningModel model);
    void remove(EntityId id);
}
