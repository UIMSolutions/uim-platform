/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.planning;

// import uim.platform.analytics.domain.entities.planning;
// import uim.platform.analytics.domain.repositories.planning;
import uim.platform.analytics.domain.values.common;

class MemoryPlanningRepository : PlanningRepository {
  private PlanningModel[string] store;

  PlanningModel findById(EntityId id) {
    if (auto p = id.value in store)
      return *p;
    return null;
  }

  PlanningModel[] findAll() {
    return store.values;
  }

  void save(PlanningModel model) {
    store[model.id.value] = model;
  }

  void remove(EntityId id) {
    store.remove(id.value);
  }
}
