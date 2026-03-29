module analytics.infrastructure.persistence.memory.repositories.planning;

import analytics.domain.entities.planning_model;
import analytics.domain.repositories.planning;
import analytics.domain.values.common;

class InMemoryPlanningRepository : PlanningRepository {
    private PlanningModel[string] store;

    PlanningModel findById(EntityId id) {
        if (auto p = id.value in store) return *p;
        return null;
    }

    PlanningModel[] findAll() { return store.values; }

    void save(PlanningModel model) { store[model.id.value] = model; }

    void remove(EntityId id) { store.remove(id.value); }
}
