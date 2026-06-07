/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.widgets;
// import uim.platform.analytics.domain.entities.widget;
// import uim.platform.analytics.domain.repositories.widget;
import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
class MemoryWidgetRepository : TenantRepository!(Widget, WidgetId), WidgetRepository {

  size_t countByDataset(TenantId tenantId, EntityId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  Widget[] findByDataset(TenantId tenantId, EntityId datasetId) {
    return findByTenant(tenantId).filter!(w => w.datasetId == datasetId).array;
  }

  void removeByDataset(TenantId tenantId, EntityId datasetId) {
    foreach (w; findByDataset(tenantId, datasetId))
      remove(w);
  }
}
