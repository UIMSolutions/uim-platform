/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.widget;
// import uim.platform.analytics.domain.entities.widget;
// import uim.platform.analytics.domain.repositories.widget;
import uim.platform.analytics.domain.values.common;

class MemoryWidgetRepository : TenantRepository!(Widget, EntityId), WidgetRepository {

  size_t countByDataset(EntityId datasetId) {
    return findByDataset(datasetId).length;
  }
  Widget[] findByDataset(EntityId datasetId) {
    return findByTenant(tenantId).filter!(w => w.datasetId == datasetId).array;
  }
  void removeByDataset(EntityId datasetId) {
    findByDataset(datasetId).each!(w => store.remove(w.id.value))  ;
  }

}
