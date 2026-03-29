module analytics.domain.repositories.planning_repository;

import analytics.domain.entities.planning_model;
import analytics.domain.values.common;

interface PlanningRepository {
    PlanningModel findById(EntityId id);
    PlanningModel[] findAll();
    void save(PlanningModel model);
    void remove(EntityId id);
}
