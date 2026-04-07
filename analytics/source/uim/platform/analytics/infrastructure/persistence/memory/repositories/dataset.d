/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.dataset;

// import uim.platform.analytics.domain.entities.dataset;
// import uim.platform.analytics.domain.repositories.dataset;
// import uim.platform.analytics.domain.values.common;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class MemoryDatasetRepository : DatasetRepository {
  private Dataset[string] store;

  Dataset findById(EntityId id) {
    if (auto p = id.value in store)
      return *p;
    return null;
  }

  Dataset[] findAll() {
    return store.values;
  }

  void save(Dataset dataset) {
    store[dataset.id.value] = dataset;
  }

  void remove(EntityId id) {
    store.remove(id.value);
  }
}
