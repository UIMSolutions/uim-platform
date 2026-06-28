/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.datasets;
// import uim.platform.analytics.domain.entities.dataset;
// import uim.platform.analytics.domain.repositories.dataset;


import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
class MemoryDatasetRepository : TenantRepository!(Dataset, DatasetId), DatasetRepository {

  size_t countByDataSource(TenantId tenantId, DataSourceId dataSourceId) {
    return findByDataSource(tenantId, dataSourceId).length;
  }

  Dataset[] filterByDataSource(Dataset[] datasets, DataSourceId dataSourceId) {
    return datasets.filter!(d => d.dataSourceId == dataSourceId).array;
  }

  Dataset[] findByDataSource(TenantId tenantId, DataSourceId dataSourceId) {
    return filterByDataSource(find(tenantId), dataSourceId);
  }

  void removeByDataSource(TenantId tenantId, DataSourceId dataSourceId) {
    foreach (d; findByDataSource(tenantId, dataSourceId))
      remove(d);
  }
}
