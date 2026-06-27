/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.repositories.dataset;
// import uim.platform.analytics.domain.entities.dataset;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:

interface DatasetRepository : ITenantRepository!(Dataset, DatasetId) {
  
  size_t countByDataSource(TenantId tenantId, DataSourceId dataSourceId);
  Dataset[] findByDataSource(TenantId tenantId, DataSourceId dataSourceId);
  void removeByDataSource(TenantId tenantId, DataSourceId dataSourceId);
  
}
